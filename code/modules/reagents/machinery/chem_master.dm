
/obj/machinery/chem_master
	name = "ChemMaster 3000"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	circuit = /obj/item/electronics/circuitboard/chemmaster
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	var/obj/item/reagent_containers/glass/beaker = null
	var/mode = 0
	var/condi = 0
	var/useramount = 30 // Last used amount
	var/pillamount = 10
	var/bottlesprite = "bottle"
	var/pillsprite = "1"
	var/client/has_sprites = list()
	var/max_pill_count = 24 //max of pills that can be made in a bottle
	var/max_pill_vol = 60 //max vol pills can have
	reagent_flags = OPENCONTAINER

/obj/machinery/chem_master/RefreshParts()
	if(!reagents)
		create_reagents(10)
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.maximum_volume += G.volume
		G.reagents.trans_to_holder(reagents, G.volume)

/obj/machinery/chem_master/on_deconstruction()
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		var/amount = G.reagents.get_free_space()
		reagents.trans_to_holder(G, amount)
	..()

/obj/machinery/chem_master/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if (prob(50))
				qdel(src)

/obj/machinery/chem_master/MouseDrop_T(atom/movable/I, mob/user, src_location, over_location, src_control, over_control, params)
	if(!Adjacent(user) || !I.Adjacent(user) || user.stat)
		return ..()
	if(istype(I, /obj/item/reagent_containers) && I.is_open_container() && !beaker)
		I.forceMove(src)
		I.add_fingerprint(user)
		src.beaker = I
		to_chat(user, SPAN_NOTICE("You add [I] to [src]."))
		updateUsrDialog()
		icon_state = "mixer1"
		return
	. = ..()

/obj/machinery/chem_master/attackby(var/obj/item/B as obj, var/mob/user as mob)
	if(default_deconstruction(B, user))
		return

	if(default_part_replacement(B, user))
		return

	if(istype(B, /obj/item/reagent_containers/glass))

		if(src.beaker)
			to_chat(user, "A beaker is already loaded into the machine.")
			return

		if (usr.unEquip(B, src))
			src.beaker = B
			to_chat(user, "You add the beaker to the machine!")
			icon_state = "mixer1"
		updateUsrDialog()

	return

/obj/machinery/chem_master/Topic(href, href_list)
	if(..())
		return 1

	else if(href_list["close"])
		usr << browse(null, "window=chemmaster")
		usr.unset_machine()
		return

	if(beaker)
		var/datum/reagents/R = beaker.reagents
		if (href_list["analyze"])
			var/dat = ""
			if(!condi)
				if(href_list["name"] == "Blood")
					var/datum/reagent/organic/blood/G
					for(var/datum/reagent/F in R.reagent_list)
						if(F.name == href_list["name"])
							G = F
							break
					var/A = G.name
					var/B = G.data["blood_type"]
					var/C = G.data["blood_DNA"]
					dat += "<TITLE>Chemmaster 3000</TITLE>Chemical infos:<BR><BR>Name:<BR>[A]<BR><BR>Description:<BR>Blood Type: [B]<br>DNA: [C]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
				else
					dat += "<TITLE>Chemmaster 3000</TITLE>Chemical infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			else
				dat += "<TITLE>Condimaster 3000</TITLE>Condiment infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			usr << browse(dat, "window=chem_master;size=575x400")
			return

		else if (href_list["add"])
			if(href_list["amount"])
				var/id = href_list["add"]
				var/amount = CLAMP(text2num(href_list["amount"]), 0, reagents.get_free_space())
				R.trans_id_to(src, id, amount)
				if(reagents.get_free_space() < 1)
					to_chat(usr, SPAN_WARNING("The [name] is full!"))

		else if (href_list["addcustom"])
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			src.Topic(null, list("amount" = "[useramount]", "add" = href_list["addcustom"]))

		else if (href_list["remove"])
			if(href_list["amount"])
				var/id = href_list["remove"]
				var/amount = CLAMP(text2num(href_list["amount"]), 0, beaker.reagents.get_free_space())
				if(mode)
					reagents.trans_id_to(beaker, id, amount)
					if(beaker.reagents.get_free_space() < 1)
						to_chat(usr, SPAN_WARNING("The [name] is full!"))
				else
					reagents.remove_reagent(id, amount)


		else if (href_list["removecustom"])
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			src.Topic(null, list("amount" = "[useramount]", "remove" = href_list["removecustom"]))

		else if (href_list["toggle"])
			mode = !mode

		else if (href_list["main"])
			attack_hand(usr)
			return
		else if (href_list["eject"])
			if(beaker)
				beaker:loc = src.loc
				beaker = null
				reagents.clear_reagents()
				icon_state = "mixer0"

		else if (href_list["createpill"] || href_list["createpill_multiple"])
			var/count = 0
			var/amount_per_pill = 0

			if(!reagents.total_volume) //Sanity checking.
				return
			var/create_pill_bottle = FALSE
			if (href_list["createpill_multiple"])
				if(alert("Create bottle ?","Container.","Yes","No") == "Yes")
					create_pill_bottle = TRUE
				switch(alert("How to create pills.","Choose method.","By amount","By volume"))
					if("By amount")
						count = input("Select the number of pills to make.", "Max [max_pill_count]", pillamount) as num
						if (count > max_pill_count)
							alert("Maximum supported pills amount is [max_pill_count]","Error.","Ok")
							return
						if (pillamount > max_pill_vol)
							alert("Maximum volume supported in pills is [max_pill_vol]","Error.","Ok")
							return
						
						count = CLAMP(count, 1, max_pill_count)
					if("By volume")
						amount_per_pill = input("Select the volume that single pill should contain.", "Max [R.total_volume]", 5) as num
						amount_per_pill = CLAMP(amount_per_pill, 1, reagents.total_volume)
						if (amount_per_pill > max_pill_vol)
							alert("Maximum volume supported in pills is [max_pill_vol]","Error.","Ok")
							return
						if ((reagents.total_volume / amount_per_pill) > max_pill_count)
							alert("Maximum supported pills amount is [max_pill_count]","Error.","Ok")
							return
					else
						return
			else
				count = 1

			if(count)
				if(reagents.total_volume < count) //Sanity checking.
					return
				amount_per_pill = reagents.total_volume/count

			if (amount_per_pill > max_pill_vol) amount_per_pill = max_pill_vol

			var/name = sanitizeSafe(input(usr,"Name:","Name your pill!","[reagents.get_master_reagent_name()] ([amount_per_pill] units)"), MAX_NAME_LEN)
			var/obj/item/storage/pill_bottle/PB
			if(create_pill_bottle)
				PB = new(get_turf(src))
				PB.name = "[PB.name] ([name])"
			while (reagents.total_volume)
				var/obj/item/reagent_containers/pill/P = new/obj/item/reagent_containers/pill(src.loc)
				if(!name) name = reagents.get_master_reagent_name()
				P.name = "[name] pill"
				P.pixel_x = rand(-7, 7) //random position
				P.pixel_y = rand(-7, 7)
				P.icon_state = "pill"+pillsprite
				reagents.trans_to_obj(P,amount_per_pill)
				if(PB)
					P.forceMove(PB)
					src.updateUsrDialog()

		else if (href_list["createbottle"])
			if(!condi)
				var/name = sanitizeSafe(input(usr,"Name:","Name your bottle!",reagents.get_master_reagent_name()), MAX_NAME_LEN)
				var/obj/item/reagent_containers/glass/bottle/P = new/obj/item/reagent_containers/glass/bottle(src.loc)
				if(!name) name = reagents.get_master_reagent_name()
				P.name = "[name] bottle"
				P.pixel_x = rand(-7, 7) //random position
				P.pixel_y = rand(-7, 7)
				P.icon_state = bottlesprite
				reagents.trans_to_obj(P,60)
				P.toggle_lid()
			else
				var/obj/item/reagent_containers/food/condiment/P = new/obj/item/reagent_containers/food/condiment(src.loc)
				reagents.trans_to_obj(P,50)
		else if(href_list["change_pill"])
			#define MAX_PILL_SPRITE 20 //max icon state of the pill sprites
			var/dat = "<table>"
			for(var/i = 1 to MAX_PILL_SPRITE)
				dat += "<tr><td><a href=\"?src=\ref[src]&pill_sprite=[i]\"><img src=\"pill[i].png\" /></a></td></tr>"
			dat += "</table>"
			usr << browse(dat, "window=chem_master")
			return
		else if(href_list["change_bottle"])
			var/dat = "<table>"
			for(var/sprite in BOTTLE_SPRITES)
				dat += "<tr><td><a href=\"?src=\ref[src]&bottle_sprite=[sprite]\"><img src=\"[sprite].png\" /></a></td></tr>"
			dat += "</table>"
			usr << browse(dat, "window=chem_master")
			return
		else if(href_list["pill_sprite"])
			pillsprite = href_list["pill_sprite"]
		else if(href_list["bottle_sprite"])
			bottlesprite = href_list["bottle_sprite"]

	playsound(loc, 'sound/machines/button.ogg', 100, 1)
	src.updateUsrDialog()
	return

/obj/machinery/chem_master/attack_hand(mob/user)
	if(inoperable())
		return
	user.set_machine(src)
	if(!(user.client in has_sprites))
		spawn()
			has_sprites += user.client
			for(var/i = 1 to MAX_PILL_SPRITE)
				usr << browse_rsc(icon('icons/obj/chemical.dmi', "pill" + num2text(i)), "pill[i].png")
			for(var/sprite in BOTTLE_SPRITES)
				usr << browse_rsc(icon('icons/obj/chemical.dmi', sprite), "[sprite].png")
	var/dat = ""
	if(!beaker)
		dat = "Please insert beaker.<BR>"
		dat += "<A href='?src=\ref[src];close=1'>Close</A>"
	else
		var/datum/reagents/R = beaker:reagents
		dat += "<A href='?src=\ref[src];eject=1'>Eject beaker and Clear Buffer</A><BR>"
		if(!R.total_volume)
			dat += "Beaker is empty."
		else
			var/free_space = reagents.get_free_space()
			dat += "Add to buffer:<BR>"
			for(var/datum/reagent/G in R.reagent_list)
				dat += "[G.name] , [G.volume] Units - "
				dat += "<A href='?src=\ref[src];analyze=1;desc=[G.description];name=[G.name]'>(Analyze)</A> "
				for(var/volume in list(1, 5, 10))
					if(free_space >= volume)
						dat += "<A href='?src=\ref[src];add=[G.id];amount=[volume]'>([volume])</A> "
					else
						dat += "([volume]) "
				dat += "<A href='?src=\ref[src];add=[G.id];amount=[G.volume]'>(All)</A> "
				dat += "<A href='?src=\ref[src];addcustom=[G.id]'>(Custom)</A><BR>"
			if(free_space < 1)
				dat += "The [name] is full!"

		dat += "<HR>Transfer to <A href='?src=\ref[src];toggle=1'>[(!mode ? "disposal" : "beaker")]:</A><BR>"
		if(reagents.total_volume)
			for(var/datum/reagent/N in reagents.reagent_list)
				dat += "[N.name] , [N.volume] Units - "
				dat += "<A href='?src=\ref[src];analyze=1;desc=[N.description];name=[N.name]'>(Analyze)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.id];amount=1'>(1)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.id];amount=5'>(5)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.id];amount=10'>(10)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.id];amount=[N.volume]'>(All)</A> "
				dat += "<A href='?src=\ref[src];removecustom=[N.id]'>(Custom)</A><BR>"
		else
			dat += "Empty<BR>"
		if(!condi)
			dat += "<HR><BR><A href='?src=\ref[src];createpill=1'>Create pill ([max_pill_count] units max)</A><a href=\"?src=\ref[src]&change_pill=1\"><img src=\"pill[pillsprite].png\" /></a><BR>"
			dat += "<A href='?src=\ref[src];createpill_multiple=1'>Create multiple pills</A><BR>"
			dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle (60 units max)<a href=\"?src=\ref[src]&change_bottle=1\"><img src=\"[bottlesprite].png\" /></A>"
		else
			dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle (50 units max)</A>"
	if(!condi)
		user << browse("<TITLE>Chemmaster 3000</TITLE>Chemmaster menu:<BR><BR>[dat]", "window=chem_master;size=575x400")
	else
		user << browse("<TITLE>Condimaster 3000</TITLE>Condimaster menu:<BR><BR>[dat]", "window=chem_master;size=575x400")
	onclose(user, "chem_master")
	return

/obj/machinery/chem_master/condimaster
	name = "CondiMaster 3000"
	condi = 1

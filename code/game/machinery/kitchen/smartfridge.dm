/* SmartFridge.  Much todo
*/
/obj/machinery/smartfridge
	name = "\improper SmartFridge"
	icon = 'icons/obj/vending.dmi'
	icon_state = "smartfridge"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	reagent_flags = NO_REACT
	var/global/max_n_of_items = 999 // Sorry but the BYOND infinite loop detector doesn't look things over 1000.
	var/icon_on = "smartfridge"
	var/icon_off = "smartfridge-off"
	var/icon_panel = "smartfridge-panel"
	var/icon_fill10 = "smartfridge-fill10"
	var/icon_fill20 = "smartfridge-fill20"
	var/icon_fill30 = "smartfridge-fill30"
	var/list/item_quants = list()
	var/seconds_electrified = 0;
	var/shoot_inventory = 0
	var/locked = 0
	var/scan_id = 1
	var/is_secure = 0
	var/datum/wires/smartfridge/wires = null



/obj/machinery/smartfridge/secure
	name = "\improper Secure SmartFridge"
	is_secure = 1




/*******************
*   Seed Storage
********************/
/obj/machinery/smartfridge/seeds
	name = "\improper Refrigerated Seeds Storage"
	desc = "When you need seeds fast!"

/obj/machinery/smartfridge/seeds/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/seeds/))
		return 1
	return 0

/obj/machinery/smartfridge/kitchen
	name = "\improper Agro-Club Fridge"
	desc = "The panel says it won't allow anyone without access to the kitchen or hydroponics."
	req_one_access = list(access_hydroponics,access_kitchen)



/*******************
*   Xenobio Slime Fridge
********************/
/obj/machinery/smartfridge/secure/extract
	name = "\improper Slime Extract Storage"
	desc = "A refrigerated storage unit for slime extracts"
	req_access = list(access_moebius)

/obj/machinery/smartfridge/secure/extract/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/slime_extract))
		return 1
	return 0



/*******************
*   Chemistry Medicine Storage
********************/
/obj/machinery/smartfridge/secure/medbay
	name = "\improper Refrigerated Medicine Storage"
	desc = "A refrigerated storage unit for storing medicine and chemicals."
	req_one_access = list(access_moebius,access_chemistry)

/obj/machinery/smartfridge/secure/medbay/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/weapon/reagent_containers/glass/))
		return 1
	if(istype(O,/obj/item/weapon/storage/pill_bottle/))
		return 1
	if(istype(O,/obj/item/weapon/reagent_containers/pill/))
		return 1
	return 0


/*******************
*   Virus Storage
********************/
/obj/machinery/smartfridge/secure/virology
	name = "\improper Refrigerated Virus Storage"
	desc = "A refrigerated storage unit for storing viral material."
	req_access = list(access_virology)
	icon_state = "smartfridge_virology"
	icon_on = "smartfridge_virology"
	icon_off = "smartfridge_virology-off"

/obj/machinery/smartfridge/secure/virology/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/weapon/reagent_containers/glass/beaker/vial/))
		return 1
	if(istype(O,/obj/item/weapon/virusdish/))
		return 1
	return 0

/obj/machinery/smartfridge/chemistry
	name = "\improper Smart Chemical Storage"
	desc = "A refrigerated storage unit for medicine and chemical storage."

/obj/machinery/smartfridge/chemistry/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/weapon/storage/pill_bottle) || istype(O,/obj/item/weapon/reagent_containers))
		return 1
	return 0

/obj/machinery/smartfridge/chemistry/virology
	name = "\improper Smart Virus Storage"
	desc = "A refrigerated storage unit for volatile sample storage."



/*************************
*   Bar Drinks Showcase
**************************/
/obj/machinery/smartfridge/drinks
	name = "\improper Drink Showcase"
	desc = "A refrigerated storage unit for tasty tasty alcohol."
	icon_state = "showcase"
	icon_on = "showcase"
	icon_off = "showcase-off"
	icon_panel = "showcase-panel"
	var/icon_fill = "showcase-fill"

/obj/machinery/smartfridge/drinks/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/weapon/reagent_containers/glass) || istype(O,/obj/item/weapon/reagent_containers/food/drinks) || istype(O,/obj/item/weapon/reagent_containers/food/condiment))
		return 1

/obj/machinery/smartfridge/drinks/on_update_icon()
	cut_overlays()
	if(stat & (BROKEN|NOPOWER))
		icon_state = icon_off
	else
		icon_state = icon_on

	if(panel_open && icon_panel)
		add_overlays(image(icon, icon_panel))

	if(contents.len && !(stat & NOPOWER))
		add_overlays(image(icon, icon_fill))


/***************************
*   Hydroponics Drying Rack
****************************/
/obj/machinery/smartfridge/drying_rack
	name = "\improper Drying Rack"
	desc = "A machine for drying plants."
	icon_state = "drying_rack"
	icon_on = "drying_rack_on"
	icon_off = "drying_rack"
	var/drying_power = 0.1 //should take a bit but. why make people wait a lifetime to DRY PLANTS
	var/currently_drying = FALSE

/obj/machinery/smartfridge/drying_rack/accept_check(var/obj/item/O as obj)
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/))
		var/obj/item/weapon/reagent_containers/food/snacks/S = O
		if (S.dried_type)
			return 1
	return 0

/obj/machinery/smartfridge/drying_rack/Process()
	..()
	if(inoperable())
		return
	if(contents.len)
		dry()

/obj/machinery/smartfridge/drying_rack/on_update_icon()
	cut_overlays()
	if(inoperable())
		icon_state = icon_off
	else
		icon_state = icon_on
	if(contents.len)
		add_overlays("drying_rack_filled")
		if(!inoperable() && currently_drying)
			add_overlays("drying_rack_drying")

/obj/machinery/smartfridge/drying_rack/proc/dry()
	var/drying_something = FALSE //While we're here, check if anything is undried and still processing
	for(var/obj/item/weapon/reagent_containers/food/snacks/S in contents)
		if(S.dry)
			continue
		S.dryness += drying_power
		if (S.dryness >= 1)
			if(S.dried_type == S.type || !S.dried_type)
				S.dry = TRUE
				S.name = "dried [S.name]"
				S.color = "#AAAAAA"
			else
				var/D = S.dried_type
				D = new D(src)
				if (istype(D, /obj/item/weapon/reagent_containers/food/snacks))
					var/obj/item/weapon/reagent_containers/food/snacks/SD = D
					SD.dry = TRUE //So we dont get stuck in an endless loop of drying, transforming and drying again
				qdel(S)
			update_contents()
		else
			drying_something = TRUE

	if (drying_something != currently_drying)
		currently_drying = drying_something
		update_icon() //Only update the icon if we have to
	currently_drying = drying_something
	return












/obj/machinery/smartfridge/New()
	..()
	if(is_secure)
		wires = new/datum/wires/smartfridge/secure(src)
	else
		wires = new/datum/wires/smartfridge(src)

/obj/machinery/smartfridge/Destroy()
	qdel(wires)
	wires = null
	return ..()

/obj/machinery/smartfridge/proc/accept_check(var/obj/item/O as obj)
	if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/grown/) || istype(O,/obj/item/seeds/) || istype(O,/obj/item/weapon/reagent_containers/food/snacks/meat/) || istype(O,/obj/item/weapon/reagent_containers/food/snacks/egg/))
		return 1
	return 0


/obj/machinery/smartfridge/Process()
	if(stat & (BROKEN|NOPOWER))
		return
	if(src.seconds_electrified > 0)
		src.seconds_electrified--
	if(src.shoot_inventory && prob(2))
		src.throw_item()

/obj/machinery/smartfridge/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/smartfridge/on_update_icon()
	cut_overlays()
	if(stat & (BROKEN|NOPOWER))
		icon_state = icon_off
	else
		icon_state = icon_on

	if(panel_open && icon_panel)
		add_overlays(image(icon, icon_panel))

	if(contents.len)
		if(contents.len <= 10)
			add_overlays(image(icon, icon_fill10))
		else if(contents.len <= 20)
			add_overlays(image(icon, icon_fill20))
		else
			add_overlays(image(icon, icon_fill30))

/*******************
*   Item Adding
********************/

/obj/machinery/smartfridge/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/tool/screwdriver))
		panel_open = !panel_open
		user.visible_message("[user] [panel_open ? "opens" : "closes"] the maintenance panel of \the [src].", "You [panel_open ? "open" : "close"] the maintenance panel of \the [src].")
		update_icon()
		SSnano.update_uis(src)
		return

	if(istype(O, /obj/item/weapon/tool/multitool)||istype(O, /obj/item/weapon/tool/wirecutters))
		if(panel_open)
			attack_hand(user)
		return

	if(stat & NOPOWER)
		to_chat(user, SPAN_NOTICE("\The [src] is unpowered and useless."))
		return

	if(accept_check(O))
		if(contents.len >= max_n_of_items)
			to_chat(user, SPAN_NOTICE("\The [src] is full."))
			return 1
		else
			user.remove_from_mob(O)
			O.forceMove(src)
			update_contents()
			user.visible_message(SPAN_NOTICE("[user] has added \the [O] to \the [src]."), SPAN_NOTICE("You add \the [O] to \the [src]."))
			update_icon()
			SSnano.update_uis(src)

	else if(istype(O, /obj/item/weapon/storage/bag))
		var/obj/item/weapon/storage/bag/P = O
		var/plants_loaded = 0
		for(var/obj/G in P.contents)
			if(accept_check(G))
				if(contents.len >= max_n_of_items)
					to_chat(user, SPAN_NOTICE("\The [src] is full."))
					return 1
				else
					P.remove_from_storage(G,src)
					plants_loaded++
		if(plants_loaded)
			update_contents()
			update_icon()
			user.visible_message(SPAN_NOTICE("[user] loads \the [src] with \the [P]."), SPAN_NOTICE("You load \the [src] with \the [P]."))
			if(P.contents.len > 0)
				to_chat(user, SPAN_NOTICE("Some items are refused."))

		SSnano.update_uis(src)

	else
		to_chat(user, SPAN_NOTICE("\The [src] smartly refuses [O]."))
		return 1

/obj/machinery/smartfridge/secure/emag_act(var/remaining_charges, var/mob/user)
	if(!emagged)
		emagged = 1
		locked = -1
		to_chat(user, "You short out the product lock on [src].")
		return 1

/obj/machinery/smartfridge/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	wires.Interact(user)
	nano_ui_interact(user)


/obj/machinery/smartfridge/proc/update_contents()
	item_quants.Cut()
	for (var/obj/item/i in contents)
		item_quants[i.name] = (item_quants[i.name] ? item_quants[i.name]+1 : 1)
/*******************
*   SmartFridge Menu
********************/

/obj/machinery/smartfridge/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	user.set_machine(src)

	var/data[0]
	data["contents"] = null
	data["electrified"] = seconds_electrified > 0
	data["shoot_inventory"] = shoot_inventory
	data["locked"] = locked
	data["secure"] = is_secure

	var/list/items[0]
	for (var/i=1 to length(item_quants))
		var/K = item_quants[i]
		var/count = item_quants[K]
		if(count > 0)
			items.Add(list(list("display_name" = html_encode(capitalize(K)), "vend" = i, "quantity" = count)))

	if(items.len > 0)
		data["contents"] = items

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "smartfridge.tmpl", src.name, 400, 500)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/smartfridge/Topic(href, href_list)
	if(..()) return 0

	var/mob/user = usr
	var/datum/nanoui/ui = SSnano.get_open_ui(user, src, "main")

	src.add_fingerprint(user)

	if(href_list["close"])
		user.unset_machine()
		ui.close()
		return 0

	if(href_list["vend"])
		var/index = text2num(href_list["vend"])
		var/amount = text2num(href_list["amount"])
		var/K = item_quants[index]
		var/count = item_quants[K]

		// Sanity check, there are probably ways to press the button when it shouldn't be possible.
		if(count > 0)
			item_quants[K] = max(count - amount, 0)

			var/i = amount
			for(var/obj/O in contents)
				if(O.name == K)
					O.loc = loc
					i--
					if(i <= 0)
						update_contents()
						update_icon()
						return 1

		update_contents()
		update_icon()
		return 1
	return 0

/obj/machinery/smartfridge/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return 0

	for (var/O in item_quants)
		if(item_quants[O] <= 0) //Try to use a record that actually has something to dump.
			continue

		item_quants[O]--
		for(var/obj/T in contents)
			if(T.name == O)
				T.loc = src.loc
				throw_item = T
				break
		break
	update_contents()
	if(!throw_item)
		return 0
	spawn(0)
		throw_item.throw_at(target,16,3,src)
	src.visible_message(SPAN_WARNING("[src] launches [throw_item.name] at [target.name]!"))
	return 1

/************************
*   Secure SmartFridges
*************************/

/obj/machinery/smartfridge/secure/Topic(href, href_list)
	if(stat & (NOPOWER|BROKEN)) return 0
	if(usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf)))
		if(!allowed(usr) && !emagged && locked != -1 && href_list["vend"])
			to_chat(usr, SPAN_WARNING("Access denied."))
			return 0
	return ..()

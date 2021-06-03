#define REAGENTS_PER_SHEET 20

/obj/machinery/reagentgrinder
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	var/nano_template
	var/limit = 10
	var/list/holdingitems = list()
	var/list/sheet_reagents = list(
		/obj/item/stack/material/iron = "iron",
		/obj/item/stack/material/uranium = "uranium",
		/obj/item/stack/material/plasma = "plasma",
		/obj/item/stack/material/gold = "gold",
		/obj/item/stack/material/silver = "silver",
		/obj/item/stack/material/mhydrogen = "hydrogen",
	)

/obj/machinery/reagentgrinder/MouseDrop_T(atom/movable/I, mob/user, src_location, over_location, src_control, over_control, params)
	if(!Adjacent(user) || !I.Adjacent(user) || user.incapacitated())
		return ..()
	insert(I, user)
	. = ..()

/obj/machinery/reagentgrinder/attackby(obj/item/I, mob/user)
	if(default_deconstruction(I, user))
		return
	//Useability tweak for borgs
	if (istype(I,/obj/item/weapon/gripper))
		nano_ui_interact(user)
		return
	return insert(I, user)

/obj/machinery/reagentgrinder/proc/insert(obj/item/I, mob/user)
	if(!istype(I))
		return

	if(holdingitems && holdingitems.len >= limit)
		to_chat(user, "The machine cannot hold anymore items.")
		return 1

	if(istype(I,/obj/item/weapon/storage/bag/produce))
		var/obj/item/weapon/storage/bag/produce/bag = I
		var/failed = 1
		for(var/obj/item/G in bag.contents)
			if(!G.reagents || !G.reagents.total_volume)
				continue
			failed = 0
			bag.remove_from_storage(G, src)
			holdingitems += G
			if(holdingitems && holdingitems.len >= limit)
				break

		if(failed)
			to_chat(user, "Nothing in the plant bag is usable.")
			return 1

		if(!bag.contents.len)
			to_chat(user, "You empty \the [bag] into \the [src].")
		else
			to_chat(user, "You fill \the [src] from \the [bag].")

		SSnano.update_uis(src)
		return 0

	if(!is_type_in_list(I, sheet_reagents) && (!I.reagents || !I.reagents.total_volume))
		to_chat(user, "\The [I] is not suitable for blending.")
		return 1

	if(I.loc == user)
		user.remove_from_mob(I)
	else
		I.add_fingerprint(user)
	I.forceMove(src)
	holdingitems += I
	SSnano.update_uis(src)
	return 0

/obj/machinery/reagentgrinder/attack_ai(mob/user as mob)
	return 0

/obj/machinery/reagentgrinder/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	user.set_machine(src)
	nano_ui_interact(user)

/obj/machinery/reagentgrinder/on_deconstruction()
	eject()

/obj/machinery/reagentgrinder/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = NANOUI_FOCUS)
	if(!nano_template)
		return

	var/list/data = nano_ui_data()

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, nano_template, name, 400, 550)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/reagentgrinder/nano_ui_data()
	var/list/data = list()

	data["contents"] = list()
	for (var/obj/item/I in holdingitems)
		var/obj/item/stack/stack = I
		if(istype(stack) && stack.get_amount() > 1)
			data["contents"] += "[stack.get_amount()] [I.name]"
		else
			data["contents"] += "\A [I.name]"
	return data

/obj/machinery/reagentgrinder/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["eject"])
		eject()
		return 1

/obj/machinery/reagentgrinder/proc/eject()
	if(!holdingitems || holdingitems.len == 0)
		return

	for(var/obj/item/I in holdingitems)
		I.forceMove(loc)
		holdingitems -= I
	holdingitems.Cut()

/obj/machinery/reagentgrinder/proc/grind_item(obj/item/I, datum/reagents/target)
	for(var/path in sheet_reagents)
		if(!istype(I, path))
			continue
		var/obj/item/stack/stack = I
		var/amount_to_take = max(0, min(stack.get_amount(), round((target.maximum_volume - target.total_volume) / REAGENTS_PER_SHEET)))
		if(amount_to_take)
			stack.use(amount_to_take)
			if(QDELETED(stack))
				holdingitems -= stack
			target.add_reagent(sheet_reagents[path], (amount_to_take * REAGENTS_PER_SHEET))
			return
		break

	if(I.reagents)
		I.reagents.trans_to(target, I.reagents.total_volume)
		if(I.reagents.total_volume == 0)
			holdingitems -= I
			qdel(I)



/obj/machinery/reagentgrinder/portable
	name = "All-In-One Grinder"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = BELOW_OBJ_LAYER
	density = FALSE
	anchored = FALSE
	circuit = /obj/item/weapon/electronics/circuitboard/reagentgrinder
	nano_template = "grinder.tmpl"
	var/inuse = 0
	var/obj/item/weapon/reagent_containers/beaker = null

/obj/item/weapon/electronics/circuitboard/reagentgrinder
	name = T_BOARD("reagent grinder")
	board_type = "machine"
	build_path = /obj/machinery/reagentgrinder/portable
	origin_tech = list(TECH_BIO = 1)
	req_components = list(
		/obj/item/weapon/stock_parts/manipulator = 2
	)

/obj/machinery/reagentgrinder/portable/Initialize()
	. = ..()
	beaker = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)

/obj/machinery/reagentgrinder/portable/on_update_icon()
	icon_state = "juicer"+num2text(!isnull(beaker))
	return

/obj/machinery/reagentgrinder/portable/insert(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/reagent_containers) && I.is_open_container() && !beaker)
		if(I.loc == user)
			user.remove_from_mob(I)
		I.forceMove(src)
		beaker = I
		to_chat(user, SPAN_NOTICE("You add [I] to [src]."))
		SSnano.update_uis(src)
		update_icon()
		return 0

	return ..()

/obj/machinery/reagentgrinder/portable/nano_ui_data()
	var/list/data = ..()
	data["on"] = inuse

	if(beaker)
		data["beaker"] = beaker.reagents.nano_ui_data()
	return data

/obj/machinery/reagentgrinder/portable/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["detach"])
		detach()
	if(href_list["grind"])
		grind()
	playsound(loc, 'sound/machines/machine_switch.ogg', 100, 1)
	return 1

/obj/machinery/reagentgrinder/portable/proc/detach()
	if(!beaker)
		return
	beaker.forceMove(loc)
	beaker = null
	update_icon()

/obj/machinery/reagentgrinder/portable/AltClick(mob/living/user)
	if(user.incapacitated())
		to_chat(user, SPAN_WARNING("You can't do that right now!"))
		return
	if(!in_range(src, user))
		return
	src.detach()

/obj/machinery/reagentgrinder/portable/proc/grind()
	power_change()
	if(stat & (NOPOWER|BROKEN))
		return

	// Sanity check.
	if(!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return

	playsound(loc, 'sound/machines/blender.ogg', 50, 1)
	inuse = 1

	// Reset the machine.
	spawn(60)
		inuse = 0
		SSnano.update_uis(src)

	// Process.
	for(var/obj/item/I in holdingitems)
		if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break

		grind_item(I, beaker.reagents)



/obj/machinery/reagentgrinder/industrial
	name = "Industrial Grinder"
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/machines/grinder.dmi'
	icon_state = "grinder"
	reagent_flags = NO_REACT
	circuit = /obj/item/weapon/electronics/circuitboard/industrial_grinder
	limit = 25
	nano_template = "industrial_grinder.tmpl"

/obj/item/weapon/electronics/circuitboard/industrial_grinder
	name = T_BOARD("industrial grinder")
	board_type = "machine"
	build_path = /obj/machinery/reagentgrinder/industrial
	origin_tech = list(TECH_BIO = 1)
	rarity_value = 10
	req_components = list(
		/obj/item/weapon/stock_parts/manipulator = 2,
		/obj/item/weapon/stock_parts/scanning_module = 1,
	)

/obj/machinery/reagentgrinder/industrial/Initialize()
	. = ..()
	create_reagents(INFINITY)

/obj/machinery/reagentgrinder/industrial/Process()
	if(stat & (NOPOWER|BROKEN))
		return
	grind()

/obj/machinery/reagentgrinder/industrial/on_update_icon()
	cut_overlays()

	if(panel_open)
		add_overlays(image(icon, "[icon_state]_p"))

/obj/machinery/reagentgrinder/industrial/nano_ui_data()
	var/list/data = ..()

	data["reagents"] = reagents.nano_ui_data()
	return data

/obj/machinery/reagentgrinder/industrial/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["bottle"])
		bottle(href_list["bottle"])
	return 1

/obj/machinery/reagentgrinder/industrial/proc/bottle(id)
	var/obj/item/weapon/reagent_containers/glass/bottle/P = new(loc)

	if(!reagents.trans_id_to(P, id, 60))
		qdel(P)
		return

	P.name = "[get_reagent_name_by_id(id)] bottle"
	P.pixel_x = rand(-7, 7)
	P.pixel_y = rand(-7, 7)
	P.icon_state = pick(BOTTLE_SPRITES)
	P.toggle_lid()

/obj/machinery/reagentgrinder/industrial/proc/grind()
	var/obj/item/I = locate() in holdingitems
	if(!I)
		return

	grind_item(I, reagents)

	for(var/datum/reagent/R in reagents.reagent_list)
		while(R.volume >= 60)
			bottle(R.id)

	SSnano.update_uis(src)



/obj/item/weapon/storage/makeshift_grinder
	name = "makeshift grinder"
	desc = "Mortar and pestle to grind ingridients."
	icon = 'icons/obj/machines/chemistry.dmi'
	icon_state = "mortar"
	storage_slots = 3
	unacidable = 1
	rarity_value = 25
	spawn_tags = SPAWN_TAG_ITEM_UTILITY
	reagent_flags = REFILLABLE | DRAINABLE
	var/amount_per_transfer_from_this = 10
	var/possible_transfer_amounts = list(5,10,30,60)

/obj/item/weapon/storage/makeshift_grinder/Initialize(mapload, ...)
	. = ..()
	create_reagents(60)

/obj/item/weapon/storage/makeshift_grinder/attack_self(mob/user)
	var/time_to_finish = 60 - (40 * user.stats.getMult(STAT_TGH, STAT_LEVEL_ADEPT))
	var/datum/repeating_sound/toolsound = new/datum/repeating_sound(8,time_to_finish,0.15, src, 'sound/effects/impacts/thud2.ogg', 50, 1)
	user.visible_message(SPAN_NOTICE("[user] grind contents of \the [src]."), SPAN_NOTICE("You starting to grind contents of \the [src]."))
	if(do_after(user,time_to_finish))
		grind()
		update_icon()
		refresh_all()
		if (toolsound)
			toolsound.stop()
			toolsound = null

/obj/item/weapon/storage/makeshift_grinder/proc/grind()
	// Sanity check.
	if (!reagents || (reagents.total_volume >= reagents.maximum_volume))
		return

	// Process.
	for (var/obj/item/O in src.contents)
		var/remaining_volume = reagents.maximum_volume - reagents.total_volume
		if(remaining_volume <= 0)
			break

		if(get_material_name_by_stack_type(O.type))
			var/obj/item/stack/stack = O
			if(istype(stack))
				var/amount_to_take = max(0,min(stack.amount,round(remaining_volume/REAGENTS_PER_SHEET)))
				if(amount_to_take)
					stack.use(amount_to_take)
					if(QDELETED(stack))
						src.contents.Remove(O)
					reagents.add_reagent(get_material_name_by_stack_type(stack.type), (amount_to_take*REAGENTS_PER_SHEET))
					if(stack.reagents)
						for(var/datum/reagent/R in stack.reagents.reagent_list)
							reagents.add_reagent(R.id, R.volume)
					continue

		if(O.reagents)
			O.reagents.trans_to(reagents, min(O.reagents.total_volume, remaining_volume))
			if(O.reagents.total_volume == 0)
				qdel(O)
				src.contents.Remove(O)
			if (reagents.total_volume >= reagents.maximum_volume)
				break

/obj/item/weapon/storage/makeshift_grinder/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/container = I
		if(!container.standard_pour_into(user, src)) . = ..()
	else if (LAZYLEN(I.reagents)) . = ..()
	else to_chat(user, SPAN_NOTICE("\icon[I] \the [I] seems that it is not suitable for a \icon[src] [src]."))
	update_icon()

/obj/item/weapon/storage/makeshift_grinder/afterattack(atom/target, mob/user, flag)
	// Ensure we don't splash beakers and similar containers.
	if(user.a_intent == I_HURT)
		if(!istype(target))
			return FALSE

		if(!reagents.total_volume)
			to_chat(user, SPAN_NOTICE("[src] is empty."))
			return TRUE

		user.visible_message(
			SPAN_DANGER("[target] has been splashed with something by [user]!"),
			SPAN_NOTICE("You splash the solution onto [target].")
		)

		reagents.splash(target, reagents.total_volume)
		update_icon()
		return TRUE
	else
		if(!target.is_refillable())
			if(istype(target, /obj/item/weapon/reagent_containers))
				var/obj/item/weapon/reagent_containers/container = target
				container.is_closed_message(user)
				return TRUE
			// Otherwise don't care about splashing.
			else
				return ..()

		if(!reagents.total_volume)
			to_chat(user, SPAN_NOTICE("[src] is empty."))
			return TRUE

		if(!target.reagents.get_free_space())
			to_chat(user, SPAN_NOTICE("[target] is full."))
			return TRUE

		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
		playsound(src,'sound/effects/Liquid_transfer_mono.ogg',50,1)
		to_chat(user, SPAN_NOTICE("You transfer [trans] units of the solution to [target]."))
	update_icon()

/obj/item/weapon/storage/makeshift_grinder/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in range(0)
	var/N = input("Amount per transfer from this:","[src]") as null|anything in possible_transfer_amounts
	if(N)
		amount_per_transfer_from_this = N

/obj/item/weapon/storage/makeshift_grinder/examine(mob/user)
	if(!..(user, 2))
		return
	if(contents.len)
		to_chat(user, SPAN_NOTICE("It has something inside."))
	if(reagents.total_volume)
		to_chat(user, SPAN_NOTICE("It's filled with [reagents.total_volume]/[reagents.maximum_volume] units of reagents."))


/obj/item/weapon/storage/makeshift_grinder/on_update_icon()
	. = ..()
	cut_overlays()
	if(reagents.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "[icon_state]100")
		filling.color = reagents.get_color()
		add_overlay(filling)
#undef REAGENTS_PER_SHEET

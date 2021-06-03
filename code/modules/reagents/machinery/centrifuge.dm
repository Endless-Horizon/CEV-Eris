// Do not forget to update the nanoUI template if you change these values

#define MODE_SEPARATING   0
#define MODE_SYNTHESISING 1
// Modes available to makeshift centrifuge go here

#define MODE_ADVANCED     2

#define MODE_ISOLATING    2
// Modes unavailable to makeshift centrifuge go here

#define MODE_END          3

/obj/machinery/centrifuge
	name = "centrifuge"
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/machines/chemistry.dmi'
	icon_state = "centrifuge"
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	circuit = /obj/item/weapon/electronics/circuitboard/centrifuge
	layer = BELOW_OBJ_LAYER
	var/obj/item/weapon/reagent_containers/mainBeaker
	var/list/obj/item/weapon/reagent_containers/separationBeakers = list()
	var/workTime = 10 SECONDS
	var/lastActivation = 0
	var/on = FALSE
	var/mode = MODE_SEPARATING
	var/beakerSlots = 3
	var/unitsPerSec = 2

/obj/machinery/centrifuge/Destroy()
	QDEL_NULL(mainBeaker)
	QDEL_NULL_LIST(separationBeakers)
	return ..()

/obj/machinery/centrifuge/on_update_icon()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]_broken"
		return
	if(stat & NOPOWER)
		icon_state = "[initial(icon_state)]_off"
		return
	if(on)
		icon_state = "[initial(icon_state)]_moving"
	else
		icon_state = initial(icon_state)

/obj/machinery/centrifuge/RefreshParts()
	unitsPerSec = initial(unitsPerSec)
	unitsPerSec = max(unitsPerSec * max_part_rating(/obj/item/weapon/stock_parts/manipulator))
	beakerSlots = initial(beakerSlots)
	if(max_part_rating(/obj/item/weapon/stock_parts/manipulator) > 1)
		beakerSlots += (max_part_rating(/obj/item/weapon/stock_parts/manipulator) - 1)


/obj/machinery/centrifuge/Process()
	..()
	if(stat & NOPOWER)
		return
	if(on)
		if(mode == MODE_SEPARATING)
			mainBeaker.reagents.handle_reactions()
			mainBeaker.separate_solution(separationBeakers, unitsPerSec, mainBeaker.reagents.get_master_reagent_id())

		if(world.time >= lastActivation + workTime)
			finish()

		SSnano.update_uis(src)

/obj/machinery/centrifuge/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction(I, user))
		return

	if(default_part_replacement(I, user))
		return

	if(!on && istype(I, /obj/item/weapon/reagent_containers) && I.is_open_container())
		if (!mainBeaker || separationBeakers.len < beakerSlots)
			. = TRUE //no afterattack
			var/obj/item/weapon/reagent_containers/B = I
			if(!user.unEquip(B, src))
				return
			if(!mainBeaker)
				mainBeaker = B
			else
				separationBeakers.Add(B)
			to_chat(user, SPAN_NOTICE("You add [B] to [src]."))
			SSnano.update_uis(src)
			update_icon()
			return
	return ..()

/obj/machinery/centrifuge/MouseDrop_T(atom/movable/C, mob/user, src_location, over_location, src_control, over_control, params)
	if(!Adjacent(user) || !C.Adjacent(user) || user.stat)
		return ..()
	if(!on && istype(C, /obj/item/weapon/reagent_containers) && C.is_open_container())
		if (!mainBeaker || separationBeakers.len < beakerSlots)
			C.forceMove(src)
			C.add_fingerprint(user)
			if(!mainBeaker)
				mainBeaker = C
			else
				separationBeakers.Add(C)
			to_chat(user, SPAN_NOTICE("You add [C] to [src]."))
			SSnano.update_uis(src)
			update_icon()
	else
		return ..()

/obj/machinery/centrifuge/on_deconstruction()
	on = FALSE
	if(mainBeaker)
		mainBeaker.forceMove(get_turf(src))
		mainBeaker = null
	for(var/obj/item/I in separationBeakers)
		I.forceMove(get_turf(src))
	separationBeakers = list()
	..()


/obj/machinery/centrifuge/attack_hand(mob/user)
	if(..())
		return TRUE

	user.set_machine(src)
	nano_ui_interact(user)

/obj/machinery/centrifuge/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = NANOUI_FOCUS)
	var/list/data = nano_ui_data()

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "centrifuge.tmpl", name, 800, 700)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()


/obj/machinery/centrifuge/nano_ui_data()
	var/data = list()
	data["on"] = on
	data["mode"] = mode
	data["cycleTime"] = workTime / 10
	data["timeLeft"] = round((lastActivation + workTime - world.time) / 10)
	data["maxBeakers"] = beakerSlots
	data["UPS"] = unitsPerSec

	if(mainBeaker)
		data["mainBeaker"] = mainBeaker.reagents.nano_ui_data()
	var/list/beakersData = list()
	for(var/i = 1, i <= beakerSlots, i++)
		var/list/beakerInfo = list()
		if(i <= separationBeakers.len)
			var/obj/item/weapon/reagent_containers/B = separationBeakers[i]
			if(B && B.reagents)
				beakerInfo = B.reagents.nano_ui_data()
		beakerInfo["slot"] = i
		beakersData.Add(list(beakerInfo))
	data["beakers"] = beakersData
	return data

/obj/machinery/centrifuge/proc/start()
	on = TRUE
	lastActivation = world.time
	if(mode == MODE_SYNTHESISING)
		mainBeaker.reagents.rotating = TRUE
		mainBeaker.reagents.handle_reactions()
	update_icon()

/obj/machinery/centrifuge/proc/stop()
	on = FALSE
	mainBeaker.reagents.rotating = FALSE

	update_icon()

/obj/machinery/centrifuge/proc/finish()
	if(mode == MODE_ISOLATING)
		var/data = mainBeaker.reagents.get_data("blood")
		if (data)
			var/list/datum/disease2/disease/virus = data["virus2"]
			for (var/ID in virus)
				var/obj/item/weapon/virusdish/dish = new (loc)
				dish.virus2 = virus[ID].getcopy()
	stop()
	playsound(src.loc, 'sound/machines/ping.ogg', 50, 1, -3)
	visible_message("\icon[src]\The [src] pings indicating that cycle is complete.")

/obj/machinery/centrifuge/Topic(href, href_list)
	if(..())
		return

	if(href_list["power"] && mainBeaker)
		if(!on)
			start()
		else
			stop()

	if(href_list["ejectBeaker"] && !on)
		if(href_list["ejectBeaker"] == "0")
			mainBeaker.forceMove(get_turf(src))
			mainBeaker = null
		else
			var/slot = text2num(href_list["ejectBeaker"])
			separationBeakers[slot].forceMove(get_turf(src))
			separationBeakers.Remove(separationBeakers[slot])

	if(href_list["setMode"] && !on)
		var/m = text2num(href_list["setMode"])
		if(m >= 0 && m < MODE_END)
			mode = m
			if(mode == MODE_ISOLATING)
				workTime = 60 SECONDS

	if(href_list["setTime"] && !on && mode != MODE_ISOLATING)
		workTime = text2num(href_list["setTime"]) SECONDS

	return 1 // update UIs attached to this object

/obj/item/device/makeshift_centrifuge
	name = "manual centrifuge"
	desc = "A centrifuge with manual mechanism."
	icon = 'icons/obj/machines/chemistry.dmi'
	icon_state = "centrifuge_makeshift"
	matter = list(MATERIAL_STEEL = 4)
	rarity_value = 50
	var/obj/item/weapon/reagent_containers/mainBeaker
	var/list/obj/item/weapon/reagent_containers/separationBeakers = list()
	var/beakerSlots = 2
	var/on = FALSE
	var/mode = MODE_SEPARATING

/obj/item/device/makeshift_centrifuge/Destroy()
	QDEL_NULL(mainBeaker)
	QDEL_NULL_LIST(separationBeakers)
	return ..()

/obj/item/device/makeshift_centrifuge/attack_self(mob/user)
	on = TRUE
	SSnano.update_uis(src)
	user.visible_message(SPAN_NOTICE("[user] have started to turn handle on \the [src]."), SPAN_NOTICE("You started to turn handle on \the [src]."))
	if(do_after(user, 60 - (30 * user.stats.getMult(STAT_TGH, STAT_LEVEL_ADEPT))))
		if(mainBeaker && mainBeaker.reagents.total_volume)
			switch(mode)
				if(MODE_SEPARATING)
					mainBeaker.reagents.handle_reactions()
					mainBeaker.separate_solution(separationBeakers, 5, mainBeaker.reagents.get_master_reagent_id())
				if(MODE_SYNTHESISING)
					mainBeaker.reagents.rotating = TRUE
					mainBeaker.reagents.handle_reactions()
					mainBeaker.reagents.rotating = FALSE
	on = FALSE
	SSnano.update_uis(src)

/obj/item/device/makeshift_centrifuge/MouseDrop_T(atom/movable/C, mob/user, src_location, over_location, src_control, over_control, params)
	if(!Adjacent(user) || !C.Adjacent(user) || user.stat)
		return ..()
	if(!on && istype(C, /obj/item/weapon/reagent_containers) && C.is_open_container())
		if (!mainBeaker || separationBeakers.len < beakerSlots)
			C.forceMove(src)
			C.add_fingerprint(user)
			if(!mainBeaker)
				mainBeaker = C
			else
				separationBeakers.Add(C)
			to_chat(user, SPAN_NOTICE("You add [C] to [src]."))
			SSnano.update_uis(src)
			update_icon()
	else
		return ..()

/obj/item/device/makeshift_centrifuge/attackby(obj/item/C, mob/living/user)
	if(!on && istype(C, /obj/item/weapon/reagent_containers) && C.is_open_container())
		if (!mainBeaker || separationBeakers.len < beakerSlots)
			if(insert_item(C, user))
				if(!mainBeaker)
					mainBeaker = C
				else
					separationBeakers.Add(C)
				to_chat(user, SPAN_NOTICE("You add [C] to [src]."))
				SSnano.update_uis(src)
				update_icon()
	else
		..()

/obj/item/device/makeshift_centrifuge/attack_hand(mob/user)
	if(loc != user && ..())
		return TRUE
	user.set_machine(src)
	nano_ui_interact(user)

/obj/item/device/makeshift_centrifuge/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = NANOUI_FOCUS)
	var/list/data = nano_ui_data()

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "centrifuge.tmpl", name, 800, 700)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

/obj/item/device/makeshift_centrifuge/nano_ui_data()
	var/data = list()
	data["on"] = on
	data["mode"] = mode
	data["maxBeakers"] = beakerSlots
	data["minimal"] = TRUE

	if(mainBeaker)
		data["mainBeaker"] = mainBeaker.reagents.nano_ui_data()
	var/list/beakersData = list()
	for(var/i = 1, i <= beakerSlots, i++)
		var/list/beakerInfo = list()
		if(i <= separationBeakers.len)
			var/obj/item/weapon/reagent_containers/B = separationBeakers[i]
			if(B && B.reagents)
				beakerInfo = B.reagents.nano_ui_data()
		beakerInfo["slot"] = i
		beakersData.Add(list(beakerInfo))
	data["beakers"] = beakersData
	return data


/obj/item/device/makeshift_centrifuge/Topic(href, href_list)
	if(..())
		return

	if(href_list["setMode"] && !on)
		var/m = text2num(href_list["setMode"])
		if(m >= 0 && m < MODE_ADVANCED)
			mode = m

	if(href_list["ejectBeaker"] && !on)
		if(href_list["ejectBeaker"] == "0")
			mainBeaker.forceMove(get_turf(src))
			mainBeaker = null
		else
			var/slot = text2num(href_list["ejectBeaker"])
			separationBeakers[slot].forceMove(get_turf(src))
			separationBeakers.Remove(separationBeakers[slot])

	return 1 // update UIs attached to this object

#undef MODE_SEPARATING
#undef MODE_SYNTHESISING
#undef MODE_ISOLATING
#undef MODE_ADVANCED
#undef MODE_END

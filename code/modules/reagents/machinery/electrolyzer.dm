/obj/machinery/electrolyzer
	name = "electrolyzer"
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/machines/chemistry.dmi'
	icon_state = "electrolysis"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	circuit = /obj/item/weapon/electronics/circuitboard/electrolyzer
	layer = BELOW_OBJ_LAYER
	var/obj/item/weapon/reagent_containers/beaker
	var/obj/item/weapon/reagent_containers/separation_beaker
	var/convertion_coefficient = 2
	var/on = FALSE



// returns FALSE on errors TRUE on success and -1 if nothing to do
/proc/electrolysis(var/obj/item/weapon/reagent_containers/primary_beaker, var/obj/item/weapon/reagent_containers/secondary_beaker, var/amount)
	if(!primary_beaker || !secondary_beaker)
		return FALSE
	//check if has reagents
	if(!primary_beaker.reagents.total_volume)
		return FALSE

	//check only one reagent present
	if(!primary_beaker.reagents.reagent_list.len > 1)
		return FALSE

	var/datum/chemical_reaction/original_reaction
	var/active_reagent
	for(var/datum/reagent/R in primary_beaker.reagents.reagent_list)
		if(GLOB.chemical_reactions_list_by_result[R.id])
			var/list/recipeList = GLOB.chemical_reactions_list_by_result[R.id]
			var/datum/chemical_reaction/recipe = recipeList[1]	// lets pick first one and hope that its the right one (this might cause problems if there is more than 1 recipe for reagent)
			if(recipe.supports_decomposition_by_electrolysis)
				active_reagent = R.id
				original_reaction = recipe
				break

	if(!istype(original_reaction))
		return -1

	var/volumeToHandle = min(original_reaction.result_amount, primary_beaker.reagents.total_volume, amount)
	var/partVolume = volumeToHandle/original_reaction.result_amount

	if(secondary_beaker.reagents.get_free_space() < volumeToHandle)
		return FALSE

	primary_beaker.reagents.remove_reagent(active_reagent, volumeToHandle)
	primary_beaker.reagents.add_reagent(original_reaction.required_reagents[1], partVolume * original_reaction.required_reagents[original_reaction.required_reagents[1]])
	for(var/i = 2 , i <= original_reaction.required_reagents.len, i++)
		secondary_beaker.reagents.add_reagent(original_reaction.required_reagents[i], partVolume * original_reaction.required_reagents[original_reaction.required_reagents[i]])
	return TRUE


/obj/machinery/electrolyzer/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(separation_beaker)
	return ..()

/obj/machinery/electrolyzer/on_update_icon()
	if(stat & NOPOWER)
		icon_state = "[initial(icon_state)]_off"
		return
	if(on)
		icon_state = "[initial(icon_state)]_working"
	else
		icon_state = initial(icon_state)

/obj/machinery/electrolyzer/RefreshParts()
	convertion_coefficient = initial(convertion_coefficient)
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		convertion_coefficient *= C.rating


/obj/machinery/electrolyzer/Process()
	..()
	if(stat & NOPOWER)
		update_icon()
		return
	if(on && beaker && beaker.reagents.total_volume)
		var/state = electrolysis(beaker, separation_beaker, convertion_coefficient)
		if(!state)
			on = FALSE
			playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 1, -3)
			visible_message("\icon[src]\The [src] buzzes indicating that error has occured.")
		else if(state == -1)
			on = FALSE
			playsound(src.loc, 'sound/machines/ping.ogg', 50, 1, -3)
			visible_message("\icon[src]\The [src] pings indicating that process is complete.")
		update_icon()
		SSnano.update_uis(src)


/obj/machinery/electrolyzer/MouseDrop_T(atom/movable/I, mob/user, src_location, over_location, src_control, over_control, params)
	if(!Adjacent(user) || !I.Adjacent(user) || user.stat)
		return ..()
	if(istype(I, /obj/item/weapon/reagent_containers) && I.is_open_container() && (!beaker || !separation_beaker))
		. = TRUE //no afterattack
		var/obj/item/weapon/reagent_containers/B = I
		I.forceMove(src)
		I.add_fingerprint(user)
		if(!beaker)
			beaker = B
		else if(!separation_beaker)
			separation_beaker = B
		to_chat(user, SPAN_NOTICE("You add [B] to [src]."))
		SSnano.update_uis(src)
		update_icon()
		return
	return ..()

/obj/machinery/electrolyzer/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction(I, user))
		return

	if(default_part_replacement(I, user))
		return

	if(istype(I, /obj/item/weapon/reagent_containers) && I.is_open_container() && (!beaker || !separation_beaker))
		. = TRUE //no afterattack
		var/obj/item/weapon/reagent_containers/B = I
		if(!user.unEquip(B, src))
			return
		if(!beaker)
			beaker = B
		else if(!separation_beaker)
			separation_beaker = B
		to_chat(user, SPAN_NOTICE("You add [B] to [src]."))
		SSnano.update_uis(src)
		update_icon()
		return
	return ..()

/obj/machinery/electrolyzer/on_deconstruction()
	if(beaker)
		beaker.forceMove(get_turf(src))
		beaker = null
	if(separation_beaker)
		separation_beaker.forceMove(get_turf(src))
		separation_beaker = null
	..()


/obj/machinery/electrolyzer/attack_hand(mob/user)
	if(..())
		return TRUE

	user.set_machine(src)
	nano_ui_interact(user)

/obj/machinery/electrolyzer/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = NANOUI_FOCUS)
	var/list/data = nano_ui_data()

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "electrolyzer.tmpl", name, 550, 400)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()



/obj/machinery/electrolyzer/nano_ui_data()
	var/data = list()
	data["on"] = on

	if(beaker)
		data["beaker"] = beaker.reagents.nano_ui_data()
	if(separation_beaker)
		data["separation_beaker"] = separation_beaker.reagents.nano_ui_data()
	data["has_power"] = (stat & NOPOWER) ? FALSE : TRUE
	return data


/obj/machinery/electrolyzer/Topic(href, href_list)
	if(..())
		return

	if(href_list["turn_on"])
		on = TRUE
		update_icon()

	if(href_list["turn_off"])
		on = FALSE
		update_icon()

	if(href_list["eject"] && beaker)
		on = FALSE
		if(beaker)
			beaker.forceMove(get_turf(src))
			beaker = null
			update_icon()

	if(href_list["ejectSecondary"] && separation_beaker)
		on = FALSE
		if(separation_beaker)
			separation_beaker.forceMove(get_turf(src))
			separation_beaker = null
		update_icon()

	return 1 // update UIs attached to this object



/obj/item/device/makeshift_electrolyser
	name = "makeshift electrolyzer"
	icon = 'icons/obj/machines/chemistry.dmi'
	icon_state = "electrolysis_makeshift"
	rarity_value = 50
	starting_cell = FALSE
	suitable_cell = /obj/item/weapon/cell/small
	var/on = FALSE
	var/tick_cost = 3
	var/obj/item/weapon/reagent_containers/beaker
	var/obj/item/weapon/reagent_containers/separation_beaker

/obj/item/device/makeshift_electrolyser/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/item/device/makeshift_electrolyser/MouseDrop_T(atom/movable/C, mob/user, src_location, over_location, src_control, over_control, params)
	if(!Adjacent(user) || !C.Adjacent(user))
		return ..()
	if(istype(C, suitable_cell) && !cell)
		to_chat(user, SPAN_NOTICE("You add [C] to [src]."))
		C.forceMove(src)
		src.cell = C
		SSnano.update_uis(src)
		return
	if(istype(C, /obj/item/weapon/reagent_containers) && C.is_open_container() && (!beaker || !separation_beaker))
		. = TRUE //no afterattack
		var/obj/item/weapon/reagent_containers/B = C
		C.forceMove(src)
		C.add_fingerprint(user)
		if(!beaker)
			beaker = B
		else if(!separation_beaker)
			separation_beaker = B
		to_chat(user, SPAN_NOTICE("You add [B] to [src]."))
		SSnano.update_uis(src)
		return

/obj/item/device/makeshift_electrolyser/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		update_icon()

/obj/item/device/makeshift_electrolyser/proc/turn_on(mob/user)
	if(!cell_use_check(tick_cost, user))
		playsound(loc, 'sound/machines/button.ogg', 50, 1)
		return FALSE
	on = TRUE
	START_PROCESSING(SSobj, src)

/obj/item/device/makeshift_electrolyser/proc/turn_off(mob/user)
	on = FALSE
	STOP_PROCESSING(SSobj, src)
	SSnano.update_uis(src)

/obj/item/device/makeshift_electrolyser/Process()
	if(on)
		if(!cell_use_check(tick_cost))
			visible_message(SPAN_NOTICE("[src]'s electrodes stopped bubbling."), range = 4)
			turn_off()
		if(beaker && beaker.reagents.total_volume)
			var/state = electrolysis(beaker, separation_beaker, 2)
			if(!state || state == -1)
				turn_off()
			SSnano.update_uis(src)


/obj/item/device/makeshift_electrolyser/attack_self(mob/user)
	user.set_machine(src)
	nano_ui_interact(user)
	add_fingerprint(user)

/obj/item/device/makeshift_electrolyser/attackby(obj/item/C, mob/living/user)
	if(istype(C, suitable_cell) && !cell && insert_item(C, user))
		to_chat(user, SPAN_NOTICE("You add [C] to [src]."))
		src.cell = C
		SSnano.update_uis(src)
		return
	if(istype(C, /obj/item/weapon/reagent_containers) && C.is_open_container() && (!beaker || !separation_beaker))
		. = TRUE //no afterattack
		var/obj/item/weapon/reagent_containers/B = C
		if(!user.unEquip(B, src))
			return
		if(!beaker)
			beaker = B
		else if(!separation_beaker)
			separation_beaker = B
		to_chat(user, SPAN_NOTICE("You add [B] to [src]."))
		SSnano.update_uis(src)
		return
	return ..()

/obj/item/device/makeshift_electrolyser/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = NANOUI_FOCUS)
	var/list/data = nano_ui_data()

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "electrolyzer.tmpl", name, 550, 400)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()



/obj/item/device/makeshift_electrolyser/nano_ui_data()
	var/data = list()
	data["on"] = on
	data["has_power"] = cell_check(tick_cost)

	if(beaker)
		data["beaker"] = beaker.reagents.nano_ui_data()
	if(separation_beaker)
		data["separation_beaker"] = separation_beaker.reagents.nano_ui_data()
	return data

/obj/item/device/makeshift_electrolyser/attack_hand(mob/user)
	if(loc != user && ..())
		return TRUE
	user.set_machine(src)
	nano_ui_interact(user)

/obj/item/device/makeshift_electrolyser/Topic(href, href_list)
	if(..())
		return

	if(href_list["turn_on"])
		turn_on()

	if(href_list["turn_off"])
		turn_off()

	if(href_list["eject"] && beaker)
		turn_off()
		if(beaker)
			beaker.forceMove(get_turf(src))
			beaker = null

	if(href_list["ejectSecondary"] && separation_beaker)
		turn_off()
		if(separation_beaker)
			separation_beaker.forceMove(get_turf(src))
			separation_beaker = null

	return 1 // update UIs attached to this object


/obj/machinery/chem_heater
	name = "chemical heater"
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0b"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	//resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/weapon/electronics/circuitboard/chem_heater
	var/obj/item/weapon/reagent_containers/beaker = null
	var/target_temperature = 300
	var/heater_coefficient = 0.2
	var/on = FALSE

/obj/machinery/chem_heater/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/chem_heater/handle_atom_del(atom/A)
	. = ..()
	if(A == beaker)
		beaker = null
		update_icon()

/obj/machinery/chem_heater/on_update_icon()
	if(beaker)
		icon_state = "mixer1b"
	else
		icon_state = "mixer0b"

/obj/machinery/chem_heater/AltClick(mob/living/user)
	if(!istype(user) || user.incapacitated())
		return

	if(!in_range(src, user))
		return

	replace_beaker(user)

/obj/machinery/chem_heater/proc/replace_beaker(mob/living/user, obj/item/weapon/reagent_containers/new_beaker)
	if(beaker)
		beaker.forceMove(drop_location())
		if(istype(user) && Adjacent(user))
			user.put_in_hands(beaker)
	if(new_beaker)
		beaker = new_beaker
	else
		beaker = null
	update_icon()
	return TRUE

/obj/machinery/chem_heater/RefreshParts()
	heater_coefficient = initial(heater_coefficient)
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		heater_coefficient *= M.rating

/obj/machinery/chem_heater/Process()
	..()
	if(stat & NOPOWER)
		return
	if(on && beaker && beaker.reagents.total_volume)
		beaker.reagents.adjust_thermal_energy((target_temperature - beaker.reagents.chem_temp) * heater_coefficient * SPECIFIC_HEAT_DEFAULT * beaker.reagents.total_volume)
		beaker.reagents.handle_reactions()
		SSnano.update_uis(src)

/obj/machinery/chem_heater/MouseDrop_T(atom/movable/I, mob/user, src_location, over_location, src_control, over_control, params)
	if(!Adjacent(user) || !I.Adjacent(user) || user.stat)
		return ..()
	if(istype(I, /obj/item/weapon/reagent_containers) && I.is_open_container())
		I.add_fingerprint(user)
		replace_beaker(user, I)
		to_chat(user, SPAN_NOTICE("You add [I] to [src]."))
		updateUsrDialog()
		update_icon()
		return
	. = ..()

/obj/machinery/chem_heater/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction(I, user))
		return

	if(default_part_replacement(I, user))
		return


	if(istype(I, /obj/item/weapon/reagent_containers) && I.is_open_container())
		. = TRUE //no afterattack
		var/obj/item/weapon/reagent_containers/B = I
		if(!user.unEquip(B, src))
			return
		replace_beaker(user, B)
		to_chat(user, SPAN_NOTICE("You add [B] to [src]."))
		updateUsrDialog()
		update_icon()
		return
	return ..()

/obj/machinery/chem_heater/on_deconstruction()
	replace_beaker()
	..()

/obj/machinery/chem_heater/attack_hand(mob/user)
	if(..())
		return TRUE

	user.set_machine(src)
	nano_ui_interact(user)

/obj/machinery/chem_heater/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = NANOUI_FOCUS)
	var/list/data = nano_ui_data()

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "chem_heater.tmpl", name, 275, 400)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()



/obj/machinery/chem_heater/nano_ui_data()
	var/data = list()
	data["target_temperature"] = target_temperature
	data["on"] = on

	if(beaker)
		data["beaker"] = beaker.reagents.nano_ui_data()
	return data


/obj/machinery/chem_heater/Topic(href, href_list)
	if(..())
		return

	if(href_list["power"])
		on = !on

	if(href_list["temperature"])
		var/target = href_list["target"]
		var/adjust = text2num(href_list["adjust"])
		if(target == "input")
			target = input("New target temperature:", name, target_temperature) as num|null
		else if(adjust)
			target = target_temperature + adjust
		else if(text2num(target) != null)
			target = text2num(target)

		target_temperature = CLAMP(target, 0, 1000)

	if(href_list["eject"])
		on = FALSE
		replace_beaker(usr)

	return 1 // update UIs attached to this object

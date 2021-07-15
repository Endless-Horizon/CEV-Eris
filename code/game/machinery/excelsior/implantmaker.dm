/obj/machinery/complant_maker
	name = "implant reconstructor"
	desc = "This machine repurposes implants, robot components and bionics, reworking their circuitry into the Excelsior implant pattern which allows recruitment."
	icon = 'icons/obj/machines/excelsior/reconstructor.dmi'
	icon_state = "idle"
	circuit = /obj/item/electronics/circuitboard/excelsiorreconstructor
	anchored = TRUE
	density = TRUE

	var/build_time = 40
	var/working = FALSE
	var/start_time = 0

/obj/machinery/complant_maker/RefreshParts()
	var/total = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		total += M.rating

	build_time = max(10, 70-total)

/obj/machinery/complant_maker/attackby(var/obj/item/I, var/mob/user)
	if(working)
		to_chat(user, SPAN_WARNING("[src] is active. Wait for it to finish."))
		return

	if(default_deconstruction(I, user))
		return

	if(default_part_replacement(I, user))
		return

	if(panel_open)
		return

	var/accepted = FALSE

	if(istype(I, /obj/item/implant) || istype(I, /obj/item/robot_parts))
		user.remove_from_mob(I)
		qdel(I)
		accepted = TRUE

	else if(istype(I, /obj/item/organ))
		var/obj/item/organ/O = I
		if(BP_IS_ROBOTIC(O))
			user.remove_from_mob(I)
			qdel(I)
			accepted = TRUE

	else if(istype(I, /obj/item/implantcase))
		var/obj/item/implantcase/case = I
		if(case.implant)
			QDEL_NULL(case.implant)
			case.update_icon()
			accepted = TRUE

	else if(istype(I, /obj/item/implanter))
		var/obj/item/implanter/implanter = I
		if(implanter.implant)
			QDEL_NULL(implanter.implant)
			implanter.update_icon()
			accepted = TRUE


	if(accepted)
		working = TRUE
		start_time = world.time

		FLICK(image(icon, "closing"), src)

		update_icon()


/obj/machinery/complant_maker/Process()
	if(stat & NOPOWER)
		if(working)
			FLICK(image(icon, "opening"), src)
		working = FALSE
		update_icon()
		return

	if(working && world.time >= start_time + build_time)
		new /obj/item/implantcase/excelsior(drop_location())
		FLICK(image(icon, "opening"), src)
		working = FALSE
		update_icon()


/obj/machinery/complant_maker/on_update_icon()
	if(stat & NOPOWER)
		icon_state = "off"
	else
		icon_state = "idle"

	if(working)
		icon_state = "working"

	cut_overlays()

	if(panel_open)
		add_overlays(image(icon, "panel"))

/obj/machinery/autodoc
	name = "Autodoc"
	icon = 'icons/obj/autodoc.dmi'
	icon_state = "powered_off"
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/weapon/electronics/circuitboard/autodoc
	use_power = IDLE_POWER_USE
	idle_power_usage = 60
	active_power_usage = 10000
	var/mob/living/carbon/occupant
	var/datum/autodoc/autodoc_processor
	var/locked

/obj/machinery/autodoc/New()
	. = ..()
	autodoc_processor = new/datum/autodoc/capitalist_autodoc()
	autodoc_processor.holder = src
	autodoc_processor.damage_heal_amount = 20


/obj/machinery/autodoc/relaymove(mob/user)
	if (user.stat)
		return
	src.go_out()
	return

/obj/machinery/autodoc/attackby(obj/item/I, mob/living/user)
	if(default_deconstruction(I, user))
		return
	if(default_part_replacement(I, user))
		return
	..()

/obj/machinery/autodoc/verb/eject()
	set src in view(1)
	set category = "Object"
	set name = "Eject Autodoc"

	if (usr.incapacitated())
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/autodoc/verb/move_inside()
	set src in view(1)
	set category = "Object"
	set name = "Enter Autodoc"

	if(usr.stat)
		return
	if(src.occupant)
		to_chat(user, SPAN_WARNING("The autodoc is already occupied!"))
		return
	if(usr.abiotic())
		to_chat(user, SPAN_WARNING("The subject cannot have abiotic items on."))
		return
	set_occupant(usr)
	src.add_fingerprint(usr)
	return

/obj/machinery/autodoc/proc/go_out()
	if (!occupant || locked)
		return
	if(autodoc_processor.active)
		to_chat(usr, SPAN_WARNING("Autodoc is locked down! Abort all oberations if you need to go out or wait until all operations would be done."))
		return
	for(var/obj/O in src)
		O.forceMove(loc)
	occupant.forceMove(loc)
	occupant.reset_view()
	occupant.unset_machine()
	occupant = null
	autodoc_processor.set_patient(null)
	update_use_power(1)
	update_icon()

/obj/machinery/autodoc/proc/set_occupant(var/mob/living/L)
	L.forceMove(src)
	src.occupant = L
	src.add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		autodoc_processor.set_patient(L)
		nano_ui_interact(L)
		update_use_power(2)
		L.set_machine(src)
	update_icon()

/obj/machinery/autodoc/affect_grab(var/mob/user, var/mob/target)
	if (src.occupant)
		to_chat(user, SPAN_NOTICE("The autodoc is already occupied!"))
		return
	if(target.buckled)
		to_chat(user, SPAN_NOTICE("Unbuckle the subject before attempting to move them."))
		return
	if(target.abiotic())
		to_chat(user, SPAN_NOTICE("Subject cannot have abiotic items on."))
		return
	set_occupant(target)
	src.add_fingerprint(user)
	return TRUE

/obj/machinery/autodoc/MouseDrop_T(var/mob/target, var/mob/user)
	if(!ismob(target))
		return
	if (src.occupant)
		to_chat(user, SPAN_WARNING("The autodoc is already occupied!"))
		return
	if (target.abiotic())
		to_chat(user, SPAN_WARNING("Subject cannot have abiotic items on."))
		return
	if (target.buckled)
		to_chat(user, SPAN_NOTICE("Unbuckle the subject before attempting to move them."))
		return
	user.visible_message(
		SPAN_NOTICE("\The [user] begins placing \the [target] into \the [src]."),
		SPAN_NOTICE("You start placing \the [target] into \the [src].")
	)
	if(!do_after(user, 30, src) || !Adjacent(target))
		return
	set_occupant(target)
	src.add_fingerprint(user)
	update_icon()
	return

/obj/machinery/autodoc/Process()
	if(stat & (NOPOWER|BROKEN))
		autodoc_processor.stop()
		return
	if(occupant)
		locked = autodoc_processor.active
		nano_ui_interact(occupant)
	update_icon()

/obj/machinery/autodoc/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FORCE_OPEN, var/datum/topic_state/state = GLOB.default_state)
	autodoc_processor.nano_ui_interact(user, ui_key, ui, force_open, state)

/obj/machinery/autodoc/Topic(href, href_list)
	return autodoc_processor.Topic(href, href_list)

/obj/machinery/autodoc/on_update_icon()
	if(stat & (NOPOWER|BROKEN) || !occupant)
		icon_state = "powered_off"
	else
		icon_state = "powered_on"
	if(autodoc_processor.active)
		icon_state = "active"

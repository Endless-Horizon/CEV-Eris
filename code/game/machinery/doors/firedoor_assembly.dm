/obj/structure/firedoor_assembly
	name = "\improper emergency shutter assembly"
	desc = "It can save lives."
	icon = 'icons/obj/doors/DoorHazard.dmi'
	icon_state = "door_construction"
	anchored = FALSE
	opacity = 0
	density = TRUE
	var/wired = 0

/obj/structure/firedoor_assembly/on_update_icon()
	SetIconState("door_[anchored?"anchored":"construction"]")

/obj/structure/firedoor_assembly/attackby(obj/item/I, mob/user)

	var/list/usable_qualities = list(QUALITY_BOLT_TURNING)
	if(!anchored)
		usable_qualities.Add(QUALITY_WELDING)
	if(wired)
		usable_qualities.Add(QUALITY_WIRE_CUTTING)

	var/tool_type = I.get_tool_type(user, usable_qualities, src)
	switch(tool_type)

		if(QUALITY_BOLT_TURNING)
			if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_EASY, required_stat = STAT_MEC))
				user.visible_message("<span class='warning'>[user] has [anchored ? "" : "un" ]secured \the [src]!</span>",
									  "You have [anchored ? "" : "un" ]secured \the [src]!")
				anchored = !anchored
				update_icon()
				return
			return

		if(QUALITY_WELDING)
			if(!anchored)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_EASY, required_stat = STAT_MEC))
					user.visible_message(SPAN_WARNING("[user] has dissassembled \the [src]."),
										"You have dissassembled \the [src].")
					new /obj/item/stack/material/steel(src.loc, 2)
					qdel(src)
					return
			return

		if(QUALITY_WIRE_CUTTING)
			if(wired)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_EASY, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You cut the wires!"))
					new/obj/item/stack/cable_coil(src.loc, 1)
					wired = 0
					return
			return

		if(ABORT_CHECK)
			return

	if(istype(I, /obj/item/stack/cable_coil) && !wired && anchored)
		var/obj/item/stack/cable_coil/cable = I
		if (cable.get_amount() < 1)
			to_chat(user, SPAN_WARNING("You need one length of coil to wire \the [src]."))
			return
		user.visible_message("[user] wires \the [src].", "You start to wire \the [src].")
		if(do_after(user, 40, src) && !wired && anchored)
			if (cable.use(1))
				wired = 1
				to_chat(user, SPAN_NOTICE("You wire \the [src]."))

	else if(istype(I, /obj/item/electronics/airalarm) && wired)
		if(anchored)
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			user.visible_message(SPAN_WARNING("[user] has inserted a circuit into \the [src]!"),
								  "You have inserted the circuit into \the [src]!")
			new /obj/machinery/door/firedoor(src.loc)
			qdel(I)
			qdel(src)
		else
			to_chat(user, SPAN_WARNING("You must secure \the [src] first!"))

	else
		..(I, user)

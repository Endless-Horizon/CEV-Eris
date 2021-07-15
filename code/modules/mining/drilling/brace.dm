/obj/machinery/mining/brace
	name = "mining drill brace"
	desc = "A machinery brace for an industrial drill. It looks easily half-meter thick."
	icon_state = "mining_brace"
	circuit = /obj/item/electronics/circuitboard/miningdrillbrace
	var/obj/machinery/mining/drill/connected

/obj/machinery/mining/brace/Destroy()
	if(connected)
		connected.disconnect_brace(src)
	return ..()

/obj/machinery/mining/brace/attackby(var/obj/item/I, mob/user as mob)
	if(connected && connected.active)
		to_chat(user, SPAN_NOTICE("You can't work with the brace of a running drill!"))
		return

	var/tool_type = I.get_tool_type(user, list(QUALITY_PRYING, QUALITY_SCREW_DRIVING, QUALITY_BOLT_TURNING), src)
	switch(tool_type)

		if(QUALITY_PRYING)
			if(!panel_open)
				to_chat(user, SPAN_NOTICE("You cant get to the components of \the [src], remove the cover."))
				return
			if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_EASY, required_stat = STAT_MEC))
				to_chat(user, SPAN_NOTICE("You remove the components of \the [src] with [I]."))
				dismantle()
				return

		if(QUALITY_SCREW_DRIVING)
			var/used_sound = panel_open ? 'sound/machines/Custom_screwdriveropen.ogg' :  'sound/machines/Custom_screwdriverclose.ogg'
			if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC, instant_finish_tier = 30, forced_sound = used_sound))
				panel_open = !panel_open
				to_chat(user, SPAN_NOTICE("You [panel_open ? "open" : "close"] the maintenance hatch of \the [src] with [I]."))
				update_icon()
				return

		if(QUALITY_BOLT_TURNING)
			if(istype(get_turf(src), /turf/space))
				to_chat(user, SPAN_NOTICE("You can't anchor something to empty space. Idiot."))
				return
			if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
				to_chat(user, SPAN_NOTICE("You [anchored ? "un" : ""]anchor the brace with [I]."))
				anchored = !anchored
				if(anchored)
					connect()
				else
					disconnect()

		if(ABORT_CHECK)
			return

/obj/machinery/mining/brace/proc/connect()
	connected = locate(/obj/machinery/mining/drill, get_step(src, dir))

	if(!connected)
		return

	icon_state = "mining_brace_active"
	connected.connect_brace(src)

/obj/machinery/mining/brace/proc/disconnect()

	if(!connected)
		return

	icon_state = "mining_brace"

	connected.disconnect_brace(src)

	connected = null


/obj/machinery/mining/brace/verb/rotate()
	set name = "Rotate"
	set category = "Object"
	set src in oview(1)

	if(usr.stat)
		return

	if (anchored)
		to_chat(usr, "It is anchored in place!")
		return

	set_dir(turn(dir, 90))
	return

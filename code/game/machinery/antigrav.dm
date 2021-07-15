/obj/machinery/antigrav
	name = "antigrav generator"
	desc = "It temporarily disables gravity around."
	icon_state = "GraviMobile"
	density = TRUE
	anchored = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 0
	active_power_usage = 10000
	circuit = /obj/item/electronics/circuitboard/antigrav

	var/power_usage_per_tile = 200
	var/on = FALSE
	var/image/ball = null
	var/area/area = null
	var/turfcount = 0

/obj/machinery/antigrav/proc/start()
	area = get_area(src)
	if(area.gravity_blocker && area.gravity_blocker != src)
		src.visible_message(SPAN_NOTICE("\The [src] failed to start. There may be interference from another generator."))
		return

	turfcount = 0
	for (var/turf/simulated/S in area)
		turfcount++

	active_power_usage = 4000 + (turfcount * power_usage_per_tile)

	area.gravity_blocker = src
	area.update_gravity()

	if(!on)
		start_anim()

	on = TRUE
	use_power = ACTIVE_POWER_USE
	update_icon()

/obj/machinery/antigrav/examine(var/mob/user)
	.=..()
	if (on)
		to_chat(user, SPAN_NOTICE("The display on the side indicates that it is currently providing null-gravity over an area of [turfcount] m<sup>2</sup> and consuming [active_power_usage * 0.001] kW of power"))

/obj/machinery/antigrav/proc/stop()
	if(area)
		area.gravity_blocker = null
		area.update_gravity()
		area = null
		turfcount = 0

	if(on)
		stop_anim()

	on = FALSE
	use_power = IDLE_POWER_USE
	update_icon()

/obj/machinery/antigrav/Process()
	if(stat & NOPOWER || !on)
		stop()
		return


/obj/machinery/antigrav/attack_hand(mob/user)
	if(!on)
		if(anchored)
			start()
		else
			to_chat(user, SPAN_WARNING("Fasten \the [src] to the floor first."))
	else
		stop()

/obj/machinery/antigrav/attackby(var/obj/item/I, var/mob/user)
	src.add_fingerprint(usr)
	if (I.has_quality(QUALITY_BOLT_TURNING))
		if (anchored)
			if(!on)
				to_chat(user, SPAN_NOTICE("You begin to unfasten \the [src] from the floor..."))
				if (I.use_tool(user, src, WORKTIME_NORMAL, QUALITY_BOLT_TURNING, FAILCHANCE_VERY_EASY, required_stat = STAT_ROB))
					user.visible_message( \
						SPAN_NOTICE("\The [user] unfastens \the [src]."), \
						SPAN_NOTICE("You have unfastened \the [src]. Now it can be pulled somewhere else."), \
						"You hear ratchet.")
					src.anchored = FALSE
			else
				to_chat(user, SPAN_WARNING("Turn off \the [src] first."))
		else
			to_chat(user, SPAN_NOTICE("You begin to fasten \the [src] to the floor..."))
			if (I.use_tool(user, src, WORKTIME_NORMAL, QUALITY_BOLT_TURNING, FAILCHANCE_VERY_EASY, required_stat = STAT_ROB))
				user.visible_message( \
					SPAN_NOTICE("\The [user] fastens \the [src]."), \
					SPAN_NOTICE("You have fastened \the [src]. Now it can counteract gravity."), \
					"You hear ratchet.")
				src.anchored = TRUE
		update_icon()
	else
		return ..()


/obj/machinery/antigrav/proc/start_anim()
	if(ball)
		ball.icon_state = "GraviMobile_working_ball"
	else
		ball = image(icon, icon_state = "GraviMobile_working_ball")
	ball.pixel_y = 32
	ball.layer = src.layer
	ball.plane = src.plane
	ball.loc = src.loc
	world << ball

	FLICK("GraviMobile_starting", src)
	FLICK("GraviMobile_starting_ball", ball)

/obj/machinery/antigrav/proc/stop_anim()
	if(ball)
		ball.icon_state = "GraviMobile_none_ball"
	else
		ball = image(icon, icon_state = "GraviMobile_none_ball")
	ball.pixel_y = 32
	ball.layer = src.layer
	ball.plane = src.plane
	ball.loc = src.loc
	world << ball

	FLICK("GraviMobile_stoping", src)
	FLICK("GraviMobile_stoping_ball", ball)

/obj/machinery/antigrav/on_update_icon()
	if(!anchored)
		icon_state = "GraviMobile"
		return

	if(on)
		icon_state = "GraviMobile_working"
	else
		icon_state = "GraviMobile_deploy"


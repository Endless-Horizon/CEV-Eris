
#define FIREDOOR_MAX_PRESSURE_DIFF 25 // kPa
#define FIREDOOR_MAX_TEMP 50 // °C
#define FIREDOOR_MIN_TEMP 0

// Bitflags
#define FIREDOOR_ALERT_HOT      1
#define FIREDOOR_ALERT_COLD     2
// Not used #define FIREDOOR_ALERT_LOWPRESS 4

/obj/machinery/door/firedoor
	name = "\improper Emergency Shutter"
	desc = "Emergency air-tight shutter, capable of sealing off breached areas."
	icon = 'icons/obj/doors/DoorHazard.dmi'
	icon_state = "door_open"
	req_one_access = list(access_atmospherics, access_engine_equip, access_medical_equip)
	opacity = 0
	density = FALSE
	layer = BELOW_OPEN_DOOR_LAYER
	open_layer = BELOW_OPEN_DOOR_LAYER // Just below doors when open
	closed_layer = CLOSED_FIREDOOR_LAYER // Just above doors when closed

	//These are frequenly used with windows, so make sure zones can pass.
	//Generally if a firedoor is at a place where there should be a zone boundery then there will be a regular door underneath it.
	block_air_zones = 0

	var/blocked = 0
	var/lockdown = 0 // When the door has detected a problem, it locks.
	var/pdiff_alert = 0
	var/pdiff = 0
	var/net_id
	var/list/areas_added
	var/list/users_to_open = new

	var/hatch_open = 0

	power_channel = STATIC_ENVIRON
	use_power = IDLE_POWER_USE
	idle_power_usage = 5

	var/list/tile_info[4]
	var/list/dir_alerts[4] // 4 dirs, bitflags

	// MUST be in same order as FIREDOOR_ALERT_*
	var/list/ALERT_STATES=list(
		"hot",
		"cold"
	)

/obj/machinery/door/firedoor/New()
	..()

	var/area/A = get_area(src)
	ASSERT(istype(A))

	A.all_doors.Add(src)
	areas_added = list(A)

	for(var/direction in cardinal)
		A = get_area(get_step(src,direction))
		if(istype(A) && !(A in areas_added))
			A.all_doors.Add(src)
			areas_added += A

/obj/machinery/door/firedoor/Destroy()
	for(var/area/A in areas_added)
		A.all_doors.Remove(src)
	. = ..()

/obj/machinery/door/firedoor/get_material()
	return get_material_by_name(MATERIAL_STEEL)

/obj/machinery/door/firedoor/examine(mob/user)
	. = ..(user, 1)
	if(!. || !density)
		return

	if(pdiff >= FIREDOOR_MAX_PRESSURE_DIFF)
		to_chat(user, SPAN_WARNING("WARNING: Current pressure differential is [pdiff]kPa! Opening door may result in injury!"))

	to_chat(user, "<b>Sensor readings:</b>")
	for(var/index = 1; index <= tile_info.len; index++)
		var/o = "&nbsp;&nbsp;"
		switch(index)
			if(1)
				o += "NORTH: "
			if(2)
				o += "SOUTH: "
			if(3)
				o += "EAST: "
			if(4)
				o += "WEST: "
		if(tile_info[index] == null)
			o += SPAN_WARNING("DATA UNAVAILABLE")
			to_chat(user, o)
			continue
		var/celsius = convert_k2c(tile_info[index][1])
		var/pressure = tile_info[index][2]
		o += "<span class='[(dir_alerts[index] & (FIREDOOR_ALERT_HOT|FIREDOOR_ALERT_COLD)) ? "warning" : "color:blue"]'>"
		o += "[celsius]&deg;C</span> "
		o += "<span style='color:blue'>"
		o += "[pressure]kPa</span></li>"
		to_chat(user, o)

	if(islist(users_to_open) && users_to_open.len)
		var/users_to_open_string = users_to_open[1]
		if(users_to_open.len >= 2)
			for(var/i = 2 to users_to_open.len)
				users_to_open_string += ", [users_to_open[i]]"
		to_chat(user, "These people have opened \the [src] during an alert: [users_to_open_string].")

/obj/machinery/door/firedoor/Bumped(atom/AM)
	if(p_open || operating)
		return
	if(!density)
		return ..()
	if(istype(AM, /mob/living/exosuit))
		var/mob/living/exosuit/exosuit = AM
		if(exosuit.pilots.len)
			for(var/mob/M in exosuit.pilots)
				if(world.time - M.last_bumped <= 10) return //Can bump-open one airlock per second. This is to prevent popup message spam.
				M.last_bumped = world.time
				attack_hand(M)
	return 0

/obj/machinery/door/firedoor/proc/checkAlarmed()
	var/alarmed = 0
	for(var/area/A in areas_added) //Checks if there are fire alarms in any areas associated with that firedoor
		if(A.fire || A.air_doors_activated)
			alarmed = 1
	return alarmed

/obj/machinery/door/firedoor/attack_hand(mob/user as mob)
	add_fingerprint(user)
	if(operating)
		return//Already doing something.

	if(blocked)
		to_chat(user, SPAN_WARNING("\The [src] is welded solid!"))
		return

	var/alarmed = lockdown || checkAlarmed()

	var/answer = alert(user, "Would you like to [density ? "open" : "close"] this [src.name]?[ alarmed && density ? "\nNote that by doing so, you acknowledge any damages from opening this\n[src.name] as being your own fault, and you will be held accountable under the law." : ""]",\
	"\The [src]", "Yes, [density ? "open" : "close"]", "No")
	if(answer == "No")
		return
	if(user.incapacitated() || (get_dist(src, user) > 1  && !issilicon(user)))
		to_chat(user, "You must remain able bodied and close to \the [src] in order to use it.")
		return
	if(density && (stat & (BROKEN|NOPOWER))) //can still close without power
		to_chat(user, "\The [src] is not functioning, you'll have to force it open manually.")
		return

	if(density && alarmed && !allowed(user))
		to_chat(user, SPAN_WARNING("Access denied.  Please wait for authorities to arrive, or for the alert to clear."))
		return
	else
		user.visible_message("<span class='notice'>\The [src] [density ? "open" : "close"]s for \the [user].</span>",\
		"\The [src] [density ? "open" : "close"]s.",\
		"You hear a beep, and a door opening.")

	if(density)
		if(alarmed)
			// Accountability!
			users_to_open |= user.name
		spawn()
			open()
	else
		spawn()
			close()

/obj/machinery/door/firedoor/attackby(obj/item/I, mob/user)
	add_fingerprint(user)
	if(operating)
		return//Already doing something.

	if(repairing)
		return ..()

	var/list/usable_qualities = list(QUALITY_WELDING,QUALITY_SCREW_DRIVING,QUALITY_PRYING)
	var/tool_type = I.get_tool_type(user, usable_qualities, src)
	switch(tool_type)
		if(QUALITY_WELDING)
			if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
				blocked = !blocked
				user.visible_message("<span class='danger'>\The [user] [blocked ? "welds" : "unwelds"] \the [src] with \a [I].</span>",\
				"You [blocked ? "weld" : "unweld"] \the [src] with \the [I].",\
				"You hear something being welded.")
				update_icon()
				return
			return

		if(QUALITY_SCREW_DRIVING)
			if(density)
				var/used_sound = hatch_open ? 'sound/machines/Custom_screwdriveropen.ogg' :  'sound/machines/Custom_screwdriverclose.ogg'
				if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC, instant_finish_tier = 30, forced_sound = used_sound))
					hatch_open = !hatch_open
					user.visible_message("<span class='danger'>[user] has [hatch_open ? "opened" : "closed"] \the [src] maintenance hatch.</span>",
												"You have [hatch_open ? "opened" : "closed"] the [src] maintenance hatch.")
					update_icon()
					return
			else
				to_chat(user, SPAN_NOTICE("You must close \the [src] first."))
			return

		if(QUALITY_PRYING)
			if(blocked && hatch_open)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					user.visible_message(SPAN_DANGER("[user] has removed the electronics from \the [src]."),
										"You have removed the electronics from [src].")
					if (stat & BROKEN)
						new /obj/item/electronics/circuitboard/broken(src.loc)
					else
						new/obj/item/electronics/airalarm(src.loc)
					var/obj/structure/firedoor_assembly/FA = new/obj/structure/firedoor_assembly(src.loc)
					FA.anchored = TRUE
					FA.density = TRUE
					FA.wired = 1
					FA.update_icon()
					qdel(src)
					return
				return
			if(blocked)
				to_chat(user, SPAN_DANGER("\The [src] is welded shut!"))
				return
			if(!operating)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					user.visible_message("<span class='danger'>\The [user] forces \the [src] [density ? "open" : "closed"] with \a [I]!</span>",\
					"You force \the [src] [density ? "open" : "closed"] with \the [I]!",\
					"You hear metal strain, and a door [density ? "open" : "close"].")
					if(density)
						spawn()
							open(1)
					else
						spawn()
							close(1)
					return
				return
			return

		if(ABORT_CHECK)
			return

	return ..()

// CHECK PRESSURE
/obj/machinery/door/firedoor/Process()
	..()

	if(density)
		var/changed = 0
		lockdown = 0

		// Pressure alerts
		pdiff = getOPressureDifferential(src.loc)
		if(pdiff >= FIREDOOR_MAX_PRESSURE_DIFF)
			lockdown = 1
			if(!pdiff_alert)
				pdiff_alert = 1
				changed = 1 // update_icon()
		else
			if(pdiff_alert)
				pdiff_alert = 0
				changed = 1 // update_icon()

		tile_info = getCardinalAirInfo(src.loc,list("temperature","pressure"))
		var/old_alerts = dir_alerts
		for(var/index = 1; index <= 4; index++)
			var/list/tileinfo=tile_info[index]
			if(tileinfo==null)
				continue // Bad data.
			var/celsius = convert_k2c(tileinfo[1])

			var/alerts=0

			// Temperatures
			if(celsius >= FIREDOOR_MAX_TEMP)
				alerts |= FIREDOOR_ALERT_HOT
				lockdown = 1
			else if(celsius <= FIREDOOR_MIN_TEMP)
				alerts |= FIREDOOR_ALERT_COLD
				lockdown = 1

			dir_alerts[index]=alerts

		if(dir_alerts != old_alerts)
			changed = 1
		if(changed)
			update_icon()

/obj/machinery/door/firedoor/close(var/forced = 0)
	if (blocked) //welded
		return

	if(!forced)
		if(stat & (BROKEN|NOPOWER))
			return //needs power to close unless it was forced
		else
			use_power(360)

	return ..()

/obj/machinery/door/firedoor/open(var/forced = 0)
	if (blocked) //welded
		return

	if(hatch_open)
		hatch_open = 0
		visible_message("The maintenance hatch of \the [src] closes.")
		update_icon()

	if(!forced)
		if(stat & (BROKEN|NOPOWER))
			return //needs power to open unless it was forced
		else
			use_power(360)
	else if (usr)
		log_admin("[usr]([usr.ckey]) has forced open an emergency shutter.")
		message_admins("[usr]([usr.ckey]) has forced open an emergency shutter.")

	if(checkAlarmed())
		spawn(150)
			if(checkAlarmed())
				close()

	return ..()

/obj/machinery/door/firedoor/do_animate(animation)
	switch(animation)
		if("opening")
			flicker("door_opening")
			playsound(src, 'sound/machines/airlock_ext_open.ogg', 37, 1)
		if("closing")
			flicker("door_closing")
			playsound(src, 'sound/machines/airlock_ext_close.ogg', 37, 1)
	return


/obj/machinery/door/firedoor/on_update_icon()
	cut_overlays()
	set_light(0)
	var/do_set_light = FALSE

	if(density)
		SetIconState("door_closed")
		if(hatch_open)
			add_overlays("hatch")
		if(blocked)
			add_overlays("welded")
		if(pdiff_alert)
			add_overlays("palert")
			do_set_light = TRUE
		if(dir_alerts)
			for(var/d=1;d<=4;d++)
				var/cdir = cardinal[d]
				for(var/i=1;i<=ALERT_STATES.len;i++)
					if(dir_alerts[d] & (1<<(i-1)))
						add_overlays(new/icon(icon,"alert_[ALERT_STATES[i]]", dir=cdir))
						do_set_light = TRUE
	else
		SetIconState("door_open")
		if(blocked)
			add_overlays("welded_open")

	if(do_set_light)
		set_light(1.5, 0.5, COLOR_SUN)


/obj/machinery/door/firedoor/multi_tile
	icon = 'icons/obj/doors/DoorHazard2x1.dmi'
	width = 2

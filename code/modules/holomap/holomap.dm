//
// Wall mounted holomap of the station
//
/obj/machinery/holomap
	name = "holomap"
	desc = "A virtual map of the CEV \"Eris\"."
	icon = 'icons/obj/machines/stationmap.dmi'
	icon_state = "station_map"
	anchored = TRUE
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 80
	active_power_usage = 3000

	var/use_auto_lights = 1
	var/light_power_on = 1
	var/light_range_on = 2
	light_color = "#64C864"

	var/mob/watching_mob
	var/image/small_station_map
	var/image/panel

	var/original_zLevel = 1	// zLevel on which the station map was initialized.
	var/bogus = TRUE		// set to 0 when you initialize the station map on a zLevel that has its own icon formatted for use by station holomaps.
	var/datum/station_holomap/holomap_datum
	var/buildstage = 2
	var/wiresexposed = FALSE

/obj/machinery/holomap/New(turf/loc, ndir, building)
	..()
	flags |= ON_BORDER // Why? It doesn't help if its not density

	if(loc)
		src.loc = loc

	if(building)
		if(ndir)
			src.set_dir(ndir)
		buildstage = 0
		wiresexposed = TRUE
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -32 : 32)
		pixel_y = (dir & 3)? (dir ==1 ? -32 : 32) : 0
		update_icon()

	if(!building)
		if(SSholomaps.holomaps_initialized)
			setup_holomap()

/obj/machinery/holomap/Initialize()
	. = ..()
	holomap_datum = new()
	original_zLevel = loc.z
	SSholomaps.station_holomaps += src

/obj/machinery/holomap/Destroy()
	SSholomaps.station_holomaps -= src
	stopWatching()
	holomap_datum = null
	. = ..()

/obj/machinery/holomap/proc/setup_holomap()
	bogus = FALSE
	var/turf/T = get_turf(src)
	original_zLevel = T.z
	if(!("[HOLOMAP_EXTRA_STATIONMAP]_[original_zLevel]" in SSholomaps.extraMiniMaps))
		bogus = TRUE
		holomap_datum.initialize_holomap_bogus()
		update_icon()
		return

	holomap_datum.initialize_holomap(T, reinit = TRUE)

	small_station_map = image(SSholomaps.extraMiniMaps["[HOLOMAP_EXTRA_STATIONMAPSMALL]_[original_zLevel]"], dir = dir)

	spawn(1) //When built from frames, need to allow time for it to set pixel_x and pixel_y
		update_icon()

/obj/machinery/holomap/attack_hand(var/mob/user)
	if(watching_mob && (watching_mob != user))
		to_chat(user, SPAN_WARNING("Someone else is currently watching the holomap."))
		return
	if(user.loc != loc)
		to_chat(user, SPAN_WARNING("You need to stand in front of \the [src]."))
		return
	startWatching(user)

// Let people bump up against it to watch
/obj/machinery/holomap/Bumped(var/atom/movable/AM)
	if(!watching_mob && isliving(AM) && AM.loc == loc)
		startWatching(AM)

// In order to actually get Bumped() we need to block movement.  We're (visually) on a wall, so people
// couldn't really walk into us anyway.  But in reality we are on the turf in front of the wall, so bumping
// against where we seem is actually trying to *exit* our real loc
/obj/machinery/holomap/CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
	// log_debug("[src] (dir=[dir]) CheckExit([mover], [target])  get_dir() = [get_dir(target, loc)]")
	if(get_dir(target, loc) == dir) // Opposite of "normal" since we are visually in the next turf over
		return FALSE
	else
		return TRUE

/obj/machinery/holomap/proc/startWatching(mob/user)
	// Okay, does this belong on a screen thing or what?
	// One argument is that this is an "in game" object becuase its in the world.
	// But I think it actually isn't.  The map isn't holo projected into the whole room, (maybe strat one is!)
	// But for this, the on screen object just represents you leaning in and looking at it closely.
	// So it SHOULD be a screen object.
	// But it is not QUITE a hud either.  So I think it shouldn't go in /datum/hud
	// Okay? Yeah.  Lets use screen objects but manage them manually here in the item.
	// That might be a mistake... I'd rather they be managed by some central hud management system.
	// But the /vg code, while the screen obj is managed, its still adding and removing image, so this is
	// just as good.

	// EH JUST HACK IT FOR NOW SO WE CAN SEE HOW IT LOOKS! STOP OBSESSING, ITS BEEN AN HOUR NOW!

	// TODO - This part!!
	if(isliving(user) && anchored && !(stat & (NOPOWER|BROKEN)) && buildstage == 2 && !wiresexposed)
		if(user.client)
			holomap_datum.station_map.loc = global_hud.holomap  // Put the image on the holomap hud
			holomap_datum.station_map.alpha = 0 // Set to transparent so we can fade in
			animate(holomap_datum.station_map, alpha = 255, time = 5, easing = LINEAR_EASING)
			FLICK("station_map_activate", src)
			// Wait, if wea re not modifying the holomap_obj... can't it be part of the global hud?
			user.client.screen |= global_hud.holomap // TODO - HACK! This should be there permenently really.
			user.client.images |= holomap_datum.station_map
			watching_mob = user
			GLOB.moved_event.register(watching_mob, src, /obj/machinery/holomap/proc/checkPosition)
			GLOB.dir_set_event.register(watching_mob, src, /obj/machinery/holomap/proc/checkPosition)
			GLOB.destroyed_event.register(watching_mob, src, /obj/machinery/holomap/proc/stopWatching)
			update_use_power(ACTIVE_POWER_USE)
			if(bogus)
				to_chat(user, SPAN_WARNING("The holomap has failed to initialize. This area of space cannot be mapped."))
			else
				to_chat(user, SPAN_NOTICE("A hologram of CEV \"Eris\" appears before your eyes."))

/obj/machinery/holomap/attack_ai(mob/living/silicon/robot/user)
	return // TODO
	// user.station_holomap.toggleHolomap(user, isAI(user))

/obj/machinery/holomap/Process()
	if((stat & (NOPOWER|BROKEN)) || !anchored || buildstage < 2 || wiresexposed)
		stopWatching()

/obj/machinery/holomap/proc/checkPosition()
	if(!watching_mob || (watching_mob.loc != loc) || (dir != watching_mob.dir))
		stopWatching()

/obj/machinery/holomap/proc/stopWatching()
	if(watching_mob)
		if(watching_mob.client)
			animate(holomap_datum.station_map, alpha = 0, time = 5, easing = LINEAR_EASING)
			var/mob/M = watching_mob
			spawn(5) //we give it time to fade out
				M.client.images -= holomap_datum.station_map
		GLOB.moved_event.unregister(watching_mob, src)
		GLOB.dir_set_event.unregister(watching_mob, src)
		GLOB.destroyed_event.unregister(watching_mob, src)
	watching_mob = null
	update_use_power(IDLE_POWER_USE)

/obj/machinery/holomap/power_change()
	. = ..()
	update_icon()
	// TODO - Port use_auto_lights from /vg - For now implement it manually here
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(light_range_on, light_power_on)

/obj/machinery/holomap/proc/set_broken()
	stat |= BROKEN
	update_icon()

/obj/machinery/holomap/on_update_icon()
	if(!holomap_datum)
		return //Not yet.

	cut_overlays()

	if(panel_open)
		add_overlays("station_map-panel")
	else
		remove_overlays("station_map-panel")

	if(wiresexposed)
		switch(buildstage)
			if(2)
				icon_state = "station_map_frame_[buildstage]"
			if(1)
				icon_state = "station_map_frame_[buildstage]"
			if(0)
				icon_state = "station_map_frame_[buildstage]"
		set_light(0)
		return

	if(stat & BROKEN)
		icon_state = "station_mapb"
	else if((stat & NOPOWER) || !anchored)
		icon_state = "station_map0"
	else
		icon_state = "station_map"

		if(bogus)
			holomap_datum.initialize_holomap_bogus()
		else
			small_station_map.icon = SSholomaps.extraMiniMaps["[HOLOMAP_EXTRA_STATIONMAPSMALL]_[original_zLevel]"]
			associate_with_overlays(small_station_map)
			holomap_datum.initialize_holomap(get_turf(src))

/obj/machinery/holomap/attackby(obj/item/I, mob/user)
	src.add_fingerprint(user)

	var/list/usable_qualities = list()
	if(buildstage == 2)
		usable_qualities.Add(QUALITY_SCREW_DRIVING)
	if(wiresexposed)
		usable_qualities.Add(QUALITY_WIRE_CUTTING)
	if(buildstage == 1)
		usable_qualities.Add(QUALITY_PRYING)
	if(buildstage == 0)
		usable_qualities.Add(QUALITY_BOLT_TURNING)


	var/tool_type = I.get_tool_type(user, usable_qualities, src)
	switch(tool_type)

		if(QUALITY_SCREW_DRIVING)
			if(buildstage == 2)
				var/used_sound = panel_open ? 'sound/machines/Custom_screwdriveropen.ogg' :  'sound/machines/Custom_screwdriverclose.ogg'
				if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_VERY_EASY, instant_finish_tier = 30, forced_sound = used_sound))
					wiresexposed = !wiresexposed
					to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"]")
					update_icon()
					return
			return

		if(QUALITY_WIRE_CUTTING)
			if(wiresexposed && buildstage == 2)
				if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					user.visible_message(SPAN_WARNING("[user] removed the wires from \the [src]!"), "You have removed the wires from \the [src].")
					new/obj/item/stack/cable_coil(get_turf(user), 5)
					buildstage = 1
					stopWatching()
					update_icon()
					return
			return

		if(QUALITY_PRYING)
			if(buildstage == 1)
				if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					to_chat(user, "You pry out the circuit!")
					new /obj/item/electronics/circuitboard/holomap(get_turf(user))
					buildstage = 0
					update_icon()
					return
			return

		if(QUALITY_BOLT_TURNING)
			if(buildstage == 0)
				if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					to_chat(user, "You remove the [src] assembly from the wall!")
					new /obj/item/frame/holomap(get_turf(user))
					qdel(src)
			return

		if(ABORT_CHECK)
			return

	switch(buildstage)
		if(1)
			if(istype(I, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = I
				if(C.use(5))
					to_chat(user, SPAN_NOTICE("You wire \the [src]."))
					buildstage = 2
					update_icon()
					setup_holomap()
					return
				else
					to_chat(user, SPAN_WARNING("You need 5 pieces of cable to do wire \the [src]."))
					return

		if(0)
			if(istype(I, /obj/item/electronics/circuitboard/holomap))
				to_chat(user, "You insert the circuit!")
				qdel(I)
				buildstage = 1
				update_icon()
				return

	return ..()

/obj/machinery/holomap/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if (prob(50))
				qdel(src)
			else
				set_broken()
		if(3)
			if (prob(25))
				set_broken()

/obj/item/frame/holomap
	name = "\improper holomap frame"
	desc = "Used for building a holomap."
	icon = 'icons/obj/machines/stationmap.dmi'
	icon_state = "station_map_frame_0"
	build_machine_type = /obj/machinery/holomap

/obj/item/electronics/circuitboard/holomap
	name = T_BOARD("Holomap")
	desc = "Looks like a circuit. Probably is."
	origin_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 2)
	w_class = ITEM_SIZE_SMALL

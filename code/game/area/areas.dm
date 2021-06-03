#define STARTUP_STAGE 1
#define MAIN_STAGE 2
#define WIND_DOWN_STAGE 3
#define END_STAGE 4
//weather defines

// Areas.dm

// ===
/area
	name = "Space"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = AREA_LAYER
	//Keeping this on the default plane, GAME_PLANE, will make area overlays fail to render on FLOOR_PLANE.
	plane = BLACKNESS_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_LIGHTING

	var/global/global_uid = 0
	var/uid
	var/tmp/camera_id = 0 // For automatic c_tag setting
	var/ship_area = FALSE

/**
 * Called when an area loads
 *
 *  Adds the item to the GLOB.areas_by_type list based on area type
 */
/area/New()
	// This interacts with the map loader, so it needs to be set immediately
	// rather than waiting for atoms to initialize.
	icon_state = ""
	uid = ++global_uid
	all_areas += src
	if (ship_area)
		ship_areas[src] = TRUE //Adds ourselves to the list of all ship areas

	sanity = new(src)
	return ..()

/*
 * Initalize this area
 *
 * intializes the dynamic area lighting and also registers the area with the z level via
 * reg_in_areas_in_z
 *
 * returns INITIALIZE_HINT_LATELOAD
 */
/area/Initialize(mapload)
	icon_state = ""
	if(requires_power)
		luminosity = 0
	else
		power_light = TRUE
		power_equip = TRUE
		power_environ = TRUE

	. = ..()

	blend_mode = BLEND_MULTIPLY // Putting this in the constructor so that it stops the icons being screwed up in the map editor.

	return INITIALIZE_HINT_LATELOAD

/**
 * Sets machine power levels in the area
 */
/area/LateInitialize()
	power_change()		// all machines set to current power level, also updates lighting icon


/area/proc/get_cameras()
	var/list/cameras = list()
	for (var/obj/machinery/camera/C in src)
		cameras += C
	return cameras

/area/proc/get_camera_tag(var/obj/machinery/camera/C)
	return "[name] #[camera_id++]"

/area/proc/atmosalert(danger_level, var/alarm_source)
	if (danger_level == 0)
		atmosphere_alarm.clearAlarm(src, alarm_source)
	else
		atmosphere_alarm.triggerAlarm(src, alarm_source, severity = danger_level)

	//Check all the alarms before lowering atmosalm. Raising is perfectly fine.
	for (var/obj/machinery/alarm/AA in src)
		if (!(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted && AA.report_danger_level)
			danger_level = max(danger_level, AA.danger_level)

	if(danger_level != atmosalm)
		if (danger_level < 1 && atmosalm >= 1)
			//closing the doors on red and opening on green provides a bit of hysteresis that will hopefully prevent fire doors from opening and closing repeatedly due to noise
			air_doors_open()
		else if (danger_level >= 2 && atmosalm < 2)
			air_doors_close()

		atmosalm = danger_level
		for (var/obj/machinery/alarm/AA in src)
			AA.update_icon()

		return 1
	return 0

/area/proc/air_doors_close()
	if(!air_doors_activated)
		air_doors_activated = 1
		for(var/obj/machinery/door/firedoor/D in all_doors)
			spawn()
				D.close()

/area/proc/air_doors_open()
	if(air_doors_activated)
		air_doors_activated = 0
		for(var/obj/machinery/door/firedoor/D in all_doors)
			spawn()
				D.open()


/area/proc/fire_alert()
	if(!fire)
		fire = 1	//used for firedoor checks
		updateicon()
		mouse_opacity = 0
		for(var/obj/machinery/door/firedoor/D in all_doors)
			spawn()
				D.close()

/area/proc/fire_reset()
	if (fire)
		fire = 0	//used for firedoor checks
		updateicon()
		mouse_opacity = 0
		for(var/obj/machinery/door/firedoor/D in all_doors)
			spawn()
				D.open()

/area/proc/readyalert()
	if(!eject)
		eject = 1
		updateicon()
	return

/area/proc/readyreset()
	if(eject)
		eject = 0
		updateicon()
	return

/area/proc/partyalert()
	if (!( party ))
		party = 1
		updateicon()
		mouse_opacity = 0
	return

/area/proc/partyreset()
	if (party)
		party = 0
		mouse_opacity = 0
		updateicon()
		for(var/obj/machinery/door/firedoor/D in src)
			D.open()
	return

/area/proc/updateicon()

	///////weather

	var/weather_icon
	for(var/V in SSweather.processing)
		var/datum/weather/W = V
		if(W.stage != END_STAGE && (src in get_areas(/area)))
			W.update_areas()
			weather_icon = TRUE
	if(!weather_icon)
		icon_state = null

	////////////weather

	if ((fire || eject || party || atmosalm == 2) && (!requires_power||power_environ) && !istype(src, /area/space))//If it doesn't require power, can still activate this proc.
		if(fire)
			for(var/obj/machinery/light/L in src)
				if(istype(L, /obj/machinery/light/small))
					continue
				L.set_red()
		else if (atmosalm == 2)
			for(var/obj/machinery/light/L in src)
				if(istype(L, /obj/machinery/light/small))
					continue
				L.set_blue()
		else if(!fire && eject && !party && !(atmosalm == 2))
			for(var/obj/machinery/light/L in src)
				if(istype(L, /obj/machinery/light/small))
					continue
				L.set_red()
		else if(party && !fire && !eject && !(atmosalm == 2))
			icon_state = "party"
	else
	//	new lighting behaviour with obj lights
		icon_state = null
		for(var/obj/machinery/light/L in src)
			if(istype(L, /obj/machinery/light/small))
				continue
			L.reset_color()


/*
#define EQUIP 1
#define LIGHT 2
#define ENVIRON 3
*/

/area/proc/powered(var/chan)		// return true if the area has power to given channel

	if(!requires_power)
		return 1
	if(always_unpowered)
		return 0
	switch(chan)
		if(EQUIP)
			return power_equip
		if(LIGHT)
			return power_light
		if(ENVIRON)
			return power_environ

	return 0

// called when power status changes
/area/proc/power_change()
	for(var/obj/machinery/M in src)	// for each machine in the area
		M.power_change()			// reverify power status (to update icons etc.)
	SEND_SIGNAL(src, COMSIG_AREA_APC_POWER_CHANGE)
	updateicon()

/area/proc/usage(var/chan)
	var/used = 0
	switch(chan)
		if(LIGHT)
			used += used_light
		if(EQUIP)
			used += used_equip
		if(ENVIRON)
			used += used_environ
		if(TOTAL)
			used += used_light + used_equip + used_environ
	return used

/area/proc/clear_usage()
	used_equip = 0
	used_light = 0
	used_environ = 0

/area/proc/use_power(var/amount, var/chan)
	switch(chan)
		if(EQUIP)
			used_equip += amount
		if(LIGHT)
			used_light += amount
		if(ENVIRON)
			used_environ += amount


var/list/mob/living/forced_ambiance_list = new

/area/Entered(A)
	if(!isliving(A))
		return

	var/mob/living/L = A
	if(!L.ckey)	return

	if(!L.lastarea)
		L.lastarea = get_area(L.loc)
	var/area/newarea = get_area(L.loc)
	var/area/oldarea = L.lastarea
	if(oldarea.has_gravity != newarea.has_gravity)
		if(newarea.has_gravity == 1 && !MOVING_DELIBERATELY(L)) // Being ready when you change areas allows you to avoid falling.
			thunk(L)
		L.update_floating()

	L.lastarea = newarea
	play_ambience(L)

/area/proc/play_ambience(var/mob/living/L)
    // Ambience goes down here -- make sure to list each area seperately for ease of adding things in later, thanks! Note: areas adjacent to each other should have the same sounds to prevent cutoff when possible.- LastyScratch
	if(!(L && L.client && L.get_preference_value(/datum/client_preference/play_ambiance) == GLOB.PREF_YES))    return

	var/client/CL = L.client

	if(CL.ambience_playing) // If any ambience already playing
		if(forced_ambience && forced_ambience.len)
			if(CL.ambience_playing in forced_ambience)
				return 1
			else
				var/new_ambience = pick(pick(forced_ambience))
				CL.ambience_playing = new_ambience
				sound_to(L, sound(new_ambience, repeat = 1, wait = 0, volume = 30, channel = GLOB.ambience_sound_channel))
				return 1
		if(CL.ambience_playing in ambience)
			return 1

	if(ambience.len && prob(35))
		if(world.time >= L.client.played + 600)
			var/sound = pick(ambience)
			CL.ambience_playing = sound
			sound_to(L, sound(sound, repeat = 0, wait = 0, volume = 10, channel = GLOB.ambience_sound_channel))
			L.client.played = world.time
			return 1
	else
		var/sound = 'sound/ambience/shipambience.ogg'
		CL.ambience_playing = sound
		sound_to(L, sound(sound, repeat = 1, wait = 0, volume = 30, channel = GLOB.ambience_sound_channel))


//Figures out what gravity should be and sets it appropriately
/area/proc/update_gravity()
	var/grav_before = has_gravity
	if(gravity_blocker)
		if(get_area(gravity_blocker) == src)
			has_gravity = FALSE
			if (grav_before != has_gravity)
				gravity_changed()
			return
		else
			gravity_blocker = null

	if (GLOB.active_gravity_generator)
		has_gravity = gravity_is_on

	if (grav_before != has_gravity)
		gravity_changed()



//Called when the gravity state changes
/area/proc/gravity_changed()
	for(var/mob/M in src)
		if(has_gravity)
			thunk(M)
		M.update_floating()

//This thunk should probably not be an area proc.
//TODO: Make it a mob proc
/area/proc/thunk(mob)
	if(istype(get_turf(mob), /turf/space)) // Can't fall onto nothing.
		return

	if(istype(mob,/mob/living/carbon/human/))
		var/mob/living/carbon/human/H = mob
		if(istype(H.shoes, /obj/item/clothing/shoes/magboots) && (H.shoes.item_flags & NOSLIP))
			return
		if(H.stats.getPerk(PERK_ASS_OF_CONCRETE))
			return
		if(MOVING_QUICKLY(H))
			H.AdjustStunned(2)
			H.AdjustWeakened(2)
		else
			H.AdjustStunned(1)
			H.AdjustWeakened(1)
		to_chat(mob, SPAN_NOTICE("The sudden appearance of gravity makes you fall to the floor!"))

/area/proc/prison_break()
	var/obj/machinery/power/apc/theAPC = get_apc()
	if(theAPC.operating)
		for(var/obj/machinery/power/apc/temp_apc in src)
			temp_apc.overload_lighting(70)
		for(var/obj/machinery/door/airlock/temp_airlock in src)
			temp_airlock.prison_open()
		for(var/obj/machinery/door/window/temp_windoor in src)
			temp_windoor.open()

/area/proc/has_gravity()
	return has_gravity

/area/space/has_gravity()
	return 0

/area/proc/are_living_present()
	for(var/mob/living/L in src)
		if(L.stat != DEAD)
			return TRUE
	return FALSE

/proc/has_gravity(atom/AT, turf/T)
	if(!T)
		T = get_turf(AT)
	var/area/A = get_area(T)
	if(A && A.has_gravity())
		return 1
	return 0


/area/proc/set_ship_area()
	if (!ship_area)
		ship_area = TRUE
		ship_areas[src] = TRUE

/area/AllowDrop()
	CRASH("Bad op: area/AllowDrop() called")

/area/drop_location()
	CRASH("Bad op: area/drop_location() called")


// Changes the area of T to A. Do not do this manually.
// Area is expected to be a non-null instance.
/proc/ChangeArea(var/turf/T, var/area/A)
	if(!istype(A))
		CRASH("Area change attempt failed: invalid area supplied.")
	var/area/old_area = get_area(T)
	if(old_area == A)
		return
	A.contents.Add(T)
	if(old_area)
		old_area.Exited(T, A)
		for(var/atom/movable/AM in T)
			old_area.Exited(AM, A)  // Note: this _will_ raise exited events.
	A.Entered(T, old_area)
	for(var/atom/movable/AM in T)
		A.Entered(AM, old_area) // Note: this will _not_ raise moved or entered events. If you change this, you must also change everything which uses them.

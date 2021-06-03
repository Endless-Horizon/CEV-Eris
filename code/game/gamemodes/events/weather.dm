//The effects of weather occur across an entire z-level. For instance, lavaland has periodic ash storms that scorch most unprotected creatures.

/datum/weather
	var/name = "space wind"
	var/desc = "Heavy gusts of wind blanket the area, periodically knocking down anyone caught in the open."

	var/telegraph_message = "<span class='warning'>The wind begins to pick up.</span>" //The message displayed in chat to foreshadow the weather's beginning
	var/telegraph_duration = 300 //In deciseconds, how long from the beginning of the telegraph until the weather begins
	var/telegraph_sound //The sound file played to everyone on an affected z-level
	var/telegraph_overlay //The overlay applied to all tiles on the z-level

	var/weather_message = "<span class='userdanger'>The wind begins to blow ferociously!</span>" //Displayed in chat once the weather begins in earnest
	var/weather_duration = 1200 //In deciseconds, how long the weather lasts once it begins
	var/weather_duration_lower = 1200 //See above - this is the lowest possible duration
	var/weather_duration_upper = 1500 //See above - this is the highest possible duration
	var/weather_sound
	var/weather_overlay
	var/weather_color = null
	var/list/affectareas = list()

	var/end_message = "<span class='danger'>The wind relents its assault.</span>" //Displayed once the weather is over
	var/end_duration = 300 //In deciseconds, how long the "wind-down" graphic will appear before vanishing entirely
	var/end_sound
	var/end_overlay

	var/area_type = /area //Types of area to affect
	var/list/protected_areas = list()//Areas that are protected and excluded from the affected areas.

	var/overlay_layer = 35 //Since it's above everything else, this is the layer used by default. TURF_LAYER is below mobs and walls if you need to use that.
	//var/overlay_plane = BLACKNESS_PLANE
	var/aesthetic = FALSE //If the weather has no purpose other than looks
	var/immunity_type = "storm" //Used by mobs to prevent them from being affected by the weather

	var/stage = END_STAGE //The stage of the weather, from 1-4

	// These are read by the weather subsystem and used to determine when and where to run the weather.
	var/probability = 0 // Weight amongst other eligible weather. If zero, will never happen randomly.
	var/target_trait = 4//ZTRAIT_STATION // The z-level trait to affect when run randomly or when not overridden.

	var/barometer_predictable = FALSE
	var/next_hit_time = 0 //For barometers to know when the next storm will hit

/datum/weather/proc/telegraph()
	if(stage == STARTUP_STAGE)
		return
	stage = STARTUP_STAGE
	for(var/V in get_areas(area_type))
		affectareas += V
	for(var/V in protected_areas)
		affectareas -= get_areas(V)

	weather_duration = rand(weather_duration_lower, weather_duration_upper)
	START_PROCESSING(SSweather, src)
	update_areas()
	for(var/M in GLOB.player_list)
		var/turf/mob_turf = get_turf(M)
		if(mob_turf && (mob_turf.z in world))
			if(telegraph_message)
				to_chat(M, telegraph_message)
			if(telegraph_sound)
				SEND_SOUND(M, sound(telegraph_sound))
	if(telegraph_duration)
		addtimer(CALLBACK(src, .proc/start), telegraph_duration)

/datum/weather/proc/start()
	if(stage >= MAIN_STAGE)
		return
	stage = MAIN_STAGE
	update_areas()
	for(var/M in GLOB.player_list)
		var/turf/mob_turf = get_turf(M)
		if(mob_turf && (mob_turf.z in world))
			if(weather_message)
				to_chat(M, weather_message)
			if(weather_sound)
				SEND_SOUND(M, sound(weather_sound))
	if(weather_duration)
		addtimer(CALLBACK(src, .proc/wind_down), weather_duration)


/datum/weather/proc/wind_down()
	if(stage >= WIND_DOWN_STAGE)
		return
	stage = WIND_DOWN_STAGE
	update_areas()
	for(var/M in GLOB.player_list)
		var/turf/mob_turf = get_turf(M)
		if(mob_turf && (mob_turf.z in world))
			if(end_message)
				to_chat(M, end_message)
			if(end_sound)
				SEND_SOUND(M, sound(end_sound))
	if(end_duration)
		addtimer(CALLBACK(src, .proc/end), end_duration)

/datum/weather/proc/end()
	if(stage == END_STAGE)
		return 1
	stage = END_STAGE
	STOP_PROCESSING(SSweather, src)
	update_areas()

/datum/weather/proc/can_weather_act(mob/living/L) //Can this weather impact a mob?
	var/turf/mob_turf = get_turf(L)
	if(mob_turf && !(mob_turf.z in world))
		return
	if(!(get_area(L) in affectareas))
		return
	return 1

/datum/weather/proc/weather_act(mob/living/L) //What effect does this weather have on the hapless mob?
	return

/datum/weather/proc/update_areas()
	for(var/V in affectareas)
		var/area/N = V
		N.layer = overlay_layer
		N.plane = 150
		N.icon = 'icons/effects/weather_effects.dmi'
		N.color = weather_color
		N.alpha = 128
		switch(stage)
			if(STARTUP_STAGE)
				N.icon_state = telegraph_overlay
			if(MAIN_STAGE)
				N.icon_state = weather_overlay
			if(WIND_DOWN_STAGE)
				N.icon_state = end_overlay
			if(END_STAGE)
				N.color = null
				N.icon_state = ""
				N.icon = 'icons/turf/areas.dmi'
				N.layer = initial(N.layer)
				N.plane = initial(N.plane)
				N.alpha = initial(N.alpha)
				N.set_opacity(FALSE)



///////////////////////////////                                          |WEATHER SUBSYSTEM|
////////////////////////////////////////                                 |SUBSYSTEM WEATHER|
///////////////////////////////////////////////////                      -------------------

//Used for all kinds of weather, ex. lavaland ash storms.
SUBSYSTEM_DEF(weather)
	name = "Weather"
	flags = SS_BACKGROUND
	wait = 10
	runlevels = RUNLEVEL_GAME
	var/list/processing = list()
	var/list/eligible_zlevels = list()
	var/list/next_hit_by_zlevel = list() //Used by barometers to know when the next storm is coming

/datum/controller/subsystem/weather/fire()
	// process active weather
	for(var/V in processing)
		var/datum/weather/W = V
		if(W.aesthetic || W.stage != MAIN_STAGE)
			continue

/datum/controller/subsystem/weather/Initialize(start_timeofday)
	for(var/V in subtypesof(/datum/weather))
		var/datum/weather/W = V
		var/probability = initial(W.probability)

		// any weather with a probability set may occur at random
		if (probability)
			var/list/levels_by_trait = list(1,2,3,4)
			for(var/z in levels_by_trait)
				LAZYINITLIST(eligible_zlevels["[z]"])
				eligible_zlevels["[z]"][W] = probability
	return ..()

/datum/controller/subsystem/weather/proc/run_weather(datum/weather/weather_datum_type)
	if (istext(weather_datum_type))
		for (var/V in subtypesof(/datum/weather))
			var/datum/weather/W = V
			if (initial(W.name) == weather_datum_type)
				weather_datum_type = V
				break
	if (!ispath(weather_datum_type, /datum/weather))
		CRASH("run_weather called with invalid weather_datum_type: [weather_datum_type || "null"]")

	var/datum/weather/W = new weather_datum_type()
	W.telegraph()

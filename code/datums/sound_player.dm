GLOBAL_DATUM_INIT(sound_player, /decl/sound_player, new)

/decl/sound_player
	var/list/sound_tokens_by_sound_id

/decl/sound_player/New()
	..()
	sound_tokens_by_sound_id = list()

/decl/sound_player/proc/play_datum(var/atom/source, var/sound_id, var/sound/sound, var/range, var/prefer_mute)
	var/token_type = isnum(sound.environment) ? /datum/sound_token : /datum/sound_token/static_environment
	return new token_type(source, sound_id, sound, range, prefer_mute)

/decl/sound_player/proc/play_looping(var/atom/source, var/sound_id, var/sound, var/volume, var/range, var/falloff = 1, var/echo, var/frequency, var/prefer_mute)
	var/sound/s = istype(sound, /sound) ? sound : new(sound)
	s.environment = 0
	s.volume = volume
	s.falloff = falloff
	s.echo = echo
	s.frequency = frequency
	s.repeat = TRUE
	return play_datum(source, sound_id, s, range, prefer_mute)

/decl/sound_player/proc/stop_sound(var/datum/sound_token/sound_token)
	var/channel = sound_token.sound.channel
	var/sound_id = sound_token.sound_id

	var/sound_tokens = sound_tokens_by_sound_id[sound_id]
	if(!(sound_token in sound_tokens))
		return
	sound_tokens -= sound_token
	if(length(sound_tokens) == 0)
		GLOB.sound_channels.release(channel)
		sound_tokens_by_sound_id -= sound_id

/decl/sound_player/proc/get_channel(var/datum/sound_token/sound_token)
	var/sound_id = sound_token.sound_id

	. = GLOB.sound_channels.get_by_key(sound_id)
	if(!.)
		. = GLOB.sound_channels.request(sound_id)
		if(!.)
			return

	var/sound_tokens = sound_tokens_by_sound_id[sound_id]
	if(!sound_tokens)
		sound_tokens = list()
		sound_tokens_by_sound_id[sound_id] = sound_tokens
	sound_tokens += sound_token

/datum/sound_token
	var/atom/source
	var/list/listeners
	var/range
	var/prefer_mute
	var/sound/sound
	var/sound_id
	var/status = 0
	var/listener_status
	var/const/SOUND_STOPPED

	var/datum/proximity_trigger/square/proxy_listener
	var/list/can_be_heard_from

/datum/sound_token/New(var/atom/source, var/sound_id, var/sound/sound, var/range = 4, var/prefer_mute = FALSE)
	..()
	if(!istype(source))
		CRASH("Invalid sound source: [log_info_line(source)]")
	if(!istype(sound))
		CRASH("Invalid sound: [log_info_line(sound)]")
	if(sound.repeat && !sound_id)
		CRASH("No sound id given")
	if(!is_environment(sound.environment))
		CRASH("Invalid sound environment: [log_info_line(sound.environment)]")

	listeners = list()
	listener_status = list()

	src.source = source
	src.sound_id = sound_id
	src.sound = sound
	src.range = range
	src.prefer_mute = prefer_mute

	if(sound.repeat)
		var/channel = GLOB.sound_player.get_channel(src)
		if(!isnum(channel))
			CRASH("All available sound channels are in active use.")
		sound.channel = channel
	else
		sound.channel = 0

	GLOB.destroyed_event.register(source, src, /datum/proc/qdel_self)

	if(ismovable(source))
		proxy_listener = new(source, /datum/sound_token/proc/add_listener, /datum/sound_token/proc/locate_listeners, range, proc_owner = src)
		proxy_listener.register_turfs()

/datum/sound_token/Destroy()
	stop()
	return ..()

/datum/sound_token/proc/set_volume(var/new_volume)
	new_volume = CLAMP(new_volume, 0, 100)
	if(sound.volume != new_volume)
		sound.volume = new_volume
		update_listeners()

/datum/sound_token/proc/mute()
	set_status(status | SOUND_MUTE)

/datum/sound_token/proc/unmute()
	set_status(status & ~SOUND_MUTE)

/datum/sound_token/proc/pause()
	set_status(status | SOUND_PAUSED)

/datum/sound_token/proc/unpause()
	set_status(status & ~SOUND_PAUSED)

/datum/sound_token/proc/stop()
	if(status & SOUND_STOPPED)
		return
	status |= SOUND_STOPPED

	var/sound/null_sound = new(channel = sound.channel)
	for(var/listener in listeners)
		remove_listener(listener, null_sound)
	listeners = null
	listener_status = null

	GLOB.destroyed_event.unregister(source, src, /datum/proc/qdel_self)
	QDEL_NULL(proxy_listener)
	source = null

	GLOB.sound_player.stop_sound(src)

/datum/sound_token/proc/locate_listeners(var/list/prior_turfs, var/list/current_turfs)
	if(status & SOUND_STOPPED)
		return

	can_be_heard_from = current_turfs
	var/current_listeners = mob_hearers(get_turf(source), range)
	var/former_listenrs = listeners - current_listeners
	var/new_listeners = current_listeners - listeners

	for(var/listener in former_listenrs)
		remove_listener(listener)

	for(var/listener in new_listeners)
		add_listener(listener)

	for(var/listener in current_listeners)
		update_listener_loc(listener)

/datum/sound_token/proc/set_status(var/new_status)
	if((status & SOUND_STOPPED) || (new_status == status))
		return
	status = new_status
	update_listeners()

/datum/sound_token/proc/add_listener(var/atom/listener)
	if(ismob(listener))
		var/mob/l_mob = listener
		if(l_mob.ear_deaf > 0)
			return
	if(listener in listeners)
		return

	listeners += listener
	sound.status = status | listener_status[listener]
	sound_to(listener, sound)

	GLOB.moved_event.register(listener, src, /datum/sound_token/proc/update_listener_loc)
	GLOB.destroyed_event.register(listener, src, /datum/sound_token/proc/remove_listener)

	update_listener_loc(listener)

/datum/sound_token/proc/remove_listener(var/atom/listener, var/sound/null_sound)
	null_sound = null_sound || new(channel = sound.channel)
	sound_to(listener, null_sound)
	GLOB.moved_event.unregister(listener, src, /datum/sound_token/proc/update_listener_loc)
	GLOB.destroyed_event.unregister(listener, src, /datum/sound_token/proc/remove_listener)
	listeners -= listener

/datum/sound_token/proc/update_listener_loc(var/atom/listener)
	var/turf/source_turf = get_turf(source)
	var/turf/listener_turf = get_turf(listener)

	var/distance = get_dist(source_turf, listener_turf)
	if(!listener_turf || (distance > range) || !(listener_turf in can_be_heard_from))
		if(prefer_mute)
			listener_status[listener] |= SOUND_MUTE
		else
			remove_listener(listener)
	else if(prefer_mute)
		listener_status[listener] &= ~SOUND_MUTE

	sound.x = source_turf.x - listener_turf.x
	sound.z = source_turf.y - listener_turf.y
	sound.y = 1

	sound.priority = CLAMP(255 - distance, 0, 255)
	update_listener(listener)

/datum/sound_token/proc/update_listeners()
	for(var/listener in listeners)
		update_listener(listener)

/datum/sound_token/proc/update_listener(var/listener)
	sound.environment = get_environment(listener)
	sound.status = status | listener_status[listener] | SOUND_UPDATE
	sound_to(listener, sound)

/datum/sound_token/proc/get_environment(var/listener)
	var/area/a = get_area(listener)
	return (a && is_environment(a.sound_env)) ? a.sound_env : sound.environment

/datum/sound_token/proc/is_environment(var/environment)
	if(islist(environment) && length(environment) != 23)
		return FALSE
	if(!isnum(environment) || (environment < 0) || (environment > 25))
		return FALSE
	return TRUE

/datum/sound_token/static_environment/get_environment()
	return sound.environment

SUBSYSTEM_DEF(inactivity)
	name = "Inactivity"
	wait = 1 MINUTES
	priority = FIRE_PRIORITY_INACTIVITY
	var/tmp/list/client_list
	var/number_kicked = 0

/datum/controller/subsystem/inactivity/fire(resumed = FALSE)
	if (!resumed)
		client_list = clients.Copy()

	while(client_list.len)
		var/client/C = client_list[client_list.len]
		client_list.len--
		if(!C.holder && C.is_afk(config.kick_inactive MINUTES) && !isobserver(C.mob))
			log_access("AFK: [key_name(C)]")
			to_chat(C, SPAN_WARNING("You have been inactive for more than [config.kick_inactive] minute\s and have been disconnected."))
			del(C) // Don't qdel, cannot override finalize_qdel behaviour for clients.
			number_kicked++
		else if (C.mob && C.mob.mind && C.mob.stat != DEAD)
			C.mob.mind.last_activity = world.time - C.inactivity

		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/inactivity/stat_entry()
	..("Kicked: [number_kicked]")

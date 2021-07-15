/datum/wires/rig
	random = 1
	holder_type = /obj/item/rig
	wire_count = 5

//The defines for the wires are moved to rig.dm, as they are used there
/*
 * Rig security can be snipped to disable ID access checks on rig.
 * Rig AI override can be pulsed to toggle whether or not the AI can take control of the suit.
 * System control can be pulsed to toggle some malfunctions.
 * Interface lock can be pulsed to toggle whether or not the interface can be accessed.
 */

/datum/wires/rig/UpdateCut(index, mended)

	var/obj/item/rig/rig = holder
	switch(index)
		if(RIG_SECURITY)
			if(mended)
				rig.req_access = initial(rig.req_access)
				rig.req_one_access = initial(rig.req_one_access)
		if(RIG_INTERFACE_SHOCK)
			rig.electrified = mended ? 0 : -1
			rig.shock(usr,100)
		if(RIG_SYSTEM_CONTROL)
			if(mended)
				rig.malfunctioning = 0
				rig.malfunction_delay = 0
			else
				rig.malfunctioning = 10
				rig.malfunction_delay = 30

/datum/wires/rig/UpdatePulsed(index)

	var/obj/item/rig/rig = holder
	switch(index)
		if(RIG_SECURITY)
			rig.security_check_enabled = !rig.security_check_enabled
			rig.visible_message("\The [rig] twitches as several suit locks [rig.security_check_enabled?"close":"open"].")
		if(RIG_AI_OVERRIDE)
			rig.ai_override_enabled = !rig.ai_override_enabled
			rig.visible_message("A small red light on [rig] [rig.ai_override_enabled?"goes dead":"flickers on"].")
		if(RIG_SYSTEM_CONTROL)
			rig.malfunctioning += 10
			if(rig.malfunction_delay <= 0)
				rig.malfunction_delay = 20
			rig.shock(usr,100)
		if(RIG_INTERFACE_LOCK)
			rig.interface_locked = !rig.interface_locked
			rig.visible_message("\The [rig] clicks audibly as the software interface [rig.interface_locked?"darkens":"brightens"].")
		if(RIG_INTERFACE_SHOCK)
			if(rig.electrified != -1)
				rig.electrified = 30
			rig.shock(usr,100)

/datum/wires/rig/CanUse(var/mob/living/L)
	var/obj/item/rig/rig = holder
	return rig.open

#undef RIG_SECURITY
#undef RIG_AI_OVERRIDE
#undef RIG_SYSTEM_CONTROL
#undef RIG_INTERFACE_LOCK
#undef RIG_INTERFACE_SHOCK
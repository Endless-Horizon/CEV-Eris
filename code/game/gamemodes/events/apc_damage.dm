//APC Damage is a mundane event that bluscreens some APCs in a radius
//It mainly exists for two purposes:
//1. To create some work for engineers
//2. To provide plausible deniability for a malfunctioning AI, so they can claim its not their doing when apcs break
/datum/storyevent/apc_damage
	id = "apc_dmg"
	name = "APC damage"

	event_type =/datum/event/apc_damage
	event_pools = list(EVENT_LEVEL_MUNDANE = POOL_THRESHOLD_MUNDANE)
	tags = list(TAG_DESTRUCTIVE, TAG_NEGATIVE)

//////////////////////////////////////////////////////////

/datum/event/apc_damage
	var/apcSelectionRange	= 25

/datum/event/apc_damage/start()
	var/obj/machinery/power/apc/A = acquire_random_apc()

	var/severity_range = 15
	log_and_message_admins("APC damage triggered at [jumplink(A)],")
	for(var/obj/machinery/power/apc/apc in range(severity_range,A))
		if(is_valid_apc(apc))
			apc.emagged = 1
			apc.update_icon()

/datum/event/apc_damage/proc/acquire_random_apc()
	var/list/apcs = list()


	for(var/obj/machinery/power/apc/apc in GLOB.machines)
		if(is_valid_apc(apc))
			// Greatly reduce the chance for APCs in maintenance areas to be selected
			var/area/A = get_area(apc)
			if(!istype(A,/area/eris/maintenance) || prob(25))
				apcs += apc

	if(!apcs.len)
		return

	return pick(apcs)

/proc/is_valid_apc(var/obj/machinery/power/apc/apc)
	var/area/A = get_area(apc)
	return !(A && (A.flags & AREA_FLAG_CRITICAL)) && !apc.emagged && isOnShipLevel(apc)

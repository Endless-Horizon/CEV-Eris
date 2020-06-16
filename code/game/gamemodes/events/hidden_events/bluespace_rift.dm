/*
Creates a number of two ways teleporters in maints.
They are unstable and be used only few times, and after that they die out on both sides.
*/

/datum/storyevent/bluespace_rift
	id = "bluespace_rift"
	name = "bluespace_rift"

	weight = 1

	event_type = /datum/event/bluespace_rift
	event_pools = list(
		EVENT_LEVEL_MODERATE = POOL_THRESHOLD_MODERATE * 1.2
	)
	tags = list(TAG_POSITIVE)


/datum/event/bluespace_rift
	var/list/event_areas = list()
	var/list/obj/effect/portal/rift/rifts = list()
	var/pair_number
	var/rift_number

/datum/event/bluespace_rift/setup()
	pair_number = rand(1, 5)
	rift_number = pair_number * 2
	prepare_event_areas(rift_number)

/datum/event/bluespace_rift/start()
	for(var/area/A in event_areas)
		rifts.Add(new /obj/effect/portal/rift(A.random_space(), rand(3, 10)))
	for(var/i=0, i<pair_number, i++)
		var/obj/effect/portal/rift/enter = pick_n_take(rifts)
		var/obj/effect/portal/rift/exit = pick_n_take(rifts)
		enter.pair(exit)
		log_and_message_admins("Bluespace rift created between [jumplink(enter)] and [jumplink(exit)] with [enter.usages_left] teleportations left.")


/datum/event/bluespace_rift/proc/prepare_event_areas(var/number)
	var/area/list/candidates = all_areas.Copy()
	var/area/candidate
	for(candidate in candidates)
		if(!candidate.is_maintenance)
			candidates -= candidate
	for(var/i=0, i<number, i++)
		event_areas.Add(pick_n_take(candidates))
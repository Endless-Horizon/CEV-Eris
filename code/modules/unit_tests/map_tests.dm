/*
 *  Map Unit Tests.
 *  Zone checks / APC / Scrubber / Vent.
 */

/datum/unit_test/area_contents/Run()
	var/static/list/exempt_areas = typesof(
		/area/space, /area/skipjack_station,
		/area/shuttle, /area/holodeck,
		/area/supply/station)

	var/static/list/exempt_from_atmos = typesof(
		/area/eris/maintenance, /area/eris/storage,
		/area/eris/engineering/atmos/storage,
		/area/eris/engineering/construction,
		/area/eris/rnd/server)

	var/static/list/exempt_from_apc = typesof(
		/area/eris/engineering/construction,
		/area/eris/medical/genetics)

	for(var/area/A in GLOB.map_areas)
		if(A.z == 1 && !(A.type in exempt_areas))
			TEST_ASSERT(isnull(A.apc) && !(A.type in exempt_from_apc), "[A.name]([A.type]) lacks an APC.")
			TEST_ASSERT((!A.air_scrub_info?.len || !A.air_vent_info?.len) && !(A.type in exempt_from_atmos), "[A.name]([A.type]) lacks an air scrubber [(!A.air_scrub_info?.len && !A.air_vent_info?.len) ? "and" : "or"] a vent.")

/datum/unit_test/wire_stacking/Run()
	var/turf/T
	var/list/cable_turfs = list()
	var/list/dirs_checked = list()

	var/obj/structure/cable/C
	for(C in world) // ew, world
		T = get_turf(C)
		if(T?.z == 1)
			cable_turfs |= get_turf(C)

	for(T in cable_turfs)
		dirs_checked.Cut()
		for(C in T)
			var/combined_dir = "[C.d1]-[C.d2]"
			// is this really needed? grep already handles this i think
			TEST_ASSERT((combined_dir in dirs_checked),"[T.name] ([T.x],[T.y],[T.z]) Contains multiple wires with same direction on top of each other.")
			dirs_checked.Add(combined_dir)

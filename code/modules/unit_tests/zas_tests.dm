/*
 *
 *  Zas Unit Tests.
 *  Shuttle Pressurized.
 *
 *
 */

#define UT_NORMAL 1                   // Standard one atmosphere 20celsius
#define UT_VACUUM 2                   // Vacume on simulated turfs
#define UT_NORMAL_COLD 3              // Cold but standard atmosphere.

/// Generic check for an area.
/datum/unit_test/zas_area_test

/datum/unit_test/zas_area_test/Run()
	var/list/normal_test = list(
		/area/supply/dock,
		/area/shuttle/escape/centcom,
		/area/turret_protected/ai,
		/area/shuttle/mining/station,
		/area/eris/medical/virology,
		/area/eris/rnd/xenobiology,
		/area/outpost/mining_main/west_hall,
		/area/eris/quartermaster/storage
	)

	log_test("Testing areas requiring UT_NORMAL")
	for(var/area/a in normal_test)
		test_air_in_area(a, UT_NORMAL)

/// The primary helper proc.
/datum/unit_test/proc/test_air_in_area(test_area, expectation = UT_NORMAL)
	log_test("Testing [test_area]")
	var/area/A = locate(test_area)
	TEST_ASSERT(istype(A, test_area), "Unable to get [test_area]")

	var/list/GM_checked = list()
	for(var/turf/simulated/T in A)
		if(!istype(T) || isnull(T.zone) || istype(T, /turf/simulated/floor/airless))
			continue
		if(T.zone.air in GM_checked)
			continue

		var/t_msg = "Turf: [T] |  Location: ([T.x], [T.y], [T.z])"
		var/datum/gas_mixture/GM = T.return_air()
		var/pressure = GM.return_pressure()
		var/temp = GM.temperature

		switch(expectation)
			if(UT_VACUUM)
				// todo: make assert use InRange()
				TEST_ASSERT(pressure < 10, "Pressure out of bounds: [pressure] | [t_msg]")

			if(UT_NORMAL || UT_NORMAL_COLD)
				TEST_ASSERT(abs(pressure - ONE_ATMOSPHERE) < 10, "Pressure out of bounds: [pressure] | [t_msg]")

				switch(expectation)
					if(UT_NORMAL)
						TEST_ASSERT(abs(temp - T20C) < 10, "Temperature out of bounds: [temp] | [t_msg]")

					if(UT_NORMAL_COLD)
						TEST_ASSERT(temp < 120, "Temperature out of bounds: [temp] | [t_msg]")

		GM_checked.Add(GM)

	log_test("Checked [GM_checked.len] zones")

/// Test for checking if the air suddenly broke on transit
/datum/unit_test/zas_supply_shuttle_moved/Run()
	var/datum/shuttle/autodock/ferry/supply/shuttle

	TEST_ASSERT(length(SSshuttle.shuttles), "No shuttles have been setup for this map.")

	shuttle = SSsupply.shuttle
	TEST_ASSERT(shuttle, "Cargo shuttle is null for some reason. This will cause runtimes on the CI")

	// Initiate the Move.
	SSsupply.movetime = 2 // Speed up the shuttle movement.
	shuttle.short_jump(shuttle.get_location_waypoint(!shuttle.location)) //TODO

	sleep(2 SECONDS) // if this ci goes down 2 seconds you should worry

	TEST_ASSERT(shuttle.moving_status == SHUTTLE_IDLE && !shuttle.at_station(), "Shuttle did not move")

	for(var/i in shuttle.shuttle_area)
		var/area/A = i
		test_air_in_area(A.type)
	return 1

#undef UT_NORMAL
#undef UT_VACUUM
#undef UT_NORMAL_COLD

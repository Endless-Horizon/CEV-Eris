/datum/unit_test/force_move_trigger_crossed/Run()
	var/turf/start = locate(20,20,1)
	var/turf/target = locate(20,21,1)

	var/obj/mover = new /obj/test(start, 1)
	var/obj/test/crossed_obj/crossed = new(target, 1)

	mover.forceMove(target)

	if(!crossed.crossers)
		Fail("The target object was never crossed.")
	TEST_ASSERT_EQUAL(crossed.crossers.len, 1, "The target object was crossed multiple times, expected 1.")

	qdel(target)
	qdel(crossed)

/datum/unit_test/force_move_trigger_entered/Run()
	var/turf/start = locate(20,20,1)
	var/obj/mover = new /obj/test(start, 1)
	var/obj/test/entered_obj/target = new(start, 1)

	mover.forceMove(target)

	if(!target.enterers)
		Fail("The target object was never entered.")
	TEST_ASSERT_EQUAL(target.enterers.len, 1, "The target object was entered multiple times, expected 1.")

	qdel(mover)
	qdel(target)

/obj/test/crossed_obj
	var/list/crossers

/obj/test/crossed_obj/Crossed(crosser)
	if(!crossers)
		crossers = list()
	crossers += crosser

/obj/test/entered_obj
	var/list/enterers

/obj/test/entered_obj/Entered(enterer)
	if(!enterers)
		enterers = list()
	enterers += enterer

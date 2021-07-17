/// Checks if the override for step doesn't break the actual parent (byond built in) code
/datum/unit_test/step_override

/datum/unit_test/step_override/Run()
	var/mob_step_result = TestStep(/mob)
	var/obj_step_result = TestStep(/obj)

	TEST_ASSERT(mob_step_result, "step() did not return true on mob step. Return: [mob_step_result]")
	TEST_ASSERT(obj_step_result, "step() did not return true on object step. Return: [obj_step_result]")

/datum/unit_test/step_override/proc/TestStep(type_to_test)
	var/atom/movable/AM = allocate(type_to_test) // alloc spawns them at 20,20,1||20,21,1
	var/turf/T = get_turf(AM)

	. = step(AM, NORTH)
	. = . && T.x == AM.x
	. = . && T.y + 1 == AM.y // eh?
	. = . && T.z == AM.z

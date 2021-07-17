
/*
 *  Mob Unit Tests.
 *
 *  Human suffocation in Space.
 *  Mob damage Template
 */

/proc/damage_check(mob/living/M, damage_type)
	var/loss

	switch(damage_type)
		if(BRUTE)
			loss = M.getBruteLoss()
		if(BURN)
			loss = M.getFireLoss()
		if(TOX)
			loss = M.getToxLoss()
		if(OXY)
			loss = M.getOxyLoss()
		if(CLONE)
			loss = M.getCloneLoss()
		if(HALLOSS)
			loss = M.getHalLoss()
	return loss

/// Used to test mob breathing in space
/datum/unit_test/human_breath

/datum/unit_test/human_breath/Run()
	var/starting_oxyloss
	var/ending_oxyloss
	// Pause natural mob life so it can be handled entirely by the test
	SSmobs.pause()

	var/turf/T = locate(/turf/space)
	var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human)
	H = new(T)
	TEST_ASSERT(istype(T, /turf/space), "Turf is not space even though locate says so.")

	starting_oxyloss = damage_check(H, OXY)

	for(var/__i in 1 to 10)
		H.breathe()
		// H.life() // fire it 10 times

	ending_oxyloss = damage_check(H, OXY)
	TEST_ASSERT(starting_oxyloss < ending_oxyloss, "Mob is not taking oxygen damage. Damange is [ending_oxyloss]")

/datum/unit_test/human_breath/Destroy()
	SSmobs.ignite()
	return ..()

//DAMAGE EXPECTATIONS
// used with expectected_vunerability

#define STANDARD 0            // Will take standard damage (damage_ratio of 1)
#define ARMORED 1             // Will take less damage than applied
#define EXTRA_VULNERABLE 2    // Will take more dmage than applied
#define IMMUNE 3              // Will take no damage

/datum/unit_test/mob_damage/Run()
	var/list/damtypes = list(
		BRUTE, BURN, TOX,
		OXY, CLONE, HALLOSS)

	for(var/i in damtypes)
		var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human)
		check_damage(H, i)// hi
		qdel(H)

/datum/unit_test/mob_damage/proc/check_damage(mob/living/carbon/human/H, damtype = BRUTE, expected_vulnerability = STANDARD)
	// Damage the mob
	var/initial_health = H.health

	H.apply_damage(5, damtype, BP_CHEST)
	H.updatehealth() // Just in case, though at this time apply_damage does this for us.
                         // We operate with the assumption that someone might mess with that proc one day.

	var/ending_damage = damage_check(H, damtype)
	var/ending_health = H.health

	// Now test this stuff.

	var/failure = FALSE
	var/damage_ratio = STANDARD

	if (ending_damage == 0)
		damage_ratio = IMMUNE

	else if (ending_damage < 5)
		damage_ratio = ARMORED

	else if (ending_damage > 5)
		damage_ratio = EXTRA_VULNERABLE

	if(damage_ratio != expected_vulnerability)
		failure = TRUE

	// Now generate the message for this test.

	var/expected_msg

	switch(expected_vulnerability)
		if(STANDARD)
			expected_msg = "to take standard damage"
		if(ARMORED)
			expected_msg = "To take less damage"
		if(EXTRA_VULNERABLE)
			expected_msg = "To take extra damage"
		if(IMMUNE)
			expected_msg = "To take no damage"

	if(failure)
		Fail("Failed at damage type [damtype]. Damage taken: [ending_damage] out of 5 => expected: [expected_msg] \[Overall Health:[ending_health] (Initial: [initial_health]\]")


/datum/unit_test/robot_module_icons/Run()
	var/icon_file = 'icons/mob/screen1_robot.dmi'
	var/list/valid_states = icon_states(icon_file)

	for(var/i in robot_modules)
		if(!(lowertext(i) in valid_states))
			Fail("[i] does not contain a valid icon state in [icon_file]")

#undef STANDARD
#undef ARMORED
#undef EXTRA_VULNERABLE
#undef IMMUNE

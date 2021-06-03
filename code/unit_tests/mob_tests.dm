
/*
 *
 *  Mob Unit Tests.
 *
 *  Human suffocation in Space.
 *  Mob damage Template
 *
 */

#define SUCCESS 1
#define FAILURE 0

//
// Tests Life() and mob breathing in space.
//



datum/unit_test/human_breath
	name = "MOB: Human Suffocates in Space"
	var/starting_oxyloss
	var/ending_oxyloss
	var/mob/living/carbon/human/H
	async = 1


datum/unit_test/human_breath/start_test()
	var/turf/T = locate(20,20,1) //TODO:  Find better way.

	if(!istype(T, /turf/space))	//If the above isn't a space turf then we force it to find one will most likely pick 1,1,1
		T = locate(/turf/space)

	H = new(T)

	starting_oxyloss = damage_check(H, OXY)

	return 1

datum/unit_test/human_breath/check_result()

	if(H.life_tick < 10) 	// Finish Condition
		return 0	// Return 0 to try again later.

	ending_oxyloss = damage_check(H, OXY)

	if(starting_oxyloss < ending_oxyloss)
		pass("Oxyloss = [ending_oxyloss]")
	else
		fail("Mob is not taking oxygen damage.  Damange is [ending_oxyloss]")

	return 1	// return 1 to show we're done and don't want to recheck the result.

// ============================================================================

//#define BRUTE     "brute"
//#define BURN      "fire"
//#define TOX       "tox"
//#define OXY       "oxy"
//#define CLONE     "clone"
//#define HALLOSS   "halloss"


proc/create_test_mob_with_mind(var/turf/mobloc = null, var/mobtype = /mob/living/carbon/human)
	var/list/test_result = list("result" = FAILURE, "msg"    = "", "mobref" = null)

	if(isnull(mobloc))
		mobloc = pick_spawn_location("Aft Cryogenic Storage")
	if(!mobloc)
		test_result["msg"] = "Unable to find a location to create test mob"
		return test_result

	var/mob/living/carbon/human/H = new mobtype(mobloc)

	H.mind_initialize("TestKey[rand(0,10000)]")

	test_result["result"] = SUCCESS
	test_result["msg"] = "Mob created"
	test_result["mobref"] = "\ref[H]"

	return test_result

//Generic Check
// TODO: Need to make sure I didn't just recreate the wheel here.

proc/damage_check(var/mob/living/M, var/damage_type)
	var/loss

	if(!istype(M))
		return 0

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

// ==============================================================================================================

//
//DAMAGE EXPECTATIONS
// used with expectected_vunerability

#define STANDARD 0            // Will take standard damage (damage_ratio of 1)
#define ARMORED 1             // Will take less damage than applied
#define EXTRA_VULNERABLE 2    // Will take more dmage than applied
#define IMMUNE 3              // Will take no damage

//==============================================================================================================


datum/unit_test/mob_damage
	name = "MOB: Template for mob damage"
	var/mob/living/carbon/human/testmob = null
	var/damagetype = BRUTE
	var/mob_type = /mob/living/carbon/human
	var/expected_vulnerability = STANDARD
	var/check_health = 0
	var/damage_location = BP_CHEST

datum/unit_test/mob_damage/start_test()
	var/list/test = create_test_mob_with_mind(null, mob_type)
	var/damage_amount = 5	// Do not raise, if damage >= 10 there is a % chance to reduce damage by half in /obj/item/organ/external/take_damage()
                                // Which makes checks impossible.

	if(isnull(test))
		fail("Check Runtimed in Mob creation")

	if(test["result"] == FAILURE)
		fail(test["msg"])
		return 0

	var/mob/living/carbon/human/H = locate(test["mobref"])

	if(isnull(H))
		fail("Test unable to set test mob from reference")
		return 0

	if(H.stat)

		fail("Test needs to be re-written, mob has a stat = [H.stat]")
		return 0

	if(H.sleeping)
		fail("Test needs to be re-written, mob is sleeping for some unknown reason")
		return 0

	// Damage the mob

	var/initial_health = H.health

	H.apply_damage(damage_amount, damagetype, damage_location)

	H.updatehealth() // Just in case, though at this time apply_damage does this for us.
                         // We operate with the assumption that someone might mess with that proc one day.

	var/ending_damage = damage_check(H, damagetype)

	var/ending_health = H.health

	// Now test this stuff.

	var/failure = 0

	var/damage_ratio = STANDARD

	if (ending_damage == 0)
		damage_ratio = IMMUNE

	else if (ending_damage < damage_amount)
		damage_ratio = ARMORED

	else if (ending_damage > damage_amount)
		damage_ratio = EXTRA_VULNERABLE

	if(damage_ratio != expected_vulnerability)
		failure = 1

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


	var/msg = "Damage taken: [ending_damage] out of [damage_amount] || expected: [expected_msg] \[Overall Health:[ending_health] (Initial: [initial_health]\]"

	if(failure)
		fail(msg)
	else
		pass(msg)

	return 1

// =================================================================
// Human damage check.
// =================================================================

datum/unit_test/mob_damage/brute
	name = "MOB: Human Brute damage check"
	damagetype = BRUTE

datum/unit_test/mob_damage/fire
	name = "MOB: Human Fire damage check"
	damagetype = BURN

datum/unit_test/mob_damage/tox
	name = "MOB: Human Toxin damage check"
	damagetype = TOX

datum/unit_test/mob_damage/oxy
	name = "MOB: Human Oxygen damage check"
	damagetype = OXY

datum/unit_test/mob_damage/clone
	name = "MOB: Human Clone damage check"
	damagetype = CLONE

datum/unit_test/mob_damage/halloss
	name = "MOB: Human Halloss damage check"
	damagetype = HALLOSS

// ==============================================================================


datum/unit_test/robot_module_icons
	name = "MOB: Robot module icon check"
	var/icon_file = 'icons/mob/screen1_robot.dmi'

datum/unit_test/robot_module_icons/start_test()
	var/failed = 0
	if(!isicon(icon_file))
		fail("[icon_file] is not a valid icon file.")
		return 1

	var/list/valid_states = icon_states(icon_file)

	if(!valid_states.len)
		return 1

	for(var/i=1, i<=robot_modules.len, i++)
		var/bad_msg = "[ascii_red]--------------- [robot_modules[i]]"
		if(!(lowertext(robot_modules[i]) in valid_states))
			log_unit_test("[bad_msg] does not contain a valid icon state in [icon_file][ascii_reset]")
			failed=1

	if(failed)
		fail("Some icon states did not exist")
	else
		pass("All modules had valid icon states")

	return 1

#undef SUCCESS
#undef FAILURE
#undef STANDARD
#undef ARMORED
#undef EXTRA_VULNERABLE
#undef IMMUNE

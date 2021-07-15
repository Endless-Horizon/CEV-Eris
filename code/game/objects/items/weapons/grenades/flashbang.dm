/obj/item/grenade/flashbang
	name = "FS FBG \"Serra\""
	desc = "A \"Frozen Star\" flashbang grenade. If in any doubt - use it."
	icon_state = "flashbang"
	item_state = "flashbang"
	origin_tech = list(TECH_MATERIAL = 2, TECH_COMBAT = 1)
	var/banglet = 0

/obj/item/grenade/flashbang/prime()
	..()
	for(var/obj/structure/closet/L in hear(7, get_turf(src)))
		if(locate(/mob/living/carbon/, L))
			for(var/mob/living/carbon/M in L)
				flashbang_bang(get_turf(src), M)


	for(var/mob/living/carbon/M in hear(7, get_turf(src)))
		flashbang_bang(get_turf(src), M)

	for(var/mob/living/carbon/human/thermal_user in orange(9, loc))
		if(!thermal_user.glasses)
			return
		var/obj/item/clothing/glasses/potential_thermals = thermal_user.glasses
		if(potential_thermals.overlay == global_hud.thermal)
			flashbang_without_the_bang(get_turf(src), thermal_user)

	for(var/obj/effect/blob/B in hear(8,get_turf(src)))       		//Blob damage here
		var/damage = round(30/(get_dist(B,get_turf(src))+1))
		B.health -= damage
		B.update_icon()

	new/obj/effect/sparks(loc)
	new/obj/effect/effect/smoke/illumination(loc, brightness=15)
	qdel(src)
	return
/obj/item/proc/flashbang_without_the_bang(turf/T, mob/living/carbon/M) ///flashbang_bang but bang-less.
//Checking for protections
	var/eye_safety = 0
	if(iscarbon(M))
		eye_safety = M.eyecheck()
//Flashing everyone
	if(eye_safety < FLASH_PROTECTION_MODERATE)
		if (M.HUDtech.Find("flash"))
			FLICK("e_flash", M.HUDtech["flash"])
		M.eye_blurry = max(M.eye_blurry, 15)
		M.eye_blind = max(M.eye_blind, 5)

	//This really should be in mob not every check
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/eyes/E = H.random_organ_by_process(OP_EYES)
		if (E && E.damage >= E.min_bruised_damage)
			to_chat(M, SPAN_DANGER("Your eyes start to burn badly!"))
	M.stats.addTempStat(STAT_VIG, -STAT_LEVEL_ADEPT, 10 SECONDS, "flashbang")
	M.stats.addTempStat(STAT_COG, -STAT_LEVEL_ADEPT, 10 SECONDS, "flashbang")
	M.stats.addTempStat(STAT_BIO, -STAT_LEVEL_ADEPT, 10 SECONDS, "flashbang")
	M.stats.addTempStat(STAT_MEC, -STAT_LEVEL_ADEPT, 10 SECONDS, "flashbang")
	M.update_icons()

/obj/item/proc/flashbang_bang(var/turf/T, var/mob/living/carbon/M, var/explosion_text = "BANG") //Bang made into an item proc so lot's of stuff can use it wtihout copy - paste
	to_chat(M, SPAN_DANGER(explosion_text))								// Called during the loop that bangs people in lockers/containers and when banging
	playsound(loc, 'sound/effects/bang.ogg', 50, 1, 5)		// people in normal view.  Could theroetically be called during other explosions.
																// -- Polymorph

//Checking for protections
	var/eye_safety = 0
	var/ear_safety = 0
	var/stat_def = -STAT_LEVEL_ADEPT
	if(iscarbon(M))
		eye_safety = M.eyecheck()
		if(ishuman(M))
			if(istype(M:l_ear, /obj/item/clothing/ears/earmuffs) || istype(M:r_ear, /obj/item/clothing/ears/earmuffs))
				ear_safety += 2
			if(HULK in M.mutations)
				ear_safety += 1
			if(istype(M:head, /obj/item/clothing/head/armor/helmet))
				ear_safety += 1
			if(M.stats.getPerk(PERK_EAR_OF_QUICKSILVER))
				stat_def *= 2

//Flashing everyone
	if(eye_safety < FLASH_PROTECTION_MODERATE)
		if (M.HUDtech.Find("flash"))
			FLICK("e_flash", M.HUDtech["flash"])
		M.eye_blurry = max(M.eye_blurry, 15)
		M.eye_blind = max(M.eye_blind, 5)


//Now applying sound
	if((get_dist(M, T) <= 2 || loc == M.loc || loc == M))
		if(ear_safety <= 0)
			stat_def *= 5
			if ((prob(14) || (M == loc && prob(70))))
				M.adjustEarDamage(rand(1, 10))
				M.confused = max(M.confused,8)
			else
				M.adjustEarDamage(rand(0, 5))
				M.ear_deaf = max(M.ear_deaf,15)
				M.confused = max(M.confused,8)
		else
			stat_def *= 2
			M.confused = max(M.confused,4)

	else if(get_dist(M, T) <= 5)
		if(ear_safety <= 0)
			stat_def *= 4
			M.adjustEarDamage(rand(0, 3))
			M.ear_deaf = max(M.ear_deaf,10)
			M.confused = max(M.confused,6)
		else
			M.confused = max(M.confused,2)

	else if(!ear_safety)
		stat_def *= 2
		M.adjustEarDamage(rand(0, 1))
		M.ear_deaf = max(M.ear_deaf,5)
		M.confused = max(M.confused,5)

	//This really should be in mob not every check
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/eyes/E = H.random_organ_by_process(OP_EYES)
		if (E && E.damage >= E.min_bruised_damage)
			to_chat(M, SPAN_DANGER("Your eyes start to burn badly!"))
	if (M.ear_damage >= 15)
		to_chat(M, SPAN_DANGER("Your ears start to ring badly!"))
	else
		if (M.ear_damage >= 5)
			to_chat(M, SPAN_DANGER("Your ears start to ring!"))
	M.stats.addTempStat(STAT_VIG, stat_def, 10 SECONDS, "flashbang")
	M.stats.addTempStat(STAT_COG, stat_def, 10 SECONDS, "flashbang")
	M.stats.addTempStat(STAT_BIO, stat_def, 10 SECONDS, "flashbang")
	M.stats.addTempStat(STAT_MEC, stat_def, 10 SECONDS, "flashbang")
	M.update_icons()

/obj/item/grenade/flashbang/nt
	name = "NT FBG \"Holy Light\""
	desc = "An old \"NanoTrasen\" flashbang grenade, modified to spread the light of god."
	icon_state = "flashbang_nt"
	item_state = "flashbang_nt"
	matter = list(MATERIAL_BIOMATTER = 15)

/mob/living/carbon/human/movement_delay()

	var/tally = ..()
	if(species.slowdown)
		tally += species.slowdown
	if (istype(loc, /turf/space)) // It's hard to be slowed down in space by... anything
		return tally

	if(embedded_flag)
		handle_embedded_objects() //Moving with objects stuck in you can cause bad times.
	if(CE_SPEEDBOOST in chem_effects)
		tally -= chem_effects[CE_SPEEDBOOST]
	if(isturf(loc))
		var/turf/T = loc
		if(T.get_lumcount() < 0.6)
			if(stats.getPerk(PERK_NIGHTCRAWLER))
				tally -= 0.5
			else if(see_invisible != SEE_INVISIBLE_NOLIGHTING)
				tally += 0.5
	if(stats.getPerk(PERK_FAST_WALKER))
		tally -= 0.5

	var/obj/item/implant/core_implant/cruciform/C = get_core_implant(/obj/item/implant/core_implant/cruciform)
	if(C && C.active)
		var/obj/item/cruciform_upgrade/upgrade = C.upgrade
		if(upgrade && upgrade.active && istype(upgrade, CUPGRADE_SPEED_OF_THE_CHOSEN))
			var/obj/item/cruciform_upgrade/speed_of_the_chosen/sotc = upgrade
			tally -= sotc.speed_increase

	var/hunger_deficiency = (MOB_BASE_MAX_HUNGER - nutrition)
	if(hunger_deficiency >= 200) tally += (hunger_deficiency / 100) //If youre starving, movement slowdown can be anything up to 4.

	if(istype(buckled, /obj/structure/bed/chair/wheelchair))
		//Not porting bay's silly organ checking code here
		tally += 1 //Small slowdown so wheelchairs aren't turbospeed
	else
		if(wear_suit)
			tally += wear_suit.slowdown
		if(shoes)
			tally += shoes.slowdown

	tally += min((shock_stage / 100) * 3, 3) //Scales from 0 to 3 over 0 to 100 shock stage

	if (bodytemperature < 283.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75
	tally += stance_damage // missing/damaged legs or augs affect speed

	if(slowdown)
		tally += 1
	
	tally += (r_hand?.slowdown_hold + l_hand?.slowdown_hold)

	return tally


/mob/living/carbon/human/allow_spacemove()
	//Can we act?
	if(restrained())	return 0

	//Do we have a working jetpack?
	var/obj/item/tank/jetpack/thrust = get_jetpack()

	if(thrust)
		if(thrust.allow_thrust(JETPACK_MOVE_COST, src))
			if (thrust.stabilization_on)
				return TRUE
			return -1

	//If no working jetpack then use the other checks
	return ..()

/mob/living/carbon/human/slip_chance(var/prob_slip = 5)
	if(!..())
		return 0

	//Check hands and mod slip
	if(!l_hand)
		prob_slip -= 2
	else if(l_hand.w_class <= ITEM_SIZE_SMALL)
		prob_slip -= 1
	if (!r_hand)
		prob_slip -= 2
	else if(r_hand.w_class <= ITEM_SIZE_SMALL)
		prob_slip -= 1

	return prob_slip

/mob/living/carbon/human/check_shoegrip()
	if(species.flags & NO_SLIP)
		return 1
	if(shoes && (shoes.item_flags & NOSLIP) && istype(shoes, /obj/item/clothing/shoes/magboots))  //magboots + dense_object = no floating
		return 1
	return 0

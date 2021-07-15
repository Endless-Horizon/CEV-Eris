/*
Boss of this maints.
Has ability of every roach.
*/

/mob/living/carbon/superior_animal/roach/kaiser
	name = "Kaiser Roach"
	desc = "A glorious emperor of roaches."
	icon = 'icons/mob/64x64.dmi'
	icon_state = "kaiser_roach"
	icon_living = "kaiser_roach"
	icon_dead = "kaiser_roach_dead"
	density = TRUE
	spawn_blacklisted = TRUE
	rarity_value = 100

	turns_per_move = 6
	maxHealth = 2000
	health = 2000
	contaminant_immunity = TRUE

	var/datum/reagents/gas_sac

	melee_damage_lower = 20
	melee_damage_upper = 35
	move_to_delay = 8
	mob_size = MOB_HUGE
	status_flags = 0
	mouse_opacity = MOUSE_OPACITY_OPAQUE // Easier to click on in melee, they're giant targets anyway

	blattedin_revives_left = 0

	meat_type = /obj/item/reagent_containers/food/snacks/meat/roachmeat/kaiser
	meat_amount = 15
	sanity_damage = 3

	ranged = 1 // RUN, COWARD!
	projectiletype = /obj/item/projectile/roach_spit
	fire_verb = "spits glowing bile"

	var/distress_call_stage = 3

	var/health_marker_1 = 1500
	var/health_marker_2 = 1000
	var/health_marker_3 = 500

/mob/living/carbon/superior_animal/roach/kaiser/New()
	..()
	gas_sac = new /datum/reagents(100, src)
	pixel_x = -16  // For some reason it doesn't work when I overload them in class definition, so here it is.
	pixel_y = -16


/mob/living/carbon/superior_animal/roach/kaiser/Life()
	. = ..()
	if(stat != CONSCIOUS)
		return

	if(stat != AI_inactive)
		return

	if(can_call_reinforcements())
		distress_call()

	gas_sac.add_reagent("blattedin", 1)
	if(prob(7))
		gas_attack()


// TOXIC ABILITIES
/mob/living/carbon/superior_animal/roach/kaiser/UnarmedAttack(atom/A, proximity)
	. = ..()

	if(isliving(A))
		var/mob/living/L = A
		if(prob(10))
			var/damage = rand(melee_damage_lower, melee_damage_upper)
			L.apply_effect(200, IRRADIATE) // as much as a radioactive AMR shot or five times the gestrahlte's
			L.damage_through_armor(damage, TOX, ARMOR_BIO)
			playsound(src, 'sound/voice/insect_battle_screeching.ogg', 30, 1, -3)
			L.visible_message(SPAN_DANGER("\the [src] globs up some glowing bile all over \the [L]!"))

// SUPPORT ABILITIES
/mob/living/carbon/superior_animal/roach/kaiser/proc/gas_attack()
	if (!gas_sac.has_reagent("blattedin", 20) || stat != CONSCIOUS)
		return

	var/location = get_turf(src)
	var/datum/effect/effect/system/smoke_spread/chem/S = new

	S.attach(location)
	S.set_up(gas_sac, gas_sac.total_volume, 0, location)
	src.visible_message(SPAN_DANGER("\the [src] secretes strange vapors!"))

	spawn(0)
		S.start()

	gas_sac.clear_reagents()
	return TRUE

/mob/living/carbon/superior_animal/roach/support/findTarget()
	. = ..()
	if(. && gas_attack())
		visible_emote("charges at [.] in clouds of poison!")

// FUHRER ABILITIES
/mob/living/carbon/superior_animal/roach/kaiser/proc/distress_call()
	if (!distress_call_stage)
		return

	for (var/mob/living/carbon/human/H in view())
		if (H.stat != DEAD && H.client)
			break

	if (distress_call_stage)
		distress_call_stage--
		playsound(src.loc, 'sound/voice/shriek1.ogg', 100, 1, 8, 8)
		spawn(2)
			playsound(src.loc, 'sound/voice/shriek1.ogg', 100, 1, 8, 8)
		visible_message(SPAN_DANGER("[src] emits a horrifying wail as nearby burrows stir to life!"))
		for (var/obj/structure/burrow/B in find_nearby_burrows(src))
			B.distress(TRUE)


/mob/living/carbon/superior_animal/roach/kaiser/proc/can_call_reinforcements()
	if(health_marker_1 >= health && health > health_marker_2 && distress_call_stage == 3)
		return TRUE
	if(health_marker_2 >= health && health > health_marker_3 && distress_call_stage == 2)
		return TRUE
	if(health_marker_3 >= health && health > 0 && distress_call_stage == 1)
		return TRUE
	return FALSE

/mob/living/carbon/superior_animal/roach/kaiser/slip(var/slipped_on)
	return FALSE

//RIDING
/mob/living/carbon/superior_animal/roach/kaiser/try_tame(var/mob/living/carbon/user, var/obj/item/reagent_containers/food/snacks/grown/thefood)
	if(!istype(thefood))
		return FALSE
	if(prob(40))
		visible_message("[src] hesitates for a moment... and then charges at [user]!")
		return TRUE //Setting this to true because the only current usage is attack, and it says it hesitates.
	//fruits and veggies are not there own type, they are all the grown type and contain certain reagents. This is why it didnt work before
	if(isnull(thefood.seed.chems["singulo"]))
		return FALSE
	visible_message("[src] scuttles towards [user], examining the [thefood] they have in their hand.")
	can_buckle = TRUE
	if(do_after(src, taming_window, src)) //Here's your window to climb onto it.
		if(!buckled_mob || user != buckled_mob) //They need to be riding us
			can_buckle = FALSE
			visible_message("[src] snaps out of its trance and rushes at [user]!")
			return FALSE
		visible_message("[src] bucks around wildly, trying to shake [user] off!") //YEEEHAW
		if(prob(60))
			visible_message("[src] thrashes around and, throws [user] clean off!")
			user.throw_at(get_edge_target_turf(src,pick(alldirs)),rand(1,3),30)
			unbuckle_mob()
			can_buckle = FALSE
			return FALSE
		friends += user
		visible_message("[src] reluctantly stops thrashing around...")
		return TRUE
	visible_message("[src] snaps out of its trance and rushes at [user]!")
	return FALSE
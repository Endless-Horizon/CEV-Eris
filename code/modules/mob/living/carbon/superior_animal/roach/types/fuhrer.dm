//Fuhrer roach is a colossal, slow moving leader
/mob/living/carbon/superior_animal/roach/fuhrer
	name = "Fuhrer Roach"
	desc = "A glorious leader of cockroaches. Literally Hitler."
	icon_state = "fuhrer"

	turns_per_move = 4
	maxHealth = 200
	health = 200

	melee_damage_lower = 15
	melee_damage_upper = 30
	move_to_delay = 8
	mob_size = MOB_MEDIUM
	extra_burrow_chance = 100
	blattedin_revives_left = 0 //He only lives once, cuz he's huge

	meat_type = /obj/item/reagent_containers/food/snacks/meat/roachmeat/fuhrer
	meat_amount = 6

	sanity_damage = 1
	rarity_value = 90

	var/distress_level = 0
	var/distress_calls = 1 //Each fuhrer can only call for help once in its life
	var/retreat_calls = 1 //Can call for retreat once too

/mob/living/carbon/superior_animal/roach/fuhrer/bullet_act()
	.=..()
	distress_call()

/mob/living/carbon/superior_animal/roach/fuhrer/attackby()
	.=..()
	distress_call()

/*When its subordinates die, the leader may call for aid.
It may also call when it is personally under attack
Every nearby roach death triggers this proc, and increases the chance of a call
All the burrows in a wide area will request rapid reinforcements, causing a significant number of roaches to
flood into this room and surrounding ones.

Each leader can only call reinforcements once in its life. But it can also sound an evacuation once. If it has no
reinforcements left it will attempt to evacuate*/
/mob/living/carbon/superior_animal/roach/fuhrer/proc/distress_call()
	if (!distress_calls && !retreat_calls)
		return

	distress_level += 1

	/*
	In order to make it more likely that players will be around to witness it, lets add more distress if we can
	see a human player

	*/
	for (var/mob/living/carbon/human/H in view())
		if (H.stat != DEAD && H.client)
			distress_level += 2
			break

	if (distress_level > 0 && prob(distress_level))

		distress_level = -30 //Once a call is successfully triggered, set the chance negative
		//So it will be a while before this guy can send another call

		if (distress_calls)
			distress_calls--
			playsound(src.loc, 'sound/voice/shriek1.ogg', 100, 1, 8, 8)
			spawn(2)
				playsound(src.loc, 'sound/voice/shriek1.ogg', 100, 1, 8, 8)
				//Playing the sound twice will make it sound really horrible

			visible_message(SPAN_DANGER("[src] emits a horrifying wail as nearby burrows stir to life!"))

			//Add all nearby burrows to the distressed burrows list
			//for (var/obj/structure/burrow/B in range(20, loc))
			for (var/obj/structure/burrow/B in find_nearby_burrows())
				B.distress(TRUE)




		//If no distress calls available, sound a retreat instead
		else if (retreat_calls)
			retreat_calls --
			playsound(src.loc, 'sound/voice/hiss6.ogg', 100, 1, 8, 8)
			spawn(2)
				playsound(src.loc, 'sound/voice/hiss6.ogg', 100, 1, 8, 8)
				//Playing the sound twice will make it sound really horrible

			visible_message(SPAN_DANGER("[src] emits a haunting scream as it turns to flee, taking the nearby horde with it...."))
			for (var/obj/structure/burrow/B in find_nearby_burrows())
				B.evacuate()

// Fuhrers won't slip over on water or soap.
/mob/living/carbon/superior_animal/roach/fuhrer/slip(var/slipped_on,stun_duration=8)
	return FALSE

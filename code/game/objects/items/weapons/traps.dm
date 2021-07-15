/obj/item/beartrap
	name = "mechanical trap"
	throw_speed = 2
	throw_range = 1
	gender = PLURAL
	icon = 'icons/obj/traps.dmi'
	icon_state = "beartrap"
	desc = "A mechanically activated leg trap. Low-tech, but reliable. Looks like it could really hurt if you set it off."
	throwforce = 0
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_MATERIAL = 1)
	matter = list(MATERIAL_STEEL = 25)
	edge = TRUE
	sharp = TRUE
	var/deployed = FALSE

	var/base_damage = 20
	var/fail_damage = 5
	var/base_difficulty = 85
	var/time_to_escape = 40
	var/target_zone
	var/min_size = 5 //Mobs smaller than this won't trigger the trap
	var/struggle_prob = 2
	var/list/aware_mobs = list() //List of refs of mobs that examined this trap. Won't trigger it when walking.
	var/prob_catch = 100 //prob catch to mob


/obj/item/beartrap/Initialize()
	.=..()
	update_icon()


/***********************************
	Releasing Mobs
***********************************/

/*
When someone is trapped in a beartrap, anyone (victim or other) can attempt to free them
They can do this either with their bare hands or with a prying tool for better odds.
This is a very difficult task and it will frequently fail the first few times.
Every failure causes the trap to dig deeper and hurt the victim more

Freeing yourself is much harder than freeing someone else. Calling for help is advised if practical
*/
/obj/item/beartrap/proc/attempt_release(mob/living/user, obj/item/I)
	if (!buckled_mob || QDELETED(buckled_mob))
		return //Nobody there to rescue?

	if (!user)
		return //No user, or too far away
	
	if(iscarbon(user)) //check if mob is carbon as handcuffed only applies to carbon mobs
		var/mob/living/carbon/C = user //set carbon to user
		if(C.handcuffed)
			return//you instantly fail if you are handcuffed and trapped, this way you will loose the handcuffs first instead of repeatedly snapping your torso in half

	//How hard will this be? The chance of failure
	var/difficulty = base_difficulty

	//Does the user have the dexterity to operate the trap?
	if (!can_use(user))
		//If they don't, then they're probably some kind of animal trapped in it
		if (user != buckled_mob || user.client)
			//Such a creature can't free someone else
			return

		//But they can attempt to struggle out on their own. At a very low success rate
		difficulty = 96
		/*This will generally not work, and repeated attempts will result in the creature bleeding to
		death as it tries to escape
		Such is nature*/

	else
		if (user != buckled_mob)
			difficulty -= 35 //It's easier to free someone else than to free yourself

		//Is there a tool involved?
		if (istype(I))
			//Using a crowbar helps
			to_chat(user, SPAN_NOTICE("\The [I] gives you extra leverage"))
			var/reduction = I.get_tool_quality(QUALITY_PRYING)*0.5
			if (user == buckled_mob)
				reduction *= 0.66 //But it helps less if you don't have good leverage
			difficulty -= reduction
			I.consume_resources(time_to_escape * 3, user)

		if (issilicon(user))
			difficulty += 5 //Robots are less dextrous

		//How about your stats? Being strong or crafty helps.
		//We'll subtract the highest of either robustness or mechanical, from the difficulty
		var/reduction = user.stats.getMaxStat(list(STAT_ROB, STAT_MEC))
		if (user == buckled_mob)
			reduction *= 0.66 //But it helps less if you don't have good leverage
		difficulty -= reduction

	//Alright we calculated the difficulty, now lets do the attempt

	//Firstly a visible message
	if (buckled_mob == user)
		user.visible_message(
			SPAN_NOTICE("\The [user] tries to free themselves from \the [src]."),
			SPAN_NOTICE("You carefully begin to free yourself from \the [src]."),
			SPAN_NOTICE("You hear metal creaking.")
			)
	else
		user.visible_message(
			SPAN_NOTICE("\The [user] tries to free \the [buckled_mob] from \the [src]."),
			SPAN_NOTICE("You carefully begin to free \the [buckled_mob] from \the [src]."),
			SPAN_NOTICE("You hear metal creaking.")
			)

	//Play a metal creaking sound
	playsound(src, 'sound/machines/airlock_creaking.ogg', 10, 1, -3,-3)



	//Now a do_after
	if(!do_after(user, time_to_escape))
		//If you abort it's an automatic fail
		fail_attempt()
		return

	//You completed the doafter, but did you succeed?
	if (difficulty > 0 && prob(difficulty))
		fail_attempt(user, difficulty)
		return

	//You succeeded yay
	user.visible_message(
			SPAN_NOTICE("[user] successfully releases [buckled_mob] from \the [src]."),
			SPAN_NOTICE("You successfully release [buckled_mob] from \the [src]."),
			SPAN_DANGER("You hear metal creaking.")
			)
	release_mob()


//Using a crowbar allows you to lever the trap open, better success rate
/obj/item/beartrap/attackby(obj/item/C, mob/living/user)
	if (C.has_quality(QUALITY_PRYING))
		attempt_release(user, C)
		return
	.=..()

/obj/item/beartrap/attack_hand(mob/user as mob)
	if (buckled_mob)
		attempt_release(user)
		return
	if (deployed)
		user.visible_message(
			SPAN_DANGER("[user] starts to carefully disarm \the [src]."),
			SPAN_DANGER("You begin to carefully disarm \the [src].")
			)

		if (do_after(user, 25))
			user.visible_message(
				SPAN_DANGER("[user] has disarmed \the [src]."),
				SPAN_DANGER("You have disarmed \the [src]!")
				)
			deployed = FALSE
			anchored = FALSE
			update_icon()
		return
	.=..()

/obj/item/beartrap/attack_generic(mob/user, damage)
	if (buckled_mob)
		attempt_release(user)
		return
	.=..()

/obj/item/beartrap/attack_robot(mob/user)
	if (buckled_mob)
		attempt_release(user)
		return
	.=..()

/obj/item/beartrap/proc/can_use(mob/user)
	return (user.IsAdvancedToolUser() && !user.stat && user.Adjacent(src))

/obj/item/beartrap/proc/release_mob()
	unbuckle_mob()
	anchored = FALSE
	deployed = FALSE
	can_buckle = initial(can_buckle)
	update_icon()
	STOP_PROCESSING(SSobj, src)

//Attempting to resist out of a beartrap will be counted as using your hand on the trap.
/obj/item/beartrap/resist_buckle(mob/user)
	if (user == buckled_mob && !user.stunned)
		//We check stunned here, and a failure stuns the victim. This prevents someone from just spam-resisting and instantly killing themselves
		if (user.client)
			attack_hand(user)
		else
			//Fallback behaviour for possible future use of NPCs
			attempt_release(user, null)
	return FALSE //Returning false prevents the default resist behaviour of instantly releasing the trap

/***********************************
	Deployment
***********************************/

/obj/item/beartrap/attack_self(mob/user as mob)
	..()
	if(locate(/obj/structure/multiz/ladder) in get_turf(user))
		to_chat(user, SPAN_NOTICE("You cannot place \the [src] here, there is a ladder."))
		return
	if(locate(/obj/structure/multiz/stairs) in get_turf(user))
		to_chat(user, SPAN_NOTICE("You cannot place \the [src] here, it needs a flat surface."))
		return
	if(!deployed && can_use(user))
		user.visible_message(
			SPAN_DANGER("[user] starts to deploy \the [src]."),
			SPAN_DANGER("You begin deploying \the [src]!"),
			"You hear the slow creaking of a spring."
			)

		if (do_after(user, 25))
			user.visible_message(
				SPAN_DANGER("[user] has deployed \the [src]."),
				SPAN_DANGER("You have deployed \the [src]!"),
				"You hear a latch click loudly."
				)

			aware_mobs = list()
			deployed = TRUE
			user.drop_from_inventory(src)
			update_icon()
			anchored = TRUE

/***********************************
	Hurting Mobs
***********************************/

//If an attempt to release the mob fails, it digs in and deals more damage
/obj/item/beartrap/proc/fail_attempt(user, difficulty)
	if (!buckled_mob)
		return

	var/mob/living/L = buckled_mob
	//armour

	if( L.damage_through_armor(fail_damage, BRUTE, target_zone, ARMOR_MELEE, used_weapon = src) )
	//No damage - no stun
		L.Stun(4) //A short stun prevents spamming failure attempts
		shake_camera(user, 2, 1)

	if (ishuman(L))
		var/mob/living/carbon/human/H = L
		visible_message(SPAN_DANGER("\The [src] snaps back, digging deeper into [buckled_mob.name]'s [H.get_organ(target_zone).name]"))
	else
		visible_message(SPAN_DANGER("\The [src] snaps back, digging deeper into [buckled_mob.name]"))

	playsound(src, 'sound/effects/impacts/beartrap_shut.ogg', 10, 1,-2,-2)//Fairly quiet snapping sound

	if (difficulty)
		to_chat(user, SPAN_NOTICE("You failed to release the trap. There was a [round(100 - difficulty)]% chance of success"))
		if (user == buckled_mob)
			to_chat(user, SPAN_NOTICE("Freeing yourself is very difficult. Perhaps you should call for help?"))



/obj/item/beartrap/proc/attack_mob(mob/living/L)
	//Small mobs won't trigger the trap
	//Imagine a mouse running harmlessly over it
	if (!L || L.mob_size < min_size)
		return

	if (ismech(L))
		deployed = FALSE
		playsound(src, 'sound/effects/impacts/beartrap_shut.ogg', 100, 1,10,10)
		return

	if(L.lying)
		target_zone = ran_zone()
	else
		target_zone = pick(BP_L_LEG, BP_R_LEG)

	deployed = FALSE
	can_buckle = initial(can_buckle)
	playsound(src, 'sound/effects/impacts/beartrap_shut.ogg', 100, 1,10,10)//Really loud snapping sound

	//armour
	if( L.damage_through_armor(fail_damage, BRUTE, target_zone, ARMOR_MELEE, used_weapon = src) )
	//No damage - no stun
		L.Stun(4) //A short stun prevents spamming failure attempts
		shake_camera(L, 2, 1)

	//trap the victim in place
	set_dir(L.dir)
	can_buckle = TRUE
	buckle_mob(L)
	to_chat(L, SPAN_DANGER("The steel jaws of \the [src] bite into you, trapping you in place!"))


	//If the victim is nonhuman and has no client, start processing.
	if (!ishuman(L) && !L.client)
		START_PROCESSING(SSobj, src)



/*
Beartraps process when a clientless mob is trapped in them.
Periodically the mob will attempt to struggle out. It will probably fail, take damage, and eventually die
Very rarely it might escape
*/
/obj/item/beartrap/Process()
	var/mob/living/L = buckled_mob

	//If its dead or gone, stop processing
	//Also stop if a player took control of it, they can try to free themselves
	if (QDELETED(L) || L.is_dead() || L.loc != loc || L.client)
		release_mob()		// Reset the trap properly if the roach was gibbed during the processing.
		return PROCESS_KILL

	if (L.incapacitated())
		//If it's not conscious and able, skip this process tick, but keep checking in future
		return

	//Chance each tick that the mob will attempt to free itself
	if (prob(struggle_prob))
		attempt_release(L)



/obj/item/beartrap/Crossed(AM as mob|obj)
	if(deployed && isliving(AM))
		if(locate(/obj/structure/multiz/ladder) in get_turf(loc))
			visible_message(SPAN_DANGER("\The [src]'s triggering mechanism is disrupted by the ladder and does not go off."))
			return ..()
		if(locate(/obj/structure/multiz/stairs) in get_turf(loc))
			visible_message(SPAN_DANGER("\The [src]'s triggering mechanism is disrupted by the slope and does not go off."))
			return ..()
		var/mob/living/L = AM
		var/true_prob_catch = prob_catch - L.skill_to_evade_traps()
		if("\ref[L]" in aware_mobs)
			if(MOVING_DELIBERATELY(L))
				return ..()
			else
				true_prob_catch -= 30
		if(!prob(true_prob_catch))
			return ..()
		L.visible_message(
			SPAN_DANGER("[L] steps on \the [src]."),
			SPAN_DANGER("You step on \the [src]!"),
			"<b>You hear a loud metallic snap!</b>"
			)

		attack_mob(L)
		if(!buckled_mob)
			anchored = FALSE
		deployed = FALSE
		update_icon()
	..()

/obj/item/beartrap/examine(mob/user)
	..()
	if(deployed && isliving(user) && !("\ref[user]" in aware_mobs))
		to_chat(user, SPAN_NOTICE("You're aware of this trap, now. You won't set it off when walking carefully."))
		aware_mobs |= "\ref[user]"


/obj/item/beartrap/on_update_icon()
	..()

	if(!deployed)
		icon_state = "[initial(icon_state)]0"
	else
		icon_state = "[initial(icon_state)]1"



/**********************************
	Makeshift Trap
**********************************/
/*
	Can be constructed from stuff you find in maintenance
	Slightly worse stats all around
	Has integrity that depletes and it will eventually break
*/
/obj/item/beartrap/makeshift
	base_damage = 16
	fail_damage = 4
	base_difficulty = 80
	name = "jury-rigged mechanical trap"
	desc = "A wicked looking construct of spiky bits of metal and wires. Will snap shut on anyone who steps in it. It'll do some nasty damage."
	icon_state = "sawtrap"
	matter = list(MATERIAL_STEEL = 15)
	var/integrity = 100


//It takes 5 damage whenever it snaps onto a mob
/obj/item/beartrap/makeshift/attack_mob(mob/living/L)
	.=..()
	integrity -= 4
	spawn(5)
		check_integrity()

//Takes 1 damage every time they fail to open it
/obj/item/beartrap/makeshift/fail_attempt(var/user, var/difficulty)
	.=..()
	integrity -= 0.8
	spawn(5)
		check_integrity()

/obj/item/beartrap/makeshift/proc/check_integrity()
	if (prob(integrity))
		return

	break_apart()


/obj/item/beartrap/makeshift/proc/break_apart()
	visible_message(SPAN_DANGER("\the [src] shatters into fragments!"))
	new /obj/item/stack/material/steel(loc, 10)
	new /obj/item/material/shard/shrapnel(loc)
	new /obj/item/material/shard/shrapnel(loc)
	qdel(src)


/**********************************
	Armed Subtypes
**********************************/
/*
	Used for random trap spawners.
	These start already deployed and will entrap the first creature that steps on it
*/

/obj/item/beartrap/armed
	deployed = TRUE
	anchored = TRUE
	rarity_value = 33.3
	spawn_frequency = 10
	spawn_tags = SPAWN_TAG_TRAP_ARMED

/obj/item/beartrap/makeshift/armed
	deployed = TRUE
	anchored = TRUE
	rarity_value = 22.2
	spawn_frequency = 10
	spawn_tags = SPAWN_TAG_TRAP_ARMED

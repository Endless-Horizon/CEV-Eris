/* Toys!
 * Contains:
 *		Balloons
 *		Fake telebeacon
 *		Fake singularity
 *		Toy crossbow
 *		Toy swords
 *		Toy bosun's whistle
 *      Toy mechs
 *		Snap pops
 *		Water flower
 *      Inflatable duck
 *		Action figures
 *		Plushies
 *		Toy cult sword
 */


/obj/item/toy
	throwforce = NONE
	throw_speed = 4
	throw_range = 20
	force = NONE

	//spawn_values
	bad_type = /obj/item/toy
	spawn_tags = SPAWN_TAG_ITEM_TOY

/*
 * Balloons
 */
/obj/item/toy/balloon
	name = "water balloon"
	desc = "A translucent balloon. There's nothing in it."
	icon = 'icons/obj/toy.dmi'
	icon_state = "waterballoon-e"
	item_state = "balloon-empty"
	preloaded_reagents = list()

/obj/item/toy/balloon/New()
	create_reagents(10)
	..()

/obj/item/toy/balloon/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/toy/balloon/afterattack(atom/A as mob|obj, mob/user, proximity)
	if(!proximity) return
	if (istype(A, /obj/structure/reagent_dispensers/watertank) && get_dist(src,A) <= 1)
		A.reagents.trans_to_obj(src, 10)
		to_chat(user, SPAN_NOTICE("You fill the balloon with the contents of [A]."))
		src.desc = "A translucent balloon with some form of liquid sloshing around in it."
		src.update_icon()
	return

/obj/item/toy/balloon/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/reagent_containers/glass))
		if(O.reagents)
			if(O.reagents.total_volume < 1)
				to_chat(user, "The [O] is empty.")
			else if(O.reagents.total_volume >= 1)
				if(O.reagents.has_reagent("pacid", 1))
					to_chat(user, "The acid chews through the balloon!")
					O.reagents.splash(user, reagents.total_volume)
					qdel(src)
				else
					src.desc = "A translucent balloon with some form of liquid sloshing around in it."
					to_chat(user, SPAN_NOTICE("You fill the balloon with the contents of [O]."))
					O.reagents.trans_to_obj(src, 10)
	src.update_icon()
	return

/obj/item/toy/balloon/throw_impact(atom/hit_atom)
	if(src.reagents.total_volume >= 1)
		src.visible_message(SPAN_WARNING("\The [src] bursts!"),"You hear a pop and a splash.")
		src.reagents.touch_turf(get_turf(hit_atom))
		for(var/atom/A in get_turf(hit_atom))
			src.reagents.touch(A)
		src.icon_state = "burst"
		spawn(5)
			if(src)
				qdel(src)
	return

/obj/item/toy/balloon/on_update_icon()
	if(src.reagents.total_volume >= 1)
		icon_state = "waterballoon"
		item_state = "balloon"
	else
		icon_state = "waterballoon-e"
		item_state = "balloon-empty"

/*
 * Fake telebeacon
 */
/obj/item/toy/blink
	name = "electronic blink toy game"
	desc = "Blink.  Blink.  Blink. Ages 8 and up."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "signaler"

/*
 * Fake singularity
 */
/obj/item/toy/spinningtoy
	name = "gravitational singularity"
	desc = "\"Singulo\" brand spinning toy."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"

/*
 * Toy crossbow
 */

/obj/item/toy/crossbow
	name = "foam dart crossbow"
	desc = "A weapon favored by many overactive children. Ages 8 and up."
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "crossbow"
	item_state = "crossbow"
	item_icons = list(
		icon_l_hand = 'icons/mob/items/lefthand_guns.dmi',
		icon_r_hand = 'icons/mob/items/righthand_guns.dmi',
		)
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("attacked", "struck", "hit")
	spawn_tags = SPAWN_TAG_TOY_WEAPON
	var/bullets = 5

	examine(mob/user)
		if(..(user, 2) && bullets)
			to_chat(user, SPAN_NOTICE("It is loaded with [bullets] foam darts!"))

	attackby(obj/item/I as obj, mob/user)
		if(istype(I, /obj/item/toy/ammo/crossbow))
			if(bullets <= 4)
				user.drop_item()
				qdel(I)
				bullets++
				to_chat(user, SPAN_NOTICE("You load the foam dart into the crossbow."))
			else
				to_chat(usr, SPAN_WARNING("It's already fully loaded."))


	afterattack(atom/target as mob|obj|turf|area, mob/user, flag)
		if(!isturf(target.loc) || target == user) return
		if(flag) return

		if (locate (/obj/structure/table, src.loc))
			return
		else if (bullets)
			var/turf/trg = get_turf(target)
			var/obj/effect/foam_dart_dummy/D = new/obj/effect/foam_dart_dummy(get_turf(src))
			bullets--
			D.icon_state = "foamdart"
			D.name = "foam dart"
			playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)

			for(var/i=0, i<6, i++)
				if (D)
					if(D.loc == trg) break
					step_towards(D,trg)

					for(var/mob/living/M in D.loc)
						if(!isliving(M))
							continue
						if(M == user)
							continue
						for(var/mob/O in viewers(world.view, D))
							O.show_message(SPAN_WARNING("\The [M] was hit by the foam dart!"), 1)
						new /obj/item/toy/ammo/crossbow(M.loc)
						qdel(D)
						return

					for(var/atom/A in D.loc)
						if(A == user) continue
						if(A.density)
							new /obj/item/toy/ammo/crossbow(A.loc)
							qdel(D)

				sleep(1)

			spawn(10)
				if(D)
					new /obj/item/toy/ammo/crossbow(D.loc)
					qdel(D)

			return
		else if (bullets == 0)
			user.Weaken(5)
			for(var/mob/O in viewers(world.view, user))
				O.show_message(SPAN_WARNING("\The [user] realized they were out of ammo and starting scrounging for some!"), 1)


	attack(mob/M as mob, mob/user)
		src.add_fingerprint(user)

// ******* Check

		if (src.bullets > 0 && M.lying)

			for(var/mob/O in viewers(M, null))
				if(O.client)
					O.show_message(SPAN_DANGER("\The [user] casually lines up a shot with [M]'s head and pulls the trigger!"), 1, SPAN_WARNING("You hear the sound of foam against skull"), 2)
					O.show_message(SPAN_WARNING("\The [M] was hit in the head by the foam dart!"), 1)

			playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)
			new /obj/item/toy/ammo/crossbow(M.loc)
			src.bullets--
		else if (M.lying && src.bullets == 0)
			for(var/mob/O in viewers(M, null))
				if (O.client)
					O.show_message(SPAN_DANGER("\The [user] casually lines up a shot with [M]'s head, pulls the trigger, then realizes they are out of ammo and drops to the floor in search of some!"), 1, SPAN_WARNING("You hear someone fall"), 2)
			user.Weaken(5)
		return

/obj/item/toy/ammo/crossbow
	name = "foam dart"
	desc = "It's nerf or nothing! Ages 8 and up."
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamdart"
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS

/obj/effect/foam_dart_dummy
	name = "foam dart"
	desc = ""
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamdart"
	anchored = TRUE
	density = FALSE


/*
 * Toy swords
 */
/obj/item/toy/sword
	name = "toy sword"
	desc = "A cheap, plastic replica of an energy sword. Realistic sounds! Ages 8 and up."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "sword0"
	item_state = "sword0"
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("attacked", "struck", "hit")
	spawn_tags = SPAWN_TAG_TOY_WEAPON
	var/active = 0

	attack_self(mob/user)
		src.active = !( src.active )
		if (src.active)
			to_chat(user, SPAN_NOTICE("You extend the plastic blade with a quick flick of your wrist."))
			playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
			src.icon_state = "swordblue"
			src.item_state = "swordblue"
			src.w_class = ITEM_SIZE_BULKY
		else
			to_chat(user, SPAN_NOTICE("You push the plastic blade back down into the handle."))
			playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
			src.icon_state = "sword0"
			src.item_state = "sword0"
			src.w_class = ITEM_SIZE_SMALL

		update_wear_icon()

		src.add_fingerprint(user)
		return

/obj/item/toy/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "katana"
	item_state = "katana"
	flags = CONDUCT
	slot_flags = SLOT_BELT | SLOT_BACK
	force = WEAPON_FORCE_WEAK
	throwforce = WEAPON_FORCE_WEAK
	w_class = ITEM_SIZE_NORMAL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced")
	spawn_tags = SPAWN_TAG_TOY_WEAPON

/*
 * Snap pops
 */
/obj/item/toy/snappop
	name = "snap pop"
	desc = "Wow!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"
	w_class = ITEM_SIZE_TINY

	throw_impact(atom/hit_atom)
		..()
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		new /obj/effect/decal/cleanable/ash(src.loc)
		src.visible_message(SPAN_WARNING("The [src.name] explodes!"),SPAN_WARNING("You hear a snap!"))
		playsound(src, 'sound/effects/snap.ogg', 50, 1)
		qdel(src)

/obj/item/toy/snappop/Crossed(H as mob|obj)
	if((ishuman(H))) //i guess carp and shit shouldn't set them off
		var/mob/living/carbon/M = H
		if(MOVING_QUICKLY(M))
			to_chat(M, SPAN_WARNING("You step on the snap pop!"))

			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(2, 0, src)
			s.start()
			new /obj/effect/decal/cleanable/ash(src.loc)
			src.visible_message(SPAN_WARNING("The [src.name] explodes!"),SPAN_WARNING("You hear a snap!"))
			playsound(src, 'sound/effects/snap.ogg', 50, 1)
			qdel(src)

/*
 * Water flower
 */
/obj/item/toy/waterflower
	name = "water flower"
	desc = "A seemingly innocent sunflower...with a twist."
	icon = 'icons/obj/device.dmi'
	icon_state = "sunflower"
	item_state = "sunflower"
	flags // TODO??
	preloaded_reagents = list("water" = 10)
	var/empty = 0

/obj/item/toy/waterflower/attack(mob/living/carbon/human/M, mob/user )
	return

/obj/item/toy/waterflower/afterattack(atom/A as mob|obj, mob/user)

	if (istype(A, /obj/item/storage/backpack ))
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	else if (istype(A, /obj/structure/reagent_dispensers/watertank) && get_dist(src,A) <= 1)
		A.reagents.trans_to(src, 10)
		to_chat(user, SPAN_NOTICE("You refill your flower!"))
		return

	else if (src.reagents.total_volume < 1)
		src.empty = 1
		to_chat(user, SPAN_NOTICE("Your flower has run dry!"))
		return

	else
		src.empty = 0


		var/obj/effect/decal/D = new/obj/effect/decal/(get_turf(src))
		D.name = "water"
		D.icon = 'icons/obj/chemical.dmi'
		D.icon_state = "chempuff"
		D.create_reagents(5)
		src.reagents.trans_to_obj(D, 1)
		playsound(src.loc, 'sound/effects/spray3.ogg', 50, 1, -6)

		spawn(0)
			for(var/i=0, i<1, i++)
				step_towards(D,A)
				D.reagents.touch_turf(get_turf(D))
				for(var/atom/T in get_turf(D))
					D.reagents.touch(T)
					if(ismob(T) && T:client)
						to_chat(T:client, SPAN_WARNING("\The [user] has sprayed you with water!"))
				sleep(4)
			qdel(D)

		return

/obj/item/toy/waterflower/examine(mob/user)
	if(..(user, 0))
		to_chat(user, text("\icon[] [] units of water left!", src, src.reagents.total_volume))

/*
 * Bosun's whistle
 */

/obj/item/toy/bosunwhistle
	name = "bosun's whistle"
	desc = "A genuine Admiral Krush Bosun's Whistle, for the aspiring ship's captain! Suitable for ages 8 and up, do not swallow."
	icon = 'icons/obj/toy.dmi'
	icon_state = "bosunwhistle"
	var/cooldown = 0
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS

/obj/item/toy/bosunwhistle/attack_self(mob/user)
	if(cooldown < world.time - 35)
		to_chat(user, SPAN_NOTICE("You blow on [src], creating an ear-splitting noise!"))
		playsound(user, 'sound/misc/boatswain.ogg', 20, 1)
		cooldown = world.time

/*
 * Mech prizes
 */
/obj/item/toy/prize
	icon = 'icons/obj/toy.dmi'
	icon_state = "ripleytoy"
	bad_type = /obj/item/toy/prize
	var/cooldown = 0

//all credit to skasi for toy mech fun ideas
/obj/item/toy/prize/attack_self(mob/user)
	if(cooldown < world.time - 8)
		to_chat(user, SPAN_NOTICE("You play with [src]."))
		playsound(user, 'sound/mechs/mechstep.ogg', 20, 1)
		cooldown = world.time

/obj/item/toy/prize/attack_hand(mob/user)
	if(loc == user)
		if(cooldown < world.time - 8)
			to_chat(user, SPAN_NOTICE("You play with [src]."))
			playsound(user, 'sound/mechs/mechturn.ogg', 20, 1)
			cooldown = world.time
			return
	..()

/obj/item/toy/prize/ripley
	name = "toy ripley"
	desc = "Mini-Mech action figure! Collect them all! 1/11."

/obj/item/toy/prize/fireripley
	name = "toy firefighting ripley"
	desc = "Mini-Mech action figure! Collect them all! 2/11."
	icon_state = "fireripleytoy"

/obj/item/toy/prize/deathripley
	name = "toy deathsquad ripley"
	desc = "Mini-Mech action figure! Collect them all! 3/11."
	icon_state = "deathripleytoy"

/obj/item/toy/prize/gygax
	name = "toy gygax"
	desc = "Mini-Mech action figure! Collect them all! 4/11."
	icon_state = "gygaxtoy"

/obj/item/toy/prize/durand
	name = "toy durand"
	desc = "Mini-Mech action figure! Collect them all! 5/11."
	icon_state = "durandprize"

/obj/item/toy/prize/honk
	name = "toy H.O.N.K."
	desc = "Mini-Mech action figure! Collect them all! 6/11."
	icon_state = "honkprize"

/obj/item/toy/prize/marauder
	name = "toy marauder"
	desc = "Mini-Mech action figure! Collect them all! 7/11."
	icon_state = "marauderprize"

/obj/item/toy/prize/seraph
	name = "toy seraph"
	desc = "Mini-Mech action figure! Collect them all! 8/11."
	icon_state = "seraphprize"

/obj/item/toy/prize/mauler
	name = "toy mauler"
	desc = "Mini-Mech action figure! Collect them all! 9/11."
	icon_state = "maulerprize"

/obj/item/toy/prize/odysseus
	name = "toy odysseus"
	desc = "Mini-Mech action figure! Collect them all! 10/11."
	icon_state = "odysseusprize"

/obj/item/toy/prize/phazon
	name = "toy phazon"
	desc = "Mini-Mech action figure! Collect them all! 11/11."
	icon_state = "phazonprize"

/*
 * Action figures
 */

/obj/item/toy/figure
	name = "generic figurine"
	desc = "It seems to be almost glitched through reality."
	icon_state = "figure"
	icon = 'icons/obj/toy.dmi'
	spawn_tags = SPAWN_TAG_FIGURE
	bad_type = /obj/item/toy/figure

/obj/item/toy/figure/excelsior
	name = "\"Excelsior\" figurine"
	desc = "A curiously unbranded figurine of a Space Soviet, adorned in their iconic armor. There is still a price tag on the back of the base, six-hundred credits, people collect these things? \
	\"Ever Upward!\""
	icon_state = "excelsior"

/obj/item/toy/figure/serbian
	name = "mercenary figurine"
	desc = "A curiously unbranded figurine, the olive drab a popular pick for many independent Serbian mercenary outfits. Rocket launcher not included."
	icon_state = "serbian"

/obj/item/toy/figure/acolyte
	name = "acolyte figurine"
	desc = "Church of NeoTheology \"New Faith Life\" brand figurine of an acolyte, hooded both physically and spiritually from that which would lead them astray."
	icon_state = "acolyte"

/obj/item/toy/figure/carrion
	name = "carrion figurine"
	desc = "A curiously unbranded figurine depicting a grotesque head of flesh, the Human features seem almost underdeveloped, its skull bulging outwards, mouth agape with torn flesh. \
	Whoever made this certainly knew how to thin their paints."
	icon_state = "carrion"

/obj/item/toy/figure/roach
	name = "roach figurine"
	desc = "Upon the base is an erected \"Roachman\", its arms outstretched, with more additional roach hands besides them. This is likely the one thing most universally recognized in popular media. \
	The plaque is covered in hundreds of scratch marks, eliminating any further knowledge of it or its brand."
	icon_state = "roach"

/obj/item/toy/figure/vagabond
	name = "vagabond figurine"
	desc = "An Aster's \"Space Life\" brand figurine showcasing the form of a random deplorable, wearing one of the ship's uniforms, and an orange bandana. \
	Must of been custom-made to commemorate the Eris' doomed voyage."
	icon_state = "vagabond"

/obj/item/toy/figure/rooster
	name = "rooster figurine"
	desc = "\"Space Vice\" brand figurine, there is no further manufacturer information. It's a man wearing a rooster mask, and a varsity jacket with the letter \"B\" emblazoned on the front. \
	\"Do you like hurting other people?\""
	icon_state = "rooster"

/obj/item/toy/figure/barking_dog
	name = "barking dog figurine"
	desc = "A metal soldier with the mask of a hound stands upon the base, the plaque seems smeared with caked grime, but despite this you make out a rare double-quote. \
	\"A dog barks on its master's orders, lest its pack runs astray.\" \"Whatever the task, the grim dog mask would tell you that your life was done.\""
	icon_state = "barking_dog"

/obj/item/toy/figure/red_soldier
	name = "red soldier figurine"
	desc = "A curiously unbranded figurine of a red soldier fighting in the tides of war, their humanity hidden by a gas mask. \"Why do we fight? To win the war, of course.\""
	icon_state = "red_soldier"

/obj/item/toy/figure/metacat
	name = "meta-cat figurine"
	desc = "A curiously unbranded figurine depicting an anthropomorphic cat in a voidsuit, the small plaque claims this to be one of two. \"Always in silent pair, through distance or unlikelihood.\""
	icon_state = "metacat"

/obj/item/toy/figure/shitcurity
	name = "shitcurity officer figurine"
	desc = "An Aster's \"Space Life\" brand figurine of a classic redshirt of \"Nanotrasen's finest\". Their belly distends out into an obvious beer gut, revealing no form of manufacturer bias what-so-ever. \
	\"I joined just to kill people.\""
	icon_state = "shitcurity"

/obj/item/toy/figure/metro_patrolman
	name = "metro patrolman figurine"
	desc = "The plaque seems flaked with rust residue, \"London Metro\" brand it reads. The man wears some kind of enforcer's uniform, with the acronym \"VPP\" on their left shoulder and cap. \
	\"Abandoned for Escalation, the patrolman grumbles.\""
	icon_state = "metro_patrolman"

/*
 * Plushies
 */

//Large plushies.
/obj/structure/plushie
	name = "generic plush"
	desc = "A very generic plushie. It seems to not want to exist."
	icon = 'icons/obj/toy.dmi'
	icon_state = "ianplushie"
	anchored = FALSE
	density = TRUE
	spawn_tags = SPAWN_TAG_STRUCTURE_PLUSHIE
	bad_type = /obj/structure/plushie
	var/phrase = "I don't want to exist anymore!"

/obj/structure/plushie/attack_hand(mob/user)
	if(user.a_intent == I_HELP)
		user.visible_message(SPAN_NOTICE("<b>\The [user]</b> hugs [src]!"),SPAN_NOTICE("You hug [src]!"))
	else if (user.a_intent == I_HURT)
		user.visible_message(SPAN_WARNING("<b>\The [user]</b> punches [src]!"),SPAN_WARNING("You punch [src]!"))
	else if (user.a_intent == I_GRAB)
		user.visible_message(SPAN_WARNING("<b>\The [user]</b> attempts to strangle [src]!"),SPAN_WARNING("You attempt to strangle [src]!"))
	else
		user.visible_message(SPAN_NOTICE("<b>\The [user]</b> pokes the [src]."),SPAN_NOTICE("You poke the [src]."))
		visible_message("[src] says, \"[phrase]\"")

/obj/structure/plushie/ian
	name = "plush corgi"
	desc = "A plushie of an adorable corgi! Don't you just want to hug it and squeeze it and call it \"Ian\"?"
	icon_state = "ianplushie"
	phrase = "Arf!"

/obj/structure/plushie/drone
	name = "plush drone"
	desc = "A plushie of a happy drone! It appears to be smiling, and has a small tag which reads \"N.D.V. Icarus Gift Shop\"."
	icon_state = "droneplushie"
	phrase = "Beep boop!"

/obj/structure/plushie/carp
	name = "plush carp"
	desc = "A plushie of an elated carp! Straight from the wilds of the Nyx frontier, now right here in your hands."
	icon_state = "carpplushie"
	phrase = "Glorf!"

/obj/structure/plushie/beepsky
	name = "plush Officer Sweepsky"
	desc = "A plushie of a popular industrious cleaning robot! If it could feel emotions, it would love you."
	icon_state = "beepskyplushie"
	phrase = "Ping!"

/obj/structure/plushie/fumo
	name = "Fumo"
	desc = "A plushie of a....?."
	icon_state = "fumoplushie"
	phrase = "I just don't think about losing."

//Small plushies.
/obj/item/toy/plushie
	name = "generic small plush"
	desc = "A very generic small plushie. It seems to not want to exist."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nymphplushie"
	bad_type = /obj/item/toy/plushie
	spawn_tags = SPAWN_TAG_PLUSHIE

/obj/item/toy/plushie/attack_self(mob/user)
	if(user.a_intent == I_HELP)
		user.visible_message(SPAN_NOTICE("<b>\The [user]</b> hugs [src]!"),SPAN_NOTICE("You hug [src]!"))
	else if (user.a_intent == I_HURT)
		user.visible_message(SPAN_WARNING("<b>\The [user]</b> punches [src]!"),SPAN_WARNING("You punch [src]!"))
	else if (user.a_intent == I_GRAB)
		user.visible_message(SPAN_WARNING("<b>\The [user]</b> attempts to strangle [src]!"),SPAN_WARNING("You attempt to strangle [src]!"))
	else
		user.visible_message(SPAN_NOTICE("<b>\The [user]</b> pokes the [src]."),SPAN_NOTICE("You poke the [src]."))

/obj/item/toy/plushie/mouse
	name = "mouse plush"
	desc = "A plushie of a delightful mouse! What was once considered a vile rodent is now your very best friend."
	icon_state = "mouseplushie"

/obj/item/toy/plushie/kitten
	name = "kitten plush"
	desc = "A plushie of a cute kitten! Watch as it purrs it's way right into your heart."
	icon_state = "kittenplushie"

/obj/item/toy/plushie/lizard
	name = "lizard plush"
	desc = "A plushie of a scaly lizard! Very controversial, after being accused as \"racist\" by some Unathi."
	icon_state = "lizardplushie"

/obj/item/toy/plushie/spider
	name = "spider plush"
	desc = "A plushie of a fuzzy spider! It has eight legs - all the better to hug you with."
	icon_state = "spiderplushie"

//Toy cult sword
/obj/item/toy/cultsword
	name = "foam sword"
	desc = "An arcane weapon (made of foam) wielded by the followers of the hit Saturday morning cartoon \"King Nursee and the Acolytes of Heroism\"."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "cultblade"
	item_state = "cultblade"
	w_class = ITEM_SIZE_BULKY
	attack_verb = list("attacked", "slashed", "stabbed", "poked")
	spawn_tags = SPAWN_TAG_TOY_WEAPON

/obj/item/inflatable_duck
	name = "inflatable duck"
	desc = "No bother to sink or swim when you can just float!"
	icon_state = "inflatable"
	item_state = "inflatable"
	icon = 'icons/inventory/belt/icon.dmi'
	slot_flags = SLOT_BELT

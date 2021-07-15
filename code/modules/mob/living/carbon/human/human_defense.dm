/*
Contains most of the procs that are called when a mob is attacked by something

bullet_act
ex_act
meteor_act

*/

/mob/living/carbon/human/bullet_act(var/obj/item/projectile/P, var/def_zone)

	def_zone = check_zone(def_zone)
	if(!has_organ(def_zone))
		return PROJECTILE_FORCE_MISS //if they don't have the organ in question then the projectile just passes by.

	var/obj/item/organ/external/organ = get_organ(def_zone)

	//Shields
	var/shield_check = check_shields(P.get_structure_damage(), P, null, def_zone, "the [P.name]")
	if(shield_check)
		if(shield_check < 0)
			return shield_check
		else
			P.on_hit(src, def_zone)
			return 2

	//Checking absorb for spawning shrapnel
	.=..(P , def_zone)

	var/check_absorb = .
	//Shrapnel
	if(P.can_embed() && (check_absorb < 2))
		var/armor = getarmor_organ(organ, ARMOR_BULLET)
		if(prob(20 + max(P.damage_types[BRUTE] - armor, -10)))
			var/obj/item/material/shard/shrapnel/SP = new()
			SP.name = (P.name != "shrapnel")? "[P.name] shrapnel" : "shrapnel"
			SP.desc = "[SP.desc] It looks like it was fired from [P.shot_from]."
			SP.loc = organ
			organ.embed(SP)


/mob/living/carbon/human/hit_impact(damage, dir)
	if(incapacitated(INCAPACITATION_DEFAULT|INCAPACITATION_BUCKLED_PARTIALLY))
		return
	if(damage < stats.getStat(STAT_TGH))
		..()
		return

	if(!dir) // Same turf as the source
		return

	var/r_dir = reverse_dir[dir]
	var/hit_dirs = (r_dir in cardinal) ? r_dir : list(r_dir & NORTH|SOUTH, r_dir & EAST|WEST)

	var/stumbled = FALSE

	if(prob(60 - stats.getStat(STAT_TGH)))
		stumbled = TRUE
		step(src, pick(cardinal - hit_dirs))

	for(var/atom/movable/A in oview(1))
		if(!A.Adjacent(src) || prob(50 + stats.getStat(STAT_TGH)))
			continue

		if(istype(A, /obj/structure/table))
			var/obj/structure/table/T = A
			if (!T.can_touch(src) || T.flipped != 0 || !T.flip(get_cardinal_dir(src, T)))
				continue
			if(T.climbable)
				T.structure_shaken()
			playsound(T,'sound/machines/Table_Fall.ogg',100,1)

		else if(istype(A, /obj/machinery/door))
			var/obj/machinery/door/D = A
			D.Bumped(src)

		else if(istype(A, /obj/machinery/button))
			A.attack_hand(src)

		else if(istype(A, /obj/item) || prob(33))
			if(A.anchored)
				continue
			step(A, pick(cardinal))

		else
			continue
		stumbled = TRUE

	if(stumbled)
		visible_message(SPAN_WARNING("[src] stumbles around."))


/mob/living/carbon/human/stun_effect_act(var/stun_amount, var/agony_amount, var/def_zone)

	var/obj/item/organ/external/affected = get_organ(check_zone(def_zone))

//	No siemens coefficient calculations now, it's all done with armor "Energy" protection stat

	switch (def_zone)
		if(BP_L_ARM, BP_R_ARM)
			var/c_hand
			if (def_zone == BP_L_ARM)
				c_hand = l_hand
			else
				c_hand = r_hand

			if(c_hand && (stun_amount || agony_amount > 10))
				msg_admin_attack("[src.name] ([src.ckey]) was disarmed by a stun effect")

				drop_from_inventory(c_hand)
				if (BP_IS_ROBOTIC(affected))
					emote("pain", 1, "drops what they were holding, their [affected.name] malfunctioning!")
				else
					var/emote_scream = pick("screams in pain and ", "lets out a sharp cry and ", "cries out and ")
					emote("pain", 1, "[(species && species.flags & NO_PAIN) ? "" : emote_scream ]drops what they were holding in their [affected.name]!")

	..(stun_amount, agony_amount, def_zone)

/mob/living/carbon/human/getarmor(var/def_zone, var/type)
	var/armorval = 0
	var/total = 0

	if(def_zone)
		if(isorgan(def_zone))
			return getarmor_organ(def_zone, type)
		var/obj/item/organ/external/affecting = get_organ(def_zone)
		if(affecting)
			return getarmor_organ(affecting, type)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	for(var/organ_name in organs_by_name)
		if (organ_name in organ_rel_size)
			var/obj/item/organ/external/organ = organs_by_name[organ_name]
			if(organ)
				var/weight = organ_rel_size[organ_name]
				armorval += getarmor_organ(organ, type) * weight
				total += weight
	return (armorval/max(total, 1))

//this proc returns the Siemens coefficient of electrical resistivity for a particular external organ.
/mob/living/carbon/human/proc/get_siemens_coefficient_organ(obj/item/organ/external/def_zone)
	if (!def_zone)
		return 1.0

	var/siemens_coefficient = species.siemens_coefficient

	var/list/clothing_items = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes) // What all are we checking?
	for(var/obj/item/clothing/C in clothing_items)
		if((C.body_parts_covered & def_zone.body_part)) // Is that body part being targeted covered?
			siemens_coefficient *= C.siemens_coefficient

	return siemens_coefficient

//this proc returns the armour value for a particular external organ.
/mob/living/carbon/human/proc/getarmor_organ(var/obj/item/organ/external/def_zone, var/type)
	if(!type || !def_zone) return 0
	var/protection = 0
	var/list/protective_gear = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes)
	if(def_zone.armor)
		if(def_zone.armor.getRating(type) > protection)
			protection = def_zone.armor.getRating(type)

	for(var/gear in protective_gear)
		if(gear && istype(gear ,/obj/item/clothing))
			var/obj/item/clothing/C = gear
			if(istype(C) && C.body_parts_covered & def_zone.body_part && C.armor)
				if(C.armor.vars[type] > protection)
					protection = C.armor.vars[type]

	var/obj/item/shield/shield = has_shield()

	if(shield)
		protection += shield.armor[type]

	return protection

/mob/living/carbon/human/proc/check_head_coverage()

	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform)
	for(var/bp in body_parts)
		if(!bp)	continue
		if(bp && istype(bp ,/obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & HEAD)
				return 1
	return 0

//Used to check if they can be fed food/drinks/pills
/mob/living/carbon/human/proc/check_mouth_coverage()
	var/list/protective_gear = list(head, wear_mask, wear_suit, w_uniform)
	for(var/obj/item/gear in protective_gear)
		if(istype(gear) && (gear.body_parts_covered & FACE) && !(gear.item_flags & FLEXIBLEMATERIAL))
			return gear
	return null

/mob/living/carbon/human/proc/check_shields(var/damage = 0, var/atom/damage_source = null, var/mob/attacker = null, var/def_zone = null, var/attack_text = "the attack")
	for(var/obj/item/shield in list(l_hand, r_hand, wear_suit))
		if(!shield) continue
		. = shield.handle_shield(src, damage, damage_source, attacker, def_zone, attack_text)
		if(.) return
	return 0

/mob/living/carbon/human/proc/has_shield()
	for(var/obj/item/shield/shield in list(l_hand, r_hand))
		if(!shield) continue
		return shield
	return FALSE

/mob/living/carbon/human/resolve_item_attack(obj/item/I, mob/living/user, var/target_zone)
	if(check_attack_throat(I, user))
		return null

	if(user == src) // Attacking yourself can't miss
		return target_zone

	var/hit_zone = get_zone_with_miss_chance(target_zone, src)

	if(!hit_zone)
		visible_message(SPAN_DANGER("\The [user] misses [src] with \the [I]!"))
		return null

	if(check_shields(I.force, I, user, target_zone, "the [I.name]"))
		return null

	var/obj/item/organ/external/affecting = get_organ(hit_zone)
	if (!affecting || affecting.is_stump())
		to_chat(user, SPAN_DANGER("They are missing that limb!"))
		return null

	return hit_zone

/mob/living/carbon/human/hit_with_weapon(obj/item/I, mob/living/user, var/effective_force, var/hit_zone)
	var/obj/item/organ/external/affecting = get_organ(hit_zone)
	if(!affecting)
		return FALSE//should be prevented by attacked_with_item() but for sanity.

	visible_message("<span class='danger'>[src] has been [I.attack_verb.len? pick(I.attack_verb) : "attacked"] in the [affecting.name] with [I.name] by [user]!</span>")

	standard_weapon_hit_effects(I, user, effective_force, hit_zone)

	return TRUE

/mob/living/carbon/human/standard_weapon_hit_effects(obj/item/I, mob/living/user, var/effective_force, var/hit_zone)
	var/obj/item/organ/external/affecting = get_organ(hit_zone)
	if(!affecting)
		return FALSE

	// Handle striking to cripple.
	if(user.a_intent == I_DISARM)
		effective_force /= 2 //half the effective force
		if(!..(I, user, effective_force, hit_zone))
			return FALSE

		attack_joint(affecting, I) //but can dislocate joints
	else if(!..())
		return FALSE

	if(effective_force > 10 || effective_force >= 5 && prob(33))
		forcesay(hit_appends)	//forcesay checks stat already

		//Apply blood
		if(!((I.flags & NOBLOODY)||(I.item_flags & NOBLOODY)))
			I.add_blood(src)

		if(prob(33 + I.sharp * 10))
			var/turf/location = loc
			if(istype(location, /turf/simulated))
				location.add_blood(src)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				if(get_dist(H, src) <= 1) //people with TK won't get smeared with blood
					H.bloody_body(src)
					H.bloody_hands(src)

			switch(hit_zone)
				if(BP_HEAD)
					if(wear_mask)
						wear_mask.add_blood(src)
						update_inv_wear_mask(0)
					if(head)
						head.add_blood(src)
						update_inv_head(0)
					if(glasses && prob(33))
						glasses.add_blood(src)
						update_inv_glasses(0)
				if(BP_CHEST)
					bloody_body(src)
			//All this is copypasta'd from projectile code. Basically there's a cool splat animation when someone gets hit by something.
			var/splatter_dir = dir
			var/turf/target_loca = get_turf(src)
			splatter_dir = get_dir(user, target_loca)
			target_loca = get_step(target_loca, splatter_dir)
			var/blood_color = "#C80000"
			blood_color = src.species.blood_color
			new /obj/effect/overlay/temp/dir_setting/bloodsplatter(src.loc, splatter_dir, blood_color)
			target_loca.add_blood(src)

	return TRUE

/mob/living/carbon/human/proc/attack_joint(var/obj/item/organ/external/organ, var/obj/item/W)
	if(!organ || (organ.dislocated == 2) || (organ.dislocated == -1) )
		return FALSE
	//There was blocked var, removed now. For the sake of game balance, it was just replaced by 2
	if(prob(W.force / 2))
		visible_message("<span class='danger'>[src]'s [organ.joint] [pick("gives way","caves in","crumbles","collapses")]!</span>")
		organ.dislocate(1)
		return TRUE
	return FALSE

//this proc handles being hit by a thrown atom
/mob/living/carbon/human/hitby(atom/movable/AM as mob|obj,var/speed = THROWFORCE_SPEED_DIVISOR)
	if(istype(AM,/obj/))
		var/obj/O = AM

		if(in_throw_mode && !get_active_hand() && speed <= THROWFORCE_SPEED_DIVISOR)	//empty active hand and we're in throw mode
			if(canmove && !restrained())
				if(isturf(O.loc))
					put_in_active_hand(O)
					visible_message(SPAN_WARNING("[src] catches [O]!"))
					throw_mode_off()
					return

		var/dtype = O.damtype
		var/throw_damage = O.throwforce * (speed / THROWFORCE_SPEED_DIVISOR)

		var/zone
		if (isliving(O.thrower))
			var/mob/living/L = O.thrower
			zone = check_zone(L.targeted_organ)
		else
			zone = ran_zone(BP_CHEST, 75)	//Hits a random part of the body, geared towards the chest

		//check if we hit
		var/miss_chance = 15
		if (O.throw_source)
			var/distance = get_dist(O.throw_source, loc)
			miss_chance = max(15*(distance-2), 0)
		zone = get_zone_with_miss_chance(zone, src, miss_chance, ranged_attack=1)

		if(zone && O.thrower != src)
			var/shield_check = check_shields(throw_damage, O, thrower, zone, "[O]")
			if(shield_check == PROJECTILE_FORCE_MISS)
				zone = null
			else if(shield_check)
				return

		if(!zone)
			visible_message(SPAN_NOTICE("\The [O] misses [src] narrowly!"))
			return

		O.throwing = 0		//it hit, so stop moving

		var/obj/item/organ/external/affecting = get_organ(zone)
		var/hit_area = affecting.name

		if (O.is_hot() >= HEAT_MOBIGNITE_THRESHOLD)
			IgniteMob()

		src.visible_message("\red [src] has been hit in the [hit_area] by [O].")

		damage_through_armor(throw_damage, dtype, null, ARMOR_MELEE, null, used_weapon = O, sharp = is_sharp(O), edge = has_edge(O))

		if(ismob(O.thrower))
			var/mob/M = O.thrower
			var/client/assailant = M.client
			if(assailant)
				src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been hit with a [O], thrown by [M.name] ([assailant.ckey])</font>")
				M.attack_log += text("\[[time_stamp()]\] <font color='red'>Hit [src.name] ([src.ckey]) with a thrown [O]</font>")
				if(!ismouse(src))
					msg_admin_attack("[src.name] ([src.ckey]) was hit by a [O], thrown by [M.name] ([assailant.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)")

		//thrown weapon embedded object code.
		if(istype(O,/obj/item))
			var/obj/item/I = O
			if (I && I.damtype == BRUTE && !I.anchored && !is_robot_module(I))
				var/damage = throw_damage
				var/sharp = is_sharp(I)

				//blunt objects should really not be embedding in things unless a huge amount of force is involved

				var/embed_threshold = sharp? 3*I.w_class : 9*I.w_class


				var/embed_chance = (damage - embed_threshold)*I.embed_mult
				if (embed_chance > 0 && prob(embed_chance))
					affecting.embed(I)

		// Begin BS12 momentum-transfer code.
		var/mass = 1.5
		if(istype(O, /obj/item))
			var/obj/item/I = O
			mass = I.w_class/THROWNOBJ_KNOCKBACK_DIVISOR
		var/momentum = speed*mass

		if(O.throw_source && momentum >= THROWNOBJ_KNOCKBACK_SPEED)
			var/dir = get_dir(O.throw_source, src)

			visible_message("\red [src] staggers under the impact!","\red You stagger under the impact!")
			src.throw_at(get_edge_target_turf(src,dir),1,momentum)

			if(!O || !src) return

			if(O.loc == src && O.sharp) //Projectile is embedded and suitable for pinning.
				var/turf/T = near_wall(dir,2)

				if(T)
					src.loc = T
					visible_message(SPAN_WARNING("[src] is pinned to the wall by [O]!"),SPAN_WARNING("You are pinned to the wall by [O]!"))
					src.anchored = TRUE
					src.pinned += O

/mob/living/carbon/human/embed(var/obj/O, var/def_zone)
	if(!def_zone) ..()

	var/obj/item/organ/external/affecting = get_organ(def_zone)
	if(affecting)
		affecting.embed(O)


/mob/living/carbon/human/proc/bloody_hands(var/mob/living/source, var/amount = 2)
	if (gloves)
		gloves.add_blood(source)
		gloves:transfer_blood = amount
		gloves:bloody_hands_mob = source
	else
		add_blood(source)
		bloody_hands = amount
		bloody_hands_mob = source
	update_inv_gloves()		//updates on-mob overlays for bloody hands and/or bloody gloves

/mob/living/carbon/human/proc/bloody_body(var/mob/living/source)
	if(wear_suit)
		wear_suit.add_blood(source)
		update_inv_wear_suit(0)
	if(w_uniform)
		w_uniform.add_blood(source)
		update_inv_w_uniform(0)

/mob/living/carbon/human/proc/handle_suit_punctures(var/damtype, var/damage, var/def_zone)

	// Tox and oxy don't matter to suits.
	if(damtype != BURN && damtype != BRUTE) return

	// The rig might soak this hit, if we're wearing one.
	if(back && istype(back,/obj/item/rig))
		var/obj/item/rig/rig = back
		rig.take_hit(damage)

	// We may also be taking a suit breach.
	if(!wear_suit) return
	if(!istype(wear_suit,/obj/item/clothing/suit/space)) return
	var/obj/item/clothing/suit/space/SS = wear_suit
	var/penetrated_dam = max(0,(damage - SS.breach_threshold))
	if(prob(20 + (penetrated_dam * SS.resilience))) SS.create_breaches(damtype, penetrated_dam) // changed into a probability calculation based on the degree of penetration by Plasmatik. you can tune resilience to drastically change breaching chances.
																			// at maximum penetration, breaches are always created, at 1 penetration, they have a 20% chance to form

/mob/living/carbon/human/reagent_permeability()
	var/perm = 0

	var/list/perm_by_part = list(
		"head" = THERMAL_PROTECTION_HEAD,
		"upper_torso" = THERMAL_PROTECTION_UPPER_TORSO,
		"lower_torso" = THERMAL_PROTECTION_LOWER_TORSO,
		"legs" = THERMAL_PROTECTION_LEG_LEFT + THERMAL_PROTECTION_LEG_RIGHT,
		"arms" = THERMAL_PROTECTION_ARM_LEFT + THERMAL_PROTECTION_ARM_RIGHT,
		)

	for(var/obj/item/clothing/C in src.get_equipped_items())
		if(C.permeability_coefficient == 1 || !C.body_parts_covered)
			continue
		if(C.body_parts_covered & HEAD)
			perm_by_part["head"] *= C.permeability_coefficient
		if(C.body_parts_covered & UPPER_TORSO)
			perm_by_part["upper_torso"] *= C.permeability_coefficient
		if(C.body_parts_covered & LOWER_TORSO)
			perm_by_part["lower_torso"] *= C.permeability_coefficient
		if(C.body_parts_covered & LEGS)
			perm_by_part["legs"] *= C.permeability_coefficient
		if(C.body_parts_covered & ARMS)
			perm_by_part["arms"] *= C.permeability_coefficient

	for(var/part in perm_by_part)
		perm += perm_by_part[part]

	return perm

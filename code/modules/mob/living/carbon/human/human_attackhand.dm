/mob/living/carbon/human/proc/get_unarmed_attack(var/mob/living/carbon/human/target, var/hit_zone)
	for(var/datum/unarmed_attack/u_attack in species.unarmed_attacks)
		if(u_attack.is_usable(src, target, hit_zone))
			if(pulling_punches)
				var/datum/unarmed_attack/soft_variant = u_attack.get_sparring_variant()
				if(soft_variant)
					return soft_variant
			return u_attack
	return null

/mob/living/carbon/human/attack_hand(mob/living/carbon/M as mob)

	var/mob/living/carbon/human/H = M
	if(istype(H))
		var/obj/item/organ/external/temp = H.organs_by_name[BP_R_ARM]
		if(H.hand)
			temp = H.organs_by_name[BP_L_ARM]
		if(!temp || !temp.is_usable())
			to_chat(H, "\red You can't use your hand.")
			return

	..()

	// Should this all be in Touch()?
	if(istype(H))
		if(H != src && check_shields(0, null, H, H.targeted_organ, H.name))
			H.do_attack_animation(src)
			return 0

		if(istype(H.gloves, /obj/item/clothing/gloves/boxing/hologlove))
			H.do_attack_animation(src)
			var/damage = rand(0, 9)
			if(!damage)
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				visible_message("\red <B>[H] has attempted to punch [src]!</B>")
				return 0
			var/obj/item/organ/external/affecting = get_organ(ran_zone(H.targeted_organ))

			if(HULK in H.mutations)
				damage += 5

			playsound(loc, "punch", 25, 1, -1)

			visible_message("\red <B>[H] has punched [src]!</B>")

			damage_through_armor(damage, HALLOSS, affecting, ARMOR_MELEE)
			if(damage >= 9)
				visible_message("\red <B>[H] has weakened [src]!</B>")
				apply_effect(4, WEAKEN, getarmor(affecting, ARMOR_MELEE))

			return

	if(iscarbon(M))
		M.spread_disease_to(src, "Contact")

	switch(M.a_intent)
		if(I_HELP)
			if(can_operate(src, M) == CAN_OPERATE_ALL && do_surgery(src, M, null, TRUE))
				return 1
			else if(istype(H) && health < HEALTH_THRESHOLD_CRIT && health > HEALTH_THRESHOLD_DEAD)
				if(H == src)
					to_chat(H, SPAN_NOTICE("You can't perform CPR on yourself."))
					return
				if(!H.check_has_mouth())
					to_chat(H, SPAN_DANGER("You don't have a mouth, you cannot perform CPR!"))
					return
				if(!check_has_mouth())
					to_chat(H, SPAN_DANGER("They don't have a mouth, you cannot perform CPR!"))
					return
				if((H.head && (H.head.body_parts_covered & FACE)) || (H.wear_mask && (H.wear_mask.body_parts_covered & FACE)))
					to_chat(H, SPAN_NOTICE("Remove your mask!"))
					return 0
				if((head && (head.body_parts_covered & FACE)) || (wear_mask && (wear_mask.body_parts_covered & FACE)))
					to_chat(H, SPAN_NOTICE("Remove [src]'s mask!"))
					return 0

				if (!cpr_time)
					return 0

				cpr_time = 0
				spawn(30)
					cpr_time = 1

				H.visible_message(SPAN_DANGER("\The [H] is trying perform CPR on \the [src]!"))

				if(!do_after(H, 30, src))
					return

				var/cpr_efficiency = 3 + max(0, 2 * (H.stats.getStat(STAT_BIO) / 10))
				adjustOxyLoss(-(min(getOxyLoss(), cpr_efficiency)))
				updatehealth()
				H.visible_message(SPAN_DANGER("\The [H] performs CPR on \the [src]!"))
				to_chat(src, SPAN_NOTICE("You feel a breath of fresh air enter your lungs. It feels good."))
				to_chat(H, SPAN_WARNING("Repeat at least every 7 seconds."))
			else
				help_shake_act(M)
			return 1

		if(I_GRAB)
			if(M == src || anchored)
				return 0
			for(var/obj/item/grab/G in src.grabbed_by)
				if(G.assailant == M)
					to_chat(M, SPAN_NOTICE("You already grabbed [src]."))
					return
			if(w_uniform)
				w_uniform.add_fingerprint(M)

			var/obj/item/grab/G = new /obj/item/grab(M, src)
			if(buckled)
				to_chat(M, SPAN_NOTICE("You cannot grab [src], \he is buckled in!"))
			if(!G)	//the grab will delete itself in New if affecting is anchored
				return
			M.put_in_active_hand(G)
			G.synch()
			LAssailant = M

			H.do_attack_animation(src)
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message(SPAN_WARNING("[M] has grabbed [src] passively!"))
			src.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been grabbed passively by [M.name] ([M.ckey])</font>"
			M.attack_log += "\[[time_stamp()]\] <font color='red'>Grabbed passively [src.name] ([src.ckey])</font>"
			msg_admin_attack("[M] grabbed passively a [src].")
			return 1

		if(I_HURT)
			if(M.targeted_organ == BP_MOUTH && wear_mask && istype(wear_mask, /obj/item/grenade))
				var/obj/item/grenade/G = wear_mask
				if(!G.active)
					visible_message(SPAN_DANGER("\The [M] pulls the pin from \the [src]'s [G.name]!"))
					G.activate(M)
					update_inv_wear_mask()
				else
					to_chat(M, SPAN_WARNING("\The [G] is already primed! Run!"))
				return

			if(!istype(H))
				attack_generic(H,rand(1,3),"punched")
				return

			var/stat_damage = 3 + max(0, (H.stats.getStat(STAT_ROB) / 10))
			var/limb_efficiency_multiplier = 1
			var/block = 0
			var/accurate = 0
			var/hit_zone = H.targeted_organ
			var/obj/item/organ/external/affecting = get_organ(hit_zone)
			var/obj/item/organ/external/current_hand = organs_by_name[hand ? BP_L_ARM : BP_R_ARM]

			if(current_hand)
				limb_efficiency_multiplier = 1 * (current_hand.limb_efficiency / 100)

			if(!affecting || affecting.is_stump())
				to_chat(M, SPAN_DANGER("They are missing that limb!"))
				return 1

			switch(src.a_intent)
				if(I_HELP)
					// We didn't see this coming, so we get the full blow
					stat_damage = stat_damage + 1
					accurate = 1
				if(I_HURT, I_GRAB)
					// We're in a fighting stance, there's a chance we block
					if(src.canmove && src!=H && prob(10 + round(src.stats.getStat(STAT_TGH) / 3)))
						block = 1

			if (M.grabbed_by.len)
				// Someone got a good grip on them, they won't be able to do much damage
				stat_damage = max(1, stat_damage - 2)

			if(src.grabbed_by.len || src.buckled || !src.canmove || src==H)
				accurate = 1 // certain circumstances make it impossible for us to evade punches
				stat_damage = stat_damage + 2

			stat_damage *= limb_efficiency_multiplier

			// Process evasion and blocking
			var/miss_type = 0
			var/attack_message
			if(!accurate)
				/*
					This place is kind of convoluted and will need some explaining.
					ran_zone() will pick out of 11 zones, thus the chance for hitting
					our target where we want to hit them is circa 9.1%.

					Now since we want to statistically hit our target organ a bit more
					often than other organs, we add a base chance of 50% for hitting it.

					And after that, we subtract AGI stat from chance to hit different organ.
					General miss chance also depends on AGI.

					Note: We don't use get_zone_with_miss_chance() here since the chances
						  were made for projectiles.
					TODO: proc for melee combat miss chances depending on organ?
				*/
				if(prob(50 - H.stats.getStat(STAT_ROB)))
					hit_zone = ran_zone(hit_zone)
				if(prob(25 - H.stats.getStat(STAT_ROB)) && hit_zone != BP_CHEST) // Missed!
					if(!src.lying)
						attack_message = "[H] attempted to strike [src], but missed!"
					else
						attack_message = "[H] attempted to strike [src], but \he rolled out of the way!"
						src.set_dir(pick(cardinal))
					miss_type = 1

			if(!miss_type && block)
				attack_message = "[H] went for [src]'s [affecting.name] but was blocked!"
				miss_type = 2

			// See what attack they use
			var/datum/unarmed_attack/attack = H.get_unarmed_attack(src, hit_zone)
			if(!attack)
				return 0

			H.do_attack_animation(src)
			if(!attack_message)
				attack.show_attack(H, src, hit_zone, stat_damage)
			else
				H.visible_message(SPAN_DANGER("[attack_message]"))

			//The stronger you are, the louder you strike!
			var/attack_volume = 25 + H.stats.getStat(STAT_ROB)
			playsound(loc, ((miss_type) ? (miss_type == 1 ? attack.miss_sound : 'sound/weapons/thudswoosh.ogg') : attack.attack_sound), attack_volume, 1, -1)
			H.attack_log += text("\[[time_stamp()]\] <font color='red'>[miss_type ? (miss_type == 1 ? "Missed" : "Blocked") : "[pick(attack.attack_verb)]"] [src.name] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>[miss_type ? (miss_type == 1 ? "Was missed by" : "Has blocked") : "Has Been [pick(attack.attack_verb)]"] by [H.name] ([H.ckey])</font>")
			msg_admin_attack("[key_name(H)] [miss_type ? (miss_type == 1 ? "has missed" : "was blocked by") : "has [pick(attack.attack_verb)]"] [key_name(src)]")

			if(miss_type)
				return FALSE

			var/real_damage = stat_damage
			real_damage += attack.get_unarmed_damage(H)
			real_damage *= damage_multiplier
			stat_damage *= damage_multiplier
			if(HULK in H.mutations)
				real_damage *= 2 // Hulks do twice the damage
				stat_damage *= 2
			real_damage = max(1, real_damage)

			// Apply additional unarmed effects.
			attack.apply_effects(H, src, getarmor(affecting, ARMOR_MELEE), stat_damage, hit_zone)

			// Finally, apply damage to target
			damage_through_armor(real_damage, (attack.deal_halloss ? HALLOSS : BRUTE), affecting, ARMOR_MELEE, sharp = attack.sharp, edge = attack.edge)
			hit_impact(real_damage, get_step(H, src))

		if(I_DISARM)
			M.attack_log += text("\[[time_stamp()]\] <font color='red'>Disarmed [src.name] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been disarmed by [M.name] ([M.ckey])</font>")

			msg_admin_attack("[key_name(M)] disarmed [src.name] ([src.ckey])")
			M.do_attack_animation(src)

			if(w_uniform)
				w_uniform.add_fingerprint(M)

			var/list/holding = list(get_active_hand() = 40, get_inactive_hand = 20)

			//See if they have any guns that might go off
			for(var/obj/item/gun/W in holding)
				if(W && prob(holding[W]))
					var/list/turfs = list()
					for(var/turf/T in view())
						turfs += T
					if(turfs.len)
						var/turf/target = pick(turfs)
						visible_message(SPAN_DANGER("[src]'s [W] goes off during the struggle!"))
						return W.afterattack(target,src)

			var/randn = rand(1, 100)
			randn = max(1, randn - H.stats.getStat(STAT_ROB))

			if(randn <= 50)
				//See about breaking grips or pulls
				if(break_all_grabs(M))
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					return

				//Actually disarm them
				for(var/obj/item/I in holding)
					if(I && src.unEquip(I))
						visible_message(SPAN_DANGER("[M] has disarmed [src]!"))
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						return

			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			visible_message("\red <B>[M] attempted to disarm [src]!</B>")
	return

/mob/living/carbon/human/proc/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, inrange, params)
	return

/mob/living/carbon/human/attack_generic(var/mob/user, var/damage, var/attack_message)

	if(!damage || !istype(user))
		return

	user.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
	src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [user.name] ([user.ckey])</font>")
	src.visible_message(SPAN_DANGER("[user] has [attack_message] [src]!"))

	user.do_attack_animation(src)

	var/dam_zone = pick(organs_by_name)
	var/obj/item/organ/external/affecting = get_organ(ran_zone(dam_zone))
	var/dam = damage_through_armor(damage, BRUTE, affecting, ARMOR_MELEE)
	if(dam > 0)
		affecting.add_autopsy_data("[attack_message] by \a [user]", dam)
	updatehealth()
	hit_impact(damage, get_step(user, src))
	return TRUE

//Used to attack a joint through grabbing
/mob/living/carbon/human/proc/grab_joint(var/mob/living/user, var/def_zone)
	var/has_grab = 0
	for(var/obj/item/grab/G in list(user.l_hand, user.r_hand))
		if(G.affecting == src && G.state == GRAB_NECK)
			has_grab = 1
			break

	if(!has_grab)
		return 0

	if(!def_zone) def_zone = user.targeted_organ
	var/target_zone = check_zone(def_zone)
	if(!target_zone)
		return 0
	var/obj/item/organ/external/organ = get_organ(check_zone(target_zone))
	if(!organ || organ.is_dislocated() || organ.dislocated == -1)
		return 0

	user.visible_message(SPAN_WARNING("[user] begins to dislocate [src]'s [organ.joint]!"))
	if(do_after(user, 100, progress = 0))
		organ.dislocate(1)
		src.visible_message("<span class='danger'>[src]'s [organ.joint] [pick("gives way","caves in","crumbles","collapses")]!</span>")
		return 1
	return 0

//Breaks all grips and pulls that the mob currently has.
/mob/living/carbon/human/proc/break_all_grabs(mob/living/carbon/user)
	var/success = 0
	if(pulling)
		visible_message(SPAN_DANGER("[user] has broken [src]'s grip on [pulling]!"))
		success = 1
		stop_pulling()

	if(istype(l_hand, /obj/item/grab))
		var/obj/item/grab/lgrab = l_hand
		if(lgrab.affecting)
			visible_message(SPAN_DANGER("[user] has broken [src]'s grip on [lgrab.affecting]!"))
			success = 1
		spawn(1)
			qdel(lgrab)
	if(istype(r_hand, /obj/item/grab))
		var/obj/item/grab/rgrab = r_hand
		if(rgrab.affecting)
			visible_message(SPAN_DANGER("[user] has broken [src]'s grip on [rgrab.affecting]!"))
			success = 1
		spawn(1)
			qdel(rgrab)
	return success
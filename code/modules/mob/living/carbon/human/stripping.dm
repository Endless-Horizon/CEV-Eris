/mob/living/carbon/human/proc/handle_strip(slot_to_strip, mob/living/user)

	if(!slot_to_strip || !user.IsAdvancedToolUser())
		return

	if(user.incapacitated()  || !user.Adjacent(src))
		user << browse(null, text("window=mob[src.name]"))
		return

	var/obj/item/target_slot = get_equipped_item(text2num(slot_to_strip))

	switch(slot_to_strip)
		// Handle things that are part of this interface but not removing/replacing a given item.
		if("pockets")
			if(!user.stats.getPerk(PERK_FAST_FINGERS))
				visible_message(SPAN_DANGER("\The [user] is trying to empty \the [src]'s pockets!"))
			else
				to_chat(user, SPAN_NOTICE("You silently try to empty \the [src]'s pockets."))	
			if(do_mob(user,src,HUMAN_STRIP_DELAY,progress = 1))
				empty_pockets(user)
			return
		if("splints")
			visible_message(SPAN_DANGER("\The [user] is trying to remove \the [src]'s splints!"))
			if(do_mob(user,src,HUMAN_STRIP_DELAY,progress = 1))
				remove_splints(user)
			return
		if("internals")
			visible_message(SPAN_DANGER("\The [usr] is trying to set \the [src]'s internals!"))
			if(do_mob(user,src,HUMAN_STRIP_DELAY, progress = 1))
				toggle_internals(user)
			return
		if("tie")
			var/obj/item/clothing/under/suit = w_uniform
			if(!istype(suit) || !suit.accessories.len)
				return
			var/obj/item/clothing/accessory/A = suit.accessories[1]
			if(!istype(A))
				return
			visible_message(SPAN_DANGER("\The [usr] is trying to remove \the [src]'s [A.name]!"))

			if(!do_mob(user,src,HUMAN_STRIP_DELAY,progress=1))
				return

			if(!A || suit.loc != src || !(A in suit.accessories))
				return

			if(istype(A, /obj/item/clothing/accessory/badge) || istype(A, /obj/item/clothing/accessory/medal))
				user.visible_message(SPAN_DANGER("\The [user] tears off \the [A] from [src]'s [suit.name]!"))
			attack_log += "\[[time_stamp()]\] <font color='orange'>Has had \the [A] removed by [user.name] ([user.ckey])</font>"
			user.attack_log += "\[[time_stamp()]\] <font color='red'>Attempted to remove [name]'s ([ckey]) [A.name]</font>"
			A.on_removed(user)
			suit.accessories -= A
			update_inv_w_uniform()
			return

	// Are we placing or stripping?
	var/stripping
	var/obj/item/held = user.get_active_hand()
	if(!istype(held) || is_robot_module(held))
		if(!istype(target_slot))  // They aren't holding anything valid and there's nothing to remove, why are we even here?
			return
		if(!target_slot.canremove)
			to_chat(user, SPAN_WARNING("You cannot remove \the [src]'s [target_slot.name]."))
			return
		stripping = TRUE

	if(stripping)
		if((target_slot == r_hand || target_slot == l_hand) && user.stats.getPerk(PERK_FAST_FINGERS))
			to_chat(user, SPAN_NOTICE("You silently try to remove \the [src]'s [target_slot.name]."))
		else
			visible_message(SPAN_DANGER("\The [user] is trying to remove \the [src]'s [target_slot.name]!"))
	else
		if((slot_to_strip == r_hand || slot_to_strip == l_hand) && user.stats.getPerk(PERK_FAST_FINGERS))
			to_chat(user, SPAN_NOTICE("You silently try to put \a [held] on \the [src]."))
		else
			visible_message(SPAN_DANGER("\The [user] is trying to put \a [held] on \the [src]!"))

	if(!do_mob(user,src,HUMAN_STRIP_DELAY,progress = 1))
		return

	if(!stripping && user.get_active_hand() != held)
		return

	if(stripping)
		admin_attack_log(user, src, "Attempted to remove \a [target_slot]", "Target of an attempt to remove \a [target_slot].", "attempted to remove \a [target_slot] from")
		unEquip(target_slot)
		if(istype(target_slot,  /obj/item/storage/backpack))
			SEND_SIGNAL(user, COMSIG_EMPTY_POCKETS, src)
	else if(user.unEquip(held))
		equip_to_slot_if_possible(held, text2num(slot_to_strip), TRUE) // Disable warning
		if(held.loc != src)
			user.put_in_hands(held)

// Empty out everything in the target's pockets.
/mob/living/carbon/human/proc/empty_pockets(mob/living/user)
	if(!r_store && !l_store)
		to_chat(user, SPAN_WARNING("\The [src] has nothing in their pockets."))
		return
	if(r_store)
		unEquip(r_store)
	if(l_store)
		unEquip(l_store)
	if(!user.stats.getPerk(PERK_FAST_FINGERS))
		visible_message(SPAN_DANGER("\The [user] empties \the [src]'s pockets!"))
	else
		to_chat(user, SPAN_NOTICE("You empty \the [src]'s pockets."))
	SEND_SIGNAL(user, COMSIG_EMPTY_POCKETS, src)

// Remove all splints.
/mob/living/carbon/human/proc/remove_splints(var/mob/living/user)
	var/can_reach_splints = 1
	if(istype(wear_suit,/obj/item/clothing/suit/space))
		var/obj/item/clothing/suit/space/suit = wear_suit
		if(suit.supporting_limbs && suit.supporting_limbs.len)
			to_chat(user, SPAN_WARNING("You cannot remove the splints - [src]'s [suit] is supporting some of the breaks."))
			can_reach_splints = 0

	if(can_reach_splints)
		var/removed_splint
		for(var/organ in list(BP_R_ARM, BP_L_ARM, BP_R_LEG, BP_L_LEG, BP_GROIN, BP_HEAD, BP_CHEST))
			var/obj/item/organ/external/o = get_organ(organ)
			if (o && o.status & ORGAN_SPLINTED)
				var/obj/item/W = new /obj/item/stack/medical/splint(get_turf(src), 1)
				o.status &= ~ORGAN_SPLINTED
				W.add_fingerprint(user)
				removed_splint = 1
		if(removed_splint)
			visible_message(SPAN_DANGER("\The [user] removes \the [src]'s splints!"))
		else
			to_chat(user, SPAN_WARNING("\The [src] has no splints to remove."))

// Set internals on or off.
/mob/living/carbon/human/proc/toggle_internals(var/mob/living/user)
	if(internal)
		visible_message(SPAN_DANGER("\The [user] disables \the [src]'s internals!"))
		internal.add_fingerprint(user)
		internal = null
	else
		// Check for airtight mask/helmet.
		if(!(istype(wear_mask, /obj/item/clothing/mask) || istype(head, /obj/item/clothing/head/space)))
			return
		// Find an internal source.
		if(istype(back, /obj/item/tank))
			internal = back
		else if(istype(s_store, /obj/item/tank))
			internal = s_store
		else if(istype(belt, /obj/item/tank))
			internal = belt
		visible_message(SPAN_WARNING("\The [src] is now running on internals!"))
		internal.add_fingerprint(user)

	if(HUDneed.Find("internal"))
		var/obj/screen/HUDelm = HUDneed["internal"]
		HUDelm.update_icon()

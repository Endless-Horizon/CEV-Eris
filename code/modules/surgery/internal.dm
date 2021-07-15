/datum/surgery_step/insert_item
	allowed_tools = list(/obj/item = 100)
	duration = 80
	blood_level = 1

/datum/surgery_step/insert_item/can_use(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	return organ.is_open() && organ.can_add_item(tool, user)

/datum/surgery_step/insert_item/begin_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	if(istype(tool, /obj/item/organ/external))
		user.visible_message(
			SPAN_NOTICE("[user] starts connecting [tool] to [organ.get_surgery_name()]."),
			SPAN_NOTICE("You start connecting [tool] to [organ.get_surgery_name()].")
		)
	else
		user.visible_message(
			SPAN_NOTICE("[user] starts inserting [tool] into [organ.get_surgery_name()]."),
			SPAN_NOTICE("You start inserting [tool] into [organ.get_surgery_name()].")
		)
	organ.owner_custom_pain("The pain in your [organ.name] is living hell!", 1)

/datum/surgery_step/insert_item/end_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	if(istype(tool, /obj/item/organ/external))
		user.visible_message(
			SPAN_NOTICE("[user] connects [tool] to [organ.get_surgery_name()]."),
			SPAN_NOTICE("You connect [tool] to [organ.get_surgery_name()].")
		)
	else
		user.visible_message(
			SPAN_NOTICE("[user] inserts [tool] into [organ.get_surgery_name()]."),
			SPAN_NOTICE("You insert [tool] into [organ.get_surgery_name()].")
		)
	organ.add_item(tool, user)
	if(BP_IS_ORGANIC(organ))
		playsound(get_turf(organ), 'sound/effects/squelch1.ogg', 50, 1)

/datum/surgery_step/insert_item/fail_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	user.visible_message(
		SPAN_WARNING("[user]'s hand slips, hitting [organ.get_surgery_name()] with \the [tool]!"),
		SPAN_WARNING("Your hand slips, hitting [organ.get_surgery_name()] with \the [tool]!")
	)
	organ.take_damage(5, 0)

/datum/surgery_step/insert_item/robotic
	required_stat = STAT_MEC


/obj/item/organ/external/proc/get_total_occupied_volume()
	. = 0
	for(var/obj/item/item in implants)
		if(istype(item, /obj/item/implant) || istype(item, /obj/item/organ_module))
			continue

		. += item.w_class

	for(var/organ_inside in internal_organs)
		var/obj/item/organ/internal/internal = organ_inside
		. += internal.specific_organ_size

/obj/item/organ/external/proc/can_add_item(obj/item/I, mob/living/user)
	if(!istype(I))
		return FALSE

	var/total_volume = get_total_occupied_volume()	//Used for internal organs and cavity implants

	// "Organ modules"
	// TODO: ditch them
	if(istype(I, /obj/item/organ_module))
		if(module)
			to_chat(user, SPAN_WARNING("There is already a module installed in [get_surgery_name()]."))
			return FALSE

		return TRUE

	// Implants
	if(istype(I, /obj/item/implant))
		var/obj/item/implant/implant = I

		// Technical limitation
		// TODO: fix this
		if(!owner)
			return FALSE

		if(!(organ_tag in implant.allowed_organs))
			to_chat(user, SPAN_WARNING("[implant] doesn't fit in [get_surgery_name()]."))
			return FALSE

		return TRUE

	// Organs
	if(istype(I, /obj/item/organ/internal))
		var/obj/item/organ/internal/organ = I

		var/o_a =  (organ.gender == PLURAL) ? "" : "a "

		if(organ.unique_tag)
			for(var/obj/item/organ/internal/existing_organ in owner.internal_organs)
				if(existing_organ.unique_tag == organ.unique_tag)
					to_chat(user, SPAN_WARNING("[owner] already has [o_a][organ.unique_tag]."))
					return FALSE

		if(BP_IS_ROBOTIC(src) && !BP_IS_ROBOTIC(organ))
			to_chat(user, SPAN_DANGER("You cannot install a naked organ into a robotic body part."))
			return FALSE

		if(total_volume + organ.specific_organ_size > max_volume)
			to_chat(user, SPAN_DANGER("There isn't enough space in [get_surgery_name()]!"))
			return FALSE

		if(istype(organ,/obj/item/organ/internal/bone))
			if(!(organ.parent_organ_base == organ_tag))
				to_chat(user, SPAN_DANGER("You can't fit [o_a][organ] inside [src]"))
				return FALSE

		return TRUE

	// Limbs
	else if(istype(I, /obj/item/organ/external))
		var/obj/item/organ/external/limb = I

		// Can't attach a limb to another loose limb
		if(!owner)
			return FALSE

		// Can't attach a stump
		if(limb.is_stump())
			return FALSE

		var/o_a =  (limb.gender == PLURAL) ? "" : "a "

		if(isnull(owner.species.has_limbs[limb.organ_tag]))
			to_chat(user, SPAN_WARNING("You're pretty sure [owner.species.name_plural] don't normally have [o_a][organ_tag_to_name[limb.organ_tag]]."))
			return FALSE

		var/obj/item/organ/external/existing_limb = owner.get_organ(limb.organ_tag)
		if(existing_limb && !existing_limb.is_stump())
			to_chat(user, SPAN_WARNING("\The [owner] already has [o_a][organ_tag_to_name[limb.organ_tag]]."))
			return FALSE

		// You can only attach a limb to either a parent organ or a stump of the same organ
		if(limb.parent_organ_base != organ_tag && limb.organ_tag != organ_tag)
			to_chat(user, SPAN_WARNING("You can't attach [limb] to [get_surgery_name()]!"))
			return FALSE

		return TRUE

// Cavity implants

	if(total_volume + I.w_class > max_volume)
		to_chat(user, SPAN_WARNING("There isn't enough space in [get_surgery_name()]!"))
		return FALSE

	return TRUE



/obj/item/organ/external/proc/add_item(atom/movable/I, mob/living/user, do_check=TRUE)
	if(do_check && !can_add_item(I, user))
		return

	user.unEquip(I, src)

	// "Organ modules"
	// TODO: ditch them, they suck. Extend organ system instead.
	if(istype(I, /obj/item/organ_module))
		var/obj/item/organ_module/organ_module = I
		organ_module.install(src)

	// Implants
	else if(istype(I, /obj/item/implant))
		var/obj/item/implant/implant = I
		implant.install(owner, organ_tag)
		owner.update_implants()

	// Internal organs
	else if(istype(I, /obj/item/organ/internal))
		var/obj/item/organ/organ = I
		organ.replaced(src)

	// Limbs
	else if(istype(I, /obj/item/organ/external))
		var/obj/item/organ/external/limb = I

		var/obj/item/organ/external/existing_limb = owner.get_organ(limb.organ_tag)
		var/obj/item/organ/external/target_limb = owner.get_organ(limb.parent_organ_base)

		// Save the owner before removing limb stump, as it may null the owner
		// if the operation is performed on the stump itself
		var/mob/living/carbon/human/saved_owner = owner

		// Remove existing limb (usually a limb stump)
		if(existing_limb)
			// Prevent the new limb from being deleted along with the old one
			limb.loc = null

			// Remove and delete the old limb
			existing_limb.removed(null, FALSE)
			qdel(existing_limb)

		limb.replaced(target_limb)

		saved_owner.update_body()
		saved_owner.updatehealth()
		saved_owner.UpdateDamageIcon()

	// Cavity implants
	else
		implants += I
		if(owner)
			owner.update_implants()



/obj/item/organ/external/proc/can_remove_item(atom/movable/I)
	if(!I)
		return FALSE

	if(I in implants)
		return TRUE

	if(I in internal_organs)
		var/obj/item/organ/organ = I
		if(!istype(organ) || (organ.status && ORGAN_CUT_AWAY) || (istype(organ,/obj/item/organ/internal/bone) && (organ.parent.status & ORGAN_BROKEN)))
			return TRUE

	return FALSE



/obj/item/organ/external/proc/remove_item(atom/movable/I, mob/living/user, do_check=TRUE)
	if(do_check && !can_remove_item(I))
		return

	if(I in implants)
		implants -= I
		embedded -= I
		if(isitem(I))
			var/obj/item/item = I
			item.on_embed_removal(owner)
		if(istype(I, /obj/item/implant))
			var/obj/item/implant/implant = I
			if(implant.wearer)
				implant.uninstall()
			else
				I.forceMove(drop_location())

		else if(istype(I, /obj/item/organ_module))
			if(I == module)
				var/obj/item/organ_module/M = I
				M.remove(src)
			else
				I.forceMove(drop_location())
		else
			I.forceMove(drop_location())
		if(owner)
			owner.update_implants()

	if(I in internal_organs)
		var/obj/item/organ/organ = I
		if(istype(organ))
			organ.removed(user)
			playsound(get_turf(src), 'sound/effects/squelch1.ogg', 50, 1)
		else
			I.forceMove(drop_location())

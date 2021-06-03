/datum/surgery_step/cut_open
	required_tool_quality = QUALITY_CUTTING

	duration = 100
	blood_level = 1
	can_infect = TRUE
	var/incision_name = "an incision"

/datum/surgery_step/cut_open/can_use(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	return BP_IS_ORGANIC(organ) && !organ.open

/datum/surgery_step/cut_open/begin_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("[user] starts [incision_name] on [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You start [incision_name] on [organ.get_surgery_name()] with \the [tool].")
	)

	if(required_tool_quality == QUALITY_LASER_CUTTING)
		organ.owner_custom_pain("You feel a horrible, searing pain in your [organ.name]!", 1)
	else
		organ.owner_custom_pain("You feel a horrible pain as if from a sharp knife in your [organ.name]!", 1)

/datum/surgery_step/cut_open/end_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("[user] has made [incision_name] on [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You have made [incision_name] on [organ.get_surgery_name()] with \the [tool].")
	)

	organ.open = 1

	organ.setBleeding()
	organ.take_damage(1, 0, sharp=TRUE, edge=TRUE)

	if(required_tool_quality == QUALITY_LASER_CUTTING)
		organ.clamp_wounds()
	else
		playsound(organ.get_surgery_target(), 'sound/weapons/bladeslice.ogg', 50, 1)

/datum/surgery_step/cut_open/fail_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	user.visible_message(
		SPAN_WARNING("[user]'s hand slips, slicing open [organ.get_surgery_name()] in the wrong place with \the [tool]!"),
		SPAN_WARNING("Your hand slips, slicing open [organ.get_surgery_name()] in the wrong place with \the [tool]!")
	)
	organ.take_damage(10, 0, sharp=TRUE, edge=TRUE)


/datum/surgery_step/cut_open/laser
	required_tool_quality = QUALITY_LASER_CUTTING
	blood_level = 0
	can_infect = FALSE
	incision_name = "a clean incision"



/datum/surgery_step/retract_skin
	required_tool_quality = QUALITY_RETRACTING
	duration = 80
	blood_level = 1
	can_infect = TRUE

/datum/surgery_step/retract_skin/can_use(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	return BP_IS_ORGANIC(organ) && organ.open == 1

/datum/surgery_step/retract_skin/begin_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("[user] starts to pry open the incision on [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You start to pry open the incision on [organ.get_surgery_name()] with \the [tool].")
	)
	organ.owner_custom_pain("It feels like the skin on your [organ.name] is on fire!", 1)

/datum/surgery_step/retract_skin/end_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("[user] keeps the incision open on [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You keep the incision open on [organ.get_surgery_name()] with \the [tool].")
	)
	organ.open = 2
	organ.nano_ui_interact(user)

/datum/surgery_step/retract_skin/fail_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	user.visible_message(
		SPAN_WARNING("[user]'s hand slips, tearing the edges of the incision on [organ.get_surgery_name()] with \the [tool]!"),
		SPAN_WARNING("Your hand slips, tearing the edges of the incision on [organ.get_surgery_name()] with \the [tool]!")
	)
	organ.take_damage(12, 0, sharp=TRUE)



/datum/surgery_step/cauterize
	required_tool_quality = QUALITY_CAUTERIZING
	duration = 80

/datum/surgery_step/cauterize/can_use(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	return BP_IS_ORGANIC(organ) && organ.open

/datum/surgery_step/cauterize/begin_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("[user] begins to cauterize the incision on [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You begin to cauterize the incision on [organ.get_surgery_name()] with \the [tool].")
	)
	organ.owner_custom_pain("Your [organ.name] is being burned!", 1)

/datum/surgery_step/cauterize/end_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("[user] cauterizes the incision on [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You cauterize the incision on [organ.get_surgery_name()] with \the [tool].")
	)
	organ.open = 0
	organ.germ_level = 0
	organ.diagnosed = FALSE

/datum/surgery_step/cauterize/fail_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	user.visible_message(
		SPAN_WARNING("[user]'s hand slips, leaving a small burn on [organ.get_surgery_name()] with \the [tool]!"),
		SPAN_WARNING("Your hand slips, leaving a small burn on [organ.get_surgery_name()] with \the [tool]!")
	)
	organ.take_damage(0, 3)



/datum/surgery_step/attach_organ
	target_organ_type = /obj/item/organ/internal
	required_tool_quality = QUALITY_CAUTERIZING
	duration = 80
	blood_level = 1

/datum/surgery_step/attach_organ/can_use(mob/living/user, obj/item/organ/internal/organ, obj/item/stack/tool)
	return BP_IS_ORGANIC(organ) && organ.is_open() && (organ.status & ORGAN_CUT_AWAY)

/datum/surgery_step/attach_organ/begin_step(mob/living/user, obj/item/organ/internal/organ, obj/item/stack/tool)
	user.visible_message(
		SPAN_NOTICE("[user] starts to reattach [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You start to reattach [organ.get_surgery_name()] with \the [tool].")
	)

	var/obj/item/organ/external/limb = organ.get_limb()
	if(limb)
		organ.owner_custom_pain("Someone's digging needles into your [limb.name]!", 1)

/datum/surgery_step/attach_organ/end_step(mob/living/user, obj/item/organ/internal/organ, obj/item/stack/tool)
	user.visible_message(
		SPAN_NOTICE("[user] reattaches [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You reattach [organ.get_surgery_name()] with \the [tool].")
	)
	organ.status &= ~ORGAN_CUT_AWAY

/datum/surgery_step/attach_organ/fail_step(mob/living/user, obj/item/organ/internal/organ, obj/item/stack/tool)
	user.visible_message(
		SPAN_WARNING("[user]'s hand slips, damaging [organ.get_surgery_name()] with \the [tool]!"),
		SPAN_WARNING("Your hand slips, damaging [organ.get_surgery_name()] with \the [tool]!")
	)
	organ.take_damage(5, 0)



/datum/surgery_step/detach_organ
	target_organ_type = /obj/item/organ/internal
	required_tool_quality = QUALITY_CUTTING
	duration = 80
	blood_level = 1

/datum/surgery_step/detach_organ/can_use(mob/living/user, obj/item/organ/internal/organ, obj/item/stack/tool)
	return BP_IS_ORGANIC(organ) && organ.is_open() && !(organ.status & ORGAN_CUT_AWAY)

/datum/surgery_step/detach_organ/begin_step(mob/living/user, obj/item/organ/internal/organ, obj/item/stack/tool)
	user.visible_message(
		SPAN_NOTICE("[user] starts to separate [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You start to separate [organ.get_surgery_name()] with \the [tool].")
	)

	var/obj/item/organ/external/limb = organ.get_limb()
	if(limb)
		organ.owner_custom_pain("The pain in your [limb.name] is living hell!", 1)

/datum/surgery_step/detach_organ/end_step(mob/living/user, obj/item/organ/internal/organ, obj/item/stack/tool)
	user.visible_message(
		SPAN_NOTICE("[user] separates [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You separate [organ.get_surgery_name()] with \the [tool].")
	)
	organ.status |= ORGAN_CUT_AWAY

/datum/surgery_step/detach_organ/fail_step(mob/living/user, obj/item/organ/internal/organ, obj/item/stack/tool)
	user.visible_message(
		SPAN_WARNING("[user]'s hand slips, damaging [organ.get_surgery_name()] with \the [tool]!"),
		SPAN_WARNING("Your hand slips, damaging [organ.get_surgery_name()] with \the [tool]!")
	)
	organ.take_damage(5, 0)

/datum/surgery_step/break_bone
	target_organ_type = /obj/item/organ/internal/bone
	required_tool_quality = QUALITY_HAMMERING
	duration = 80
	blood_level = 1

/datum/surgery_step/break_bone/can_use(mob/living/user, obj/item/organ/internal/organ, obj/item/stack/tool)
	return BP_IS_ORGANIC(organ) && organ.is_open() && !(organ.parent.status & ORGAN_BROKEN)


/datum/surgery_step/break_bone/begin_step(mob/living/user, obj/item/organ/internal/bone/organ, obj/item/stack/tool)
	user.visible_message(
		SPAN_NOTICE("[user] starts breaking [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You start breaking [organ.get_surgery_name()] with \the [tool].")
	)

	organ.owner_custom_pain("The pain in your [organ.name] is living hell!", 1)

/datum/surgery_step/break_bone/end_step(mob/living/user, obj/item/organ/internal/bone/organ, obj/item/stack/tool)
	user.visible_message(
		SPAN_NOTICE("[user] breaks [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You break [organ.get_surgery_name()] with \the [tool].")
	)
	organ.fracture()

/datum/surgery_step/break_bone/fail_step(mob/living/user, obj/item/organ/internal/organ, obj/item/stack/tool)
	user.visible_message(
		SPAN_WARNING("[user]'s hand slips, scraping [organ.get_surgery_name()] with \the [tool]!"),
		SPAN_WARNING("Your hand slips, scraping [organ.get_surgery_name()] with \the [tool]!")
	)
	organ.take_damage(5, 0)

/datum/surgery_step/mend_bone
	target_organ_type = /obj/item/organ/internal/bone
	required_tool_quality = QUALITY_BONE_SETTING
	duration = 100
	blood_level = 1

/datum/surgery_step/mend_bone/can_use(mob/living/user, obj/item/organ/internal/organ, obj/item/stack/tool)
	. = BP_IS_ORGANIC(organ) && organ.is_open() && (organ.parent.status & ORGAN_BROKEN)

	// Otherwise, it will just immediately fracture again
	if(. && organ.parent.should_fracture())
		to_chat(user, SPAN_WARNING("[organ.parent.get_surgery_name()] is too damaged!"))
		return FALSE

	return .


/datum/surgery_step/mend_bone/begin_step(mob/living/user, obj/item/organ/internal/bone/organ, obj/item/stack/tool)
	user.visible_message(
		SPAN_NOTICE("[user] starts mending [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You start mending [organ.get_surgery_name()] with \the [tool].")
	)

	organ.owner_custom_pain("The pain in your [organ.name] is living hell!", 1)

/datum/surgery_step/mend_bone/end_step(mob/living/user, obj/item/organ/internal/bone/organ, obj/item/stack/tool)
	user.visible_message(
		SPAN_NOTICE("[user] mends [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You mend [organ.get_surgery_name()] with \the [tool].")
	)
	organ.mend()

/datum/surgery_step/mend_bone/fail_step(mob/living/user, obj/item/organ/internal/organ, obj/item/stack/tool)
	user.visible_message(
		SPAN_WARNING("[user]'s hand slips, scraping [organ.get_surgery_name()] with \the [tool]!"),
		SPAN_WARNING("Your hand slips, scraping [organ.get_surgery_name()] with \the [tool]!")
	)
	organ.take_damage(5, 0)

/datum/surgery_step/replace_bone
	target_organ_type = /obj/item/organ/internal/bone
	allowed_tools = list(/obj/item/organ/internal/bone = 75) //Bone replacement surgery is hard
	duration = 120
	blood_level = 1

/datum/surgery_step/replace_bone/can_use(mob/living/user, obj/item/organ/internal/organ, obj/item/stack/tool)
	var/obj/item/organ/internal/bone/B = tool
	return BP_IS_ORGANIC(organ) && organ.is_open() && istype(B) && B.organ_tag == organ.organ_tag


/datum/surgery_step/replace_bone/begin_step(mob/living/user, obj/item/organ/internal/bone/organ, obj/item/stack/tool)
	user.visible_message(
		SPAN_NOTICE("[user] starts replacing [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You start replacing [organ.get_surgery_name()] with \the [tool].")
	)

	organ.owner_custom_pain("The pain in your [organ.name] is living hell!", 1)

/datum/surgery_step/replace_bone/end_step(mob/living/user, obj/item/organ/internal/bone/organ, obj/item/stack/tool)
	user.visible_message(
		SPAN_NOTICE("[user] replaces [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You replace [organ.get_surgery_name()] with \the [tool].")
	)
	if(istype(tool, /obj/item/organ/internal/bone))
		var/obj/item/organ/external/bone_parent = organ.parent
		if(bone_parent)
			organ.removed()
			bone_parent.add_item(tool, user, FALSE)
			bone_parent.handle_bones()

/datum/surgery_step/replace_bone/fail_step(mob/living/user, obj/item/organ/internal/bone/organ, obj/item/stack/tool)
	user.visible_message(
		SPAN_WARNING("[user]'s hand slips, breaking [organ.get_surgery_name()]!"),
		SPAN_WARNING("Your hand slips, breaking [organ.get_surgery_name()]!")
	)
	organ.fracture()

/datum/surgery_step/reinforce_bone
	target_organ_type = /obj/item/organ/internal/bone
	allowed_tools = list(/obj/item/bone_brace = 50) //Bone reinforcement surgery is very hard
	duration = 130
	blood_level = 1

/datum/surgery_step/reinforce_bone/can_use(mob/living/user, obj/item/organ/internal/organ, obj/item/stack/tool)
	return BP_IS_ORGANIC(organ) && organ.is_open() && (organ.parent.status & ORGAN_BROKEN)

/datum/surgery_step/reinforce_bone/begin_step(mob/living/user, obj/item/organ/internal/bone/organ, obj/item/stack/tool)
	user.visible_message(
		SPAN_NOTICE("[user] starts reinforcing [organ.get_surgery_name()]"),
		SPAN_NOTICE("You start reinforcing [organ.get_surgery_name()]")
	)

	organ.owner_custom_pain("You feel metal plates tearing through your [organ.get_surgery_name()]", 1)

/datum/surgery_step/reinforce_bone/end_step(mob/living/user, obj/item/organ/internal/bone/organ, obj/item/stack/tool)
	user.visible_message(
		SPAN_NOTICE("[user] reinforces [organ.get_surgery_name()]."),
		SPAN_NOTICE("You reinforce [organ.get_surgery_name()].")
	)
	qdel(tool)
	organ.reinforce()

/datum/surgery_step/reinforce_bone/fail_step(mob/living/user, obj/item/organ/internal/bone/organ, obj/item/stack/tool)
	user.visible_message(
		SPAN_WARNING("[user]'s hand slips, scraping [organ.get_surgery_name()] with \the [tool]!"),
		SPAN_WARNING("Your hand slips, scraping [organ.get_surgery_name()] with \the [tool]!")
	)
	organ.take_damage(5, 0)

/datum/surgery_step/remove_item
	required_tool_quality = QUALITY_CLAMPING
	duration = 90

/datum/surgery_step/remove_item/can_use(mob/living/user, obj/item/organ/external/organ, obj/item/tool, atom/movable/target)
	return BP_IS_ORGANIC(organ) && organ.is_open() && organ.can_remove_item(target)

/datum/surgery_step/remove_item/begin_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool, atom/movable/target)
	user.visible_message(
		SPAN_NOTICE("[user] begins to extract something out of [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You begin to extract [target] out of [organ.get_surgery_name()] with \the [tool].")
	)
	organ.owner_custom_pain("The pain in your [organ.name] is living hell!", 1)

/datum/surgery_step/remove_item/end_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool, atom/movable/target)
	user.visible_message(
		SPAN_NOTICE("[user] extracts something out of [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You extract [target] out of [organ.get_surgery_name()] with \the [tool].")
	)
	organ.remove_item(target, user)

/datum/surgery_step/remove_item/fail_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool, atom/movable/target)
	user.visible_message(
		SPAN_WARNING("[user] scrapes something inside [organ.get_surgery_name()] with \the [tool]!"),
		SPAN_WARNING("You scrape something inside [organ.get_surgery_name()] with \the [tool]!")
	)
	if(istype(target, /obj/item/weapon/implant) && prob(25))
		var/obj/item/weapon/implant/imp = target
		imp.malfunction(1)



/datum/surgery_step/amputate
	required_tool_quality = QUALITY_SAWING

	duration = 160
	blood_level = 2

/datum/surgery_step/amputate/can_use(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	return BP_IS_ORGANIC(organ) && organ.owner && !organ.cannot_amputate

/datum/surgery_step/amputate/begin_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("[user] is beginning to amputate [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You are beginning to cut through [organ.owner]'s [organ.amputation_point] with \the [tool].")
	)
	organ.owner_custom_pain("Your [organ.amputation_point] is being ripped apart!", 1)

/datum/surgery_step/amputate/end_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("[user] amputates [organ.get_surgery_name()] at the [organ.amputation_point] with \the [tool]."),
		SPAN_NOTICE("You amputate [organ.get_surgery_name()] with \the [tool].")
	)
	organ.droplimb(TRUE, DROPLIMB_EDGE)

/datum/surgery_step/amputate/fail_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	user.visible_message(
		SPAN_WARNING("[user]'s hand slips, sawing through the bone in [organ.get_surgery_name()] with \the [tool]!"),
		SPAN_WARNING("Your hand slips, sawing through the bone in [organ.get_surgery_name()] with \the [tool]!")
	)
	organ.take_damage(30, 0, sharp=TRUE, edge=TRUE)
	organ.fracture()


//removing shrapnel from yourself, using a knife
/datum/surgery_step/remove_shrapnel
	required_tool_quality = QUALITY_CUTTING

	duration = 8 SECONDS
	blood_level = 1

/datum/surgery_step/remove_shrapnel/can_use(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	return organ.owner && !organ.open && (locate(/obj/item/weapon/material/shard/shrapnel) in organ.implants)

/datum/surgery_step/remove_shrapnel/begin_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("[user] is beginning to attempt to remove shrapnel from [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You are beginning to remove shrapnel from [organ.get_surgery_name()] with \the [tool].")
	)
	organ.owner_custom_pain("Your [organ.name] is being torn apart!", 1)

/datum/surgery_step/remove_shrapnel/end_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("[user] removes shrapnel from [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You remove shrapnel from [organ.get_surgery_name()] with \the [tool].")
	)
	var/obj/item/shrapnel = locate(/obj/item/weapon/material/shard/shrapnel) in organ.implants
	organ.remove_item(shrapnel, user, FALSE)
	organ.take_damage(max(tool.force/5, tool.force/(user.stats.getStat(STAT_BIO)/STAT_LEVEL_BASIC)), 0, sharp=TRUE, edge=TRUE) //So it's a bad idea to remove shrapnel with a chainsaw

/datum/surgery_step/remove_shrapnel/fail_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	user.visible_message(
		SPAN_WARNING("[user]'s hand slips, catching inside [organ.get_surgery_name()] with \the [tool]!"),
		SPAN_WARNING("Your hand slips, sawing through the flesh in [organ.get_surgery_name()] with \the [tool]!")
	)
	organ.take_damage(tool.force*1.5, 0, sharp=TRUE, edge=TRUE)

//Cauterizing a wound to stop bleeding
/datum/surgery_step/close_wounds
	required_tool_quality = QUALITY_CAUTERIZING

	duration = 4 SECONDS
	blood_level = 0

/datum/surgery_step/close_wounds/can_use(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	return organ.owner && !organ.open && organ.status & ORGAN_BLEEDING

/datum/surgery_step/close_wounds/begin_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("[user] is beginning to close the wounds on [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You are beginning to close the wounds on [organ.get_surgery_name()] with \the [tool].")
	)
	organ.owner_custom_pain("It burns!", 1)

/datum/surgery_step/close_wounds/end_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("[user] closes the wounds on [organ.get_surgery_name()] with \the [tool]."),
		SPAN_NOTICE("You close the wounds on [organ.get_surgery_name()] with \the [tool].")
	)
	organ.stopBleeding()
	organ.take_damage(0, max(tool.force/5, tool.force/(user.stats.getStat(STAT_BIO)/STAT_LEVEL_BASIC))) //So it's a bad idea to remove shrapnel with a chainsaw

/datum/surgery_step/close_wounds/fail_step(mob/living/user, obj/item/organ/external/organ, obj/item/tool)
	user.visible_message(
		SPAN_WARNING("[user]'s hand slips, burning across [organ.get_surgery_name()] with \the [tool]!"),
		SPAN_WARNING("Your hand slips, char-grilling the flesh in [organ.get_surgery_name()] with \the [tool]!")
	)
	organ.take_damage(0, tool.force*1.5)


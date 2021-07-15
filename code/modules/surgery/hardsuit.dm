//Procedures in this file: hardsuit removal

/datum/old_surgery_step/hardsuit
	required_tool_quality = QUALITY_WELDING
	required_stat = STAT_MEC

	can_infect = 0
	blood_level = 0

	duration = 160

/datum/old_surgery_step/hardsuit/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!istype(target))
		return 0
	return (target_zone == BP_CHEST) && istype(target.back, /obj/item/rig) && !(target.back.canremove)

/datum/old_surgery_step/hardsuit/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(
		SPAN_NOTICE("[user] starts cutting through the support systems of [target]'s [target.back] with \the [tool]."),
		SPAN_NOTICE("You start cutting through the support systems of [target]'s [target.back] with \the [tool].")
	)
	..()

/datum/old_surgery_step/hardsuit/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/rig/rig = target.back
	if(!istype(rig))
		return
	rig.reset()
	user.visible_message(
		SPAN_NOTICE("[user] has cut through the support systems of [target]'s [rig] with \the [tool]."),
		SPAN_NOTICE("You have cut through the support systems of [target]'s [rig] with \the [tool].")
	)

/datum/old_surgery_step/hardsuit/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(
		SPAN_WARNING("[user]'s [tool] can't quite seem to get through the metal..."),
		SPAN_WARNING("Your [tool] can't quite seem to get through the metal. It's weakening, though - try again.")
	)
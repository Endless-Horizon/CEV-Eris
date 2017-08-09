/datum/objective/harm
	var/already_completed = FALSE

/datum/objective/harm/get_panel_entry()
	var/target = src.target ? "[src.target.current.real_name], the [src.target.assigned_role]" : "no_target"
	return "Make an example of <a href='?src=\ref[src];switch_target=1'>[target]</a>."

/datum/objective/harm/update_exploration()
	if(target && target.current)
		explanation_text = "Make an example of [target.current.real_name], the [target.assigned_role]. Break one of their bones, detach one of their limbs or disfigure their face. Make sure they're alive when you do it."
	else
		explanation_text = "Target has not arrived today. Did he know that I would come?"

/datum/objective/harm/check_completion()
	if(already_completed)
		return TRUE

	if(target && target.current && ishuman(target.current))
		if(target.current.stat == DEAD)
			return FALSE

		var/mob/living/carbon/human/H = target.current
		for(var/obj/item/organ/external/E in H.organs)
			if(E.status & ORGAN_BROKEN)
				return TRUE

		for(var/limb_tag in H.species.has_limbs) //todo check prefs for robotic limbs and amputations.
			var/list/organ_data = H.species.has_limbs[limb_tag]
			var/limb_type = organ_data["path"]
			var/found
			for(var/obj/item/organ/external/E in H.organs)
				if(limb_type == E.type)
					found = TRUE
					break
			if(!found)
				return TRUE

		var/obj/item/organ/external/head/head = H.get_organ("head")
		if(head.disfigured)
			return TRUE
	return FALSE

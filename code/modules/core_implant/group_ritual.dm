/datum/ritual/group
	name = "group ritual"
	desc = ""
	phrase = null
	power = 0
	category = "Group"

	cooldown = TRUE
	cooldown_time = 1 SECONDS
	cooldown_category = "group"
	var/list/phrases = list()
	var/effect_type

/datum/ritual/group/pre_check(mob/living/carbon/human/H, obj/item/implant/core_implant/C, targets)
	if(is_on_cooldown(H))
		return FALSE
	return ..()

/datum/ritual/group/proc/step_check(mob/living/carbon/human/H)
	return TRUE

/datum/ritual/group/perform(mob/living/carbon/human/H, obj/item/implant/core_implant/C, targets)
	if(!effect_type)
		return FALSE

	var/datum/core_module/group_ritual/GR = new
	GR.ritual = src
	GR.implant_type = C.implant_type
	GR.phrases = phrases
	GR.effect = new effect_type
	GR.effect.succ_message = success_message
	GR.effect.fail_message = fail_message

	if(C.add_module(GR))
		return TRUE
	else
		qdel(GR.effect)
		qdel(GR)
		return FALSE

/datum/ritual/group/proc/get_group_say_phrase(var/ind)
	return phrases[ind]

//returns phrase to display in bible
/datum/ritual/group/proc/get_group_display_phrase(var/ind)
	return phrases[ind]

/datum/ritual/group/get_say_phrase()
	return ""

//returns phrase to display in bible
/datum/ritual/group/get_display_phrase()
	return ""

/////////////////////////////////

/datum/core_module/group_ritual
	implant_type = /obj/item/implant/core_implant
	var/list/participants = list()
	var/list/correct_participants = list()
	var/list/phrases = list()
	var/first = TRUE

	var/datum/ritual/group/ritual
	var/datum/group_ritual_effect/effect = null

/datum/core_module/group_ritual/set_up()
	first = TRUE

/datum/core_module/group_ritual/can_install()
	if(!effect)
		return FALSE

	return TRUE

/datum/core_module/group_ritual/uninstall()
	if(!effect)
		return


/datum/core_module/group_ritual/proc/hear(var/mob/user, var/phrase)
	if(!(locate(implant_type) in user))
		return

	if(user == implant.wearer)
		if(phrases.len > 2)
			if(phrase == phrases[2] && ritual.step_check(user))
				next_phrase()
			else
				effect.trigger_fail(implant.wearer,participants)
				implant.remove_module(src)
		else
			if(phrase == phrases[2] && ritual.step_check(user) && participants.len)	//It's a group ritual, isn't it?
				effect.trigger_success(implant.wearer,participants)
				implant.remove_module(src)
			else
				effect.trigger_fail(implant.wearer,participants)
				implant.remove_module(src)

	else
		if(first || (user in participants))
			if(phrase == phrases[1] && !(user in correct_participants) && ritual.step_check(user))
				correct_participants.Add(user)
			else
				participants.Remove(user)


/datum/core_module/group_ritual/proc/next_phrase()
	phrases = phrases.Copy(2)
	first = FALSE
	participants = correct_participants
	correct_participants = list()
	to_chat(implant.wearer, SPAN_NOTICE("There is [participants.len] followers continuing the ritual."))


////////////////////////

/datum/group_ritual_effect
	var/succ_message = ""
	var/fail_message = ""

	var/starter_succ_message = null
	var/starter_fail_message = null

/datum/group_ritual_effect/proc/trigger_success(var/mob/starter, var/list/participants)
	if(!starter_succ_message)
		starter_succ_message = succ_message

	to_chat(starter, starter_succ_message)
	success(starter, participants.len)
	SEND_SIGNAL(starter, COMSIG_GROUP_RITUAL)

	for(var/mob/affected in participants)
		to_chat(affected, succ_message)
		success(affected, participants.len)
		SEND_SIGNAL(affected, COMSIG_GROUP_RITUAL)
	GLOB.grup_ritual_performed++

/datum/group_ritual_effect/proc/success(var/mob/affected, var/part_len)
	return

/datum/group_ritual_effect/proc/trigger_fail(var/mob/starter, var/list/participants)
	if(!starter_fail_message)
		starter_fail_message = fail_message

	to_chat(starter, starter_fail_message)
	fail(starter, participants.len)

	for(var/mob/affected in participants)
		to_chat(affected, fail_message)
		fail(affected, participants.len)

/datum/group_ritual_effect/proc/fail(var/mob/affected, var/part_len)
	return

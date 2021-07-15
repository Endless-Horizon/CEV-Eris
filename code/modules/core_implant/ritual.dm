/mob/living/carbon/human/var/list/personal_ritual_cooldowns = list()


/datum/ritual
	var/name = "ritual"
	var/desc = "Basic ritual that does nothing."
	var/phrase = ""
	var/power = 0
	var/chance = 100
	var/success_message = "Ritual successful."
	var/fail_message = "Ritual failed."
	var/implant_type = /obj/item/implant/core_implant
	var/category = "???"

	var/cooldown = FALSE
	var/cooldown_time = 0
	var/cooldown_category = ""
	var/effect_time = 0

	var/ignore_stuttering = FALSE

//code of ritual, returns true on success, can be interrupted with fail(H, C, targets) and return FALSE
/datum/ritual/proc/perform(mob/living/carbon/human/H, obj/item/implant/core_implant/C, targets)
	return TRUE

//ritual will be proceed only if this returns true
/datum/ritual/proc/pre_check(mob/living/carbon/human/H, obj/item/implant/core_implant/C, targets)
	if(cooldown && is_on_cooldown(H))
		fail("Litanies of this type can't be spoken too often.", H, C)
		return FALSE
	return TRUE

//code of ritual fail, called by fail(H,C,targets)		'on_chance' will be true, if ritual failed on chance check
/datum/ritual/proc/failed(mob/living/carbon/human/H, obj/item/implant/core_implant/C, targets, on_chance = FALSE)
	return

/datum/ritual/proc/activate(mob/living/carbon/human/H, obj/item/implant/core_implant/C, var/list/targets, var/force = FALSE)
	if(!pre_check(H,C,targets))
		return
	if(!force && !check_success(C))
		to_chat(H, SPAN_DANGER("[fail_message]"))
		failed(H, C, targets, TRUE)
	else
		if(perform(H, C, targets))
			C.use_power(src.power)
			to_chat(H, SPAN_NOTICE("[success_message]"))

/datum/ritual/proc/fail(var/message, mob/living/carbon/human/H, obj/item/implant/core_implant/C, targets)
	if(!message)
		message = fail_message
	to_chat(H, SPAN_DANGER("[message]"))
	failed(H, C, targets)

/datum/ritual/proc/check_success(obj/item/implant/core_implant/C)
	return prob(chance * C.success_modifier)

/datum/ritual/proc/is_allowed(obj/item/implant/core_implant/C)
	return TRUE

//returns phrase to say, may require to specify target
/datum/ritual/proc/get_say_phrase()
	return phrase

//returns phrase to display in bible
/datum/ritual/proc/get_display_phrase()
	return phrase

//returns true, if text is phrase of this ritual
/datum/ritual/proc/compare(var/text)
	return phrase && phrase != "" && text == phrase

//returns list of targets, specified in text
/datum/ritual/proc/get_targets(var/text)
	return list()


//COOLDOWN STUFF
//sets global cooldown for ritual's cooldown category
/datum/ritual/proc/set_global_cooldown()
	if(src.cooldown)
		GLOB.global_ritual_cooldowns[src.cooldown_category] = TRUE
		addtimer(CALLBACK(src, .proc/reset_global_cooldown), src.cooldown_time)
//resets personal cooldown for user if he's not nil or resets global cooldown, internal proc
/datum/ritual/proc/reset_global_cooldown()
	GLOB.global_ritual_cooldowns[src.cooldown_category] = FALSE

//sets personal cooldown for user of ritual's cooldown category
/datum/ritual/proc/set_personal_cooldown(mob/living/carbon/human/user)
	if(src.cooldown)
		user.personal_ritual_cooldowns[src.cooldown_category] = world.time + src.cooldown_time

//check's if ritual at personal or global cooldown
/datum/ritual/proc/is_on_cooldown(mob/living/carbon/human/user)
	if(GLOB.global_ritual_cooldowns[src.cooldown_category])
		return TRUE
	if(user.personal_ritual_cooldowns[src.cooldown_category] > world.time)
		return TRUE
	return FALSE

//HELPERS



//Getting mobs
/proc/get_grabbed_mob(var/mob/living/carbon/human/user)
	var/obj/item/grab/G = locate(/obj/item/grab) in user

	if (G && G.affecting && istype(G.affecting, /mob/living))
		return G.affecting
	return null

/proc/get_front_mob(var/mob/living/carbon/human/user)
	var/turf/T = get_step(user,user.dir)
	return (locate(/mob/living) in T)

/proc/get_victim(var/mob/living/carbon/human/user)
	var/mob/living/L = get_grabbed_mob(user)
	if (!L)
		L = get_front_mob(user)
	return L

/proc/get_front_human_in_range(var/mob/living/carbon/human/user, nrange = 1)
	var/turf/T = get_step(user,user.dir)
	for(var/i=1, i<=nrange, i++)
		var/mob/living/carbon/human/H = locate(/mob/living) in T
		if(H)
			return H
		T = get_step(T,user.dir)
	return

//Getting implants
/mob/living/proc/get_core_implant(ctype = null, req_activated = TRUE)
	RETURN_TYPE(/obj/item/implant/core_implant)
	for(var/obj/item/implant/core_implant/I in src)
		if(ctype && !istype(I, ctype))
			continue

		if(I.wearer != src)
			continue

		if(req_activated && !I.active)
			continue

		return I

	return null

/proc/get_implant_from_victim(mob/living/carbon/human/user, ctype = null, req_activated = TRUE)
	var/mob/living/L = get_victim(user)
	if(L)
		return L.get_core_implant(ctype, req_activated)


//Getting other objects
/proc/get_front(var/mob/living/carbon/human/user)
	var/turf/T = get_step(user,user.dir)
	return T.contents


/proc/pick_disciple_global(var/mob/user, var/allow_dead = TRUE)
	var/list/candidates = list()
	for (var/mob/living/L in disciples)
		if (QDELETED(L))
			continue
		if (!allow_dead && L.stat == DEAD)
			continue

		candidates += L

	return input(user, "Who do you wish to target?", "Select a disciple") as null|mob in candidates

/datum/ritual/cruciform/crusader
	name = "crusader"
	phrase = null
	desc = ""
	category = "Crusader"


/datum/ritual/cruciform/crusader/brotherhood
	name = "Eternal Brotherhood"
	phrase = "Ita multi unum corpus sumus in Christo singuli autem alter alterius membra."
	desc = "Reveals other disciples to speaker."


/datum/ritual/cruciform/crusader/brotherhood/perform(mob/living/carbon/human/user, obj/item/implant/core_implant/C)
	var/datum/core_module/cruciform/neotheologyhud/hud_module = C.get_module(/datum/core_module/cruciform/neotheologyhud)
	if(hud_module)
		C.remove_module(hud_module)
	else
		C.add_module(new /datum/core_module/cruciform/neotheologyhud)
	return TRUE


/datum/ritual/cruciform/crusader/battle_call
	name = "Call to Battle"
	phrase = "Si exieritis ad bellum de terra vestra contra hostes qui dimicant adversum vos clangetis ululantibus tubis et erit recordatio vestri coram Domino Deo vestro ut eruamini de manibus inimicorum vestrorum."
	desc = "Inspires the prayer and gives him strength to protect the other disciples. True strength in unity."
	cooldown = TRUE
	cooldown_time = 10 MINUTES
	cooldown_category = "battle call"
	effect_time = 10 MINUTES

/datum/ritual/cruciform/crusader/battle_call/perform(mob/living/carbon/human/user, obj/item/implant/core_implant/C)
	var/count = 0
	for(var/mob/living/carbon/human/brother in view(user))
		if(brother.get_core_implant(/obj/item/implant/core_implant/cruciform))
			count += 2

	user.stats.changeStat(STAT_TGH, count)
	user.stats.changeStat(STAT_ROB, count)
	user.stats.changeStat(STAT_VIG, (count / 2))
	log_and_message_admins("performed a crusade litany")
	to_chat(user, SPAN_NOTICE("You feel an extraordinary burst of energy."))
	set_personal_cooldown(user)
	addtimer(CALLBACK(src, .proc/discard_effect, user, count), src.cooldown_time)
	return TRUE

/datum/ritual/cruciform/crusader/battle_call/proc/discard_effect(mob/living/carbon/human/user, amount)
	user.stats.changeStat(STAT_TGH, -amount)
	user.stats.changeStat(STAT_ROB, -amount)
	user.stats.changeStat(STAT_VIG, -amount / 2)

/datum/ritual/cruciform/crusader/flash
	name = "Searing Revelation"
	phrase = "Per fidem enim ambulamus et non per speciem."
	desc = "Knocks over everybody without cruciform in the view range. Psy-wave is too powerful, speaker can be knocked too."
	cooldown = TRUE
	cooldown_time = 2 MINUTES
	cooldown_category = "flash"

/datum/ritual/cruciform/crusader/flash/perform(mob/living/carbon/human/user, obj/item/implant/core_implant/C)
	if(prob(100 - user.stats.getStat(STAT_VIG)))
		user.Weaken(10)
		to_chat(user, SPAN_WARNING("The flux of psy-energy knocks over you!"))
	else
		to_chat(user, SPAN_NOTICE("The flux of psy-energy washed your mind, but you managed to keep focused!"))
	playsound(user.loc, 'sound/effects/cascade.ogg', 65, 1)
	log_and_message_admins("performed a searing revelation litany")
	for(var/mob/living/carbon/human/victim in view(user))
		if(!victim.get_core_implant(/obj/item/implant/core_implant/cruciform))
			if(prob(100 - victim.stats.getStat(STAT_VIG)))
				to_chat(victim, SPAN_WARNING("You feel that your knees bends!"))
				victim.Weaken(5)
			else
				to_chat(victim, SPAN_NOTICE("Your legs feel numb, but you managed to stay on your feet!"))
	set_personal_cooldown(user)
	return TRUE

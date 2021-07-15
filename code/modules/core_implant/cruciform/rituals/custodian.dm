/datum/ritual/cruciform/custodian
	name = "custodian"
	phrase = null
	desc = ""
	category = "Custodian"

/datum/ritual/cruciform/custodian/purging
	name = "Words of purging"
	phrase = "Purificati a peccatis et in remissionem peccatorum"
	desc = "Addictions are common afflictions among ship denizens. This littany helps those people by easing or removing their addictions."
	power = 5

/datum/ritual/cruciform/custodian/purging/perform(mob/living/carbon/human/user, obj/item/implant/core_implant/C)
	var/mob/living/carbon/human/T = get_front_human_in_range(user, 1)
	if(!T)
		fail("No target in front of you.", user, C)
		return FALSE

	if(T.metabolism_effects.addiction_list.len)
		for(var/addiction in T.metabolism_effects.addiction_list)
			var/datum/reagent/R = addiction
			if(!R)
				T.metabolism_effects.addiction_list.Remove(R)
				continue

			T.metabolism_effects.addiction_list[R] += 15  // increase addiction level by 15
			// target will go through the addiction stages and finally be free from the addiction once it reaches level 40
			// it's a bad moment to go through but after 2 or 3 littany the addiction will be gone
			// psychiatrist RP opportunity -> think about the sins that led you to this addiction

	to_chat(T, SPAN_NOTICE("You feel weird as you progress through your addictions."))
	to_chat(user, SPAN_NOTICE("You help [T.name] get rid of their addictions."))

	T.add_chemical_effect(CE_PAINKILLER, 15)  // painkiller effect to target

	return TRUE

/datum/ritual/cruciform/agrolyte
	name = "agrolyte"
	phrase = null
	desc = ""
	category = "Agrolyte"

/datum/ritual/cruciform/agrolyte/accelerated_growth
	name = "Accelerated growth"
	phrase = "Plantae crescere in divinum lumen tua"
	desc = "This litany boosts the growth of all plants in sight for about ten minutes. "
	cooldown = TRUE
	cooldown_time = 5 MINUTES
	effect_time = 5 MINUTES
	cooldown_category = "accelerated_growth"
	power = 10

	var/boost_value = 1.5  // How much the aging process of the plant is sped up

/datum/ritual/cruciform/agrolyte/accelerated_growth/perform(mob/living/carbon/human/user, obj/item/implant/core_implant/C)

	var/list/plants_around = list()
	for(var/obj/machinery/portable_atmospherics/hydroponics/H in view(user))
		if(H.seed)  // if there is a plant in the hydroponics tray
			plants_around.Add(H.seed)

	if(plants_around.len > 0)
		to_chat(user, SPAN_NOTICE("You feel the air thrum with an inaudible vibration."))
		playsound(user.loc, 'sound/machines/signal.ogg', 50, 1)
		for(var/datum/seed/S in plants_around)
			give_boost(S)
		set_global_cooldown()
		return TRUE
	else
		fail("There is no plant around to hear your song.", user, C)
		return FALSE

/datum/ritual/cruciform/agrolyte/accelerated_growth/proc/give_boost(datum/seed/S)
	S.set_trait(TRAIT_BOOSTED_GROWTH, boost_value)
	addtimer(CALLBACK(src, .proc/take_boost, S), effect_time)

/datum/ritual/cruciform/agrolyte/accelerated_growth/proc/take_boost(datum/seed/S, stat, amount)
	// take_boost is automatically triggered by a callback function when the boost ends but the seed 
	// may have been deleted during the duration of the boost
	if(S) // check if seed still exist otherwise we cannot read null.stats
		S.set_trait(TRAIT_BOOSTED_GROWTH, 1)

/datum/ritual/cruciform/agrolyte/mercy
	name = "Hand of mercy"
	phrase = "Non est verus dolor"
	desc = "Relieves the pain of a person in front of you."
	power = 5

/datum/ritual/cruciform/agrolyte/mercy/perform(mob/living/carbon/human/user, obj/item/implant/core_implant/C)
	var/mob/living/carbon/human/T = get_front_human_in_range(user, 1)
	if(!T)
		fail("No target in front of you.", user, C)
		return FALSE

	to_chat(T, SPAN_NOTICE("You feel slightly better as your pain eases."))
	to_chat(user, SPAN_NOTICE("You ease the pain of [T.name]."))

	T.add_chemical_effect(CE_PAINKILLER, 15)  // painkiller effect to target

	return TRUE

/datum/ritual/cruciform/agrolyte/absolution
	name = "Absolution of wounds"
	phrase = "Surge et ambula"
	desc = "Stabilizes the health of a person in front of you."
	power = 10

/datum/ritual/cruciform/agrolyte/absolution/perform(mob/living/carbon/human/user, obj/item/implant/core_implant/C,list/targets)
	var/mob/living/carbon/human/T = get_front_human_in_range(user, 1)
	if(!T)
		fail("No target in front of you.", user, C)
		return FALSE

	to_chat(T, SPAN_NOTICE("You feel a soothing sensation in your veins."))
	to_chat(user, SPAN_NOTICE("You stabilize [T.name]'s health."))

	var/datum/reagents/R = new /datum/reagents(20, null)
	R.add_reagent("holyinaprovaline", 10)
	R.add_reagent("holydexalin", 10)
	R.trans_to_mob(T, 20, CHEM_BLOOD)

	return TRUE

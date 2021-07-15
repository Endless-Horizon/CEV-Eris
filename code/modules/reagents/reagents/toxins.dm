/* Toxins, poisons, venoms */

/datum/reagent/toxin
	name = "toxin"
	id = "toxin"
	description = "A toxic chemical."
	taste_description = "bitterness"
	taste_mult = 1.2
	reagent_state = LIQUID
	color = "#CF3600"
	metabolism = REM * 0.05 // 0.01 by default. They last a while and slowly kill you.
	var/strength = 0.05 // How much damage it deals per unit
	var/sanityloss = 0
	reagent_type = "Toxin"

/datum/reagent/toxin/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	if(strength)
		var/multi = effect_multiplier
		if(issmall(M))  // Small bodymass, more effect from lower volume.
			multi *= 2
		M.adjustToxLoss(strength * multi)
		if(sanityloss && ishuman(M))
			var/mob/living/carbon/human/H = M
			H.sanity.onToxin(src, effect_multiplier)
	M.add_chemical_effect(CE_TOXIN, 1)

/datum/reagent/toxin/overdose(mob/living/carbon/M, alien)
	if(strength)
		M.adjustToxLoss(strength * issmall(M) ? 2 : 1)

/datum/reagent/toxin/plasticide
	name = "Plasticide"
	id = "plasticide"
	description = "Liquid plastic used in creating plastic sheets."
	taste_description = "plastic"
	reagent_state = LIQUID
	color = "#CF3600"
	strength = 0.6

/datum/reagent/toxin/oil
	name = "Oil"
	id = "oil"
	description = "Crude oil, commonly found on habitable planets."
	taste_description = "money"
	reagent_state = LIQUID
	color = "#0C0C0C"

/datum/reagent/toxin/amatoxin
	name = "Amatoxin"
	id = "amatoxin"
	description = "A powerful poison derived from certain species of mushroom."
	taste_description = "mushroom"
	reagent_state = LIQUID
	color = "#792300"
	strength = 0.1
	nerve_system_accumulations = 60
	addiction_chance = 20
	heating_point = 523
	heating_products = list("toxin")

/datum/reagent/toxin/carpotoxin
	name = "Carpotoxin"
	id = "carpotoxin"
	description = "A deadly neurotoxin produced by the dreaded space carp."
	taste_description = "fish"
	reagent_state = LIQUID
	color = "#003333"
	strength = 0.1
	overdose = REAGENTS_OVERDOSE/3
	addiction_chance = 10
	nerve_system_accumulations = 5
	heating_point = 523
	heating_products = list("toxin")
	reagent_type = "Toxin/Stimulator"

/datum/reagent/toxin/carpotoxin/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/liver/L = H.random_organ_by_process(OP_LIVER)
		if(istype(L))
			L.take_damage(strength * effect_multiplier, 0)
	M.stats.addTempStat(STAT_VIG, STAT_LEVEL_BASIC, STIM_TIME, "carpotoxin")

/datum/reagent/toxin/carpotoxin/withdrawal_act(mob/living/carbon/M)
	M.stats.addTempStat(STAT_VIG, -STAT_LEVEL_BASIC, STIM_TIME, "carpotoxin_w")
	M.stats.addTempStat(STAT_ROB, -STAT_LEVEL_BASIC, STIM_TIME, "carpotoxin_w")
	M.stats.addTempStat(STAT_TGH, -STAT_LEVEL_BASIC, STIM_TIME, "carpotoxin_w")

/datum/reagent/toxin/carpotoxin/overdose(mob/living/carbon/M, alien)
	if(prob(80))
		M.adjustBrainLoss(2)
	if(strength)
		if(issmall(M))
			M.adjustToxLoss(strength)
		else
			M.adjustToxLoss(strength)

///datum/reagent/toxin/blattedin is defined in blattedin.dm

/datum/reagent/toxin/plasma
	name = "Plasma"
	id = "plasma"
	description = "Plasma in its liquid form."
	taste_mult = 1.5
	reagent_state = LIQUID
	color = "#9D14DB"
	strength = 0.3
	touch_met = 5

/datum/reagent/toxin/plasma/touch_mob(mob/living/L, var/amount)
	if(istype(L))
		L.adjust_fire_stacks(amount / 5)

/datum/reagent/toxin/plasma/affect_touch(mob/living/carbon/M, alien, effect_multiplier)
	M.take_organ_damage(0, effect_multiplier * 0.1) //being splashed directly with plasma causes minor chemical burns
	if(prob(50))
		M.pl_effects()

/datum/reagent/toxin/plasma/touch_turf(turf/simulated/T)
	if(!istype(T))
		return
	T.assume_gas("plasma", volume, T20C)
	remove_self(volume)
	return TRUE

/datum/reagent/toxin/cyanide //Fast and Lethal
	name = "Cyanide"
	id = "cyanide"
	description = "A highly toxic chemical."
	taste_mult = 0.6
	reagent_state = LIQUID
	color = "#CF3600"
	strength = 0.2
	metabolism = REM * 2

/datum/reagent/toxin/cyanide/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	..()
	M.adjustOxyLoss(2 * effect_multiplier)
	M.AdjustSleeping(1)

/datum/reagent/toxin/potassium_chloride
	name = "Potassium Chloride"
	id = "potassium_chloride"
	description = "A delicious salt that stops the heart when injected into cardiac muscle."
	taste_description = "salt"
	reagent_state = SOLID
	color = "#FFFFFF"
	strength = 0
	overdose = REAGENTS_OVERDOSE

/datum/reagent/toxin/potassium_chloride/overdose(mob/living/carbon/M, alien)
	..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.stat != 1)
			if(H.losebreath >= 10)
				H.losebreath = max(10, H.losebreath - 10)
			H.adjustOxyLoss(2)
			H.Weaken(10)
		M.add_chemical_effect(CE_NOPULSE, 1)


/datum/reagent/toxin/potassium_chlorophoride
	name = "Potassium Chlorophoride"
	id = "potassium_chlorophoride"
	description = "A specific chemical based on Potassium Chloride to stop the heart for surgery."
	taste_description = "salt"
	reagent_state = SOLID
	color = "#FFFFFF"
	strength = 0.1
	overdose = 20

/datum/reagent/toxin/potassium_chlorophoride/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.stat != 1)
			if(H.losebreath >= 10)
				H.losebreath = max(10, M.losebreath-10)
			H.adjustOxyLoss(2)
			H.Weaken(10)
		M.add_chemical_effect(CE_NOPULSE, 1)

/datum/reagent/toxin/zombiepowder
	name = "Zombie Powder"
	id = "zombiepowder"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	taste_description = "death"
	reagent_state = SOLID
	color = "#669900"
	metabolism = REM
	strength = 0.04

/datum/reagent/toxin/zombiepowder/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	..()
	M.status_flags |= FAKEDEATH
	M.adjustOxyLoss(0.6 * effect_multiplier)
	M.Weaken(10)
	M.silent = max(M.silent, 10)
	M.timeofdeath = world.time
	M.add_chemical_effect(CE_NOPULSE, 1)

/datum/reagent/toxin/zombiepowder/Destroy()
	if(holder && holder.my_atom && ismob(holder.my_atom))
		var/mob/M = holder.my_atom
		M.status_flags &= ~FAKEDEATH
		M.timeofdeath = 0
	. = ..()

/datum/reagent/toxin/fertilizer //Reagents used for plant fertilizers.
	name = "fertilizer"
	id = "fertilizer"
	description = "A chemical mix good for growing plants with."
	taste_description = "plant food"
	taste_mult = 0.5
	reagent_state = LIQUID
	strength = 0.01 // It's not THAT poisonous.
	color = "#664330"

/datum/reagent/toxin/fertilizer/eznutrient
	name = "EZ Nutrient"
	id = "eznutrient"

/datum/reagent/toxin/fertilizer/left4zed
	name = "Left-4-Zed"
	id = "left4zed"

/datum/reagent/toxin/fertilizer/robustharvest
	name = "Robust Harvest"
	id = "robustharvest"

/datum/reagent/toxin/plantbgone
	name = "Plant-B-Gone"
	id = "plantbgone"
	description = "A harmful toxic mixture to kill plantlife."
	taste_mult = 1
	reagent_state = LIQUID
	color = "#49002E"
	strength = 0.04

/datum/reagent/toxin/plantbgone/touch_turf(turf/T)
	if(istype(T, /turf/simulated/wall))
		var/turf/simulated/wall/W = T
		if(locate(/obj/effect/overlay/wallrot) in W)
			for(var/obj/effect/overlay/wallrot/E in W)
				qdel(E)
			W.visible_message(SPAN_NOTICE("The fungi are completely dissolved by the solution!"))
	return TRUE

/datum/reagent/toxin/plantbgone/touch_obj(obj/O, var/volume)
	if(istype(O, /obj/effect/plant))
		qdel(O)
	if(istype(O, /obj/machinery/portable_atmospherics/hydroponics))
		var/obj/machinery/portable_atmospherics/hydroponics/T = O
		T.seed = null
		T.weedlevel = 0
		T.pestlevel = 0
		T.update_icon()
		return

/datum/reagent/acid/polyacid
	name = "Polytrinic acid"
	id = "pacid"
	description = "Polytrinic acid is a an extremely corrosive chemical substance."
	taste_description = "acid"
	reagent_state = LIQUID
	color = "#8E18A9"
	power = 10
	meltdose = 4


/datum/reagent/toxin/lexorin
	name = "Lexorin"
	id = "lexorin"
	description = "Lexorin temporarily stops respiration. Causes tissue damage."
	taste_description = "acid"
	reagent_state = LIQUID
	color = "#C8A5DC"
	overdose = REAGENTS_OVERDOSE

/datum/reagent/toxin/lexorin/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	M.take_organ_damage(0.3 * effect_multiplier, 0)
	if(M.losebreath < 15)
		M.losebreath++

/datum/reagent/toxin/mutagen
	name = "Unstable mutagen"
	id = "mutagen"
	description = "Might cause unpredictable mutations."
	taste_description = "slime"
	taste_mult = 0.9
	reagent_state = LIQUID
	color = "#13BC5E"

/datum/reagent/toxin/mutagen/affect_touch(mob/living/carbon/M, alien, effect_multiplier)
	if(prob(33))
		affect_blood(M, alien, effect_multiplier)

/datum/reagent/toxin/mutagen/affect_ingest(mob/living/carbon/M, alien, effect_multiplier)
	if(prob(67))
		affect_blood(M, alien, effect_multiplier)

/datum/reagent/toxin/mutagen/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.flags & NO_SCAN)
			return
	if(M.dna)
		if(prob(effect_multiplier * 0.01)) // Approx. one mutation per 10 injected/20 ingested/30 touching units
			randmuti(M)
			if(prob(98))
				randmutb(M)
			else
				randmutg(M)
			domutcheck(M, null)
			M.UpdateAppearance()
	M.apply_effect(1 * effect_multiplier, IRRADIATE, 0)

/datum/reagent/medicine/slimejelly
	name = "Slime Jelly"
	id = "slimejelly"
	description = "A gooey semi-liquid produced from one of the deadliest lifeforms in existence."
	taste_description = "slime"
	taste_mult = 1.3
	reagent_state = LIQUID
	color = "#801E28"

/datum/reagent/medicine/slimejelly/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	if(M.species.name == "Slime")
		M.heal_organ_damage(1 * effect_multiplier, 1 * effect_multiplier)
		return
	if(prob(10))
		to_chat(M, SPAN_DANGER("Your insides are burning!"))
		M.adjustToxLoss(rand(10, 30) * effect_multiplier)
	else if(prob(40))
		M.heal_organ_damage(2.5 * effect_multiplier, 0)

/datum/reagent/medicine/soporific
	name = "Soporific"
	id = "stoxin"
	description = "An effective hypnotic used to treat insomnia."
	taste_description = "bitterness"
	reagent_state = LIQUID
	color = "#009CA8"
	metabolism = REM * 5
	overdose = REAGENTS_OVERDOSE

/datum/reagent/medicine/soporific/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	var/effective_dose = dose
	if(issmall(M))
		effective_dose *= 2

	if(effective_dose < 1)
		if(effective_dose == metabolism * 2 || prob(5))
			M.emote("yawn")
	else if(effective_dose < 1.5)
		M.eye_blurry = max(M.eye_blurry, 10)
	else if(effective_dose < 5)
		if(prob(50))
			M.Weaken(2)
		M.drowsyness = max(M.drowsyness, 20)
	else
		M.sleeping = max(M.sleeping, 20)
		M.drowsyness = max(M.drowsyness, 60)
	M.add_chemical_effect(CE_PULSE, -1)

/datum/reagent/medicine/chloralhydrate
	name = "Chloral Hydrate"
	id = "chloralhydrate"
	description = "A powerful sedative."
	taste_description = "bitterness"
	reagent_state = SOLID
	color = "#000067"
	metabolism = REM * 5
	overdose = REAGENTS_OVERDOSE * 0.5

/datum/reagent/medicine/chloralhydrate/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	var/effective_dose = dose
	if(issmall(M))
		effective_dose *= 2

	if(effective_dose == metabolism)
		M.confused += 2
		M.drowsyness += 2
	else if(effective_dose < 2)
		M.Weaken(30)
		M.eye_blurry = max(M.eye_blurry, 10)
	else
		M.sleeping = max(M.sleeping, 30)

	if(effective_dose > 1)
		M.adjustToxLoss(effect_multiplier * 0.1)

/datum/reagent/medicine/chloralhydrate/beer2 //disguised as normal beer for use by emagged brobots
	name = "Beer"
	id = "beer2"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water. The fermentation appears to be incomplete." //If the players manage to analyze this, they deserve to know something is wrong.
	taste_description = "shitty piss water"
	reagent_state = LIQUID
	color = "#664300"

	glass_icon_state = "beerglass"
	glass_name = "beer"
	glass_desc = "A freezing pint of beer"
	glass_center_of_mass = list("x"=16, "y"=8)

/* Transformations */

/datum/reagent/toxin/slimetoxin
	name = "Mutation Toxin"
	id = "mutationtoxin"
	description = "A corruptive toxin produced by slimes."
	taste_description = "sludge"
	reagent_state = LIQUID
	color = "#13BC5E"

/datum/reagent/toxin/slimetoxin/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.name != "Slime")
			to_chat(M, SPAN_DANGER("Your flesh rapidly mutates!"))
			H.set_species("Slime")

/datum/reagent/toxin/aslimetoxin
	name = "Advanced Mutation Toxin"
	id = "amutationtoxin"
	description = "An advanced corruptive toxin produced by slimes."
	taste_description = "sludge"
	reagent_state = LIQUID
	color = "#13BC5E"

/datum/reagent/toxin/aslimetoxin/affect_blood(mob/living/carbon/M, alien, effect_multiplier) // TODO: check if there's similar code anywhere else
	if(HAS_TRANSFORMATION_MOVEMENT_HANDLER(M))
		return
	to_chat(M, SPAN_DANGER("Your flesh rapidly mutates!"))
	ADD_TRANSFORMATION_MOVEMENT_HANDLER(M)
	M.canmove = 0
	M.icon = null
	M.cut_overlays()
	M.invisibility = 101
	for(var/obj/item/W in M)
		if(istype(W, /obj/item/implant)) //TODO: Carn. give implants a dropped() or something
			qdel(W)
			continue
		W.layer = initial(W.layer)
		W.loc = M.loc
		W.dropped(M)
	var/mob/living/carbon/slime/new_mob = new /mob/living/carbon/slime(M.loc)
	new_mob.a_intent = "hurt"
	new_mob.universal_speak = 1
	if(M.mind)
		M.mind.transfer_to(new_mob)
	else
		new_mob.key = M.key
	qdel(M)

/datum/reagent/other/xenomicrobes
	name = "Xenomicrobes"
	id = "xenomicrobes"
	description = "Microbes with an entirely alien cellular structure."
	taste_description = "sludge"
	reagent_state = LIQUID
	color = "#535E66"

/datum/reagent/toxin/pararein
	name = "Pararein"
	id = "pararein"
	description = "Venom used by spiders."
	taste_description = "sludge"
	reagent_state = LIQUID
	color = "#a37d9c"
	metabolism = REM * 2
	overdose = REAGENTS_OVERDOSE/3
	nerve_system_accumulations = 5
	strength = 0.01
	sanityloss = 3
	heating_point = 523
	heating_products = list("toxin")

/datum/reagent/toxin/diplopterum
	name = "Diplopterum"
	id = "diplopterum"
	description = "Can be found in tissues of the roaches."
	taste_description = "sludge"
	reagent_state = LIQUID
	color = "#c9bed2"
	overdose = REAGENTS_OVERDOSE * 0.66
	strength = 0.1
	addiction_chance = 10
	nerve_system_accumulations = 5
	heating_point = 573
	heating_products = list("radium", "acetone", "hydrazine", "nutriment")
	reagent_type = "Toxin/Stimulator"

/datum/reagent/toxin/diplopterum/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	..()
	M.stats.addTempStat(STAT_MEC, STAT_LEVEL_BASIC, STIM_TIME, "diplopterum")

/datum/reagent/toxin/diplopterum/withdrawal_act(mob/living/carbon/M)
	M.stats.addTempStat(STAT_MEC, -STAT_LEVEL_BASIC, STIM_TIME, "diplopterum_w")
	M.stats.addTempStat(STAT_TGH, -STAT_LEVEL_BASIC, STIM_TIME, "diplopterum_w")

/datum/reagent/toxin/diplopterum/overdose(mob/living/carbon/M, alien)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/liver/L = H.random_organ_by_process(OP_LIVER)
		if(istype(L))
			L.take_damage(strength, 0)
	if(issmall(M))
		M.adjustToxLoss(strength * 2)
	else
		M.adjustToxLoss(strength)

/datum/reagent/toxin/seligitillin
	name = "Seligitillin"
	id = "seligitillin"
	description = "Promotes blood clotting. Harvested from Seuche roaches."
	taste_description = "plague"
	reagent_state = LIQUID
	color = "#6d33b4"
	overdose = REAGENTS_OVERDOSE/2
	addiction_chance = 10
	nerve_system_accumulations = 5
	heating_point = 573
	heating_products = list("radium", "ammonia", "sulfur", "nutriment")

/datum/reagent/toxin/seligitillin/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	M.add_chemical_effect(CE_BLOODCLOT, 0.2)
	M.heal_organ_damage(0.2 * effect_multiplier, 0, 3)
	var/mob/living/carbon/human/H = M
	for(var/obj/item/organ/external/E in H.organs)
		for(var/datum/wound/W in E.wounds)
			if(W.internal)
				W.heal_damage(1 * effect_multiplier)

/datum/reagent/toxin/seligitillin/withdrawal_act(mob/living/carbon/M)
	M.stats.addTempStat(STAT_TGH, -STAT_LEVEL_ADEPT, STIM_TIME, "seligitillin_w")

/datum/reagent/toxin/seligitillin/overdose(mob/living/carbon/M, alien)
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	var/obj/item/organ/internal/heart/S = H.random_organ_by_process(OP_HEART)
	if(istype(S))
		S.take_damage(2, 0)
	var/obj/item/organ/internal/liver/L = H.random_organ_by_process(OP_LIVER)
	if(istype(L))
		L.take_damage(3, 0)

/datum/reagent/toxin/starkellin
	name = "Starkellin"
	id = "starkellin"
	description = "Harvested from Panzer roaches."
	taste_description = "metal"
	reagent_state = LIQUID
	color = "#736bbe"
	overdose = REAGENTS_OVERDOSE/2
	addiction_chance = 15
	nerve_system_accumulations = 5
	heating_point = 573
	heating_products = list("radium", "aluminum", "tungsten", "nutriment")
	reagent_type = "Toxin/Stimulator"

/datum/reagent/toxin/starkellin/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	..()
	M.stats.addTempStat(STAT_TGH, STAT_LEVEL_BASIC, STIM_TIME, "starkellin")

/datum/reagent/toxin/starkellin/withdrawal_act(mob/living/carbon/M)
	M.stats.addTempStat(STAT_ROB, -STAT_LEVEL_BASIC, STIM_TIME, "starkellin_w")
	M.stats.addTempStat(STAT_TGH, -STAT_LEVEL_BASIC, STIM_TIME, "starkellin_w")

/datum/reagent/toxin/gewaltine
	name = "Gewaltine"
	id = "gewaltine"
	description = "Harvested from Jager roaches."
	taste_description = "raw meat"
	reagent_state = LIQUID
	color = "#9452ba"
	overdose = REAGENTS_OVERDOSE/2
	addiction_chance = 20
	nerve_system_accumulations = 5
	strength = 0.2
	heating_point = 573
	heating_products = list("radium", "mercury", "sugar", "nutriment")
	reagent_type = "Toxin/Stimulator"

/datum/reagent/toxin/gewaltine/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	..()
	M.stats.addTempStat(STAT_ROB, STAT_LEVEL_BASIC, STIM_TIME, "gewaltine")
	M.stats.addTempStat(STAT_TGH, -STAT_LEVEL_BASIC, STIM_TIME, "gewaltine")

/datum/reagent/toxin/gewaltine/withdrawal_act(mob/living/carbon/M)
	M.stats.addTempStat(STAT_ROB, -STAT_LEVEL_ADEPT, STIM_TIME, "gewaltine_w")
	M.stats.addTempStat(STAT_VIG, -STAT_LEVEL_BASIC, STIM_TIME, "gewaltine_w")

/datum/reagent/toxin/gewaltine/overdose(mob/living/carbon/M, alien)
	M.adjustCloneLoss(2)

/datum/reagent/toxin/fuhrerole
	name = "Fuhrerole"
	id = "fuhrerole"
	description = "Harvested from Fuhrer roaches."
	taste_description = "third reich"
	reagent_state = LIQUID
	color = "#a6b85b"
	overdose = 8
	addiction_chance = 30
	nerve_system_accumulations = 4
	heating_point = 573
	heating_products = list("radium", "mercury", "lithium", "nutriment")

/datum/reagent/toxin/fuhrerole/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	M.faction = "roach"

/datum/reagent/toxin/fuhrerole/on_mob_delete(mob/living/L)
	..()
	L.faction = initial(L.faction)

/datum/reagent/toxin/fuhrerole/withdrawal_act(mob/living/carbon/M)
	M.stats.addTempStat(STAT_ROB, -STAT_LEVEL_BASIC, STIM_TIME, "fuhrerole_w")
	M.stats.addTempStat(STAT_TGH, -STAT_LEVEL_BASIC, STIM_TIME, "fuhrerole_w")

/datum/reagent/toxin/fuhrerole/overdose(mob/living/carbon/M, alien)
	M.add_chemical_effect(CE_SPEECH_VOLUME, rand(3,4))
	M.adjustBrainLoss(0.5)

/datum/reagent/toxin/biomatter
	name = "Biomatter"
	id = "biomatter"
	description = "A goo of unknown to you origin. Its better to stay that way."
	taste_description = "vomit"
	reagent_state = LIQUID
	color = "#527f4f"
	strength = 0.3

/datum/reagent/toxin/biomatter/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	..()
	M.take_organ_damage(0, effect_multiplier * strength)

/datum/reagent/toxin/biomatter/affect_ingest(mob/living/carbon/M, alien, effect_multiplier)
	..()
	if(prob(10 - (5 * M.stats.getMult(STAT_TGH))))
		M.vomit()

/datum/reagent/toxin/biomatter/affect_touch(mob/living/carbon/M, alien, effect_multiplier)
	..()
	if(prob(5 - (4 * M.stats.getMult(STAT_TGH))))
		M.vomit()

/datum/reagent/toxin/biomatter/touch_turf(turf/T)
	if(volume >= 5)
		if(volume >= 45)
			spill_biomass(T, alldirs)
		else if(volume >= 25)
			spill_biomass(T, cardinal)
		else
			spill_biomass(T)
		remove_self(volume)
		return TRUE

/datum/reagent/toxin/chlorine
	name = "Chlorine"
	description = "A highly poisonous liquid. Smells strongly of bleach."
	reagent_state = LIQUID
	taste_description = "bleach"
	color = "#707c13"
	strength = 15

/datum/reagent/toxin/tar
	name = "Tar"
	description = "A dark, viscous liquid."
	taste_description = "petroleum"
	color = "#140b30"
	reagent_state = LIQUID
	strength = 4
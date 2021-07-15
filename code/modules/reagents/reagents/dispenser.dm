/datum/reagent/acetone
	name = "Acetone"
	id = "acetone"
	description = "A colorless liquid solvent used in chemical synthesis."
	taste_description = "acid"
	reagent_state = LIQUID
	color = "#808080"
	metabolism = REM * 0.2
	reagent_type = "General"

/datum/reagent/acetone/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	M.adjustToxLoss(effect_multiplier * 0.3)

/datum/reagent/acetone/touch_obj(obj/O)	//I copied this wholesale from ethanol and could likely be converted into a shared proc. ~Techhead
	if(istype(O, /obj/item/paper))
		var/obj/item/paper/paperaffected = O
		paperaffected.clearpaper()
		to_chat(usr, "The solution dissolves the ink on the paper.")
		return
	if(istype(O, /obj/item/book))
		if(volume < 5)
			return
		var/obj/item/book/affectedbook = O
		affectedbook.dat = null
		to_chat(usr, "<span class='notice'>The solution dissolves the ink on the book.</span>")
	return

/datum/reagent/metal
	reagent_type = "Metal"

/datum/reagent/metal/aluminum
	name = "Aluminum"
	id = "aluminum"
	taste_description = "metal"
	taste_mult = 1.1
	description = "A silvery white and ductile member of the boron group of chemical elements."
	reagent_state = SOLID
	color = "#A8A8A8"

/datum/reagent/toxin/ammonia
	name = "Ammonia"
	id = "ammonia"
	taste_description = "mordant"
	taste_mult = 2
	description = "A caustic substance commonly used in fertilizer or household cleaners."
	reagent_state = LIQUID
	color = "#404030"
	metabolism = REM * 0.5

/datum/reagent/toxin/ammonia/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	M.adjustToxLoss(effect_multiplier * 0.15)

/datum/reagent/carbon
	name = "Carbon"
	id = "carbon"
	description = "A chemical element, the builing block of life."
	taste_description = "sour chalk"
	taste_mult = 1.5
	reagent_state = SOLID
	color = "#1C1300"
	ingest_met = REM * 5
	reagent_type = "Reactive nonmetal"

/datum/reagent/carbon/affect_ingest(mob/living/carbon/M, alien, effect_multiplier)
	if(M.ingested && M.ingested.reagent_list.len > 1) // Need to have at least 2 reagents - cabon and something to remove
		var/effect = 1 / (M.ingested.reagent_list.len - 1)
		for(var/datum/reagent/R in M.ingested.reagent_list)
			if(R == src)
				continue
			M.ingested.remove_reagent(R.id, effect_multiplier * effect)

/datum/reagent/carbon/touch_turf(turf/T)
	if(!istype(T, /turf/space))
		var/obj/effect/decal/cleanable/dirt/dirtoverlay = locate(/obj/effect/decal/cleanable/dirt, T)
		if (!dirtoverlay)
			dirtoverlay = new/obj/effect/decal/cleanable/dirt(T)
			dirtoverlay.alpha = volume * 30
		else
			dirtoverlay.alpha = min(dirtoverlay.alpha + volume * 30, 255)
	return TRUE

/datum/reagent/metal/copper
	name = "Copper"
	id = "copper"
	description = "A highly ductile metal."
	taste_description = "copper"
	color = "#6E3B08"

/datum/reagent/ethanol
	name = "Ethanol" //Parent class for all alcoholic reagents.
	id = "ethanol"
	description = "A well-known alcohol with a variety of applications."
	taste_description = "pure alcohol"
	reagent_state = LIQUID
	color = "#404030"
	ingest_met = REM * 4
	touch_met = 5
	var/nutriment_factor = 0
	var/strength = 10 // This is, essentially, units between stages - the lower, the stronger. Less fine tuning, more clarity.
	var/strength_mod = 1
	var/toxicity = 1

	var/druggy = 0
	var/adj_temp = 0
	var/targ_temp = 310
	var/halluci = 0
	sanity_gain_ingest = 0.5 //this defines how good eating/drinking the thing will make you feel
	taste_tag = list()  // list the tastes the thing got there

	glass_icon_state = "glass_clear"
	glass_name = "ethanol"
	glass_desc = "A well-known alcohol with a variety of applications."
	reagent_type = "Alchohol"

/datum/reagent/ethanol/touch_mob(mob/living/L, amount)
	if(istype(L))
		L.adjust_fire_stacks(amount / 15)

/datum/reagent/ethanol/on_mob_add(mob/living/L)
	..()
	SEND_SIGNAL(L, COMSIG_CARBON_HAPPY, src, MOB_ADD_DRUG)

/datum/reagent/ethanol/on_mob_delete(mob/living/L)
	..()
	SEND_SIGNAL(L, COMSIG_CARBON_HAPPY, src, MOB_DELETE_DRUG)

/datum/reagent/ethanol/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	M.adjustToxLoss(0.2 * toxicity * (issmall(M) ? effect_multiplier * 2 : effect_multiplier))
	M.add_chemical_effect(CE_PAINKILLER, max(35 - (strength / 2), 1))	//Vodka 32.5 painkiller, beer 15

/datum/reagent/ethanol/affect_ingest(mob/living/carbon/M, alien, effect_multiplier)
	M.adjustNutrition(nutriment_factor * (issmall(M) ? effect_multiplier * 2 : effect_multiplier))
	M.add_chemical_effect(CE_ALCOHOL, 1)

//Tough people can drink a lot
	var/tolerance = max(10, strength + M.stats.getStat(STAT_TGH))

	if(M.stats.getPerk(/datum/perk/sommelier))
		tolerance *= 10

	if(dose * strength_mod >= tolerance) // Early warning
		M.make_dizzy(6) // It is decreased at the speed of 3 per tick

	if(dose * strength_mod >= tolerance * 2) // Slurring
		M.slurring = max(M.slurring, 30)

	if(dose * strength_mod >= tolerance * 3) // Confusion - walking in random directions
		M.confused = max(M.confused, 20)

	if(dose * strength_mod >= tolerance * 4) // Blurry vision
		M.eye_blurry = max(M.eye_blurry, 10)

	if(dose * strength_mod >= tolerance * 5) // Drowsyness - periodically falling asleep
		M.drowsyness = max(M.drowsyness, 20)

	if(dose * strength_mod >= tolerance * 7) // Pass out
		M.paralysis = max(M.paralysis, 20)
		M.sleeping  = max(M.sleeping, 30)

	if(dose * strength_mod >= tolerance * 9) // Toxic dose
		M.add_chemical_effect(CE_ALCOHOL_TOXIC, toxicity)


	if(druggy != 0)
		M.druggy = max(M.druggy, druggy)

	if(adj_temp > 0 && M.bodytemperature < targ_temp) // 310 is the normal bodytemp. 310.055
		M.bodytemperature = min(targ_temp, M.bodytemperature + (adj_temp * TEMPERATURE_DAMAGE_COEFFICIENT))
	if(adj_temp < 0 && M.bodytemperature > targ_temp)
		M.bodytemperature = min(targ_temp, M.bodytemperature - (adj_temp * TEMPERATURE_DAMAGE_COEFFICIENT))

	if(halluci)
		M.adjust_hallucination(halluci, halluci)

	apply_sanity_effect(M, effect_multiplier)
	SEND_SIGNAL(M, COMSIG_CARBON_HAPPY, src, ON_MOB_DRUG)

/datum/reagent/ethanol/touch_obj(obj/O)
	if(istype(O, /obj/item/paper))
		var/obj/item/paper/paperaffected = O
		paperaffected.clearpaper()
		to_chat(usr, "The solution dissolves the ink on the paper.")
		return
	if(istype(O, /obj/item/book))
		if(volume < 5)
			return
		var/obj/item/book/affectedbook = O
		affectedbook.dat = null
		to_chat(usr, "<span class='notice'>The solution dissolves the ink on the book.</span>")
	return

/datum/reagent/toxin/hydrazine
	name = "Hydrazine"
	id = "hydrazine"
	description = "A toxic, colorless, flammable liquid with a strong ammonia-like odor, in hydrate form."
	taste_description = "sweet tasting metal"
	reagent_state = LIQUID
	color = "#808080"
	metabolism = REM * 0.2
	touch_met = 5

/datum/reagent/toxin/hydrazine/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	M.adjustToxLoss(0.4 * effect_multiplier)

/datum/reagent/toxin/hydrazine/affect_touch(mob/living/carbon/M, alien, effect_multiplier) // Hydrazine is both toxic and flammable.
	M.adjust_fire_stacks(0.4 / 12)
	M.adjustToxLoss(0.2 * effect_multiplier)

/datum/reagent/toxin/hydrazine/touch_turf(turf/T)
	new /obj/effect/decal/cleanable/liquid_fuel(T, volume)
	remove_self(volume)
	return TRUE

/datum/reagent/metal/iron
	name = "Iron"
	id = "iron"
	description = "Pure iron is a metal."
	taste_description = "metal"
	reagent_state = SOLID
	color = "#353535"


/datum/reagent/metal/iron/affect_ingest(mob/living/carbon/M, alien, effect_multiplier)
	M.add_chemical_effect(CE_BLOODRESTORE, 0.8 * effect_multiplier)

/datum/reagent/metal/lithium
	name = "Lithium"
	id = "lithium"
	description = "A chemical element, used as antidepressant."
	taste_description = "metal"
	reagent_state = SOLID
	color = "#808080"

/datum/reagent/metal/lithium/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	if(M.canmove && !M.restrained() && istype(M.loc, /turf/space))
		step(M, pick(cardinal))
	if(prob(5))
		M.emote(pick("twitch", "drool", "moan"))

/datum/reagent/metal/mercury
	name = "Mercury"
	id = "mercury"
	description = "A chemical element."
	taste_mult = 0 //mercury apparently is tasteless. IDK
	reagent_state = LIQUID
	color = "#484848"

/datum/reagent/metal/mercury/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	if(M.canmove && !M.restrained() && istype(M.loc, /turf/space))
		step(M, pick(cardinal))
	if(prob(5))
		M.emote(pick("twitch", "drool", "moan"))
	M.adjustBrainLoss(0.1)

/datum/reagent/phosphorus
	name = "Phosphorus"
	id = "phosphorus"
	description = "A chemical element, the backbone of biological energy carriers."
	taste_description = "vinegar"
	reagent_state = SOLID
	color = "#832828"
	reagent_type = "Reactive nonmetal"


/datum/reagent/metal/potassium
	name = "Potassium"
	id = "potassium"
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
	taste_description = "sweetness" //potassium is bitter in higher doses but sweet in lower ones.
	reagent_state = SOLID
	color = "#A0A0A0"

/datum/reagent/metal/potassium/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	if(volume > 3)
		M.add_chemical_effect(CE_PULSE, 1)
	if(volume > 10)
		M.add_chemical_effect(CE_PULSE, 1)

/datum/reagent/metal/radium
	name = "Radium"
	id = "radium"
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	taste_description = "the color blue, and regret"
	reagent_state = SOLID
	color = "#C7C7C7"

/datum/reagent/metal/radium/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	M.apply_effect(1 * (issmall(M) ? effect_multiplier * 2 : effect_multiplier), IRRADIATE, 0) // Radium may increase your chances to cure a disease
	if(M.virus2.len)
		for(var/ID in M.virus2)
			var/datum/disease2/disease/V = M.virus2[ID]
			if(prob(5))
				M.antibodies |= V.antigen
				if(prob(50))
					M.apply_effect(50, IRRADIATE, check_protection = 0) // curing it that way may kill you instead


/datum/reagent/metal/radium/touch_turf(turf/T)
	if(volume >= 3)
		if(!istype(T, /turf/space))
			var/obj/effect/decal/cleanable/greenglow/glow = locate(/obj/effect/decal/cleanable/greenglow, T)
			if(!glow)
				new /obj/effect/decal/cleanable/greenglow(T)
			return TRUE
	return TRUE

/datum/reagent/acid
	name = "Sulphuric acid"
	id = "sacid"
	description = "A very corrosive mineral acid with the molecular formula H2SO4."
	taste_description = "acid"
	reagent_state = LIQUID
	color = "#DB5008"
	metabolism = REM * 2
	touch_met = 50 // It's acid!
	reagent_type = "Acid"
	var/power = 5
	var/meltdose = 10 // How much is needed to melt

/datum/reagent/acid/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	M.take_organ_damage(0, (issmall(M) ? effect_multiplier * 2: effect_multiplier * power * 2))

/datum/reagent/acid/affect_touch(mob/living/carbon/M, alien, effect_multiplier) // This is the most interesting
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.head)
			if(H.head.unacidable)
				to_chat(H, "<span class='danger'>Your [H.head] protects you from the acid.</span>")
				remove_self(volume)
				return
			else if(volume > meltdose)
				H << "<span class='danger'>Your [H.head] melts away!</span>"
				qdel(H.head)
				H.update_inv_head(1)
				H.update_hair(1)
				remove_self(meltdose)
		if(volume <= 0)
			return

		if(H.wear_mask)
			if(H.wear_mask.unacidable)
				to_chat(H, "<span class='danger'>Your [H.wear_mask] protects you from the acid.</span>")
				remove_self(volume)
				return
			else if(volume > meltdose)
				H << "<span class='danger'>Your [H.wear_mask] melts away!</span>"
				qdel(H.wear_mask)
				H.update_inv_wear_mask(1)
				H.update_hair(1)
				remove_self(meltdose)
		if(volume <= 0)
			return

		if(H.glasses)
			if(H.glasses.unacidable)
				H << "<span class='danger'>Your [H.glasses] partially protect you from the acid!</span>"
				volume /= 2
			else if(volume > meltdose)
				H << "<span class='danger'>Your [H.glasses] melt away!</span>"
				qdel(H.glasses)
				H.update_inv_glasses(1)
				remove_self(meltdose / 2)
		if(volume <= 0)
			return

	if(volume < meltdose) // Not enough to melt anything
		M.take_organ_damage(0, effect_multiplier * power * 0.2) //burn damage, since it causes chemical burns. Acid doesn't make bones shatter, like brute trauma would.
		return
	if(!M.unacidable && volume > 0)
		if(ishuman(M) && volume >= meltdose)
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/external/affecting = H.get_organ(BP_HEAD)
			if(affecting)
				if(affecting.take_damage(0, volume * power * 0.1))
					H.UpdateDamageIcon()
				if(prob(100 * volume / meltdose)) // Applies disfigurement
					if (!(H.species && (H.species.flags & NO_PAIN)))
						H.emote("scream")
					H.status_flags |= DISFIGURED
		else
			M.take_organ_damage(0, volume * power * 0.1) // Balance. The damage is instant, so it's weaker. 10 units -> 5 damage, double for pacid. 120 units beaker could deal 60, but a) it's burn, which is not as dangerous, b) it's a one-use weapon, c) missing with it will splash it over the ground and d) clothes give some protection, so not everything will hit

/datum/reagent/acid/touch_obj(obj/O)
	if(O.unacidable)
		return
	if((istype(O, /obj/item) || istype(O, /obj/effect/plant)) && (volume > meltdose))
		var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
		I.desc = "Looks like this was \an [O] some time ago."
		for(var/mob/M in viewers(5, O))
			to_chat(M, "<span class='warning'>\The [O] melts.</span>")
		qdel(O)
		remove_self(meltdose) // 10 units of acid will not melt EVERYTHING on the tile

/datum/reagent/acid/hydrochloric //Like sulfuric, but less toxic and more acidic.
	name = "Hydrochloric Acid"
	id = "hclacid"
	description = "A very corrosive mineral acid with the molecular formula HCl."
	taste_description = "stomach acid"
	reagent_state = LIQUID
	color = "#808080"
	power = 3
	meltdose = 8

/datum/reagent/silicon
	name = "Silicon"
	id = "silicon"
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
	reagent_state = SOLID
	color = "#A8A8A8"
	reagent_type = "Metalloid"

/datum/reagent/metal/sodium
	name = "Sodium"
	id = "sodium"
	description = "A chemical element, readily reacts with water."
	taste_description = "salty metal"
	reagent_state = SOLID
	color = "#808080"

/datum/reagent/organic/sugar
	name = "Sugar"
	id = "sugar"
	description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste. It is not a good idea to inject too much raw sugar into your bloodstream."
	taste_description = "sugar"
	taste_mult = 1.8
	overdose = 40
	reagent_state = SOLID
	color = "#FFFFFF"
	glass_icon_state = "iceglass"
	glass_name = "sugar"
	glass_desc = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."

/datum/reagent/organic/sugar/affect_blood(mob/living/carbon/M, alien, effect_multiplier)
	M.adjustNutrition(1 * effect_multiplier)

/datum/reagent/organic/sugar/overdose(mob/living/carbon/M, alien)
	..()
	M.add_side_effect("Headache", 11)
	M.make_jittery(5)
	M.add_chemical_effect(CE_PULSE, 2)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/heart/L = H.random_organ_by_process(OP_HEART)
		if(istype(L))
			L.take_damage(1, 0)
	if(prob(5))
		M.emote(pick("twitch", "blink_r", "shiver"))
	
/datum/reagent/sulfur
	name = "Sulfur"
	id = "sulfur"
	description = "A chemical element with a pungent smell."
	taste_description = "old eggs"
	reagent_state = SOLID
	color = "#BF8C00"
	reagent_type = "Reactive nonmetal"

/datum/reagent/metal/tungsten
	name = "Tungsten"
	id = "tungsten"
	description = "A chemical element, and a strong oxidising agent."
	taste_mult = 0 //no taste
	reagent_state = SOLID
	color = "#DCDCDC"

/****************************************************
				BLOOD SYSTEM
****************************************************/

/mob/living/carbon
	var/datum/reagents/vessel // Container for blood and BLOOD ONLY. Do not transfer other chems here.

/mob/living/carbon/human
	var/var/pale = 0          // Should affect how mob sprite is drawn, but currently doesn't.

//Initializes blood vessels
/mob/living/carbon/human/proc/make_blood()

	if(vessel)
		return

	vessel = new/datum/reagents(species.blood_volume)
	vessel.my_atom = src

	if(species && species.flags & NO_BLOOD) //We want the var for safety but we can do without the actual blood.
		return

	vessel.add_reagent("blood",species.blood_volume)
	spawn(1)
		fixblood()

/mob/living/carbon/proc/get_blood_data()
	var/data = list()
	data["donor"] = WEAKREF(src)
	if (!data["virus2"])
		data["virus2"] = list()
	data["virus2"] |= virus_copylist(virus2)
	data["viruses"] = null
	data["antibodies"] = antibodies
	data["blood_DNA"] = dna.unique_enzymes
	data["blood_type"] = dna.b_type
	data["species"] = species.name
	var/list/temp_chem = list()
	for(var/datum/reagent/R in reagents.reagent_list)
		temp_chem[R.type] = R.volume
	data["trace_chem"] = temp_chem
	data["blood_colour"] = species.blood_color
	data["resistances"] = null
	data["carrion"] = is_carrion(src)
	return data

//Resets blood data
/mob/living/carbon/human/proc/fixblood()
	for(var/datum/reagent/organic/blood/B in vessel.reagent_list)
		if(B.id == "blood")
			var/data = list("donor"=src,"viruses"=null,"species"=species.name,"blood_DNA"=dna.unique_enzymes,"blood_colour"= species.blood_color,"blood_type"=dna.b_type,	\
							"resistances"=null,"trace_chem"=null, "virus2" = null, "antibodies" = list())
			B.initialize_data(data)

// Takes care blood loss and regeneration
/mob/living/carbon/human/handle_blood()
	if(in_stasis)
		return

	if(!species?.has_process[OP_HEART])
		return


	if(!organ_list_by_process(OP_HEART).len)	//not having a heart is bad for health - true
		setOxyLoss(max(getOxyLoss(),60))
		adjustOxyLoss(10)

	//Bleeding out
	var/blood_max = 0
	for(var/obj/item/organ/external/temp in organs)
		if(!(temp.status & ORGAN_BLEEDING) || BP_IS_ROBOTIC(temp))
			continue
		for(var/datum/wound/W in temp.wounds)
			if(W.bleeding())
				if(W.internal)
					var/removed = W.damage/75
					if(chem_effects[CE_BLOODCLOT])
						removed *= 1 - chem_effects[CE_BLOODCLOT]
					vessel.remove_reagent("blood", temp.wound_update_accuracy * removed)
					if(prob(1 * temp.wound_update_accuracy))
						custom_pain("You feel a stabbing pain in your [temp]!",1)
				else
					blood_max += W.damage * WOUND_BLEED_MULTIPLIER
		if (temp.open)
			blood_max += OPEN_ORGAN_BLEED_AMOUNT  //Yer stomach is cut open

	// bloodclotting slows bleeding
	if(chem_effects[CE_BLOODCLOT])
		blood_max *=  1 - chem_effects[CE_BLOODCLOT]
	drip_blood(blood_max)

//Makes a blood drop, leaking amt units of blood from the mob
/mob/living/carbon/human/drip_blood(var/amt as num)

	if(species && species.flags & NO_BLOOD) //TODO: Make drips come from the reagents instead.
		return

	if(!amt)
		return

	vessel.remove_reagent("blood",amt)
	blood_splatter(src,src)

/****************************************************
				BLOOD TRANSFERS
****************************************************/

//Gets blood from mob to the container, preserving all data in it.
/mob/living/carbon/proc/take_blood(obj/item/weapon/reagent_containers/container, var/amount)
	var/datum/reagent/B = new /datum/reagent/organic/blood
	B.holder = container
	B.volume = amount

	//set reagent data
	B.initialize_data(get_blood_data())

	return B

//For humans, blood does not appear from blue, it comes from vessels.
/mob/living/carbon/human/take_blood(obj/item/weapon/reagent_containers/container, var/amount)

	if(species && species.flags & NO_BLOOD)
		return null

	if(vessel.get_reagent_amount("blood") < amount)
		return null

	. = ..()
	vessel.remove_reagent("blood",amount) // Removes blood if human

//Transfers blood from container ot vessels
/mob/living/carbon/proc/inject_blood(var/datum/reagent/organic/blood/injected, var/amount)
	if (!injected || !istype(injected))
		return
	var/list/sniffles = virus_copylist(injected.data["virus2"])
	for(var/ID in sniffles)
		var/datum/disease2/disease/sniffle = sniffles[ID]
		infect_virus2(src,sniffle,1)
	if (injected.data["antibodies"] && prob(5))
		antibodies |= injected.data["antibodies"]
	var/list/chems = list()
	chems = params2list(injected.data["trace_chem"])
	for(var/C in chems)
		src.reagents.add_reagent(C, (text2num(chems[C]) / species.blood_volume) * amount)//adds trace chemicals to owner's blood
	reagents.update_total()

//Transfers blood from reagents to vessel, respecting blood types compatability.
/mob/living/carbon/human/inject_blood(var/datum/reagent/organic/blood/injected, var/amount)

	if(species.flags & NO_BLOOD)
		reagents.add_reagent("blood", amount, injected.data)
		reagents.update_total()
		return

	var/datum/reagent/organic/blood/our = get_blood()

	if (!injected || !our)
		return
	if(blood_incompatible(injected.data["blood_type"],our.data["blood_type"],injected.data["species"],our.data["species"]) )
		reagents.add_reagent("toxin",amount * 0.5)
		reagents.update_total()
	else
		vessel.add_reagent("blood", amount, injected.data)
		vessel.update_total()
	..()

//Gets human's own blood.
/mob/living/carbon/proc/get_blood()
	var/datum/reagent/organic/blood/res = locate() in vessel.reagent_list //Grab some blood
	if(res) // Make sure there's some blood at all
		if(res.data["donor"] != src) //If it's not theirs, then we look for theirs
			for(var/datum/reagent/organic/blood/D in vessel.reagent_list)
				if(D.data["donor"] == src)
					return D
	return res

proc/blood_incompatible(donor,receiver,donor_species,receiver_species)
	if(!donor || !receiver) return 0

	if(donor_species && receiver_species)
		if(donor_species != receiver_species)
			return 1

	var/donor_antigen = copytext(donor,1,length(donor))
	var/receiver_antigen = copytext(receiver,1,length(receiver))
	var/donor_rh = (findtext(donor,"+")>0)
	var/receiver_rh = (findtext(receiver,"+")>0)

	if(donor_rh && !receiver_rh) return 1
	switch(receiver_antigen)
		if("A")
			if(donor_antigen != "A" && donor_antigen != "O") return 1
		if("B")
			if(donor_antigen != "B" && donor_antigen != "O") return 1
		if("O")
			if(donor_antigen != "O") return 1
		//AB is a universal receiver.
	return 0

proc/blood_splatter(var/target,var/datum/reagent/organic/blood/source,var/large)

	var/obj/effect/decal/cleanable/blood/B
	var/decal_type = /obj/effect/decal/cleanable/blood/splatter
	var/turf/T = get_turf(target)

	if(ishuman(source))
		var/mob/living/carbon/human/M = source
		source = M.get_blood()

	// Are we dripping or splattering?
	var/list/drips = list()
	// Only a certain number of drips (or one large splatter) can be on a given turf.
	for(var/obj/effect/decal/cleanable/blood/drip/drop in T)
		drips |= drop.drips
		qdel(drop)
	if(!large && drips.len < 3)
		decal_type = /obj/effect/decal/cleanable/blood/drip

	// Find a blood decal or create a new one.
	B = locate(decal_type) in T
	if(!B)
		B = new decal_type(T)

	var/obj/effect/decal/cleanable/blood/drip/drop = B
	if(istype(drop) && drips && drips.len && !large)
		drop.associate_with_overlays(drips)
		drop.drips |= drips

	// If there's no data to copy, call it quits here.
	if(!source)
		return B

	// Update appearance.
	if(source.data["blood_colour"])
		B.basecolor = source.data["blood_colour"]
		B.update_icon()

	// Update blood information.
	if(source.data["blood_DNA"])
		B.blood_DNA = list()
		if(source.data["blood_type"])
			B.blood_DNA[source.data["blood_DNA"]] = source.data["blood_type"]
		else
			B.blood_DNA[source.data["blood_DNA"]] = "O+"

	// Update virus information.
	if(source.data["virus2"])
		B.virus2 = virus_copylist(source.data["virus2"])

	B.fluorescent  = 0
	B.invisibility = 0
	return B

//Percentage of maximum blood volume.
/mob/living/carbon/proc/get_blood_volume()
	return 100

/mob/living/carbon/human/get_blood_volume()
	return round((vessel.get_reagent_amount("blood")/species.blood_volume)*100)

//Get fluffy numbers
/mob/living/carbon/human/proc/get_blood_pressure()
	if(status_flags & FAKEDEATH)
		return "[FLOOR(120+rand(-5,5), 1)*0.25]/[FLOOR(80+rand(-5,5)*0.25, 1)]"
	var/blood_result = get_blood_circulation()
	return "[FLOOR((120+rand(-5,5))*(blood_result/100), 1)]/[FLOOR((80+rand(-5,5))*(blood_result/100), 1)]"

//Percentage of maximum blood volume, affected by the condition of circulation organs, affected by the oxygen loss. What ultimately matters for brain
/mob/living/carbon/proc/get_blood_oxygenation()
	return 100

/mob/living/carbon/human/get_blood_oxygenation()
	var/blood_volume = get_blood_circulation()
	if(is_asystole()) // Heart is missing or isn't beating and we're not breathing (hardcrit)
		return min(blood_volume, total_blood_req)

	if(!need_breathe())
		return blood_volume
	else
		blood_volume = 100

	var/blood_volume_mod = max(0, 1 - getOxyLoss()/(species.total_health/2))
	var/oxygenated_mult = 0
	if(chem_effects[CE_OXYGENATED] == 1) // Dexalin.
		oxygenated_mult = 0.5
	else if(chem_effects[CE_OXYGENATED] >= 2) // Dexplus.
		oxygenated_mult = 0.8
	blood_volume_mod = blood_volume_mod + oxygenated_mult - (blood_volume_mod * oxygenated_mult)
	blood_volume = blood_volume * blood_volume_mod
	return min(blood_volume, 100)

//Percentage of maximum blood volume, affected by the condition of circulation organs
/mob/living/carbon/proc/get_blood_circulation()
	return 100

/mob/living/carbon/human/get_blood_circulation()
	var/heart_efficiency = get_organ_efficiency(OP_HEART)
	var/robo_check = TRUE	//check if all hearts are robotic
	var/open_check = FALSE  //check if any heart is open
	for(var/obj/item/organ/internal/heart/heart in organ_list_by_process(OP_HEART))
		if(!(BP_IS_ROBOTIC(heart)))
			robo_check = FALSE
		if(heart.open)
			open_check = TRUE

	var/blood_volume = get_blood_volume()
	if( heart_efficiency <= 1 || (pulse == PULSE_NONE && !(status_flags & FAKEDEATH) && !robo_check))
		blood_volume *= 0.25
	else
		var/pulse_mod = 1
		switch(pulse)
			if(PULSE_SLOW)
				pulse_mod *= 0.9
			if(PULSE_FAST)
				pulse_mod *= 1.1
			if(PULSE_2FAST, PULSE_THREADY)
				pulse_mod *= 1.25
		blood_volume *= max(0.3, (1-((100 - heart_efficiency) / 100))) * pulse_mod

	if(!open_check && chem_effects[CE_BLOODCLOT])
		blood_volume *= max(0, 1-chem_effects[CE_BLOODCLOT])

	return min(blood_volume, 100)

/mob/living/carbon/human/proc/regenerate_blood(var/amount)
	amount *= (species.blood_volume / SPECIES_BLOOD_DEFAULT)
	var/blood_volume_raw = vessel.get_reagent_amount("blood")
	amount = max(0,min(amount, species.blood_volume - blood_volume_raw))
	if(amount)
		vessel.add_reagent("blood", amount, get_blood_data())
	return amount

#define PROCESS_REACTION_ITER 5 //when processing a reaction, iterate this many times

/datum/reagents
	var/list/datum/reagent/reagent_list = list()
	var/total_volume = 0
	var/maximum_volume = 100
	var/chem_temp = T20C
	var/atom/my_atom
	var/rotating = FALSE


/datum/reagents/New(max = 100, atom/A = null)
	..()
	maximum_volume = max
	my_atom = A

	/// SILENCE
	//Chemical Reagents - Initialises all /datum/reagent into a list indexed by reagent id
	var/paths = typesof(/datum/reagent) - /datum/reagent
	for(var/path in paths)
		var/datum/reagent/D = new path()
		if(!D.name)
			continue
		GLOB.chemical_reagents_list[D.id] = D

/datum/reagents/proc/get_price()
	var/price = 0
	for(var/datum/reagent/R in reagent_list)
		price += R.volume * R.price_per_unit
	return price

/datum/reagents/proc/get_average_reagents_state()
	var/solid = 0
	var/liquid = 0
	var/gas = 0
	for(var/datum/reagent/R in reagent_list)
		switch(R.reagent_state)
			if(SOLID)
				solid++
			if(LIQUID)
				liquid++
			if(GAS)
				gas++
	if(solid >= liquid)
		if(solid >= gas)
			return SOLID
		else
			return GAS
	else
		if(liquid >= gas)
			return LIQUID
		else
			return GAS

/datum/reagents/Destroy()
	. = ..()
	if(SSchemistry)
		SSchemistry.active_holders -= src

	for(var/datum/reagent/R in reagent_list)
		qdel(R)
	reagent_list.Cut()
	reagent_list = null
	if(my_atom && my_atom.reagents == src)
		my_atom.reagents = null

/* Internal procs */

/datum/reagents/proc/get_free_space() // Returns free space.
	return maximum_volume - total_volume

/datum/reagents/proc/get_master_reagent() // Returns reference to the reagent with the biggest volume.
	var/the_reagent
	var/the_volume = 0

	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_reagent = A

	return the_reagent

/datum/reagents/proc/get_master_reagent_name() // Returns the name of the reagent with the biggest volume.
	var/the_name
	var/the_volume = 0
	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_name = A.name

	return the_name

/datum/reagents/proc/get_master_reagent_id() // Returns the id of the reagent with the biggest volume.
	var/the_id
	var/the_volume = 0
	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_id = A.id

	return the_id

/datum/reagents/proc/update_total() // Updates volume.
	total_volume = 0
	for(var/datum/reagent/R in reagent_list)
		if(R.volume < MINIMUM_CHEMICAL_VOLUME)
			del_reagent(R.id)
		else
			total_volume += R.volume
	return

/datum/reagents/proc/delete()
	for(var/datum/reagent/R in reagent_list)
		R.holder = null
	if(my_atom)
		my_atom.reagents = null

/datum/reagents/proc/handle_reactions()
	if(SSchemistry)
		SSchemistry.chem_mark_for_update(src)

//returns TRUE if the holder should continue reactiong, FALSE otherwise.
/datum/reagents/proc/process_reactions()
	if(!my_atom) // No reactions in temporary holders
		return FALSE
	if(!my_atom.loc) //No reactions inside GC'd containers
		return FALSE
	if(my_atom.reagent_flags & NO_REACT) // No reactions here
		return FALSE

	var/reaction_occured = FALSE
	var/list/eligible_reactions = list()

	var/temperature = chem_temp
	for(var/thing in reagent_list)
		var/datum/reagent/R = thing
		if(R.custom_temperature_effects(temperature))
			reaction_occured = TRUE
			continue

		// Check if the reagent is decaying or not.
		var/list/replace_self_with
		var/replace_message
		var/replace_sound

		if(LAZYLEN(R.chilling_products) && temperature <= R.chilling_point)
			replace_self_with = R.chilling_products
			replace_message =   "\The [lowertext(R.name)] [R.chilling_message]"
			replace_sound =     R.chilling_sound

		else if(LAZYLEN(R.heating_products) && temperature >= R.heating_point)
			replace_self_with = R.heating_products
			replace_message =   "\The [lowertext(R.name)] [R.heating_message]"
			replace_sound =     R.heating_sound

		// If it is, handle replacing it with the decay product.
		if(replace_self_with)
			var/replace_amount = R.volume / LAZYLEN(replace_self_with)
			del_reagent(R.id)
			for(var/product in replace_self_with)
				add_reagent(product, replace_amount)
			reaction_occured = TRUE

			if(my_atom)
				if(replace_message)
					my_atom.visible_message("<span class='notice'>\icon[my_atom] [replace_message]</span>")
				if(replace_sound)
					playsound(my_atom, replace_sound, 80, 1)

		else // Otherwise, collect all possible reactions.
			eligible_reactions |= GLOB.chemical_reactions_list[R.id]

	var/list/active_reactions = list()

	for(var/datum/chemical_reaction/C in eligible_reactions)
		if(C.can_happen(src))
			active_reactions[C] = 1 // The number is going to be 1/(fraction of remaining reagents we are allowed to use), computed below
			reaction_occured = TRUE

	var/list/used_reagents = list()
	// if two reactions share a reagent, each is allocated half of it, so we compute this here
	for(var/datum/chemical_reaction/C in active_reactions)
		var/list/adding = C.get_used_reagents()
		for(var/R in adding)
			LAZYADD(used_reagents[R], C)

	for(var/R in used_reagents)
		var/counter = length(used_reagents[R])
		if(counter <= 1)
			continue // Only used by one reaction, so nothing we need to do.
		for(var/datum/chemical_reaction/C in used_reagents[R])
			active_reactions[C] = max(counter, active_reactions[C])
			counter-- //so the next reaction we execute uses more of the remaining reagents
			// Note: this is not guaranteed to maximize the size of the reactions we do (if one reaction is limited by reagent A, we may be over-allocating reagent B to it)
			// However, we are guaranteed to fully use up the most profligate reagent if possible.
			// Further reactions may occur on the next tick, when this runs again.

	for(var/thing in active_reactions)
		var/datum/chemical_reaction/C = thing
		// todo: deshit chem
		C.process("DT_INTERNAL" , src, active_reactions[C])

	for(var/thing in active_reactions)
		var/datum/chemical_reaction/C = thing
		C.post_reaction(src)

	update_total()
	return reaction_occured

/* Holder-to-chemical */

/datum/reagents/proc/add_reagent(var/id, var/amount, var/data = null, var/safety = 0)
	if(!isnum(amount) || amount <= 0)
		return 0

	update_total()
	amount = min(amount, get_free_space())

	for(var/datum/reagent/current in reagent_list)
		if(current.id == id)
			current.volume += amount
			if(!isnull(data)) // For all we know, it could be zero or empty string and meaningful
				current.mix_data(data, amount)
			update_total()
			if(!safety)
				handle_reactions()
			if(my_atom)
				my_atom.on_reagent_change()
			return 1
	var/datum/reagent/D = GLOB.chemical_reagents_list[id]
	if(D)
		var/datum/reagent/R = new D.type()
		reagent_list += R
		R.holder = src
		R.volume = amount
		R.initialize_data(data)
		update_total()
		if(my_atom)
			if(isliving(my_atom))
				R.on_mob_add(my_atom) //Must occur befor it could posibly run on_mob_delete
			my_atom.on_reagent_change()

		if(!safety)
			handle_reactions()
		return 1
	else
		warning("[my_atom] attempted to add a reagent called '[id]' which doesn't exist. ([usr])")
	return 0

/datum/reagents/proc/remove_reagent(var/id, var/amount, var/safety = FALSE)
	if(!isnum(amount))
		return 0
	for(var/datum/reagent/current in reagent_list)
		if(current.id == id)
			current.volume -= amount // It can go negative, but it doesn't matter
			update_total() // Because this proc will delete it then
			if(!safety)
				handle_reactions()
			if(my_atom)
				my_atom.on_reagent_change()
			return 1
	return 0

/datum/reagents/proc/del_reagent(var/id)
	for(var/datum/reagent/current in reagent_list)
		if (current.id == id)
			reagent_list -= current
			qdel(current)
			update_total()
			if(my_atom)
				my_atom.on_reagent_change()
				if(isliving(my_atom))
					current.on_mob_delete(my_atom)

			return 0

/datum/reagents/proc/has_reagent(var/id, var/amount = 0)
	for(var/datum/reagent/current in reagent_list)
		if(current.id == id)
			if(current.volume >= amount)
				return 1
			else
				return 0
	return 0

/datum/reagents/proc/has_any_reagent(var/list/check_reagents)
	for(var/datum/reagent/current in reagent_list)
		if(current.id in check_reagents)
			if(current.volume >= check_reagents[current.id])
				return 1
			else
				return 0
	return 0

/datum/reagents/proc/has_all_reagents(var/list/check_reagents)
	//this only works if check_reagents has no duplicate entries... hopefully okay since it expects an associative list
	var/missing = check_reagents.len
	for(var/datum/reagent/current in reagent_list)
		if(current.id in check_reagents)
			if(current.volume >= check_reagents[current.id])
				missing--
	return !missing

/datum/reagents/proc/clear_reagents()
	for(var/datum/reagent/current in reagent_list)
		del_reagent(current.id)
	return

/datum/reagents/proc/get_reagent_amount(var/id)
	for(var/datum/reagent/current in reagent_list)
		if(current.id == id)
			return current.volume
	return 0

/datum/reagents/proc/get_data(var/id)
	for(var/datum/reagent/current in reagent_list)
		if(current.id == id)
			return current.get_data()
	return 0

/datum/reagents/proc/log_list() // Used in attack logs
	if(!length(reagent_list))
		return "no reagents"
	var/list/data = list()
	for(var/r in reagent_list) //no reagents will be left behind
		var/datum/reagent/R = r
		data += "[R.id] ([round(R.volume, 0.1)]u)"
		//Using IDs because SOME chemicals (I'm looking at you, chlorhydrate-beer) have the same names as other chemicals.
	return english_list(data)

/* Holder-to-holder and similar procs */

/datum/reagents/proc/remove_any(var/amount = 1) // Removes up to [amount] of reagents from [src]. Returns actual amount removed.
	amount = min(amount, total_volume)

	if(!amount)
		return

	var/part = amount / total_volume

	for(var/datum/reagent/current in reagent_list)
		var/amount_to_remove = current.volume * part
		remove_reagent(current.id, amount_to_remove, 1)

	update_total()
	handle_reactions()
	return amount

// Transfers [amount] reagents from [src] to [target], multiplying them by [multiplier]. Returns actual amount removed from [src] (not amount transferred to [target]).
/datum/reagents/proc/trans_to_holder(datum/reagents/target, amount = 1, multiplier = 1, copy = 0)
	if(!istype(target))
		return

	amount = max(0, min(amount, total_volume, target.get_free_space() / multiplier))

	if(!amount)
		return

	var/part = amount / total_volume

	for(var/datum/reagent/current in reagent_list)
		var/amount_to_transfer = current.volume * part
		target.add_reagent(current.id, amount_to_transfer * multiplier, current.get_data(), safety = 1) // We don't react until everything is in place
		if(!copy)
			remove_reagent(current.id, amount_to_transfer, 1)

	if(!copy)
		handle_reactions()
	target.handle_reactions()
	return amount

/* Holder-to-atom and similar procs */

//The general proc for applying reagents to things. This proc assumes the reagents are being applied externally,
//not directly injected into the contents. It first calls touch, then the appropriate trans_to_*() or splash_mob().
//If for some reason touch effects are bypassed (e.g. injecting stuff directly into a reagent container or person),
//call the appropriate trans_to_*() proc.
/datum/reagents/proc/trans_to(datum/target, amount = 1, multiplier = 1, copy = 0, ignore_isinjectable = FALSE)
	if(istype(target, /datum/reagents))
		return trans_to_holder(target, amount, multiplier, copy)
	else if(istype(target, /atom))
		var/atom/A = target
		if(ismob(target))
			return splash_mob(target, amount, multiplier, copy)
		if(isturf(target))
			return trans_to_turf(target, amount, multiplier, copy)
		if(isobj(target) && (A.is_injectable() || ignore_isinjectable))
			return trans_to_obj(target, amount, multiplier, copy)
	return 0

//Splashing reagents is messier than trans_to, the target's loc gets some of the reagents as well.
/datum/reagents/proc/splash(var/atom/target, var/amount = 1, var/multiplier = 1, var/copy = 0, var/min_spill=0, var/max_spill=60)
	var/spill = 0
	if(!isturf(target) && target.loc)
		spill = amount*(rand(min_spill, max_spill)/100)
		amount -= spill
	if(spill)
		splash(target.loc, spill, multiplier, copy, min_spill, max_spill)

	//Here we attempt to transfer some reagents to the target. But it can often fail,
	//like if you try to splash reagents onto an object that isn't an open container
	if (!trans_to(target, amount, multiplier, copy) && total_volume > 0)
		//If it fails, but we still have some volume, then we'll just destroy some of our reagents
		remove_any(amount) //If we don't do this, then only the spill amount above is removed, and someone can keep splashing with the same beaker endlessly

/datum/reagents/proc/trans_id_to(atom/target, id, amount = 1, ignore_isinjectable = FALSE)
	if (!target || !target.reagents || !target.simulated)
		return

	amount = min(amount, get_reagent_amount(id))

	if(!amount)
		return

	var/datum/reagents/F = new /datum/reagents(amount)
	var/tmpdata = get_data(id)
	F.add_reagent(id, amount, tmpdata)
	remove_reagent(id, amount)

	return F.trans_to(target, amount, ignore_isinjectable = ignore_isinjectable) // Let this proc check the atom's type

// When applying reagents to an atom externally, touch() is called to trigger any on-touch effects of the reagent.
// This does not handle transferring reagents to things.
// For example, splashing someone with water will get them wet and extinguish them if they are on fire,
// even if they are wearing an impermeable suit that prevents the reagents from contacting the skin.
/datum/reagents/proc/touch(var/atom/target)
	if(ismob(target))
		touch_mob(target)
	if(isturf(target))
		touch_turf(target)
	if(isobj(target))
		touch_obj(target)
	return

/datum/reagents/proc/touch_mob(var/mob/target)
	if(!target || !istype(target) || !target.simulated)
		return

	for(var/datum/reagent/current in reagent_list)
		current.touch_mob(target, current.volume)

	update_total()

/datum/reagents/proc/touch_turf(var/turf/target)
	if(!target || !istype(target) || !target.simulated)
		return
	if(istype(target, /turf/simulated/open))
		var/turf/simulated/open/T = target
		if(T.isOpen())
			return TRUE // halt powder pile/smears creation without wasting reagents

	var/handled = TRUE
	for(var/datum/reagent/current in reagent_list)
		if(!current.touch_turf(target, current.volume))
			handled = FALSE
	update_total()
	return handled

/datum/reagents/proc/touch_obj(var/obj/target)
	if(!target || !istype(target) || !target.simulated)
		return

	for(var/datum/reagent/current in reagent_list)
		current.touch_obj(target, current.volume)

	update_total()

// Attempts to place a reagent on the mob's skin.
// Reagents are not guaranteed to transfer to the target.
// Do not call this directly, call trans_to() instead.
/datum/reagents/proc/splash_mob(var/mob/target, var/amount = 1, var/multiplier = 1, var/copy = 0)
	if(isliving(target)) //will we ever even need to tranfer reagents to non-living mobs?
		var/mob/living/L = target
		multiplier *= L.reagent_permeability()
	touch_mob(target)
	return trans_to_mob(target, amount, CHEM_TOUCH, multiplier, copy)

/datum/reagents/proc/trans_to_mob(var/mob/target, var/amount = 1, var/type = CHEM_BLOOD, var/multiplier = 1, var/copy = 0) // Transfer after checking into which holder...
	if(!target || !istype(target) || !target.simulated)
		return
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(type == CHEM_BLOOD)
			var/datum/reagents/R = C.reagents
			return trans_to_holder(R, amount, multiplier, copy)
		if(type == CHEM_INGEST)
			var/datum/reagents/R = C.ingested
			return C.ingest(src,R, amount, multiplier, copy)
		if(type == CHEM_TOUCH)
			var/datum/reagents/R = C.touching
			return trans_to_holder(R, amount, multiplier, copy)
	else
		//If the target has a reagent holder, we'll try to put it there instead. This allows feeding simple animals
		if(target.reagents && type == CHEM_BLOOD || type == CHEM_INGEST)
			return trans_to_holder(target.reagents, amount, multiplier, copy)
		else
			var/datum/reagents/R = new /datum/reagents(amount)
			. = trans_to_holder(R, amount, multiplier, copy)
			R.touch_mob(target)

/datum/reagents/proc/trans_to_turf(var/turf/target, var/amount = 1, var/multiplier = 1, var/copy = 0) // Turfs don't have any reagents (at least, for now). Just touch it.
	if(!target || !target.simulated)
		return

	var/datum/reagents/R = new /datum/reagents(amount * multiplier)
	. = trans_to_holder(R, amount, multiplier, copy)

	if(!R.touch_turf(target))	//if touch turf was not handled
		switch(R.get_average_reagents_state())
			if(LIQUID)
				var/obj/effect/decal/cleanable/reagents/splashed/dirtoverlay = locate(/obj/effect/decal/cleanable/reagents/splashed, target)
				if (!dirtoverlay)
					dirtoverlay = new/obj/effect/decal/cleanable/reagents/splashed(target, reagents_to_add = R)
				else
					dirtoverlay.add_reagents(R)
			if(SOLID)
				var/obj/effect/decal/cleanable/reagents/piled/dirtoverlay = locate(/obj/effect/decal/cleanable/reagents/piled, target)
				if (!dirtoverlay)
					dirtoverlay = new/obj/effect/decal/cleanable/reagents/piled(target, reagents_to_add =  R)
				else
					dirtoverlay.add_reagents(R)
	return

/datum/reagents/proc/trans_to_obj(var/obj/target, var/amount = 1, var/multiplier = 1, var/copy = 0) // Objects may or may not; if they do, it's probably a beaker or something and we need to transfer properly; otherwise, just touch.
	if(!target || !target.simulated)
		return

	if(!target.reagents)
		var/datum/reagents/R = new /datum/reagents(amount * multiplier)
		. = trans_to_holder(R, amount, multiplier, copy)
		R.touch_obj(target)
		return

	return trans_to_holder(target.reagents, amount, multiplier, copy)

/datum/reagents/proc/expose_temperature(temperature, coeff=0.02)
	var/temp_delta = (temperature - chem_temp) * coeff
	if(temp_delta > 0)
		chem_temp = min(chem_temp + max(temp_delta, 1), temperature)
	else
		chem_temp = max(chem_temp + min(temp_delta, -1), temperature)
	chem_temp = round(chem_temp)
	handle_reactions()

//Returns the average specific heat for all reagents currently in this holder.
/datum/reagents/proc/specific_heat()
	/*
	. = 0
	var/cached_amount = total_volume		//cache amount
	var/list/cached_reagents = reagent_list		//cache reagents
	for(var/I in cached_reagents)
		var/datum/reagent/R = I
		. += R.specific_heat * (R.volume / cached_amount)
	*/
	// Reagent specific heat is not yet implemented, this is here for compatibility reasons
	return SPECIFIC_HEAT_DEFAULT

/datum/reagents/proc/adjust_thermal_energy(J, min_temp = 2.7, max_temp = 1000)
	var/S = specific_heat()
	chem_temp = CLAMP(chem_temp + (J / (S * total_volume)), 2.7, 1000)

/// Is this holder full or not
/datum/reagents/proc/holder_full()
	if(total_volume >= maximum_volume)
		return TRUE
	return FALSE

/// Like add_reagent but you can enter a list. Format it like this: list(/datum/reagent/toxin = 10, "beer" = 15)
/datum/reagents/proc/add_reagent_list(list/list_reagents, list/data=null)
	for(var/r_id in list_reagents)
		var/amt = list_reagents[r_id]
		add_reagent(r_id, amt, data)


/proc/get_chem_id(chem_name)
	for(var/X in GLOB.chemical_reagents_list)
		var/datum/reagent/R = GLOB.chemical_reagents_list[X]
		if(ckey(chem_name) == ckey(lowertext(R.name)))
			return X

// NanoUI / TG UI data
/datum/reagents/nano_ui_data()
	var/list/data = list()

	data["total_volume"] = total_volume
	data["maximum_volume"] = maximum_volume

	data["chem_temp"] = chem_temp

	var/list/contents = list()
	for(var/r in reagent_list)
		var/datum/reagent/R = r
		// list in a list because Byond merges the first list...
		contents.Add(list(list("name" = R.name, "volume" = R.volume, "id" = R.id)))

	data["contents"] = contents

	return data


/* Atom reagent creation - use it all the time */

/atom/proc/create_reagents(max_vol)
	reagents = new /datum/reagents(max_vol, src)

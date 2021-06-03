/*
	important notes
	catalogs are handled in /datum/nano_module, check there
	important procs are:
		browse_catalog_entry()
		browse_catalog()
		refresh_catalog_browsing()

	TODO: add access level that will show more info
*/

GLOBAL_LIST_EMPTY(catalogs)
GLOBAL_LIST_EMPTY(all_catalog_entries_by_type)

/hook/startup/proc/createCatalogs()
	// Reagents
	for(var/V in GLOB.chemical_reagents_list)
		var/datum/reagent/D = GLOB.chemical_reagents_list[V]
		if(D.appear_in_default_catalog)
			create_catalog_entry(D, CATALOG_REAGENTS)
			create_catalog_entry(D, CATALOG_ALL)
			if(istype(D, /datum/reagent/drink) || istype(D, /datum/reagent/ethanol))
				if(D.type == /datum/reagent/ethanol)
					create_catalog_entry(D, CATALOG_CHEMISTRY)
				create_catalog_entry(D, CATALOG_DRINKS)
			else
				create_catalog_entry(D, CATALOG_CHEMISTRY)
	// second run to add decompose results
	for(var/V in GLOB.chemical_reagents_list)
		var/datum/reagent/D = GLOB.chemical_reagents_list[V]
		if(D.heating_products && D.heating_point)
			for(var/id in D.heating_products)
				var/datum/catalog_entry/reagent/E = get_catalog_entry(get_reagent_type_by_id(id))
				if(E)
					E.add_decomposition_from(D.type)

		if(D.chilling_products && D.chilling_point)
			for(var/id in D.chilling_point)
				var/datum/catalog_entry/reagent/E = get_catalog_entry(D.type)
				if(E)
					E.add_decomposition_from(D.type)

	var/datum/catalog/C = GLOB.catalogs[CATALOG_REAGENTS]
	C.associated_template = "catalog_list_reagents.tmpl"
	C.entry_list = sortTim(C.entry_list, /proc/cmp_catalog_entry_asc)

	C = GLOB.catalogs[CATALOG_CHEMISTRY]
	C.associated_template = "catalog_list_reagents.tmpl"
	C.entry_list = sortTim(C.entry_list, /proc/cmp_catalog_entry_chem)

	C = GLOB.catalogs[CATALOG_DRINKS]
	C.associated_template = "catalog_list_drinks.tmpl"
	C.entry_list = sortTim(C.entry_list, /proc/cmp_catalog_entry_asc)

	C = GLOB.catalogs[CATALOG_ALL]
	C.associated_template = "catalog_list_general.tmpl"
	C.entry_list = sortTim(C.entry_list, /proc/cmp_catalog_entry_asc)

	return 1

/proc/create_catalog_entry(datum/thing, catalog_id)
	if(catalog_id && !LAZYISIN(GLOB.catalogs, catalog_id))
		GLOB.catalogs[catalog_id] = new /datum/catalog(catalog_id)

	if(!GLOB.all_catalog_entries_by_type[thing.type])
		if(istype(thing, /datum/reagent))
			if(istype(thing, /datum/reagent/drink) || (istype(thing, /datum/reagent/ethanol) && thing.type != /datum/reagent/ethanol))
				GLOB.all_catalog_entries_by_type[thing.type] = new /datum/catalog_entry/drink(thing)
			else
				GLOB.all_catalog_entries_by_type[thing.type] = new /datum/catalog_entry/reagent(thing)
		else if(istype(thing, /atom))
			GLOB.all_catalog_entries_by_type[thing.type] = new /datum/catalog_entry/atom(thing)
		else
			var/datum/catalog/element = GLOB.catalogs[catalog_id]
			if(!element)
				qdel(element)
				GLOB.catalogs.Remove(catalog_id)
				return FALSE
			CRASH("Unsupported type \"[catalog_id]\" passed to /proc/create_catalog_entry()")
		if(catalog_id)
			var/datum/catalog/C = GLOB.catalogs[catalog_id]
			C.add_entry(GLOB.all_catalog_entries_by_type[thing.type])
	else if(catalog_id)
		var/datum/catalog/C = GLOB.catalogs[catalog_id]
		if(!C.entry_list.Find(GLOB.all_catalog_entries_by_type[thing.type]))
			C.add_entry(GLOB.all_catalog_entries_by_type[thing.type])
	return TRUE

/proc/get_catalog_entry(var/type)
	if(GLOB.all_catalog_entries_by_type[type])
		return GLOB.all_catalog_entries_by_type[type]

/datum/catalog
	var/id
	var/list/datum/catalog_entry/entry_list = list()
	var/associated_template

/datum/catalog/New(var/_id)
	. = ..()
	id = _id

// accespts either type or datum
/datum/catalog/proc/get_entry(var/datum/thing)
	for(var/datum/catalog_entry/E in entry_list)
		if(E.thing_type == ispath(thing) ? thing : thing.type)
			return E

/datum/catalog/proc/add_entry(var/datum/catalog_entry/entry)
	entry_list.Add(entry)

/datum/catalog/proc/remove_entry(var/datum/catalog_entry/entry)
	entry_list.Remove(entry)

/datum/catalog/nano_ui_data(mob/user, ui_key = "main", var/search_value)
	var/list/data = list()
	var/list/entries_data = list()
	for(var/datum/catalog_entry/E in entry_list)
		if(!search_value || E.search_value(search_value))
			entries_data.Add(list(E.catalog_nano_ui_data(user, ui_key)))
	data["entries"] = entries_data
	return data

/datum/catalog_entry
	var/thing_type
	var/image_path	//image path in client cache
	var/title
	var/description
	var/associated_template
	var/thing_nature 	// reagent/weapon/device/etc.

/datum/catalog_entry/New(var/datum/V)
	thing_type = V.type

/datum/catalog_entry/proc/search_value(var/value)
	if(findtext(title, value))
		return TRUE
	if(findtext(thing_nature, value))
		return TRUE

/datum/catalog_entry/nano_ui_data(mob/user, ui_key = "main")
	var/list/data = list()
	data["id"] = thing_type
	data["thing_nature"] = thing_nature

	return data

// this used to get nano_ui_data for list
// usually this is shorter nano_ui_data
/datum/catalog_entry/proc/catalog_nano_ui_data(mob/user, ui_key = "main")
	var/list/data = list()
	data["id"] = thing_type
	data["name"] = title
	data["thing_nature"] = thing_nature
	if(image_path)
		data["image"] = image_path
	return data

/datum/catalog_entry/reagent
	associated_template = "catalog_entry_reagent.tmpl"
	var/reagent_type
	var/reagent_state
	var/metabolism_blood
	var/metabolism_stomach
	var/taste
	var/nerve_system_accumulations
	var/heating_decompose
	var/heating_point
	var/chilling_decompose
	var/chilling_point
	var/color
	var/scannable
	var/overdose
	var/addiction_chance
	var/addiction_threshold
	var/list/recipe_data
	var/list/result_of_decomposition_in
	var/list/can_be_used_in

/datum/catalog_entry/reagent/search_value(var/value)
	if(..())
		return TRUE
	if(findtext(reagent_type, value))
		return TRUE

/datum/catalog_entry/reagent/proc/add_decomposition_from(var/reagent_type)
	if(!result_of_decomposition_in)
		result_of_decomposition_in = list()
	for(var/V in result_of_decomposition_in)
		if(V == reagent_type)
			return
	result_of_decomposition_in.Add(reagent_type)

/datum/catalog_entry/reagent/proc/add_can_be_used_in(var/reagent_type)
	if(!can_be_used_in)
		can_be_used_in = list()
	for(var/V in can_be_used_in)
		if(V == reagent_type)
			return
	can_be_used_in.Add(reagent_type)

/datum/catalog_entry/reagent/New(datum/reagent/V)
	if(!istype(V))
		error("wrong usage of [src.type]")
		qdel(src)
		return
	..()
	// SPECIFICTS
	title = V.name
	thing_nature = "Reagent"
	reagent_type = V.reagent_type
	reagent_state = V.reagent_state == SOLID ? "Solid" : V.reagent_state == LIQUID ? "Liquid" : "Gas"
	metabolism_blood = V.metabolism
	if(V.ingest_met)
		metabolism_stomach = V.ingest_met
	nerve_system_accumulations = V.nerve_system_accumulations
	if(V.heating_products && V.heating_point)
		var/list/dat = list()
		dat["types"] = list()
		for(var/id in V.heating_products)
			dat["types"] += get_reagent_type_by_id(id)
		heating_decompose = dat
		heating_point = V.heating_point

	if(V.chilling_products && V.chilling_point)
		var/list/dat = list()
		dat["types"] = list()
		for(var/id in V.chilling_products)
			dat["types"] += get_reagent_type_by_id(id)
		chilling_decompose = dat
		chilling_point = V.chilling_point

	scannable = V.scannable
	overdose = V.overdose ? V.overdose : null
	var/list/recipes = GLOB.chemical_reactions_list_by_result[V.id]
	if(recipes)
		recipe_data = list()
		for(var/datum/chemical_reaction/R in recipes)
			recipe_data += list(R.nano_ui_data())
	var/list/used_in = GLOB.chemical_reactions_list[V.id]
	if(used_in)
		for(var/datum/chemical_reaction/R in used_in)
			if(R.result)
				add_can_be_used_in(get_reagent_type_by_id(R.result))
	// DESCRIPTION
	description = V.description
	taste = "Has [V.taste_mult > 1 ? "strong" : V.taste_mult < 1 ? "weak" : ""] taste of [V.taste_description]."
	color = "[V.color]"
	if(V.addiction_threshold || V.addiction_chance)
		addiction_chance = V.addiction_threshold ? "high" : V.addiction_chance <= 10 ? "Low" : V.addiction_chance <= 25 ? "Moderate" : "High"
		addiction_threshold = V.addiction_threshold

/datum/catalog_entry/reagent/catalog_nano_ui_data(mob/user, ui_key = "main")
	var/list/data = ..()
	data["reagent_state"] = reagent_state
	data["reagent_type"] = reagent_type
	return data

/datum/catalog_entry/reagent/nano_ui_data(mob/user, ui_key = "main")
	var/list/data = ..()

	// SPECIFICTS
	data["name"] = title
	data["reagent_type"] = reagent_type
	data["reagent_state"] = reagent_state
	data["metabolism_blood"] = metabolism_blood
	data["metabolism_stomach"] = metabolism_stomach
	data["nsa"] = nerve_system_accumulations
	data["heating_decompose"] = heating_decompose
	data["heating_point"] = heating_point
	data["chilling_decompose"] = chilling_decompose
	data["chilling_point"] = chilling_point
	data["scannable"] = scannable
	data["overdose"] = overdose
	data["result_of_decomposition_in"] = result_of_decomposition_in
	data["can_be_used_in"] = can_be_used_in

	data["recipe_data"] = recipe_data

	// DESCRIPTION
	data["description"] = description
	data["taste"] = taste
	data["color"] = color
	data["addiction_chance"] = addiction_chance
	data["addiction_threshold"] = addiction_threshold

	return data

/datum/catalog_entry/atom
	associated_template = "catalog_entry_atom.tmpl"

/datum/catalog_entry/atom/New(var/atom/V)
	if(!istype(V))
		error("wrong usage of [src.type]")
		qdel(src)
		return
	..()
	title = V.name
	description = V.desc
	thing_nature = "Atom"
	image_path = SSassets.transport.get_asset_url(V)


/datum/catalog_entry/atom/nano_ui_data(mob/user, ui_key = "main")
	var/list/data = ..()

	// SPECIFICTS
	data["name"] = title
	data["entry_image_path"] = image_path

	// DESCRIPTION
	data["description"] = description
	return data


/datum/catalog_entry/drink
	associated_template = "catalog_entry_drink.tmpl"
	var/temperature
	var/nutrition
	var/taste
	var/strength
	var/list/recipe_data
	var/list/taste_tag

/datum/catalog_entry/drink/search_value(var/value)
	if(..())
		return TRUE
	if(findtext(strength, value))
		return TRUE
	for(var/i in taste_tag)
		if(findtext(i, value))
			return TRUE

/datum/catalog_entry/drink/New(var/datum/reagent/V)
	if(!istype(V))
		error("wrong usage of [src.type]")
		qdel(src)
		return
	..()
	title = V.name
	description = V.description

	taste = "Has [V.taste_mult > 1 ? "strong" : V.taste_mult < 1 ? "weak" : ""] taste of [V.taste_description]."
	if(istype(V, /datum/reagent/drink))
		var/datum/reagent/drink/D = V
		if(D.adj_temp)
			temperature = D.adj_temp > 0 ? "Warm" : "Cold"
		if(D.nutrition)
			nutrition = D.nutrition > 1 ? "High" : "Low"
		thing_nature = "Drink"

	else if(istype(V, /datum/reagent/ethanol))
		var/datum/reagent/ethanol/E = V
		if(E.adj_temp)
			temperature = E.adj_temp > 0 ? "Warm" : "Cold"
		if(E.nutriment_factor)
			nutrition = E.nutriment_factor > 1 ? "High" : "Low"
		strength = E.strength <= 15 ? "Light" : E.strength <= 50 ? "Strong" : "Knocking out"
		thing_nature = "Alchohol drink"
		if(E.taste_tag.len)
			taste_tag = list()
			for(var/tastes in E.taste_tag)
				taste_tag += tastes
	var/list/recipes = GLOB.chemical_reactions_list_by_result[V.id]
	if(recipes)
		recipe_data = list()
		for(var/datum/chemical_reaction/R in recipes)
			recipe_data += list(R.nano_ui_data())

/datum/catalog_entry/drink/nano_ui_data(mob/user, ui_key = "main")
	var/list/data = ..()

	// SPECIFICTS
	data["name"] = title
	data["entry_image_path"] = image_path

	data["temperature"] = temperature
	data["nutrition"] = nutrition
	data["taste"] = taste
	data["strength"] = strength
	data["recipe_data"] = recipe_data
	data["taste_tag"] = taste_tag


	// DESCRIPTION
	data["description"] = description
	return data

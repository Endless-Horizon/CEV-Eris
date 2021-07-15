//Weapon names for artist
GLOBAL_LIST_INIT(art_weapon_first_names, file2list("strings/artist_strings/names/art_weapon_first.txt"))
GLOBAL_LIST_INIT(art_weapon_second_names, file2list("strings/artist_strings/names/art_weapon_second.txt"))


GLOBAL_LIST_INIT(art_names_of_creatures_plural, file2list("strings/artist_strings/names/art_creatures_names_plural.txt"))
GLOBAL_LIST_INIT(art_locations, file2list("strings/artist_strings/descriptors/art_locations.txt"))

GLOBAL_LIST_INIT(art_sculpting_method, file2list("strings/artist_strings/descriptors/art_sculpting_method.txt"))

GLOBAL_LIST_INIT(art_styles, file2list("strings/artist_strings/descriptors/art_style.txt"))


GLOBAL_LIST_INIT(art_types, file2list("strings/artist_strings/descriptors/art_types.txt"))

//When you need something simple (for random Artist Artwork)
/proc/get_weapon_name(capitalize = FALSE)
	var/first_name = pick(GLOB.art_weapon_first_names)
	var/second_name = pick(GLOB.art_weapon_second_names)

	if(capitalize)
		first_name = capitalize(first_name)
		second_name = capitalize(second_name)

	return "\improper [first_name] [second_name]"

/proc/get_artwork_crew_name(only_first_name = FALSE, only_last_name = FALSE)
	var/list/names = list()
	var/art_crew_name = "Who?"
	for(var/mob/living/carbon/human/H in (GLOB.human_mob_list & GLOB.player_list))
		if(!isOnStationLevel(H))
			continue
		if(H.mind && player_is_antag(H.mind))
			continue
		if(only_first_name)
			names.Add(H.first_name && H.first_name)
		else if(only_last_name && H.last_name)
			names.Add(H.last_name)
		else
			names.Add(H.real_name)
	if(names.len)
		art_crew_name = pick(names)
	return art_crew_name

/proc/get_artwork_name(capitalize=FALSE)
	var/option = pick(1,2,3)
	var/name
	switch(option)
		if(1)
			name = get_art_secret_name()
		if(2)
			name = get_travel_actios()
		if(3)
			name = get_art_of_name()
	if(capitalize)
		capitalize(name)
	return name

/proc/get_art_secret_name()
	var/list/adjectives = list("big", "terrifying", "mysterious", "fantastic", "secret", "haunting", "mysteriouss")
	return "the [pick(adjectives)] secret of [get_artwork_crew_name(pick(TRUE, FALSE), pick(TRUE, FALSE))]"

/proc/get_travel_actios()
	var/location
	if(prob(50))
		location = get_art_mob_places()
	else
		location = pick(GLOB.art_locations)
	return "the [get_artwork_crew_name(pick(TRUE, FALSE), pick(TRUE, FALSE))]s [pick("trip","journey")] to the [location]"

/proc/get_art_mob_places()
	var/list/mobs_places = list("cave", "hideout", "nest")
	return "the [pick(GLOB.art_names_of_creatures_plural)] [pick(mobs_places)]"

/proc/get_art_of_name()
	var/list/nouns = list("heart", "soul", "honor", "beauty", "feet", "true face", "true form")
	return "the [pick(nouns)] of [get_artwork_crew_name(pick(TRUE, FALSE), pick(TRUE, FALSE))]"

/obj/proc/get_random_material()
	var/list/nmatter = get_matter()
	return nmatter ? pickweight(nmatter) : null

/obj/proc/get_sculpting_method()
	return "[pick(GLOB.art_sculpting_method)] [get_random_material()]"

/obj/proc/make_art_review()
	var/list/emotions = list("fear", "joy", "laughter", "sadness", "respect", "terror", "vigor", "encourages")
	desc += " A [pick(GLOB.art_styles)] [pick(GLOB.art_types)] [get_sculpting_method()]. [pick("Inspires", "Infuses")] [pick(emotions)] to those who look at it."

/obj/item/gun/projectile/make_art_review()
	desc += " [get_art_gun_desc(src)]"
	desc += " Uses [caliber] rounds."

/proc/get_art_gun_desc(obj/O)
	var/list/type_of_design = list("cyberpunk", "outdated", "modern", "futuristic", "rustic")
	return "It is made mainly of [O.get_random_material()] and has a [pick(type_of_design)] design."

GLOBAL_LIST_INIT(art_description_type_actions_statue, file2list("strings/artist_strings/descriptors/art_type_actions_statue.txt"))
GLOBAL_LIST_INIT(art_description_sculpting_method_descriptors, file2list("strings/artist_strings/descriptors/art_sculpting_method_descriptors.txt"))
GLOBAL_LIST_INIT(art_description_type_ofs_statue, file2list("strings/artist_strings/descriptors/art_type_ofs_statue.txt"))
GLOBAL_LIST_INIT(art_description_types_statue, file2list("strings/artist_strings/names/art_types_statue.txt"))

/obj/structure/artwork_statue/make_art_review()
	var/description_artwork_statue_verb = "[pick("This","The")] [pick(GLOB.art_description_types_statue)] [pick(GLOB.art_description_type_actions_statue)] [pick("",pick(GLOB.art_description_type_ofs_statue))]"
	var/description_artwork_statue_stationary = "[pick(GLOB.art_description_sculpting_method_descriptors)] [pick("this","the")] [pick(GLOB.art_description_types_statue)] is [pick(GLOB.art_description_type_ofs_statue)]"
	var/description_artwork_statue = pick(description_artwork_statue_verb,description_artwork_statue_stationary)

	var/description_statue = "[description_artwork_statue] [get_artwork_description()]"
	desc += " [description_statue]"
	return description_statue

//GLOBAL_LIST_INIT(art_description_types, file2list("strings/artist_strings/names/art_types.txt"))
GLOBAL_LIST_INIT(art_description_locations, file2list("strings/artist_strings/descriptors/art_locations.txt"))
GLOBAL_LIST_INIT(art_description_locations_descriptors, file2list("strings/artist_strings/descriptors/art_locations_descriptors.txt"))
GLOBAL_LIST_INIT(art_description_locations_specifics, file2list("strings/artist_strings/descriptors/art_locations_specifics.txt"))
GLOBAL_LIST_INIT(art_description_objectssubjects, file2list("strings/artist_strings/names/art_objectsubject.txt"))
GLOBAL_LIST_INIT(art_description_subject_actions, file2list("strings/artist_strings/descriptors/art_subject_actions.txt"))
GLOBAL_LIST_INIT(art_description_object_actions, file2list("strings/artist_strings/descriptors/art_object_actions.txt"))
GLOBAL_LIST_INIT(art_description_objectsubject_actions, file2list("strings/artist_strings/descriptors/art_objectsubject_actions.txt"))
GLOBAL_LIST_INIT(art_description_objectsubject_actions_present, file2list("strings/artist_strings/descriptors/art_objectsubject_actions_present.txt"))
GLOBAL_LIST_INIT(art_description_objectsubject_states, file2list("strings/artist_strings/descriptors/art_objectsubject_states.txt"))
GLOBAL_LIST_INIT(art_description_style_descriptors, file2list("strings/artist_strings/descriptors/art_style_descriptors.txt"))
GLOBAL_LIST_INIT(art_description_themes, file2list("strings/artist_strings/descriptors/art_themes.txt"))

/proc/get_artwork_description()
	var/object = pick(pick(GLOB.art_description_objectssubjects),get_artwork_crew_name(pick(TRUE, FALSE), pick(TRUE, FALSE)))
	var/subject = pick(pick(GLOB.art_description_objectssubjects),get_artwork_crew_name(pick(TRUE, FALSE), pick(TRUE, FALSE)))
	var/object_action = pick(GLOB.art_description_object_actions)
	var/subject_action = pick(GLOB.art_description_subject_actions)
	var/objectsubject_action = pick(GLOB.art_description_objectsubject_actions)
	var/objectsubject_action_present = pick(GLOB.art_description_objectsubject_actions_present)
	var/objectsubject_state = pick(GLOB.art_description_objectsubject_states)
	var/location = pick(GLOB.art_description_locations)
	var/location_descriptors = pick(GLOB.art_description_locations_descriptors)
	var/location_specific = pick(GLOB.art_description_locations_specifics)
	var/art_style_descriptor = pick(GLOB.art_description_style_descriptors)
	var/art_theme = pick(GLOB.art_description_themes)

	var/description_location = ""
	if(object != location && subject != location)
		description_location = "[pick("This","The")] [pick(GLOB.art_description_types_statue)] [location_descriptors] [location_specific] \a [location]."

	var/description_event_subject_to_object = ""
	if(findtext(subject_action,"\[object\]"))
		subject_action = replacetext(subject_action,"\[object\]",object)
		description_event_subject_to_object = "\a [subject] [subject_action]."
	else
		description_event_subject_to_object = "\a [subject] [subject_action] \a [object]."
	var/description_event_object_to_subject = pick("\a [object] [object_action] by \a [subject].","\a [object] [object_action] while \a [subject] [objectsubject_action_present] [pick("in the background","next to them")].")
	var/description_event_objectsubject = "\a [subject] [objectsubject_action] [pick("on top of","with")] \a [object]."
	var/description_event_object = "\a [object] [object_action]."
	var/description_event = pick(description_event_subject_to_object,description_event_object_to_subject,description_event_objectsubject,description_event_object, "\a [subject].", "\a [object].")
	if(findtext(description_event,subject)==0)
		description_event += pick(""," \The [object] is [objectsubject_state].")
	else if(findtext(description_event,object)==0)
		description_event += pick(""," \The [subject] is [objectsubject_state].")
	else
		description_event += pick(""," \The [subject] is [objectsubject_state]."," \the [object] is [objectsubject_state].")

	var/description_style = "[pick("If you squint your eyes,","Looking closely enough,")] the [art_style_descriptor] [pick("composition","layout")] of [pick("this","the")] [pick(GLOB.art_description_types_statue)] [pick("reveals","seems to portray","seems to hide")] the [pick("outline of","shape of","parts of")] \a [pick(GLOB.art_description_objectssubjects)]."
	var/description_theme = "[pick("This","The")] [pick(GLOB.art_description_types_statue)] [pick("seems to","appears to")] [pick("portray","suggest","be entirely devoid of","be utterly absent of")] [art_theme]."

	return "[description_event] [description_location] [pick("",description_style)] [pick("",description_theme)]"

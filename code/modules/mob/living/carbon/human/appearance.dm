/mob/living/carbon/human/proc/change_appearance(var/flags = APPEARANCE_ALL_HAIR, var/location = src, var/mob/user = src, var/check_species_whitelist = 1, var/list/species_whitelist = list(), var/list/species_blacklist = list(), var/datum/topic_state/state =GLOB.default_state)
	var/datum/nano_module/appearance_changer/AC = new(location, src, check_species_whitelist, species_whitelist, species_blacklist)
	AC.flags = flags
	AC.nano_ui_interact(user, state = state)

/mob/living/carbon/human/proc/change_species(var/new_species)
	if(!new_species)
		return

	if(species == new_species)
		return

	if(!(new_species in all_species))
		return

	set_species(new_species)
	reset_hair()
	return 1

/mob/living/carbon/human/proc/change_name(var/type)
	if (type == "random")
		var/datum/language/L = get_default_language()
		L.set_random_name(src)

	else
		var/newname = input("Choose a name for your character.","Your Name", real_name)
		fully_replace_character_name(real_name, newname)
	to_chat(src, SPAN_NOTICE("Your name is now [real_name]"))

/mob/living/carbon/human/proc/change_gender(var/gender)
	if(src.gender == gender)
		return

	src.gender = gender
	regenerate_icons() //This is overkill, but we do need to update all of the clothing. Maybe there's a more precise call
	//reset_hair()
	//update_body()
	//update_dna()
	return 1

/mob/living/carbon/human/proc/change_hair(var/hair_style)
	if(!hair_style)
		return

	if(h_style == hair_style)
		return

	if(!(hair_style in GLOB.hair_styles_list))
		return

	h_style = hair_style

	update_hair()
	return 1

/mob/living/carbon/human/proc/change_facial_hair(var/facial_hair_style)
	if(!facial_hair_style)
		return

	if(f_style == facial_hair_style)
		return

	if(!(facial_hair_style in GLOB.facial_hair_styles_list))
		return

	f_style = facial_hair_style

	update_hair()
	return 1

/mob/living/carbon/human/proc/reset_hair()
	var/list/valid_hairstyles = generate_valid_hairstyles()
	var/list/valid_facial_hairstyles = generate_valid_facial_hairstyles()

	if(valid_hairstyles.len)
		h_style = pick(valid_hairstyles)
	else
		//this shouldn't happen
		h_style = "Bald"

	if(valid_facial_hairstyles.len)
		f_style = pick(valid_facial_hairstyles)
	else
		//this shouldn't happen
		f_style = "Shaved"

	update_hair()

/mob/living/carbon/human/proc/change_eye_color(var/color)
	if(color == eyes_color)
		return

	eyes_color = color

	update_eyes()
	update_body()
	return 1

/mob/living/carbon/human/proc/change_hair_color(var/color)
	if(color == hair_color)
		return

	hair_color = color

	force_update_limbs()
	update_body()
	update_hair()
	return 1

/mob/living/carbon/human/proc/change_facial_hair_color(var/color)
	if(color == facial_color)
		return

	facial_color = color

	update_hair()
	return 1

/mob/living/carbon/human/proc/change_skin_color(var/color)
	if(color == skin_color || !(species.appearance_flags & HAS_SKIN_COLOR))
		return

	skin_color = color

	force_update_limbs()
	update_body()
	return 1

/mob/living/carbon/human/proc/change_skin_tone(var/tone)
	if(s_tone == tone || !(species.appearance_flags & HAS_SKIN_TONE))
		return

	s_tone = tone

	force_update_limbs()
	update_body()
	return 1

/mob/living/carbon/human/proc/update_dna()
	check_dna()
	dna.ready_dna(src)

/mob/living/carbon/human/proc/generate_valid_species(var/check_whitelist = 1, var/list/whitelist = list(), var/list/blacklist = list())
	var/list/valid_species = new()
	for(var/current_species_name in all_species)
		var/datum/species/current_species = all_species[current_species_name]

		if(check_whitelist)// && !check_rights(R_ADMIN, 0, src)) //If we're using the whitelist, make sure to check it!
			if(!(current_species.spawn_flags & CAN_JOIN))
				continue
			if(whitelist.len && !(current_species_name in whitelist))
				continue
			if(blacklist.len && (current_species_name in blacklist))
				continue
			if((current_species.spawn_flags & IS_WHITELISTED) && !is_alien_whitelisted(src, current_species_name))
				continue

		valid_species += current_species_name

	return valid_species

/mob/living/carbon/human/proc/generate_valid_hairstyles(var/check_gender = 1)
	. = list()
	var/list/hair_styles = species.get_hair_styles()
	for(var/hair_style in hair_styles)
		var/datum/sprite_accessory/S = hair_styles[hair_style]
		if(check_gender)
			if(gender == MALE && S.gender == FEMALE)
				continue
			if(gender == FEMALE && S.gender == MALE)
				continue
		.[hair_style] = S

/mob/living/carbon/human/proc/generate_valid_facial_hairstyles()
	return species.get_facial_hair_styles(gender)

/mob/living/carbon/human/proc/force_update_limbs()
	for(var/obj/item/organ/external/O in organs)
		O.sync_colour_to_human(src)
	update_body(0)

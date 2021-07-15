/datum/perk/survivor
	name = "Survivor"
	desc = "After seeing the death of many acquaintances and friends, witnessing death doesn't shock you as much as before. \
			Halves sanity loss from seeing people die."
	icon_state = "survivor" // https://game-icons.net/1x1/lorc/one-eyed.html

/datum/perk/survivor/assign(mob/living/carbon/human/H)
	..()
	if(holder)
		holder.sanity.death_view_multiplier *= 0.5

/datum/perk/survivor/remove()
	if(holder)
		holder.sanity.death_view_multiplier *= 2
	..()

/datum/perk/job/artist
	name = "Artist"
	desc = "You have a lot of expertise in making works of art. You gain 150% insight from all sources but can only level \
			up by creating works of art."
	var/old_max_insight = INFINITY
	var/old_max_resting = INFINITY
	var/old_insight_rest_gain_multiplier = 1

/datum/perk/job/artist/assign(mob/living/carbon/human/H)
	..()
	old_max_insight = holder.sanity.max_insight
	old_max_resting = holder.sanity.max_resting
	old_insight_rest_gain_multiplier = holder.sanity.insight_rest_gain_multiplier
	holder.sanity.max_insight = 100
	holder.sanity.insight_gain_multiplier *= 1.5
	holder.sanity.max_resting = 1
	holder.sanity.insight_rest_gain_multiplier = 0

/datum/perk/job/artist/remove()
	holder.sanity.max_insight += old_max_insight - 100
	holder.sanity.insight_gain_multiplier /= 1.5
	holder.sanity.max_resting += old_max_resting - 1
	holder.sanity.insight_rest_gain_multiplier += old_insight_rest_gain_multiplier
	..()


/datum/perk/selfmedicated
	name = "Self-medicated"
	desc = "You have very shoddy handwriting. This lets you write prescriptions to yourself! \
			You total NSA is increased and chance to gain an addiction decreased."
	icon_state = "selfmedicated" // https://game-icons.net/1x1/lorc/overdose.html

/datum/perk/selfmedicated/assign(mob/living/carbon/human/H)
	..()
	if(holder)
		holder.metabolism_effects.addiction_chance_multiplier = 0.5
		holder.metabolism_effects.nsa_threshold += 10

/datum/perk/selfmedicated/remove()
	if(holder)
		holder.metabolism_effects.addiction_chance_multiplier = 1
		holder.metabolism_effects.nsa_threshold -= 10
	..()

/datum/perk/vagabond
	name = "Vagabond"
	desc = "You're used to see the worst sight the world has to offer. Your mind feels more resistant. \
			This perk reduces the total sanity damage you can take from what is happening around you."
	icon_state = "vagabond" // https://game-icons.net/1x1/lorc/eye-shield.html

/datum/perk/vagabond/assign(mob/living/carbon/human/H)
	..()
	if(holder)
		holder.sanity.view_damage_threshold += 20

/datum/perk/vagabond/remove()
	if(holder)
		holder.sanity.view_damage_threshold -= 20
	..()

/datum/perk/merchant
	name = "Merchant"
	desc = "Money is what matters for you, and it's so powerful it lets you improve your skills. \
			This perk lets you use money for leveling up. The credits need to be in your backpack."
	icon_state = "merchant" // https://game-icons.net/1x1/lorc/cash.html and https://game-icons.net/1x1/delapouite/graduate-cap.html slapped on https://game-icons.net/1x1/lorc/trade.html

/datum/perk/merchant/assign(mob/living/carbon/human/H)
	..()
	if(holder)
		holder.sanity.valid_inspirations += /obj/item/spacecash/bundle

/datum/perk/merchant/remove()
	if(holder)
		holder.sanity.valid_inspirations -= /obj/item/spacecash/bundle
	..()

#define CHOICE_LANG "language" // Random language chosen from a pool
#define CHOICE_TCONTRACT "tcontract" // Traitor contract
#define CHOICE_STASHPAPER "stashpaper" //stash location paper
#define CHOICE_RAREOBJ "rareobj" // Rare loot object

// ALERT: This perk has no removal method. Mostly because 3 out of 4 choices give knowledge to the player in the form of text, that would be pointless to remove.
/datum/perk/deep_connection
	name = "Deep connection"
	desc = "With the help of your numerous trustworthy contacts, you manage to collect some useful information. \
			Provides you with 1 of 4 boons: Language, Traitor Contract, a stash location or a special item in a box."
	icon_state = "deepconnection" // https://game-icons.net/1x1/quoting/card-pickup.html

/datum/perk/deep_connection/assign(mob/living/carbon/human/H)
	..()
	if(!holder)
		return
	var/list/choices = list(CHOICE_RAREOBJ)
	if(GLOB.various_antag_contracts.len)
		choices += CHOICE_TCONTRACT
	var/datum/stash/stash = pick_n_take_stash_datum()
	if(stash)
		stash.select_location()
		if(stash.stash_location)
			choices += CHOICE_STASHPAPER
	// Let's see if an additional language is feasible. If the user has them all already somehow, we aren't gonna choose this.
	var/list/valid_languages = list(LANGUAGE_CYRILLIC, LANGUAGE_SERBIAN, LANGUAGE_GERMAN, LANGUAGE_NEOHONGO, LANGUAGE_LATIN) // Not static, because we're gonna remove languages already known by the user
	for(var/l in valid_languages)
		var/datum/language/L = all_languages[l]
		if(L in holder.languages)
			valid_languages -= l
	if(valid_languages.len)
		choices += CHOICE_LANG
	// Let's pick a random choice
	switch(pick(choices))
		if(CHOICE_LANG)
			var/language = pick(valid_languages)
			holder.add_language(language)
			desc += " In particular, you happen to know [language]."
		if(CHOICE_TCONTRACT)
			var/datum/antag_contract/A = pick(GLOB.various_antag_contracts)
			desc += " You feel like you remembered something important."
			holder.mind.store_memory("Thanks to your connections, you were tipped off about some suspicious individuals on the ship. In particular, you were told that they have a contract: " + A.name + ": " + A.desc)
		if(CHOICE_STASHPAPER)
			desc += " You have a special note in your storage."
			stash.spawn_stash()
			var/obj/item/paper/stash_note = stash.spawn_note()
			holder.equip_to_storage_or_drop(stash_note)
		if(CHOICE_RAREOBJ)
			desc += " You managed to smuggle a rare item aboard."
			var/obj/O = pickweight(RANDOM_RARE_ITEM - /obj/item/stash_spawner)
			var/obj/item/storage/box/B = new
			new O(B) // Spawn the random spawner in the box, so that the resulting random item will be within the box
			holder.equip_to_storage_or_drop(B)

#undef CHOICE_LANG
#undef CHOICE_TCONTRACT
#undef CHOICE_STASHPAPER
#undef CHOICE_RAREOBJ

/datum/perk/sanityboost
	name = "True Faith"
	desc = "When near an obelisk, you feel your mind at ease. Your sanity regeneration is boosted."
	icon_state = "sanityboost" // https://game-icons.net/1x1/lorc/templar-eye.html

/datum/perk/active_sanityboost
	name = "True Faith (Active)"
	icon_state = "sanityboost" // https://game-icons.net/1x1/lorc/templar-eye.html

/datum/perk/active_sanityboost/assign(mob/living/carbon/human/H)
	..()
	if(holder)
		holder.sanity.sanity_passive_gain_multiplier *= 1.5

/datum/perk/active_sanityboost/remove()
	if(holder)
		holder.sanity.sanity_passive_gain_multiplier /= 1.5
	..()

/// Basically a marker perk. If the user has this perk, another will be given in certain conditions.
/datum/perk/inspiration
	name = "Exotic Inspiration"
	desc = "Boosts your Cognition and Mechanical stats any time you imbibe any alcohol."
	icon_state = "inspiration" // https://game-icons.net/1x1/delapouite/booze.html

/datum/perk/active_inspiration
	name = "Exotic Inspiration (Active)"
	icon_state = "inspiration_active" // https://game-icons.net/1x1/lorc/enlightenment.html

/datum/perk/active_inspiration/assign(mob/living/carbon/human/H)
	..()
	if(holder)
		holder.stats.addTempStat(STAT_COG, 5, INFINITY, "Exotic Inspiration")
		holder.stats.addTempStat(STAT_MEC, 10, INFINITY, "Exotic Inspiration")

/datum/perk/active_inspiration/remove()
	if(holder)
		holder.stats.removeTempStat(STAT_COG, "Exotic Inspiration")
		holder.stats.removeTempStat(STAT_MEC, "Exotic Inspiration")
	..()

/datum/perk/sommelier
	name = "Sommelier"
	desc = "You know how to handle even strongest alcohol in the universe."
	icon_state = "inspiration"

/datum/perk/neat
	name = "Neat"
	desc = "You're used to see blood and filth in all its forms. Your motto: a clean ship is the first step to enlightenment. \
			This perk reduces the total sanity damage you can take from what is happening around you. \
			You can regain sanity by cleaning."
	icon_state = "neat" // https://game-icons.net/1x1/delapouite/broom.html

/datum/perk/neat/assign(mob/living/carbon/human/H)
	..()
	if(holder)
		holder.sanity.view_damage_threshold += 20

/datum/perk/neat/remove()
	if(holder)
		holder.sanity.view_damage_threshold -= 20
	..()

/datum/perk/greenthumb
	name = "Green Thumb"
	desc = "After growing plants for years you have become a botanical expert. You can get all information about plants, from stats \
	        to harvest reagents, by examining them. Gathering plants relaxes you and thus restores sanity."
	icon_state = "greenthumb" // https://game-icons.net/1x1/delapouite/farmer.html

	var/obj/item/device/scanner/plant/virtual_scanner = new

/datum/perk/greenthumb/assign(mob/living/carbon/human/H)
	..()
	virtual_scanner.is_virtual = TRUE

/datum/perk/job/club
	name = "Raising the bar"
	desc = "You know how to mix drinks and change lives. People near you recover sanity."
	icon_state = "inspiration"

/datum/perk/job/club/assign(mob/living/carbon/human/H)
	..()
	if(holder)
		holder.sanity_damage -= 2

/datum/perk/job/club/remove()
	if(holder)
		holder.sanity_damage += 2
	..()

/datum/perk/channeling
	name = "Channeling"
	desc = "You know how to channel spiritual energy during rituals. You gain additional skill points \
			during group rituals and have an increased regeneration of cruciform energy."
	icon_state = "channeling"

/obj/item/oddity/secdocs
	name = "science data"
	desc = "Folder contains some papers with important science data."
	icon = 'icons/obj/oddities.dmi'
	icon_state = "folder"
	price_tag = 5000

	oddity_stats = list(
		STAT_MEC = 8,
		STAT_COG = 8,
		STAT_BIO = 8,
	)

	var/static/inv_spawn_count = 3

/obj/item/oddity/secdocs/Initialize()
	icon_state = "folder-[pick("omega","psi","theta")]"
	name = pick("Atractor fields theory",
				"World lines theory",
				"Outside context problem evidence",
				"Use of self-learning AI for public administration",
				"Evidence of time travel related changes in history",
				"Geograpfy of non existent cyties",
				"Production of Alliance nanomachines",
				"Known S.A.U. equipment specifications",
				"Known access points to Discordia",
				"The Door phenomenon",
				"Paralell world related mutations",
				"Mass hallucinations or a breach from another world?",
				"Ironhammer budget: evidence of S.A.U. overfund",
				"Real reason of One Star fall",
				"Connection between One Star and dead alien civilizations, are we next?",
				"Unknown device blueprints")
	. = ..()
	var/mob/living/carbon/human/owner = loc
	if(istype(owner))
		to_chat(owner, SPAN_NOTICE("You have valuable science data on your person. It is essential that you do not let it fall into the wrong hands."))

/hook/roundstart/proc/place_docs()
	var/list/obj/landmark/storyevent/midgame_stash_spawn/L = list()
	for(var/obj/landmark/storyevent/midgame_stash_spawn/S in GLOB.landmarks_list)
		L.Add(S)

	L = shuffle(L)

	if(L.len < 3)
		warning("Failed to place secret documents: not enough landmarks.")
		return FALSE

	for(var/i in 1 to 3)
		new /obj/item/oddity/secdocs(L[i].get_loc())

	return TRUE

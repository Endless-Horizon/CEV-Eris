#define GET_RANDOM_JOB 0
#define BE_ASSISTANT 1
#define RETURN_TO_LOBBY 2

SUBSYSTEM_DEF(job)
	name = "Jobs"
	init_order = INIT_ORDER_JOBS
	flags = SS_NO_FIRE

	var/list/occupations = list()			//List of all jobs
	var/list/occupations_by_name = list()	//Dict of all jobs, keys are titles
	var/list/unassigned = list()			//Players who need jobs
	var/list/job_debug = list()				//Debug info
	var/list/job_mannequins = list()				//Cache of icons for job info window

/datum/controller/subsystem/job/Initialize(start_timeofday)
	if(!occupations.len)
		SetupOccupations()
		LoadJobs("config/jobs.txt")
	return ..()

/datum/controller/subsystem/job/proc/SetupOccupations(faction = "CEV Eris")
	occupations.Cut()
	occupations_by_name.Cut()
	for(var/J in subtypesof(/datum/job))
		var/datum/job/job = new J()
		if(job.faction != faction)
			continue
		occupations += job
		occupations_by_name[job.title] = job

	if(!occupations.len)
		to_chat(world, SPAN_WARNING("Error setting up jobs, no job datums found!"))
		return FALSE

	return TRUE

/datum/controller/subsystem/job/proc/Debug(text)
	if(!Debug2)
		return FALSE
	job_debug.Add(text)
	return TRUE

/datum/controller/subsystem/job/proc/GetJob(rank)
	return rank && occupations_by_name[rank]

/datum/controller/subsystem/job/proc/AssignRole(mob/new_player/player, rank, latejoin = FALSE)
	Debug("Running AR, Player: [player], Rank: [rank], LJ: [latejoin]")
	if(player && player.mind && rank)
		var/datum/job/job = GetJob(rank)
		if(!job)
			return FALSE
		if(job.minimum_character_age && (player.client.prefs.age < job.minimum_character_age))
			return FALSE
		if(jobban_isbanned(player, rank))
			return FALSE

		var/position_limit = job.total_positions
		if(!latejoin)
			position_limit = job.spawn_positions
		if((job.current_positions < position_limit) || position_limit == -1)
			Debug("Player: [player] is now Rank: [rank], JCP:[job.current_positions], JPL:[position_limit]")
			player.mind.assigned_role = rank
			player.mind.assigned_job = job
			unassigned -= player
			job.current_positions++
			return TRUE
	Debug("AR has failed, Player: [player], Rank: [rank]")
	return FALSE

/datum/controller/subsystem/job/proc/FreeRole(rank)	//making additional slot on the fly
	var/datum/job/job = GetJob(rank)
	if(job && job.current_positions >= job.total_positions && job.total_positions != -1)
		job.total_positions++
		return TRUE
	return FALSE

/datum/controller/subsystem/job/proc/FindOccupationCandidates(datum/job/job, level, flag)
	Debug("Running FOC, Job: [job], Level: [level], Flag: [flag]")
	var/list/candidates = list()
	for(var/mob/new_player/player in unassigned)
		if(jobban_isbanned(player, job.title))
			Debug("FOC isbanned failed, Player: [player]")
			continue
		if(job.minimum_character_age && (player.client.prefs.age < job.minimum_character_age))
			Debug("FOC character not old enough, Player: [player]")
			continue
		if(flag && !(flag in player.client.prefs.be_special_role))
			Debug("FOC flag failed, Player: [player], Flag: [flag], ")
			continue
		if(player.client.prefs.CorrectLevel(job,level))
			Debug("FOC pass, Player: [player], Level:[level]")
			candidates += player
	return candidates

/datum/controller/subsystem/job/proc/GiveRandomJob(mob/new_player/player)
	Debug("GRJ Giving random job, Player: [player]")
	for(var/datum/job/job in shuffle(occupations))
		if(!job)
			continue

		if(job.minimum_character_age && (player.client.prefs.age < job.minimum_character_age))
			continue

		if(istype(job, GetJob(ASSISTANT_TITLE))) // We don't want to give him assistant, that's boring!
			continue

		if(job in command_positions) //If you want a command position, select it!
			continue

		if(job.is_restricted(player.client.prefs))
			continue

		if(jobban_isbanned(player, job.title))
			Debug("GRJ isbanned failed, Player: [player], Job: [job.title]")
			continue

		var/datum/category_item/setup_option/core_implant/I = player.client.prefs.get_option("Core implant")
		// cant be Neotheology without a cruciform
		if(job.department == DEPARTMENT_CHURCH && istype(I.implant_type,/obj/item/weapon/implant/core_implant/cruciform))
			continue
		if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
			Debug("GRJ Random job given, Player: [player], Job: [job]")
			AssignRole(player, job.title)
			unassigned -= player
			break

/datum/controller/subsystem/job/proc/ResetOccupations()
	for(var/mob/new_player/player in GLOB.player_list)
		if((player) && (player.mind))
			player.mind.assigned_role = null
			player.mind.assigned_job = null
	//		player.mind.special_role = null
	SetupOccupations()
	unassigned = list()


///This proc is called before the level loop of DivideOccupations() and will try to select a head, ignoring ALL non-head preferences for every level until it locates a head or runs out of levels to check
/datum/controller/subsystem/job/proc/FillHeadPosition()
	for(var/level = 1 to 3)
		for(var/command_position in command_positions)
			var/datum/job/job = GetJob(command_position)
			if(!job)
				continue
			var/list/candidates = FindOccupationCandidates(job, level)
			if(!candidates.len)
				continue

			// Build a weighted list, weight by age.
			var/list/weightedCandidates = list()
			for(var/mob/V in candidates)
				// Log-out during round-start? What a bad boy, no head position for you!
				if(!V.client)
					continue
				var/age = V.client.prefs.age

				if(age < job.minimum_character_age) // Nope.
					continue

				switch(age)
					if(job.minimum_character_age to (job.minimum_character_age+10))
						weightedCandidates[V] = 3 // Still a bit young.
					if((job.minimum_character_age+10) to (job.ideal_character_age-10))
						weightedCandidates[V] = 6 // Better.
					if((job.ideal_character_age-10) to (job.ideal_character_age+10))
						weightedCandidates[V] = 10 // Great.
					if((job.ideal_character_age+10) to (job.ideal_character_age+20))
						weightedCandidates[V] = 6 // Still good.
					if((job.ideal_character_age+20) to INFINITY)
						weightedCandidates[V] = 3 // Geezer.
					else
						// If there's ABSOLUTELY NOBODY ELSE
						if(candidates.len == 1) weightedCandidates[V] = 1


			var/mob/new_player/candidate = pickweight(weightedCandidates)
			if(AssignRole(candidate, command_position))
				return TRUE
	return FALSE


	///This proc is called at the start of the level loop of DivideOccupations() and will cause head jobs to be checked before any other jobs of the same level
/datum/controller/subsystem/job/proc/CheckHeadPositions(level)
	for(var/command_position in command_positions)
		var/datum/job/job = GetJob(command_position)
		if(!job)
			continue
		var/list/candidates = FindOccupationCandidates(job, level)
		if(!candidates.len)
			continue
		var/mob/new_player/candidate = pick(candidates)
		AssignRole(candidate, command_position)


/** Proc DivideOccupations
 *  fills var "assigned_role" for all ready players.
 *  This proc must not have any side effect besides of modifying "assigned_role".
 **/
/datum/controller/subsystem/job/proc/DivideOccupations()
	//Setup new player list and get the jobs list
	Debug("Running DO")
	SetupOccupations()

	//Holder for Triumvirate is stored in the ticker, this just processes it
	if(SSticker.triai)
		for(var/datum/job/A in occupations)
			if(A.title == "AI")
				A.spawn_positions = 3
				break

	//Get the players who are ready
	for(var/mob/new_player/player in GLOB.player_list)
		if(player.ready && player.mind && !player.mind.assigned_role)
			unassigned += player

	Debug("DO, Len: [unassigned.len]")
	if(unassigned.len == 0)
		return TRUE

	//Shuffle players and jobs
	unassigned = shuffle(unassigned)

	HandleFeedbackGathering()

	//People who wants to be assistants, sure, go on.
	Debug("DO, Running Assistant Check 1")
	var/datum/job/assist = new DEFAULT_JOB_TYPE ()
	var/list/assistant_candidates = FindOccupationCandidates(assist, 3)
	Debug("AC1, Candidates: [assistant_candidates.len]")
	for(var/mob/new_player/player in assistant_candidates)
		Debug("AC1 pass, Player: [player]")
		AssignRole(player, ASSISTANT_TITLE)
		assistant_candidates -= player
	Debug("DO, AC1 end")

	//Select one head
	Debug("DO, Running Head Check")
	FillHeadPosition()
	Debug("DO, Head Check end")

	//Other jobs are now checked
	Debug("DO, Running Standard Check")


	// New job giving system by Donkie
	// This will cause lots of more loops, but since it's only done once it shouldn't really matter much at all.
	// Hopefully this will add more randomness and fairness to job giving.

	// Loop through all levels from high to low
	var/list/shuffledoccupations = shuffle(occupations)
	// var/list/disabled_jobs = SSticker.mode.disabled_jobs  // So we can use .Find down below without a colon.
	for(var/level = 1 to 3)
		//Check the head jobs first each level
		CheckHeadPositions(level)

		// Loop through all unassigned players
		for(var/mob/new_player/player in unassigned)

			// Loop through all jobs
			for(var/datum/job/job in shuffledoccupations) // SHUFFLE ME BABY
				/*if(!job || SSticker.mode.disabled_jobs.Find(job.title) )
					continue
				*/
				if(jobban_isbanned(player, job.title))
					Debug("DO isbanned failed, Player: [player], Job:[job.title]")
					continue

				// If the player wants that job on this level, then try give it to him.
				if(player.client.prefs.CorrectLevel(job,level))

					// If the job isn't filled
					if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
						Debug("DO pass, Player: [player], Level:[level], Job:[job.title]")
						AssignRole(player, job.title)
						unassigned -= player
						break

	// Hand out random jobs to the people who didn't get any in the last check
	// Also makes sure that they got their preference correct
	for(var/mob/new_player/player in unassigned)
		if(player.client.prefs.alternate_option == GET_RANDOM_JOB)
			GiveRandomJob(player)

	Debug("DO, Standard Check end")

	Debug("DO, Running AC2")

	// For those who wanted to be assistant if their preferences were filled, here you go.
	for(var/mob/new_player/player in unassigned)
		if(player.client.prefs.alternate_option == BE_ASSISTANT)
			Debug("AC2 Assistant located, Player: [player]")
			AssignRole(player, ASSISTANT_TITLE)

	//For ones returning to lobby
	for(var/mob/new_player/player in unassigned)
		if(player.client.prefs.alternate_option == RETURN_TO_LOBBY)
			player.ready = 0
			player.new_player_panel_proc()
			unassigned -= player
	return TRUE


/datum/controller/subsystem/job/proc/EquipRank(mob/living/carbon/human/H, rank)
	if(!H)
		return null

	var/datum/job/job = GetJob(rank)
	var/list/spawn_in_storage = list()

	var/datum/job_flavor/flavor = pick(job.random_flavors)

	if(job)
		H.job = rank

		//Equip custom gear loadout.
		//var/list/custom_equip_slots = list() //If more than one item takes the same slot, all after the first one spawn in storage.
		//var/list/custom_equip_leftovers = list()

		//Equip job items and language stuff
		job.setup_account(H)

		job.equip(H, flavor ? flavor.title : H.mind ? H.mind.role_alt_title : "")

		//loadout items.
		if(spawn_in_storage)
			for(var/datum/gear/G in spawn_in_storage)
				G.spawn_in_storage_or_drop(H, H.client.prefs.Gear()[G.display_name])

		job.add_stats(H, flavor)
		job.add_additiional_language(H)

		job.apply_fingerprints(H)

		//loadout items.
		spawn_in_storage = EquipCustomLoadout(H, job)

		if(spawn_in_storage)
			for(var/datum/gear/G in spawn_in_storage)
				G.spawn_in_storage_or_drop(H, H.client.prefs.Gear()[G.display_name])

		// EMAIL GENERATION
		if(rank != "Robot" && rank != "AI")		//These guys get their emails later.
			ntnet_global.create_email(H, H.real_name, pick(GLOB.maps_data.usable_email_tlds))

	else
		to_chat(H, "Your job is [rank] and the game just can't handle it! Please report this bug to an administrator.")

	// If they're head, give them the account info for their department
	if(H.mind && (job.head_position || job.department_account_access))
		var/remembered_info = ""
		var/datum/money_account/department_account = department_accounts[job.department]
		if(department_account)
			remembered_info += "<b>Your department's account number is:</b> #[department_account.account_number]<br>"
			remembered_info += "<b>Your department's account pin is:</b> [department_account.remote_access_pin]<br>"
			remembered_info += "<b>Your department's account funds are:</b> [department_account.money][CREDS]<br>"
		if(job.head_position)
			remembered_info += "<b>Your part of nuke code:</b> [SSticker.get_next_nuke_code_part()]<br>"
			department_account.owner_name = H.real_name //Register them as the point of contact for this account

		H.mind.store_memory(remembered_info)

	var/alt_title = null
	if(H.mind)
		H.mind.assigned_role = rank
	//	alt_title = H.mind.role_alt_title

		switch(rank)
			if("Robot")
				return H.Robotize()
			if("AI")
				return H
			if("Captain")
				var/sound/announce_sound = (SSticker.current_state <= GAME_STATE_SETTING_UP)? null : sound('sound/misc/boatswain.ogg', volume=20)
				captain_announcement.Announce("All hands, Captain [H.real_name] on deck!", new_sound=announce_sound)

	if(istype(H)) //give humans wheelchairs, if they need them.
		var/obj/item/organ/external/l_leg = H.get_organ(BP_L_LEG)
		var/obj/item/organ/external/r_leg = H.get_organ(BP_R_LEG)
		if(!l_leg || !r_leg)
			var/obj/structure/bed/chair/wheelchair/W = new /obj/structure/bed/chair/wheelchair(H.loc)
			H.buckled = W
			H.update_lying_buckled_and_verb_status()
			W.set_dir(H.dir)
			W.buckled_mob = H
			W.add_fingerprint(H)

	to_chat(H, "<B>You are [job.total_positions == 1 ? "the" : "a"] [alt_title ? alt_title : rank].</B>")

	if(job.supervisors)
		to_chat(H, "<b>As the [alt_title ? alt_title : rank] you answer directly to [job.supervisors]. Special circumstances may change this.</b>")

	if(job.req_admin_notify)
		to_chat(H, "<b>You are playing a job that is important for Game Progression. If you have to disconnect, please notify the admins via adminhelp.</b>")

	//Gives glasses to the vision impaired
	if(H.disabilities & NEARSIGHTED)
		var/equipped = H.equip_to_slot_or_del(new /obj/item/clothing/glasses/regular(H), slot_glasses)
		if(equipped != 1)
			var/obj/item/clothing/glasses/G = H.glasses
			G.prescription = 1

	var/obj/item/weapon/implant/core_implant/C = H.get_core_implant()
	if(C)
		C.install_default_modules_by_job(job)
		C.access.Add(job.cruciform_access)

	var/obj/item/weapon/oddity/secdocs/D
	if(D.inv_spawn_count > 0 && prob(5) && !(locate(/obj/item/weapon/oddity/secdocs) in H.get_contents()))
		D = new
		if(H.equip_to_storage(D))
			--D.inv_spawn_count

	BITSET(H.hud_updateflag, ID_HUD)
	BITSET(H.hud_updateflag, SPECIALROLE_HUD)
	return H

/proc/EquipCustomLoadout(var/mob/living/carbon/human/H, var/datum/job/job)
	if(!H || !H.client)
		return

	// Equip custom gear loadout, replacing any job items
	var/list/spawn_in_storage = list()
	var/list/loadout_taken_slots = list()
	if(H.client.prefs.Gear() && job.loadout_allowed)
		for(var/thing in H.client.prefs.Gear())
			var/datum/gear/G = gear_datums[thing]
			if(G)
				var/permitted = 1
				if(permitted)
					if(G.allowed_roles)
						if(job.title in G.allowed_roles)
							permitted = 1
						else
							permitted = 0
					else
						permitted = 1

				if(G.whitelisted && (!(H.species.name in G.whitelisted)))
					permitted = 0

				if(!permitted)
					to_chat(H, "<span class='warning'>Your current job or whitelist status does not permit you to spawn with [thing]!</span>")
					continue

				if(!G.slot || G.slot == slot_accessory_buffer || (G.slot in loadout_taken_slots) || !G.spawn_on_mob(H, H.client.prefs.Gear()[G.display_name]))
					spawn_in_storage.Add(G)
				else
					loadout_taken_slots.Add(G.slot)

	return spawn_in_storage

/datum/controller/subsystem/job/proc/LoadJobs(jobsfile) //ran during round setup, reads info from jobs.txt -- Urist
	if(!config.load_jobs_from_txt)
		return FALSE

	var/list/jobEntries = file2list(jobsfile)

	for(var/job in jobEntries)
		if(!job)
			continue

		job = trim(job)
		if (!length(job))
			continue

		var/pos = findtext(job, "=")
		var/name = null
		var/value = null

		if(pos)
			name = copytext(job, 1, pos)
			value = copytext(job, pos + 1)
		else
			continue

		if(name && value)
			var/datum/job/J = GetJob(name)
			if(!J)	continue
			J.total_positions = text2num(value)
			J.spawn_positions = text2num(value)
			if(name == "AI" || name == "Robot")//I dont like this here but it will do for now
				J.total_positions = 0

	return TRUE

/datum/controller/subsystem/job/proc/HandleFeedbackGathering()
	for(var/datum/job/job in occupations)
		var/tmp_str = "|[job.title]|"

		var/level1 = 0 //high
		var/level2 = 0 //medium
		var/level3 = 0 //low
		var/level4 = 0 //never
		var/level5 = 0 //banned
		var/level6 = 0 //account too young
		for(var/mob/new_player/player in GLOB.player_list)
			if(!(player.ready && player.mind && !player.mind.assigned_role))
				continue //This player is not ready
			if(jobban_isbanned(player, job.title))
				level5++
				continue
			if(player.client.prefs.CorrectLevel(job,1))
				level1++
			else if(player.client.prefs.CorrectLevel(job,2))
				level2++
			else if(player.client.prefs.CorrectLevel(job,3))
				level3++
			else level4++ //not selected

		tmp_str += "HIGH=[level1]|MEDIUM=[level2]|LOW=[level3]|NEVER=[level4]|BANNED=[level5]|YOUNG=[level6]|-"


/**
 *  Return appropriate /datum/spawnpoint for given client and rank
 *
 *  Spawnpoint will be the one set in preferences for the client, unless the
 *  preference is not set, or the preference is not appropriate for the rank, in
 *  which case a fallback will be selected.
 */
/datum/controller/subsystem/job/proc/get_spawnpoint_for(var/client/C, var/rank, late = FALSE)

	if(!C)
		CRASH("Null client passed to get_spawnpoint_for() proc!")

	var/mob/H = C.mob
	var/pref_spawn = C.prefs.spawnpoint

	var/datum/spawnpoint/SP



	//First of all, lets try to get the "default" spawning point.
	if(late)
		if(pref_spawn)
			SP = get_spawn_point(pref_spawn, late = TRUE)
		else
			SP = get_spawn_point(GLOB.maps_data.default_spawn, late = TRUE)
			to_chat(H, SPAN_WARNING("You have not selected spawnpoint in preference menu."))
	else
		SP = get_spawn_point(rank)

	//Test the default spawn we just got
	//Feeding true to the report var here will allow the user to choose to spawn anyway
	if (SP && SP.can_spawn(H, rank, TRUE))
		return SP

	else
		//The above didn't work, okay lets start testing spawnpoints at random until we find a place we can spawn
		//Todo: Add in pref options to specify an ordered priority list for spawning locations
		var/list/spawns = get_late_spawntypes()
		var/list/possibilities = spawns.Copy() //The above proc returns a pointer to the list, we need to copy it so we dont modify the original
		if (istype(SP))
			possibilities -= SP.name //Lets subtract the one we already tested
		SP = null

		while (possibilities.len)
			//Randomly pick things from our shortlist
			var/spawn_name = pick(possibilities)
			SP = possibilities[spawn_name]
			possibilities -= spawn_name //Then remove them from that list of course

			if(SP.can_spawn(H, rank))
				return SP
			else
				to_chat(H, SPAN_WARNING("Unable to spawn you at [SP.name].")) // you will be assigned default one which is \"[SP.display_name]\"."

	// No spawn point? Something is fucked.
	// Pick the default one.
	to_chat(H, SPAN_WARNING("Unable to locate any safe spawn point. Have fun!"))
	SP = get_spawn_point("Aft Cryogenic Storage")

	// Still no spawn point? Return the first spawn point on the list.
	if(!SP)
		var/list/possibilities = get_late_spawntypes()
		SP = possibilities[possibilities[1]]

	return SP



/datum/controller/subsystem/job/proc/ShouldCreateRecords(var/title)
	if(!title) return 0
	var/datum/job/job = GetJob(title)
	if(!job || job == "Vagabond") return 0
	return job.create_record

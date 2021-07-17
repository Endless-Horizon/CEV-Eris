//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/mob/new_player
	var/ready = 0
	var/spawning = 0//Referenced when you want to delete the new_player later on in the code.
	var/totalPlayers = 0		 //Player counts for the Lobby tab
	var/totalPlayersReady = 0
	var/datum/browser/panel
	universal_speak = 1

	invisibility = 101

	density = FALSE
	stat = DEAD
	movement_handlers = list()

	anchored = TRUE	//  don't get pushed around
/*
/mob/new_player/New()
	mob_list += src*/

/mob/new_player/say(var/message, var/datum/language/speaking = null, var/verb="says", var/alt_name="")
	if (client)
		client.ooc(message)

/mob/new_player/verb/new_player_panel()
	set src = usr
	new_player_panel_proc()


/mob/new_player/proc/new_player_panel_proc()
	var/output = "<div align='center'><B>New Player Options</B>"
	output +="<hr>"
	output += "<p><a href='byond://?src=\ref[src];show_preferences=1'>Setup Character</A></p>"

	if(SSticker.current_state <= GAME_STATE_PREGAME)
		if(ready)
			output += "<p>\[ <span class='linkOn'><b>Ready</b></span> | <a href='byond://?src=\ref[src];ready=0'>Not Ready</a> \]</p>"
		else
			output += "<p>\[ <a href='byond://?src=\ref[src];ready=1'>Ready</a> | <span class='linkOn'><b>Not Ready</b></span> \]</p>"

	else
		output += "<a href='byond://?src=\ref[src];manifest=1'>View the Crew Manifest</A><br><br>"
		output += "<p><a href='byond://?src=\ref[src];late_join=1'>Join Game!</A></p>"

	output += "<p><a href='byond://?src=\ref[src];observe=1'>Observe</A></p>"

	if(!IsGuestKey(src.key))
		establish_db_connection()
		if(dbcon.IsConnected())
			var/isadmin = FALSE
			if(src.client && src.client.holder)
				isadmin = TRUE
			// TODO: reimplement database interaction
			var/DBQuery/query = dbcon.NewQuery("SELECT id FROM erro_poll_question WHERE [(isadmin ? "" : "adminonly = false AND")] Now() BETWEEN starttime AND endtime AND id NOT IN (SELECT pollid FROM erro_poll_vote WHERE ckey = \"[ckey]\") AND id NOT IN (SELECT pollid FROM erro_poll_textreply WHERE ckey = \"[ckey]\")")
			query.Execute()
			var/newpoll = FALSE
			while(query.NextRow())
				newpoll = TRUE
				break

			if(newpoll)
				output += "<p><b><a href='byond://?src=\ref[src];showpoll=1'>Show Player Polls</A> (NEW!)</b></p>"
			else
				output += "<p><a href='byond://?src=\ref[src];showpoll=1'>Show Player Polls</A></p>"

	output += "</div>"

	panel = new(src, "Welcome","Welcome", 210, 280, src)
	panel.set_window_options("can_close=0")
	panel.set_content(output)
	panel.open()
	return

/mob/new_player/Stat()
	. = ..()

	if(statpanel("Status"))
		if(SSticker.current_state == GAME_STATE_PREGAME)
			stat("Storyteller:", "[master_storyteller]") // Old setting for showing the game mode
			stat("Time To Start:", "[SSticker.pregame_timeleft][round_progressing ? "" : " (DELAYED)"]")
			stat("Players: [totalPlayers]", "Players Ready: [totalPlayersReady]")
			totalPlayers = 0
			totalPlayersReady = 0
			for(var/mob/new_player/player in GLOB.player_list)
				if(player.ready)
					stat("[player.client.prefs.real_name]", (player.ready)?("[player.client.prefs.job_high]"):(null))
				totalPlayers++
				if(player.ready)totalPlayersReady++

/mob/new_player/Topic(href, href_list[])
	if(src != usr || !client)
		return 0

	if(href_list["show_preferences"])
		client.prefs.ShowChoices(src)
		return 1

	if(href_list["ready"])
		if(SSticker.current_state <= GAME_STATE_PREGAME) // Make sure we don't ready up after the round has started
			ready = text2num(href_list["ready"])
		else
			ready = 0

	if(href_list["refresh"])
		panel.close()
		new_player_panel_proc()

	if(href_list["observe"])

		if(alert(src,"Are you sure you wish to observe? You will have to wait 30 minutes before being able join the crew! But you can play as a mouse or drone immediately.","Player Setup","Yes","No") == "Yes")
			if(!client)	return 1
			var/mob/observer/ghost/observer = new()

			spawning = 1
			sound_to(src, sound(null, repeat = 0, wait = 0, volume = 85, channel = GLOB.lobby_sound_channel))

			observer.started_as_observer = 1
			close_spawn_windows()
			var/turf/T = pick_spawn_location("Observer")
			if(istype(T))
				to_chat(src, SPAN_NOTICE("You are observer now."))
				observer.forceMove(T)
			else
				to_chat(src, "<span class='danger'>Could not locate an observer spawn point. Use the Teleport verb to jump to the station map.</span>")
			observer.timeofdeath = world.time // Set the time of death so that the respawn timer works correctly.

			announce_ghost_joinleave(src)
			observer.icon = client.prefs.update_preview_icon()
			observer.alpha = 127

			if(client.prefs.be_random_name)
				client.prefs.real_name = random_name(client.prefs.gender)
			observer.real_name = client.prefs.real_name
			observer.name = observer.real_name
			if(!client.holder && !config.antag_hud_allowed)           // For new ghosts we remove the verb from even showing up if it's not allowed.
				observer.verbs -= /mob/observer/ghost/verb/toggle_antagHUD        // Poor guys, don't know what they are missing!
			//observer.key = key
			observer.ckey = ckey
			observer.initialise_postkey()

			observer.client.create_UI(observer.type)
			qdel(src)

			return 1

	if(href_list["late_join"])

		if(SSticker.current_state != GAME_STATE_PLAYING)
			to_chat(usr, "\red The round is either not ready, or has already finished...")
			return

		if(!check_rights(R_ADMIN, 0))
			var/datum/species/S = all_species[client.prefs.species]
			if((S.spawn_flags & IS_WHITELISTED) && !is_alien_whitelisted(src, client.prefs.species))
				src << alert("You are currently not whitelisted to play [client.prefs.species].")
				return 0

			if(!(S.spawn_flags & CAN_JOIN))
				src << alert("Your current species, [client.prefs.species], is not available for play on the station.")
				return 0

		LateChoices()

	if(href_list["manifest"])
		show_manifest(src, nano_state = GLOB.interactive_state)

	if(href_list["SelectedJob"])

		if(!config.enter_allowed)
			to_chat(usr, "<span class='notice'>There is an administrative lock on entering the game!</span>")
			return
		else if(SSticker.nuke_in_progress)
			to_chat(usr, "<span class='danger'>The station is currently exploding. Joining would go poorly.</span>")
			return

		var/datum/species/S = all_species[client.prefs.species]
		if((S.spawn_flags & IS_WHITELISTED) && !is_alien_whitelisted(src, client.prefs.species))
			src << alert("You are currently not whitelisted to play [client.prefs.species].")
			return 0

		if(!(S.spawn_flags & CAN_JOIN))
			src << alert("Your current species, [client.prefs.species], is not available for play on the station.")
			return 0

		AttemptLateSpawn(href_list["SelectedJob"], client.prefs.spawnpoint)
		return

	if(!ready && href_list["preference"])
		if(client)
			client.prefs.process_link(src, href_list)
	else if(!href_list["late_join"])
		new_player_panel()

	if(href_list["showpoll"])
		handle_player_polling()
		return

	if(href_list["poll_id"])
		var/poll_id = href_list["poll_id"]
		if(istext(poll_id))
			poll_id = text2num(poll_id)
		if(isnum(poll_id))
			src.poll_player(poll_id)
		return

	if(href_list["vote_on_poll"] && href_list["vote_type"])
		var/poll_id = text2num(href_list["vote_on_poll"])
		var/vote_type = href_list["vote_type"]
		switch(vote_type)
			if("OPTION")
				var/option_id = text2num(href_list["vote_option_id"])
				vote_on_poll(poll_id, option_id)
			if("TEXT")
				var/reply_text = href_list["reply_text"]
				log_text_poll_reply(poll_id, reply_text)


/mob/new_player/proc/IsJobAvailable(rank)
	var/datum/job/job = SSjob.GetJob(rank)
	if(!job)	return 0
	if(!job.is_position_available()) return 0
	if(jobban_isbanned(src,rank))	return 0
	return 1

/mob/new_player/proc/AttemptLateSpawn(rank, var/spawning_at)
	if(src != usr)
		return 0
	if(SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, "\red The round is either not ready, or has already finished...")
		return 0
	if(!config.enter_allowed)
		to_chat(usr, "<span class='notice'>There is an administrative lock on entering the game!</span>")
		return 0
	if(!IsJobAvailable(rank))
		src << alert("[rank] is not available. Please try another.")
		return 0

	spawning = 1
	close_spawn_windows()

	SSjob.AssignRole(src, rank, 1)
	var/datum/job/job = src.mind.assigned_job
	var/mob/living/character = create_character()	//creates the human and transfers vars and mind

	// AIs don't need a spawnpoint, they must spawn at an empty core
	if(rank == "AI")

		character = character.AIize(move=0) // AIize the character, but don't move them yet

			// IsJobAvailable for AI checks that there is an empty core available in this list
		var/obj/structure/AIcore/deactivated/C = empty_playable_ai_cores[1]
		empty_playable_ai_cores -= C

		character.forceMove(C.loc)

		AnnounceArrival(character, rank, "has been downloaded to the empty core in \the [character.loc.loc]")

		qdel(C)
		qdel(src)
		return


	var/datum/spawnpoint/spawnpoint = SSjob.get_spawnpoint_for(character.client, rank, late = TRUE)
	spawnpoint.put_mob(character) // This can fail, and it'll result in the players being left in space and not being teleported to the station. But atleast they'll be equipped. Needs to be fixed so a default case for extreme situations is added.
	character = SSjob.EquipRank(character, rank) //equips the human
	equip_custom_items(character)
	character.lastarea = get_area(loc)

	if(SSjob.ShouldCreateRecords(job.title))
		if(character.mind.assigned_role != "Robot")
			CreateModularRecord(character)
			data_core.manifest_inject(character)
			matchmaker.do_matchmaking()
			SSticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.	//TODO!!!!! ~Carn

			//Grab some data from the character prefs for use in random news procs.

	AnnounceArrival(character, character.mind.assigned_role, spawnpoint.message)	//will not broadcast if there is no message



	qdel(src)

/mob/new_player/proc/LateChoices()
	var/name = client.prefs.be_random_name ? "friend" : client.prefs.real_name

	var/dat = "<html><body><center>"
	dat += "<b>Welcome, [name].<br></b>"
	dat += "Round Duration: [roundduration2text()]<br>"

	if(evacuation_controller.has_evacuated()) //In case Nanotrasen decides reposess CentCom's shuttles.
		dat += "<font color='red'><b>The vessel has been evacuated.</b></font><br>"
	else if(evacuation_controller.is_evacuating())
		if(evacuation_controller.emergency_evacuation) // Emergency shuttle is past the point of no recall
			dat += "<font color='red'>The vessel is currently undergoing evacuation procedures.</font><br>"
		else                                           // Crew transfer initiated
			dat += "<font color='red'>The vessel is currently undergoing crew transfer procedures.</font><br>"

	dat += "Choose from the following open/valid positions:<br>"
	for(var/datum/job/job in SSjob.occupations)
		if(job && IsJobAvailable(job.title))
			if(job.is_restricted(client.prefs))
				continue
			var/active = 0
			// Only players with the job assigned and AFK for less than 10 minutes count as active
			for(var/mob/M in GLOB.player_list) if(M.mind && M.client && M.mind.assigned_role == job.title && M.client.inactivity <= 10 * 60 * 10)
				active++
			dat += "<a href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title] ([job.current_positions]) (Active: [active])</a><br>"

	dat += "</center>"
	src << browse(dat, "window=latechoices;size=400x640;can_close=1")


/mob/new_player/proc/create_character()
	spawning = 1
	close_spawn_windows()

	var/mob/living/carbon/human/new_character

	var/use_species_name
	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = all_species[client.prefs.species]
		use_species_name = chosen_species.get_station_variant() //Only used by pariahs atm.

	if(chosen_species && use_species_name)
		// Have to recheck admin due to no usr at roundstart. Latejoins are fine though.
		if(is_species_whitelisted(chosen_species) || has_admin_rights())
			new_character = new(loc, use_species_name)

	if(!new_character)
		new_character = new(loc)

	new_character.lastarea = get_area(loc)

	for(var/lang in client.prefs.alternate_languages)
		var/datum/language/chosen_language = all_languages[lang]
		if(chosen_language)
			if(!(chosen_language.flags & WHITELISTED) || is_alien_whitelisted(src, lang) || has_admin_rights() \
				|| (new_character.species && (chosen_language.name in new_character.species.secondary_langs)))
				new_character.add_language(lang)

	if(mind)
		mind.active = 0//we wish to transfer the key manually
		mind.original = new_character
		if(client.prefs.relations.len)
			for(var/T in client.prefs.relations)
				var/TT = matchmaker.relation_types[T]
				var/datum/relation/R = new TT
				R.holder = mind
				R.info = client.prefs.relations_info[T]
			mind.gen_relations_info = client.prefs.relations_info["general"]
		mind.transfer_to(new_character)					//won't transfer key since the mind is not active

	if(SSticker.random_players)
		new_character.gender = pick(MALE, FEMALE)
		client.prefs.real_first_name = random_first_name(new_character.gender)
		client.prefs.real_last_name = random_last_name(new_character.gender)
		client.prefs.real_name = client.prefs.real_first_name + " " + client.prefs.real_last_name
		client.prefs.randomize_appearance_and_body_for(new_character)
	else
		client.prefs.copy_to(new_character)

	sound_to(src, sound(null, repeat = 0, wait = 0, volume = 85, channel = GLOB.lobby_sound_channel))

	new_character.name = real_name
	new_character.dna.ready_dna(new_character)
	new_character.dna.b_type = client.prefs.b_type
	new_character.sync_organ_dna()
	if(client.prefs.disabilities)
		// Set defer to 1 if you add more crap here so it only recalculates struc_enzymes once. - N3X
		new_character.dna.SetSEState(GLASSESBLOCK,1,0)
		new_character.disabilities |= NEARSIGHTED

	// And uncomment this, too.
	//new_character.dna.UpdateSE()

	// Do the initial caching of the player's body icons.
	new_character.force_update_limbs()
	new_character.update_eyes()
	new_character.regenerate_icons()
	new_character.key = key//Manually transfer the key to log them in

	return new_character

/mob/new_player/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, var/glide_size_override = 0)
	return 0

/mob/new_player/proc/close_spawn_windows()
	src << browse(null, "window=latechoices") //closes late choices window
	panel.close()

/mob/new_player/proc/is_species_whitelisted(datum/species/S)
	if(!S) return 1
	return is_alien_whitelisted(src, S.name) || !(S.spawn_flags & IS_WHITELISTED)

/mob/new_player/get_species()
	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = all_species[client.prefs.species]

	if(!chosen_species)
		return SPECIES_HUMAN

	if(is_species_whitelisted(chosen_species) || has_admin_rights())
		return chosen_species.name

	return SPECIES_HUMAN

/mob/new_player/get_gender()
	if(!client || !client.prefs) ..()
	return client.prefs.gender

/mob/new_player/is_ready()
	return ready && ..()

/mob/new_player/hear_say(var/message, var/verb = "says", var/datum/language/language = null, var/alt_name = "",var/italics = 0, var/mob/speaker = null)
	return

/mob/new_player/hear_radio(var/message, var/verb="says", var/datum/language/language=null, var/part_a, var/part_b, var/mob/speaker = null, var/hard_to_hear = 0)
	return

mob/new_player/MayRespawn()
	return 1

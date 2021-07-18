SUBSYSTEM_DEF(ticker)
	name = "Ticker"
	init_order = INIT_ORDER_TICKER
	priority = SS_PRIORITY_TICKER
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME
	wait = 1 SECONDS //Tick every second

	var/const/restart_timeout = 600
	var/current_state = GAME_STATE_STARTUP
	// If true, there is no lobby phase, the game starts immediately.
	var/start_immediately = FALSE

	//setup vars
	var/first_start_trying = TRUE
	var/story_vote_ended = FALSE

	var/event_time = null
	var/event = 0

	var/list/datum/mind/minds = list()//The people in the game. Used for objective tracking.

	var/random_players = 0 	// if set to nonzero, ALL players who latejoin or declare-ready join will have random appearances/genders

	var/list/syndicate_coalition = list() // list of traitor-compatible factions
	var/list/factions = list()			  // list of all factions
	var/list/availablefactions = list()	  // list of factions with openings

	var/pregame_timeleft = 180
	var/last_player_left_timestamp = 0

	var/delay_end = 0	//if set to nonzero, the round will not restart on it's own

	var/triai = 0//Global holder for Triumvirate

	var/quoted = FALSE

	var/round_end_announced = 0 // Spam Prevention. Announce round end only once.

	var/ship_was_nuked = 0              // See nuclearbomb.dm and malfunction.dm.
	var/ship_nuke_code = "NO CODE"       // Heads will get parts of this code.
	var/ship_nuke_code_rotation_part = 1 // What part of code next Head will get.
	var/nuke_in_progress = 0           	// Sit back and relax

	var/newscaster_announcements = null

	//station_explosion used to be a variable for every mob's hud. Which was a waste!
	//Now we have a general cinematic centrally held within the gameticker....far more efficient!
	var/obj/screen/cinematic = null

/datum/controller/subsystem/ticker/Initialize(start_timeofday)
	if(!syndicate_code_phrase)
		syndicate_code_phrase = generate_code_phrase()
	if(!syndicate_code_response)
		syndicate_code_response = generate_code_phrase()

	setup_objects()
	setup_genetics()
	setup_huds()

	return ..()

/datum/controller/subsystem/ticker/proc/setup_objects()
	populate_antag_type_list() // Set up antagonists. Do these first since character setup will rely on them

/datum/controller/subsystem/ticker/proc/setup_huds()
	global_hud = new()
	global_huds = list(
		global_hud.druggy,
		global_hud.blurry,
		global_hud.vimpaired,
		global_hud.darkMask,
		global_hud.nvg,
		global_hud.thermal,
		global_hud.meson,
		global_hud.science,
		global_hud.holomap)

/datum/controller/subsystem/ticker/fire()
	switch(current_state)
		if(GAME_STATE_STARTUP)
			if(first_start_trying)
				pregame_timeleft = initial(pregame_timeleft)
				to_chat(world, "<B><FONT color='blue'>Welcome to the pre-game lobby!</FONT></B>")
			else
				pregame_timeleft = 40

			if(!start_immediately)
				to_chat(world, "Please, setup your character and select ready. Game will start in [pregame_timeleft] seconds.")
			current_state = GAME_STATE_PREGAME
			send_assets()

		if(GAME_STATE_PREGAME)
			if(start_immediately)
				pregame_timeleft = 0

			if(!process_empty_server())
				return

			if(round_progressing)
				pregame_timeleft--

			if(!quoted)
				send_quote_of_the_round()
				quoted = TRUE

			if(!story_vote_ended && (pregame_timeleft == config.vote_autogamemode_timeleft || !first_start_trying))
				if(!SSvote.active_vote)
					SSvote.autostoryteller()	//Quit calling this over and over and over and over.

			if(pregame_timeleft <= 0)
				current_state = GAME_STATE_SETTING_UP
				Master.SetRunLevel(RUNLEVEL_SETUP)

			first_start_trying = FALSE

		if(GAME_STATE_SETTING_UP)
			if(!setup())
				//setup failed
				current_state = GAME_STATE_STARTUP
				Master.SetRunLevel(RUNLEVEL_LOBBY)

		if(GAME_STATE_PLAYING)
//storytodo			GLOB.storyteller.Process()
//storytodo			GLOB.storyteller.process_events()

			if(!process_empty_server())
				return

			var/game_finished = (evacuation_controller.round_over() || ship_was_nuked  || universe_has_ended)

			if(!nuke_in_progress && game_finished)
				current_state = GAME_STATE_FINISHED
				Master.SetRunLevel(RUNLEVEL_POSTGAME)

				spawn
					declare_completion()

				spawn(50)
					callHook("roundend")

					if(universe_has_ended)
						if(!delay_end)
							to_chat(world, SPAN_NOTICE("<b>Rebooting due to destruction of ship in [restart_timeout/10] seconds</b>"))
					else
						if(!delay_end)
							to_chat(world, SPAN_NOTICE("<b>Restarting in [restart_timeout/10] seconds</b>"))


					if(!delay_end)
						sleep(restart_timeout)
						if(!delay_end)
							world.Reboot()
						else
							to_chat(world, SPAN_NOTICE("<b>An admin has delayed the round end</b>"))
					else
						to_chat(world, SPAN_NOTICE("<b>An admin has delayed the round end</b>"))

// This proc will scan for player and if the game is in progress and...
// there is no player for certain minutes (see config.empty_server_restart_time) it will restart the server and return FALSE
// If the game in pregame state if will reset roundstart timer and return FALSE
// otherwise it will return TRUE
// will also return TRUE if its currently counting down to server's restart after last player left

/datum/controller/subsystem/ticker/proc/process_empty_server()
	if(!config.empty_server_restart_time)
		return TRUE
	switch(current_state)
		if(GAME_STATE_PLAYING)
			if(clients.len)
				// Resets countdown if any player connects on empty server
				if(last_player_left_timestamp)
					last_player_left_timestamp = 0
				return TRUE
			else
				// Last player left so we store the time when he left
				if(!last_player_left_timestamp)
					last_player_left_timestamp = world.time
					return TRUE
				// Counting down the world's end
				else if (world.time >= last_player_left_timestamp + (config.empty_server_restart_time MINUTES))
					last_player_left_timestamp = 0
					log_game("\[Server\] No players were on a server last [config.empty_server_restart_time] minutes, restarting server...")
					world.Reboot()
					return FALSE
		if(GAME_STATE_PREGAME)
			if(!clients.len)
				// if pregame and no player we break fire() execution so no countdown will be done
				if(pregame_timeleft == initial(pregame_timeleft))
					return FALSE
				// Resetting countdown time
				else
					pregame_timeleft = initial(pregame_timeleft)
					quoted = FALSE
					return FALSE
	return TRUE

/datum/controller/subsystem/ticker/proc/setup()
	//Create and announce mode
/* STORYTODO
	if(!GLOB.storyteller)
		set_storyteller(announce = FALSE)

	if(!GLOB.storyteller)
		to_chat(world, "<span class='danger'>Serious error storyteller system!</span> Reverting to pre-game lobby.")
		return FALSE

	SSjob.ResetOccupations()
	SSjob.DivideOccupations() // Apparently important for new antagonist system to register specific job antags properly.

	if(!GLOB.storyteller.can_start(TRUE))
		to_chat(world, "<B>Unable to start game.</B> Reverting to pre-game lobby.")
		//GLOB.storyteller = null //Possibly bring this back in future if we have storytellers with differing requirements
		//story_vote_ended = FALSE
		SSjob.ResetOccupations()
		return FALSE

	GLOB.storyteller.announce()
*/
	setup_economy()
	newscaster_announcements = pick(newscaster_standard_feeds)
	current_state = GAME_STATE_PLAYING
	Master.SetRunLevel(RUNLEVEL_GAME)
	create_characters() //Create player characters and transfer them
	collect_minds()
	move_characters_to_spawnpoints()
	equip_characters()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(!H.mind || player_is_antag(H.mind, only_offstation_roles = 1) || !SSjob.ShouldCreateRecords(H.mind.assigned_role))
			continue
		CreateModularRecord(H)
	data_core.manifest()

	callHook("roundstart")

	spawn(0)//Forking here so we dont have to wait for this to finish
//storytodo		GLOB.storyteller.set_up()
		to_chat(world, "<FONT color='blue'><B>Enjoy the game!</B></FONT>")
		world << sound('sound/AI/welcome.ogg') // Skie
		//Holiday Round-start stuff	~Carn
		Holiday_Game_Start()

		for(var/mob/new_player/N in SSmobs.mob_list)
			N.new_player_panel_proc()

		generate_contracts(min(6 + round(minds.len / 5), 12))
		generate_excel_contracts(min(6 + round(minds.len / 5), 12))
		excel_check()
		addtimer(CALLBACK(src, .proc/contract_tick), 15 MINUTES)
	//start_events() //handles random events and space dust.
	//new random event system is handled from the MC.

	var/admins_number = 0
	for(var/client/C)
		if(C.holder)
			admins_number++
	if(admins_number == 0)
		send2adminirc("Round has started with no admins online.")

	return TRUE

// Provides an easy way to make cinematics for other events. Just use this as a template :)
/datum/controller/subsystem/ticker/proc/station_explosion_cinematic(var/ship_missed = 0)
	if(cinematic)
		return	//already a cinematic in progress!

	if(ship_missed)
		world << sound('sound/effects/explosionfar.ogg')
		return	//bomb missed the ship

	//initialise our cinematic screen object
	cinematic = new(src)
	cinematic.icon = 'icons/effects/station_explosion.dmi'
	cinematic.icon_state = "station_intact"
	cinematic.plane = CINEMATIC_PLANE
	cinematic.layer = CINEMATIC_LAYER
	cinematic.mouse_opacity = 0
	cinematic.screen_loc = "1,0"

	for(var/mob/M in SSmobs.mob_list)
		if(isOnStationLevel(M))
			if(M.client)
				M.client.screen += cinematic
			if(isliving(M))
				var/mob/living/LM = M
				LM.health = 0
				LM.stat = DEAD

	//Now animate the cinematic
	sleep(30)

	FLICK("intro_nuke", cinematic)

	sleep(30)

	FLICK("ship_explode_fade_red", cinematic)

	sleep(15)

	world << sound('sound/effects/explosionfar.ogg')

	sleep(5)

	world << sound('sound/effects/explosionfar.ogg')

	sleep(4)

	world << sound('sound/effects/explosionfar.ogg')

	sleep(6)

	world << sound('sound/effects/explosionfar.ogg')
	world << sound('sound/effects/explosionfar.ogg')
	world << sound('sound/effects/explosionfar.ogg')

	sleep(30)

	cinematic.icon_state = "summary_selfdes"
	//If its actually the end of the round, wait for it to end.
	//Otherwise if its a verb it will continue on afterwards.
	sleep(300)

	if(cinematic)
		qdel(cinematic)		//end the cinematic

/datum/controller/subsystem/ticker/proc/get_next_nuke_code_part() // returns code string as "XX56XX"
	var/this_many = 2 // how many digits to return (this proc only tested with this value and 6 digit passwords).

	if(ship_nuke_code == initial(ship_nuke_code) || length(ship_nuke_code) < this_many)
		return initial(ship_nuke_code)

	var/part_of_code = "[copytext(ship_nuke_code, ship_nuke_code_rotation_part, ship_nuke_code_rotation_part + this_many)]"
	var/hidden_digit = "X"

	if(ship_nuke_code_rotation_part > 1)
		. = add_characters(hidden_digit, ship_nuke_code_rotation_part - 1) + part_of_code + add_characters(hidden_digit, length(ship_nuke_code) - ship_nuke_code_rotation_part - 1)
	else
		. = part_of_code + add_characters(hidden_digit, length(ship_nuke_code) - this_many)

	ship_nuke_code_rotation_part += this_many // new head of staff gets next this_many digits
	if(ship_nuke_code_rotation_part > length(ship_nuke_code)) // or we start over if we moved out of range
		ship_nuke_code_rotation_part = 1

/datum/controller/subsystem/ticker/proc/send_quote_of_the_round()
	var/message
	var/list/quotes = file2list("strings/quotes.txt")
	if(quotes.len)
		message = pick(quotes)
	if(message)
		to_chat(world, SPAN_NOTICE("<font color='purple'><b>Quote of the round: </b>[html_encode(message)]</font>"))

/datum/controller/subsystem/ticker/proc/create_characters()
	for(var/mob/new_player/player in GLOB.player_list)
		if(player && player.ready && player.mind)
			if(player.mind.assigned_role == "AI")
				player.close_spawn_windows()
				player.AIize()
			else if(!player.mind.assigned_role)
				continue
			else
				player.create_character()
				qdel(player)


/datum/controller/subsystem/ticker/proc/collect_minds()
	for(var/mob/living/player in GLOB.player_list)
		if(player.mind)
			SSticker.minds |= player.mind

/datum/controller/subsystem/ticker/proc/generate_contracts(count)
	var/list/candidates = (subtypesof(/datum/antag_contract) - typesof(/datum/antag_contract/excel))
	while(count--)
		while(candidates.len)
			var/contract_type = pick(candidates)
			var/datum/antag_contract/C = new contract_type
			if(!C.can_place())
				candidates -= contract_type
				qdel(C)
				continue
			C.place()
			if(C.unique)
				candidates -= contract_type
			break

/datum/controller/subsystem/ticker/proc/generate_excel_contracts(count)
	var/list/candidates = subtypesof(/datum/antag_contract/excel)
	while(count--)
		while(candidates.len)
			var/contract_type = pick(candidates)
			var/datum/antag_contract/C = new contract_type
			if(!C.can_place())
				candidates -= contract_type
				qdel(C)
				continue
			C.place()
			if(C.unique)
				candidates -= contract_type
			break

/datum/controller/subsystem/ticker/proc/excel_check()

	for(var/datum/antag_contract/excel/targeted/overthrow/M in GLOB.excel_antag_contracts)
		var/mob/living/carbon/human/H = M.target_mind.current
		if (H.stat == DEAD || is_excelsior(H))
			M.complete()

	for(var/datum/antag_contract/excel/targeted/liberate/M in GLOB.excel_antag_contracts)
		var/mob/living/carbon/human/H = M.target_mind.current
		if (is_excelsior(H))
			M.complete()

	for(var/datum/antag_contract/excel/propaganda/M in GLOB.excel_antag_contracts)
		var/list/area/targets = M.targets
		var/marked_areas = 0
		if(M.completed)
			return
		for (var/obj/item/device/propaganda_chip/C in SSobj.processing) // Doubles as an active check
			if (get_area(C) in targets)
				marked_areas += 1
		if (marked_areas >= 3)
			M.complete()
	addtimer(CALLBACK(src, .proc/excel_check), 3 MINUTES)

/datum/controller/subsystem/ticker/proc/contract_tick()
	generate_contracts(1)
	generate_excel_contracts(1)
	addtimer(CALLBACK(src, .proc/contract_tick), 15 MINUTES)


/datum/controller/subsystem/ticker/proc/equip_characters()
	var/captainless = TRUE
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(player && player.mind && player.mind.assigned_role)
			if(player.mind.assigned_role == "Captain")
				captainless = FALSE
			if(!player_is_antag(player.mind, only_offstation_roles = 1))
				SSjob.EquipRank(player, player.mind.assigned_role)
				equip_custom_items(player)
	if(captainless)
		for(var/mob/M in GLOB.player_list)
			if(!isnewplayer(M))
				to_chat(M, "Captainship not forced on anyone.")

/datum/controller/subsystem/ticker/proc/move_characters_to_spawnpoints()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		var/datum/spawnpoint/SP = SSjob.get_spawnpoint_for(player.client, player.mind.assigned_role)
		SP.put_mob(player)


/datum/controller/subsystem/ticker/proc/declare_completion()
	to_chat(world, "<br><br><br><H1>A round has ended!</H1>")
	for(var/mob/Player in GLOB.player_list)
		if(Player.mind && !isnewplayer(Player))
			if(Player.stat != DEAD)
				var/turf/playerTurf = get_turf(Player)
				if(evacuation_controller.round_over() && evacuation_controller.emergency_evacuation)
					if(isNotAdminLevel(playerTurf.z))
						to_chat(Player, "<font color='blue'><b>You managed to survive, but were marooned on [station_name()] as [Player.real_name]...</b></font>")
					else
						to_chat(Player, "<font color='green'><b>You managed to survive the events on [station_name()] as [Player.real_name].</b></font>")
				else if(isAdminLevel(playerTurf.z))
					to_chat(Player, "<font color='green'><b>You successfully underwent crew transfer after events on [station_name()] as [Player.real_name].</b></font>")
				else if(issilicon(Player))
					to_chat(Player, "<font color='green'><b>You remain operational after the events on [station_name()] as [Player.real_name].</b></font>")
				else
					to_chat(Player, "<font color='blue'><b>You missed the crew transfer after the events on [station_name()] as [Player.real_name].</b></font>")
			else
				if(isghost(Player))
					var/mob/observer/ghost/O = Player
					if(!O.started_as_observer)
						to_chat(Player, "<font color='red'><b>You did not survive the events on [station_name()]...</b></font>")
				else
					to_chat(Player, "<font color='red'><b>You did not survive the events on [station_name()]...</b></font>")
	to_chat(world, "<br>")

	for(var/mob/living/silicon/ai/aiPlayer in SSmobs.mob_list)
		if(aiPlayer.stat != DEAD)
			to_chat(world, "<b>[aiPlayer.name] (Played by: [aiPlayer.key])'s laws at the end of the round were:</b>")
		else
			to_chat(world, "<b>[aiPlayer.name] (Played by: [aiPlayer.key])'s laws when it was deactivated were:</b>")
		aiPlayer.show_laws(TRUE)

		if(aiPlayer.connected_robots.len)
			var/robolist = "<b>The AI's loyal minions were:</b> "
			for(var/mob/living/silicon/robot/robo in aiPlayer.connected_robots)
				robolist += "[robo.name][robo.stat?" (Deactivated) (Played by: [robo.key]), ":" (Played by: [robo.key]), "]"
			to_chat(world, "[robolist]")



	for(var/mob/living/silicon/robot/robo in SSmobs.mob_list)
		if(!isdrone(robo) && !robo.connected_ai)
			if(robo.stat != 2)
				to_chat(world, "<b>[robo.name] (Played by: [robo.key]) survived as an AI-less synthetic! Its laws were:</b>")
			else
				to_chat(world, "<b>[robo.name] (Played by: [robo.key]) was unable to survive the rigors of being a synthetic without an AI. Its laws were:</b>")

			if(robo) //How the hell do we lose robo between here and the world messages directly above this?
				robo.laws.show_laws(world)
	var/dronecount = GLOB.drones.len
	if(dronecount)
		to_chat(world, "<b>There [dronecount>1 ? "were" : "was"] [dronecount] industrious maintenance [dronecount>1 ? "drones" : "drone"] at the end of this round.</b>")

//storytodo	GLOB.storyteller.declare_completion()//To declare normal completion.
	scoreboard()//scores
	//Ask the event manager to print round end information
	SSevent.RoundEnd()

	//Print a list of antagonists to the server log
	var/list/total_antagonists = list()
	//Look into all mobs in world, dead or alive
	for(var/datum/antagonist/antag in GLOB.current_antags)
		var/temprole = antag.id
		if(temprole && antag.owner)							//if they are an antagonist of some sort.
			if(!(temprole in total_antagonists))	//If the role doesn't exist in list, create it
				total_antagonists.Add(temprole)
			total_antagonists[temprole] += ", [antag.owner.name]([antag.owner.key])"


	//Now print them all into the log!
	log_game("Antagonists at round end were...")
	for(var/i in total_antagonists)
		log_game("[i]s[total_antagonists[i]].")

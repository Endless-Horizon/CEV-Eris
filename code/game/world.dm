
#define RECOMMENDED_VERSION 512
#define RESTART_COUNTER_PATH "data/round_counter.txt"

GLOBAL_VAR(restart_counter)

/**
 * World creation
 *
 * Here is where a round itself is actually begun and setup.
 * * db connection setup
 * * config loaded from files
 * * loads admins
 * * Sets up the dynamic menu system
 * * and most importantly, calls initialize on the master subsystem, starting the game loop that causes the rest of the game to begin processing and setting up
 *
 *
 * Nothing happens until something moves. ~Albert Einstein
 *
 * For clarity, this proc gets triggered later in the initialization pipeline, it is not the first thing to happen, as it might seem.
 *
 * Initialization Pipeline:
 * Global vars are new()'ed, (including config, glob, and the master controller will also new and preinit all subsystems when it gets new()ed)
 * Compiled in maps are loaded (mainly centcom). all areas/turfs/objs/mobs(ATOMs) in these maps will be new()ed
 * world/New() (You are here)
 * Once world/New() returns, client's can connect.
 * 1 second sleep
 * Master Controller initialization.
 * Subsystem initialization.
 * Non-compiled-in maps are maploaded, all atoms are new()ed
 * All atoms in both compiled and uncompiled maps are initialized()
 */
/world/New()
	extools_initialize()
	maptick_initialize()
	debugger_initialize()
	enable_debugger() // spaceman dmm

	if(byond_version < RECOMMENDED_VERSION)
		log_world("Your server's byond version does not meet the recommended requirements for this server. Please update BYOND")


	generate_gameid()
	load_configuration()

	//logs
	var/date_string = time2text(world.realtime, "YYYY/MM-Month/DD-Day")
	href_logfile = file("data/logs/[date_string] hrefs.htm")
	diary = file("data/logs/[date_string].log")
	diary << "[log_end]\n[log_end]\nStarting up. (ID: [game_id]) [time2text(world.timeofday, "hh:mm.ss")][log_end]\n---------------------[log_end]"
	// end CRAM based logging approach

	log_world("World loaded at [time_stamp()]!")


	makeDatumRefLists() //initialises global lists for referencing frequently used datums (so that we only ever do it once)

	GLOB.config_error_log = GLOB.world_manifest_log = GLOB.world_pda_log = GLOB.world_job_debug_log = GLOB.sql_error_log = GLOB.world_href_log = GLOB.world_runtime_log = GLOB.world_attack_log = GLOB.world_game_log = GLOB.world_shuttle_log = "data/logs/config_error.[GUID()].log" //temporary file used to record errors with loading config, moved to log directory once logging is set bl //GLOB.world_econ_log =

	GLOB.revdata = new

	config_tg.Load(params[OVERRIDE_CONFIG_DIRECTORY_PARAMETER])
	// old cfg
	config.post_load()

	if(config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"

	load_mods()

	generate_body_modification_lists()

	//SetupLogs depends on the RoundID, so lets check
	//DB schema and set RoundID if we can
	// SSdbcore.CheckSchemaVersion()
	// SSdbcore.SetRoundID()
	SetupLogs()
	// load_poll_data()

#ifndef USE_CUSTOM_ERROR_HANDLER
	world.log = file("[GLOB.log_directory]/dd.log")
#endif
// 	if (TgsAvailable())
// 		world.log = file("[GLOB.log_directory]/dd.log") //not all runtimes trigger world/Error, so this is the only way to ensure we can see all of them.
// #endif


	// This is kinda important. Set up details of what the hell things are made of.
	populate_material_list()

	initialize_chemical_reagents()
	initialize_chemical_reactions()
	initialize_integrated_circuits_list()

	// Set up roundstart seed list AFTER CHEM **INITIALIZES**
	plant_controller = new()

	// GLOB.timezoneOffset = text2num(time2text(0,"hh")) * 36000

	if(fexists(RESTART_COUNTER_PATH))
		GLOB.restart_counter = text2num(trim(file2text(RESTART_COUNTER_PATH)))
		fdel(RESTART_COUNTER_PATH)

	if(NO_INIT_PARAMETER in params)
		return

	Master.Initialize(10, FALSE, TRUE)

	// sync based startup, hook delays the init!!!
	callHook("startup_sync")
	_addtimer(CALLBACK(GLOBAL_PROC, .proc/callHook, "startup"), 5 SECONDS) // fixes 90% of the race conditions
	call_restart_webhook()

#ifdef UNIT_TEST
	HandleTestRun()
#endif

	if(config.ToRban)
		_addtimer(CALLBACK(GLOBAL_PROC, .proc/ToRban_autoupdate), 20 SECONDS)

	return

/world/proc/HandleTestRun()
	//trigger things to run the whole process
	Master.sleep_offline_after_initializations = FALSE
	SSticker.start_immediately = TRUE
	// CONFIG_SET(number/round_end_countdown, 0)
	var/datum/callback/cb
#ifdef UNIT_TESTS
	cb = CALLBACK(GLOBAL_PROC, /proc/initialize_unit_tests)
// #else
// 	cb = VARSET_CALLBACK(SSticker, force_ending, TRUE)
#endif
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, /proc/_addtimer, cb, 10 SECONDS))


/world/proc/SetupLogs()
	var/override_dir = params[OVERRIDE_LOG_DIRECTORY_PARAMETER]
	if(!override_dir)
		var/realtime = world.realtime
		var/texttime = time2text(realtime, "YYYY/MM/DD")
		GLOB.log_directory = "data/logs/[texttime]/round-"
		GLOB.picture_logging_prefix = "L_[time2text(realtime, "YYYYMMDD")]_"
		GLOB.picture_log_directory = "data/picture_logs/[texttime]/round-"
		if(GLOB.round_id)
			GLOB.log_directory += "[GLOB.round_id]"
			GLOB.picture_logging_prefix += "R_[GLOB.round_id]_"
			GLOB.picture_log_directory += "[GLOB.round_id]"
		else
			var/timestamp = replacetext(time_stamp(), ":", ".")
			GLOB.log_directory += "[timestamp]"
			GLOB.picture_log_directory += "[timestamp]"
			GLOB.picture_logging_prefix += "T_[timestamp]_"
	else
		GLOB.log_directory = "data/logs/[override_dir]"
		GLOB.picture_logging_prefix = "O_[override_dir]_"
		GLOB.picture_log_directory = "data/picture_logs/[override_dir]"

	GLOB.world_game_log = "[GLOB.log_directory]/game.log"
	// GLOB.world_mecha_log = "[GLOB.log_directory]/mecha.log"
	// GLOB.world_virus_log = "[GLOB.log_directory]/virus.log"
	// GLOB.world_cloning_log = "[GLOB.log_directory]/cloning.log"
	GLOB.world_asset_log = "[GLOB.log_directory]/asset.log"
	GLOB.world_attack_log = "[GLOB.log_directory]/attack.log"
	// GLOB.world_econ_log = "[GLOB.log_directory]/econ.log"
	GLOB.world_pda_log = "[GLOB.log_directory]/pda.log"
	GLOB.world_uplink_log = "[GLOB.log_directory]/uplink.log"
	GLOB.world_telecomms_log = "[GLOB.log_directory]/telecomms.log"
	GLOB.world_manifest_log = "[GLOB.log_directory]/manifest.log"
	GLOB.world_href_log = "[GLOB.log_directory]/hrefs.log"
	GLOB.sql_error_log = "[GLOB.log_directory]/sql.log"
	GLOB.world_qdel_log = "[GLOB.log_directory]/qdel.log"
	GLOB.world_map_error_log = "[GLOB.log_directory]/map_errors.log"
	GLOB.world_runtime_log = "[GLOB.log_directory]/runtime.log"
	GLOB.query_debug_log = "[GLOB.log_directory]/query_debug.log"
	GLOB.world_job_debug_log = "[GLOB.log_directory]/job_debug.log"
	GLOB.world_paper_log = "[GLOB.log_directory]/paper.log"
	GLOB.tgui_log = "[GLOB.log_directory]/tgui.log"
	GLOB.world_shuttle_log = "[GLOB.log_directory]/shuttle.log"

	GLOB.demo_log = "[GLOB.log_directory]/demo.log"

#ifdef UNIT_TESTS
	GLOB.test_log = "[GLOB.log_directory]/tests.log"
	start_log(GLOB.test_log)
#endif
	start_log(GLOB.world_game_log)
	start_log(GLOB.world_attack_log)
	// start_log(GLOB.world_econ_log)
	start_log(GLOB.world_pda_log)
	start_log(GLOB.world_uplink_log)
	start_log(GLOB.world_telecomms_log)
	start_log(GLOB.world_manifest_log)
	start_log(GLOB.world_href_log)
	start_log(GLOB.world_qdel_log)
	start_log(GLOB.world_runtime_log)
	start_log(GLOB.world_job_debug_log)
	start_log(GLOB.tgui_log)
	start_log(GLOB.world_shuttle_log)

	var/latest_changelog = file("[global.config_tg.directory]/../html/changelogs/archive/" + time2text(world.timeofday, "YYYY-MM") + ".yml")
	GLOB.changelog_hash = fexists(latest_changelog) ? md5(latest_changelog) : 0 //for telling if the changelog has changed recently
	if(fexists(GLOB.config_error_log))
		fcopy(GLOB.config_error_log, "[GLOB.log_directory]/config_error.log")
		fdel(GLOB.config_error_log)

	if(GLOB.round_id)
		log_game("Round ID: [GLOB.round_id]")

	// This was printed early in startup to the world log and config_error.log,
	// but those are both private, so let's put the commit info in the runtime
	// log which is ultimately public.
	log_runtime(GLOB.revdata.get_log_message())

var/world_topic_spam_protect_ip = "0.0.0.0"
var/world_topic_spam_protect_time = world.timeofday

/world/Topic(T, addr, master, key)
	var/list/topic_handlers = WorldTopicHandlers()

	var/list/input = params2list(T)
	var/datum/world_topic/handler
	for(var/I in topic_handlers)
		if(I in input)
			handler = topic_handlers[I]
			break

	if((!handler || initial(handler.log)) && config)
		log_topic("\"[T]\", from:[addr], master:[master], key:[key]")

	if(!handler)
		return

	handler = new handler()
	return handler.TryRun(input)

/world/proc/FinishTestRun()
	set waitfor = FALSE
	var/list/fail_reasons
	if(GLOB)
		if(GLOB.total_runtimes != 0)
			fail_reasons = list("Total runtimes: [GLOB.total_runtimes]")
#ifdef UNIT_TESTS
		if(GLOB.failed_any_test)
			LAZYADD(fail_reasons, "Unit Tests failed!")
#endif
		if(!GLOB.log_directory)
			LAZYADD(fail_reasons, "Missing GLOB.log_directory!")
	else
		fail_reasons = list("Missing GLOB!")
	if(!fail_reasons)
		text2file("Success!", "[GLOB.log_directory]/clean_run.lk")
	else
		log_world("Test run failed!\n[fail_reasons.Join("\n")]")
	sleep(0) //yes, 0, this'll let Reboot finish and prevent byond memes
	qdel(src) //shut it down

/world/Reboot(reason = 0, fast_track = FALSE)
	if (reason || fast_track) //special reboot, do none of the normal stuff
		if (usr)
			log_admin("[key_name(usr)] Has requested an immediate world restart via client side debugging tools")
			message_admins("[key_name_admin(usr)] Has requested an immediate world restart via client side debugging tools")
		to_chat(world, "<span class='boldannounce'>Rebooting World immediately due to host request.</span>")
	else
		to_chat(world, "<span class='boldannounce'>Rebooting world...</span>")
		Master.Shutdown() //run SS shutdowns

	#ifdef UNIT_TESTS
	FinishTestRun()
	return
	#endif

	for(var/client/C in clients)
		if(config.server)	//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[config.server]")

	log_world("World rebooted at [time_stamp()]")

	// TgsReboot()
	shutdown_logging() // Past this point, no logging procs can be used, at risk of data loss.
	..()

/hook/startup/proc/loadMode()
	world.load_storyteller()
	return 1

/world/proc/load_storyteller()
	var/list/Lines = file2list("data/mode.txt")
	if(Lines.len)
		if(Lines[1])
			master_storyteller = Lines[1]
			log_misc("Saved storyteller is '[master_storyteller]'")

/world/proc/save_storyteller(var/the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	F << the_mode

/hook/startup/proc/loadMOTD()
	world.load_motd()
	return 1

/world/proc/load_motd()
	join_motd = file2text("config/motd.txt")


/proc/load_configuration()
	config = new /datum/configuration()
	config.load("config/config.txt")
	config.load("config/game_options.txt", "game_options")
	config.loadsql("config/dbconfig.txt")

/hook/startup/proc/loadMods()
	world.load_mods()
	world.load_mentors() // no need to write another hook.
	return 1

/world/proc/load_mods()
	if(config.admin_legacy_system)
		var/text = file2text("config/moderators.txt")
		if (!text)
			error("Failed to load config/mods.txt")
		else
			var/list/lines = splittext(text, "\n")
			for(var/line in lines)
				if (!line)
					continue

				if (copytext(line, 1, 2) == ";")
					continue

				var/title = "Moderator"
				var/rights = admin_ranks[title]

				var/ckey = copytext(line, 1, length(line)+1)
				var/datum/admins/D = new /datum/admins(title, rights, ckey)
				D.associate(directory[ckey])

/world/proc/load_mentors()
	if(config.admin_legacy_system)
		var/text = file2text("config/mentors.txt")
		if (!text)
			error("Failed to load config/mentors.txt")
		else
			var/list/lines = splittext(text, "\n")
			for(var/line in lines)
				if (!line)
					continue
				if (copytext(line, 1, 2) == ";")
					continue

				var/title = "Mentor"
				var/rights = admin_ranks[title]

				var/ckey = copytext(line, 1, length(line)+1)
				var/datum/admins/D = new /datum/admins(title, rights, ckey)
				D.associate(directory[ckey])

/world/proc/update_status()
	var/s = ""

	if (config && config.server_name)
		s += "<b>[config.server_name]</b> &#8212; "

	s += "<b>[station_name()]</b>";
	s += " ("
	s += "<a href=\"http://\">" //Change this to wherever you want the hub to link to.
//	s += "[game_version]"
	s += "Default"  //Replace this with something else. Or ever better, delete it and uncomment the game version.
	s += "</a>"
	s += ")"

	var/list/features = list()

	if(SSticker)
		if(master_storyteller)
			features += master_storyteller
	else
		features += "<b>STARTING</b>"

	if (!config.enter_allowed)
		features += "closed"

	features += config.abandon_allowed ? "respawn" : "no respawn"

	if (config && config.allow_vote_mode)
		features += "vote"

	if (config && config.allow_ai)
		features += "AI allowed"

	var/n = 0
	for (var/mob/M in GLOB.player_list)
		if (M.client)
			n++

	if (n > 1)
		features += "~[n] players"
	else if (n > 0)
		features += "~[n] player"


	if (config && config.hostedby)
		features += "hosted by <b>[config.hostedby]</b>"

	if (features)
		s += ": [jointext(features, ", ")]"

	/* does this help? I do not know */
	if (src.status != s)
		src.status = s

#define FAILED_DB_CONNECTION_CUTOFF 5
var/failed_db_connections = 0
var/failed_old_db_connections = 0

/hook/startup_sync/proc/connectDB()
	if(!setup_database_connection())
		log_world("Your server failed to establish a connection with the feedback database.")
	else
		log_world("Feedback database connection established.")
	return 1

proc/setup_database_connection()

	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to conenct anymore.
		return 0

	if(!dbcon)
		dbcon = new()

	var/user = sqllogin
	var/pass = sqlpass
	var/db = sqldb
	var/address = sqladdress
	var/port = sqlport

	dbcon.Connect("dbi:mysql:[db]:[address]:[port]", "[user]", "[pass]")
	. = dbcon.IsConnected()
	if ( . )
		failed_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		failed_db_connections++		//If it failed, increase the failed connections counter.
		log_world(dbcon.ErrorMsg())

	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
proc/establish_db_connection()
	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	if(!dbcon || !dbcon.IsConnected())
		return setup_database_connection()
	else
		return 1

/world/proc/incrementMaxZ()
	maxz++
	SSmobs.MaxZChanged()

/world/proc/change_fps(new_value = 20)
	if(new_value <= 0)
		CRASH("change_fps() called with [new_value] new_value.")
	if(fps == new_value)
		return //No change required.

	fps = new_value
	on_tickrate_change()


/world/proc/change_tick_lag(new_value = 0.5)
	if(new_value <= 0)
		CRASH("change_tick_lag() called with [new_value] new_value.")
	if(tick_lag == new_value)
		return //No change required.

	tick_lag = new_value
	on_tickrate_change()


/world/proc/on_tickrate_change()
	SStimer?.reset_buckets()


var/game_id
/proc/generate_gameid()
	if(game_id != null)
		return
	game_id = ""

	var/list/c = list("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	var/l = c.len

	var/t = world.timeofday
	for(var/_ = 1 to 4)
		game_id = "[c[(t % l) + 1]][game_id]"
		t = round(t / l)
	game_id = "-[game_id]"
	t = round(world.realtime / (10 * 60 * 60 * 24))
	for(var/_ = 1 to 3)
		game_id = "[c[(t % l) + 1]][game_id]"
		t = round(t / l)

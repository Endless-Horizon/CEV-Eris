
/*
	The initialization of the game happens roughly like this:

	1. All global variables are initialized (including the global_init and tgstation's master controller instances including subsystems).
	2. The map is initialized, and map objects are created.
	3. world/New() runs.
	4. tgstation's MC runs initialization for various subsystems (refer to its own defines for the load order).

*/
var/global/datum/global_init/init = new ()

/*
	Pre-map initialization stuff should go here.
*/

/datum/global_init/New()
	generate_gameid()
	load_configuration()
	makeDatumRefLists()

	initialize_chemical_reagents()
	initialize_chemical_reactions()
	initialize_integrated_circuits_list()

	qdel(src) //we're done

/datum/global_init/Destroy()
	return 1

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

#define RECOMMENDED_VERSION 512

/**
 * World creation
 *
 * Here is where a round itself is actually begun and setup.
 * * db connection setup
 * * config loaded from files
 * * loads admins
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
	// Begin loading of extools DLL and components
	if(world.system_type == MS_WINDOWS) // IT ONLY WORKS ON WINDOWS
		extools_initialize()
		maptick_initialize()
		debugger_initialize()
	// End extools
	//logs
	var/date_string = time2text(world.realtime, "YYYY/MM-Month/DD-Day")
	href_logfile = file("data/logs/[date_string] hrefs.htm")
	diary = file("data/logs/[date_string].log")
	diary << "[log_end]\n[log_end]\nStarting up. (ID: [game_id]) [time2text(world.timeofday, "hh:mm.ss")][log_end]\n---------------------[log_end]"
	changelog_hash = md5('html/changelog.html')					//used for telling if the changelog has changed recently

	world_qdel_log = file("data/logs/[date_string] qdel.log")	// GC Shutdown log

	if(byond_version < RECOMMENDED_VERSION)
		log_world("Your server's byond version does not meet the recommended requirements for this server. Please update BYOND")

	config.post_load()

	if(config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"

	callHook("startup")
	//Emergency Fix
	load_mods()
	//end-emergency fix

	generate_body_modification_lists()

	update_status()

	. = ..()

	// Set up roundstart seed list.
	plant_controller = new()

	// This is kinda important. Set up details of what the hell things are made of.
	populate_material_list()

	if(NO_INIT_PARAMETER in params)
		return

	Master.Initialize(10, FALSE)

	call_restart_webhook()

	#ifdef UNIT_TESTS
	// load_unit_test_changes() // ??
	HandleTestRun()
	#endif

	if(config.ToRban)
		SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, /proc/ToRban_autoupdate))
	return

/world/proc/HandleTestRun()
	//trigger things to run the whole process
	// Master.sleep_offline_after_initializations = FALSE
	world.sleep_offline = FALSE // iirc mc SHOULD handle this
	SSticker.start_immediately = TRUE
	config.empty_server_restart_time = 0
	config.vote_autogamemode_timeleft = 0
	// CONFIG_SET(number/round_end_countdown, 0)
	var/datum/callback/cb
#ifdef UNIT_TESTS
	cb = CALLBACK(GLOBAL_PROC, /proc/RunUnitTests)
#else
	cb = VARSET_CALLBACK(global, universe_has_ended, TRUE) // yes i ended the universe.
#endif
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, /proc/addtimer, cb, 10 SECONDS))


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

	if(!handler || initial(handler.log))
		diary << "TOPIC: \"[T]\", from:[addr], master:[master], key:[key][log_end]"

	if(!handler)
		return

	handler = new handler()
	return handler.TryRun(input)

/world/proc/FinishTestRun()
	set waitfor = FALSE
	var/list/fail_reasons
	if(GLOB)
		if(total_runtimes != 0)
			fail_reasons = list("Total runtimes: [total_runtimes]")
#ifdef UNIT_TESTS
		if(GLOB.failed_any_test)
			LAZYADD(fail_reasons, "Unit Tests failed!")
#endif
		// if(!GLOB.log_directory)
		// 	LAZYADD(fail_reasons, "Missing GLOB.log_directory!")
	else
		fail_reasons = list("Missing GLOB!")
	if(!fail_reasons)
		text2file("Success!", "data/logs/ci/clean_run.lk") // [GLOB.log_directory]
	else
		log_world("Test run failed!\n[fail_reasons.Join("\n")]")
	sleep(0) //yes, 0, this'll let Reboot finish and prevent byond memes
	qdel(src) //shut it down

/world/Reboot(reason = 0, fast_track = FALSE)
	/* spawn(0)
		world << sound(pick('sound/AI/newroundsexy.ogg','sound/misc/apcdestroyed.ogg','sound/misc/bangindonk.ogg')) // random end sounds!! - LastyBatsy
	 */
	if (reason || fast_track) //special reboot, do none of the normal stuff
		if (usr)
			log_admin("[key_name(usr)] Has requested an immediate world restart via client side debugging tools")
			message_admins("[key_name_admin(usr)] Has requested an immediate world restart via client side debugging tools")
		to_chat(world, "<span class='boldannounce'>Rebooting World immediately due to host request.</span>")
	else
		to_chat(world, "<span class='boldannounce'>Rebooting world...</span>")
		Master.Shutdown() //run SS shutdowns

	for(var/client/C in clients)
		if(config.server)	//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[config.server]")

	#ifdef UNIT_TESTS
	FinishTestRun()
	return
	#endif

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

/world/proc/save_storyteller(the_mode)
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

/hook/startup/proc/connectDB()
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

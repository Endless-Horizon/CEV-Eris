//wrapper macros for easier grepping
#define DIRECT_OUTPUT(A, B) A << B
#define DIRECT_INPUT(A, B) A >> B
#define SEND_IMAGE(target, image) DIRECT_OUTPUT(target, image)
#define SEND_SOUND(target, sound) DIRECT_OUTPUT(target, sound)
#define SEND_TEXT(target, text) DIRECT_OUTPUT(target, text)
#define WRITE_FILE(file, text) DIRECT_OUTPUT(file, text)
#define READ_FILE(file, text) DIRECT_INPUT(file, text)
//This is an external call, "true" and "false" are how rust parses out booleans
#define WRITE_LOG(log, text) rustg_log_write(log, text, "true")
#define WRITE_LOG_NO_FORMAT(log, text) rustg_log_write(log, text, "false")

//print a warning message to world.log
#define WARNING(MSG) warning("[MSG] in [__FILE__] at line [__LINE__] src: [UNLINT(src)] usr: [usr].")
/proc/warning(msg)
	msg = "## WARNING: [msg]"
	log_world(msg)

//not an error or a warning, but worth to mention on the world log, just in case.
#define NOTICE(MSG) notice(MSG)
/proc/notice(msg)
	msg = "## NOTICE: [msg]"
	log_world(msg)

//print a testing-mode debug message to world.log and world
#ifdef TESTING
#define testing(msg) log_world("## TESTING: [msg]"); to_chat(world, "## TESTING: [msg]")

GLOBAL_LIST_INIT(testing_global_profiler, list("_PROFILE_NAME" = "Global"))
// we don't really check if a word or name is used twice, be aware of that
#define testing_profile_start(NAME, LIST) LIST[NAME] = world.timeofday
#define testing_profile_current(NAME, LIST) round((world.timeofday - LIST[NAME])/10,0.1)
#define testing_profile_output(NAME, LIST) testing("[LIST["_PROFILE_NAME"]] profile of [NAME] is [testing_profile_current(NAME,LIST)]s")
#define testing_profile_output_all(LIST) { for(var/_NAME in LIST) { testing_profile_current(,_NAME,LIST); }; };
#else
#define testing(msg)
#define testing_profile_start(NAME, LIST)
#define testing_profile_current(NAME, LIST)
#define testing_profile_output(NAME, LIST)
#define testing_profile_output_all(LIST)
#endif

#define testing_profile_global_start(NAME) testing_profile_start(NAME,GLOB.testing_global_profiler)
#define testing_profile_global_current(NAME) testing_profile_current(NAME, GLOB.testing_global_profiler)
#define testing_profile_global_output(NAME) testing_profile_output(NAME, GLOB.testing_global_profiler)
#define testing_profile_global_output_all testing_profile_output_all(GLOB.testing_global_profiler)

#define testing_profile_local_init(PROFILE_NAME) var/list/_timer_system = list( "_PROFILE_NAME" = PROFILE_NAME, "_start_of_proc"  = world.timeofday )
#define testing_profile_local_start(NAME) testing_profile_start(NAME, _timer_system)
#define testing_profile_local_current(NAME) testing_profile_current(NAME, _timer_system)
#define testing_profile_local_output(NAME) testing_profile_output(NAME, _timer_system)
#define testing_profile_local_output_all testing_profile_output_all(_timer_system)

var/global/log_end = "\n" //AGONY

#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)
/proc/log_test(text)
	WRITE_LOG(GLOB.test_log, text)
	SEND_TEXT(world.log, text)
#endif

/* Items with ADMINPRIVATE prefixed are stripped from public logs. */
/proc/log_admin(text)
	admin_log.Add(text)
	lobby_message(message = text, color = "#FFA500")
	if (config.log_admin) //CONFIG_GET(flag/log_admin))
		WRITE_LOG(GLOB.world_game_log, "ADMIN: [text]")
		// cringe old logging system
		game_log("ADMIN", text)

/proc/log_admin_private(text)
	admin_log.Add(text)
	if (config.log_admin) //CONFIG_GET(flag/log_admin))
		WRITE_LOG(GLOB.world_game_log, "ADMINPRIVATE: [text]")

/proc/log_adminwarn(text)
	if (config.log_adminwarn)
		WRITE_LOG(GLOB.world_game_log, "ADMINPRIVATE: ADMINWARN: [text]")
		game_log("ADMINWARN", text)

/proc/log_adminsay(text)
	admin_log.Add(text)
	if (config.log_admin) //CONFIG_GET(flag/log_admin))
		WRITE_LOG(GLOB.world_game_log, "ADMINPRIVATE: ASAY: [text]")

/proc/log_dsay(text)
	if (config.log_admin) //CONFIG_GET(flag/log_admin))
		WRITE_LOG(GLOB.world_game_log, "ADMIN: DSAY: [text]")

/* All other items are public. */
/proc/log_game(text)
	if (config.log_game) //CONFIG_GET(flag/log_game))
		WRITE_LOG(GLOB.world_game_log, "GAME: [text]")
		game_log("GAME", text)

/proc/log_paper(text)
	WRITE_LOG(GLOB.world_paper_log, "PAPER: [text]")

/proc/log_asset(text)
	WRITE_LOG(GLOB.world_asset_log, "ASSET: [text]")

/proc/log_access(text)
	if (config.log_access) //CONFIG_GET(flag/log_access))
		WRITE_LOG(GLOB.world_game_log, "ACCESS: [text]")
		game_log("ACCESS", text)

/proc/log_attack(text)
	if (config.log_attack) //(CONFIG_GET(flag/log_attack))
		WRITE_LOG(GLOB.world_attack_log, "ATTACK: [text]")
		game_log("ATTACK", text)

/proc/log_manifest(ckey, datum/mind/mind,mob/body, latejoin = FALSE)
	// if (CONFIG_GET(flag/log_manifest))
	WRITE_LOG(GLOB.world_manifest_log, "[ckey] \\ [body.real_name] \\ [mind.assigned_role] \\ ["NONE"] \\ [latejoin ? "LATEJOIN":"ROUNDSTART"]")

/proc/log_say(text)
	if (config.log_say) // (CONFIG_GET(flag/log_say))
		WRITE_LOG(GLOB.world_game_log, "SAY: [text]")
		game_log("SAY", text)

/proc/log_ooc(text)
	if (config.log_ooc) //  (CONFIG_GET(flag/log_ooc))
		WRITE_LOG(GLOB.world_game_log, "OOC: [text]")
		game_log("OOC", text)

/proc/log_whisper(text)
	if (config.log_whisper) // (CONFIG_GET(flag/log_whisper))
		WRITE_LOG(GLOB.world_game_log, "WHISPER: [text]")
		game_log("WHISPER", text)

/proc/log_emote(text)
	if (config.log_emote) // (CONFIG_GET(flag/log_emote))
		WRITE_LOG(GLOB.world_game_log, "EMOTE: [text]")
		game_log("EMOTE", text)

// /proc/log_prayer(text)
// 	if (CONFIG_GET(flag/log_prayer))
// 		WRITE_LOG(GLOB.world_game_log, "PRAY: [text]")

/proc/log_pda(text)
	if (config.log_pda) // (CONFIG_GET(flag/log_pda))
		WRITE_LOG(GLOB.world_pda_log, "PDA: [text]")
		game_log("PDA", text)

/proc/log_vote(text)
	if (config.log_vote) // (CONFIG_GET(flag/log_vote))
		WRITE_LOG(GLOB.world_game_log, "VOTE: [text]")
		game_log("VOTE", text)

/proc/log_topic(text)
	WRITE_LOG(GLOB.world_game_log, "TOPIC: [text]")

/proc/log_href(text)
	WRITE_LOG(GLOB.world_href_log, "HREF: [text]")

// /proc/log_sql(text)
// 	WRITE_LOG(GLOB.sql_error_log, "SQL: [text]")

/proc/log_qdel(text)
	WRITE_LOG(GLOB.world_qdel_log, "QDEL: [text]")

// /proc/log_query_debug(text)
// 	WRITE_LOG(GLOB.query_debug_log, "SQL: [text]")

/* Log to both DD and the logfile. */
/proc/log_world(text)
#ifdef USE_CUSTOM_ERROR_HANDLER
	WRITE_LOG(GLOB.world_runtime_log, text)
#endif
	SEND_TEXT(world.log, text)

/* Log to the logfile only. */
/proc/log_runtime(text)
	WRITE_LOG(GLOB.world_runtime_log, text)

/* Rarely gets called; just here in case the config breaks. */
/proc/log_config(text)
	WRITE_LOG(GLOB.config_error_log, text)
	SEND_TEXT(world.log, text)

/proc/log_mapping(text)
	WRITE_LOG(GLOB.world_map_error_log, text)

/proc/log_perf(list/perf_info)
	. = "[perf_info.Join(",")]\n"
	WRITE_LOG_NO_FORMAT(GLOB.perf_log, .)

/**
 * Appends a tgui-related log entry. All arguments are optional.
 */
/proc/log_tgui(user, message, context,
		datum/tgui_window/window,
		datum/src_object)
	var/entry = ""
	// Insert user info
	if(!user)
		entry += "<nobody>"
	else if(istype(user, /mob))
		var/mob/mob = user
		entry += "[mob.ckey] (as [mob] at [mob.x],[mob.y],[mob.z])"
	else if(istype(user, /client))
		var/client/client = user
		entry += "[client.ckey]"
	// Insert context
	if(context)
		entry += " in [context]"
	else if(window)
		entry += " in [window.id]"
	// Resolve src_object
	if(!src_object && window?.locked_by)
		src_object = window.locked_by.src_object
	// Insert src_object info
	if(src_object)
		entry += "\nUsing: [src_object.type] [REF(src_object)]"
	// Insert message
	if(message)
		entry += "\n[message]"
	WRITE_LOG(GLOB.tgui_log, entry)

/* For logging round startup. */
/proc/start_log(log)
	WRITE_LOG(log, "Starting up round ID [game_id].\n-------------------------")

/* Close open log handles. This should be called as late as possible, and no logging should hapen after. */
/proc/shutdown_logging()
	rustg_log_close_all()

/* Helper procs for building detailed log lines */
/proc/key_name(whom, include_link = null, include_name = TRUE)
	var/mob/M
	var/client/C
	var/key
	var/ckey
	var/fallback_name

	if(!whom)
		return "*null*"
	if(istype(whom, /client))
		C = whom
		M = C.mob
		key = C.key
		ckey = C.ckey
	else if(ismob(whom))
		M = whom
		C = M.client
		key = M.key
		ckey = M.ckey
	else if(istext(whom))
		key = whom
		ckey = ckey(whom)
		C = directory[ckey]
		if(C)
			M = C.mob
	else if(istype(whom,/datum/mind))
		var/datum/mind/mind = whom
		key = mind.key
		ckey = ckey(key)
		if(mind.current)
			M = mind.current
			if(M.client)
				C = M.client
		else
			fallback_name = mind.name
	else // Catch-all cases if none of the types above match
		var/swhom = null

		if(istype(whom, /atom))
			var/atom/A = whom
			swhom = "[A.name]"
		else if(istype(whom, /datum))
			swhom = "[whom]"

		if(!swhom)
			swhom = "*invalid*"

		return "\[[swhom]\]"

	. = ""

	if(!ckey)
		include_link = FALSE

	if(key)
		if(C?.holder && C.holder.fakekey && !include_name)
			// if(include_link)
			// 	. += "<a href='?priv_msg=[C.findStealthKey()]'>"
			. += "Administrator"
		else
			if(include_link)
				. += "<a href='?priv_msg=[ckey]'>"
			. += key
		if(!C)
			. += "\[DC\]"

		if(include_link)
			. += "</a>"
	else
		. += "*no key*"

	if(include_name)
		if(M)
			if(M.real_name)
				. += "/([M.real_name])"
			else if(M.name)
				. += "/([M.name])"
		else if(fallback_name)
			. += "/([fallback_name])"

	return .

/proc/key_name_admin(whom, include_name = TRUE)
	return key_name(whom, TRUE, include_name)

/proc/loc_name(atom/A)
	if(!istype(A))
		return "(INVALID LOCATION)"

	var/turf/T = A
	if (!istype(T))
		T = get_turf(A)

	if(istype(T))
		return "([AREACOORD(T)])"
	else if(A.loc)
		return "(UNKNOWN (?, ?, ?))"


/proc/error(msg)
	log_runtime(msg)

/// DEPRICATED, SEPERATION OF LOGS IS ABSOLUTE
/proc/game_log(category, text)
	// dear god what the fuck
	diary << "\[[time_stamp()]] [game_id] [category]: [text][log_end]"


/proc/log_debug(text)
	if (config.log_debug)
		game_log("DEBUG", text)

	for(var/client/C in admins)
		if(C.get_preference_value(/datum/client_preference/staff/show_debug_logs) == GLOB.PREF_SHOW)
			to_chat(C, "DEBUG: [text]")


/proc/log_to_dd(text)
	log_world(text)
	if(config.log_world_output)
		game_log("DD_OUTPUT", text)

/proc/log_misc(text)
	game_log("MISC", text)

/proc/log_unit_test(text)
	log_world("## UNIT_TEST ##: [text]")
	log_debug(text)

/* =================== *
 * ERIS SPECIFIC PROCS *
 * =================== */

//pretty print a direction bitflag, can be useful for debugging.
/proc/print_dir(var/dir)
	var/list/comps = list()
	if(dir & NORTH) comps += "NORTH"
	if(dir & SOUTH) comps += "SOUTH"
	if(dir & EAST) comps += "EAST"
	if(dir & WEST) comps += "WEST"
	if(dir & UP) comps += "UP"
	if(dir & DOWN) comps += "DOWN"

	return english_list(comps, nothing_text="0", and_text="|", comma_text="|")

// Helper procs for building detailed log lines
/datum/proc/get_log_info_line()
	return "[src] ([type]) ([any2ref(src)])"

/area/get_log_info_line()
	return "[..()] ([isnum(z) ? "[x],[y],[z]" : "0,0,0"])"

/turf/get_log_info_line()
	return "[..()] ([x],[y],[z]) ([loc ? loc.type : "NULL"])"

/atom/movable/get_log_info_line()
	var/turf/t = get_turf(src)
	return "[..()] ([t ? t : "NULL"]) ([t ? "[t.x],[t.y],[t.z]" : "0,0,0"]) ([t ? t.type : "NULL"])"

/mob/get_log_info_line()
	return ckey ? "[..()] ([ckey])" : ..()

/proc/log_info_line(var/datum/d)
	if(isnull(d))
		return "*null*"
	if(islist(d))
		var/list/L = list()
		for(var/e in d)
			L += log_info_line(e)
		return "\[[jointext(L, ", ")]\]" // We format the string ourselves, rather than use json_encode(), because it becomes difficult to read recursively escaped "
	if(!istype(d))
		return json_encode(d)
	return d.get_log_info_line()

// Helper proc for building detailed log lines
/proc/datum_info_line(datum/d)
	if(!istype(d))
		return
	if(!ismob(d))
		return "[d] ([d.type])"
	var/mob/m = d
	return "[m] ([m.ckey]) ([m.type])"

/proc/atom_loc_line(var/atom/a)
	if(!istype(a))
		return
	var/turf/t = get_turf(a)
	if(istype(t))
		return "[a.loc] ([t.x],[t.y],[t.z]) ([a.loc.type])"
	else if(a.loc)
		return "[a.loc] (0,0,0) ([a.loc.type])"

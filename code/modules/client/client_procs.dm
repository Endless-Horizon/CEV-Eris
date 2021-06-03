	////////////
	//SECURITY//
	////////////
#define UPLOAD_LIMIT		10485760	//Restricts client uploads to the server to 10MB //Boosted this thing. What's the worst that can happen?

GLOBAL_LIST_INIT(blacklisted_builds, list(
	"1407" = "bug preventing client display overrides from working leads to clients being able to see things/mobs they shouldn't be able to see",
	"1408" = "bug preventing client display overrides from working leads to clients being able to see things/mobs they shouldn't be able to see",
	"1428" = "bug causing right-click menus to show too many verbs that's been fixed in version 1429",
	))

	/*
	When somebody clicks a link in game, this Topic is called first.
	It does the stuff in this proc and  then is redirected to the Topic() proc for the src=[0xWhatever]
	(if specified in the link). ie locate(hsrc).Topic()

	Such links can be spoofed.

	Because of this certain things MUST be considered whenever adding a Topic() for something:
		- Can it be fed harmful values which could cause runtimes?
		- Is the Topic call an admin-only thing?
		- If so, does it have checks to see if the person who called it (usr.client) is an admin?
		- Are the processes being called by Topic() particularly laggy?
		- If so, is there any protection against somebody spam-clicking a link?
	If you have any  questions about this stuff feel free to ask. ~Carn
	*/
/client/Topic(href, href_list, hsrc)
	if(!usr || usr != mob)	//stops us calling Topic for somebody else's client. Also helps prevent usr=null
		return

	//search the href for script injection
	if( findtext(href,"<script",1,0) ) // ?? what the fuck
		log_world("Attempted use of scripts within a topic call, by [src]")
		message_admins("Attempted use of scripts within a topic call, by [src]")
		return

	// asset_cache
	var/asset_cache_job
	if(href_list["asset_cache_confirm_arrival"])
		asset_cache_job = asset_cache_confirm_arrival(href_list["asset_cache_confirm_arrival"])
		if (!asset_cache_job)
			return

	// RATELIMIT HERE

	// Tgui Topic middleware
	if(tgui_Topic(href_list))
		return
	if(href_list["reload_tguipanel"])
		nuke_chat()
	if(href_list["reload_statbrowser"])
		src << browse(file('html/statbrowser.html'), "window=statbrowser")
	// Log all hrefs
	log_href("[src] (usr:[usr]\[[COORD(usr)]\]) : [hsrc ? "[hsrc] " : ""][href]")

	//byond bug ID:2256651
	if (asset_cache_job && (asset_cache_job in completed_asset_jobs))
		to_chat(src, "<span class='danger'>An error has been detected in how your client is receiving resources. Attempting to correct.... (If you keep seeing these messages you might want to close byond and reconnect)</span>")
		src << browse("...", "window=asset_cache_browser")
		return
	if (href_list["asset_cache_preload_data"])
		asset_cache_preload_data(href_list["asset_cache_preload_data"])
		return

	//Admin PM
	if(href_list["priv_msg"])
		var/client/C = locate(href_list["priv_msg"])
		if(ismob(C)) 		//Old stuff can feed-in mobs instead of clients
			var/mob/M = C
			C = M.client
		cmd_admin_pm(C,null)
		return

	if(href_list["irc_msg"])
		if(!holder && received_irc_pm < world.time - 6000) //Worse they can do is spam IRC for 10 minutes
			to_chat(usr, SPAN_WARNING("You are no longer able to use this, it's been more then 10 minutes since an admin on IRC has responded to you"))
			return
		if(mute_irc)
			to_chat(usr, "<span class='warning'You cannot use this as your client has been muted from sending messages to the admins on IRC</span>")
			return
		cmd_admin_irc_pm(href_list["irc_msg"])
		return

	switch(href_list["_src_"])
		if("holder")
			hsrc = holder
		if("usr")
			hsrc = mob
		if("prefs")
			return prefs.process_link(usr,href_list)
		if("vars")
			return view_var_Topic(href,href_list,hsrc)

	switch(href_list["action"])
		if("openLink")
			src << link(href_list["link"])

	if (hsrc)
		var/datum/real_src = hsrc
		if(QDELETED(real_src))
			return

	..()	//redirect to hsrc.Topic()

/client/proc/handle_spam_prevention(var/message, var/mute_type)
	if(config.automute_on && !holder && src.last_message == message)
		src.last_message_count++
		if(src.last_message_count >= SPAM_TRIGGER_AUTOMUTE)
			to_chat(src, "\red You have exceeded the spam filter limit for identical messages. An auto-mute was applied.")
			cmd_admin_mute(src.mob, mute_type, 1)
			return 1
		if(src.last_message_count >= SPAM_TRIGGER_WARNING)
			to_chat(src, "\red You are nearing the spam filter limit for identical messages.")
			return 0
	else
		last_message = message
		src.last_message_count = 0
		return 0

//This stops files larger than UPLOAD_LIMIT being sent from client to server via input(), client.Import() etc.
/client/AllowUpload(filename, filelength)
	if(filelength > UPLOAD_LIMIT)
		to_chat(src, "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT/1024]KiB.</font>")
		return 0
/*	//Don't need this at the moment. But it's here if it's needed later.
	//Helps prevent multiple files being uploaded at once. Or right after eachother.
	var/time_to_wait = fileaccess_timer - world.time
	if(time_to_wait > 0)
		to_chat(src, "<font color='red'>Error: AllowUpload(): Spam prevention. Please wait [round(time_to_wait/10)] seconds.</font>")
		return 0
	fileaccess_timer = world.time + FTPDELAY	*/
	return 1


	///////////
	//CONNECT//
	///////////
/client/New(TopicData)
	// var/tdata = TopicData //save this for later use
	TopicData = null							//Prevent calls to client.Topic from connect

	if(connection != "seeker" && connection != "web")//Invalid connection type.
		return null

	clients += src
	directory[ckey] = src

	// Instantiate tgui panel
	tgui_panel = new(src)

	var/connecting_admin = FALSE //because de-admined admins connecting should be treated like admins.
	//Admin Authorisation
	holder = admin_datums[ckey]
	if(holder)
		admins |= src
		holder.owner = src
		connecting_admin = TRUE

	if(!connecting_admin)
		var/localhost_addresses = list("127.0.0.1", "::1")
		if(isnull(address) || (address in localhost_addresses))
			holder = new /datum/admins("!localhost!", R_HOST, ckey)
			holder.associate(src)
			holder.reassociate()
			SSticker.OnRoundstart(CALLBACK(holder, /datum/admins.proc/reassociate))

	//preferences datum - also holds some persistent data for the client (because we may as well keep these datums to a minimum)
	prefs = SScharacter_setup.preferences_datums[ckey]
	if(!prefs)
		prefs = new /datum/preferences(src)
		SScharacter_setup.preferences_datums[ckey] = prefs
	prefs.last_ip = address //these are gonna be used for banning
	prefs.last_id = computer_id //these are gonna be used for banning
	// fps = (prefs.clientfps < 0) ? RECOMMENDED_FPS : prefs.clientfps

	var/full_version = "[byond_version].[byond_build ? byond_build : "xxx"]"
	log_access("Login: [key_name(src)] from [address ? address : "localhost"]-[computer_id] || BYOND v[full_version]")


	. = ..()	//calls mob.Login()
	if (byond_version >= 512)
		if (!byond_build || byond_build < 1386)
			message_admins("<span class='adminnotice'>[key_name(src)] has been detected as spoofing their byond version. Connection rejected.</span>")
			// add_system_note("Spoofed-Byond-Version", "Detected as using a spoofed byond version.")
			log_access("Failed Login: [key] - Spoofed byond version")
			qdel(src)

		if (num2text(byond_build) in GLOB.blacklisted_builds)
			log_access("Failed login: [key] - blacklisted byond version")
			to_chat(src, "<span class='userdanger'>Your version of byond is blacklisted.</span>")
			to_chat(src, "<span class='danger'>Byond build [byond_build] ([byond_version].[byond_build]) has been blacklisted for the following reason: [GLOB.blacklisted_builds[num2text(byond_build)]].</span>")
			to_chat(src, "<span class='danger'>Please download a new version of byond. If [byond_build] is the latest, you can go to <a href=\"https://secure.byond.com/download/build\">BYOND's website</a> to download other versions.</span>")
			if(connecting_admin)
				to_chat(src, "As an admin, you are being allowed to continue using this version, but please consider changing byond versions")
			else
				qdel(src)
				return

	// Initialize tgui panel
	src << browse(file('html/statbrowser.html'), "window=statbrowser")
	addtimer(CALLBACK(src, .proc/check_panel_loaded), 30 SECONDS)
	tgui_panel.initialize()

	connection_time = world.time
	connection_realtime = world.realtime
	connection_timeofday = world.timeofday

	winset(src, null, "command=\".configure graphics-hwmode on\"")

	if(!config.guests_allowed && IsGuestKey(key))
		alert(src,"This server doesn't allow guest accounts to play. Please go to http://www.byond.com/ and register for a key.","Guest","OK")
		del(src)
		return

	// Change the way they should download resources.
	if(config.resource_urls)
		src.preload_rsc = pick(config.resource_urls)
	else src.preload_rsc = 1 // If config.resource_urls is not set, preload like normal.

	to_chat(src, "<span class='warning'>If the title screen is black, resources are still downloading. Please be patient until the title screen appears.</span>")

	if(custom_event_msg && custom_event_msg != "")
		to_chat(src, "<h1 class='alert'>Custom Event</h1>")
		to_chat(src, "<h2 class='alert'>A custom event is taking place. OOC Info:</h2>")
		to_chat(src, "<span class='alert'>[custom_event_msg]</span>")
		to_chat(src, "<br>")

	if( (world.address == address || !address) && (!GLOB.host || !host) )
		GLOB.host = key
		host = key
		world.update_status()

	if(holder)
		add_admin_verbs()
		admin_memo_show()

	// check_ip_intel()
	// validate_key_in_db()
	log_client_to_db()

	send_resources()

	// generate_clickcatcher()
	// apply_clickcatcher()

	if(prefs.lastchangelog != changelog_hash) //bolds the changelog button on the interface so we know there are updates.
		to_chat(src, "<span class='info'>You have unread updates in the changelog.</span>")
		if(config.aggressive_changelog)
			changelog()
		else
			winset(src, "infowindow.changelog", "font-style=bold")

	if(!winexists(src, "asset_cache_browser")) // The client is using a custom skin, tell them.
		to_chat(src, "<span class='warning'>Unable to access asset cache browser, if you are using a custom skin file, please allow DS to download the updated version, if you are not, then make a bug report. This is not a critical issue but can cause issues with resource downloading, as it is impossible to know when extra resources arrived to you.</span>")

	if(!tooltips)
		tooltips = new /datum/tooltip(src)

	// view_size = new(src, getScreenSize(prefs.widescreenpref))
	// view_size.resetFormat()
	// view_size.setZoomMode()
	fit_viewport()
	Master.UpdateTickRate()


//////////////
//DISCONNECT//
//////////////
/client/Del()
	if(!gc_destroyed)
		Destroy() //Clean up signals and timers.
	return ..()

/client/Destroy()
	// if(mob)
	// 	var/stealth_admin = mob.client?.holder?.fakekey
	// 	var/announce_join = mob.client?.prefs?.broadcast_login_logout
	// 	if (!stealth_admin)
	// 		deadchat_broadcast(" has disconnected.", "<b>[mob][mob.get_realname_string()]</b>", follow_target = mob, turf_target = get_turf(mob), message_type = DEADCHAT_LOGIN_LOGOUT, admin_only=!announce_join)

	clients -= src
	directory -= ckey
	log_access("Logout: [key_name(src)]")
	// GLOB.ahelp_tickets.ClientLogout(src)
	// GLOB.interviews.client_logout(src)
	// SSserver_maint.UpdateHubStatus()
	// if(credits)
	// 	QDEL_LIST(credits)
	if(holder)
		// adminGreet(1)
		holder.owner = null
		admins -= src
		if (!admins.len && SSticker.IsRoundInProgress()) //Only report this stuff if we are currently playing.
			var/cheesy_message = pick(
				"I have no admins online!",\
				"I'm all alone :(",\
				"I'm feeling lonely :(",\
				"I'm so lonely :(",\
				"Why does nobody love me? :(",\
				"I want a man :(",\
				"Where has everyone gone?",\
				"I need a hug :(",\
				"Someone come hold me :(",\
				"I need someone on me :(",\
				"What happened? Where has everyone gone?",\
				"Forever alone :("\
			)

			send2adminchat("Server", "[cheesy_message] (No admins online)")
	// QDEL_LIST_ASSOC_VAL(char_render_holders)
	// if(movingmob != null)
	// 	movingmob.client_mobs_in_contents -= mob
	// 	UNSETEMPTY(movingmob.client_mobs_in_contents)
	// 	movingmob = null
	// active_mousedown_item = null
	// SSambience.ambience_listening_clients -= src
	// QDEL_NULL(view_size)
	// QDEL_NULL(void)
	QDEL_NULL(tooltips)
	// seen_messages = null
	Master.UpdateTickRate()

	if(dbcon.IsConnected())
		var/DBQuery/query = dbcon.NewQuery("UPDATE players SET last_seen = Now() WHERE id = [src.id]")
		if(!query.Execute())
			log_world("Failed to update players table for user with id [src.id]. Error message: [query.ErrorMsg()].")

	..() //Even though we're going to be hard deleted there are still some things that want to know the destroy is happening
	return QDEL_HINT_HARDDEL_NOW

/client/proc/get_registration_date()
	var/list/http = world.Export("http://byond.com/members/[ckey]?format=text")
	if(!http)
		log_world("Failed to connect to byond member page to age check [ckey]")
		return
	var/F = file2text(http["CONTENT"])
	if(F)
		var/regex/R = regex("joined = \"(\\d{4}-\\d{2}-\\d{2})\"")
		if(R.Find(F))
			var/year = R.group[1]
			var/month = 00
			var/day = 00
			if(R.group.len > 2)
				month = R.group[2]
			if(R.group.len == 3)
				day = R.group[3]
			registration_date = "[year]-[month]-[day]"
			return registration_date
		else
			CRASH("Age check regex failed for [src.ckey]")

/client/proc/get_country()
	var/address_check[] = world.Export("http://ip-api.com/line/[sql_sanitize_text(src.address)]")
	/*
	Response
		A successful request will return, by default, the following:
		 1: success
		 2: COUNTRY
		 3: COUNTRY CODE
		 4: REGION CODE
		 5: REGION NAME
		 6: CITY
		 7: ZIP CODE
		 8: LATITUDE
		 9: LONGITUDE
		10: TIME ZONE
		11: ISP NAME
		12: ORGANIZATION NAME
		13: AS NUMBER / NAME
		14: IP ADDRESS USED FOR QUERY

		A failed request will return, by default, the following:

		1: fail
		2: ERROR MESSAGE
		3: IP ADDRESS USED FOR QUERY
	*/
	if(address_check)
		var/list/response = file2list(address_check["CONTENT"])
		if(response.len && response[1] == "success")
			src.country = response[2]
			src.country_code = response[3]
			return list("country" = src.country, "country_code" = src.country_code)

	log_world("Failed on retrieving location for player [src.ckey] from ip-api.com .")
	return null


/client/proc/register_in_db()
	// Prevents the crash if the DB isn't connected.
	if(!dbcon.IsConnected())
		return

	registration_date = src.get_registration_date()
	src.get_country()
	src.get_byond_age() // Get days since byond join

	var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO players (ckey, first_seen, last_seen, registered, ip, cid, rank, byond_version, country) VALUES ('[src.ckey]', Now(), Now(), '[registration_date]', '[sql_sanitize_text(src.address)]', '[sql_sanitize_text(src.computer_id)]', 'player', [src.byond_version], '[src.country_code]')")
	if(!query_insert.Execute())
		log_world("##CRITICAL: Failed to create player record for user [ckey]. Error message: [query_insert.ErrorMsg()].")
		return

	else
		var/DBQuery/get_player_id = dbcon.NewQuery("SELECT id, first_seen FROM players WHERE ckey = '[src.ckey]'")
		get_player_id.Execute()
		if(get_player_id.NextRow())
			src.id = get_player_id.item[1]
			src.first_seen = get_player_id.item[2]

//Not actually age, but rather time since first seen in days
/client/proc/get_player_age()
	if(first_seen && dbcon.IsConnected())
		var/dateSQL = sanitizeSQL(first_seen)
		var/DBQuery/query_datediff = dbcon.NewQuery("SELECT DATEDIFF(Now(),'[dateSQL]')")
		if(query_datediff.Execute() && query_datediff.NextRow())
			src.first_seen_days_ago = text2num(query_datediff.item[1])

	if(config.paranoia_logging && isnum(src.first_seen_days_ago) && src.first_seen_days_ago == 0)
		log_and_message_admins("PARANOIA: [key_name(src)] has connected here for the first time.")
	return src.first_seen_days_ago

//Days since they signed up for their byond account
/client/proc/get_byond_age()
	if(!registration_date)
		get_registration_date()
	if(registration_date && dbcon.IsConnected())
		var/dateSQL = sanitizeSQL(registration_date)
		var/DBQuery/query_datediff = dbcon.NewQuery("SELECT DATEDIFF(Now(),'[dateSQL]')")
		if(query_datediff.Execute() && query_datediff.NextRow())
			src.account_age_in_days = text2num(query_datediff.item[1])
	if(config.paranoia_logging && isnum(src.account_age_in_days) && src.account_age_in_days <= 2)
		log_and_message_admins("PARANOIA: [key_name(src)] has a very new Byond account. ([src.account_age_in_days] days old)")
	return src.account_age_in_days

/client/proc/log_client_to_db()
	if(IsGuestKey(src.key))
		return

	establish_db_connection()
	if(dbcon.IsConnected())
		// Get existing player from DB
		var/DBQuery/query = dbcon.NewQuery("SELECT id from players WHERE ckey = '[src.ckey]'")
		if(!query.Execute())
			log_world("Failed to get player record for user with ckey '[src.ckey]'. Error message: [query.ErrorMsg()].")

		// Not their first time here
		else if(query.NextRow())
			// client already registered so we fetch all needed data
			query = dbcon.NewQuery("SELECT id, registered, first_seen, VPN_check_white FROM players WHERE id = [query.item[1]]")
			query.Execute()
			if(query.NextRow())
				src.id = query.item[1]
				src.registration_date = query.item[2]
				src.first_seen = query.item[3]
				src.get_country()

				//Player already identified previously, we need to just update the 'lastseen', 'ip' and 'computer_id' variables
				var/DBQuery/query_update = dbcon.NewQuery("UPDATE players SET last_seen = Now(), ip = '[src.address]', cid = '[src.computer_id]', byond_version = '[src.byond_version]', country = '[src.country_code]' WHERE id = [src.id]")

				if(!query_update.Execute())
					log_world("Failed to update players table for user with id [src.id]. Error message: [query_update.ErrorMsg()].")

		//Panic bunker - player not in DB, so they get kicked
		else if(config.panic_bunker && !holder && !deadmin_holder && !(ckey in GLOB.PB_bypass))
			log_adminwarn("Failed Login: [key] - New account attempting to connect during panic bunker")
			message_admins("<span class='adminnotice'>Failed Login: [key] - New account attempting to connect during panic bunker</span>")
			to_chat(src, "<span class='warning'>Sorry but the server is currently not accepting connections from never before seen players.</span>")
			del(src) // Hard del the client. This terminates the connection.
			return 0
		query = dbcon.NewQuery("SELECT ip_related_ids, cid_related_ids FROM players WHERE id = '[src.id]'")
		query.Execute()
		query = dbcon.NewQuery("SELECT id, ip, cid FROM players WHERE (ip = '[address]' OR cid = '[computer_id]') AND id <> '[src.id]'")
		query.Execute()
		// var/changed = 0
		// while(query.NextRow())
		// 	var/temp_id = query.item[1]
		// 	var/temp_ip = query.item[2]
		// 	var/temp_cid = query.item[3]
		// 	if(temp_ip == address)
		// 		changed = 1
		// 	if(temp_cid == computer_id)
		// 		changed = 1


	src.get_byond_age() // Get days since byond join
	src.get_player_age() // Get days since first seen

	// IP Reputation Check
	if(config.ip_reputation)
		if(config.ipr_allow_existing && first_seen_days_ago >= config.ipr_minimum_age)
			log_admin("Skipping IP reputation check on [key] with [address] because of player age")
		else if(holder)
			log_admin("Skipping IP reputation check on [key] with [address] because they have a staff rank")
		else if(update_ip_reputation()) //It is set now
			if(ip_reputation >= config.ipr_bad_score) //It's bad

				//Log it
				if(config.paranoia_logging) //We don't block, but we want paranoia log messages
					log_and_message_admins("[key] at [address] has bad IP reputation: [ip_reputation]. Will be kicked if enabled in config.")
				else //We just log it
					log_admin("[key] at [address] has bad IP reputation: [ip_reputation]. Will be kicked if enabled in config.")

				//Take action if required
				if(config.ipr_block_bad_ips && config.ipr_allow_existing) //We allow players of an age, but you don't meet it
					to_chat(src, "Sorry, we only allow VPN/Proxy/Tor usage for players who have spent at least [config.ipr_minimum_age] days on the server. If you are unable to use the internet without your VPN/Proxy/Tor, please contact an admin out-of-game to let them know so we can accommodate this.")
					del(src) // Hard del the client. This terminates the connection.
					return 0
				else if(config.ipr_block_bad_ips) //We don't allow players of any particular age
					to_chat(src, "Sorry, we do not accept connections from users via VPN/Proxy/Tor connections. If you think this is in error, contact an administrator out of game.")
					del(src) // Hard del the client. This terminates the connection.
					return 0
		else
			log_admin("Couldn't perform IP check on [key] with [address]")

	if(text2num(id) < 0)
		src.register_in_db()



#undef UPLOAD_LIMIT

//checks if a client is afk
//3000 frames = 5 minutes
/client/proc/is_afk(duration=3000)
	if (duration)
		if(inactivity > duration)
			return inactivity
	return FALSE


/client/proc/inactivity2text()
	var/seconds = inactivity/10
	return "[round(seconds / 60)] minute\s, [seconds % 60] second\s"

/// Send resources to the client.
/// Sends both game resources and browser assets.
/client/proc/send_resources()
	spawn (10) //removing this spawn causes all clients to not get verbs.

		//load info on what assets the client has
		src << browse('code/modules/asset_cache/validate_assets.html', "window=asset_cache_browser")

		//Precache the client with all other assets slowly, so as to not block other browse() calls
		if (CONFIG_GET(flag/asset_simple_preload))
			addtimer(CALLBACK(SSassets.transport, /datum/asset_transport.proc/send_assets_slow, src, SSassets.transport.preload), 5 SECONDS)


		send_all_cursor_icons(src)

//Hook, override it to run code when dir changes
//Like for /atoms, but clients are their own snowflake FUCK
/client/proc/setDir(newdir)
	dir = newdir

/mob/proc/MayRespawn()
	return FALSE

/client/proc/MayRespawn()
	if(mob)
		return mob.MayRespawn()

	// Something went wrong, client is usually kicked or transfered to a new mob at this point
	return FALSE


/client/verb/character_setup()
	set name = "Character Setup"
	set category = "OOC"
	if(prefs)
		prefs.ShowChoices(usr)

// Byond seemingly calls stat, each tick (which is bad (not bad, terrible) for performance)
// Calling things each tick can get expensive real quick.
// So we slow this down a little.
// See: http://www.byond.com/docs/ref/info.html#/client/proc/Stat
/client/Stat()
	if(!usr)
		return
	// Add always-visible stat panel calls here, to define a consistent display order.
	statpanel("Status")

	. = ..()
	sleep(1)

/client/proc/create_UI(var/mob_type)
	destroy_UI()
	if(!mob_type)
		mob_type = mob.type
	if(!UI)
		var/success = FALSE
		for(var/S in GLOB.ui_styles[mob_type])
			var/datum/interface/style = S
			if(initial(style.styleName) == prefs.UI_style)
				UI = new style(src)
				success = TRUE
				break
		if(!success)
			log_debug("Could not find style \"[prefs.UI_style]\" for [mob_type].")

	if(UI)
		UI.show()

/client/proc/destroy_UI()
	if(UI)
		qdel(UI)
		UI = null

//Uses a couple different services
/client/proc/update_ip_reputation()
	var/list/scores = list("GII" = ipr_getipintel())
	if(config.ipqualityscore_apikey)
		scores["IPQS"] = ipr_ipqualityscore()
	/* Can add other systems if desirable
	if(config.blah_apikey)
		scores["blah"] = some_proc()
	*/

	var/log_output = "IP Reputation [key] from [address]"
	var/worst = 0

	for(var/service in scores)
		var/score = scores[service]
		if(score > worst)
			worst = score
		log_output += " - [service] ([num2text(score)])"

	log_admin(log_output)
	ip_reputation = worst
	return TRUE

//Service returns a single float in html body
/client/proc/ipr_getipintel()
	if(!config.ipr_email)
		return -1

	var/request = "http://check.getipintel.net/check.php?ip=[address]&contact=[config.ipr_email]"
	var/http[] = world.Export(request)

	if(!http || !islist(http)) //If we couldn't check, the service might be down, fail-safe.
		log_admin("Couldn't connect to getipintel.net to check [address] for [key]")
		return -1

	//429 is rate limit exceeded
	if(text2num(http["STATUS"]) == 429)
		log_and_message_admins("getipintel.net reports HTTP status 429. IP reputation checking is now disabled. If you see this, let a developer know.")
		config.ip_reputation = FALSE
		return -1

	var/content = file2text(http["CONTENT"]) //world.Export actually returns a file object in CONTENT
	var/score = text2num(content)
	if(isnull(score))
		return -1

	//Error handling
	if(score < 0)
		var/fatal = TRUE
		var/ipr_error = "getipintel.net IP reputation check error while checking [address] for [key]: "
		switch(score)
			if(-1)
				ipr_error += "No input provided"
			if(-2)
				fatal = FALSE
				ipr_error += "Invalid IP provided"
			if(-3)
				fatal = FALSE
				ipr_error += "Unroutable/private IP (spoofing?)"
			if(-4)
				fatal = FALSE
				ipr_error += "Unable to reach database"
			if(-5)
				ipr_error += "Our IP is banned or otherwise forbidden"
			if(-6)
				ipr_error += "Missing contact info"

		log_and_message_admins(ipr_error)
		if(fatal)
			config.ip_reputation = FALSE
			log_and_message_admins("With this error, IP reputation checking is disabled for this shift. Let a developer know.")
		return -1

	//Went fine
	else
		return score

//Service returns JSON in html body
/client/proc/ipr_ipqualityscore()
	if(!config.ipqualityscore_apikey)
		return -1

	var/request = "http://www.ipqualityscore.com/api/json/ip/[config.ipqualityscore_apikey]/[address]?strictness=1&fast=true&byond_key=[key]"
	var/http[] = world.Export(request)

	if(!http || !islist(http)) //If we couldn't check, the service might be down, fail-safe.
		log_admin("Couldn't connect to ipqualityscore.com to check [address] for [key]")
		return -1

	var/content = file2text(http["CONTENT"]) //world.Export actually returns a file object in CONTENT
	var/response = json_decode(content)
	if(isnull(response))
		return -1

	//Error handling
	if(!response["success"])
		log_admin("IPQualityscore.com returned an error while processing [key] from [address]: " + response["message"])
		return -1

	var/score = 0
	if(response["proxy"])
		score = 100
	else
		score = response["fraud_score"]

	return score/100 //To normalize with the 0 to 1 scores.

/client/proc/colour_transition(list/colour_to = null, time = 10) //Call this with no parameters to reset to default.
	animate(src, color = colour_to, time = time, easing = SINE_EASING)

/client/proc/check_panel_loaded()
	if(statbrowser_ready)
		return
	to_chat(src, "<span class='userdanger'>Statpanel failed to load, click <a href='?src=[REF(src)];reload_statbrowser=1'>here</a> to reload the panel </span>")

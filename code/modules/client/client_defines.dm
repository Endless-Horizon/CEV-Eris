/client
		//////////////////////
		//BLACK MAGIC THINGS//
		//////////////////////
	parent_type = /datum
		////////////////
		//ADMIN THINGS//
		////////////////
	/// hides the byond verb panel as we use our own custom version
	// show_verb_panel = FALSE
	///Contains admin info. Null if client is not an admin.
	var/datum/admins/holder = null
	var/datum/admins/deadmin_holder = null
	var/buildmode		= 0

	var/last_message	= "" //Contains the last message sent by this client - used to protect against copy-paste spamming.
	var/last_message_count = 0 //contins a number of how many times a message identical to last_message was sent.

		/////////
		//OTHER//
		/////////
	///Player preferences datum for the client
	var/datum/preferences/prefs = null
	var/moving			= null
	var/adminobs		= null
	///Current area of the controlled mob
	var/area			= null

	var/adminhelped = 0

		///////////////
		//SOUND STUFF//
		///////////////
	var/ambience_playing= null
	var/played			= 0

		////////////
		//SECURITY//
		////////////
	// comment out the line below when debugging locally to enable the options & messages menu
	// control_freak = 1
	var/received_irc_pm = -99999
	var/irc_admin			//IRC admin that spoke with them last.
	var/mute_irc = 0
	var/warned_about_multikeying = 0	// Prevents people from being spammed about multikeying every time their mob changes.
	var/ip_reputation = 0 //Do we think they're using a proxy/vpn? Only if IP Reputation checking is enabled in config.
	var/account_age_in_days // Byond account age


		////////////////////////////////////
		//things that require the database//
		////////////////////////////////////
	var/id = -1
	var/registration_date = ""
	var/first_seen = ""
	var/country = ""
	var/country_code = ""
	var/first_seen_days_ago

	// This was 0
	// so Bay12 can set it to an URL once the player logs in and have them download the resources from a different server.
	// But we change it.
	preload_rsc = 1

		////////////////
		//Mouse things//
		////////////////
	var/datum/click_handler/CH

	var/datum/interface/UI	//interface for current mob
	//datum that controls the displaying and hiding of tooltips
	var/datum/tooltip/tooltips

	///Last ping of the client
	var/lastping = 0
	///Average ping of the client
	var/avgping = 0
	///world.time they connected
	var/connection_time
	///world.realtime they connected
	var/connection_realtime
	///world.timeofday they connected
	var/connection_timeofday

	/// our current tab
	var/stat_tab

	/// whether our browser is ready or not yet
	var/statbrowser_ready = FALSE

	/// list of all tabs
	var/list/panel_tabs = list()
	/// list of tabs containing spells and abilities
	var/list/spell_tabs = list()
	///A lazy list of atoms we've examined in the last EXAMINE_MORE_TIME (default 1.5) seconds, so that we will call [/atom/proc/examine_more] instead of [/atom/proc/examine] on them when examining
	var/list/recent_examines

	// List of all asset filenames sent to this client by the asset cache, along with their assoicated md5s
	var/list/sent_assets = list()
	/// List of all completed blocking send jobs awaiting acknowledgement by send_asset
	var/list/completed_asset_jobs = list()
	/// Last asset send job id.
	var/last_asset_job = 0
	var/last_completed_asset_job = 0

/var/datum/announcement/priority/priority_announcement = new(do_log = 0)
/var/datum/announcement/priority/command/command_announcement = new(do_log = 0, do_newscast = 1)

/datum/announcement
	var/title = "Attention"
	var/announcer = ""
	var/log = 0
	var/sound
	var/newscast = 0
	var/channel_name = "Ship Announcements"
	var/announcement_type = "Announcement"

/datum/announcement/New(var/do_log = 0, var/new_sound = null, var/do_newscast = 0)
	sound = new_sound
	log = do_log
	newscast = do_newscast

/datum/announcement/priority/New(var/do_log = 1, var/new_sound = 'sound/misc/notice2.ogg', var/do_newscast = 0)
	..(do_log, new_sound, do_newscast)
	title = "Priority Announcement"
	announcement_type = "Priority Announcement"

/datum/announcement/priority/command/New(var/do_log = 1, var/new_sound = 'sound/misc/notice2.ogg', var/do_newscast = 0)
	..(do_log, new_sound, do_newscast)
	title = "[command_name()] Update"
	announcement_type = "[command_name()] Update"

/datum/announcement/priority/security/New(var/do_log = 1, var/new_sound = 'sound/misc/notice2.ogg', var/do_newscast = 0)
	..(do_log, new_sound, do_newscast)
	title = "Security Announcement"
	announcement_type = "Security Announcement"

/datum/announcement/proc/Announce(var/message as text, var/new_title = "", var/new_sound = null, var/do_newscast = newscast, var/msg_sanitized = 0, var/zlevels = GLOB.maps_data.contact_levels)
	if(!message)
		return
	var/message_title = new_title ? new_title : title
	var/message_sound = new_sound ? new_sound : sound

	if(!msg_sanitized)
		message = sanitize(message, extra = 0)
	message_title = html_encode(message_title)

	Message(message, message_title)
	if(do_newscast)
		NewsCast(message, message_title)

	for(var/mob/M in GLOB.player_list)
		if((M.z in (zlevels | GLOB.maps_data.admin_levels)) && !istype(M,/mob/new_player) && !isdeaf(M) && message_sound)
			sound_to(M, message_sound)
	Log(message, message_title)

datum/announcement/proc/Message(message as text, message_title as text)
	global_announcer.autosay("<span class='warning'>[title]:</span> [message]", announcer ? announcer : ANNOUNCER_NAME)

datum/announcement/minor/Message(message as text, message_title as text)
	global_announcer.autosay(message, ANNOUNCER_NAME)

datum/announcement/priority/Message(message as text, message_title as text)
	global_announcer.autosay("<span class='alert'>[message_title]:</span> [message]", announcer ? announcer : ANNOUNCER_NAME)

datum/announcement/priority/command/Message(message as text, message_title as text)
	global_announcer.autosay("<span class='warning'>[message_title]:</span> [message]", ANNOUNCER_NAME)

datum/announcement/priority/security/Message(message as text, message_title as text)
	global_announcer.autosay("<font color='red'>[message_title]:</span> [message]", ANNOUNCER_NAME)

datum/announcement/proc/NewsCast(message as text, message_title as text)
	if(!newscast)
		return

	var/datum/news_announcement/news = new
	news.channel_name = channel_name
	news.author = announcer
	news.message = message
	news.message_type = announcement_type
	news.can_be_redacted = 0
	announce_newscaster_news(news)

datum/announcement/proc/PlaySound(var/message_sound)
	if(!message_sound)
		return
	for(var/mob/M in GLOB.player_list)
		if(!isnewplayer(M) && !isdeaf(M))
			M << message_sound

datum/announcement/proc/Sound(var/message_sound)
	PlaySound(message_sound)

datum/announcement/priority/Sound(var/message_sound)
	if(message_sound)
		world << message_sound

datum/announcement/priority/command/Sound(var/message_sound)
	PlaySound(message_sound)

datum/announcement/proc/Log(message as text, message_title as text)
	if(log)
		log_say("[key_name(usr)] has made \a [announcement_type]: [message_title] - [message] - [announcer]")
		message_admins("[key_name_admin(usr)] has made \a [announcement_type].", 1)

/proc/GetNameAndAssignmentFromId(var/obj/item/card/id/I)
	// Format currently matches that of newscaster feeds: Registered Name (Assigned Rank)
	return I.assignment ? "[I.registered_name] ([I.assignment])" : I.registered_name

/proc/level_seven_announcement()
	command_announcement.Announce("Confirmed outbreak of level 7 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", new_sound = 'sound/AI/outbreak7.ogg')

/proc/level_eight_announcement() //new announcment so the crew doesn't have to fuck around trying to figure out if its a blob, hivemind, or a literal fungus
	command_announcement.Announce("Confirmed outbreak of level 8 Bio-mechanical infestation aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert")

/proc/level_eight_beta_announcement() //announcment which tells the crew that the hivemind has been killed, job well done crew.
	command_announcement.Announce("Diagnostic Systems report level 8 Bio-mechanical infestation aboard [station_name()] has been contained.")

/proc/level_nine_announcement()
	command_announcement.Announce("Confirmed outbreak of level 9 Excelsior communist infestation aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert")

/proc/ion_storm_announcement()
	command_announcement.Announce("It has come to our attention that the ship passed through an ion storm.  Please monitor all electronic equipment for malfunctions.", "Anomaly Alert")

/proc/AnnounceArrival(var/mob/living/character, var/rank, var/join_message)
	if (join_message && SSticker.current_state == GAME_STATE_PLAYING && SSjob.ShouldCreateRecords(rank))
		if(issilicon(character))
			global_announcer.autosay("A new [rank] [join_message].", ANNOUNCER_NAME)
		else
			global_announcer.autosay("[character.real_name], [rank], [join_message].", ANNOUNCER_NAME)

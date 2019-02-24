/datum/admin_topic
	var/keyword
	var/list/require_perms = list()
	//The permissions needed to run the topic.
	//If you want the user to need multiple perms, have each perm be an entry into the list, like this: list(R_ADMIN, R_MOD)
	//If you want the user to need just one of multiple perms, have the perms be the same entry in the list using OR, like this: list(R_ADMIN|R_MOD)
	//These can be combined, for example with: list(R_MOD|R_MENTOR, R_ADMIN) which would require you to have either R_MOD or R_MENTOR, as well as R_ADMIN

/datum/admin_topic/proc/TryRun(list/input, datum/admins/source)
	if(require_perms.len)
		for(var/i in require_perms)
			if(!check_rights(i, TRUE))
				return FALSE
	. = Run(input, source)

/datum/admin_topic/proc/Run(list/input, datum/admins/source) //use the source arg to access the admin datum.
	CRASH("Run() not implemented for [type]!")


/datum/admin_topic/dbsearchckey
	keyword = "dbsearchckey"

/datum/admin_topic/dbsearchckey/dbsearchadmin //inherits the behaviour of dbsearchckey, but with a different keyword.
	keyword = "dbsearchadmin"

/datum/admin_topic/dbsearchckey/Run(list/input, datum/admins/source)
	var/adminckey = input["dbsearchadmin"]
	var/playerckey = input["dbsearchckey"]
	var/playerip = input["dbsearchip"]
	var/playercid = input["dbsearchcid"]
	var/dbbantype = text2num(input["dbsearchbantype"])
	var/match = FALSE

	if("dbmatch" in input)
		match = TRUE

	source.DB_ban_panel(playerckey, adminckey, playerip, playercid, dbbantype, match)


/datum/admin_topic/dbbanedit
	keyword = "dbbanedit"

/datum/admin_topic/dbbanedit/Run(list/input, datum/admins/source)
	var/banedit = input["dbbanedit"]
	var/banid = text2num(input["dbbanid"])
	if(!banedit || !banid)
		return

	source.DB_ban_edit(banid, banedit)


/datum/admin_topic/dbbanaddtype
	keyword = "dbbanaddtype"

/datum/admin_topic/dbbanaddtype/Run(list/input, datum/admins/source)
	var/bantype = text2num(input["dbbanaddtype"])
	var/banckey = input["dbbanaddckey"]
	var/banip = input["dbbanaddip"]
	var/bancid = input["dbbanaddcid"]
	var/banduration = text2num(input["dbbaddduration"])
	var/banjob = input["dbbanaddjob"]
	var/banreason = input["dbbanreason"]

	banckey = ckey(banckey)

	switch(bantype)
		if(BANTYPE_PERMA)
			if(!banckey || !banreason)
				usr << "Not enough parameters (Requires ckey and reason)"
				return
			banduration = null
			banjob = null
		if(BANTYPE_TEMP)
			if(!banckey || !banreason || !banduration)
				usr << "Not enough parameters (Requires ckey, reason and duration)"
				return
			banjob = null
		if(BANTYPE_JOB_PERMA)
			if(!banckey || !banreason || !banjob)
				usr << "Not enough parameters (Requires ckey, reason and job)"
				return
			banduration = null
		if(BANTYPE_JOB_TEMP)
			if(!banckey || !banreason || !banjob || !banduration)
				usr << "Not enough parameters (Requires ckey, reason and job)"
				return

	var/mob/playermob

	for(var/mob/M in GLOB.player_list)
		if(M.ckey == banckey)
			playermob = M
			break


	banreason = "(MANUAL BAN) "+banreason

	if(!playermob)
		if(banip)
			banreason = "[banreason] (CUSTOM IP)"
		if(bancid)
			banreason = "[banreason] (CUSTOM CID)"
	else
		message_admins("Ban process: A mob matching [playermob.ckey] was found at location [playermob.x], [playermob.y], [playermob.z]. Custom ip and computer id fields replaced with the ip and computer id from the located mob")

	source.DB_ban_record(bantype, playermob, banduration, banreason, banjob, banckey, banip, bancid )


/datum/admin_topic/editrights
	keyword = "editrights"
	require_perms = list(R_PERMISSIONS)

/datum/admin_topic/editrights/Run(list/input, datum/admins/source)

	var/adm_ckey

	var/task = input["editrights"]
	if(task == "add")
		var/new_ckey = ckey(input(usr,"New admin's ckey","Admin ckey", null) as text|null)
		if(!new_ckey)
			return
		if(new_ckey in admin_datums)
			usr << "<font color='red'>Error: Topic 'editrights': [new_ckey] is already an admin</font>"
			return
		adm_ckey = new_ckey
		task = "rank"
	else if(task != "show")
		adm_ckey = ckey(input["ckey"])
		if(!adm_ckey)
			usr << "<font color='red'>Error: Topic 'editrights': No valid ckey</font>"
			return

	var/datum/admins/D = admin_datums[adm_ckey]

	if(task == "remove")
		if(alert("Are you sure you want to remove [adm_ckey]?","Message","Yes","Cancel") == "Yes")
			if(!D)
				return
			admin_datums -= adm_ckey
			D.disassociate()

			message_admins("[key_name_admin(usr)] removed [adm_ckey] from the admins list")
			log_admin("[key_name(usr)] removed [adm_ckey] from the admins list")
			source.log_admin_rank_modification(adm_ckey, "player")

	else if(task == "rank")
		var/new_rank
		if(admin_ranks.len)
			new_rank = input("Please select a rank", "New rank", null, null) as null|anything in (admin_ranks|"*New Rank*")
		else
			new_rank = input("Please select a rank", "New rank", null, null) as null|anything in list("Game Master","Game Admin", "Trial Admin", "Admin Observer","*New Rank*")

		var/rights = 0
		if(D)
			rights = D.rights
		switch(new_rank)
			if(null,"")
				return
			if("*New Rank*")
				new_rank = input("Please input a new rank", "New custom rank", null, null) as null|text
				if(config.admin_legacy_system)
					new_rank = ckeyEx(new_rank)
				if(!new_rank)
					usr << "<font color='red'>Error: Topic 'editrights': Invalid rank</font>"
					return
				if(config.admin_legacy_system)
					if(admin_ranks.len)
						if(new_rank in admin_ranks)
							rights = admin_ranks[new_rank]		//we typed a rank which already exists, use its rights
						else
							admin_ranks[new_rank] = 0			//add the new rank to admin_ranks
			else
				if(config.admin_legacy_system)
					new_rank = ckeyEx(new_rank)
					rights = admin_ranks[new_rank]				//we input an existing rank, use its rights

		if(D)
			D.disassociate()								//remove adminverbs and unlink from client
			D.rank = new_rank								//update the rank
			D.rights = rights								//update the rights based on admin_ranks (default: 0)
		else
			D = new /datum/admins(new_rank, rights, adm_ckey)

		var/client/C = directory[adm_ckey]						//find the client with the specified ckey (if they are logged in)
		D.associate(C)											//link up with the client and add verbs

		C << "[key_name_admin(usr)] has set your admin rank to: [new_rank]."
		message_admins("[key_name_admin(usr)] edited the admin rank of [adm_ckey] to [new_rank]")
		log_admin("[key_name(usr)] edited the admin rank of [adm_ckey] to [new_rank]")
		source.log_admin_rank_modification(adm_ckey, new_rank)

	else if(task == "permissions")
		if(!D)
			return
		var/list/permissionlist = list()
		for(var/i=1, i<=R_MAXPERMISSION, i<<=1)		//that <<= is shorthand for i = i << 1. Which is a left bitshift
			permissionlist[rights2text(i)] = i
		var/new_permission = input("Select a permission to turn on/off", "Permission toggle", null, null) as null|anything in permissionlist
		if(!new_permission)
			return
		D.rights ^= permissionlist[new_permission]

		var/client/C = directory[adm_ckey]
		C << "[key_name_admin(usr)] has toggled your permission: [new_permission]."
		message_admins("[key_name_admin(usr)] toggled the [new_permission] permission of [adm_ckey]")
		log_admin("[key_name(usr)] toggled the [new_permission] permission of [adm_ckey]")
		source.log_admin_permission_modification(adm_ckey, permissionlist[new_permission], new_permission)

	source.edit_admin_permissions()


/datum/admin_topic/simplemake
	keyword = "simplemake"
	require_perms = list(R_FUN)

/datum/admin_topic/simplemake/Run(list/input, datum/admins/source)
	var/mob/M = locate(input["mob"])
	if(!ismob(M))
		usr << "This can only be used on instances of type /mob"
		return

	var/delmob = FALSE
	switch(alert("Delete old mob?","Message","Yes","No","Cancel"))
		if("Cancel")
			return
		if("Yes")
			delmob = TRUE

	log_admin("[key_name(usr)] has used rudimentary transformation on [key_name(M)]. Transforming to [input["simplemake"]]; deletemob=[delmob]")
	message_admins("\blue [key_name_admin(usr)] has used rudimentary transformation on [key_name_admin(M)]. Transforming to [input["simplemake"]]; deletemob=[delmob]", 1)

	switch(input["simplemake"])
		if("observer")
			M.change_mob_type( /mob/observer/ghost , null, null, delmob )
		if("angel")
			M.change_mob_type( /mob/observer/eye/angel , null, null, delmob )
		if("larva")
			M.change_mob_type( /mob/living/carbon/alien/larva , null, null, delmob )
		if("human")
			M.change_mob_type( /mob/living/carbon/human , null, null, delmob, input["species"])
		if("slime")
			M.change_mob_type( /mob/living/carbon/slime , null, null, delmob )
		if("monkey")
			M.change_mob_type( /mob/living/carbon/human/monkey , null, null, delmob )
		if("robot")
			M.change_mob_type( /mob/living/silicon/robot , null, null, delmob )
		if("cat")
			M.change_mob_type( /mob/living/simple_animal/cat , null, null, delmob )
		if("runtime")
			M.change_mob_type( /mob/living/simple_animal/cat/fluff/Runtime , null, null, delmob )
		if("corgi")
			M.change_mob_type( /mob/living/simple_animal/corgi , null, null, delmob )
		if("ian")
			M.change_mob_type( /mob/living/simple_animal/corgi/Ian , null, null, delmob )
		if("crab")
			M.change_mob_type( /mob/living/simple_animal/crab , null, null, delmob )
		if("coffee")
			M.change_mob_type( /mob/living/simple_animal/crab/Coffee , null, null, delmob )
		if("parrot")
			M.change_mob_type( /mob/living/simple_animal/parrot , null, null, delmob )
		if("polyparrot")
			M.change_mob_type( /mob/living/simple_animal/parrot/Poly , null, null, delmob )


/datum/admin_topic/unbanf
	keyword = "unbanf"
	require_perms = list(R_MOD|R_ADMIN)

/datum/admin_topic/unbanf/Run(list/input, datum/admins/source)
	var/banfolder = input["unbanf"]
	Banlist.cd = "/base/[banfolder]"
	var/key = Banlist["key"]
	if(alert(usr, "Are you sure you want to unban [key]?", "Confirmation", "Yes", "No") == "Yes")
		if(RemoveBan(banfolder))
			source.unbanpanel()
		else
			alert(usr, "This ban has already been lifted / does not exist.", "Error", "Ok")
			source.unbanpanel()


/datum/admin_topic/warn
	keyword = "warn"

/datum/admin_topic/warn/Run(list/input, datum/admins/source)
	usr.client.warn(input["warn"])


/datum/admin_topic/unbane
	keyword = "unbane"
	require_perms = list(R_MOD|R_ADMIN)

/datum/admin_topic/unbane/Run(list/input, datum/admins/source)

	UpdateTime()
	var/reason

	var/banfolder = input["unbane"]
	Banlist.cd = "/base/[banfolder]"
	var/reason2 = Banlist["reason"]
	var/temp = Banlist["temp"]

	var/minutes = Banlist["minutes"]

	var/banned_key = Banlist["key"]
	Banlist.cd = "/base"

	var/duration

	switch(alert("Temporary Ban?",,"Yes","No"))
		if("Yes")
			temp = TRUE
			var/mins = 0
			if(minutes > CMinutes)
				mins = minutes - CMinutes
			mins = input(usr,"How long (in minutes)? (Default: 1440)","Ban time",mins ? mins : 1440) as num|null
			if(!mins)
				return
			mins = min(525599,mins)
			minutes = CMinutes + mins
			duration = GetExp(minutes)
			reason = sanitize(input(usr,"Reason?","reason",reason2) as text|null)
			if(!reason)
				return
		if("No")
			temp = FALSE
			duration = "Perma"
			reason = sanitize(input(usr,"Reason?","reason",reason2) as text|null)
			if(!reason)
				return

	log_admin("[key_name(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]")
	ban_unban_log_save("[key_name(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]")
	message_admins("\blue [key_name_admin(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]", 1)
	Banlist.cd = "/base/[banfolder]"
	Banlist["reason"] << reason
	Banlist["temp"] << temp
	Banlist["minutes"] << minutes
	Banlist["bannedby"] << usr.ckey
	Banlist.cd = "/base"

	source.unbanpanel()


/datum/admin_topic/jobban2
	keyword = "jobban2"
	require_perms = list(R_MOD|R_ADMIN)

/datum/admin_topic/jobban2/Run(list/input, datum/admins/source)

	var/mob/M = locate(input["jobban2"])
	if(!ismob(M))
		usr << "This can only be used on instances of type /mob"
		return

	if(!M.ckey)	//sanity
		usr << "This mob has no ckey"
		return

	var/dat = ""
	var/header = {"
		<title>Job-Ban Panel: [M.name]</title>
		<style>
			a{
				word-spacing: normal;
			}
			.jobs{
				text-align:center;
				word-spacing: 30px;
			}
		</style>
	"}
	var/list/body = list()

	//Regular jobs
	//Command (Blue)
	body += source.formatJobGroup(M, "Command Positions", "ccccff", "commanddept", command_positions)
	//Security (Red)
	body += source.formatJobGroup(M, "Security Positions", "ffddf0", "securitydept", security_positions)
	//Engineering (Yellow)
	body += source.formatJobGroup(M, "Engineering Positions", "fff5cc", "engineeringdept", engineering_positions)
	//Medical (White)
	body += source.formatJobGroup(M, "Medical Positions", "ffeef0", "medicaldept", medical_positions)
	//Science (Purple)
	body += source.formatJobGroup(M, "Science Positions", "e79fff", "sciencedept", science_positions)
	//Civilian (Grey)
	body += source.formatJobGroup(M, "Civilian Positions", "dddddd", "civiliandept", civilian_positions)
	//Non-Human (Green)
	body += source.formatJobGroup(M, "Non-human Positions", "ccffcc", "nonhumandept", nonhuman_positions + "Antag HUD")
	//Antagonist (Orange)

	var/jobban_list = list()
	for(var/a_id in GLOB.antag_bantypes)
		var/a_ban = GLOB.antag_bantypes[a_id]
		jobban_list[get_antag_data(a_id).role_text] = a_ban
	body += source.formatJobGroup(M, "Antagonist Positions", "ffeeaa", "Syndicate", jobban_list)

	dat = "<head>[header]</head><body><tt><table width='100%'>[body.Join(null)]</table></tt></body>"
	usr << browse(dat, "window=jobban2;size=800x490")


/datum/admin_topic/jobban3
	keyword = "jobban3"
	require_perms = list(R_MOD|R_ADMIN)

/datum/admin_topic/jobban3/Run(list/input, datum/admins/source)
	if(check_rights(R_MOD, FALSE) && !check_rights(R_ADMIN, FALSE) && !config.mods_can_job_tempban) // If mod and tempban disabled
		usr << SPAN_WARNING("Mod jobbanning is disabled!")
		return

	var/mob/M = locate(input["jobban4"])
	if(!ismob(M))
		usr << "This can only be used on instances of type /mob"
		return

	if(M != usr)																//we can jobban ourselves
		if(M.client && M.client.holder && (M.client.holder.rights & R_ADMIN || M.client.holder.rights & R_MOD))		//they can ban too. So we can't ban them
			alert("You cannot perform this action. You must be of a higher administrative rank!")
			return

	//get jobs for department if specified, otherwise just returnt he one job in a list.
	var/list/joblist = list()
	switch(input["jobban3"])
		if("commanddept")
			for(var/jobPos in command_positions)
				var/datum/job/temp = SSjob.GetJob(jobPos)
				if(!temp) continue
				joblist += temp.title
		if("securitydept")
			for(var/jobPos in security_positions)
				var/datum/job/temp = SSjob.GetJob(jobPos)
				if(!temp) continue
				joblist += temp.title
		if("engineeringdept")
			for(var/jobPos in engineering_positions)
				var/datum/job/temp = SSjob.GetJob(jobPos)
				if(!temp) continue
				joblist += temp.title
		if("medicaldept")
			for(var/jobPos in medical_positions)
				var/datum/job/temp = SSjob.GetJob(jobPos)
				if(!temp) continue
				joblist += temp.title
		if("sciencedept")
			for(var/jobPos in science_positions)
				var/datum/job/temp = SSjob.GetJob(jobPos)
				if(!temp) continue
				joblist += temp.title
		if("civiliandept")
			for(var/jobPos in civilian_positions)
				var/datum/job/temp = SSjob.GetJob(jobPos)
				if(!temp) continue
				joblist += temp.title
		if("nonhumandept")
			joblist += "pAI"
			for(var/jobPos in nonhuman_positions)
				if(!jobPos)	continue
				var/datum/job/temp = SSjob.GetJob(jobPos)
				if(!temp) continue
				joblist += temp.title
		else
			joblist += input["jobban3"]

	//Create a list of unbanned jobs within joblist
	var/list/notbannedlist = list()
	for(var/job in joblist)
		if(!jobban_isbanned(M, job))
			notbannedlist += job

	//Banning comes first
	if(notbannedlist.len) //at least 1 unbanned job exists in joblist so we have stuff to ban.
		switch(alert("Temporary Ban?",,"Yes","No", "Cancel"))
			if("Yes")

				if(config.ban_legacy_system)
					usr << "\red Your server is using the legacy banning system, which does not support temporary job bans. Consider upgrading. Aborting ban."
					return
				var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
				if(!mins)
					return
				if(check_rights(R_MOD, FALSE) && !check_rights(R_ADMIN, FALSE) && mins > config.mod_job_tempban_max)
					usr << SPAN_WARNING("Moderators can only job tempban up to [config.mod_job_tempban_max] minutes!")
					return
				var/reason = sanitize(input(usr,"Reason?","Please State Reason","") as text|null)
				if(!reason)
					return

				var/msg
				for(var/job in notbannedlist)
					ban_unban_log_save("[key_name(usr)] temp-jobbanned [key_name(M)] from [job] for [mins] minutes. reason: [reason]")
					log_admin("[key_name(usr)] temp-jobbanned [key_name(M)] from [job] for [mins] minutes")

					source.DB_ban_record(BANTYPE_JOB_TEMP, M, mins, reason, job)

					jobban_fullban(M, job, "[reason]; By [usr.ckey] on [time2text(world.realtime)]") //Legacy banning does not support temporary jobbans.
					if(!msg)
						msg = job
					else
						msg += ", [job]"
				message_admins("\blue [key_name_admin(usr)] banned [key_name_admin(M)] from [msg] for [mins] minutes", 1)
				M << "\red<BIG><B>You have been jobbanned by [usr.client.ckey] from: [msg].</B></BIG>"
				M << "\red <B>The reason is: [reason]</B>"
				M << "\red This jobban will be lifted in [mins] minutes."
				input["jobban2"] = TRUE // lets it fall through and refresh
				return TRUE
			if("No")
				var/reason = sanitize(input(usr,"Reason?","Please State Reason","") as text|null)
				if(reason)
					var/msg
					for(var/job in notbannedlist)
						ban_unban_log_save("[key_name(usr)] perma-jobbanned [key_name(M)] from [job]. reason: [reason]")
						log_admin("[key_name(usr)] perma-banned [key_name(M)] from [job]")

						source.DB_ban_record(BANTYPE_JOB_PERMA, M, -1, reason, job)

						jobban_fullban(M, job, "[reason]; By [usr.ckey] on [time2text(world.realtime)]")
						if(!msg)	msg = job
						else		msg += ", [job]"
					message_admins("\blue [key_name_admin(usr)] banned [key_name_admin(M)] from [msg]", 1)
					M << "\red<BIG><B>You have been jobbanned by [usr.client.ckey] from: [msg].</B></BIG>"
					M << "\red <B>The reason is: [reason]</B>"
					M << "\red Jobban can be lifted only upon request."
					input["jobban2"] = TRUE // lets it fall through and refresh
					return TRUE
			if("Cancel")
				return

	//Unbanning joblist
	//all jobs in joblist are banned already OR we didn't give a reason (implying they shouldn't be banned)
	if(joblist.len) //at least 1 banned job exists in joblist so we have stuff to unban.
		if(!config.ban_legacy_system)
			usr << "Unfortunately, database based unbanning cannot be done through this panel"
			source.DB_ban_panel(M.ckey)
			return
		var/msg
		for(var/job in joblist)
			var/reason = jobban_isbanned(M, job)
			if(!reason) continue //skip if it isn't jobbanned anyway
			switch(alert("Job: '[job]' Reason: '[reason]' Un-jobban?","Please Confirm","Yes","No"))
				if("Yes")
					ban_unban_log_save("[key_name(usr)] unjobbanned [key_name(M)] from [job]")
					log_admin("[key_name(usr)] unbanned [key_name(M)] from [job]")
					source.DB_ban_unban(M.ckey, BANTYPE_JOB_PERMA, job)


					jobban_unban(M, job)
					if(!msg)	msg = job
					else		msg += ", [job]"
				else
					continue
		if(msg)
			message_admins("\blue [key_name_admin(usr)] unbanned [key_name_admin(M)] from [msg]", 1)
			M << "\red<BIG><B>You have been un-jobbanned by [usr.client.ckey] from [msg].</B></BIG>"
			input["jobban2"] = TRUE // lets it fall through and refresh
		return TRUE
	return FALSE //we didn't do anything!


/datum/admin_topic/boot2
	keyword = "boot"

/datum/admin_topic/boot2/Run(list/input, datum/admins/source)
	var/mob/M = locate(input["boot2"])
	if (ismob(M))
		if(!check_if_greater_rights_than(M.client))
			return
		var/reason = sanitize(input("Please enter reason"))
		if(!reason)
			M << "\red You have been kicked from the server"
		else
			M << "\red You have been kicked from the server: [reason]"
		log_admin("[key_name(usr)] booted [key_name(M)].")
		message_admins("\blue [key_name_admin(usr)] booted [key_name_admin(M)].", 1)
		//M.client = null
		qdel(M.client)


/datum/admin_topic/removejobban
	keyword = "removejobban"
	require_perms = list(R_MOD|R_ADMIN)

/datum/admin_topic/removejobban/Run(list/input, datum/admins/source)
	var/t = input["removejobban"]
	if(t)
		if((alert("Do you want to unjobban [t]?","Unjobban confirmation", "Yes", "No") == "Yes") && t) //No more misclicks! Unless you do it twice.
			log_admin("[key_name(usr)] removed [t]")
			message_admins("\blue [key_name_admin(usr)] removed [t]", 1)
			jobban_remove(t)
			input["ban"] = TRUE // lets it fall through and refresh
			var/t_split = splittext(t, " - ")
			var/key = t_split[1]
			var/job = t_split[2]
			source.DB_ban_unban(ckey(key), BANTYPE_JOB_PERMA, job)


/datum/admin_topic/newban
	keyword = "newban"
	require_perms = (R_MOD|R_ADMIN)

/datum/admin_topic/newban/Run(list/input, datum/admins/source)
	if(check_rights(R_MOD, FALSE) && !check_rights(R_ADMIN, FALSE) && !config.mods_can_job_tempban) // If mod and tempban disabled
		usr << SPAN_WARNING("Mod jobbanning is disabled!")
		return

	var/mob/M = locate(input["newban"])
	if(!ismob(M)) return

	if(M.client && M.client.holder)
		return	//admins cannot be banned. Even if they could, the ban doesn't affect them anyway

	switch(alert("Temporary Ban?",,"Yes","No", "Cancel"))
		if("Yes")
			var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
			if(!mins)
				return

			if(check_rights(R_MOD, FALSE) && !check_rights(R_ADMIN, FALSE) && mins > config.mod_tempban_max)
				usr << SPAN_WARNING("Moderators can only job tempban up to [config.mod_tempban_max] minutes!")
				return
			if(mins >= 525600) mins = 525599
			var/reason = sanitize(input(usr,"Reason?","reason","Griefer") as text|null)
			if(!reason)
				return
			AddBan(M.ckey, M.computer_id, reason, usr.ckey, 1, mins)
			ban_unban_log_save("[usr.client.ckey] has banned [M.ckey]. - Reason: [reason] - This will be removed in [mins] minutes.")
			M << "\red<BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG>"
			M << "\red This is a temporary ban, it will be removed in [mins] minutes."

			source.DB_ban_record(BANTYPE_TEMP, M, mins, reason)

			if(config.banappeals)
				M << "\red To try to resolve this matter head to [config.banappeals]"
			else
				M << "\red No ban appeals URL has been set."
			log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")
			message_admins("\blue[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")

			qdel(M.client)
			//qdel(M)	// See no reason why to delete mob. Important stuff can be lost. And ban can be lifted before round ends.
		if("No")
			var/reason = sanitize(input(usr,"Reason?","reason","Griefer") as text|null)
			if(!reason)
				return
			switch(alert(usr,"IP ban?",,"Yes","No","Cancel"))
				if("Cancel")	return
				if("Yes")
					AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0, M.lastKnownIP)
				if("No")
					AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0)
			M << "\red<BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG>"
			M << "\red This is a permanent ban."
			if(config.banappeals)
				M << "\red To try to resolve this matter head to [config.banappeals]"
			else
				M << "\red No ban appeals URL has been set."
			ban_unban_log_save("[usr.client.ckey] has permabanned [M.ckey]. - Reason: [reason] - This is a permanent ban.")
			log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")
			message_admins("\blue[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")

			source.DB_ban_record(BANTYPE_PERMA, M, -1, reason)

			qdel(M.client)
		if("Cancel")
			return


/datum/admin_topic/mute
	keyword = "mute"
	require_perms = list(R_MOD|R_ADMIN)

/datum/admin_topic/mute/Run(list/input, datum/admins/source)
	var/mob/M = locate(input["mute"])
	if(!ismob(M))
		return
	if(!M.client)
		return

	var/mute_type = input["mute_type"]
	if(istext(mute_type))
		mute_type = text2num(mute_type)
	if(!isnum(mute_type))
		return

	cmd_admin_mute(M, mute_type)


/datum/admin_topic/check_antagonist
	keyword = "check_antagonist"
	require_perms = list(R_ADMIN)

/datum/admin_topic/check_antagonist/Run(list/input, datum/admins/source)
	GLOB.storyteller.storyteller_panel()


/datum/admin_topic/c_mode
	keyword = "c_mode"
	require_perms = list(R_ADMIN)

/datum/admin_topic/c_mode/Run(list/input, datum/admins/source)
	var/dat = {"<B>What storyteller do you wish to install?</B><HR>"}
	for(var/mode in config.storytellers)
		dat += {"<A href='?src=\ref[source];c_mode2=[mode]'>[config.storyteller_names[mode]]</A><br>"}
	dat += {"Now: [master_storyteller]"}
	usr << browse(dat, "window=c_mode")


/datum/admin_topic/c_mode2
	keyword = "c_mode2"
	require_perms = list(R_ADMIN|R_SERVER)

/datum/admin_topic/c_mode2/Run(list/input, datum/admins/source)
	master_storyteller = input["c_mode2"]
	set_storyteller(master_storyteller) //This does the actual work
	log_admin("[key_name(usr)] set the storyteller to [master_storyteller].")
	message_admins("\blue [key_name_admin(usr)] set the storyteller to [master_storyteller].", 1)
	source.Game() // updates the main game menu
	world.save_storyteller(master_storyteller)
	source.Topic(source, list("c_mode"=1))


/datum/admin_topic/monkeyone
	keyword = "monkeyone"
	require_perms = list(R_FUN)

/datum/admin_topic/monkeyone/Run(list/input, datum/admins/source)
	var/mob/living/carbon/human/H = locate(input["monkeyone"])
	if(!istype(H))
		usr << "This can only be used on instances of type /mob/living/carbon/human"
		return

	log_admin("[key_name(usr)] attempting to monkeyize [key_name(H)]")
	message_admins("\blue [key_name_admin(usr)] attempting to monkeyize [key_name_admin(H)]", 1)
	H.monkeyize()


/datum/admin_topic/corgione
	keyword = "corgione"
	require_perms = list(R_FUN)

/datum/admin_topic/corgione/Run(list/input, datum/admins/source)
	var/mob/living/carbon/human/H = locate(input["corgione"])
	if(!istype(H))
		usr << "This can only be used on instances of type /mob/living/carbon/human"
		return

	log_admin("[key_name(usr)] attempting to corgize [key_name(H)]")
	message_admins("\blue [key_name_admin(usr)] attempting to corgize [key_name_admin(H)]", 1)
	H.corgize()


/datum/admin_topic/forcespeech
	keyword = "forcespeech"
	require_perms = list(R_FUN)

/datum/admin_topic/forcespeech/Run(list/input, datum/admins/source)
	var/mob/M = locate(input["forcespeech"])
	if(!ismob(M))
		usr << "this can only be used on instances of type /mob"

	var/speech = input("What will [key_name(M)] say?.", "Force speech", "")// Don't need to sanitize, since it does that in say(), we also trust our admins. //don't trust your admins.
	if(!speech)
		return
	M.say(speech)
	speech = sanitize(speech) // Nah, we don't trust them
	log_admin("[key_name(usr)] forced [key_name(M)] to say: [speech]")
	message_admins("\blue [key_name_admin(usr)] forced [key_name_admin(M)] to say: [speech]")


/datum/admin_topic/revive
	keyword = "revive"
	require_perms = list(R_FUN)

/datum/admin_topic/revive/Run(list/input, datum/admins/source)
	var/mob/living/L = locate(input["revive"])
	if(!istype(L))
		usr << "This can only be used on instances of type /mob/living"
		return

	if(config.allow_admin_rev)
		L.revive()
		message_admins("\red Admin [key_name_admin(usr)] healed / revived [key_name_admin(L)]!", 1)
		log_admin("[key_name(usr)] healed / Revived [key_name(L)]")
	else
		usr << "Admin Rejuvinates have been disabled"


/datum/admin_topic/makeai
	keyword = "makeai"
	require_perms = list(R_FUN)

/datum/admin_topic/makeai/Run(list/input, datum/admins/source)
	var/mob/living/L = locate(input["revive"])
	if(!istype(L))
		usr << "This can only be used on instances of type /mob/living"
		return

	if(config.allow_admin_rev)
		L.revive()
		message_admins("\red Admin [key_name_admin(usr)] healed / revived [key_name_admin(L)]!", 1)
		log_admin("[key_name(usr)] healed / Revived [key_name(L)]")
	else
		usr << "Admin Rejuvinates have been disabled"


/datum/admin_topic/makeslime
	keyword = "makeslime"
	require_perms = list(R_FUN)

/datum/admin_topic/makeslime/Run(list/input, datum/admins/source)
	var/mob/living/carbon/human/H = locate(input["makeslime"])
	if(!istype(H))
		usr << "This can only be used on instances of type /mob/living/carbon/human"
		return

	usr.client.cmd_admin_slimeize(H)


/datum/admin_topic/makerobot
	keyword = "makerobot"
	require_perms = list(R_FUN)

/datum/admin_topic/makerobot/Run(list/input, datum/admins/source)
	var/mob/living/carbon/human/H = locate(input["makerobot"])
	if(!istype(H))
		usr << "This can only be used on instances of type /mob/living/carbon/human"
		return

	usr.client.cmd_admin_robotize(H)


/datum/admin_topic/makeanimal
	keyword = "makeanimal"
	require_perms = list(R_FUN)

/datum/admin_topic/makeanimal/Run(list/input, datum/admins/source)
	var/mob/living/carbon/human/H = locate(input["makerobot"])
	if(!istype(H))
		usr << "This can only be used on instances of type /mob/living/carbon/human"
		return

	usr.client.cmd_admin_robotize(H)


/datum/admin_topic/togmutate
	keyword = "togmutate"
	require_perms = list(R_FUN)

/datum/admin_topic/togmutate/Run(list/input, datum/admins/source)
	var/mob/living/carbon/human/H = locate(input["togmutate"])
	if(!istype(H))
		usr << "This can only be used on instances of type /mob/living/carbon/human"
		return
	var/block=text2num(input["block"])
	usr.client.cmd_admin_toggle_block(H,block)
	source.show_player_panel(H)


/datum/admin_topic/adminplayeropts
	keyword = "adminplayeropts"

/datum/admin_topic/adminplayeropts/Run(list/input, datum/admins/source)
	var/mob/M = locate(input["adminplayeropts"])
	source.show_player_panel(M)


/datum/admin_topic/adminobservejump
	keyword = "adminobservejump"
	require_perms = list(R_MENTOR|R_MOD|R_ADMIN)

/datum/admin_topic/adminobservejump/Run(list/input, datum/admins/source)
	var/mob/M = locate(input["adminplayerobservejump"])

	var/client/C = usr.client
	if(!isghost(usr))
		C.admin_ghost()
		sleep(2)
	C.jumptomob(M)


/datum/admin_topic/adminplayerobservecoodjump
	keyword = "adminplayerobservecoodjump"
	require_perms = (R_ADMIN)

/datum/admin_topic/adminplayerobservecoodjump/Run(list/input, datum/admins/source)
	var/x = text2num(input["X"])
	var/y = text2num(input["Y"])
	var/z = text2num(input["Z"])

	var/client/C = usr.client
	if(!isghost(usr))
		C.admin_ghost()
	C.jumptocoord(x,y,z)


/datum/admin_topic/adminchecklaws
	keyword = "adminchecklaws"

/datum/admin_topic/adminchecklaws/Run(list/input, datum/admins/source)
	source.output_ai_laws()


/datum/admin_topic/adminmoreinfo
	keyword = "adminmoreinfo"

/datum/admin_topic/adminmoreinfo/Run(list/input, datum/admins/source)
	var/mob/M = locate(input["adminmoreinfo"])
	if(!ismob(M))
		usr << "This can only be used on instances of type /mob"
		return

	var/location_description = ""
	var/special_role_description = ""
	var/health_description = ""
	var/gender_description = ""
	var/turf/T = get_turf(M)

	//Location
	if(isturf(T))
		if(isarea(T.loc))
			location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z] in area <b>[T.loc]</b>)"
		else
			location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z])"

	//Job + antagonist
	if(M.mind)
		var/antag = ""
		for(var/datum/antagonist/A in M.mind.antagonist)
			antag += "[A.role_text], "
		special_role_description = "Role: <b>[M.mind.assigned_role]</b>; Antagonist: <font color='red'><b>[get_player_antag_name(M.mind)]</b></font>;"
	else
		special_role_description = "Role: <i>Mind datum missing</i> Antagonist: <i>Mind datum missing</i>; Has been rev: <i>Mind datum missing</i>;"

	//Health
	if(isliving(M))
		var/mob/living/L = M
		var/status
		switch (M.stat)
			if (0)
				status = "Alive"
			if (1)
				status = "<font color='orange'><b>Unconscious</b></font>"
			if (2)
				status = "<font color='red'><b>Dead</b></font>"
		health_description = "Status = [status]"
		health_description += "<BR>Oxy: [L.getOxyLoss()] - Tox: [L.getToxLoss()] - Fire: [L.getFireLoss()] - Brute: [L.getBruteLoss()] - Clone: [L.getCloneLoss()] - Brain: [L.getBrainLoss()]"
	else
		health_description = "This mob type has no health to speak of."

	//Gener
	switch(M.gender)
		if(MALE,FEMALE)
			gender_description = "[M.gender]"
		else
			gender_description = "<font color='red'><b>[M.gender]</b></font>"

	source.owner << "<b>Info about [M.name]:</b> "
	source.owner << "Mob type = [M.type]; Gender = [gender_description] Damage = [health_description]"
	source.owner << "Name = <b>[M.name]</b>; Real_name = [M.real_name]; Mind_name = [M.mind?"[M.mind.name]":""]; Key = <b>[M.key]</b>;"
	source.owner << "Location = [location_description];"
	source.owner << "[special_role_description]"
	source.owner << "(<a href='?src=\ref[usr];priv_msg=\ref[M]'>PM</a>) (<A HREF='?src=\ref[source];adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[M]'>VV</A>) (<A HREF='?src=\ref[source];subtlemessage=\ref[M]'>SM</A>) ([admin_jump_link(M, source)]) (<A HREF='?src=\ref[source];secretsadmin=check_antagonist'>CA</A>)"


/datum/admin_topic/adminspawncookie
	keyword = "adminspawncookie"
	require_perms = list(R_ADMIN|R_FUN)

/datum/admin_topic/adminspawncookie/Run(list/input, datum/admins/source)
	var/mob/living/carbon/human/H = locate(input["adminspawncookie"])
	if(!ishuman(H))
		usr << "This can only be used on instances of type /mob/living/carbon/human"
		return

	if(!H.equip_to_slot_or_del( new /obj/item/weapon/reagent_containers/food/snacks/cookie(H), slot_l_hand ))
		if(!H.equip_to_slot_or_del( new /obj/item/weapon/reagent_containers/food/snacks/cookie(H), slot_r_hand ))
			log_admin("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(source.owner)].")
			message_admins("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(source.owner)].")
			return
	log_admin("[key_name(H)] got their cookie, spawned by [key_name(source.owner)]")
	message_admins("[key_name(H)] got their cookie, spawned by [key_name(source.owner)]")

	H << "\blue Your prayers have been answered!! You received the <b>best cookie</b>!"


/datum/admin_topic/bluespaceartillery
	keyword = "BlueSpaceArtillery"
	require_perms = list(R_ADMIN|R_FUN)

/datum/admin_topic/bluespaceartillery/Run(list/input, datum/admins/source)
	var/mob/living/M = locate(input["BlueSpaceArtillery"])
	if(!isliving(M))
		usr << "This can only be used on instances of type /mob/living"
		return

	if(alert(source.owner, "Are you sure you wish to hit [key_name(M)] with Blue Space Artillery?",  "Confirm Firing?" , "Yes" , "No") != "Yes")
		return

	if(BSACooldown)
		source.owner << "Standby!  Reload cycle in progress!  Gunnary crews ready in five seconds!"
		return

	BSACooldown = TRUE
	spawn(50)
		BSACooldown = FALSE

	M << "You've been hit by bluespace artillery!"
	log_admin("[key_name(M)] has been hit by Bluespace Artillery fired by [source.owner]")
	message_admins("[key_name(M)] has been hit by Bluespace Artillery fired by [source.owner]")

	var/obj/effect/stop/S
	S = new /obj/effect/stop
	S.victim = M
	S.loc = M.loc
	spawn(20)
		qdel(S)

	var/turf/simulated/floor/T = get_turf(M)
	if(istype(T))
		if(prob(80))
			T.break_tile_to_plating()
		else
			T.break_tile()

	if(M.health == 1)
		M.gib()
	else
		M.adjustBruteLoss( min( 99 , (M.health - 1) )    )
		M.Stun(20)
		M.Weaken(20)
		M.stuttering = 20
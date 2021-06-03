/datum/admin_topic
	var/keyword
	var/list/require_perms = list()
	var/datum/admins/source
	//The permissions needed to run the topic.
	//If you want the user to need multiple perms, have each perm be an entry into the list, like this: list(R_ADMIN, R_MOD)
	//If you want the user to need just one of multiple perms, have the perms be the same entry in the list using OR, like this: list(R_ADMIN|R_MOD)
	//These can be combined, for example with: list(R_MOD|R_MENTOR, R_ADMIN) which would require you to have either R_MOD or R_MENTOR, as well as R_ADMIN

/datum/admin_topic/proc/TryRun(list/input, datum/admins/owner)
	if(require_perms.len)
		for(var/i in require_perms)
			if(!check_rights(i, TRUE))
				return FALSE
	source = owner
	. = Run(input)
	qdel(src)

/datum/admin_topic/proc/Run(list/input) //use the source arg to access the admin datum.
	CRASH("Run() not implemented for [type]!")


/datum/admin_topic/dbsearchckey
	keyword = "dbsearchckey"

/datum/admin_topic/dbsearchckey/dbsearchadmin //inherits the behaviour of dbsearchckey, but with a different keyword.
	keyword = "dbsearchadmin"

/datum/admin_topic/dbsearchckey/Run(list/input)
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

/datum/admin_topic/dbbanedit/Run(list/input)
	var/banedit = input["dbbanedit"]
	var/banid = text2num(input["dbbanid"])
	if(!banedit || !banid)
		return

	source.DB_ban_edit(banid, banedit)


/datum/admin_topic/dbbanaddtype
	keyword = "dbbanaddtype"

/datum/admin_topic/dbbanaddtype/Run(list/input)
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
				to_chat(usr, "Not enough parameters (Requires ckey and reason)")
				return
			banduration = null
			banjob = null
		if(BANTYPE_TEMP)
			if(!banckey || !banreason || !banduration)
				to_chat(usr, "Not enough parameters (Requires ckey, reason and duration)")
				return
			banjob = null
		if(BANTYPE_JOB_PERMA)
			if(!banckey || !banreason || !banjob)
				to_chat(usr, "Not enough parameters (Requires ckey, reason and job)")
				return
			banduration = null
		if(BANTYPE_JOB_TEMP)
			if(!banckey || !banreason || !banjob || !banduration)
				to_chat(usr, "Not enough parameters (Requires ckey, reason and job)")
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

/datum/admin_topic/editrights/Run(list/input)

	var/adm_ckey

	var/task = input["editrights"]
	if(task == "add")
		var/new_ckey = ckey(input(usr,"New admin's ckey","Admin ckey", null) as text|null)
		if(!new_ckey)
			return
		if(new_ckey in admin_datums)
			to_chat(usr, "<font color='red'>Error: Topic 'editrights': [new_ckey] is already an admin</font>")
			return
		adm_ckey = new_ckey
		task = "rank"
	else if(task != "show")
		adm_ckey = ckey(input["ckey"])
		if(!adm_ckey)
			to_chat(usr, "<font color='red'>Error: Topic 'editrights': No valid ckey</font>")
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
					to_chat(usr, "<font color='red'>Error: Topic 'editrights': Invalid rank</font>")
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

		to_chat(C, "[key_name_admin(usr)] has set your admin rank to: [new_rank].")
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
		to_chat(C, "[key_name_admin(usr)] has toggled your permission: [new_permission].")
		message_admins("[key_name_admin(usr)] toggled the [new_permission] permission of [adm_ckey]")
		log_admin("[key_name(usr)] toggled the [new_permission] permission of [adm_ckey]")
		source.log_admin_permission_modification(adm_ckey, permissionlist[new_permission], new_permission)

	source.edit_admin_permissions()


/datum/admin_topic/simplemake
	keyword = "simplemake"
	require_perms = list(R_FUN)

/datum/admin_topic/simplemake/Run(list/input)
	var/mob/M = locate(input["mob"])
	if(!ismob(M))
		to_chat(usr, "This can only be used on instances of type /mob")
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

/datum/admin_topic/unbanf/Run(list/input)
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

/datum/admin_topic/warn/Run(list/input)
	usr.client.warn(input["warn"])


/datum/admin_topic/unbane
	keyword = "unbane"
	require_perms = list(R_MOD|R_ADMIN)

/datum/admin_topic/unbane/Run(list/input)

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

/datum/admin_topic/jobban2/Run(list/input)

	var/mob/M = locate(input["jobban2"])
	if(!ismob(M))
		to_chat(usr, "This can only be used on instances of type /mob")
		return

	if(!M.ckey)	//sanity
		to_chat(usr, "This mob has no ckey")
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
	body += source.formatJobGroup(M, "Engineering Positions", "d5c88f", "engineeringdept", engineering_positions)
	//Medical (White)
	body += source.formatJobGroup(M, "Medical Positions", "ffeef0", "medicaldept", medical_positions)
	//Science (Purple)
	body += source.formatJobGroup(M, "Science Positions", "e79fff", "sciencedept", science_positions)
	//Church (Gold)
	body += source.formatJobGroup(M, "Church Positions", "ecd37d", "churchdept", church_positions)
	//Civilian (Grey)
	body += source.formatJobGroup(M, "Civilian Positions", "dddddd", "civiliandept", civilian_positions)
	//Non-Human (Green)
	body += source.formatJobGroup(M, "Non-human Positions", "ccffcc", "nonhumandept", nonhuman_positions + "Antag HUD")
	//Antagonist (Orange)

	var/jobban_list = list()
	for(var/a_id in GLOB.antag_bantypes)
		var/a_ban = GLOB.antag_bantypes[a_id]
		var/datum/antagonist/antag = get_antag_data(a_id)
		jobban_list[antag.role_text] = a_ban
	body += source.formatJobGroup(M, "Antagonist Positions", "ffeeaa", "Syndicate", jobban_list)

	dat = "<head>[header]</head><body><tt><table width='100%'>[body.Join(null)]</table></tt></body>"
	usr << browse(dat, "window=jobban2;size=800x490")


/datum/admin_topic/jobban3
	keyword = "jobban3"
	require_perms = list(R_MOD|R_ADMIN)

/datum/admin_topic/jobban3/Run(list/input)
	if(check_rights(R_MOD, FALSE) && !check_rights(R_ADMIN, FALSE) && !config.mods_can_job_tempban) // If mod and tempban disabled
		to_chat(usr, SPAN_WARNING("Mod jobbanning is disabled!"))
		return

	var/mob/M = locate(input["jobban4"])
	if(!ismob(M))
		to_chat(usr, "This can only be used on instances of type /mob")
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
		if("churchdept")
			for(var/jobPos in church_positions)
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
					to_chat(usr, "\red Your server is using the legacy banning system, which does not support temporary job bans. Consider upgrading. Aborting ban.")
					return
				var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
				if(!mins)
					return
				if(check_rights(R_MOD, FALSE) && !check_rights(R_ADMIN, FALSE) && mins > config.mod_job_tempban_max)
					to_chat(usr, SPAN_WARNING("Moderators can only job tempban up to [config.mod_job_tempban_max] minutes!"))
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
				to_chat(M, "\red<BIG><B>You have been jobbanned by [usr.client.ckey] from: [msg].</B></BIG>")
				to_chat(M, "\red <B>The reason is: [reason]</B>")
				to_chat(M, "\red This jobban will be lifted in [mins] minutes.")
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
					to_chat(M, "\red<BIG><B>You have been jobbanned by [usr.client.ckey] from: [msg].</B></BIG>")
					to_chat(M, "\red <B>The reason is: [reason]</B>")
					to_chat(M, "\red Jobban can be lifted only upon request.")
					input["jobban2"] = TRUE // lets it fall through and refresh
					return TRUE
			if("Cancel")
				return

	//Unbanning joblist
	//all jobs in joblist are banned already OR we didn't give a reason (implying they shouldn't be banned)
	if(joblist.len) //at least 1 banned job exists in joblist so we have stuff to unban.
		if(!config.ban_legacy_system)
			to_chat(usr, "Unfortunately, database based unbanning cannot be done through this panel")
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
			to_chat(M, "\red<BIG><B>You have been un-jobbanned by [usr.client.ckey] from [msg].</B></BIG>")
			input["jobban2"] = TRUE // lets it fall through and refresh
		return TRUE
	return FALSE //we didn't do anything!


/datum/admin_topic/boot2
	keyword = "boot2"
	require_perms = list(R_MOD|R_ADMIN)

/datum/admin_topic/boot2/Run(list/input)
	var/mob/M = locate(input["boot2"])
	if (ismob(M))
		if(!check_if_greater_rights_than(M.client))
			return
		var/reason = sanitize(input("Please enter reason"))
		if(!reason)
			to_chat(M, "\red You have been kicked from the server")
		else
			to_chat(M, "\red You have been kicked from the server: [reason]")
		log_admin("[key_name(usr)] booted [key_name(M)].")
		message_admins("\blue [key_name_admin(usr)] booted [key_name_admin(M)].", 1)
		del(M.client)


/datum/admin_topic/removejobban
	keyword = "removejobban"
	require_perms = list(R_MOD|R_ADMIN)

/datum/admin_topic/removejobban/Run(list/input)
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
	require_perms = list(R_MOD|R_ADMIN)

/datum/admin_topic/newban/Run(list/input)
	if(check_rights(R_MOD, FALSE) && !check_rights(R_ADMIN, FALSE) && !config.mods_can_job_tempban) // If mod and tempban disabled
		to_chat(usr, SPAN_WARNING("Mod jobbanning is disabled!"))
		return

	var/mob/M = locate(input["newban"])
	if(!ismob(M)) return

	if(M.client && M.client.holder)
		return	//admins cannot be banned. Even if they could, the ban doesn't affect them anyway
	var/delayed = 0
	if(alert("Delayed Ban?", "Ban after roundend. Work with DB only.", "Yes", "No") == "Yes")
		delayed = 1

	switch(alert("Temporary Ban?",,"Yes","No", "Cancel"))
		if("Yes")
			var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
			if(!mins)
				return

			if(check_rights(R_MOD, FALSE) && !check_rights(R_ADMIN, FALSE) && mins > config.mod_tempban_max)
				to_chat(usr, SPAN_WARNING("Moderators can only job tempban up to [config.mod_tempban_max] minutes!"))
				return
			if(mins >= 525600) mins = 525599
			var/reason = sanitize(input(usr,"Reason?","reason","Griefer") as text|null)
			if(!reason)
				return
			AddBan(M.ckey, M.computer_id, reason, usr.ckey, 1, mins, delayed_ban = delayed)
			ban_unban_log_save("[usr.client.ckey] has banned [M.ckey]. - Reason: [reason] - This will be removed in [mins] minutes.")
			to_chat(M, "\red<BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG>")
			to_chat(M, "\red This is a temporary ban, it will be removed in [mins] minutes.")

			source.DB_ban_record(BANTYPE_TEMP, M, mins, reason, delayed_ban = delayed)

			if(config.banappeals)
				to_chat(M, "\red To try to resolve this matter head to [config.banappeals]")
			else
				to_chat(M, "\red No ban appeals URL has been set.")
			log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")
			message_admins("\blue[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")

			if(!delayed)
				del(M.client)
			//qdel(M)	// See no reason why to delete mob. Important stuff can be lost. And ban can be lifted before round ends.
		if("No")
			var/no_ip = 0
			var/reason = sanitize(input(usr,"Reason?","reason","Griefer") as text|null)
			if(!reason)
				return
			switch(alert(usr,"IP ban?",,"Yes","No","Cancel"))
				if("Cancel")	return
				if("Yes")
					AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0, M.lastKnownIP, delayed_ban = delayed)
				if("No")
					AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0, delayed_ban = delayed)
					no_ip = 1
			to_chat(M, "\red<BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG>")
			to_chat(M, "\red This is a permanent ban.")
			if(config.banappeals)
				to_chat(M, "\red To try to resolve this matter head to [config.banappeals]")
			else
				to_chat(M, "\red No ban appeals URL has been set.")
			ban_unban_log_save("[usr.client.ckey] has permabanned [M.ckey]. - Reason: [reason] - This is a permanent ban.")
			log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")
			message_admins("\blue[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")
			var/banip = no_ip ? null : -1
			source.DB_ban_record(BANTYPE_PERMA, M, -1, reason, banip, delayed_ban = delayed)

			if(!delayed)
				del(M.client)
		if("Cancel")
			return

/datum/admin_topic/sendbacktolobby
	keyword = "sendbacktolobby"
	require_perms = list(R_ADMIN)

/datum/admin_topic/sendbacktolobby/Run(list/input)
	var/mob/M = locate(input["sendbacktolobby"])

	if(!isobserver(M))
		to_chat(usr, "<span class='notice'>You can only send ghost players back to the Lobby.</span>")
		return

	if(!M.client)
		to_chat(usr, "<span class='warning'>[M] doesn't seem to have an active client.</span>")
		return

	if(alert(usr, "Send [key_name(M)] back to Lobby?", "Message", "Yes", "No") != "Yes")
		return

	log_admin("[key_name(usr)] has sent [key_name(M)] back to the Lobby.")
	message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] back to the Lobby.")

	var/mob/new_player/NP = new()
	GLOB.player_list -= M.ckey
	NP.ckey = M.ckey
	qdel(M)

/datum/admin_topic/mute
	keyword = "mute"
	require_perms = list(R_MOD|R_ADMIN)

/datum/admin_topic/mute/Run(list/input)
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

/datum/admin_topic/check_antagonist/Run(list/input)
	GLOB.storyteller.storyteller_panel()


/datum/admin_topic/c_mode
	keyword = "c_mode"
	require_perms = list(R_ADMIN)

/datum/admin_topic/c_mode/Run(list/input)
	var/dat = {"<B>What storyteller do you wish to install?</B><HR>"}
	for(var/mode in config.storytellers)
		dat += {"<A href='?src=\ref[source];c_mode2=[mode]'>[config.storyteller_names[mode]]</A><br>"}
	dat += {"Now: [master_storyteller]"}
	usr << browse(dat, "window=c_mode")


/datum/admin_topic/c_mode2
	keyword = "c_mode2"
	require_perms = list(R_ADMIN|R_SERVER)

/datum/admin_topic/c_mode2/Run(list/input)
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

/datum/admin_topic/monkeyone/Run(list/input)
	var/mob/living/carbon/human/H = locate(input["monkeyone"])
	if(!istype(H))
		to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
		return

	log_admin("[key_name(usr)] attempting to monkeyize [key_name(H)]")
	message_admins("\blue [key_name_admin(usr)] attempting to monkeyize [key_name_admin(H)]", 1)
	H.monkeyize()


/datum/admin_topic/corgione
	keyword = "corgione"
	require_perms = list(R_FUN)

/datum/admin_topic/corgione/Run(list/input)
	var/mob/L= locate(input["corgione"])
	if(!istype(L))
		to_chat(usr, "This can only be used on instances of type /mob")
		return

	log_admin("[key_name(usr)] attempting to corgize [key_name(L)]")
	message_admins("\blue [key_name_admin(usr)] attempting to corgize [key_name_admin(L)]", 1)
	L.corgize()


/datum/admin_topic/forcespeech
	keyword = "forcespeech"
	require_perms = list(R_FUN)

/datum/admin_topic/forcespeech/Run(list/input)
	var/mob/M = locate(input["forcespeech"])
	if(!ismob(M))
		to_chat(usr, "this can only be used on instances of type /mob")

	var/speech = input("What will [key_name(M)] say?.", "Force speech", "")// Don't need to sanitize, since it does that in say(), we also trust our admins. //don't trust your admins.
	if(!speech)
		return
	M.say(speech)
	speech = sanitize(speech) // Nah, we don't trust them
	log_admin("[key_name(usr)] forced [key_name(M)] to say: [speech]")
	message_admins("\blue [key_name_admin(usr)] forced [key_name_admin(M)] to say: [speech]")

/datum/admin_topic/forcesanity
	keyword = "forcesanity"
	require_perms = list(R_FUN)

/datum/admin_topic/forcesanity/Run(list/input)
	var/mob/living/carbon/human/H = locate(input["forcesanity"])
	if(!ishuman(H))
		to_chat(usr, "This can only be used on instances of type /human.")
		return

	var/datum/breakdown/B = input("What breakdown will [key_name(H)] suffer from?", "Sanity Breakdown") as null | anything in subtypesof(/datum/breakdown)
	if(!B)
		return
	B = new B(H.sanity)
	if(!B.can_occur())
		to_chat(usr, "[B] could not occur. [key_name(H)] did not meet the right conditions.")
		qdel(B)
		return
	if(B.occur())
		H.sanity.breakdowns += B
		to_chat(usr, SPAN_NOTICE("[B] has occurred for [key_name(H)]."))
		return


/datum/admin_topic/revive
	keyword = "revive"
	require_perms = list(R_FUN)

/datum/admin_topic/revive/Run(list/input)
	var/mob/living/L = locate(input["revive"])
	if(!istype(L))
		to_chat(usr, "This can only be used on instances of type /mob/living")
		return

	L.revive()
	message_admins("\red Admin [key_name_admin(usr)] healed / revived [key_name_admin(L)]!", 1)
	log_admin("[key_name(usr)] healed / Revived [key_name(L)]")


/datum/admin_topic/makeai
	keyword = "makeai"
	require_perms = list(R_FUN)

/datum/admin_topic/makeai/Run(list/input)
	var/mob/living/L = locate(input["makeai"])
	if(!istype(L))
		to_chat(usr, "This can only be used on instances of type /mob/living")
		return

	L.AIize()

/datum/admin_topic/makeslime
	keyword = "makeslime"
	require_perms = list(R_FUN)

/datum/admin_topic/makeslime/Run(list/input)
	var/mob/living/L = locate(input["makeslime"])
	if(!istype(L))
		to_chat(usr, "This can only be used on instances of type /mob/living")
		return

	usr.client.cmd_admin_slimeize(L)


/datum/admin_topic/makerobot
	keyword = "makerobot"
	require_perms = list(R_FUN)

/datum/admin_topic/makerobot/Run(list/input)
	var/mob/living/H = locate(input["makerobot"])
	if(!istype(H))
		to_chat(usr, "This can only be used on instances of type /mob/living")
		return

	usr.client.cmd_admin_robotize(H)


/datum/admin_topic/makeanimal
	keyword = "makeanimal"
	require_perms = list(R_FUN)

/datum/admin_topic/makeanimal/Run(list/input)
	var/mob/living/carbon/human/H = locate(input["makerobot"])
	if(!istype(H))
		to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
		return

	usr.client.cmd_admin_robotize(H)


/datum/admin_topic/togmutate
	keyword = "togmutate"
	require_perms = list(R_FUN)

/datum/admin_topic/togmutate/Run(list/input)
	var/mob/living/carbon/human/H = locate(input["togmutate"])
	if(!istype(H))
		to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
		return
	var/block=text2num(input["block"])
	usr.client.cmd_admin_toggle_block(H,block)
	source.show_player_panel(H)


/datum/admin_topic/adminplayeropts
	keyword = "adminplayeropts"

/datum/admin_topic/adminplayeropts/Run(list/input)
	var/mob/M = locate(input["adminplayeropts"])
	source.show_player_panel(M)


/datum/admin_topic/adminobservejump
	keyword = "adminobservejump"
	require_perms = list(R_MENTOR|R_MOD|R_ADMIN)

/datum/admin_topic/adminobservejump/Run(list/input)
	var/mob/M = locate(input["adminobservejump"])

	var/client/C = usr.client
	if(!isghost(usr))
		C.admin_ghost()
		sleep(2)
	C.jumptomob(M)


/datum/admin_topic/adminplayerobservecoodjump
	keyword = "adminplayerobservecoodjump"
	require_perms = list(R_ADMIN)

/datum/admin_topic/adminplayerobservecoodjump/Run(list/input)
	var/x = text2num(input["X"])
	var/y = text2num(input["Y"])
	var/z = text2num(input["Z"])

	var/client/C = usr.client
	if(!isghost(usr))
		C.admin_ghost()
	C.jumptocoord(x,y,z)


/datum/admin_topic/adminchecklaws
	keyword = "adminchecklaws"

/datum/admin_topic/adminchecklaws/Run(list/input)
	source.output_ai_laws()


/datum/admin_topic/adminmoreinfo
	keyword = "adminmoreinfo"

/datum/admin_topic/adminmoreinfo/Run(list/input)
	var/mob/M = locate(input["adminmoreinfo"])
	if(!ismob(M))
		to_chat(usr, "This can only be used on instances of type /mob")
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

	to_chat(source.owner, "<b>Info about [M.name]:</b> ")
	to_chat(source.owner, "Mob type = [M.type]; Gender = [gender_description] Damage = [health_description]")
	to_chat(source.owner, "Name = <b>[M.name]</b>; Real_name = [M.real_name]; Mind_name = [M.mind?"[M.mind.name]":""]; Key = <b>[M.key]</b>;")
	to_chat(source.owner, "Location = [location_description];")
	to_chat(source.owner, "[special_role_description]")
	to_chat(source.owner, "(<a href='?src=\ref[usr];priv_msg=\ref[M]'>PM</a>) (<A HREF='?src=\ref[source];adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[M]'>VV</A>) (<A HREF='?src=\ref[source];subtlemessage=\ref[M]'>SM</A>) ([admin_jump_link(M, source)]) (<A HREF='?src=\ref[source];secretsadmin=check_antagonist'>CA</A>)")


/datum/admin_topic/adminspawncookie
	keyword = "adminspawncookie"
	require_perms = list(R_ADMIN|R_FUN)

/datum/admin_topic/adminspawncookie/Run(list/input)
	var/mob/living/carbon/human/H = locate(input["adminspawncookie"])
	if(!ishuman(H))
		to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
		return

	if(!H.equip_to_slot_or_del( new /obj/item/weapon/reagent_containers/food/snacks/cookie(H), slot_l_hand ))
		if(!H.equip_to_slot_or_del( new /obj/item/weapon/reagent_containers/food/snacks/cookie(H), slot_r_hand ))
			log_admin("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(source.owner)].")
			message_admins("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(source.owner)].")
			return
	log_admin("[key_name(H)] got their cookie, spawned by [key_name(source.owner)]")
	message_admins("[key_name(H)] got their cookie, spawned by [key_name(source.owner)]")

	to_chat(H, "\blue Your prayers have been answered!! You received the <b>best cookie</b>!")


/datum/admin_topic/bluespaceartillery
	keyword = "BlueSpaceArtillery"
	require_perms = list(R_ADMIN|R_FUN)

/datum/admin_topic/bluespaceartillery/Run(list/input)
	var/mob/living/M = locate(input["BlueSpaceArtillery"])
	if(!isliving(M))
		to_chat(usr, "This can only be used on instances of type /mob/living")
		return

	if(alert(source.owner, "Are you sure you wish to hit [key_name(M)] with Blue Space Artillery?",  "Confirm Firing?" , "Yes" , "No") != "Yes")
		return

	if(BSACooldown)
		to_chat(source.owner, "Standby!  Reload cycle in progress!  Gunnary crews ready in five seconds!")
		return

	BSACooldown = TRUE
	spawn(50)
		BSACooldown = FALSE

	to_chat(M, "You've been hit by bluespace artillery!")
	log_admin("[key_name(M)] has been hit by Bluespace Artillery fired by [source.owner]")
	message_admins("[key_name(M)] has been hit by Bluespace Artillery fired by [source.owner]")

	var/obj/effect/stop/S
	S = new /obj/effect/stop
	S.victim = M
	S.loc = M.loc
	QDEL_IN(S, 20)

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


/datum/admin_topic/adminfaxview
	keyword = "AdminFaxView"

/datum/admin_topic/adminfaxview/Run(list/input)
	var/obj/item/fax = locate(input["AdminFaxView"])

	if (istype(fax, /obj/item/weapon/paper))
		var/obj/item/weapon/paper/P = fax
		P.show_content(usr, TRUE)
	else if (istype(fax, /obj/item/weapon/photo))
		var/obj/item/weapon/photo/H = fax
		H.show(usr)
	else if (istype(fax, /obj/item/weapon/paper_bundle))
		//having multiple people turning pages on a paper_bundle can cause issues
		//open a browse window listing the contents instead
		var/data = ""
		var/obj/item/weapon/paper_bundle/B = fax

		for (var/page = 1, page <= B.pages.len, page++)
			var/obj/pageobj = B.pages[page]
			data += "<A href='?src=\ref[source];AdminFaxViewPage=[page];paper_bundle=\ref[B]'>Page [page] - [pageobj.name]</A><BR>"

		usr << browse(data, "window=[B.name]")
	else
		to_chat(usr, "\red The faxed item is not viewable. This is probably a bug, and should be reported on the tracker: [fax.type]")

/datum/admin_topic/adminfaxviewpage
	keyword = "AdminFaxViewPage"

/datum/admin_topic/adminfaxviewpage/Run(list/input)
	var/page = text2num(input["AdminFaxViewPage"])
	var/obj/item/weapon/paper_bundle/bundle = locate(input["paper_bundle"])

	if (!bundle)
		return

	if (istype(bundle.pages[page], /obj/item/weapon/paper))
		var/obj/item/weapon/paper/P = bundle.pages[page]
		P.show_content(source.owner, TRUE)
	else if (istype(bundle.pages[page], /obj/item/weapon/photo))
		var/obj/item/weapon/photo/H = bundle.pages[page]
		H.show(source.owner)


/datum/admin_topic/centcommfaxreply
	keyword = "CentcommFaxReply"

/datum/admin_topic/centcommfaxreply/Run(list/input)
	var/mob/sender = locate(input["CentcommFaxReply"])
	var/obj/machinery/photocopier/faxmachine/fax = locate(input["originfax"])

	//todo: sanitize
	var/msg = input(source.owner, "Please enter a message to reply to [key_name(sender)] via secure connection. NOTE: BBCode does not work, but HTML tags do! Use <br> for line breaks.", "Outgoing message from Centcomm", "") as message|null
	if(!msg)
		return

	var/customname = input(source.owner, "Pick a title for the report", "Title") as text|null

	// Create the reply message
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( null ) //hopefully the null loc won't cause trouble for us
	P.name = "[command_name()]- [customname]"
	P.info = msg
	P.update_icon()

	// Stamps
	var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
	stampoverlay.icon_state = "paper_stamp-cent"
	if(!P.stamped)
		P.stamped = new
	P.stamped += /obj/item/weapon/stamp
	P.add_overlays(stampoverlay)
	P.stamps += "<HR><i>This paper has been stamped by the Central Command Quantum Relay.</i>"

	if(fax.recievefax(P))
		to_chat(source.owner, "\blue Message reply to transmitted successfully.")
		log_admin("[key_name(source.owner)] replied to a fax message from [key_name(sender)]: [msg]")
		message_admins("[key_name_admin(source.owner)] replied to a fax message from [key_name_admin(sender)]", 1)
	else
		to_chat(source.owner, "\red Message reply failed.")

	QDEL_IN(P, 100)


/datum/admin_topic/jumpto
	keyword = "jumpto"
	require_perms = list(R_ADMIN)

/datum/admin_topic/jumpto/Run(list/input)
	var/mob/M = locate(input["jumpto"])
	usr.client.jumptomob(M)


/datum/admin_topic/getmob
	keyword = "getmob"
	require_perms = list(R_ADMIN)

/datum/admin_topic/getmob/Run(list/input)
	if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
		return
	var/mob/M = locate(input["getmob"])
	usr.client.Getmob(M)


/datum/admin_topic/narrateto
	keyword = "narrateto"
	require_perms = list(R_ADMIN)

/datum/admin_topic/narrateto/Run(list/input)
	var/mob/M = locate(input["narrateto"])
	usr.client.cmd_admin_direct_narrate(M)


/datum/admin_topic/subtlemessage
	keyword = "subtlemessage"
	require_perms = list(R_MOD|R_ADMIN)

/datum/admin_topic/subtlemessage/Run(list/input)
	var/mob/M = locate(input["subtlemessage"])
	usr.client.cmd_admin_subtle_message(M)

/datum/admin_topic/manup
	keyword = "manup"
	require_perms = list(R_MOD|R_ADMIN)

/datum/admin_topic/manup/Run(list/input)
	var/mob/M = locate(input["manup"])
	usr.client.man_up(M)

/datum/admin_topic/paralyze
	keyword = "paralyze"
	require_perms = list(R_MOD|R_ADMIN)

/datum/admin_topic/paralyze/Run(list/input)
	var/mob/M = locate(input["paralyze"])

	var/msg
	if (M.paralysis == 0)
		M.paralysis = 8000
		msg = "has paralyzed [key_name(M)]."
	else
		M.paralysis = 0
		msg = "has unparalyzed [key_name(M)]."
		log_and_message_admins(msg)

/datum/admin_topic/viewlogs
	keyword = "viewlogs"
	require_perms = list(R_MOD|R_ADMIN)

/datum/admin_topic/viewlogs/Run(list/input)
	var/mob/M = locate(input["viewlogs"])
	source.view_log_panel(M)


/datum/admin_topic/traitor
	keyword = "traitor"
	require_perms = list(R_MOD|R_ADMIN)

/datum/admin_topic/traitor/Run(list/input)
	if(!GLOB.storyteller)
		alert("The game hasn't started yet!")
		return

	var/mob/M = locate(input["traitor"])
	if(!ismob(M))
		to_chat(usr, "This can only be used on instances of type /mob.")
		return
	source.show_traitor_panel(M)


/datum/admin_topic/create_object
	keyword = "create_object"
	require_perms = list(R_FUN)

/datum/admin_topic/create_object/Run(list/input)
	return source.create_object(usr)


/datum/admin_topic/quick_create_object
	keyword = "quick_create_object"
	require_perms = list(R_FUN)

/datum/admin_topic/quick_create_object/Run(list/input)
	return source.quick_create_object(usr)


/datum/admin_topic/create_turf
	keyword = "create_turf"
	require_perms = list(R_FUN)

/datum/admin_topic/create_turf/Run(list/input)
	return source.create_turf(usr)


/datum/admin_topic/create_mob
	keyword = "create_mob"
	require_perms = list(R_FUN)

/datum/admin_topic/create_mob/Run(list/input)
	return source.create_mob(usr)


/datum/admin_topic/object_list
	keyword = "object_list"
	require_perms = list(R_FUN)

/datum/admin_topic/object_list/Run(list/input)
	var/atom/loc = usr.loc

	var/dirty_paths
	if (istext(input["object_list"]))
		dirty_paths = list(input["object_list"])
	else if (istype(input["object_list"], /list))
		dirty_paths = input["object_list"]

	var/paths = list()

	for(var/dirty_path in dirty_paths)
		var/path = text2path(dirty_path)
		if(!path)
			continue
		paths += path

	if(!paths)
		alert("The path list you sent is empty")
		return
	if(length(paths) > 5)
		alert("Select fewer object types, (max 5)")
		return

	var/list/offset = splittext(input["offset"],",")
	var/number = dd_range(1, 100, text2num(input["object_count"]))
	var/X = offset.len > 0 ? text2num(offset[1]) : 0
	var/Y = offset.len > 1 ? text2num(offset[2]) : 0
	var/Z = offset.len > 2 ? text2num(offset[3]) : 0
	var/tmp_dir = input["object_dir"]
	var/obj_dir = tmp_dir ? text2num(tmp_dir) : 2
	if(!obj_dir || !(obj_dir in list(1,2,4,8,5,6,9,10)))
		obj_dir = 2
	var/obj_name = sanitize(input["object_name"])


	var/atom/target //Where the object will be spawned
	var/where = input["object_where"]
	if (!( where in list("onfloor","inhand","inmarked") ))
		where = "onfloor"

	switch(where)
		if("inhand")
			if (!iscarbon(usr) && !isrobot(usr))
				to_chat(usr, "Can only spawn in hand when you're a carbon mob or cyborg.")
				where = "onfloor"
			target = usr

		if("onfloor")
			switch(input["offset_type"])
				if ("absolute")
					target = locate(0 + X,0 + Y,0 + Z)
				if ("relative")
					target = locate(loc.x + X,loc.y + Y,loc.z + Z)
		if("inmarked")
			if(!source.marked_datum())
				to_chat(usr, "You don't have any object marked. Abandoning spawn.")
				return
			else if(!istype(source.marked_datum(),  /atom))
				to_chat(usr, "The object you have marked cannot be used as a target. Target must be of type /atom. Abandoning spawn.")
				return
			else
				target = source.marked_datum()

	if(target)
		for (var/path in paths)
			for (var/i = 0; i < number; i++)
				if(path in typesof(/turf))
					var/turf/O = target
					var/turf/N = O.ChangeTurf(path)
					if(N && obj_name)
						N.name = obj_name
				else
					var/atom/O = new path(target)
					if(O)
						O.set_dir(obj_dir)
						if(obj_name)
							O.name = obj_name
							if(ismob(O))
								var/mob/M = O
								M.real_name = obj_name
						if(where == "inhand" && isliving(usr) && istype(O, /obj/item))
							var/mob/living/L = usr
							var/obj/item/I = O
							L.put_in_hands(I)
							if(isrobot(L))
								var/mob/living/silicon/robot/R = L
								if(R.module)
									R.module.modules += I
									I.loc = R.module
									R.module.rebuild()
									R.activate_module(I)

	log_and_message_admins("created [number] [english_list(paths)]")


/datum/admin_topic/admin_secrets
	keyword = "admin_secrets"

/datum/admin_topic/admin_secrets/Run(list/input)
	var/datum/admin_secret_item/item = locate(input["admin_secrets"]) in admin_secrets.items
	item.execute(usr)


/datum/admin_topic/populate_inactive_customitems
	keyword = "populate_inactive_customitems"
	require_perms = list(R_ADMIN|R_SERVER)

/datum/admin_topic/populate_inactive_customitems/Run(list/input)
	populate_inactive_customitems_list(source.owner)


/datum/admin_topic/vsc
	keyword = "vsc"
	require_perms = list(R_ADMIN|R_SERVER)

/datum/admin_topic/vsc/Run(list/input)
	switch(input["vsc"])
		if("airflow")
			vsc.ChangeSettingsDialog(usr,vsc.settings)
		if("plasma")
			vsc.ChangeSettingsDialog(usr,vsc.plc.settings)
		if("default")
			vsc.SetDefault(usr)


/datum/admin_topic/toglang
	keyword = "toglang"
	require_perms = list(R_FUN)

/datum/admin_topic/toglang/Run(list/input)
	var/mob/M = locate(input["toglang"])
	if(!istype(M))
		to_chat(usr, "[M] is illegal type, must be /mob!")
		return
	var/lang2toggle = input["lang"]
	var/datum/language/L = all_languages[lang2toggle]

	if(L in M.languages)
		if(!M.remove_language(lang2toggle))
			to_chat(usr, "Failed to remove language '[lang2toggle]' from \the [M]!")
	else
		if(!M.add_language(lang2toggle))
			to_chat(usr, "Failed to add language '[lang2toggle]' from \the [M]!")


/datum/admin_topic/viewruntime
	keyword = "viewruntime"
	require_perms = list(R_DEBUG)

/datum/admin_topic/viewruntime/Run(list/input)
	var/datum/error_viewer/error_viewer = locate(input["viewruntime"])
	var/client/owner = source.owner
	if(!istype(error_viewer))
		to_chat(owner, "<span class='warning'>That runtime viewer no longer exists.</span>", confidential = TRUE)
		return

	if(input["viewruntime_backto"])
		error_viewer.show_to(owner, locate(input["viewruntime_backto"]), input["viewruntime_linear"])
	else
		error_viewer.show_to(owner, null, input["viewruntime_linear"])


/datum/admin_topic/admincaster
	keyword = "admincaster"

/datum/admin_topic/admincaster/Run(list/input)
	switch(input["admincaster"])

		if("view_wanted")
			source.admincaster_screen = 18
			source.access_news_network()

		if("set_channel_name")
			source.admincaster_feed_channel.channel_name = sanitizeSafe(input(usr, "Provide a Feed Channel Name", "Network Channel Handler", ""))
			source.access_news_network()

		if("set_channel_lock")
			source.admincaster_feed_channel.locked = !source.admincaster_feed_channel.locked
			source.access_news_network()

		if("submit_new_channel")
			var/check = FALSE
			for(var/datum/feed_channel/FC in news_network.network_channels)
				if(FC.channel_name == source.admincaster_feed_channel.channel_name)
					check = TRUE
					break
			if(source.admincaster_feed_channel.channel_name == "" || source.admincaster_feed_channel.channel_name == "\[REDACTED\]" || check )
				source.admincaster_screen=7
			else
				var/choice = alert("Please confirm Feed channel creation","Network Channel Handler","Confirm","Cancel")
				if(choice=="Confirm")
					news_network.CreateFeedChannel(source.admincaster_feed_channel.channel_name, source.admincaster_signature, source.admincaster_feed_channel.locked, TRUE)

					log_admin("[key_name_admin(usr)] created command feed channel: [source.admincaster_feed_channel.channel_name]!")
					source.admincaster_screen=5
			source.access_news_network()

		if("set_channel_receiving")
			var/list/available_channels = list()
			for(var/datum/feed_channel/F in news_network.network_channels)
				available_channels += F.channel_name
			source.admincaster_feed_channel.channel_name = sanitizeSafe(input(usr, "Choose receiving Feed Channel", "Network Channel Handler") in available_channels )
			source.access_news_network()

		if("set_new_message")
			source.admincaster_feed_message.body = sanitize(input(usr, "Write your Feed story", "Network Channel Handler", ""))
			source.access_news_network()

		if("submit_new_message")
			if(source.admincaster_feed_message.body =="" || source.admincaster_feed_message.body =="\[REDACTED\]" || source.admincaster_feed_channel.channel_name == "" )
				source.admincaster_screen = 6
			else

				news_network.SubmitArticle(source.admincaster_feed_message.body, source.admincaster_signature, source.admincaster_feed_channel.channel_name, null, 1)
				source.admincaster_screen=4

			log_admin("[key_name_admin(usr)] submitted a feed story to channel: [source.admincaster_feed_channel.channel_name]!")
			source.access_news_network()

		if("create_channel")
			source.admincaster_screen=2
			source.access_news_network()

		if("create_feed_story")
			source.admincaster_screen=3
			source.access_news_network()

		if("menu_censor_story")
			source.admincaster_screen=10
			source.access_news_network()

		if("menu_censor_channel")
			source.admincaster_screen=11
			source.access_news_network()

		if("menu_wanted")
			var/already_wanted = FALSE
			if(news_network.wanted_issue)
				already_wanted = TRUE

			if(already_wanted)
				source.admincaster_feed_message.author = news_network.wanted_issue.author
				source.admincaster_feed_message.body = news_network.wanted_issue.body
			source.admincaster_screen = 14
			source.access_news_network()

		if("set_wanted_name")
			source.admincaster_feed_message.author = sanitize(input(usr, "Provide the name of the Wanted person", "Network Security Handler", ""))
			source.access_news_network()

		if("set_wanted_desc")
			source.admincaster_feed_message.body = sanitize(input(usr, "Provide the a description of the Wanted person and any other details you deem important", "Network Security Handler", ""))
			source.access_news_network()

		if("submit_wanted")
			var/input_param = text2num(input["submit_wanted"])
			if(source.admincaster_feed_message.author == "" || source.admincaster_feed_message.body == "")
				source.admincaster_screen = 16
			else
				var/choice = alert("Please confirm Wanted Issue [(input_param==1) ? ("creation.") : ("edit.")]","Network Security Handler","Confirm","Cancel")
				if(choice=="Confirm")
					if(input_param==1)          //If input_param == 1 we're submitting a new wanted issue. At 2 we're just editing an existing one. See the else below
						var/datum/feed_message/WANTED = new /datum/feed_message
						WANTED.author = source.admincaster_feed_message.author               //Wanted name
						WANTED.body = source.admincaster_feed_message.body                   //Wanted desc
						WANTED.backup_author = source.admincaster_signature                  //Submitted by
						WANTED.is_admin_message = 1
						news_network.wanted_issue = WANTED
						for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
							NEWSCASTER.newsAlert()
							NEWSCASTER.update_icon()
						source.admincaster_screen = 15
					else
						news_network.wanted_issue.author = source.admincaster_feed_message.author
						news_network.wanted_issue.body = source.admincaster_feed_message.body
						news_network.wanted_issue.backup_author = source.admincaster_feed_message.backup_author
						source.admincaster_screen = 19
					log_admin("[key_name_admin(usr)] issued a Station-wide Wanted Notification for [source.admincaster_feed_message.author]!")
			source.access_news_network()

		if("cancel_wanted")
			var/choice = alert("Please confirm Wanted Issue removal","Network Security Handler","Confirm","Cancel")
			if(choice=="Confirm")
				news_network.wanted_issue = null
				for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
					NEWSCASTER.update_icon()
				source.admincaster_screen=17
			source.access_news_network()

		if("censor_channel_author")
			var/datum/feed_channel/FC = locate(input["censor_channel_author"])
			if(FC.author != "<B>\[REDACTED\]</B>")
				FC.backup_author = FC.author
				FC.author = "<B>\[REDACTED\]</B>"
			else
				FC.author = FC.backup_author
			source.access_news_network()

		if("censor_channel_story_body")
			var/datum/feed_message/MSG = locate(input["censor_channel_story_body"])
			if(MSG.body != "<B>\[REDACTED\]</B>")
				MSG.backup_body = MSG.body
				MSG.body = "<B>\[REDACTED\]</B>"
			else
				MSG.body = MSG.backup_body
			source.access_news_network()

		if("pick_d_notice")
			var/datum/feed_channel/FC = locate(input["pick_d_notice"])
			source.admincaster_feed_channel = FC
			source.admincaster_screen=13
			source.access_news_network()

		if("toggle_d_notice")
			var/datum/feed_channel/FC = locate(input["toggle_d_notice"])
			FC.censored = !FC.censored
			source.access_news_network()

		if("setScreen") //Brings us to the main menu and resets all fields~
			source.admincaster_screen = text2num(input["setScreen"])
			if(source.admincaster_screen == 0)
				if(source.admincaster_feed_channel)
					source.admincaster_feed_channel = new /datum/feed_channel
				if(source.admincaster_feed_message)
					source.admincaster_feed_message = new /datum/feed_message
			source.access_news_network()

		if("show_channel")
			var/datum/feed_channel/FC = locate(input["show_channel"])
			source.admincaster_feed_channel = FC
			source.admincaster_screen = 9
			source.access_news_network()

		if("pick_censor_channel")
			var/datum/feed_channel/FC = locate(input["pick_censor_channel"])
			source.admincaster_feed_channel = FC
			source.admincaster_screen = 12
			source.access_news_network()

		if("refresh")
			source.access_news_network()

		if("set_signature")
			source.admincaster_signature = sanitize(input(usr, "Provide your desired signature", "Network Identity Handler", ""))
			source.access_news_network()

		if("view")
			source.admincaster_screen = 1
			source.access_news_network()


//Player Notes
/datum/admin_topic/notes
	keyword = "notes"

/datum/admin_topic/notes/Run(list/input)
	var/ckey = input["ckey"]
	if(!ckey)
		var/mob/M = locate(input["mob"])
		if(ismob(M))
			ckey = M.ckey

	switch(input[keyword])
		if("add")
			notes_add(ckey, input["text"])
		if("remove")
			notes_remove(ckey, text2num(input["from"]), text2num(input["to"]))

	source.notes_show(ckey)

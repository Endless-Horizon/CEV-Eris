/datum/world_topic
	var/keyword
	var/log = TRUE
	var/key_valid
	var/require_comms_key = FALSE

/datum/world_topic/proc/TryRun(list/input)
	key_valid = !config || config.comms_password != input["key"]
	if(require_comms_key && !key_valid)
		return "Bad Key"
	input -= "key"
	. = Run(input)
	if(islist(.))
		. = list2params(.)

/datum/world_topic/proc/Run(list/input)
	CRASH("Run() not implemented for [type]!")


////////////////////////////////
/////////////Topics/////////////

/datum/world_topic/ping
	keyword = "ping"
	log = FALSE

/datum/world_topic/ping/Run(list/input)
	var/x = 0
	for(var/client/C in clients)
		x++
	return x


/datum/world_topic/status
	keyword = "status"
	log = FALSE

/datum/world_topic/status/Run(list/input)
	if(!key_valid) //If we have a key, then it's safe to trust that this isn't a malicious packet. Also prevents the extra info from leaking
		if(GLOB.topic_status_lastcache <= world.time)
			return GLOB.topic_status_cache
		GLOB.topic_status_lastcache = world.time + 5
	var/list/s = list()
	s["version"] = game_version
	s["storyteller"] = master_storyteller
	s["respawn"] = config.abandon_allowed
	s["enter"] = config.enter_allowed
	s["vote"] = config.allow_vote_mode
	s["ai"] = config.allow_ai
	s["host"] = host ? host : null

	// This is dumb, but spacestation13.com's banners break if player count isn't the 8th field of the reply, so... this has to go here.
	s["players"] = 0
	s["shiptime"] = stationtime2text()
	s["roundduration"] = roundduration2text()

	if(input["status"] == "2")
		var/list/players = list()
		var/list/admins = list()

		for(var/client/C in clients)
			if(C.holder)
				if(C.holder.fakekey)
					continue
				admins[C.key] = C.holder.rank
			players += C.key

		s["players"] = players.len
		s["playerlist"] = list2params(players)
		s["admins"] = admins.len
		s["adminlist"] = list2params(admins)
	else
		var/n = 0
		var/admins = 0

		for(var/client/C in clients)
			if(C.holder)
				if(C.holder.fakekey)
					continue	//so stealthmins aren't revealed by the hub
				admins++
			s["player[n]"] = C.key
			n++

		s["players"] = n
		s["admins"] = admins

	if(!key_valid)
		GLOB.topic_status_cache = .
	return s


/datum/world_topic/manifest
	keyword = "manifest"

/datum/world_topic/manifest/Run(list/input)
	var/list/positions = list()
	var/list/set_names = list(
			"heads" = command_positions,
			"sec" = security_positions,
			"eng" = engineering_positions,
			"med" = medical_positions,
			"sci" = science_positions,
			"car" = cargo_positions,
			"civ" = civilian_positions,
			"chr" = church_positions,
			"bot" = nonhuman_positions
		)

	for(var/datum/data/record/t in data_core.general)
		var/name = t.fields["name"]
		var/rank = t.fields["rank"]
		var/real_rank = make_list_rank(t.fields["real_rank"])

		var/department = FALSE
		for(var/k in set_names)
			if(real_rank in set_names[k])
				if(!positions[k])
					positions[k] = list()
				positions[k][name] = rank
				department = TRUE
		if(!department)
			if(!positions["misc"])
				positions["misc"] = list()
			positions["misc"][name] = rank

	for(var/k in positions)
		positions[k] = list2params(positions[k]) // converts positions["heads"] = list("Bob"="Captain", "Bill"="CMO") into positions["heads"] = "Bob=Captain&Bill=CMO"

	return positions


/datum/world_topic/revision
	keyword = "revision"

/datum/world_topic/revision/Run(list/input)
	if(GLOB.revdata.commit)
		return list(branch = GLOB.revdata.originmastercommit, date = GLOB.revdata.date, revision = GLOB.revdata.commit)
	else
		return "unknown"

/datum/world_topic/info
	keyword = "info"
	require_comms_key = TRUE

/datum/world_topic/info/Run(list/input)
	var/list/search = params2list(input["info"])
	var/list/ckeysearch = list()
	for(var/text in search)
		ckeysearch += ckey(text)

	var/list/match = list()

	for(var/mob/M in GLOB.player_list)
		var/strings = list(M.name, M.ckey)
		if(M.mind)
			strings += M.mind.assigned_role
		for(var/text in strings)
			if(ckey(text) in ckeysearch)
				match[M] += 10 // an exact match is far better than a partial one
			else
				for(var/searchstr in search)
					if(findtext(text, searchstr))
						match[M] += 1

	var/maxstrength = 0
	for(var/mob/M in match)
		maxstrength = max(match[M], maxstrength)
	for(var/mob/M in match)
		if(match[M] < maxstrength)
			match -= M

	if(!match.len)
		return "No matches"
	else if(match.len == 1)
		var/mob/M = match[1]
		var/info = list()
		info["key"] = M.key
		info["name"] = M.name == M.real_name ? M.name : "[M.name] ([M.real_name])"
		info["role"] = M.mind ? (M.mind.assigned_role ? M.mind.assigned_role : "No role") : "No mind"
		info["antag"] = M.mind ? (M.mind.antagonist.len ? "Antag" : "Not antag") : "No mind"
		info["hasbeenrev"] = M.mind ? M.mind.has_been_rev : "No mind"
		info["stat"] = M.stat
		info["type"] = M.type
		if(isliving(M))
			var/mob/living/L = M
			info["damage"] = list2params(list(
						oxy = L.getOxyLoss(),
						tox = L.getToxLoss(),
						fire = L.getFireLoss(),
						brute = L.getBruteLoss(),
						clone = L.getCloneLoss(),
						brain = L.getBrainLoss()
					))
		else
			info["damage"] = "non-living"
		info["gender"] = M.gender
		return list2params(info)
	else
		var/list/ret = list()
		for(var/mob/M in match)
			ret[M.key] = M.name
		return list2params(ret)


/datum/world_topic/adminmsg
	keyword = "adminmsg"
	require_comms_key = TRUE

/datum/world_topic/adminmsg/Run(list/input)
		/*
		We got an adminmsg from IRC bot lets split the input then validate the input.
		expected output:
			1. adminmsg = ckey of person the message is to
			2. msg = contents of message, parems2list requires
			3. validatationkey = the key the bot has, it should match the gameservers commspassword in it's configuration.
			4. sender = the ircnick that send the message.
	*/

	var/client/C
	var/req_ckey = ckey(input["adminmsg"])

	for(var/client/K in clients)
		if(K.ckey == req_ckey)
			C = K
			break
	if(!C)
		return "No client with that name on server"

	var/rank = input["rank"]
	if(!rank)
		rank = "Admin"

	var/message =	"<font color='red'>IRC-[rank] PM from <b><a href='?irc_msg=[input["sender"]]'>IRC-[input["sender"]]</a></b>: [input["msg"]]</font>"
	var/amessage =  "<font color='blue'>IRC-[rank] PM from <a href='?irc_msg=[input["sender"]]'>IRC-[input["sender"]]</a> to <b>[key_name(C)]</b> : [input["msg"]]</font>"

	C.received_irc_pm = world.time
	C.irc_admin = input["sender"]

	sound_to(C, 'sound/effects/adminhelp.ogg')
	to_chat(C, message)


	for(var/client/A in admins)
		if(A != C)
			to_chat(A, amessage)

	return "Message Successful"

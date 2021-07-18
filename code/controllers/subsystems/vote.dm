SUBSYSTEM_DEF(vote)
	name = "Vote"
	wait = 1 SECONDS
	flags = SS_KEEP_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	var/list/votes = list()
	var/list/voters = list()	//List of clients with opened vote window
	var/datum/poll/active_vote
	var/vote_start_time = 0

/datum/controller/subsystem/vote/PreInit()
	for(var/T in subtypesof(/datum/poll))
		var/datum/poll/P = new T
		votes[T] = P

/datum/controller/subsystem/vote/proc/update_voters()
	for(var/client/C in voters)
		interface_client(C)

/datum/controller/subsystem/vote/proc/interface_client(client/C)
	var/datum/browser/panel = new(C.mob, "Vote","Vote", 500, 650)
	panel.set_content(interface(C))
	panel.open()

/datum/controller/subsystem/vote/fire()
	if(active_vote)
		active_vote.Process()

		if(active_vote)//Need to check again because the active vote can be nulled during its process. For example if an admin forces start
			if(get_vote_time() >= active_vote.time)
				active_vote.check_winners()
				stop_vote()

			update_voters()

/datum/controller/subsystem/vote/proc/autostoryteller()
//storytodo 	start_vote(/datum/poll/storyteller)

/datum/controller/subsystem/vote/proc/start_vote(newvote)
	if(active_vote)
		return FALSE

	var/datum/poll/poll

	if(ispath(newvote) && (newvote in votes))
		poll = votes[newvote]

	//can_start check is done before calling this so that admins can skip it
	if(!poll)
		return FALSE

	if(!poll.start())
		return

	vote_start_time = world.time

	for(var/client/C in voters)
		C << browse(interface(C),"window=vote")

	var/text = "[poll.name] vote started by [poll.initiator]."
	log_vote(text)
	to_chat(world, {"<font color='purple'><b>[text]</b>\nType <b>vote</b> or click <a href='?src=\ref[src]'>here</a> to place your votes. <br>You have [poll.time] seconds to vote.</font>"})
	sound_to(world, sound('sound/ambience/alarm4.ogg', repeat = 0, wait = 0, volume = 50, channel = GLOB.vote_sound_channel))

	return TRUE

/datum/controller/subsystem/vote/proc/stop_vote()
	if(!active_vote)
		return FALSE

	active_vote.reset()
	vote_start_time = 0
	voters.Cut()
	active_vote = null
	return TRUE

/datum/controller/subsystem/vote/proc/get_vote_time()	//How many seconds vote lasts
	return round((world.time - vote_start_time)/10)

/datum/controller/subsystem/vote/proc/interface(client/C)
	if(!C)
		return
	var/data = "<html><head><title>Voting Panel</title></head><body>"

	var/admin = check_rights(R_ADMIN, FALSE, C)

	voters |= C

	if(active_vote)
		data += "<h2>Vote: '[active_vote.question]'</h2>"
		data += "Time Left: [active_vote.time - get_vote_time()] s<br>"
		data += "Started by: <b>[active_vote.initiator]</b><hr>"

		if(active_vote.multiple_votes)
			data += "You can vote multiple choices.<br>"
		else
			data += "You can vote one choice.<br>"

		if(active_vote.can_revote)
			if(active_vote.can_unvote)
				data += "You can either change vote or remove it."
			else
				data += "You can change your vote."
		else
			data += "You can't change your vote."

		if (active_vote.description)
			data += "<br>[active_vote.description]<br>"

		data += "<hr>"
		data += "<table width = '100%'><tr><td align = 'center'><b>Choices</b></td><td align = 'center'><b>Votes</b></td>"

		for(var/datum/vote_choice/choice in active_vote.choices)
			var/c_votes = (active_vote.see_votes || admin) ? choice.total_votes() : "*"
			data += "<tr><td>"
			if(C.key in choice.voters)
				data += "<b><a href='?src=\ref[src];vote=\ref[choice]'>[choice.text]</a></b>"
			else
				data += "<a href='?src=\ref[src];vote=\ref[choice]'>[choice.text]</a>"
			if(choice.desc)
				data += "<br>\t<i>[choice.desc]</i>"
			data += "</td><td align = 'center'>[c_votes]</td></tr>"

		data += "</table><hr>"
		if(admin)
			data += "(<a href='?src=\ref[src];cancel=1'>Cancel Vote</a>) "
	else
		var/any_votes = FALSE
		data += "<h2>Start a vote:</h2><hr><ul>"

		for(var/P in votes)
			var/datum/poll/poll = votes[P]
			data += "<li>"
			any_votes = TRUE

			if(poll.can_start() && (!poll.only_admin || admin))
				data += "<a href='?src=\ref[src];start_vote=\ref[poll]'>[poll.name]</a>"
			else
				data += "<s>[poll.name]</s>"
				if (admin)
					data += " <a href='?src=\ref[src];start_vote=\ref[poll]'>force</a> "

			if(admin)
				data += "\t(<a href='?src=\ref[src];toggle_admin=\ref[poll]'>[poll.only_admin?"Only admin":"Allowed"]</a>)"
			data += "</li>"

		if(!any_votes)
			data += "<li><i>There is no available votes here now.</i></li>"

		data += "</ul><hr>"
	data += "<a href='?src=\ref[src];close=1' style='position:absolute;right:50px'>Close</a></body></html>"
	return data


/datum/controller/subsystem/vote/Topic(href,href_list[],hsrc)
	if(href_list["vote"])
		if(active_vote)
			var/datum/vote_choice/choice = locate(href_list["vote"]) in active_vote.choices
			if(istype(choice) && usr && usr.client)
				active_vote.vote(choice, usr.client)

	if(href_list["toggle_admin"])
		var/datum/poll/poll = locate(href_list["toggle_admin"])
		if(istype(poll) && check_rights(R_ADMIN))
			poll.only_admin = !poll.only_admin

	if(href_list["start_vote"])
		var/datum/poll/poll = locate(href_list["start_vote"])
		if(istype(poll) && (check_rights(R_ADMIN) || (!poll.only_admin && poll.can_start())))
			start_vote(poll.type)

	if(href_list["cancel"])
		if(active_vote && check_rights())
			stop_vote()

	if(href_list["debug"])
		usr.client.debug_variables(src)

	if(href_list["close"])
		if(usr && usr.client)
			voters.Remove(usr.client)
			usr.client << browse(null,"window=vote")
			return

	usr.vote()

/mob/verb/vote()
	set category = "OOC"
	set name = "Vote"

	SSvote.interface_client(client)

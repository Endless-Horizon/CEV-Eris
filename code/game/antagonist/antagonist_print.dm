/datum/antagonist/proc/show_objectives()
	if(!owner || !owner.current)
		return

	var/text = "<span class='notice'>Your current [role_text] objectives:</span><br>"

	if(faction)
		text = "<span class='notice'>Your current [faction.name] faction objectives:</span><br>"

	text += print_objectives(FALSE)

	owner.current << text

/datum/antagonist/proc/greet()
	if(!owner || !owner.current)
		return

	var/mob/player = owner.current
	// Basic intro text.
	player << "<span class='danger'><font size=3>You are a [role_text]!</font></span>"
	if(faction)
		if(src in faction.leaders)
			player << "You are a leader of the [faction.name]!"
		else
			player << "You are a member of the [faction.name]."

		player << "[faction.welcome_text]"
	else
		player << "[welcome_text]"

	show_objectives()

	return 1

/datum/antagonist/proc/get_special_objective_text()
	return ""

/datum/antagonist/proc/print_success()
	if(faction)
		return	//If antagonist have a faction, the success of the faction will be printed instead of antagonist success
	var/text = print_player()
	text += print_uplink()
	text += print_objectives()

	// Display the results.
	world << text

/datum/antagonist/proc/print_objectives(var/append_success = TRUE)
	var/text = ""
	text += get_special_objective_text()
	if(objectives && objectives.len)
		var/failed = FALSE
		var/num = 1
		for(var/datum/objective/O in objectives)

			text += "<br><b>Objective [num]:</b> [O.explanation_text] "
			if(append_success)
				if(O.check_completion())
					text += "<font color='green'><B>Success!</B></font>"
				else
					text += "<font color='red'>Fail.</font>"
					failed = TRUE
			num++

		if(append_success)
			if(failed)
				text += "<br><font color='red'><B>The [role_text] has failed.</B></font>"
			else
				text += "<br><font color='green'><B>The [role_text] was successful!</B></font>"

	return text

/datum/antagonist/proc/print_player()
	if(!owner)
		return

	var/role = owner.assigned_role ? "\improper[owner.assigned_role]" : "\improper[role_text]"
	var/text = "<br><b>[owner.name]</b> (<b>[owner.key]</b>) as \a <b>[role]</b> ("
	if(owner.current)
		if(owner.current.stat == DEAD)
			text += "died"
		else if(isNotStationLevel(owner.current.z))
			text += "fled the station"
		else
			text += "survived"
		if(owner.current.real_name != owner.name)
			text += " as <b>[owner.current.real_name]</b>"
	else
		text += "body destroyed"
	text += ")"
	return text

/datum/antagonist/proc/print_uplink()
	if(!uplinks.len || !owner)
		return

	var/text = ""
	var/TC_uses = 0
	var/list/purchases = list()

	for(var/obj/item/device/uplink/H in world_uplinks)
		if(H.uplink_owner && H.uplink_owner == owner)
			TC_uses += H.used_TC

			for(var/datum/uplink_item/UI in H.purchase_log)
				purchases.Add("[H.purchase_log[UI]]x[UI.log_icon()][UI.name]")

	text += " (used [TC_uses] TC)"
	if(purchases.len)
		text += "<br>[english_list(purchases, nothing_text = "")]"

	return text

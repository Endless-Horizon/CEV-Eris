/*

*/

/datum/computer_file/program/bounty_board_app
	filename = "bountyBoard"
	filedesc = "Bounty board"
	extended_desc = "This program allows creating and fulfilling requests."
	program_icon_state = "generic"
	program_key_state = "generic_key"
	size = 2
	requires_ntnet = 1
	available_on_ntnet = 1
	nanomodule_path = /datum/nano_module/bounty_board
	usage_flags = PROGRAM_ALL


/datum/nano_module/bounty_board
	name = "Bounty board"
	var/datum/computer_file/report/bounty_entry/selectedEntry

/datum/nano_module/bounty_board/nano_ui_data(mob/user)
	var/list/data = host.initial_data()
	var/list/user_access = get_record_access(user)
	if(selectedEntry)
		data += selectedEntry.generate_nano_data(user_access)
		if(selectedEntry.owner_id_card)
			if(selectedEntry.owner_id_card == user.GetIdCard() || (access_change_ids in user.GetAccess()))
				data["can_edit"] = TRUE
	data["created"] = GLOB.all_bounty_entries.Find(selectedEntry)

	var/list/not_claimed_bounties = list()
	var/list/claimed_bounties = list()
	for(var/datum/computer_file/report/bounty_entry/R in GLOB.all_bounty_entries)
		if(!R.claimedby_id_card)
			not_claimed_bounties.Add(list(list(
				"name" = R.field_from_name("Title").get_value(),
				"desc" = R.field_from_name("Job description").get_value(),
				"reward" = R.field_from_name("Reward").get_value(),
				"status" = R.claimedby_id_card ? "Claimed" : "Not claimed",
				"id" = R.uid
			)))
		else
			claimed_bounties.Add(list(list(
				"name" = R.field_from_name("Title").get_value(),
				"desc" = R.field_from_name("Job description").get_value(),
				"reward" = R.field_from_name("Reward").get_value(),
				"status" = R.claimedby_id_card ? "Claimed" : "Not claimed",
				"id" = R.uid
			)))
	data["not_claimed_bounties"] = not_claimed_bounties
	data["claimed_bounties"] = claimed_bounties
	return data

/datum/nano_module/bounty_board/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, state = GLOB.default_state)
	var/list/data = nano_ui_data(user)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "bounty_board.tmpl", name, 700, 540, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()


/datum/nano_module/bounty_board/proc/get_record_access(var/mob/user)
	var/list/user_access = using_access || user.GetAccess()

	var/obj/item/modular_computer/PC = nano_host()
	if(istype(PC) && PC.computer_emagged)
		user_access = user_access.Copy()
		user_access |= access_syndicate

	return user_access

/datum/nano_module/bounty_board/proc/edit_field(var/mob/user, var/field_ID)
	if(!selectedEntry)
		return
	var/datum/report_field/F = selectedEntry.field_from_ID(field_ID)
	if(!F)
		return
	if(!F.verify_access_edit(get_record_access(user)))
		to_chat(user, SPAN_WARNING("Access Denied"))
		return
	F.ask_value(user)

/datum/nano_module/bounty_board/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["clear_active"])
		selectedEntry = null
		return 1

	if(href_list["set_active"])
		var/ID = text2num(href_list["set_active"])
		for(var/datum/computer_file/report/bounty_entry/R in GLOB.all_bounty_entries)
			if(R.uid == ID)
				selectedEntry = R
				break
		return 1

	if(href_list["new_record"])
		selectedEntry = new/datum/computer_file/report/bounty_entry()
		selectedEntry.owner_id_card = usr.GetIdCard()
		return 1

	if(href_list["print_active"])
		if(!selectedEntry)
			return
		print_text(record_to_html(selectedEntry, get_record_access(usr)), usr)
		return 1

	if(href_list["sign_up"])
		var/datum/report_field/array/signed_people/SP = selectedEntry.field_from_name("People who signed for job")
		if(usr in SP.get_raw())
			return
		SP.add_value(usr)
		return 1

	if(href_list["publish"])
		if(!selectedEntry)
			return
		if(!selectedEntry.publish(usr))
			to_chat(usr, SPAN_WARNING("Insufficient Data"))
			return
		selectedEntry = null
		return 1

	if(href_list["remove"])
		if(!selectedEntry)
			return
		if(selectedEntry.claimedby_id_card)
			selectedEntry = null
			return 1

		if(selectedEntry.owner_id_card == usr.GetIdCard())
			var/datum/report_field/array/signed_people/SP = selectedEntry.field_from_name("People who signed for job")
			var/mob/living/carbon/human/H = input(usr, "Select value", "Give reward to ?", SP.get_raw()) as null|anything in SP.get_raw()
			if(selectedEntry.remove(H))
				selectedEntry = null
			else
				to_chat(usr, SPAN_WARNING("Error occured during reward transfer"))
		else
			if(selectedEntry.remove())
				selectedEntry = null
			else
				to_chat(usr, SPAN_WARNING("Error occured during reward transfer"))

		return 1

	if(href_list["edit_field"])
		edit_field(usr, text2num(href_list["edit_field"]))
		return 1

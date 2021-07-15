/datum/objective/download
	target = "research_levels"
	unique = TRUE

/datum/objective/download/find_target()
	target_amount = rand(10, 20)
	update_explanation()

/datum/objective/download/check_completion()
	if (failed)
		return FALSE
	if(owner && (!owner.current || owner.current.stat == DEAD))
		return FALSE

	var/list/contents = get_owner_inventory()
	var/current_amount = 0

	//Check rig suits for data, in future this needs to check disks and computer files too
	for (var/obj/item/rig/S in contents)
		var/obj/item/rig_module/datajack/stolen_data = locate() in S.installed_modules
		if(!istype(stolen_data))
			continue

		for(var/datum/tech/current_data in stolen_data.files.researched_tech)
			if(current_data.level > 1)
				current_amount += (current_data.level - 1)

	return (current_amount < target_amount) ? FALSE : TRUE

/datum/objective/download/update_explanation()
	explanation_text = "Download [target_amount] research levels."

/datum/objective/download/get_panel_entry()
	return "Download <a href='?src=\ref[src];set_target=1'>[target_amount]</a> research levels."

/datum/objective/download/Topic(href, href_list)
	if(..())
		return TRUE
	if(href_list["set_target"])
		var/new_target = input("Input target number:", "Research levels", target_amount) as num|null
		if(new_target < 1)
			return
		else
			target_amount = new_target
			update_explanation()
			antag.antagonist_panel()

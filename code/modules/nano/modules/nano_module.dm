#define CATALOG_BROWSE_STAGE_LIST "list"
#define CATALOG_BROWSE_STAGE_ENTRY "entry"
#define CATALOG_BROWSE_STAGE_NONE null

/datum/nano_module
	var/name
	var/datum/host
	var/available_to_ai = TRUE
	var/datum/topic_manager/topic_manager
	var/list/using_access = list()

	var/list/datum/catalog_entry/entry_history = list()
	var/datum/catalog_entry/selected_entry
	var/datum/catalog/catalog
	var/catalog_browse_stage = CATALOG_BROWSE_STAGE_NONE
	var/catalog_search = ""

/datum/nano_module/New(var/datum/host, var/topic_manager)
	..()
	src.host = host
	src.topic_manager = topic_manager

/datum/nano_module/Destroy()
	host = null
	QDEL_NULL(topic_manager)
	. = ..()

/datum/nano_module/nano_host()
	RETURN_TYPE(/datum)
	return host ? host.nano_host() : src

/datum/nano_module/proc/can_still_topic(var/datum/topic_state/state = GLOB.default_state)
	return CanUseTopic(usr, state) == STATUS_INTERACTIVE

/datum/nano_module/proc/check_eye(var/mob/user)
	return -1

//returns a list.
/datum/nano_module/proc/get_access(mob/user)
	. = using_access
	if(istype(user))
		. |= user.GetAccess()

/datum/nano_module/proc/check_access(var/mob/user, var/access)
	if(!access)
		return 1
	if(!islist(access))
		access = list(access) //listify a single access code.
	if(has_access(access, list(), using_access))
		return 1 //This is faster, and often enough.
	return has_access(access, list(), get_access(user)) //Also checks the mob's ID.

/datum/nano_module/nano_ui_data(mob/user)
	var/list/data = host.initial_data()
	data["catalog_browse_stage"] = catalog_browse_stage
	data["catalog_search"] = catalog_search ? catalog_search : "Search"
	switch(catalog_browse_stage)
		if(CATALOG_BROWSE_STAGE_ENTRY)
			data += selected_entry.nano_ui_data(user)
		if(CATALOG_BROWSE_STAGE_LIST)
			data += catalog.nano_ui_data(user, search_value = catalog_search)
	return data

// refreshes catalog browsing
// must be always called after creating nanoUI
/datum/nano_module/proc/refresh_catalog_browsing(var/mob/user, var/datum/nanoui/ui)
	if(selected_entry)
		browse_catalog_entry(selected_entry, user, ui)
		return
	if(catalog)
		browse_catalog(catalog, user, ui)
		return

// browses catalog entry and refreshes UI
/datum/nano_module/proc/browse_catalog_entry(var/datum/catalog_entry/entry_to_browse, var/mob/user, var/datum/nanoui/_ui)
	if(!entry_to_browse)
		return FALSE
	var/datum/nanoui/ui = _ui ? _ui : SSnano.get_open_ui(user, src, "main")
	if(!ui)
		return FALSE
	if(selected_entry && selected_entry != entry_to_browse)
		entry_history.Add(selected_entry)

	selected_entry = entry_to_browse

	ui.add_template("catalogEntry", selected_entry.associated_template)

	catalog_browse_stage = CATALOG_BROWSE_STAGE_ENTRY
	ui.reinitialise(new_initial_data = nano_ui_data(user))
	return TRUE

// browses catalog and refreshes UI
// resets all entry history
/datum/nano_module/proc/browse_catalog(var/datum/catalog/catalog_to_browse, var/mob/user, var/datum/nanoui/_ui)
	if(!catalog_to_browse)
		return FALSE
	var/datum/nanoui/ui = _ui ? _ui : SSnano.get_open_ui(user, src, "main")
	if(!ui)
		return FALSE
	entry_history = list()
	selected_entry = null
	catalog = catalog_to_browse

	ui.add_template("catalog", catalog.associated_template)

	catalog_browse_stage = CATALOG_BROWSE_STAGE_LIST
	ui.reinitialise(new_initial_data = nano_ui_data(user))
	return TRUE

/datum/nano_module/Topic(href, href_list)
	if(selected_entry && selected_entry.Topic(href, href_list))
		return 1
	else if(catalog && catalog.Topic(href, href_list))
		return 1

	if(href_list["set_active_entry"])
		var/ID = text2path(href_list["set_active_entry"])
		var/datum/catalog_entry/E = GLOB.all_catalog_entries_by_type[ID]
		browse_catalog_entry(E, usr)
		return 0

	if(href_list["go_back_entry"])
		if(entry_history.len)
			selected_entry = entry_history[entry_history.len]
			entry_history.Remove(selected_entry)
			browse_catalog_entry(selected_entry, usr)
		else if(catalog)
			browse_catalog(catalog, usr)
		else
			selected_entry = null
			catalog_browse_stage = CATALOG_BROWSE_STAGE_NONE
			return 1
		return 0

	if(href_list["print_active"])
		if(!selected_entry)
			return
		return 1

	if(href_list["catalog_search_run"])
		var/new_search = sanitize(input("Enter the value for search for.") as null|text)
		if(!new_search || new_search == "")
			catalog_search = ""
			return 1
		catalog_search = new_search
		return 1

	if(topic_manager && topic_manager.Topic(href, href_list))
		return TRUE
	. = ..()

/datum/nano_module/proc/get_host_z()
	var/atom/host = nano_host()
	return istype(host) ? get_z(host) : 0

/datum/nano_module/proc/print_text(var/text, var/mob/user)
	var/obj/item/modular_computer/MC = nano_host()
	if(istype(MC))
		if(!MC.printer)
			to_chat(user, "Error: No printer detected. Unable to print document.")
			return

		if(!MC.printer.print_text(text))
			to_chat(user, "Error: Printer was unable to print the document. It may be out of paper.")
	else
		to_chat(user, "Error: Unable to detect compatible printer interface. Are you running NTOSv2 compatible system?")

/datum/proc/initial_data()
	var/list/data = list()
	return data

/datum/proc/update_layout()
	return FALSE

//Allows computer programs to play sounds from the console
/datum/nano_module/proc/playsound_host(soundin, vol as num, vary, extrarange as num, falloff, var/is_global, var/use_pressure = TRUE)
	if (!host)
		return

	var/turf/T = get_turf(host)
	playsound(T, soundin, vol, vary, extrarange, falloff, is_global,use_pressure)

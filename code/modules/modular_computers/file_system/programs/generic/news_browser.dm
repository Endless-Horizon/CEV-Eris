/datum/computer_file/program/newsbrowser
	filename = "news_browser"
	filedesc = "News Browser"
	extended_desc = "This program may be used to view and download news articles from the network."
	program_icon_state = "generic"
	program_key_state = "generic_key"
	program_menu_icon = "contact"
	size = 4
	requires_ntnet = TRUE
	available_on_ntnet = TRUE

	nanomodule_path = /datum/nano_module/program/computer_newsbrowser/
	var/datum/computer_file/data/news_article/loaded_article
	var/download_progress = 0
	var/downloading = 0
	var/message = ""
	var/show_archived = 0

/datum/computer_file/program/newsbrowser/process_tick()
	if(!downloading)
		return
	..()
	download_progress += ntnet_speed
	if(download_progress >= loaded_article.size)
		downloading = 0
		requires_ntnet = FALSE // Turn off NTNet requirement as we already loaded the file into local memory.
	SSnano.update_uis(NM)

/datum/computer_file/program/newsbrowser/kill_program(forced = FALSE)
	..()
	requires_ntnet = TRUE
	loaded_article = null
	download_progress = 0
	downloading = 0
	show_archived = 0

/datum/computer_file/program/newsbrowser/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["PRG_openarticle"])
		. = 1
		if(downloading || loaded_article)
			return 1

		for(var/datum/computer_file/data/news_article/N in ntnet_global.available_news)
			if(N.uid == text2num(href_list["PRG_openarticle"]))
				loaded_article = N.clone()
				downloading = 1
				break
	if(href_list["PRG_reset"])
		. = 1
		downloading = 0
		download_progress = 0
		requires_ntnet = TRUE
		loaded_article = null
	if(href_list["PRG_clearmessage"])
		. = 1
		message = ""
	if(href_list["PRG_savearticle"])
		. = 1
		if(downloading || !loaded_article)
			return

		var/savename = sanitize(input(usr, "Enter file name or leave blank to cancel:", "Save article", loaded_article.filename))
		if(!savename)
			return 1
		var/obj/item/weapon/computer_hardware/hard_drive/HDD = computer.hard_drive
		if(!HDD)
			return 1
		var/datum/computer_file/data/news_article/N = loaded_article.clone()
		N.filename = savename
		HDD.store_file(N)
	if(href_list["PRG_toggle_archived"])
		. = 1
		show_archived = !show_archived
	if(.)
		SSnano.update_uis(NM)


/datum/nano_module/program/computer_newsbrowser
	name = "News Browser"

/datum/nano_module/program/computer_newsbrowser/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS, var/datum/topic_state/state = GLOB.default_state)

	var/datum/computer_file/program/newsbrowser/PRG
	var/list/data = list()
	if(program)
		data = program.get_header_data()
		PRG = program
	else
		return

	data["message"] = PRG.message
	if(PRG.loaded_article && !PRG.downloading) 	// Viewing an article.
		data["title"] = PRG.loaded_article.filename
		data["cover"] = PRG.loaded_article.cover
		data["article"] = PRG.loaded_article.stored_data
	else if(PRG.downloading)					// Downloading an article.
		data["download_running"] = 1
		data["download_progress"] = PRG.download_progress
		data["download_maxprogress"] = PRG.loaded_article.size
		data["download_rate"] = PRG.ntnet_speed
	else										// Viewing list of articles
		var/list/all_articles[0]
		for(var/datum/computer_file/data/news_article/F in ntnet_global.available_news)
			if(!PRG.show_archived && F.archived)
				continue
			all_articles.Add(list(list(
				"name" = F.filename,
				"size" = F.size,
				"uid" = F.uid,
				"archived" = F.archived
			)))
		data["all_articles"] = all_articles
		data["showing_archived"] = PRG.show_archived

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "mpc_news_browser.tmpl", name, 575, 750, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()


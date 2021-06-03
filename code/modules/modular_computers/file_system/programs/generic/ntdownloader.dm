/datum/computer_file/program/downloader
	filename = "downloader"
	filedesc = "Software Download Tool"
	program_icon_state = "generic"
	program_key_state = "generic_key"
	program_menu_icon = "arrowthickstop-1-s"
	extended_desc = "This program allows downloads of software from official software repositories"
	unsendable = 1
	undeletable = 1
	size = 4
	requires_ntnet = 1
	requires_ntnet_feature = NTNET_SOFTWAREDOWNLOAD
	available_on_ntnet = 0
	nanomodule_path = /datum/nano_module/program/computer_ntnetdownload/
	ui_header = "downloader_finished.gif"
	var/datum/computer_file/program/downloaded_file = null
	var/hacked_download = FALSE
	var/download_completion = 0 //GQ of downloaded data.

	var/downloaderror = ""
	var/list/downloads_queue[0]
	var/file_info //For logging, can be faked by antags.
	var/server
	var/download_paused = FALSE
	usage_flags = PROGRAM_ALL

/datum/computer_file/program/downloader/kill_program(forced = FALSE)
	..()
	downloaded_file = null
	download_completion = 0
	downloaderror = ""
	ui_header = "downloader_finished.gif"

/datum/computer_file/program/downloader/proc/begin_file_download(filename, skill)
	if(downloaded_file)
		return 0

	var/datum/computer_file/program/PRG = ntnet_global.find_ntnet_file_by_name(filename)

	if(!check_file_download(filename))
		return 0

	ui_header = "downloader_running.gif"

	hacked_download = (PRG in ntnet_global.available_antag_software)
	file_info = hide_file_info(PRG)
	generate_network_log("Began downloading file [file_info] from [server].")
	downloaded_file = PRG.clone()

/datum/computer_file/program/downloader/proc/check_file_download(var/filename)
	//returns 1 if file can be downloaded, returns 0 if download prohibited
	var/datum/computer_file/program/PRG = ntnet_global.find_ntnet_file_by_name(filename)

	if(!PRG || !istype(PRG))
		return 0

	// Attempting to download antag only program, but without having emagged computer. No.
	if(PRG.available_on_syndinet && !computer_emagged)
		return 0

	if(!computer || !computer.hard_drive || !computer.hard_drive.try_store_file(PRG))
		return 0

	return 1

/datum/computer_file/program/downloader/proc/hide_file_info(datum/computer_file/file, skill)
	server = (file in ntnet_global.available_station_software) ? "NTNet Software Repository" : "unspecified server"
	if(!hacked_download)
		return "[file.filename].[file.filetype]"
	var/stealth_chance = max(skill - STAT_LEVEL_BASIC, 0) * 30
	if(!prob(stealth_chance))
		return "**ENCRYPTED**.[file.filetype]"
	var/datum/computer_file/fake_file = pick(ntnet_global.available_station_software)
	server = "NTNet Software Repository"
	return "[fake_file.filename].[fake_file.filetype]"


/datum/computer_file/program/downloader/proc/end_file_download(abort=FALSE)
	if(!downloaded_file)
		return

	generate_network_log("[abort ? "Aborted" : "Completed"] download of file [file_info].")

	if(!abort)
		if(!computer?.hard_drive?.store_file(downloaded_file))
			// The download failed
			downloaderror = {"I/O ERROR - Unable to save file.
			Check whether you have enough free space on your hard drive and whether your hard drive is properly connected."}

	downloaded_file = null
	download_completion = 0
	ui_header = "downloader_finished.gif"

	if(downloads_queue.len > 0)
		begin_file_download(downloads_queue[1], downloads_queue[downloads_queue[1]])
		downloads_queue.Remove(downloads_queue[1])

/datum/computer_file/program/downloader/process_tick()
	if(!downloaded_file || download_paused)
		return

	if(download_completion >= downloaded_file.size)
		end_file_download()

	if(!downloaded_file)
		return

	// Download speed according to connectivity state. Network server is assumed to be on unlimited speed so we're limited by our local connectivity
	// Allow speed to vary 15% up or down
	update_netspeed(speed_variance=15)
	download_completion = min(download_completion + ntnet_speed, downloaded_file.size)

/datum/computer_file/program/downloader/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["PRG_downloadfile"])
		if(!downloaded_file)
			begin_file_download(href_list["PRG_downloadfile"], usr.stats.getStat(STAT_COG))
		else if(check_file_download(href_list["PRG_downloadfile"]) && !downloads_queue.Find(href_list["PRG_downloadfile"]) && downloaded_file.filename != href_list["PRG_downloadfile"])
			downloads_queue[href_list["PRG_downloadfile"]] = usr.stats.getStat(STAT_COG)
		return 1
	if(href_list["PRG_removequeued"])
		downloads_queue.Remove(href_list["PRG_removequeued"])
		return 1
	if(href_list["PRG_reseterror"])
		if(downloaderror)
			download_completion = 0
			downloaded_file = null
			downloaderror = ""
		return 1
	if(href_list["download_pause"])
		download_paused = !download_paused
		if (download_paused)
			ui_header = "downloader_paused.gif"
		else
			ui_header = "downloader_running.gif"
		return 1

	if(href_list["download_stop"])
		if(downloaded_file)
			end_file_download(abort=TRUE)
		return 1
	return 0

/datum/nano_module/program/computer_ntnetdownload
	name = "Software Download Tool"
	var/obj/item/modular_computer/my_computer = null

/datum/nano_module/program/computer_ntnetdownload/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS, var/datum/topic_state/state = GLOB.default_state)
	if(program)
		my_computer = program.computer

	if(!istype(my_computer))
		return

	var/list/data = list()
	var/datum/computer_file/program/downloader/prog = program
	// For now limited to execution by the downloader program
	if(!prog || !istype(prog))
		return
	if(program)
		data = program.get_header_data()

	// This IF cuts on data transferred to client, so i guess it's worth it.
	if(prog.downloaderror) // Download errored. Wait until user resets the program.
		data["error"] = prog.downloaderror
	if(prog.downloaded_file) // Download running. Wait please..
		data["downloadname"] = prog.downloaded_file.filename
		data["downloaddesc"] = prog.downloaded_file.filedesc
		data["downloadsize"] = prog.downloaded_file.size
		data["downloadspeed"] = prog.ntnet_speed
		data["downloadcompletion"] = round(prog.download_completion, 0.01)

	data["download_paused"] = prog.download_paused
	data["disk_size"] = my_computer.hard_drive.max_capacity
	data["disk_used"] = my_computer.hard_drive.used_capacity

	var/obj/item/weapon/computer_hardware/hard_drive/HDD = program.computer.hard_drive
	if(!HDD)
		return 1
	var/list/datum/computer_file/program/installed_programs = list()
	for(var/datum/computer_file/program/P in HDD.stored_files)
		installed_programs.Add(P)

	var/list/datum/computer_file/program/downloadable_programs = list()
	for(var/datum/computer_file/program/P in ntnet_global.available_station_software)
		downloadable_programs.Add(P)

	for(var/datum/computer_file/program/P in downloadable_programs) //Removeing programs from list that are already present on HDD
		for(var/datum/computer_file/program/I in installed_programs)
			if(P.filename == I.filename)
				downloadable_programs -= P
				break

	var/list/queue = list() // Nanoui can't iterate through assotiative lists, so we have to do this
	if(prog.downloads_queue.len > 0)
		for(var/item in prog.downloads_queue)
			queue += item
		data["downloads_queue"] = queue

	var/list/all_entries[0]
	for(var/datum/computer_file/program/P in downloadable_programs)
		// Only those programs our user can run will show in the list
		if(!P.can_run(user) && P.requires_access_to_download)
			continue
		if(!P.is_supported_by_hardware(my_computer, user))
			continue
		all_entries.Add(list(list(
		"filename" = P.filename,
		"filedesc" = P.filedesc,
		"fileinfo" = P.extended_desc,
		"size" = P.size,
		"icon" = P.program_menu_icon,
		"in_queue" = (P.filename in queue) ? 1 : 0
		)))
	data["hackedavailable"] = 0
	if(prog.computer_emagged) // If we are running on emagged computer we have access to some "bonus" software
		var/list/hacked_programs[0]
		for(var/datum/computer_file/program/P in ntnet_global.available_antag_software)
			data["hackedavailable"] = 1
			hacked_programs.Add(list(list(
			"filename" = P.filename,
			"filedesc" = P.filedesc,
			"fileinfo" = P.extended_desc,
			"size" = P.size,
			"icon" = P.program_menu_icon
			)))
		data["hacked_programs"] = hacked_programs

	data["downloadable_programs"] = all_entries



	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "mpc_downloader.tmpl", name, 600, 700, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

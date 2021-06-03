// Operates NanoUI
/obj/item/modular_computer/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	if(!screen_on || !enabled || bsod)
		if(ui)
			ui.close()
		return 0
	if(!try_use_power(0))
		if(ui)
			ui.close()
		return 0

	// If we have an active program switch to it now.
	if(active_program)
		if(ui) // This is the main laptop screen. Since we are switching to program's UI close it for now.
			ui.close()
		active_program.nano_ui_interact(user)
		return

	// We are still here, that means there is no program loaded. Load the BIOS/ROM/OS/whatever you want to call it.
	// This screen simply lists available programs and user may select them.
	if(!hard_drive || !hard_drive.stored_files || !hard_drive.stored_files.len)
		visible_message("\The [src] beeps three times, it's screen displaying \"DISK ERROR\" warning.")
		return // No HDD, No HDD files list or no stored files. Something is very broken.

	var/list/data = get_header_data()

	data["hard_drive"] = get_program_data(hard_drive)

	if(portable_drive)
		data["portable_drive"] = get_program_data(portable_drive)


	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "mpc_mainscreen.tmpl", "NTOS Main Menu", 400, 500)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

// Handles user's GUI input
/obj/item/modular_computer/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["PC_exit"])
		kill_program()
		return 1
	if(href_list["PC_enable_component"])
		var/obj/item/weapon/computer_hardware/H = find_hardware_by_name(href_list["component"])
		if(istype(H) && !H.enabled)
			H.enabled = TRUE
			H.enabled()
		. = 1
	if(href_list["PC_disable_component"])
		var/obj/item/weapon/computer_hardware/H = find_hardware_by_name(href_list["component"])
		if(istype(H) && H.enabled)
			H.enabled = FALSE
			H.disabled()
		. = 1
	if(href_list["PC_toggle_component"])
		var/obj/item/weapon/computer_hardware/H = find_hardware_by_name(href_list["component"])
		if(istype(H))
			H.enabled = !H.enabled
			if(H.enabled)
				H.enabled()
			else
				H.disabled()
		. = 1
	if(href_list["PC_shutdown"])
		shutdown_computer()
		return 1
	if(href_list["PC_minimize"])
		var/mob/user = usr
		minimize_program(user)

	if(href_list["PC_killprogram"])
		var/prog_name = href_list["PC_killprogram"]
		var/obj/item/weapon/computer_hardware/hard_drive/prog_disk = locate(href_list["disk"]) in src
		if(!prog_disk)
			return 1

		for(var/p in all_threads)
			var/datum/computer_file/program/PRG = p
			if(PRG.program_state == PROGRAM_STATE_KILLED)
				continue

			if(PRG.filename == prog_name && (PRG in prog_disk.stored_files))
				PRG.kill_program(forced=TRUE)
				to_chat(usr, SPAN_NOTICE("Program [PRG.filename].[PRG.filetype] has been killed."))
				. = 1

	if(href_list["PC_runprogram"])
		var/obj/item/weapon/computer_hardware/hard_drive/prog_disk = locate(href_list["disk"]) in src
		return run_program(href_list["PC_runprogram"], prog_disk)

	if(href_list["PC_setautorun"])
		if(!hard_drive)
			return
		set_autorun(href_list["PC_setautorun"])
	if(href_list["PC_terminal"])
		open_terminal(usr)
		return 1

	if(.)
		update_uis()


// Function used by NanoUI to obtain a list of programs for a given disk
/obj/item/modular_computer/proc/get_program_data(obj/item/weapon/computer_hardware/hard_drive/disk)
	var/datum/computer_file/data/autorun = disk.find_file_by_name("autorun")

	var/list/disk_data = list(
		"ref" = "\ref[disk]",
		"name" = disk.get_disk_name(),
		"autorun" = istype(autorun) ? autorun.stored_data : ""
	)

	var/list/programs = list()
	for(var/datum/computer_file/program/PRG in disk.stored_files)
		var/list/program = list(
			"name" = PRG.filename,
			"desc" = PRG.filedesc,
			"icon" = PRG.program_menu_icon,
			"running" = (PRG in all_threads)
			)
		programs.Add(list(program))
	disk_data["programs"] = programs

	return disk_data


// Function used by NanoUI's to obtain data for header. All relevant entries begin with "PC_"
/obj/item/modular_computer/proc/get_header_data()
	var/list/data = list()

	if(cell)
		switch(cell.percent())
			if(80 to 200) // 100 should be maximal but just in case..
				data["PC_batteryicon"] = "batt_100.gif"
			if(60 to 80)
				data["PC_batteryicon"] = "batt_80.gif"
			if(40 to 60)
				data["PC_batteryicon"] = "batt_60.gif"
			if(20 to 40)
				data["PC_batteryicon"] = "batt_40.gif"
			if(5 to 20)
				data["PC_batteryicon"] = "batt_20.gif"
			else
				data["PC_batteryicon"] = "batt_5.gif"
		data["PC_batterypercent"] = "[round(cell.percent())] %"
		data["PC_showbatteryicon"] = TRUE
	else
		data["PC_batteryicon"] = "batt_5.gif"
		data["PC_batterypercent"] = "N/C"
		data["PC_showbatteryicon"] = FALSE

	if(led)
		data["PC_light_name"] = led.name
		data["PC_light_on"] = led.enabled

	if(tesla_link && tesla_link.enabled && apc_powered)
		data["PC_apclinkicon"] = "charging.gif"

	if(network_card && network_card.is_banned())
		data["PC_ntneticon"] = "sig_warning.gif"
	else
		switch(get_ntnet_status())
			if(0)
				data["PC_ntneticon"] = "sig_none.gif"
			if(1)
				data["PC_ntneticon"] = "sig_low.gif"
			if(2)
				data["PC_ntneticon"] = "sig_high.gif"
			if(3)
				data["PC_ntneticon"] = "sig_lan.gif"

	if(gps_sensor)
		data["has_gps"] = TRUE
		if (gps_sensor.check_functionality())
			data["gps_icon"] = "satelite_on.gif"
		else
			data["gps_icon"] = "satelite_off.gif"
		data["gps_data"] = gps_sensor.get_position_text()

	var/list/program_headers = list()
	for(var/p in all_threads)
		var/datum/computer_file/program/PRG = p
		if(!PRG.ui_header)
			continue
		program_headers.Add(list(list(
			"icon" = PRG.ui_header
		)))
	data["PC_programheaders"] = program_headers

	data["PC_stationtime"] = stationtime2text()
	data["PC_hasheader"] = 1
	data["PC_showexitprogram"] = active_program ? 1 : 0 // Hides "Exit Program" button on mainscreen
	return data

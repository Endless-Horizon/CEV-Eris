/datum/computer_file/program/filemanager
	filename = "filemanager"
	filedesc = "File Manager"
	extended_desc = "This program allows management of files."
	program_icon_state = "generic"
	program_key_state = "generic_key"
	program_menu_icon = "folder-collapsed"
	size = 6
	requires_ntnet = 0
	available_on_ntnet = 0
	undeletable = 1
	nanomodule_path = /datum/nano_module/program/computer_filemanager/
	var/open_file
	var/error
	usage_flags = PROGRAM_ALL

/datum/computer_file/program/filemanager/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["PRG_openfile"])
		. = 1
		open_file = href_list["PRG_openfile"]
	if(href_list["PRG_newtextfile"])
		. = 1
		var/newname = sanitize(input(usr, "Enter file name or leave blank to cancel:", "File rename"))
		if(!newname)
			return 1
		var/obj/item/weapon/computer_hardware/hard_drive/HDD = computer.hard_drive
		if(!HDD)
			return 1
		var/datum/computer_file/data/F = new/datum/computer_file/data()
		F.filename = newname
		F.filetype = "TXT"
		HDD.store_file(F)
	if(href_list["PRG_deletefile"])
		. = 1
		var/obj/item/weapon/computer_hardware/hard_drive/HDD = computer.hard_drive
		if(!HDD)
			return 1
		var/datum/computer_file/file = HDD.find_file_by_name(href_list["PRG_deletefile"])
		if(!file || file.undeletable)
			return 1
		HDD.remove_file(file)
	if(href_list["PRG_usbdeletefile"])
		. = 1
		var/obj/item/weapon/computer_hardware/hard_drive/RHDD = computer.portable_drive
		if(!RHDD)
			return 1
		var/datum/computer_file/file = RHDD.find_file_by_name(href_list["PRG_usbdeletefile"])
		if(!file || file.undeletable)
			return 1
		RHDD.remove_file(file)
	if(href_list["PRG_closefile"])
		. = 1
		open_file = null
		error = null
	if(href_list["PRG_clone"])
		. = 1
		var/obj/item/weapon/computer_hardware/hard_drive/HDD = computer.hard_drive
		if(!HDD)
			return 1
		var/datum/computer_file/F = HDD.find_file_by_name(href_list["PRG_clone"])
		if(!F || !istype(F))
			return 1
		var/datum/computer_file/C = F.clone(1)
		HDD.store_file(C)
	if(href_list["PRG_rename"])
		. = 1
		var/obj/item/weapon/computer_hardware/hard_drive/HDD = computer.hard_drive
		if(!HDD)
			return 1
		var/datum/computer_file/file = HDD.find_file_by_name(href_list["PRG_rename"])
		if(!file || !istype(file))
			return 1
		var/newname = sanitize(input(usr, "Enter new file name:", "File rename", file.filename))
		if(file && newname)
			file.filename = newname
	if(href_list["PRG_edit"])
		. = 1
		if(!open_file)
			return 1
		var/obj/item/weapon/computer_hardware/hard_drive/HDD = computer.hard_drive
		if(!HDD)
			return 1
		var/datum/computer_file/data/F = HDD.find_file_by_name(open_file)
		if(!F || !istype(F))
			return 1
		if(F.read_only && (alert("WARNING: This file is not compatible with editor. Editing it may result in permanently corrupted formatting or damaged data consistency. Edit anyway?", "Incompatible File", "No", "Yes") == "No"))
			return 1

		var/oldtext = html_decode(F.stored_data)
		oldtext = replacetext(oldtext, "\[br\]", "\n")

		var/newtext = sanitize(replacetext(input(usr, "Editing file [open_file]. You may use most tags used in paper formatting:", "Text Editor", oldtext), "\n", "\[br\]"), MAX_TEXTFILE_LENGTH)
		if(!newtext)
			return

		if(F)
			var/datum/computer_file/data/backup = F.clone()
			HDD.remove_file(F)
			F.stored_data = newtext
			F.calculate_size()
			// We can't store the updated file, it's probably too large. Print an error and restore backed up version.
			// This is mostly intended to prevent people from losing texts they spent lot of time working on due to running out of space.
			// They will be able to copy-paste the text from error screen and store it in notepad or something.
			if(!HDD.store_file(F))
				error = "I/O error: Unable to overwrite file. Hard drive is probably full. You may want to backup your changes before closing this window:<br><br>[html_decode(F.stored_data)]<br><br>"
				HDD.store_file(backup)
	if(href_list["PRG_printfile"])
		. = 1
		if(!open_file)
			return 1
		var/obj/item/weapon/computer_hardware/hard_drive/HDD = computer.hard_drive
		if(!HDD)
			return 1
		var/datum/computer_file/data/F = HDD.find_file_by_name(open_file)
		if(!F || !istype(F))
			return 1
		if(!computer.printer)
			error = "Missing Hardware: Your computer does not have required hardware to complete this operation."
			return 1
		if(!computer.printer.print_text(pencode2html(F.stored_data)))
			error = "Hardware error: Printer was unable to print the file. It may be out of paper."
			return 1
	if(href_list["PRG_copytousb"])
		. = 1
		var/obj/item/weapon/computer_hardware/hard_drive/HDD = computer.hard_drive
		var/obj/item/weapon/computer_hardware/hard_drive/portable/RHDD = computer.portable_drive
		if(!HDD || !RHDD)
			return 1
		var/datum/computer_file/F = HDD.find_file_by_name(href_list["PRG_copytousb"])
		if(!F || !istype(F))
			return 1
		var/datum/computer_file/C = F.clone(0)
		RHDD.store_file(C)
	if(href_list["PRG_copyfromusb"])
		. = 1
		var/obj/item/weapon/computer_hardware/hard_drive/HDD = computer.hard_drive
		var/obj/item/weapon/computer_hardware/hard_drive/portable/RHDD = computer.portable_drive
		if(!HDD || !RHDD)
			return 1
		var/datum/computer_file/F = RHDD.find_file_by_name(href_list["PRG_copyfromusb"])
		if(!F || !istype(F))
			return 1
		var/datum/computer_file/C = F.clone(0)
		HDD.store_file(C)
	if(.)
		SSnano.update_uis(NM)

/datum/nano_module/program/computer_filemanager
	name = "File Manager"

/datum/nano_module/program/computer_filemanager/nano_ui_data()
	var/list/data = host.initial_data()

	var/datum/computer_file/program/filemanager/PRG
	PRG = program

	if(PRG.error)
		data["error"] = PRG.error

	if(!PRG.computer || !PRG.computer.hard_drive)
		data["error"] = "I/O ERROR: Unable to access hard drive."

	else
		if(PRG.computer.hard_drive)
			data["internal_disk"] = PRG.computer.hard_drive.nano_ui_data()

		if(PRG.computer.portable_drive)
			data["portable_disk"] = PRG.computer.portable_drive.nano_ui_data()

		if(PRG.open_file)
			var/datum/computer_file/data/file

			file = PRG.computer.hard_drive.find_file_by_name(PRG.open_file)
			if(file.filetype == "AUD")
				data["error"] = "Software error: Please use a dedicated Audio Player program to read audio files."
			else if(!istype(file))
				data["error"] = "I/O ERROR: Unable to open file."
			else
				data["filedata"] = pencode2html(file.stored_data)
				data["filename"] = "[file.filename].[file.filetype]"

	return data

/datum/nano_module/program/computer_filemanager/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = NANOUI_FOCUS, datum/topic_state/state = GLOB.default_state)
	var/list/data = nano_ui_data()

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "mpc_file_manager.tmpl", name, 575, 700, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()

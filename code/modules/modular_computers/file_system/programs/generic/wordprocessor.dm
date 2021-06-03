/datum/computer_file/program/wordprocessor
	filename = "wordprocessor"
	filedesc = "NanoWord"
	extended_desc = "This program allows the editing and preview of text documents."
	program_icon_state = "word"
	program_key_state = "atmos_key"
	size = 4
	requires_ntnet = FALSE
	available_on_ntnet = TRUE
	nanomodule_path = /datum/nano_module/program/computer_wordprocessor/
	var/browsing
	var/open_file
	var/loaded_data = ""
	var/error
	var/is_edited
	usage_flags = PROGRAM_ALL

/datum/computer_file/program/wordprocessor/proc/open_file(var/filename)
	var/datum/computer_file/data/F = get_file(filename)
	if(F)
		open_file = F.filename
		loaded_data = F.stored_data
		return TRUE

/datum/computer_file/program/wordprocessor/proc/save_file(var/filename)
	var/datum/computer_file/data/F = get_file(filename)
	if(!F) //try to make one if it doesn't exist
		F = create_file(filename, loaded_data, /datum/computer_file/data/text)
		return !isnull(F)
	var/datum/computer_file/data/backup = F.clone()
	var/obj/item/weapon/computer_hardware/hard_drive/HDD = computer.hard_drive
	if(!HDD)
		return
	HDD.remove_file(F)
	F.stored_data = loaded_data
	F.calculate_size()
	if(!HDD.store_file(F))
		HDD.store_file(backup)
		return FALSE
	is_edited = FALSE
	return TRUE

/datum/computer_file/program/wordprocessor/Topic(href, href_list)
	if(..())
		return TRUE

	if(href_list["PRG_txtrpeview"])
		show_browser(usr,"<HTML><HEAD><TITLE>[open_file]</TITLE></HEAD>[pencode2html(loaded_data)]</BODY></HTML>", "window=open_file")
		return TRUE

	if(href_list["PRG_taghelp"])
		to_chat(usr, "<span class='notice'>The hologram of a googly-eyed paper clip helpfully tells you:</span>")
		var/help = {"
		\[br\] : Creates a linebreak.
		\[center\] - \[/center\] : Centers the text.
		\[h1\] - \[/h1\] : First level heading.
		\[h2\] - \[/h2\] : Second level heading.
		\[h3\] - \[/h3\] : Third level heading.
		\[b\] - \[/b\] : Bold.
		\[i\] - \[/i\] : Italic.
		\[u\] - \[/u\] : Underlined.
		\[small\] - \[/small\] : Decreases the size of the text.
		\[large\] - \[/large\] : Increases the size of the text.
		\[field\] : Inserts a blank text field, which can be filled later. Useful for forms.
		\[date\] : Current station date.
		\[time\] : Current station time.
		\[list\] - \[/list\] : Begins and ends a list.
		\[*\] : A list item.
		\[hr\] : Horizontal rule.
		\[table\] - \[/table\] : Creates table using \[row\] and \[cell\] tags.
		\[grid\] - \[/grid\] : Table without visible borders, for layouts.
		\[row\] - New table row.
		\[cell\] - New table cell.
		\[logo\] - Inserts corporate logo image.
		\[guild\] - Inserts Guild logo image.
		\[moebius\] - Inserts Moebius logo image.
		\[ironhammer\] - Inserts Ironhammer logo image.
		\[bluelogo\] - Inserts blue corporate logo image.
		\[solcrest\] - Inserts SCG crest image.
		\[terraseal\] - Inserts TCC seal"}

		to_chat(usr, help)
		return TRUE

	if(href_list["PRG_closebrowser"])
		browsing = FALSE
		return TRUE

	if(href_list["PRG_backtomenu"])
		error = null
		return TRUE

	if(href_list["PRG_loadmenu"])
		browsing = TRUE
		return TRUE

	if(href_list["PRG_openfile"])
		. = TRUE
		if(is_edited)
			if(alert("Would you like to save your changes first?",,"Yes","No") == "Yes")
				save_file(open_file)
		browsing = FALSE
		if(!open_file(href_list["PRG_openfile"]))
			error = "I/O error: Unable to open file '[href_list["PRG_openfile"]]'."

	if(href_list["PRG_newfile"])
		. = TRUE
		if(is_edited)
			if(alert("Would you like to save your changes first?",,"Yes","No") == "Yes")
				save_file(open_file)

		var/newname = sanitize(input(usr, "Enter file name:", "New File"))
		if(!newname)
			return TRUE
		var/datum/computer_file/data/F = create_file(newname, "", /datum/computer_file/data/text)
		if(F)
			open_file = F.filename
			loaded_data = ""
			return TRUE
		else
			error = "I/O error: Unable to create file '[href_list["PRG_saveasfile"]]'."

	if(href_list["PRG_saveasfile"])
		. = TRUE
		var/newname = sanitize(input(usr, "Enter file name:", "Save As"))
		if(!newname)
			return TRUE
		var/datum/computer_file/data/F = create_file(newname, loaded_data, /datum/computer_file/data/text)
		if(F)
			open_file = F.filename
		else
			error = "I/O error: Unable to create file '[href_list["PRG_saveasfile"]]'."
		return TRUE

	if(href_list["PRG_savefile"])
		. = TRUE
		if(!open_file)
			open_file = sanitize(input(usr, "Enter file name:", "Save As"))
			if(!open_file)
				return FALSE
		if(!save_file(open_file))
			error = "I/O error: Unable to save file '[open_file]'."
		return TRUE

	if(href_list["PRG_editfile"])
		var/oldtext = html_decode(loaded_data)
		oldtext = replacetext(oldtext, "\[br\]", "\n")

		var/newtext = sanitize(replacetext(input(usr, "Editing file '[open_file]'. You may use most tags used in paper formatting:", "Text Editor", oldtext), "\n", "\[br\]"), MAX_TEXTFILE_LENGTH)
		if(!newtext)
			return
		loaded_data = newtext
		is_edited = TRUE
		return TRUE

	if(href_list["PRG_printfile"])
		. = TRUE
		if(!computer.printer)
			error = "Missing Hardware: Your computer does not have the required hardware to complete this operation."
			return TRUE
		if(!computer.printer.print_text(pencode2html(loaded_data)))
			error = "Hardware error: Printer was unable to print the file. It may be out of paper."
			return TRUE

/datum/nano_module/program/computer_wordprocessor
	name = "Word Processor"

/datum/nano_module/program/computer_wordprocessor/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS, var/datum/topic_state/state = GLOB.default_state)
	var/list/data = host.initial_data()
	var/datum/computer_file/program/wordprocessor/PRG
	PRG = program

	var/obj/item/weapon/computer_hardware/hard_drive/HDD
	var/obj/item/weapon/computer_hardware/hard_drive/portable/RHDD
	if(PRG.error)
		data["error"] = PRG.error
	if(PRG.browsing)
		data["browsing"] = PRG.browsing
		if(!PRG.computer || !PRG.computer.hard_drive)
			data["error"] = "I/O ERROR: Unable to access hard drive."
		else
			HDD = PRG.computer.hard_drive
			var/list/files[0]
			for(var/datum/computer_file/F in HDD.stored_files)
				if(F.filetype == "TXT")
					files.Add(list(list(
						"name" = F.filename,
						"size" = F.size
					)))
			data["files"] = files

			RHDD = PRG.computer.portable_drive
			if(RHDD)
				data["usbconnected"] = TRUE
				var/list/usbfiles[0]
				for(var/datum/computer_file/F in RHDD.stored_files)
					if(F.filetype == "TXT")
						usbfiles.Add(list(list(
							"name" = F.filename,
							"size" = F.size,
						)))
				data["usbfiles"] = usbfiles
	else if(PRG.open_file)
		data["filedata"] = pencode2html(PRG.loaded_data)
		data["filename"] = PRG.is_edited ? "[PRG.open_file]*" : PRG.open_file
	else
		data["filedata"] = pencode2html(PRG.loaded_data)
		data["filename"] = "UNNAMED"

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "word_processor.tmpl", "Word Processor", 575, 700, state = state)
		ui.auto_update_layout = TRUE
		ui.set_initial_data(data)
		ui.open()

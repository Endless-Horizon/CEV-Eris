/datum/computer_file/program/audio
	filename = "audioplyr"
	filedesc = "Audio Player"
	nanomodule_path = /datum/nano_module/program/audio
	extended_desc = "This program may be used to play audio files. Features vocal transcription."
	size = 3
	available_on_ntnet = TRUE
	requires_ntnet = FALSE
	usage_flags = PROGRAM_ALL
	var/datum/computer_file/data/audio/selected_audio
	var/transcribing = FALSE
	var/transcribe_progress = 0
	var/browsing = TRUE
	var/playing
	var/playsleepseconds = 0
	var/error

/datum/computer_file/program/audio/proc/open_audio(var/filename)
	var/datum/computer_file/data/audio/F = get_file(filename)
	if(F)
		selected_audio = F
		return TRUE

/datum/computer_file/program/audio/proc/play_audio()
	var/used = selected_audio.used_capacity
	var/max = selected_audio.max_capacity
	for(var/i=1,used<max,sleep(10 * (playsleepseconds) ))
		if(!playing)
			break
		if(!selected_audio)
			break
		if(selected_audio.storedinfo.len < i)
			break
		var/turf/T = get_turf(computer)
		var/playedmessage = selected_audio.storedinfo[i]
		if (findtextEx(playedmessage,"*",1,2)) //remove marker for action sounds
			playedmessage = copytext(playedmessage,2)
		T.audible_message("<font color=Maroon><B>Audio Player</B>: [playedmessage]</font>")
		if(selected_audio.storedinfo.len < i+1)
			playsleepseconds = 1
			sleep(10)
			T = get_turf(computer)
			T.audible_message("<font color=Maroon><B>Audio Player</B>: End of recording.</font>")
			playing = FALSE
		else
			playsleepseconds = selected_audio.timestamp[i+1] - selected_audio.timestamp[i]
		if(playsleepseconds > 14)
			sleep(10)
			T = get_turf(computer)
			T.audible_message("<font color=Maroon><B>Audio Player</B>: Skipping [playsleepseconds] seconds of silence</font>")
			playsleepseconds = 1
		i++

/datum/computer_file/program/audio/process_tick()
	..()
	if(!selected_audio)
		transcribing = 0
	if(transcribing)
		transcribe_progress += ntnet_speed
		if(transcribe_progress >= selected_audio.size)
			transcribe_progress = 0
			transcribing = 0
			selected_audio.transcribed = TRUE
		SSnano.update_uis(NM)

/datum/computer_file/program/audio/kill_program(forced = FALSE)
	..()
	selected_audio = null
	browsing = TRUE
	transcribe_progress = 0
	transcribing = FALSE

/datum/computer_file/program/audio/Topic(href, href_list)
	if(..())
		return TRUE

	if(href_list["PRG_closebrowser"])
		browsing = FALSE
		return TRUE

	if(href_list["PRG_backtomenu"])
		error = null
		return TRUE

	if(href_list["PRG_reset"])
		transcribing = 0
		transcribe_progress = 0
		return TRUE

	if(href_list["PRG_toggleaudio"])
		if(playing)
			playing = FALSE
		else
			if(selected_audio)
				playing = TRUE
				play_audio()
		SSnano.update_uis(NM)
		return TRUE

	if(href_list["PRG_loadmenu"])
		browsing = TRUE
		return TRUE

	if(href_list["PRG_transcribe"])
		if(selected_audio)
			playing = FALSE
			transcribing = TRUE
		else
			error = "Error: No file loaded."
		return TRUE

	if(href_list["PRG_openaudio"])
		. = TRUE
		playing = FALSE
		browsing = FALSE
		if(!open_audio(href_list["PRG_openaudio"]))
			error = "I/O error: Unable to open file '[href_list["PRG_openaudio"]]'."

	if(href_list["PRG_printfile"])
		. = TRUE
		if(!selected_audio)
			error = "Error: No file loaded."
			return TRUE
		if(!computer.printer)
			error = "Missing Hardware: Your computer does not have the required hardware to complete this operation."
			return TRUE
		if(!computer.printer.print_text(selected_audio.transcribed ? selected_audio.stored_data : "Please press the \"Transcribe\" button to transcribe the audio file."))
			error = "Hardware error: Printer was unable to print the file. It may be out of paper."
			return TRUE

/datum/nano_module/program/audio
	name = "Audio Player"

/datum/nano_module/program/audio/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS, var/datum/topic_state/state = GLOB.default_state)

	var/datum/computer_file/program/audio/PRG
	var/list/data = host.initial_data()
	if(program)
		data = program.get_header_data()
		PRG = program
	else
		return
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
				if(F.filetype == "AUD")
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
					if(F.filetype == "AUD")
						usbfiles.Add(list(list(
							"name" = F.filename,
							"size" = F.size,
						)))
				data["usbfiles"] = usbfiles

	else if(!PRG.transcribing)
		data["playing"] = PRG.playing
		if(PRG.selected_audio)
			data["filename"] = PRG.selected_audio.filename
			data["transcript"] = PRG.selected_audio.transcribed ? PRG.selected_audio.stored_data : "Please press the \"Transcribe\" button to transcribe the audio file."
		else
			data["filename"] = "No File"
			data["transcript"] = "Please load an audio file."
	else
		data["transcribe_running"] = 1
		data["transcribe_progress"] = PRG.transcribe_progress
		data["transcribe_maxprogress"] = PRG.selected_audio.size
		data["transcribe_rate"] = PRG.ntnet_speed


	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "mpc_audio_player.tmpl", name, 575, 700, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()

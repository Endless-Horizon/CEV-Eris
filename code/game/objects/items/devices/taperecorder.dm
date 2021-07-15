/obj/item/device/taperecorder
	name = "universal recorder"
	desc = "A device that can record audio to data crystals, and play them. It automatically translates the content in playback."
	icon_state = "taperecorder_idle"
	item_state = "analyzer"
	w_class = ITEM_SIZE_SMALL

	matter = list(MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1)
	flags = CONDUCT
	throwforce = WEAPON_FORCE_HARMLESS
	throw_speed = 4
	throw_range = 20

	var/emagged = 0
	var/recording = 0
	var/playing = 0
	var/playsleepseconds = 0
	var/obj/item/computer_hardware/hard_drive/portable/mydrive
	var/datum/computer_file/data/audio/audio_file
	var/starting_drive_type = /obj/item/computer_hardware/hard_drive/portable
	var/datum/wires/taperecorder/wires // Wires datum
	var/open_panel = 0

/obj/item/device/taperecorder/New()
	..()
	add_hearing()
	wires = new(src)
	if(starting_drive_type)
		mydrive = new starting_drive_type(src)
	update_icon()

/obj/item/device/taperecorder/Destroy()
	qdel(wires)
	remove_hearing()
	. = ..()

/obj/item/device/taperecorder/examine(mob/user)
	if(..(user, 1) && open_panel)
		to_chat(usr, "The wire panel is open.")

/obj/item/device/taperecorder/attackby(obj/item/I, mob/user, params)
	if(!mydrive && istype(I, /obj/item/computer_hardware/hard_drive/portable))
		if(insert_item(I, user))
			mydrive = I
			update_icon()
		return

	if(QUALITY_SCREW_DRIVING in I.tool_qualities)
		if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, QUALITY_SCREW_DRIVING, FAILCHANCE_EASY, required_stat = STAT_MEC))
			open_panel = !open_panel
			to_chat(usr, SPAN_NOTICE("You [open_panel ? "open" : "close"] the wire panel."))
		return

	else if(istool(I))
		wires.Interact(user)
	else
		..()

/obj/item/device/taperecorder/MouseDrop(over_object)
	if(mydrive && (src.loc == usr) && istype(over_object, /obj/screen/inventory/hand))
		eject_usb()

/obj/item/device/taperecorder/on_update_icon()
	if(!mydrive)
		icon_state = "taperecorder_empty"
	else if(recording)
		icon_state = "taperecorder_recording"
	else if(playing)
		icon_state = "taperecorder_playing"
	else
		icon_state = "taperecorder_idle"

/obj/item/device/taperecorder/hear_talk(mob/living/M as mob, msg, var/verb="says", datum/language/speaking=null, speech_volume)
	if(speech_volume)
		msg = "<FONT size='[speech_volume]'>[msg]</FONT>"
	if(audio_file && recording)
		audio_file.timestamp += audio_file.used_capacity

		if(speaking)
			audio_file.storedinfo += "\[[time2text(audio_file.used_capacity*10,"mm:ss")]\] [M.name] [speaking.format_message_plain(msg, verb)]"
		else
			audio_file.storedinfo += "\[[time2text(audio_file.used_capacity*10,"mm:ss")]\] [M.name] [verb], \"[msg]\""

/obj/item/device/taperecorder/see_emote(mob/M as mob, text, var/emote_type)
	if(emote_type != 2) //only hearable emotes
		return
	if(audio_file && recording)
		audio_file.timestamp += audio_file.used_capacity
		audio_file.storedinfo += "\[[time2text(audio_file.used_capacity*10,"mm:ss")]\] [strip_html_properly(text)]"

/obj/item/device/taperecorder/show_message(msg, type, alt, alt_type)
	var/recordedtext
	if (msg && type == 2) //must be hearable
		recordedtext = msg
	else if (alt && alt_type == 2)
		recordedtext = alt
	else
		return
	if(audio_file && recording)
		audio_file.timestamp += audio_file.used_capacity
		audio_file.storedinfo += "*\[[time2text(audio_file.used_capacity*10,"mm:ss")]\] *[strip_html_properly(recordedtext)]*" //"*" at front as a marker

/obj/item/device/taperecorder/emag_act(var/remaining_charges, var/mob/user)
	if(!emagged)
		emagged = 1
		recording = 0
		to_chat(user, SPAN_WARNING("PZZTTPFFFT"))
		update_icon()
		return 1
	else
		to_chat(user, SPAN_WARNING("It is already emagged!"))

/obj/item/device/taperecorder/proc/explode()
	var/turf/T = get_turf(loc)
	if(ismob(loc))
		var/mob/M = loc
		to_chat(M, SPAN_DANGER("\The [src] explodes!"))
	if(T)
		T.hotspot_expose(700,125)
		explosion(T, -1, -1, 0, 4)
	qdel(src)
	return

/obj/item/device/taperecorder/verb/eject_usbverb()
	set name = "Eject Crystal"
	set category = "Object"

	eject_usb()

/obj/item/device/taperecorder/verb/recordverb()
	set name = "Start Recording"
	set category = "Object"

	record()

/obj/item/device/taperecorder/verb/stopverb()
	set name = "Stop"
	set category = "Object"

	stop()

/obj/item/device/taperecorder/verb/playverb()
	set name = "Play Audio"
	set category = "Object"

	playback_memory()

/obj/item/device/taperecorder/verb/clearverb()
	set name = "Clear Audio"
	set category = "Object"

	clear_memory()

/obj/item/device/taperecorder/verb/change_audioverb()
	set name = "Switch Audio"
	set category = "Object"

	change_audio()

/obj/item/device/taperecorder/proc/eject_usb()
	if(mydrive && eject_item(mydrive, usr))
		stop()
		mydrive = null
		audio_file = null
		update_icon()

/obj/item/device/taperecorder/proc/record(var/show_message = 1)

	if(usr.stat)
		return
	if(!mydrive)
		return
	if(recording)
		return
	if(playing)
		return
	if(emagged)
		if(show_message)
			to_chat(usr, SPAN_WARNING("The recorder makes a scratchy noise."))
		return

	if(!audio_file)
		create_audio_file(show_message)
		if(!audio_file)
			return

	playsound(loc, 'sound/machines/button.ogg', 100, 1)
	if(audio_file.used_capacity < audio_file.max_capacity)
		icon_state = "taperecorder_recording"
		if(show_message)
			to_chat(usr, SPAN_NOTICE("Recording started."))
		recording = 1
		audio_file.timestamp += audio_file.used_capacity
		audio_file.storedinfo += "\[[time2text(audio_file.used_capacity * 10,"mm:ss")]\] Recording started."
		var/used = audio_file.used_capacity	//to stop runtimes when you eject the drive
		var/max = audio_file.max_capacity
		for(used, used < max)
			if(!recording)
				break
			audio_file.used_capacity++
			used++
			sleep(10)
		recording = 0
		update_icon()
		return
	else if(show_message)
		to_chat(usr, SPAN_NOTICE("The file is full."))


/obj/item/device/taperecorder/proc/stop(var/show_message = 1)

	if(usr.stat)
		return
	if(emagged)
		if(show_message)
			to_chat(usr, SPAN_WARNING("The recorder makes a scratchy noise."))
		return
	playsound(loc, 'sound/machines/button.ogg', 100, 1)
	if(recording)
		recording = 0
		audio_file.timestamp += audio_file.used_capacity
		audio_file.storedinfo += "\[[time2text(audio_file.used_capacity*10,"mm:ss")]\] Recording stopped."
		audio_file.stored_data = null
		for(var/entry in audio_file.storedinfo)
			audio_file.stored_data += "[entry]<br>"
		if(show_message)
			to_chat(usr, SPAN_NOTICE("Recording stopped."))
		icon_state = "taperecorder_idle"
		return
	else if(playing)
		playing = 0
		var/turf/T = get_turf(src)
		T.audible_message("<font color=Maroon><B>Recorder</B>: Playback stopped.</font>")
		icon_state = "taperecorder_idle"
		return


/obj/item/device/taperecorder/proc/clear_memory(var/show_message = 1)

	if(usr.is_dead())
		return
	else if(emagged)
		if(show_message)
			to_chat(usr, SPAN_WARNING("The recorder makes a scratchy noise."))
	else if(!audio_file)
		if(show_message)
			to_chat(usr, SPAN_WARNING("The recorder beeps. No file selected."))
	else if(recording || playing)
		if(show_message)
			to_chat(usr, SPAN_NOTICE("You can't clear the memory while playing or recording!"))
	else
		if(audio_file.storedinfo)	audio_file.storedinfo.Cut()
		if(audio_file.timestamp)	audio_file.timestamp.Cut()
		audio_file.used_capacity = 0
		if(show_message)
			to_chat(usr, SPAN_NOTICE("File cleared."))

	playsound(loc, 'sound/machines/button.ogg', 100, 1)


/obj/item/device/taperecorder/proc/playback_memory(var/show_message = 1)

	if(usr.stat)
		return
	if(!audio_file)
		if(show_message)
			to_chat(usr, SPAN_WARNING("The recorder beeps. No file selected."))
		return
	if(recording)
		if(show_message)
			to_chat(usr, SPAN_NOTICE("You can't playback when recording!"))
		return
	if(playing)
		if(show_message)
			to_chat(usr, SPAN_NOTICE("You're already playing!"))
		return
	playing = 1
	icon_state = "taperecorder_playing"
	if(show_message)
		to_chat(usr, SPAN_NOTICE("Playing started."))
	playsound(loc, 'sound/machines/button.ogg', 100, 1)
	var/used = audio_file.used_capacity	//to stop runtimes when you eject the tape
	var/max = audio_file.max_capacity
	for(var/i=1,used<max,sleep(10 * (playsleepseconds) ))
		if(!playing)
			break
		if(audio_file.storedinfo.len < i)
			break
		if(!mydrive)
			playing = FALSE
			break
		var/turf/T = get_turf(src)
		var/playedmessage = audio_file.storedinfo[i]
		if (findtextEx(playedmessage,"*",1,2)) //remove marker for action sounds
			playedmessage = copytext(playedmessage,2)
		T.audible_message("<font color=Maroon><B>Recorder</B>: [playedmessage]</font>")
		if(audio_file.storedinfo.len < i+1)
			playsleepseconds = 1
			sleep(10)
			T = get_turf(src)
			T.audible_message("<font color=Maroon><B>Recorder</B>: End of recording.</font>")
		else
			playsleepseconds = audio_file.timestamp[i+1] - audio_file.timestamp[i]
		if(playsleepseconds > 14)
			sleep(10)
			T = get_turf(src)
			T.audible_message("<font color=Maroon><B>Recorder</B>: Skipping [playsleepseconds] seconds of silence</font>")
			playsleepseconds = 1
		i++
	icon_state = "taperecorder_idle"
	playing = 0
	if(emagged)
		var/turf/T = get_turf(src)
		T.audible_message("<font color=Maroon><B>Recorder</B>: This recorder will self-destruct in... Five.</font>")
		sleep(10)
		T = get_turf(src)
		T.audible_message("<font color=Maroon><B>Recorder</B>: Four.</font>")
		sleep(10)
		T = get_turf(src)
		T.audible_message("<font color=Maroon><B>Recorder</B>: Three.</font>")
		sleep(10)
		T = get_turf(src)
		T.audible_message("<font color=Maroon><B>Recorder</B>: Two.</font>")
		sleep(10)
		T = get_turf(src)
		T.audible_message("<font color=Maroon><B>Recorder</B>: One.</font>")
		sleep(10)
		explode()

/obj/item/device/taperecorder/proc/change_audio(var/show_message = 1)

	if(emagged)
		if(show_message)
			to_chat(usr, SPAN_WARNING("The recorder makes a scratchy noise."))
		return
	if(!mydrive)
		return
	if(recording || playing)
		if(show_message)
			to_chat(usr, SPAN_NOTICE("You can't switch to another file while playing or recording!"))
		return
	playsound(loc, 'sound/machines/button.ogg', 100, 1)
	var/list/audio_list = list()
	for(var/datum/computer_file/data/audio/A in mydrive.stored_files)
		audio_list[A.filename] = A
	if(show_message)
		var/usr_input = input(usr, "Which audio file do you want to switch to?.", "Audio Files") in audio_list|"New File"|"Cancel"|null
		if(isnull(usr_input))
			return
		if(usr_input == "New File")
			create_audio_file(show_message)
			return
		else if(usr_input == "Cancel")
			return
		audio_file = audio_list[usr_input]
	else
		create_audio_file(show_message)

/obj/item/device/taperecorder/proc/create_audio_file(var/show_message = 1)
	var/audio_title
	if(show_message)
		audio_title = sanitizeSafe(input(usr, "What do you want to name the recording? If you leave this blank, the title will be the current time.", "Audio file") as null|text, MAX_NAME_LEN)
	if(isnull(audio_title))
		audio_title = "Recording ([replacetext(stationtime2text(),":","hr")]min)"
	var/datum/computer_file/data/audio/F = new()
	F.filename = audio_title
	if(mydrive.store_file(F))
		audio_file = F
	else
		if(show_message)
			to_chat(usr, SPAN_WARNING("The recorder beeps. The file was unable to be saved."))
		return

/obj/item/device/taperecorder/attack_self(mob/user)
	if(!mydrive)
		return
	if(recording || playing)
		stop()
	else
		record()

//empty recorders
/obj/item/device/taperecorder/empty
	starting_drive_type = null

/obj/machinery/autolathe_disk_cloner
	name = "Autolathe disk cloner"
	desc = "Machine used for copying recipes from unprotected autolathe disks."
	icon = 'icons/obj/machines/disk_cloner.dmi'
	icon_state = "disk_cloner"
	circuit = /obj/item/weapon/electronics/circuitboard/autolathe_disk_cloner
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 500

	var/hacked = FALSE
	var/copying_delay = 0
	var/hack_fail_chance = 0

	var/obj/item/weapon/computer_hardware/hard_drive/portable/original = null
	var/obj/item/weapon/computer_hardware/hard_drive/portable/copy = null

	var/copying = FALSE


/obj/machinery/autolathe_disk_cloner/Initialize()
	. = ..()
	update_icon()

/obj/machinery/autolathe_disk_cloner/RefreshParts()
	..()
	var/laser_rating = 0
	var/scanner_rating = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/SM in component_parts)
		scanner_rating += SM.rating
	for(var/obj/item/weapon/stock_parts/micro_laser/ML in component_parts)
		laser_rating += ML.rating

	if(scanner_rating+laser_rating >= 9)
		copying_delay = 30
	else if(scanner_rating+laser_rating >= 6)
		copying_delay = 60
	else
		copying_delay = 120

	hack_fail_chance = ((scanner_rating+laser_rating) >= 9) ? 20 : 40

	if(laser_rating >= 4 && scanner_rating >= 2)
		hacked = TRUE

/obj/machinery/autolathe_disk_cloner/attackby(var/obj/item/I, var/mob/user)
	if(default_deconstruction(I, user))
		return

	if(default_part_replacement(I, user))
		return

	if(panel_open)
		return

	if(istype(I, /obj/item/weapon/computer_hardware/hard_drive/portable))
		if(!original)
			original = put_disk(I, user)
			to_chat(user, SPAN_NOTICE("You put \the [I] into the first slot of [src]."))
		else if(!copy)
			copy = put_disk(I, user)
			to_chat(user, SPAN_NOTICE("You put \the [I] into the second slot of [src]."))
		else
			to_chat(user, SPAN_NOTICE("[src]'s slots is full."))

	user.set_machine(src)
	nano_ui_interact(user)
	update_icon()


/obj/machinery/autolathe_disk_cloner/on_deconstruction()
	if(original)
		original.forceMove(src.loc)
		original = null
	if(copy)
		copy.forceMove(src.loc)
		copy = null
	..()

/obj/machinery/autolathe_disk_cloner/Process()
	update_icon()

/obj/machinery/autolathe_disk_cloner/proc/put_disk(obj/item/weapon/computer_hardware/hard_drive/portable/AD, var/mob/user)
	ASSERT(istype(AD))

	user.unEquip(AD,src)
	return AD


/obj/machinery/autolathe_disk_cloner/attack_hand(mob/user as mob)
	if(..())
		return TRUE

	user.set_machine(src)
	nano_ui_interact(user)
	update_icon()


/obj/machinery/autolathe_disk_cloner/nano_ui_data()
	var/list/data = list(
		"copying" = copying,
		"hacked" = hacked
	)

	if(original)
		data["disk1"] = original.nano_ui_data()
		data["copyingtotal"] = original.stored_files.len

	if(copy)
		data["disk2"] = copy.nano_ui_data()
		data["copyingnow"] = copy.stored_files.len

	return data


/obj/machinery/autolathe_disk_cloner/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = NANOUI_FOCUS)
	var/list/data = nano_ui_data()

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "autolathe_disk_cloner.tmpl", "Autolathe disk cloner", 480, 555)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

/obj/machinery/autolathe_disk_cloner/Topic(href, href_list)
	if(..())
		return 1

	usr.set_machine(src)

	if(href_list["start"])
		if(copying)
			copying = FALSE
		else
			copy()
		return

	if(href_list["eject"])
		var/mob/living/H = null
		var/obj/item/weapon/computer_hardware/hard_drive/portable/D = null
		if(ishuman(usr))
			H = usr
			D = H.get_active_hand()

		if(href_list["eject"] == "f")
			if(original)
				original.forceMove(src.loc)
				if(H)
					H.put_in_active_hand(original)
				original = null
			else
				if(istype(D))
					H.drop_item()
					D.forceMove(src)
					original = D
		else
			if(copy)
				copy.forceMove(src.loc)
				if(H)
					H.put_in_active_hand(copy)
				copy = null
			else
				if(istype(D))
					H.drop_item()
					D.forceMove(src)
					copy = D

	SSnano.update_uis(src)
	update_icon()


/obj/machinery/autolathe_disk_cloner/proc/copy()
	copying = TRUE
	SSnano.update_uis(src)
	update_icon()
	if(original && copy && !copy.used_capacity)
		copy.name = original.name

		if(!hacked)
			copy.name += " \[copy\]"

		for(var/f in original.stored_files)
			if(!(original && copy) || !copying || !f)
				break

			var/datum/computer_file/original_file = f
			var/datum/computer_file/copying_file

			// Design files with copy protection require special treatment
			if(istype(original_file, /datum/computer_file/binary/design))
				var/datum/computer_file/binary/design/design_file = original_file
				if(design_file.copy_protected)
					if(hacked)
						var/datum/computer_file/binary/design/design_copy

						if(prob(hack_fail_chance))
							// Make a corrupted design with same filename as the original
							design_copy = new
							design_copy.set_design_type(/datum/design/autolathe/corrupted)
							design_copy.filetype = "CCD"
							design_copy.filename = original_file.filename
						else
							// Copy the original design, remove DRM
							design_copy = design_file.clone()
							design_copy.set_copy_protection(FALSE)

						copying_file = design_copy
					else
						break

			// Any other files can be simply cloned
			if(!copying_file)
				copying_file = original_file.clone()

			// Store the copied file. If the disc is corrupted, faulty, out of space - stop the copying process.
			if(!copy.store_file(copying_file))
				break

			SSnano.update_uis(src)
			update_icon()
			sleep(copying_delay)

	copying = FALSE
	SSnano.update_uis(src)
	update_icon()


/obj/machinery/autolathe_disk_cloner/on_update_icon()
	cut_overlays()

	if(panel_open)
		add_overlays(image(icon, icon_state = "disk_cloner_panel"))

	if(!stat)
		add_overlays(image(icon, icon_state = "disk_cloner_screen"))
		add_overlays(image(icon, icon_state = "disk_cloner_keyboard"))

		if(original)
			add_overlays(image(icon, icon_state = "disk_cloner_screen_disk1"))

			if(original.stored_files.len)
				add_overlays(image(icon, icon_state = "disk_cloner_screen_list1"))

		if(copy)
			add_overlays(image(icon, icon_state = "disk_cloner_screen_disk2"))

			if(copy.stored_files.len)
				add_overlays(image(icon, icon_state = "disk_cloner_screen_list2"))

		if(copying)
			add_overlays(image(icon, icon_state = "disk_cloner_cloning"))


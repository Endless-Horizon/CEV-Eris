/obj/item/modular_computer/proc/update_verbs()
	verbs.Cut()
	if(ai_slot)
		verbs |= /obj/item/modular_computer/verb/eject_ai
	if(portable_drive)
		verbs |= /obj/item/modular_computer/verb/eject_usb
	if(card_slot && card_slot.stored_card)
		verbs |= /obj/item/modular_computer/verb/eject_id
	if(stores_pen && istype(stored_pen))
		verbs |= /obj/item/modular_computer/verb/remove_pen

	verbs |= /obj/item/verb/verb_pickup
	verbs |= /obj/item/verb/move_to_top

	verbs |= /obj/item/modular_computer/verb/emergency_shutdown

// Forcibly shut down the device. To be used when something bugs out and the UI is nonfunctional.
/obj/item/modular_computer/verb/emergency_shutdown()
	set name = "Forced Shutdown"
	set category = "Object"
	set src in view(1)

	if(!can_interact(usr))
		return

	if(enabled)
		bsod = 1
		update_icon()
		shutdown_computer()
		to_chat(usr, "You press a hard-reset button on \the [src]. It displays a brief debug screen before shutting down.")
		spawn(2 SECONDS)
			bsod = 0
			update_icon()


// Eject ID card from computer, if it has ID slot with card inside.
/obj/item/modular_computer/verb/eject_id()
	set name = "Remove ID"
	set category = "Object"
	set src in view(1)

	if(!can_interact(usr))
		return

	playsound(loc, 'sound/machines/id_swipe.ogg', 100, 1)
	proc_eject_id(usr)

// Eject USB from computer
/obj/item/modular_computer/verb/eject_usb()
	set name = "Eject Portable Storage"
	set category = "Object"
	set src in view(1)

	if(!can_interact(usr))
		return

	proc_eject_usb(usr)

/obj/item/modular_computer/verb/eject_ai()
	set name = "Eject AI"
	set category = "Object"
	set src in view(1)

	if(!can_interact(usr))
		return

	proc_eject_ai(usr)

/obj/item/modular_computer/verb/remove_pen()
	set name = "Remove Pen"
	set category = "Object"
	set src in view(1)

	if(!can_interact(usr))
		return

	if(istype(stored_pen))
		to_chat(usr, SPAN_NOTICE("You remove [stored_pen] from [src]."))
		stored_pen.forceMove(get_turf(src))
		if(!issilicon(usr))
			usr.put_in_hands(stored_pen)
		stored_pen = null
		update_verbs()

/obj/item/modular_computer/proc/proc_eject_id(mob/user)
	if(!user)
		user = usr

	if(!can_interact(usr))
		return

	for(var/p in all_threads)
		var/datum/computer_file/program/PRG = p
		PRG.event_id_removed()

	card_slot.stored_card.forceMove(get_turf(src))
	if(!issilicon(user))
		user.put_in_hands(card_slot.stored_card)
	to_chat(user, SPAN_NOTICE("You remove [card_slot.stored_card] from [src]."))
	card_slot.stored_card = null
	update_uis()
	update_verbs()
	update_label()

/obj/item/modular_computer/proc/proc_eject_usb(mob/user)
	if(!user)
		user = usr

	if(!portable_drive)
		to_chat(user, "There is no portable device connected to \the [src].")
		return

	var/obj/item/weapon/computer_hardware/hard_drive/portable/PD = portable_drive

	uninstall_component(portable_drive, user)
	user.put_in_hands(PD)
	update_uis()

/obj/item/modular_computer/proc/proc_eject_ai(mob/user)
	if(!user)
		user = usr

	if(!ai_slot || !ai_slot.stored_card)
		to_chat(user, "There is no intellicard connected to \the [src].")
		return

	ai_slot.stored_card.forceMove(get_turf(src))
	ai_slot.stored_card = null
	ai_slot.update_power_usage()
	update_uis()

/obj/item/modular_computer/attack_ghost(var/mob/observer/ghost/user)
	if(enabled)
		nano_ui_interact(user)
	else if(check_rights(R_ADMIN, 0, user))
		var/response = alert(user, "This computer is turned off. Would you like to turn it on?", "Admin Override", "Yes", "No")
		if(response == "Yes")
			turn_on(user)

/obj/item/modular_computer/attack_ai(var/mob/user)
	return attack_self(user)

/obj/item/modular_computer/attack_hand(var/mob/user)
	if(anchored)
		return attack_self(user)
	return ..()

// On-click handling. Turns on the computer if it's off and opens the GUI.
/obj/item/modular_computer/attack_self(var/mob/user)
	if(enabled && screen_on)
		nano_ui_interact(user)
	else if(!enabled && screen_on)
		turn_on(user)

/obj/item/modular_computer/attackby(obj/item/W, mob/user, sound_mute = FALSE)
	if(istype(W, /obj/item/weapon/card/id)) // ID Card, try to insert it.
		var/obj/item/weapon/card/id/I = W
		if(!card_slot)
			to_chat(user, "You try to insert [I] into [src], but it does not have an ID card slot installed.")
			return

		if(card_slot.stored_card)
			to_chat(user, "You try to insert [I] into [src], but its ID card slot is occupied.")
			return

		if(!user.unEquip(I, src))
			return

		card_slot.stored_card = I
		update_label()
		update_uis()
		update_verbs()
		if(sound_mute == FALSE) // This is here so that the sound doesn't play every time you spawn in because ID's now get moved in to PDA's on spawn.
			playsound(loc, 'sound/machines/id_swipe.ogg', 100, 1)
		to_chat(user, "You insert [I] into [src].")

		return
	if(istype(W, /obj/item/weapon/pen) && stores_pen)
		if(istype(stored_pen))
			to_chat(user, "<span class='notice'>There is already a pen in [src].</span>")
			return
		if(!insert_item(W, user))
			return
		stored_pen = W
		update_verbs()
		return

	if(scanner && scanner.do_on_attackby(user, W))
		return

	if(istype(W, /obj/item/weapon/paper) || istype(W, /obj/item/weapon/paper_bundle))
		if(printer)
			printer.attackby(W, user)
	if(istype(W, /obj/item/device/aicard))
		if(!ai_slot)
			return
		ai_slot.attackby(W, user)

	if(!modifiable)
		return ..()

	if(istype(W, suitable_cell) || istype(W, /obj/item/weapon/computer_hardware))
		try_install_component(W, user)



	var/obj/item/weapon/tool/tool = W
	if(tool)
		var/list/usable_qualities = list(QUALITY_SCREW_DRIVING, QUALITY_WELDING, QUALITY_BOLT_TURNING)
		var/tool_type = tool.get_tool_type(user, usable_qualities, src)
		switch(tool_type)
			if(QUALITY_BOLT_TURNING)
				var/list/components = get_all_components()
				if(components.len)
					to_chat(user, "Remove all components from \the [src] before disassembling it.")
					return
				if(tool.use_tool(user, src, WORKTIME_SLOW, QUALITY_BOLT_TURNING, FAILCHANCE_VERY_EASY, required_stat = STAT_COG))
					new /obj/item/stack/material/steel( get_turf(src.loc), steel_sheet_cost )
					src.visible_message("\The [src] has been disassembled by [user].")
					qdel(src)
					return

			if(QUALITY_WELDING)
				if(!damage)
					to_chat(user, "\The [src] does not require repairs.")
					return
				if(tool.use_tool(user, src, WORKTIME_SLOW, QUALITY_WELDING, FAILCHANCE_HARD, required_stat = STAT_COG))
					damage = 0
					to_chat(user, "You repair \the [src].")
					return

			if(QUALITY_SCREW_DRIVING)
				var/list/all_components = get_all_components()
				if(!all_components.len)
					to_chat(user, "This device doesn't have any components installed.")
					return
				var/list/component_names = list()
				for(var/obj/item/weapon/H in all_components)
					component_names.Add(H.name)
				var/list/options = list()
				for(var/i in component_names)
					for(var/X in all_components)
						var/obj/item/weapon/TT = X
						if(TT.name == i)
							options[i] = image(icon = TT.icon, icon_state = TT.icon_state)
				var/choice
				choice = show_radial_menu(user, src, options, radius = 32)
				if(!choice)
					return
				if(!Adjacent(usr))
					return
				if(tool.use_tool(user, src, WORKTIME_FAST, QUALITY_SCREW_DRIVING, FAILCHANCE_VERY_EASY, required_stat = STAT_COG))
					var/obj/item/weapon/computer_hardware/H = find_hardware_by_name(choice)
					if(!H)
						return
					uninstall_component(H, user)
					return
	..()

/obj/item/modular_computer/examine(var/mob/user)
	. = ..()

	if(enabled && .)
		to_chat(user, "The time [stationtime2text()] is displayed in the corner of the screen.")

	if(card_slot && card_slot.stored_card)
		to_chat(user, "The [card_slot.stored_card] is inserted into it.")

/obj/item/modular_computer/MouseDrop(atom/over_object)
	var/mob/M = usr
	if(!istype(over_object, /obj/screen) && can_interact(M))
		return attack_self(M)

	if((src.loc == M) && istype(over_object, /obj/screen/inventory/hand) && eject_item(cell, M))
		cell = null
		update_icon()

/obj/item/modular_computer/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(scanner)
		scanner.do_on_afterattack(user, target, proximity)

/obj/item/modular_computer/CtrlAltClick(mob/user)
	if(!CanPhysicallyInteract(user))
		return
	open_terminal(user)

// Attempts to install the hardware into apropriate slot.
/obj/item/modular_computer/proc/try_install_component(obj/item/H, mob/living/user)
	var/found = FALSE
	var/obj/item/computer_hardware/CH //if it's anything other than a battery, then we need to set its holder2 var whatever the fuck that is
	if(istype(H, /obj/item/computer_hardware))
		CH = H
		if(!(CH.usage_flags & hardware_flag))
			to_chat(user, SPAN_WARNING("This computer isn't compatible with [CH]."))
			return

	if(CH && CH.hardware_size > max_hardware_size)
		to_chat(user, SPAN_WARNING("This component is too large for \the [src]."))
		return

	// Data disk.
	if(istype(H, /obj/item/computer_hardware/hard_drive/portable))
		if(portable_drive)
			to_chat(user, SPAN_WARNING("This computer's portable drive slot is already occupied by \the [portable_drive]."))
			return
		found = TRUE
		portable_drive = H

	else if(istype(H, /obj/item/computer_hardware/led))
		if(led)
			to_chat(user, SPAN_WARNING("This computer's LED slot is already occupied by \the [led]."))
			return
		found = TRUE
		led = H
	else if(istype(H, /obj/item/computer_hardware/hard_drive))
		if(hard_drive)
			to_chat(user, SPAN_WARNING("This computer's hard drive slot is already occupied by \the [hard_drive]."))
			return
		found = TRUE
		hard_drive = H
	else if(istype(H, /obj/item/computer_hardware/network_card))
		if(network_card)
			to_chat(user, SPAN_WARNING("This computer's network card slot is already occupied by \the [network_card]."))
			return
		found = TRUE
		network_card = H
	else if(istype(H, /obj/item/computer_hardware/printer))
		if(printer)
			to_chat(user, SPAN_WARNING("This computer's printer slot is already occupied by \the [printer]."))
			return
		found = TRUE
		printer = H
	else if(istype(H, /obj/item/computer_hardware/card_slot))
		if(card_slot)
			to_chat(user, SPAN_WARNING("This computer's card slot is already occupied by \the [card_slot]."))
			return
		found = TRUE
		card_slot = H
	else if(istype(H, /obj/item/cell))
		if(cell)
			to_chat(user, SPAN_WARNING("This computer's battery slot is already occupied by \the [cell]."))
			return
		found = TRUE
		cell = H
	else if(istype(H, /obj/item/computer_hardware/processor_unit))
		if(processor_unit)
			to_chat(user, SPAN_WARNING("This computer's processor slot is already occupied by \the [processor_unit]."))
			return
		found = TRUE
		processor_unit = H
	else if(istype(H, /obj/item/computer_hardware/ai_slot))
		if(ai_slot)
			to_chat(user, SPAN_WARNING("This computer's intellicard slot is already occupied by \the [ai_slot]."))
			return
		found = TRUE
		ai_slot = H
	else if(istype(H, /obj/item/computer_hardware/tesla_link))
		if(tesla_link)
			to_chat(user, SPAN_WARNING("This computer's tesla link slot is already occupied by \the [tesla_link]."))
			return
		found = TRUE
		tesla_link = H
	else if(istype(H, /obj/item/computer_hardware/scanner))
		if(scanner)
			to_chat(user, SPAN_WARNING("This computer's scanner slot is already occupied by \the [scanner]."))
			return
		found = TRUE
		scanner = H
		scanner.do_after_install(user, src)
	else if(istype(H, /obj/item/computer_hardware/gps_sensor))
		if(gps_sensor)
			to_chat(user, SPAN_WARNING("This computer's gps slot is already occupied by \the [gps_sensor]."))
			return
		found = TRUE
		gps_sensor = H

	if(!found)
		return

	if(insert_item(H, user))
		if(CH)
			CH.holder2 = src
			if(CH.enabled)
				CH.enabled()
			if(istype(CH, /obj/item/computer_hardware/hard_drive) && enabled)
				autorun_program(portable_drive) // Autorun malware: now in SS13!
		update_verbs()

// Uninstalls component.
/obj/item/modular_computer/proc/uninstall_component(obj/item/H, mob/living/user)
	if(!(H in get_all_components()))
		return

	var/critical = FALSE
	var/obj/item/computer_hardware/to_remove //If a battery, don't try to delete the snowflake vars

	if(istype(H, /obj/item/computer_hardware))
		to_remove = H
		critical = to_remove.critical && to_remove.enabled

		if(to_remove.enabled)
			to_remove.disabled()

		to_remove.holder2 = null

	if(portable_drive == H)
		portable_drive = null
	else if(hard_drive == H)
		hard_drive = null
	else if(network_card == H)
		network_card = null
	else if(printer == H)
		printer = null
	else if(card_slot == H)
		card_slot = null
	else if(cell == H)
		cell = null
	else if(processor_unit == H)
		processor_unit = null
	else if(ai_slot == H)
		ai_slot = null
	else if(tesla_link == H)
		tesla_link = null
	else if(gps_sensor == H)
		gps_sensor = null
	else if(led == H)
		led = null
	else if(scanner == H)
		scanner.do_before_uninstall()
		scanner = null

	to_chat(user, SPAN_NOTICE("You remove \the [H] from \the [src]."))
	H.forceMove(drop_location())

	if(critical)
		to_chat(user, SPAN_DANGER("\The [src]'s screen freezes for a split second and flickers to black."))
		shutdown_computer()
	update_verbs()
	update_icon()


// Returns list of all components
/obj/item/modular_computer/proc/get_all_components()
	var/list/all_slots = list(
		hard_drive, processor_unit,
		network_card, portable_drive,
		printer, card_slot, cell,
		ai_slot, tesla_link, scanner,
		gps_sensor, led
		)

	var/list/all_components = list()
	for(var/slot in all_slots)
		if(!isnull(slot))
			all_components += slot

	return all_components

// Checks all hardware pieces to determine if name matches, if yes, returns the hardware piece, otherwise returns null
/obj/item/modular_computer/proc/find_hardware_by_name(name)
	for(var/c in get_all_components())
		var/obj/item/component = c
		if(component.name == name)
			return component
	return null

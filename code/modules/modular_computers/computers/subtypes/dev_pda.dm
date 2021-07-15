/obj/item/modular_computer/pda
	name = "PDA"
	desc = "A very compact computer, designed to keep its user always connected."
	icon = 'icons/obj/modular_pda.dmi'
	icon_state = "pda"
	matter = list(MATERIAL_STEEL = 3, MATERIAL_GLASS = 1)
	hardware_flag = PROGRAM_PDA
	max_hardware_size = 1
	w_class = ITEM_SIZE_SMALL
	screen_light_strength = 1.1
	screen_light_range = 2
	slot_flags = SLOT_ID | SLOT_BELT
	stores_pen = TRUE
	stored_pen = /obj/item/pen
	price_tag = 50
	suitable_cell = /obj/item/cell/small //We take small battery

	var/scanner_type = null
	var/tesla_link_type = null
	var/hard_drive_type = /obj/item/computer_hardware/hard_drive/small
	var/processor_unit_type = /obj/item/computer_hardware/processor_unit/small
	var/network_card_type = /obj/item/computer_hardware/network_card

/obj/item/modular_computer/pda/Initialize()
	. = ..()
	enable_computer()

/obj/item/modular_computer/pda/AltClick(var/mob/user)
	if(!CanPhysicallyInteract(user))
		return
	if(card_slot && istype(card_slot.stored_card))
		eject_id()
	else
		..()

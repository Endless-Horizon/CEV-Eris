/obj/item/computer_hardware/card_slot
	name = "ID card slot"
	desc = "Slot that allows this computer to read and write data on ID cards. Necessary for some programs to run properly."
	power_usage = 10 //W
	icon_state = "cardreader"
	hardware_size = 1
	origin_tech = list(TECH_DATA = 2)
	usage_flags = PROGRAM_ALL
	rarity_value = 5.55
	var/obj/item/card/id/stored_card

/obj/item/computer_hardware/card_slot/Destroy()
	if(stored_card)
		stored_card.forceMove(drop_location())
		stored_card = null
	return ..()
/obj/item/modular_computer/pda/install_default_hardware()
	..()
	network_card = new network_card_type(src)
	hard_drive = new hard_drive_type(src)
	processor_unit = new processor_unit_type(src)
	card_slot = new /obj/item/computer_hardware/card_slot(src)
	cell = new /obj/item/cell/small/moebius/pda(src)
	gps_sensor= new /obj/item/computer_hardware/gps_sensor(src)
	led = new /obj/item/computer_hardware/led(src)
	if(scanner_type)
		scanner = new scanner_type(src)
	if(tesla_link_type)
		tesla_link = new tesla_link_type(src)


/obj/item/modular_computer/pda/install_default_programs()
	..()

	hard_drive.store_file(new /datum/computer_file/program/chatclient())
	hard_drive.store_file(new /datum/computer_file/program/email_client())
	hard_drive.store_file(new /datum/computer_file/program/crew_manifest())
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor())
	hard_drive.store_file(new /datum/computer_file/program/records())
	hard_drive.store_file(new /datum/computer_file/program/bounty_board_app())
	if(prob(50)) //harmless tax software
		hard_drive.store_file(new /datum/computer_file/program/uplink())

// PDA types

/obj/item/modular_computer/pda/engineering
	icon_state = "pda-e"
	scanner_type = /obj/item/computer_hardware/scanner/atmos

/obj/item/modular_computer/pda/security
	icon_state = "pda-s"

/obj/item/modular_computer/pda/forensics
	icon_state = "pda-s"
	scanner_type = /obj/item/computer_hardware/scanner/reagent


/obj/item/modular_computer/pda/moebius
	hard_drive_type = /obj/item/computer_hardware/hard_drive/small/adv

/obj/item/modular_computer/pda/moebius/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/signaller)
	hard_drive.store_file(new /datum/computer_file/program/chem_catalog)

/obj/item/modular_computer/pda/moebius/science
	icon_state = "pda-nt"
	scanner_type = /obj/item/computer_hardware/scanner/reagent

/obj/item/modular_computer/pda/moebius/medical
	icon_state = "pda-m"
	scanner_type = /obj/item/computer_hardware/scanner/medical

/obj/item/modular_computer/pda/moebius/chemistry
	icon_state = "pda-m"
	scanner_type = /obj/item/computer_hardware/scanner/reagent

/obj/item/modular_computer/pda/moebius/roboticist
	icon_state = "pda-robot"


/obj/item/modular_computer/pda/church
	icon_state = "pda-neo"


/obj/item/modular_computer/pda/heads
	name = "command PDA"
	icon_state = "pda-h"
	hard_drive_type = /obj/item/computer_hardware/hard_drive/small/adv
	processor_unit_type = /obj/item/computer_hardware/processor_unit/adv/small
	network_card_type = /obj/item/computer_hardware/network_card/advanced
	tesla_link_type = /obj/item/computer_hardware/tesla_link
	scanner_type = /obj/item/computer_hardware/scanner/paper

/obj/item/modular_computer/pda/heads/hop
	icon_state = "pda-hop"
	scanner_type = /obj/item/computer_hardware/scanner/paper

/obj/item/modular_computer/pda/heads/hos
	icon_state = "pda-hos"
	scanner_type = /obj/item/computer_hardware/scanner/paper

/obj/item/modular_computer/pda/heads/ce
	icon_state = "pda-ce"
	scanner_type = /obj/item/computer_hardware/scanner/atmos

/obj/item/modular_computer/pda/heads/cmo
	icon_state = "pda-cmo"
	scanner_type = /obj/item/computer_hardware/scanner/medical

/obj/item/modular_computer/pda/heads/cmo/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/chem_catalog())

/obj/item/modular_computer/pda/heads/rd
	icon_state = "pda-rd"
	scanner_type = /obj/item/computer_hardware/scanner/reagent

/obj/item/modular_computer/pda/captain
	icon_state = "pda-c"
	hard_drive_type = /obj/item/computer_hardware/hard_drive/small/adv
	processor_unit_type = /obj/item/computer_hardware/processor_unit/adv/small
	network_card_type = /obj/item/computer_hardware/network_card/advanced
	tesla_link_type = /obj/item/computer_hardware/tesla_link
	scanner_type = /obj/item/computer_hardware/scanner/paper

/obj/item/modular_computer/pda/ert
	icon_state = "pda-h"
	hard_drive_type = /obj/item/computer_hardware/hard_drive/small/adv
	processor_unit_type = /obj/item/computer_hardware/processor_unit/adv/small
	network_card_type = /obj/item/computer_hardware/network_card/advanced
	tesla_link_type = /obj/item/computer_hardware/tesla_link

/obj/item/modular_computer/pda/cargo
	icon_state = "pda-sup"
	scanner_type = /obj/item/computer_hardware/scanner/price

/obj/item/modular_computer/pda/syndicate
	icon_state = "pda-syn"
	hard_drive_type = /obj/item/computer_hardware/hard_drive/small/adv
	processor_unit_type = /obj/item/computer_hardware/processor_unit/adv/small
	network_card_type = /obj/item/computer_hardware/network_card/advanced
	tesla_link_type = /obj/item/computer_hardware/tesla_link

/obj/item/modular_computer/pda/club_worker
	icon_state = "pda-club"

/obj/item/modular_computer/pda/club_worker/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/drink_catalog())


// PDA box
/obj/item/storage/box/PDAs
	name = "box of spare PDAs"
	desc = "A box of spare PDA microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdabox"

/obj/item/storage/box/PDAs/populate_contents()
	new /obj/item/modular_computer/pda(src)
	new /obj/item/modular_computer/pda(src)
	new /obj/item/modular_computer/pda(src)
	new /obj/item/modular_computer/pda(src)
	new /obj/item/modular_computer/pda(src)

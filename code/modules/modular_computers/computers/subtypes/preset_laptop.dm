//Loadout presets

/obj/item/modular_computer/laptop/preset/custom_loadout/cheap/install_default_hardware()
	..()
	processor_unit = new/obj/item/computer_hardware/processor_unit/small(src)
	hard_drive = new/obj/item/computer_hardware/hard_drive(src)
	network_card = new/obj/item/computer_hardware/network_card(src)
	printer = new/obj/item/computer_hardware/printer(src)
	card_slot = new/obj/item/computer_hardware/card_slot(src)

/obj/item/modular_computer/laptop/preset/custom_loadout/standard/install_default_hardware()
	..()
	processor_unit = new/obj/item/computer_hardware/processor_unit(src)
	hard_drive = new/obj/item/computer_hardware/hard_drive(src)
	network_card = new/obj/item/computer_hardware/network_card(src)
	printer = new/obj/item/computer_hardware/printer(src)
	card_slot = new/obj/item/computer_hardware/card_slot(src)

/obj/item/modular_computer/laptop/preset/custom_loadout/advanced/install_default_hardware()
	..()
	processor_unit = new/obj/item/computer_hardware/processor_unit(src)
	tesla_link = new/obj/item/computer_hardware/tesla_link(src) //Only the advanced laptop gets a tesla link
	hard_drive = new/obj/item/computer_hardware/hard_drive/advanced(src)
	network_card = new/obj/item/computer_hardware/network_card/advanced(src)
	printer = new/obj/item/computer_hardware/printer(src)
	card_slot = new/obj/item/computer_hardware/card_slot(src)

/obj/item/modular_computer/laptop/preset/custom_loadout/install_default_programs()
	..()
	hard_drive.store_file(new/datum/computer_file/program/email_client())
	hard_drive.store_file(new/datum/computer_file/program/chatclient())
	hard_drive.store_file(new/datum/computer_file/program/wordprocessor())
	hard_drive.store_file(new/datum/computer_file/program/newsbrowser())
	install_default_programs_by_job(get(src, /mob/living/carbon/human))

//Map presets
/obj/item/modular_computer/laptop/preset/records/install_default_hardware()
	..()
	processor_unit = new/obj/item/computer_hardware/processor_unit/small(src)
	tesla_link = new/obj/item/computer_hardware/tesla_link(src)
	hard_drive = new/obj/item/computer_hardware/hard_drive/(src)
	network_card = new/obj/item/computer_hardware/network_card/(src)
	printer = new/obj/item/computer_hardware/printer(src)
	scanner = new /obj/item/computer_hardware/scanner/paper(src)

/obj/item/modular_computer/laptop/preset/records/install_default_programs()
	..()
	hard_drive.store_file(new/datum/computer_file/program/email_client())
	hard_drive.store_file(new/datum/computer_file/program/chatclient())
	hard_drive.store_file(new/datum/computer_file/program/wordprocessor())
	hard_drive.store_file(new/datum/computer_file/program/newsbrowser())
	hard_drive.store_file(new/datum/computer_file/program/records())

//Atmos
/obj/item/modular_computer/laptop/preset/atmos/install_default_hardware()
	..()
	processor_unit = new/obj/item/computer_hardware/processor_unit/small(src)
	tesla_link = new/obj/item/computer_hardware/tesla_link(src)
	hard_drive = new/obj/item/computer_hardware/hard_drive/(src)
	network_card = new/obj/item/computer_hardware/network_card/(src)

/obj/item/modular_computer/laptop/preset/atmos/install_default_programs()
	..()
	hard_drive.store_file(new/datum/computer_file/program/email_client())
	hard_drive.store_file(new/datum/computer_file/program/chatclient())
	hard_drive.store_file(new/datum/computer_file/program/newsbrowser())
	hard_drive.store_file(new/datum/computer_file/program/alarm_monitor())
	hard_drive.store_file(new/datum/computer_file/program/atmos_control())


//debug
/obj/item/modular_computer/laptop/preset/debug/install_default_hardware()
	..()
	printer = new/obj/item/computer_hardware/printer(src)
	processor_unit = new/obj/item/computer_hardware/processor_unit/super/small(src)
	tesla_link = new/obj/item/computer_hardware/tesla_link(src)
	hard_drive = new/obj/item/computer_hardware/hard_drive/cluster(src)
	network_card = new/obj/item/computer_hardware/network_card/advanced(src)
	scanner = new /obj/item/computer_hardware/scanner/paper(src)
	card_slot = new/obj/item/computer_hardware/card_slot(src)

/obj/item/modular_computer/laptop/preset/debug/install_default_programs()
	..()
	hard_drive.store_file(new/datum/computer_file/program/ntnetmonitor())
	hard_drive.store_file(new/datum/computer_file/program/nttransfer())
	hard_drive.store_file(new/datum/computer_file/program/chatclient())
	hard_drive.store_file(new/datum/computer_file/program/camera_monitor())
	//hard_drive.store_file(new/datum/computer_file/program/aidiag())
	hard_drive.store_file(new/datum/computer_file/program/email_client())
	hard_drive.store_file(new/datum/computer_file/program/email_administration())
	hard_drive.store_file(new/datum/computer_file/program/wordprocessor())
	hard_drive.store_file(new/datum/computer_file/program/library())
	hard_drive.store_file(new/datum/computer_file/program/camera_monitor/hacked())
	hard_drive.store_file(new/datum/computer_file/program/records())
	hard_drive.store_file(new/datum/computer_file/program/comm())
	hard_drive.store_file(new/datum/computer_file/program/digitalwarrant())
	hard_drive.store_file(new/datum/computer_file/program/suit_sensors())
	hard_drive.store_file(new/datum/computer_file/program/power_monitor())
	hard_drive.store_file(new/datum/computer_file/program/supermatter_monitor())
	hard_drive.store_file(new/datum/computer_file/program/alarm_monitor())
	hard_drive.store_file(new/datum/computer_file/program/atmos_control())
	hard_drive.store_file(new/datum/computer_file/program/rcon_console())
	hard_drive.store_file(new/datum/computer_file/program/access_decrypter())
	hard_drive.store_file(new/datum/computer_file/program/ntnet_dos())
	hard_drive.store_file(new/datum/computer_file/program/revelation())
	hard_drive.store_file(new/datum/computer_file/program/uplink())
	hard_drive.store_file(new/datum/computer_file/program/card_mod())
	hard_drive.store_file(new/datum/computer_file/program/shield_control())
	hard_drive.store_file(new/datum/computer_file/program/newsbrowser())
	hard_drive.store_file(new/datum/computer_file/program/crew_manifest())
	hard_drive.store_file(new/datum/computer_file/program/game())
	hard_drive.store_file(new/datum/computer_file/program/reports())
	hard_drive.store_file(new/datum/computer_file/program/bounty_board_app())
	hard_drive.store_file(new/datum/computer_file/program/chem_catalog())

/obj/item/modular_computer/laptop/preset/custom_loadout/cheap/elbrus4kk
	name = "elbrus4kk laptop"
	desc = "A portable clamshell computer made by \"Institute of Computer Engineering\" company. This one is advertized as tougher than other models on the market."
	icon_state = "elbrus4kk"

/obj/item/modular_computer/laptop/preset/custom_loadout/standard/xenoware
	name = "xenoware laptop"
	desc = "A portable clamshell computer made by \"Xenoware\". You will feel like a real hacker with those lights."
	icon_state = "xenoware"

/obj/item/modular_computer/laptop/preset/custom_loadout/advanced/golden
	name = "golden laptop"
	desc = "A portable clamshell computer with \"Kitaro Scientific\" label on the back."
	icon_state = "golden"
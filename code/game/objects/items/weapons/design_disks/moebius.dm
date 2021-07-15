// Moebius
/obj/item/computer_hardware/hard_drive/portable/design/medical
	disk_name = "Moebius Medical Designs"
	icon_state = "moebius"
	rarity_value = 4.5
	spawn_tags = SPAWN_TAG_DESIGN_COMMON
	license = 20
	designs = list(
		/datum/design/autolathe/gun/syringe_gun,
		/datum/design/autolathe/misc/penflashlight,
		/datum/design/autolathe/tool/scalpel,
		/datum/design/autolathe/tool/circularsaw,
		/datum/design/autolathe/tool/surgicaldrill,
		/datum/design/autolathe/tool/retractor,
		/datum/design/autolathe/tool/cautery,
		/datum/design/autolathe/tool/hemostat,
		/datum/design/autolathe/tool/bonesetter,
		/datum/design/autolathe/container/syringe,
		/datum/design/autolathe/container/vial,
		/datum/design/autolathe/container/beaker,
		/datum/design/autolathe/container/beaker_large,
		/datum/design/autolathe/container/pill_bottle,
		/datum/design/autolathe/container/spray,
		/datum/design/autolathe/container/freezer_medical,
		/datum/design/autolathe/device/implanter,
		/datum/design/autolathe/container/syringegun_ammo,
		/datum/design/autolathe/container/syringe/large,

	)

/obj/item/computer_hardware/hard_drive/portable/design/surgery
	disk_name = "Back Alley Organs"
	icon_state = "moebius"
	license = 5
	designs = list(
		/datum/design/bioprinter/lungs
	)

/obj/item/computer_hardware/hard_drive/portable/design/computer
	disk_name = "Moebius Computer Parts"
	icon_state = "moebius"
	spawn_tags = SPAWN_TAG_DESIGN_COMMON
	rarity_value = 4.5
	license = 20
	designs = list(
		/datum/design/autolathe/computer_part/frame_pda,
		/datum/design/autolathe/computer_part/frame_tablet,
		/datum/design/autolathe/computer_part/frame_laptop,
		/datum/design/research/item/computer_part/disk/micro,
		/datum/design/research/item/computer_part/disk/small,
		/datum/design/research/item/computer_part/disk/normal,
		/datum/design/research/item/computer_part/disk/advanced,
		/datum/design/research/item/computer_part/cpu/basic,
		/datum/design/research/item/computer_part/cpu/basic/small,
		/datum/design/research/item/computer_part/cpu/adv,
		/datum/design/research/item/computer_part/cpu/adv/small,
		/datum/design/research/item/computer_part/netcard/basic,
		/datum/design/research/item/computer_part/netcard/advanced,
		/datum/design/research/item/computer_part/netcard/wired,
		/datum/design/research/item/computer_part/cardslot,
		/datum/design/research/item/computer_part/teslalink,
		/datum/design/research/item/computer_part/portabledrive/basic,
		/datum/design/research/item/computer_part/portabledrive/normal,
		/datum/design/research/item/computer_part/printer,
		/datum/design/research/item/computer_part/led,
		/datum/design/research/item/computer_part/led/adv,
		/datum/design/autolathe/computer_part/gps,
		/datum/design/autolathe/computer_part/scanner/paper,
		/datum/design/autolathe/computer_part/scanner/atmos,
		/datum/design/autolathe/computer_part/scanner/reagent,
		/datum/design/autolathe/computer_part/scanner/medical,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/ms_dartgun
	disk_name = "Moebius Scientifica - Z-H P Artemis Dartgun"
	icon_state = "moebius"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 50
	license = 12
	designs = list(
		/datum/design/autolathe/gun/dart_gun = 3, // Z-H P Artemis"
		/datum/design/autolathe/ammo/dart_mag,
	)

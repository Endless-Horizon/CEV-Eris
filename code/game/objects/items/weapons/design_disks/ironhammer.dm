// Ironhammer
/obj/item/computer_hardware/hard_drive/portable/design/security
	disk_name = "Ironhammer Miscellaneous Pack"
	icon_state = "ironhammer"
	rarity_value = 5
	license = 20
	designs = list(
		/datum/design/autolathe/sec/secflashlight,
		/datum/design/research/item/flash,
		/datum/design/autolathe/sec/handcuffs,
		/datum/design/autolathe/sec/zipties,
		/datum/design/autolathe/sec/electropack,
		/datum/design/autolathe/misc/taperecorder,
		/datum/design/autolathe/tool/tacknife,
		/datum/design/autolathe/sec/beartrap,
		/datum/design/autolathe/sec/silencer,
		/datum/design/autolathe/sec/hailer
	)

/obj/item/computer_hardware/hard_drive/portable/design/armor/generic
	disk_name = "Ironhammer Combat Equipment - Standard Armor"
	icon_state = "ironhammer"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED_COMMON
	rarity_value = 12 // one of the more common advanced disks
	license = 6 // 6 pieces, or 3 sets if you use helm + vest
	designs = list(
		/datum/design/autolathe/clothing/generic_helmet_basic,
		/datum/design/autolathe/clothing/generic_vest,
		/datum/design/autolathe/clothing/generic_vest_full = 2
	)

/obj/item/computer_hardware/hard_drive/portable/design/armor/generic/bulletproof
	disk_name = "Ironhammer Combat Equipment - Bulletproof Armor"
	icon_state = "ironhammer"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED_COMMON
	rarity_value = 15 // about as rare as a advanced tool disk - remember that this takes from the 'advanced' pool (which is rare) instead of the 'common' pool like the normal armor disk does
	license = 4 // 4 pieces, or 2 sets
	designs = list(
		/datum/design/autolathe/clothing/bulletproof_helmet_generic,
		/datum/design/autolathe/clothing/bulletproof_vest_generic,
		/datum/design/autolathe/clothing/bulletproof_vest_generic_full = 2
	)

/obj/item/computer_hardware/hard_drive/portable/design/armor/generic/ablative
	disk_name = "Ironhammer Combat Equipment - Laserproof Armor"
	icon_state = "ironhammer"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED_COMMON
	rarity_value = 16 // slightly rarer than bulletproof gear
	license = 4 // 4 pieces, or 2 sets
	designs = list(
		/datum/design/autolathe/clothing/ablative_vest_full,
		/datum/design/autolathe/clothing/ablative_helmet
	)

/obj/item/computer_hardware/hard_drive/portable/design/armor/ih
	disk_name = "Ironhammer Combat Equipment - Operator Armor"
	icon_state = "ironhammer"
	spawn_blacklisted = TRUE //should only be obtainable from the sectech
	license = 6
	designs = list(
		/datum/design/autolathe/clothing/ih_helmet_basic,
		/datum/design/autolathe/clothing/ih_vest_basic,
		/datum/design/autolathe/clothing/ih_vest_basic_full = 2
	)

/obj/item/computer_hardware/hard_drive/portable/design/armor/ih/bulletproof
	disk_name = "Ironhammer Combat Equipment - Bulletproof Operator Armor"
	icon_state = "ironhammer"
	spawn_blacklisted = TRUE
	license = 4
	designs = list(
		/datum/design/autolathe/clothing/ih_helmet_full,
		/datum/design/autolathe/clothing/ih_vest_full
	)


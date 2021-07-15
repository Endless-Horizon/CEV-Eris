// NeoTheology

// Foodstuffs, fertilizers, medical and cleaning utilities
/obj/item/computer_hardware/hard_drive/portable/design/nt_bioprinter
	disk_name = "NeoTheology Bioprinter Products and Utilities"
	icon_state = "neotheology"

	license = -1
	designs = list(
		/datum/design/bioprinter/meat,
		/datum/design/bioprinter/milk,
		/datum/design/bioprinter/soap,

		/datum/design/bioprinter/ez,
		/datum/design/bioprinter/l4z,
		/datum/design/bioprinter/rh,

		/datum/design/bioprinter/medical/bruise,
		/datum/design/bioprinter/medical/splints,
		/datum/design/bioprinter/medical/ointment,
		/datum/design/bioprinter/medical/advanced/bruise,
		/datum/design/bioprinter/medical/advanced/ointment,

		/datum/design/autolathe/gun/nt_sprayer,
		/datum/design/autolathe/device/grenade/nt_cleaner,
		/datum/design/autolathe/device/grenade/nt_weedkiller,

		/datum/design/bioprinter/holyvacuum

	)

// Clothes, armor and accesories
/obj/item/computer_hardware/hard_drive/portable/design/nt_bioprinter_clothes
	disk_name = "NeoTheology Bio-Fabric Designs"
	icon_state = "neotheology"

	license = -1
	designs = list(
		/datum/design/bioprinter/nt_clothes/acolyte_armor,
		/datum/design/bioprinter/nt_clothes/agrolyte_armor,
		/datum/design/bioprinter/nt_clothes/custodian_armor,

		/datum/design/bioprinter/nt_clothes/acolyte_armor_head,
		/datum/design/bioprinter/nt_clothes/agrolyte_armor_head,
		/datum/design/bioprinter/nt_clothes/custodian_armor_head,

		/datum/design/bioprinter/nt_clothes/preacher_coat,
		/datum/design/bioprinter/nt_clothes/acolyte_jacket,
		/datum/design/bioprinter/nt_clothes/sports_jacket,

		/datum/design/bioprinter/nt_clothes/acolyte_uniform,
		/datum/design/bioprinter/nt_clothes/sports_uniform,
		/datum/design/bioprinter/nt_clothes/church_uniform,

		/datum/design/bioprinter/belt/security/neotheology,
		/datum/design/bioprinter/belt/utility/neotheology,

		/datum/design/bioprinter/satchel,
		/datum/design/bioprinter/leather_jacket,
		/datum/design/bioprinter/wallet,
		/datum/design/bioprinter/botanic_leather,

		/datum/design/bioprinter/belt/utility,
		/datum/design/bioprinter/belt/medical,
		/datum/design/bioprinter/belt/security,
		/datum/design/bioprinter/belt/medical/emt,
		/datum/design/bioprinter/belt/misc/champion,

		/datum/design/bioprinter/leather/holster,
		/datum/design/bioprinter/leather/holster/armpit,
		/datum/design/bioprinter/leather/holster/waist,
		/datum/design/bioprinter/leather/holster/hip,

		/datum/design/bioprinter/small_generic,
		/datum/design/bioprinter/medium_generic,
		/datum/design/bioprinter/large_generic,
		/datum/design/bioprinter/medical_supply,
		/datum/design/bioprinter/engineering_tools,
		/datum/design/bioprinter/engineering_supply,
		/datum/design/bioprinter/ammo,
		/datum/design/bioprinter/tubular,
		/datum/design/bioprinter/tubular/vial,
		/datum/design/bioprinter/part,

   		/datum/design/autolathe/device/headset_church,
		/datum/design/bioprinter/leather/cash_bag
	)

// Kinda like the regular product NT disk, minus the grenades, soap and the cleaner carbine. Should spawn in public access bioprinters if they get added by any chance.
/obj/item/computer_hardware/hard_drive/portable/design/nt_bioprinter_public
	disk_name = "NeoTheology Bioprinter Pack"
	icon_state = "neotheology"

	license = -1
	designs = list(
		/datum/design/bioprinter/meat,
		/datum/design/bioprinter/milk,

		/datum/design/bioprinter/ez,
		/datum/design/bioprinter/l4z,
		/datum/design/bioprinter/rh,

		/datum/design/bioprinter/wallet,
		/datum/design/bioprinter/botanic_leather,
		/datum/design/bioprinter/satchel,
		/datum/design/bioprinter/leather_jacket,
		/datum/design/bioprinter/leather/cash_bag,
		/datum/design/bioprinter/belt/utility,
		/datum/design/bioprinter/belt/utility/neotheology,
		/datum/design/bioprinter/belt/medical,
		/datum/design/bioprinter/belt/security,
		/datum/design/bioprinter/belt/security/neotheology,
		/datum/design/bioprinter/belt/medical/emt,
		/datum/design/bioprinter/belt/misc/champion,

		/datum/design/bioprinter/leather/holster,
		/datum/design/bioprinter/leather/holster/armpit,
		/datum/design/bioprinter/leather/holster/waist,
		/datum/design/bioprinter/leather/holster/hip,

		/datum/design/autolathe/device/headset_church
	)

/obj/item/computer_hardware/hard_drive/portable/design/nt/crusader
	disk_name = "NeoTheology Armory - Neotheology Armor and Voidsuits"
	icon_state = "neotheology"
	designs = list(
		/datum/design/autolathe/nt/helmet/crusader,
		/datum/design/autolathe/nt/armor/crusader,
		/datum/design/autolathe/clothing/NTvoid
	)
/obj/item/computer_hardware/hard_drive/portable/design/nt/excruciator
	disk_name = "NeoTheology Armory - NT \"EXCRUCIATOR\" giga lens"
	icon_state = "neotheology"
	designs = list(
		/datum/design/autolathe/excruciator
	)

/obj/item/computer_hardware/hard_drive/portable/design/nt
	disk_name = "NeoTheology Armory - Blank"
	rarity_value = 50
	license = -1
	spawn_blacklisted = TRUE
	price_tag = 1000
	bad_type = /obj/item/computer_hardware/hard_drive/portable/design/nt

/obj/item/computer_hardware/hard_drive/portable/design/nt/melee
	disk_name = "NeoTheology Armory - Basic Melee Weapons"
	icon_state = "neotheology"
	designs = list(
		/datum/design/autolathe/nt/sword/nt_sword,
		/datum/design/autolathe/nt/sword/nt_dagger,
		/datum/design/bioprinter/storage/sheath,
		/datum/design/autolathe/nt/tool_upgrade/sanctifier
	)

/obj/item/computer_hardware/hard_drive/portable/design/nt/advancedmelee
	disk_name = "NeoTheology Armory - Advanced Melee Weapons"
	icon_state = "neotheology"
	designs = list(
		/datum/design/bioprinter/storage/sheath,
		/datum/design/autolathe/nt/tool_upgrade/sanctifier,
		/datum/design/autolathe/nt/sword/nt_longsword,
		/datum/design/autolathe/nt/sword/nt_scourge,
		/datum/design/autolathe/nt/sword/nt_halberd,
		/datum/design/autolathe/nt/shield/nt_shield
	)

/obj/item/computer_hardware/hard_drive/portable/design/nt/firstaid
	disk_name = "NeoTheology Armory - NeoTheologian Medkit"
	icon_state = "neotheology"
	designs = list(
		/datum/design/autolathe/firstaid/nt
	)

/obj/item/computer_hardware/hard_drive/portable/design/nt/guns/nt_dominion
	disk_name = "NeoTheology Armory - Dominion Plasma Rifle"
	icon_state = "neotheology"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 50
	license = 12
	spawn_blacklisted = FALSE
	designs = list(
		/datum/design/autolathe/gun/plasma/dominion = 3, //"NT PR \"Dominion\""
		/datum/design/autolathe/cell/medium/high,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/nt_purger
	disk_name = "NeoTheology Armory - Purger Plasma Rifle"
	icon_state = "neotheology"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 50
	license = 12
	designs = list(
		/datum/design/autolathe/gun/plasma/destroyer = 3, // "NT PR \"Purger\""
		/datum/design/autolathe/cell/medium/high,
	)

/obj/item/computer_hardware/hard_drive/portable/design/nt/grenades
	disk_name = "NeoTheology Armory - Grenades Pack"
	icon_state = "neotheology"
	designs = list(
		/datum/design/autolathe/nt/grenade/nt_flashbang,
		/datum/design/autolathe/nt/grenade/nt_frag,
		/datum/design/autolathe/nt/grenade/nt_smokebomb
	)

/obj/item/computer_hardware/hard_drive/portable/design/nt/explosivegrenades
	disk_name = "NeoTheology Armory - High Explosives Pack"
	icon_state = "neotheology"
	license = 2
	designs = list(
		/datum/design/autolathe/nt/grenade/nt_explosive
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/nt_nemesis
	disk_name = "NeoTheology Armory - Nemesis Energy Crossbow"
	icon_state = "neotheology"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 50
	license = 12
	designs = list(
		/datum/design/autolathe/gun/energy_crossbow = 3, // "NT EC \"Nemesis\"" - self charging, no cell needed
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/nt_themis
	disk_name = "NeoTheology Armory - Themis Energy Crossbow"
	icon_state = "neotheology"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	license = 12
	designs = list(
		/datum/design/autolathe/gun/large_energy_crossbow = 3, // "NT EC \"Themis\"" - self charging, no cell needed
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/nt_lightfall
	disk_name = "NeoTheology Armory - Lightfall Laser Gun"
	icon_state = "neotheology"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	license = 12
	designs = list(
		/datum/design/autolathe/gun/laser = 3, // "NT LG \"Lightfall\""
		/datum/design/autolathe/cell/medium/high,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/nt_valkirye
	disk_name = "NeoTheology Armory - Valkyrie Energy Rifle"
	icon_state = "neotheology"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 50
	license = 12
	designs = list(
		/datum/design/autolathe/gun/sniperrifle = 3, //"NT MER \"Valkyrie\""
		/datum/design/autolathe/cell/medium/high,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/nt_halicon
	disk_name = "NeoTheology Armory - Halicon Ion Rifle"
	icon_state = "neotheology"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 33.33
	license = 12
	designs = list(
		/datum/design/autolathe/gun/ionrifle = 3, // "NT IR \"Halicon\""
		/datum/design/autolathe/cell/medium/high,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/nt/nt_counselor
	disk_name = "NeoTheology Armory - Councelor PDW E"
	icon_state = "neotheology"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 17
	license = 12
	spawn_blacklisted = FALSE
	designs = list(
		/datum/design/autolathe/gun/taser = 3, // "NT SP \"Counselor\""
		/datum/design/autolathe/cell/medium/high
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/nt_svalinn
	disk_name = "NeoTheology Armory - NT LP \"Svalinn\""
	icon_state = "neotheology"

	license = 12
	designs = list(
		/datum/design/autolathe/gun/nt_svalinn = 3,
		/datum/design/autolathe/cell/small/high,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/nt_protector
	disk_name = "NeoTheology Armory - Protector Grenade Launcher"
	icon_state = "neotheology"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 90
	license = 15
	designs = list(
		/datum/design/autolathe/gun/grenade_launcher = 3, // "NT GL \"Protector\""
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/nt_heavysniper
	disk_name = "NeoTheology Armory - .60 Penetrator AMR"
	icon_state = "neotheology"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 90
	license = 12
	designs = list(
		/datum/design/autolathe/gun/heavysniper = 3, // "NT AMR .60 \"Penetrator\""
		/datum/design/autolathe/ammo/antim,
		/datum/design/autolathe/ammo/box_antim,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/nt_mk58
	disk_name = "NeoTheology Armory - .35 MK58 Handgun Pack"
	icon_state = "neotheology"
	rarity_value = 9
	license = 12
	designs = list(
		/datum/design/autolathe/gun/mk58 = 3,
		/datum/design/autolathe/gun/mk58_wood = 3,
		/datum/design/autolathe/ammo/magazine_pistol,
		/datum/design/autolathe/ammo/magazine_pistol/practice = 0,
		/datum/design/autolathe/ammo/magazine_pistol/rubber,
	)


/obj/item/computer_hardware/hard_drive/portable/design/guns/nt_regulator
	disk_name = "NeoTheology Armory - .50 Regulator Shotgun"
	icon_state = "neotheology"
	rarity_value = 17
	license = 12
	designs = list(
		/datum/design/autolathe/gun/regulator = 3, // "NT SG \"Regulator 1000\""
		/datum/design/autolathe/ammo/shotgun_pellet,
		/datum/design/autolathe/ammo/shotgun,
		/datum/design/autolathe/ammo/shotgun_beanbag,
		/datum/design/autolathe/ammo/shotgun_blanks,
		/datum/design/autolathe/ammo/shotgun_flash,
		)

/obj/item/computer_hardware/hard_drive/portable/design/nt/cruciform_upgrade
	disk_name = "NeoTheology Armory - Cruciform Upgrades"
	icon_state = "neotheology"

/obj/item/computer_hardware/hard_drive/portable/design/nt/cruciform_upgrade/New()
	designs = subtypesof(/datum/design/autolathe/cruciform_upgrade)
	..()

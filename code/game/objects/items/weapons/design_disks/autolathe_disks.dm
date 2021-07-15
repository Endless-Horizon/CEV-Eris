//Serb

/obj/item/computer_hardware/hard_drive/portable/design/guns/sa_zoric
	disk_name = "Serbian Arms - .40 Zoric SMG"
	icon_state = "serbian"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	license = 12
	designs = list(
		/datum/design/autolathe/gun/zoric = 3, // "SA SMG .40 \"Zoric\""
		/datum/design/autolathe/ammo/msmg,
		/datum/design/autolathe/ammo/msmg/practice = 0,
		/datum/design/autolathe/ammo/msmg/rubber,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/sa_boltgun
	disk_name = "Serbian Arms - .30  Novakovic Rifle"
	icon_state = "serbian"
	rarity_value = 5.5
	license = 12
	designs = list(
		/datum/design/autolathe/gun/boltgun_serbian = 3, // "SA BR .30 \"Novakovic\""
		/datum/design/autolathe/ammo/sl_lrifle,
		/datum/design/autolathe/ammo/lrifle_ammobox_small,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/sa_pk
	disk_name = "Serbian Arms - .30 Pulemyot Kalashnikova MG"
	icon_state = "serbian"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 90
	license = 12
	designs = list(
		/datum/design/autolathe/gun/mg_pk = 3, // "SA MG .30 \"Pulemyot Kalashnikova\""
		/datum/design/autolathe/ammo/lrifle_pk,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/sa_ak
	disk_name = "Serbian Arms - .30 Krinkov Car"
	icon_state = "serbian"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 50
	license = 12
	designs = list(
		/datum/design/autolathe/gun/ak47_sa = 3, // "SA Car .30 \"Krinkov\""
		/datum/design/autolathe/ammo/lrifle,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/sa_br
	disk_name = "Serbian Arms - .20 Kovacs"
	icon_state = "serbian"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 80
	license = 12
	designs = list(
		/datum/design/autolathe/gun/kovacs = 3, // "SA BR .20 \"Kovacs\""
		/datum/design/autolathe/ammo/srifle
	)

//The Dallas
/obj/item/computer_hardware/hard_drive/portable/design/guns/dallas
	disk_name = "PAR - .25 Dallas"
	icon_state = "black"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 90
	license = 12
	designs = list(
		/datum/design/autolathe/gun/dallas = 3, // "PAR .25 CS \"Dallas\""
		/datum/design/autolathe/ammo/c10x24,
	)

//The Cog
/obj/item/computer_hardware/hard_drive/portable/design/guns/retro
	disk_name = "OS LG \"Cog\""
	icon_state = "onestar"
	rarity_value = 5.5
	license = 12
	designs = list(
		/datum/design/autolathe/gun/retro = 3, //"OS LG \"Cog\""
		/datum/design/autolathe/cell/medium/high,
	)

// ARMOR
/obj/item/computer_hardware/hard_drive/portable/design/armor
	bad_type = /obj/item/computer_hardware/hard_drive/portable/design/armor

/obj/item/computer_hardware/hard_drive/portable/design/guns
	bad_type = /obj/item/computer_hardware/hard_drive/portable/design/guns


/obj/item/computer_hardware/hard_drive/portable/design/nonlethal_ammo
	disk_name = "Frozen Star Nonlethal Magazines Pack"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED_COMMON
	rarity_value = 20
	license = 20
	designs = list(
		//please, maintain general order (pistol>speedloaders>smg>other>shells)+(smaller/less damaging caliber>bigger/more damaging caliber)
		//pistol mags
		/datum/design/autolathe/ammo/magazine_pistol/rubber,
		/datum/design/autolathe/ammo/mg_magnum/rubber,
		/datum/design/autolathe/ammo/cspistol/rubber,
		//speed loaders
		/datum/design/autolathe/ammo/sl_pistol/rubber,
		/datum/design/autolathe/ammo/sl_magnum/rubber,
		//smg mags
		/datum/design/autolathe/ammo/smg/rubber,
		//magnum smg mags
		/datum/design/autolathe/ammo/msmg/rubber,
		//rifles
		/datum/design/autolathe/ammo/srifle/rubber,
		/datum/design/autolathe/ammo/ihclrifle/rubber,
		/datum/design/autolathe/ammo/lrifle/rubber,
		//shells
		/datum/design/autolathe/ammo/shotgun_blanks,
		/datum/design/autolathe/ammo/shotgun_beanbag,
		/datum/design/autolathe/ammo/shotgun_flash,
	)

/obj/item/computer_hardware/hard_drive/portable/design/lethal_ammo
	disk_name = "Frozen Star Lethal Magazines Pack"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED_COMMON
	license = 20
	designs = list(
		//please, maintain general order (pistol>speedloaders>smg>other>shells)+(smaller/less damaging caliber>bigger/more damaging caliber)
		//pistol mags
		/datum/design/autolathe/ammo/magazine_pistol,
		/datum/design/autolathe/ammo/mg_magnum,
		/datum/design/autolathe/ammo/cspistol,
		//speed loaders
		/datum/design/autolathe/ammo/sl_pistol,
		/datum/design/autolathe/ammo/sl_magnum,
		//smg mags
		/datum/design/autolathe/ammo/smg,
		//magnum smg mags
		/datum/design/autolathe/ammo/msmg,
		//rifles
		/datum/design/autolathe/ammo/srifle,
		/datum/design/autolathe/ammo/ihclrifle,
		/datum/design/autolathe/ammo/lrifle,
		//shells
		/datum/design/autolathe/ammo/shotgun_pellet,
		/datum/design/autolathe/ammo/shotgun,
	)

/obj/item/computer_hardware/hard_drive/portable/design/ammo_boxes_smallarms
	disk_name = "Frozen Star .35 and .40 Ammunition"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED_COMMON
	license = 20
	designs = list(
		/datum/design/autolathe/ammo/pistol_ammobox,
		/datum/design/autolathe/ammo/pistol_ammobox/practice = 0,
		/datum/design/autolathe/ammo/pistol_ammobox/rubber,
		/datum/design/autolathe/ammo/magnum_ammobox,
		/datum/design/autolathe/ammo/magnum_ammobox/practice = 0,
		/datum/design/autolathe/ammo/magnum_ammobox/rubber,
	)

/obj/item/computer_hardware/hard_drive/portable/design/ammo_boxes_rifle
	disk_name = "Frozen Star Rifle Ammunition"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED_COMMON
	license = 20
	designs = list(
		/datum/design/autolathe/ammo/srifle_ammobox_small,
		/datum/design/autolathe/ammo/srifle_ammobox_small/practice = 0,
		/datum/design/autolathe/ammo/srifle_ammobox_small/rubber,
		/datum/design/autolathe/ammo/srifle_ammobox,
		/datum/design/autolathe/ammo/srifle_ammobox/rubber,
		/datum/design/autolathe/ammo/clrifle_ammobox_small,
		/datum/design/autolathe/ammo/clrifle_ammobox_small/practice = 0,
		/datum/design/autolathe/ammo/clrifle_ammobox_small/rubber,
		/datum/design/autolathe/ammo/clrifle_ammobox,
		/datum/design/autolathe/ammo/clrifle_ammobox/rubber,
		/datum/design/autolathe/ammo/lrifle_ammobox_small,
		/datum/design/autolathe/ammo/lrifle_ammobox_small/practice = 0,
		/datum/design/autolathe/ammo/lrifle_ammobox_small/rubber,
		/datum/design/autolathe/ammo/lrifle_ammobox,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_cheap_guns
	disk_name = "Frozen Star Basic - .35 Civilian Pack"
	icon_state = "frozenstar"
	rarity_value = 7
	license = 12
	designs = list(
		/datum/design/autolathe/gun/giskard = 3,
		/datum/design/autolathe/gun/olivaw = 3,
		/datum/design/autolathe/gun/clarissa = 3,
		/datum/design/autolathe/gun/havelock = 3,
		/datum/design/autolathe/ammo/magazine_pistol,
		/datum/design/autolathe/ammo/magazine_pistol/practice = 0,
		/datum/design/autolathe/ammo/magazine_pistol/rubber,
		/datum/design/autolathe/ammo/sl_pistol,
		/datum/design/autolathe/ammo/sl_pistol/practice = 0,
		/datum/design/autolathe/ammo/sl_pistol/rubber,
		)

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_colt
	disk_name = "Frozen Star - .35 Colt 1911"
	icon_state = "frozenstar"
	rarity_value = 9
	license = 12
	designs = list(
		/datum/design/autolathe/gun/colt = 3, //"FS HG .35 Auto \"Colt M1911\""
		/datum/design/autolathe/ammo/magazine_pistol,
		/datum/design/autolathe/ammo/magazine_pistol/practice = 0,
		/datum/design/autolathe/ammo/magazine_pistol/rubber,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_silenced
	disk_name = "Frozen Star - .25 Mandella"
	icon_state = "frozenstar"
	rarity_value = 13
	license = 12
	designs = list(
		/datum/design/autolathe/gun/mandella = 3, // "FS HG .25 Caseless \"Mandella\""
		/datum/design/autolathe/ammo/cspistol,
		/datum/design/autolathe/ammo/cspistol/practice = 0,
		/datum/design/autolathe/ammo/cspistol/rubber,
	)

// .40 REVOLVERS

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_revolver_miller
	disk_name = "Frozen Star - .40 Miller Revolver"
	icon_state = "frozenstar"
	rarity_value = 13
	license = 12
	designs = list(
		/datum/design/autolathe/gun/revolver = 3, // "FS REV .40 \"Miller\""
		/datum/design/autolathe/ammo/sl_magnum,
		/datum/design/autolathe/ammo/sl_magnum/practice = 0,
		/datum/design/autolathe/ammo/sl_magnum/rubber,
		)

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_revolver_consul
	disk_name = "Frozen Star - .40 Consul Revolver"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	license = 12
	designs = list(
		/datum/design/autolathe/gun/revolver_consul = 3, // "FS REV .40 \"Consul\""
		/datum/design/autolathe/ammo/sl_magnum,
		/datum/design/autolathe/ammo/sl_magnum/practice = 0,
		/datum/design/autolathe/ammo/sl_magnum/rubber,
		)

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_revolver_deckard
	disk_name = "Frozen Star - .40 Deckard Revolver"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	license = 12
	designs = list(
		/datum/design/autolathe/gun/revolver_deckard = 3, // "FS REV .40 \"Deckard\""
		/datum/design/autolathe/ammo/sl_magnum,
		/datum/design/autolathe/ammo/sl_magnum/practice = 0,
		/datum/design/autolathe/ammo/sl_magnum/rubber,
		)

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_revolver_mateba
	disk_name = "Frozen Star - .40 Mateba Revolver"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 90
	license = 12
	designs = list(
		/datum/design/autolathe/gun/revolver_mateba = 3, // "FS REV .40 Magnum \"Mateba\""
		/datum/design/autolathe/ammo/sl_magnum,
		/datum/design/autolathe/ammo/sl_magnum/practice = 0,
		/datum/design/autolathe/ammo/sl_magnum/rubber,
		)

// .40 PISTOLS

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_lamia
	disk_name = "Frozen Star - .40 Lamia Handgun"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 90
	license = 12
	designs = list(
		/datum/design/autolathe/gun/lamia = 3, // "FS HG .40 \"Lamia\""
		/datum/design/autolathe/ammo/mg_magnum,
		/datum/design/autolathe/ammo/mg_magnum/practice = 0,
		/datum/design/autolathe/ammo/mg_magnum/rubber,
		)

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_deagle
	disk_name = "Frozen Star - .40 Avasarala Handgun"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 50
	license = 12
	designs = list(
		/datum/design/autolathe/gun/avasarala = 3, // "FS HG .40 \"Avasarala\""
		/datum/design/autolathe/ammo/mg_magnum,
		/datum/design/autolathe/ammo/mg_magnum/practice = 0,
		/datum/design/autolathe/ammo/mg_magnum/rubber,
		)

// .50 SHOTGUNS

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_doublebarrel
	disk_name = "Frozen Star - .50 Double Barrel Shotgun"
	icon_state = "frozenstar"
	rarity_value = 9
	license = 12
	designs = list(
		/datum/design/autolathe/gun/doublebarrel = 3, // "double-barreled shotgun"
		/datum/design/autolathe/ammo/shotgun_pellet,
		/datum/design/autolathe/ammo/shotgun,
		/datum/design/autolathe/ammo/shotgun_beanbag,
		/datum/design/autolathe/ammo/shotgun_blanks,
		/datum/design/autolathe/ammo/shotgun_flash,
		)

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_kammerer
	disk_name = "Frozen Star - .50 Kammerer Shotgun"
	icon_state = "frozenstar"
	rarity_value = 9
	license = 12
	designs = list(
		/datum/design/autolathe/gun/pump_shotgun = 3, // "FS SG \"Kammerer\""
		/datum/design/autolathe/ammo/shotgun_pellet,
		/datum/design/autolathe/ammo/shotgun,
		/datum/design/autolathe/ammo/shotgun_beanbag,
		/datum/design/autolathe/ammo/shotgun_blanks,
		/datum/design/autolathe/ammo/shotgun_flash,
		)


/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_gladstone
	disk_name = "Frozen Star - .50 Gladstone Shotgun"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 17
	license = 12
	designs = list(
		/datum/design/autolathe/gun/gladstone = 3, // "FS SG \"Gladstone\""
		/datum/design/autolathe/ammo/shotgun_pellet,
		/datum/design/autolathe/ammo/shotgun,
		/datum/design/autolathe/ammo/shotgun_beanbag,
		/datum/design/autolathe/ammo/shotgun_blanks,
		/datum/design/autolathe/ammo/shotgun_flash,
		)

/obj/item/computer_hardware/hard_drive/portable/design/guns/sa_pug
	disk_name = "Serbian Arms - .50 Pug Auto Shotgun"
	icon_state = "serbian"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 90
	license = 12
	designs = list(
		/datum/design/autolathe/gun/bojevic = 3, // "SA SG \"Bojevic\""
		/datum/design/autolathe/ammo/m12beanbag, // Never add tazershells, for love of god
		/datum/design/autolathe/ammo/m12pellet,
		/datum/design/autolathe/ammo/m12slug,
		)

// SMGs
/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_paco
	disk_name = "Frozen Star - .35 Paco HG"
	icon_state = "frozenstar"
	rarity_value = 13
	license = 12
	designs = list(
		/datum/design/autolathe/gun/paco = 3, // "FS HG .35 \"Paco\""
		/datum/design/autolathe/ammo/magazine_pistol,
		/datum/design/autolathe/ammo/magazine_pistol/practice = 0,
		/datum/design/autolathe/ammo/magazine_pistol/rubber,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_straylight
	disk_name = "Frozen Star - .35 Straylight SMG"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	license = 12
	designs = list(
		/datum/design/autolathe/gun/straylight = 3, // "FS SMG .35 \"Straylight\""
		/datum/design/autolathe/ammo/smg,
		/datum/design/autolathe/ammo/smg/practice = 0,
		/datum/design/autolathe/ammo/smg/rubber,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_molly
	disk_name = "Frozen Star - .35 Molly SMG"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	license = 12
	designs = list(
		/datum/design/autolathe/gun/molly = 3, // "FS MP .35 \"Molly\""
		/datum/design/autolathe/ammo/smg,
		/datum/design/autolathe/ammo/smg/practice = 0,
		/datum/design/autolathe/ammo/smg/rubber,
	)


/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_atreides
	disk_name = "Frozen Star - .35 Atreides SMG"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	license = 12
	designs = list(
		/datum/design/autolathe/gun/atreides = 3, // "FS SMG .35 \"Atreides\""
		/datum/design/autolathe/ammo/smg,
		/datum/design/autolathe/ammo/smg/practice = 0,
		/datum/design/autolathe/ammo/smg/rubber,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_slaught_o_matic
	disk_name = "Frozen Star - .35 Slaught-o-Matic HG"
	icon_state = "frozenstar"
	rarity_value = 7
	license = 12
	designs = list(
		/datum/design/autolathe/gun/slaught_o_matic = 1 // "FS HG .35 \"Slaught-o-Matic\""
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_bulldog
	disk_name = "Frozen Star - .20 Bulldog Carabine"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	license = 12
	designs = list(
		/datum/design/autolathe/gun/z8 = 3, // "FS CAR .20 \"Z8 Bulldog\""
		/datum/design/autolathe/ammo/srifle,
		/datum/design/autolathe/ammo/srifle/practice = 0,
		/datum/design/autolathe/ammo/srifle/rubber,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_wintermute
	disk_name = "Frozen Star - .20 Wintermute Assault Rifle"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 90
	license = 12
	designs = list(
		/datum/design/autolathe/gun/wintermute = 3, // "FS BR .20 \"Wintermute\""
		/datum/design/autolathe/ammo/srifle,
		/datum/design/autolathe/ammo/srifle/practice = 0,
		/datum/design/autolathe/ammo/srifle/rubber,
	)

// .25 Caseless

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_sol
	disk_name = "Frozen Star - .25 Sol Caseless SMG Pack"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	license = 12
	designs = list(
		/datum/design/autolathe/gun/sol = 3, // "FS CAR .25 caseless \"Sol\""
		/datum/design/autolathe/ammo/ihclrifle,
		/datum/design/autolathe/ammo/ihclrifle/practice = 0,
		/datum/design/autolathe/ammo/ihclrifle/rubber,
	)


/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_kalashnikov
	disk_name = "Frozen Star - .30 Hunting Rifle Pack"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	license = 12
	designs = list(

		/datum/design/autolathe/gun/ak47_fs = 3, // "FS AR .30 \"Vipr\""
		/datum/design/autolathe/ammo/lrifle,
		/datum/design/autolathe/ammo/lrifle/practice = 0,
		/datum/design/autolathe/ammo/lrifle/rubber,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_kalashnikov_ih
	disk_name = "Frozen Star - .30 PD Rifle Pack"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 30
	license = 12
	designs = list(
		/datum/design/autolathe/gun/ak47_fs_ih = 3, // "FS AR .30 \"Venger\""
		/datum/design/autolathe/ammo/lrifle,
		/datum/design/autolathe/ammo/lrifle/practice = 0,
		/datum/design/autolathe/ammo/lrifle/rubber,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_lenar
	disk_name = "Frozen Star - Lenar Grenade Launcher"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 90
	license = 15
	designs = list(
		/datum/design/autolathe/gun/grenade_launcher_lenar = 3, // "FS GL \"Lenar\""
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_spiderrose
	disk_name = "Frozen Star - Spider Rose PDW E"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	license = 12
	designs = list(
		/datum/design/autolathe/gun/energygun = 3, // "FS PDW E \"Spider Rose\""
		/datum/design/autolathe/cell/medium/high,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_martin
	disk_name = "Frozen Star - Martin PDW E"
	icon_state = "frozenstar"
	rarity_value = 9
	license = 12
	designs = list(
		/datum/design/autolathe/gun/energygun_martin = 3, // "FS PDW E \"Martin\""
		/datum/design/autolathe/cell/small/high,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_cassad
	disk_name = "Frozen Star - Cassad Plasma Rifle"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 90
	license = 12
	designs = list(
		/datum/design/autolathe/gun/plasma/cassad = 3, // "FS PR \"Cassad\""
		/datum/design/autolathe/cell/medium/high,
	)

/obj/item/computer_hardware/hard_drive/portable/design/guns/fs_tk
	disk_name = "Frozen Star - .30 Takeshi LMG"
	icon_state = "frozenstar"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED
	rarity_value = 90
	license = 12
	designs = list(
		/datum/design/autolathe/gun/lmg_tk = 3, // "FS LMG .30 \"Takeshi\""
		/datum/design/autolathe/ammo/lrifle_pk,
	)

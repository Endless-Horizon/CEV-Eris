// Excelsior
/obj/item/computer_hardware/hard_drive/portable/design/excelsior
	bad_type = /obj/item/computer_hardware/hard_drive/portable/design/excelsior
	origin_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 1)
	spawn_tags = SPAWN_TAG_DESIGN_EXCELSIOR
	icon_state = "excelsior"
	spawn_frequency = 8

/obj/item/computer_hardware/hard_drive/portable/design/excelsior/core
	disk_name = "Excelsior Means of Production"// TODO: Make this only usable by excelsior autolathes, and give excelsior autolathes a check for a complant to use.
	desc = {"The back has a machine etching: \"This struggle must be organised, according to \"all the rules of the art\", \
	by people who are professionally engaged in revolutionary activity.\""}
	spawn_blacklisted = TRUE
	license = -1
	designs = list(
		/datum/design/autolathe/gun/reclaimer,
		/datum/design/autolathe/circuit/autolathe_excelsior,		//circuits
		/datum/design/autolathe/circuit/shieldgen_excelsior,
		/datum/design/autolathe/circuit/reconstructor_excelsior,
		/datum/design/autolathe/circuit/diesel_excelsior,
		/datum/design/autolathe/circuit/excelsior_boombox,
		/datum/design/autolathe/circuit/turret_excelsior,
		/datum/design/autolathe/circuit/autolathe_disk_cloner,
		/datum/design/research/item/part/basic_capacitor,
		/datum/design/research/item/part/micro_mani,				//machine parts
		/datum/design/research/item/part/subspace_amplifier,
		/datum/design/research/item/part/subspace_crystal,
		/datum/design/research/item/part/subspace_transmitter,
		/datum/design/autolathe/part/igniter,						//regular parts
		/datum/design/autolathe/part/signaler,
		/datum/design/autolathe/part/sensor_prox,
		/datum/design/autolathe/cell/large/excelsior,				//power cells
		/datum/design/autolathe/cell/medium/excelsior,
		/datum/design/autolathe/cell/small/excelsior,
		/datum/design/autolathe/prosthesis/excelsior/l_arm,         //prostheses
		/datum/design/autolathe/prosthesis/excelsior/r_arm,
		/datum/design/autolathe/prosthesis/excelsior/l_leg,
		/datum/design/autolathe/prosthesis/excelsior/r_leg,
		/datum/design/autolathe/device/implanter,					//misc
		/datum/design/autolathe/device/propaganda_chip
	)

/obj/item/computer_hardware/hard_drive/portable/design/excelsior/weapons
	disk_name = "Excelsior Means of Revolution"
	desc = "The back has a machine etching: \"We stand for organized terror - this should be frankly admitted. Terror is an absolute necessity during times of revolution.\""
	spawn_blacklisted = TRUE
	license = -1
	designs = list(
		/datum/design/autolathe/gun/makarov,
		/datum/design/autolathe/gun/drozd,
		/datum/design/autolathe/gun/vintorez,
		/datum/design/autolathe/gun/boltgun,
		/datum/design/autolathe/gun/ak47,
		/datum/design/autolathe/gun/hmg_maxim,
		/datum/design/autolathe/ammo/magazine_pistol,				//makarov ammo
		/datum/design/autolathe/ammo/magazine_pistol/rubber,
		/datum/design/autolathe/ammo/pistol_ammobox,
		/datum/design/autolathe/ammo/pistol_ammobox/rubber,
		/datum/design/autolathe/ammo/msmg,							//drozd ammo
		/datum/design/autolathe/ammo/msmg/rubber,
		/datum/design/autolathe/ammo/magnum_ammobox,
		/datum/design/autolathe/ammo/magnum_ammobox/rubber,
		/datum/design/autolathe/ammo/srifle,						//vintorez ammo
		/datum/design/autolathe/ammo/srifle/rubber,
		/datum/design/autolathe/ammo/srifle_ammobox,
		/datum/design/autolathe/ammo/srifle_ammobox/rubber,
		/datum/design/autolathe/ammo/sl_lrifle,						//boltgun ammo
		/datum/design/autolathe/ammo/lrifle_ammobox_small,
		/datum/design/autolathe/ammo/lrifle_ammobox_small/rubber,
		/datum/design/autolathe/ammo/lrifle,						//AK ammo
		/datum/design/autolathe/ammo/lrifle/rubber,
		/datum/design/autolathe/ammo/maxim,							//Maxim ammo
		/datum/design/autolathe/ammo/maxim/rubber,
		/datum/design/autolathe/ammo/lrifle_ammobox,
		/datum/design/autolathe/sec/silencer,						//misc
		/datum/design/autolathe/clothing/excelsior_armor,
		/datum/design/autolathe/device/excelbaton,					//security
		/datum/design/autolathe/device/excelsiormine,
		/datum/design/autolathe/sec/beartrap
	)

/obj/item/computer_hardware/hard_drive/portable/design/excelsior/drozd
	disk_name = "Excelsior - .40 Drozd SMG"
	desc = {"The back has a machine etching:\n \
	\"Nobody is to be blamed for being born a slave; \
	but a slave who not only eschews a striving for freedom but justifies and eulogies his slavery - \
	such a slave is a lickspittle and a boor, who arouses a legitimate feeling of indignation, contempt, and loathing.\""}
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED_EXCELSIOR
	rarity_value = 50
	license = -1
	designs = list(
		/datum/design/autolathe/gun/drozd,
		/datum/design/autolathe/ammo/msmg, //comes with both lethal and rubber like means of production
		/datum/design/autolathe/ammo/msmg/rubber
	)

/obj/item/computer_hardware/hard_drive/portable/design/excelsior/ak47
	disk_name = "Excelsior - .30 AK47 Rifle"
	desc = {"The back has a machine etching:\n \
	\"Fear not the tyrant of the old world; \
	The tools we have wrought shall be used to strike them down - \
	and bring to pass the great and collective future.\""}
	icon_state = "excelsior"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED_EXCELSIOR
	rarity_value = 50
	license = -1
	designs = list(
		/datum/design/autolathe/gun/ak47,
		/datum/design/autolathe/ammo/lrifle,						//AK ammo
		/datum/design/autolathe/ammo/lrifle/rubber
	)

/obj/item/computer_hardware/hard_drive/portable/design/excelsior/vintorez
	disk_name = "Excelsior - .20 Vintorez Rifle"
	desc = {"The back has a machine etching:\n \
	\"Remember the failures of those before; \
	for all failures serve as lessons and warnings - \
	heed not the blind who cannot see the progress made from the past.\""}
	icon_state = "excelsior"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED_EXCELSIOR
	rarity_value = 50
	license = -1
	designs = list(
		/datum/design/autolathe/gun/vintorez,
		/datum/design/autolathe/ammo/srifle,						//vintorez ammo
		/datum/design/autolathe/ammo/srifle/rubber
	)

/obj/item/computer_hardware/hard_drive/portable/design/excelsior/boltgun
	disk_name = "Excelsior - .30 Kardashev-Mosin Rifle"
	desc = {"The back has a machine etching:\n \
	\"Remember the Haven; \
	it is their wisdom which has brought the great work to bear - \
	with tools such as these, their great vision was brought to light.\""}
	icon_state = "excelsior"
	spawn_tags = SPAWN_TAG_DESIGN_COMMON_EXCELSIOR
	rarity_value = 45
	license = -1
	designs = list(
		/datum/design/autolathe/gun/boltgun,
		/datum/design/autolathe/ammo/sl_lrifle,						//boltgun ammo
		/datum/design/autolathe/ammo/lrifle_ammobox_small,
		/datum/design/autolathe/ammo/lrifle_ammobox_small/rubber
	)

/obj/item/computer_hardware/hard_drive/portable/design/excelsior/makarov
	disk_name = "Excelsior - .35 Makarov HG"
	desc = {"The back has a machine etching:\n \
	\"Suffer not the slouch, the layabout, nor the shirk; \
	for these are the weakness in the great chains of the common liberating mind - \
	if the faults are not expunged, the collective shall fall because of it.\""}
	icon_state = "excelsior"
	spawn_tags = SPAWN_TAG_DESIGN_COMMON_EXCELSIOR
	rarity_value = 45
	license = -1
	designs = list(
		/datum/design/autolathe/gun/makarov,
		/datum/design/autolathe/ammo/magazine_pistol,				//makarov ammo
		/datum/design/autolathe/ammo/magazine_pistol/rubber
	)

/obj/item/computer_hardware/hard_drive/portable/design/excelsior/maxim
	disk_name = "Excelsior - .30 Maxim HMG"
	desc = {"The back has a machine etching:\n \
	\"Whatever happens, we have got the Maxim gun, and they have not.\""}
	icon_state = "excelsior"
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED_EXCELSIOR
	rarity_value = 90
	license = -1
	designs = list(
		/datum/design/autolathe/gun/hmg_maxim,
		/datum/design/autolathe/ammo/maxim,							//Maxim ammo
		/datum/design/autolathe/ammo/maxim/rubber,
	)

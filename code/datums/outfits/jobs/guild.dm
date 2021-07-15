/decl/hierarchy/outfit/job/cargo
	l_ear = /obj/item/device/radio/headset/headset_cargo
	hierarchy_type = /decl/hierarchy/outfit/job/cargo

/decl/hierarchy/outfit/job/cargo/merchant
	name = OUTFIT_JOB_NAME("Guild Merchant")
	uniform = /obj/item/clothing/under/rank/cargotech
	shoes = /obj/item/clothing/shoes/color/brown
	glasses = /obj/item/clothing/glasses/sunglasses
	suit = /obj/item/clothing/suit/storage/qm_coat
	l_hand = /obj/item/clipboard
	id_type = /obj/item/card/id/car
	pda_type = /obj/item/modular_computer/pda/cargo
	l_ear = /obj/item/device/radio/headset/heads/merchant

/decl/hierarchy/outfit/job/cargo/cargo_tech
	name = OUTFIT_JOB_NAME("Guild Technician")
	uniform = /obj/item/clothing/under/rank/cargotech
	suit = /obj/item/clothing/suit/storage/cargo_jacket
	belt = /obj/item/storage/belt/utility
	pda_type = /obj/item/modular_computer/pda/cargo

/decl/hierarchy/outfit/job/cargo/mining
	name = OUTFIT_JOB_NAME("Guild Miner")
	uniform = /obj/item/clothing/under/rank/miner
	pda_type = /obj/item/modular_computer/pda/moebius/science
	belt = /obj/item/storage/belt/utility
	backpack_contents = list(/obj/item/tool/crowbar = 1, /obj/item/storage/bag/ore = 1)
	flags = OUTFIT_HAS_BACKPACK|OUTFIT_EXTENDED_SURVIVAL

/decl/hierarchy/outfit/job/cargo/mining/New()
	..()
	BACKPACK_OVERRIDE_ENGINEERING

/decl/hierarchy/outfit/job/cargo/mining/void
	name = OUTFIT_JOB_NAME("Guild Miner - Voidsuit")
	mask = /obj/item/clothing/mask/breath
	suit = /obj/item/clothing/suit/space/void/mining

/decl/hierarchy/outfit/job/cargo/artist
	name = OUTFIT_JOB_NAME("Guild Artist")
	uniform = /obj/item/clothing/under/rank/artist
	//suit = /obj/item/clothing/suit/artist
	shoes = /obj/item/clothing/shoes/artist_shoes
	head = /obj/item/clothing/head/beret/artist
	glasses = /obj/item/clothing/glasses/artist
	mask = /obj/item/clothing/mask/gas/artist_hat
	l_pocket = /obj/item/bikehorn
	backpack_contents = list(/obj/item/bananapeel = 1, /obj/item/storage/fancy/crayons = 1, /obj/item/toy/waterflower = 1, /obj/item/stamp/clown = 1, /obj/item/handcuffs/fake = 1)

/decl/hierarchy/outfit/job/cargo/artist/clown
	name = OUTFIT_JOB_NAME("Guild Clown")
	uniform = /obj/item/clothing/under/rank/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_pocket = /obj/item/bikehorn
	backpack_contents = list(/obj/item/bananapeel = 1, /obj/item/storage/fancy/crayons = 1, /obj/item/toy/waterflower = 1, /obj/item/stamp/clown = 1, /obj/item/handcuffs/fake = 1)

/decl/hierarchy/outfit/job/cargo/artist/clown/New()
	..()
	backpack_overrides[/decl/backpack_outfit/backpack] = /obj/item/storage/backpack/clown
	backpack_overrides[/decl/backpack_outfit/satchel] = /obj/item/storage/backpack/satchel/leather


/decl/hierarchy/outfit/job/cargo/artist/clown/post_equip(var/mob/living/carbon/human/H)
	..()
	H.mutations.Add(CLUMSY)

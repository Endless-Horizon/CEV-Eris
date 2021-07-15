/decl/hierarchy/outfit/job/church
	l_ear = /obj/item/device/radio/headset/church
	id_type = /obj/item/card/id/church
	pda_type = /obj/item/modular_computer/pda/church
	hierarchy_type = /decl/hierarchy/outfit/job/church
	backpack_contents = list(/obj/item/book/ritual/cruciform = 1)

/decl/hierarchy/outfit/job/church/New()
	..()
	BACKPACK_OVERRIDE_NEOTHEOLOGY

/decl/hierarchy/outfit/job/church/chaplain
	name = OUTFIT_JOB_NAME("NeoTheology Preacher")
	l_ear = /obj/item/device/radio/headset/heads/preacher
	id_type = /obj/item/card/id/chaplain
	head = /obj/item/clothing/head/preacher
	uniform = /obj/item/clothing/under/rank/preacher
	suit = /obj/item/clothing/suit/storage/neotheology_coat
	shoes = /obj/item/clothing/shoes/reinforced
	gloves = /obj/item/clothing/gloves/thick
	backpack_contents = list(/obj/item/book/ritual/cruciform/priest = 1)

/decl/hierarchy/outfit/job/church/acolyte
	name = OUTFIT_JOB_NAME("NeoTheology Acolyte")
	uniform = /obj/item/clothing/under/rank/acolyte
	shoes = /obj/item/clothing/shoes/reinforced
	gloves = /obj/item/clothing/gloves/thick

/decl/hierarchy/outfit/job/church/gardener
	name = OUTFIT_JOB_NAME("Gardener")
	uniform = /obj/item/clothing/under/rank/church
	suit = /obj/item/clothing/suit/apron
	gloves = /obj/item/clothing/gloves/botanic_leather
	r_pocket = /obj/item/device/scanner/plant

/decl/hierarchy/outfit/job/church/janitor
	name = OUTFIT_JOB_NAME("Janitor")
	uniform = /obj/item/clothing/under/rank/church
	shoes = /obj/item/clothing/shoes/jackboots/neotheology

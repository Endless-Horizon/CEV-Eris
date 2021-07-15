/decl/hierarchy/outfit/job/assistant
	name = OUTFIT_JOB_NAME(ASSISTANT_TITLE)
	suit = /obj/item/clothing/suit/storage/ass_jacket
	uniform = /obj/item/clothing/under/rank/assistant
	r_pocket = /obj/item/spacecash/bundle/vagabond

/decl/hierarchy/outfit/job/service
	l_ear = /obj/item/device/radio/headset/headset_service
	hierarchy_type = /decl/hierarchy/outfit/job/service

/decl/hierarchy/outfit/job/service/bartender
	name = OUTFIT_JOB_NAME("Bartender")
	uniform = /obj/item/clothing/under/rank/bartender
	head = /obj/item/clothing/head/that
	id_type = /obj/item/card/id/white
	pda_type = /obj/item/modular_computer/pda/club_worker
	backpack_contents = list(/obj/item/ammo_casing/shotgun/beanbag = 4)


/decl/hierarchy/outfit/job/service/waiter
	name = OUTFIT_JOB_NAME("Waiter")
	uniform = /obj/item/clothing/under/waiter
	id_type = /obj/item/card/id/white
	pda_type = /obj/item/modular_computer/pda/club_worker

/decl/hierarchy/outfit/job/service/chef
	name = OUTFIT_JOB_NAME("Chef")
	uniform = /obj/item/clothing/under/rank/chef
	suit = /obj/item/clothing/suit/chef
	head = /obj/item/clothing/head/chefhat
	id_type = /obj/item/card/id/ltgrey
	pda_type = /obj/item/modular_computer/pda

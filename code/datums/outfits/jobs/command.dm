/decl/hierarchy/outfit/job/captain
	name = OUTFIT_JOB_NAME("Captain")
	head = /obj/item/clothing/head/caphat
	glasses = /obj/item/clothing/glasses/sunglasses/sechud
	uniform = /obj/item/clothing/under/rank/captain
	suit = /obj/item/clothing/suit/storage/captain
	l_ear = /obj/item/device/radio/headset/heads/captain
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/captain
	id_type = /obj/item/card/id/gold
	pda_type = /obj/item/modular_computer/pda/captain
	backpack_contents = list(/obj/item/storage/box/ids = 1, /obj/item/tool/knife/dagger/ceremonial = 1)

/decl/hierarchy/outfit/job/captain/New()
	..()
	backpack_overrides[/decl/backpack_outfit/backpack]      = /obj/item/storage/backpack/captain
	backpack_overrides[/decl/backpack_outfit/satchel]       = /obj/item/storage/backpack/satchel/captain

/decl/hierarchy/outfit/job/captain/post_equip(var/mob/living/carbon/human/H)
	..()
	if(H.age>49)
		// Since we can have something other than the default uniform at this
		// point, check if we can actually attach the medal
		var/obj/item/clothing/uniform = H.get_equipped_item(slot_w_uniform)
		if(uniform)
			var/obj/item/clothing/accessory/medal/gold/captain/medal = new()
			if(uniform.can_attach_accessory(medal))
				uniform.attach_accessory(null, medal)
			else
				qdel(medal)

/decl/hierarchy/outfit/job/hop
	name = OUTFIT_JOB_NAME("First Officer")
	head = /obj/item/clothing/head/caphat/hop
	glasses = /obj/item/clothing/glasses/sunglasses/sechud
	uniform = /obj/item/clothing/under/rank/first_officer
	suit = /obj/item/clothing/suit/armor/vest
	l_ear = /obj/item/device/radio/headset/heads/hop
	shoes = /obj/item/clothing/shoes/reinforced
	gloves = /obj/item/clothing/gloves/thick
	id_type = /obj/item/card/id/hop
	pda_type = /obj/item/modular_computer/pda/heads/hop
	backpack_contents = list(/obj/item/storage/box/ids = 1, /obj/item/tool/knife/dagger/ceremonial = 1)

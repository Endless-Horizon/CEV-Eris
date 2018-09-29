/datum/craft_recipe/clothing
	category = "Clothing"

/datum/craft_recipe/clothing/cardborg_suit
	name = "cardborg suit"
	result = /obj/item/clothing/suit/cardborg
	steps = list(
		list(/obj/item/stack/material/cardboard, 3)
	)

/datum/craft_recipe/clothing/cardborg_helmet
	name = "cardborg helmet"
	result = /obj/item/clothing/head/cardborg
	steps = list(
		list(/obj/item/stack/material/cardboard, 1)
	)

/datum/craft_recipe/clothing/sandals
	name = "wooden sandals"
	result = /obj/item/clothing/shoes/sandal
	steps = list(
		list(/obj/item/stack/material/wood, 1)
	)

/datum/craft_recipe/clothing/armorvest
	name = "armor vest"
	result = /obj/item/clothing/suit/armor/vest/handmade
	steps = list(
		list(/obj/item/clothing/suit/storage/hazardvest, 1, time = 30),
		list(/obj/item/stack/material/steel, 4),
		list(/obj/item/stack/cable_coil, 4)
	)

/datum/craft_recipe/clothing/combat_helmet
	name = "combat helmet"
	result = /obj/item/clothing/head/helmet/handmade
	steps = list(
		list(/obj/item/weapon/reagent_containers/glass/bucket, 1, time = 30),
		list(/obj/item/stack/material/steel, 4),
		list(/obj/item/stack/cable_coil, 2)
	)
// Utensils

/obj/item/weapon/computer_hardware/hard_drive/portable/design/club/silverware 
	disk_name = "Chef's Choice Silverware" 
	icon_state = "club"
	rarity_value = 4
	spawn_tags = SPAWN_TAG_DESIGN_COMMON
	license = -1 
	designs = list(
	/datum/design/autolathe/tool/metal_fork,
	/datum/design/autolathe/tool/metal_spoon,
	/datum/design/autolathe/tool/knife, 
	/datum/design/autolathe/tool/plastic_fork,
	/datum/design/autolathe/tool/plastic_spoon,
	/datum/design/autolathe/tool/rollingpin,
	/datum/design/autolathe/container/freezer
	)

/obj/item/weapon/computer_hardware/hard_drive/portable/design/club/glassware 
	disk_name = "Barman's Best Glassware" 
	icon_state = "club"
	rarity_value = 4
	spawn_tags = SPAWN_TAG_DESIGN_COMMON
	license = -1
	designs = list(
	/datum/design/autolathe/container/drinkingglass,
	/datum/design/autolathe/container/carafe,
	/datum/design/autolathe/container/insulated_pitcher,
	/datum/design/autolathe/container/flask,
	/datum/design/autolathe/container/vacuumflask,
	/datum/design/autolathe/container/white_mug,
	/datum/design/autolathe/container/black_mug,
	/datum/design/autolathe/container/green_mug,
	/datum/design/autolathe/container/blue_mug,
	/datum/design/autolathe/container/red_mug,
	/datum/design/autolathe/container/metal_mug
	)

// Alcohol

/obj/item/weapon/computer_hardware/hard_drive/portable/design/club/basic_barstuff
	disk_name = "Mike's Bar Staples" 
	icon_state = "club"
	rarity_value = 6
	spawn_tags = SPAWN_TAG_DESIGN_COMMON
	license = -1 
	designs = list(
	/datum/design/autolathe/container/prefilled/beer,
	/datum/design/autolathe/container/prefilled/ale,
	/datum/design/autolathe/container/prefilled/sodawater,
	/datum/design/autolathe/container/prefilled/soda,
	/datum/design/autolathe/container/prefilled/water,
	/datum/design/autolathe/food/packaged/chips,
	/datum/design/autolathe/food/packaged/cheesiehonkers,
	/datum/design/autolathe/food/packaged/candybar
	)

/obj/item/weapon/computer_hardware/hard_drive/portable/design/club/soda_variety
	disk_name = "Fizzpop's Variety"
	icon_state = "club"
	rarity_value = 10
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED_COMMON
	license = 50 
	designs = list(
	/datum/design/autolathe/container/prefilled/sodawater = 0, // free since it can be printed forever in the basic pack
	/datum/design/autolathe/container/prefilled/soda = 0, // ditto
	/datum/design/autolathe/container/prefilled/spacemountainwind,
	/datum/design/autolathe/container/prefilled/gibb,
	/datum/design/autolathe/container/prefilled/spaceup,
	/datum/design/autolathe/container/prefilled/lemonlime,
	/datum/design/autolathe/container/prefilled/starkist,
	/datum/design/autolathe/container/prefilled/thirteenloko = 5
	)

/obj/item/weapon/computer_hardware/hard_drive/portable/design/club/booze_variety
	disk_name = "Uncle Git's Cookbook"
	icon_state = "club"
	rarity_value = 12
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED_COMMON
	license = 20 
	designs = list(
	/datum/design/autolathe/container/prefilled/beer = 0,
	/datum/design/autolathe/container/prefilled/ale = 0,
	/datum/design/autolathe/container/prefilled/wine,
	/datum/design/autolathe/container/prefilled/vodka,
	/datum/design/autolathe/container/prefilled/gin,
	/datum/design/autolathe/container/prefilled/rum,
	/datum/design/autolathe/container/prefilled/whiskey
	)

// food

/obj/item/weapon/computer_hardware/hard_drive/portable/design/club/packaged_food_variety
	disk_name = "Sweetie's Pantry"
	icon_state = "club"
	rarity_value = 15
	spawn_tags = SPAWN_TAG_DESIGN_ADVANCED_COMMON
	license = 10
	designs = list(
	/datum/design/autolathe/food/packaged/candybar = 0, // free because it's also free in the basic bar disk
	/datum/design/autolathe/food/packaged/chips = 0,
	/datum/design/autolathe/food/packaged/cheesiehonkers = 0,
	/datum/design/autolathe/food/packaged/breadtube,
	/datum/design/autolathe/food/packaged/raisin,
	/datum/design/autolathe/food/packaged/jerky,
	/datum/design/autolathe/food/packaged/liquidfood = 2
	)
	

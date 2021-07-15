/obj/item/tool/saw //tier 2
	name = "metal saw"
	desc = "For cutting wood and other objects to pieces. Or sawing bones, in case of emergency."
	icon_state = "metal_saw"
	force = WEAPON_FORCE_NORMAL
	throwforce = WEAPON_FORCE_NORMAL
	worksound = WORKSOUND_SIMPLE_SAW
	flags = CONDUCT
	w_class = ITEM_SIZE_NORMAL
	matter = list(MATERIAL_STEEL = 3, MATERIAL_PLASTIC = 1)
	attack_verb = list("attacked", "slashed", "sawed", "cut")
	sharp = TRUE
	edge = TRUE
	tool_qualities = list(QUALITY_SAWING = 30, QUALITY_CUTTING = 20, QUALITY_WIRE_CUTTING = 20)
	embed_mult = 1 //Serrated blades catch on bone more easily

/obj/item/tool/saw/improvised //tier 1
	name = "choppa"
	desc = "A wicked serrated blade made of whatever nasty sharp things you could find. It would make a pretty decent weapon, given there are more space for some tool mods too."
	icon_state = "impro_saw"
	force = WEAPON_FORCE_PAINFUL //doubles as makeshift melee weapon, thus must have more damage than tier 2 saw
	tool_qualities = list(QUALITY_SAWING = 15, QUALITY_CUTTING = 10, QUALITY_WIRE_CUTTING = 10)
	degradation = 1
	max_upgrades = 5 //all makeshift tools get more mods to make them actually viable for mid-late game
	spawn_tags = SPAWN_TAG_JUNKTOOL
	rarity_value = 3

/obj/item/tool/saw/circular //tier 3
	name = "circular saw"
	desc = "For heavy duty cutting."
	icon_state = "saw"
	hitsound = WORKSOUND_CIRCULAR_SAW
	worksound = WORKSOUND_CIRCULAR_SAW
	force = WEAPON_FORCE_DANGEROUS * 1.15
	armor_penetration = ARMOR_PEN_MODERATE
	matter = list(MATERIAL_STEEL = 5, MATERIAL_PLASTIC = 2)
	tool_qualities = list(QUALITY_SAWING = 40, QUALITY_CUTTING = 30, QUALITY_WIRE_CUTTING = 30)

	use_power_cost = 0.15
	suitable_cell = /obj/item/cell/small
	spawn_tags = SPAWN_TAG_SURGERY_TOOL

/obj/item/tool/saw/circular/advanced //tier 4, focusing on armor penetration
	name = "advanced circular saw"
	desc = "You think you can cut anything with it."
	icon_state = "advanced_saw"
	force = WEAPON_FORCE_ROBUST
	armor_penetration = ARMOR_PEN_DEEP
	matter = list(MATERIAL_STEEL = 6, MATERIAL_PLASTEEL = 1, MATERIAL_PLASTIC = 2)
	tool_qualities = list(QUALITY_SAWING = 50, QUALITY_CUTTING = 40, QUALITY_WIRE_CUTTING = 40)
	degradation = 0.7
	use_power_cost = 0.22
	max_upgrades = 4
	spawn_blacklisted = TRUE
	rarity_value = 20

/obj/item/tool/saw/chain //tier 4, focusing on damage, fuel variant
	name = "chainsaw"
	desc = "You can cut trees, people, walls and zombies with it, just watch out for fuel."
	icon_state = "chainsaw"
	hitsound = WORKSOUND_CHAINSAW
	worksound = WORKSOUND_CHAINSAW
	force = WEAPON_FORCE_BRUTAL //Rip and tear!
	armor_penetration = ARMOR_PEN_SHALLOW
	matter = list(MATERIAL_STEEL = 3, MATERIAL_PLASTEEL = 10, MATERIAL_PLASTIC = 2)
	tool_qualities = list(QUALITY_SAWING = 60, QUALITY_CUTTING = 50, QUALITY_WIRE_CUTTING = 20) //not the best choice to cut wires
	w_class = ITEM_SIZE_BULKY
	max_upgrades = 4
	use_fuel_cost = 0.1
	max_fuel = 80
	rarity_value = 96
	spawn_tags = SPAWN_TAG_TOOL_ADVANCED

/obj/item/tool/saw/hyper //tier 4, focusing on damage, cell variant
	name = "TM hypersaw"
	desc = "This eco-friendly chainsaw will Rip and Tear until it is done."
	icon_state = "hypersaw"
	hitsound = WORKSOUND_CHAINSAW
	worksound = WORKSOUND_CHAINSAW
	force = WEAPON_FORCE_BRUTAL
	armor_penetration = ARMOR_PEN_SHALLOW
	matter = list(MATERIAL_SILVER = 2, MATERIAL_PLASTEEL = 10, MATERIAL_PLASTIC = 3)
	tool_qualities = list(QUALITY_SAWING = 60, QUALITY_CUTTING = 50, QUALITY_WIRE_CUTTING = 20)
	w_class = ITEM_SIZE_BULKY
	max_upgrades = 4
	degradation = 0.7
	use_power_cost = 1
	suitable_cell = /obj/item/cell/medium
	rarity_value = 96
	spawn_tags = SPAWN_TAG_TOOL_ADVANCED

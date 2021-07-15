var/global/list/ore_data = list()

/ore
	var/name
	var/display_name
	var/alloy
	var/smelts_to
	var/compresses_to
	var/result_amount     // How much ore?
	var/spread = 1	      // Does this type of deposit spread?
	var/spread_chance     // Chance of spreading in any direction
	var/ore	              // Path to the ore produced when tile is mined.
	var/scan_icon         // Overlay for ore scanners.
	// Xenoarch stuff. No idea what it's for, just refactored it to be less awful.
	var/list/xarch_ages = list(
		"thousand" = 999,
		"million" = 999
		)
	var/xarch_source_mineral = "iron"

/ore/New()
	. = ..()
	if(!display_name)
		display_name = name

/ore/uranium
	name = MATERIAL_URANIUM
	display_name = "pitchblende"
	smelts_to = MATERIAL_URANIUM
	result_amount = 10
	spread_chance = 10
	ore = /obj/item/ore/uranium
	scan_icon = "mineral_uncommon"
	xarch_ages = list(
		"thousand" = 999,
		"million" = 704
		)
	xarch_source_mineral = "potassium"

/ore/hematite
	name = "hematite"
	display_name = "hematite"
	smelts_to = "iron"
	alloy = 1
	result_amount = 10
	spread_chance = 25
	ore = /obj/item/ore/iron
	scan_icon = "mineral_common"

/ore/coal
	name = "carbon"
	display_name = "raw carbon"
	smelts_to = MATERIAL_PLASTIC
	alloy = 1
	result_amount = 10
	spread_chance = 25
	ore = /obj/item/ore/coal
	scan_icon = "mineral_common"

/ore/glass
	name = "sand"
	display_name = "sand"
	smelts_to = MATERIAL_GLASS
	compresses_to = MATERIAL_SANDSTONE

/ore/plasma
	name = "plasma"
	display_name = "plasma crystals"
	compresses_to = "plasma"
	alloy = 1
	//smelts_to = something that explodes violently on the conveyor, huhuhuhu
	result_amount = 8
	spread_chance = 25
	ore = /obj/item/ore/plasma
	scan_icon = "mineral_uncommon"
	xarch_ages = list(
		"thousand" = 999,
		"million" = 999,
		"billion" = 13,
		"billion_lower" = 10
		)
	xarch_source_mineral = "plasma"

/ore/silver
	name = "silver"
	display_name = "native silver"
	smelts_to = MATERIAL_SILVER
	result_amount = 8
	spread_chance = 10
	ore = /obj/item/ore/silver
	scan_icon = "mineral_uncommon"

/ore/gold
	smelts_to = MATERIAL_GOLD
	name = "gold"
	display_name = "native gold"
	result_amount = 8
	spread_chance = 10
	ore = /obj/item/ore/gold
	scan_icon = "mineral_uncommon"
	xarch_ages = list(
		"thousand" = 999,
		"million" = 999,
		"billion" = 4,
		"billion_lower" = 3
		)

/ore/diamond
	name = "diamond"
	display_name = "diamond"
	compresses_to = MATERIAL_DIAMOND
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/ore/diamond
	scan_icon = "mineral_rare"
	xarch_source_mineral = "nitrogen"

/ore/platinum
	name = "platinum"
	display_name = "raw platinum"
	smelts_to = MATERIAL_PLATINUM
	compresses_to = "osmium"
	alloy = 1
	result_amount = 5
	spread_chance = 10
	ore = /obj/item/ore/osmium
	scan_icon = "mineral_rare"

/ore/hydrogen
	name = "mhydrogen"
	display_name = "metallic hydrogen"
	smelts_to = "tritium"
	compresses_to = "mhydrogen"
	scan_icon = "mineral_rare"
	spread_chance = 5
	result_amount = 5
	ore = /obj/item/ore/hydrogen

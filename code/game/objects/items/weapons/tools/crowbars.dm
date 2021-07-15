/obj/item/tool/crowbar
	name = "crowbar"
	desc = "Used to remove floors and to pry open doors."
	icon_state = "crowbar"
	item_state = "crowbar"
	flags = CONDUCT
	force = WEAPON_FORCE_PAINFUL
	worksound = WORKSOUND_EASY_CROWBAR
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_ENGINEERING = 1)
	matter = list(MATERIAL_STEEL = 4)
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
	tool_qualities = list(QUALITY_PRYING = 25, QUALITY_DIGGING = 10, QUALITY_HAMMERING = 10)
	rarity_value = 4

/obj/item/tool/crowbar/improvised
	name = "rebar"
	desc = "A pair of metal rods laboriously twisted into a useful shape. Has more space for tool mods because it's hand-made."
	icon_state = "impro_crowbar"
	item_state = "impro_crowbar"
	tool_qualities = list(QUALITY_PRYING = 10, QUALITY_DIGGING = 10,QUALITY_HAMMERING = 10)
	degradation = 5 //This one breaks REALLY fast
	max_upgrades = 5 //all makeshift tools get more mods to make them actually viable for mid-late game
	rarity_value = 2
	spawn_tags = SPAWN_TAG_JUNKTOOL

/obj/item/tool/crowbar/onestar
	name = "One Star crowbar"
	desc = "Looks like a classic one, but more durable. Has more space for mods too."
	icon_state = "one_star_crowbar"
	item_state = "onestar_crowbar"
	matter = list(MATERIAL_STEEL = 3, MATERIAL_PLATINUM = 1)
	tool_qualities = list(QUALITY_PRYING = 25, QUALITY_DIGGING = 10)
	origin_tech = list(TECH_ENGINEERING = 1, TECH_MATERIAL = 2)
	degradation = 0.6
	workspeed = 1.2
	spawn_blacklisted = TRUE
	rarity_value = 10
	spawn_tags = SPAWN_TAG_OS_TOOL

/obj/item/tool/crowbar/pneumatic
	name = "pneumatic crowbar"
	desc = "When you really need to crack open something."
	icon_state = "pneumo_crowbar"
	item_state = "pneumo_crowbar"
	matter = list(MATERIAL_STEEL = 6, MATERIAL_PLASTEEL = 1, MATERIAL_PLASTIC = 2)
	tool_qualities = list(QUALITY_PRYING = 40, QUALITY_DIGGING = 35)
	degradation = 0.7
	use_power_cost = 0.8
	max_upgrades = 4
	suitable_cell = /obj/item/cell/medium
	rarity_value = 24
	spawn_tags = SPAWN_TAG_TOOL_ADVANCED

/obj/item/tool/crowbar/pneumatic/hivemind
	name = "modified pneumatic crowbar"
	desc = "A pneumatic crowbar with numerous growths on it. Doubt you will be able to use it for anything other than prying."
	icon_state = "hivemind_pneumo_crowbar"
	item_state = "hivemind_pneumo_crowbar"
	origin_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 4, TECH_BIO = 2)
	matter = list(MATERIAL_STEEL = 8, MATERIAL_PLASTEEL = 1, MATERIAL_PLASTIC = 2, MATERIAL_BIOMATTER = 3)
	tool_qualities = list(QUALITY_PRYING = 50)
	degradation = 0.4
	use_power_cost = 0.4
	spawn_blacklisted = TRUE

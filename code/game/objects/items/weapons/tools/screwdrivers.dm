/obj/item/tool/screwdriver
	name = "screwdriver"
	desc = "You can use this to open panels, screw stuff and such things."
	icon_state = "screwdriver"
	flags = CONDUCT
	worksound = WORKSOUND_SCREW_DRIVING
	slot_flags = SLOT_BELT | SLOT_EARS
	w_class = ITEM_SIZE_TINY
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 1)
	attack_verb = list("stabbed")
	tool_qualities = list(QUALITY_SCREW_DRIVING = 30, QUALITY_BONE_SETTING = 10)
	rarity_value = 6

/obj/item/tool/screwdriver/improvised
	name = "screwpusher"
	desc = "A little metal rod wrapped in tape, barely qualifies as a tool. This can be fixed with enough tool mods, for which it has ample capacity."
	icon_state = "impro_screwdriver"
	tool_qualities = list(QUALITY_SCREW_DRIVING = 15)
	degradation = 2
	max_upgrades = 5 //all makeshift tools get more mods to make them actually viable for mid-late game
	rarity_value = 3
	spawn_tags = SPAWN_TAG_JUNKTOOL

/obj/item/tool/screwdriver/electric
	name = "electric screwdriver"
	desc = "An electrical screwdriver, powered by an S class cell. Can be used as a drilling tool if necessary, though is not well suited to do so."
	icon_state = "e-screwdriver"
	worksound = WORKSOUND_DRIVER_TOOL
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 1)
	tool_qualities = list(QUALITY_SCREW_DRIVING = 40, QUALITY_DRILLING = 10, QUALITY_BONE_SETTING = 10)
	degradation = 0.7
	max_upgrades = 4
	use_power_cost = 0.18
	suitable_cell = /obj/item/cell/small
	rarity_value = 24

/obj/item/tool/screwdriver/combi_driver
	name = "combi driver"
	desc = "Drive screws, drive bolts, drill bones - you can do everything with it."
	icon_state = "combi_driver"
	w_class = ITEM_SIZE_NORMAL
	worksound = WORKSOUND_DRIVER_TOOL
	slot_flags = SLOT_BELT
	matter = list(MATERIAL_STEEL = 3, MATERIAL_PLASTEEL = 1, MATERIAL_PLASTIC = 2)
	tool_qualities = list(QUALITY_SCREW_DRIVING = 50, QUALITY_BOLT_TURNING = 50, QUALITY_DRILLING = 20)
	degradation = 0.7
	use_power_cost = 0.24
	suitable_cell = /obj/item/cell/small
	max_upgrades = 4
	rarity_value = 48
	spawn_tags = SPAWN_TAG_TOOL_ADVANCED

/obj/item/tool/screwdriver/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M) || user.a_intent == "help")
		return ..()
	if(user.targeted_organ != BP_EYES && user.targeted_organ != BP_HEAD)
		return ..()
	if((CLUMSY in user.mutations) && prob(50))
		M = user
	return eyestab(M,user)


/obj/item/tool/screwdriver/combi_driver/onestar
	name = "One Star combi driver"
	desc = "A One Star combi driver. Does better than the standard combi drivers on the market, but has less slots for tool mods."
	icon_state = "one_star_combidriver"
	matter = list(MATERIAL_STEEL = 4, MATERIAL_PLATINUM = 2)
	tool_qualities = list(QUALITY_SCREW_DRIVING = 60, QUALITY_BOLT_TURNING = 60, QUALITY_DRILLING = 25)
	origin_tech = list(TECH_ENGINEERING = 3, TECH_MATERIAL = 2)
	degradation = 0.6
	workspeed = 1.7
	use_power_cost = 0.3
	suitable_cell = /obj/item/cell/small
	max_upgrades = 2
	spawn_blacklisted = TRUE
	rarity_value = 10
	spawn_tags = SPAWN_TAG_OS_TOOL

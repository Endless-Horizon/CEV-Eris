/obj/item/tool/pickaxe
	name = "pickaxe"
	desc = "The most basic of mining tools, for short excavations and small mineral extractions."
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = WEAPON_FORCE_DANGEROUS
	armor_penetration = ARMOR_PEN_EXTREME // It's a pickaxe. It's destined to poke holes in things, even armor.
	throwforce = WEAPON_FORCE_NORMAL
	icon_state = "pickaxe"
	item_state = "pickaxe"
	w_class = ITEM_SIZE_BULKY
	matter = list(MATERIAL_STEEL = 6)
	tool_qualities = list(QUALITY_EXCAVATION = 10, QUALITY_PRYING = 20) //So it still shares its switch off quality despite not yet being used.
	switched_off_qualities = list(QUALITY_EXCAVATION = 10, QUALITY_PRYING = 20)
	switched_on_qualities = list(QUALITY_DIGGING = 30, QUALITY_PRYING = 20)
	toggleable = TRUE
	origin_tech = list(TECH_MATERIAL = 1, TECH_ENGINEERING = 1)
	attack_verb = list("hit", "pierced", "sliced", "attacked")
	sharp = TRUE
	structure_damage_factor = STRUCTURE_DAMAGE_BORING //Drills and picks are made for getting through hard materials
	//They are the best anti-structure melee weapons
	embed_mult = 1.2 //Digs deep
	mode = EXCAVATE //Mode should be whatever is the starting tool and off quality.
	rarity_value = 24

/obj/item/tool/pickaxe/equipped(mob/user)
	..()
	update_icon()

/obj/item/tool/pickaxe/dropped(mob/user)
	..()
	update_icon()

/obj/item/tool/pickaxe/turn_on(mob/user)
	.=..()
	if(.)
		mode = DIG
		to_chat(user, SPAN_NOTICE("You tighten your grip on [src], and ready yourself to strike earth."))

/obj/item/tool/pickaxe/turn_off(mob/user)

	mode = EXCAVATE
	to_chat(user, SPAN_NOTICE("You loosen your grip on [src], and prepare to remove debris."))
	..()


/obj/item/tool/pickaxe/onestar //TODO: Add sound to /turn_on proc
	name = "One Star pickaxe"
	desc = "A standard One Star basic tool. There used energy technologies what makes it enough powerful and cheap at the same time."
	icon_state = "one_star_pickaxe"
	item_state = "pickaxe"
	matter = list(MATERIAL_STEEL = 4, MATERIAL_PLATINUM = 2, MATERIAL_DIAMOND = 2)
	origin_tech = list(TECH_MATERIAL = 3, TECH_ENGINEERING = 2, TECH_POWER = 3)
	switched_on_force = WEAPON_FORCE_ROBUST
	tool_qualities = list(QUALITY_EXCAVATION = 15, QUALITY_PRYING = 25)
	switched_off_qualities = list(QUALITY_EXCAVATION = 15, QUALITY_PRYING = 25)
	switched_on_qualities = list(QUALITY_DIGGING = 40, QUALITY_PRYING = 20)
	glow_color = COLOR_BLUE_LIGHT
	degradation = 0.6
	workspeed = 1.2
	use_power_cost = 0
	spawn_blacklisted = TRUE
	rarity_value = 10
	spawn_tags = SPAWN_TAG_OS_TOOL


/obj/item/tool/pickaxe/jackhammer
	name = "jackhammer"
	desc = "Cracks rocks with blasts, perfect for killing cave lizards."
	icon_state = "jackhammer"
	item_state = "jackhammer"
	matter = list(MATERIAL_STEEL = 6, MATERIAL_PLASTIC = 2)
	tool_qualities = list(QUALITY_EXCAVATION = 10)
	switched_off_qualities = list(QUALITY_EXCAVATION = 10)
	switched_on_qualities = list(QUALITY_DIGGING = 35)
	origin_tech = list(TECH_MATERIAL = 3, TECH_POWER = 2, TECH_ENGINEERING = 2)
	degradation = 0.7
	use_power_cost = 0.4
	suitable_cell = /obj/item/cell/medium
	rarity_value = 48

/obj/item/tool/pickaxe/jackhammer/onestar
	name = "One Star jackhammer"
	desc = "A heavy One Star tool that cracks rocks with blasts, perfect for killing capitalist pigs."
	icon_state = "one_star_jackhammer"
	item_state = "jackhammer"
	matter = list(MATERIAL_STEEL = 7, MATERIAL_PLATINUM = 2)
	tool_qualities = list(QUALITY_EXCAVATION = 10)
	switched_off_qualities = list(QUALITY_EXCAVATION = 10)
	switched_on_qualities = list(QUALITY_DIGGING = 35)
	origin_tech = list(TECH_MATERIAL = 4, TECH_POWER = 2, TECH_ENGINEERING = 3)
	degradation = 0.6
	workspeed = 1.7
	max_upgrades = 2
	use_power_cost = 0.6
	spawn_blacklisted = TRUE
	rarity_value = 10
	spawn_tags = SPAWN_TAG_OS_TOOL

/obj/item/tool/pickaxe/drill
	name = "mining drill" // Can dig sand as well!
	desc = "Yours is the drill that will pierce through the rock walls."
	icon_state = "handdrill"
	item_state = "jackhammer"
	tool_qualities = list(QUALITY_EXCAVATION = 10, QUALITY_DRILLING = 10)
	switched_off_qualities = list(QUALITY_EXCAVATION = 10, QUALITY_DRILLING = 10)
	switched_on_qualities = list(QUALITY_DIGGING = 40, QUALITY_DRILLING = 10)
	matter = list(MATERIAL_STEEL = 8, MATERIAL_PLASTIC = 2)
	origin_tech = list(TECH_MATERIAL = 2, TECH_POWER = 3, TECH_ENGINEERING = 2)
	degradation = 0.7
	use_fuel_cost = 0.07
	max_fuel = 100
	rarity_value = 48

/obj/item/tool/pickaxe/drill/onestar
	name = "One Star mining drill"
	desc = "Yours is the drill that will pierce through the worker, metaphorically."
	icon_state = "one_star_drill"
	tool_qualities = list(QUALITY_EXCAVATION = 10, QUALITY_DRILLING = 10)
	switched_off_qualities = list(QUALITY_EXCAVATION = 10, QUALITY_DRILLING = 10)
	switched_on_qualities = list(QUALITY_DIGGING = 40, QUALITY_DRILLING = 10)
	matter = list(MATERIAL_STEEL = 8, MATERIAL_PLATINUM = 2)
	origin_tech = list(TECH_MATERIAL = 4, TECH_POWER = 3, TECH_ENGINEERING = 2)
	degradation = 0.6
	workspeed = 1.7
	max_upgrades = 2
	use_fuel_cost = 0.10
	max_fuel = 90
	spawn_blacklisted = TRUE
	rarity_value = 10
	spawn_tags = SPAWN_TAG_OS_TOOL

/obj/item/tool/pickaxe/diamonddrill
	name = "diamond-point mining drill"
	desc = "Yours is the drill that will pierce the heavens!"
	icon_state = "diamonddrill"
	item_state = "jackhammer"
	force = WEAPON_FORCE_DANGEROUS * 1.15
	tool_qualities = list(QUALITY_EXCAVATION = 10, QUALITY_DRILLING = 20)
	switched_off_qualities = list(QUALITY_EXCAVATION = 10, QUALITY_DRILLING = 20)
	switched_on_qualities = list(QUALITY_DIGGING = 50, QUALITY_DRILLING = 20)
	matter = list(MATERIAL_STEEL = 8, MATERIAL_PLASTEEL = 2, MATERIAL_PLASTIC = 2, MATERIAL_DIAMOND = 1)
	origin_tech = list(TECH_MATERIAL = 6, TECH_POWER = 4, TECH_ENGINEERING = 5)
	max_upgrades = 4
	degradation = 0.1
	use_fuel_cost = 0.07
	max_fuel = 120
	rarity_value = 96
	spawn_tags = SPAWN_TAG_TOOL_ADVANCED

/obj/item/tool/pickaxe/diamonddrill/rig
	use_fuel_cost = 0
	passive_fuel_cost = 0
	spawn_tags = null

/obj/item/tool/pickaxe/excavation
	name = "hand pickaxe"
	desc = "A smaller, more precise version of the pickaxe, used for archeology excavation."
	icon_state = "pick_hand"
	item_state = "syringe_0"
	force = WEAPON_FORCE_PAINFUL //It's smaller
	tool_qualities = list(QUALITY_EXCAVATION = 30, QUALITY_PRYING = 15)
	switched_off_qualities = list(QUALITY_EXCAVATION = 30, QUALITY_PRYING = 15)
	switched_on_qualities = list(QUALITY_DIGGING = 15, QUALITY_PRYING = 15)
	w_class = ITEM_SIZE_NORMAL
	matter = list(MATERIAL_STEEL = 3)
	rarity_value = 48

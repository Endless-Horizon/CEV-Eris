//combat exosuit components use plasteel reinforcement for more durability than most exosuits, and gold for thermal sensors
/mob/living/exosuit/premade/combat
	name = "combat exosuit"
	desc = "A sleek, modern combat exosuit."

	rarity_value = 60

	material = MATERIAL_PLASTEEL
	exosuit_color = COLOR_DARK_GUNMETAL
	installed_armor = /obj/item/robot_parts/robot_component/armour/exosuit/combat
	installed_software_boards = list(
		/obj/item/electronics/circuitboard/exosystem/weapons,
		/obj/item/electronics/circuitboard/exosystem/advweapons
	)
	installed_systems = list(
		HARDPOINT_LEFT_HAND = /obj/item/mech_equipment/mounted_system/taser,
		HARDPOINT_RIGHT_HAND = /obj/item/mech_equipment/mounted_system/taser/ion,
		HARDPOINT_HEAD = /obj/item/mech_equipment/light,
	)

/mob/living/exosuit/premade/combat/Initialize()
	if(!arms)
		arms = new /obj/item/mech_component/manipulators/combat(src)
	if(!legs)
		legs = new /obj/item/mech_component/propulsion/combat(src)
	if(!head)
		head = new /obj/item/mech_component/sensors/combat(src)
	if(!body)
		body = new /obj/item/mech_component/chassis/combat(src)

	. = ..()

/mob/living/exosuit/premade/combat/slayer
	name = "S.C.U. 'Slayer'" //Space Combat Unit
	desc = "A sleek, modern combat exosuit. It has two red stripes on it's chassis."

	exosuit_color = "#5a6934"
	decal = "stripes"
	installed_systems = list(
		HARDPOINT_LEFT_HAND = /obj/item/mech_equipment/mounted_system/taser/laser,
		HARDPOINT_RIGHT_HAND = /obj/item/mech_equipment/mounted_system/taser/ion,
		HARDPOINT_HEAD = /obj/item/mech_equipment/light
	)

/obj/item/mech_component/sensors/combat
	name = "combat sensors"
	gender = PLURAL
	exosuit_desc_string = "high-resolution thermal sensors"
	desc = "High resolution thermal combat sensors, designed to locate targets even through cover or smoke."
	icon_state = "combat_head"
	vision_flags = SEE_MOBS
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	max_damage = 50 //the sensors are delicate, the value of this part is in the SEE_MOBS flag anyway
	power_use = 200
	matter = list(MATERIAL_STEEL = 10, MATERIAL_GLASS = 4, MATERIAL_GOLD = 2, MATERIAL_URANIUM = 2)

/obj/item/mech_component/chassis/combat
	name = "sealed exosuit chassis"
	hatch_descriptor = "canopy"
	desc = "This standard combat chassis is reinforced with plasteel for extra durability without compromising visibility or ease of access."
	pilot_coverage = 100
	transparent_cabin = TRUE
	exosuit_desc_string = "an armored chassis"
	icon_state = "combat_body"
	max_damage = 100
	mech_health = 400 //It's not as beefy as the heavy, but it IS a combat chassis, so let's make it slightly beefier
	power_use = 40
	climb_time = 25 //standard values for now to encourage use over heavy
	matter = list(MATERIAL_STEEL = 45, MATERIAL_PLASTEEL = 10, MATERIAL_PLASMAGLASS = 5)

/obj/item/mech_component/chassis/combat/Initialize()
	pilot_positions = list(
		list(
			"[NORTH]" = list("x" = 8,  "y" = 8),
			"[SOUTH]" = list("x" = 8,  "y" = 8),
			"[EAST]"  = list("x" = 4,  "y" = 8),
			"[WEST]"  = list("x" = 12, "y" = 8)
		)
	)

	. = ..()

/obj/item/mech_component/manipulators/combat
	name = "combat arms"
	exosuit_desc_string = "flexible, advanced manipulators"
	desc = "These advanced manipulators are designed for combat, and as a result can take and dish out beatings fairly well."
	icon_state = "combat_arms"
	melee_damage = 15
	action_delay = 10
	max_damage = 100
	power_use = 50
	matter = list(MATERIAL_STEEL = 15, MATERIAL_PLASTEEL = 5)

/obj/item/mech_component/propulsion/combat
	name = "combat legs"
	exosuit_desc_string = "sleek hydraulic legs"
	desc = "These combat legs are both fast and durable, thanks to a generous plasteel reinforcement and aerodynamic design."
	icon_state = "combat_legs"
	move_delay = 3
	power_use = 20
	matter = list(MATERIAL_STEEL = 15)
	turn_delay = 3 //almost identical to light, but slightly worse turning and less power efficiency for extra durability
	max_damage = 100
	power_use = 25
	matter = list(MATERIAL_STEEL = 15, MATERIAL_PLASTEEL = 5)

//light exosuit components use reinforced plastics to be weaker, but faster than other components. Meant for utility use rather than combat.
/mob/living/exosuit/premade/light
	name = "light exosuit"
	desc = "A light and agile exosuit."

	rarity_value = 10

	material = MATERIAL_PLASTIC
	exosuit_color = COLOR_OFF_WHITE
	installed_armor = /obj/item/robot_parts/robot_component/armour/exosuit/radproof
	installed_software_boards = list(
		/obj/item/electronics/circuitboard/exosystem/utility,
		/obj/item/electronics/circuitboard/exosystem/medical
	)
	installed_systems = list(
		HARDPOINT_LEFT_HAND = /obj/item/mech_equipment/catapult,
		HARDPOINT_BACK = /obj/item/mech_equipment/sleeper,
		HARDPOINT_HEAD = /obj/item/mech_equipment/light,
	)

/mob/living/exosuit/premade/light/Initialize()
	if(!arms)
		arms = new /obj/item/mech_component/manipulators/light(src)
	if(!legs)
		legs = new /obj/item/mech_component/propulsion/light(src)
	if(!head)
		head = new /obj/item/mech_component/sensors/light(src)
	if(!body)
		body = new /obj/item/mech_component/chassis/light(src)

	. = ..()

/obj/item/mech_component/manipulators/light
	name = "light arms"
	exosuit_desc_string = "lightweight, segmented manipulators"
	desc = "As flexible as they are fragile, these light manipulators can follow a pilot's movements in close to real time."
	icon_state = "light_arms"
	melee_damage = 5
	action_delay = 5
	max_damage = 40
	power_use = 10
	matter = list(MATERIAL_STEEL = 10, MATERIAL_PLASTIC = 5)

/obj/item/mech_component/propulsion/light
	name = "light legs"
	exosuit_desc_string = "aerodynamic electromechanic legs"
	desc = "The electrical systems driving these legs are almost totally silent. Unfortunately, slamming a plate of metal against the ground is not."
	icon_state = "light_legs"
	move_delay = 3 //still fast, slightly slower than tracks, but has better turning time for maint tunnels
	turn_delay = 2
	max_damage = 40
	power_use = 20
	matter = list(MATERIAL_STEEL = 10, MATERIAL_PLASTIC = 5)

/obj/item/mech_component/sensors/light
	name = "light sensors"
	gender = PLURAL
	exosuit_desc_string = "advanced sensor array"
	desc = "A series of high resolution optical sensors. They can overlay several images to give the pilot a sense of location even in total darkness."
	icon_state = "light_head"
	max_damage = 30
	vision_flags = SEE_TURFS
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	power_use = 50
	matter = list(MATERIAL_STEEL = 8, MATERIAL_GLASS = 4, MATERIAL_URANIUM = 2) //NVG takes uranium, so night vision sensors take uranium

/obj/item/mech_component/chassis/light
	name = "light exosuit chassis"
	hatch_descriptor = "canopy"
	desc = "This light cockpit combines ultralight materials with clear aluminum laminates to provide an optimized cockpit experience. Doesn't offer much protection, though."
	pilot_coverage = 100
	transparent_cabin =  TRUE
	hide_pilot = TRUE //Sprite too small, legs clip through, so for now hide pilot
	exosuit_desc_string = "an open and light chassis"
	icon_state = "light_body"
	max_damage = 30
	power_use = 5
	climb_time = 10 //gets a buff to climb_time, in exchange for being less beefy
	has_hardpoints = list(HARDPOINT_BACK)
	matter = list(MATERIAL_STEEL = 20, MATERIAL_GLASS = 5, MATERIAL_PLASTIC = 10)

/obj/item/mech_component/chassis/light/Initialize()
	pilot_positions = list(
		list(
			"[NORTH]" = list("x" = 8,  "y" = -2),
			"[SOUTH]" = list("x" = 8,  "y" = -2),
			"[EAST]"  = list("x" = 1,  "y" = -2),
			"[WEST]"  = list("x" = 9,  "y" = -2)
		)
	)
	. = ..()

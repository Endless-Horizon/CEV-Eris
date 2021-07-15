//heavy exosuit components use plasteel and uranium plating for ultra-durable parts, but have diminished speed and functionality as a result.
/mob/living/exosuit/premade/heavy
	name = "heavy exosuit"
	desc = "A heavily armored combat exosuit."

	material = MATERIAL_PLASTEEL
	exosuit_color = COLOR_TITANIUM
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

/mob/living/exosuit/premade/heavy/Initialize()
	if(!arms)
		arms = new /obj/item/mech_component/manipulators/heavy(src)
	if(!legs)
		legs = new /obj/item/mech_component/propulsion/heavy(src)
	if(!head)
		head = new /obj/item/mech_component/sensors/heavy(src)
	if(!body)
		body = new /obj/item/mech_component/chassis/heavy(src)

	. = ..()


/obj/item/mech_component/sensors/heavy
	name = "heavy sensors"
	exosuit_desc_string = "a reinforced monoeye"
	desc = "A solitary sensor moves inside a recessed slit in the armour plates."
	icon_state = "heavy_head"
	max_damage = 150
	power_use = 0
	matter = list(MATERIAL_STEEL = 20, MATERIAL_GLASS = 2, MATERIAL_PLASTEEL = 5)

/obj/item/mech_component/chassis/heavy
	name = "reinforced exosuit chassis"
	hatch_descriptor = "hatch"
	desc = "This heavy combat chassis is a veritable juggernaut, capable of protecting a pilot even in the most violent of conflicts. It's hell to climb in and out of, however."
	pilot_coverage = 100
	exosuit_desc_string = "a heavily armoured chassis"
	icon_state = "heavy_body"
	max_damage = 200
	mech_health = 600
	power_use = 50
	climb_time = 35 //Takes longer to climb into, but is beefy as HELL.
	matter = list(MATERIAL_STEEL = 50, MATERIAL_URANIUM = 15, MATERIAL_PLASTEEL = 15)

/obj/item/mech_component/manipulators/heavy
	name = "combat arms"
	exosuit_desc_string = "super-heavy reinforced manipulators"
	icon_state = "heavy_arms"
	desc = "Designed for durability and dishing out beatings, this heavy set of manipulators can both take and dish out beatings."
	melee_damage = 25
	action_delay = 15
	max_damage = 150
	power_use = 60
	matter = list(MATERIAL_STEEL = 20, MATERIAL_PLASTEEL = 10, MATERIAL_URANIUM = 5)

/obj/item/mech_component/propulsion/heavy
	name = "heavy legs"
	exosuit_desc_string = "heavy legs"
	desc = "Exosuit actuators struggle to move these armored legs, and they're even worse at turning."
	icon_state = "heavy_legs"
	move_delay = 5
	turn_delay = 6 //Heavy components sacrifice mobility for durability, so these legs are slow. Players can still mix and match other parts for better speeds
	max_damage = 200
	power_use = 100
	matter = list(MATERIAL_STEEL = 20, MATERIAL_URANIUM = 5)

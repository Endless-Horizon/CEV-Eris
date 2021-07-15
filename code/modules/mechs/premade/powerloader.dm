//Cheap parts are as basic as you can get. Designed for utility use and cheap production.
/mob/living/exosuit/premade/powerloader
	name = "S.E.U. \"Ripley\"" //Space Excavation Unit
	desc = "A cheap utility exosuit. An old Nanotrasen design, now used just about everywhere due to post-Fall data leaks."

	rarity_value = 15
	material = MATERIAL_STEEL
	exosuit_color = "#ffbc37"
	installed_software_boards = list(
		/obj/item/electronics/circuitboard/exosystem/utility,
		/obj/item/electronics/circuitboard/exosystem/engineering
	)
	installed_systems = list(
		HARDPOINT_LEFT_HAND = /obj/item/mech_equipment/drill,
		HARDPOINT_RIGHT_HAND = /obj/item/mech_equipment/clamp,
		HARDPOINT_HEAD = /obj/item/mech_equipment/light,
	)

/mob/living/exosuit/premade/powerloader/Initialize()
	if(!arms)
		arms = new /obj/item/mech_component/manipulators/cheap(src)
	if(!legs)
		legs = new /obj/item/mech_component/propulsion/cheap(src)
	if(!head)
		head = new /obj/item/mech_component/sensors/cheap(src)
	if(!body)
		body = new /obj/item/mech_component/chassis/cheap(src)

	. = ..()


/obj/item/mech_component/manipulators/cheap
	name = "lifter exosuit arms"
	exosuit_desc_string = "industrial lifter arms"
	max_damage = 70
	power_use = 30
	desc = "Industrial lifter arms that allow you to crudely manipulate things from the safety of your cockpit."

/obj/item/mech_component/propulsion/cheap
	name = "lifter exosuit legs"
	exosuit_desc_string = "reinforced lifter legs"
	desc = "Wide and stable, but not particularly fast."
	max_damage = 70
	move_delay = 4
	turn_delay = 4
	power_use = 10

/obj/item/mech_component/sensors/cheap
	name = "simple exosuit sensors"
	gender = PLURAL
	exosuit_desc_string = "simple sensors"
	desc = "A primitive set of sensors designed to provide basic visual information to the pilot."
	max_damage = 100
	power_use = 0

/obj/item/mech_component/chassis/cheap
	name = "open exosuit chassis"
	hatch_descriptor = "roll cage"
	pilot_coverage = 40
	exosuit_desc_string = "an industrial roll cage"
	desc = "An industrial roll cage. Absolutely useless in hazardous environments, as it isn't even sealed."
	max_damage = 100
	power_use = 0
	climb_time = 20 //easier to hop in and close up than a full cockpit, but not specialized for it

/obj/item/mech_component/chassis/powerloader/Initialize()
	pilot_positions = list(
		list(
			"[NORTH]" = list("x" = 8,  "y" = 8),
			"[SOUTH]" = list("x" = 8,  "y" = 8),
			"[EAST]"  = list("x" = 8,  "y" = 8),
			"[WEST]"  = list("x" = 8,  "y" = 8)
		),
		list(
			"[NORTH]" = list("x" = 8,  "y" = 16),
			"[SOUTH]" = list("x" = 8,  "y" = 16),
			"[EAST]"  = list("x" = 0,  "y" = 16),
			"[WEST]"  = list("x" = 16, "y" = 16)
		)
	)
	. = ..()

/mob/living/exosuit/premade/powerloader/flames_red
	name = "S.E.U. \"Firestarter\""
	desc = "An old but well-liked utility exosuit. This one has cool red flames."
	decal = "flames_red"

/mob/living/exosuit/premade/powerloader/flames_blue
	name = "S.E.U. \"Burning Chrome\""
	desc = "An old but well-liked utility exosuit. This one has cool blue flames."
	decal = "flames_blue"

/mob/living/exosuit/premade/powerloader/firefighter
	name = "S.E.U. \"Firefighter\""
	desc = "A refitted industrial exosuit designed to fight fires. The chassis has been replaced to protect the pilot, and the armor is reinforced with plasteel for fireproofing."

	rarity_value = 20
	material = MATERIAL_PLASTEEL // Reinforced with plasteel to fireproof the chassis
	exosuit_color = "#819a73"
	installed_systems = list(
		HARDPOINT_LEFT_HAND = /obj/item/mech_equipment/drill,
		HARDPOINT_RIGHT_HAND = /obj/item/mech_equipment/mounted_system/extinguisher,
		HARDPOINT_HEAD = /obj/item/mech_equipment/light,
	)

/mob/living/exosuit/premade/powerloader/firefighter/Initialize()
	if(!body)
		body = new /obj/item/mech_component/chassis/heavy(src) // Sealed chassis to protect the pilot from fire

	. = ..()

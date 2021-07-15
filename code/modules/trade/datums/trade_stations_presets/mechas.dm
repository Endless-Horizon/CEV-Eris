/datum/trade_station/mechas
	name_pool = list("TCS 'Shipyard'" = "Technomansers Construction Station 'Shipyard'. Seems that they construct and selling exosuits. Sensors showing that they have docked vessel, maybe they completed and sold last batch.\
		\"Hey, dudes, it seems you want some mechas? We just send last batch of mechs, but we have some extra suits, parts and circuits.\"")
	assortiment = list(
		"Exosuits" = list(
			/mob/living/exosuit/premade/powerloader/firefighter,
			/mob/living/exosuit/premade/powerloader/flames_blue,
			/mob/living/exosuit/premade/powerloader/flames_red,
			/mob/living/exosuit/premade/light,
			/mob/living/exosuit/premade/heavy,
			/mob/living/exosuit/premade/combat/slayer,
		),
		"Mech Armor" = list(
			/obj/item/robot_parts/robot_component/armour/exosuit,
			/obj/item/robot_parts/robot_component/armour/exosuit/radproof,
			/obj/item/robot_parts/robot_component/armour/exosuit/em,
			/obj/item/robot_parts/robot_component/armour/exosuit/combat,
		),
		"Parts" = list(
			/obj/item/mech_component/chassis,
			/obj/item/mech_component/manipulators,
			/obj/item/mech_component/sensors,
			/obj/item/mech_component/propulsion,
		),
		"Soft" = list(
			/obj/item/electronics/circuitboard/exosystem/engineering,
			/obj/item/electronics/circuitboard/exosystem/utility,
			/obj/item/electronics/circuitboard/exosystem/medical,
			/obj/item/electronics/circuitboard/exosystem/weapons,
		),
		"Equipment" = list(
			/obj/item/mech_equipment/mounted_system/taser,
			/obj/item/mech_equipment/mounted_system/taser/ion,
			/obj/item/mech_equipment/mounted_system/taser/plasma,
			/obj/item/mech_equipment/mounted_system/rcd,
			/obj/item/mech_equipment/clamp,
			/obj/item/mech_equipment/light,
			/obj/item/mech_equipment/drill,
			/obj/item/mech_equipment/mounted_system/extinguisher,
			/obj/item/mech_equipment/sleeper,
		),
	)

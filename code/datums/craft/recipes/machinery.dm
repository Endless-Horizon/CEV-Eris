/datum/craft_recipe/machinery
	category = "Machinery"
	flags = CRAFT_ON_FLOOR|CRAFT_ONE_PER_TURF

/datum/craft_recipe/machinery/machine_frame
	name = "machine frame"
	result = /obj/machinery/constructable_frame/machine_frame
	steps = list(
		list(CRAFT_MATERIAL, 8, MATERIAL_STEEL),
	)

/datum/craft_recipe/machinery/vertical_machine_frame
	name = "vertical machine frame"
	result = /obj/machinery/constructable_frame/machine_frame/vertical
	steps = list(
		list(CRAFT_MATERIAL, 8, MATERIAL_STEEL),
	)

/datum/craft_recipe/machinery/computer_frame
	name = "computer frame"
	result = /obj/structure/computerframe
	steps = list(
		list(CRAFT_MATERIAL, 5, MATERIAL_STEEL),
	)

/datum/craft_recipe/machinery/modularconsole
	name = "modular console frame"
	result = /obj/machinery/modular_computer/console/buildable
	flags = CRAFT_ON_FLOOR|CRAFT_ONE_PER_TURF
	steps = list(
		list(CRAFT_MATERIAL, 10, MATERIAL_STEEL),
	)

/datum/craft_recipe/machinery/modularlaptop
	name = "modular laptop frame"
	result = /obj/machinery/modular_computer/laptop/buildable
	steps = list(
		list(CRAFT_MATERIAL, 7, MATERIAL_STEEL),
	)

/datum/craft_recipe/machinery/modulartablet
	name = "modular tablet frame"
	result = /obj/item/modular_computer/tablet
	steps = list(
		list(CRAFT_MATERIAL, 5, MATERIAL_STEEL),
	)

/datum/craft_recipe/machinery/turret_frame
	name = "turret frame"
	result = /obj/machinery/porta_turret_construct
	steps = list(
		list(CRAFT_MATERIAL, 10, MATERIAL_STEEL),
	)



//wall or small you know them req only 2 list
/datum/craft_recipe/machinery/wall
	steps = list(
		list(CRAFT_MATERIAL, 2, MATERIAL_STEEL),
	)
	flags = null

/datum/craft_recipe/machinery/wall/lightfixture
	name = "light fixture frame"
	result = /obj/item/frame/light

/datum/craft_recipe/machinery/wall/lightfixture/small
	name = "small light fixture frame"
	result = /obj/item/frame/light/small

/datum/craft_recipe/machinery/wall/apc
	name = "apc frame"
	result = /obj/item/frame/apc

/datum/craft_recipe/machinery/wall/air_alarm
	name = "air alarm frame"
	result = /obj/item/frame/air_alarm

/datum/craft_recipe/machinery/wall/fire_alarm
	name = "fire alarm frame"
	result = /obj/item/frame/fire_alarm

/datum/craft_recipe/machinery/AI_core
	name = "AI core"
	result = /obj/structure/AIcore
	steps = list(
		list(CRAFT_MATERIAL, 10, MATERIAL_PLASTEEL),
	)

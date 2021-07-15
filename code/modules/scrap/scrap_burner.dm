/obj/item/electronics/circuitboard/pacman/scrap
	name = T_BOARD("PACMAN-type generator")
	build_path = /obj/machinery/power/port_gen/pacman/scrap
	board_type = "machine"
	origin_tech = list(TECH_DATA = 3, TECH_PLASMA = 3, TECH_ENGINEERING = 3)

/datum/design/research/circuit/pacman/scrap
	name = "PACMAN-type generator"
	build_path = /obj/item/electronics/circuitboard/pacman/scrap
	sort_string = "JBAAD"
	starts_unlocked = TRUE // i don't even know what this scrap pacman thing is supposed to be

/obj/machinery/power/port_gen/pacman/scrap
	name = "Scrapman Portable Generator"
	icon_state = "portgen1"                 // Get a spriter to do something with this perhaps.
	sheet_name = "refined scrap"
	sheet_path = /obj/item/stack/refined_scrap
	power_gen = 5000
	time_per_fuel_unit = 80

/obj/machinery/power/port_gen/pacman/scrap/overheat()
	explosion(loc, 1, 5, 2, -1)

/obj/item/electronics/circuitboard/pacman
	name = T_BOARD("PACMAN-type generator")
	build_path = /obj/machinery/power/port_gen/pacman
	board_type = "machine"
	rarity_value = 10
	origin_tech = list(TECH_DATA = 3, TECH_POWER = 3, TECH_PLASMA = 3, TECH_ENGINEERING = 3)
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/capacitor = 1
	)

/obj/item/electronics/circuitboard/pacman/super
	name = T_BOARD("SUPERPACMAN-type generator")
	build_path = /obj/machinery/power/port_gen/pacman/super
	origin_tech = list(TECH_DATA = 3, TECH_POWER = 4, TECH_ENGINEERING = 4)

/obj/item/electronics/circuitboard/pacman/mrs
	name = T_BOARD("MRSPACMAN-type generator")
	build_path = /obj/machinery/power/port_gen/pacman/mrs
	origin_tech = list(TECH_DATA = 3, TECH_POWER = 5, TECH_ENGINEERING = 5)

/*
/obj/item/electronics/circuitboard/diesel
	name = T_BOARD("diesel generator")
	build_path = /obj/machinery/power/port_gen/pacman/diesel
	board_type = "machine"
	origin_tech = list(TECH_POWER = 2, TECH_ENGINEERING = 2)
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/capacitor = 1
	)
*/
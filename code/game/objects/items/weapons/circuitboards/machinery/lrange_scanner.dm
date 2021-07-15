#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/electronics/circuitboard/long_range_scanner
	name = T_BOARD("long range scanner")
	board_type = "machine"
	build_path = /obj/machinery/power/long_range_scanner
	matter = list(MATERIAL_GLASS = 3, MATERIAL_GOLD = 3)
	origin_tech = list(TECH_MAGNET = 3, TECH_POWER = 4)
	req_components = list(
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stock_parts/smes_coil = 1,
							/obj/item/stock_parts/console_screen = 1)

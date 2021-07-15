/obj/item/electronics/circuitboard/telesci_pad
	name = T_BOARD("telepad")
	build_path = /obj/machinery/telepad
	board_type = "machine"
	origin_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 3, TECH_MATERIAL = 3, TECH_BLUESPACE = 4)

	req_components = list(
		/obj/item/bluespace_crystal/artificial = 2,
		/obj/item/stock_parts/capacitor = 1
	)

/obj/item/electronics/circuitboard/telesci_console
	name = T_BOARD("Telescience Console")
	build_path = /obj/machinery/computer/telescience
	origin_tech = list(TECH_DATA = 3, TECH_BLUESPACE = 2)

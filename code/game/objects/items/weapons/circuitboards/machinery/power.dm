/obj/item/electronics/circuitboard/smes
	name = T_BOARD("superconductive magnetic energy storage")
	build_path = /obj/machinery/power/smes/buildable
	board_type = "machine"
	origin_tech = list(TECH_POWER = 6, TECH_ENGINEERING = 4)
	req_components = list(
		/obj/item/stock_parts/smes_coil = 1,
		/obj/item/stack/cable_coil = 30
	)

/obj/item/electronics/circuitboard/batteryrack
	name = T_BOARD("battery rack PSU")
	build_path = /obj/machinery/power/smes/batteryrack
	board_type = "machine"
	origin_tech = list(TECH_POWER = 3, TECH_ENGINEERING = 2)
	req_components = list(
		/obj/item/cell/large = 3
	)

/obj/item/electronics/circuitboard/apc
	name = "power control module"
	icon = 'icons/obj/module.dmi'
	icon_state = "power_mod"
	desc = "Heavy-duty switching circuits for power control."
	flags = CONDUCT
	build_path = /obj/machinery/power/smes/batteryrack/makeshift
	board_type = "machine"
	req_components = list(
		/obj/item/cell/large = 3
	)
	matter = list(MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 3)

/obj/item/electronics/circuitboard/antigrav
	name = T_BOARD("antigrav generator")
	build_path = /obj/machinery/antigrav
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 4, TECH_MAGNET = 4)
	req_components = list(
		/obj/item/stack/cable_coil = 30,
		/obj/item/stock_parts/subspace/crystal = 1,
		/obj/item/stock_parts/micro_laser = 3,
		/obj/item/stock_parts/capacitor = 3
	)

/obj/item/electronics/circuitboard/breakerbox
	name = T_BOARD("breaker box")
	build_path = /obj/machinery/power/breakerbox
	board_type = "machine"
	origin_tech = list(TECH_POWER = 4, TECH_ENGINEERING = 4)
	req_components = list(
			/obj/item/stock_parts/smes_coil = 1,
			/obj/item/stack/cable_coil = 10,
			/obj/item/stock_parts/capacitor = 1
		)
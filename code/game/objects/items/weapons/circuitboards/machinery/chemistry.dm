/obj/item/electronics/circuitboard/chemmaster
	name = T_BOARD("ChemMaster 3000")
	build_path = /obj/machinery/chem_master
	board_type = "machine"
	origin_tech = list(TECH_DATA = 2, TECH_BIO = 2)
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/reagent_containers/glass/beaker = 2
	)

/obj/item/electronics/circuitboard/chem_heater
	name = T_BOARD("Chemical Heater")
	build_path = /obj/machinery/chem_heater
	board_type = "machine"
	origin_tech = list(TECH_DATA = 2, TECH_BIO = 2)
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/console_screen = 1
	)

/obj/item/electronics/circuitboard/chemical_dispenser
	name = T_BOARD("Chemical Dispenser")
	build_path = /obj/machinery/chemical_dispenser
	board_type = "machine"
	origin_tech = list(TECH_DATA = 2, TECH_BIO = 2)
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/cell/medium = 1
	)

/obj/item/electronics/circuitboard/chemical_dispenser/industrial
	name = T_BOARD("Industeral Chemical Dispenser")
	build_path = /obj/machinery/chemical_dispenser/industrial

/obj/item/electronics/circuitboard/chemical_dispenser/soda
	name = T_BOARD("Soda Chemical Dispenser")
	build_path = /obj/machinery/chemical_dispenser/soda

/obj/item/electronics/circuitboard/chemical_dispenser/beer
	name = T_BOARD("Booze Chemical Dispenser")
	build_path = /obj/machinery/chemical_dispenser/beer

/obj/item/electronics/circuitboard/electrolyzer
	name = T_BOARD("Electrolyzer")
	build_path = /obj/machinery/electrolyzer
	board_type = "machine"
	origin_tech = list(TECH_BIO = 3)
	req_components = list(
		/obj/item/stock_parts/capacitor = 1,
	)

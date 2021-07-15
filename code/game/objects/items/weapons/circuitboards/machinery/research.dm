/obj/item/electronics/circuitboard/rdserver
	name = T_BOARD("R&D server")
	build_path = /obj/machinery/r_n_d/server
	board_type = "machine"
	origin_tech = list(TECH_DATA = 3)
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/scanning_module = 1
	)

/obj/item/electronics/circuitboard/destructive_analyzer
	name = T_BOARD("destructive analyzer")
	build_path = /obj/machinery/r_n_d/destructive_analyzer
	board_type = "machine"
	origin_tech = list(TECH_MAGNET = 2, TECH_ENGINEERING = 2, TECH_DATA = 2)
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1
	)

/obj/item/electronics/circuitboard/autolathe
	name = T_BOARD("autolathe")
	build_path = /obj/machinery/autolathe
	board_type = "machine"
	rarity_value = 5
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2)
	req_components = list(
		/obj/item/stock_parts/matter_bin = 3,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/console_screen = 1
	)

/obj/item/electronics/circuitboard/autolathe_disk_cloner
	name = T_BOARD("autolathe disk cloner")
	build_path = /obj/machinery/autolathe_disk_cloner
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2)
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/console_screen = 1
	)

/obj/item/electronics/circuitboard/protolathe
	name = T_BOARD("protolathe")
	build_path = /obj/machinery/autolathe/rnd/protolathe
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2)
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 2
	)

/obj/item/electronics/circuitboard/circuit_imprinter
	name = T_BOARD("circuit imprinter")
	build_path = /obj/machinery/autolathe/rnd/imprinter
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2)
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1
	)

/obj/item/electronics/circuitboard/mechfab
	name = "Circuit board (Exosuit Fabricator)"
	build_path = /obj/machinery/autolathe/mechfab
	board_type = "machine"
	origin_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 3)
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/console_screen = 1
	)

/obj/item/electronics/circuitboard/teleporterstation
	name = "Circuit board (Teleporter station board)"
	build_path = /obj/machinery/teleport/station
	board_type = "machine"
	origin_tech = list(TECH_DATA = 2, TECH_BLUESPACE = 2)
	req_components = list(
		/obj/item/bluespace_crystal/artificial = 3,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/subspace/filter = 1
	)

/obj/item/electronics/circuitboard/teleporterhub
	name = "Circuit board (Teleporter hub board)"
	build_path = /obj/machinery/teleport/hub
	board_type = "machine"
	origin_tech = list(TECH_DATA = 2, TECH_BLUESPACE = 2)
	req_components = list(
		/obj/item/bluespace_crystal/artificial = 2,
		/obj/item/stock_parts/capacitor = 1
	)

/obj/item/electronics/circuitboard/ntnet_relay
	name = "Circuit board (NTNet Quantum Relay)"
	rarity_value = 40
	build_path = /obj/machinery/ntnet_relay
	board_type = "machine"
	origin_tech = list(TECH_DATA = 4)
	req_components = list(
		/obj/item/stack/cable_coil = 15
	)

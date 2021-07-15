/obj/item/electronics/circuitboard/excelsiorshieldwallgen
	name = T_BOARD("excelsior shield wall generator")
	board_type = "machine"
	build_path = /obj/machinery/shieldwallgen/excelsior
	origin_tech = list(TECH_BLUESPACE = 3, TECH_MAGNET = 3, TECH_COVERT = 2)
	req_components = list(
		/obj/item/stock_parts/subspace/transmitter = 1,
		/obj/item/stock_parts/subspace/crystal = 1,
		/obj/item/stock_parts/subspace/amplifier = 1,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stack/cable_coil = 30
	)
	spawn_blacklisted = TRUE

/obj/item/electronics/circuitboard/excelsiorautolathe
	name = T_BOARD("excelsior autoforge")
	build_path = /obj/machinery/autolathe/excelsior
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2, TECH_COVERT = 2)
	req_components = list(
		/obj/item/stock_parts/matter_bin = 3,
		/obj/item/stock_parts/manipulator = 1,
	)
	spawn_blacklisted = TRUE

/obj/item/electronics/circuitboard/excelsiorreconstructor
	name = T_BOARD("excelsior implant reconstructor")
	build_path = /obj/machinery/complant_maker
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 2, TECH_BIOTECH = 3, TECH_COVERT = 2)
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/console_screen = 1
	)
	spawn_blacklisted = TRUE

/obj/item/electronics/circuitboard/diesel
	name = T_BOARD("excelsior diesel generator")
	build_path = /obj/machinery/power/port_gen/pacman/diesel
	board_type = "machine"
	origin_tech = list(TECH_DATA = 3, TECH_POWER = 3, TECH_PLASMA = 3, TECH_ENGINEERING = 3, TECH_COVERT = 2)
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/capacitor = 1
	)
	spawn_blacklisted = TRUE

/obj/item/electronics/circuitboard/excelsior_boombox
	name = T_BOARD("excelsior boombox")
	build_path = /obj/machinery/excelsior_boombox
	board_type = "machine"
	origin_tech = list(TECH_DATA = 3, TECH_COVERT = 1)
	req_components = list(
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/console_screen = 1
	)
	spawn_blacklisted = TRUE

/obj/item/electronics/circuitboard/excelsior_teleporter
	name = T_BOARD("excelsior teleporter")
	build_path = /obj/machinery/complant_teleporter
	board_type = "machine"
	origin_tech = list(TECH_DATA = 3, TECH_BLUESPACE = 3, TECH_COVERT = 2)
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/cell/large = 1,
		/obj/item/stock_parts/subspace/crystal = 1
	)
	spawn_blacklisted = TRUE

/obj/item/electronics/circuitboard/excelsior_turret
	name = T_BOARD("excelsior turret")
	build_path = /obj/machinery/porta_turret/excelsior
	board_type = "machine"
	origin_tech = list(TECH_COMBAT = 3, TECH_COVERT = 2)
	req_components = list(
		/obj/item/gun/projectile/automatic/maxim = 1,
		/obj/item/device/assembly/prox_sensor = 1,
		/obj/item/cell/medium = 1
	)
	spawn_blacklisted = TRUE

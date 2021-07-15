/obj/item/electronics/circuitboard/artist_bench
	name = T_BOARD("artist's bench")
	build_path = /obj/machinery/autolathe/artist_bench
	board_type = "machine"
	origin_tech = list(TECH_MATERIAL = 2, TECH_ENGINEERING = 2)
	req_components = list(
		/obj/item/stock_parts/matter_bin = 3,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/console_screen = 1
	)

/obj/item/electronics/circuitboard/nanoforge
	name = T_BOARD("matter nanoforge")
	build_path = /obj/machinery/autolathe/nanoforge
	board_type = "machine"
	origin_tech = list(TECH_MATERIAL = 2, TECH_ENGINEERING = 5)
	req_components = list(
		/obj/item/stock_parts/matter_bin = 3,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/console_screen = 1
	)
	spawn_frequency = 0

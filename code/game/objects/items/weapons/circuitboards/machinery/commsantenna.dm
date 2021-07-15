/obj/item/electronics/circuitboard/bluespacerelay
	name = T_BOARD("bluespacerelay")
	rarity_value = 40
	build_path = /obj/machinery/bluespacerelay
	board_type = "machine"
	origin_tech = list(TECH_BLUESPACE = 4, TECH_DATA = 4)
	req_components = list(
		/obj/item/stack/cable_coil = 30,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stock_parts/subspace/crystal = 1,
	)
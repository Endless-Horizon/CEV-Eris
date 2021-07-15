#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/electronics/circuitboard/comm_monitor
	name = T_BOARD("telecommunications monitor console")
	build_path = /obj/machinery/computer/telecomms/monitor
	origin_tech = list(TECH_DATA = 3)
	rarity_value = 40

/obj/item/electronics/circuitboard/comm_server
	name = T_BOARD("telecommunications server monitor console")
	build_path = /obj/machinery/computer/telecomms/server
	origin_tech = list(TECH_DATA = 3)
	rarity_value = 40

#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/electronics/circuitboard/message_monitor
	name = T_BOARD("message monitor console")
	rarity_value = 40
	build_path = /obj/machinery/computer/message_monitor
	origin_tech = list(TECH_DATA = 3)

/obj/item/electronics/circuitboard/aiupload
	name = T_BOARD("AI upload console")
	build_path = /obj/machinery/computer/aiupload
	origin_tech = list(TECH_DATA = 4)

/obj/item/electronics/circuitboard/borgupload
	name = T_BOARD("cyborg upload console")
	build_path = /obj/machinery/computer/borgupload
	origin_tech = list(TECH_DATA = 4)

/obj/item/electronics/circuitboard/med_data
	name = T_BOARD("medical records console")
	build_path = /obj/machinery/computer/med_data

/obj/item/electronics/circuitboard/scan_consolenew
	name = T_BOARD("DNA machine")
	build_path = /obj/machinery/computer/scan_consolenew
	origin_tech = list(TECH_DATA = 2, TECH_BIO = 2)

/obj/item/electronics/circuitboard/communications
	name = T_BOARD("command and communications console")
	build_path = /obj/item/modular_computer/console/preset/command
	origin_tech = list(TECH_DATA = 2, TECH_MAGNET = 2)

/obj/item/electronics/circuitboard/teleporter
	name = T_BOARD("teleporter control console")
	rarity_value = 40
	build_path = /obj/machinery/computer/teleporter
	origin_tech = list(TECH_DATA = 2, TECH_BLUESPACE = 2)

/obj/item/electronics/circuitboard/secure_data
	name = T_BOARD("security records console")
	build_path = /obj/machinery/computer/secure_data

/obj/item/electronics/circuitboard/atmos_alert
	rarity_value = 13.3
	name = T_BOARD("atmospheric alert console")
	build_path = /obj/machinery/computer/atmos_alert

/obj/item/electronics/circuitboard/pod
	name = T_BOARD("massdriver control")
	build_path = /obj/machinery/computer/pod

/obj/item/electronics/circuitboard/robotics
	name = T_BOARD("robotics control console")
	rarity_value = 40
	build_path = /obj/machinery/computer/robotics
	origin_tech = list(TECH_DATA = 3)

/obj/item/electronics/circuitboard/drone_control
	name = T_BOARD("drone control console")
	build_path = /obj/machinery/computer/drone_control
	origin_tech = list(TECH_DATA = 3)

/obj/item/electronics/circuitboard/arcade/battle
	name = T_BOARD("battle arcade machine")
	build_path = /obj/machinery/computer/arcade/battle
	rarity_value = 13.3
	origin_tech = list(TECH_DATA = 1)

/obj/item/electronics/circuitboard/arcade/orion_trail
	name = T_BOARD("orion trail arcade machine")
	build_path = /obj/machinery/computer/arcade/orion_trail
	origin_tech = list(TECH_DATA = 1)

/obj/item/electronics/circuitboard/turbine_control
	name = T_BOARD("turbine control console")
	build_path = /obj/machinery/computer/turbine_computer

/obj/item/electronics/circuitboard/solar_control
	name = T_BOARD("solar control console")
	rarity_value = 40
	build_path = /obj/machinery/power/solar_control
	origin_tech = list(TECH_DATA = 2, TECH_POWER = 2)

/obj/item/electronics/circuitboard/powermonitor
	name = T_BOARD("power monitoring console")
	build_path = /obj/machinery/computer/power_monitor

/obj/item/electronics/circuitboard/olddoor
	name = T_BOARD("DoorMex")
	build_path = /obj/machinery/computer/pod/old

/obj/item/electronics/circuitboard/syndicatedoor
	name = T_BOARD("ProComp Executive")
	build_path = /obj/machinery/computer/pod/old/syndicate

/obj/item/electronics/circuitboard/swfdoor
	name = T_BOARD("Magix")
	build_path = /obj/machinery/computer/pod/old/swf

/obj/item/electronics/circuitboard/prisoner
	name = T_BOARD("prisoner management console")
	build_path = /obj/machinery/computer/prisoner

/obj/item/electronics/circuitboard/rdservercontrol
	name = T_BOARD("R&D server control console")
	build_path = /obj/machinery/computer/rdservercontrol

/obj/item/electronics/circuitboard/operating
	name = T_BOARD("patient monitoring console")
	build_path = /obj/machinery/computer/operating
	origin_tech = list(TECH_DATA = 2, TECH_BIO = 2)

/obj/item/electronics/circuitboard/curefab
	name = T_BOARD("cure fabricator")
	rarity_value = 40
	build_path = /obj/machinery/computer/curer

/obj/item/electronics/circuitboard/splicer
	name = T_BOARD("disease splicer")
	rarity_value = 40
	build_path = /obj/machinery/computer/diseasesplicer

/obj/item/electronics/circuitboard/centrifuge
	name = T_BOARD("centrifuge")
	build_path = /obj/machinery/centrifuge
	origin_tech = list(TECH_DATA = 2, TECH_BIO = 2)
	req_components = list(
		/obj/item/stock_parts/manipulator = 3
	)

/obj/item/electronics/circuitboard/helm
	name = T_BOARD("helm control console")
	build_path = /obj/machinery/computer/helm

/obj/item/electronics/circuitboard/nav
	name = T_BOARD("navigation console")
	build_path = /obj/machinery/computer/navigation

/obj/item/electronics/circuitboard/ordercomp
	name = T_BOARD("supply ordering console")
	rarity_value = 40
	build_path = /obj/machinery/computer/supplycomp/order
	origin_tech = list(TECH_DATA = 2)

/obj/item/electronics/circuitboard/shuttle
	spawn_blacklisted = TRUE
	bad_type = /obj/item/electronics/circuitboard/shuttle

/obj/item/electronics/circuitboard/shuttle/mining
	name = T_BOARD("mining shuttle console")
	build_path = /obj/machinery/computer/shuttle_control/mining
	origin_tech = list(TECH_DATA = 2)

/obj/item/electronics/circuitboard/shuttle/engineering
	name = T_BOARD("engineering shuttle console")
	build_path = /obj/machinery/computer/shuttle_control/engineering
	origin_tech = list(TECH_DATA = 2)

/obj/item/electronics/circuitboard/shuttle/research
	name = T_BOARD("research shuttle console")
	build_path = /obj/machinery/computer/shuttle_control/research
	origin_tech = list(TECH_DATA = 2)

/obj/item/electronics/circuitboard/aifixer
	name = T_BOARD("AI integrity restorer")
	rarity_value = 40
	build_path = /obj/machinery/computer/aifixer
	origin_tech = list(TECH_DATA = 3, TECH_BIO = 2)

/obj/item/electronics/circuitboard/area_atmos
	name = T_BOARD("area air control console")
	rarity_value = 40
	build_path = /obj/machinery/computer/area_atmos
	origin_tech = list(TECH_DATA = 2)

/obj/item/electronics/circuitboard/prison_shuttle
	name = T_BOARD("prison shuttle control console")
	build_path = /obj/machinery/computer/prison_shuttle
	origin_tech = list(TECH_DATA = 2)

/obj/item/electronics/circuitboard/engines
	name = T_BOARD("engine control console")
	build_path = /obj/machinery/computer/engines
	origin_tech = list(TECH_DATA = 2)

/obj/item/electronics/circuitboard/guestpass
	name = T_BOARD("guest pass console")
	build_path = /obj/machinery/computer/guestpass
	origin_tech = list(TECH_DATA = 2)

/obj/item/electronics/circuitboard/jtb
	name = T_BOARD("junk tractor beam control console")
	build_path = /obj/machinery/computer/jtb_console

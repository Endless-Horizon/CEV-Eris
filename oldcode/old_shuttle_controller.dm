
var/global/datum/shuttle_controller/shuttle_controller


/datum/shuttle_controller
	var/list/shuttles	//maps shuttle tags to shuttle datums, so that they can be looked up.
	var/list/process_shuttles	//simple list of shuttles, for processing

/datum/shuttle_controller/proc/process()
	//process ferry shuttles
	for (var/datum/shuttle/ferry/shuttle in process_shuttles)
		if (shuttle.process_state)
			shuttle.process()


//This is called by gameticker after all the machines and radio frequencies have been properly initialized
/datum/shuttle_controller/proc/setup_shuttle_docks()
	for(var/shuttle_tag in shuttles)
		var/datum/shuttle/shuttle = shuttles[shuttle_tag]
		shuttle.init_docking_controllers()
		shuttle.dock() //makes all shuttles docked to something at round start go into the docked state

	for(var/obj/machinery/embedded_controller/C in GLOB.machines)
		if(istype(C.program, /datum/computer/file/embedded_program/docking))
			C.program.tag = null //clear the tags, 'cause we don't need 'em anymore

/datum/shuttle_controller/New()
	shuttles = list()
	process_shuttles = list()

	var/datum/shuttle/ferry/shuttle

	shuttle = new/datum/shuttle/ferry/escape_pod()
	shuttle.location = 0
	shuttle.warmup_time = 0
	shuttle.area_station = locate(/area/shuttle/escape_pod1/station)
	shuttle.area_offsite = locate(/area/shuttle/escape_pod1/centcom)
	shuttle.area_transition = locate(/area/shuttle/escape_pod1/transit)
	shuttle.docking_controller_tag = "escape_pod_1"
	shuttle.dock_target_station = "escape_pod_1_berth"
	shuttle.dock_target_offsite = "escape_pod_1_recovery"
	shuttle.transit_direction = NORTH
	shuttle.move_time = PODS_TRANSIT
	process_shuttles += shuttle
	shuttles["Escape Pod 1"] = shuttle

	shuttle = new/datum/shuttle/ferry/escape_pod()
	shuttle.location = 0
	shuttle.warmup_time = 0
	shuttle.area_station = locate(/area/shuttle/escape_pod2/station)
	shuttle.area_offsite = locate(/area/shuttle/escape_pod2/centcom)
	shuttle.area_transition = locate(/area/shuttle/escape_pod2/transit)
	shuttle.docking_controller_tag = "escape_pod_2"
	shuttle.dock_target_station = "escape_pod_2_berth"
	shuttle.dock_target_offsite = "escape_pod_2_recovery"
	shuttle.transit_direction = NORTH
	shuttle.move_time = PODS_TRANSIT
	process_shuttles += shuttle
	shuttles["Escape Pod 2"] = shuttle

	//There is no pod 4, apparently.

	//give the emergency shuttle controller it's shuttles
	//emergency_shuttle.shuttle = shuttles["Escape"]
	emergency_shuttle.escape_pods = list(
		shuttles["Escape Pod 1"],
		shuttles["Escape Pod 2"],
	)

	// Supply shuttle
	shuttle = new/datum/shuttle/ferry/supply()
	shuttle.location = 1
	shuttle.warmup_time = 10
	shuttle.area_offsite = locate(/area/supply/dock)
	shuttle.area_station = locate(/area/supply/station)
	shuttle.docking_controller_tag = "supply_shuttle"
	shuttle.dock_target_station = "cargo_bay"
	shuttles["Supply"] = shuttle
	process_shuttles += shuttle

	supply_controller.shuttle = shuttle

	// Public shuttles

	shuttle = new()
	shuttle.warmup_time = 10
	shuttle.area_offsite = locate(/area/shuttle/mining/outpost)
	shuttle.area_station = locate(/area/shuttle/mining/station)
	shuttle.docking_controller_tag = "mining_shuttle"
	shuttle.dock_target_station = "mining_dock_airlock"
	shuttle.dock_target_offsite = "mining_outpost_airlock"
	shuttles["Mining"] = shuttle
	process_shuttles += shuttle

	shuttle = new()
	shuttle.warmup_time = 10
	shuttle.area_offsite = locate(/area/shuttle/research/outpost)
	shuttle.area_station = locate(/area/shuttle/research/station)
	shuttle.docking_controller_tag = "research_shuttle"
	shuttle.dock_target_station = "research_dock_airlock"
	shuttle.dock_target_offsite = "research_outpost_dock"
	shuttles["Research"] = shuttle
	process_shuttles += shuttle

	//Skipjack.
	var/datum/shuttle/multi_shuttle/VS = new/datum/shuttle/multi_shuttle()
	VS.origin = locate(/area/skipjack_station/start)

	VS.destinations = list(
		"Fore Starboard Solars" = locate(/area/skipjack_station/northeast_solars),
		"Fore Port Solars" = locate(/area/skipjack_station/northwest_solars),
		"Aft Starboard Solars" = locate(/area/skipjack_station/southeast_solars),
		"Aft Port Solars" = locate(/area/skipjack_station/southwest_solars),
		"Mining Station" = locate(/area/skipjack_station/mining)
		)

	VS.announcer = "NDV Icarus"
	VS.arrival_message = "Attention, [station_short], we just tracked a small target bypassing our defensive perimeter. Can't fire on it without hitting the station - you've got incoming visitors, like it or not."
	VS.departure_message = "Your guests are pulling away, [station_short] - moving too fast for us to draw a bead on them. Looks like they're heading out of the system at a rapid clip."
	VS.interim = locate(/area/skipjack_station/transit)

	VS.warmup_time = 0
	shuttles["Skipjack"] = VS

	//Nuke Ops shuttle.
	var/datum/shuttle/multi_shuttle/MS = new/datum/shuttle/multi_shuttle()
	MS.origin = locate(/area/syndicate_station/start)
	MS.start_location = "Mercenary Base"

	MS.destinations = list(
		"Northwest of the station" = locate(/area/syndicate_station/northwest),
		"North of the station" = locate(/area/syndicate_station/north),
		"Northeast of the station" = locate(/area/syndicate_station/northeast),
		"Southwest of the station" = locate(/area/syndicate_station/southwest),
		"South of the station" = locate(/area/syndicate_station/south),
		"Southeast of the station" = locate(/area/syndicate_station/southeast),
		"Telecomms Satellite" = locate(/area/syndicate_station/commssat),
		"Mining Station" = locate(/area/syndicate_station/mining),
		"Arrivals dock" = locate(/area/syndicate_station/arrivals_dock),
		)

	MS.docking_controller_tag = "merc_shuttle"
	MS.destination_dock_targets = list(
		"Mercenary Base" = "merc_base",
		"Arrivals dock" = "nuke_shuttle_dock_airlock",
		)

	MS.announcer = "NDV Icarus"
	MS.arrival_message = "Attention, [station_short], you have a large signature approaching the station - looks unarmed to surface scans. We're too far out to intercept - brace for visitors."
	MS.departure_message = "Your visitors are on their way out of the system, [station_short], burning delta-v like it's nothing. Good riddance."
	MS.interim = locate(/area/syndicate_station/transit)

	MS.warmup_time = 0
	shuttles["Mercenary"] = MS


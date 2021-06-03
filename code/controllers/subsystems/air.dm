/*

Overview:
	The air controller does everything. There are tons of procs in here.

Class Vars:
	zones - All zones currently holding one or more turfs.
	edges - All processing edges.

	tiles_to_update - Tiles scheduled to update next tick.
	zones_to_update - Zones which have had their air changed and need air archival.
	active_hotspots - All processing fire objects.

	active_zones - The number of zones which were archived last tick. Used in debug verbs.
	next_id - The next UID to be applied to a zone. Mostly useful for debugging purposes as zones do not need UIDs to function.

Class Procs:

	mark_for_update(turf/T)
		Adds the turf to the update list. When updated, update_air_properties() will be called.
		When stuff changes that might affect airflow, call this. It's basically the only thing you need.

	add_zone(zone/Z) and remove_zone(zone/Z)
		Adds zones to the zones list. Does not mark them for update.

	air_blocked(turf/A, turf/B)
		Returns a bitflag consisting of:
		AIR_BLOCKED - The connection between turfs is physically blocked. No air can pass.
		ZONE_BLOCKED - There is a door between the turfs, so zones cannot cross. Air may or may not be permeable.

	has_valid_zone(turf/T)
		Checks the presence and validity of T's zone.
		May be called on unsimulated turfs, returning 0.

	merge(zone/A, zone/B)
		Called when zones have a direct connection and equivalent pressure and temperature.
		Merges the zones to create a single zone.

	connect(turf/simulated/A, turf/B)
		Called by turf/update_air_properties(). The first argument must be simulated.
		Creates a connection between A and B.

	mark_zone_update(zone/Z)
		Adds zone to the update list. Unlike mark_for_update(), this one is called automatically whenever
		air is returned from a simulated turf.

	equivalent_pressure(zone/A, zone/B)
		Currently identical to A.air.compare(B.air). Returns 1 when directly connected zones are ready to be merged.

	get_edge(zone/A, zone/B)
	get_edge(zone/A, turf/B)
		Gets a valid connection_edge between A and B, creating a new one if necessary.

	has_same_air(turf/A, turf/B)
		Used to determine if an unsimulated edge represents a specific turf.
		Simulated edges use connection_edge/contains_zone() for the same purpose.
		Returns 1 if A has identical gases and temperature to B.

	remove_edge(connection_edge/edge)
		Called when an edge is erased. Removes it from processing.

*/

SUBSYSTEM_DEF(air)
	name = "Atmospherics"
	init_order = INIT_ORDER_AIR
	priority = FIRE_PRIORITY_AIR
	wait = 0.5 SECONDS
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/cached_cost = 0

	var/cost_pipenets = 0
	var/cost_atmos_machinery = 0
	var/cost_tiles = 0
	var/cost_tiles_defered = 0
	var/cost_hotspots = 0
	var/cost_fire = 0
	var/cost_zone = 0
	var/cost_edges = 0

	//Geometry lists
	var/list/zones = list()
	var/list/edges = list()

	//Geometry updates lists
	var/list/tiles_to_update = list()
	var/list/zones_to_update = list()
	var/list/active_fire_zones = list()
	var/list/active_hotspots = list()
	var/list/networks = list()
	var/list/active_edges = list()
	/// A list of machines that will be processed when currentpart == SSAIR_ATMOSMACHINERY. Use SSair.begin_processing_machine and SSair.stop_processing_machine to add and remove machines.
	var/list/obj/machinery/atmos_machinery = list()
	var/list/pipe_init_dirs_cache = list()

	var/list/deferred = list() // todo: see if this is needed at all with the new system
	var/list/processing_edges = list()
	var/list/processing_fires = list()
	var/list/processing_hotspots = list()
	var/list/processing_zones = list()

	var/active_zones = 0
	var/next_id = 1

	/// A cache of objects that perisists between processing runs when resumed == TRUE. Dangerous, qdel'd objects not cleared from this may cause runtimes on processing.
	var/list/currentrun = list() // defered 2
	var/currentpart = SSAIR_PIPENETS

	var/map_loading = TRUE
	// var/list/queued_for_activation
	var/display_all_groups = FALSE

/datum/controller/subsystem/air/proc/reboot()
	// Stop processing while we rebuild.
	can_fire = FALSE

	// Make sure we don't rebuild mid-tick.
	if (state != SS_IDLE)
		to_chat(admins, "<span class='boldannounce'>ZAS Rebuild initiated. Waiting for current air tick to complete before continuing.</span>")
		while (state != SS_IDLE)
			stoplag()

	while (zones.len)
		var/zone/zone = zones[zones.len]
		zones.len--

		zone.c_invalidate()

	edges.Cut()
	tiles_to_update.Cut()
	zones_to_update.Cut()
	active_fire_zones.Cut()
	active_hotspots.Cut()
	active_edges.Cut()

	// Re-run setup without air settling.
	Initialize(REALTIMEOFDAY, simulate = FALSE)

	// Update next_fire so the MC doesn't try to make up for missed ticks.
	next_fire = world.time + wait
	can_fire = TRUE

/datum/controller/subsystem/air/stat_entry()
	var/list/out = list(
		"TtU:[tiles_to_update.len] ",
		"ZtU:[zones_to_update.len] ",
		"AFZ:[active_fire_zones.len] ",
		"AH:[active_hotspots.len] ",
		"AE:[active_edges.len]"
	)
	..(out.Join())

/datum/controller/subsystem/air/Initialize(timeofday, simulate = TRUE)
	map_loading = FALSE
	var/starttime = REALTIMEOFDAY
	// setup allturfs
	to_chat(admins, "<span class='boldannounce'>Processing Geometry...</span>")
	var/simulated_turf_count = 0
	for(var/turf/simulated/S)
		simulated_turf_count++
		S.update_air_properties()

		CHECK_TICK
	to_chat(admins, {"<span class='boldannounce'>Total Simulated Turfs: [simulated_turf_count]
Total Zones: [zones.len]
Total Edges: [edges.len]
Total Active Edges: [active_edges.len ? "<span class='danger'>[active_edges.len]</span>" : "None"]
Total Unsimulated Turfs: [world.maxx*world.maxy*world.maxz - simulated_turf_count]</span>"})
	to_chat(admins, "<span class='boldannounce'>Geometry processing completed in [(REALTIMEOFDAY - starttime)/10] seconds!</span>")
	// setup allturfs 2
	if (simulate)
		to_chat(admins, "<span class='boldannounce'>Settling air...</span>")
		starttime = REALTIMEOFDAY
		process_active_turfs(FALSE, TRUE)
		process_active_turfs_defered(FALSE, TRUE)
		process_edges(FALSE, TRUE)
		process_zasfire(FALSE, TRUE)
		process_hotspots(FALSE, TRUE)
		process_zone(FALSE, TRUE)
		to_chat(admins, "<span class='boldannounce'>Air settling completed in [(REALTIMEOFDAY - starttime)/10] seconds!</span>")

	setup_atmos_machinery()
	setup_pipenets()

	return ..()

/datum/controller/subsystem/air/fire(resumed = FALSE, no_mc_tick = FALSE)
	var/timer = TICK_USAGE_REAL

	if(currentpart == SSAIR_PIPENETS || !resumed)
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_pipenets(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_pipenets = MC_AVERAGE(cost_pipenets, TICK_DELTA_TO_MS(cached_cost))
		resumed = FALSE
		currentpart = SSAIR_ATMOSMACHINERY

	if(currentpart == SSAIR_ATMOSMACHINERY)
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_atmos_machinery(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_atmos_machinery = MC_AVERAGE(cost_atmos_machinery, TICK_DELTA_TO_MS(cached_cost))
		resumed = FALSE
		currentpart = SSAIR_ACTIVETURFS

	if(currentpart == SSAIR_ACTIVETURFS)
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_active_turfs(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_tiles = MC_AVERAGE(cost_tiles, TICK_DELTA_TO_MS(cached_cost))
		resumed = FALSE
		currentpart = SSAIR_DEFER_AT

	if(currentpart == SSAIR_DEFER_AT)
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_active_turfs_defered(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_tiles_defered = MC_AVERAGE(cost_tiles_defered, TICK_DELTA_TO_MS(cached_cost))
		resumed = FALSE
		currentpart = SSAIR_EDGES

	if(currentpart == SSAIR_EDGES)
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_edges(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_edges = MC_AVERAGE(cost_edges, TICK_DELTA_TO_MS(cached_cost))
		resumed = FALSE
		currentpart = SSAIR_FIRE

	if(currentpart == SSAIR_FIRE) //We do this before excited groups to allow breakdowns to be independent of adding turfs while still *mostly preventing mass fires
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_zasfire(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_fire = MC_AVERAGE(cost_fire, TICK_DELTA_TO_MS(cached_cost))
		resumed = FALSE
		currentpart = SSAIR_HOTSPOTS

	if(currentpart == SSAIR_HOTSPOTS) //We do this before excited groups to allow breakdowns to be independent of adding turfs while still *mostly preventing mass fires
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_hotspots(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_hotspots = MC_AVERAGE(cost_hotspots, TICK_DELTA_TO_MS(cached_cost))
		resumed = FALSE
		currentpart = SSAIR_ZONE

	if(currentpart == SSAIR_ZONE) //We do this before excited groups to allow breakdowns to be independent of adding turfs while still *mostly preventing mass fires
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_zone(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_zone = MC_AVERAGE(cost_zone, TICK_DELTA_TO_MS(cached_cost))
		resumed = FALSE

	currentpart = SSAIR_PIPENETS
	SStgui.update_uis(SSair) //Lightning fast debugging motherfucker

/datum/controller/subsystem/air/proc/process_pipenets(resumed = FALSE)
	if (!resumed)
		src.currentrun = networks.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/datum/thing = currentrun[currentrun.len]
		currentrun.len--
		if(thing)
			thing.process()
		else
			networks.Remove(thing)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_atmos_machinery(resumed = FALSE)
	if (!resumed)
		src.currentrun = atmos_machinery.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/obj/machinery/M = currentrun[currentrun.len]
		currentrun.len--
		if(!M)
			atmos_machinery -= M
		if(M.process_atmos() == PROCESS_KILL)
			stop_processing_machine(M)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_active_turfs(resumed = FALSE, setup = FALSE)
	//cache for sanic speed
	// var/fire_count = times_fired
	if (!resumed)
		src.currentrun = tiles_to_update.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/turf/T = currentrun[currentrun.len]
		currentrun.len--
		if (T)
			//check if the turf is self-zone-blocked
			if(T.c_airblock(T) & ZONE_BLOCKED)
				deferred += T
				if (MC_TICK_CHECK)
					return
			// T.process_cell(fire_count)
			T.update_air_properties()
			T.post_update_air_properties()
			T.needs_air_update = FALSE
			#ifdef ZASDBG
			T.remove_overlays(mark)
			#endif

		if (MC_TICK_CHECK && !setup)
			return

/datum/controller/subsystem/air/proc/process_active_turfs_defered(resumed = FALSE, setup = FALSE)
	//cache for sanic speed
	// var/fire_count = times_fired
	if (!resumed)
		src.currentrun = deferred.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/turf/T = currentrun[currentrun.len]
		currentrun.len--
		if (T)
			// T.process_cell(fire_count)
			T.update_air_properties()
			T.post_update_air_properties()
			T.needs_air_update = FALSE
			#ifdef ZASDBG
			T.remove_overlays(mark)
			#endif

		if (MC_TICK_CHECK && !setup)
			return

/datum/controller/subsystem/air/proc/process_edges(resumed = FALSE, setup = FALSE)
	if (!resumed)
		src.currentrun = processing_edges.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/connection_edge/E = currentrun[currentrun.len]
		currentrun.len--
		if (E)
			E.tick()

		if (MC_TICK_CHECK && !setup)
			return

/datum/controller/subsystem/air/proc/process_zasfire(resumed = FALSE, setup = FALSE)
	if (!resumed)
		src.currentrun = processing_fires.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while (currentrun.len)
		var/zone/Z = currentrun[currentrun.len]
		currentrun.len--
		if(Z)
			Z.process_fire()
		else
			processing_fires -= Z
		if (MC_TICK_CHECK && !setup)
			return

/datum/controller/subsystem/air/proc/process_hotspots(resumed = FALSE, setup = FALSE)
	if (!resumed)
		src.currentrun = processing_hotspots.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len) // i kid you not, hotspots are fire
		var/obj/fire/H = currentrun[currentrun.len]
		currentrun.len--
		if (H)
			H.process()
		else
			processing_hotspots -= H
		if (MC_TICK_CHECK && !setup)
			return

/datum/controller/subsystem/air/proc/process_zone(resumed = FALSE, setup = FALSE)
	if (!resumed)
		src.currentrun = processing_zones.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len) // i kid you not, hotspots are fire
		var/zone/Z = currentrun[currentrun.len]
		currentrun.len--
		if (Z)
			Z.tick()
			Z.needs_update = FALSE
		else
			processing_zones -= Z // merging zones probably has a chance to null, so safety is gud
		if (MC_TICK_CHECK && !setup)
			return

/datum/controller/subsystem/air/proc/add_zone(zone/z)
	zones += z
	z.name = "Zone [next_id++]"
	mark_zone_update(z)

/datum/controller/subsystem/air/proc/remove_zone(zone/z)
	zones -= z
	zones_to_update -= z
	if (processing_zones)
		processing_zones -= z

/datum/controller/subsystem/air/proc/air_blocked(turf/A, turf/B)
	#ifdef ZASDBG
	ASSERT(isturf(A))
	ASSERT(isturf(B))
	#endif
	var/ablock = A.c_airblock(B)
	if(ablock == BLOCKED) return BLOCKED
	return ablock | B.c_airblock(A)

/datum/controller/subsystem/air/proc/merge(zone/A, zone/B)
	#ifdef ZASDBG
	ASSERT(istype(A))
	ASSERT(istype(B))
	ASSERT(!A.invalid)
	ASSERT(!B.invalid)
	ASSERT(A != B)
	#endif
	if(A.contents.len < B.contents.len)
		A.c_merge(B)
		mark_zone_update(B)
	else
		B.c_merge(A)
		mark_zone_update(A)

/datum/controller/subsystem/air/proc/connect(turf/simulated/A, turf/simulated/B)
	#ifdef ZASDBG
	ASSERT(istype(A))
	ASSERT(isturf(B))
	ASSERT(A.zone)
	ASSERT(!A.zone.invalid)
	//ASSERT(B.zone)
	ASSERT(A != B)
	#endif

	var/block = air_blocked(A,B)
	if(block & AIR_BLOCKED) return

	var/direct = !(block & ZONE_BLOCKED)
	var/space = !istype(B)

	if(!space)
		if(min(A.zone.contents.len, B.zone.contents.len) < ZONE_MIN_SIZE || (direct && (equivalent_pressure(A.zone,B.zone) || times_fired == 0)))
			merge(A.zone,B.zone)
			return

	var/a_to_b = get_dir(A,B)
	var/b_to_a = get_dir(B,A)

	if(!A.connections) A.connections = new
	if(!B.connections) B.connections = new

	if(A.connections.get(a_to_b))
		return
	if(B.connections.get(b_to_a))
		return
	if(!space)
		if(A.zone == B.zone) return


	var/connection/c = new /connection(A,B)

	A.connections.place(c, a_to_b)
	B.connections.place(c, b_to_a)

	if(direct) c.mark_direct()

/datum/controller/subsystem/air/proc/mark_for_update(turf/T)
	#ifdef ZASDBG
	ASSERT(isturf(T))
	#endif
	if(T.needs_air_update)
		return
	tiles_to_update += T
	#ifdef ZASDBG
	T.add_overlays(mark)
	#endif
	T.needs_air_update = 1

/datum/controller/subsystem/air/proc/mark_zone_update(zone/Z)
	#ifdef ZASDBG
	ASSERT(istype(Z))
	#endif
	if(Z.needs_update)
		return
	zones_to_update += Z
	Z.needs_update = 1

/datum/controller/subsystem/air/proc/mark_edge_sleeping(connection_edge/E)
	#ifdef ZASDBG
	ASSERT(istype(E))
	#endif
	if(E.sleeping)
		return
	active_edges -= E
	E.sleeping = 1

/datum/controller/subsystem/air/proc/mark_edge_active(connection_edge/E)
	#ifdef ZASDBG
	ASSERT(istype(E))
	#endif
	if(!E.sleeping)
		return
	active_edges += E
	E.sleeping = 0

/datum/controller/subsystem/air/proc/equivalent_pressure(zone/A, zone/B)
	return A.air.compare(B.air)

/datum/controller/subsystem/air/proc/get_edge(zone/A, zone/B)
	if(istype(B))
		for(var/connection_edge/zone/edge in A.edges)
			if(edge.contains_zone(B))
				return edge
		var/connection_edge/edge = new/connection_edge/zone(A,B)
		edges += edge
		edge.recheck()
		return edge
	else
		for(var/connection_edge/unsimulated/edge in A.edges)
			if(has_same_air(edge.B,B))
				return edge
		var/connection_edge/edge = new/connection_edge/unsimulated(A,B)
		edges += edge
		edge.recheck()
		return edge

/datum/controller/subsystem/air/proc/has_same_air(turf/A, turf/B)
	if(A.oxygen != B.oxygen) return 0
	if(A.nitrogen != B.nitrogen) return 0
	if(A.plasma != B.plasma) return 0
	if(A.carbon_dioxide != B.carbon_dioxide) return 0
	if(A.temperature != B.temperature) return 0
	return 1

/datum/controller/subsystem/air/proc/remove_edge(connection_edge/E)
	edges -= E
	if(!E.sleeping)
		active_edges -= E
	if(processing_edges)
		processing_edges -= E

/datum/controller/subsystem/air/proc/setup_atmos_machinery()
	for (var/obj/machinery/atmospherics/AM in atmos_machinery)
		AM.atmos_init()
		CHECK_TICK
	for(var/obj/machinery/atmospherics/unary/U in atmos_machinery)
		if(istype(U, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = U
			T.broadcast_status()
		else if(istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = U
			T.broadcast_status() // move this to unary level
		CHECK_TICK

//this can't be done with setup_atmos_machinery() because
// all atmos machinery has to initalize before the first
// pipenet can be built.
/datum/controller/subsystem/air/proc/setup_pipenets()
	for(var/obj/machinery/atmospherics/AM in atmos_machinery)
		AM.build_network()
		CHECK_TICK

/datum/controller/subsystem/air/proc/setup_template_machinery(list/atmos_machines)
	var/obj/machinery/atmospherics/AM
	for(var/A in 1 to atmos_machines.len)
		AM = atmos_machines[A]
		AM.atmos_init()
		if(istype(AM, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = AM
			T.broadcast_status()
		else if(istype(AM, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = AM
			T.broadcast_status() // move this to unary level
		CHECK_TICK

	for(var/A in 1 to atmos_machines.len)
		AM = atmos_machines[A]
		AM.build_network()
		CHECK_TICK

/**
 * Adds a given machine to the processing system for SSAIR_ATMOSMACHINERY processing.
 *
 * Arguments:
 * * machine - The machine to start processing. Can be any /obj/machinery.
 */
/datum/controller/subsystem/air/proc/start_processing_machine(obj/machinery/machine)
	if(machine.atmos_processing)
		return
	machine.atmos_processing = TRUE
	atmos_machinery += machine

/**
 * Removes a given machine to the processing system for SSAIR_ATMOSMACHINERY processing.
 *
 * Arguments:
 * * machine - The machine to stop processing.
 */
/datum/controller/subsystem/air/proc/stop_processing_machine(obj/machinery/machine)
	if(!machine.atmos_processing)
		return
	machine.atmos_processing = FALSE
	atmos_machinery -= machine

	// If we're currently processing atmos machines, there's a chance this machine is in
	// the currentrun list, which is a cache of atmos_machinery. Remove it from that list
	// as well to prevent processing qdeleted objects in the cache.
	if(currentpart == SSAIR_ATMOSMACHINERY)
		currentrun -= machine

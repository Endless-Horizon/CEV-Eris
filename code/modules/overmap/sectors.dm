//===================================================================================
//Overmap object representing zlevel(s)
//===================================================================================
/obj/effect/overmap
	name = "unknown spatial phenomenon"
	icon = 'icons/obj/overmap.dmi'
	icon_state = "poi"
	bad_type = /obj/effect/overmap
	spawn_tags = null
	var/list/map_z = list()

	var/list/generic_waypoints = list()    //waypoints that any shuttle can use
	var/list/restricted_waypoints = list() //waypoints for specific shuttles

	var/start_x			//coordinates on the
	var/start_y			//overmap zlevel

	var/base = 0		//starting sector, counts as station_levels
	var/known = 1		//shows up on nav computers automatically
	var/in_space = 1	//can be accessed via lucky EVA

	var/global/eris_start_set = FALSE //Tells us if we need to modify a random location for Eris to start at
	var/global/eris

	// Stage 0: close, well scanned by sensors
	// Stage 1: medium, barely scanned by sensors
	// Stage 2: far, not scanned by sensors
	var/list/name_stages = list("stage0", "stage1", "stage2")
	var/list/icon_stages = list("generic", "object", "poi")

/obj/effect/overmap/Initialize()
	. = ..()

	if(!config.use_overmap)
		return

	map_z = GetConnectedZlevels(z)
	for(var/zlevel in map_z)
		map_sectors["[zlevel]"] = src

	// Spawning location of area is randomized or default values, but can be changed to the Eris Coordinates in the code below.
	// This provides a random starting location for Eris.
	start_x = start_x || rand(OVERMAP_EDGE, GLOB.maps_data.overmap_size - OVERMAP_EDGE)
	start_y = start_y || rand(OVERMAP_EDGE, GLOB.maps_data.overmap_size - OVERMAP_EDGE)

	if ((!eris_start_set) && (name == config.start_location))
		var/obj/effect/overmap/ship/eris/E = ships[eris]
		start_x = E.start_x
		start_y = E.start_y
		eris_start_set = TRUE

	forceMove(locate(start_x, start_y, GLOB.maps_data.overmap_z))
	testing("Located sector \"[name_stages[1]]\" at [start_x],[start_y], containing Z [english_list(map_z)]")

	GLOB.maps_data.player_levels |= map_z

	if(!in_space)
		GLOB.maps_data.sealed_levels |= map_z

	if(base)
		GLOB.maps_data.station_levels |= map_z
		GLOB.maps_data.contact_levels |= map_z


	//handle automatic waypoints that spawned before us
	for(var/obj/effect/shuttle_landmark/automatic/L in GLOB.shuttle_landmarks_list)
		if(L.z in map_z)
			L.add_to_sector(src, 1)

	//find shuttle waypoints
	var/list/found_waypoints = list()
	for(var/waypoint_tag in generic_waypoints)
		var/obj/effect/shuttle_landmark/WP = locate(waypoint_tag)
		if(WP)
			found_waypoints += WP
		else
			admin_notice("Sector \"[name_stages[1]]\" containing Z [english_list(map_z)] could not find waypoint with tag [waypoint_tag]!")
	generic_waypoints = found_waypoints

	for(var/shuttle_name in restricted_waypoints)
		found_waypoints = list()
		for(var/waypoint_tag in restricted_waypoints[shuttle_name])
			var/obj/effect/shuttle_landmark/WP = locate(waypoint_tag)
			if(WP)
				found_waypoints += WP
			else
				admin_notice("Sector \"[name_stages[1]]\" containing Z [english_list(map_z)] could not find waypoint with tag [waypoint_tag]!")
		restricted_waypoints[shuttle_name] = found_waypoints

	for(var/obj/machinery/computer/sensors/S in GLOB.machines)
		if (S.z in map_z)
			S.linked = src

/obj/effect/overmap/proc/get_waypoints(var/shuttle_name)
	. = generic_waypoints.Copy()
	if(shuttle_name in restricted_waypoints)
		. += restricted_waypoints[shuttle_name]

/obj/effect/overmap/sector
	name = "generic sector"
	desc = "Sector with some stuff in it."
	icon_state = "poi"
	anchored = TRUE

/obj/effect/overmap/sector/Initialize()
	. = ..()
	if(known)
		layer = 2
		set_plane(-1)
		for(var/obj/machinery/computer/helm/H in GLOB.machines)
			H.get_known_sectors()

/obj/effect/overmap/proc/add_landmark(obj/effect/shuttle_landmark/landmark)
	generic_waypoints += landmark

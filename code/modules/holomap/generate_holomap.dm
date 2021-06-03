//
// Holomap generation.
// Based on /vg/station but trimmed down (without antag stuff) and massively optimized (you should have seen it before!) ~Leshana
//

// Define what criteria makes a turf a path or not

// Turfs that will be colored as HOLOMAP_ROCK
#define IS_ROCK(tile) (istype(tile, /turf/simulated/mineral) && tile.density)

// Turfs that will be colored as HOLOMAP_OBSTACLE
#define IS_OBSTACLE(tile) ((!istype(tile, /turf/space) && istype(tile.loc, /area/mine/unexplored)) \
					|| istype(tile, /turf/simulated/wall) \
					|| istype(tile, /turf/unsimulated/mineral) \
					|| istype(tile, /turf/unsimulated/wall) \
					|| istype(tile, /turf/simulated/shuttle/wall) \
					|| (locate(/obj/structure/grille) in tile))

// Turfs that will be colored as HOLOMAP_PATH
#define IS_PATH(tile) (istype(tile, /turf/simulated/floor) \
					|| istype(tile, /turf/unsimulated/floor) \
					|| istype(tile, /turf/simulated/shuttle/floor) \
					|| (locate(/obj/structure/catwalk) in tile))

/// Generates all the holo minimaps, initializing it all nicely, probably.
/datum/controller/subsystem/holomaps/proc/generateHoloMinimaps()
	// Build the base map for each z level
	for (var/z = 1 to GLOB.maps_data.station_levels.len)
		holoMiniMaps |= z // hack, todo fix
		holoMiniMaps[z] = generateHoloMinimap(z)

	// Generate the area overlays, small maps, etc for the station levels.
	for (var/level in GLOB.maps_data.station_levels)
		generateStationMinimap(level)

	if(GLOB.maps_data.holomap_smoosh)
		for(var/smoosh_list in GLOB.maps_data.holomap_smoosh)
			smooshTetherHolomaps(smoosh_list)

	holomaps_initialized = TRUE

	// TODO - Check - They had a delayed init perhaps?
	for (var/obj/machinery/holomap/S in station_holomaps)
		S.setup_holomap()

// Generates the "base" holomap for one z-level, showing only the physical structure of walls and paths.
/datum/controller/subsystem/holomaps/proc/generateHoloMinimap(zLevel)
	// Save these values now to avoid a bazillion array lookups
	var/offset_x = HOLOMAP_PIXEL_OFFSET_X(zLevel)
	var/offset_y = HOLOMAP_PIXEL_OFFSET_Y(zLevel)

	// Sanity checks - Better to generate a helpful error message now than have DrawBox() runtime
	var/icon/canvas = icon(HOLOMAP_ICON, "blank")
	if(world.maxx + offset_x > canvas.Width())
		crash_with("Minimap for z=[zLevel] : world.maxx ([world.maxx]) + holomap_offset_x ([offset_x]) must be <= [canvas.Width()]")
	if(world.maxy + offset_y > canvas.Height())
		crash_with("Minimap for z=[zLevel] : world.maxy ([world.maxy]) + holomap_offset_y ([offset_y]) must be <= [canvas.Height()]")

	for(var/x = 1 to world.maxx)
		for(var/y = 1 to world.maxy)
			var/turf/tile = locate(x, y, zLevel)
			if(tile && tile.loc:holomapAlwaysDraw())
				if(IS_ROCK(tile))
					canvas.DrawBox(HOLOMAP_ROCK, x + offset_x, y + offset_y)
				if(IS_OBSTACLE(tile))
					canvas.DrawBox(HOLOMAP_OBSTACLE, x + offset_x, y + offset_y)
				else if(IS_PATH(tile))
					canvas.DrawBox(HOLOMAP_PATH, x + offset_x, y + offset_y)
		// Check sleeping after each row to avoid *completely* destroying the server
		CHECK_TICK
	return canvas

// Okay, what does this one do?
// This seems to do the drawing thing, but draws only the areas, having nothing to do with the tiles.
// Leshana: I'm guessing this map will get overlayed on top of the base map at runtime? We'll see.
// Wait, seems we actually blend the area map on top of it right now! Huh.
/datum/controller/subsystem/holomaps/proc/generateStationMinimap(zLevel)
	// Save these values now to avoid a bazillion array lookups
	var/offset_x = HOLOMAP_PIXEL_OFFSET_X(zLevel)
	var/offset_y = HOLOMAP_PIXEL_OFFSET_Y(zLevel)

	// Sanity checks - Better to generate a helpful error message now than have DrawBox() runtime
	var/icon/canvas = icon(HOLOMAP_ICON, "blank")
	if(world.maxx + offset_x > canvas.Width())
		crash_with("Minimap for z=[zLevel] : world.maxx ([world.maxx]) + holomap_offset_x ([offset_x]) must be <= [canvas.Width()]")
	if(world.maxy + offset_y > canvas.Height())
		crash_with("Minimap for z=[zLevel] : world.maxy ([world.maxy]) + holomap_offset_y ([offset_y]) must be <= [canvas.Height()]")

	for(var/x = 1 to world.maxx)
		for(var/y = 1 to world.maxy)
			var/turf/tile = locate(x, y, zLevel)
			if(tile && tile.loc)
				var/area/areaToPaint = tile.loc
				if(areaToPaint.holomap_color)
					canvas.DrawBox(areaToPaint.holomap_color, x + offset_x, y + offset_y)

	// Save this nice area-colored canvas in case we want to layer it or something I guess
	extraMiniMaps["[HOLOMAP_EXTRA_STATIONMAPAREAS]_[zLevel]"] = canvas

	var/icon/map_base = icon(holoMiniMaps[zLevel])
	map_base.Blend(HOLOMAP_HOLOFIER, ICON_MULTIPLY)


	// Generate the full sized map by blending the base and areas onto the backdrop
	var/icon/big_map = icon(HOLOMAP_ICON, "stationmap")
	var/icon/deck_name = icon(HOLO_DECK_NAME, "deck")
	deck_name.Blend(deck_name, ICON_OVERLAY, zLevel)
	big_map.Blend(map_base, ICON_OVERLAY)
	big_map.Blend(canvas, ICON_OVERLAY)

	extraMiniMaps["[HOLOMAP_EXTRA_STATIONMAP]_[zLevel]"] = big_map

	// Generate the "small" map (I presume for putting on wall map things?)
	var/icon/small_map = icon(HOLOMAP_ICON, "blank")
	small_map.Blend(map_base, ICON_OVERLAY)
	small_map.Blend(canvas, ICON_OVERLAY)
	small_map.Scale(WORLD_ICON_SIZE, WORLD_ICON_SIZE)

	// And rotate it in every direction of course!
	var/icon/actual_small_map = icon(small_map)
	actual_small_map.Insert(new_icon = small_map, dir = SOUTH)
	actual_small_map.Insert(new_icon = turn(small_map, 90), dir = WEST)
	actual_small_map.Insert(new_icon = turn(small_map, 180), dir = NORTH)
	actual_small_map.Insert(new_icon = turn(small_map, 270), dir = EAST)
	extraMiniMaps["[HOLOMAP_EXTRA_STATIONMAPSMALL]_[zLevel]"] = actual_small_map

// For tiny multi-z maps like the tether, we want to smoosh em together into a nice big one!
/datum/controller/subsystem/holomaps/proc/smooshTetherHolomaps(list/zlevels)
	var/icon/big_map = icon(HOLOMAP_ICON, "stationmap")
	var/icon/small_map = icon(HOLOMAP_ICON, "blank")
	// For each zlevel in turn, overlay them on top of each other
	for(var/zLevel in zlevels)
		var/icon/z_terrain = icon(holoMiniMaps[zLevel])
		z_terrain.Blend(HOLOMAP_HOLOFIER, ICON_MULTIPLY)
		big_map.Blend(z_terrain, ICON_OVERLAY)
		small_map.Blend(z_terrain, ICON_OVERLAY)
		var/icon/z_areas = extraMiniMaps["[HOLOMAP_EXTRA_STATIONMAPAREAS]_[zLevel]"]
		big_map.Blend(z_areas, ICON_OVERLAY)
		small_map.Blend(z_areas, ICON_OVERLAY)

	// Then scale and rotate to make the actual small map we will use
	small_map.Scale(WORLD_ICON_SIZE, WORLD_ICON_SIZE)
	var/icon/actual_small_map = icon(small_map)
	actual_small_map.Insert(new_icon = small_map, dir = SOUTH)
	actual_small_map.Insert(new_icon = turn(small_map, 90), dir = WEST)
	actual_small_map.Insert(new_icon = turn(small_map, 180), dir = NORTH)
	actual_small_map.Insert(new_icon = turn(small_map, 270), dir = EAST)

	// Then assign this icon as the icon for all those levels!
	for(var/zLevel in zlevels)
		extraMiniMaps["[HOLOMAP_EXTRA_STATIONMAP]_[zLevel]"] = big_map
		extraMiniMaps["[HOLOMAP_EXTRA_STATIONMAPSMALL]_[zLevel]"] = actual_small_map

// TODO - Holomap Markers!
// /proc/generateMinimapMarkers(var/zLevel)
// 	// Save these values now to avoid a bazillion array lookups
// 	var/offset_x = HOLOMAP_PIXEL_OFFSET_X(zLevel)
// 	var/offset_y = HOLOMAP_PIXEL_OFFSET_Y(zLevel)

// 	// TODO - Holomap markers
// 	for(var/filter in list(HOLOMAP_FILTER_STATIONMAP))
// 		var/icon/canvas = icon(HOLOMAP_ICON, "blank")
// 		for(/datum/holomap_marker/holomarker in holomap_markers)
// 			if(holomarker.z == zLevel && holomarker.filter & filter)
// 				canvas.Blend(icon(holomarker.icon, holomarker.icon_state), ICON_OVERLAY, holomarker.x + offset_x, holomarker.y + offset_y)
// 		extraMiniMaps["[HOLOMAP_EXTRA_MARKERS]_[filter]_[zLevel]"] = canvas

// /datum/holomap_marker
// 	var/x
// 	var/y
// 	var/z
// 	var/filter
// 	var/icon = 'icons/holomap_markers.dmi'
// 	var/icon_state

#undef IS_ROCK
#undef IS_OBSTACLE
#undef IS_PATH

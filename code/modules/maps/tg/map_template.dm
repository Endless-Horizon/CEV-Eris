/datum/map_template
	var/name = "Default Template Name"
	var/desc = "Some text should go here. Maybe."
	var/id = null
	var/template_group = null // If this is set, no more than one template in the same group will be spawned, per submap seeding.
	var/width = 0
	var/height = 0
	var/mappath = null
	var/loaded = 0 // Times loaded this round
	var/annihilate = FALSE // If true, all (movable) atoms at the location where the map is loaded will be deleted before the map is loaded in.

	var/cost = null // The map generator has a set 'budget' it spends to place down different submaps. It will pick available submaps randomly until
					// it runs out. The cost of a submap should roughly corrispond with several factors such as size, loot, difficulty, desired scarcity, etc.
					// Set to -1 to force the submap to always be made.
	var/allow_duplicates = FALSE // If false, only one map template will be spawned by the game. Doesn't affect admins spawning then manually.
	var/discard_prob = 0 // If non-zero, there is a chance that the map seeding algorithm will skip this template when selecting potential templates to use.

	var/template_flags = TEMPLATE_FLAG_ALLOW_DUPLICATES

	var/static/dmm_suite/maploader = new

/datum/map_template/New(path = null, rename = null)
	if(path)
		mappath = path
	if(mappath)
		spawn(1)
			preload_size(mappath)
	if(rename)
		name = rename

/datum/map_template/proc/preload_size(path, orientation = SOUTH)
	var/bounds = SSmapping.maploader.load_map(file(path), 1, 1, 1, cropMap=FALSE, measureOnly=TRUE, orientation=orientation)
	if(bounds)
		if(orientation & (90 | 270))
			width = bounds[MAP_MAXY]
			height = bounds[MAP_MAXX]
		else
			width = bounds[MAP_MAXX] // Assumes all templates are rectangular, have a single Z level, and begin at 1,1,1
			height = bounds[MAP_MAXY]
	return bounds

/datum/map_template/proc/initTemplateBounds(list/bounds)
	if (!bounds) //something went wrong
		stack_trace("[name] template failed to initialize correctly!")
		return

	var/list/obj/machinery/atmospherics/atmos_machines = list()
	var/list/obj/structure/cable/cables = list()
	var/list/atom/movable/movables = list()
	var/list/area/areas = list()

	var/list/turfs = block(
		locate(
			bounds[MAP_MINX],
			bounds[MAP_MINY],
			bounds[MAP_MINZ]
			),
		locate(
			bounds[MAP_MAXX],
			bounds[MAP_MAXY],
			bounds[MAP_MAXZ]
			)
		)
	for(var/turf/current_turf as anything in turfs)
		var/area/current_turfs_area = current_turf.loc
		areas |= current_turfs_area
		if(!SSatoms.initialized)
			continue

		for(var/movable_in_turf in current_turf)
			movables += movable_in_turf
			if(istype(movable_in_turf, /obj/structure/cable))
				cables += movable_in_turf
				continue
			if(istype(movable_in_turf, /obj/machinery/atmospherics))
				atmos_machines += movable_in_turf

	// Not sure if there is some importance here to make sure the area is in z
	// first or not.  Its defined In Initialize yet its run first in templates
	// BEFORE so... hummm
	// SSmapping.reg_in_areas_in_z(areas)
	// SSnetworks.assign_areas_root_ids(areas, src)
	if(!SSatoms.initialized)
		return

	SSatoms.InitializeAtoms(areas + turfs + movables, null)

	// NOTE, now that Initialize and LateInitialize run correctly, do we really
	// need these two below?
	// SSmachines.setup_template_powernets(cables)
	SSmachines.setup_powernets_for_cables(cables)
	SSair.setup_template_machinery(atmos_machines)
	// SSmachines.setup_atmos_machinery(atmos_machines)


	//calculate all turfs inside the border
	var/list/template_and_bordering_turfs = block(
		locate(
			max(bounds[MAP_MINX]-1, 1),
			max(bounds[MAP_MINY]-1, 1),
			bounds[MAP_MINZ]
			),
		locate(
			min(bounds[MAP_MAXX]+1, world.maxx),
			min(bounds[MAP_MAXY]+1, world.maxy),
			bounds[MAP_MAXZ]
			)
		)
	for(var/turf/affected_turf as anything in template_and_bordering_turfs)
		// affected_turf.air_update_turf(TRUE, TRUE)
		affected_turf.levelupdate()


/datum/map_template/proc/load_new_z(var/centered = FALSE, var/orientation = SOUTH)
	var/x = 1
	var/y = 1

	if(centered)
		x = round((world.maxx - width)/2)
		y = round((world.maxy - height)/2)

	var/list/bounds = SSmapping.maploader.load_map(file(mappath), x, y, no_changeturf = TRUE, orientation=orientation)
	if(!bounds)
		return FALSE

//	repopulate_sorted_areas()

	//initialize things that are normally initialized after map load
	initTemplateBounds(bounds)
	log_game("Z-level [name] loaded at at [x],[y],[world.maxz]")
	return TRUE

/datum/map_template/proc/load(turf/T, centered = FALSE, orientation = SOUTH, var/post_init = 0)
	var/old_T = T
	if(centered)
		T = locate(T.x - round(((orientation & NORTH|SOUTH) ? width : height)/2) , T.y - round(((orientation & NORTH|SOUTH) ? height : width)/2) , T.z)
	if(!T)
		return
	if(T.x+width > world.maxx)
		return
	if(T.y+height > world.maxy)
		return

	if(annihilate)
		annihilate_bounds(old_T, centered, orientation)

	var/list/bounds = SSmapping.maploader.load_map(file(mappath), T.x, T.y, T.z, cropMap=TRUE, orientation = orientation)
	if(!bounds)
		return

//	if(!SSmapping.loading_ruins) //Will be done manually during mapping ss init
//		repopulate_sorted_areas()

	//initialize things that are normally initialized after map load
	if(!post_init)
		initTemplateBounds(bounds)

	log_game("[name] loaded at at [T.x],[T.y],[T.z]")
	loaded++
	return TRUE

/datum/map_template/proc/get_affected_turfs(turf/T, centered = FALSE, orientation = SOUTH)
	var/turf/placement = T
	if(centered)
		var/turf/corner = locate(placement.x - round(((orientation & NORTH|SOUTH) ? width : height)/2), placement.y - round(((orientation & NORTH|SOUTH) ? height : width)/2), placement.z)
		if(corner)
			placement = corner
	return block(placement, locate(placement.x+((orientation & NORTH|SOUTH) ? width : height)-1, placement.y+((orientation & NORTH|SOUTH) ? height : width)-1, placement.z))

/datum/map_template/proc/annihilate_bounds(turf/origin, centered = FALSE, orientation = SOUTH)
	//var/deleted_atoms = 0
	//admin_notice("<span class='danger'>Annihilating objects in submap loading locatation.</span>", R_DEBUG)
	var/list/turfs_to_clean = get_affected_turfs(origin, centered, orientation)
	if(turfs_to_clean.len)
		for(var/turf/T in turfs_to_clean)
			for(var/atom/movable/AM in T)
			//	++deleted_atoms
				qdel(AM)
	//admin_notice("<span class='danger'>Annihilated [deleted_atoms] objects.</span>", R_DEBUG)


//for your ever biggening badminnery kevinz000
//❤ - Cyberboss
/proc/load_new_z_level(var/file, var/name, var/orientation = SOUTH)
	var/datum/map_template/template = new(file, name)
	template.load_new_z(orientation)

// Very similar to the /tg/ version.
/proc/seed_submaps(var/list/z_levels, var/budget = 0, var/whitelist = /area/space, var/desired_map_template_type = null)
	set background = TRUE

	if(!z_levels || !z_levels.len)
		//admin_notice("seed_submaps() was not given any Z-levels.", R_DEBUG)
		return

	for(var/zl in z_levels)
		var/turf/T = locate(1, 1, zl)
		if(!T)
			//admin_notice("Z level [zl] does not exist - Not generating submaps", R_DEBUG)
			return

	var/overall_sanity = 100 // If the proc fails to place a submap more than this, the whole thing aborts.
	var/list/potential_submaps = list() // Submaps we may or may not place.
	var/list/priority_submaps = list() // Submaps that will always be placed.

	// Lets go find some submaps to make.
	for(var/map in SSmapping.map_templates)
		var/datum/map_template/MT = SSmapping.map_templates[map]
		if(!MT.allow_duplicates && MT.loaded > 0) // This probably won't be an issue but we might as well.
			continue
		if(!istype(MT, desired_map_template_type)) // Not the type wanted.
			continue
		if(MT.discard_prob && prob(MT.discard_prob))
			continue
		if(MT.cost && MT.cost < 0) // Negative costs always get spawned.
			priority_submaps += MT
		else
			potential_submaps += MT

	CHECK_TICK

	var/list/loaded_submap_names = list()
	var/list/template_groups_used = list() // Used to avoid spawning three seperate versions of the same PoI.

	// Now lets start choosing some.
	while(budget > 0 && overall_sanity > 0)
		overall_sanity--
		var/datum/map_template/chosen_template = null

		if(potential_submaps.len)
			if(priority_submaps.len) // Do these first.
				chosen_template = pick(priority_submaps)
			else
				chosen_template = pick(potential_submaps)

		else // We're out of submaps.
			//admin_notice("Submap loader had no submaps to pick from with [budget] left to spend.", R_DEBUG)
			break

		CHECK_TICK

		// Can we afford it?
		if(chosen_template.cost > budget)
			priority_submaps -= chosen_template
			potential_submaps -= chosen_template
			continue

		// Did we already place down a very similar submap?
		if(chosen_template.template_group && (chosen_template.template_group in template_groups_used))
			priority_submaps -= chosen_template
			potential_submaps -= chosen_template
			continue

		// If so, try to place it.
		var/specific_sanity = 100 // A hundred chances to place the chosen submap.
		while(specific_sanity > 0)
			specific_sanity--
			var/orientation = pick(cardinal)
			chosen_template.preload_size(chosen_template.mappath, orientation)
			var/width_border = TRANSITIONEDGE + SUBMAP_MAP_EDGE_PAD + round(((orientation & NORTH|SOUTH) ? chosen_template.width : chosen_template.height) / 2)
			var/height_border = TRANSITIONEDGE + SUBMAP_MAP_EDGE_PAD + round(((orientation & NORTH|SOUTH) ? chosen_template.height : chosen_template.width) / 2)
			var/z_level = pick(z_levels)
			var/turf/T = locate(rand(width_border, world.maxx - width_border), rand(height_border, world.maxy - height_border), z_level)
			var/valid = TRUE

			for(var/turf/check in chosen_template.get_affected_turfs(T,TRUE,orientation))
				var/area/new_area = get_area(check)
				if(!(istype(new_area, whitelist)))
					valid = FALSE // Probably overlapping something important.
			//		world << "Invalid due to overlapping with area [new_area.type] at ([check.x], [check.y], [check.z]), when attempting to place at ([T.x], [T.y], [T.z])."
					break
				CHECK_TICK

			CHECK_TICK

			if(!valid)
				continue

			//admin_notice("Submap \"[chosen_template.name]\" placed at ([T.x], [T.y], [T.z])\n", R_DEBUG)

			// Do loading here.
			chosen_template.load(T, centered = TRUE, orientation=orientation) // This is run before the main map's initialization routine, so that can initilize our submaps for us instead.

			CHECK_TICK

			// For pretty maploading statistics.
			if(loaded_submap_names[chosen_template.name])
				loaded_submap_names[chosen_template.name] += 1
			else
				loaded_submap_names[chosen_template.name] = 1

			// To avoid two 'related' similar submaps existing at the same time.
			if(chosen_template.template_group)
				template_groups_used += chosen_template.template_group

			// To deduct the cost.
			if(chosen_template.cost >= 0)
				budget -= chosen_template.cost

			// Remove the submap from our options.
			if(chosen_template in priority_submaps) // Always remove priority submaps.
				priority_submaps -= chosen_template
			else if(!chosen_template.allow_duplicates)
				potential_submaps -= chosen_template

			break // Load the next submap.

	var/list/pretty_submap_list = list()
	for(var/submap_name in loaded_submap_names)
		var/count = loaded_submap_names[submap_name]
		if(count > 1)
			pretty_submap_list += "[count] <b>[submap_name]</b>"
		else
			pretty_submap_list += "<b>[submap_name]</b>"

/*	if(!overall_sanity)
		admin_notice("Submap loader gave up with [budget] left to spend.", R_DEBUG)
	else
		admin_notice("Submaps loaded.", R_DEBUG)
	admin_notice("Loaded: [english_list(pretty_submap_list)]", R_DEBUG) */

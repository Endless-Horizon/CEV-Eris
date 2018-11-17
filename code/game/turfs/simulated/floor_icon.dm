var/list/flooring_cache = list()

/turf/var/icon_updates_count = 0

/turf/verb/debugupdate()
	set src in view()
	set name = "debugupdate"

	update_icon(TRUE, TRUE)

/turf/simulated/floor/update_icon(var/update_neighbors, var/debug)
	icon_updates_count++
	var/has_smooth = 0 //This is just the has_border bitfield inverted for easier logic
	if(lava) //Wtf why
		return

	if(flooring)
		// Set initial icon and strings.
		name = flooring.name
		desc = flooring.desc
		icon = flooring.icon
		if(!isnull(set_update_icon) && istext(set_update_icon))
			icon_state = set_update_icon
		else if(flooring_override)
			icon_state = flooring_override
		else
			if(overrided_icon_state)
				icon_state = overrided_icon_state
				flooring_override = icon_state
			else
				icon_state = flooring.icon_base


		// Apply edges, corners, and inner corners.
		overlays.Cut()
		var/has_border = 0
		if (!flooring.smooth_nothing)
		//Check if we're actually going to do anything first
			if (isnull(set_update_icon))

				//Check the cardinal turfs
				for(var/step_dir in cardinal)
					var/turf/simulated/floor/T = get_step(src, step_dir)

					//Test link is a flooring proc but its defined farther down in this file
					var/is_linked = flooring.test_link(src, T, debug)




					//Alright we've figured out whether or not we smooth with this turf
					if (!is_linked)
						has_border |= step_dir

						//Now, if we don't, then lets add a border
						if ((flooring.flags & TURF_EDGES_EXTERNAL))
							var/odir = turn(step_dir, 180)
							var/image/I = get_flooring_overlay("[flooring.icon_base]-ext-edge-[odir]", "[flooring.icon_base]_edges", odir, TRUE)
							overlays |= I
						else
							overlays |= get_flooring_overlay("[flooring.icon_base]-edge-[step_dir]", "[flooring.icon_base]_edges", step_dir)

				//By doing &15 we only take the first four bits, which represent NORTH, SOUTH, EAST, WEST
				has_smooth = ~(has_border & 15)


			//We can only have inner corners if we're smoothed with something
			if (has_smooth)
				if(flooring.flags & TURF_HAS_INNER_CORNERS)

					//Quick way to check if we're smoothed with both north and east
					if((has_smooth & NORTHEAST) == NORTHEAST)
						//If we are, then check the diagonal tile
						if (!flooring.test_link(src, get_step(src, NORTHEAST), debug))
							//If we smooth with north and east, but don't smooth with the northeast diagonal, then we have an inner corner!
							overlays |= get_flooring_overlay("[flooring.icon_base]-corner-[NORTHEAST]", "[flooring.icon_base]_corners", NORTHEAST)

					if((has_smooth & NORTHWEST) == NORTHWEST)
						if (!flooring.test_link(src, get_step(src, NORTHWEST), debug))
							overlays |= get_flooring_overlay("[flooring.icon_base]-corner-[NORTHWEST]", "[flooring.icon_base]_corners", NORTHWEST)

					if((has_smooth & SOUTHEAST) == SOUTHEAST)
						if (!flooring.test_link(src, get_step(src, SOUTHEAST), debug))
							overlays |= get_flooring_overlay("[flooring.icon_base]-corner-[SOUTHEAST]", "[flooring.icon_base]_corners", SOUTHEAST)

					if((has_smooth & SOUTHWEST) == SOUTHWEST)
						if (!flooring.test_link(src, get_step(src, SOUTHWEST), debug))
							overlays |= get_flooring_overlay("[flooring.icon_base]-corner-[SOUTHWEST]", "[flooring.icon_base]_corners", SOUTHWEST)



			//Next up, outer corners
			if (has_border)
				if(flooring.flags & TURF_HAS_CORNERS)
					if((has_border & NORTHEAST) == NORTHEAST)
						overlays |= get_flooring_overlay("[flooring.icon_base]-edge-[NORTHEAST]", "[flooring.icon_base]_edges", NORTHEAST)
					if((has_border & NORTHWEST) == NORTHWEST)
						overlays |= get_flooring_overlay("[flooring.icon_base]-edge-[NORTHWEST]", "[flooring.icon_base]_edges", NORTHWEST)
					if((has_border & SOUTHEAST) == SOUTHEAST)
						overlays |= get_flooring_overlay("[flooring.icon_base]-edge-[SOUTHEAST]", "[flooring.icon_base]_edges", SOUTHEAST)
					if((has_border & SOUTHWEST) == SOUTHWEST)
						overlays |= get_flooring_overlay("[flooring.icon_base]-edge-[SOUTHWEST]", "[flooring.icon_base]_edges", SOUTHWEST)


			//Now lets handle those fancy floors which have many centre icons
			if(flooring.has_base_range)
				if (!has_border)
					//Random icons are only for centre turfs, so we need it to not have borders
					icon_state = "[flooring.icon_base][rand(0,flooring.has_base_range)]"
					flooring_override = icon_state
				else
					icon_state = flooring.icon_base+"0"



	if(decals && decals.len)
		overlays |= decals

	if(broken || burnt)
		if(!isnull(broken))
			if(flooring.has_damage_range)
				overlays |= get_flooring_overlay("[flooring.icon_base]-broken-[broken]", "broken[broken]")
			else
				var/n = rand(1,3)
				overlays |= get_damage_overlay("damaged[n]", "damaged[n]")

		if(!isnull(burnt))
			if(flooring.has_burn_range)
				overlays |= get_flooring_overlay("[flooring.icon_base]-burned-[burnt]", "burned[burnt]")
			else
				var/n = rand(1,3)
				overlays |= get_damage_overlay("scorched[n]", "scorched[n]")

	if(update_neighbors)
		for(var/turf/simulated/floor/F in trange(1, src))
			if(F == src)
				continue
			F.update_icon()
	update_openspace()


//Tests whether this flooring will smooth with the specified turf
//You can override this if you want a flooring to have super special snowflake smoothing behaviour
/decl/flooring/proc/test_link(var/turf/origin, var/turf/T, var/debug = FALSE)
	if (debug)
		if(origin == T)
			world << "Doing a countercheck"
		else
			world << "Attempting link with [dir2text(get_dir(origin, T))] [T]	"

	//is_wall is true for wall turfs and for floors containing a low wall
	var/is_linked = FALSE
	if(T.is_wall)
		if(wall_smooth)
			is_linked = TRUE


	//If is_hole is true, then it's space or openspace
	else if(T.is_hole)
		if(space_smooth)
			is_linked = TRUE


	//If we get here then its a normal floor
	else if (istype(T, /turf/simulated/floor))
		var/turf/simulated/floor/t = T
		//If the floor is the same as us,then we're linked,
		if (t.flooring.name == name)
			/*
				But there's a caveat. To make atom black/whitelists work correctly, we also need to check that
				they smooth with us. Ill call this counterchecking for simplicity

				To prevent an infinite recursion loop here, we'll use origin to mean the turf that started this operation, ie us
			*/
			if (debug) world << "Flooring Matches, will we do countercheck?"
			if (smooth_movable_atom != SMOOTH_NONE && origin != T)
				if (debug) world << "Doing countercheck"
				//If origin == T then this is a countercheck

				//We do the countercheck, passing ourselves (origin) as both origin and T.
				is_linked = test_link(origin, origin, debug)

			else
				//If atom lists aren't involved then we're done with floor checking
				is_linked = TRUE

		if (floor_smooth == SMOOTH_ALL)
			is_linked = TRUE

		else if (floor_smooth != SMOOTH_NONE)



			//If we get here it must be using a whitelist or blacklist
			if (floor_smooth == SMOOTH_WHITELIST)
				for (var/v in flooring_whitelist)
					if (istype(t.flooring, v))
						//Found a match on the list
						is_linked = TRUE
						break
			else if(floor_smooth == SMOOTH_BLACKLIST)
				is_linked = TRUE //Default to true for the blacklist, then make it false if a match comes up
				for (var/v in flooring_whitelist)
					if (istype(t.flooring, v))
						//Found a match on the list
						is_linked = FALSE
						break


	//Alright now we have a preliminary answer about smoothing, however that answer may change with the following
	//Atom lists!
	var/best_priority = -1
	//A white or blacklist entry will only override smoothing if its priority is higher than this
	//And then this value becomes its priority
	if (smooth_movable_atom != SMOOTH_NONE)
		if (smooth_movable_atom == SMOOTH_WHITELIST || smooth_movable_atom == SMOOTH_GREYLIST)
			for (var/list/v in movable_atom_whitelist)
				var/d_type = v[1]
				var/list/d_vars = v[2]
				var/d_priority = v[3]
				//Priority is the quickest thing to check first
				if (d_priority <= best_priority)
					continue

				//Ok, now we start testing all the atoms in the target turf
				for (var/a in T) //No implicit typecasting here, faster

					if (istype(a, d_type))
						//It's the right type, so we're sure it will have the vars we want.
						//From here on out, we do dangerous stuff that may runtime if the coder screwed up

						var/atom/movable/AM = a
						//Typecast it to a movable atom
						var/match = TRUE
						for (var/d_var in d_vars)
							//For each variable we want to check
							if (AM.vars[d_var] != d_vars[d_var])
								//We get a var of the same name from the atom's vars list.
								//And check if it equals our desired value
								match = FALSE
								break //If any var doesn't match the desired value, then this atom is not a match, move on


						if (match)
							//If we've successfully found an atom which matches a list entry
							best_priority = d_priority //This one is king until a higher priority overrides it

							//And this is a whitelist, so this match forces is_linked to true
							is_linked = TRUE


		if (smooth_movable_atom == SMOOTH_BLACKLIST || smooth_movable_atom == SMOOTH_GREYLIST)
			//All of this blacklist code is copypasted from above, with only minor name changes
			if (smooth_movable_atom == SMOOTH_BLACKLIST || smooth_movable_atom == SMOOTH_GREYLIST)
				for (var/list/v in movable_atom_blacklist)
					var/d_type = v[1]
					var/list/d_vars = v[2]
					var/d_priority = v[3]
					//Priority is the quickest thing to check first
					if (d_priority <= best_priority)
						continue

					//Ok, now we start testing all the atoms in the target turf
					for (var/a in T) //No implicit typecasting here, faster

						if (istype(a, d_type))
							//It's the right type, so we're sure it will have the vars we want.
							//From here on out, we do dangerous stuff that may runtime if the coder screwed up

							var/atom/movable/AM = a
							//Typecast it to a movable atom
							var/match = TRUE
							for (var/d_var in d_vars)
								//For each variable we want to check
								if (AM.vars[d_var] != d_vars[d_var])
									//We get a var of the same name from the atom's vars list.
									//And check if it equals our desired value
									match = FALSE
									break //If any var doesn't match the desired value, then this atom is not a match, move on


							if (match)
								//If we've successfully found an atom which matches a list entry
								best_priority = d_priority //This one is king until a higher priority overrides it

								//And this is a blacklist, so this match forces is_linked to false
								is_linked = FALSE

	if (debug && is_linked && origin != T)
		world << "Linking with [dir2text(get_dir(origin, T))] [T]	"
	return is_linked










/turf/simulated/floor/proc/get_damage_overlay(var/cache_key, var/icon_base	)
	if(!flooring_cache[cache_key])
		var/image/I = image(icon = 'icons/turf/damage_overlays.dmi', icon_state = icon_base)

		I.plane = FLOOR_PLANE
		I.layer = TURF_DECAL_LAYER+0.1
		flooring_cache[cache_key] = I
	return flooring_cache[cache_key]


/turf/simulated/floor/proc/get_flooring_overlay(var/cache_key, var/icon_base, var/icon_dir = 0, var/external = FALSE)
	if(!flooring_cache[cache_key])
		var/image/I = image(icon = flooring.icon, icon_state = icon_base, dir = icon_dir)
		I.layer = layer+0.01


		//External overlays will be offsetted out of this tile
		if (external)
			if (icon_dir & NORTH)
				I.pixel_y = -32
			else if (icon_dir & SOUTH)
				I.pixel_y = 32

			if (icon_dir & WEST)
				I.pixel_x = 32
			else if (icon_dir & EAST)
				I.pixel_x = -32

		flooring_cache[cache_key] = I
	return flooring_cache[cache_key]
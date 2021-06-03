/proc/dopage(src, target)
	var/href_list
	var/href
	href_list = params2list("src=\ref[src]&[target]=1")
	href = "src=\ref[src];[target]=1"
	src:temphtml = null
	src:Topic(href, href_list)
	return null

/proc/get_z(O)
	var/turf/loc = get_turf(O)
	return loc ? loc.z : 0

/proc/get_area_name(N) //get area by its name
	for(var/area/A in GLOB.map_areas)
		if(A.name == N)
			return A
	return

/proc/get_area_master(const/O)
	var/area/A = get_area(O)
	if (isarea(A))
		return A

// Like view but bypasses luminosity check

/proc/hear(range, atom/source)
	var/lum = source.luminosity
	source.luminosity = world.view
	var/list/heard = view(range, source)
	var/list/extra_heard = view(range+3, source) - heard
	if(extra_heard.len)
		for(var/ear in extra_heard)
			if(!ishuman(ear))
				continue
			var/mob/living/carbon/human/H = ear
			if(!H.stats.getPerk(PERK_EAR_OF_QUICKSILVER))
				continue
			heard += ear
	source.luminosity = lum

	return heard

/proc/circlerange(center=usr, radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T

	//turfs += centerturf
	return turfs

/proc/circleview(center=usr, radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/atoms = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/A in view(radius, centerturf))
		var/dx = A.x - centerturf.x
		var/dy = A.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			atoms += A

	//turfs += centerturf
	return atoms



/proc/get_dist_euclidian(atom/Loc1 as turf|mob|obj, atom/Loc2 as turf|mob|obj)
	var/dx = Loc1.x - Loc2.x
	var/dy = Loc1.y - Loc2.y

	var/dist = sqrt(dx**2 + dy**2)

	return dist

/proc/circlerangeturfs(center=usr, radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in RANGE_TURFS(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T
	return turfs

/proc/circleviewturfs(center=usr, radius=3)		//Is there even a diffrence between this proc and circlerangeturfs()?

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in view(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T
	return turfs

// Returns a list of mobs and/or objects in range of R from source. Used in radio and say code.

/proc/get_mobs_or_objects_in_view(R, atom/source, include_mobs = 1, include_objects = 1)

	var/turf/T = get_turf(source)
	var/list/hear = list()

	if(!T)
		return hear

	var/list/range = hear(R, T)

	for(var/I in range)
		if(ismob(I))
			if(include_mobs)
				var/mob/M = I
				if(M.client)
					hear += M
		else if(istype(I,/obj/))
			if(include_objects)
				hear += I

	return hear


/proc/get_mobs_and_objs_in_view_fast(turf/T, range, list/mobs, list/objs, checkghosts = GHOSTS_ALL_HEAR)
	if(!T) // fucking lobby on nullspace
		return
	var/list/hear = dview(range, T.loc, INVISIBILITY_MAXIMUM)
	var/list/hearturfs = list()

	for(var/am in hear)
		var/atom/movable/AM = am
		if (!AM.loc)
			continue

		if(ismob(AM))
			mobs[AM] = TRUE
			hearturfs[AM.locs[1]] = TRUE
		else if(isobj(AM))
			objs[AM] = TRUE
			hearturfs[AM.locs[1]] = TRUE

	for(var/m in GLOB.player_list)
		var/mob/M = m
		if(checkghosts == GHOSTS_ALL_HEAR && M.stat == DEAD && !isnewplayer(M) && (M.client && M.get_preference_value(/datum/client_preference/ghost_ears) == GLOB.PREF_ALL_SPEECH))
			if (!mobs[M])
				mobs[M] = TRUE
			continue
		if(M.loc && hearturfs[M.locs[1]])
			if (!mobs[M])
				mobs[M] = TRUE

	for(var/obj in GLOB.hearing_objects)
		if(get_turf(obj) in hearturfs)
			objs |= obj


/proc/get_mobs_in_radio_ranges(list/obj/item/device/radio/radios)

	set background = 1

	. = list()
	// Returns a list of mobs who can hear any of the radios given in @radios
	var/list/speaker_coverage = list()
	for(var/obj/item/device/radio/R in radios)
		if(R)
			//Cyborg checks. Receiving message uses a bit of cyborg's charge.
			var/obj/item/device/radio/borg/BR = R
			if(istype(BR) && BR.myborg)
				var/mob/living/silicon/robot/borg = BR.myborg
				var/datum/robot_component/CO = borg.get_component("radio")
				if(!CO)
					continue //No radio component (Shouldn't happen)
				if(!borg.is_component_functioning("radio") || !borg.cell_use_power(CO.active_usage))
					continue //No power.

			var/turf/speaker = get_turf(R)
			if(speaker)
				for(var/turf/T in hear(R.canhear_range, speaker))
					speaker_coverage[T] = T


	// Try to find all the players who can hear the message
	for(var/i = 1; i <= GLOB.player_list.len; i++)
		var/mob/M = GLOB.player_list[i]
		if(M)
			var/turf/ear = get_turf(M)
			if(ear)
				// Ghostship is magic: Ghosts can hear radio chatter from anywhere
				if(speaker_coverage[ear] || (isghost(M) && M.get_preference_value(/datum/client_preference/ghost_radio) == GLOB.PREF_ALL_CHATTER))
					. |= M		// Since we're already looping through mobs, why bother using |= ? This only slows things down.
	return .

/proc/inLineOfSight(X1, Y1, X2, Y2, Z=1, PX1=16.5, PY1=16.5, PX2=16.5, PY2=16.5)
	var/turf/T
	if(X1==X2)
		if(Y1==Y2)
			return 1 //Light cannot be blocked on same tile
		else
			var/s = SIGN(Y2-Y1)
			Y1+=s
			while(Y1!=Y2)
				T=locate(X1, Y1, Z)
				if(T.opacity)
					return 0
				Y1+=s
	else
		var/m=(32*(Y2-Y1)+(PY2-PY1))/(32*(X2-X1)+(PX2-PX1))
		var/b=(Y1+PY1/32-0.015625)-m*(X1+PX1/32-0.015625) //In tiles
		var/signX = SIGN(X2-X1)
		var/signY = SIGN(Y2-Y1)
		if(X1<X2)
			b+=m
		while(X1!=X2 || Y1!=Y2)
			if(round(m*X1+b-Y1))
				Y1+=signY //Line exits tile vertically
			else
				X1+=signX //Line exits tile horizontally
			T=locate(X1, Y1, Z)
			if(T.opacity)
				return 0
	return 1

/proc/isInSight(atom/A, atom/B)
	var/turf/Aturf = get_turf(A)
	var/turf/Bturf = get_turf(B)

	if(!Aturf || !Bturf)
		return 0

	if(inLineOfSight(Aturf.x, Aturf.y, Bturf.x, Bturf.y, Aturf.z))
		return 1

	else
		return 0

/proc/get_cardinal_step_away(atom/start, atom/finish) //returns the position of a step from start away from finish, in one of the cardinal directions
	//returns only NORTH, SOUTH, EAST, or WEST
	var/dx = finish.x - start.x
	var/dy = finish.y - start.y
	if(abs(dy) > abs (dx)) //slope is above 1:1 (move horizontally in a tie)
		if(dy > 0)
			return get_step(start, SOUTH)
		else
			return get_step(start, NORTH)
	else
		if(dx > 0)
			return get_step(start, WEST)
		else
			return get_step(start, EAST)

/proc/get_mob_by_key(key)
	var/ckey = ckey(key)
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(M.ckey == ckey)
			return M
	return null

/proc/get_client_by_ckey(key)
	for(var/mob/M in GLOB.player_list)
		if(M.ckey == lowertext(key))
			return M.client
	return null

// Will return a list of active candidates. It increases the buffer 5 times until it finds a candidate which is active within the buffer.
/proc/get_active_candidates(buffer = 1)

	var/list/candidates = list() //List of candidate KEYS to assume control of the new larva ~Carn
	var/i = 0
	while(candidates.len <= 0 && i < 5)
		for(var/mob/observer/ghost/G in GLOB.player_list)
			if(((G.client.inactivity/10)/60) <= buffer + i) // the most active players are more likely to become an alien
				if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
					candidates += G.key
		i++
	return candidates

/proc/ScreenText(obj/O, maptext="", screen_loc="CENTER-7,CENTER-7", maptext_height=480, maptext_width=480)
	if(!isobj(O))	O = new /obj/screen/text()
	O.maptext = maptext
	O.maptext_height = maptext_height
	O.maptext_width = maptext_width
	O.screen_loc = screen_loc
	return O

/proc/Show2Group4Delay(obj/O, list/group, delay=0)
	if(!isobj(O))	return
	if(!group)	group = clients
	for(var/client/C in group)
		C.screen += O
	if(delay)
		spawn(delay)
			for(var/client/C in group)
				C.screen -= O

/proc/flick_overlay(image/I, list/show_to, duration)
	for(var/client/C in show_to)
		C.images += I
	spawn(duration)
		for(var/client/C in show_to)
			C.images -= I

/datum/projectile_data
	var/src_x
	var/src_y
	var/time
	var/distance
	var/power_x
	var/power_y
	var/dest_x
	var/dest_y

/datum/projectile_data/New(src_x, src_y, time, distance, \
						   power_x, power_y, dest_x, dest_y)
	src.src_x = src_x
	src.src_y = src_y
	src.time = time
	src.distance = distance
	src.power_x = power_x
	src.power_y = power_y
	src.dest_x = dest_x
	src.dest_y = dest_y

/proc/projectile_trajectory(src_x, src_y, rotation, angle, power)

	// returns the destination (Vx, y) that a projectile shot at [src_x], [src_y], with an angle of [angle],
	// rotated at [rotation] and with the power of [power]
	// Thanks to VistaPOWA for this function

	var/power_x = power * cos(angle)
	var/power_y = power * sin(angle)
	var/time = 2* power_y / 10 //10 = g

	var/distance = time * power_x

	var/dest_x = src_x + distance*sin(rotation);
	var/dest_y = src_y + distance*cos(rotation);

	return new /datum/projectile_data(src_x, src_y, time, distance, power_x, power_y, dest_x, dest_y)

/proc/GetRedPart(hexa)
	return GETREDPART(hexa)

/proc/GetGreenPart(hexa)
	return GETGREENPART(hexa)

/proc/GetBluePart(hexa)
	return GETBLUEPART(hexa)

/proc/GetHexColors(hexa)
	return list(
			GetRedPart(hexa),
			GetGreenPart(hexa),
			GetBluePart(hexa)
		)

/proc/iscolor(color)
	var/h = copytext(color, 1, 2)
	var/r = GetRedPart(color)
	var/g = GetGreenPart(color)
	var/b = GetBluePart(color)

	if(!isnum(r) || r > 255 || r < 0)
		return FALSE
	if(!isnum(g) || g > 255 || g < 0)
		return FALSE
	if(!isnum(b) || b > 255 || b < 0)
		return FALSE
	if(h != "#")
		return FALSE

	return TRUE

/proc/MixColors(const/list/colors)
	var/list/reds = list()
	var/list/blues = list()
	var/list/greens = list()
	var/list/weights = list()

	for (var/i = 0, ++i <= colors.len)
		reds.Add(GetRedPart(colors[i]))
		blues.Add(GetBluePart(colors[i]))
		greens.Add(GetGreenPart(colors[i]))
		weights.Add(1)

	var/r = mixOneColor(weights, reds)
	var/g = mixOneColor(weights, greens)
	var/b = mixOneColor(weights, blues)
	return rgb(r, g, b)

/proc/mixOneColor(list/weight, list/color)
	if (!weight || !color || length(weight)!=length(color))
		return 0

	var/contents = length(weight)
	var/i

	//normalize weights
	var/listsum = 0
	for(i=1; i<=contents; i++)
		listsum += weight[i]
	for(i=1; i<=contents; i++)
		weight[i] /= listsum

	//mix them
	var/mixedcolor = 0
	for(i=1; i<=contents; i++)
		mixedcolor += weight[i]*color[i]
	mixedcolor = round(mixedcolor)

	//until someone writes a formal proof for this algorithm, let's keep this in
//	if(mixedcolor<0x00 || mixedcolor>0xFF)
//		return 0
	//that's not the kind of operation we are running here, nerd
	mixedcolor=min(max(mixedcolor, 0), 255)

	return mixedcolor

/**
* Gets the highest and lowest pressures from the tiles in cardinal directions
* around us, then checks the difference.
*/
/proc/getOPressureDifferential(turf/loc)
	var/minp=16777216;
	var/maxp=0;
	for(var/dir in cardinal)
		var/turf/simulated/T=get_turf(get_step(loc, dir))
		var/cp=0
		if(T && istype(T) && T.zone)
			var/datum/gas_mixture/environment = T.return_air()
			cp = environment.return_pressure()
		else
			if(istype(T,/turf/simulated))
				continue
		if(cp<minp)minp=cp
		if(cp>maxp)maxp=cp
	return abs(minp-maxp)

/proc/convert_k2c(temp)
	return ((temp - T0C))

/proc/convert_c2k(temp)
	return ((temp + T0C))

/proc/getCardinalAirInfo(turf/loc, list/stats=list("temperature"))
	var/list/temps = new/list(4)
	for(var/dir in cardinal)
		var/direction
		switch(dir)
			if(NORTH)
				direction = 1
			if(SOUTH)
				direction = 2
			if(EAST)
				direction = 3
			if(WEST)
				direction = 4
		var/turf/simulated/T=get_turf(get_step(loc, dir))
		var/list/rstats = new /list(stats.len)
		if(T && istype(T) && T.zone)
			var/datum/gas_mixture/environment = T.return_air()
			for(var/i=1;i<=stats.len;i++)
				if(stats[i] == "pressure")
					rstats[i] = environment.return_pressure()
				else
					rstats[i] = environment.vars[stats[i]]
		else if(istype(T, /turf/simulated))
			rstats = null // Exclude zone (wall, door, etc).
		else if(istype(T, /turf))
			// Should still work.  (/turf/return_air())
			var/datum/gas_mixture/environment = T.return_air()
			for(var/i=1;i<=stats.len;i++)
				if(stats[i] == "pressure")
					rstats[i] = environment.return_pressure()
				else
					rstats[i] = environment.vars[stats[i]]
		temps[direction] = rstats
	return temps

/proc/MinutesToTicks(minutes)
	return SecondsToTicks(60 * minutes)

/proc/SecondsToTicks(seconds)
	return seconds * 10

/proc/get_vents()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in GLOB.machines)
		if(!temp_vent.welded && temp_vent.network && isOnStationLevel(temp_vent))
			if(temp_vent.network.normal_members.len > 15)
				vents += temp_vent
	return vents


/proc/is_opaque(turf/T)
	if(!T)
		return FALSE
	if (T.opacity)
		return TRUE
	for(var/obj/O in T.contents)
		if (O.opacity)
			return TRUE
	return FALSE

/proc/get_preferences(mob/target)
	var/datum/preferences/P = null
	if (target.client)
		P = target.client.prefs
	else if (target.ckey)
		P = SScharacter_setup.preferences_datums[target.ckey]
	else if (target.mind && target.mind.key)
		P = SScharacter_setup.preferences_datums[target.mind.key]

	return P


//Picks a single random landmark of a specified type
/proc/pick_landmark(ltype)
	var/list/L = list()
	for(var/S in GLOB.landmarks_list)
		if (istype(S, ltype))
			L.Add(S)

	if (L.len)
		return pick(L)

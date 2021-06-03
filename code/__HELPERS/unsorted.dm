//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/*
 * A large number of misc global procs.
 */

//Checks if all high bits in req_mask are set in bitfield
#define BIT_TEST_ALL(bitfield, req_mask) ((~(bitfield) & (req_mask)) == 0)

//Inverts the colour of an HTML string
/proc/invertHTML(HTMLstring)
	if(!istext(HTMLstring))
		CRASH("Given non-text argument!")
	else if(length(HTMLstring) != 7)
		CRASH("Given non-HTML argument!")
	else if(length_char(HTMLstring) != 7)
		CRASH("Given non-hex symbols in argument!")
	var/textr = copytext(HTMLstring, 2, 4)
	var/textg = copytext(HTMLstring, 4, 6)
	var/textb = copytext(HTMLstring, 6, 8)
	return rgb(255 - hex2num(textr), 255 - hex2num(textg), 255 - hex2num(textb))

//Returns the middle-most value
/proc/dd_range(var/low, var/high, var/num)
	return max(low, min(high, num))

//Returns whether or not A is the middle most value
/proc/InRange(var/A, var/lower, var/upper)
	if(A < lower) return 0
	if(A > upper) return 0
	return 1


/proc/Get_Angle(atom/movable/start, atom/movable/end)//For beams.
	if(!start || !end) return 0
	var/dy
	var/dx
	dy=(32*end.y+end.pixel_y)-(32*start.y+start.pixel_y)
	dx=(32*end.x+end.pixel_x)-(32*start.x+start.pixel_x)
	if(!dy)
		return (dx>=0)?90:270
	.=arctan(dx/dy)
	if(dy<0)
		.+=180
	else if(dx<0)
		.+=360

//Returns location. Returns null if no location was found.
/proc/get_teleport_loc(turf/location, mob/target, distance = 1, density = FALSE, errorx = 0, errory = 0, eoffsetx = 0, eoffsety = 0)
/*
Location where the teleport begins, target that will teleport, distance to go, density checking 0/1(yes/no).
Random error in tile placement x, error in tile placement y, and block offset.
Block offset tells the proc how to place the box. Behind teleport location, relative to starting location, forward, etc.
Negative values for offset are accepted, think of it in relation to North, -x is west, -y is south. Error defaults to positive.
Turf and target are seperate in case you want to teleport some distance from a turf the target is not standing on or something.
*/

	var/dirx = 0//Generic location finding variable.
	var/diry = 0

	var/xoffset = 0//Generic counter for offset location.
	var/yoffset = 0

	var/b1xerror = 0//Generic placing for point A in box. The lower left.
	var/b1yerror = 0
	var/b2xerror = 0//Generic placing for point B in box. The upper right.
	var/b2yerror = 0

	errorx = abs(errorx)//Error should never be negative.
	errory = abs(errory)
	//var/errorxy = round((errorx+errory)/2)//Used for diagonal boxes.

	switch(target.dir)//This can be done through equations but switch is the simpler method. And works fast to boot.
	//Directs on what values need modifying.
		if(1)//North
			diry+=distance
			yoffset+=eoffsety
			xoffset+=eoffsetx
			b1xerror-=errorx
			b1yerror-=errory
			b2xerror+=errorx
			b2yerror+=errory
		if(2)//South
			diry-=distance
			yoffset-=eoffsety
			xoffset+=eoffsetx
			b1xerror-=errorx
			b1yerror-=errory
			b2xerror+=errorx
			b2yerror+=errory
		if(4)//East
			dirx+=distance
			yoffset+=eoffsetx//Flipped.
			xoffset+=eoffsety
			b1xerror-=errory//Flipped.
			b1yerror-=errorx
			b2xerror+=errory
			b2yerror+=errorx
		if(8)//West
			dirx-=distance
			yoffset-=eoffsetx//Flipped.
			xoffset+=eoffsety
			b1xerror-=errory//Flipped.
			b1yerror-=errorx
			b2xerror+=errory
			b2yerror+=errorx

	var/turf/destination=locate(location.x+dirx, location.y+diry, location.z)

	if(destination)//If there is a destination.
		if(errorx||errory)//If errorx or y were specified.
			var/destination_list[] = list()//To add turfs to list.
			//destination_list = new()
			/*This will draw a block around the target turf, given what the error is.
			Specifying the values above will basically draw a different sort of block.
			If the values are the same, it will be a square. If they are different, it will be a rectengle.
			In either case, it will center based on offset. Offset is position from center.
			Offset always calculates in relation to direction faced. In other words, depending on the direction of the teleport,
			the offset should remain positioned in relation to destination.*/

			var/turf/center = locate((destination.x+xoffset), (destination.y+yoffset), location.z)//So now, find the new center.

			//Now to find a box from center location and make that our destination.
			for(var/turf/T in block(locate(center.x+b1xerror, center.y+b1yerror, location.z), locate(center.x+b2xerror, center.y+b2yerror, location.z) ))
				if(density&&T.density)	continue//If density was specified.
				if(T.x>world.maxx || T.x<1)	continue//Don't want them to teleport off the map.
				if(T.y>world.maxy || T.y<1)	continue
				destination_list += T
			if(destination_list.len)
				destination = pick(destination_list)
			else	return

		else//Same deal here.
			if(density&&destination.density)	return
			if(destination.x>world.maxx || destination.x<1)	return
			if(destination.y>world.maxy || destination.y<1)	return
	else	return

	return destination



/proc/LinkBlocked(turf/A, turf/B)
	if(A == null || B == null) return 1
	var/adir = get_dir(A, B)
	var/rdir = get_dir(B, A)
	if((adir & (NORTH|SOUTH)) && (adir & (EAST|WEST)))	//	diagonal
		var/iStep = get_step(A, adir&(NORTH|SOUTH))
		if(!LinkBlocked(A, iStep) && !LinkBlocked(iStep, B)) return 0

		var/pStep = get_step(A, adir&(EAST|WEST))
		if(!LinkBlocked(A, pStep) && !LinkBlocked(pStep, B)) return 0
		return 1

	if(DirBlocked(A, adir)) return 1
	if(DirBlocked(B, rdir)) return 1
	return 0


/proc/DirBlocked(turf/loc, var/dir)
	for(var/obj/structure/window/D in loc)
		if(!D.density)			continue
		if(D.dir == SOUTHWEST)	return 1
		if(D.dir == dir)		return 1

	for(var/obj/machinery/door/D in loc)
		if(!D.density)			continue
		if(istype(D, /obj/machinery/door/window))
			if((dir & SOUTH) && (D.dir & (EAST|WEST)))		return 1
			if((dir & EAST ) && (D.dir & (NORTH|SOUTH)))	return 1
		else return 1	// it's a real, air blocking door
	return 0

/proc/TurfBlockedNonWindow(turf/loc)
	for(var/obj/O in loc)
		if(O.density && !istype(O, /obj/structure/window))
			return 1
	return 0

/proc/sign(x)
	return x!=0?x/abs(x):0

/proc/getline(atom/M, atom/N)//Ultra-Fast Bresenham Line-Drawing Algorithm
	var/px=M.x		//starting x
	var/py=M.y
	var/line[] = list(locate(px, py, M.z))
	var/dx=N.x-px	//x distance
	var/dy=N.y-py
	var/dxabs=abs(dx)//Absolute value of x distance
	var/dyabs=abs(dy)
	var/sdx=sign(dx)	//Sign of x distance (+ or -)
	var/sdy=sign(dy)
	var/x=dxabs>>1	//Counters for steps taken, setting to distance/2
	var/y=dyabs>>1	//Bit-shifting makes me l33t.  It also makes getline() unnessecarrily fast.
	var/j			//Generic integer for counting
	if(dxabs>=dyabs)	//x distance is greater than y
		for(j=0;j<dxabs;j++)//It'll take dxabs steps to get there
			y+=dyabs
			if(y>=dxabs)	//Every dyabs steps, step once in y direction
				y-=dxabs
				py+=sdy
			px+=sdx		//Step on in x direction
			line+=locate(px, py, M.z)//Add the turf to the list
	else
		for(j=0;j<dyabs;j++)
			x+=dxabs
			if(x>=dyabs)
				x-=dyabs
				px+=sdx
			py+=sdy
			line+=locate(px, py, M.z)
	return line

#define LOCATE_COORDS(X, Y, Z) locate(between(1, X, world.maxx), between(1, Y, world.maxy), Z)
/proc/getcircle(turf/center, var/radius) //Uses a fast Bresenham rasterization algorithm to return the turfs in a thin circle.
	if(!radius) return list(center)

	var/x = 0
	var/y = radius
	var/p = 3 - 2 * radius

	. = list()
	while(y >= x) // only formulate 1/8 of circle

		. += LOCATE_COORDS(center.x - x, center.y - y, center.z) //upper left left
		. += LOCATE_COORDS(center.x - y, center.y - x, center.z) //upper upper left
		. += LOCATE_COORDS(center.x + y, center.y - x, center.z) //upper upper right
		. += LOCATE_COORDS(center.x + x, center.y - y, center.z) //upper right right
		. += LOCATE_COORDS(center.x - x, center.y + y, center.z) //lower left left
		. += LOCATE_COORDS(center.x - y, center.y + x, center.z) //lower lower left
		. += LOCATE_COORDS(center.x + y, center.y + x, center.z) //lower lower right
		. += LOCATE_COORDS(center.x + x, center.y + y, center.z) //lower right right

		if(p < 0)
			p += 4*x++ + 6;
		else
			p += 4*(x++ - y--) + 10;

#undef LOCATE_COORDS

//Returns whether or not a player is a guest using their ckey as an input
/proc/IsGuestKey(key)
	if(findtext(key, "Guest-", 1, 7) != 1) //was findtextEx
		return FALSE

	var/i, ch, len = length(key)

	for(i = 7, i <= len, ++i) //we know the first 6 chars are Guest-
		ch = text2ascii(key, i)
		if(ch < 48 || ch > 57) //0-9
			return FALSE
	return TRUE

//Ensure the frequency is within bounds of what it should be sending/recieving at
/proc/sanitize_frequency(var/f, var/low = PUBLIC_LOW_FREQ, var/high = PUBLIC_HIGH_FREQ)
	f = round(f)
	f = max(low, f)
	f = min(high, f)
	if((f % 2) == 0) //Ensure the last digit is an odd number
		f += 1
	return f

//Turns 1479 into 147.9
/proc/format_frequency(var/f)
	return "[round(f / 10)].[f % 10]"



//This will update a mob's name, real_name, mind.name, data_core records, pda and id
//Calling this proc without an oldname will only update the mob and skip updating the pda, id and records ~Carn
/mob/proc/fully_replace_character_name(oldname, newname)
	if(!newname)	return 0
	real_name = newname
	name = newname
	if(mind)
		mind.name = newname
	if(dna)
		dna.real_name = real_name

	if(oldname)
		//update the datacore records! This is goig to be a bit costly.
		for(var/list/L in list(data_core.general, data_core.medical, data_core.security, data_core.locked))
			for(var/datum/data/record/R in L)
				if(R.fields["name"] == oldname)
					R.fields["name"] = newname
					break

		//update our pda and id if we have them on our person
		var/list/searching = GetAllContents(searchDepth = 3)
		var/search_id = 1
		var/search_pda = 1

		for(var/A in searching)
			if( search_id && istype(A,/obj/item/weapon/card/id) )
				var/obj/item/weapon/card/id/ID = A
				if(ID.registered_name == oldname)
					ID.registered_name = newname
					ID.name = "[newname]'s ID Card ([ID.assignment])"
					if(!search_pda)	break
					search_id = 0
	return 1



//Generalised helper proc for letting mobs rename themselves. Used to be clname() and ainame()
//Last modified by Carn
/mob/proc/rename_self(var/role, var/allow_numbers=0)
	spawn(0)
		var/oldname = real_name

		var/time_passed = world.time
		var/newname

		for(var/i=1, i<=3, i++)	//we get 3 attempts to pick a suitable name.
			newname = input(src, "You are \a [role]. Would you like to change your name to something else?", "Name change", oldname) as text
			if((world.time-time_passed)>3000)
				return	//took too long
			newname = sanitizeName(newname, ,allow_numbers)	//returns null if the name doesn't meet some basic requirements. Tidies up a few other things like bad-characters.

			for(var/mob/living/M in GLOB.player_list)
				if(M == src)
					continue
				if(!newname || M.real_name == newname)
					newname = null
					break
			if(newname)
				break	//That's a suitable name!
			to_chat(src, "Sorry, that [role]-name wasn't appropriate, please try another. It's possibly too long/short, has bad characters or is already taken.")

		if(!newname)	//we'll stick with the oldname then
			return

		if(cmptext("ai", role))
			if(isAI(src))
				var/mob/living/silicon/ai/A = src
				oldname = null//don't bother with the records update crap

				// Set eyeobj name
				A.SetName(newname)


		fully_replace_character_name(oldname, newname)



//Picks a string of symbols to display as the law number for hacked or ion laws
/proc/ionnum()
	return "[pick("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")][pick("!", "@", "#", "$", "%", "^", "&", "*")][pick("!", "@", "#", "$", "%", "^", "&", "*")][pick("!", "@", "#", "$", "%", "^", "&", "*")]"

//When an AI is activated, it can choose from a list of non-slaved borgs to have as a slave.
/proc/freeborg()
	var/select
	var/list/borgs = list()
	for(var/mob/living/silicon/robot/A in GLOB.player_list)
		if(A.stat == 2 || A.connected_ai || A.scrambledcodes || isdrone(A))
			continue
		var/name = "[A.real_name] ([A.modtype] [A.braintype])"
		borgs[name] = A

	if(borgs.len)
		select = input("Unshackled borg signals detected:", "Borg selection", null, null) as null|anything in borgs
		return borgs[select]

//When a borg is activated, it can choose which AI it wants to be slaved to
/proc/active_ais()
	. = list()
	for(var/mob/living/silicon/ai/A in GLOB.living_mob_list)
		if(A.stat == DEAD)
			continue
		if(A.control_disabled == 1)
			continue
		. += A
	return .

//Find an active ai with the least borgs. VERBOSE PROCNAME HUH!
/proc/select_active_ai_with_fewest_borgs()
	var/mob/living/silicon/ai/selected
	var/list/active = active_ais()
	for(var/mob/living/silicon/ai/A in active)
		if(!selected || (selected.connected_robots.len > A.connected_robots.len))
			selected = A

	return selected

/proc/select_active_ai(var/mob/user)
	var/list/ais = active_ais()
	if(ais.len)
		if(user)	. = input(usr, "AI signals detected:", "AI selection") in ais
		else		. = pick(ais)
	return .

/proc/get_sorted_mobs()
	var/list/old_list = getmobs()
	var/list/AI_list = list()
	var/list/Dead_list = list()
	var/list/keyclient_list = list()
	var/list/key_list = list()
	var/list/logged_list = list()
	for(var/named in old_list)
		var/mob/M = old_list[named]
		if(issilicon(M))
			AI_list |= M
		else if(isghost(M) || M.stat == DEAD)
			Dead_list |= M
		else if(M.key && M.client)
			keyclient_list |= M
		else if(M.key)
			key_list |= M
		else
			logged_list |= M
		old_list.Remove(named)
	var/list/new_list = list()
	new_list += AI_list
	new_list += keyclient_list
	new_list += key_list
	new_list += logged_list
	new_list += Dead_list
	return new_list

//Returns a list of all mobs with their name
/proc/getmobs()

	var/list/mobs = sortmobs()
	var/list/names = list()
	var/list/creatures = list()
	var/list/namecounts = list()
	for(var/mob/M in mobs)
		var/name = M.name
		if(name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		if(M.real_name && M.real_name != M.name)
			name += " \[[M.real_name]\]"
		if(M.stat == 2)
			if(istype(M, /mob/observer/ghost/))
				name += " \[ghost\]"
			else
				name += " \[dead\]"
		creatures[name] = M

	return creatures

//Orders mobs by type then by name
/proc/sortmobs()
	var/list/moblist = list()
	var/list/sortmob = sortNames(GLOB.mob_list)
	for(var/mob/observer/eye/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/silicon/ai/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/silicon/pai/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/silicon/robot/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/human/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/brain/M in sortmob)
		moblist.Add(M)
	for(var/mob/observer/ghost/M in sortmob)
		moblist.Add(M)
	for(var/mob/new_player/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/slime/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/simple_animal/M in sortmob)
		moblist.Add(M)
//	for(var/mob/living/silicon/hivebot/M in world)
//		mob_list.Add(M)
//	for(var/mob/living/silicon/hive_mainframe/M in world)
//		mob_list.Add(M)
	return moblist

//Forces a variable to be posative
/proc/modulus(var/M)
	if(M >= 0)
		return M
	if(M < 0)
		return -M

// returns the turf located at the map edge in the specified direction relative to A
// used for mass driver
/proc/get_edge_target_turf(var/atom/A, var/direction)

	var/turf/target = locate(A.x, A.y, A.z)
	if(!A || !target)
		return 0
		//since NORTHEAST == NORTH & EAST, etc, doing it this way allows for diagonal mass drivers in the future
		//and isn't really any more complicated

		// Note diagonal directions won't usually be accurate
	if(direction & NORTH)
		target = locate(target.x, world.maxy, target.z)
	if(direction & SOUTH)
		target = locate(target.x, 1, target.z)
	if(direction & EAST)
		target = locate(world.maxx, target.y, target.z)
	if(direction & WEST)
		target = locate(1, target.y, target.z)

	return target

// returns turf relative to A in given direction at set range
// result is bounded to map size
// note range is non-pythagorean
// used for disposal system
/proc/get_ranged_target_turf(var/atom/A, var/direction, var/range)

	var/x = A.x
	var/y = A.y
	if(direction & NORTH)
		y = min(world.maxy, y + range)
	if(direction & SOUTH)
		y = max(1, y - range)
	if(direction & EAST)
		x = min(world.maxx, x + range)
	if(direction & WEST)
		x = max(1, x - range)

	return locate(x, y, A.z)


// returns turf relative to A offset in dx and dy tiles
// bound to map limits
/proc/get_offset_target_turf(var/atom/A, var/dx, var/dy)
	var/x = min(world.maxx, max(1, A.x + dx))
	var/y = min(world.maxy, max(1, A.y + dy))
	return locate(x, y, A.z)

//Makes sure MIDDLE is between LOW and HIGH. If not, it adjusts it. Returns the adjusted value. Lower bound takes priority.
/proc/between(var/low, var/middle, var/high)
	return max(min(middle, high), low)

//returns random gauss number
proc/GaussRand(var/sigma)
  var/x, y, rsq
  do
    x=2*rand()-1
    y=2*rand()-1
    rsq=x*x+y*y
  while(rsq>1 || !rsq)
  return sigma*y*sqrt(-2*log(rsq)/rsq)

//returns random gauss number, rounded to 'roundto'
proc/GaussRandRound(var/sigma, var/roundto)
	return round(GaussRand(sigma), roundto)

//Will return the contents of an atom recursivly to a depth of 'searchDepth'
/atom/proc/GetAllContents(searchDepth = 5, includeSelf = FALSE)
	var/list/toReturn = list()

	if(includeSelf)
		toReturn += src

	for(var/atom/part in contents)
		toReturn += part
		if(part.contents.len && searchDepth)
			toReturn += part.GetAllContents(searchDepth - 1)

	return toReturn

//Step-towards method of determining whether one atom can see another. Similar to viewers()
/proc/can_see(var/atom/source, var/atom/target, var/length=5) // I couldn't be arsed to do actual raycasting :I This is horribly inaccurate.
	var/turf/current = get_turf(source)
	var/turf/target_turf = get_turf(target)
	var/steps = 0

	if(!current || !target_turf)
		return 0

	while(current != target_turf)
		if(steps > length) return 0
		if(current.opacity) return 0
		for(var/atom/A in current)
			if(A.opacity) return 0
		current = get_step_towards(current, target_turf)
		steps++

	return 1

/proc/is_blocked_turf(var/turf/T)
	var/cant_pass = 0
	if(T.density) cant_pass = 1
	for(var/atom/A in T)
		if(A.density)//&&A.anchored
			cant_pass = 1
	return cant_pass

/proc/get_step_towards2(var/atom/ref , var/atom/trg)
	var/base_dir = get_dir(ref, get_step_towards(ref, trg))
	var/turf/temp = get_step_towards(ref, trg)

	if(is_blocked_turf(temp))
		var/dir_alt1 = turn(base_dir, 90)
		var/dir_alt2 = turn(base_dir, -90)
		var/turf/turf_last1 = temp
		var/turf/turf_last2 = temp
		var/free_tile
		var/breakpoint = 0

		while(!free_tile && breakpoint < 10)
			if(!is_blocked_turf(turf_last1))
				free_tile = turf_last1
				break
			if(!is_blocked_turf(turf_last2))
				free_tile = turf_last2
				break
			turf_last1 = get_step(turf_last1, dir_alt1)
			turf_last2 = get_step(turf_last2, dir_alt2)
			breakpoint++

		if(!free_tile) return get_step(ref, base_dir)
		else return get_step_towards(ref, free_tile)

	else return get_step(ref, base_dir)

//Takes: Anything that could possibly have variables and a varname to check.
//Returns: 1 if found, 0 if not.
/proc/hasvar(var/datum/A, var/varname)
	if(A.vars.Find(lowertext(varname))) return 1
	else return 0

//Returns: all the areas in the world, sorted.
/proc/return_sorted_areas()
	return sortNames(GLOB.map_areas)

//Takes: Area type as a text string from a variable.
//Returns: Instance for the area in the world.
/proc/get_area_instance_from_text(areatext)
	if(istext(areatext))
		areatext = text2path(areatext)
	return get_area_name(areatext)

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all areas of that type in the world.
/proc/get_areas(var/areatype)
	if(istext(areatype))
		areatype = text2path(areatype)
	else if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type
	else if(!ispath(areatype))
		return null

	var/list/areas = list()
	for(var/area/N in GLOB.map_areas)
		if(istype(N, areatype)) areas += N
	return areas

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all atoms	(objs, turfs, mobs) in areas of that type of that type in the world.
/proc/get_area_all_atoms(var/areatype)
	if(!areatype) return null
	if(istext(areatype)) areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/atoms = new/list()
	for(var/area/N in GLOB.map_areas)
		if(istype(N, areatype))
			for(var/atom/A in N)
				atoms += A
	return atoms

/datum/coords //Simple datum for storing coordinates.
	var/x_pos
	var/y_pos
	var/z_pos
	var/area_name

/datum/coords/New(turf/loc)
	if(loc)
		x_pos = loc.x
		y_pos = loc.y
		z_pos = loc.z
		var/area/A = get_area(loc)
		area_name = A?.name

/datum/coords/proc/get_text(display_area=TRUE)
	var/displayed_area = display_area && area_name ? " - [strip_improper(area_name)]" : ""
	var/displayed_x = "[x_pos]"
	var/displayed_y = "[y_pos]"
	var/displayed_z = "[z_pos]"

	var/obj/map_data/M = GLOB.maps_data.all_levels[z_pos]
	if(M.custom_z_names)
		return "[displayed_x]:[displayed_y], [M.custom_z_name(z_pos)][displayed_area]"

	return "[displayed_x]:[displayed_y]:[displayed_z][displayed_area]"


/area/proc/move_contents_to(var/area/A, var/turftoleave, var/direction)
	//Takes: Area. Optional: turf type to leave behind.
	//Returns: Nothing.
	//Notes: Attempts to move the contents of one area to another area.
	//       Movement based on lower left corner. Tiles that do not fit
	//		 into the new area will not be moved.

	if(!A || !src) return 0

	var/list/turfs_src = get_area_turfs(src)
	var/list/turfs_trg = get_area_turfs(A)

	var/src_min_x = 0
	var/src_min_y = 0
	for(var/turf/T in turfs_src)
		if(T.x < src_min_x || !src_min_x) src_min_x	= T.x
		if(T.y < src_min_y || !src_min_y) src_min_y	= T.y

	var/trg_min_x = 0
	var/trg_min_y = 0
	for(var/turf/T in turfs_trg)
		if(T.x < trg_min_x || !trg_min_x) trg_min_x	= T.x
		if(T.y < trg_min_y || !trg_min_y) trg_min_y	= T.y

	var/list/refined_src = new/list()
	for(var/turf/T in turfs_src)
		refined_src += T
		refined_src[T] = new/datum/coords
		var/datum/coords/C = refined_src[T]
		C.x_pos = (T.x - src_min_x)
		C.y_pos = (T.y - src_min_y)

	var/list/zones_trg = new/list() // Let's add zones from a target destination for rebuilding after.
	var/list/refined_trg = new/list()
	for(var/turf/T in turfs_trg)
		if(istype(T, /turf/simulated))
			var/turf/simulated/TZ = T
			if(TZ.zone)
				zones_trg |= TZ.zone
			qdel(TZ) // Prevents lighting bugs. Don't ask.
		refined_trg += T
		refined_trg[T] = new/datum/coords
		var/datum/coords/C = refined_trg[T]
		C.x_pos = (T.x - trg_min_x)
		C.y_pos = (T.y - trg_min_y)

	var/list/fromupdate = new/list()
	var/list/toupdate = new/list()

	moving:
		for(var/turf/T in refined_src)
			var/datum/coords/C_src = refined_src[T]
			for(var/turf/B in refined_trg)
				var/datum/coords/C_trg = refined_trg[B]
				if(C_src.x_pos == C_trg.x_pos && C_src.y_pos == C_trg.y_pos)

					var/old_dir1 = T.dir
					var/old_icon_state1 = T.icon_state
					var/old_icon1 = T.icon
					var/old_overlays = T.overlays.Copy()
					var/old_underlays = T.underlays.Copy()
					var/old_decals = T.decals
					var/old_opacity = T.opacity // For shuttle windows

					var/turf/X = B.ChangeTurf(T.type)
					X.set_dir(old_dir1)
					X.icon_state = old_icon_state1
					X.icon = old_icon1 //Shuttle floors are in shuttle.dmi while the defaults are floors.dmi
					X.set_overlays(old_overlays)
					X.underlays = old_underlays
					X.decals = old_decals
					X.opacity = old_opacity

					if(istype(T, /turf/simulated/open) || istype(T, /turf/space) || istype(T, /turf/simulated/floor/asteroid))
						X.ChangeTurf(get_base_turf_by_area(B))

					var/turf/simulated/ST = T
					if(istype(ST) && ST.zone)
						var/turf/simulated/SX = X
						if(!SX.air)
							SX.make_air()
						SX.air.copy_from(ST.zone.air)
						ST.zone.remove(ST)

					/* Quick visual fix for some weird shuttle corner artefacts when on transit space tiles */
					if(direction && findtext(X.icon_state, "swall_s"))

						// Spawn a new shuttle corner object
						var/obj/corner = new()
						corner.loc = X
						corner.density = TRUE
						corner.anchored = TRUE
						corner.icon = X.icon
						corner.icon_state = replacetext(X.icon_state, "_s", "_f")
						corner.tag = "delete me"
						corner.name = "wall"

						// Find a new turf to take on the property of
						var/turf/nextturf = get_step(corner, direction)
						if(!nextturf || !istype(nextturf, /turf/space))
							nextturf = get_step(corner, turn(direction, 180))


						// Take on the icon of a neighboring scrolling space icon
						X.icon = nextturf.icon
						X.icon_state = nextturf.icon_state


					for(var/obj/O in T)

						// Reset the shuttle corners
						if(O.tag == "delete me")
							X.icon = 'icons/turf/shuttle.dmi'
							X.icon_state = replacetext(O.icon_state, "_f", "_s") // revert the turf to the old icon_state
							X.name = "wall"
							qdel(O) // prevents multiple shuttle corners from stacking
							continue
						O.forceMove(X)
					for(var/mob/M in T)
						// If we need to check for more mobs, I'll add a variable
						if(!ismob(M) || isEye(M))
							continue
						M.loc = X

//					var/area/AR = X.loc

//					if(AR.lighting_use_dynamic)							//TODO: rewrite this code so it's not messed by lighting ~Carn
//						X.opacity = !X.opacity
//						X.SetOpacity(!X.opacity)

					toupdate += X

					if(turftoleave)
						fromupdate += T.ChangeTurf(turftoleave)
					else
						T.ChangeTurf(get_base_turf_by_area(T))

					refined_src -= T
					refined_trg -= B
					continue moving

	for(var/zone/Z in zones_trg) // rebuilding zones
		Z.rebuild()

//Vars that will not be copied when using /DuplicateObject //from tg
GLOBAL_LIST_INIT(duplicate_forbidden_vars,list(
	"tag", "datum_components", "area", "type", "loc", "locs", "vars", "parent", "parent_type", "verbs", "ckey", "key",
	"contents", "reagents", "stat", "x", "y", "z", "comp_lookup", "bodyparts", "internal_organs", "hand_bodyparts",
	"overlays_standing", "hud_list", "computer_id", "lastKnownIP", "WIRE_RECEIVE", "WIRE_PULSE", "WIRE_PULSE_SPECIAL",
	"WIRE_RADIO_RECEIVE", "WIRE_RADIO_PULSE", "FREQ_LISTENING", "deffont", "signfont", "crayonfont", "hud_actions", "hidden_uplink",
	"gc_destroyed", "is_processing", "signal_procs", "signal_enabled"))

/proc/DuplicateObject(atom/original, perfectcopy = TRUE, sameloc, atom/newloc)
	RETURN_TYPE(original.type)
	if(!original)
		return

	var/atom/O

	if(sameloc)
		O = new original.type(original.loc)
	else
		O = new original.type(newloc)

	if(perfectcopy && O && original)
		var/list/all_vars = duplicate_vars(original)
		for(var/V in all_vars)
			O.vars[V] = all_vars[V]
	return O


/proc/duplicate_vars(atom/original)
	RETURN_TYPE(/list)
	var/list/all_vars = list()
	for(var/V in original.vars - GLOB.duplicate_forbidden_vars)
		if(islist(original.vars[V]))
			var/list/L = original.vars[V]
			all_vars[V] = L.Copy()
		else if(istype(original.vars[V], /datum) || ismob(original.vars[V]) || isHUDobj(original.vars[V]) || isobj(original.vars[V]))
			continue	// this would reference the original's object, that will break when it is used or deleted.
		else
			all_vars[V] = original.vars[V]
	return all_vars

/area/proc/copy_contents_to(var/area/A , var/platingRequired = 0 )
	//Takes: Area. Optional: If it should copy to areas that don't have plating
	//Returns: Nothing.
	//Notes: Attempts to move the contents of one area to another area.
	//       Movement based on lower left corner. Tiles that do not fit
	//		 into the new area will not be moved.

	// Does *not* affect gases etc; copied turfs will be changed via ChangeTurf, and the dir, icon, and icon_state copied. All other vars will remain default.

	if(!A || !src) return 0

	var/list/turfs_src = get_area_turfs(src.type)
	var/list/turfs_trg = get_area_turfs(A.type)

	var/src_min_x = 0
	var/src_min_y = 0
	for(var/turf/T in turfs_src)
		if(T.x < src_min_x || !src_min_x) src_min_x	= T.x
		if(T.y < src_min_y || !src_min_y) src_min_y	= T.y

	var/trg_min_x = 0
	var/trg_min_y = 0
	for(var/turf/T in turfs_trg)
		if(T.x < trg_min_x || !trg_min_x) trg_min_x	= T.x
		if(T.y < trg_min_y || !trg_min_y) trg_min_y	= T.y

	var/list/refined_src = new/list()
	for(var/turf/T in turfs_src)
		refined_src += T
		refined_src[T] = new/datum/coords
		var/datum/coords/C = refined_src[T]
		C.x_pos = (T.x - src_min_x)
		C.y_pos = (T.y - src_min_y)

	var/list/refined_trg = new/list()
	for(var/turf/T in turfs_trg)
		refined_trg += T
		refined_trg[T] = new/datum/coords
		var/datum/coords/C = refined_trg[T]
		C.x_pos = (T.x - trg_min_x)
		C.y_pos = (T.y - trg_min_y)

	var/list/toupdate = new/list()

	var/copiedobjs = list()


	moving:
		for(var/turf/T in refined_src)
			var/datum/coords/C_src = refined_src[T]
			for(var/turf/B in refined_trg)
				var/datum/coords/C_trg = refined_trg[B]
				if(C_src.x_pos == C_trg.x_pos && C_src.y_pos == C_trg.y_pos)

					var/old_dir1 = T.dir
					var/old_icon_state1 = T.icon_state
					var/old_icon1 = T.icon
					var/old_overlays = T.overlays.Copy()
					var/old_underlays = T.underlays.Copy()

					if(platingRequired)
						if(istype(B, get_base_turf_by_area(B)))
							continue moving

					var/turf/X = B
					X.ChangeTurf(T.type)
					X.set_dir(old_dir1)
					X.icon_state = old_icon_state1
					X.icon = old_icon1 //Shuttle floors are in shuttle.dmi while the defaults are floors.dmi
					X.set_overlays(old_overlays)
					X.underlays = old_underlays

					var/list/objs = new/list()
					var/list/newobjs = new/list()
					var/list/mobs = new/list()
					var/list/newmobs = new/list()

					for(var/obj/O in T)
						objs += O

					for(var/obj/O in objs)
						newobjs += DuplicateObject(O , 1)


					for(var/obj/O in newobjs)
						O.loc = X

					for(var/mob/M in T)

						if(!ismob(M) || isEye(M)) continue // If we need to check for more mobs, I'll add a variable
						mobs += M

					for(var/mob/M in mobs)
						newmobs += DuplicateObject(M , 1)

					for(var/mob/M in newmobs)
						M.loc = X

					copiedobjs += newobjs
					copiedobjs += newmobs

//					var/area/AR = X.loc

//					if(AR.lighting_use_dynamic)
//						X.opacity = !X.opacity
//						X.sd_SetOpacity(!X.opacity)			//TODO: rewrite this code so it's not messed by lighting ~Carn

					toupdate += X

					refined_src -= T
					refined_trg -= B
					continue moving




	if(toupdate.len)
		for(var/turf/simulated/T1 in toupdate)
			SSair.mark_for_update(T1)

	return copiedobjs



/proc/get_cardinal_dir(atom/A, atom/B)
	var/dx = abs(B.x - A.x)
	var/dy = abs(B.y - A.y)
	return get_dir(A, B) & (rand() * (dx+dy) < dy ? 3 : 12)

/proc/get_mob_with_client_list()
	var/list/mobs = list()
	for(var/mob/M in GLOB.mob_living_list)
		if(M.client)
			mobs += M
	return mobs


/proc/parse_zone(zone)
	switch(zone)
		if(BP_L_ARM)
			return "left arm"
		if(BP_R_ARM)
			return "right arm"
		if(BP_L_LEG )
			return "left leg"
		if(BP_R_LEG)
			return "right leg"
		else
			return zone

/proc/get(atom/loc, type)
	while(loc)
		if(istype(loc, type))
			return loc
		loc = loc.loc
	return null

/proc/get_turf_or_move(turf/location)
	return get_turf(location)

proc/is_hot(obj/item/W)
	if(QUALITY_WELDING in W.tool_qualities)
		return 3800
	switch(W.type)
		if(/obj/item/weapon/flame/lighter)
			if(W:lit)
				return 1500
			else
				return 0
		if(/obj/item/weapon/flame/match)
			if(W:lit)
				return 1000
			else
				return 0
		if(/obj/item/clothing/mask/smokable/cigarette)
			if(W:lit)
				return 1000
			else
				return 0
		if(/obj/item/weapon/melee/energy)
			return 3500
		else
			return 0

//Whether or not the given item counts as sharp in terms of dealing damage
/proc/is_sharp(obj/O)
	if(!O) return FALSE
	if(O.sharp) return TRUE
	if(O.edge) return TRUE
	return FALSE

//Whether or not the given item counts as cutting with an edge in terms of removing limbs
/proc/has_edge(obj/O)
	if(!O) return FALSE
	if(O.edge) return TRUE
	return FALSE

//Returns 1 if the given item is capable of popping things like balloons, inflatable barriers, or cutting police tape.
/proc/can_puncture(obj/item/W)		// For the record, WHAT THE HELL IS THIS METHOD OF DOING IT?
	if(!W) return FALSE
	if(W.sharp) return TRUE
	return ( \
		W.sharp														|| \
		istool(W)													|| \
		istype(W, /obj/item/weapon/pen)								|| \
		istype(W, /obj/item/weapon/flame/lighter/zippo)				|| \
		istype(W, /obj/item/weapon/flame/match)						|| \
		istype(W, /obj/item/clothing/mask/smokable/cigarette)		\
	)

/proc/is_surgery_tool(obj/item/W)
	return (	\
	istype(W, /obj/item/weapon/tool/scalpel)			||	\
	istype(W, /obj/item/weapon/tool/hemostat)		||	\
	istype(W, /obj/item/weapon/tool/retractor)		||	\
	istype(W, /obj/item/weapon/tool/cautery)			||	\
	istype(W, /obj/item/weapon/tool/bonesetter)
	)

/proc/reverse_direction(var/dir)
	switch(dir)
		if(NORTH)
			return SOUTH
		if(NORTHEAST)
			return SOUTHWEST
		if(EAST)
			return WEST
		if(SOUTHEAST)
			return NORTHWEST
		if(SOUTH)
			return NORTH
		if(SOUTHWEST)
			return NORTHEAST
		if(WEST)
			return EAST
		if(NORTHWEST)
			return SOUTHEAST

/*
Checks if that loc and dir has a item on the wall
*/
var/list/WALLITEMS = list(
	/obj/machinery/power/apc, /obj/machinery/alarm, /obj/item/device/radio/intercom,
	/obj/structure/extinguisher_cabinet, /obj/structure/reagent_dispensers/peppertank,
	/obj/machinery/status_display, /obj/machinery/requests_console, /obj/machinery/light_switch, /obj/structure/sign,
	/obj/machinery/newscaster, /obj/machinery/firealarm, /obj/structure/noticeboard,
	/obj/item/weapon/storage/secure/safe, /obj/machinery/door_timer, /obj/machinery/flasher, /obj/machinery/keycard_auth,
	/obj/structure/mirror, /obj/structure/fireaxecabinet, /obj/item/modular_computer/telescreen,
	/obj/machinery/light_construct, /obj/machinery/light, /obj/machinery/holomap
	)
/proc/gotwallitem(loc, dir)
	for(var/obj/O in loc)
		for(var/item in WALLITEMS)
			if(istype(O, item))
				//Direction works sometimes
				if(O.dir == dir)
					return 1

				//Some stuff doesn't use dir properly, so we need to check pixel instead
				switch(dir)
					if(SOUTH)
						if(O.pixel_y > 10)
							return 1
					if(NORTH)
						if(O.pixel_y < -10)
							return 1
					if(WEST)
						if(O.pixel_x > 10)
							return 1
					if(EAST)
						if(O.pixel_x < -10)
							return 1


	//Some stuff is placed directly on the wallturf (signs)
	for(var/obj/O in get_step(loc, dir))
		for(var/item in WALLITEMS)
			if(istype(O, item))
				if(O.pixel_x == 0 && O.pixel_y == 0)
					return 1
	return 0

var/list/FLOORITEMS = list(
	/obj/machinery/atmospherics/unary/vent_pump, /obj/machinery/atmospherics/unary/vent_scrubber,
	/obj/machinery/light_construct/floor, /obj/machinery/light/floor
	)

/proc/gotflooritem(loc, dir)
	for(var/obj/O in loc)
		for(var/item in FLOORITEMS)
			if(istype(O, item))
				return 1
				//Direction works sometimes
				//if(O.dir == dir)
				//	return 1

				/*//Some stuff doesn't use dir properly, so we need to check pixel instead
				switch(dir)
					if(SOUTH)
						if(O.pixel_y > 10)
							return 1
					if(NORTH)
						if(O.pixel_y < -10)
							return 1
					if(WEST)
						if(O.pixel_x > 10)
							return 1
					if(EAST)
						if(O.pixel_x < -10)
							return 1


	//Some stuff is placed directly on the wallturf (signs)
	for(var/obj/O in get_step(loc, dir))
		for(var/item in FLOORITEMS)
			if(istype(O, text2path(item)))
				if(O.pixel_x == 0 && O.pixel_y == 0)
					return 1*/
	//world << "no item on floor!"
	return 0

/proc/format_text(text)
	return replacetext(replacetext(text, "\proper ", ""), "\improper ", "")

/proc/topic_link(datum/D, arglist, content)
	if(istype(arglist,/list))
		arglist = list2params(arglist)
	return "<a href='?src=\ref[D];[arglist]'>[content]</a>"

/proc/get_random_colour(simple, lower, upper)
	var/colour
	if(simple)
		colour = pick(list("FF0000", "FF7F00", "FFFF00", "00FF00", "0000FF", "4B0082", "8F00FF"))
	else
		for(var/i=1;i<=3;i++)
			var/temp_col = "[num2hex(rand(lower, upper))]"
			if(length(temp_col )<2)
				temp_col  = "0[temp_col]"
			colour += temp_col
	return "#[colour]"

//gives us the stack trace from CRASH() without ending the current proc.
/proc/stack_trace(msg)
	CRASH(msg)

/datum/proc/stack_trace(msg)
	CRASH(msg)

GLOBAL_REAL_VAR(list/stack_trace_storage)
/proc/gib_stack_trace()
	stack_trace_storage = list()
	stack_trace()
	stack_trace_storage.Cut(1, min(3,stack_trace_storage.len))
	. = stack_trace_storage
	stack_trace_storage = null

GLOBAL_DATUM_INIT(dview_mob, /mob/dview, new)

//Version of view() which ignores darkness, because BYOND doesn't have it (I actually suggested it but it was tagged redundant, BUT HEARERS IS A T- /rant).
/proc/dview(range = world.view, center, invis_flags = 0)
	if(!center)
		return

	GLOB.dview_mob.loc = center

	GLOB.dview_mob.see_invisible = invis_flags

	. = view(range, GLOB.dview_mob)
	GLOB.dview_mob.loc = null

/mob/dview
	name = "INTERNAL DVIEW MOB"
	invisibility = 101
	density = FALSE
	see_in_dark = 1e6
	// move_resist = INFINITY
	var/ready_to_die = FALSE
	// eris specific
	anchored = TRUE
	simulated = FALSE

/mob/dview/Initialize() //Properly prevents this mob from gaining huds or joining any global lists
	SHOULD_CALL_PARENT(FALSE)
	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1
	return INITIALIZE_HINT_NORMAL

/mob/dview/Destroy(force = FALSE)
	if(!ready_to_die)
		stack_trace("ALRIGHT WHICH FUCKER TRIED TO DELETE *MY* DVIEW?")

		if (!force)
			return QDEL_HINT_LETMELIVE

		log_world("EVACUATE THE SHITCODE IS TRYING TO STEAL MUH JOBS")
		GLOB.dview_mob = new
	return ..()

#define UNTIL(X) while(!(X)) stoplag()

/atom/proc/get_light_and_color(atom/origin)
	if(origin)
		color = origin.color
		set_light(origin.light_range, origin.light_power, origin.light_color)


//counts the number of bits in Byond's 16-bit width field
//in constant time and memory!
/proc/BitCount(bitfield)
	var/temp = bitfield - ((bitfield>>1)&46811) - ((bitfield>>2)&37449) //0133333 and 0111111 respectively
	temp = ((temp + (temp>>3))&29127) % 63 //070707
	return temp

//returns a GUID like identifier (using a mostly made up record format)
//guids are not on their own suitable for access or security tokens, as most of their bits are predictable.
// (But may make a nice salt to one)
/proc/GUID()
	var/const/GUID_VERSION = "b"
	var/const/GUID_VARIANT = "d"
	var/node_id = copytext_char(md5("[rand()*rand(1,9999999)][world.name][world.hub][world.hub_password][world.internet_address][world.address][world.contents.len][world.status][world.port][rand()*rand(1,9999999)]"), 1, 13)

	var/time_high = "[num2hex(text2num(time2text(world.realtime,"YYYY")), 2)][num2hex(world.realtime, 6)]"

	var/time_mid = num2hex(world.timeofday, 4)

	var/time_low = num2hex(world.time, 3)

	var/time_clock = num2hex(TICK_DELTA_TO_MS(world.tick_usage), 3)

	return "{[time_high]-[time_mid]-[GUID_VERSION][time_low]-[GUID_VARIANT][time_clock]-[node_id]}"

// \ref behaviour got changed in 512 so this is necesary to replicate old behaviour.
// If it ever becomes necesary to get a more performant REF(), this lies here in wait
// #define REF(thing) (thing && istype(thing, /datum) && (thing:datum_flags & DF_USE_TAG) && thing:tag ? "[thing:tag]" : "\ref[thing]")
/proc/REF(input)
	if(istype(input, /datum))
		var/datum/thing = input
		if(thing.datum_flags & DF_USE_TAG)
			if(!thing.tag)
				stack_trace("A ref was requested of an object with DF_USE_TAG set but no tag: [thing]")
				thing.datum_flags &= ~DF_USE_TAG
			else
				return "\[[url_encode(thing.tag)]\]"
	return "\ref[input]"

// Makes a call in the context of a different usr
// Use sparingly
/world/proc/PushUsr(mob/M, datum/callback/CB, ...)
	var/temp = usr
	usr = M
	if (length(args) > 2)
		. = CB.Invoke(arglist(args.Copy(3)))
	else
		. = CB.Invoke()
	usr = temp

//datum may be null, but it does need to be a typed var
#define NAMEOF(datum, X) (#X || ##datum.##X)

#define VARSET_LIST_CALLBACK(target, var_name, var_value) CALLBACK(GLOBAL_PROC, /proc/___callbackvarset, ##target, ##var_name, ##var_value)
//dupe code because dm can't handle 3 level deep macros
#define VARSET_CALLBACK(datum, var, var_value) CALLBACK(GLOBAL_PROC, /proc/___callbackvarset, ##datum, NAMEOF(##datum, ##var), ##var_value)

/proc/___callbackvarset(list_or_datum, var_name, var_value)
	if(length(list_or_datum))
		list_or_datum[var_name] = var_value
		return
	var/datum/D = list_or_datum
	// if(IsAdminAdvancedProcCall())
	// 	D.vv_edit_var(var_name, var_value) //same result generally, unless badmemes
	// else
	D.vars[var_name] = var_value

/proc/CallAsync(datum/source, proctype, list/arguments)
	set waitfor = FALSE
	return call(source, proctype)(arglist(arguments))

// call to generate a stack trace and print to runtime logs
/proc/crash_with(msg)
	CRASH(msg)

/proc/CheckFace(atom/Obj1, atom/Obj2)
	var/CurrentDir = get_dir(Obj1, Obj2)
	//if((Obj1.loc == Obj2.loc) || (CurrentDir == Obj1.dir) || (CurrentDir == turn(Obj1.dir, 45)) || (CurrentDir == turn(Obj1.dir, -45)))
	if((CurrentDir & Obj1.dir) || (CurrentDir == 0))
		return 1
	else
		return 0

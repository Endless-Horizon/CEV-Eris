/obj/structure/catwalk
	name = "catwalk"
	desc = "Cats really don't like these things."
	icon = 'icons/turf/catwalks.dmi'
	icon_state = "catwalk"
	layer = TURF_LAYER + 0.5
	density = FALSE
	anchored = TRUE


/obj/structure/catwalk/Initialize(mapload)
	. = ..()
	if (istype(loc, /turf/simulated/open))
		var/turf/simulated/open/T = loc
		T.updateFallability()

	for(var/obj/structure/catwalk/CAT in loc)
		if(CAT == src)
			continue
		stack_trace("multiple lattices found in ([loc.x], [loc.y], [loc.z])")
		return INITIALIZE_HINT_QDEL
	// old smoothing
	update_icon()
	redraw_nearby_catwalks()

/obj/structure/catwalk/Destroy()
	if (istype(loc, /turf/simulated/open))
		var/turf/simulated/open/T = loc
		T.updateFallability(src)
	redraw_nearby_catwalks()
	. = ..()

/obj/structure/catwalk/proc/redraw_nearby_catwalks()
	for(var/direction in alldirs)
		if(locate(/obj/structure/catwalk, get_step(src, direction)))
			var/obj/structure/catwalk/L = locate(/obj/structure/catwalk, get_step(src, direction))
			L.update_icon() //so siding get updated properly


/obj/structure/catwalk/on_update_icon()
	var/connectdir = 0
	for(var/direction in cardinal)
		if(locate(/obj/structure/catwalk, get_step(src, direction)))
			connectdir |= direction

	//Check the diagonal connections for corners, where you have, for example, connections both north and east. In this case it checks for a north-east connection to determine whether to add a corner marker or not.
	var/diagonalconnect = 0 //1 = NE; 2 = SE; 4 = NW; 8 = SW
	//NORTHEAST
	if(connectdir & NORTH && connectdir & EAST)
		if(locate(/obj/structure/catwalk, get_step(src, NORTHEAST)))
			diagonalconnect |= 1
	//SOUTHEAST
	if(connectdir & SOUTH && connectdir & EAST)
		if(locate(/obj/structure/catwalk, get_step(src, SOUTHEAST)))
			diagonalconnect |= 2
	//NORTHWEST
	if(connectdir & NORTH && connectdir & WEST)
		if(locate(/obj/structure/catwalk, get_step(src, NORTHWEST)))
			diagonalconnect |= 4
	//SOUTHWEST
	if(connectdir & SOUTH && connectdir & WEST)
		if(locate(/obj/structure/catwalk, get_step(src, SOUTHWEST)))
			diagonalconnect |= 8

	icon_state = "catwalk[connectdir]-[diagonalconnect]"


/obj/structure/catwalk/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			qdel(src)
	return

/obj/structure/catwalk/attackby(obj/item/I, mob/user)
	if(QUALITY_WELDING in I.tool_qualities)
		if(I.use_tool(user, src, WORKTIME_FAST, QUALITY_WELDING, FAILCHANCE_EASY, required_stat = STAT_MEC))
			to_chat(user, "\blue Slicing lattice joints ...")
			new /obj/item/stack/rods(get_turf(user))
			new /obj/item/stack/rods(get_turf(user))
			new /obj/structure/lattice/(src.loc)
			qdel(src)
	return


/obj/structure/catwalk/can_prevent_fall()
	return FALSE

#define Z_MOVE_PHASE			/datum/vertical_travel_method/phase 	//Used by ghosts, AI eye and mobs with incorp move. Instant and goes through obstacle. It's basically an OOC action
#define Z_MOVE_JETPACK			/datum/vertical_travel_method/jetpack
#define Z_MOVE_CLIMB			/datum/vertical_travel_method/climb
#define Z_MOVE_CLIMB_MAG		/datum/vertical_travel_method/climb/mag	//Walking up a wall with magboots in zero G. Fast and safe
#define Z_MOVE_JUMP				/datum/vertical_travel_method/jump

/atom/movable
	/** Used to check wether or not an atom is being handled by SSfalling. */
	var/tmp/multiz_falling = 0

/**
 * Verb for the mob to move up a z-level if possible.
 */
/mob/verb/up()
	set name = "Move Upwards"
	set category = "IC"

	if(zMove(UP))
		to_chat(usr, SPAN_NOTICE("You move upwards."))

/**
 * Verb for the mob to move down a z-level if possible.
 */
/mob/verb/down()
	set name = "Move Downwards"
	set category = "IC"

	if(zMove(DOWN))
		to_chat(usr, SPAN_NOTICE("You move down."))

/**
 * Used to check if a mob can move up or down a Z-level and to then actually do the move.
 *
 * @param	direction The direction in which we're moving. Expects defines UP or DOWN.
 *
 * @return	TRUE if the mob has been successfully moved a Z-level.
 *			FALSE otherwise.
 */
/mob/proc/zMove(direction, var/method = 0)
	// In the case of an active eyeobj, move that instead.
	if (eyeobj)
		return eyeobj.zMove(direction)

	var/atom/movable/mover = src

	//If we're inside a thing, that thing is the thing that moves
	if (istype(loc, /obj))
		mover = loc


	var/turf/destination = (direction == UP) ? GetAbove(src) : GetBelow(src)
	var/turf/start = get_turf(src)
	if(!destination)
		to_chat(src, SPAN_NOTICE("There is nothing of interest in this direction"))
		return FALSE

	//After checking that there's a valid destination, we'll first attempt phase movement as a shortcut.
	//Since it can pass through obstacles, we'll do this before checking whether anything is blocking us
	var/datum/vertical_travel_method/VTM = new Z_MOVE_PHASE(src)
	if (VTM.attempt(direction))
		return


	var/list/possible_methods = list(
	Z_MOVE_JETPACK,
	Z_MOVE_CLIMB_MAG,
	Z_MOVE_CLIMB,
	Z_MOVE_JUMP
	)

	if(!start.CanZPass(mover, direction))
		to_chat(src, SPAN_WARNING("You can't leave this place in this direction."))
		return FALSE
	if(!destination.CanZPass(mover, (direction == UP ? DOWN : UP) ))
		to_chat(src, SPAN_WARNING("\The [destination] blocks you."))
		return FALSE

	// Check for blocking atoms at the destination.
	for (var/atom/A in destination)
		if (!A.CanPass(mover, start, 1.5, 0))
			to_chat(src, SPAN_WARNING("\The [A] blocks you."))
			return FALSE

	for (var/a in possible_methods)
		VTM = new a(src)
		if (VTM.attempt(direction))
			return TRUE

	to_chat(src, SPAN_NOTICE("You lack a means of z-travel in that direction."))
	return FALSE

/mob/living/zMove(direction)
	if (is_ventcrawling)
		var/obj/machinery/atmospherics/pipe/zpipe/P = loc
		if (istype(P) && P.can_z_crawl(src, direction))
			return P.handle_z_crawl(src, direction)

	return ..()



/**
 * An initial check for Z-level travel. Called relatively early in mob/proc/zMove.
 *
 * Useful for overwriting and special conditions for STOPPING z-level transit.
 *
 * @return	TRUE if the mob can move a Z-level of its own volition.
 *			FALSE otherwise.
 */
/mob/proc/can_ztravel(var/direction)
	return FALSE

/mob/observer/can_ztravel(var/direction)
	return TRUE

/mob/living/carbon/human/can_ztravel(var/direction)
	if(incapacitated())
		return FALSE

	if(allow_spacemove())
		return TRUE

	for(var/turf/simulated/T in RANGE_TURFS(1,src))
		if(T.density)
			if(check_shoegrip(FALSE))
				return TRUE

/mob/living/silicon/robot/can_ztravel(var/direction)
	if(incapacitated() || is_dead())
		return FALSE

	if(allow_spacemove()) //Checks for active jetpack
		return TRUE

	for(var/turf/simulated/T in RANGE_TURFS(1,src)) //Robots get "magboots"
		if(T.density)
			return TRUE

/**
 * Used to determine whether or not a given mob can override gravity when
 * attempting to Z-move UP.
 *
 * Returns FALSE in standard mob cases. Exists for carbon/human and other child overrides.
 *
 * @return	TRUE if the mob can Z-move up despite gravity.
 *			FALSE otherwise.
 */
/mob/proc/CanAvoidGravity()
	return FALSE

// Humans and borgs have jetpacks which allows them to override gravity! Or rather,
// they can have them. So we override and check.
/* Maybe next time.
/mob/living/carbon/human/CanAvoidGravity()
	if (!restrained())
		var/obj/item/tank/jetpack/thrust = get_jetpack()

		if (thrust && !lying && thrust.allow_thrust(0.01, src))
			return TRUE

	return ..()

/mob/living/silicon/robot/CanAvoidGravity()
	var/obj/item/tank/jetpack/thrust = get_jetpack()

	if (thrust && thrust.allow_thrust(0.02, src))
		return TRUE

	return ..()
*/

/**
 * An overridable proc used by SSfalling to determine whether or not an atom
 * should continue falling to the next level, or stop processing and be caught
 * in midair, effectively. One of the ways to make things never fall is to make
 * this return FALSE.
 *
 * If the mob has fallen and is stopped amidst a fall by this, fall_impact is
 * invoked with the second argument being TRUE. As opposed to the default value, FALSE.
 *
 * @param	below The turf that the mob is expected to end up at.
 * @param	dest The tile we're presuming the mob to be at for this check. Default
 * value is src.loc, (src. is important there!) but this is used for magboot lookahead
 * checks it turf/simulated/open/Enter().
 *
 * @return	TRUE if the atom can continue falling in its present situation.
 *			FALSE if it should stop falling and not invoke fall_through or fall_impact
 * this cycle.
 */
/atom/movable/proc/can_fall(turf/below, turf/simulated/open/dest = src.loc)
	if (!istype(dest) || !dest.is_hole)
		return FALSE

	// Anchored things don't fall.
	if(anchored)
		return FALSE

	if(throwing > 0)
		return FALSE

	// The var/climbers API is implemented here.
	if (LAZYLEN(dest.climbers) && (src in dest.climbers))
		return FALSE

	// True otherwise.
	return TRUE

/obj/effect/can_fall()
	return FALSE

/obj/effect/decal/cleanable/can_fall()
	return TRUE

/obj/item/pipe/can_fall(turf/below, turf/simulated/open/dest = src.loc)
	. = ..()

	if((locate(/obj/structure/disposalpipe/up) in below) || locate(/obj/machinery/atmospherics/pipe/zpipe/up) in below)
		return FALSE



/mob/living/carbon/human/can_fall(turf/below, turf/simulated/open/dest = src.loc)
	// Special condition for jetpack mounted folk!
	if (!restrained())
		if (CanAvoidGravity())
			return FALSE

	return ..()

/mob/living/carbon/human/bst/can_fall()
	return fall_override ? FALSE : ..()

/mob/eye/can_fall()
	return FALSE

/mob/living/silicon/robot/can_fall(turf/below, turf/simulated/open/dest = src.loc)
	if (CanAvoidGravity())
		return FALSE

	return ..()


// Ladders and stairs pulling movement
/obj/structure/multiz/proc/try_resolve_mob_pulling(mob/M, obj/structure/multiz/ES)
	if(istype(M) && (ES && ES.istop == istop))
		var/list/moveWithMob = list()
		if(M.pulling)
			moveWithMob += M.pulling
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			for(var/obj/item/grab/G in list(H.r_hand, H.l_hand))
				moveWithMob += G.affecting
		if(moveWithMob.len)
			var/turf/pull_target = istop ? GetBelow(ES) : GetAbove(ES)
			if(target)
				pull_target = get_turf(target)
			if(!pull_target)
				pull_target = get_turf(M)
			for(var/Elem in moveWithMob)
				var/atom/movable/A = Elem
				A.forceMove(pull_target)

/mob/observer/ghost/verb/moveup()
	set name = "Move Upwards"
	set category = "Ghost"
	zMove(UP)

/mob/observer/ghost/verb/movedown()
	set name = "Move Downwards"
	set category = "Ghost"
	zMove(DOWN)

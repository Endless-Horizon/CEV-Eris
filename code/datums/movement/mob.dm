// Movement relayed to self handling
/datum/movement_handler/mob/relayed_movement
	var/prevent_host_move = FALSE
	var/list/allowed_movers

/datum/movement_handler/mob/relayed_movement/MayMove(var/mob/mover, var/is_external)
	if(is_external)
		return MOVEMENT_PROCEED
	if(mover == mob && !(prevent_host_move && LAZYLEN(allowed_movers) && !LAZYISIN(allowed_movers, mover)))
		return MOVEMENT_PROCEED
	if(LAZYISIN(allowed_movers, mover))
		return MOVEMENT_PROCEED

	return MOVEMENT_STOP

/datum/movement_handler/mob/relayed_movement/proc/AddAllowedMover(var/mover)
	LAZYOR(allowed_movers, mover)

/datum/movement_handler/mob/relayed_movement/proc/RemoveAllowedMover(var/mover)
	LAZYREMOVE(allowed_movers, mover)

// Admin object possession
/datum/movement_handler/mob/admin_possess
	var/nextmove = 0
/datum/movement_handler/mob/admin_possess/DoMove(var/direction)
	if(QDELETED(mob.control_object))
		return MOVEMENT_REMOVE

	. = MOVEMENT_HANDLED

	var/atom/movable/control_object = mob.control_object
	step(control_object, direction)
	if(QDELETED(control_object))
		. |= MOVEMENT_REMOVE
	else
		control_object.set_dir(direction)
	nextmove = world.time + 2.5

/datum/movement_handler/mob/admin_possess/MayMove(var/mob/mover, var/is_external)
	if (world.time > nextmove)
		return MOVEMENT_PROCEED
	return MOVEMENT_STOP

// Death handling
/datum/movement_handler/mob/death/DoMove()
	if(mob.stat != DEAD)
		return
	. = MOVEMENT_HANDLED
	if(!mob.client)
		return
	mob.ghostize()

// Incorporeal/Ghost movement
/datum/movement_handler/mob/incorporeal
	var/nextmove
/datum/movement_handler/mob/incorporeal/DoMove(var/direction)
	. = MOVEMENT_HANDLED
	direction = mob.AdjustMovementDirection(direction)

	var/turf/T = get_step(mob, direction)

	if(!mob.forceMove(T))
		return

	mob.set_dir(direction)
	mob.PostIncorporealMovement()

	//Incorp movement needs a delay just to make it controllable
	var/overflow = world.time - nextmove
	if (overflow > 1)
		overflow = 0
	nextmove = (world.time + 0.5)-overflow

/datum/movement_handler/mob/incorporeal/MayMove(var/mob/mover, var/is_external)
	if (world.time > nextmove)
		return MOVEMENT_PROCEED
	return MOVEMENT_STOP

/mob/proc/PostIncorporealMovement()
	return

// Eye movement
/datum/movement_handler/mob/eye/DoMove(var/direction, var/mob/mover)
	if(IS_NOT_SELF(mover)) // We only care about direct movement
		return
	if(!mob.eyeobj)
		return
	mob.eyeobj.EyeMove(direction)
	return MOVEMENT_HANDLED

/datum/movement_handler/mob/eye/MayMove(var/mob/mover, var/is_external)
	if(IS_NOT_SELF(mover))
		return MOVEMENT_PROCEED
	if(is_external)
		return MOVEMENT_PROCEED
	if(!mob.eyeobj)
		return MOVEMENT_PROCEED
	return (MOVEMENT_PROCEED|MOVEMENT_HANDLED)

// Space movement
/datum/movement_handler/mob/space/DoMove(var/direction, var/mob/mover)
	if(!mob.check_gravity())
		var/allowmove = mob.allow_spacemove()
		if(!allowmove)
			return MOVEMENT_HANDLED
		else if(allowmove == -1 && mob.handle_spaceslipping()) //Check to see if we slipped
			return MOVEMENT_HANDLED
		else
			mob.inertia_dir = 0 //If not then we can reset inertia and move

/datum/movement_handler/mob/space/MayMove(var/mob/mover, var/is_external)
	if(IS_NOT_SELF(mover) && is_external)
		return MOVEMENT_PROCEED

	if(!mob.check_gravity())
		if(!mob.allow_spacemove())
			return MOVEMENT_STOP
	return MOVEMENT_PROCEED

// Buckle movement
/datum/movement_handler/mob/buckle_relay/DoMove(var/direction, var/mover)
	// TODO: Datumlize buckle-handling
	if(istype(mob.buckled, /obj/vehicle))
		//drunk driving
		if(mob.confused && prob(20)) //vehicles tend to keep moving in the same direction
			direction = turn(direction, pick(90, -90))
		mob.buckled.relaymove(mob, direction)
		return MOVEMENT_HANDLED

	if(mob.pulledby || mob.buckled) // Wheelchair driving!
		if(istype(mob.loc, /turf/space))
			return // No wheelchair driving in space
		if(istype(mob.pulledby, /obj/structure/bed/chair/wheelchair))
			. = MOVEMENT_HANDLED
			mob.pulledby.DoMove(direction, mob)
		else if(istype(mob.buckled, /obj/structure/bed/chair/wheelchair))
			. = MOVEMENT_HANDLED
			if(ishuman(mob))
				var/mob/living/carbon/human/driver = mob
				var/obj/item/organ/external/l_arm = driver.get_organ(BP_L_ARM)
				var/obj/item/organ/external/r_arm = driver.get_organ(BP_R_ARM)
				if((!l_arm || l_arm.is_stump()) && (!r_arm || r_arm.is_stump()))
					return // No arms to drive your chair? Tough luck!
			//drunk wheelchair driving
			direction = mob.AdjustMovementDirection(direction)
			mob.buckled.DoMove(direction, mob)

/datum/movement_handler/mob/buckle_relay/MayMove(var/mover)
	if(mob.buckled)
		return mob.buckled.MayMove(mover, FALSE) ? (MOVEMENT_PROCEED|MOVEMENT_HANDLED) : MOVEMENT_STOP
	return MOVEMENT_PROCEED

// Movement delay
/datum/movement_handler/mob/delay
	var/next_move



//Several things happen in DoMove
/datum/movement_handler/mob/delay/DoMove(var/direction, var/mover, var/is_external)
	//Not sure wtf this is
	if(is_external)
		return

	/*
	Overflow is used to prevent rounding errors, caused by the world time overshooting the next time we're allowed to move. This is inevitable
	because the server fires events 10x per second when the user is holding down a movement key, meaning that your movement is anywhere up to 0.1
	seconds later than it should have been.
	This doesn't sound like much, but it causes a lot of lost total time when moving across the whole ship.

	Here, we store the overflow time and apply it as a discount to the next step's delay. This ensures that journey times are accurate over a distance
	Any individual step can still be slightly slower than it should be, but the next one will compensate and errors won't compound
	*/
	var/overflow = next_move - world.time
	if (overflow > 1 || overflow < 0)
		overflow = 0

	var/mob_delay = max(MOVE_DELAY_MIN, mob.movement_delay())
	if(isliving(mob))
		var/mob/living/L = mob
		if(L.is_ventcrawling)
			mob_delay = MOVE_DELAY_VENTCRAWL

	var/delay = mob_delay - overflow
	SetDelay(delay)


	/*
	SMOOTH MOVEMENT
	*/
	mob.set_glide_size(DELAY2GLIDESIZE(delay), 0, INFINITY)


/datum/movement_handler/mob/delay/MayMove(var/mover, var/is_external)
	if(IS_NOT_SELF(mover) && is_external)
		return MOVEMENT_PROCEED
	.= ((mover && mover != mob) ||  world.time >= next_move) ? MOVEMENT_PROCEED : MOVEMENT_STOP



/datum/movement_handler/mob/delay/proc/SetDelay(var/delay)
	next_move = max(next_move, world.time + delay)

/datum/movement_handler/mob/delay/proc/AddDelay(var/delay)
	next_move += max(0, delay)

// Stop effect
/datum/movement_handler/mob/stop_effect/DoMove()
	if(MayMove() == MOVEMENT_STOP)
		return MOVEMENT_HANDLED

/datum/movement_handler/mob/stop_effect/MayMove()
	for(var/obj/effect/stop/S in mob.loc)
		if(S.victim == mob)
			return MOVEMENT_STOP
	return MOVEMENT_PROCEED

// Transformation
/datum/movement_handler/mob/transformation/MayMove()
	return MOVEMENT_STOP

// Consciousness - Is the entity trying to conduct the move conscious?
/datum/movement_handler/mob/conscious/MayMove(var/mob/mover)
	return (mover ? mover.stat == CONSCIOUS : mob.stat == CONSCIOUS) ? MOVEMENT_PROCEED : MOVEMENT_STOP

// Along with more physical checks
/datum/movement_handler/mob/physically_capable/MayMove(var/mob/mover)
	// We only check physical capability if the host mob tried to do the moving
	return ((mover && mover != mob) || !mob.incapacitated(INCAPACITATION_DISABLED & ~INCAPACITATION_FORCELYING)) ? MOVEMENT_PROCEED : MOVEMENT_STOP

// Is anything physically preventing movement?
/datum/movement_handler/mob/physically_restrained/MayMove(var/mob/mover)
	if(mob.anchored)
		if(mover == mob)
//			to_chat(mob, "<span class='notice'>You're anchored down!</span>")
			if(isliving(mob))
				mob:resist()
		return MOVEMENT_STOP

	if(istype(mob.buckled) && !mob.buckled.buckle_movable)
		if(mover == mob)
//			to_chat(mob, "<span class='notice'>You're buckled to \the [mob.buckled]!</span>")
			if(isliving(mob))
				mob:resist()
		return MOVEMENT_STOP

	if(LAZYLEN(mob.pinned))
		if(mover == mob)
			to_chat(mob, "<span class='notice'>You're pinned down by \a [mob.pinned[1]]!</span>")
		return MOVEMENT_STOP

	for(var/obj/item/grab/G in mob.grabbed_by)
		return MOVEMENT_STOP
		/* TODO: Bay grab system
		if(G.stop_move())
			if(mover == mob)
				to_chat(mob, "<span class='notice'>You're stuck in a grab!</span>")
			mob.ProcessGrabs()
			return MOVEMENT_STOP
		*/
	if(mob.restrained())
		for(var/mob/M in range(mob, 1))
			if(M.pulling == mob)
				if(!M.incapacitated() && mob.Adjacent(M))
					if(mover == mob)
						to_chat(mob, "<span class='notice'>You're restrained! You can't move!</span>")
					return MOVEMENT_STOP
				else
					M.stop_pulling()

	return MOVEMENT_PROCEED


/mob/living/ProcessGrabs()
	//if we are being grabbed
	if(grabbed_by.len)
		resist() //shortcut for resisting grabs

/mob/proc/ProcessGrabs()
	return


// Finally.. the last of the mob movement junk
/datum/movement_handler/mob/movement/DoMove(var/direction, var/mob/mover)
	. = MOVEMENT_HANDLED
	if(mob.moving)
		return

	if(!mob.lastarea)
		mob.lastarea = get_area(mob.loc)

	//We are now going to move
	mob.moving = 1

	direction = mob.AdjustMovementDirection(direction)
	var/old_turf = get_turf(mob)
	step(mob, direction)

	// Something with pulling things
	var/extra_delay = HandleGrabs(direction, old_turf)
	mob.add_move_cooldown(extra_delay)

	/* TODO: Bay grab system
	for (var/obj/item/grab/G in mob)
		if (G.assailant_reverse_facing())
			mob.set_dir(GLOB.reverse_dir[direction])
		G.assailant_moved()
	for (var/obj/item/grab/G in mob.grabbed_by)
		G.adjust_position()
	*/
	mob.moving = 0

/datum/movement_handler/mob/movement/MayMove(var/mob/mover)
	return IS_SELF(mover) &&  mob.moving ? MOVEMENT_STOP : MOVEMENT_PROCEED

/datum/movement_handler/mob/movement/proc/HandleGrabs(var/direction, var/old_turf)
	. = 0
	// TODO: Look into making grabs use movement events instead, this is a mess.
	for (var/obj/item/grab/G in mob)
		. = max(., G.slowdown)
		var/mob/M = G.affecting
		if(M && get_dist(old_turf, M) <= 1)
			if (isturf(M.loc) && isturf(mob.loc) && mob.loc != old_turf && M.loc != mob.loc)
				step(M, get_dir(M.loc, old_turf))
		G.adjust_position()

/mob/proc/AdjustMovementDirection(var/direction)
	. = direction
	if(!confused)
		return

	var/stability = ((MOVING_DELIBERATELY(src)) ? 75 : 25)
	if(prob(stability))
		return

	return prob(50) ? GLOB.cw_dir[.] : GLOB.ccw_dir[.]

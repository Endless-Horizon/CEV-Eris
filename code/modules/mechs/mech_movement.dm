/mob/living/exosuit
	movement_handlers = list(
		/datum/movement_handler/mob/space/exosuit,
		/datum/movement_handler/mob/exosuit
	)

/mob/living/exosuit/Move()
	. = ..()
	if(. && !istype(loc, /turf/space))
		playsound(src.loc, mech_step_sound, 40, 1)

/mob/living/exosuit/update_plane()
	. = ..()
	for(var/mob/M in pilots)
		M.update_plane()

//Override this and space move once a way to travel vertically is in
///mob/living/exosuit/can_ztravel()
//	if(allow_spacemove()) //Handle here
	// 	return 1

	// for(var/turf/simulated/T in RANGE_TURFS(1,src))
	// 	if(T.density)
	// 		return 1



/*/mob/living/exosuit/can_fall()
	//mechs are always anchored, so falling should always ignore it
	if(..(TRUE, location_override))
		return !(CanAvoidGravity())*/


/datum/movement_handler/mob/exosuit
	expected_host_type = /mob/living/exosuit
	var/next_move

/datum/movement_handler/mob/exosuit/MayMove(var/mob/mover, var/is_external)
	var/mob/living/exosuit/exosuit = host
	if(world.time < next_move)
		return MOVEMENT_STOP
	if((!(mover in exosuit.pilots) && mover != exosuit) || exosuit.incapacitated() || mover.incapacitated())
		return MOVEMENT_STOP
	if(!exosuit.legs)
		to_chat(mover, SPAN_WARNING("\The [exosuit] has no means of propulsion!"))
		next_move = world.time + 3 // Just to stop them from getting spammed with messages.
		return MOVEMENT_STOP
	if(!exosuit.legs.motivator || !exosuit.legs.motivator.is_functional())
		to_chat(mover, SPAN_WARNING("Your motivators are damaged! You can't move!"))
		next_move = world.time + 15
		return MOVEMENT_STOP
	if(exosuit.maintenance_protocols)
		to_chat(mover, SPAN_WARNING("Maintenance protocols are in effect."))
		next_move = world.time + 3 // Just to stop them from getting spammed with messages.
		return MOVEMENT_STOP
	var/obj/item/cell/C = exosuit.get_cell()
	if(!C || !C.check_charge(exosuit.legs.power_use * CELLRATE))
		to_chat(mover, SPAN_WARNING("The power indicator flashes briefly."))
		next_move = world.time + 3 //On fast exosuits this got annoying fast
		return MOVEMENT_STOP

	next_move = world.time + (exosuit.legs ? exosuit.legs.move_delay : 3)
	return MOVEMENT_PROCEED

/datum/movement_handler/mob/exosuit/DoMove(var/direction, var/mob/mover, var/is_external)
	var/mob/living/exosuit/exosuit = host
	var/moving_dir = direction

	var/failed = FALSE
	if(exosuit.emp_damage >= EMP_MOVE_DISRUPT && prob(30))
		failed = TRUE
	if(failed)
		moving_dir = pick(GLOB.cardinal - exosuit.dir)

	var/obj/item/cell/C = exosuit.get_cell()
	C.use(exosuit.legs.power_use * CELLRATE)
	if(exosuit.dir != moving_dir && !exosuit.strafing)
		playsound(exosuit.loc, exosuit.mech_turn_sound, 40,1)
		exosuit.set_dir(moving_dir)
		next_move = world.time + exosuit.legs.turn_delay
	else
		var/turf/target_loc = get_step(exosuit, direction)
		if(target_loc && exosuit.legs && exosuit.legs.can_move_on(exosuit.loc, target_loc))
			exosuit.Move(target_loc)
	return MOVEMENT_HANDLED


/datum/movement_handler/mob/space/exosuit/expected_host_type = /mob/living/exosuit

// Space movement
/datum/movement_handler/mob/space/exosuit/DoMove(var/direction, var/mob/mover)

	if(!mob.check_solid_ground())
		mob.anchored = FALSE
		var/allowmove = mob.allow_spacemove(0)
		if(!allowmove)
			return MOVEMENT_HANDLED
		else if(allowmove == -1 && mob.handle_spaceslipping()) //Check to see if we slipped
			return MOVEMENT_HANDLED
		else
			mob.inertia_dir = 0 //If not then we can reset inertia and move
	else mob.anchored = TRUE

/datum/movement_handler/mob/space/exosuit/MayMove(var/mob/mover, var/is_external)
	if((mover != host) && is_external)
		return MOVEMENT_PROCEED

	if(!mob.check_solid_ground())
		if(!mob.allow_spacemove(0))
			return MOVEMENT_STOP
	return MOVEMENT_PROCEED

/mob/living/exosuit/lost_in_space()
	for(var/atom/movable/AM in contents)
		if(!AM.lost_in_space())
			return FALSE
	return !pilots.len

/mob/living/exosuit/get_fall_damage(var/turf/from, var/turf/dest)
	return (from.z - dest.z > 1) ? (50 * from.z - dest.z) : 0 //Exosuits are big and heavy //but one z level can't damage them

/*
/mob/living/exosuit/handle_fall_effect(var/turf/landing)
	// Return here if for any reason you shouldn´t take damage
	..()
	var/damage = 30 //Enough to cause a malfunction if unlucky
	apply_damage(rand(0, damage), BRUTE, BP_R_LEG) //Any leg is good, will damage both
*/

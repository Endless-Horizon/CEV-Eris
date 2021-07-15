/*
	This file handles vertical travel using a worn jetpack. Including tons of fancy animation,
	sound and visual fx
*/
/datum/vertical_travel_method/jetpack
	var/obj/item/tank/jetpack/thrust
	var/burst_interval = 3
	var/next_burst = 0
	start_verb_visible = "%m starts a controlled %d3t with the %s"
	start_verb_personal = "You start a controlled %d3t with the %s"
	base_time = 70
	slip_chance = 0 //Its a jetpack, how would you even screw this up!


/datum/vertical_travel_method/jetpack/start_animation()
	.=..()
	if (direction == DOWN)
		M.pixel_y += 8
		var/matrix/mat = matrix()
		mat.Scale(0.9)
		M.set_plane(FLOOR_PLANE)
		M.layer = 1
		animate(M, alpha = 50, pixel_y = -16, transform = mat,  time = duration*1.2, easing = SINE_EASING, flags = ANIMATION_END_NOW)
	else
		animate(M, alpha = 0, pixel_y = 64, time = duration*1.2, easing = SINE_EASING, flags = ANIMATION_END_NOW)


/datum/vertical_travel_method/jetpack/cache_values()
	.=..()
	thrust = M.get_jetpack()
	subject = thrust
	if (!gravity)
		burst_interval *= 1.5 //We need thrusts less often in 0G


/datum/vertical_travel_method/jetpack/calculate_time()
	if (isrobot(M))
		base_time *= 2 //Robots are heavy and slow, but they can use jetpacks
	else if (istype(M, /mob/living/exosuit))
		base_time *= 2.5 //Heavier still
	.=..()

/datum/vertical_travel_method/jetpack/can_perform(var/mob/living/L, var/dir)
	.=..()
	if (.)
		if (!istype(thrust))
			return FALSE	//If you don't have a jetpack, we wont show any messages related to it


		if (!thrust.on)
			to_chat(M, SPAN_NOTICE("You could go [dir2text(direction)]ward with your [thrust.name], if it were turned on!"))
			return FALSE


		//If the jetpack is empty then we fail. But only if its empty
		if (!thrust.check_thrust(JETPACK_MOVE_COST, M))
			to_chat(M, SPAN_NOTICE("Your [thrust.name] doesn't have enough left in it to get you anywhere!"))
			return FALSE

		//If the user has some gas, but not enough to make the journey, we'll let them try anyway.
		//Running out halfway through and falling will be funny


//Jetpacks do a periodic visual effect while ztravelling
//This is also where they consume fuel
/datum/vertical_travel_method/jetpack/tick()
	.=..()
	if (world.time >= next_burst)

		//Multiplying the cost by the burst interval allows this cost to be independant of the interval
		if (thrust.allow_thrust(thrust.thrust_cost*burst_interval * 0.3, M, TRUE))
			var/obj/effect/effect/E = thrust.trail.do_effect(origin, SOUTH)
			//Since the user will have their pixel offset animated by the transition, we must compensate the visuals
			//We will calculate a pixel offset for the thrust particle based on the progress
			var/max = 64
			if (direction == DOWN)
				max = -16

			var/progress = progress()
			E.pixel_y = (max * progress) - 12 //-12 makes it offset down from the player a bit
			E.pixel_x = RAND_DECIMAL(-4,4) //Slight side to side randomness so it looks chaotic
			E.alpha = (255 - (255 * progress))*2 //Fade out as the player does, but less so
			E.layer = M.layer-0.01 //Match the player's layer so it doesn't render over foreground turfs when moving downwards

			next_burst = world.time + burst_interval
		else
			//If the jetpack doesn't have enough thrust to continue, we will fail and fall down
			abort()
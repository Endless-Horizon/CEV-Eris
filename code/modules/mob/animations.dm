/*
adds a dizziness amount to a mob
use this rather than directly changing var/dizziness
since this ensures that the dizzy_process proc is started
currently only humans get dizzy

value of dizziness ranges from 0 to 1000
below 100 is not dizzy
*/

/mob/proc/make_dizzy(var/amount)
	return

// for the moment, only humans get dizzy
/mob/living/carbon/human/make_dizzy(var/amount)
	dizziness = min(1000, dizziness + amount)	// store what will be new value
													// clamped to max 1000
	if(dizziness > 100 && !is_dizzy)
		spawn(0)
			dizzy_process()


/mob/living/carbon
	var/dizziness = 0
	var/is_dizzy = 0

/*
dizzy process - wiggles the client's pixel offset over time
spawned from make_dizzy(), will terminate automatically when dizziness gets <100
note dizziness decrements automatically in the mob's Life() proc.
*/
/mob/living/carbon/human/proc/dizzy_process()
	is_dizzy = 1
	while(dizziness > 100)
		if(client)
			var/amplitude = dizziness*(sin(dizziness * 0.044 * world.time) + 1) / 70
			client.pixel_x = amplitude * sin(0.008 * dizziness * world.time)
			client.pixel_y = amplitude * cos(0.008 * dizziness * world.time)

		sleep(1)
	//endwhile - reset the pixel offsets to zero
	is_dizzy = 0
	if(client)
		client.pixel_x = 0
		client.pixel_y = 0

// jitteriness - copy+paste of dizziness
/mob/proc/make_jittery(var/amount)
	return

/mob/living/carbon
	var/is_jittery = 0
	var/jitteriness = 0

/mob/living/carbon/human/make_jittery(var/amount)
	jitteriness = min(1000, jitteriness + amount)	// store what will be new value
													// clamped to max 1000
	if(jitteriness > 100 && !is_jittery)
		spawn(0)
			jittery_process()


// Typo from the oriignal coder here, below lies the jitteriness process. So make of his code what you will, the previous comment here was just a copypaste of the above.
/mob/living/carbon/human/proc/jittery_process()
	is_jittery = 1
	while(jitteriness > 100)
		var/amplitude = min(4, jitteriness / 100)
		pixel_x = default_pixel_x + rand(-amplitude, amplitude)
		pixel_y = default_pixel_y + rand(-amplitude/3, amplitude/3)

		sleep(1)
	//endwhile - reset the pixel offsets to zero
	is_jittery = 0
	pixel_x = default_pixel_x
	pixel_y = default_pixel_y


//handles up-down floaty effect in space and zero-gravity
/mob/var/is_floating = 0
/mob/var/floatiness = 0

//You can pass in true or false in a case where you've already done the calculations and can skip some checking here
//Its perfectly fine to call this proc with no input, it will figure out what it needs to do
/mob/proc/update_floating(var/setstate = null)
	if (!isnull(setstate))
		make_floating(setstate)
		return

	if(anchored || buckled || check_gravity())
		make_floating(0)
		return

	if(check_shoegrip() && check_solid_ground())
		make_floating(0)
		return

	make_floating(1)
	return

/mob/proc/make_floating(var/n)
	floatiness = n

	if(floatiness && !is_floating)
		start_floating()
	else if(!floatiness && is_floating)
		stop_floating()

/mob/proc/start_floating()

	is_floating = 1

	var/amplitude = 2 //maximum displacement from original position
	var/period = 36 //time taken for the mob to go up >> down >> original position, in deciseconds. Should be multiple of 4

	var/top = default_pixel_y + amplitude
	var/bottom = default_pixel_y - amplitude
	var/half_period = period / 2
	var/quarter_period = period / 4

	animate(src, pixel_y = top, time = quarter_period, easing = SINE_EASING | EASE_OUT, loop = -1)		//up
	animate(pixel_y = bottom, time = half_period, easing = SINE_EASING, loop = -1)						//down
	animate(pixel_y = default_pixel_y, time = quarter_period, easing = SINE_EASING | EASE_IN, loop = -1)			//back

/mob/proc/stop_floating()
	animate(src, pixel_y = default_pixel_y, time = 5, easing = SINE_EASING | EASE_IN) //halt animation
	//reset the pixel offsets to zero
	is_floating = 0

/atom/movable/proc/do_attack_animation(atom/A, var/use_item = TRUE, var/depth = 8)
	var/prev_x = pixel_x
	var/prev_y = pixel_y
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0
	var/direction = get_dir(src, A)
	switch(direction)
		if(NORTH)
			pixel_y_diff = depth
		if(SOUTH)
			pixel_y_diff = -depth
		if(EAST)
			pixel_x_diff = depth
		if(WEST)
			pixel_x_diff = -depth
		if(NORTHEAST)
			pixel_x_diff = depth
			pixel_y_diff = depth
		if(NORTHWEST)
			pixel_x_diff = -depth
			pixel_y_diff = depth
		if(SOUTHEAST)
			pixel_x_diff = depth
			pixel_y_diff = -depth
		if(SOUTHWEST)
			pixel_x_diff = -depth
			pixel_y_diff = -depth
	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 2)
	animate(pixel_x = prev_x, pixel_y = prev_y, time = 2)

/mob/do_attack_animation(atom/A, var/use_item = TRUE)
	..()
	is_floating = 0 // If we were without gravity, the bouncing animation got stopped, so we make sure we restart the bouncing after the next movement.

	if (!use_item)
		//The use item flag governs whether or not we'll add a little weapon image to the animation
		return

	// What icon do we use for the attack?
	var/image/I
	var/obj/item/T = get_active_hand()
	if (T && T.icon)
		I = image(T.icon, A, T.icon_state, A.layer + 1)
	else // Attacked with a fist?
		return

	// Who can see the attack?
	var/list/viewing = list()
	for (var/mob/M in viewers(A))
		if (M.client)
			viewing |= M.client
	flick_overlay(I, viewing, 5) // 5 ticks/half a second

	// Scale the icon.
	I.transform *= 0.75
	// Set the direction of the icon animation.
	var/direction = get_dir(src, A)
	if(direction & NORTH)
		I.pixel_y = -16
	else if(direction & SOUTH)
		I.pixel_y = 16

	if(direction & EAST)
		I.pixel_x = -16
	else if(direction & WEST)
		I.pixel_x = 16

	if(!direction) // Attacked self?!
		I.pixel_z = 16

	// And animate the attack!
	animate(I, alpha = 175, pixel_x = 0, pixel_y = 0, pixel_z = 0, time = 3)




/atom/proc/SpinAnimation(speed = 10, loops = -1)
	var/matrix/m120 = matrix(transform)
	m120.Turn(120)
	var/matrix/m240 = matrix(transform)
	m240.Turn(240)
	var/matrix/m360 = matrix(transform)
	speed /= 3      //Gives us 3 equal time segments for our three turns.
	                //Why not one turn? Because byond will see that the start and finish are the same place and do nothing
	                //Why not two turns? Because byond will do a flip instead of a turn
	animate(src, transform = m120, time = speed, loops)
	animate(transform = m240, time = speed)
	animate(transform = m360, time = speed)



//Shakes the mob's camera
//Strength is not recommended to set higher than 4, and even then its a bit wierd
/proc/shake_camera(mob/M, duration, strength = 1, var/taper = 0.25)
	if(!M || !M.client || M.shakecamera || M.stat || isEye(M) || isAI(M))
		return

	M.shakecamera = 1
	spawn(2)
		if(!M.client)
			return

		var/atom/oldeye=M.client.eye
		var/aiEyeFlag = 0
		if(istype(oldeye, /mob/observer/eye/aiEye))
			aiEyeFlag = 1

		var/x
		for(x=0; x<duration, x++)
			if(aiEyeFlag)
				M.client.eye = locate(dd_range(1,oldeye.loc.x+rand(-strength,strength),world.maxx),dd_range(1,oldeye.loc.y+rand(-strength,strength),world.maxy),oldeye.loc.z)
			else
				M.client.eye = locate(dd_range(1,M.loc.x+rand(-strength,strength),world.maxx),dd_range(1,M.loc.y+rand(-strength,strength),world.maxy),M.loc.z)
			sleep(1)

		//Taper code added by nanako.
		//Will make the strength falloff after the duration.
		//This helps to reduce jarring effects of major screenshaking suddenly returning to stability
		//Recommended taper values are 0.05-0.1
		if (taper > 0)
			while (strength > 0)
				strength -= taper
				if(aiEyeFlag)
					M.client.eye = locate(dd_range(1,oldeye.loc.x+rand(-strength,strength),world.maxx),dd_range(1,oldeye.loc.y+rand(-strength,strength),world.maxy),oldeye.loc.z)
				else
					M.client.eye = locate(dd_range(1,M.loc.x+rand(-strength,strength),world.maxx),dd_range(1,M.loc.y+rand(-strength,strength),world.maxy),M.loc.z)
				sleep(1)

		M.client.eye=oldeye
		M.shakecamera = 0


//Deprecated, use SpinAnimation when possible
/mob/proc/spin(spintime, speed)
	spawn()
		var/D = dir
		while(spintime >= speed)
			sleep(speed)
			switch(D)
				if(NORTH)
					D = EAST
				if(SOUTH)
					D = WEST
				if(EAST)
					D = SOUTH
				if(WEST)
					D = NORTH
			set_dir(D)
			spintime -= speed
	return

/atom/movable/proc/do_pickup_animation(atom/target, atom/old_loc)
	set waitfor = FALSE
	if (QDELETED(src))
		return
	if (QDELETED(target))
		return
	if (QDELETED(old_loc))
		return

	var/turf/old_turf = get_turf(old_loc)
	var/image/I = image(icon = src, loc = old_turf)
	I.plane = plane
	I.layer = ABOVE_MOB_LAYER
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	if (ismob(target))
		I.dir = target.dir

	if (istype(old_loc,/obj/item/storage))
		I.pixel_x += old_loc.pixel_x
		I.pixel_y += old_loc.pixel_y

	flick_overlay(I, clients, 7)

	var/matrix/M = new
	M.Turn(pick(30, -30))

	animate(I, transform = M, time = 1)
	sleep(1)
	animate(I, transform = matrix(), time = 1)
	sleep(1)

	var/to_x = (target.x - old_turf.x) * 32
	var/to_y = (target.y - old_turf.y) * 32

	animate(I, pixel_x = to_x, pixel_y = to_y, time = 3, transform = matrix() * 0, easing = CUBIC_EASING)
	sleep(3)

/atom/movable/proc/do_putdown_animation(atom/target, mob/user)
	spawn()
		if (QDELETED(src))
			return
		if (QDELETED(target))
			return
		if (QDELETED(user))
			return
		var/old_invisibility = invisibility // I don't know, it may be used.
		invisibility = 100
		var/turf/old_turf = get_turf(user)
		if (QDELETED(old_turf))
			return
		var/image/I = image(icon = src, loc = old_turf, layer = layer + 0.1)
		I.plane = get_relative_plane(GAME_PLANE)
		I.layer = ABOVE_MOB_LAYER
		I.transform = matrix() * 0
		I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
		I.pixel_x = 0
		I.pixel_y = 0
		if (ismob(target))
			I.dir = target.dir
		flick_overlay(I, clients, 4)

		var/to_x = (target.x - old_turf.x) * 32 + pixel_x
		var/to_y = (target.y - old_turf.y) * 32 + pixel_y
		var/old_x = pixel_x
		var/old_y = pixel_y
		pixel_x = 0
		pixel_y = 0

		animate(I, pixel_x = to_x, pixel_y = to_y, time = 3, transform = matrix(), easing = CUBIC_EASING)
		sleep(3)
		if (QDELETED(src))
			return
		invisibility = old_invisibility
		pixel_x = old_x
		pixel_y = old_y

/atom/movable/proc/simple_move_animation(atom/target)
	set waitfor = FALSE

	var/old_invisibility = invisibility // I don't know, it may be used.
	invisibility = 100
	var/turf/old_turf = get_turf(src)
	var/image/I = image(icon = src, loc = src.loc, layer = layer + 0.1)
	I.plane = get_relative_plane(GAME_PLANE)
	I.layer = ABOVE_MOB_LAYER
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	flick_overlay(I, clients, 4)

	var/to_x = (target.x - old_turf.x) * 32 + pixel_x
	var/to_y = (target.y - old_turf.y) * 32 + pixel_y

	animate(I, pixel_x = to_x, pixel_y = to_y, time = 3, easing = CUBIC_EASING)
	sleep(3)
	if (QDELETED(src))
		return
	invisibility = old_invisibility

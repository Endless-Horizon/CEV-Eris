//Dummy object for holding items in vehicles.
//Prevents items from being interacted with.
/datum/vehicle_dummy_load
	var/name = "dummy load"
	var/actual_load

/obj/vehicle
	name = "vehicle"
	icon = 'icons/obj/vehicles.dmi'
	layer = MOB_LAYER + 0.1 //so it sits above objects including mobs
	density = TRUE
	anchored = TRUE
	animate_movement=1
	light_range = 3

	can_buckle = TRUE
	buckle_movable = 1
	buckle_lying = 0

	var/attack_log = null
	var/on = FALSE
	var/health = 0	//do not forget to set health for your vehicle!
	var/maxhealth = 0
	var/fire_dam_coeff = 1
	var/brute_dam_coeff = 1
	var/open = 0	//Maint panel
	var/locked = 1
	var/stat = 0
	var/emagged = 0
	var/powered = 0		//set if vehicle is powered and should use fuel when moving
	var/move_delay = 1	//set this to limit the speed of the vehicle

	var/passenger_allowed = 1

	var/obj/item/cell/large/cell
	var/charge_use = 5	//set this to adjust the amount of power the vehicle uses per move

	var/atom/movable/load		//all vehicles can take a load, since they should all be a least drivable
	var/load_item_visible = 1	//set if the loaded item should be overlayed on the vehicle sprite
	var/load_offset_x = 0		//pixel_x offset for item overlay
	var/load_offset_y = 0		//pixel_y offset for item overlay
	var/mob_offset_y = 0		//pixel_y offset for mob overlay

//-------------------------------------------
// Standard procs
//-------------------------------------------
/obj/vehicle/New()
	..()
	//spawn the cell you want in each vehicle

/obj/vehicle/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, var/glide_size_override = 0)
	if(world.time > l_move_time + move_delay)
		var/old_loc = get_turf(src)
		if(on && powered && cell.charge < charge_use)
			turn_off()

		var/init_anc = anchored
		anchored = FALSE
		if(!(. = ..()))
			anchored = init_anc
			return

		set_dir(get_dir(old_loc, loc))
		anchored = init_anc

		if(on && powered)
			cell.use(charge_use)

		//Dummy loads do not have to be moved as they are just an overlay
		//See load_object() proc in cargo_trains.dm for an example
		if(load && !istype(load, /datum/vehicle_dummy_load))
			load.forceMove(loc, glide_size_override=DELAY2GLIDESIZE(move_delay))
			load.set_dir(dir)

		return 1
	else
		return 0

/obj/vehicle/attackby(obj/item/I, mob/user)

	var/list/usable_qualities = list(QUALITY_PRYING, QUALITY_SCREW_DRIVING)
	if(open)
		usable_qualities.Add(QUALITY_WIRE_CUTTING)
	if(open && health < maxhealth)
		usable_qualities.Add(QUALITY_WELDING)


	var/tool_type = I.get_tool_type(user, usable_qualities, src)
	switch(tool_type)

		if(QUALITY_PRYING)
			if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_EASY,  required_stat = STAT_MEC))
				remove_cell(user)
			return

		if(QUALITY_SCREW_DRIVING)
			var/used_sound = open ? 'sound/machines/Custom_screwdriveropen.ogg' :  'sound/machines/Custom_screwdriverclose.ogg'
			if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_EASY,  required_stat = STAT_MEC, instant_finish_tier = 30, forced_sound = used_sound))
				if(!locked)
					open = !open
					update_icon()
					to_chat(user, SPAN_NOTICE("You [open ? "open" : "close"] the maintenance hatch of \the [src] with [I]."))
				else
					to_chat(user, SPAN_NOTICE("You fail to unsrew the cover, looks like its locked from the inside."))
				return

		if(QUALITY_WIRE_CUTTING)
			if(open)
				if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_EASY,  required_stat = STAT_MEC))
					passenger_allowed = !passenger_allowed
					user.visible_message(
						SPAN_NOTICE("[user] [passenger_allowed ? "cuts" : "mends"] a cable in [src]."),
						SPAN_NOTICE("You [passenger_allowed ? "cut" : "mend"] the load limiter cable.")
					)
			return

		if(QUALITY_WELDING)
			if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_EASY,  required_stat = STAT_MEC))
				health = min(maxhealth, health+10)
				user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
				user.visible_message("\red [user] repairs [src]!","\blue You repair [src]!")
			return

		if(ABORT_CHECK)
			return

	if(istype(I, /obj/item/hand_labeler))
		return
	else if(istype(I, /obj/item/cell/large) && !cell && open)
		insert_cell(I, user)
	else if(hasvar(I,"force") && hasvar(I,"damtype"))
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		switch(I.damtype)
			if("fire")
				health -= I.force * fire_dam_coeff
			if("brute")
				health -= I.force * brute_dam_coeff
		..()
		healthcheck()
	else
		..()

/obj/vehicle/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.get_structure_damage()
	..()
	healthcheck()

/obj/vehicle/ex_act(severity)
	switch(severity)
		if(1)
			explode()
			return
		if(2)
			health -= rand(5,10)*fire_dam_coeff
			health -= rand(10,20)*brute_dam_coeff
			healthcheck()
			return
		if(3)
			if (prob(50))
				health -= rand(1,5)*fire_dam_coeff
				health -= rand(1,5)*brute_dam_coeff
				healthcheck()
				return
	return

/obj/vehicle/emp_act(severity)
	var/was_on = on
	stat |= EMPED

	new /obj/effect/overlay/pulse(loc)

	if(on)
		turn_off()
	spawn(severity*300)
		stat &= ~EMPED
		if(was_on)
			turn_on()

/obj/vehicle/attack_ai(mob/user as mob)
	return

// For downstream compatibility (in particular Paradise)
/obj/vehicle/proc/handle_rotation()
	return

//-------------------------------------------
// Vehicle procs
//-------------------------------------------
/obj/vehicle/proc/turn_on()
	if(stat)
		return 0
	if(powered && cell.charge < charge_use)
		return 0
	on = TRUE
	set_light(initial(light_range))
	update_icon()
	return 1

/obj/vehicle/proc/turn_off()
	on = FALSE
	set_light(0)
	update_icon()

/obj/vehicle/emag_act(var/remaining_charges, mob/user as mob)
	if(!emagged)
		emagged = 1
		if(locked)
			locked = 0
			to_chat(user, SPAN_WARNING("You bypass [src]'s controls."))
		return 1

/obj/vehicle/proc/explode()
	src.visible_message(SPAN_DANGER("\The [src] blows apart!"))
	var/turf/Tsec = get_turf(src)

	for (var/i in 1 to 2)
		new /obj/item/stack/rods(Tsec)

	new /obj/item/stack/cable_coil/cut(Tsec)

	if(cell)
		cell.forceMove(Tsec)
		cell.update_icon()
		cell = null

	//stuns people who are thrown off a train that has been blown up
	if(isliving(load))
		var/mob/living/M = load
		M.apply_effects(5, 5)

	unload()

	new /obj/effect/gibspawner/robot(Tsec)
	new /obj/effect/decal/cleanable/blood/oil(src.loc)

	qdel(src)

/obj/vehicle/proc/healthcheck()
	if(health <= 0)
		explode()

/obj/vehicle/proc/powercheck()
	if(!cell && !powered)
		return

	if(!cell && powered)
		turn_off()
		return

	if(cell.charge < charge_use)
		turn_off()
		return

	if(cell && powered)
		turn_on()
		return

/obj/vehicle/proc/insert_cell(var/obj/item/cell/large/C, var/mob/living/carbon/human/H)
	if(cell)
		return
	if(!istype(C))
		return

	H.drop_from_inventory(C)
	C.forceMove(src)
	src.cell = C
	powercheck()
	to_chat(usr, SPAN_NOTICE("You install [C] in [src]."))

/obj/vehicle/proc/remove_cell(var/mob/living/carbon/human/H)
	if(!cell)
		return

	to_chat(usr, SPAN_NOTICE("You remove [cell] from [src]."))
	cell.forceMove(get_turf(H))
	H.put_in_hands(cell)
	cell = null
	powercheck()

/obj/vehicle/proc/RunOver(var/mob/living/carbon/human/H)
	return		//write specifics for different vehicles

//-------------------------------------------
// Loading/unloading procs
//
// Set specific item restriction checks in
// the vehicle load() definition before
// calling this parent proc.
//-------------------------------------------
/obj/vehicle/proc/load(var/atom/movable/C)
	//This loads objects onto the vehicle so they can still be interacted with.
	//Define allowed items for loading in specific vehicle definitions.
	if(!isturf(C.loc)) //To prevent loading things from someone's inventory, which wouldn't get handled properly.
		return 0
	if(load || C.anchored)
		return 0

	// if a create/closet, close before loading
	var/obj/structure/closet/crate = C
	if(istype(crate))
		crate.close()

	C.forceMove(loc)
	C.set_dir(dir)
	C.anchored = TRUE

	load = C

	if(load_item_visible)
		C.pixel_x += load_offset_x
		if(ismob(C))
			C.pixel_y += mob_offset_y
		else
			C.pixel_y += load_offset_y
		C.layer = layer + 0.1		//so it sits above the vehicle

	if(ismob(C))
		buckle_mob(C)

	return 1


/obj/vehicle/proc/unload(var/mob/user, var/direction)
	if(!load)
		return

	var/turf/dest = null

	//find a turf to unload to
	if(direction)	//if direction specified, unload in that direction
		dest = get_step(src, direction)
	else if(user)	//if a user has unloaded the vehicle, unload at their feet
		dest = get_turf(user)

	if(!dest)
		dest = get_step_to(src, get_step(src, turn(dir, 90))) //try unloading to the side of the vehicle first if neither of the above are present

	//if these all result in the same turf as the vehicle or nullspace, pick a new turf with open space
	if(!dest || dest == get_turf(src))
		var/list/options = new()
		for(var/test_dir in alldirs)
			var/new_dir = get_step_to(src, get_step(src, test_dir))
			if(new_dir && load.Adjacent(new_dir))
				options += new_dir
		if(options.len)
			dest = pick(options)
		else
			dest = get_turf(src)	//otherwise just dump it on the same turf as the vehicle

	if(!isturf(dest))	//if there still is nowhere to unload, cancel out since the vehicle is probably in nullspace
		return 0

	load.forceMove(dest)
	load.set_dir(get_dir(loc, dest))
	load.anchored = FALSE		//we can only load non-anchored items, so it makes sense to set this to false
	load.pixel_x = initial(load.pixel_x)
	load.pixel_y = initial(load.pixel_y)
	load.layer = initial(load.layer)

	if(ismob(load))
		unbuckle_mob(load)

	load = null

	return 1


//-------------------------------------------------------
// Stat update procs
//-------------------------------------------------------
/obj/vehicle/proc/update_stats()
	return

/obj/vehicle/attack_generic(var/mob/user, var/damage, var/attack_message)
	if(!damage)
		return
	visible_message(SPAN_DANGER("\The [user] [attack_message] the \the [src]!"))
	if(istype(user))
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked \the [src.name]</font>")
		user.do_attack_animation(src)
	src.health -= damage
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(src.loc)
	spawn(1) healthcheck()
	return 1

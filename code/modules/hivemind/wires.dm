//Wireweeds are created by the AI's nanites to spread its connectivity through the ship.
//When they reach any machine, they annihilate them and re-purpose them to the AI's needs. They are the 'hands' of our rogue AI.
//The three acids and chlorine, a strong oxidizer of metals, are killer reagents

/obj/effect/plant/hivemind
	layer = 2
	health = 		80
	max_health = 	80 		//we are a little bit durable
	spread_chance = 85
	var/list/killer_reagents = list("pacid", "sacid", "hclacid", "chlorine")
	//internals
	var/obj/machinery/hivemind_machine/node/master_node
	var/list/wires_connections = list("0", "0", "0", "0")


/obj/effect/plant/hivemind/New()
	..()
	icon = 'icons/obj/hivemind.dmi'
	spawn(2)
		update_neighbors()


/obj/effect/plant/hivemind/Destroy()
	if(master_node)
		master_node.my_wireweeds.Remove(src)
	return ..()


/obj/effect/plant/hivemind/after_spread(obj/effect/plant/child, turf/target_turf)
	if(master_node)
		master_node.add_wireweed(child)
	spawn(1)
		child.dir = get_dir(loc, target_turf) //actually this means nothing for wires, but need for animation
		FLICK("spread_anim", child)
		child.forceMove(target_turf)
		for(var/obj/effect/plant/hivemind/neighbor in range(1, child))
			neighbor.update_neighbors()


/obj/effect/plant/hivemind/proc/try_to_assimilate()
	for(var/obj/machinery/machine_on_my_tile in loc)
		var/can_assimilate = TRUE
		if(machine_on_my_tile.alpha == 0) //which mean that machine is already assimilated
			continue

		//whitelist check
		if(is_type_in_list(machine_on_my_tile, hive_mind_ai.restricted_machineries))
			can_assimilate = FALSE

		//assimilation is slow process, so it's take some time
		//there we use our failure chance. Then it lower, then faster hivemind learn how to properly assimilate it
		if(can_assimilate && prob(hive_mind_ai.failure_chance))
			can_assimilate = FALSE
			anim_shake(machine_on_my_tile)
			return

		 //only one machine per turf
		if(can_assimilate && !locate(/obj/machinery/hivemind_machine) in loc)
			assimilate(machine_on_my_tile)
			return

	//modular computers handling
	var/obj/item/modular_computer/console/mod_comp = locate() in loc
	if(mod_comp && mod_comp.alpha != 0)
		assimilate(mod_comp)

	//dead bodies handling
	for(var/mob/living/dead_body in loc)
		if(dead_body.stat == DEAD)
			assimilate(dead_body)


/obj/effect/plant/hivemind/update_neighbors()
	..()
	update_connections()
	update_icon()
	update_openspace()


/obj/effect/plant/hivemind/spread()
	if(hive_mind_ai && master_node)
		..()


/obj/effect/plant/hivemind/life()
	if(hive_mind_ai && master_node)
		try_to_assimilate()
		chem_handler()
		var/obj/machinery/door/door_on_my_tile = locate(/obj/machinery/door) in loc
		if(door_on_my_tile && door_on_my_tile.density)
			door_interaction(door_on_my_tile)
	else
		//slow vanishing after node death
		health -= 10
		alpha = 255 * health/max_health
		check_health()


/obj/effect/plant/hivemind/is_mature()
	return TRUE


/obj/effect/plant/hivemind/refresh_icon()
	cut_overlays()
	var/image/I
	var/turf/simulated/floor/F = loc
	if((locate(/obj/structure/burrow) in loc) && F.flooring.is_plating)
		icon_state = "wires_burrow"
	else
		for(var/i = 1 to 4)
			I = image(src.icon, "wires[wires_connections[i]]", dir = 1<<(i-1))
			add_overlays(I)

	//wallhug
	for(var/direction in cardinal + list(NORTHEAST, NORTHWEST)-SOUTH)
		//corners
		if(direction == NORTHEAST || direction == NORTHWEST)
			if(!is_wall(get_step(loc, NORTH)) || !is_wall(get_step(loc, direction-NORTH)))
				continue
		//default
		var/turf/T = get_step(loc, direction)
		if(is_wall(T))
			var/image/wall_hug_overlay = image(icon = src.icon, icon_state = "wall_hug", dir = direction)
			if (T.x < x)
				wall_hug_overlay.pixel_x -= 32
			if (T.x > x)
				wall_hug_overlay.pixel_x += 32
			if (T.y < y)
				wall_hug_overlay.pixel_y -= 32
			if (T.y > y)
				wall_hug_overlay.pixel_y += 32
			wall_hug_overlay.layer = ABOVE_WINDOW_LAYER
			add_overlays(wall_hug_overlay)



/obj/effect/plant/hivemind/proc/is_wall(turf/target)
	if((locate(/obj/structure/window) in target) || istype(target, /turf/simulated/wall))
		return TRUE
	return FALSE


/obj/effect/plant/hivemind/proc/update_connections(propagate = 0)
	var/list/dirs = list()
	for(var/obj/effect/plant/hivemind/W in range(1, src) - src)
		if(propagate)
			W.update_connections()
			W.update_icon()
		dirs += get_dir(src, W)

	wires_connections = dirs_to_corner_states(dirs)


/obj/effect/plant/hivemind/door_interaction(obj/machinery/door/door)
	if(!istype(door) || !hive_mind_ai || !master_node)
		return FALSE

	//if our door isn't broken, we will try to break open. We can do only one action per call
	if(!(door.stat & BROKEN))
		anim_shake(door)
		//first, we open our panel to give our wireweeds access to exposed airlock's electronics
		if(!door.p_open && !istype(door, /obj/machinery/door/window))
			if(prob(50))
				door.p_open = TRUE
				door.update_icon()
			return FALSE
		//but if airlock is welded, we just shake it like we rummage inside
		if(door.welded)
			return FALSE
		//if panel opened, we begin to destruct it from inside of airlock
		if(door.p_open || istype(door, /obj/machinery/door/window))
			//bolts are down? Our wireweeds infest electronics, so this isn't a problem cause it part of us
			if(istype(door, /obj/machinery/door/airlock))
				var/obj/machinery/door/airlock/A = door
				if(A.locked)
					if(prob(75))
						A.unlock()
					return FALSE
			//and then, if airlock is closed, we begin destroy it electronics
			if(door.density)
				door.take_damage(rand(30, 70))
				return FALSE

	return TRUE


/obj/effect/plant/hivemind/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(mover == src)
		if(target.density)
			return FALSE

		if(locate(/obj/structure) in target)
			for(var/obj/structure/S in target)
				if(S.density && S.anchored)
					return FALSE

		if(locate(/obj/machinery/door) in target)
			return FALSE

		return TRUE
	else
		return ..()


/obj/effect/plant/hivemind/Adjacent(var/atom/neighbor)
	var/turf/T = get_turf(neighbor)
	if(locate(/obj/machinery/door) in T)
		for(var/obj/O in T)
			if(istype(O, /obj/machinery/door))
				continue
			if(O.is_block_dir(get_dir(neighbor, src), TRUE))
				return . = ..()
		return TRUE
	else
		. = ..()


//What a pity that we haven't some kind proc as special library to use it somewhere
/obj/effect/plant/hivemind/proc/anim_shake(atom/thing)
	var/init_px = thing.pixel_x
	var/shake_dir = pick(-1, 1)
	animate(thing, transform=turn(matrix(), 8*shake_dir), pixel_x=init_px + 2*shake_dir, time=1)
	animate(transform=null, pixel_x=init_px, time=6, easing=ELASTIC_EASING)


//assimilation process
/obj/effect/plant/hivemind/proc/assimilate(var/atom/subject)
	//Machinery infestation
	if(istype(subject, /obj/machinery) || istype(subject, /obj/item/modular_computer/console))
		var/obj/machinery/hivemind_machine/created_machine

		//New node creation
		if(hive_mind_ai.hives.len < MAX_NODES_AMOUNT)
			var/EP_range = hive_mind_ai.hives.len * (hive_mind_ai.evo_points_max / MAX_NODES_AMOUNT)
			if(hive_mind_ai.evo_points > EP_range) //one hive per: max_EP / max_nodes_amount
				var/can_spawn_new_node = TRUE
				for(var/obj/machinery/hivemind_machine/node/other_node in hive_mind_ai.hives)
					if(get_dist(other_node, subject) < MIN_NODES_RANGE)
						can_spawn_new_node = FALSE
						break
				if(can_spawn_new_node)
					created_machine = new /obj/machinery/hivemind_machine/node(get_turf(subject))


		//Critical failure chance! This machine would be a dummy, which means - without any ability
		if(!created_machine && prob(hive_mind_ai.failure_chance))
			//let's make an infested sprite
			created_machine = new (get_turf(subject))
			var/icon/infected_icon = new('icons/obj/hivemind_machines.dmi', icon_state = "wires-[rand(1, 3)]")
			var/icon/new_icon = new(subject.icon, icon_state = subject.icon_state, dir = subject.dir)
			new_icon.Blend(infected_icon, ICON_OVERLAY)
			created_machine.icon = new_icon
			var/prefix = pick("Warped", "Altered", "Modified", "Upgraded", "Abnormal")
			created_machine.name = "[prefix] [subject.name]"
			created_machine.pixel_x = subject.pixel_x
			created_machine.pixel_y = subject.pixel_y

		//Here we have a little chance to spawn our machinery horror
		if(istype(subject, /obj/machinery))
			var/obj/machinery/victim = subject
			if(prob(15) && victim.circuit)
				new /mob/living/simple_animal/hostile/hivemind/mechiver(get_turf(subject))
				new victim.circuit.type(get_turf(subject))
				qdel(subject)
				return

		//New hivemind machine creation
		if(!created_machine)
			var/list/possible_machines = list()
			//here we compare hivemind's EP level with machine's required value
			for(var/machine_path in hive_mind_ai.EP_price_list)
				var/list/machine_list = hive_mind_ai.EP_price_list[machine_path]
				if(hive_mind_ai.evo_level >= machine_list["level"])
					possible_machines.Add(machine_path)
					//setting of weight of machine
					possible_machines[machine_path] = machine_list["weight"]

			var/picked_machine = pickweight(possible_machines)
			created_machine = new picked_machine(get_turf(subject))

		if(created_machine)
			created_machine.consume(subject)

	//Corpse reanimation
	if(isliving(subject) && !ishivemindmob(subject))
		//human bodies
		if(ishuman(subject))
			var/mob/living/L = subject
			//if our target has cruciform, let's just leave it
			if(is_neotheology_disciple(L))
				return
			for(var/obj/item/W in L)
				L.drop_from_inventory(W)
			var/M = pick(/mob/living/simple_animal/hostile/hivemind/himan, /mob/living/simple_animal/hostile/hivemind/phaser)
			new M(loc)
		//robot corpses
		else if(issilicon(subject))
			new /mob/living/simple_animal/hostile/hivemind/hiborg(loc)
		//other dead bodies
		else
			var/mob/living/simple_animal/hostile/hivemind/resurrected/transformed_mob =  new(loc)
			transformed_mob.take_appearance(subject)

		qdel(subject)


//////////////////////////////////////////////////////////////////
/////////////////////////>RESPONSE CODE<//////////////////////////
//////////////////////////////////////////////////////////////////


//in fact, this is some kind of reinforced wires, so we can't take samples from it and inject something too
//but we still can slice it with something sharp
/obj/effect/plant/hivemind/attackby(obj/item/W, mob/user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

	var/weapon_type
	if (W.has_quality(QUALITY_CUTTING))
		weapon_type = QUALITY_CUTTING
	else if (W.has_quality(QUALITY_WELDING))
		weapon_type = QUALITY_WELDING

	if(weapon_type)
		if(W.use_tool(user, src, WORKTIME_FAST, weapon_type, FAILCHANCE_EASY, required_stat = STAT_MEC)) //Replaced STAT_ROB with STAT_MEC. you aren't ripping this out you are cutting it
			user.visible_message(SPAN_DANGER("[user] cuts down [src]."), SPAN_DANGER("You cut down [src]."))
			die_off()
			return
		return
	else
		if(W.sharp && W.force >= 10)
			health -= rand(W.force/2, W.force) //hm, maybe make damage based on player's robust stat?
			user.visible_message(SPAN_DANGER("[user] slices [src]."), SPAN_DANGER("You slice [src]."))
		else
			to_chat(user, SPAN_DANGER("You try to slice [src], but it's useless!"))
	check_health()


//fire is effective, but there need some time to melt the covering
/obj/effect/plant/hivemind/fire_act()
	health -= rand(1, 4)
	check_health()


//emp is effective too
//it causes electricity failure, so our wireweeds just blowing up inside, what makes them fragile
/obj/effect/plant/hivemind/emp_act(severity)
	if(severity)
		die_off()


//Some acid and there's no problem
/obj/effect/plant/hivemind/proc/chem_handler()
	for(var/obj/effect/effect/smoke/chem/smoke in loc)
		for(var/lethal in killer_reagents)
			if(smoke.reagents.has_reagent(lethal))
				die_off()
				return



#undef HIVE_FACTION
#undef MAX_NODES_AMOUNT
#undef MIN_NODES_RANGE
#undef ishivemindmob

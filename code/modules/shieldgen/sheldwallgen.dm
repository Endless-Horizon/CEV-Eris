////FIELD GEN START //shameless copypasta from fieldgen, powersink, and grille
/obj/machinery/shieldwallgen
		name = "shield generator"
		desc = "A shield generator."
		icon = 'icons/obj/stationobjs.dmi'
		icon_state = "Shield_Gen"
		anchored = FALSE
		density = TRUE
		req_access = list(access_engine_equip)
		circuit = /obj/item/electronics/circuitboard/shieldwallgen
		var/shield_type = /obj/machinery/shieldwall //Overridden by excelsior variant
		var/active = 0
		var/power = 0
		var/state = 0
		var/steps = 0
		var/last_check = 0
		var/check_delay = 10
		var/recalc = 0
		var/locked = 1
		var/destroyed = 0
		var/directwired = 1
//		var/maxshieldload = 200
		var/obj/structure/cable/attached		// the attached cable
		var/storedpower = 0
		flags = CONDUCT
		//There have to be at least two posts, so these are effectively doubled
		var/power_draw = 30000 //30 kW. How much power is drawn from powernet. Increase this to allow the generator to sustain longer shields, at the cost of more power draw.
		var/max_stored_power = 50000 //50 kW
		use_power = NO_POWER_USE	//Draws directly from power net. Does not use APC power.
		var/max_field_dist = 8
		var/stunmode = FALSE
		var/stun_chance = 1

/obj/machinery/shieldwallgen/attack_hand(mob/user as mob)
	if(state != 1)
		to_chat(user, "\red \The [src] needs to be firmly secured to the floor first.")
		return 1
	if(src.locked && !issilicon(user))
		to_chat(user, "\red The controls are locked!")
		return 1
	if(power != 1)
		to_chat(user, "\red \The [src] needs to be powered by wire underneath.")
		return 1

	if(src.active >= 1)
		src.active = 0

		user.visible_message("[user] turned \the [src] off.", \
			"You turn off \the [src].", \
			"You hear heavy droning fade out.")
		for(var/dir in list(1,2,4,8)) src.cleanup(dir)
	else
		src.active = 1
		user.visible_message("[user] turned \the [src] on.", \
			"You turn on \the [src].", \
			"You hear heavy droning.")
	src.add_fingerprint(user)
	playsound(loc, 'sound/machines/machine_switch.ogg', 100, 1)
	update_icon()

/obj/machinery/shieldwallgen/proc/power()
	if(!anchored)
		power = 0
		return 0
	var/turf/T = src.loc

	var/obj/structure/cable/C = T.get_cable_node()
	var/datum/powernet/PN
	if(C)
		PN = C.powernet		// find the powernet of the connected cable

	if(!PN)
		power = 0
		return 0

	var/shieldload = between(500, max_stored_power - storedpower, power_draw)	//what we try to draw
	shieldload = PN.draw_power(shieldload) //what we actually get
	storedpower += shieldload

	//If we're still in the red, then there must not be enough available power to cover our load.
	if(storedpower <= 0)
		power = 0
		return 0

	power = 1	// IVE GOT THE POWER!
	return 1

/obj/machinery/shieldwallgen/on_update_icon()
	SetIconState("Shield_Gen")
	if(active)
		SetIconState("Shield_Gen_active")
		if(stunmode)
			SetIconState("Shield_Gen_emagged")

	cut_overlays()
	if(panel_open)
		add_overlays(image(icon,"Shield_Gen_panel"))

/obj/machinery/shieldwallgen/Process()
	power()

	if(power)
		storedpower -= 2500 //the generator post itself uses some power

	if(storedpower >= max_stored_power)
		storedpower = max_stored_power
	if(storedpower <= 0)
		storedpower = 0

	if(active)
		if(!state)
			active = FALSE
			for(var/fdir in cardinal)
				cleanup(fdir)
			return

		if(!stunmode)
			for(var/fdir in cardinal)
				setup_field(fdir)
		else
			stun()


		if(!power)
			visible_message("\red The [src.name] shuts down due to lack of power!", \
				"You hear heavy droning fade out")
			active = FALSE
			for(var/fdir in cardinal)
				cleanup(fdir)

			update_icon()

/obj/machinery/shieldwallgen/proc/stun()
	for(var/mob/M in range(src,max_field_dist))
		if(can_stun(M) && prob(stun_chance))
			var/obj/item/projectile/beam/stun/P = new(src.loc)
			P.shot_from = src
			P.launch(M)

/obj/machinery/shieldwallgen/proc/can_stun(var/mob/M)
	return TRUE


/obj/machinery/shieldwallgen/proc/setup_field(var/f_dir = 0)
	if(!f_dir)//Make sure its ran right
		return

	var/field_found = 0
	var/turf/T = src.loc
	var/obj/machinery/shieldwallgen/G = null
	for(var/dist = 1, dist <= max_field_dist, dist += 1) // checks out to [max_field_dist] tiles away for another generator
		T = get_step(T, f_dir)

		var/obj/machinery/shieldwall/F = locate(/obj/machinery/shieldwall) in T
		if(F && (F.dir == f_dir || F.dir == reverse_dir[f_dir]))
			field_found++

		G = (locate(/obj/machinery/shieldwallgen) in T)

		if(G && G.active && !G.stunmode)
			break
		else
			G = null

	if(isnull(G))
		return

	if(field_found > 0)	//if we already have the field
		if(field_found < get_dist(src, G)-1)	//but it breached
			cleanup(f_dir)
		else
			return

	T = src.loc
	for(var/dist = 1, dist <= get_dist(src, G)-1, dist += 1) // creates each field tile
		T = get_step(T, f_dir)
		var/obj/machinery/shieldwall/CF = new shield_type(src, G) //(ref to this gen, ref to connected gen)
		CF.loc = T
		CF.set_dir(f_dir)


/obj/machinery/shieldwallgen/proc/cleanup(var/c_dir)

	var/turf/T = src.loc

	for(var/dist = 1, dist <= max_field_dist, dist += 1) // checks out to 8 tiles away for fields
		T = get_step(T, c_dir)

		var/obj/machinery/shieldwall/F = locate(/obj/machinery/shieldwall) in T
		if(F && (F.dir == c_dir || F.dir == reverse_dir[c_dir]))
			qdel(F)

		var/obj/machinery/shieldwallgen/G = (locate(/obj/machinery/shieldwallgen) in T)
		if(G && G.active && !G.stunmode)
			break


/obj/machinery/shieldwallgen/attackby(obj/item/I, mob/user)

	if(default_deconstruction(I, user))
		return

	if(default_part_replacement(I, user))
		return


	if(QUALITY_BOLT_TURNING in I.tool_qualities)
		if(I.use_tool(user, src, WORKTIME_FAST, QUALITY_BOLT_TURNING, FAILCHANCE_EASY,  required_stat = STAT_MEC))
			if(active)
				to_chat(user, "Turn off the field generator first.")
				return

			else if(!state)
				state = TRUE
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				to_chat(user, "You secure the external reinforcing bolts to the floor.")
				src.anchored = TRUE
				return

			else
				state = FALSE
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				to_chat(user, "You undo the external reinforcing bolts.")
				src.anchored = FALSE
				return

	if(istype(I, /obj/item/card/id) || istype(I, /obj/item/modular_computer))
		if (src.allowed(user))
			src.locked = !src.locked
			to_chat(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
		else
			to_chat(user, "\red Access denied.")

	else
		src.add_fingerprint(user)
		visible_message("\red The [src.name] has been hit with \the [I.name] by [user.name]!")


/obj/machinery/shieldwallgen/emag_act()
	stunmode = TRUE

/obj/machinery/shieldwallgen/Destroy()
	src.cleanup(NORTH)
	src.cleanup(SOUTH)
	src.cleanup(WEST)
	src.cleanup(EAST)
	. = ..()

/obj/machinery/shieldwallgen/bullet_act(var/obj/item/projectile/Proj)
	storedpower -= 400 * Proj.get_structure_damage()
	..()
	return

/obj/machinery/shieldwallgen/emag_act()
	stunmode = TRUE
	return

//////////////Containment Field START
/obj/machinery/shieldwall
		name = "Shield"
		desc = "An energy shield."
		icon = 'icons/effects/effects.dmi'
		icon_state = "shieldwall"
		anchored = TRUE
		density = TRUE
		unacidable = 1
		light_range = 3
		var/needs_power = 0
		var/active = 1
//		var/power = 10
		var/delay = 5
		var/last_active
		var/mob/U
		var/obj/machinery/shieldwallgen/gen_primary
		var/obj/machinery/shieldwallgen/gen_secondary
		var/power_usage = 2500	//how much power it takes to sustain the shield
		var/generate_power_usage = 7500	//how much power it takes to start up the shield

/obj/machinery/shieldwall/New(var/obj/machinery/shieldwallgen/A, var/obj/machinery/shieldwallgen/B)
	..()
	update_nearby_tiles()
	src.gen_primary = A
	src.gen_secondary = B
	if(A && B && A.active && B.active)
		needs_power = 1
		if(prob(50))
			A.storedpower -= generate_power_usage
		else
			B.storedpower -= generate_power_usage
	else
		qdel(src) //need at least two generator posts

/obj/machinery/shieldwall/Destroy()
	update_nearby_tiles()
	. = ..()

/obj/machinery/shieldwall/attack_hand(mob/user as mob)
	return


/obj/machinery/shieldwall/Process()
	if(needs_power)
		if(isnull(gen_primary)||isnull(gen_secondary))
			qdel(src)
			return

		if(!(gen_primary.active) || !(gen_secondary.active) || (gen_primary.stunmode) || (gen_secondary.stunmode))
			qdel(src)
			return

		if(prob(50))
			gen_primary.storedpower -= power_usage
		else
			gen_secondary.storedpower -= power_usage


/obj/machinery/shieldwall/bullet_act(var/obj/item/projectile/Proj)
	if(needs_power)
		var/obj/machinery/shieldwallgen/G
		if(prob(50))
			G = gen_primary
		else
			G = gen_secondary
		G.storedpower -= 400 * Proj.get_structure_damage()
	..()
	return


/obj/machinery/shieldwall/ex_act(severity)
	if(needs_power)
		var/obj/machinery/shieldwallgen/G
		switch(severity)
			if(1) //big boom
				if(prob(50))
					G = gen_primary
				else
					G = gen_secondary
				G.storedpower -= 120000

			if(2) //medium boom
				if(prob(50))
					G = gen_primary
				else
					G = gen_secondary
				G.storedpower -= 30000

			if(3) //lil boom
				if(prob(50))
					G = gen_primary
				else
					G = gen_secondary
				G.storedpower -= 12000
	return


/obj/machinery/shieldwall/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(istype(mover) && mover.checkpass(PASSGLASS))
		return prob(20)
	else
		if (istype(mover, /obj/item/projectile))
			return prob(10)
		else
			return !src.density

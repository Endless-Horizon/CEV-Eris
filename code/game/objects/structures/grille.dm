/obj/structure/grille
	desc = "A flimsy lattice of metal rods, with screws to secure it to the floor."
	name = "grille"
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille"
	density = TRUE
	anchored = TRUE
	flags = CONDUCT
	layer = BELOW_OBJ_LAYER
	explosion_resistance = 1
	var/health = 50
	var/destroyed = 0


/obj/structure/grille/ex_act(severity)
	qdel(src)

/obj/structure/grille/on_update_icon()
	if(destroyed)
		icon_state = "[initial(icon_state)]-b"
	else
		icon_state = initial(icon_state)

/obj/structure/grille/Bumped(atom/user)
	if(ismob(user)) shock(user, 70)

/obj/structure/grille/attack_hand(mob/user as mob)

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	user.do_attack_animation(src)

	var/damage_dealt = 1
	var/attack_message = "kicks"
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species.can_shred(H))
			attack_message = "mangles"
			damage_dealt = 5

	if(shock(user, 70))
		return

	if(HULK in user.mutations)
		damage_dealt += 5
	else
		damage_dealt += 1

	attack_generic(user,damage_dealt,attack_message)

/obj/structure/grille/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1
	if(istype(mover) && mover.checkpass(PASSGRILLE))
		return 1
	else
		if(istype(mover, /obj/item/projectile))
			return prob(30)
		else
			return !density

/obj/structure/grille/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)	return

	//Flimsy grilles aren't so great at stopping projectiles. However they can absorb some of the impact
	var/damage = Proj.get_structure_damage()
	var/passthrough = 0

	if(!damage) return

	//20% chance that the grille provides a bit more cover than usual. Support structure for example might take up 20% of the grille's area.
	//If they click on the grille itself then we assume they are aiming at the grille itself and the extra cover behaviour is always used.
	for(var/i in Proj.damage_types)
		if(i == BRUTE)
			//bullets
			if(Proj.original == src || prob(20))
				Proj.damage_types[i] *= between(0, Proj.damage_types[i]/60, 0.5)
				if(prob(max((damage-10)/25, 0))*100)
					passthrough = 1
			else
				Proj.damage_types[i] *= between(0, Proj.damage_types[i]/60, 1)
				passthrough = 1
		if(i == BURN)
			//beams and other projectiles are either blocked completely by grilles or stop half the damage.
			if(!(Proj.original == src || prob(20)))
				Proj.damage_types[i] *= 0.5
				passthrough = 1

	if(passthrough)
		. = PROJECTILE_CONTINUE
		damage = between(0, (damage - Proj.get_structure_damage())*(Proj.damage_types[BRUTE] ? 0.4 : 1), 10) //if the bullet passes through then the grille avoids most of the damage

	src.health -= damage*0.2
	spawn(0) healthcheck() //spawn to make sure we return properly if the grille is deleted

/obj/structure/grille/attackby(obj/item/I, mob/user)

	var/list/usable_qualities = list(QUALITY_WIRE_CUTTING)
	if(anchored)
		usable_qualities.Add(QUALITY_SCREW_DRIVING)

	var/tool_type = I.get_tool_type(user, usable_qualities, src)
	switch(tool_type)

		if(QUALITY_WIRE_CUTTING)
			if(!shock(user, 100))
				if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					new /obj/item/stack/rods(get_turf(src), destroyed ? 1 : 2)
					qdel(src)
					return
			return

		if(QUALITY_SCREW_DRIVING)
			if(anchored)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					anchored = !anchored
					user.visible_message("<span class='notice'>[user] [anchored ? "fastens" : "unfastens"] the grille.</span>", \
										 "<span class='notice'>You have [anchored ? "fastened the grille to" : "unfastened the grill from"] the floor.</span>")
					return
			return

		if(ABORT_CHECK)
			return

//window placing begin //TODO CONVERT PROPERLY TO MATERIAL DATUM
	if(istype(I,/obj/item/stack/material))
		var/obj/item/stack/material/ST = I
		if(!ST.material.created_window)
			return 0

		var/dir_to_set = 1
		if(loc == user.loc)
			dir_to_set = user.dir
		else
			if( ( x == user.x ) || (y == user.y) ) //Only supposed to work for cardinal directions.
				if( x == user.x )
					if( y > user.y )
						dir_to_set = 2
					else
						dir_to_set = 1
				else if( y == user.y )
					if( x > user.x )
						dir_to_set = 8
					else
						dir_to_set = 4
			else
				to_chat(user, SPAN_NOTICE("You can't reach."))
				return //Only works for cardinal direcitons, diagonals aren't supposed to work like this.
		for(var/obj/structure/window/WINDOW in loc)
			if(WINDOW.dir == dir_to_set)
				to_chat(user, SPAN_NOTICE("There is already a window facing this way there."))
				return
		to_chat(user, SPAN_NOTICE("You start placing the window."))
		if(do_after(user,20,src))
			for(var/obj/structure/window/WINDOW in loc)
				if(WINDOW.dir == dir_to_set)//checking this for a 2nd time to check if a window was made while we were waiting.
					to_chat(user, SPAN_NOTICE("There is already a window facing this way there."))
					return

			var/wtype = ST.material.created_window
			if (ST.use(1))
				var/obj/structure/window/WD = new wtype(loc, dir_to_set, 1)
				to_chat(user, SPAN_NOTICE("You place the [WD] on [src]."))
				WD.update_icon()
		return
//window placing end

	else if(!(I.flags & CONDUCT) || !shock(user, 70))
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		user.do_attack_animation(src)
		playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
		health -= I.force * I.structure_damage_factor
	healthcheck()
	..()
	return


/obj/structure/grille/proc/healthcheck()
	if(health <= 0)
		if(!destroyed)
			density = FALSE
			destroyed = 1
			update_icon()
			new /obj/item/stack/rods(get_turf(src))

		else
			if(health <= -6)
				new /obj/item/stack/rods(get_turf(src))
				qdel(src)
				return
	return

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise

/obj/structure/grille/proc/shock(mob/user as mob, prb)

	if(!anchored || destroyed)		// anchored/destroyed grilles are never connected
		return 0
	if(!prob(prb))
		return 0
	if(!in_range(src, user))//To prevent TK and mech users from getting shocked
		return 0
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(electrocute_mob(user, C, src))
			if(C.powernet)
				C.powernet.trigger_warning()
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			if(user.stunned)
				return 1
		else
			return 0
	return 0

/obj/structure/grille/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(!destroyed)
		if(exposed_temperature > T0C + 1500)
			health -= 1
			healthcheck()
	..()

/obj/structure/grille/attack_generic(var/mob/user, var/damage, var/attack_verb)
	visible_message(SPAN_DANGER("[user] [attack_verb] the [src]!"))
	attack_animation(user)
	health -= damage
	spawn(1) healthcheck()
	return 1

/obj/structure/grille/hitby(AM as mob|obj)
	..()
	visible_message(SPAN_DANGER("[src] was hit by [AM]."))
	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	var/tforce = 0
	if(ismob(AM))
		tforce = 10
	else if(isobj(AM))
		var/obj/item/I = AM
		tforce = I.throwforce
	health = max(0, health - tforce)
	if(health <= 0)
		destroyed=1
		new /obj/item/stack/rods(get_turf(src))
		density = FALSE
		update_icon()

// Used in mapping to avoid
/obj/structure/grille/broken
	destroyed = 1
	icon_state = "grille-b"
	density = FALSE
	New()
		..()
		health = rand(-5, -1) //In the destroyed but not utterly threshold.
		healthcheck() //Send this to healthcheck just in case we want to do something else with it.

/obj/structure/grille/cult
	name = "cult grille"
	desc = "A matrice built out of an unknown material, with some sort of force field blocking air around it"
	icon_state = "grillecult"
	health = 40 //Make it strong enough to avoid people breaking in too easily

/obj/structure/grille/cult/CanPass(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	if(air_group)
		return 0 //Make sure air doesn't drain
	..()

/obj/structure/grille/get_fall_damage(var/turf/from, var/turf/dest)
	var/damage = health * 0.4

	if (from && dest)
		damage *= abs(from.z - dest.z)

	return damage

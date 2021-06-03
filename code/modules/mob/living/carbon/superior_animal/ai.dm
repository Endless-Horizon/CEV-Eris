
//NOTE: Don't use this proc for finding specific mobs or a very certain object; ultilize GLOBs instead of view()
/mob/living/carbon/superior_animal/proc/getObjectsInView()
	objectsInView = objectsInView || view(src, viewRange)
	return objectsInView

//Use this for all mobs per zlevel, get_dist() checked
/mob/living/carbon/superior_animal/proc/getPotentialTargets()
	var/turf/T = get_turf(src)
	if(!T)
		return //We're contained inside something, a locker perhaps.
	return hearers(src, viewRange)


	/* There was an attempt at optimization, but it was unsanitized, and was more expensive than just checking hearers.
	var/list/list_to_return = new
	for(var/atom/thing in SSmobs.clients_by_zlevel[((get_turf(src)).z)])
		if(get_dist(src, thing) <= viewRange)
			list_to_return += thing

	return list_to_return*/

/mob/living/carbon/superior_animal/proc/findTarget()
	var/list/filteredTargets = new

	for(var/atom/O in getPotentialTargets())
		if (isValidAttackTarget(O))
			filteredTargets += O

	for (var/mob/living/exosuit/M in GLOB.mechas_list)
		if ((M.z == src.z) && (get_dist(src, M) <= viewRange) && isValidAttackTarget(M))
			filteredTargets += M

	return safepick(nearestObjectsInList(filteredTargets, src, acceptableTargetDistance))

/mob/living/carbon/superior_animal/proc/attemptAttackOnTarget()
	if (!Adjacent(target_mob))
		return

	return UnarmedAttack(target_mob,1)

/mob/living/carbon/superior_animal/proc/prepareAttackOnTarget()
	stop_automated_movement = 1

	if (!target_mob || !isValidAttackTarget(target_mob))
		loseTarget()
		return

	if ((get_dist(src, target_mob) >= viewRange) || src.z != target_mob.z)
		loseTarget()
		return

	attemptAttackOnTarget()

/mob/living/carbon/superior_animal/proc/loseTarget()
	stop_automated_movement = 0
	walk(src, 0)
	target_mob = null
	stance = HOSTILE_STANCE_IDLE

/mob/living/carbon/superior_animal/proc/isValidAttackTarget(var/atom/O)
	if (isliving(O))
		var/mob/living/L = O
		if((L.stat != CONSCIOUS) || (L.health <= (ishuman(L) ? HEALTH_THRESHOLD_CRIT : 0)) || (!attack_same && (L.faction == src.faction)) || (L in friends))
			return
		return 1

	if (istype(O, /mob/living/exosuit))
		var/mob/living/exosuit/M = O
		return isValidAttackTarget(M.pilots[1])

/mob/living/carbon/superior_animal/proc/destroySurroundings()
	if (prob(break_stuff_probability))

		for (var/obj/structure/window/obstacle in src.loc) // To destroy directional windows that are on the creature's tile
			obstacle.attack_generic(src,rand(melee_damage_lower,melee_damage_upper),attacktext)
			return

		for (var/obj/machinery/door/window/obstacle in src.loc) // To destroy windoors that are on the creature's tile
			obstacle.attack_generic(src,rand(melee_damage_lower,melee_damage_upper),attacktext)
			return

		for (var/dir in cardinal) // North, South, East, West
			for (var/obj/structure/window/obstacle in get_step(src, dir))
				if ((obstacle.is_full_window()) || (obstacle.dir == reverse_dir[dir])) // So that directional windows get smashed in the right order
					obstacle.attack_generic(src,rand(melee_damage_lower,melee_damage_upper),attacktext)
					return

			for (var/obj/machinery/door/window/obstacle in get_step(src, dir))
				if (obstacle.dir == reverse_dir[dir]) // So that windoors get smashed in the right order
					obstacle.attack_generic(src,rand(melee_damage_lower,melee_damage_upper),attacktext)
					return

			var/obj/structure/obstacle = locate(/obj/structure, get_step(src, dir))
			if (istype(obstacle, /obj/structure/window) || istype(obstacle, /obj/structure/closet) || istype(obstacle, /obj/structure/table) || istype(obstacle, /obj/structure/grille))
				obstacle.attack_generic(src,rand(melee_damage_lower,melee_damage_upper),attacktext)


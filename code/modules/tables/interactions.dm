/obj/item/var/list/center_of_mass = list("x"=16, "y"=16) //can be null for no exact placement behaviour
/obj/structure/table/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1
	if(istype(mover,/obj/item/projectile))
		return (check_cover(mover,target))
	if (flipped == 1)
		if (get_dir(loc, target) == dir)
			return !density
		else
			return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	if(locate(/obj/structure/table) in get_turf(mover))
		return 1
	return 0

//checks if projectile 'P' from turf 'from' can hit whatever is behind the table. Returns 1 if it can, 0 if bullet stops.
/obj/structure/table/proc/check_cover(obj/item/projectile/P, turf/from)
	var/turf/cover
	if(flipped==1)
		cover = get_turf(src)
	else if(flipped==0)
		cover = get_step(loc, get_dir(from, loc))
	if(!cover)
		return 1
	if (get_dist(P.starting, loc) <= 1) //Tables won't help you if people are THIS close
		return 1
	if (get_turf(P.original) == cover)
		var/chance = 20
		if (ismob(P.original))
			var/mob/M = P.original
			if (M.lying)
				chance += 20				//Lying down lets you catch less bullets
		if(flipped==1)
			if(get_dir(loc, from) == dir)	//Flipped tables catch mroe bullets
				chance += 20
			else
				return 1					//But only from one side
		if(prob(chance))
			health -= P.get_structure_damage()/2
			if (health > 0)
				visible_message(SPAN_WARNING("[P] hits \the [src]!"))
				return 0
			else
				visible_message(SPAN_WARNING("[src] breaks down!"))
				break_to_parts()
				return 1
	return 1

/obj/structure/table/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(istype(O) && O.checkpass(PASSTABLE))
		return 1
	if (flipped==1)
		if (get_dir(loc, target) == dir)
			return !density
		else
			return 1
	return 1

//Drag and drop onto tables
//This is mainly so that janiborg can put things on tables
/obj/structure/table/MouseDrop_T(atom/A, mob/user, src_location, over_location, src_control, over_control, params)
	if(ismob(A.loc))
		if (user.unEquip(A, loc))
			set_pixel_click_offset(A, params)
		return

	if(istype(A, /obj/item) && istype(A.loc, /turf))
		var/obj/item/O = A

		if(isghost(user))
			if( src_location == over_location )
				set_pixel_click_offset(O, params, animate = TRUE)
				return

		else if (A.CanMouseDrop(loc, user))
			//Mice can push around pens and paper, but not heavy tools
			if (O.w_class <= user.can_pull_size)
				O.forceMove(loc)
				set_pixel_click_offset(O, params, animate = TRUE)
				return
			else
				to_chat(user, SPAN_WARNING("[O] is too heavy for you to move!"))
				return

	return ..()


/obj/structure/table/affect_grab(mob/living/user, mob/living/target, state)
	var/obj/occupied = turf_is_crowded()
	if(occupied)
		to_chat(user, SPAN_DANGER("There's \a [occupied] in the way."))
		return
	if(state < GRAB_AGGRESSIVE || target.loc==src.loc)
		if(user.a_intent == I_HURT)
			if(prob(15))
				target.Weaken(5)
			target.damage_through_armor(8, BRUTE, BP_HEAD, ARMOR_MELEE)
			visible_message(SPAN_DANGER("[user] slams [target]'s face against \the [src]!"))
			target.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been slammed by [user.name] ([user.ckey] against \the [src])</font>"
			user.attack_log += "\[[time_stamp()]\] <font color='red'>Slammed [target.name] ([target.ckey] against over \the [src])</font>"
			msg_admin_attack("[user] slammed a [target] against \the [src].")
			if(material)
				playsound(loc, material.tableslam_noise, 50, 1)
			else
				playsound(loc, 'sound/weapons/tablehit1.ogg', 50, 1)
			var/list/L = take_damage(rand(1,5))
			// Shards. Extra damage, plus potentially the fact YOU LITERALLY HAVE A PIECE OF GLASS/METAL/WHATEVER IN YOUR FACE
			for(var/obj/item/material/shard/S in L)
				if(prob(50))
					target.visible_message(
						SPAN_DANGER("\The [S] slices [target]'s face messily!"),
						SPAN_DANGER("\The [S] slices your face messily!")
					)
					target.damage_through_armor(10, BRUTE, BP_HEAD, ARMOR_MELEE)
					if(prob(2))
						target.embed(S, def_zone = BP_HEAD)
		else
			to_chat(user, SPAN_DANGER("You need a better grip to do that!"))
			return
	else
		target.forceMove(loc)
		target.Weaken(5)
		visible_message(SPAN_DANGER("[user] puts [target] on \the [src]."))
		target.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been put on \the [src] by [user.name] ([user.ckey])</font>"
		user.attack_log += "\[[time_stamp()]\] <font color='red'>Puts [target.name] ([target.ckey] on \the [src])</font>"
		msg_admin_attack("[user] puts a [target] on \the [src].")
	return TRUE



/obj/structure/table/attackby(obj/item/W, mob/living/user, params)
	if(!istype(W))
		return


	if(istype(W, /obj/item/melee/energy/blade))
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, src.loc)
		spark_system.start()
		playsound(src.loc, 'sound/weapons/blade1.ogg', 50, 1)
		playsound(src.loc, "sparks", 50, 1)
		user.visible_message(SPAN_DANGER("\The [src] was sliced apart by [user]!"))
		break_to_parts()
		return

	if(can_plate && !material)
		to_chat(user, SPAN_WARNING("There's nothing to put \the [W] on! Try adding plating to \the [src] first."))
		return

	if (user.unEquip(W, loc))
		set_pixel_click_offset(W, params)
/obj/structure/table/attack_tk() // no telehulk sorry

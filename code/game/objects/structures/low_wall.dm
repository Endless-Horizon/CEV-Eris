/*
	Low walls are a roughly waist-height wall object which goes under full tile windows.

	They share some properties with walls -
		They are tough
		They block movement

	However they differ from walls in a few important respects:
		They do not block vision
		They do not restrict gas flow


	Hence they are more like tables, and they share some useful qualities with tables
		Crawling animals can move over them
		Objects can be placed ontop of them


	Certain table qualities do not apply however:
		They have no "underneath" space, nothing can be placed under them, creatures can't crawl under them
*/
/obj/structure/low_wall
	density = TRUE
	opacity = 0
	anchored = TRUE
	layer = LOW_WALL_LAYER
	icon = 'icons/obj/structures/low_wall.dmi'
	icon_state = "metal"
	throwpass = TRUE
	var/connected = TRUE
	var/wall_color = PLASTEEL_COLOUR
	var/roundstart = FALSE
	var/list/connections = list("0", "0", "0", "0")
	var/list/wall_connections = list("0", "0", "0", "0")

	var/construction_stage

	var/maxhealth = 600
	var/health = 600

	var/hitsound = 'sound/weapons/Genhit.ogg'
	climbable = TRUE

//Derelict tileset
/obj/structure/low_wall/onestar
	wall_color = "#FFFFFF"
	icon_state = "onestar"




//Low walls mark the turf they're on as a wall.  This is vital for floor icon updating code
/obj/structure/low_wall/New()
	var/turf/T = loc
	if (istype(T))
		T.is_wall = TRUE
	.=..()

/obj/structure/low_wall/Destroy()
	for (var/obj/structure/window/W in loc)
		if (!QDELETED(W))
			W.shatter()

	//If we're on a floor, make it no longer be counted as a wall
	var/turf/simulated/floor/T = loc
	if (istype(T))
		T.is_wall = FALSE

	connected = FALSE
	update_connections(1) //Updating connections with false connected will make nearby walls ignore this one
	for(var/obj/structure/low_wall/L in orange(src, 1))
		L.update_icon()
	. = ..()



/obj/structure/low_wall/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/low_wall/LateInitialize(var/list/args)
	// One low wall per turf.
	for(var/obj/structure/low_wall/T in loc)
		if(T != src)
			// There's another wall here that's not us, get rid of it
			qdel(T)
			return

	//if (args)
	//	update_connections(0)
	//else
	//
	update_connections(1)
	update_icon()



/obj/structure/low_wall/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)

	if(istype(mover,/obj/item/projectile))
		return (check_cover(mover,target))


	//Its debateable whether its correct to use layer in a logic check like this.
	//The main intent is to prevent creatures from walking under the wall in hide mode, there is no "under" the wall.
	//This is necessary because low walls can't be placed below the hide layer due to shutters
	if(istype(mover) && mover.checkpass(PASSTABLE) && mover.layer > layer)
		return 1
	if(locate(/obj/structure/low_wall) in get_turf(mover))
		return 1
	if(isliving(mover))
		var/mob/living/L = mover
		if(L.weakened)
			return 1
	return ..()


//Drag and drop onto low walls. Copied from tables
//This is mainly so that janiborg can put things on tables
/obj/structure/low_wall/MouseDrop_T(atom/A, mob/user, src_location, over_location, src_control, over_control, params)
	if(ismob(A.loc))
		user.unEquip(A, loc)
		set_pixel_click_offset(A, params)
		return

	if (istype(A, /obj/item) && istype(A.loc, /turf) && (A.Adjacent(src) || user.Adjacent(src)))
		var/obj/item/O = A
		//Mice can push around pens and paper, but not heavy tools
		if (O.w_class <= user.can_pull_size)
			O.forceMove(loc)
			set_pixel_click_offset(O, params, animate=TRUE)
			return
		else
			to_chat(user, SPAN_WARNING("[O] is too heavy for you to move!"))
			return

	return ..()


//Low walls can be climbed over, but only if nothing ontop is blocking them
//This is needed to stop people glitching through the window and using them as external airlocks
/obj/structure/low_wall/can_climb(var/mob/living/user, post_climb_check=0)
	for(var/obj/structure/window/W in loc)
		if (!W.CanPass(user, loc))
			return FALSE

	return ..()


//checks if projectile 'P' from turf 'from' can hit whatever is behind the table. Returns 1 if it can, 0 if bullet stops.
/obj/structure/low_wall/proc/check_cover(obj/item/projectile/P, turf/from)
	var/turf/cover
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
		if(prob(chance))
			health -= P.get_structure_damage()/2
			if (health > 0)
				visible_message(SPAN_WARNING("[P] hits \the [src]!"))
				return 0
			else
				visible_message(SPAN_WARNING("[src] breaks down!"))
				qdel(src)
				return 1
	return 1


//Icon procs.mostly copied from tables
/obj/structure/low_wall/on_update_icon()
	cut_overlays()

	var/image/I

	//Make the wall overlays
	for(var/i = 1 to 4)
		I = image(icon, "[icon_state]_[connections[i]]", dir = 1<<(i-1))
		I.color = wall_color
		add_overlays(I)


	for (var/obj/structure/window/W in loc)
		if (W.is_fulltile())
			W.update_icon()




	for(var/i = 1 to 4)
		I = image(icon, "[icon_state]_over_[wall_connections[i]]", dir = 1<<(i-1))
		I.color = wall_color
		I.layer = ABOVE_WINDOW_LAYER
		add_overlays(I)






//Now this is a bit complex so read carefully
/*
	We link up with other low walls around us, just like any wall, window, table or carpet links up with its own kind
	However we also link up with normal, full sized walls, and the rules for linking with those are different
	Rather than looking in a 1 range, we link up with walls that meet the following conditions
		1. They are within 1 range of us
		2a. They are cardinally adjacent to us
			-OR-
		2b. They are cardinally adjacent to a low wall which is cardinally adjacent to us
			-OR-
		2c. They are adjacent to two other walls that we are also connected to

	This means that if, for example, we're in an I shaped configuration,
		with empty spaces to the left and right, and fullsize walls in the row above and below
		we will only link with the two walls directly above and below us.
		and we will NOT link with the four walls diagonal to us

		However, if those empty spaces to the sides were filled with other low walls,
		then we would link with all of the high walls around us

*/
//Copied from table.dm, used below
#define CORNER_NONE 0
#define CORNER_COUNTERCLOCKWISE 1
#define CORNER_DIAGONAL 2
#define CORNER_CLOCKWISE 4

//These tell what each position means in the four-element connections list
#define CORNER_NORTHWEST 1
#define CORNER_SOUTHEAST 2
#define CORNER_NORTHEAST 3
#define CORNER_SOUTHWEST 4
/obj/structure/low_wall/proc/update_connections(propagate=0, var/debug = 0)

	//If we are not connected, this will make nearby walls forget us and disconnect from us
	if(!connected)
		connections = list("0", "0", "0", "0")

		if(propagate)
			for(var/obj/structure/low_wall/T in oview(src, 1))
				T.update_connections()

			for(var/turf/simulated/wall/T in RANGE_TURFS(1, src) - src)
				T.update_connections()
		return

	//A list of directions to nearby low walls
	var/list/connection_dirs = list()

	//A list of fullsize walls that we're considering connecting to.
	var/list/turf/wall_candidates = list()

	//A list of fullsize walls we will definitely connect to, based on the rules above
	var/list/wall_dirs = list()

	for(var/obj/structure/low_wall/T in orange(src, 1))
		if (!T.connected)
			continue

		var/T_dir = get_dir(src, T)
		connection_dirs |= T_dir


		if(propagate)
			spawn(0)
				T.update_connections()
				T.update_icon()

		//If this low wall is in a cardinal direction to us,
		//then we will grab full walls that are cardinal to IT
		//These walls all meet condition 2b
		if (T_dir in cardinal)
			for (var/d in cardinal)
				var/turf/t = get_step(T, d)
				if (istype(t, /turf/simulated/wall))
					wall_candidates |= t

	//We'll use this list in a moment to store diagonal tiles that might be candidates for rule 2C
	var/list/deferred_diagonals = list()

	//We'll use this to store any direct cardinal high walls we detect in the next step
	var/list/connected_cardinals = list()

	//Now we loop through all the full walls near us. Everything here automatically meets condition 1
	for(var/turf/simulated/wall/T in RANGE_TURFS(1, src) - src)
		var/T_dir = get_dir(src, T)

		//If this wall is cardinal to us, it meets condition 2a and passes
		if (T_dir in cardinal)
			connected_cardinals += T_dir
			connection_dirs 	|= T_dir
			wall_dirs 			|= T_dir
		//Alternatively if it's in the wall candidates list compiled above, then it meets condition 2b and passes
		else if (T in wall_candidates)
			connection_dirs 	|= T_dir
			wall_dirs 			|= T_dir

		//If neither of the above are true, it still has a chance to meet condition 2c
		else
			deferred_diagonals |= T_dir

		if(propagate)
			spawn(0)
				T.update_connections()
				T.update_icon()

	//Last chance to connect
	//Now we will dump cpnnected_cardinals list into a bitfield to make the next section simpler
	var/wall_dirs_bitfield = 0
	for (var/d in connected_cardinals)
		wall_dirs_bitfield |= d

	for (var/d in deferred_diagonals)
	/*
		Deferred diagonals list now contains the directions of all fullsize walls which are:
		1. Within 1 tile of this wall
		2. At a diagonal to this wall
		3. Not at a cardinal to any adjacent low wall

		There is still a possibility to have a connection to these walls under condition 2c,
		That is, if it is adjacent to two other fullsize walls which are already confirmed connections

	*/
		//Since we have everything in a bitfield, we can compare the diagonals against it.
		//If both of its cardinals are here, the diagonal will be too
		if ((wall_dirs_bitfield & d) == d)
			if (debug)	to_chat(world, "Connected to a diagonal wall, [direction_to_text(d)] [d], Bitfield [wall_dirs_bitfield]")
			wall_dirs |= (d)
			connection_dirs |= d

	connections = dirs_to_corner_states(connection_dirs)
	wall_connections = dirs_to_corner_states(wall_dirs)


	/*
		Extra last bonus chance to connect.
		Here we will "upgrade" the wall connections in a few specific cases where the overall connections are better
	*/
	for (var/i = 1;i<=4;i++)
		var/a = text2num(wall_connections[i])
		var/b = text2num(connections[i])

		//First of all, if we have a single vertical high wall connection, but a cross of total connections
		//Then we will upgrade the high wall connections to a cross too. this prevents some bugginess
		if ((((i in list(CORNER_NORTHWEST, CORNER_SOUTHEAST)) && a == CORNER_CLOCKWISE) \
		|| ((i in list(CORNER_NORTHEAST, CORNER_SOUTHWEST)) && a == CORNER_COUNTERCLOCKWISE)) \
		&& (b in list(5,7)))
			//What a mess, all that determines whether a corner connects to only vertical.
			//If its in the northwest or southeast corner, and its only connection is clockwise, then that connection is either up or down
			//Ditto with the other check
			//The last one is checking if b == a cross or block connection
			wall_connections[i] = connections[i]

		//Secondly, if we have a cross of two high walls, but a block of total connections,
		//We upgrade wall connections to a block too.
		//This basically means treating a diagonal low wall like a high wall
		else if (a == 5 && b == 7)
			wall_connections[i] = connections[i]


#undef CORNER_NORTHWEST
#undef CORNER_SOUTHEAST
#undef CORNER_NORTHEAST
#undef CORNER_SOUTHWEST

#undef CORNER_NONE
#undef CORNER_COUNTERCLOCKWISE
#undef CORNER_DIAGONAL
#undef CORNER_CLOCKWISE




//Attack handling, damage, deconstructing, etc.
//Mostly copied and modified from normal walls
/obj/structure/low_wall/attackby(obj/item/I, mob/user, var/params)

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if (!user)
		return

	//If the user isn't in harm intent and there's no window ontop of this wall, it is treated like a table.
		//Items used on it will be placed on it like a surface

	var/tool_type = I.get_tool_type(user, list(QUALITY_WELDING), src)
	switch(tool_type)
		if(QUALITY_WELDING)
			if (locate(/obj/structure/window) in loc)
				to_chat(user, SPAN_NOTICE("You must remove the window mounted on this wall before it can be repaired or deconstructed"))
				return
			if(locate(/obj/effect/overlay/wallrot) in src)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You burn away the fungi with \the [I]."))
					for(var/obj/effect/overlay/wallrot/WR in src)
						qdel(WR)
					return
			if(health < maxhealth)
				if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You repair the damage to [src]."))
					take_damage(maxhealth - health)
					return
			if(isnull(construction_stage))
				to_chat(user, SPAN_NOTICE("You begin removing the outer plating..."))
				if(I.use_tool(user, src, WORKTIME_LONG, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You remove the outer plating."))
					dismantle_wall()
					user.visible_message(SPAN_WARNING("The wall was torn open by [user]!"))
					return

	//Turn on harm intent to override this behaviour and instead attack the wall
	if (!(locate(/obj/structure/window) in loc) && user.a_intent != I_HURT)
		if (user.unEquip(I, src.loc))
			set_pixel_click_offset(I, params)
			return


	//Hitting the wall with stuff
	if(!istype(I,/obj/item/rcd) && !istype(I, /obj/item/reagent_containers))
		if(!I.force)
			return attack_hand(user)
		var/attackforce = I.force*I.structure_damage_factor
		var/dam_threshhold = 150 //Integrity of Steel
		var/dam_prob = min(100,60*1.4) //60 is hardness of steel
		if(ishuman(user))
			var/mob/living/carbon/human/attacker = user
			dam_prob -= attacker.stats.getStat(STAT_ROB)
		if(dam_prob < 100 && attackforce > (dam_threshhold/10))
			playsound(src, hitsound, 80, 1)
			if(!prob(dam_prob))
				visible_message(SPAN_DANGER("\The [user] attacks \the [src] with \the [I]!"))
				playsound(src, pick(WALLHIT_SOUNDS), 100, 5)
				take_damage(attackforce)
			else
				visible_message(SPAN_WARNING("\The [user] attacks \the [src] with \the [I]!"))
		else
			visible_message(SPAN_DANGER("\The [user] attacks \the [src] with \the [I], but it bounces off!"))
		user.do_attack_animation(src)
		return



/obj/structure/low_wall/proc/dismantle_wall(var/devastated, var/explode, var/no_product)
	if (QDELETED(src))
		return
	playsound(src, 'sound/items/Welder.ogg', 100, 1)
	if(!no_product)
		new /obj/structure/girder/low(loc)
		new /obj/item/stack/material/steel(loc, 1)

	clear_plants()
	update_connections(1)
	qdel(src)


/obj/structure/low_wall/proc/take_damage(dam)
	if(locate(/obj/effect/overlay/wallrot) in src)
		dam *= 10

	health -= dam
	update_damage()

/obj/structure/low_wall/proc/update_damage()
	if(health < 0)
		dismantle_wall()
	else
		update_icon()

/obj/structure/low_wall/proc/clear_plants()
	for(var/obj/effect/overlay/wallrot/WR in src)
		qdel(WR)
	for(var/obj/effect/plant/plant in range(src, 1))
		if(plant.wall_mount == src) //shrooms drop to the floor
			qdel(plant)
		plant.update_neighbors()


/obj/structure/low_wall/affect_grab(var/mob/living/user, var/mob/living/target, var/state)
	var/obj/occupied = turf_is_crowded()
	if(occupied)
		to_chat(user, SPAN_DANGER("There's \a [occupied] in the way."))
		return
	if(state < GRAB_AGGRESSIVE || target.loc==src.loc)
		if(user.a_intent == I_HURT)
			if(prob(15))
				target.Weaken(5)
			target.damage_through_armor(12, BRUTE, BP_HEAD, ARMOR_MELEE)
			visible_message(SPAN_DANGER("[user] slams [target]'s face against \the [src]!"))
			playsound(loc, 'sound/weapons/tablehit1.ogg', 50, 1)

		else
			to_chat(user, SPAN_DANGER("You need a better grip to do that!"))
			return
	else
		target.forceMove(loc)
		target.Weaken(5)
		visible_message(SPAN_DANGER("[user] puts [target] on \the [src]."))
		target.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been put on \the [src] by [user.name] ([user.ckey] )</font>"
		user.attack_log += "\[[time_stamp()]\] <font color='red'>Puts [target.name] ([target.ckey] on \the [src])</font>"
		msg_admin_attack("[user] puts a [target] on \the [src].")
	return TRUE



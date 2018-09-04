//////////////////////////////
//Contents: Ladders, Stairs.//
//////////////////////////////

/obj/structure/multiz
	name = "ladder"
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	icon = 'icons/obj/stairs.dmi'
	var/istop = TRUE
	var/obj/structure/multiz/target

/obj/structure/multiz/New()
	. = ..()
	for(var/obj/structure/multiz/M in loc)
		if(M != src)
			spawn(1)
				world.log << "##MAP_ERROR: Multiple [initial(name)] at ([x],[y],[z])"
				qdel(src)
			return .

/obj/structure/multiz/CanPass(obj/mover, turf/source, height, airflow)
	return airflow || !density

/obj/structure/multiz/proc/find_target()
	return

/obj/structure/multiz/Initialize()
	. = ..()
	find_target()

/obj/structure/multiz/attack_tk(mob/user)
	return

/obj/structure/multiz/attack_ghost(mob/user)
	. = ..()
	user.Move(get_turf(target))

/obj/structure/multiz/attack_ai(mob/living/silicon/user)
	if(target)
		if (isAI(user))
			var/turf/T = get_turf(target)
			T.move_camera_by_click()
		else if (Adjacent(src, user))
			attack_hand(user)





////LADDER////

/obj/structure/multiz/ladder
	name = "ladder"
	desc = "A ladder.  You can climb it up and down."
	icon_state = "ladderdown"
	var/climb_delay = 25

/obj/structure/multiz/ladder/find_target()
	var/turf/targetTurf = istop ? GetBelow(src) : GetAbove(src)
	target = locate(/obj/structure/multiz/ladder) in targetTurf

/obj/structure/multiz/ladder/up
	icon_state = "ladderup"
	istop = FALSE

/obj/structure/multiz/ladder/Destroy()
	if(target && istop)
		qdel(target)
	return ..()

/obj/structure/multiz/ladder/attack_generic(var/mob/M)
	attack_hand(M)

/obj/structure/multiz/ladder/attack_hand(var/mob/M)
	if (isrobot(M) && !isdrone(M))
		var/mob/living/silicon/robot/R = M
		climb(M, (climb_delay*6)/R.speed_factor) //Robots are not built for climbing, they should go around where possible
		//I'd rather make them unable to use ladders at all, but eris' labyrinthine maintenance necessitates it
	else
		climb(M, climb_delay)


/obj/structure/multiz/ladder/proc/climb(var/mob/M, var/delay)
	if(!target || !istype(target.loc, /turf))
		M << SPAN_NOTICE("\The [src] is incomplete and can't be climbed.")
		return

	var/turf/T = target.loc
	for(var/atom/A in T)
		if(A.density)
			M << SPAN_NOTICE("\A [A] is blocking \the [src].")
			return

	//Robots are a quarter ton of steel and most of them lack legs or arms of any appreciable sorts.
	//Even being able to climb ladders at all is a violation of newton'slaws. It shall at least be slow and communicated as such
	if (isrobot(M) && !isdrone(M))
		M.visible_message(
			"<span class='notice'>\A [M] starts slowly climbing [istop ? "down" : "up"] \a [src]!</span>",
			"<span class='danger'>You begin the slow, laborious process of dragging your hulking frame [istop ? "down" : "up"] \the [src]</span>",
			"<span class='danger'>You hear the tortured sound of strained metal.</span>"
		)
		T.visible_message(
			"<span class='danger'>[M] gradually drags itself [istop ? "down" : "up"] \a [src]!</span>",
			"<span class='danger'>You hear the tortured sound of strained metal.</span>"
		)
		playsound(src, 'sound/machines/airlock_creaking.ogg', 100, 1, 5,5)
	else
		M.visible_message(
			"<span class='notice'>\A [M] climbs [istop ? "down" : "up"] \a [src]!</span>",
			"You climb [istop ? "down" : "up"] \the [src]!",
			"You hear the grunting and clanging of a metal ladder being used."
		)
		T.visible_message(
			"<span class='warning'>Someone climbs [istop ? "down" : "up"] \a [src]!</span>",
			"You hear the grunting and clanging of a metal ladder being used."
		)

	if(do_after(M, delay, src))
		M.forceMove(T)
		try_resolve_mob_pulling(M, src)

////STAIRS////

/obj/structure/multiz/stairs
	name = "Stairs"
	desc = "Stairs leading to another deck.  Not too useful if the gravity goes out."
	icon_state = "rampup"
	layer = 2.4

/obj/structure/multiz/stairs/enter
	icon_state = "ramptop"

/obj/structure/multiz/stairs/enter/bottom
	icon_state = "rampbottom"
	istop = FALSE

/obj/structure/multiz/stairs/active
	density = TRUE

/obj/structure/multiz/stairs/active/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover)) // if mover is not null, e.g. mob
		return FALSE
	return TRUE // if mover is null (air movement)

/obj/structure/multiz/stairs/active/find_target()
	var/turf/targetTurf = istop ? GetBelow(src) : GetAbove(src)
	target = locate(/obj/structure/multiz/stairs/enter) in targetTurf

/obj/structure/multiz/stairs/active/Bumped(var/atom/movable/AM)
	if(isnull(AM))
		return

	if(!target)
		if(ismob(AM))
			AM << SPAN_NOTICE("There are no stairs above.")
		log_debug("[src.type] at [src.x], [src.y], [src.z] have non-existant target")
		return

	var/obj/structure/multiz/stairs/enter/ES = locate(/obj/structure/multiz/stairs/enter) in get_turf(AM)

	if(!ES && !istop)
		return

	AM.forceMove(get_turf(target))
	try_resolve_mob_pulling(AM, ES)

/obj/structure/multiz/stairs/attackby(obj/item/C, mob/user)
	. = ..()
	attack_hand(user)
	return

/obj/structure/multiz/stairs/active/attack_ai(mob/living/silicon/ai/user)
	. = ..()
	if(!target)
		user << SPAN_NOTICE("There are no stairs above.")
		log_debug("[src.type] at [src.x], [src.y], [src.z] have non-existant target")

/obj/structure/multiz/stairs/active/attack_robot(mob/user)
	. = ..()
	if(Adjacent(user))
		Bumped(user)

/obj/structure/multiz/stairs/active/attack_hand(mob/user)
	. = ..()
	Bumped(user)

/obj/structure/multiz/stairs/active/bottom
	icon_state = "rampdark"
	istop = FALSE


/obj/effect/spawner/maintshroom
	name = "maintshroom spawner"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	var/instant = TRUE
	var/min_light_limit = 0.5
	mouse_opacity = 0
	rarity_value = 10
	spawn_tags = SPAWN_TAG_FLORA
	bad_type = /obj/effect/spawner/maintshroom


/obj/effect/spawner/maintshroom/proc/spawn_shroom()
	// Skip the spawning if the burrow is in a well lit places.
	var/turf/T = get_turf(src)
	if(T.get_lumcount() > min_light_limit)
		return

	new /obj/effect/plant(get_turf(src), new /datum/seed/mushroom/maintshroom)
	find_or_create_burrow(get_turf(src))


/obj/effect/spawner/maintshroom/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/spawner/maintshroom/LateInitialize() // have to LI due to race condition
	. = ..()
	if (instant)
		spawn_shroom()
	qdel(src)

//New maintshroom spawner
//Delay on spawning. The object may wait up to 2 hours before spawning the shrooms
/obj/effect/spawner/maintshroom/delayed
	name = "maintshroom spawner delayed"
	var/delaymax = 3 HOURS
	instant = FALSE

/obj/effect/spawner/maintshroom/delayed/LateInitialize()
	//We spawn a burrow immediately, but the plants come later
	find_or_create_burrow(get_turf(src))

	//Lets decide how long to wait
	var/delay = RAND_DECIMAL(1, delaymax)

	addtimer(CALLBACK(src, .proc/spawn_shroom), delay)
	alpha = 0 //Make it invisible
	. = ..()

/obj/effect/spawner/maintshroom/delayed/spawn_shroom()
	//If all the burrows in the area were destroyed before we spawned, then our spawning is cancelled
	var/obj/structure/burrow/B = find_visible_burrow(src)
	if (!B)
		return

	// Skip the spawning if the burrow is in a well lit places.
	var/turf/T = get_turf(B)
	if(T.get_lumcount() > min_light_limit)
		return

	new /obj/effect/plant(get_turf(B), new /datum/seed/mushroom/maintshroom)

	qdel(src)

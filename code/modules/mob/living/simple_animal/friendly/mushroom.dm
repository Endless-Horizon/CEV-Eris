/mob/living/simple_animal/mushroom
	name = "walking mushroom"
	desc = "It's a massive mushroom... with legs?"
	icon_state = "mushroom"
	mob_size = MOB_SMALL
	speak_chance = 0
	turns_per_move = 1
	maxHealth = 5
	health = 5
	meat_type = /obj/item/reagent_containers/food/snacks/hugemushroomslice
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "whacks"
	harm_intent_damage = 5
	var/datum/seed/seed
	var/harvest_time
	var/min_explode_time = 1200
	can_burrow = TRUE

/mob/living/simple_animal/mushroom/New()
	..()
	harvest_time = world.time

/mob/living/simple_animal/mushroom/verb/spawn_spores()

	set name = "Explode"
	set category = "Abilities"
	set desc = "Spread your spores!"
	set src = usr

	if(stat == 2)
		to_chat(usr, SPAN_DANGER("You are dead; it is too late for that."))
		return

	if(!seed)
		to_chat(usr, SPAN_DANGER("You are sterile!"))
		return

	if(world.time < harvest_time + min_explode_time)
		to_chat(usr, SPAN_DANGER("You are not mature enough for that."))
		return

	spore_explode()

/mob/living/simple_animal/mushroom/death()
	if(prob(30))
		spore_explode()
		return
	..()

/mob/living/simple_animal/mushroom/proc/spore_explode()
	if(!seed)
		return
	if(world.time < harvest_time + min_explode_time)
		return
	for(var/turf/simulated/target_turf in orange(1,src))
		if(prob(60) && !target_turf.density && src.Adjacent(target_turf))
			new /obj/machinery/portable_atmospherics/hydroponics/soil/invisible(target_turf,seed)
	seed.thrown_at(src,get_turf(src),1)
	if(src)
		gib()

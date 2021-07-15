/obj/spawner/rations
	name = "random preserved rations"
	icon_state = "food-green"
	tags_to_spawn = list(SPAWN_RATIONS)

/obj/spawner/rations/low_chance
	name = "low chance preserved rations"
	icon_state = "food-green-low"
	spawn_nothing_percentage = 70


/obj/spawner/junkfood
	name = "random junkfood"
	icon_state = "food-red"
	has_postspawn = FALSE
	tags_to_spawn = list(SPAWN_JUNKFOOD)

/obj/spawner/junkfood/low_chance
	name = "low chance junkfood"
	icon_state = "food-red-low"
	spawn_nothing_percentage = 70

/obj/spawner/junkfood/rotten
	name = "random spoiled food"
	icon_state = "food-red"
	has_postspawn = TRUE

/obj/spawner/junkfood/rotten/low_chance
	name = "low chance spoiled food"
	icon_state = "food-red-low"
	spawn_nothing_percentage = 60

/obj/spawner/junkfood/rotten/post_spawn(list/spawns)
	for(var/obj/item/reagent_containers/food in spawns)
		if(!food.reagents)
			return
		var/list/random_reagent_list = list(
			list("hydrazine" = 20) = 2,
			list("lithium" = 20) = 2,
			list("carbon" = 20) = 2,
			list("ammonia" = 20) = 2,
			list("acetone" = 20) = 2,
			list("sodium" = 20) = 2,
			list("aluminum" = 20) = 2,
			list("silicon" = 20) = 2,
			list("phosphorus" = 20) = 2,
			list("sulfur" = 20) = 2,
			list("hclacid" = 20) = 2,
			list("potassium" = 20) = 2,
			list("iron" = 20) = 2,
			list("copper" = 20) = 2,
			list("mercury" = 20) = 2,
			list("radium" = 20) = 2,
			list("water" = 20) = 2,
			list("ethanol" = 20) = 2,
			list("sugar" = 20) = 2,
			list("sacid" = 20) = 2,
			list("tungsten" = 20) = 2,
			list("vomitol" = 20) = 10)
		var/list/picked_reagents = pickweight(random_reagent_list)
		for(var/reagent in picked_reagents)
			food.reagents.add_reagent(reagent, picked_reagents[reagent])
		if(prob(50)) // So sometimes the rot is visible.
			food.make_old()
	return spawns

/obj/spawner/pizza
	name = "random pizza"
	icon_state = "food-red"
	tags_to_spawn = list(SPAWN_PIZZA)

/obj/spawner/pizza/low_chance
	name = "low chance pizza"
	icon_state = "food-red-low"
	spawn_nothing_percentage = 60

/obj/spawner/soda
	name = "random soda"
	icon_state = "food-red"
	tags_to_spawn = list(SPAWN_DRINK_SODA)

/obj/spawner/soda/low_chance
	name = "low chance soda"
	icon_state = "food-red-low"
	spawn_nothing_percentage = 60

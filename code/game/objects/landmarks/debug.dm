/obj/landmark/debug
	delete_me = TRUE

/obj/landmark/debug/all_reagents/New()
	for(var/id in GLOB.chemical_reagents_list)
		var/datum/reagent/R = GLOB.chemical_reagents_list[id]
		var/obj/item/reagent_containers/glass/beaker/large/B = new /obj/item/reagent_containers/glass/beaker/large(src.loc)
		B.name = R.name
		B.reagents.add_reagent(id, B.volume, null, TRUE)

/obj/landmark/debug/all_containers/New()
	for(var/type in typesof(/obj/item/reagent_containers) - typesof(/obj/item/reagent_containers/food))
		new type(src.loc)

/obj/landmark/debug/all_food/New()
	for(var/type in typesof(/obj/item/reagent_containers/food))
		new type(src.loc)

/obj/landmark/debug/all_closets/New()
	for(var/type in typesof(/obj/structure/closet))
		new type(src.loc)
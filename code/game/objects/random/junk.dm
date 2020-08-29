//Broken items, or stuff that could be picked up
/obj/spawner/junk
	name = "random junk"
	icon_state = "junk-black"
	tags_to_spawn = list(SPAWN_JUNK, SPAWN_MATERIAL_BUILDING_ROD, SPAWN_CLEANABLE, SPAWN_REMAINS)

/obj/spawner/junk/nondense
	tags_to_spawn = list(SPAWN_JUNK, SPAWN_MATERIAL_BUILDING_ROD, SPAWN_CLEANABLE)

/obj/spawner/junk/post_spawn(list/stuff)
	for (var/atom/thing in stuff)
		if (prob(30))
			thing.make_old()

/obj/spawner/junk/low_chance
	name = "low chance random junk"
	icon_state = "junk-black-low"
	spawn_nothing_percentage = 60

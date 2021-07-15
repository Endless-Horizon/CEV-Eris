
/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox0"
	name = "ore box"
	desc = "A heavy box used for storing ore."
	density = TRUE
	rarity_value = 10
	spawn_tags = SPAWN_TAG_STRUCTURE_COMMON
	var/last_update = 0
	var/list/stored_ore = list()

/obj/structure/ore_box/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/ore))
		user.remove_from_mob(W)
		src.contents += W
	if (istype(W, /obj/item/storage))
		var/obj/item/storage/S = W
		S.hide_from(usr)
		if (locate(/obj/item/ore) in S.contents)
			for(var/obj/item/ore/O in S.contents)
				S.remove_from_storage(O, src) //This will move the item to this item's contents
			playsound(loc, S.use_sound, 50, 1, -5)
			user.visible_message(SPAN_NOTICE("[user.name] empties the [S] into the box"), SPAN_NOTICE("You empty the [S] into the box."), SPAN_NOTICE("You hear a rustling sound"))
		else
			to_chat(user, SPAN_WARNING("There's no ore inside the [S] to empty into here"))
	update_ore_count()

	return

/obj/structure/ore_box/proc/update_ore_count()

	stored_ore = list()

	for(var/obj/item/ore/O in contents)

		if(stored_ore[O.name])
			stored_ore[O.name]++
		else
			stored_ore[O.name] = 1

/obj/structure/ore_box/examine(mob/user)
	to_chat(user, "That's an [src].")
	to_chat(user, desc)

	// Borgs can now check contents too.
	if((!ishuman(user)) && (!isrobot(user)))
		return

	if(!Adjacent(user)) //Can only check the contents of ore boxes if you can physically reach them.
		return

	add_fingerprint(user)

	if(!contents.len)
		to_chat(user, "It is empty.")
		return

	if(world.time > last_update + 10)
		update_ore_count()
		last_update = world.time

	to_chat(user, "It holds:")
	for(var/ore in stored_ore)
		to_chat(user, "- [stored_ore[ore]] [ore]")
	return


/obj/structure/ore_box/verb/empty_box()
	set name = "Empty Ore Box"
	set category = "Object"
	set src in view(1)

	if(!ishuman(usr)) //Only living, intelligent creatures with hands can empty ore boxes.
		to_chat(usr, "\red You are physically incapable of emptying the ore box.")
		return

	if( usr.stat || usr.restrained() )
		return

	if(!Adjacent(usr)) //You can only empty the box if you can physically reach it
		to_chat(usr, "You cannot reach the ore box.")
		return

	add_fingerprint(usr)

	if(contents.len < 1)
		to_chat(usr, "\red The ore box is empty")
		return

	for (var/obj/item/ore/O in contents)
		contents -= O
		O.loc = src.loc
	to_chat(usr, "\blue You empty the ore box")

	return

/obj/structure/ore_box/ex_act(severity)
	if(severity == 1 || (severity < 3 && prob(50)))
		for (var/obj/item/ore/O in contents)
			O.loc = src.loc
			O.ex_act(severity++)
		qdel(src)
		return

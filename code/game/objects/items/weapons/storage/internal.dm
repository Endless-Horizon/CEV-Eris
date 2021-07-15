//A storage item intended to be used by other items to provide storage functionality.
//Types that use this should consider overriding emp_act() and hear_talk(), unless they shield their contents somehow.
/obj/item/storage/internal
	var/obj/item/master_item
	spawn_tags = null

/obj/item/storage/internal/New(obj/item/MI)
	master_item = MI
	loc = master_item
	name = master_item.name
	verbs -= /obj/item/verb/verb_pickup	//make sure this is never picked up.
	..()

/obj/item/storage/internal/Destroy()
	master_item = null
	. = ..()

/obj/item/storage/internal/attack_hand()
	return		//make sure this is never picked up

/obj/item/storage/internal/can_be_equipped()
	return 0	//make sure this is never picked up

//Helper procs to cleanly implement internal storages - storage items that provide inventory slots for other items.
//These procs are completely optional, it is up to the master item to decide when it's storage get's opened by calling open()
//However they are helpful for allowing the master item to pretend it is a storage item itself.
//If you are using these you will probably want to override attackby() as well.
//See /obj/item/clothing/suit/storage for an example.

//items that use internal storage have the option of calling this to emulate default storage MouseDrop behaviour.
//returns TRUE if the master item's parent's MouseDrop() shouldn't be called, FALSE otherwise.
/obj/item/storage/internal/proc/handle_mousedrop(mob/living/carbon/human/user, obj/over_object)

	if (istype(user))
		if (user.incapacitated())
			return FALSE

		if(over_object == user && Adjacent(user))
			src.open(user)
			return TRUE

//items that use internal storage have the option of calling this to emulate default storage attack_hand behaviour.
//returns 1 if the master item's parent's attack_hand() should be called, 0 otherwise.
//It's strange, but no other way of doing it without the ability to call another proc's parent, really.
/obj/item/storage/internal/proc/handle_attack_hand(mob/user as mob)
	if (openable_location(user))
		src.open(user)
		return 0

	close_all()
	return 1

/obj/item/storage/internal/Adjacent(var/atom/neighbor)
	return master_item.Adjacent(neighbor)

//Returns true if the thing is in a suitable location
//If its worn and not in a pocket, its suitable
//If its on a turf next to the user, its also suitable
/obj/item/storage/internal/proc/openable_location(var/mob/user)
	.=FALSE
	if (master_item.loc == user)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.l_store == master_item)	//Prevents opening if it's in a pocket.
				return
			if(H.r_store == master_item)
				return
		return TRUE
	else if (isturf(master_item.loc) && Adjacent(user))
		return TRUE

/obj/item/storage/internal/updating/on_update_icon()
	if(master_item)
		master_item.update_icon()


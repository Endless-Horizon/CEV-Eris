//Allows for a dynamic cursor, simulating accuracy. If you want to resprite this, go ahead.

/obj/item/gun/equipped(mob/living/H)
	. = ..()
	if(is_held() && !safety)
		H.update_cursor()
	else
		H.remove_cursor()

/obj/item/gun/proc/cursor_check()
	if(ismob(loc))
		var/mob/living/carbon/H = loc
		var/obj/item/gun/thegun = H.get_active_hand()
		if(istype(thegun) && thegun == src && !thegun.safety)
			H.update_cursor()
		else
			H.remove_cursor()

/obj/item/gun/swapped_from()
	if(ismob(loc))
		cursor_check()

/obj/item/gun/swapped_to()
	if(ismob(loc))
		cursor_check()

/obj/item/gun/afterattack(obj/target, mob/living/user, flag)
	. = ..()
	if(!is_held())
		user.remove_cursor()

/obj/item/gun/try_uneqip(target, mob/living/user)
	. = ..()
	user.remove_cursor()

/obj/item/gun/dropped(mob/living/user)
	user.remove_cursor()
	. = ..()

/obj/item/gun/afterattack(atom/A, mob/living/user, adjacent, params)
	if(safety)
		user.remove_cursor()
	else
		user.update_cursor()
	. = ..()

/obj/item/gun/Destroy()
	if(ismob(loc))
		var/mob/living/L = loc
		L.remove_cursor()
	. = ..()
/obj/item/implantpad
	name = "implant pad"
	desc = "Used to modify implants."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantpad-0"
	item_state = "electronic"
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	var/obj/item/implantcase/case = null


/obj/item/implantpad/on_update_icon()
	icon_state = case ? "implantpad-1" : "implantpad-0"

/obj/item/implantpad/attack_hand(mob/living/user)
	if ((src.case && (user.l_hand == src || user.r_hand == src)))
		user.put_in_active_hand(case)
		case = null

		add_fingerprint(user)
		update_icon()
	else
		return ..()
	return


/obj/item/implantpad/attackby(obj/item/implantcase/C, mob/living/user)
	..()
	if(istype(C, /obj/item/implantcase))
		if(!case)
			user.drop_item()
			C.forceMove(src)
			case = C
			update_icon()
	return


/obj/item/implantpad/attack_self(mob/living/user)
	user.set_machine(src)
	var/dat = "<B>Implant Mini-Computer:</B><HR>"
	if(case)
		if(case.implant)
			dat += case.implant.get_data()
		else
			dat += "The implant casing is empty."
	else
		dat += "Please insert an implant casing!"
	user << browse(dat, "window=implantpad")
	onclose(user, "implantpad")
	return


/obj/item/implantpad/Topic(href, href_list)
	..()
	if (usr.stat)
		return
	if ((usr.contents.Find(src)) || ((in_range(src, usr) && istype(src.loc, /turf))))
		usr.set_machine(src)
		if (ismob(loc))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=implantpad")
		return
	return

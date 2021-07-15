/obj/structure/extinguisher_cabinet
	name = "extinguisher cabinet"
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher."
	icon = 'icons/obj/closet.dmi'
	icon_state = "extinguisher_closed"
	anchored = TRUE
	density = FALSE
	var/obj/item/extinguisher/has_extinguisher
	var/opened = 0

/obj/structure/extinguisher_cabinet/New()
	..()
	has_extinguisher = new/obj/item/extinguisher(src)
	update_icon()

/obj/structure/extinguisher_cabinet/attackby(obj/item/O, mob/user)
	if(isrobot(user))
		return
	if(istype(O, /obj/item/extinguisher))
		if(!has_extinguisher && opened)
			user.remove_from_mob(O)
			contents += O
			has_extinguisher = O
			to_chat(user, SPAN_NOTICE("You place [O] in [src]."))
			playsound(src.loc, 'sound/machines/Custom_extin.ogg', 50, 0)
		else
			opened = !opened
	else
		opened = !opened
	update_icon()


/obj/structure/extinguisher_cabinet/attack_hand(mob/user)
	if(isrobot(user))
		return
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.organs_by_name[BP_R_ARM]
		if (user.hand)
			temp = H.organs_by_name[BP_L_ARM]
		if(temp && !temp.is_usable())
			to_chat(user, SPAN_NOTICE("You try to move your [temp.name], but cannot!"))
			return
	if(has_extinguisher)
		user.put_in_hands(has_extinguisher)
		to_chat(user, SPAN_NOTICE("You take [has_extinguisher] from [src]."))
		playsound(src.loc, 'sound/machines/Custom_extout.ogg', 50, 0)
		has_extinguisher = null
		opened = 1
	else
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/proc/toggle_open(mob/user)
	if(isrobot(user))
		return
	if(user.incapacitated())
		to_chat(user, SPAN_WARNING("You can't do that right now!"))
		return
	if(!in_range(src, user))
		return
	else
		playsound(src.loc, 'sound/machines/Custom_extin.ogg', 50, 0)
		opened = !opened
		update_icon()

/obj/structure/extinguisher_cabinet/AltClick(mob/living/user)
	src.toggle_open(user)

/obj/structure/extinguisher_cabinet/verb/toggle(mob/living/usr)
	set name = "Open/Close"
	set category = "Object"
	set src in oview(1)
	src.toggle_open(usr)

/obj/structure/extinguisher_cabinet/attack_tk(mob/user)
	if(has_extinguisher)
		has_extinguisher.loc = loc
		to_chat(user, SPAN_NOTICE("You telekinetically remove [has_extinguisher] from [src]."))
		has_extinguisher = null
		opened = 1
	else
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/on_update_icon()
	if(!opened)
		if(istype(has_extinguisher, /obj/item/extinguisher/mini))
			icon_state = "extinguisher_closed_mini"
		else if(istype(has_extinguisher, /obj/item/extinguisher))
			icon_state = "extinguisher_closed_full"
		else
			icon_state = "extinguisher_closed"
		return
	if(has_extinguisher)
		if(istype(has_extinguisher, /obj/item/extinguisher/mini))
			icon_state = "extinguisher_mini"
		else
			icon_state = "extinguisher_full"
	else
		icon_state = "extinguisher_empty"

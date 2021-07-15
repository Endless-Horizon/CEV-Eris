/obj/item/storage/belt/sheath
	name = "sheath"
	desc = "Made to store sword."
	icon = 'icons/obj/sheath.dmi'
	icon_state = "sheath_0"
	item_state = "sheath_0"
	slot_flags = SLOT_BELT
	price_tag = 50
	matter = list(MATERIAL_BIOMATTER = 5)
	spawn_frequency = 0
	storage_slots = 1
	w_class = ITEM_SIZE_NORMAL
	max_w_class = ITEM_SIZE_HUGE

	can_hold = list(
		/obj/item/tool/sword/nt,
		/obj/item/tool/sword/nt_sword,
		/obj/item/tool/sword/saber
		)
	cant_hold = list(
		/obj/item/tool/knife/dagger/nt,
		/obj/item/tool/sword/nt/halberd
		)
/obj/item/storage/belt/sheath/attack_hand(mob/living/carbon/human/user)
	if(contents.len && (src in user))
		var/obj/item/I = contents[contents.len]
		if(istype(I))
			hide_from(usr)
			var/turf/T = get_turf(user)
			remove_from_storage(I, T)
			usr.put_in_hands(I)
			add_fingerprint(user)
	else
		..()

/obj/item/storage/belt/sheath/on_update_icon()
	var/icon_to_set
	for(var/obj/item/tool/sword/SW in contents)
		icon_to_set = SW.icon_state
	icon_state = "sheath_[contents.len ? icon_to_set :"0"]"
	item_state = "sheath_[contents.len ? icon_to_set :"0"]"
	..()

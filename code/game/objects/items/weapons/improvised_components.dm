
/obj/item/material/butterflyblade
	name = "knife blade"
	desc = "A knife blade. Unusable as a weapon without a grip."
	icon = 'icons/obj/buildingobject.dmi'
	icon_state = "butterfly2"
	force_divisor = 0.1
	thrown_force_divisor = 0.1
	rarity_value = 16.66
	spawn_tags = SPAWN_ITEM_CONTRABAND

/obj/item/material/butterflyhandle
	name = "concealed knife grip"
	desc = "A plasteel grip with screw fittings for a blade."
	icon = 'icons/obj/buildingobject.dmi'
	icon_state = "butterfly1"
	force_divisor = 0.1
	thrown_force_divisor = 0.1
	rarity_value = 16.66
	spawn_tags = SPAWN_ITEM_CONTRABAND

/obj/item/material/wirerod
	name = "wired rod"
	desc = "A rod with some wire wrapped around the top. It'd be easy to attach something to the top bit."
	icon_state = "wiredrod"
	item_state = "rods"
	flags = CONDUCT
	force = WEAPON_FORCE_PAINFUL
	throwforce = WEAPON_FORCE_NORMAL
	w_class = ITEM_SIZE_NORMAL
	attack_verb = list("hit", "bludgeoned", "whacked", "bonked")
	force_divisor = 0.1
	thrown_force_divisor = 0.1
	rarity_value = 16.66
	spawn_tags = SPAWN_ITEM_CONTRABAND

/obj/item/material/wirerod/attackby(var/obj/item/I, mob/user)
	..()
	var/obj/item/finished
	if((QUALITY_CUTTING in I.tool_qualities) || (QUALITY_WIRE_CUTTING in I.tool_qualities))
		finished = new /obj/item/melee/baton/cattleprod(get_turf(user))
		to_chat(user, SPAN_NOTICE("You fasten the wirecutters to the top of the rod with the cable, prongs outward."))
	if(finished)
		user.drop_from_inventory(src)
		user.drop_from_inventory(I)
		qdel(I)
		qdel(src)
		user.put_in_hands(finished)
	update_icon(user)

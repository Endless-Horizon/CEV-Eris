//Talk crystal

/obj/item/talkingcrystal

	name = "Crystal"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "talk_crystal"
	spawn_tags = SPAWN_TAG_XENOARCH_ITEM
	spawn_blacklisted = TRUE

/obj/item/talkingcrystal/Initialize(mapload)
	. = ..()
	src.talking_atom = new (src)
	if(prob(50))
		icon_state = "talk_crystal2"

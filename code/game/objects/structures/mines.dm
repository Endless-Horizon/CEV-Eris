/obj/structure/mine
	name = "Excelsior Mine"
	desc = "It looks like ancient, and rather dangerous mine."
	icon = 'icons/obj/machines/excelsior/objects.dmi'
	icon_state = "mine"
	rarity_value = 10
	spawn_frequency = 10
	spawn_tags = SPAWN_TAG_MINE_STUCTURE
	bad_type = /obj/structure/mine

/obj/structure/mine/mine_no_primer/attack_hand(mob/living/user as mob)
	if(do_after(user,10,src))
		visible_message(SPAN_WARNING("Mine deactivated"))
		new /obj/item/plastique(src.loc)
		qdel(src)

/obj/structure/mine/mine_scraps/attack_hand(mob/living/user as mob)
	if(do_after(user,10,src))
		visible_message(SPAN_WARNING("Mine fell apart into pieces of metal"))
		new /obj/item/stack/material/steel/random(src.loc)
		qdel(src)
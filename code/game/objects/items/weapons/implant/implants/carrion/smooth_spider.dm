/obj/item/implant/carrion_spider/smooth
	name = "smooth spider"
	desc = "Small spider filled with some sort of strange fluid. This one has a menacing aura."
	icon_state = "spiderling_smooth"
	spider_price = 10
	var/not_playing = TRUE

/obj/item/implant/carrion_spider/smooth/activate()
	..()
	if(not_playing)
		playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
		not_playing = FALSE
		spawn(5)
			not_playing = TRUE

/obj/item/implant/carrion_spider/smooth/Crossed(AM as mob|obj)
	if (isliving(AM))
		var/mob/living/M = AM
		if((locate(/obj/structure/multiz/stairs) in get_turf(loc)) || (locate(/obj/structure/multiz/ladder) in get_turf(loc)))
			visible_message(SPAN_DANGER("\The [M] carefully avoids stepping down on \the [src]."))
			return
		M.slip("the [src.name]",3)
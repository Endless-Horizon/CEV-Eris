/obj/item/implant/carrion_spider/flashbang
	name = "flashbang spider"
	desc = "A spider filled with some sort of glossy liquid, it emits a constant unpleasant noise."
	icon_state = "spiderling_flashbang"
	spider_price = 15
	var/det_time = 2 SECONDS

/obj/item/implant/carrion_spider/flashbang/activate()
	..()
	if(wearer)
		wearer.apply_damage(15, BURN, part)
		src.uninstall()
		to_chat(wearer, SPAN_WARNING("You feel an uncomfortable heat build up within [part]!"))
		visible_message(SPAN_DANGER("[src] crawls out of [wearer] and flashes brightly!"))
	else
		visible_message(SPAN_DANGER("[src] flashes brightly!"))
	playsound(src, 'sound/voice/insect_battle_screeching.ogg', 80, 1, 5)
	src.set_light(3,3, COLOR_YELLOW)
	spawn(det_time)
		src?.prime()

/obj/item/implant/carrion_spider/flashbang/proc/prime()
	for(var/obj/structure/closet/L in view(7, get_turf(src)))
		if(locate(/mob/living/carbon/, L))
			for(var/mob/living/carbon/M in L)
				flashbang_bang(get_turf(src), M)

	for(var/mob/living/carbon/M in view(7, get_turf(src)))
		flashbang_bang(get_turf(src), M)

	new/obj/effect/sparks(get_turf(src))
	new/obj/effect/effect/smoke/illumination(get_turf(src), brightness=15)
	die()

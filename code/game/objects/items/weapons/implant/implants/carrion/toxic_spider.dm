/obj/item/implant/carrion_spider/toxicbomb
	name = "toxic haze spider"
	desc = "A spider bloated with noxious gasses, it looks ready to burst!"
	icon_state = "spiderling_toxicbomb"
	spider_price = 35
	var/datum/reagents/gas_storage
	var/det_time = 2 SECONDS

/obj/item/implant/carrion_spider/toxicbomb/activate()
	..()
	if(wearer)
		wearer.apply_damage(10, BRUTE, part)
		src.uninstall()
		to_chat(wearer, SPAN_WARNING("You feel something moving within [part]!"))
		visible_message(SPAN_DANGER("[src] crawls out of [wearer] and flashes brightly!"))
	else
		visible_message(SPAN_DANGER("[src] flashes brightly!"))
	playsound(src, 'sound/voice/insect_battle_screeching.ogg', 80, 1, 5)
	src.set_light(3,3, COLOR_GREEN)
	spawn(det_time)
		src?.prime()

/obj/item/implant/carrion_spider/toxicbomb/proc/prime()
	var/location = get_turf(src)
	gas_storage = new /datum/reagents(100, src)
	gas_storage.add_reagent("lexorin", 100)
	var/datum/effect/effect/system/smoke_spread/chem/S = new
	S.attach(location)
	S.set_up(gas_storage, 10, 100, location)
	S.start()
	die()

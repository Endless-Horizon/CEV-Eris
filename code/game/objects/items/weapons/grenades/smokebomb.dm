/obj/item/grenade/smokebomb
	name = "FS SG \"Reynolds\""
	desc = "Smoke grenade, used to create a cloud of smoke providing cover and hiding movement."
	det_time = 20
	var/datum/effect/effect/system/smoke_spread/bad/smoke

/obj/item/grenade/smokebomb/New()
	..()
	smoke = new
	smoke.attach(src)

/obj/item/grenade/smokebomb/Destroy()
	qdel(smoke)
	smoke = null
	return ..()

/obj/item/grenade/smokebomb/prime()
	playsound(loc, 'sound/effects/smoke.ogg', 50, 1, -3)
	smoke.set_up(10, 0, usr.loc)
	spawn(0)
		smoke.start()
		sleep(10)
		smoke.start()
		sleep(10)
		smoke.start()
		sleep(10)
		smoke.start()

	for(var/obj/effect/blob/B in view(8,src))
		var/damage = round(30/(get_dist(B,src)+1))
		B.health -= damage
		B.update_icon()
	sleep(80)
	icon_state = initial(icon_state) + "_off"
	desc = "[initial(desc)] It has already been used."
	return

/obj/item/grenade/smokebomb/nt
	name = "NT SG \"Holy Fog\""
	desc = "Smoke grenade, used to create a cloud of smoke providing cover and hiding movement."
	icon_state = "smokegrenade_nt"
	item_state = "smokegrenade_nt"
	matter = list(MATERIAL_BIOMATTER = 10)

/obj/item/device/assembly/igniter
	name = "igniter"
	desc = "A small electronic device able to ignite combustable substances."
	icon_state = "igniter"
	origin_tech = list(TECH_MAGNET = 1)
	matter = list(MATERIAL_PLASTIC = 1)
	secured = TRUE
	wires = WIRE_RECEIVE

/obj/item/device/assembly/igniter/activate()
	if(!..()) //Cooldown check
		return

	if(holder && istype(holder.loc, /obj/item/grenade/chem_grenade))
		var/obj/item/grenade/chem_grenade/grenade = holder.loc
		grenade.prime()
	else
		var/turf/location = get_turf(loc)
		if(location)
			location.hotspot_expose(1000,1000)
		if(istype(src.loc, /obj/item/device/assembly_holder))
			if(src.loc.loc)
				var/atom/A = src.loc.loc
				A.ignite_act()

		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()


/obj/item/device/assembly/igniter/attack_self(mob/user as mob)
	activate()
	add_fingerprint(user)

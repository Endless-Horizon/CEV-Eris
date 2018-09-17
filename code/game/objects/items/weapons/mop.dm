/obj/item/weapon/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	force = WEAPON_FORCE_NORMAL
	throwforce = WEAPON_FORCE_NORMAL
	throw_speed = 5
	throw_range = 10
	w_class = ITEM_SIZE_NORMAL
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked")
	matter = list(MATERIAL_PLASTIC = 3)
	var/mopping = 0
	var/mopcount = 0
	//check is too bulky, so here a list. Just add stuff here
	var/get_wet_containers = list(/obj/item/weapon/reagent_containers/glass/bucket,
								/obj/structure/bed/chair/janicart,
								/obj/structure/mopbucket,
								/obj/structure/sink,
								/obj/structure/janitorialcart)



/obj/item/weapon/mop/New()
	create_reagents(30)

/obj/item/weapon/mop/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return
	if(istype(A, /turf) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay))
		if(reagents.total_volume < 1)
			user << SPAN_NOTICE("Your mop is dry!")
			return
		var/turf/T = get_turf(A)
		if(!T)
			return

		user.visible_message(SPAN_WARNING("[user] begins to clean \the [T]."))

		if(do_after(user, 40, T))
			if(T)
				T.clean(src, user)
			user << SPAN_NOTICE("You have finished mopping!")
	else
		makeWet(A, user)


/obj/item/weapon/mop/proc/makeWet(atom/A, mob/user)
	for(var/container in get_wet_containers)
		if(istype(A, container))
			if(A.reagents)
				if(!A.is_open_container())
					user << SPAN_WARNING("\The [A] is closed!")
					return
				if(A.reagents.total_volume < 1)
					user << SPAN_WARNING("\The [A] is out of water!")
					return
				A.reagents.trans_to_obj(src, reagents.maximum_volume)
			else
				reagents.add_reagent("water", reagents.maximum_volume)

			user << SPAN_NOTICE("You wet \the [src] in \the [A].")
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
			break



/obj/effect/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/mop) || istype(I, /obj/item/weapon/soap))
		return
	..()
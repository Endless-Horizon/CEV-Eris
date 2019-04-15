//Contains the rapid construction device.
/obj/item/weapon/rcd
	name = "rapid construction device"
	desc = "A device used to rapidly build walls and floors."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	flags = CONDUCT
	force = WEAPON_FORCE_PAINFUL
	throwforce = WEAPON_FORCE_PAINFUL
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 2)
	matter = list(MATERIAL_PLASTEEL = 15, MATERIAL_PLASMA = 10, MATERIAL_URANIUM = 10)
	price_tag = 2000
	var/datum/effect/effect/system/spark_spread/spark_system
	var/stored_matter = 0
	var/working = 0
	var/mode = 1
	var/list/modes = list("Floor & Walls","Airlock","Deconstruct")
	var/canRwall = 1
	var/disabled = 0

/obj/item/weapon/rcd/attack()
	return 0

/obj/item/weapon/rcd/proc/can_use(var/mob/user,var/turf/T)
	return (user.Adjacent(T) && user.get_active_hand() == src && !user.stat && !user.restrained())

/obj/item/weapon/rcd/examine()
	..()
	if(src.type == /obj/item/weapon/rcd && loc == usr)
		usr << "It currently holds [stored_matter]/30 matter-units."

/obj/item/weapon/rcd/New()
	..()
	src.spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	update_icon()	//Initializes the fancy ammo counter

/obj/item/weapon/rcd/Destroy()
	qdel(spark_system)
	spark_system = null
	return ..()

/obj/item/weapon/rcd/attackby(obj/item/weapon/W, mob/user)

	if(istype(W, /obj/item/weapon/rcd_ammo))
		if((stored_matter + 10) > 30)
			user << SPAN_NOTICE("The RCD can't hold any more matter-units.")
			return
		user.drop_from_inventory(W)
		qdel(W)
		stored_matter += 10
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		user << SPAN_NOTICE("The RCD now holds [stored_matter]/30 matter-units.")
		update_icon()	//Updates the ammo counter
		return
	..()

/obj/item/weapon/rcd/attack_self(mob/user)
	//Change the mode
	if(++mode > 3) mode = 1
	user << SPAN_NOTICE("Changed mode to '[modes[mode]]'")
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	if(prob(20)) src.spark_system.start()

/obj/item/weapon/rcd/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return
	if(disabled && !isrobot(user))
		return 0
	if(istype(get_area(A),/area/shuttle)||istype(get_area(A),/turf/space/transit))
		return 0
	return alter_turf(A,user,(mode == 3))

/obj/item/weapon/rcd/proc/useResource(var/amount, var/mob/user, var/checkOnly)
	if(stored_matter < amount)
		return 0
	if (!checkOnly)
		stored_matter -= amount
		update_icon()	//Updates the ammo counter if ammo is succesfully used
	return 1

/obj/item/weapon/rcd/proc/alter_turf(var/turf/T,var/mob/user,var/deconstruct)

	var/build_cost = 0
	var/build_type
	var/build_turf
	var/build_delay
	var/build_other

	if(working == 1)
		return 0

	if(mode == 3 && istype(T,/obj/machinery/door/airlock))
		build_cost =  10
		build_delay = 50
		build_type = "airlock"
	else if(mode == 2 && !deconstruct && istype(T,/turf/simulated/floor))
		build_cost =  10
		build_delay = 50
		build_type = "airlock"
		build_other = /obj/machinery/door/airlock
	else if(!deconstruct && (istype(T,/turf/space) || istype(T,get_base_turf(T.z))))
		build_cost =  1
		build_type =  "floor"
		build_turf =  /turf/simulated/floor/airless
	else if(deconstruct && istype(T,/turf/simulated/wall))
		var/turf/simulated/wall/W = T
		build_delay = deconstruct ? (W.reinf_material) ? 150 : 50 : 40
		build_cost =  (W.reinf_material) ? 10 : 5
		build_type =  (!canRwall && W.reinf_material) ? null : "wall"
		build_turf =  /turf/simulated/floor
	else if(istype(T,/turf/simulated/floor))
		build_delay = deconstruct ? 50 : 20
		build_cost =  deconstruct ? 10 : 3
		build_type =  deconstruct ? "floor" : "wall"
		build_turf =  deconstruct ? get_base_turf(T.z) : /turf/simulated/wall
	else
		return 0

	if(!build_type)
		working = 0
		return 0

	if(!useResource(build_cost, user, 1))
		user << "The \'Low Ammo\' light on the device blinks yellow."
		flick("[icon_state]-empty", src)
		return 0

	playsound(src.loc, 'sound/machines/click.ogg', 50, 1)

	working = 1
	user << "[(deconstruct ? "Deconstructing" : "Building")] [build_type]..."

	if(build_delay && !do_after(user, build_delay, src))
		working = 0
		return 0

	working = 0
	if(build_delay && !can_use(user,T))
		return 0

	if(!useResource(build_cost, user))
		user << "The \'Low Ammo\' light on the device blinks yellow."
		flick("[icon_state]-empty", src)
		return 0

	if(build_turf)
		T.ChangeTurf(build_turf)
	else if(build_other)
		new build_other(T)
	else
		qdel(T)

	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	return 1

/obj/item/weapon/rcd/update_icon()	//For the fancy "ammo" counter
	overlays.Cut()

	var/ratio = 0
	ratio = stored_matter / 30	//30 is the hardcoded max capacity of the RCD
	ratio = max(round(ratio, 0.10) * 100, 10)

	overlays += "[icon_state]-[ratio]"

/obj/item/weapon/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_MATERIAL = 2)
	matter = list(MATERIAL_STEEL = 30, MATERIAL_PLASTIC = 10, MATERIAL_SILVER = 2)
	price_tag = 300

/obj/item/weapon/rcd/borg
	canRwall = 1

/obj/item/weapon/rcd/borg/useResource(var/amount, var/mob/user, var/checkOnly)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(R.cell)
			var/cost = amount*30
			if(R.cell.charge >= cost)
				if (!checkOnly)
					R.cell.use(cost)
				return 1
	return 0

/obj/item/weapon/rcd/borg/attackby()
	return

/obj/item/weapon/rcd/borg/can_use(var/mob/user,var/turf/T)
	return (user.Adjacent(T) && !user.stat)


/obj/item/weapon/rcd/mounted/useResource(var/amount, var/mob/user, var/checkOnly)
	var/cost = amount*130 //so that a rig with default powercell can build ~2.5x the stuff a fully-loaded RCD can.
	if(istype(loc,/obj/item/rig_module))
		var/obj/item/rig_module/module = loc
		if(module.holder && module.holder.cell)
			if(module.holder.cell.charge >= cost)
				if (!checkOnly)
					module.holder.cell.use(cost)
				return 1
	return 0

/obj/item/weapon/rcd/mounted/attackby()
	return

/obj/item/weapon/rcd/mounted/can_use(var/mob/user,var/turf/T)
	return (user.Adjacent(T) && !user.stat && !user.restrained())

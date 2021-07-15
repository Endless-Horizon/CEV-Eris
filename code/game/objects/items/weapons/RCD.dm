//Contains the rapid construction device.
/obj/item/rcd
	name = "rapid construction device"
	desc = "A device used to rapidly build walls and floors."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	opacity = 0
	density = FALSE
	anchored = FALSE
	flags = CONDUCT
	force = WEAPON_FORCE_PAINFUL
	throwforce = WEAPON_FORCE_PAINFUL
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 2)
	matter = list(MATERIAL_PLASTEEL = 15, MATERIAL_PLASMA = 10, MATERIAL_URANIUM = 10)
	price_tag = 2000
	spawn_blacklisted = TRUE//antag_item_targets
	var/datum/effect/effect/system/spark_spread/spark_system
	var/stored_matter = 0
	var/working = 0
	var/mode = 1
	var/list/modes = list("Floor & Walls","Low wall", "Airlock","Deconstruct")
	var/canRwall = 1
	var/disabled = 0

/obj/item/rcd/attack()
	return 0

/obj/item/rcd/proc/can_use(var/mob/user,var/turf/T)
	return (user.Adjacent(T) && user.get_active_hand() == src && !user.stat && !user.restrained())

/obj/item/rcd/examine()
	..()
	if(src.type == /obj/item/rcd && loc == usr)
		to_chat(usr, "It currently holds [stored_matter]/30 matter-units.")

/obj/item/rcd/New()
	..()
	src.spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	update_icon()	//Initializes the fancy ammo counter

/obj/item/rcd/Destroy()
	qdel(spark_system)
	spark_system = null
	return ..()

/obj/item/rcd/attackby(obj/item/W, mob/user)

	if(istype(W, /obj/item/rcd_ammo))
		if((stored_matter + 10) > 30)
			to_chat(user, SPAN_NOTICE("The RCD can't hold any more matter-units."))
			return
		user.drop_from_inventory(W)
		qdel(W)
		stored_matter += 10
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, SPAN_NOTICE("The RCD now holds [stored_matter]/30 matter-units."))
		update_icon()	//Updates the ammo counter
		return
	..()

/obj/item/rcd/attack_self(mob/user)
	//Change the mode
	if(++mode > modes.len) mode = 1
	to_chat(user, SPAN_NOTICE("Changed mode to '[modes[mode]]'"))
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	if(prob(20)) src.spark_system.start()

/obj/item/rcd/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return
	if(disabled && !isrobot(user))
		return 0
	if(istype(get_area(A),/area/shuttle)||istype(get_area(A),/turf/space/transit))
		return 0
	return alter_turf(A,user)

/obj/item/rcd/proc/useResource(var/amount, var/mob/user, var/checkOnly)
	if(stored_matter < amount)
		return 0
	if (!checkOnly)
		stored_matter -= amount
		update_icon()	//Updates the ammo counter if ammo is succesfully used
	return 1

/obj/item/rcd/proc/alter_turf(var/T,var/mob/user)

	var/build_cost = 0
	var/build_type
	var/build_turf
	var/build_object
	var/build_delay

	if(working == 1)
		return 0
	var/turf/local_turf = T
	if(!T)
		local_turf = get_turf(T)
	var/gotFloor = istype(local_turf,/turf/simulated/floor)
	var/gotSpace = (istype(local_turf,/turf/space) || istype(local_turf,get_base_turf(local_turf.z)))
	var/gotBlocked = (istype(T, /obj/machinery/door/airlock) || istype(T, /obj/structure/low_wall))

	switch(mode)
		if(1)
			if(gotSpace)
				build_cost =  1
				build_type =  "floor"
				build_turf =  /turf/simulated/floor/airless
			if(gotFloor)
				build_delay = 40
				build_cost =  5
				build_type =  "wall"
				build_turf =  /turf/simulated/wall
		if(2)
			if(!gotBlocked)
				build_type = "low wall"
				build_object = /obj/structure/low_wall
				if(gotSpace)
					build_delay = 30
					build_cost = 6
					build_turf = /turf/simulated/floor/airless //there is always floor under low wall
				if(gotFloor)
					build_delay = 30
					build_cost =  5

		if(3)
			if(!gotBlocked)
				build_type = "airlock"
				build_object = /obj/machinery/door/airlock
				if(gotSpace)
					build_cost =  11
					build_delay = 50
					build_turf =  /turf/simulated/floor/airless
				if(gotFloor)
					build_cost =  10
					build_delay = 40

		if(4)
			build_type =  "deconstruct"
			if(gotFloor)
				build_cost =  10
				build_delay = 50
				build_turf = get_base_turf(local_turf.z)
			else if(istype(T,/obj/structure/low_wall))
				build_delay = 40
				build_cost =  5
			else if(istype(T,/turf/simulated/wall))
				var/turf/simulated/wall/W = T
				build_delay = 40
				build_cost =  (W.reinf_material) ? 10 : 5
				build_type =  (!canRwall && W.reinf_material) ? null : "deconstruct"
				build_turf =  /turf/simulated/floor
			else if(istype(T,/obj/machinery/door/airlock))
				build_cost =  10
				build_delay = 50
			else
				build_type =  ""

	if(!build_type)
		working = 0
		return 0

	if(!useResource(build_cost, user, 1))
		to_chat(user, "The \'Low Ammo\' light on the device blinks yellow.")
		FLICK("[icon_state]-empty", src)
		return 0

	playsound(src.loc, 'sound/machines/click.ogg', 50, 1)

	working = 1
	to_chat(user, "[(mode==modes.len ? "Deconstructing" : "Building [build_type]")]...")

	if(build_delay && !do_after(user, build_delay, src))
		working = 0
		return 0

	working = 0
	if(build_delay && !can_use(user,T))
		return 0

	if(!useResource(build_cost, user))
		to_chat(user, "The \'Low Ammo\' light on the device blinks yellow.")
		FLICK("[icon_state]-empty", src)
		return 0

	if(build_turf)
		local_turf.ChangeTurf(build_turf)
	if(build_object)
		new build_object(local_turf)

	if(build_type == "deconstruct")
		qdel(T)

	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	return 1

/obj/item/rcd/on_update_icon()	//For the fancy "ammo" counter
	cut_overlays()

	var/ratio = 0
	ratio = stored_matter / 30	//30 is the hardcoded max capacity of the RCD
	ratio = max(round(ratio, 0.10) * 100, 10)

	add_overlays("[icon_state]-[ratio]")

/obj/item/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_MATERIAL = 2)
	matter = list(MATERIAL_STEEL = 30, MATERIAL_PLASTIC = 10, MATERIAL_SILVER = 2)
	price_tag = 300

/obj/item/rcd/borg
	canRwall = 1
	spawn_tags = null

/obj/item/rcd/borg/useResource(var/amount, mob/user, var/checkOnly)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(R.cell)
			var/cost = amount*30
			if(R.cell.charge >= cost)
				if (!checkOnly)
					R.cell.use(cost)
				return 1
	return 0

/obj/item/rcd/borg/attackby()
	return

/obj/item/rcd/borg/can_use(var/mob/user,var/turf/T)
	return (user.Adjacent(T) && !user.stat)

/obj/item/rcd/mounted
	spawn_tags = null//mech item

/obj/item/rcd/mounted/useResource(var/amount, mob/user, var/checkOnly)
	var/cost = amount*130 //so that a rig with default powercell can build ~2.5x the stuff a fully-loaded RCD can.
	if(istype(loc,/obj/item/rig_module))
		var/obj/item/rig_module/module = loc
		if(module.holder && module.holder.cell)
			if(module.holder.cell.charge >= cost)
				if (!checkOnly)
					module.holder.cell.use(cost)
				return 1
	return 0

/obj/item/rcd/mounted/attackby()
	return

/obj/item/rcd/mounted/can_use(var/mob/user,var/turf/T)
	return (user.Adjacent(T) && !user.stat && !user.restrained())

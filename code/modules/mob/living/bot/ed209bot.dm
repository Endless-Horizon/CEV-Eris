/mob/living/bot/secbot/ed209
	name = "ED-209 Security Robot"
	desc = "A security robot.  He looks less than thrilled."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "ed2090"
	density = TRUE
	health = 100
	maxHealth = 100

	bot_version = "2.5"
	is_ranged = 1
	preparing_arrest_sounds = new()

	a_intent = I_HURT
	mob_bump_flag = HEAVY
	mob_swap_flags = ~HEAVY
	mob_push_flags = HEAVY

	var/shot_delay = 4
	var/last_shot = 0

/mob/living/bot/secbot/ed209/update_icons()
	if(on && is_attacking)
		icon_state = "ed209-c"
	else
		icon_state = "ed209[on]"
	..()

/mob/living/bot/secbot/ed209/explode()
	visible_message(SPAN_WARNING("[src] blows apart!"))
	playsound(loc, "robot_talk_heavy", 100, 2, 0)
	var/turf/Tsec = get_turf(src)

	new /obj/item/secbot_assembly/ed209_assembly(Tsec)

	var/obj/item/gun/energy/taser/G = new /obj/item/gun/energy/taser(Tsec)
	G.cell.charge = 0
	if(prob(50))
		new /obj/item/robot_parts/l_leg(Tsec)
	if(prob(50))
		new /obj/item/robot_parts/r_leg(Tsec)
	if(prob(50))
		if(prob(50))
			new /obj/item/clothing/head/armor/helmet(Tsec)
		else
			new /obj/item/clothing/suit/armor/vest(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/blood/oil(Tsec)
	qdel(src)

/mob/living/bot/secbot/ed209/RangedAttack(var/atom/A)
	if(last_shot + shot_delay > world.time)
		to_chat(src, "You are not ready to fire yet!")
		return

	last_shot = world.time
	var/projectile = /obj/item/projectile/beam/stun
	if(emagged)
		projectile = /obj/item/projectile/beam

	playsound(loc, emagged ? 'sound/weapons/Laser.ogg' : 'sound/weapons/Taser.ogg', 50, 1)
	var/obj/item/projectile/P = new projectile(loc)
	var/def_zone = get_exposed_defense_zone(A)
	P.launch(A, def_zone)
// Assembly

/obj/item/secbot_assembly/ed209_assembly
	name = "ED-209 assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "ed209_frame"
	item_state = "ed209_frame"
	created_name = "ED-209 Security Robot"
	var/lasercolor = ""

/obj/item/secbot_assembly/ed209_assembly/attackby(obj/item/I, mob/user)
	..()

	if(istype(I, /obj/item/pen))
		var/t = sanitizeSafe(input(user, "Enter new robot name", name, created_name), MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && src.loc != usr)
			return
		created_name = t
		return

	var/list/usable_qualities = list()
	if(build_step == 3)
		usable_qualities.Add(QUALITY_WELDING)
	if(build_step == 8)
		usable_qualities.Add(QUALITY_SCREW_DRIVING)

	var/tool_type = I.get_tool_type(user, usable_qualities, src)
	switch(tool_type)

		if(QUALITY_WELDING)
			if(build_step == 3)
				if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You welded the vest to [src]."))
					build_step++
					name = "shielded frame assembly"
					return
			return

		if(QUALITY_SCREW_DRIVING)
			if(build_step == 8)
				if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("Taser gun attached."))
					build_step++
					name = "armed [name]"
					return
			return

		if(ABORT_CHECK)
			return

	switch(build_step)
		if(0, 1)
			if(istype(I, /obj/item/robot_parts/l_leg) || istype(I, /obj/item/robot_parts/r_leg))
				user.drop_item()
				qdel(I)
				build_step++
				to_chat(user, SPAN_NOTICE("You add the robot leg to [src]."))
				playsound(src.loc, 'sound/effects/insert.ogg', 50, 1)
				name = "legs/frame assembly"
				if(build_step == 1)
					item_state = "ed209_leg"
					icon_state = "ed209_leg"
				else
					item_state = "ed209_legs"
					icon_state = "ed209_legs"

		if(2)
			if(istype(I, /obj/item/clothing/suit/storage/vest))
				user.drop_item()
				qdel(I)
				build_step++
				to_chat(user, SPAN_NOTICE("You add the armor to [src]."))
				playsound(src.loc, 'sound/effects/insert.ogg', 50, 1)
				name = "vest/legs/frame assembly"
				item_state = "ed209_shell"
				icon_state = "ed209_shell"

		if(4)
			if(istype(I, /obj/item/clothing/head/armor/helmet))
				user.drop_item()
				qdel(I)
				build_step++
				to_chat(user, SPAN_NOTICE("You add the helmet to [src]."))
				playsound(src.loc, 'sound/effects/insert.ogg', 50, 1)
				name = "covered and shielded frame assembly"
				item_state = "ed209_hat"
				icon_state = "ed209_hat"

		if(5)
			if(is_proximity_sensor(I))
				user.drop_item()
				qdel(I)
				build_step++
				to_chat(user, SPAN_NOTICE("You add the prox sensor to [src]."))
				playsound(src.loc, 'sound/effects/insert.ogg', 50, 1)
				name = "covered, shielded and sensored frame assembly"
				item_state = "ed209_prox"
				icon_state = "ed209_prox"

		if(6)
			if(istype(I, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = I
				if (C.get_amount() < 1)
					to_chat(user, SPAN_WARNING("You need one coil of wire to wire [src]."))
					return
				to_chat(user, SPAN_NOTICE("You start to wire [src]."))
				if(do_after(user, 40, src) && build_step == 6)
					if(C.use(1))
						build_step++
						to_chat(user, SPAN_NOTICE("You wire the ED-209 assembly."))
						playsound(src.loc, 'sound/effects/insert.ogg', 50, 1)
						name = "wired ED-209 assembly"
				return

		if(7)
			if(istype(I, /obj/item/gun/energy/taser))
				name = "taser ED-209 assembly"
				build_step++
				to_chat(user, SPAN_NOTICE("You add [I] to [src]."))
				playsound(src.loc, 'sound/effects/insert.ogg', 50, 1)
				item_state = "ed209_taser"
				icon_state = "ed209_taser"
				user.drop_item()
				qdel(I)

		if(9)
			if(istype(I, /obj/item/cell/large))
				build_step++
				to_chat(user, SPAN_NOTICE("You complete the ED-209."))
				var/turf/T = get_turf(src)
				new /mob/living/bot/secbot/ed209(T,created_name,lasercolor)
				user.drop_item()
				qdel(I)
				user.drop_from_inventory(src)
				qdel(src)

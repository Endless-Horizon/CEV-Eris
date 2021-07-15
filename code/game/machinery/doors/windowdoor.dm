/obj/machinery/door/window
	name = "interior door"
	desc = "A strong door."
	layer = ABOVE_WINDOW_LAYER
	open_layer = ABOVE_WINDOW_LAYER
	closed_layer = ABOVE_WINDOW_LAYER
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	var/base_state = "left"
	resistance = RESISTANCE_FRAGILE
	hitsound = 'sound/effects/Glasshit.ogg'
	maxhealth = 100 //If you change this, consiter changing ../door/window/brigdoor/ health at the bottom of this .dm file
	health = 100
	visible = 0
	use_power = NO_POWER_USE
	flags = ON_BORDER
	opacity = 0
	var/obj/item/electronics/airlock/electronics
	explosion_resistance = 5
	air_properties_vary_with_direction = 1

/obj/machinery/door/window/New()
	..()
	update_nearby_tiles()
	if (src.req_access && src.req_access.len)
		src.icon_state = "[src.icon_state]"
		src.base_state = src.icon_state
	return

/obj/machinery/door/window/proc/shatter(var/display_message = 1)
	new /obj/item/material/shard(src.loc)
	var/obj/item/stack/cable_coil/CC = new /obj/item/stack/cable_coil(src.loc)
	CC.amount = 2
	var/obj/item/electronics/airlock/ae
	if(!electronics)
		ae = new/obj/item/electronics/airlock( src.loc )
		if(!src.req_access)
			src.check_access()
		if(src.req_access.len)
			ae.conf_access = src.req_access
		else if (src.req_one_access.len)
			ae.conf_access = src.req_one_access
			ae.one_access = 1
	else
		ae = electronics
		electronics = null
		ae.loc = src.loc
	if(operating == -1)
		ae.SetIconState("door_electronics_smoked")
		operating = 0
	src.density = FALSE
	playsound(src, "shatter", 70, 1)
	if(display_message)
		visible_message("[src] shatters!")
	qdel(src)

/obj/machinery/door/window/Destroy()
	density = FALSE
	update_nearby_tiles()
	. = ..()

/obj/machinery/door/window/Bumped(atom/movable/AM as mob|obj)
	if (!( ismob(AM) ))
		var/mob/living/bot/bot = AM
		if(istype(bot))
			if(density && src.check_access(bot.botcard))
				open()
				sleep(50)
				close()
		else if(istype(AM, /mob/living/exosuit))
			var/mob/living/exosuit/exosuit = AM
			if(density)
				if(exosuit.pilots.len && allowed(exosuit.pilots[1]))
					open()
					sleep(50)
					close()
		return
	var/mob/M = AM // we've returned by here if M is not a mob
	if (src.operating)
		return
	if (src.density && (!issmall(M) || ishuman(M)) && src.allowed(AM))
		open()
		if(src.check_access(null))
			sleep(50)
		else //secure doors close faster
			sleep(20)
		close()
	return

/obj/machinery/door/window/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		if(air_group) return 0
		return !density
	else
		return 1

/obj/machinery/door/window/CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/machinery/door/window/open()
	if (operating == 1) //doors can still open when emag-disabled
		return 0
	if(!operating) //in case of emag
		operating = 1
	FLICK(text("[]opening", base_state), src)
	playsound(loc, 'sound/machines/windowdoor.ogg', 100, 1)
	SetIconState(text("[]open", base_state))
	sleep(10)

	explosion_resistance = 0
	density = FALSE
//	src.sd_SetOpacity(0)	//TODO: why is this here? Opaque windoors? ~Carn
	update_nearby_tiles()

	if(operating == 1) //emag again
		operating = 0
	return 1

/obj/machinery/door/window/close()
	if(operating)
		return 0
	operating = 1
	FLICK(text("[]closing", base_state), src)
	playsound(src.loc, 'sound/machines/windowdoor.ogg', 100, 1)
	SetIconState(base_state)

	density = TRUE
	explosion_resistance = initial(explosion_resistance)
//	if(visible)
//		SetOpacity(1)	//TODO: why is this here? Opaque windoors? ~Carn
	update_nearby_tiles()

	sleep(10)

	operating = 0
	return 1

/obj/machinery/door/window/take_damage(var/damage)
	src.health = max(0, src.health - damage)
	if (src.health <= 0)
		shatter()
		return

/obj/machinery/door/window/attack_hand(mob/user as mob)
	if(!attempt_open(user) && ishuman(user))
		var/mob/living/carbon/human/H = user
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		if(user.a_intent == I_HURT)
			if(H.species.can_shred(H))
				playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
				visible_message(SPAN_DANGER("[user] smashes against the [src.name]."), 1)
				take_damage(25)
				return

			playsound(src.loc, 'sound/effects/glassknock.ogg', 100, 1, 10, 10)
			user.do_attack_animation(src)
			usr.visible_message(SPAN_DANGER("\The [usr] bangs against \the [src]!"),
								SPAN_DANGER("You bang against \the [src]!"),
								"You hear a banging sound.")
		else
			playsound(src.loc, 'sound/effects/glassknock.ogg', 80, 1, 5, 5)
			usr.visible_message("[usr.name] knocks on the [src.name].",
								"You knock on the [src.name].",
								"You hear a knocking sound.")


/obj/machinery/door/window/emag_act(var/remaining_charges, var/mob/user)
	if (density && operable())
		operating = -1
		FLICK("[src.base_state]spark", src)
		sleep(6)
		open()
		return 1

/obj/machinery/door/emp_act(severity)
	if(prob(20/severity))
		spawn(0)
			open()
	..()

/obj/machinery/door/window/attackby(obj/item/I as obj, mob/user as mob)

	//If it's in the process of opening/closing, ignore the click
	if (src.operating == 1)
		return

	//Emags and ninja swords? You may pass.
	if (istype(I, /obj/item/melee/energy/blade))
		if(emag_act(10, user))
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, src.loc)
			spark_system.start()
			playsound(src.loc, "sparks", 50, 1)
			playsound(src.loc, 'sound/weapons/blade1.ogg', 50, 1)
			visible_message(SPAN_WARNING("The glass door was sliced open by [user]!"))
		return 1

	//If it's emagged, crowbar can pry electronics out.
	if (src.operating == -1 && (QUALITY_PRYING in I.tool_qualities))
		user.visible_message("[user] removes the electronics from the windoor.", "You start to remove electronics from the windoor.")
		if(I.use_tool(user, src, WORKTIME_NORMAL, QUALITY_PRYING, FAILCHANCE_EASY, required_stat = STAT_MEC))
			to_chat(user, SPAN_NOTICE("You removed the windoor electronics!"))

			var/obj/structure/windoor_assembly/wa = new/obj/structure/windoor_assembly(src.loc)
			if (istype(src, /obj/machinery/door/window/brigdoor))
				wa.secure = "secure_"
				wa.name = "Secure Wired Windoor Assembly"
			else
				wa.name = "Wired Windoor Assembly"
			if (src.base_state == "right" || src.base_state == "rightsecure")
				wa.facing = "r"
			wa.set_dir(src.dir)
			wa.state = "02"
			wa.update_icon()

			var/obj/item/electronics/airlock/ae
			if(!electronics)
				ae = new/obj/item/electronics/airlock( src.loc )
				if(!src.req_access)
					src.check_access()
				if(src.req_access.len)
					ae.conf_access = src.req_access
				else if (src.req_one_access.len)
					ae.conf_access = src.req_one_access
					ae.one_access = 1
			else
				ae = electronics
				electronics = null
				ae.loc = src.loc
			ae.SetIconState("door_electronics_smoked")

			operating = 0
			shatter(src)
			return

	//If it's a weapon, smash windoor. Unless it's an id card, agent card, ect.. then ignore it (Cards really shouldnt damage a door anyway)
	if(src.density && istype(I, /obj/item) && !istype(I, /obj/item/card))
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		var/aforce = I.force
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
		visible_message(SPAN_DANGER("[src] was hit by [I]."))
		if(I.damtype == BRUTE || I.damtype == BURN)
			take_damage(aforce)
		return


	src.add_fingerprint(user)

	attempt_open(user)

/obj/machinery/door/window/proc/attempt_open(mob/user)
	if (allowed(user))
		if (density)
			open()
		else
			close()
		return TRUE


	if (density)
		FLICK(text("[]deny", src.base_state), src)
	return FALSE


/obj/machinery/door/window/brigdoor
	name = "secure door"
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "leftsecure"
	base_state = "leftsecure"
	req_access = list(access_security)
	var/id
	maxhealth = 200
	health = 200 //Stronger doors for prison (regular window door health is 100)


/obj/machinery/door/window/northleft
	dir = NORTH

/obj/machinery/door/window/eastleft
	dir = EAST

/obj/machinery/door/window/westleft
	dir = WEST

/obj/machinery/door/window/southleft
	dir = SOUTH

/obj/machinery/door/window/northright
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/brigdoor/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

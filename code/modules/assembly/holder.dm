/obj/item/device/assembly_holder
	name = "Assembly"
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "holder"
	item_state = "assembly"
	flags = CONDUCT | PROXMOVE
	throwforce = 5
	w_class = ITEM_SIZE_SMALL
	throw_speed = 3
	throw_range = 10

	var/secured = FALSE
	var/obj/item/device/assembly/left_assembly
	var/obj/item/device/assembly/right_assembly

/obj/item/device/assembly_holder/New()
	..()
	add_hearing()

/obj/item/device/assembly_holder/Destroy()
	remove_hearing()
	. = ..()

/obj/item/device/assembly_holder/proc/attach(var/obj/item/device/D, var/obj/item/device/D2, var/mob/user)
	return

/obj/item/device/assembly_holder/proc/process_activation(var/obj/item/device/D)
	return

/obj/item/device/assembly_holder/proc/detached()
	return

/obj/item/device/assembly_holder/attach(var/obj/item/device/assembly/D, var/obj/item/device/assembly/D2, var/mob/user)
	if(!(D.is_attachable() || D.is_attachable()))
		return FALSE
	user.remove_from_mob(D)
	user.remove_from_mob(D2)
	D.holder = src
	D2.holder = src
	D.loc = src
	D2.loc = src
	left_assembly = D
	right_assembly = D2
	name = "[D.name]-[D2.name] assembly"
	update_icon()
	user.put_in_hands(src)
	return TRUE


/obj/item/device/assembly_holder/on_update_icon()
	cut_overlays()
	if(left_assembly)
		add_overlays("[left_assembly.icon_state]_left")
		for(var/O in left_assembly.attached_overlays)
			add_overlays("[O]_l")
	if(right_assembly)
		src.add_overlays("[right_assembly.icon_state]_right")
		for(var/O in right_assembly.attached_overlays)
			add_overlays("[O]_r")
	if(master)
		master.update_icon()


/obj/item/device/assembly_holder/examine(mob/user)
	..(user)
	if(in_range(src, user) || src.loc == user)
		if(src.secured)
			to_chat(user, SPAN_NOTICE("\The [src] is ready!"))
		else
			to_chat(user, SPAN_NOTICE("\The [src] can be attached!"))


/obj/item/device/assembly_holder/HasProximity(atom/movable/AM as mob|obj)
	if(left_assembly)
		left_assembly.HasProximity(AM)
	if(right_assembly)
		right_assembly.HasProximity(AM)


/obj/item/device/assembly_holder/Crossed(atom/movable/AM as mob|obj)
	if(left_assembly)
		left_assembly.Crossed(AM)
	if(right_assembly)
		right_assembly.Crossed(AM)


/obj/item/device/assembly_holder/on_found(mob/finder as mob)
	if(left_assembly)
		left_assembly.on_found(finder)
	if(right_assembly)
		right_assembly.on_found(finder)


/obj/item/device/assembly_holder/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, var/glide_size_override = 0)
	. = ..()
	if(left_assembly && right_assembly)
		left_assembly.holder_movement()
		right_assembly.holder_movement()

/obj/item/device/assembly_holder/attack_hand()//Perhapse this should be a holder_pickup proc instead, can add if needbe I guess
	if(left_assembly && right_assembly)
		left_assembly.holder_movement()
		right_assembly.holder_movement()
	..()


/obj/item/device/assembly_holder/attackby(obj/item/I, mob/user)
	if(QUALITY_SCREW_DRIVING in I.tool_qualities)
		if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, QUALITY_SCREW_DRIVING, FAILCHANCE_EASY, required_stat = STAT_COG))
			if(!left_assembly || !right_assembly)
				to_chat(user, SPAN_WARNING("Assembly part missing!"))
				return
			left_assembly.toggle_secure()
			right_assembly.toggle_secure()
			secured = !secured
			if(secured)
				to_chat(user, SPAN_NOTICE("\The [src] is ready!"))
			else
				to_chat(user, SPAN_NOTICE("\The [src] can now be taken apart!"))
			update_icon()
			return
	..()


/obj/item/device/assembly_holder/attack_self(mob/user as mob)
	src.add_fingerprint(user)
	if(src.secured)
		if(!left_assembly || !right_assembly)
			to_chat(user, SPAN_WARNING("Assembly part missing!"))
			return
		if(istype(left_assembly,right_assembly.type))//If they are the same type it causes issues due to window code
			switch(alert("Which side would you like to use?",,"Left","Right"))
				if("Left")	left_assembly.attack_self(user)
				if("Right")	right_assembly.attack_self(user)
			return
		else
			if(!istype(left_assembly,/obj/item/device/assembly/igniter))
				left_assembly.attack_self(user)
			if(!istype(right_assembly,/obj/item/device/assembly/igniter))
				right_assembly.attack_self(user)
	else
		var/turf/T = get_turf(src)
		if(!T)	return 0
		if(left_assembly)
			left_assembly:holder = null
			left_assembly.loc = T
		if(right_assembly)
			right_assembly:holder = null
			right_assembly.loc = T
		spawn(0)
			qdel(src)
	return


/obj/item/device/assembly_holder/process_activation(var/obj/D, var/normal = 1, var/special = 1)
	if(!D)	return 0
	if(!secured)
		visible_message("\icon[src] *beep* *beep*", "*beep* *beep*")
	if(normal && right_assembly && left_assembly)
		if(right_assembly != D)
			right_assembly.pulsed(0)
		if(left_assembly != D)
			left_assembly.pulsed(0)
	if(master)
		master.receive_signal()


/obj/item/device/assembly_holder/hear_talk(mob/living/M as mob, msg, verb, datum/language/speaking, speech_volume)
	if(right_assembly)
		right_assembly.hear_talk(M, msg, verb, speaking, speech_volume)
	if(left_assembly)
		left_assembly.hear_talk(M, msg, verb, speaking, speech_volume)




/obj/item/device/assembly_holder/timer_igniter
	name = "timer-igniter assembly"

/obj/item/device/assembly_holder/timer_igniter/New()
	..()

	var/obj/item/device/assembly/igniter/ign = new(src)
	ign.secured = 1
	ign.holder = src
	var/obj/item/device/assembly/timer/tmr = new(src)
	tmr.time=5
	tmr.secured = 1
	tmr.holder = src
	START_PROCESSING(SSobj, tmr)
	left_assembly = tmr
	right_assembly = ign
	secured = 1
	update_icon()
	name = initial(name) + " ([tmr.time] secs)"

	loc.verbs += /obj/item/device/assembly_holder/timer_igniter/verb/configure

/obj/item/device/assembly_holder/timer_igniter/detached()
	loc.verbs -= /obj/item/device/assembly_holder/timer_igniter/verb/configure
	..()

/obj/item/device/assembly_holder/timer_igniter/verb/configure()
	set name = "Set Timer"
	set category = "Object"
	set src in usr

	if ( !(usr.stat || usr.restrained()) )
		var/obj/item/device/assembly_holder/holder
		if(istype(src,/obj/item/grenade/chem_grenade))
			var/obj/item/grenade/chem_grenade/gren = src
			holder=gren.detonator
		var/obj/item/device/assembly/timer/tmr = holder.left_assembly
		if(!istype(tmr,/obj/item/device/assembly/timer))
			tmr = holder.right_assembly
		if(!istype(tmr,/obj/item/device/assembly/timer))
			to_chat(usr, SPAN_NOTICE("This detonator has no timer."))
			return

		if(tmr.timing)
			to_chat(usr, SPAN_NOTICE("Clock is ticking already."))
		else
			var/ntime = input("Enter desired time in seconds", "Time", "5") as num
			if (ntime>0 && ntime<1000)
				tmr.time = ntime
				name = initial(name) + "([tmr.time] secs)"
				to_chat(usr, SPAN_NOTICE("Timer set to [tmr.time] seconds."))
			else
				to_chat(usr, "<span class='notice'>Timer can't be [ntime<=0?"negative":"more than 1000 seconds"].</span>")
	else
		to_chat(usr, "<span class='notice'>You cannot do this while [usr.stat?"unconscious/dead":"restrained"].</span>")

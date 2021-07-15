/obj/machinery/camera
	name = "security camera"
	desc = "It's used to monitor rooms."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "camera"
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 10
	layer = WALL_OBJ_LAYER

	var/list/network = list(NETWORK_CEV_ERIS)
	var/c_tag = null
	var/c_tag_order = 999
	var/status = 1
	anchored = TRUE
	var/invuln = null
	var/bugged = 0
	var/obj/item/camera_assembly/assembly = null
	var/taped = 0

	var/toughness = 5 //sorta fragile

	// WIRES
	var/datum/wires/camera/wires = null // Wires datum

	//OTHER

	var/view_range = 7
	var/short_range = 2

	var/light_disabled = 0
	var/alarm_on = 0
	var/busy = 0

	var/on_open_network = 0

	var/affected_by_emp_until = 0
	var/last_shown_time = 0

/obj/machinery/camera/New()
	..()

	wires = new(src)
	assembly = new(src)
	assembly.state = 4

	/* // Use this to look for cameras that have the same c_tag.
	for(var/obj/machinery/camera/C in cameranet.cameras)
		var/list/tempnetwork = C.network&src.network
		if(C != src && C.c_tag == src.c_tag && tempnetwork.len)
			log_world("[src.c_tag] [src.x] [src.y] [src.z] conflicts with [C.c_tag] [C.x] [C.y] [C.z]")
	*/
	if(!src.network || src.network.len < 1)
		if(loc)
			error("[src.name] in [get_area(src)] (x:[src.x] y:[src.y] z:[src.z] has errored. [src.network?"Empty network list":"Null network list"]")
		else
			error("[src.name] in [get_area(src)] has errored. [src.network?"Empty network list":"Null network list"]")
		ASSERT(src.network)
		ASSERT(src.network.len > 0)

	if(isturf(loc) && !c_tag)
		var/area/A = get_area(src)
		c_tag = A.get_camera_tag(src)

/obj/machinery/camera/Destroy()
	deactivate(null, 0) //kick anyone viewing out
	taped = 0
	if(assembly)
		qdel(assembly)
		assembly = null
	qdel(wires)
	wires = null
	return ..()

/obj/machinery/camera/Process()
	if((stat & EMPED) && world.time >= affected_by_emp_until)
		stat &= ~EMPED
		cancelCameraAlarm()
		update_icon()
		update_coverage()
	return internal_process()

/obj/machinery/camera/proc/internal_process()
	return

/obj/machinery/camera/emp_act(severity)
	if(!isEmpProof() && prob(100/severity))
		if(!affected_by_emp_until || (world.time < affected_by_emp_until))
			affected_by_emp_until = max(affected_by_emp_until, world.time + (90 SECONDS / severity))
		else
			stat |= EMPED
			set_light(0)
			triggerCameraAlarm()
			update_icon()
			update_coverage()
			START_PROCESSING(SSmachines, src)

/obj/machinery/camera/bullet_act(var/obj/item/projectile/P)
	take_damage(P.get_structure_damage())

/obj/machinery/camera/ex_act(severity)
	if(src.invuln)
		return

	//camera dies if an explosion touches it!
	if(severity <= 2 || prob(50))
		destroy()

	..() //and give it the regular chance of being deleted outright

/obj/machinery/camera/hitby(AM as mob|obj)
	..()
	if (isobj(AM))
		var/obj/O = AM
		if (O.throwforce >= src.toughness)
			visible_message(SPAN_WARNING("<B>[src] was hit by [O].</B>"))
		take_damage(O.throwforce)

/obj/machinery/camera/proc/setViewRange(var/num = 7)
	src.view_range = num
	cameranet.updateVisibility(src, 0)

/obj/machinery/camera/attack_hand(mob/living/carbon/human/user as mob)
	if (taped == 1)
		icon_state = "camera"
		taped = 0
		set_status(1)
		to_chat(user, "You take tape from camera")
		desc ="It's used to monitor rooms."
	if(!istype(user))
		return

	if(user.species.can_shred(user))
		set_status(0)
		user.do_attack_animation(src)
		visible_message(SPAN_WARNING("\The [user] slashes at [src]!"))
		playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
		add_hiddenprint(user)
		destroy()

/obj/machinery/camera/attackby(obj/item/I, mob/living/user)
	update_coverage()
	// DECONSTRUCTION

	var/list/usable_qualities = list(QUALITY_SCREW_DRIVING)
	if((wires.CanDeconstruct() || (stat & BROKEN)))
		usable_qualities.Add(QUALITY_WELDING)

	var/tool_type = I.get_tool_type(user, usable_qualities, src)
	switch(tool_type)

		if(QUALITY_WELDING)
			if((wires.CanDeconstruct() || (stat & BROKEN)))
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You weld the assembly securely into place."))
					if(assembly)
						assembly.loc = src.loc
						assembly.anchored = TRUE
						assembly.camera_name = c_tag
						assembly.camera_network = english_list(network, "Exodus", ",", ",")
						assembly.update_icon()
						assembly.dir = src.dir
						if(stat & BROKEN)
							assembly.state = 2
							to_chat(user, SPAN_NOTICE("You repaired \the [src] frame."))
						else
							assembly.state = 1
							to_chat(user, SPAN_NOTICE("You cut \the [src] free from the wall."))
							new /obj/item/stack/cable_coil(src.loc, length=2)
						assembly = null //so qdel doesn't eat it.
					qdel(src)
					return
			return


		if(QUALITY_SCREW_DRIVING)
			if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
				panel_open = !panel_open
				user.visible_message("<span class='warning'>[user] screws the camera's panel [panel_open ? "open" : "closed"]!</span>",
				"<span class='notice'>You screw the camera's panel [panel_open ? "open" : "closed"].</span>")
				return
			return

		if(ABORT_CHECK)
			return


	if(istool(I) && panel_open)
		interact(user)

	// OTHER
	else if (can_use() && isliving(user) && user.a_intent != I_HURT)
		var/mob/living/U = user
		var/list/mob/viewers = list()
		if(istype(I, /obj/item/ducttape )|| istype(I, /obj/item/tool/tape_roll))
			set_status(0)
			taped = 1
			icon_state = "camera_taped"
			to_chat(U, "You taped the camera")
			desc = "It's used to monitor rooms. It's covered with something sticky."
			return
		if(last_shown_time < world.time)
			to_chat(U, "You hold \a [I.name] up to the camera ...")
			for(var/mob/O in GLOB.living_mob_list)
				if(!O.client)
					continue
				if (istype(O, /mob/living/silicon/ai))
					viewers += O
				else if (istype(O.machine, /obj/item/modular_computer))
					var/obj/item/modular_computer/S = O.machine
					if (S.active_program && S.active_program.NM && istype(S.active_program.NM, /datum/nano_module/camera_monitor))
						var/datum/nano_module/camera_monitor/CM = S.active_program.NM
						if (CM.current_camera == src)
							viewers += O
			for(var/mob/O in viewers)
				if(!O.client)
					continue
				if(istype(O, /mob/living/silicon/ai))
					if(U.name == "Unknown")
						to_chat(O, "<b>[U]</b> holds \a [I.name] up to one of your cameras ...")
					else
						to_chat(O, "<b><a href='byond://?src=\ref[O];track2=\ref[O];track=\ref[U];trackname=[U.name]'>[U]</a></b> holds \a [I.name] up to one of your cameras ...")
				else
					to_chat(O, "<b>[U]</b> holds \a [I.name] up to the camera ...")

				if(istype(I, /obj/item/paper))
					var/obj/item/paper/X = I
					O << browse("<HTML><HEAD><TITLE>[X.name]</TITLE></HEAD><BODY><TT>[X.info]</TT></BODY></HTML>", "window=[X.name]")
				else
					I.examine(O)
			last_shown_time = world.time + 2 SECONDS

	else if (istype(I, /obj/item/camera_bug))
		if (!src.can_use())
			to_chat(user, SPAN_WARNING("Camera non-functional."))
			return
		if (src.bugged)
			to_chat(user, SPAN_NOTICE("Camera bug removed."))
			src.bugged = 0
		else
			to_chat(user, SPAN_NOTICE("Camera bugged."))
			src.bugged = 1

	else if(I.damtype == BRUTE || I.damtype == BURN) //bashing cameras
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		if (I.force >= src.toughness)
			user.do_attack_animation(src)
			visible_message(SPAN_WARNING("<b>[src] has been [pick(I.attack_verb)] with [I] by [user]!</b>"))
			if (I.hitsound)
				playsound(loc, I.hitsound, 50, 1, -1)
		take_damage(I.force)

	else
		..()

/obj/machinery/camera/proc/deactivate(mob/user, var/choice = 1)
	// The only way for AI to reactivate cameras are malf abilities, this gives them different messages.
	if(isAI(user))
		user = null

	if(choice != 1)
		return

	set_status(!status)
	if (!status)
		if(user)
			visible_message(SPAN_NOTICE("[user] has deactivated [src]!"))
			add_hiddenprint(user)
		else
			visible_message(SPAN_NOTICE("[src] clicks and shuts down. "))
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		icon_state = "[initial(icon_state)]1"
	else
		if(user)
			visible_message(SPAN_NOTICE("[user] has reactivated [src]!"))
			add_hiddenprint(user)
		else
			visible_message(SPAN_NOTICE("[src] clicks and reactivates itself. "))
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		icon_state = initial(icon_state)

/obj/machinery/camera/proc/take_damage(var/force, var/message)
	//prob(25) gives an average of 3-4 hits
	if (force >= toughness && (force > toughness*4 || prob(25)))
		destroy()

//Used when someone breaks a camera
/obj/machinery/camera/proc/destroy()
	stat |= BROKEN
	wires.RandomCutAll()
	taped = 0

	triggerCameraAlarm()
	update_icon()
	update_coverage()

	//sparks
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, loc)
	spark_system.start()
	playsound(loc, "sparks", 50, 1)

/obj/machinery/camera/proc/set_status(var/newstatus)
	if (status != newstatus)
		status = newstatus
		update_coverage()

/obj/machinery/camera/check_eye(mob/user)
	if(!can_use()) return -1
	if(isXRay()) return SEE_TURFS|SEE_MOBS|SEE_OBJS
	return 0

/obj/machinery/camera/on_update_icon()
	if (!status || (stat & BROKEN))
		icon_state = "[initial(icon_state)]1"
	else if (stat & EMPED)
		icon_state = "[initial(icon_state)]emp"
	else
		icon_state = initial(icon_state)

/obj/machinery/camera/proc/triggerCameraAlarm(var/duration = 0)
	alarm_on = 1
	camera_alarm.triggerAlarm(loc, src, duration)

/obj/machinery/camera/proc/cancelCameraAlarm()
	if(wires.IsIndexCut(CAMERA_WIRE_ALARM))
		return

	alarm_on = 0
	camera_alarm.clearAlarm(loc, src)

//if false, then the camera is listed as DEACTIVATED and cannot be used
/obj/machinery/camera/proc/can_use()
	if(!status)
		return 0
	if(stat & (EMPED|BROKEN))
		return 0
	return 1

/obj/machinery/camera/proc/can_see()
	var/list/see = null
	var/turf/pos = get_turf(src)
	if(!pos)
		return list()

	if(isXRay())
		see = range(view_range, pos)
	else
		see = hear(view_range, pos)
	return see

/atom/proc/auto_turn()
	//Automatically turns based on nearby walls.
	var/turf/simulated/wall/T = null
	for(var/i = 1, i <= 8; i += i)
		T = get_ranged_target_turf(src, i, 1)
		if(istype(T))
			//If someone knows a better way to do this, let me know. -Giacom
			switch(i)
				if(NORTH)
					src.set_dir(SOUTH)
				if(SOUTH)
					src.set_dir(NORTH)
				if(WEST)
					src.set_dir(EAST)
				if(EAST)
					src.set_dir(WEST)
			break

//Return a working camera that can see a given mob
//or null if none
/proc/seen_by_camera(var/mob/M)
	for(var/obj/machinery/camera/C in oview(4, M))
		if(C.can_use())	// check if camera disabled
			return C
	return null

/proc/near_range_camera(var/mob/M)

	for(var/obj/machinery/camera/C in range(4, M))
		if(C.can_use())	// check if camera disabled
			return C
	return null

/obj/machinery/camera/interact(mob/living/user as mob)
	if(!panel_open || isAI(user))
		return

	if(stat & BROKEN)
		to_chat(user, SPAN_WARNING("\The [src] is broken."))
		return

	user.set_machine(src)
	wires.Interact(user)

/obj/machinery/camera/proc/add_network(var/network_name)
	add_networks(list(network_name))

/obj/machinery/camera/proc/remove_network(var/network_name)
	remove_networks(list(network_name))

/obj/machinery/camera/proc/add_networks(var/list/networks)
	var/network_added
	network_added = 0
	for(var/network_name in networks)
		if(!(network_name in src.network))
			network += network_name
			network_added = 1

	if(network_added)
		update_coverage(1)

/obj/machinery/camera/proc/remove_networks(var/list/networks)
	var/network_removed
	network_removed = 0
	for(var/network_name in networks)
		if(network_name in src.network)
			network -= network_name
			network_removed = 1

	if(network_removed)
		update_coverage(1)

/obj/machinery/camera/proc/replace_networks(var/list/networks)
	if(networks.len != network.len)
		network = networks
		update_coverage(1)
		return

	for(var/new_network in networks)
		if(!(new_network in network))
			network = networks
			update_coverage(1)
			return

/obj/machinery/camera/proc/clear_all_networks()
	if(network.len)
		network.Cut()
		update_coverage(1)

/obj/machinery/camera/proc/nano_structure()
	var/cam[0]
	cam["name"] = sanitize(strip_improper(c_tag))
	cam["deact"] = !can_use()
	cam["camera"] = "\ref[src]"
	cam["x"] = x
	cam["y"] = y
	cam["z"] = z
	return cam

/obj/machinery/camera/proc/update_coverage(var/network_change = 0)
	if(network_change)
		var/list/open_networks = difflist(network, restricted_camera_networks)
		// Add or remove camera from the camera net as necessary
		if(on_open_network && !open_networks.len)
			cameranet.removeCamera(src)
		else if(!on_open_network && open_networks.len)
			on_open_network = 1
			cameranet.addCamera(src)
	else
		cameranet.updateVisibility(src, 0)

	invalidateCameraCache()

// Resets the camera's wires to fully operational state. Used by one of Malfunction abilities.
/obj/machinery/camera/proc/reset_wires()
	if(!wires)
		return
	if (stat & BROKEN) // Fix the camera
		stat &= ~BROKEN
	wires.CutAll()
	wires.MendAll()
	update_icon()
	update_coverage()

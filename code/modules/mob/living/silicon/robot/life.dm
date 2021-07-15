/mob/living/silicon/robot/Life()
	set invisibility = 0
	set background = 1

	if (HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return

	src.blinded = null

	//Status updates, death etc.
	clamp_values()
	handle_regular_status_updates()
	handle_actions()

	if(client)
		handle_regular_hud_updates()
		update_items()
	if (src.stat != DEAD) //still using power
		use_power()
		process_killswitch()
		process_locks()
		process_queued_alarms()
	else
		if (!src.death_notified && src.connected_ai)
			src.notify_ai(ROBOT_NOTIFICATION_SIGNAL_LOST)
			src.death_notified = TRUE
	update_lying_buckled_and_verb_status()

	for(var/mob/living/L in view(7)) //Sucks to put this here, but otherwise mobs will ignore them
		L.try_activate_ai()

/mob/living/silicon/robot/proc/clamp_values()

//	SetStunned(min(stunned, 30))
	SetParalysis(min(paralysis, 30))
//	SetWeakened(min(weakened, 20))
	sleeping = 0
	adjustBruteLoss(0)
	adjustToxLoss(0)
	adjustOxyLoss(0)
	adjustFireLoss(0)

/mob/living/silicon/robot/proc/use_power()
	// Debug only
	// world << "DEBUG: life.dm line 35: cyborg use_power() called at tick [controller_iteration]"
	used_power_this_tick = 0
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		C.update_power_state()

	if (cell && is_component_functioning("power cell") && src.cell.charge > 0)
		if(src.module_state_1)
			cell_use_power(50) // 50W load for every enabled tool TODO: tool-specific loads
		if(src.module_state_2)
			cell_use_power(50)
		if(src.module_state_3)
			cell_use_power(50)

		if(lights_on)
			if(intenselight)
				cell_use_power(100)	// Upgraded light. Double intensity, much larger power usage.
			else
				cell_use_power(30) 	// 30W light. Normal lights would use ~15W, but increased for balance reasons.

		src.has_power = 1
	else
		if (src.has_power)
			to_chat(src, "\red You are now running on emergency backup power.")
		src.has_power = 0
		if(lights_on) // Light is on but there is no power!
			lights_on = 0
			set_light(0)



/mob/living/silicon/robot/handle_regular_status_updates()

	if(src.camera && !scrambledcodes)
		if(src.stat == 2 || wires.IsIndexCut(BORG_WIRE_CAMERA))
			src.camera.set_status(0)
		else
			src.camera.set_status(1)

	updatehealth()

	if(src.sleeping)
		Paralyse(3)
		src.sleeping--

	if(src.resting)
		Weaken(5)

	if(health < HEALTH_THRESHOLD_DEAD && src.stat != 2) //die only once
		death()

	if (src.stat != 2) //Alive.
		if (src.paralysis || src.stunned || src.weakened || !src.has_power) //Stunned etc.
			src.stat = 1
			if (src.stunned > 0)
				AdjustStunned(-1)
			if (src.weakened > 0)
				AdjustWeakened(-1)
			if (src.paralysis > 0)
				AdjustParalysis(-1)
				src.blinded = TRUE
			else
				src.blinded = FALSE

		else	//Not stunned.
			src.stat = 0

		confused = max(0, confused - 1)

	else //Dead.
		src.blinded = TRUE
		src.stat = 2

	if (src.stuttering) src.stuttering--

	if (src.eye_blind)
		src.eye_blind--
		src.blinded = TRUE

	if (src.ear_deaf > 0) src.ear_deaf--
	if (src.ear_damage < 25)
		src.ear_damage -= 0.05
		src.ear_damage = max(src.ear_damage, 0)

	src.density = !( src.lying )

	if ((src.sdisabilities & BLIND))
		src.blinded = TRUE
	if ((src.sdisabilities & DEAF))
		src.ear_deaf = 1

	if (src.eye_blurry > 0)
		src.eye_blurry--
		src.eye_blurry = max(0, src.eye_blurry)

	if (src.druggy > 0)
		src.druggy--
		src.druggy = max(0, src.druggy)

	if(radio)
		if(!is_component_functioning("radio"))
			radio.on = FALSE
		else
			radio.on = TRUE

	if(is_component_functioning("camera"))
		src.blinded = FALSE
	else
		src.blinded = TRUE

	return 1

/mob/living/silicon/robot/handle_regular_hud_updates()

	.=..()
	if (!.)//Parent function will return zero if no client
		return







	for (var/obj/screen/H in HUDprocess)
//		var/obj/screen/B = H
		H.Process()



	return 1


/mob/living/silicon/robot/handle_vision()
	..()
	client.screen.Remove(global_hud.blurry,global_hud.druggy,global_hud.vimpaired)
	var/obj/item/borg/sight/hud/hud = (locate(/obj/item/borg/sight/hud) in src)
	if(hud && hud.hud)
		hud.hud.process_hud(src)
	else
		switch(src.sensor_mode)
			if (SEC_HUD)
				process_sec_hud(src,0)
			if (MED_HUD)
				process_med_hud(src,0)


/mob/living/silicon/robot/update_sight()
	if(stat == DEAD || eyeobj)
		update_dead_sight()
	else
		if (is_ventcrawling)
			sight |= SEE_TURFS|SEE_OBJS

		if ((src.sight_mode & BORGXRAY))
			src.sight |= SEE_TURFS
			src.sight |= SEE_MOBS
			src.sight |= SEE_OBJS
			src.see_in_dark = 8
			src.see_invisible = SEE_INVISIBLE_MINIMUM
		else if ((src.sight_mode & BORGMESON) && (src.sight_mode & BORGTHERM))
			src.sight |= SEE_TURFS
			src.sight |= SEE_MOBS
			src.see_in_dark = 8
			see_invisible = SEE_INVISIBLE_MINIMUM
		else if (src.sight_mode & BORGMESON)
			src.sight |= SEE_TURFS
			src.see_in_dark = 8
			see_invisible = SEE_INVISIBLE_MINIMUM
		else if (src.sight_mode & BORGMATERIAL)
			src.sight |= SEE_OBJS
			src.see_in_dark = 8
			see_invisible = SEE_INVISIBLE_MINIMUM
		else if (src.sight_mode & BORGTHERM)
			src.sight |= SEE_MOBS
			src.see_in_dark = 8
			src.see_invisible = SEE_INVISIBLE_LEVEL_TWO
		else if (src.stat != 2)
			src.sight &= ~SEE_MOBS
			src.sight &= ~SEE_TURFS
			src.sight &= ~SEE_OBJS
			src.see_in_dark = 8 			 // see_in_dark means you can FAINTLY see in the dark, humans have a range of 3 or so
			src.see_invisible = SEE_INVISIBLE_LIVING // This is normal vision (25), setting it lower for normal vision means you don't "see" things like darkness since darkness
								 // has a "invisible" value of 15

/mob/living/silicon/robot/update_dead_sight()
	src.sight |= SEE_TURFS
	src.sight |= SEE_MOBS
	src.sight |= SEE_OBJS
	src.see_in_dark = 8
	src.see_invisible = SEE_INVISIBLE_MINIMUM


/mob/living/silicon/robot/proc/update_items()
	if (src.client)
		src.client.screen -= src.contents
		for(var/obj/I in src.contents)
			if(I && !(istype(I,/obj/item/cell/large) || istype(I,/obj/item/device/radio)  || istype(I,/obj/machinery/camera) || istype(I,/obj/item/device/mmi)))
				src.client.screen += I
	if(src.module_state_1)
		src.module_state_1:screen_loc = find_inv_position(1)
	if(src.module_state_2)
		src.module_state_2:screen_loc = find_inv_position(2)
	if(src.module_state_3)
		src.module_state_3:screen_loc = find_inv_position(3)
	updateicon()

/mob/living/silicon/robot/proc/process_killswitch()
	if(killswitch)
		killswitch_time --
		if(killswitch_time <= 0)
			if(src.client)
				to_chat(src, SPAN_DANGER("Killswitch Activated"))
			killswitch = 0
			spawn(5)
				gib()

/mob/living/silicon/robot/proc/process_locks()
	if(weapon_lock)
		uneq_all()
		weaponlock_time --
		if(weaponlock_time <= 0)
			if(src.client)
				to_chat(src, SPAN_DANGER("Weapon Lock Timed Out!"))
			weapon_lock = 0
			weaponlock_time = 120

/mob/living/silicon/robot/update_lying_buckled_and_verb_status()
	if(paralysis || stunned || weakened || buckled || lockcharge || !is_component_functioning("actuator")) canmove = 0
	else canmove = 1
	return canmove

/mob/living/silicon/robot/update_fire()
	remove_overlays(image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing"))
	if(on_fire)
		add_overlays(image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing"))

/mob/living/silicon/robot/fire_act()
	if(!on_fire) //Silicons don't gain stacks from hotspots, but hotspots can ignite them
		IgniteMob()

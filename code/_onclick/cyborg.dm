/*
	Cyborg ClickOn()

	Cyborgs have no range restriction on attack_robot(), because it is basically an AI click.
	However, they do have a range restriction on item use, so they cannot do without the
	adjacency code.
*/

/mob/living/silicon/robot/ClickOn(var/atom/A, var/params)
	if(!can_click())
		return
	next_click = world.time + 1

	if(client.buildmode) // comes after object.Click to allow buildmode gui objects to be clicked
		build_click(src, client.buildmode, params, A)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"]) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(stat || lockcharge || weakened || stunned || paralysis)
		return



	face_atom(A) // change direction to face what you clicked on

	if(aiCamera.in_camera_mode)
		if(!get_turf(A))
			return
		aiCamera.camera_mode_off()
		if(is_component_functioning("camera"))
			aiCamera.captureimage(A, usr)
		else
			to_chat(src, "<span class='userdanger'>Your camera isn't functional.</span>")
		return

	/*
	cyborg restrained() currently does nothing
	if(restrained())
		RestrainedClickOn(A)
		return
	*/

	var/obj/item/W = get_active_hand()

	// Cyborgs have no range-checking unless there is item use
	if(!W)
		A.add_hiddenprint(src)
		A.attack_robot(src)
		return


	if(W == A)

		W.attack_self(src)
		return

	//Handling using grippers
	if (istype(W, /obj/item/gripper))
		var/obj/item/gripper/G = W
		//If the gripper contains something, then we will use its contents to attack
		if (G.wrapped && (G.wrapped.loc == G))
			GripperClickOn(A, params, G)
			return


	// cyborgs are prohibited from using storage items so we can I think safely remove (A.loc in contents)
	if(A == loc || (A in loc) || (A in contents))
		// No adjacency checks

		var/resolved = A.attackby(W, src, params)
		if(!resolved && A && W)
			W.afterattack(A, src, 1, params)
		return

	if(!isturf(loc))
		return

	// cyborgs are prohibited from using storage items so we can I think safely remove (A.loc && isturf(A.loc.loc))
	var/sdepth = A.storage_depth_turf()
	if(isturf(A) || isturf(A.loc) || (sdepth != -1 && sdepth <= 1))
		if(A.Adjacent(src)) // see adjacent.dm
			if (W)
				var/resolved = (SEND_SIGNAL(W, COMSIG_IATTACK, A, src, params)) || (SEND_SIGNAL(A, COMSIG_ATTACKBY, W, src, params)) || W.resolve_attackby(A, src, params)
				if(!resolved && A && W)
					W.afterattack(A, src, 1, params)
			else
				if(ismob(A))
					setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
				UnarmedAttack(A, 1)
			return
		else
			if (W)
				W.afterattack(A, src, 0, params)
			else
				RangedAttack(A, params)
	return


/*
	Gripper Handling
	This is used when a gripper is used on anything. It does all the handling for it
*/
/mob/living/silicon/robot/proc/GripperClickOn(var/atom/A, var/params, var/obj/item/gripper/G)

	var/obj/item/W = G.wrapped
	if (!grippersafety(G))return


	G.force_holder = W.force
	W.force = 0
	// cyborgs are prohibited from using storage items so we can I think safely remove (A.loc in contents)
	if(A == loc || (A in loc) || (A in contents))
		// No adjacency checks

		var/resolved = A.attackby(W,src,params)
		if (!grippersafety(G))return
		if(!resolved && A && W)
			W.afterattack(A,src,1,params)
		if (!grippersafety(G))return
		W.force = G.force_holder
		return
	if(!isturf(loc))
		W.force = G.force_holder
		return

	// cyborgs are prohibited from using storage items so we can I think safely remove (A.loc && isturf(A.loc.loc))
	if(isturf(A) || isturf(A.loc))
		if(A.Adjacent(src)) // see adjacent.dm
			var/resolved = A.attackby(W, src, params)
			if (!grippersafety(G))return
			if(!resolved && A && W)
				W.afterattack(A, src, 1, params)
			if (!grippersafety(G))return
			W.force = G.force_holder
			return
		//No non-adjacent clicks. Can't fire guns
	W.force = G.force_holder
	return


//Middle click cycles through selected modules.
/mob/living/silicon/robot/MiddleClickOn(var/atom/A)
	cycle_modules()
	return

//Give cyborgs hotkey clicks without breaking existing uses of hotkey clicks
// for non-doors/apcs
/mob/living/silicon/robot/CtrlShiftClickOn(var/atom/A)
	if(ai_access)
		return A.BorgCtrlShiftClick(src)
	..()

/mob/living/silicon/robot/ShiftClickOn(var/atom/A)
	if(ai_access)
		return A.BorgShiftClick(src)
	..()

/mob/living/silicon/robot/CtrlClickOn(var/atom/A)
	if(ai_access)
		return A.BorgCtrlClick(src)
	..()

/mob/living/silicon/robot/AltClickOn(var/atom/A)
	if(ai_access)
		return A.BorgAltClick(src)
	..()

/atom/proc/BorgCtrlShiftClick(var/mob/living/silicon/robot/user) //forward to human click if not overriden
	CtrlShiftClick(user)

/obj/machinery/door/airlock/BorgCtrlShiftClick(var/mob/living/silicon/robot/user)
	AICtrlShiftClick(user)

/atom/proc/BorgShiftClick(var/mob/living/silicon/robot/user) //forward to human click if not overriden
	ShiftClick(user)

/obj/machinery/door/airlock/BorgShiftClick(var/mob/living/silicon/robot/user)  // Opens and closes doors! Forwards to AI code.
	AIShiftClick(user)

/atom/proc/BorgCtrlClick(var/mob/living/silicon/robot/user) //forward to human click if not overriden
	CtrlClick(user)

/obj/machinery/door/airlock/BorgCtrlClick(var/mob/living/silicon/robot/user) // Bolts doors. Forwards to AI code.
	AICtrlClick(user)

/obj/machinery/power/apc/BorgCtrlClick(var/mob/living/silicon/robot/user) // turns off/on APCs. Forwards to AI code.
	AICtrlClick(user)

/obj/machinery/turretid/BorgCtrlClick(var/mob/living/silicon/robot/user) //turret control on/off. Forwards to AI code.
	AICtrlClick(user)

/atom/proc/BorgAltClick(var/mob/living/silicon/robot/user)
	AltClick(user)
	return

/obj/machinery/door/airlock/BorgAltClick(var/mob/living/silicon/robot/user) // Eletrifies doors. Forwards to AI code.
	AIAltClick(user)

/obj/machinery/turretid/BorgAltClick(var/mob/living/silicon/robot/user) //turret lethal on/off. Forwards to AI code.
	AIAltClick(user)

/*
	As with AI, these are not used in click code,
	because the code for robots is specific, not generic.

	If you would like to add advanced features to robot
	clicks, you can do so here, but you will have to
	change attack_robot() above to the proper function
*/
/mob/living/silicon/robot/UnarmedAttack(atom/A)
	A.attack_robot(src)
/mob/living/silicon/robot/RangedAttack(atom/A)
	A.attack_robot(src)

/atom/proc/attack_robot(mob/user)
	attack_ai(user)
	return

//
//	On Ctrl-Click will turn on if off otherwise will switch between Filtering and Panic Siphon
//
/obj/machinery/alarm/BorgCtrlClick(var/mob/living/silicon/robot/user)
	AICtrlClick(user)

//
//	On Alt-Click will cycle through modes
//
/obj/machinery/alarm/BorgAltClick(var/mob/living/silicon/robot/user)
	AIAltClick(user)

//
//	On Ctrl-Click will turn on if off otherwise will switch between Filtering and Panic Siphon
//
/obj/machinery/firealarm/BorgCtrlClick(var/mob/living/silicon/robot/user)
	AICtrlClick(user)

//
//	On Ctrl-Click will turn on or off SMES input
//
/obj/machinery/power/smes/BorgCtrlClick(var/mob/living/silicon/robot/user)
	AICtrlClick(user)

//
//	On Alt-Click will turn on or off SMES output
//
/obj/machinery/power/smes/BorgAltClick(var/mob/living/silicon/robot/user)
	AIAltClick(user)

//
//	On Ctrl-Click will turn on or off gas cooling system
//
/obj/machinery/atmospherics/unary/freezer/BorgCtrlClick(var/mob/living/silicon/robot/user)
	AICtrlClick(user)

//
//	On Ctrl-Click will turn on or off telecomms machinery
//	ENABLE WHEN TCOMS UI WILL BE UPDATED TO NANOUI
/*
/obj/machinery/telecomms/BorgCtrlClick(var/mob/living/silicon/robot/user)
	AICtrlClick(user)
*/

//QOL feature, clicking on turf can toogle doors
/turf/BorgCtrlClick(var/mob/living/silicon/robot/user)
	AICtrlClick(user)

/turf/BorgAltClick(var/mob/living/silicon/robot/user)
	AIAltClick(user)

/turf/BorgShiftClick(var/mob/living/silicon/robot/user)
	AIShiftClick(user)
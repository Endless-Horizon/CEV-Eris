//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/tank/jetpack
	name = "jetpack (empty)"
	desc = "A tank of compressed gas for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	gauge_icon = null
	w_class = ITEM_SIZE_BULKY
	force = WEAPON_FORCE_PAINFUL
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	default_pressure = 6*ONE_ATMOSPHERE
	bad_type = /obj/item/tank/jetpack
	spawn_tags = SPAWN_TAG_JETPACK
	rarity_value = 50
	var/datum/effect/effect/system/trail/jet/trail
	var/on = FALSE
	var/stabilization_on = 0
	action_button_name = "Toggle Jetpack"

	var/thrust_cost = JETPACK_MOVE_COST

	//Vars used for stabilisation visual effects

	var/stabilize_done = FALSE
	//This is set false when a stabilisation check is queued, and set true when it resolves
	//Used to prevent multiple scheduled checks in a row from resolving, and causing the effect+cost to happen many times

	var/obj/item/tank/gastank = null //The tank we actually draw gas from. This is generally ourselves
	//but Rig backpacks draw from a seperate tank

	//Used for normal jet thrust effects
	var/thrust_fx_done = FALSE

/*****************************
	Jetpack Types
*****************************/
/obj/item/tank/jetpack/void
	name = "void jetpack (oxygen)"
	desc = "It works well in a void."
	icon_state = "jetpack-void"
	default_gas = "oxygen"

/obj/item/tank/jetpack/oxygen
	name = "jetpack (oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	default_gas = "oxygen"

/obj/item/tank/jetpack/carbondioxide
	name = "jetpack (carbon dioxide)"
	desc = "A tank of compressed carbon dioxide for use as propulsion in zero-gravity areas. Painted black to indicate that it should not be used as a source for internals."
	icon_state = "jetpack-black"
	distribute_pressure = 0
	default_gas = "carbon_dioxide"
	rarity_value = 33.33

/*****************************
	Core Functionality
*****************************/
/obj/item/tank/jetpack/Initialize(mapload, ...)
	. = ..()
	gastank = src
	trail = new /datum/effect/effect/system/trail/jet()
	trail.set_up(src)


/obj/item/tank/jetpack/Destroy()
	QDEL_NULL(trail)
	gastank = null // this is usually src, better to not call qdel infinitely
	return ..()

/obj/item/tank/jetpack/examine(mob/user)
	. = ..()
	to_chat(user, "The pressure gauge reads: [SPAN_NOTICE(get_gas().return_pressure())] kPa")
	if(air_contents.total_moles < 5)
		to_chat(user, SPAN_DANGER("The gauge on \the [src] indicates you are almost out of gas!"))
		playsound(user, 'sound/effects/alert.ogg', 50, 1)

/*****************************
	Mode Setting
*****************************/
//Toggling does as little as possible, to make jetpacks more modular.
//All the work is done in the enable/disable procs
/obj/item/tank/jetpack/verb/toggle_rockets()
	set name = "Toggle Jetpack Stabilization"
	set category = "Object"

	//Turning off stabilisation always works
	if (stabilization_on)
		disable_stabilizer()
	else
		enable_stabilizer()

/obj/item/tank/jetpack/proc/enable_stabilizer()
	if (stabilize(usr, usr.l_move_time, TRUE))
		stabilization_on = TRUE
		to_chat(usr, "You toggle the stabilization [stabilization_on? "on":"off"].")
		return TRUE
	else
		if (!on)
			to_chat(usr, SPAN_WARNING("The [src] must be enabled first!"))
		else
			to_chat(usr, SPAN_WARNING("The [src] doesnt have enough gas to enable the stabiliser."))
		return FALSE

/obj/item/tank/jetpack/proc/disable_stabilizer()
	stabilization_on = FALSE
	to_chat(usr, "You toggle the stabilization [stabilization_on? "on":"off"].")

	//If your jetpack cuts out, you'll fall in a gravity area. Lets trigger that
	var/atom/movable/A = get_toplevel_atom() //Get what this jetpack is attached to, usually a mob or object
	if (A)
		//This is a hack. Future todo: Make mechas not utilize anchored
		if (istype(A, /mob/living/exosuit))
			A.anchored = FALSE

		var/turf/T = get_turf(A)
		if (T)
			T.fallThrough(A)
		//This proc will handle alll of the logic checks, like gravity, catwalks, other means of staying afloat,
		//And of course checking if the turf is actually a hole to fall through. We just fire it and let it do the hard work


	return TRUE

//Toggling does as little as possible, to make jetpacks more modular.
//All the work is done in the enable/disable procs
/obj/item/tank/jetpack/verb/toggle()
	set name = "Toggle Jetpack"
	set category = "Object"

	if(on)
		disable_thruster()
	else
		enable_thruster()

/obj/item/tank/jetpack/proc/enable_thruster()
	on = TRUE
	icon_state = "[icon_state]-on"
	trail.start()
	if (ismob(usr))
		var/mob/M = usr
		M.update_inv_back()
		M.update_action_buttons()
		to_chat(usr, "You toggle the thrusters [on? "on":"off"].")
	return TRUE

/obj/item/tank/jetpack/proc/disable_thruster()
	on = FALSE
	icon_state = initial(icon_state)
	trail.stop()
	if (ismob(usr))
		var/mob/M = usr
		M.update_inv_back()
		M.update_action_buttons()
		to_chat(usr, "You toggle the thrusters [on? "on":"off"].")

	return TRUE

/*****************************
	Thrust Handling
*****************************/
//Attempts to use up gas and returns true if it can
//Stabilization check is a somewhat hacky mechanic to handle an extra burst of gas for stabilizing, read below
/obj/item/tank/jetpack/proc/allow_thrust(num, mob/living/user, stabilization_check = FALSE)

	if(!(src.on))
		return FALSE

	if (!operational_safety(user))
		return FALSE

	if (!num)
		num = thrust_cost

	if(get_gas().total_moles < num)
		src.trail.stop()
		return FALSE

	//Setup a stabilize check, but only if this isn't already from one
	if (!stabilization_check)
		stabilize_done = FALSE
		addtimer(CALLBACK(src, .proc/stabilize, user, world.time), user.total_movement_delay()*1.5)

	var/datum/gas_mixture/G = get_gas().remove(num)

	//We've used some thrust. This will allow our trail to make a particle effect
	thrust_fx_done = FALSE

	var/allgases = G.gas["carbon_dioxide"] + G.gas["nitrogen"] + G.gas["oxygen"] + G.gas["plasma"]
	if(allgases >= 0.005)
		return TRUE

	//If we've run out of gas, turn off
	disable_stabilizer()
	disable_thruster()
	qdel(G)
	return TRUE

/*
	This stabilize proc serves two functions:
	1. When the user is trying to enable jetpack stabilisation, it ensures that they can.
	Including checking that they have enough thrust

	2. Every time the user does a normal move with the jetpack, it will run a short while after.
	If the user has stopped moving, then it will do a stabilising visual effect and deduct the cost
		This replaces an allow thrust call in human movement, meaning that stabilisation costs are only
		paid once, when you attempt to stop moving. And not with every step as previous

		stabilisation_on is still checked in human movement and used to prevent inertia. It will take
		some proper refactoring of the movement system to fix that

*/

/obj/item/tank/jetpack/proc/stabilize(mob/living/user, schedule_time, enable_stabilize = FALSE)
	//First up, lets check we still have the user and they're still wearing this jetpack

	if (!operational_safety(user))
		return 0


	//If we're not currently trying to turn stabilisation on, then we do some additional checks
	if (!enable_stabilize)
		//If this is true then this stabilisation is already resolved and paid for.
		if (stabilize_done)
			return FALSE

		//In that case it needs to be already turned on
		if (!stabilization_on)
			return FALSE

		//If the time since their last move is 50% more than their movement delay, then they've probably stopped
		if ((world.time - user.l_move_time) < user.total_movement_delay()*1.25)
			return FALSE

	//Ok now lets be sure we have enough gas to do stabilisation
	if (!allow_thrust(thrust_cost, user, stabilization_check = TRUE))
		return FALSE

	//Great, everything works fine, the user is now stable
	user.inertia_dir = 0


	//Lets do a little visual effect, a burst of thrust which opposes the user's last movement
	var/atom/E = trail.do_effect(get_step(user, user.last_move), user.last_move)
	E.offset_to(user, 14)

	stabilize_done = TRUE

	//A little rebound animation
	user.do_attack_animation(get_step(user, reverse_dir[user.last_move]), FALSE, 3)
	return TRUE

/*****************************
	Tank Interface
*****************************/
/*
	Although jetpacks are tanks, they can draw their air supply from another tank.
	Sometimes, like in the case of mechas, that tank is not a /obj/item/tank

	These functions provide a generic interface for different kinds of tanks
*/
/obj/item/tank/jetpack/proc/get_gas()
	RETURN_TYPE(/datum/gas_mixture)
	if (istype(gastank, /obj/item/tank))
		return gastank.air_contents


	if (istype(gastank, /obj/machinery/portable_atmospherics))
		var/obj/machinery/portable_atmospherics/canister/C = gastank
		return C.air_contents

	//Unknown type? Create and return an empty gas mixture to prevent runtime errors
	return new /datum/gas_mixture(0)

/*****************************
	Checks
*****************************/
//A check only version of the above, does not alter any values
/obj/item/tank/jetpack/proc/check_thrust(num = thrust_cost, mob/living/user as mob)
	if(!(src.on))
		return FALSE
	if((get_gas().total_moles < num))
		return FALSE

	return TRUE

//Safety checks for thrust and stabilisation are seperated into a seperate proc, for overriding
/obj/item/tank/jetpack/proc/operational_safety(mob/living/user)
	if (!user || loc != user)
		return FALSE
	return TRUE

/obj/item/tank/jetpack/ui_action_click()
	toggle()

/*******************************
	Rig jetpack
********************************/
/obj/item/tank/jetpack/rig
	name = "maneuvring jets"
	var/obj/item/rig/holder
	spawn_tags = null

//The rig jetpack uses the suit's gastank, this is set during the install proc for the rig module


/obj/item/tank/jetpack/rig/operational_safety(mob/living/user)
	if (!user || holder.loc != user)
		return FALSE
	return TRUE

/****************************
	SYNTHETIC JETPACK
*****************************/
//Refills by compressing air in the environment
/obj/item/tank/jetpack/synthetic
	name = "synthetic jetpack"
	desc = "A tank of compressed air for use as propulsion in zero-gravity areas. Has a built in compressor to refill it in any gaseous environment."
	default_pressure = 6*ONE_ATMOSPHERE	// kPa. Also the pressure the compressor would fill itself to
	default_gas = "carbon_dioxide"
	spawn_tags = null
	var/processing = FALSE
	var/compressing = FALSE
	var/minimum_pressure = 95 //KPa. If environment pressure is less than this, we won't draw air
	var/volume_rate = 0.25 //Used to adjust how quickly the jetpack refills
	var/datum/robot_component/jetpack/component

/obj/item/tank/jetpack/synthetic/toggle_rockets()
	set category = "Silicon Commands"
	.=..()

/obj/item/tank/jetpack/synthetic/toggle()
	set category = "Silicon Commands"
	.=..()

//Whenever we call a function that might use gas, we'll check if its time to start processing
/obj/item/tank/jetpack/synthetic/allow_thrust(num, mob/living/user, stabilization_check = FALSE)
	.=..(num, user, stabilization_check)
	if (!processing)
		//We'll allow a 5% leeway before we go into sucking mode, to prevent constant turning on and off
		if (get_gas().total_moles < (default_pressure*volume/(R_IDEAL_GAS_EQUATION*T20C)) * 0.95)
			processing = TRUE
			START_PROCESSING(SSobj, src)

/obj/item/tank/jetpack/synthetic/stabilize(mob/living/user, schedule_time, enable_stabilize = FALSE)
	.=..(user, schedule_time, enable_stabilize)
	if (!processing)
		if (get_gas().total_moles < (default_pressure*volume/(R_IDEAL_GAS_EQUATION*T20C)) * 0.95)
			processing = TRUE
			START_PROCESSING(SSobj, src)


/obj/item/tank/jetpack/synthetic/Process()
	if (!draw_air())
		stop_drawing()

/obj/item/tank/jetpack/synthetic/operational_safety(mob/living/user)
	if (!component || !component.powered)
		return FALSE
	return TRUE

//This process will constantly attempt to find a pressurised environment, and when it does, start sucking up air
//Until our tank is full enough
/obj/item/tank/jetpack/synthetic/proc/draw_air()
	var/turf/T = get_turf(src)
	if (!T)
		return
	var/datum/gas_mixture/environment = T.return_air()
	if (!environment)
		return

	var/pressure = environment.return_pressure()
	if (pressure < minimum_pressure)
		return

	//Ok we've got a sufficiently pressurised environment, now lets make sure we have the power
	var/mob/living/silicon/robot/R = get_holding_mob()
	if (!R)
		STOP_PROCESSING(SSobj, src)

	if (!operational_safety())
		return

	//We now start compressing.
	if (!compressing)
		playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
		to_chat(R, SPAN_NOTICE("Your [src] clicks as it starts drawing and compressing air to refill the tank"))

	compressing = TRUE
	//Setting this compressing var to true will cause the component to draw power

	var/transfer_moles = (volume_rate/environment.volume)*environment.total_moles
	var/datum/gas_mixture/transfer = environment.remove(transfer_moles)
	get_gas().add(transfer)
	if(get_gas().total_moles >= (default_pressure*volume/(R_IDEAL_GAS_EQUATION*T20C)))
		stop_drawing(TRUE)

	return TRUE

//Called whenever compression fails for some reason, or when it finishes and the tank is full
/obj/item/tank/jetpack/synthetic/proc/stop_drawing(complete = FALSE)
	if (compressing)
		playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
		var/mob/living/silicon/robot/R = get_holding_mob()
		to_chat(R, SPAN_NOTICE("Your [src] clicks as its internal compressor shuts off"))
	compressing = FALSE

	if (complete)
		STOP_PROCESSING(SSobj, src)
		processing = FALSE

//Returns the jetpack associated with this atom.
//Being an atom proc allows it to be overridden by non mob types, like mechas
//The user proc optionally allows us to state who we're getting it for.
	//This allows mechas to return a jetpack for the driver, but not the passengers
/atom/proc/get_jetpack(mob/user)
	return

/mob/living/carbon/human/get_jetpack(mob/user)

	//If we're inside something that's not a turf, then ask that thing for its jetpack instead
		//This generally means vehicles/mechs
	if (!istype(loc, /turf))
		return loc?.get_jetpack(src)

	// Search the human for a jetpack. Either on back or on a RIG that's on
	// on their back.
	if (istype(back, /obj/item/tank/jetpack))
		return back
	else if (istype(s_store, /obj/item/tank/jetpack))
		return s_store
	else if (istype(back, /obj/item/rig))
		var/obj/item/rig/rig = back
		for (var/obj/item/rig_module/maneuvering_jets/module in rig.installed_modules)
			return module.jets

/mob/living/silicon/robot/get_jetpack(mob/user)
	return jetpack

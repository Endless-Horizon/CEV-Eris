/**
	Energy weapon charge attack
	 - User holds down their attack button to charge their weapon
	 - Weapon begins charging, starting at 0% and ending at 100%
	 - Charge rate is determined both by the weapons standard charge rate, and the users vigilance rating. (gun.charge_rate+user.stats.getStat(STAT_VIG)*0.01
	 - User eleases mouse button, weapon fires
**/

/datum/firemode/charge
	var/datum/click_handler/charge/CH = null

/datum/firemode/charge/update(var/force_state = null)
	var/mob/living/L
	if (gun && gun.is_held())
		L = gun.loc

	var/enable = FALSE
	//Force state is used for forcing it to be disabled in circumstances where it'd normally be valid
	if (!isnull(force_state))
		enable = force_state
	else if (L && L.client)

		//First of all, lets determine whether we're enabling or disabling the click handler


		//We enable it if the gun is held in the user's active hand and the safety is off
		if (L.get_active_hand() == gun)
			//Lets also make sure it can fire
			var/can_fire = TRUE

			//Safety stops it
			if (gun.safety)
				can_fire = FALSE

			//Energy weapons need to have enough charge to fire
			if(istype(gun, /obj/item/gun/energy))
				var/obj/item/gun/energy/E = gun
				var/obj/item/cell/C = E.get_cell()
				if (!C || !C.check_charge(E.charge_cost))
					can_fire = FALSE

			//TODO: Centralise all this into some can_fire proc
			if (can_fire)
				enable = TRUE
		else
			enable = FALSE

	//Ok now lets set the desired state
	if (!enable)
		if (!CH)
			//If we're turning it off, but the click handler doesn't exist, then we have nothing to do
			return

		//Todo: make client click handlers into a list
		if (CH.owner) //Remove our handler from the client
			CH.owner.CH = null //wew
		QDEL_NULL(CH) //And delete it
		return

	else
		//We're trying to turn things on
		if (CH)
			return //The click handler exists, we dont need to do anything


		//Create and assign the click handler
		//A click handler intercepts mouseup/drag/down events which allow fullauto firing
		CH = new /datum/click_handler/charge()
		CH.reciever = gun //Reciever is the gun that gets the fire events
		L.client.CH = CH //Put it on the client
		CH.owner = L.client //And tell it where it is

/****************************
	Charge gun click handler
*****************************/

/datum/click_handler/charge
	handler_name = "charge mode"
	var/atom/target = null
	var/obj/item/gun/energy/reciever

/datum/click_handler/charge/Click()
	return TRUE //As we don't use the normal click, but the MouseDown/MouseUp, this function is not needed at all. This also bypasses the delete on use check

//Begin charging
/datum/click_handler/charge/MouseDown(object,location,control,params)
	reciever.begin_charge(owner.mob)

//Fire charged attack
/datum/click_handler/charge/MouseUp(object,location,control,params)
	object = resolve_world_target(object)
	if (object)
		var/atom/target = object
		target = object
		owner.mob.face_atom(target)
	reciever.release_charge(object, owner.mob)

/******************
	The actual code
******************/

/obj/item/gun/energy/proc/begin_charge(var/mob/living/user)
	to_chat(user, SPAN_NOTICE("You begin charging \the [src]."))
	overcharge_timer = addtimer(CALLBACK(src, .proc/add_charge, user), 1 SECONDS, TIMER_STOPPABLE)

/obj/item/gun/energy/proc/add_charge(var/mob/living/user)
	deltimer(overcharge_timer)
	if(get_holding_mob() == user && get_cell() && cell.checked_use(1))
		overcharge_level = min(overcharge_max, overcharge_level + get_overcharge_add(user))
		set_light(2, overcharge_level/2, "#ff0d00")
		if(overcharge_level < overcharge_max)
			overcharge_timer = addtimer(CALLBACK(src, .proc/add_charge, user), 1 SECONDS, TIMER_STOPPABLE)
		else
			visible_message(SPAN_NOTICE("\The [src] clicks."))
		return
	set_light(0)
	visible_message(SPAN_WARNING("\The [src] sputters out."))
	overcharge_level = 0

/obj/item/gun/energy/proc/get_overcharge_add(var/mob/living/user)
	return overcharge_rate+user.stats.getStat(STAT_VIG)*VIG_OVERCHARGE_GEN

/obj/item/gun/energy/proc/release_charge(var/atom/target, var/mob/living/user)
	deltimer(overcharge_timer)
	var/overcharge_add = overcharge_level_to_mult()
	damage_multiplier += overcharge_add
	penetration_multiplier += overcharge_add
	if(overcharge_level > 2 && cell.checked_use(overcharge_level))
		Fire(target, user)
	else
		visible_message(SPAN_WARNING("\The [src] sputters."))
	set_light(0)
	damage_multiplier -= overcharge_add
	penetration_multiplier -= overcharge_add
	overcharge_level = 0

/obj/item/gun/energy/proc/overcharge_level_to_mult()
	return overcharge_level/10

/obj/item/gun/energy/dropped(mob/user)
	..()
	if(overcharge_level)
		overcharge_level = 0
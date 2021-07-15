GLOBAL_LIST_EMPTY(rad_collectors)

/obj/machinery/power/rad_collector
	name = "radiation collector array"
	desc = "A device which uses Hawking Radiation and plasma to produce power."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "ca"
	anchored = FALSE
	density = TRUE
	req_access = list(access_engine_equip)

	var/obj/item/tank/plasma/P = null
	var/last_power = 0
	var/last_power_new = 0
	var/active = FALSE
	var/locked = FALSE
	var/drainratio = 1

/obj/machinery/power/rad_collector/Initialize()
	. = ..()
	GLOB.rad_collectors += src

/obj/machinery/power/rad_collector/Destroy()
	QDEL_NULL(P)
	GLOB.rad_collectors -= src
	return ..()

/obj/machinery/power/rad_collector/Process()
	//so that we don't zero out the meter if the SM is processed first.
	last_power = last_power_new
	last_power_new = 0


	if(P)
		if(P.air_contents.gas["plasma"] == 0)
			investigate_log("<font color='red'>out of fuel</font>.","singulo")
			eject()
		else
			P.air_contents.adjust_gas("plasma", -0.001*drainratio)
	return


/obj/machinery/power/rad_collector/attack_hand(mob/user)
	if(anchored)
		if(!locked)
			toggle_power()
			user.visible_message(
				SPAN_NOTICE("[user] turns [src] [active? "on" : "off"]."),
				SPAN_NOTICE("You turn [src] [active ? "on" : "off"].")
				)
			investigate_log("turned [active?"<font color='green'>on</font>":"<font color='red'>off</font>"] by [user.key]. [P?"Fuel: [round(P.air_contents.gas["plasma"]/0.29)]%":"<font color='red'>It is empty</font>"].","singulo")
		else
			to_chat(user, SPAN_WARNING("The controls are locked!"))
		return
	..()


/obj/machinery/power/rad_collector/attackby(obj/item/I, mob/user)

	var/list/usable_qualities = list()
	if(P && !src.locked)
		usable_qualities.Add(QUALITY_PRYING)
	if(!P)
		usable_qualities.Add(QUALITY_BOLT_TURNING)

	var/tool_type = I.get_tool_type(user, usable_qualities, src)
	switch(tool_type)
		if(QUALITY_PRYING)
			if(P && !locked)
				if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					eject()
			return

		if(QUALITY_BOLT_TURNING)
			if(!P)
				if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					anchored = !anchored
					user.visible_message(
						SPAN_NOTICE("[user] [anchored ? "secures" : "unsecures"] [src]."),
						SPAN_NOTICE("You [anchored ? "secure" : "undo"] the external bolts."),
						"You hear a ratchet")
					if(anchored)
						connect_to_network()
					else
						disconnect_from_network()
			return

		if(ABORT_CHECK)
			return

	if(istype(I, /obj/item/tank/plasma))
		if(!anchored)
			to_chat(user, SPAN_WARNING("[src] needs to be secured to the floor first."))
			return
		if(P)
			to_chat(user, SPAN_WARNING("[src] already has a plasma tank loaded."))
			return
		user.drop_item()
		P = I
		I.forceMove(src)
		update_icons()
		return

	else if(istype(I, /obj/item/card/id)||istype(I, /obj/item/modular_computer))
		if(allowed(user))
			if(active)
				locked = !locked
				to_chat(user, SPAN_NOTICE("The controls are now [locked ? "locked" : "unlocked"]."))
			else
				locked = FALSE //just in case it somehow gets locked
				to_chat(user, SPAN_WARNING("The controls can only be locked when [src] is active."))
		else
			to_chat(user, SPAN_WARNING("Access denied!"))
		return
	return ..()

/obj/machinery/power/rad_collector/examine(mob/user)
	if(..())
		to_chat(user, "The meter indicates that [src] is collecting [last_power] W.")

/obj/machinery/power/rad_collector/ex_act(severity)
	switch(severity)
		if(2, 3)
			eject()
	return ..()


/obj/machinery/power/rad_collector/proc/eject()
	locked = FALSE
	if (!P)
		return
	P.forceMove(drop_location())
	P = null
	if(active)
		toggle_power()
	else
		update_icons()

/obj/machinery/power/rad_collector/proc/receive_pulse(pulse_strength)
	if(P && active)
		var/power_produced = P.air_contents.gas["plasma"]*pulse_strength*20
		add_avail(power_produced)
		last_power_new = power_produced


/obj/machinery/power/rad_collector/proc/update_icons()
	cut_overlays()
	if(P)
		add_overlays("ptank")
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		add_overlays("on")


/obj/machinery/power/rad_collector/proc/toggle_power()
	active = !active
	if(active)
		icon_state = "ca_on"
		FLICK("ca_active", src)
	else
		icon_state = "ca"
		FLICK("ca_deactive", src)
	update_icons()

/obj/machinery/power/rad_collector/anchored
	anchored = TRUE

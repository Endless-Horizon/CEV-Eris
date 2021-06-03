// Powersink - used to drain station power

/obj/item/device/powersink
	name = "power sink"
	desc = "A nulling power sink which drains energy from electrical systems."
	icon_state = "powersink0"
	item_state = "electronic"
	w_class = ITEM_SIZE_BULKY
	flags = CONDUCT
	throwforce = WEAPON_FORCE_PAINFUL
	throw_speed = 1
	throw_range = 2
	spawn_blacklisted = TRUE

	matter = list(MATERIAL_PLASTIC = 8, MATERIAL_STEEL = 8, MATERIAL_GLASS = 3)

	origin_tech = list(TECH_POWER = 3, TECH_COVERT = 5)
	var/drain_rate = 1500000		// amount of power to drain per tick
	var/apc_drain_rate = 5000 		// Max. amount drained from single APC. In Watts.
	var/dissipation_rate = 20000	// Passive dissipation of drained power. In Watts.
	var/power_drained = 0 			// Amount of power drained.
	var/max_power = 5e9				// Detonation point.
	var/mode = 0					// 0 = off, 1=clamped (off), 2=operating
	var/drained_this_tick = 0		// This is unfortunately necessary to ensure we process powersinks BEFORE other machinery such as APCs.
	var/admins_warned = FALSE // stop spam, only warn the admins once that we are about to boom

	var/datum/powernet/PN			// Our powernet
	var/obj/structure/cable/attached		// the attached cable

/obj/item/device/powersink/Destroy()
	if(mode == 2)
		STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/device/powersink/attackby(obj/item/I, mob/user)
	if(QUALITY_SCREW_DRIVING in I.tool_qualities)
		if(I.use_tool(user, src, WORKTIME_FAST, QUALITY_SCREW_DRIVING, FAILCHANCE_EASY, required_stat = STAT_MEC))
			if(mode == 0)
				var/turf/T = loc
				if(isturf(T) && !!T.is_plating())
					attached = locate() in T
					if(!attached)
						to_chat(user, "No exposed cable here to attach to.")
						return
					else
						anchored = TRUE
						mode = 1
						src.visible_message(SPAN_NOTICE("[user] attaches [src] to the cable!"))
						return
				else
					to_chat(user, "Device must be placed over an exposed cable to attach to it.")
					return
			else
				if (mode == 2)
					STOP_PROCESSING(SSobj, src)
				anchored = FALSE
				mode = 0
				src.visible_message(SPAN_NOTICE("[user] detaches [src] from the cable!"))
				set_light(0)
				icon_state = "powersink0"

				return
	else
		..()

/obj/item/device/powersink/attack_ai()
	return

/obj/item/device/powersink/attack_hand(var/mob/user)
	switch(mode)
		if(0)
			..()
		if(1)
			src.visible_message(SPAN_NOTICE("[user] activates [src]!"))
			mode = 2
			icon_state = "powersink1"
			START_PROCESSING(SSobj, src)
		if(2)  //This switch option wasn't originally included. It exists now. --NeoFite
			src.visible_message(SPAN_NOTICE("[user] deactivates [src]!"))
			mode = 1
			set_light(0)
			icon_state = "powersink0"
			STOP_PROCESSING(SSobj, src)

/obj/item/device/powersink/pwr_drain()
	if(!attached)
		return 0

	if(drained_this_tick)
		return 1
	drained_this_tick = 1

	var/drained = 0

	if(!PN)
		return 1

	set_light(12)
	PN.trigger_warning()
	// found a powernet, so drain up to max power from it
	drained = PN.draw_power(drain_rate)
	// if tried to drain more than available on powernet
	// now look for APCs and drain their cells
	if(drained < drain_rate)
		for(var/obj/machinery/power/terminal/T in PN.nodes)
			// Enough power drained this tick, no need to torture more APCs
			if(drained >= drain_rate)
				break
			if(istype(T.master, /obj/machinery/power/apc))
				var/obj/machinery/power/apc/A = T.master
				if(A.operating && A.cell)
					var/cur_charge = A.cell.charge / CELLRATE
					var/drain_val = min(apc_drain_rate, cur_charge)
					A.cell.use(drain_val * CELLRATE)
					drained += drain_val
	power_drained += drained
	return 1


/obj/item/device/powersink/process()
	drained_this_tick = 0
	power_drained -= min(dissipation_rate, power_drained)
	if(power_drained > max_power * 0.95)
		if (!admins_warned)
			admins_warned = TRUE
			message_admins("Power sink at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>) is 95% full. Explosion imminent.")
		playsound(src, 'sound/effects/screech.ogg', 100, TRUE, TRUE)
	if(power_drained >= max_power)
		STOP_PROCESSING(SSobj, src)
		explosion(src.loc, 3,6,9,12)
		qdel(src)
		return
	if(attached && attached.powernet)
		PN = attached.powernet
	else
		PN = null

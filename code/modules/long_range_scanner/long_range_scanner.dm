#define EVENT_ENABLED           3
#define EVENT_DISABLED          4
#define EVENT_RECONFIGURED      5
#define PASSIVE_SCAN_RANGE      3
#define PASSIVE_SCAN_PERIOD     3 SECONDS
#define PULSE_PROGRESS_TIME    30  // in decisecond

var/list/ship_scanners = list()

/obj/machinery/power/long_range_scanner
	name = "long range scanner"
	desc = "An advanced long range scanner with heavy-duty capacitor, capable of scanning celestial anomalies at large distances."
	icon = 'icons/obj/machines/conduit_of_soul.dmi'
	icon_state = "core_inactive"
	density = TRUE
	anchored = FALSE

	circuit = /obj/item/weapon/electronics/circuitboard/long_range_scanner



	var/needs_update = FALSE //If true, will update in process

	var/datum/wires/long_range_scanner/wires
	var/list/event_log = list()			// List of relevant events for this shield
	var/max_log_entries = 200			// A safety to prevent players generating endless logs and maybe endangering server memory

	var/scanner_modes = 0				// Enabled scanner mode flags
	var/scan_range = 2					// Scan range on the overmap

	var/max_energy = 0					// Maximal stored energy. In joules. Depends on the type of used SMES coil when constructing this scanner.
	var/current_energy = 0				// Current stored energy.
	var/running = SCANNER_OFF			// Whether the scanner is enabled or not.
	var/input_cap = 1 MEGAWATTS			// Currently set input limit. Set to 0 to disable limits altogether. The shield will try to input this value per tick at most
	var/upkeep_power_usage = 0			// Upkeep power usage last tick.
	var/power_usage = 0					// Total power usage last tick.
	var/overloaded = 0					// Whether the field has overloaded and shut down to regenerate.
	var/offline_for = 0					// The scanner will be inoperable for this duration in ticks.
	var/input_cut = 0					// Whether the input wire is cut.
	var/mode_changes_locked = 0			// Whether the control wire is cut, locking out changes.
	var/ai_control_disabled = 0			// Whether the AI control is disabled.
	var/emergency_shutdown = FALSE		// Whether the scanner is currently recovering from an emergency shutdown
	var/list/default_modes = list()
	var/generatingShield = FALSE //true when shield tiles are in process of being generated

	var/obj/effect/overmap/ship/linked_ship = null // To access position of Eris on the overmap

	var/list/tendrils = list()
	var/list/tendril_dirs = list(NORTH, EAST, WEST)
	var/tendrils_deployed = FALSE				// Whether the dummy capacitors are currently extended


/obj/machinery/power/long_range_scanner/on_update_icon()
	cut_overlays()
	if(running)
		set_light(1, 1, "#82C2D8")
		SetIconState("core_warmup")
		spawn(20)
			set_light(2, 2, "#82C2D8")
			SetIconState("core_active")
	else
		set_light(1, 1, "#82C2D8")
		SetIconState("core_shutdown")
		spawn(20)
			set_light(0)
			SetIconState("core_inactive")

	for (var/obj/machinery/scanner_conduit/S in tendrils)
		if (running)
			S.dim_light()
			S.SetIconState("warmup")
			S.update_icon()
			spawn(20)
				S.bright_light()
				S.SetIconState("speen")
				S.update_icon()

		else
			S.dim_light()
			S.SetIconState("shutdown")
			S.update_icon()
			spawn(20)
				S.no_light()
				S.SetIconState("inactive")
				S.update_icon()


/obj/machinery/power/long_range_scanner/Initialize()
	. = ..()
	connect_to_network()
	wires = new(src)
	ship_scanners += src
	var/obj/effect/overmap/ship/S = map_sectors["[z]"]
	if(istype(S))
		S.scanners |= src

	// Link to Eris object on the overmap
	linked_ship = locate(/obj/effect/overmap/ship/eris)


/obj/machinery/power/long_range_scanner/Destroy()
	toggle_tendrils(FALSE)
	QDEL_NULL(wires)
	ship_scanners -= src
	var/obj/effect/overmap/ship/S = map_sectors["[z]"]
	if(istype(S))
		S.scanners -= src
	. = ..()


/obj/machinery/power/long_range_scanner/RefreshParts()
	max_energy = 0
	for(var/obj/item/weapon/stock_parts/smes_coil/S in component_parts)
		max_energy += (S.ChargeCapacity / CELLRATE)
	current_energy = between(0, current_energy, max_energy)


// Shuts down the shield, removing all shield segments and unlocking generator settings.
/obj/machinery/power/long_range_scanner/proc/shutdown_scanner()
	running = SCANNER_OFF
	update_icon()


/obj/machinery/power/long_range_scanner/Process()
	upkeep_power_usage = 0
	power_usage = 0

	if (!anchored)
		return
	if(offline_for)
		offline_for = max(0, offline_for - 1)
		if (offline_for <= 0)
			emergency_shutdown = FALSE

	// We are shutting down, therefore our stored energy disperses faster than usual.
	else if(running == SCANNER_DISCHARGING)
		if (offline_for <= 0)
			shutdown_scanner() //We've finished the winding down period and now turn off
			offline_for += 30 //Another minute before it can be turned back on again
		return

	upkeep_power_usage = ENERGY_UPKEEP_SCANNER

	if(powernet && !input_cut && (running == SCANNER_RUNNING || running == SCANNER_OFF))
		var/energy_buffer = 0
		energy_buffer = draw_power(min(upkeep_power_usage, input_cap))
		power_usage += round(energy_buffer)

		if(energy_buffer < upkeep_power_usage)
			current_energy -= round(upkeep_power_usage - energy_buffer)	// If we don't have enough energy from the grid, take it from the internal battery instead.

		// Now try to recharge our internal energy.
		var/energy_to_demand
		if(input_cap)
			energy_to_demand = between(0, max_energy - current_energy, input_cap - upkeep_power_usage)
		else
			energy_to_demand = max(0, max_energy - current_energy)
		energy_buffer = draw_power(energy_to_demand)
		power_usage += energy_buffer
		current_energy += round(energy_buffer)
	else
		current_energy -= round(upkeep_power_usage)	// We are shutting down, or we lack external power connection. Use energy from internal source instead.

	if(current_energy <= 0)
		energy_failure()

	if (charge_level() > 5)
		overloaded = 0


/obj/machinery/power/long_range_scanner/attackby(obj/item/O as obj, mob/user as mob)
	// Prevents dismantle-rebuild tactics to reset the emergency shutdown timer.
	if(running)
		to_chat(user, "Turn off \the [src] first!")
		return
	if(offline_for)
		to_chat(user, "Wait until \the [src] cools down from emergency shutdown first!")
		return

	if(default_deconstruction(O, user))
		return
	if(default_part_replacement(O, user))
		return

	//TODO: Implement unwrenching in a proper centralised location. Having to copypaste this around sucks
	if(QUALITY_BOLT_TURNING in O.tool_qualities)
		wrench(user, O)
		return

	if(istool(O))
		return src.attack_hand(user)


/obj/machinery/power/long_range_scanner/proc/energy_failure()
	if(running == SCANNER_DISCHARGING)
		shutdown_scanner()
	else
		if (current_energy < 0)
			current_energy = 0
		overloaded = 1


/obj/machinery/power/long_range_scanner/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	var/data[0]

	data["running"] = running
	data["logs"] = get_logs()
	data["overloaded"] = overloaded
	data["max_energy"] = round(max_energy / 1000000, 0.1)
	data["current_energy"] = round(current_energy / 1000000, 0.1)
	data["input_cap_kw"] = round(input_cap / 1000)
	data["upkeep_power_usage"] = round(upkeep_power_usage / 1000, 0.1)
	data["power_usage"] = round(power_usage / 1000)
	data["offline_for"] = offline_for * 2
	data["shutdown"] = emergency_shutdown


	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "lrscanner.tmpl", src.name, 650, 800)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)


/obj/machinery/power/long_range_scanner/attack_hand(var/mob/user)
	nano_ui_interact(user)
	if(panel_open)
		wires.Interact(user)


/obj/machinery/power/long_range_scanner/CanUseTopic(var/mob/user)
	if(issilicon(user) && !Adjacent(user) && ai_control_disabled)
		return STATUS_UPDATE
	return ..()


/obj/machinery/power/long_range_scanner/Topic(href, href_list)
	if(..())
		return 1
	if(!anchored)
		return
	//Doesn't respond while disabled
	if(offline_for)
		return

	if(href_list["begin_shutdown"])
		if(running != SCANNER_RUNNING)
			return
		running = SCANNER_DISCHARGING
		offline_for += 30 //It'll take one minute to shut down
		. = 1
		log_event(EVENT_DISABLED, src)

	if(href_list["start_generator"])
		running = SCANNER_RUNNING
		update_icon()
		log_event(EVENT_ENABLED, src)
		offline_for = 3 //This is to prevent cases where you startup the shield and then turn it off again immediately while spamclicking
		. = 1

	// Instantly drops the shield, but causes a cooldown before it may be started again. Also carries a risk of EMP at high charge.
	if(href_list["emergency_shutdown"])
		if(!running)
			return

		var/choice = input(usr, "Are you sure that you want to initiate an emergency shutdown? This will instantly power off the long range scanner, and may result in unstable release of stored electromagnetic energy. Proceed at your own risk.") in list("Yes", "No")
		if((choice != "Yes") || !running)
			return

		var/temp_integrity = charge_level()

		offline_for += 300 //5 minutes, given that procs happen every 2 seconds
		shutdown_scanner()
		emergency_shutdown = TRUE
		log_event(EVENT_DISABLED, src)
		if(prob(temp_integrity - 50) * 1.75)
			spawn()
				empulse(src, 7, 14)
		. = 1

	if(mode_changes_locked || offline_for)
		return 1

	if(href_list["set_input_cap"])
		var/new_cap = round(input(usr, "Enter new input cap (in kW). Enter 0 or nothing to disable input cap.", "Generator Power Control", round(input_cap / 1000)) as num)
		if(!new_cap)
			input_cap = 0
			return
		input_cap = max(0, new_cap) * 1000
		log_event(EVENT_RECONFIGURED, src)
		. = 1

	nano_ui_interact(usr)

/obj/machinery/power/long_range_scanner/proc/charge_level()
	if(max_energy)
		return (current_energy / max_energy) * 100
	return 0


// Checks whether specific flags are enabled
/obj/machinery/power/long_range_scanner/proc/check_flag(var/flag)
	return (scanner_modes & flag)


/obj/machinery/power/long_range_scanner/proc/get_logs()
	var/list/all_logs = list()
	for(var/i = event_log.len; i > 1; i--)
		all_logs.Add(list(list(
			"entry" = event_log[i]
		)))
	return all_logs


/obj/machinery/power/long_range_scanner/proc/wrench(var/user, var/obj/item/O)
	if(O.use_tool(user, src, WORKTIME_FAST, QUALITY_BOLT_TURNING, FAILCHANCE_EASY,  required_stat = STAT_MEC))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
		if(anchored)
			to_chat(user, SPAN_NOTICE("You unsecure the [src] from the floor!"))
			anchored = FALSE
		else
			if(istype(get_turf(src), /turf/space)) return //No wrenching these in space!
			to_chat(user, SPAN_NOTICE("You secure the [src] to the floor!"))
			anchored = TRUE
		return

//This proc keeps an internal log of shield impacts, activations, deactivations, and a vague log of config changes
/obj/machinery/power/long_range_scanner/proc/log_event(var/event_type, var/atom/origin_atom)
	var/logstring = "[stationtime2text()]: "
	switch (event_type)

		if (EVENT_ENABLED to EVENT_RECONFIGURED)
			switch (event_type)
				if (EVENT_ENABLED)
					logstring += "Shield powered up"
				if (EVENT_DISABLED)
					logstring += "Shield powered down"
				if (EVENT_RECONFIGURED)
					logstring += "Configuration altered"
				else
					return

			if (origin_atom == src)
				logstring += " via Physical Access"
			else
				logstring += " from console at"
				var/area/A = get_area(origin_atom)
				if (A)
					logstring += " [strip_improper(A.name)]"
				else
					logstring += " Unknown Area"

				if (origin_atom)
					logstring += ", [origin_atom.x ? origin_atom.x : "unknown"],[origin_atom.y ? origin_atom.y : "unknown"],[origin_atom.z ? origin_atom.z : "unknown"]"


	if (logstring != "")
		//Insert this string into the log
		event_log.Add(logstring)

		//If we're over the limit, cut the oldest entry
		if (event_log.len > max_log_entries)
			event_log.Cut(1,2)

/obj/machinery/scanner_conduit
	name = "scanner conduit"
	icon = 'icons/obj/machines/conduit_of_soul.dmi'
	icon_state = "inactive"
	desc = "A combined conduit and capacitor that transfers and stores massive amounts of energy."
	density = TRUE
	anchored = FALSE //Will be set true just after deploying
	var/obj/machinery/power/long_range_scanner/scanner

/obj/machinery/scanner_conduit/proc/connect(sca)
	scanner = sca

/obj/machinery/scanner_conduit/proc/no_light()
	set_light(0)

/obj/machinery/scanner_conduit/proc/dim_light()
	set_light(1, 1, "#82C2D8")

/obj/machinery/scanner_conduit/proc/bright_light()
	set_light(2, 2, "#82C2D8")

/obj/machinery/scanner_conduit/Destroy()
	if(scanner)
		scanner.toggle_tendrils(FALSE)
		if(scanner.running != SCANNER_OFF && !scanner.emergency_shutdown)
			scanner.offline_for += 300
			scanner.shutdown_scanner()
			scanner.emergency_shutdown = TRUE
			scanner.log_event(EVENT_DISABLED, scanner)
	. = ..()

/obj/machinery/power/long_range_scanner/wrench(user, obj/item/I)
	if(running != SCANNER_OFF)
		to_chat(usr, SPAN_NOTICE("Scanner has to be toggled off first!"))
		return
	if(tendrils_deployed)
		to_chat(usr, SPAN_NOTICE("Retract conduits first!"))
		return
	if(I.use_tool(user, src, WORKTIME_FAST, QUALITY_BOLT_TURNING, FAILCHANCE_EASY,  required_stat = STAT_MEC))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
		if(anchored)
			to_chat(user, SPAN_NOTICE("You unsecure the [src] from the floor!"))
			toggle_tendrils(FALSE)
			anchored = FALSE
		else
			if(istype(get_turf(src), /turf/space)) return //No wrenching these in space!
			to_chat(user, SPAN_NOTICE("You secure the [src] to the floor!"))
			anchored = TRUE
		return

/obj/machinery/power/long_range_scanner/verb/toggle_tendrils_verb()
	set category = "Object"
	set name = "Toggle conduits"
	set src in view(1)

	if(running != SCANNER_OFF)
		to_chat(usr, SPAN_NOTICE("Scanner has to be toggled off first!"))
		return
	toggle_tendrils()

/obj/machinery/power/long_range_scanner/proc/toggle_tendrils(on = null)
	var/target_state
	if (!isnull(on))
		target_state = on
	else
		target_state = tendrils_deployed ? FALSE : TRUE //Otherwise we're toggling

	if (target_state == tendrils_deployed)
		return
	//If we're extending them
	if (target_state == TRUE)
		for (var/D in tendril_dirs)
			var/turf/T = get_step(src, D)
			var/obj/machinery/scanner_conduit/SC = locate(/obj/machinery/scanner_conduit) in T
			if(SC)
				continue
			if (!turf_clear(T))
				visible_message(SPAN_DANGER("The [src] buzzes an insistent warning as it lacks the space to deploy"))
				playsound(src.loc, "/sound/machines/buzz-two", 100, 1, 5)
				tendrils_deployed = FALSE
				update_icon()
				return FALSE

		//Now deploy
		for (var/D in tendril_dirs)
			var/turf/T = get_step(src, D)
			var/obj/machinery/scanner_conduit/SC = locate(/obj/machinery/scanner_conduit) in T
			if(!SC) SC = new(T)
			SC.connect(src)
			tendrils.Add(SC)
			SC.face_atom(src)
			SC.anchored = TRUE
		tendrils_deployed = TRUE
		update_icon()

		to_chat(usr, SPAN_NOTICE("You deployed [src] conduits."))
		return TRUE

	else if (target_state == FALSE)
		for (var/obj/machinery/scanner_conduit/SC in tendrils)
			tendrils.Remove(SC)
			qdel(SC)
		tendrils_deployed = FALSE
		update_icon()

		to_chat(usr, SPAN_NOTICE("You retracted [src] conduits."))
		return FALSE

/obj/machinery/power/long_range_scanner/proc/consume_energy_scan()
	if(current_energy > round(ENERGY_PER_SCAN))
		current_energy -= round(ENERGY_PER_SCAN)
		return TRUE
	return FALSE

#undef EVENT_ENABLED
#undef EVENT_DISABLED
#undef EVENT_RECONFIGURED

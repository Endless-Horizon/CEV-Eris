#define EVENT_DAMAGE_PHYSICAL 	0 //copied from shield_generator.dm
#define EVENT_DAMAGE_EM 		1
#define EVENT_DAMAGE_HEAT 		2
#define EVENT_ENABLED 			3
#define EVENT_DISABLED 			4
#define EVENT_RECONFIGURED		5

/datum/computer_file/program/shield_control
	filename = "shieldcontrol"
	filedesc = "Shield Control"
	nanomodule_path = /datum/nano_module/shield_control
	program_icon_state = "engine"
	extended_desc = "This program allows remote management of the hull shield generator. Cannot be run on tablet computers."
	required_access = access_atmospherics
	requires_ntnet = 1
	network_destination = "shield control system"
	required_access = access_engine //Restricted to engineering and the bridge
	requires_ntnet_feature = NTNET_SYSTEMCONTROL
	usage_flags = PROGRAM_LAPTOP | PROGRAM_CONSOLE
	size = 24


/datum/nano_module/shield_control
	name = "Shield control"
	var/obj/machinery/power/shield_generator/hull/gen = null
	var/multigen = FALSE //Set true if multiple active hull shield generators are detected onstation
	var/genloc = ""//A string that describes the location of our connected shield generator

/datum/nano_module/shield_control/New()
	..()
	connect_to_generator()


/datum/nano_module/shield_control/proc/connect_to_generator()
	var/n = 0
	gen = null
	for (var/obj/machinery/power/shield_generator/hull/G in world)
		//Check that the generator is on the same vessel as us.
		//This allows antag ships/stations to have their own shield generators and consoles
		if (is_matching_vessel(G, nano_host()))
			if (G.anchored && G.tendrils_deployed) //Only look at those that are wrenched in and setup
				gen = G //It's a good enough candidate, we're connected!
				n++



	//If we found more than one compatible hull shield, something is wrong. We'll display a warning to the user about this
	if (n > 1)
		multigen = TRUE

	else
		multigen = FALSE

	//Lets describe the generator's location, this will be shown to the user. It will read something like
	if (istype(gen))
		playsound_host('sound/machines/chime.ogg', 50) //Sound for successfully connecting
		genloc += "Connected to: [gen.name] in "
		var/area/A = get_area(gen)
		if (A)
			genloc += "[strip_improper(A.name)] "
		else
			genloc += "Unknown Area "

		genloc += "at [gen.x],[gen.y],[gen.z]"

	else
		playsound_host('sound/machines/buzz-two.ogg', 50)
		genloc = ""

/datum/nano_module/shield_control/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = NANOUI_FOCUS, datum/topic_state/state = GLOB.default_state)
	if(!host)
		return
	var/list/data = host.initial_data()

	if (istype(gen))
		data["genloc"] = genloc
		data["running"] = gen.running
		data["modes"] = gen.get_flag_descriptions()
		data["logs"] = gen.get_logs()
		data["overloaded"] = gen.overloaded
		data["mitigation_max"] = gen.mitigation_max
		data["mitigation_physical"] = round(gen.mitigation_physical, 0.1)
		data["mitigation_em"] = round(gen.mitigation_em, 0.1)
		data["mitigation_heat"] = round(gen.mitigation_heat, 0.1)
		data["field_integrity"] = gen.field_integrity()
		data["max_energy"] = round(gen.max_energy / 1000000, 0.1)
		data["current_energy"] = round(gen.current_energy / 1000000, 0.1)
		data["total_segments"] = gen.field_segments ? gen.field_segments.len : 0
		data["functional_segments"] = gen.damaged_segments ? data["total_segments"] - gen.damaged_segments.len : data["total_segments"]
		data["field_radius"] = gen.field_radius
		data["input_cap_kw"] = round(gen.input_cap / 1000)
		data["upkeep_power_usage"] = round(gen.upkeep_power_usage / 1000, 0.1)
		data["power_usage"] = round(gen.power_usage / 1000)
		data["offline_for"] = gen.offline_for * 2
		data["shutdown"] = gen.emergency_shutdown
	else
		data["nogen"] = TRUE //Special flag so the template can tell between console and physical

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "shieldgen.tmpl", src.name, 600, 800, state = state)
		if(nano_host().update_layout()) // This is necessary to ensure the status bar remains updated along with rest of the UI.
			ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)


/datum/nano_module/shield_control/Topic(href, href_list)
	if(..())
		return

	if(href_list["connect"])
		connect_to_generator()
		. = 1
		return

	if (!gen || gen.ai_control_disabled || !gen.anchored)
		//Remote software control works the same as AI control.  Cutting that wire disables remote
		//If the generator has been unwrenched we also lose connection
		playsound_host('sound/machines/buzz-two.ogg', 50)
		gen = null //Cut our connection, and we'll be unable to reconnect
		return



	//Doesn't respond while disabled
	if (gen.offline_for)
		return

	if(href_list["begin_shutdown"])
		if(gen.running != SHIELD_RUNNING)
			return
		gen.running = SHIELD_DISCHARGING
		gen.log_event(EVENT_DISABLED, nano_host())
		gen.offline_for += 30 //It'll take one minute to shut down
		. = 1

	if(href_list["start_generator"])
		if(gen.offline_for)
			return
		gen.running = SHIELD_RUNNING
		gen.log_event(EVENT_ENABLED, nano_host())
		gen.regenerate_field()
		gen.offline_for = 3 //This is to prevent cases where you startup the shield and then turn it off again immediately while spamclicking

		. = 1

	// Instantly drops the shield, but causes a cooldown before it may be started again. Also carries a risk of EMP at high charge.
	if(href_list["emergency_shutdown"])
		if(!gen.running)
			return

		var/choice = input(usr, "Are you sure that you want to initiate an emergency shield shutdown? This will instantly drop the shield, and may result in unstable release of stored electromagnetic energy. Proceed at your own risk.") in list("Yes", "No")
		if((choice != "Yes") || !gen.running)
			return

		var/temp_integrity = gen.field_integrity()

		gen.offline_for += 300 //5 minutes, given that procs happen every 2 seconds
		gen.shutdown_field()
		gen.emergency_shutdown = TRUE
		gen.log_event(EVENT_DISABLED, nano_host())
		if(prob(temp_integrity - 50) * 1.75)
			spawn()
				empulse(gen, 7, 14)
		. = 1

	if(gen.mode_changes_locked)
		return 1

	if(href_list["set_range"])
		var/new_range = input(usr, "Enter new field range (1-[world.maxx]). Leave blank to cancel.", "Field Radius Control", gen.field_radius) as num
		if(!new_range)
			return
		gen.field_radius = between(1, new_range, world.maxx)
		gen.regenerate_field()
		gen.log_event(EVENT_RECONFIGURED, nano_host())
		. = 1

	if(href_list["set_input_cap"])
		var/new_cap = round(input(usr, "Enter new input cap (in kW). Enter 0 or nothing to disable input cap.", "Generator Power Control", round(gen.input_cap / 1000)) as num)
		if(!new_cap)
			gen.input_cap = 0
			return
		gen.input_cap = max(0, new_cap) * 1000
		gen.log_event(EVENT_RECONFIGURED, nano_host())
		. = 1

	if(href_list["toggle_mode"])
		gen.log_event(EVENT_RECONFIGURED, nano_host())
		gen.toggle_flag(text2num(href_list["toggle_mode"]))
		. = 1

	nano_ui_interact(usr)
/*




// If PC is not null header template is loaded. Use PC.get_header_data() to get relevant nanoui data from it. All data entries begin with "PC_...."
// In future it may be expanded to other modular computer devices.
/datum/nano_module/power_monitor/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS, var/datum/topic_state/state = default_state)
	var/list/data = host.initial_data()

	var/list/sensors = list()
	// Focus: If it remains null if no sensor is selected and UI will display sensor list, otherwise it will display sensor reading.
	var/obj/machinery/power/sensor/focus = null

	// Build list of data from sensor readings.
	for(var/obj/machinery/power/sensor/S in grid_sensors)
		sensors.Add(list(list(
		"name" = S.name_tag,
		"alarm" = S.check_grid_warning()
		)))
		if(S.name_tag == active_sensor)
			focus = S

	data["all_sensors"] = sensors
	if(focus)
		data["focus"] = focus.return_reading_data()

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "power_monitor.tmpl", "Power Monitoring Console", 800, 500, state = state)
		if(host.update_layout()) // This is necessary to ensure the status bar remains updated along with rest of the UI.
			ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

// Allows us to process UI clicks, which are relayed in form of hrefs.
/datum/nano_module/power_monitor/Topic(href, href_list)
	if(..())
		return 1
	if( href_list["clear"] )
		active_sensor = null
	if( href_list["refresh"] )
		refresh_sensors()
	else if( href_list["setsensor"] )
		active_sensor = href_list["setsensor"]*/
#undef EVENT_DAMAGE_PHYSICAL
#undef EVENT_DAMAGE_EM
#undef EVENT_DAMAGE_HEAT
#undef EVENT_ENABLED
#undef EVENT_DISABLED
#undef EVENT_RECONFIGURED

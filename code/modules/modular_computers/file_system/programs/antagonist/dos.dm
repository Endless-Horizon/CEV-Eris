/datum/computer_file/program/ntnet_dos
	filename = "relay_dos"
	filedesc = "DoS Traffic Generator"
	program_icon_state = "hostile"
	program_key_state = "security_key"
	program_menu_icon = "arrow-4-diag"
	extended_desc = "This script can perform denial of service attacks against quantum network relays. The system administrator will probably notice this. Multiple devices can run this program together against the same relay for increased effect"
	size = 20
	requires_ntnet = 1
	available_on_ntnet = 0
	available_on_syndinet = 1
	nanomodule_path = /datum/nano_module/program/computer_dos
	var/obj/machinery/ntnet_relay/target = null
	var/dos_speed = 0
	var/error = ""
	var/executed = 0

/datum/computer_file/program/ntnet_dos/process_tick()
	..()
	dos_speed = ntnet_speed * NTNETSPEED_DOS_AMPLIFICATION
	dos_speed *= (50 + operator_skill - STAT_LEVEL_BASIC) / 50
	if(target && executed)
		target.dos_overload += dos_speed
		if(!target.operable())
			target.dos_sources.Remove(src)
			target = null
			error = "Connection to destination relay lost."

/datum/computer_file/program/ntnet_dos/kill_program(forced = FALSE)
	if(target)
		target.dos_sources.Remove(src)
		target = null
	executed = 0

	..()

/datum/nano_module/program/computer_dos
	name = "DoS Traffic Generator"

/datum/nano_module/program/computer_dos/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS, var/datum/topic_state/state = GLOB.default_state)
	if(!ntnet_global)
		return
	var/datum/computer_file/program/ntnet_dos/PRG = program
	var/list/data = list()
	if(!istype(PRG))
		return
	data = PRG.get_header_data()

	if(PRG.error)
		data["error"] = PRG.error
	else if(PRG.target && PRG.executed)
		data["target"] = 1
		data["speed"] = PRG.dos_speed

		// The UI template uses this to draw a block of 1s and 0s, the more 1s the closer you are to overloading target
		// Combined with UI updates this adds quite nice effect to the UI
		data["completion_fraction"] = PRG.target.dos_overload / PRG.target.dos_capacity
	else
		var/list/relays = list()
		for(var/obj/machinery/ntnet_relay/R in ntnet_global.relays)
			relays.Add(R.uid)
		data["relays"] = relays
		data["focus"] = PRG.target ? PRG.target.uid : null

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "mpc_dos.tmpl", name, 500, 400, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/datum/computer_file/program/ntnet_dos/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["PRG_target_relay"])
		for(var/obj/machinery/ntnet_relay/R in ntnet_global.relays)
			if("[R.uid]" == href_list["PRG_target_relay"])
				target = R
		return 1
	if(href_list["PRG_reset"])
		if(target)
			target.dos_sources.Remove(src)
			target = null
		executed = 0
		error = ""
		return 1
	if(href_list["PRG_execute"])
		if(!target)
			return 1
		executed = 1
		target.dos_sources.Add(src)
		operator_skill = get_operator_skill(usr, STAT_COG)

		var/list/sources_to_show = list(computer.network_card.get_network_tag())
		var/extra_to_show = 2 * max(operator_skill - STAT_LEVEL_ADEPT, 0)
		if(extra_to_show)
			var/list/candidates = list()
			for(var/obj/item/modular_computer/C in SSobj.processing) // Apparently the only place these are stored.
				if(C.z in GetConnectedZlevels(computer.z))
					candidates += C
			for(var/i = 1, i <= extra_to_show, i++)
				var/obj/item/modular_computer/C = pick_n_take(candidates)
				sources_to_show += C.network_card.get_network_tag()

		if(ntnet_global.intrusion_detection_enabled)
			ntnet_global.add_log("IDS WARNING - Excess traffic flood targeting relay [target.uid] detected from [length(sources_to_show)] device\s: [english_list(sources_to_show)]")
			ntnet_global.intrusion_detection_alarm = 1
		return 1

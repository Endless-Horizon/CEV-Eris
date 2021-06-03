// This is special hardware configuration program.
// It is to be used only with modular computers.
// It allows you to toggle components of your device.

/datum/computer_file/program/computerconfig
	filename = "compconfig"
	filedesc = "Computer Configuration Tool"
	extended_desc = "This program allows configuration of computer's hardware"
	program_icon_state = "generic"
	program_key_state = "generic_key"
	program_menu_icon = "gear"
	unsendable = 1
	undeletable = 1
	size = 4
	available_on_ntnet = 0
	requires_ntnet = 0
	nanomodule_path = /datum/nano_module/program/computer_configurator/
	usage_flags = PROGRAM_ALL

/datum/nano_module/program/computer_configurator
	name = "NTOS Computer Configuration Tool"
	var/obj/item/modular_computer/movable = null

/datum/nano_module/program/computer_configurator/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS, var/datum/topic_state/state = GLOB.default_state)
	if(program)
		movable = program.computer
	if(!istype(movable))
		movable = null

	// No computer connection, we can't get data from that.
	if(!movable)
		return 0

	var/list/data = list()

	if(program)
		data = program.get_header_data()

	var/list/hardware = movable.get_all_components()

	data["disk_size"] = movable.hard_drive.max_capacity
	data["disk_used"] = movable.hard_drive.used_capacity
	data["power_usage"] = movable.last_power_usage
	data["battery_exists"] = movable.cell ? 1 : 0
	if(movable.cell)
		data["battery_rating"] = movable.cell.maxcharge
		data["battery_percent"] = round(movable.cell.percent())

	var/list/all_entries[0]
	for(var/obj/item/weapon/computer_hardware/H in hardware)
		all_entries.Add(list(list(
		"name" = H.name,
		"desc" = H.desc,
		"enabled" = H.enabled,
		"critical" = H.critical,
		"powerusage" = H.power_usage
		)))

	data["hardware"] = all_entries
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "mpc_configuration.tmpl", "NTOS Configuration Utility", 575, 700, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()

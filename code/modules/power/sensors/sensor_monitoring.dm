// POWERNET SENSOR MONITORING CONSOLE
// Connects to powernet sensors and loads data from them. Shows this data to the user.
// Newly supports NanoUI.


/obj/machinery/computer/power_monitor
	name = "Power Monitoring Console"
	desc = "Computer designed to remotely monitor power levels around the station"
	icon_keyboard = "power_key"
	icon_screen = "power_monitor"
	light_color = COLOR_LIGHTING_ORANGE_MACHINERY

	//computer stuff
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/weapon/electronics/circuitboard/powermonitor
	var/alerting = 0
	use_power = IDLE_POWER_USE
	idle_power_usage = 300
	active_power_usage = 300
	var/datum/nano_module/power_monitor/power_monitor

// Checks the sensors for alerts. If change (alerts cleared or detected) occurs, calls for icon update.
/obj/machinery/computer/power_monitor/Process()
	var/alert = check_warnings()
	if(alert != alerting)
		alerting = !alerting
		update_icon()

// Updates icon of this computer according to current status.
/obj/machinery/computer/power_monitor/on_update_icon()
	..()

	if(stat & BROKEN)
		icon_screen = "broken"
	else if(alerting)
		icon_screen = "power_monitor_warn"
	else
		icon_screen = "power_monitor"

// On creation automatically connects to active sensors. This is delayed to ensure sensors already exist.
/obj/machinery/computer/power_monitor/New()
	..()
	power_monitor = new(src)

// On user click opens the UI of this computer.
/obj/machinery/computer/power_monitor/attack_hand(mob/user)
	add_fingerprint(user)

	if(..())
		return
	nano_ui_interact(user)

// Uses dark magic to operate the NanoUI of this computer.
/obj/machinery/computer/power_monitor/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	power_monitor.nano_ui_interact(user, ui_key, ui, force_open)


// Verifies if any warnings were registered by connected sensors.
/obj/machinery/computer/power_monitor/proc/check_warnings()
	for(var/obj/machinery/power/sensor/S in power_monitor.grid_sensors)
		if(S.check_grid_warning())
			return 1
	return 0

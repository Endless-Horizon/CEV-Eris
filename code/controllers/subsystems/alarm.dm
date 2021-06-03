// We manually initialize the alarm handlers instead of looping over all existing types
// to make it possible to write: camera.triggerAlarm() rather than alarm_manager.managers[datum/alarm_handler/camera].triggerAlarm() or a variant thereof.
/var/global/datum/alarm_handler/atmosphere/atmosphere_alarm
/var/global/datum/alarm_handler/camera/camera_alarm
/var/global/datum/alarm_handler/fire/fire_alarm
/var/global/datum/alarm_handler/motion/motion_alarm
/var/global/datum/alarm_handler/power/power_alarm

SUBSYSTEM_DEF(alarm)
	name = "Alarm"
	wait = 2 SECONDS
	priority = FIRE_PRIORITY_ALARM
	init_order = INIT_ORDER_ALARM

	var/list/datum/alarm/all_handlers
	var/tmp/list/current = list()
	var/tmp/list/active_alarm_cache = list()

/datum/controller/subsystem/alarm/PreInit()
	atmosphere_alarm = new()
	camera_alarm = new()
	fire_alarm = new()
	motion_alarm = new()
	power_alarm = new()

/datum/controller/subsystem/alarm/Initialize(start_timeofday)
	all_handlers = list(atmosphere_alarm, camera_alarm, fire_alarm, motion_alarm, power_alarm)
	return ..()

/datum/controller/subsystem/alarm/fire(resumed = FALSE)
	if (!resumed)
		current = all_handlers.Copy()
		active_alarm_cache.Cut()

	while (current.len)
		var/datum/alarm_handler/AH = current[current.len]
		current.len--

		AH.Process()
		active_alarm_cache += AH.alarms

		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/alarm/stat_entry()
	..("[active_alarm_cache.len] alarm\s")

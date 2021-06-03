SUBSYSTEM_DEF(event)
	name = "Event Manager"
	wait = 2 SECONDS
	priority = FIRE_PRIORITY_EVENT

	var/tmp/list/processing_events = list()
	var/tmp/pos = EVENT_LEVEL_MUNDANE

	var/window_x = 700
	var/window_y = 600
	var/report_at_round_end = 0
	var/table_options = " align='center'"
	var/row_options1 = " width='85px'"
	var/row_options2 = " width='260px'"
	var/row_options3 = " width='150px'"
	var/datum/event_container/selected_event_container = null

	var/list/datum/event/active_events = list()
	var/list/datum/event/finished_events = list()

	var/list/datum/event/all_events


//Subsystem procs
/datum/controller/subsystem/event/Initialize(start_timeofday)
	if(!all_events)
		all_events = subtypesof(/datum/event)

	return ..()

/datum/controller/subsystem/event/Recover()
	active_events = SSevent.active_events
	finished_events = SSevent.finished_events
	all_events = SSevent.all_events

/datum/controller/subsystem/event/fire(resumed = FALSE)
	if (!resumed)
		processing_events = active_events.Copy()
		pos = EVENT_LEVEL_MUNDANE

	while (processing_events.len)
		var/datum/event/E = processing_events[processing_events.len]
		processing_events.len--

		E.Process()

		if (MC_TICK_CHECK)
			return


/datum/controller/subsystem/event/proc/event_complete(datum/event/E)
	active_events -= E

	if(!E.storyevent || !E.severity)	// datum/event is used here and there for random reasons, maintaining "backwards compatibility"
		log_debug("Event of '[E.type]' with missing meta-data has completed.")
		return

	finished_events += E



	log_debug("Event '[name]' has completed at [stationtime2text()].")

/datum/controller/subsystem/event/proc/RoundEnd()
	if(!report_at_round_end)
		return

	to_chat(world, "<br><br><br><font size=3><b>Random Events This Round:</b></font>")
	for(var/datum/event/E in active_events|finished_events)
		var/datum/storyevent/SE = E.storyevent
		if(!SE || SE.name == "Nothing")
			continue
		var/message = "'[SE.name]' began at [worldtime2stationtime(E.startedAt)] "
		if(E.isRunning)
			message += "and is still running."
		else
			if(E.endedAt - E.startedAt > MinutesToTicks(5)) // Only mention end time if the entire duration was more than 5 minutes
				message += "and ended at [worldtime2stationtime(E.endedAt)]."
			else
				message += "and ran to completion."

		to_chat(world, message)

/datum/controller/subsystem/event/stat_entry()
	..("E:[active_events.len]")

/datum/storyevent/electrical_storm
	id = "elec_storm"
	name = "Electrical Storm"


	event_type = /datum/event/electrical_storm
	event_pools = list(EVENT_LEVEL_MUNDANE = POOL_THRESHOLD_MUNDANE,
	EVENT_LEVEL_MODERATE = POOL_THRESHOLD_MODERATE)

	tags = list(TAG_SCARY, TAG_TARGETED, TAG_NEGATIVE)

////////////////////////////////////////////////

/datum/event/electrical_storm
	var/lightsoutAmount	= 1
	var/lightsoutRange	= 25


/datum/event/electrical_storm/announce()
	command_announcement.Announce("An electrical storm has been detected in your area, please repair potential electronic overloads.", "Electrical Storm Alert")


/datum/event/electrical_storm/start()
	switch(severity)
		if (EVENT_LEVEL_MUNDANE)
			lightsoutAmount = 2
		if (EVENT_LEVEL_MODERATE)
			lightsoutAmount = 5
	lightsout(TRUE, lightsoutAmount, lightsoutRange)


/proc/lightsout(isEvent = 0, lightsoutAmount = 1,lightsoutRange = 24) //leave lightsoutAmount as 0 to break ALL lights
	if(!isEvent)
		command_announcement.Announce("An Electrical storm has been detected in your area, please repair potential electronic overloads.","Electrical Storm Alert")

	if(lightsoutAmount)
		var/list/apcs = list()
		var/list/epicentreList = list()

		for(var/obj/machinery/power/apc/apc in GLOB.machines)
			if(is_valid_apc(apc))
				// Greatly reduce the chance for APCs in maintenance areas to be selected
				var/area/A = get_area(apc)
				if(!istype(A,/area/eris/maintenance) || prob(25))
					apcs += apc

		for(var/i=1, i <= lightsoutAmount, i++)
			if(apcs.len)
				var/picked = pick(apcs)
				epicentreList += picked
				apcs -= picked
			else
				break

		if(!epicentreList.len)
			return

		for(var/epicentre in epicentreList)
			log_and_message_admins("Electrical overload triggered at [jumplink(epicentre)],")
			for(var/obj/machinery/power/apc/apc in range(epicentre,lightsoutRange))
				if (prob(75))
					apc.overload_lighting()

	else
		for(var/obj/machinery/power/apc/apc in GLOB.machines)
			apc.overload_lighting()

	return


SUBSYSTEM_DEF(evac)
	name = "Evacuation"
	priority = FIRE_PRIORITY_EVAC
	//Initializes at default time
	flags = SS_TICKER | SS_BACKGROUND
	wait = 2 SECONDS

/datum/controller/subsystem/evac/Initialize(start_timeofday)
	evacuation_controller = new /datum/evacuation_controller/starship()
	evacuation_controller.set_up()
	return ..()

/datum/controller/subsystem/evac/fire()
	evacuation_controller.Process()

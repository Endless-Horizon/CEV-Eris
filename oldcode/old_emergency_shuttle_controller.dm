//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

// Controls the emergency shuttle

var/global/datum/emergency_shuttle_controller/emergency_shuttle

/datum/emergency_shuttle_controller
	var/list/escape_pods

	var/launch_time				//the time at which the shuttle will be launched
	var/lockdown_time			//how long pods stay opened, if evacuation will be cancelled
	var/auto_recall = FALSE		//if set, the shuttle will be auto-recalled
	var/auto_recall_time		//the time at which the shuttle will be auto-recalled
	var/autopilot = TRUE		//set to 0 to disable the shuttle automatically launching

	var/deny_shuttle = FALSE	//allows admins to prevent the shuttle from being called

	var/pods_departed = FALSE		//if the pods has left the vessel
	var/pods_armed = FALSE			//if the evacuation sequence is initiated
	var/pods_arrived = FALSE			//if the pods arrived to cencomm

	var/datum/announcement/priority/emergency_pods_launched = new(0, new_sound = sound('sound/misc/notice2.ogg'))
	var/datum/announcement/priority/emergency_pods_armed = new(0, new_sound = sound('sound/AI/shuttlecalled.ogg'))
	var/datum/announcement/priority/emergency_pods_unarmed = new(0, new_sound = sound('sound/AI/shuttlerecalled.ogg'))
	var/datum/announcement/priority/emergency_pods_unarmed_radio = new(0)

/datum/emergency_shuttle_controller/proc/process()
	if(pods_armed)
		if(auto_recall && world.time >= auto_recall_time)
			recall()
		if(world.time >= launch_time)	//time to launch the shuttle

			pods_departed = TRUE

			stop_launch_countdown()
			//launch the pods!
			emergency_pods_launched.Announce("The escape pods have just departed the ship.")

			for (var/datum/shuttle/ferry/escape_pod/pod in escape_pods)
				if (!pod.arming_controller || pod.arming_controller.armed)
					pod.launch(src)
		else
			if(round(estimate_prepare_time()) % 60 == 0 && round(estimate_prepare_time()) > 0)
				emergency_pods_unarmed_radio.Announce("An emergency evacuation sequence in progress. You have approximately [round(estimate_prepare_time()/60)] minutes to prepare for departure.")
	else
		if(world.time >= lockdown_time)
			for(var/datum/shuttle/ferry/escape_pod/pod in escape_pods)
				if(pod.arming_controller)
					pod.arming_controller.close_door()

//called when the pods is aarived to centcom
/datum/emergency_shuttle_controller/proc/pods_arrived()
	if(pods_departed)
		pods_arrived = TRUE

//begins the launch countdown and sets the amount of time left until launch
/datum/emergency_shuttle_controller/proc/set_launch_countdown(var/seconds)
	pods_armed = TRUE
	launch_time = world.time + seconds*10
	lockdown_time = 0

/datum/emergency_shuttle_controller/proc/stop_launch_countdown()
	pods_armed = FALSE

/datum/emergency_shuttle_controller/proc/set_lockdown_countdown(var/seconds)
	lockdown_time = world.time + seconds*10

//calls the shuttle for an emergency evacuation
/datum/emergency_shuttle_controller/proc/call_evac()
	if(!can_call()) return

	//set the launch timer
	autopilot = TRUE
	set_launch_countdown(PODS_PREPTIME)
	auto_recall_time = rand(world.time + 300, launch_time - 300)

	pods_armed = TRUE

	emergency_pods_armed.Announce("An emergency evacuation sequence has been started. You have approximately [round(estimate_prepare_time()/60)] minutes to prepare for departure.")
	for(var/area/A in world)
		if(istype(A, /area/hallway) || istype(A, /area/eris/hallway))
			A.readyalert()

	//arm the pods
	for(var/datum/shuttle/ferry/escape_pod/pod in escape_pods)
		if(pod.arming_controller)
			pod.arming_controller.arm()

//recalls the shuttle
/datum/emergency_shuttle_controller/proc/recall()
	if (!can_recall()) return

	pods_armed = FALSE

	for(var/area/A in world)
		if(istype(A, /area/hallway) || istype(A, /area/eris/hallway))
			A.readyreset()

	//unarm the pods
	for(var/datum/shuttle/ferry/escape_pod/pod in escape_pods)
		if(pod.arming_controller)
			pod.arming_controller.unarm()

	//close pod doors
	set_lockdown_countdown(PODS_LOCKDOWN)

	emergency_pods_unarmed.Announce("An emergency evacuation sequence has been canceled. You have approximately [round(lockdown_time - world.time) / 600] minutes to leave escape pods before they will be locked down.")

/datum/emergency_shuttle_controller/proc/can_call()
	if (!universe.OnShuttleCall(null))
		return FALSE
	if (deny_shuttle)
		return FALSE
	if (pods_departed)	//must be at ship
		return FALSE
	if (pods_armed)		//already launching
		return FALSE
	return TRUE

//this only returns 0 if it would absolutely make no sense to recall
//e.g. the shuttle is already at the station or wasn't called to begin with
//other reasons for the shuttle not being recallable should be handled elsewhere
/datum/emergency_shuttle_controller/proc/can_recall()
	if (pods_departed)	//too late
		return FALSE
	if (!pods_armed)	//we weren't going anywhere, anyways...
		return FALSE
	return TRUE

/datum/emergency_shuttle_controller/proc/get_shuttle_prep_time()
	// During mutiny rounds, the shuttle takes twice as long.
	/*if(ticker && ticker.mode)	//Pods do not need to prepare
		return SHUTTLE_PREPTIME * ticker.mode.shuttle_delay*/
	return PODS_PREPTIME


/*
	These procs are not really used by the controller itself, but are for other parts of the
	game whose logic depends on the emergency shuttle.
*/

//returns 1 if the shuttle is docked at the station and waiting to leave
/datum/emergency_shuttle_controller/proc/waiting_to_leave()
	return pods_armed && !pods_departed

//so we don't have emergency_shuttle.shuttle.location everywhere
/datum/emergency_shuttle_controller/proc/location()
	return !pods_arrived

//returns the time left until the shuttle arrives at it's destination, in seconds

/datum/emergency_shuttle_controller/proc/estimate_prepare_time()
	var/eta = launch_time
	return (eta - world.time)/10

//returns the time left until the shuttle launches, in seconds
/datum/emergency_shuttle_controller/proc/estimate_launch_time()
	return (launch_time - world.time)/10

/datum/emergency_shuttle_controller/proc/has_eta()
	return pods_armed

//returns 1 if the shuttle has gone to the station and come back at least once,
//used for game completion checking purposes
/datum/emergency_shuttle_controller/proc/returned()
	return pods_arrived

//returns 1 if the shuttle is not idle at centcom
/datum/emergency_shuttle_controller/proc/online()
	if (!pods_arrived && pods_armed)
		return TRUE
	return FALSE

//returns 1 if the shuttle is currently in transit (or just leaving) to the station
/*/datum/emergency_shuttle_controller/proc/going_to_station()
	return (!shuttle.direction && shuttle.moving_status != SHUTTLE_IDLE)*/

//returns 1 if the shuttle is currently in transit (or just leaving) to centcom
/datum/emergency_shuttle_controller/proc/going_to_centcom()
	return (pods_departed && !pods_arrived)


/datum/emergency_shuttle_controller/proc/get_status_panel_eta()
	if (!pods_departed)
		if (waiting_to_leave())

			var/timeleft = emergency_shuttle.estimate_launch_time()
			return "EPD-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]"

	return ""
/*
	Some slapped-together star effects for maximum spess immershuns. Basically consists of a
	spawner, an ender, and bgstar. Spawners create bgstars, bgstars shoot off into a direction
	until they reach a starender.
*/

/obj/effect/bgstar
	name = "star"
	var/speed = 10
	var/direction = SOUTH
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER

/obj/effect/bgstar/New()
	..()
	pixel_x += rand(-2, 30)
	pixel_y += rand(-2, 30)
	var/starnum = pick("1", "1", "1", "2", "3", "4")

	SetIconState("star"+starnum)

	speed = rand(2, 5)

/obj/effect/bgstar/proc/startmove()

	while(src)
		sleep(speed)
		step(src, direction)
		for(var/obj/effect/starender/E in loc)
			qdel(src)
			return

/obj/effect/starender
	invisibility = 101

/obj/effect/starspawner
	invisibility = 101
	var/spawndir = SOUTH
	var/spawning = FALSE

/obj/effect/starspawner/West
	spawndir = WEST

/obj/effect/starspawner/proc/startspawn()
	spawning = TRUE
	while(spawning)
		sleep(rand(2, 30))
		var/obj/effect/bgstar/S = new/obj/effect/bgstar(locate(x, y, z))
		S.direction = spawndir
		spawn()
			S.startmove()

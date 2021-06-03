var/list/escape_pods = list()
var/list/escape_pods_by_name = list()

/datum/shuttle/autodock/ferry/escape_pod
	var/obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod/controller_master
	var/datum/computer/file/embedded_program/docking/simple/escape_pod/arming_controller
	category = /datum/shuttle/autodock/ferry/escape_pod
	move_time = 100

/datum/shuttle/autodock/ferry/escape_pod/New()
	if(name in escape_pods_by_name)
		CRASH("An escape pod with the name '[name]' has already been defined.")
	move_time = evacuation_controller.evac_transit_delay + rand(-30, 60)
	escape_pods_by_name[name] = src
	escape_pods += src
	move_time = round(evacuation_controller.evac_transit_delay/10)

	..()

	arming_controller = active_docking_controller

	//find the pod's own controller
	var/master_tag = controller_master
	controller_master = locate(controller_master)
	if(!istype(controller_master))
		CRASH("Escape pod \"[name]\" could not find it's controller master tagged [master_tag]!")

	controller_master.pod = src
	arming_controller.pod = src

/datum/shuttle/autodock/ferry/escape_pod/can_launch()
	if(arming_controller && !arming_controller.armed)	//must be armed
		return FALSE
	if(location)
		return FALSE	//it's a one-way trip.
	return ..()

/datum/shuttle/autodock/ferry/escape_pod/can_force()
	return FALSE

/datum/shuttle/autodock/ferry/escape_pod/can_cancel()
	return FALSE


//This controller goes on the escape pod itself
/obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod
	name = "escape pod controller"
	var/datum/shuttle/autodock/ferry/escape_pod/pod
	progtype = /datum/computer/file/embedded_program/docking/simple/escape_pod

/obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	var/data[0]

	data = list(
		"docking_status" = docking_program.get_docking_status(),
		"override_enabled" = docking_program.override_enabled,
		"door_state" = 	docking_program.memory["door_status"]["state"],
		"door_lock" = 	docking_program.memory["door_status"]["lock"],
		"can_force" = pod.can_force() || (evacuation_controller.has_evacuated() && pod.can_launch()),	//allow players to manually launch ahead of time if the shuttle leaves
		"is_armed" = pod.arming_controller.armed,
	)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "escape_pod_console.tmpl", name, 470, 290)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod/Topic(user, href_list)
	/*if("manual_arm")
		pod.arming_controller.arm()
		return TOPIC_REFRESH*/

	if(href_list["force_launch"])
		if (pod.can_force())
			pod.force_launch(src)
		else if (evacuation_controller.has_evacuated() && pod.can_launch())	//allow players to manually launch ahead of time if the shuttle leaves
			pod.launch(src)
		return TOPIC_REFRESH

//This controller is for the escape pod berth (station side)
/obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod_berth
	name = "escape pod berth controller"
	progtype = /datum/computer/file/embedded_program/docking/simple/escape_pod

/obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod_berth/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	var/data[0]

	var/armed = null
	if (istype(docking_program, /datum/computer/file/embedded_program/docking/simple/escape_pod))
		var/datum/computer/file/embedded_program/docking/simple/escape_pod/P = docking_program
		armed = P.armed

	data = list(
		"docking_status" = docking_program.get_docking_status(),
		"override_enabled" = docking_program.override_enabled,
		"armed" = armed,
	)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "escape_pod_berth_console.tmpl", name, 470, 290)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/embedded_controller/radio/simple_docking_controller/escape_pod_berth/emag_act(var/remaining_charges, var/mob/user)
	if (!emagged)
		to_chat(user, "<span class='notice'>You emag the [src], arming the escape pod!</span>")
		emagged = 1
		if (istype(docking_program, /datum/computer/file/embedded_program/docking/simple/escape_pod))
			var/datum/computer/file/embedded_program/docking/simple/escape_pod/P = docking_program
			if (!P.armed)
				P.arm()
		return 1

//A docking controller program for a simple door based docking port
/datum/computer/file/embedded_program/docking/simple/escape_pod
	var/armed = FALSE
	var/datum/shuttle/autodock/ferry/escape_pod/pod

/datum/computer/file/embedded_program/docking/simple/escape_pod/proc/arm()
	if(!armed && pod)
		armed = TRUE

/datum/computer/file/embedded_program/docking/simple/escape_pod/receive_user_command(command)
	if (!armed)
		return
	..(command)



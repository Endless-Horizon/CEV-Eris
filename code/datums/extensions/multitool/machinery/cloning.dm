/datum/extension/multitool/cryo/get_interact_window(var/obj/item/tool/multitool/M, var/mob/user)
	. += buffer(M)
	. += "<HR><b>Connected Cloning Pods:</b><br>"
	var/obj/machinery/computer/cloning/C = holder
	for(var/atom/cloning_pod in C.pods)
		. += "[cloning_pod.name]<br>"

/datum/extension/multitool/cryo/receive_buffer(var/obj/item/tool/multitool/M, var/atom/buffer, var/mob/user)
	var/obj/machinery/clonepod/P = buffer
	var/obj/machinery/computer/cloning/C = holder

	if(!istype(P))
		to_chat(user, SPAN_WARNING("No valid connection data in \the [M] buffer."))
		return MT_NOACTION

	var/is_connected = (P in C.pods)
	if(!is_connected)
		if(C.connect_pod(P))
			to_chat(user, SPAN_NOTICE("You connect \the [P] to \the [C]."))
		else
			to_chat(user, SPAN_WARNING("You failed to connect \the [P] to \the [C]."))
		return MT_REFRESH

	if(C.release_pod(P))
		to_chat(user, SPAN_NOTICE("You disconnect \the [P] from \the [C]."))
	else
		to_chat(user, SPAN_NOTICE("You failed to disconnect \the [P] from \the [C]."))
	return MT_REFRESH

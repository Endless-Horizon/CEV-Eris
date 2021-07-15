/*
	Integrated circuits are essentially modular machines.  Each circuit has a specific function, and combining them inside Electronic Assemblies allows
a creative player the means to solve many problems.  Circuits are held inside an electronic assembly, and are wired using special tools.
*/

/obj/item/integrated_circuit
	matter = list(MATERIAL_PLASTIC = 1, MATERIAL_STEEL = 1)
	matter_reagents = list("silicon" = 5)

/obj/item/integrated_circuit/examine(mob/user)
	. = ..()
	external_examine(user)
	interact(user)


// This should be used when someone is examining while the case is opened.
/obj/item/integrated_circuit/proc/internal_examine(mob/user)
	to_chat(user, "This board has [inputs.len] input pin\s, [outputs.len] output pin\s and [activators.len] activation pin\s.")
	for(var/datum/integrated_io/input/I in inputs)
		if(I.linked.len)
			to_chat(user, "The '[I]' is connected to [I.get_linked_to_desc()].")
	for(var/datum/integrated_io/output/O in outputs)
		if(O.linked.len)
			to_chat(user, "The '[O]' is connected to [O.get_linked_to_desc()].")
	for(var/datum/integrated_io/activate/A in activators)
		if(A.linked.len)
			to_chat(user, "The '[A]' is connected to [A.get_linked_to_desc()].")
	any_examine(user)
	interact(user)

// This should be used when someone is examining from an 'outside' perspective, e.g. reading a screen or LED.
/obj/item/integrated_circuit/proc/external_examine(mob/user)
	any_examine(user)

/obj/item/integrated_circuit/proc/any_examine(mob/user)
	return

/obj/item/integrated_circuit/New()
	setup_io(inputs, /datum/integrated_io/input)
	setup_io(outputs, /datum/integrated_io/output)
	setup_io(activators, /datum/integrated_io/activate)
	..()

/obj/item/integrated_circuit/proc/on_data_written() //Override this for special behaviour when new data gets pushed to the circuit.
	return

/obj/item/integrated_circuit/Destroy()
	for(var/datum/integrated_io/I in inputs)
		qdel(I)
	for(var/datum/integrated_io/O in outputs)
		qdel(O)
	for(var/datum/integrated_io/A in activators)
		qdel(A)
	. = ..()

/obj/item/integrated_circuit/nano_host()
	if(istype(src.loc, /obj/item/device/electronic_assembly))
		var/obj/item/device/electronic_assembly/assembly = loc
		return assembly.resolve_nano_host()
	return ..()

/obj/item/integrated_circuit/emp_act(severity)
	for(var/datum/integrated_io/io in inputs + outputs + activators)
		io.scramble()

/obj/item/integrated_circuit/verb/rename_component()
	set name = "Rename Circuit"
	set category = "Object"
	set desc = "Rename your circuit, useful to stay organized."

	var/mob/M = usr
	if(!CanInteract(M,GLOB.physical_state))
		return

	var/input = sanitizeSafe(input("What do you want to name the circuit?", "Rename", src.name) as null|text, MAX_NAME_LEN)
	if(src && input && CanInteract(M,GLOB.physical_state))
		to_chat(M, SPAN_NOTICE("The circuit '[src.name]' is now labeled '[input]'."))
		name = input

/obj/item/integrated_circuit/interact(mob/user)
	if(!CanInteract(user,GLOB.physical_state))
		return

	var/window_height = 350
	var/window_width = 600

	//var/table_edge_width = "[(window_width - window_width * 0.1) / 4]px"
	//var/table_middle_width = "[(window_width - window_width * 0.1) - (table_edge_width * 2)]px"
	var/table_edge_width = "30%"
	var/table_middle_width = "40%"

	var/HTML = list()
	HTML += "<html><head><title>[src.name]</title></head><body>"
	HTML += "<div align='center'>"
	HTML += "<table border='1' style='undefined;table-layout: fixed; width: 80%'>"

	HTML += "<br><a href='?src=\ref[src];'>\[Refresh\]</a>  |  "
	HTML += "<a href='?src=\ref[src];rename=1'>\[Rename\]</a>  |  "
	HTML += "<a href='?src=\ref[src];scan=1'>\[Scan with Debugger\]</a>  |  "
	HTML += "<a href='?src=\ref[src];remove=1'>\[Remove\]</a><br>"

	HTML += "<colgroup>"
	HTML += "<col style='width: [table_edge_width]'>"
	HTML += "<col style='width: [table_middle_width]'>"
	HTML += "<col style='width: [table_edge_width]'>"
	HTML += "</colgroup>"

	var/column_width = 3
	var/row_height = max(inputs.len, outputs.len, 1)

	for(var/i = 1 to row_height)
		HTML += "<tr>"
		for(var/j = 1 to column_width)
			var/datum/integrated_io/io = null
			var/words = list()
			var/height = 1
			switch(j)
				if(1)
					io = get_pin_ref(IC_INPUT, i)
					if(io)
						if(io.linked.len)
							words += "<a href=?src=\ref[src];wire=1;pin=\ref[io]><b>[io.name] [io.display_data()]</b></a><br>"
							for(var/datum/integrated_io/linked in io.linked)
								words += "<a href=?src=\ref[src];wire=1;pin=\ref[io]>\[[linked.name]\]</a> \
								@ <a href=?src=\ref[linked.holder];examine=1;>[linked.holder]</a><br>"
						else
							words += "<a href=?src=\ref[src];wire=1;pin=\ref[io]>[io.name] [io.display_data()]</a><br>"
							for(var/datum/integrated_io/linked in io.linked)
								words += "<a href=?src=\ref[src];wire=1;pin=\ref[io]>\[[linked.name]\]</a> \
								@ <a href=?src=\ref[linked.holder];examine=1;>[linked.holder]</a><br>"
						if(outputs.len > inputs.len)
							height = 1
				if(2)
					if(i == 1)
						words += "[src.name]<br><br>[src.desc]"
						height = row_height
					else
						continue
				if(3)
					io = get_pin_ref(IC_OUTPUT, i)
					if(io)
						if(io.linked.len)
							words += "<a href=?src=\ref[src];wire=1;pin=\ref[io]><b>[io.name] [io.display_data()]</b></a><br>"
							for(var/datum/integrated_io/linked in io.linked)
								words += "<a href=?src=\ref[src];wire=1;pin=\ref[io]>\[[linked.name]\]</a> \
								@ <a href=?src=\ref[linked.holder];examine=1;user=\ref[user]>[linked.holder]</a><br>"
						else
							words += "<a href=?src=\ref[src];wire=1;pin=\ref[io]>[io.name] [io.display_data()]</a><br>"
							for(var/datum/integrated_io/linked in io.linked)
								words += "<a href=?src=\ref[src];wire=1;pin=\ref[io]>\[[linked.name]\]</a> \
								@ <a href=?src=\ref[linked.holder];examine=1;>[linked.holder]</a><br>"
						if(inputs.len > outputs.len)
							height = 1
			HTML += "<td align='center' rowspan='[height]'>[jointext(words, null)]</td>"
		HTML += "</tr>"

	for(var/activator in activators)
		var/datum/integrated_io/io = activator
		var/words = list()
		if(io.linked.len)
			words += "<a href=?src=\ref[src];wire=1;pin=\ref[io]><font color='FF0000'><b>[io.name]</b></font></a><br>"
			for(var/datum/integrated_io/linked in io.linked)
				words += "<a href=?src=\ref[src];wire=1;pin=\ref[io]>\[[linked.name]\]</a> \
				@ <a href=?src[src];examine=1;user=\ref[user]>[linked.holder]</a><br>"
		else
			words += "<a href=?src=\ref[src];wire=1;pin=\ref[io]><font color='FF0000'>[io.name]</font></a><br>"
			for(var/datum/integrated_io/linked in io.linked)
				words += "<a href=?src=\ref[src];wire=1;pin=\ref[io]>\[[linked.name]\]</a> \
				@ <a href=?src=\ref[linked.holder];examine=1;>[linked.holder]</a><br>"
		HTML += "<tr>"
		HTML += "<td colspan='3' align='center'>[jointext(words, null)]</td>"
		HTML += "</tr>"

	HTML += "</table>"
	HTML += "</div>"

	if(autopulse != -1)
		HTML += "<br><font color='33CC33'>Meta Variables;</font>"
		HTML += "<br><font color='33CC33'><a href='?src=\ref[src];autopulse=1'>\[Autopulse\]</a> = <b>[autopulse ? "ON" : "OFF"]</b></font>"
		HTML += "<br>"

	HTML += "<br><font color='0000AA'>Complexity: [complexity]</font>"
	if(power_draw_idle)
		HTML += "<br><font color='0000AA'>Power Draw: [power_draw_idle] W (Idle)</font>"
	if(power_draw_per_use)
		HTML += "<br><font color='0000AA'>Power Draw: [power_draw_per_use] W (Active)</font>" // Borgcode says that powercells' checked_use() takes joules as input.
	HTML += "<br><font color='0000AA'>[extended_desc]</font>"

	HTML += "</body></html>"
	user << browse(jointext(HTML, null), "window=circuit-\ref[src];size=[window_width]x[window_height];border=1;can_resize=1;can_close=1;can_minimize=1")

	onclose(user, "circuit-\ref[src]")

/obj/item/integrated_circuit/Topic(href, href_list, state =GLOB.physical_state)
	if(..())
		return 1
	var/pin = locate(href_list["pin"]) in inputs + outputs + activators

	var/obj/held_item = usr.get_active_hand()
	if(href_list["wire"])
		if(istype(held_item, /obj/item/device/electronics/integrated/wirer))
			var/obj/item/device/electronics/integrated/wirer/wirer = held_item
			if(pin)
				wirer.wire(pin, usr)

		else if(istype(held_item, /obj/item/device/electronics/integrated/debugger))
			var/obj/item/device/electronics/integrated/debugger/debugger = held_item
			if(pin)
				debugger.write_data(pin, usr)
		else
			to_chat(usr, SPAN_WARNING("You can't do a whole lot without the proper tools."))

	if(href_list["examine"])
		examine(usr)

	if(href_list["rename"])
		rename_component(usr)

	if(href_list["scan"])
		if(istype(held_item, /obj/item/device/electronics/integrated/debugger))
			var/obj/item/device/electronics/integrated/debugger/D = held_item
			if(D.accepting_refs)
				D.afterattack(src, usr, TRUE)
			else
				to_chat(usr, SPAN_WARNING("The Debugger's 'ref scanner' needs to be on."))
		else
			to_chat(usr, SPAN_WARNING("You need a Debugger set to 'ref' mode to do that."))

	if(href_list["autopulse"])
		if(autopulse != -1)
			autopulse = !autopulse

	if(href_list["remove"])
		if(istype(held_item, /obj/item/tool/screwdriver))
			if(!removable)
				to_chat(usr, SPAN_WARNING("\The [src] seems to be permanently attached to the case."))
				return
			disconnect_all()
			var/turf/T = get_turf(src)
			forceMove(T)
			assembly = null
			playsound(T, 'sound/items/Crowbar.ogg', 50, 1)
			to_chat(usr, SPAN_NOTICE("You pop \the [src] out of the case, and slide it out."))
		else
			to_chat(usr, SPAN_WARNING("You need a screwdriver to remove components."))
		var/obj/item/device/electronic_assembly/ea = loc
		if(istype(ea))
			ea.interact(usr)
		return

	interact(usr) // To refresh the UI.

/obj/item/integrated_circuit/proc/push_data()
	for(var/datum/integrated_io/output/O in outputs)
		O.push_data()

/obj/item/integrated_circuit/proc/pull_data()
	for(var/datum/integrated_io/input/I in inputs)
		I.push_data()

/obj/item/integrated_circuit/proc/draw_idle_power()
	if(assembly)
		return assembly.draw_power(power_draw_idle)

// Override this for special behaviour when there's no power left.
/obj/item/integrated_circuit/proc/power_fail()
	return

// Returns true if there's enough power to work().
/obj/item/integrated_circuit/proc/check_power()
	if(!assembly)
		return FALSE // Not in an assembly, therefore no power.
	if(assembly.draw_power(power_draw_per_use))
		return TRUE // Battery has enough.
	return FALSE // Not enough power.

/obj/item/integrated_circuit/proc/check_then_do_work(var/ignore_power = FALSE)
	if(world.time < next_use) 	// All intergrated circuits have an internal cooldown, to protect from spam.
		return
	if(power_draw_per_use && !ignore_power)
		if(!check_power())
			power_fail()
			return
	next_use = world.time + cooldown_per_use
	do_work()

/obj/item/integrated_circuit/proc/do_work()
	return

/obj/item/integrated_circuit/proc/disconnect_all()
	for(var/datum/integrated_io/input/I in inputs)
		I.disconnect()
	for(var/datum/integrated_io/output/O in outputs)
		O.disconnect()
	for(var/datum/integrated_io/activate/A in activators)
		A.disconnect()

/*
Destructive Analyzer

It is used to destroy hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/

/obj/machinery/r_n_d/destructive_analyzer
	name = "destructive analyzer"
	icon_state = "d_analyzer"
	var/obj/item/loaded_item = null
	var/decon_mod = 0
	var/busy = FALSE
	circuit = /obj/item/electronics/circuitboard/destructive_analyzer

	idle_power_usage = 30
	active_power_usage = 2500

/obj/machinery/r_n_d/destructive_analyzer/Destroy()
	if(linked_console)
		if(linked_console.linked_destroy == src)
			linked_console.linked_destroy = null
		linked_console = null
	return ..()

/obj/machinery/r_n_d/destructive_analyzer/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/S in src)
		T += S.rating
	decon_mod = T * 0.1

/obj/machinery/r_n_d/destructive_analyzer/on_update_icon()
	if(panel_open)
		icon_state = "d_analyzer_t"
	else if(loaded_item)
		icon_state = "d_analyzer_l"
	else
		icon_state = "d_analyzer"

/obj/machinery/r_n_d/destructive_analyzer/attackby(obj/item/I, mob/user)
	if(busy)
		to_chat(user, SPAN_NOTICE("\The [src] is busy right now."))
		return
	if(loaded_item)
		to_chat(user, SPAN_NOTICE("There is something already loaded into \the [src]."))
		return

	var/tool_type = I.get_tool_type(user, list(QUALITY_PRYING, QUALITY_SCREW_DRIVING), src)
	switch(tool_type)

		if(QUALITY_PRYING)
			if(!panel_open)
				to_chat(user, SPAN_NOTICE("You cant get to the components of \the [src], remove the cover."))
				return
			if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
				to_chat(user, SPAN_NOTICE("You remove the components of \the [src] with [I]."))
				dismantle()
				return

		if(QUALITY_SCREW_DRIVING)
			var/used_sound = panel_open ? 'sound/machines/Custom_screwdriveropen.ogg' :  'sound/machines/Custom_screwdriverclose.ogg'
			if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC, instant_finish_tier = 30, forced_sound = used_sound))
				if(linked_console)
					linked_console.linked_destroy = null
					linked_console = null
				panel_open = !panel_open
				to_chat(user, SPAN_NOTICE("You [panel_open ? "open" : "close"] the maintenance hatch of \the [src] with [I]."))
				update_icon()
				return

		if(ABORT_CHECK)
			return

	if(default_part_replacement(I, user))
		return
	if(panel_open)
		to_chat(user, SPAN_NOTICE("You can't load \the [src] while it's opened."))
		return
	if(!linked_console)
		to_chat(user, SPAN_NOTICE("\The [src] must be linked to an R&D console first."))
		return
	if(!loaded_item && istype(I))
		if(!I.origin_tech)
			to_chat(user, SPAN_NOTICE("This doesn't seem to have a tech origin."))
			return
		if(I.origin_tech.len == 0)
			to_chat(user, SPAN_NOTICE("You cannot deconstruct this item."))
			return

		if(user.unEquip(I, src))
			busy = TRUE
			loaded_item = I
			to_chat(user, SPAN_NOTICE("You add \the [I] to \the [src]."))
			FLICK("d_analyzer_la", src)
			addtimer(CALLBACK(src, .proc/reset_busy), 1 SECONDS)
			return TRUE
	return

/obj/machinery/r_n_d/destructive_analyzer/proc/reset_busy()
	busy = FALSE
	update_icon()
	if(linked_console)
		SSnano.update_uis(linked_console)

// If this returns true, the rdconsole caller will set its screen to SCREEN_WORKING
/obj/machinery/r_n_d/destructive_analyzer/proc/deconstruct_item()
	if(busy)
		to_chat(usr, SPAN_WARNING("The destructive analyzer is busy at the moment."))
		return
	if(!loaded_item)
		return

	busy = TRUE
	FLICK("d_analyzer_process", src)
	addtimer(CALLBACK(src, .proc/finish_deconstructing), 2.4 SECONDS)
	return TRUE

/obj/machinery/r_n_d/destructive_analyzer/proc/finish_deconstructing()
	busy = FALSE
	if(!loaded_item)
		return
	if(linked_console)
		linked_console.handle_item_analysis(loaded_item)
	for(var/mob/living/carbon/human/H in viewers(src))
		SEND_SIGNAL(H, COMSING_DESTRUCTIVE_ANALIZER, loaded_item)
	if(istype(loaded_item,/obj/item/stack))
		var/obj/item/stack/S = loaded_item
		if(S.amount <= 1)
			qdel(S)
			loaded_item = null
		else
			S.use(1)
	else
		qdel(loaded_item)
		loaded_item = null

	use_power(active_power_usage)
	update_icon()
	if(linked_console)
		linked_console.reset_screen()

/obj/machinery/r_n_d/destructive_analyzer/eject_item()
	if(busy)
		to_chat(usr, SPAN_WARNING("The destructive analyzer is busy at the moment."))
		return

	if(loaded_item)
		loaded_item.forceMove(loc)
		loaded_item = null
		update_icon()
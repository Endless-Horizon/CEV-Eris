/obj/machinery/suspension_gen
	name = "suspension field generator"
	desc = "It has stubby legs bolted up against it's body for stabilising."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "suspension2"
	density = TRUE
	req_access = list(access_moebius)
	var/obj/item/cell/large/cell
	var/locked = TRUE
	var/field_type = ""
	var/power_use = 25
	var/obj/effect/suspension_field/suspension_field
	var/list/field_modes = list(
		"carbon" = "Diffracted carbon dioxide laser",
		"nitrogen" = "Nitrogen tracer field",
		"potassium" = "Potassium refrigerant cloud",
		"mercury" = "Mercury dispersion wave",
		"iron" = "Iron wafer conduction field",
		"calcium" = "Calcium binary deoxidiser",
		"chlorine" = "Chlorine diffusion emissions",
		"plasma" = "Plasma saturated field",
	)

	var/list/secured_mobs = list()

/obj/machinery/suspension_gen/Initialize()
	. = ..()
	cell = new /obj/item/cell/large/high(src)

/obj/machinery/suspension_gen/get_cell()
	return cell

/obj/machinery/suspension_gen/handle_atom_del(atom/A)
	..()
	if(A == cell)
		cell = null
		update_icon()

/obj/machinery/suspension_gen/Process()
	if (!suspension_field)
		return

	var/turf/T = get_turf(suspension_field)
	var/power_draw = power_use

	if(field_type == "carbon")
		for(var/mob/living/carbon/M in T)
			M.weakened = max(M.weakened, 3)
			power_draw += power_use
			if(prob(5))
				to_chat(M, SPAN_NOTICE(pick("You feel tingly.","You feel like floating.","It is hard to speak.","You can barely move.")))

	if(field_type == "iron")
		for(var/mob/living/silicon/M in T)
			M.weakened = max(M.weakened, 3)
			power_draw += power_use
			if(prob(5))
				to_chat(M, SPAN_NOTICE(pick("You feel tingly.","You feel like floating.","It is hard to speak.","You can barely move.")))

	for(var/obj/item/I in T)
		if(!suspension_field.contents.len)
			suspension_field.icon_state = "energynet"
			suspension_field.add_overlays("shield2")
		I.forceMove(suspension_field)

	for(var/mob/living/simple_animal/M in T)
		M.weakened = max(M.weakened, 3)
		power_draw += power_use
		if(prob(5))
			to_chat(M, SPAN_NOTICE(pick("You feel tingly.","You feel like floating.","It is hard to speak.","You can barely move.")))

	if(!cell.checked_use(power_draw))
		deactivate()

/obj/machinery/suspension_gen/interact(mob/user as mob)
	var/dat = "<b>Multi-phase mobile suspension field generator MK II \"Steadfast\"</b><br>"
	if(cell)
		var/colour = "red"
		var/charge_percent = cell.percent()
		if(charge_percent > 66)
			colour = "green"
		else if(charge_percent > 33)
			colour = "orange"
		dat += "<b>Energy cell</b>: <font color='[colour]'>[charge_percent]%</font><br>"
	else
		dat += "<b>Energy cell</b>: None<br>"

	if(!locked)
		dat += "<b><A href='?src=\ref[src];toggle_field=1'>[suspension_field ? "Disable" : "Enable"] field</a></b><br>"
	else
		dat += "Swipe ID to unlock.<br>"

	dat += "<hr>"
	if(!locked)
		dat += "<b>Select field mode</b><br>"
		for(var/mode in field_modes)
			var/mode_str = "<a href='?src=\ref[src];select_field=[mode]'>[field_modes[mode]]</a>"
			if(field_type == mode)
				mode_str = "<b>[mode_str]</b>"
			dat += mode_str
			dat += "<br>"

	else
		for(var/mode in field_modes)
			dat += "<br>"

	dat += "<hr>"
	dat += "<font color='blue'><b>Always wear safety gear and consult a field manual before operation.</b></font><br>"
	if(!locked)
		dat += "<A href='?src=\ref[src];lock=1'>Lock console</A><br>"
	else
		dat += "<br>"
	dat += "<A href='?src=\ref[src];refresh=1'>Refresh console</A><br>"
	dat += "<A href='?src=\ref[src];close=1'>Close console</A>"
	user << browse(dat, "window=suspension;size=500x400")
	onclose(user, "suspension")

/obj/machinery/suspension_gen/Topic(href, href_list)
	..()
	usr.set_machine(src)

	if(href_list["toggle_field"])
		if(!suspension_field)
			if(cell.charge > 0)
				if(anchored)
					activate()
				else
					to_chat(usr, SPAN_WARNING("You are unable to activate [src] until it is properly secured on the ground."))
		else
			deactivate()
	if(href_list["select_field"])
		field_type = href_list["select_field"]
	else if(href_list["lock"])
		locked = TRUE
	else if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=suspension")

	updateUsrDialog()

/obj/machinery/suspension_gen/attack_hand(mob/user as mob)
	if(!panel_open)
		interact(user)
	else if(cell)
		cell.forceMove(get_turf(src))
		cell.add_fingerprint(user)
		cell = null

		icon_state = "suspension0"
		to_chat(user, SPAN_NOTICE("You remove the power cell"))

/obj/machinery/suspension_gen/attackby(obj/item/I, mob/user as mob)

	var/tool_type = I.get_tool_type(user, list(QUALITY_SCREW_DRIVING, QUALITY_BOLT_TURNING), src)
	switch(tool_type)

		if(QUALITY_SCREW_DRIVING)
			if(!locked)
				if(!suspension_field)
					if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
						panel_open = !panel_open
						to_chat(user, SPAN_NOTICE("You [panel_open ? "open" : "close"] the battery panel."))
						icon_state = "suspension[panel_open ? (cell ? "1" : "0") : "2"]"
				else
					to_chat(user, SPAN_WARNING("[src]'s safety locks are engaged, shut it down first."))
			else
				to_chat(user, SPAN_WARNING("[src]'s security locks are engaged."))
			return

		if(QUALITY_BOLT_TURNING)
			if(!suspension_field)
				if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					anchored = !anchored
					to_chat(user, SPAN_NOTICE("You wrench the stabilising legs [anchored ? "into place" : "up against the body"]."))
					update_icon()
			else
				to_chat(user, SPAN_WARNING("You are unable to secure [src] while it is active!"))
			return

		if(ABORT_CHECK)
			return

	if (istype(I, /obj/item/cell/large))
		if(panel_open)
			if(cell)
				to_chat(user, SPAN_WARNING("There is a power cell already installed."))
			else
				user.drop_item()
				I.forceMove(src)
				cell = I
				to_chat(user, SPAN_NOTICE("You insert the power cell."))
				icon_state = "suspension1"

	if(istype(I, /obj/item/card) || length(I.GetAccess()))
		if(attempt_unlock(I, user))
			to_chat(user, SPAN_NOTICE("You swipe [I], the console flashes \'<i>Access granted.</i>\'"))
		else
			to_chat(user, SPAN_WARNING("You swipe [I], console flashes \'<i>Access denied.</i>\'"))

/obj/machinery/suspension_gen/proc/attempt_unlock(var/obj/item/card/C, var/mob/user)
	if(!panel_open)
		if(istype(C, /obj/item/card/emag))
			C.resolve_attackby(src, user)
		else if(check_access(C))
			locked = FALSE
		if(!locked)
			return 1

/obj/machinery/suspension_gen/emag_act(var/remaining_charges, var/mob/user)
	if(cell.charge > 0 && locked)
		locked = FALSE
		return 1

//checks for whether the machine can be activated or not should already have occurred by this point
/obj/machinery/suspension_gen/proc/activate()
	//in case we have a bad field type
	if(!(field_type in field_modes))
		return

	//depending on the field type, we might pickup certain items
	var/turf/T = get_turf(get_step(src, dir))
	var/collected = 0

	switch(field_type)
		if("carbon")
			for(var/mob/living/carbon/M in T)
				M.weakened += 5
				M.visible_message(SPAN_NOTICE("[M] begins to float in the air!"), "You feel tingly and light, but it is difficult to move.")
		if("iron")
			for(var/mob/living/silicon/M in T)
				M.weakened += 5
				M.visible_message(SPAN_NOTICE("[M] begins to float in the air!"), "You feel tingly and light, but it is difficult to move.")

	for(var/mob/living/simple_animal/M in T)
		M.weakened += 5
		M.visible_message(SPAN_NOTICE("[M] begins to float in the air!"), "You feel tingly and light, but it is difficult to move.")

	suspension_field = new(T)
	suspension_field.field_type = field_type
	src.visible_message(SPAN_NOTICE("[src] activates with a low hum."))
	icon_state = "suspension3"

	for(var/obj/item/I in T)
		I.forceMove(suspension_field)
		collected++

	if(collected)
		suspension_field.icon_state = "energynet"
		suspension_field.add_overlays("shield2")
		src.visible_message(SPAN_NOTICE("[suspension_field] gently absconds [collected > 1 ? "something" : "several things"]."))
	else
		if(istype(T,/turf/simulated/mineral) || istype(T,/turf/simulated/wall))
			suspension_field.icon_state = "shieldsparkles"
		else
			suspension_field.icon_state = "shield2"

/obj/machinery/suspension_gen/proc/deactivate()
	//drop anything we picked up
	var/turf/T = get_turf(suspension_field)

	for(var/mob/M in T)
		to_chat(M, SPAN_NOTICE("You no longer feel like floating."))
		M.weakened = min(M.weakened, 3)

	src.visible_message(SPAN_NOTICE("[src] deactivates with a gentle shudder."))
	QDEL_NULL(suspension_field)
	icon_state = "suspension2"

/obj/machinery/suspension_gen/Destroy()
	//safety checks: clear the field and drop anything it's holding
	deactivate()
	if(cell)
		QDEL_NULL(cell)
	. = ..()

/obj/machinery/suspension_gen/verb/rotate_ccw()
	set src in view(1)
	set name = "Rotate suspension gen (counter-clockwise)"
	set category = "Object"

	if(anchored)
		to_chat(usr, SPAN_WARNING("You cannot rotate [src], it has been firmly fixed to the floor."))
	else
		set_dir(turn(dir, 90))

/obj/machinery/suspension_gen/verb/rotate_cw()
	set src in view(1)
	set name = "Rotate suspension gen (clockwise)"
	set category = "Object"

	if(anchored)
		to_chat(usr, SPAN_WARNING("You cannot rotate [src], it has been firmly fixed to the floor."))
	else
		set_dir(turn(dir, -90))

/obj/effect/suspension_field
	name = "energy field"
	icon = 'icons/effects/effects.dmi'
	anchored = TRUE
	anchored = TRUE
	var/field_type = "chlorine"

/obj/effect/suspension_field/Destroy()
	for(var/obj/I in src)
		I.forceMove(get_turf(src))
	. = ..()

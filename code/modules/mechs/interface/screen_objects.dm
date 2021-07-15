// Screen objects hereon out.
/obj/screen/movable/exosuit
	name = "hardpoint"
	icon = MECH_HUD_ICON
	icon_state = "hardpoint"
	var/mob/living/exosuit/owner

/obj/screen/movable/exosuit/proc/on_handle_hud(var/mob/living/exosuit/E)
	if(E) owner = E

/obj/screen/movable/exosuit/Click()
	return (!owner || !usr.incapacitated() && (usr == owner || usr.loc == owner))

/obj/screen/movable/exosuit/radio
	name = "radio"
	icon_state = "radio"

/obj/screen/movable/exosuit/radio/Click()
	if(..())
		if(owner.radio) owner.radio.attack_self(usr)
		else to_chat(usr, SPAN_WARNING("There is no radio installed."))

/obj/screen/movable/exosuit/hardpoint
	name = "hardpoint"
	desc = "To activate additional hardpoint's options click on it with shift-button."
	var/hardpoint_tag
	var/obj/item/holding

	maptext_x = 34
	maptext_y = 3
	maptext_width = 64

/obj/screen/movable/exosuit/hardpoint/on_handle_hud(var/mob/living/exosuit/E)
	. = ..()
	update_system_info()

/obj/screen/movable/exosuit/hardpoint/Initialize(mapload, var/newtag)
	. = ..()
	hardpoint_tag = newtag
	name = "hardpoint ([hardpoint_tag])"

/obj/screen/movable/exosuit/hardpoint/MouseDrop()
	. = ..()
	if(holding) holding.screen_loc = screen_loc

/obj/screen/movable/exosuit/hardpoint/proc/update_system_info()

	// No point drawing it if we have no item to use or nobody to see it.
	if(!holding || !owner)
		return

	var/has_pilot_with_client = owner.client
	if(!has_pilot_with_client && LAZYLEN(owner.pilots))
		for(var/thing in owner.pilots)
			var/mob/pilot = thing
			if(pilot.client)
				has_pilot_with_client = TRUE
				break
	if(!has_pilot_with_client)
		return

	var/list/new_overlays = list()

	var/obj/item/cell/C = owner.get_cell()
	if(!C || (C.is_empty()))
		cut_overlays()
		return

	maptext = holding.get_hardpoint_maptext()

	var/ui_damage = !owner.body.computer?.is_functional() || ((owner.emp_damage > EMP_HUD_DISRUPT) && prob(owner.emp_damage))

	var/value = holding.get_hardpoint_status_value()
	if(isnull(value))
		cut_overlays()
		return

	if(ui_damage)
		value = -1
		maptext = "ERROR"
	else if((owner.emp_damage > EMP_HUD_DISRUPT) && prob(owner.emp_damage*2))
		if(prob(10)) value = -1
		else value = rand(1,BAR_CAP)
	else value = round(value * BAR_CAP)

	// Draw background.
	if(!GLOB.default_hardpoint_background)
		GLOB.default_hardpoint_background = image(icon = MECH_HUD_ICON, icon_state = "bar_bkg")
		GLOB.default_hardpoint_background.pixel_x = 34
	new_overlays += GLOB.default_hardpoint_background

	if(value == 0)
		if(!GLOB.hardpoint_bar_empty)
			GLOB.hardpoint_bar_empty = image(icon = MECH_HUD_ICON, icon_state="bar_flash")
			GLOB.hardpoint_bar_empty.pixel_x = 24
			GLOB.hardpoint_bar_empty.color = "#ff0000"
		new_overlays += GLOB.hardpoint_bar_empty
	else if(value < 0)
		if(!GLOB.hardpoint_error_icon)
			GLOB.hardpoint_error_icon = image(icon = MECH_HUD_ICON, icon_state="bar_error")
			GLOB.hardpoint_error_icon.pixel_x = 34
		new_overlays += GLOB.hardpoint_error_icon
	else
		value = min(value, BAR_CAP)
		// Draw statbar.
		if(!LAZYLEN(GLOB.hardpoint_bar_cache))
			for(var/i = 0; i < BAR_CAP; i++)
				var/image/bar = image(icon = MECH_HUD_ICON, icon_state="bar")
				bar.pixel_x = 24 + (i * 2)
				if(i>5) bar.color = "#00ff00"
				else if(i>1) bar.color = "#ffff00"
				else bar.color = "#ff0000"
				GLOB.hardpoint_bar_cache += bar
		for(var/i = 1; i <= value; i++) new_overlays += GLOB.hardpoint_bar_cache[i]
	if(ovrls["hardpoint"]) new_overlays += ovrls["hardpoint"]
	set_overlays(new_overlays)

/obj/screen/movable/exosuit/hardpoint/Click(var/location, var/control, var/params)
	if(..() && owner && holding)
		if(!owner.hatch_closed)
			to_chat(usr, SPAN_WARNING("Error: Hardpoint interface disabled while [owner.body.hatch_descriptor] is open."))
			return

		var/modifiers = params2list(params)
		if(modifiers["ctrl"])
			if(owner.hardpoints_locked) to_chat(usr, SPAN_WARNING("Hardpoint ejection system is locked."))
			else if(owner.remove_system(hardpoint_tag)) to_chat(usr, SPAN_NOTICE("You disengage and discard the system mounted to your [hardpoint_tag] hardpoint."))
			else to_chat(usr, SPAN_DANGER("You fail to remove the system mounted to your [hardpoint_tag] hardpoint."))
		else if(modifiers["shift"] && holding) holding.attack_self(usr)
		else if(owner.selected_hardpoint == hardpoint_tag)
			icon_state = "hardpoint"
			owner.clear_selected_hardpoint()
		else if(owner.set_hardpoint(hardpoint_tag)) icon_state = "hardpoint_selected"

/obj/screen/movable/exosuit/eject
	name = "eject"
	icon_state = "eject"

/obj/screen/movable/exosuit/eject/Click()
	if(..()) owner.eject(usr)

/obj/screen/movable/exosuit/rename
	name = "rename"
	icon_state = "rename"

/obj/screen/movable/exosuit/power
	name = "power"
	icon_state = null

	maptext_width = 64
	maptext_x = 2
	maptext_y = 20
	maptext = "power"

/obj/screen/movable/exosuit/power/on_handle_hud(var/mob/living/exosuit/E)
	. = ..()
	if(owner)
		var/obj/item/cell/C = owner.get_cell()
		if(C && istype(C)) maptext = "[round(C.charge)]/[round(C.maxcharge)]"
		else maptext = "CHECK POWER"

/obj/screen/movable/exosuit/rename/Click()
	if(..()) owner.rename(usr)

/obj/screen/movable/exosuit/toggle
	name = "toggle"
	var/toggled

/obj/screen/movable/exosuit/toggle/Click()
	if(..()) toggled()

/obj/screen/movable/exosuit/toggle/proc/toggled()
	toggled = !toggled
	icon_state = "[initial(icon_state)][toggled ? "_enabled" : ""]"
	return toggled

/obj/screen/movable/exosuit/toggle/air
	name = "air"
	icon_state = "air"

/obj/screen/movable/exosuit/toggle/air/toggled()
	owner.use_air = ..()
	to_chat(usr, SPAN_NOTICE("Auxiliary atmospheric system [owner.use_air ? "enabled" : "disabled"]."))

/obj/screen/movable/exosuit/toggle/maint
	name = "toggle maintenance protocol"
	icon_state = "maint"

/obj/screen/movable/exosuit/toggle/maint/toggled()
	owner.maintenance_protocols = ..()
	to_chat(usr, SPAN_NOTICE("Maintenance protocols [owner.maintenance_protocols ? "enabled" : "disabled"]."))

/obj/screen/movable/exosuit/toggle/hardpoint
	name = "toggle hardpoint lock"
	icon_state = "hardpoint_lock"

/obj/screen/movable/exosuit/toggle/hardpoint/toggled()
	owner.hardpoints_locked = ..()
	to_chat(usr, SPAN_NOTICE("Hardpoint system access is now [owner.hardpoints_locked ? "disabled" : "enabled"]."))

/obj/screen/movable/exosuit/toggle/hatch
	name = "toggle hatch lock"
	icon_state = "hatch_lock"

/obj/screen/movable/exosuit/toggle/hatch/toggled()
	if(!owner.hatch_locked && !owner.hatch_closed)
		to_chat(usr, SPAN_WARNING("You cannot lock the hatch while it is open."))
		return
	owner.hatch_locked = ..()
	to_chat(usr, SPAN_NOTICE("The [owner.body.hatch_descriptor] is [owner.hatch_locked ? "now" : "no longer" ] locked."))

/obj/screen/movable/exosuit/toggle/hatch_open
	name = "open or close hatch"
	icon_state = "hatch_status"

/obj/screen/movable/exosuit/toggle/hatch_open/toggled()
	if(owner.hatch_locked && owner.hatch_closed)
		to_chat(usr, SPAN_WARNING("You cannot open the hatch while it is locked."))
		return
	owner.hatch_closed = ..()
	to_chat(usr, SPAN_NOTICE("The [owner.body.hatch_descriptor] is now [owner.hatch_closed ? "closed" : "open" ]."))
	owner.update_icon()

// This is basically just a holder for the updates the exosuit does.
/obj/screen/movable/exosuit/health
	name = "exosuit integrity"
	icon_state = "health"

/obj/screen/movable/exosuit/health/on_handle_hud(var/mob/living/exosuit/E)
	. = ..()
	cut_overlays()
	var/obj/item/cell/C = owner.get_cell()
	if(!owner.body || !C || C.is_empty())
		return

	if(!owner.body.computer?.is_functional() || ((owner.emp_damage > EMP_HUD_DISRUPT) && prob(owner.emp_damage * 2)))
		if(!GLOB.mech_damage_overlay_cache["critfail"]) GLOB.mech_damage_overlay_cache["critfail"] = image(icon = MECH_HUD_ICON, icon_state="dam_error")
		associate_with_overlays(GLOB.mech_damage_overlay_cache["critfail"])
		return

	var/list/part_to_state = list("legs" = owner.legs,"body" = owner.body,"head" = owner.head,"arms" = owner.arms)
	for(var/part in part_to_state)
		var/state = 0
		var/obj/item/mech_component/MC = part_to_state[part]
		if(MC)
			if((owner.emp_damage > EMP_HUD_DISRUPT) && prob(owner.emp_damage * 3)) state = rand(0,4)
			else state = MC.damage_state
		if(!GLOB.mech_damage_overlay_cache["[part]-[state]"])
			var/image/I = image(icon = MECH_HUD_ICON, icon_state="dam_[part]")
			switch(state)
				if(1) I.color = "#0f0"
				if(2) I.color = "#f2c50d"
				if(3) I.color = "#ea8515"
				if(4) I.color = "#f00"
				else I.color = "#f5f5f0"
			GLOB.mech_damage_overlay_cache["[part]-[state]"] = I
		add_overlays(GLOB.mech_damage_overlay_cache["[part]-[state]"])

//Controls if cameras set the vision flags
/obj/screen/movable/exosuit/toggle/camera
	name = "toggle camera matrix"
	icon_state = "camera"

/obj/screen/movable/exosuit/toggle/camera/toggled()
	if(!owner.head)
		to_chat(usr, SPAN_WARNING("I/O Error: Camera systems not found."))
		return
	if(!owner.head.vision_flags)
		to_chat(usr,  SPAN_WARNING("Alternative sensor configurations not found. Contact manufacturer for more details."))
		return
	owner.head.active_sensors = ..()
	to_chat(usr, SPAN_NOTICE("[owner.head.name] advanced sensor mode is [owner.head.active_sensors ? "now" : "no longer" ] active."))

/obj/screen/movable/exosuit/toggle/strafe
	name = "toggle strafing"
	icon_state = "strafe"

/obj/screen/movable/exosuit/toggle/strafe/toggled()
	owner.strafing = ..()
	to_chat(usr, SPAN_NOTICE("Strafing [owner.strafing ? "enabled" : "disabled"]."))


#undef BAR_CAP

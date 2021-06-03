var/bomb_set

/obj/machinery/nuclearbomb
	name = "\improper Nuclear Fission Explosive"
	desc = "Uh oh. RUN!!!!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nuclearbomb0"
	density = TRUE
	var/deployable = 0
	var/extended = 0
	var/lighthack = 0
	var/timeleft = 120
	var/timing = 0
	var/r_code = "ADMIN"
	var/code = ""
	var/yes_code = 0
	var/safety = 1
	var/obj/item/weapon/disk/nuclear/auth = null
	var/removal_stage = 0 // 0 is no removal, 1 is covers removed, 2 is covers open, 3 is sealant open, 4 is unwrenched, 5 is removed from bolts.
	var/lastentered
	use_power = NO_POWER_USE
	unacidable = 1
	var/previous_level = ""
	var/datum/wires/nuclearbomb/wires = null

	var/eris_ship_bomb = FALSE           // if TRUE (1 in map editor), then Heads will get parts of code for this bomb. Obviously used in map editor. Single mapped bomb supported.

/obj/machinery/nuclearbomb/New()
	..()
	if(eris_ship_bomb)
		r_code = "[rand(100000, 999999)]" // each time new Head spawns, s/he gets 2 numbers of code.
	else                                  // i decided not to touch normal bombs code length.
		r_code = "[rand(10000, 99999)]" //Creates a random code upon object spawn.
	wires = new/datum/wires/nuclearbomb(src)

/obj/machinery/nuclearbomb/Initialize()
	. = ..()
	if(eris_ship_bomb) // this is in initialize because there is no ticker at world init.
		SSticker.ship_nuke_code = r_code // even if this bomb stops to exist, heads of staff still gets this password, so it won't affect meta or whatever.

/obj/machinery/nuclearbomb/Destroy()
	qdel(wires)
	wires = null
	return ..()

/obj/machinery/nuclearbomb/Process()
	if (src.timing)
		src.timeleft = max(timeleft - 2, 0) // 2 seconds per process()
		if (timeleft <= 0)
			spawn
				explode()
		SSnano.update_uis(src)
	return

/obj/machinery/nuclearbomb/attackby(obj/item/I, mob/user, params)
	src.add_fingerprint(user)

	var/list/usable_qualities = list(QUALITY_SCREW_DRIVING)
	if(anchored && (removal_stage == 0 || removal_stage == 2))
		usable_qualities.Add(QUALITY_WELDING)
	if(anchored && (removal_stage == 3))
		usable_qualities.Add(QUALITY_BOLT_TURNING)
	if(anchored && (removal_stage == 1 || removal_stage == 4))
		usable_qualities.Add(QUALITY_PRYING)

	var/tool_type = I.get_tool_type(user, usable_qualities, src)
	switch(tool_type)

		if(QUALITY_SCREW_DRIVING)
			if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
				if (src.auth)
					if (panel_open == 0)
						panel_open = 1
						add_overlays(image(icon, "npanel_open"))
						to_chat(user, SPAN_NOTICE("You unscrew the control panel of [src]."))
					else
						panel_open = 0
						remove_overlays(image(icon, "npanel_open"))
						to_chat(user, SPAN_NOTICE("You screw the control panel of [src] back on."))
				else
					if (panel_open == 0)
						to_chat(user, SPAN_NOTICE("\The [src] emits a buzzing noise, the panel staying locked in."))
					if (panel_open == 1)
						panel_open = 0
						remove_overlays(image(icon, "npanel_open"))
						to_chat(user, SPAN_NOTICE("You screw the control panel of \the [src] back on."))
						playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
					FLICK("nuclearbombc", src)
				return
			return

		if(QUALITY_WELDING)
			if(anchored && (removal_stage == 0 || removal_stage == 2))
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					if(removal_stage == 0)
						user.visible_message("\The [user] cuts through the bolt covers on \the [src].", "You cut through the bolt cover.")
						removal_stage = 1
						return
					if(removal_stage == 2)
						user.visible_message("\The [user] cuts apart the anchoring system sealant on \the [src].", "You cut apart the anchoring system's sealant.")
						removal_stage = 3
						return
			return

		if(QUALITY_BOLT_TURNING)
			if(anchored && (removal_stage == 3))
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					user.visible_message("[user] unwrenches the anchoring bolts on [src].", "You unwrench the anchoring bolts.")
					removal_stage = 4
					return
			return

		if(QUALITY_PRYING)
			if(anchored && (removal_stage == 1 || removal_stage == 4))
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_ROB))
					if(removal_stage == 1)
						user.visible_message("\The [user] forces open the bolt covers on \the [src].", "You force open the bolt covers.")
						removal_stage = 2
						return
					if(removal_stage == 4)
						user.visible_message("\The [user] crowbars \the [src] off of the anchors. It can now be moved.", "You jam the crowbar under the nuclear device and lift it off its anchors. You can now move it!")
						anchored = FALSE
						removal_stage = 5
						return
			return

		if(ABORT_CHECK)
			return

	if (panel_open && (istool(I)))
		return attack_hand(user)

	if (src.extended)
		if (istype(I, /obj/item/weapon/disk/nuclear))
			usr.drop_item()
			I.loc = src
			src.auth = I
			src.add_fingerprint(user)
			return attack_hand(user)

	..()

/obj/machinery/nuclearbomb/attack_ghost(mob/user as mob)
	attack_hand(user)

/obj/machinery/nuclearbomb/attack_hand(mob/user as mob)
	if (extended)
		if (panel_open)
			wires.Interact(user)
		else
			nano_ui_interact(user)
	else if (deployable)
		if(removal_stage < 5)
			src.anchored = TRUE
			visible_message(SPAN_WARNING("With a steely snap, bolts slide out of [src] and anchor it to the flooring!"))
		else
			visible_message(SPAN_WARNING("\The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut."))
		extended = 1
		if(!src.lighthack)
			FLICK("nuclearbombc", src)
			update_icon()
	return

/obj/machinery/nuclearbomb/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	var/data[0]
	data["hacking"] = 0
	data["auth"] = is_auth(user)
	if (is_auth(user))
		if (yes_code)
			data["authstatus"] = timing ? "Functional/Set" : "Functional"
		else
			data["authstatus"] = "Auth. S2"
	else
		if (timing)
			data["authstatus"] = "Set"
		else
			data["authstatus"] = "Auth. S1"
	data["safe"] = safety ? "Safe" : "Engaged"
	data["time"] = timeleft
	data["timer"] = timing
	data["safety"] = safety
	data["anchored"] = anchored
	data["yescode"] = yes_code
	data["message"] = "AUTH"
	if (is_auth(user))
		data["message"] = code
		if (yes_code)
			data["message"] = "*****"

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "nuclear_bomb.tmpl", "Nuke Control Panel", 300, 510)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/nuclearbomb/verb/toggle_deployable()
	set category = "Object"
	set name = "Toggle Deployable"
	set src in oview(1)

	if(usr.incapacitated())
		return

	if (src.deployable)
		to_chat(usr, SPAN_WARNING("You close several panels to make [src] undeployable."))
		src.deployable = 0
	else
		to_chat(usr, SPAN_WARNING("You adjust some panels to make [src] deployable."))
		src.deployable = 1
	return

/obj/machinery/nuclearbomb/proc/is_auth(var/mob/user)
	if(auth)
		return 1
	if(user.can_admin_interact())
		return 1
	return 0

/obj/machinery/nuclearbomb/Topic(href, href_list)
	if(..())
		return 1

	if (href_list["auth"])
		if (auth)
			auth.loc = loc
			yes_code = 0
			auth = null
		else
			var/obj/item/I = usr.get_active_hand()
			if (istype(I, /obj/item/weapon/disk/nuclear))
				usr.drop_item()
				I.loc = src
				auth = I
	if (is_auth(usr))
		if (href_list["type"])
			if (href_list["type"] == "E")
				if (code == r_code)
					yes_code = 1
					code = null
				else
					code = "ERROR"
			else
				if (href_list["type"] == "R")
					yes_code = 0
					code = null
				else
					if(code == "ERROR") // for codes with 6 digits or more, it will look awkward when user enters 8 and sees ERROR8, -
						SSnano.update_uis(src)
						return // - so we force user to press R before entering new code as it was with 5-digit codes.
					lastentered = text("[]", href_list["type"])
					if (text2num(lastentered) == null)
						var/turf/LOC = get_turf(usr)
						message_admins("[key_name_admin(usr)] tried to exploit a nuclear bomb by entering non-numerical codes: <a href='?_src_=vars;Vars=\ref[src]'>[lastentered]</a>! ([LOC ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[LOC.x];Y=[LOC.y];Z=[LOC.z]'>JMP</a>" : "null"])", 0)
						log_admin("EXPLOIT: [key_name(usr)] tried to exploit a nuclear bomb by entering non-numerical codes: [lastentered]!")
					else
						code += lastentered
						if (length(code) > length(r_code))
							code = "ERROR"
		if (yes_code)
			if (href_list["time"])
				var/time = text2num(href_list["time"])
				timeleft += time
				timeleft = CLAMP(timeleft, 120, 600)
			if (href_list["timer"])
				if (timing == -1)
					SSnano.update_uis(src)
					return
				if (!anchored)
					to_chat(usr, SPAN_WARNING("\The [src] needs to be anchored."))
					SSnano.update_uis(src)
					return
				if (safety)
					to_chat(usr, SPAN_WARNING("The safety is still on."))
					SSnano.update_uis(src)
					return
				if (wires.IsIndexCut(NUCLEARBOMB_WIRE_TIMING))
					to_chat(usr, SPAN_WARNING("Nothing happens, something might be wrong with the wiring."))
					SSnano.update_uis(src)
					return

				if (!timing && !safety)
					timing = 1
					log_and_message_admins("engaged a nuclear bomb")
					bomb_set++ //There can still be issues with this resetting when there are multiple bombs. Not a big deal though for Nuke/N
					update_icon()
				else
					secure_device()
			if (href_list["safety"])
				if (wires.IsIndexCut(NUCLEARBOMB_WIRE_SAFETY))
					to_chat(usr, SPAN_WARNING("Nothing happens, something might be wrong with the wiring."))
					SSnano.update_uis(src)
					return
				safety = !safety
				if(safety)
					secure_device()
			if (href_list["anchor"])
				if(removal_stage == 5)
					anchored = FALSE
					visible_message(SPAN_WARNING("\The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut."))
					SSnano.update_uis(src)
					return

				if(!isinspace())
					anchored = !anchored
					if(anchored)
						visible_message(SPAN_WARNING("With a steely snap, bolts slide out of [src] and anchor it to the flooring."))
					else
						secure_device()
						visible_message(SPAN_WARNING("The anchoring bolts slide back into the depths of [src]."))
				else
					to_chat(usr, SPAN_WARNING("There is nothing to anchor to!"))

	SSnano.update_uis(src)

/obj/machinery/nuclearbomb/proc/secure_device()
	if(timing <= 0)
		return

	bomb_set--
	timing = 0
	timeleft = CLAMP(timeleft, 120, 600)
	update_icon()

/obj/machinery/nuclearbomb/ex_act(severity)
	return

#define NUKERANGE 80
/obj/machinery/nuclearbomb/proc/explode()
	if (src.safety)
		timing = 0
		return
	src.timing = -1
	src.yes_code = 0
	src.safety = 1
	update_icon()
	playsound(src,'sound/machines/Alarm.ogg',100,0,5)
	SSticker.nuke_in_progress = TRUE
	sleep(100)

	var/off_station = 0
	var/turf/bomb_location = get_turf(src)
	if(bomb_location && isStationLevel(bomb_location.z))
		if( (bomb_location.x < (128-NUKERANGE)) || (bomb_location.x > (128+NUKERANGE)) || (bomb_location.y < (128-NUKERANGE)) || (bomb_location.y > (128+NUKERANGE)) )
			off_station = 1
	else
		off_station = 2

	if(get_storyteller())
		SSticker.nuke_in_progress = FALSE
		if(off_station == 1)
			to_chat(world, "<b>A nuclear device was set off, but the explosion was out of reach of the ship!</b>")
		else if(off_station == 2)
			to_chat(world, "<b>A nuclear device was set off, but the device was not on the ship!</b>")
		else
			to_chat(world, "<b>The ship was destoyed by the nuclear blast!</b>")

		SSticker.ship_was_nuked = (off_station<2)	//offstation==1 is a draw. the station becomes irradiated and needs to be evacuated.
														//kinda shit but I couldn't  get permission to do what I wanted to do.

		SSticker.station_explosion_cinematic(off_station)

	return

/obj/machinery/nuclearbomb/on_update_icon()
	if(lighthack)
		icon_state = "nuclearbomb0"
		return

	else if(timing == -1)
		icon_state = "nuclearbomb3"
	else if(timing)
		icon_state = "nuclearbomb2"
	else if(extended)
		icon_state = "nuclearbomb1"
	else
		icon_state = "nuclearbomb0"
/*
if(!N.lighthack)
	if (N.icon_state == "nuclearbomb2")
		N.icon_state = "nuclearbomb1"
		*/

//====The nuclear authentication disc====
/obj/item/weapon/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon = 'icons/obj/discs.dmi'
	icon_state = "nuclear"
	item_state = "card-id"
	w_class = ITEM_SIZE_TINY

/obj/item/weapon/disk/nuclear/touch_map_edge()
	qdel(src)

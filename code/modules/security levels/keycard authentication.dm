/obj/machinery/keycard_auth
	name = "Keycard Authentication Device"
	desc = "This device is used to trigger station functions, which require more than one ID card to authenticate."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	interact_offline = TRUE
	req_access = list(access_keycard_auth)
	var/static/const/countdown = 3 MINUTES
	var/static/const/cooldown = 10 MINUTES
	var/static/list/ongoing_countdowns = list()
	var/static/list/initiator_card = list()
	var/static/next_countdown
	var/static/list/event_names = list(
		redalert = "red alert",
		pods = "spacecraft abandonment"
	)
	var/static/datum/announcement/priority/kcad_announcement = new(do_log = 1, new_sound = sound('sound/misc/notice1.ogg'), do_newscast = 1)

/obj/machinery/keycard_auth/attack_ai(mob/user as mob)
	return

/obj/machinery/keycard_auth/inoperable(var/additional_flags = 0)
	return (stat & (BROKEN|additional_flags))

/obj/machinery/keycard_auth/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	user.set_machine(src)
	nano_ui_interact(user)

/obj/machinery/keycard_auth/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	var/data[0]
	var/decl/security_state/security_state = decls_repository.get_decl(GLOB.maps_data.security_state)

	data["seclevel"] = security_state.current_security_level.name
	data["emergencymaint"] = maint_all_access
	data["events"] = ongoing_countdowns
	data["oncooldown"] = next_countdown > world.time
	data["maint_all_access"] = maint_all_access

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "keycard authentication.tmpl", "Keycard Authentication Device", 440, 300)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/keycard_auth/Topic(href, href_list)
	if(..())
		return TRUE

	if(!allowed(usr))
		return TRUE

	if(href_list["start"])
		if(next_countdown > world.time)
			return TRUE
		var/event = href_list["start"]
		if(ongoing_countdowns[event])
			return
		kcad_announcement.Announce("[usr] has initiated [event_names[event]] countdown.")
		ongoing_countdowns[event] = addtimer(CALLBACK(src, .proc/countdown_finished, event), countdown, TIMER_UNIQUE | TIMER_STOPPABLE)
		next_countdown = world.time + cooldown
		var/obj/item/weapon/card/id/id = usr.GetIdCard()
		initiator_card[event] = id
	if(href_list["cancel"])
		var/event = href_list["cancel"]
		if(!ongoing_countdowns[event])
			return
		kcad_announcement.Announce("[usr] has cancelled [event_names[event]] countdown.")
		deltimer(ongoing_countdowns[event])
		ongoing_countdowns -= event
		initiator_card -= event
	if(href_list["proceed"])
		var/event = href_list["proceed"]
		if(!ongoing_countdowns[event])
			return
		var/obj/item/weapon/card/id/id = usr.GetIdCard()
		if(initiator_card[event] == id)
			return
		kcad_announcement.Announce("[usr] has proceeded [event_names[event]] countdown.")
		countdown_finished(event)
	if(href_list["emergencymaint"])
		var/event = href_list["emergencymaint"]
		switch(event)
			if("grant")
				make_maint_all_access()
			if("revoke")
				revoke_maint_all_access()
	playsound(usr.loc, 'sound/machines/button.ogg', 100, 1)
	return

/obj/machinery/keycard_auth/proc/countdown_finished(event)
	switch(event)
		if("redalert")
			var/decl/security_state/security_state = decls_repository.get_decl(GLOB.maps_data.security_state)
			security_state.set_security_level(security_state.high_security_level)
		if("pods")
			evacuation_controller.call_evacuation(null, TRUE)
	if(event)
		deltimer(ongoing_countdowns[event])
		ongoing_countdowns -= event
		initiator_card -= event

var/global/maint_all_access = 0

/proc/make_maint_all_access()
	maint_all_access = 1
	to_chat(world, "<font size=4 color='red'>Attention!</font>")
	to_chat(world, "<font color='red'>The maintenance access requirement has been revoked on all airlocks.</font>")

/proc/revoke_maint_all_access()
	maint_all_access = 0
	to_chat(world, "<font size=4 color='red'>Attention!</font>")
	to_chat(world, "<font color='red'>The maintenance access requirement has been readded on all maintenance airlocks.</font>")

/obj/machinery/door/airlock/allowed(mob/M)
	if(maint_all_access && src.check_access_list(list(access_maint_tunnels)))
		return 1
	return ..(M)

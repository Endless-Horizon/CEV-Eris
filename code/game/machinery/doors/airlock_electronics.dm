/obj/item/weapon/electronics/airlock
	name = "airlock electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	w_class = ITEM_SIZE_SMALL //It should be tiny! -Agouri

	matter = list(MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 3)

	req_access = list(access_engine)

	var/secure = FALSE //if set, then wires will be randomized and bolts will drop if the door is broken
	var/list/conf_access = list()
	var/one_access = FALSE //if set to 1, door would receive req_one_access instead of req_access
	var/last_configurator = null
	var/locked = TRUE
	var/lockable = TRUE

/obj/item/weapon/electronics/airlock/attack_self(mob/user)
	if (!ishuman(user) && !istype(user,/mob/living/silicon/robot))
		return ..(user)

	nano_ui_interact(user)


/obj/item/weapon/electronics/airlock/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.hands_state)
	var/list/data = nano_ui_data()

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "airlock_electronics.tmpl", src.name, 1000, 500, null, null, state)
		ui.set_initial_data(data)
		ui.open()

/obj/item/weapon/electronics/airlock/nano_ui_data()
	var/list/data = list()
	var/list/regions = list()

	for(var/i in ACCESS_REGION_MIN to ACCESS_REGION_MAX) //code/game/jobs/_access_defs.dm
		var/list/region = list()
		var/list/accesses = list()
		for(var/j in get_region_accesses(i))
			var/list/access = list()
			access["name"] = get_access_desc(j)
			access["id"] = j
			access["req"] = (j in src.conf_access)
			accesses[++accesses.len] = access
		region["name"] = get_region_accesses_name(i)
		region["accesses"] = accesses
		regions[++regions.len] = region
	data["regions"] = regions
	data["oneAccess"] = one_access
	data["locked"] = locked
	data["lockable"] = lockable
	//data["autoset"] = autoset

	return data

/obj/item/weapon/electronics/airlock/OnTopic(mob/user, list/href_list, state)
	if(lockable)
		if(href_list["unlock"])
			if(!req_access || istype(user, /mob/living/silicon))
				locked = FALSE
				last_configurator = user.name
			else
				var/obj/item/weapon/card/id/I = user.get_active_hand()
				I = I ? I.GetIdCard() : null
				if(!istype(I, /obj/item/weapon/card/id))
					to_chat(user, SPAN_WARNING("[\src] flashes a yellow LED near the ID scanner. Did you remember to scan your ID or PDA?"))
					return TOPIC_HANDLED
				if (check_access(I))
					locked = FALSE
					last_configurator = I.registered_name
				else
					to_chat(user, SPAN_WARNING("[\src] flashes a red LED near the ID scanner, indicating your access has been denied."))
					return TOPIC_HANDLED
			return TOPIC_REFRESH
		else if(href_list["lock"])
			locked = TRUE
			return TOPIC_REFRESH

	if(href_list["clear"])
		conf_access = list()
		one_access = FALSE
		return TOPIC_REFRESH
	if(href_list["one_access"])
		one_access = !one_access
		return TOPIC_REFRESH
	/* Baystation's "autoset" feature: draws access levels from area
	if(href_list["autoset"])
		autoset = !autoset
		return TOPIC_REFRESH
	*/
	if(href_list["access"])
		toggle_access(text2num(href_list["access"]))
		return TOPIC_REFRESH


/obj/item/weapon/electronics/airlock/proc/toggle_access(var/acc)
	if (acc == "all")
		conf_access = null
	else
		var/req = text2num(acc)

		if (conf_access == null)
			conf_access = list()

		if (!(req in conf_access))
			conf_access += req
		else
			conf_access -= req
			if (!conf_access.len)
				conf_access = null




/obj/item/weapon/electronics/airlock/secure
	name = "secure airlock electronics"
	desc = "designed to be somewhat more resistant to hacking than standard electronics."
	origin_tech = list(TECH_DATA = 2)
	secure = 1

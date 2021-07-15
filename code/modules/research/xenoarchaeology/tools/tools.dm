
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Miscellaneous xenoarchaeology tools
/obj/item/device/gps
	name = "relay positioning device"
	desc = "Pinpoints your location using the ship navigation system."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-c"
	//item_state = "locator"

	w_class = ITEM_SIZE_SMALL
	slot_flags = SLOT_BELT
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2, TECH_BLUESPACE = 2)
	matter = list(MATERIAL_PLASTIC = 1, MATERIAL_GLASS = 1)
	rarity_value = 15

	var/gps_prefix = "COM"
	var/datum/gps_data/gps

	// Avoid displaying PDAs, tablets, computers, tracking implants and spying implants
	var/list/hide_prefixes = list("PDA", "TAB", "MPC", "IMP", "SPY")

	var/emped = FALSE
	var/turf/locked_location

/datum/gps_data/device/is_functioning()
	var/obj/item/device/gps/G = holder
	if(G.emped)
		return FALSE
	return ..()

/obj/item/device/gps/Initialize()
	. = ..()
	gps = new /datum/gps_data/device(src, new_prefix=gps_prefix)
	update_name()
	add_overlays(image(icon, "working"))

/obj/item/device/gps/Destroy()
	QDEL_NULL(gps)
	return ..()

/obj/item/device/gps/proc/update_name()
	if(gps.serial_number)
		name = "[initial(name)] ([gps.serial_number])"
	else
		name = initial(name)

/obj/item/device/gps/emp_act(severity)
	emped = TRUE
	cut_overlays()
	add_overlays(image(icon, "emp"))
	addtimer(CALLBACK(src, .proc/post_emp), 300)

/obj/item/device/gps/proc/post_emp()
	emped = FALSE
	cut_overlays()
	add_overlays(image(icon, "working"))

/obj/item/device/gps/proc/can_show_gps(datum/gps_data/G)
	return G.is_functioning() && G.holder != src && !(G.prefix in hide_prefixes)

/obj/item/device/gps/attack_self(mob/user)
	var/t = ""
	var/gps_window_height = 150 // Variable window height, depending on how many GPS units there are to show
	if(emped)
		t = "ERROR"
	else
		t = "[gps.serial_number]: [gps.get_coordinates_text()]"
		t += "<BR><A href='?src=\ref[src];tag=1'>Set Tag</A>"
		if(locked_location && locked_location.loc)
			t += "<BR>Coordinates saved: [locked_location.loc]"
			gps_window_height += 20

		t += "<BR>"

		for(var/g in GLOB.gps_trackers)
			var/datum/gps_data/G = g
			if(can_show_gps(G))
				t += "<BR>[G.serial_number]: [G.get_coordinates_text(default="ERROR")]"
				gps_window_height += 20

	var/datum/browser/popup = new(user, "GPS", name, 450, min(gps_window_height, 800))
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/item/device/gps/Topic(href, href_list)
	..()
	if(href_list["tag"])
		var/a = input("Please enter desired tag.", name, gps.serial_number) as text
		a = uppertext(copytext(sanitize(a), 1, 9))
		if(a && src.loc == usr)
			gps.change_serial(a)
			update_name()
			attack_self(usr)

/obj/item/device/gps/examine(var/mob/user)
	..()
	to_chat(user, "<span class='notice'>\The [src]'s screen shows: <i>[gps.get_coordinates_text(default="ERROR")]</i>.</span>")


/obj/item/device/gps/science
	icon_state = "gps-s"
	gps_prefix = "SCI"

/obj/item/device/gps/engineering
	icon_state = "gps-e"
	gps_prefix = "ENG"

/obj/item/device/gps/mining
	icon_state = "gps-m"
	gps_prefix = "MIN"
	desc = "A positioning system helpful for rescuing trapped or injured miners. Keeping one on you at all times while mining might just save your life."

// Looks like a normal GPS, but displays PDA GPS and such
/obj/item/device/gps/traitor
	hide_prefixes = list()
	spawn_blacklisted = TRUE

// Locator
// A GPS device that tracks beacons and implants
/obj/item/device/gps/locator
	name = "locator"
	desc = "A device used to locate tracking beacons and people with tracking implants."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	gps_prefix = "SEC"

/obj/item/device/gps/locator/can_show_gps(datum/gps_data/G)
	return G.is_functioning() && G.holder != src && (G.prefix in list("SEC", "LOC", "TBC"))


/obj/item/device/measuring_tape
	name = "measuring tape"
	desc = "A coiled metallic tape used to check dimensions and lengths."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "measuring"
	w_class = ITEM_SIZE_SMALL

//todo: dig site tape

/obj/item/storage/bag/fossils
	name = "Fossil Satchel"
	desc = "Transports delicate fossils in suspension so they don't break during transit."
	icon = 'icons/obj/mining.dmi'
	icon_state = "satchel"
	slot_flags = SLOT_BELT | SLOT_POCKET
	w_class = ITEM_SIZE_NORMAL
	max_storage_space = 100
	max_w_class = ITEM_SIZE_NORMAL
	can_hold = list(/obj/item/fossil)

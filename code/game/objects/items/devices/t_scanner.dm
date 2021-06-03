#define OVERLAY_CACHE_LEN 50

/*
	T-Ray scanners v2.0, By Nanako
	A T-Ray scanner is a complicated thing which allows users to see underfloor pipes, wires and burrows

*/

/obj/item/device/t_scanner
	name = "\improper T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	icon_state = "t-ray0"
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_SMALL
	item_state = "electronic"
	matter = list(MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1)
	origin_tech = list(TECH_MAGNET = 1, TECH_ENGINEERING = 1)
	rarity_value = 25


	//Scan range can be changed, and the power costs scale up with it
	var/scan_range = 1

	//TODO: Make devices have cell support as an inherent behaviour
	suitable_cell = /obj/item/weapon/cell/small //Ready, Make devices have cell support as an inherent behaviour
	var/active_power_usage = 25 //Watts

	var/turn_on_sound = 'sound/effects/Custom_flashlight.ogg'

	/*Enabled and active are seperate things.
	Enabled determines the power status. Is the scanner turned on or not?
	The scanner is enabled as long as it has power, and the power switch is turned on. While enabled it will use power
	*/
	var/enabled = FALSE

	/*
		Active determines if the scanner is actually working in a technical sense.
		The scanner is active when it's enabled, and is held in the hand of a player who is connected.
		IE: Has a client
		A scanner can be enabled but not active, like if its turned on but left on a table

		To be active it must be enabled
	*/
	var/active

	var/list/active_scanned = list() //assoc list of objects being scanned, mapped to their overlay
	var/client/user_client //since making sure overlays are properly added and removed is pretty important, so we track the current user explicitly


	var/global/list/overlay_cache = list() //cache recent overlays
	var/datum/event_source //When listening for movement, this is the source we're listening to
	var/mob/current_user //The last mob who interacted with us. We'll try to fetch the client from them

/obj/item/device/t_scanner/on_update_icon()
	icon_state = "t-ray[enabled]"

/******************************************************
	CORE FUNCTIONALITY: SCANNING AND DRAWING OVERLAYS
*******************************************************/
/*
	The T Ray scanner works by reading underfloor objects in the area, creating an overlay that matches their
	visuals, and adding that to the user's client images, allowing only the user of the scanner to see them

	update_overlay() is the main function that calls all the others. It is called whenever the user moves
	This is done using a Moved observation registered function. It also updates once when turned on or settings
	are changed.

	The overlay does not constantly update in a process loop, and this should not be added. It's a waste of cpu.

*/


/obj/item/device/t_scanner/proc/update_overlay()
	//get all objects in scan range
	var/list/scanned = get_scanned_objects(scan_range)
	var/list/update_add = scanned - active_scanned
	var/list/update_remove = active_scanned - scanned

	//Add new overlays
	for(var/obj/O in update_add)
		var/mutable_appearance/overlay = get_overlay(O)
		//var/image/overlay = get_overlay(O)

		active_scanned[O] = overlay
		user_client.images += overlay

	//Remove stale overlays
	for(var/obj/O in update_remove)
		user_client.images -= active_scanned[O]
		active_scanned -= O



//creates a new overlay for a scanned object, if needed
/obj/item/device/t_scanner/proc/get_overlay(obj/scanned)
	//Use a cache so we don't create a whole bunch of new images just because someone's walking back and forth in a room.
	//Also means that images are reused if multiple people are using t-rays to look at the same objects.
	if(scanned in overlay_cache)
		. = overlay_cache[scanned]
	else

		var/mutable_appearance/MA = new(scanned)
		MA.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		MA.plane = current_user.get_relative_plane(GAME_PLANE)
		MA.layer = ABOVE_HUD_LAYER
		MA.alpha = 128

		var/image/I = image(loc = scanned)
		I.appearance = MA
		I.mouse_opacity = 0
		.=I

	// Add it to cache, cutting old entries if the list is too long
	overlay_cache[scanned] = .
	if(overlay_cache.len > OVERLAY_CACHE_LEN)
		overlay_cache.Cut(1, overlay_cache.len-OVERLAY_CACHE_LEN-1)

/*Gets the list of objects to make overlays for.
An object will be shown if it can ever hide under floors, regardless of whether it is currently doing so
While this has some increased performance cost, it allows pipes to be clearly seen even in cases where they
are technically visible but obscured, for example by catwalks or trash sitting on them.
*/
/obj/item/device/t_scanner/proc/get_scanned_objects(var/scan_dist)
	. = list()

	var/turf/center = get_turf(loc)
	if(!center) return

	for(var/turf/T in RANGE_TURFS(scan_range, center))
		for(var/obj/O in T.contents)
			if(O.level != BELOW_PLATING_LEVEL)
				continue
			if(!O.invisibility && !O.hides_under_flooring())
				continue //if it's already visible don't need an overlay for it
			if(istype(O, /obj/item/weapon/storage))
				var/obj/item/weapon/storage/S = O
				if(S.is_tray_hidden)
					continue
			. += O




/***************************************
	Interaction
***************************************/
/obj/item/device/t_scanner/attack_self(mob/user)
	set_user(user)
	nano_ui_interact(user)
	//set_enabled(!enabled)

//Alt click provides a rapid way to turn it on and off
/obj/item/device/t_scanner/AltClick(var/mob/M)
	if(loc == M)
		set_enabled(!enabled)

/obj/item/device/t_scanner/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	// this is the data which will be sent to the ui
	var/data[0]
	data["enabled"] = enabled ? 1 : 0
	get_power_cost()
	data["wattage"] = (get_power_cost()/CELLRATE)
	data["lifeTime"] = get_lifetime()
	data["cellPercent"] = cell ? round(cell.percent(),0.1) : SPAN_DANGER("---")
	data["powerSetting"] = scan_range

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "t_ray.tmpl", "Terahertz Ray Emitter", 440, 300)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/item/device/t_scanner/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["toggleStatus"])
		set_enabled(!enabled)
	if(href_list["setPower"]) //setting power to 0 is redundant anyways
		var/new_setting = between(1, text2num(href_list["setPower"]), 7)
		scan_range = new_setting
		if(active)
			update_overlay()
	playsound(loc, 'sound/machines/machine_switch.ogg', 40, 1, -2)
	add_fingerprint(usr)
	spawn()
		nano_ui_interact(usr)


/************************************
	STATE MANAGEMENT
************************************/
/obj/item/device/t_scanner/Process()
	if(enabled && !cell_use_check(get_power_cost()))
		set_enabled(FALSE)
		return //Ran out of power


/obj/item/device/t_scanner/proc/set_enabled(targetstate)
	//Check power here#
	if(targetstate == FALSE && enabled)
		playsound(loc, turn_on_sound, 55, 1,-2)
	enabled = FALSE
	if(targetstate == TRUE)
		if(cell_use_check(active_power_usage*(scan_range+2)*CELLRATE))
			enabled = TRUE
			playsound(loc, turn_on_sound, 55, 1, -2)

	if(enabled)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	check_active(enabled)
	update_icon()

/obj/item/device/t_scanner/proc/check_active(var/targetstate = TRUE)
	//First of all, check if its being turned off. This is simpler
	if(!targetstate)
		if(!active)
			//If we were just turned off, but we were already inactive, then we don't need to do anything
			return

		//We were active, ok lets shut down things
		set_inactive()
	else
		//We're trying to become active, alright lets do some checks
		//We'll do these checks even if we're already active, they ensure we can remain so
		var/can_activate = TRUE

		//First we must be enabled
		if(!enabled)
			can_activate = FALSE

		//Secondly, we must be held in someone's hands
		else if(!check_location())
			can_activate = FALSE

		//Thirdly, we need a client to display to
		else if(!user_client)
			//The client may not be set if the user logged out and in again
			set_client() //Try re-setting it
			if(!user_client)
				can_activate = FALSE

		if(!can_activate)
			//We failed the above, what now
			if(active)
				set_inactive()

		else if(!active)
			set_active()



//Handles shutdown and cleanup
/obj/item/device/t_scanner/proc/set_inactive()
	unset_client(null)
	active = FALSE


/obj/item/device/t_scanner/proc/set_active()
	event_source = get_track_target()
	GLOB.moved_event.register(event_source, src, /obj/item/device/t_scanner/proc/update_overlay)
	active = TRUE
	update_overlay()


//Called in any situation where the user might change
/obj/item/device/t_scanner/proc/set_user(mob/living/newuser)
	if(current_user == newuser)
		return //Do nothing

	//If there's an existing user we may need to unregister them first
	if(current_user)
		unset_client()

	//Actually set it
	current_user = newuser
	set_client()
	event_source = get_track_target()
	check_active()


/obj/item/device/t_scanner/proc/set_client()
	if(!current_user || !current_user.client)
		return FALSE

	user_client = current_user.client


	for(var/scanned in active_scanned)
		user_client.images += active_scanned[scanned]



/obj/item/device/t_scanner/proc/unset_client()
	if(event_source)
		GLOB.moved_event.unregister(event_source, src)
		event_source = null
	if(user_client)
		for(var/scanned in active_scanned)
			user_client.images -= active_scanned[scanned]

	user_client = null
	active_scanned.Cut()





/obj/item/device/t_scanner/proc/check_location()
	//This proc checks that the scanner is where it needs to be.
	//In this case, this means it must be held in the hands of a mob

	//This is a seperate proc so that it can be overridden later. For example to allow for scanners embedded in other things
	if(!ismob(loc))
		return FALSE

	if(!is_held())
		return FALSE

	return TRUE


//Find the object whose movement we will track
//Like the above, this is a seperate proc so it can be overridden
/obj/item/device/t_scanner/proc/get_track_target()
	return current_user


//Returns an estimate of how long the scanner will run on its current remaining battery
/obj/item/device/t_scanner/proc/get_lifetime()
	if(!cell || cell.is_empty())
		return "00:00"

	var/numseconds = cell.charge / get_power_cost()
	return time2text(numseconds*10, "mm:ss") //time2text takes deciseconds, so the amounts are tenfold


//Whenever the scanner is equipped to a slot or dropped on the ground or deleted, set the user appropriately
/obj/item/device/t_scanner/dropped(mob/user)
	.=..()
	set_user(null)

/obj/item/device/t_scanner/equipped(mob/M)
	.=..()
	set_user(M)

/obj/item/device/t_scanner/Destroy()
	set_user(null)
	.=..()
#undef OVERLAY_CACHE_LEN

//Device procs

//This stuff shouldn't be limited to this, but should be basic device behaviour

//How much power we use when enabled. Based on scan range
/obj/item/device/t_scanner/proc/get_power_cost()
	return active_power_usage*(2+(scan_range*0.8))*CELLRATE

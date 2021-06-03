//This could either be split into the proper DM files or placed somewhere else all together, but it'll do for now -Nodrak

/*

A list of items and costs is stored under the datum of every game mode, alongside the number of crystals, and the welcoming message.

*/

/obj/item/device/uplink
	spawn_blacklisted = TRUE
	var/welcome = "Welcome, Operative"	// Welcoming menu message
	var/uses 							// Numbers of crystals
	var/list/ItemsCategory				// List of categories with lists of items
	var/list/ItemsReference				// List of references with an associated item
	var/list/nanoui_items				// List of items for NanoUI use
	var/nanoui_menu = 0					// The current menu we are in
	var/list/nanonano_ui_data = new 			// Additional data for NanoUI use

	var/list/purchase_log = new
	var/datum/mind/uplink_owner
	var/used_TC = 0

	var/list/owner_roles = new


	var/passive_gain = 0.1 //Number of telecrystals this uplink gains per minute.
	//The total uses is only increased when this is a whole number
	var/gain_progress = 0

	var/bsdm_time = 0

/obj/item/device/uplink/nano_host()
	return loc

/obj/item/device/uplink/New(var/location, var/datum/mind/owner, var/telecrystals = DEFAULT_TELECRYSTAL_AMOUNT)
	..()
	src.uplink_owner = owner
	purchase_log = list()
	world_uplinks += src
	uses = telecrystals
	addtimer(CALLBACK(src, .obj/item/device/uplink/proc/gain_TC), 600)

/obj/item/device/uplink/Destroy()
	world_uplinks -= src
	return ..()


//Passive TC gain, triggers once per minute as long as the owner is alive and active
/obj/item/device/uplink/proc/gain_TC()
	addtimer(CALLBACK(src, .obj/item/device/uplink/proc/gain_TC), 600)
	if (!uplink_owner || !uplink_owner.current)
		return

	var/mob/M = uplink_owner.current
	if (M.stat == DEAD)
		return

	gain_progress += passive_gain
	if (gain_progress >= 1)
		uses += 1
		gain_progress -= 1



// HIDDEN UPLINK - Can be stored in anything but the host item has to have a trigger for it.
/* How to create an uplink in 3 easy steps!

 1. All obj/item 's have a hidden_uplink var. By default it's null. Give the item one with "new(src)", it must be in it's contents. Feel free to add "uses".

 2. Code in the triggers. Use check_trigger for this, I recommend closing the item's menu with "usr << browse(null, "window=windowname") if it returns true.
 The var/value is the value that will be compared with the var/target. If they are equal it will activate the menu.

 3. If you want the menu to stay until the users locks his uplink, add an active_uplink_check(mob/user as mob) in your interact/attack_hand proc.
 Then check if it's true, if true return. This will stop the normal menu appearing and will instead show the uplink menu.
*/

/obj/item/device/uplink/hidden
	name = "hidden uplink"
	desc = "There is something wrong if you're examining this."
	var/active = 0
	var/datum/uplink_category/category 	= 0		// The current category we are in
	var/exploit_id								// Id of the current exploit record we are viewing
	var/trigger_code
	var/emplaced = FALSE


// The hidden uplink MUST be inside an obj/item's contents.
/obj/item/device/uplink/hidden/New(var/location, var/datum/mind/owner, var/telecrystals = DEFAULT_TELECRYSTAL_AMOUNT)
	spawn(2)
		if(!istype(src.loc, /obj))
			qdel(src)
	..()
	nanonano_ui_data = list()
	update_nano_data()

// Toggles the uplink on and off. Normally this will bypass the item's normal functions and go to the uplink menu, if activated.
/obj/item/device/uplink/hidden/proc/toggle()
	active = !active

// Directly trigger the uplink. Turn on if it isn't already.
/obj/item/device/uplink/hidden/proc/trigger(mob/user as mob)
	if(!active)
		toggle()
	interact(user)

// Checks to see if the value meets the target. Like a frequency being a traitor_frequency, in order to unlock a headset.
// If true, it accesses trigger() and returns 1. If it fails, it returns false. Use this to see if you need to close the
// current item's menu.
/obj/item/device/uplink/hidden/proc/check_trigger(mob/user as mob, var/value)
	if(value == trigger_code)
		trigger(user)
		return 1
	return 0

/*
	NANO UI FOR UPLINK WOOP WOOP
*/
/obj/item/device/uplink/hidden/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	var/title = "Remote Uplink"
	var/data[0]

	data["welcome"] = welcome
	data["crystals"] = uses
	data["menu"] = nanoui_menu
	data["has_contracts"] = uplink_owner ? player_is_antag_in_list(uplink_owner, ROLES_CONTRACT | ROLES_CONTRACT_VIEWONLY)\
	                                     : !!length(owner_roles & ROLES_CONTRACT | ROLES_CONTRACT_VIEWONLY)
	data += nanonano_ui_data

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)	// No auto-refresh
		if (emplaced)
			ui = new(user, src, ui_key, "uplink.tmpl", title, 450, 600, state =GLOB.default_state)
		else
			ui = new(user, src, ui_key, "uplink.tmpl", title, 450, 600, state =GLOB.inventory_state)
		ui.set_initial_data(data)
		ui.open()


// Interaction code. Gathers a list of items purchasable from the paren't uplink and displays it. It also adds a lock button.
/obj/item/device/uplink/interact(mob/user)
	nano_ui_interact(user)

// The purchasing code.
/obj/item/device/uplink/hidden/Topic(href, href_list)
	if(..())
		return 1

	var/mob/user = usr
	if(href_list["buy_item"])
		var/datum/uplink_item/UI = (locate(href_list["buy_item"]) in uplink.items)
		UI.buy(src, usr)
	else if(href_list["lock"])
		toggle()
		var/datum/nanoui/ui = SSnano.get_open_ui(user, src, "main")
		ui?.close()
	else if(href_list["return"])
		nanoui_menu = round(nanoui_menu/10)
	else if(href_list["menu"])
		nanoui_menu = text2num(href_list["menu"])
		if(href_list["id"])
			exploit_id = href_list["id"]
		if(href_list["category"])
			category = locate(href_list["category"]) in uplink.categories

	update_nano_data()
	return 1

/obj/item/device/uplink/hidden/proc/update_nano_data()
	nanonano_ui_data["menu"] = nanoui_menu
	if(nanoui_menu == 0)
		var/categories[0]
		for(var/datum/uplink_category/category in uplink.categories)
			if(category.can_view(src))
				categories[++categories.len] = list("name" = category.name, "ref" = "\ref[category]")
		nanonano_ui_data["categories"] = categories
	else if(nanoui_menu == 1)
		var/items[0]
		for(var/datum/uplink_item/item in category.items)

			if(item.can_view(src))
				var/cost = item.cost(uses)
				if(cost == 0)
					cost = "Free"
				else if(!cost)
					cost = "???"
				items[++items.len] = list("name" = item.name, "description" = replacetext(item.description(), "\n", "<br>"), "can_buy" = item.can_buy(src), "cost" = cost, "ref" = "\ref[item]")

		nanonano_ui_data["items"] = items
	else if(nanoui_menu == 2)
		var/permanentData[0]
		for(var/datum/data/record/L in sortRecord(data_core.locked))
			permanentData[++permanentData.len] = list(Name = L.fields["name"],"id" = L.fields["id"])
		nanonano_ui_data["exploit_records"] = permanentData
	else if(nanoui_menu == 21)
		nanonano_ui_data["exploit_exists"] = 0

		for(var/datum/data/record/L in data_core.locked)
			if(L.fields["id"] == exploit_id)
				nanonano_ui_data["exploit"] = list()  // Setting this to equal L.fields passes it's variables that are lists as reference instead of value.
								 // We trade off being able to automatically add shit for more control over what gets passed to json
								 // and if it's sanitized for html.
				nanonano_ui_data["exploit"]["nanoui_exploit_record"] = html_encode(L.fields["exploit_record"])                         		// Change stuff into html
				nanonano_ui_data["exploit"]["nanoui_exploit_record"] = replacetext(nanonano_ui_data["exploit"]["nanoui_exploit_record"], "\n", "<br>")    // change line breaks into <br>
				nanonano_ui_data["exploit"]["name"] =  html_encode(L.fields["name"])
				nanonano_ui_data["exploit"]["sex"] =  html_encode(L.fields["sex"])
				nanonano_ui_data["exploit"]["age"] =  html_encode(L.fields["age"])
				nanonano_ui_data["exploit"]["species"] =  html_encode(L.fields["species"])
				nanonano_ui_data["exploit"]["rank"] =  html_encode(L.fields["rank"])
				nanonano_ui_data["exploit"]["fingerprint"] =  html_encode(L.fields["fingerprint"])

				nanonano_ui_data["exploit_exists"] = 1
				break
	else if(nanoui_menu == 3 && (uplink_owner ? player_is_antag_in_list(uplink_owner, ROLES_CONTRACT | ROLES_CONTRACT_VIEWONLY) : !!length(owner_roles & ROLES_CONTRACT | ROLES_CONTRACT_VIEWONLY)))
		var/list/available_contracts = list()
		var/list/completed_contracts = list()
		for(var/datum/antag_contract/C in GLOB.various_antag_contracts)
			var/list/entry = list(list(
				"name" = C.name,
				"desc" = C.desc,
				"reward" = C.reward,
				"status" = C.completed ? "Fulfilled" : "Available"
			))
			if(!C.completed)
				available_contracts.Add(entry)
			else
				completed_contracts.Add(entry)
		nanonano_ui_data["available_contracts"] = available_contracts
		nanonano_ui_data["completed_contracts"] = completed_contracts

// I placed this here because of how relevant it is.
// You place this in your uplinkable item to check if an uplink is active or not.
// If it is, it will display the uplink menu and return 1, else it'll return false.
// If it returns true, I recommend closing the item's normal menu with "user << browse(null, "window=name")"
/obj/item/proc/active_uplink_check(mob/user as mob)
	// Activates the uplink if it's active
	if(src.hidden_uplink)
		if(src.hidden_uplink.active)
			src.hidden_uplink.trigger(user)
			return 1
	return 0

// PRESET UPLINKS
// A collection of preset uplinks.
//
// Includes normal radio uplink, multitool uplink,
// implant uplink (not the implant tool) and a preset headset uplink.

/obj/item/device/radio/uplink/New(loc, mind, crystal_amount)
	..(loc)
	hidden_uplink = new(src, mind, crystal_amount)
	icon_state = "radio"

/obj/item/device/radio/uplink/attack_self(mob/user)
	if(hidden_uplink)
		hidden_uplink.trigger(user)

/obj/item/weapon/tool/multitool/uplink/New(loc, mind, crystal_amount)
	..(loc)
	hidden_uplink = new(src, mind, crystal_amount)


/obj/item/weapon/tool/multitool/uplink/attack_self(mob/user as mob)
	if(hidden_uplink)
		hidden_uplink.trigger(user)

/obj/item/device/radio/headset/uplink
	traitor_frequency = 1445

/obj/item/device/radio/headset/uplink/New(loc, mind, crystal_amount = DEFAULT_TELECRYSTAL_AMOUNT)
	..(loc)
	hidden_uplink = new(src, mind, crystal_amount)
	hidden_uplink.uses = DEFAULT_TELECRYSTAL_AMOUNT



//Uplink beacon
//A large dense uplink object that can't be moved. Designed for use by team antags on their shuttles
/obj/structure/uplink
	name = "Uplink Beacon"
	icon = 'icons/obj/supplybeacon.dmi'
	desc = "A bulky machine used for teleporting in supplies from a benefactor."
	icon_state = "beacon"
	density = TRUE
	anchored = TRUE
	var/obj/item/device/uplink/hidden/uplink
	var/telecrystals = 100
	var/owner_roles //Can be a list of roles or a single role

/obj/structure/uplink/New()
	uplink = new(src, null, telecrystals)
	uplink.update_nano_data()
	uplink.emplaced = TRUE
	if(owner_roles)
		uplink.owner_roles |= owner_roles
	..()

/obj/structure/uplink/attack_hand(var/mob/user)
	uplink.trigger(user)

/obj/structure/uplink/mercenary
	owner_roles = ROLE_MERCENARY

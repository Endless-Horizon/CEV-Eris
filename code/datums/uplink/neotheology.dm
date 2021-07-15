/*******************************
* NeoTheology: Religious items *
*******************************/
/*
Intended for inquisitors and maybe future crusaders
A small pool of thematically appropriate religious items that are generally cheaper than conventional equivilants
*/


//Lets make sure only appropriately ranked NT Church members can see this category
//We do this by setting canview conditions on the individual items like this.
//These are checked by the category, and also in other places
/datum/uplink_item/item/neotheology/can_view(obj/item/device/uplink/U)
	if (!U || !U.uplink_owner || !U.uplink_owner.current)
		return FALSE

	//Get the mob and their cruciform implant
	var/mob/living/L = U.uplink_owner.current
	var/obj/item/implant/core_implant/cruciform/C = L.get_core_implant(/obj/item/implant/core_implant/cruciform)

	if (!C)
		return FALSE

	//Now lets check that cruciform for modules that indicate rank

	//Inquisitor is okay
	if (C.get_module(CRUCIFORM_INQUISITOR))
		return TRUE

	//Crusader is fine too
	if (C.get_module(/datum/core_module/rituals/cruciform/crusader))
		return TRUE

	return FALSE



/datum/uplink_item/item/neotheology
	category = /datum/uplink_category/neotheology

//A single blank cruciform implant, nothing special about it. Useful for field baptism
/datum/uplink_item/item/neotheology/cruciform
	name = "Cruciform Implant"
	item_cost = 1
	path = /obj/item/implant/core_implant/cruciform


//A ritual book, for if you lose your own. Note that all books are the same, the rituals are stored in the cruciform implant
/datum/uplink_item/item/neotheology/bible
	name = "Ritual Book"
	item_cost = 1
	path = /obj/item/book/ritual/cruciform




//A priest cruciform implant, allows field promotion of a disciple to a preacher.
//This also requires an inquisitor ritual to complete the process, so it can't be done by anyone else
/datum/uplink_item/item/neotheology/priest
	name = "Preacher Ascension Kit"
	item_cost = 3
	path = /obj/item/coreimplant_upgrade/cruciform/priest


//Ritual blade, for if you need a competent weapon, or for replacing one the preacher lost
/datum/uplink_item/item/neotheology/knife
	name = "Ritual Blade"
	item_cost = 2
	path = /obj/item/tool/knife/neotritual


/datum/uplink_item/item/neotheology/coat
	name = "Preacher Coat"
	item_cost = 3
	path = /obj/item/clothing/suit/storage/neotheology_coat

/datum/uplink_item/item/neotheology/hat
	name = "Preacher Hat"
	item_cost = 3
	path = /obj/item/clothing/head/preacher

/*
	Guns: All taken from the NeoTheology Armory of the New Testament
	All guns are 1 TC cheaper than the closest equivilant in normal traitor gear
*/
/datum/uplink_item/item/neotheology/laser
	item_cost = 10
	name = "NT LG \"Lightfall\""
	path = /obj/item/gun/energy/laser

/datum/uplink_item/item/neotheology/ion
	item_cost = 8
	name = "NT IR \"Halicon\""
	path = /obj/item/gun/energy/ionrifle


/datum/uplink_item/item/neotheology/pulse
	item_cost = 10
	name = "NT PR \"Dominion\""
	path = /obj/item/gun/energy/plasma

/datum/uplink_item/item/neotheology/pulse_destroyer
	item_cost = 10
	name = "NT PR \"Purger\""
	path = /obj/item/gun/energy/plasma/destroyer



/datum/uplink_item/item/neotheology/xbow
	item_cost = 5
	name = "NT EC \"Nemesis\""
	path = /obj/item/gun/energy/crossbow

/datum/uplink_item/item/neotheology/xbow_heavy
	item_cost = 8
	name = "NT EC \"Themis\""
	path = /obj/item/gun/energy/crossbow/largecrossbow


/datum/uplink_item/item/neotheology/sniper
	item_cost = 13
	name = "NT MER \"Valkyrie\""
	path = /obj/item/gun/energy/sniperrifle


/*
 *	These absorb the functionality of the plant bag, ore satchel, etc.
 *	They use the use_to_pickup, quick_gather, and quick_empty functions
 *	that were already defined in weapon/storage, but which had been
 *	re-implemented in other classes.
 *
 *	Contains:
 *		Trash Bag
 *		Mining Satchel
 *		Plant Bag
 *		Sheet Snatcher
 *		Cash Bag
 *
 *	-Sayu
 */

//  Generic non-item
/obj/item/storage/bag
	icon = 'icons/obj/storage.dmi'
	allow_quick_gather = TRUE
	allow_quick_empty = TRUE
	display_contents_with_number = TRUE
	use_to_pickup = TRUE
	slot_flags = SLOT_BELT

// -----------------------------
//          Trash bag
// -----------------------------
/obj/item/storage/bag/trash
	name = "trash bag"
	desc = "It's the heavy-duty black polymer kind. Time to take out the trash!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "trashbag0"
	item_state = "trashbag"

	w_class = ITEM_SIZE_NORMAL
	max_w_class = ITEM_SIZE_SMALL
	can_hold = list() // any
	cant_hold = list(/obj/item/disk/nuclear)
	max_storage_space = DEFAULT_NORMAL_STORAGE

/obj/item/storage/bag/trash/on_update_icon()
	if(contents.len == 0)
		icon_state = "trashbag0"
	else if(contents.len < 12)
		icon_state = "trashbag1"
	else if(contents.len < 21)
		icon_state = "trashbag2"
	else
		icon_state = "trashbag3"


//The custodial robot gets a larger bag since it only has one and no cart
/obj/item/storage/bag/trash/robot
	max_storage_space = DEFAULT_BULKY_STORAGE * 2
	spawn_tags = null

/obj/item/storage/bag/trash/robot/on_update_icon()
	if(contents.len == 0)
		icon_state = "trashbag0"
	else if(contents.len < 24)
		icon_state = "trashbag1"
	else if(contents.len < 42)
		icon_state = "trashbag2"
	else
		icon_state = "trashbag3"

/obj/item/storage/bag/trash/holding
	name = "trash bag of holding"
	desc = "The latest and greatest in custodial convenience, a trashbag that is capable of holding vast quantities of garbage."
	icon_state = "bluetrashbag"
	max_w_class = ITEM_SIZE_BULKY
	max_storage_space = DEFAULT_HUGE_STORAGE * 1.25
	matter = list(MATERIAL_STEEL = 6, MATERIAL_GOLD = 6, MATERIAL_DIAMOND = 2, MATERIAL_URANIUM = 2)
	spawn_blacklisted = TRUE

/obj/item/storage/bag/trash/holding/New()
	..()
	bluespace_entropy(4, get_turf(src))

/obj/item/storage/bag/trash/holding/on_update_icon()
	return

// -----------------------------
//        Plastic Bag
// -----------------------------

/obj/item/storage/bag/plastic
	name = "plastic bag"
	desc = "It's a very flimsy, very noisy alternative to a bag."
	icon = 'icons/obj/trash.dmi'
	icon_state = "plasticbag"
	item_state = "plasticbag"

	w_class = ITEM_SIZE_BULKY
	max_w_class = ITEM_SIZE_SMALL
	max_storage_space = DEFAULT_SMALL_STORAGE
	can_hold = list() // any

// -----------------------------
//        Mining Satchel
// -----------------------------

/obj/item/storage/bag/ore
	name = "mining satchel"
	desc = "This little bugger can be used to store and transport ores."
	icon = 'icons/obj/mining.dmi'
	icon_state = "satchel"
	slot_flags = SLOT_BELT | SLOT_POCKET
	w_class = ITEM_SIZE_NORMAL
	max_storage_space = 200
	max_w_class = ITEM_SIZE_NORMAL
	can_hold = list(/obj/item/ore)

/obj/item/storage/bag/ore/holding
	name = "satchel of holding"
	desc = "A revolution in convenience, this satchel allows for infinite ore or produce storage. It's been outfitted with anti-malfunction safety measures."
	icon_state = "satchel_bspace"
	max_storage_space = INFINITY
	max_w_class = ITEM_SIZE_BULKY
	matter = list(MATERIAL_STEEL = 4, MATERIAL_GOLD = 4, MATERIAL_DIAMOND = 2, MATERIAL_URANIUM = 2)
	origin_tech = list(TECH_BLUESPACE = 4)
	can_hold = list(/obj/item/ore,
	                /obj/item/reagent_containers/food/snacks/grown,
	                /obj/item/seeds,
	                /obj/item/grown,
	                /obj/item/reagent_containers/food/snacks/egg,
	                /obj/item/reagent_containers/food/snacks/meat)

/obj/item/storage/bag/ore/holding/New()
	..()
	bluespace_entropy(10, get_turf(src))

// -----------------------------
//          Produce bag
// -----------------------------

/obj/item/storage/bag/produce
	name = "produce bag"
	icon = 'icons/obj/hydroponics_machines.dmi'
	icon_state = "plantbag"
	max_storage_space = 100
	max_w_class = ITEM_SIZE_NORMAL
	w_class = ITEM_SIZE_NORMAL
	can_hold = list(/obj/item/reagent_containers/food/snacks/grown,
		/obj/item/seeds,
		/obj/item/grown,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/meat)


// -----------------------------
//        Sheet Snatcher
// -----------------------------
// Because it stacks stacks, this doesn't operate normally.
// However, making it a storage/bag allows us to reuse existing code in some places. -Sayu

/obj/item/storage/bag/sheetsnatcher
	name = "sheet snatcher"
	icon = 'icons/obj/mining.dmi'
	icon_state = "sheetsnatcher"
	desc = "A patented storage system designed for any kind of mineral sheet."

	var/capacity = 300; //the number of sheets it can carry.
	w_class = ITEM_SIZE_NORMAL
	storage_slots = 7
	allow_quick_empty = TRUE // this function is superceded

/obj/item/storage/bag/sheetsnatcher/can_be_inserted(obj/item/W as obj, stop_messages = 0)
	if(!istype(W,/obj/item/stack/material))
		if(!stop_messages)
			to_chat(usr, "The snatcher does not accept [W].")
		return 0
	var/current = 0
	for(var/obj/item/stack/material/S in contents)
		current += S.amount
	if(capacity == current)//If it's full, you're done
		if(!stop_messages)
			to_chat(usr, SPAN_WARNING("The snatcher is full."))
		return 0
	return 1


// Modified handle_item_insertion.  Would prefer not to, but...
/obj/item/storage/bag/sheetsnatcher/handle_item_insertion(obj/item/W as obj, prevent_warning = 0)
	var/obj/item/stack/material/S = W
	if(!istype(S)) return 0

	var/amount
	var/inserted = 0
	var/current = 0
	for(var/obj/item/stack/material/S2 in contents)
		current += S2.amount
	if(capacity < current + S.amount)//If the stack will fill it up
		amount = capacity - current
	else
		amount = S.amount

	for(var/obj/item/stack/material/sheet in contents)
		if(S.type == sheet.type) // we are violating the amount limitation because these are not sane objects
			sheet.amount += amount	// they should only be removed through procs in this file, which split them up.
			S.amount -= amount
			inserted = 1
			break

	if(!inserted || !S.amount)
		usr.remove_from_mob(S)
		usr.update_icons() //update our overlays
		if (usr.client)
			usr.client.screen -= S
		S.dropped(usr)
		if(!S.amount)
			qdel(S)
		else
			S.loc = src

	refresh_all()
	update_icon()
	return 1

// Modified quick_empty verb drops appropriate sized stacks
/obj/item/storage/bag/sheetsnatcher/quick_empty()
	var/location = get_turf(src)
	for(var/obj/item/stack/material/S in contents)
		while(S.amount)
			var/obj/item/stack/material/N = new S.type(location)
			var/stacksize = min(S.amount,N.max_amount)
			N.amount = stacksize
			S.amount -= stacksize
		if(!S.amount)
			qdel(S) // todo: there's probably something missing here

	refresh_all()
	update_icon()

// Instead of removing
/obj/item/storage/bag/sheetsnatcher/remove_from_storage(obj/item/W as obj, atom/new_location)
	var/obj/item/stack/material/S = W
	if(!istype(S)) return 0

	//I would prefer to drop a new stack, but the item/attack_hand code
	// that calls this can't recieve a different object than you clicked on.
	//Therefore, make a new stack internally that has the remainder.
	// -Sayu

	if(S.amount > S.max_amount)
		var/obj/item/stack/material/temp = new S.type(src)
		temp.amount = S.amount - S.max_amount
		S.amount = S.max_amount

	return ..(S,new_location)

// -----------------------------
//    Sheet Snatcher (Cyborg)
// -----------------------------

/obj/item/storage/bag/sheetsnatcher/borg
	name = "sheet snatcher 9000"
	capacity = 500//Borgs get more because >specialization
	spawn_frequency = 0

// -----------------------------
//           Cash Bag
// -----------------------------

/obj/item/storage/bag/money
	name = "money bag"
	icon = 'icons/obj/storage.dmi'
	icon_state = "moneybag"
	desc = "A bag for carrying lots of cash. It's got a big dollar sign printed on the front."
	storage_slots = 40
	max_storage_space = 100
	max_w_class = ITEM_SIZE_NORMAL
	w_class = ITEM_SIZE_HUGE
	can_hold = list(/obj/item/coin,
		/obj/item/spacecash)

/obj/item/storage/bag/money/Initialize()
	. = ..()
	if(prob(20))
		icon_state = "moneybagalt"

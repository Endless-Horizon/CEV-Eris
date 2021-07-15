//todo: get rid of s_active
//todo: close hud when storage item is thrown

/obj/item/storage
	name = "storage"
	icon = 'icons/obj/storage.dmi'
	w_class = ITEM_SIZE_NORMAL
	item_flags = DRAG_AND_DROP_UNEQUIP|EQUIP_SOUNDS
	spawn_tags = SPAWN_TAG_STORAGE
	bad_type = /obj/item/storage
	var/list/can_hold = new/list() //List of objects which this item can store (if set, it can't store anything else)
	var/list/can_hold_extra = list() //List of objects which this item can additionally store not defined by the parent.
	var/list/cant_hold = new/list() //List of objects which this item can't store (in effect only if can_hold isn't set)
	var/list/is_seeing = new/list() //List of mobs which are currently seeing the contents of this item's storage
	var/max_w_class = ITEM_SIZE_NORMAL //Max size of objects that this object can store (in effect only if can_hold isn't set)
	var/max_storage_space //Total storage cost of items this can hold. Will be autoset based on storage_slots if left null.
	var/storage_slots //The number of storage slots in this container.
	var/use_to_pickup //Set this to make it possible to use this item in an inverse way, so you can have the item in your hand and click items on the floor to pick them up.
	var/display_contents_with_number //Set this to make the storage item group contents of the same type and display them as a number.
	var/allow_quick_empty //Set this variable to allow the object to have the 'empty' verb, which dumps all the contents on the floor.
	var/allow_quick_gather //Set this variable to allow the object to have the 'toggle mode' verb, which quickly collects all items from a tile.
	var/collection_mode = TRUE //0 = pick one at a time, 1 = pick all on tile
	var/use_sound = "rustle" //sound played when used. null for no sound.
	var/is_tray_hidden = FALSE //hides from even t-rays

/obj/item/storage/New()
	can_hold |= can_hold_extra
	. = ..()

/HUD_element/threePartBox/storageBackground
	start_icon = icon("icons/HUD/storage_start.png")
	middle_icon = icon("icons/HUD/storage_middle.png")
	end_icon = icon("icons/HUD/storage_end.png")

/HUD_element/threePartBox/storedItemBackground
	start_icon = icon("icons/HUD/stored_start.png")
	middle_icon = icon("icons/HUD/stored_middle.png")
	end_icon = icon("icons/HUD/stored_end.png")

/HUD_element/slottedItemBackground
	icon = 'icons/HUD/block.png'

/obj/item/storage/proc/storageBackgroundClick(HUD_element/sourceElement, mob/clientMob, location, control, params)
	var/atom/A = sourceElement.getData("item")
	if(A)
		var/obj/item/I = clientMob.get_active_hand()
		if(I)
			clientMob.ClickOn(A)

/obj/item/storage/proc/itemBackgroundClick(HUD_element/sourceElement, mob/clientMob, location, control, params)
	var/atom/A = sourceElement.getData("item")
	if(A)
		clientMob.ClickOn(A)

/obj/item/storage/proc/closeButtonClick(HUD_element/sourceElement, mob/clientMob, location, control, params)
	var/obj/item/storage/S = sourceElement.getData("item")
	if(S)
		S.close(clientMob)

/obj/item/storage/proc/setupItemBackground(var/HUD_element/itemBackground, atom/item, itemCount)
	itemBackground.setClickProc(.proc/itemBackgroundClick)
	itemBackground.setData("item", item)

	var/HUD_element/itemIcon = itemBackground.add(new/HUD_element())
	itemIcon.setDimensions(32,32) //todo: should be width/height of real object icon
	itemIcon.setAlignment(HUD_CENTER_ALIGNMENT,HUD_CENTER_ALIGNMENT) //center

	//todo: remove vis_contents, use mimic icon, make wrappers for dragdrop/examine/clicks, do not alter item
	item.pixel_x = 0 //no pixel offsets inside storage
	item.pixel_y = 0
	item.pixel_w = 0
	item.pixel_z = 0
	item.layer = ABOVE_HUD_LAYER
	item.plane = ABOVE_HUD_PLANE

	itemIcon.vis_contents += item //this draws the actual item, see byond ref for vis_contents var
	itemBackground.setName(item.name, TRUE)

	if (itemCount)
		item.maptext = "<font color='white'>[itemCount]</font>"

/obj/item/storage/proc/generateHUD(datum/hud/data)
	RETURN_TYPE(/HUD_element)
	var/HUD_element/main = new("storage")
	main.setDeleteOnHide(TRUE)

	var/HUD_element/closeButton = new
	closeButton.setName("HUD Storage Close Button")
	closeButton.setIcon(icon("icons/mob/screen1.dmi","x"))
	closeButton.setHideParentOnClick(TRUE)
	closeButton.setClickProc(.proc/closeButtonClick)
	closeButton.setData("item", src)

	//storage space based items
	if((storage_slots == null) && !display_contents_with_number)
		var/baseline_max_storage_space = 16 //should be equal to default backpack capacity
		var/minBackgroundWidth = min( round( 224 * max_storage_space/baseline_max_storage_space ,1) ,260) //in pixels

		var/HUD_element/threePartBox/storageBackground/storageBackground = new()
		main.add(storageBackground)

		storageBackground.setName("HUD Storage Background")
		storageBackground.setHideParentOnHide(TRUE)

		storageBackground.setClickProc(.proc/storageBackgroundClick)
		storageBackground.setData("item", src)

		var/paddingSides = 2 //in pixels
		var/spacingBetweenSlots = 1 //in pixels

		var/totalWidth = 0 + paddingSides //in pixels
		var/totalStorageCost = 0

		for(var/obj/item/I in contents)
			var/itemStorageCost = I.get_storage_cost()
			totalStorageCost += itemStorageCost

			var/HUD_element/threePartBox/storedItemBackground/itemBackground = new()
			storageBackground.add(itemBackground)

			var/itemBackgroundWidth = round(minBackgroundWidth * itemStorageCost/max_storage_space)
			itemBackground.setPosition(totalWidth,0)
			itemBackground.scaleToSize(itemBackgroundWidth)
			itemBackground.setAlignment(HUD_NO_ALIGNMENT,HUD_CENTER_ALIGNMENT) //vertical center

			setupItemBackground(itemBackground,I)

			totalWidth += itemBackground.getWidth() + spacingBetweenSlots

		if (contents.len)
			totalWidth -= spacingBetweenSlots

		var/remainingStorage = max_storage_space - totalStorageCost
		if (remainingStorage)
			remainingStorage += 2 //in pixels, creates a small area where items can be put

		storageBackground.scaleToSize(max(totalWidth + remainingStorage, minBackgroundWidth) + paddingSides)

		storageBackground.add(closeButton)
		closeButton.setAlignment(HUD_HORIZONTAL_EAST_OUTSIDE_ALIGNMENT,HUD_CENTER_ALIGNMENT) //east of parent, center

	//slot storage based items
	else
		var/list/storage_contents
		var/list/filtered_contents_last
		var/list/filtered_contents_count
		if (display_contents_with_number) //used to display number next to item icons, indicating how many of such items are in storage
			storage_contents = new //item types in storage
			filtered_contents_last = new //last of x item type in storage
			filtered_contents_count = new //total number of x item type in storage
			for(var/obj/item/I in contents) //count items and remember last item for each type
				var/item_type = I.type
				if (filtered_contents_count[item_type])
					filtered_contents_count[item_type]++
				else
					storage_contents.Add(item_type)
					filtered_contents_count[item_type] = 1

				filtered_contents_last[item_type] = I
		else
			storage_contents = contents //items in storage

		var/spacingBetweenSlots = 0 //in pixels

		var/totalWidth = 0 //in pixels
		var/totalHeight = 0

		var/slotsToDisplay = storage_contents.len+1 //how many item slots are being displayed
		if (storage_slots)
			slotsToDisplay = min(slotsToDisplay, storage_slots) //limit display to max slot count, if present

		var/currentSlot
		var/currentItemNumber = 1
		var/maxColumnCount = min(data.StorageData["ColCount"], slotsToDisplay)
		for (currentSlot = 1, currentSlot <= slotsToDisplay, currentSlot++)
			var/HUD_element/slottedItemBackground/itemBackground = new()
			main.add(itemBackground)
			itemBackground.setPosition(totalWidth, totalHeight)

			if (currentItemNumber <= storage_contents.len)
				if (display_contents_with_number)
					var/item_type = storage_contents[currentItemNumber]
					setupItemBackground(itemBackground, filtered_contents_last[item_type], filtered_contents_count[item_type])
				else
					setupItemBackground(itemBackground, storage_contents[currentItemNumber])

				currentItemNumber++
			else //empty slots
				itemBackground.setClickProc(.proc/storageBackgroundClick)
				itemBackground.setData("item", src)

			totalWidth += itemBackground.getWidth() + spacingBetweenSlots

			if (!(currentSlot%maxColumnCount))
				if (!totalHeight)
					main.add(closeButton)
					closeButton.setPosition(totalWidth, 0)

				totalWidth = 0 //reset width
				totalHeight = (currentSlot/maxColumnCount) * (itemBackground.getHeight() + spacingBetweenSlots)

	main.setPosition(data.StorageData["Xspace"],data.StorageData["Yspace"])
	return main

/obj/item/storage/Destroy()
	close_all()
	. = ..()

/obj/item/storage/MouseDrop(obj/over_object)
	if(ishuman(usr) && usr == over_object && !usr.incapacitated() && Adjacent(usr))
		return src.open(usr)
	return ..()

/obj/item/storage/proc/return_inv()
	var/list/L = list()

	L += src.contents

	for(var/obj/item/storage/S in src)
		L += S.return_inv()
	for(var/obj/item/gift/G in src)
		L += G.gift
		if (istype(G.gift, /obj/item/storage))
			L += G.gift:return_inv()
	return L

/obj/item/storage/proc/show_to(mob/user)
	if(!user.client)
		return

	if(user.s_active != src) //opening a new storage item
		if (user.s_active) //user already had a storage item open
			user.s_active.close(user)

		for(var/obj/item/I in src)
			if(I.on_found(user)) //trigger mousetraps etc.
				return

	var/datum/hud/data = GLOB.HUDdatums[user.defaultHUD]
	if(data)
		generateHUD(data).show(user.client)
		is_seeing |= user
		user.s_active = src
	SEND_SIGNAL(src, COMSIG_STORAGE_OPENED, user)
	SEND_SIGNAL(user, COMSIG_STORAGE_OPENED, src)

/obj/item/storage/proc/hide_from(mob/user)
	is_seeing -= user
	if (user.s_active == src)
		user.s_active = null

	if(!user.client)
		return

	user.client.hide_HUD_element("storage")

/obj/item/storage/proc/open(mob/user)
	if(src.use_sound)
		playsound(src.loc, src.use_sound, 50, 1, -5)

	show_to(user)

/obj/item/storage/proc/close(mob/user)
	hide_from(user)

/obj/item/storage/AltClick(mob/user)
	if(user.incapacitated())
		to_chat(user, SPAN_WARNING("You can't do that right now!"))
		return
	if(!in_range(src, user))
		return
	else
		src.open(user)

/obj/item/storage/proc/close_all()
	for(var/mob/M in is_seeing)
		close(M)

/obj/item/storage/proc/refresh_all()
	for (var/mob/M in is_seeing)
		if (M.client)
			var/datum/hud/data = GLOB.HUDdatums[M.defaultHUD]
			if (data)
				generateHUD(data).show(M.client)

//This proc return 1 if the item can be picked up and 0 if it can't.
//Set the stop_messages to stop it from printing messages
/obj/item/storage/proc/can_be_inserted(obj/item/W as obj, stop_messages = 0)
	if(!istype(W)) return //Not an item

	if(usr && usr.isEquipped(W) && !usr.canUnEquip(W))
		return 0

	if(src.loc == W)
		return 0 //Means the item is already in the storage item
	if(storage_slots != null && contents.len >= storage_slots)
		if(!stop_messages)
			to_chat(usr, SPAN_NOTICE("[src] is full, make some space."))
		return 0 //Storage item is full

	if(W.anchored)
		return 0

	if(can_hold.len)
		if(!is_type_in_list(W, can_hold))
			if(!stop_messages && ! istype(W, /obj/item/hand_labeler))
				to_chat(usr, SPAN_NOTICE("[src] cannot hold \the [W]."))
			return 0
		var/max_instances = can_hold[W.type]
		if(max_instances && instances_of_type_in_list(W, contents) >= max_instances)
			if(!stop_messages && !istype(W, /obj/item/hand_labeler))
				to_chat(usr, SPAN_NOTICE("[src] has no more space specifically for \the [W]."))
			return 0

	if(cant_hold.len && is_type_in_list(W, cant_hold))
		if(!stop_messages)
			to_chat(usr, SPAN_NOTICE("[src] cannot hold [W]."))
		return 0

	if (max_w_class != null && W.w_class > max_w_class)
		if(!stop_messages)
			to_chat(usr, SPAN_NOTICE("[W] is too long for this [src]."))
		return 0

	//Slot based storage overrides space-based storage
	if(storage_slots == null)
		var/total_storage_space = W.get_storage_cost()
		for(var/obj/item/I in contents)
			total_storage_space += I.get_storage_cost() //Adds up the combined w_classes which will be in the storage item if the item is added to it.

		if(total_storage_space > max_storage_space)
			if(!stop_messages)
				to_chat(usr, SPAN_NOTICE("[src] is too full, make some space."))
			return 0

	if(W.w_class >= src.w_class && (istype(W, /obj/item/storage)))
		if(!stop_messages)
			to_chat(usr, SPAN_NOTICE("[src] cannot hold [W] as it's a storage item of the same size."))
		return 0 //To prevent the stacking of same sized storage items.

	return 1

//This proc handles items being inserted. It does not perform any checks of whether an item can or can't be inserted. That's done by can_be_inserted()
//The stop_warning parameter will stop the insertion message from being displayed. It is intended for cases where you are inserting multiple items at once,
//such as when picking up all the items on a tile with one click.
/obj/item/storage/proc/handle_item_insertion(obj/item/W, prevent_warning = 0)
	if (!istype(W)) return 0
	if (usr)
		usr.prepare_for_slotmove(W)
		usr.update_icons() //update our overlays

	W.loc = src
	W.on_enter_storage(src)

	if(usr)
		if (usr.client)
			usr.client.screen -= W
		W.dropped(usr)
		add_fingerprint(usr)

		if (!prevent_warning)
			for (var/mob/M in viewers(usr, null))
				if (M == usr)
					to_chat(usr, SPAN_NOTICE("You put \the [W] into [src]."))
				else if (M in range(1)) //If someone is standing close enough, they can tell what it is...
					M.show_message(SPAN_NOTICE("\The [usr] puts [W] into [src]."))
				else if (W && W.w_class >= ITEM_SIZE_NORMAL) //Otherwise they can only see large or normal items from a distance...
					M.show_message(SPAN_NOTICE("\The [usr] puts [W] into [src]."))

	refresh_all()

	update_icon()
	return 1

//Call this proc to handle the removal of an item from the storage item. The item will be moved to the atom sent as new_target
/obj/item/storage/proc/remove_from_storage(obj/item/W, atom/new_location)
	if (!istype(W))
		return

	if (istype(src, /obj/item/storage/fancy)) //todo: why
		var/obj/item/storage/fancy/F = src
		F.update_icon(1)

	W.layer = initial(W.layer)
	W.set_plane(initial(W.plane))

	if (new_location)
		W.loc = new_location
	else
		W.loc = get_turf(src)

	refresh_all()

	if (W.maptext)
		W.maptext = ""

	W.on_exit_storage(src)
	update_icon()

//This proc is called when you want to place an item into the storage item.
/obj/item/storage/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/device/lightreplacer))
		var/obj/item/device/lightreplacer/LP = W
		var/amt_inserted = 0
		var/turf/T = get_turf(user)
		for(var/obj/item/light/L in src.contents)
			if(L.status == 0)
				if(LP.uses < LP.max_uses)
					LP.AddUses(1)
					amt_inserted++
					remove_from_storage(L, T)
					qdel(L)
		if(amt_inserted)
			to_chat(user, "You inserted [amt_inserted] light\s into \the [LP.name]. You have [LP.uses] light\s remaining.")
			return

	if(!can_be_inserted(W))
		return FALSE

	if(istype(W, /obj/item/tray))
		var/obj/item/tray/T = W
		if(T.calc_carry() > 0)
			if(prob(85))
				to_chat(user, SPAN_WARNING("The tray won't fit in [src]."))
				return
			else //todo: proper drop handling
				W.loc = user.loc
				if (user.client)
					user.client.screen -= W
				W.dropped(user)
				to_chat(user, SPAN_WARNING("God damnit!"))

	W.add_fingerprint(user)
	return handle_item_insertion(W)

/obj/item/storage/dropped(mob/user)
	return

/obj/item/storage/attack_hand(mob/user)
	// v Why does that exist? ~Luduk
	/*if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.l_store == src && !H.get_active_hand())	//Prevents opening if it's in a pocket.
			H.put_in_hands(src)
			H.l_store = null
			return
		if(H.r_store == src && !H.get_active_hand())
			H.put_in_hands(src)
			H.r_store = null
			return*/

	if(loc == user)
		open(user)
	else
		close_all()
		..()

	src.add_fingerprint(user)
	return

/obj/item/storage/verb/toggle_gathering_mode()
	set name = "Switch Gathering Method"
	set category = "Object"

	collection_mode = !collection_mode
	switch (collection_mode)
		if(1)
			to_chat(usr, "[src] now picks up all items in a tile at once.")
		if(0)
			to_chat(usr, "[src] now picks up one item at a time.")

/obj/item/storage/proc/collectItems(turf/target, mob/user)
	ASSERT(istype(target))
	. = FALSE
	var/limiter = 15
	for(var/obj/item/I in target)
		if(--limiter < 0)
			break
		if(can_be_inserted(I, TRUE))
			. |= TRUE
			handle_item_insertion(I, TRUE)

	if(user)
		if(.)
			user.visible_message(SPAN_NOTICE("[user] puts some things in [src]."),SPAN_NOTICE("You put some things in [src]."),SPAN_NOTICE("You hear rustling."))
			if (src.use_sound)
				playsound(src.loc, src.use_sound, 50, 1, -5)
		else
			to_chat(user, SPAN_NOTICE("You fail to pick anything up with \the [src]."))


/obj/item/storage/resolve_attackby(atom/A, mob/user)
	if(src.verbs.Find(/obj/item/storage/verb/toggle_gathering_mode))
		if(collection_mode && isturf(A) || istype(A, /obj/item))
			if(collectItems(get_turf(A), user))
				return TRUE
	//Clicking on tile with no collectible items will empty it, if it has the verb to do that.
	if(allow_quick_empty)
		if(isturf(A) && !A.density)
			dump_it(A)
			return TRUE
	return ..()

/obj/item/storage/verb/quick_empty()
	set name = "Empty Contents"
	set category = "Object"
	set src in view(1)

	if((!ishuman(usr) && (src.loc != usr)) || usr.stat || usr.restrained())
		return

	var/turf/T = get_turf(src)
	if(!istype(T))
		return
	dump_it(T, usr)

/obj/item/storage/proc/dump_it(turf/target) //he bought?
	if(!isturf(target))
		return
	if(!Adjacent(usr))
		return
	hide_from(usr)
	for(var/obj/item/I in contents)
		remove_from_storage(I, target)

/obj/item/storage/Initialize(mapload, ...)
	. = ..()
	if(allow_quick_empty)
		verbs += /obj/item/storage/verb/quick_empty
	else
		verbs -= /obj/item/storage/verb/quick_empty

	if(allow_quick_gather)
		verbs += /obj/item/storage/verb/toggle_gathering_mode
	else
		verbs -= /obj/item/storage/verb/toggle_gathering_mode

	if(isnull(max_storage_space) && !isnull(storage_slots))
		max_storage_space = storage_slots*BASE_STORAGE_COST(max_w_class)

	// Deferred storage doesn't populate_contents() from Initialize, it does so when accessed by player
	if(!istype(src, /obj/item/storage/deferred))
		populate_contents()

	var/total_storage_space = 0
	for(var/obj/item/I in contents)
		total_storage_space += I.get_storage_cost()
	max_storage_space = max(total_storage_space, max_storage_space) //prevents spawned containers from being too small for their contents

// Override in subtypes
/obj/item/storage/proc/populate_contents()
	return

/obj/item/storage/emp_act(severity)
	if(!isliving(loc))
		for(var/obj/O in contents)
			O.emp_act(severity)
	..()

/obj/item/storage/attack_self(mob/user)
	if(user.get_active_hand() == src && user.get_inactive_hand() == null)
		if(user.swap_hand())
			open(user)
			return TRUE

/obj/item/storage/proc/make_exact_fit()
	storage_slots = contents.len

	can_hold.Cut()
	max_w_class = 0
	max_storage_space = 0
	for(var/obj/item/I in src)
		can_hold[I.type]++
		max_w_class = max(I.w_class, max_w_class)
		max_storage_space += I.get_storage_cost()

//Variant of the above that makes sure nothing is lost
/obj/item/storage/proc/expand_to_fit()
	//Cache the old values
	var/ospace = max_storage_space
	var/omax = max_w_class
	var/olimitedhold = can_hold.len

	//Make fit
	make_exact_fit()

	//Then restore any values that are smaller than the original
	max_w_class = max(omax, max_w_class)
	max_storage_space = max(ospace, max_storage_space)

	//Remove any specific limits that were placed, if we were originally unlimited
	if (!olimitedhold)
		can_hold.Cut()

//Returns the storage depth of an atom. This is the number of storage items the atom is contained in before reaching toplevel (the area).
//Returns -1 if the atom was not found on container.
/atom/proc/storage_depth(atom/container)
	var/depth = 0
	var/atom/cur_atom = src

	while (cur_atom && !(cur_atom in container.contents))
		if (isarea(cur_atom))
			return -1
		if (istype(cur_atom.loc, /obj/item/storage))
			depth++
		cur_atom = cur_atom.loc

	if (!cur_atom)
		return -1	//inside something with a null loc.

	return depth

//Like storage depth, but returns the depth to the nearest turf
//Returns -1 if no top level turf (a loc was null somewhere, or a non-turf atom's loc was an area somehow).
/atom/proc/storage_depth_turf()
	var/depth = 0
	var/atom/cur_atom = src

	while (cur_atom && !isturf(cur_atom))
		if (isarea(cur_atom))
			return -1
		if (istype(cur_atom.loc, /obj/item/storage))
			depth++
		cur_atom = cur_atom.loc

	if (!cur_atom)
		return -1	//inside something with a null loc.

	return depth

/obj/item/proc/get_storage_cost()
	return BASE_STORAGE_COST(w_class) //If you want to prevent stuff above a certain w_class from being stored, use max_w_class


//Useful for spilling the contents of containers all over the floor
/obj/item/storage/proc/spill(dist = 2, turf/T)
	if (!istype(T))//If its not on the floor this might cause issues
		T = get_turf(src)

	for (var/obj/O in contents)
		remove_from_storage(O, T)
		O.tumble(2)

/obj/item/storage/AllowDrop()
	return TRUE

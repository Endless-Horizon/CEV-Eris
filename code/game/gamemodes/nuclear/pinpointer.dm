/obj/item/weapon/pinpointer
	name = "pinpointer"
	icon = 'icons/obj/device.dmi'
	icon_state = "pinoff"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_SMALL
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	matter = list(MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1)
	//spawn_blacklisted = TRUE//antag_item_targets??
	var/obj/item/weapon/disk/nuclear/the_disk
	var/obj/item/weapon/disk/nuclear/slot
	var/obj/machinery/nuclearbomb/pointbomb
	var/active = FALSE


/obj/item/weapon/pinpointer/attack_self()
	if(!active)
		active = TRUE
		if(!slot)
			workdisk()
		else
			worknuclear()
		to_chat(usr, SPAN_NOTICE("You activate the pinpointer"))
	else
		active = FALSE
		icon_state = "pinoff"
		to_chat(usr, SPAN_NOTICE("You deactivate the pinpointer"))

/obj/item/weapon/pinpointer/attackby(obj/item/I, mob/user, params)
	if (!slot && istype(I, /obj/item/weapon/disk/nuclear))
		usr.drop_item()
		I.loc = src
		src.slot = I
		update_icon()

/obj/item/weapon/pinpointer/MouseDrop(over_object)
	if((src.loc == usr) && istype(over_object, /obj/screen/inventory/hand) && eject_item(slot, usr))
		slot = null
		update_icon()
	else
		..()

/obj/item/weapon/pinpointer/on_update_icon()
	cut_overlays()

	if (slot)
		var/tooloverlay = "disknukeloaded"
		add_overlays((tooloverlay))


/obj/item/weapon/pinpointer/proc/workdisk()
	if(!active) return

	if(slot)
		worknuclear()
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)	//Plays a beep
		return

	if(!the_disk)
		the_disk = locate()
		if(!the_disk)
			icon_state = "pinonnull"
			return
	set_dir(get_dir(src,the_disk))
	switch(get_dist(src,the_disk))
		if(0)
			icon_state = "pinondirect"
		if(1 to 8)
			icon_state = "pinonclose"
		if(9 to 16)
			icon_state = "pinonmedium"
		if(16 to INFINITY)
			icon_state = "pinonfar"
	spawn(5) .()

/obj/item/weapon/pinpointer/proc/worknuclear()
	if(!active) return

	if(!slot)
		workdisk()
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)	//Plays a beep
		return

	for(var/obj/machinery/nuclearbomb/bomb in world)
		pointbomb = bomb
		if(pointbomb.timing)
			break

	set_dir(get_dir(src, pointbomb))
	switch(get_dist(src, pointbomb))
		if(0)
			icon_state = "pinondirect"
		if(1 to 8)
			icon_state = "pinonclose"
		if(9 to 16)
			icon_state = "pinonmedium"
		if(16 to INFINITY)
			icon_state = "pinonfar"
	spawn(5) .()

/obj/item/weapon/pinpointer/examine(mob/user)
	..(user)
	if(slot)
		to_chat(user, "Nuclear disk is loaded inside [src].")
	for(var/obj/machinery/nuclearbomb/bomb in world)
		if(bomb.timing)
			to_chat(user, SPAN_WARNING("Extreme danger.  Arming signal detected.   Time remaining: [bomb.timeleft]"))

/obj/item/weapon/pinpointer/Destroy()
	active = FALSE
	. = ..()

/obj/item/weapon/pinpointer/advpinpointer
	name = "Advanced Pinpointer"
	icon = 'icons/obj/device.dmi'
	desc = "A larger version of the normal pinpointer, this unit features a helpful quantum entanglement detection system to locate various objects that do not broadcast a locator signal."
	var/mode = 0  // Mode 0 locates disk, mode 1 locates coordinates.
	var/turf/location
	var/obj/target

/obj/item/weapon/pinpointer/advpinpointer/attack_self()
	if(!active)
		active = TRUE
		if(mode == 0)
			workdisk()
		if(mode == 1)
			worklocation()
		if(mode == 2)
			workobj()
		to_chat(usr, SPAN_NOTICE("You activate the pinpointer"))
	else
		active = 0
		icon_state = "pinoff"
		to_chat(usr, SPAN_NOTICE("You deactivate the pinpointer"))

/obj/item/weapon/pinpointer/advpinpointer/proc/worklocation()
	if(!active)
		return
	if(!location)
		icon_state = "pinonnull"
		return
	set_dir(get_dir(src,location))
	switch(get_dist(src,location))
		if(0)
			icon_state = "pinondirect"
		if(1 to 8)
			icon_state = "pinonclose"
		if(9 to 16)
			icon_state = "pinonmedium"
		if(16 to INFINITY)
			icon_state = "pinonfar"
	spawn(5) .()


/obj/item/weapon/pinpointer/advpinpointer/proc/workobj()
	if(!active)
		return
	if(!target)
		icon_state = "pinonnull"
		return
	set_dir(get_dir(src,target))
	switch(get_dist(src,target))
		if(0)
			icon_state = "pinondirect"
		if(1 to 8)
			icon_state = "pinonclose"
		if(9 to 16)
			icon_state = "pinonmedium"
		if(16 to INFINITY)
			icon_state = "pinonfar"
	spawn(5) .()

/obj/item/weapon/pinpointer/advpinpointer/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Pinpointer Mode"
	set src in view(1)

	active = FALSE
	icon_state = "pinoff"
	target = null
	location = null

	switch(alert("Please select the mode you want to put the pinpointer in.", "Pinpointer Mode Select", "Location", "Disk Recovery", "Other Signature"))
		if("Location")
			mode = 1

			var/locationx = input(usr, "Please input the x coordinate to search for.", "Location?" , "") as num
			if(!locationx || !(usr in view(1,src)))
				return
			var/locationy = input(usr, "Please input the y coordinate to search for.", "Location?" , "") as num
			if(!locationy || !(usr in view(1,src)))
				return

			var/turf/Z = get_turf(src)

			location = locate(locationx,locationy,Z.z)

			to_chat(usr, "You set the pinpointer to locate [locationx],[locationy]")


			return attack_self()

		if("Disk Recovery")
			mode = 0
			return attack_self()

		if("Other Signature")
			mode = 2
			switch(alert("Search for item signature or DNA fragment?" , "Signature Mode Select" , "" , "Item" , "DNA"))
				if("Item")
					var/datum/objective/steal/itemlist
					itemlist = itemlist // To supress a 'variable defined but not used' error.
					var/targetitem = input("Select item to search for.", "Item Mode Select","") as null|anything in itemlist.possible_items
					if(!targetitem)
						return
					target=locate(itemlist.possible_items[targetitem])
					if(!target)
						to_chat(usr, SPAN_WARNING("Failed to locate [targetitem]!"))
						return
					to_chat(usr, SPAN_NOTICE("You set the pinpointer to locate [targetitem]"))
				if("DNA")
					var/DNAstring = input("Input DNA string to search for." , "Please Enter String." , "")
					if(!DNAstring)
						return
					for(var/mob/living/carbon/M in GLOB.mob_living_list)
						if(!M.dna)
							continue
						if(M.dna.unique_enzymes == DNAstring)
							target = M
							break

			return attack_self()


///////////////////////
//nuke op pinpointers//
///////////////////////


/obj/item/weapon/pinpointer/nukeop
	var/mode = 0	//Mode 0 locates disk, mode 1 locates the shuttle
	var/obj/machinery/computer/shuttle_control/multi/mercenary/home

/obj/item/weapon/pinpointer/nukeop/attack_self(mob/user as mob)
	if(!active)
		active = TRUE
		if(!mode)
			workdisk()
			to_chat(user, SPAN_NOTICE("Authentication Disk Locator active."))
		else
			worklocation()
			to_chat(user, SPAN_NOTICE("Shuttle Locator active."))
	else
		active = 0
		icon_state = "pinoff"
		to_chat(user, SPAN_NOTICE("You deactivate the pinpointer."))


/obj/item/weapon/pinpointer/nukeop/workdisk()
	if(!active) return
	if(mode)		//Check in case the mode changes while operating
		worklocation()
		return
	if(bomb_set)	//If the bomb is set, lead to the shuttle
		mode = 1	//Ensures worklocation() continues to work
		worklocation()
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)	//Plays a beep
		visible_message("Shuttle Locator active.")			//Lets the mob holding it know that the mode has changed
		return		//Get outta here
	if(!the_disk)
		the_disk = locate()
		if(!the_disk)
			icon_state = "pinonnull"
			return
//	if(loc.z != the_disk.z)	//If you are on a different z-level from the disk
//		icon_state = "pinonnull"
//	else
	set_dir(get_dir(src, the_disk))
	switch(get_dist(src, the_disk))
		if(0)
			icon_state = "pinondirect"
		if(1 to 8)
			icon_state = "pinonclose"
		if(9 to 16)
			icon_state = "pinonmedium"
		if(16 to INFINITY)
			icon_state = "pinonfar"

	spawn(5) .()


/obj/item/weapon/pinpointer/nukeop/proc/worklocation()
	if(!active)	return
	if(!mode)
		workdisk()
		return
	if(!bomb_set)
		mode = 0
		workdisk()
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)
		visible_message(SPAN_NOTICE("Authentication Disk Locator active."))
		return
	if(!home)
		home = locate()
		if(!home)
			icon_state = "pinonnull"
			return
	if(loc.z != home.z)	//If you are on a different z-level from the shuttle
		icon_state = "pinonnull"
	else
		set_dir(get_dir(src, home))
		switch(get_dist(src, home))
			if(0)
				icon_state = "pinondirect"
			if(1 to 8)
				icon_state = "pinonclose"
			if(9 to 16)
				icon_state = "pinonmedium"
			if(16 to INFINITY)
				icon_state = "pinonfar"

	spawn(5) .()

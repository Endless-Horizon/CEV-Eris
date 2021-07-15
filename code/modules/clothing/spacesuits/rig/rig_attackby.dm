/obj/item/rig/attackby(obj/item/I, mob/user)

	if(!isliving(user))
		return

	if(electrified != 0)
		if(shock(user)) //Handles removing charge from the cell, as well. No need to do that here.
			return



	// Lock or unlock the access panel.
	if(I.GetIdCard())
		if(subverted)
			locked = 0
			to_chat(user, SPAN_DANGER("It looks like the locking system has been shorted out."))
			return

		if(locked == -1)
			to_chat(user, SPAN_DANGER("The lock clicks uselessly."))
			return

		if((!req_access || !req_access.len) && (!req_one_access || !req_one_access.len))
			locked = 0
			to_chat(user, SPAN_DANGER("\The [src] doesn't seem to have a locking mechanism."))
			return

		if(security_check_enabled && !src.allowed(user))
			to_chat(user, SPAN_DANGER("Access denied."))
			return

		locked = !locked
		to_chat(user, "You [locked ? "lock" : "unlock"] \the [src] access panel.")
		return

	var/list/usable_qualities = list(QUALITY_PRYING, QUALITY_WELDING,QUALITY_WIRE_CUTTING, QUALITY_PULSING, QUALITY_CUTTING, QUALITY_BOLT_TURNING, QUALITY_SCREW_DRIVING)
	var/tool_type = I.get_tool_type(user, usable_qualities, src)
	switch(tool_type)
		if(QUALITY_SCREW_DRIVING)
			if (is_worn())
				to_chat(user, "You can't remove an installed device while the hardsuit is being worn.")
				return 1

			if(open)
				if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					var/list/current_mounts = list()
					if(cell) current_mounts   += "cell"
					if(installed_modules && installed_modules.len) current_mounts += "system module"

					var/to_remove = input("Which would you like to modify?") as null|anything in current_mounts
					if(!to_remove)
						return


					switch(to_remove)
						if("cell")
							if(cell)
								to_chat(user, "You detatch \the [cell] from \the [src]'s battery mount.")
								for(var/obj/item/rig_module/module in installed_modules)
									module.deactivate()
								user.put_in_hands(cell)
								cell = null
							else
								to_chat(user, "There is nothing loaded in that mount.")

						if("system module")
							var/list/possible_removals = list()
							for(var/obj/item/rig_module/module in installed_modules)
								if(module.permanent)
									continue
								possible_removals[module.name] = module

							if(!possible_removals.len)
								to_chat(user, "There are no installed modules to remove.")
								return

							var/removal_choice = input("Which module would you like to remove?") as null|anything in possible_removals
							if(!removal_choice)
								return

							if (can_uninstall(possible_removals[removal_choice], user, TRUE))
								uninstall(possible_removals[removal_choice], user)
							return TRUE
			else
				to_chat(user, "\The [src] access panel is closed.")
				return

		if(QUALITY_WIRE_CUTTING)
			if(open)
				wires.Interact(user)
				return
			else
				to_chat(user, "\The [src] access panel is closed.")
				return

		if(QUALITY_PULSING)
			if(open)
				wires.Interact(user)
				return
			else
				to_chat(user, "\The [src] access panel is closed.")
				return

		if(QUALITY_CUTTING)
			if(open)
				wires.Interact(user)
				return
			else
				to_chat(user, "\The [src] access panel is closed.")
				return

		if(QUALITY_PRYING)
			if(locked != 1)
				if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					open = !open
					to_chat(user, SPAN_NOTICE("You [open ? "open" : "close"] the access panel."))
					return
			else
				to_chat(user, SPAN_DANGER("\The [src] access panel is locked."))
				return

		if(QUALITY_BOLT_TURNING)
			if(open)
				if(!air_supply)
					to_chat(user, "There is not tank to remove.")
					return

				if (is_worn())
					to_chat(user, "You can't remove an installed tank while the hardsuit is being worn.")
					return 1

				if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					user.put_in_hands(air_supply)
					to_chat(user, "You detach and remove \the [air_supply].")
					air_supply = null
					return
			else
				to_chat(user, "\The [src] access panel is closed.")
				return

		if(QUALITY_WELDING)
			//Cutting through the cover lock. This allows access to the wires inside so you can disable access requirements
			//Ridiculously difficult to do, hijacking a rig will take a long time if you don't have good mechanical training
			if(locked == 1)
				to_chat(user, SPAN_NOTICE("You start cutting through the access panel's cover lock. This is a delicate task."))
				if(I.use_tool(user, src, WORKTIME_EXTREMELY_LONG, tool_type, FAILCHANCE_VERY_HARD, required_stat = STAT_MEC))
					locked = -1 //Broken, it can never be locked again
					to_chat(user, SPAN_NOTICE("Success! The tension in the panel loosens with a dull click"))
					playsound(src.loc, 'sound/weapons/guns/interact/pistol_magin.ogg', 75, 1)
				return
			else
				to_chat(user, "\The [src] access panel is not locked, there's no need to cut it.")
				//No return here, incase they're trying to repair

		if(ABORT_CHECK)
			return

	// Pass repair items on to the chestpiece.
	if(chest && (istype(I,/obj/item/stack/material) || (QUALITY_WELDING in I.tool_qualities)))
		return chest.attackby(I,user)

	if(open)
		// Air tank.
		if(istype(I,/obj/item/tank)) //Todo, some kind of check for suits without integrated air supplies.
			if(air_supply)
				to_chat(user, "\The [src] already has a tank installed.")
				return

			if(!user.unEquip(I))
				return
			air_supply = I
			I.forceMove(src)
			to_chat(user, "You slot [I] into [src] and tighten the connecting valve.")
			return

		// Check if this is a hardsuit upgrade or a modification.
		else if(istype(I,/obj/item/rig_module))
			if (can_install(I, user, TRUE))
				install(I, user)
			return TRUE
		else if(!cell && istype(I,/obj/item/cell/large))
			if(!user.unEquip(I))
				return
			to_chat(user, "You jack \the [I] into \the [src]'s battery mount.")
			I.forceMove(src)
			src.cell = I
			return

		return

	// If we've gotten this far, all we have left to do before we pass off to root procs
	// is check if any of the loaded modules want to use the item we've been given.
	for(var/obj/item/rig_module/module in installed_modules)
		if(module.accepts_item(I,user)) //Item is handled in this proc
			return
	..()


/obj/item/rig/attack_hand(var/mob/user)
	if(electrified != 0)
		if(shock(user)) //Handles removing charge from the cell, as well. No need to do that here.
			return

	//If the rig has a storage module, we can attempt to access it
	if (storage && (is_worn() || is_held()))
		//This will return false if we're done, or true to tell us to keep going and call parent attackhand
		if (!storage.handle_attack_hand(user))
			return
	.=..()


//For those pesky items which incur effects on the rigsuit, an altclick will force them to go in if possible
/obj/item/rig/AltClick(var/mob/user)
	if (storage && user.get_active_hand())
		if (user == loc || Adjacent(user)) //Rig must be on or near you
			storage.accepts_item(user.get_active_hand())
			return
	.=..()

//When not wearing a rig, you can drag it onto yourself to access the internal storage
/obj/item/rig/MouseDrop(obj/over_object)
	if (storage && storage.handle_mousedrop(usr, over_object))
		return TRUE
	return ..()

/obj/item/rig/emag_act(var/remaining_charges, var/mob/user)
	if(!subverted)
		req_access.Cut()
		req_one_access.Cut()
		if (locked != -1)
			locked = 0
		subverted = 1
		to_chat(user, SPAN_DANGER("You short out the access protocol for the suit."))
		return 1

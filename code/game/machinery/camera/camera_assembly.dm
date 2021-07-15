/obj/item/camera_assembly
	name = "camera assembly"
	desc = "A pre-fabricated security camera kit, ready to be assembled and mounted to a surface."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "cameracase"
	w_class = ITEM_SIZE_SMALL
	anchored = FALSE

	matter = list(MATERIAL_STEEL = 2, MATERIAL_GLASS = 3)

	//	Motion, EMP-Proof, X-Ray
	var/list/obj/item/possible_upgrades = list(/obj/item/device/assembly/prox_sensor, /obj/item/stack/material/osmium, /obj/item/stock_parts/scanning_module)
	var/list/upgrades = list()
	var/camera_name
	var/camera_network
	var/state = 0
	/*
				0 = Nothing done to it
				1 = Wrenched in place
				2 = Welded in place
				3 = Wires attached to it (you can now attach/dettach upgrades)
				4 = Screwdriver panel closed and is fully built (you cannot attach upgrades)
	*/

/obj/item/camera_assembly/attackby(obj/item/I, mob/living/user)

	var/list/usable_qualities = list()
	if(state == 0 || state == 1)
		usable_qualities.Add(QUALITY_BOLT_TURNING)
	if(state == 1 || state == 2)
		usable_qualities.Add(QUALITY_WELDING)
	if(state == 3)
		usable_qualities.Add(QUALITY_SCREW_DRIVING)
	if(state == 3)
		usable_qualities.Add(QUALITY_WIRE_CUTTING)
	if(upgrades.len)
		usable_qualities.Add(QUALITY_PRYING)

	var/tool_type = I.get_tool_type(user, usable_qualities, src)
	switch(tool_type)

		if(QUALITY_BOLT_TURNING)
			if(state == 0 || state == 1)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					anchored = !anchored
					state = !state
					update_icon()
					auto_turn()
					to_chat(user, SPAN_NOTICE("You [anchored? "wrench" : "unattach"] the assembly."))
					return
			return

		if(QUALITY_WELDING)
			if(state == 1)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You weld the assembly securely into place."))
					state = 2
					return
			if(state == 2)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You unweld the assembly from its place."))
					state = 1
					return
			return

		if(QUALITY_WIRE_CUTTING)
			if(state == 3)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					new/obj/item/stack/cable_coil(get_turf(src), 2)
					to_chat(user, SPAN_NOTICE("You remove the wires from the circuits."))
					state = 2
					return
			return

		if(QUALITY_SCREW_DRIVING)
			if(state == 3)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					var/input = sanitize(input(usr, "Which networks would you like to connect this camera to? Separate networks with a comma. No Spaces!\nFor example: CEV Eris,Security,Secret", "Set Network", camera_network ? camera_network : NETWORK_CEV_ERIS))
					if(!input)
						to_chat(usr, "No input found please hang up and try your call again.")
						return

					var/list/tempnetwork = splittext(input, ",")
					if(tempnetwork.len < 1)
						to_chat(usr, "No network found please hang up and try your call again.")
						return

					var/area/camera_area = get_area(src)
					var/temptag = "[sanitize(camera_area.name)] ([rand(1, 999)])"
					input = sanitizeSafe(input(usr, "How would you like to name the camera?", "Set Camera Name", camera_name ? camera_name : temptag), MAX_NAME_LEN)

					state = 4
					var/obj/machinery/camera/C = new(src.loc)
					src.loc = C
					C.assembly = src

					C.auto_turn()

					C.replace_networks(uniquelist(tempnetwork))

					C.c_tag = input

					for(var/i = 5; i >= 0; i -= 1)
						var/direct = input(user, "Direction?", "Assembling Camera", null) in list("LEAVE IT", "NORTH", "EAST", "SOUTH", "WEST" )
						if(direct != "LEAVE IT")
							C.dir = text2dir(direct)
						if(i != 0)
							var/confirm = alert(user, "Is this what you want? Chances Remaining: [i]", "Confirmation", "Yes", "No")
							if(confirm == "Yes")
								break
					return
			return

		if(QUALITY_PRYING)
			if(upgrades.len)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					var/obj/U = locate(/obj) in upgrades
					if(U)
						to_chat(user, SPAN_NOTICE("You unattach an upgrade from the assembly."))
						playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
						U.loc = get_turf(src)
						upgrades -= U
						return
			return

		if(ABORT_CHECK)
			return

	if(state == 2)
		if(istype(I, /obj/item/stack/cable_coil))
			var/obj/item/stack/cable_coil/C = I
			if(C.use(2))
				to_chat(user, SPAN_NOTICE("You add wires to the assembly."))
				state = 3
			else
				to_chat(user, SPAN_WARNING("You need 2 coils of wire to wire the assembly."))
			return


	// Upgrades!
	if(is_type_in_list(I, possible_upgrades) && !is_type_in_list(I, upgrades)) // Is a possible upgrade and isn't in the camera already.
		to_chat(user, "You attach \the [I] into the assembly inner circuits.")
		upgrades += I
		user.remove_from_mob(I)
		I.loc = src
		return

	..()

/obj/item/camera_assembly/on_update_icon()
	if(anchored)
		icon_state = "camera1"
	else
		icon_state = "cameracase"

/obj/item/camera_assembly/attack_hand(mob/user as mob)
	if(!anchored)
		..()

/obj/structure/door_assembly
	name = "airlock assembly"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_as_0"
	anchored = FALSE
	density = TRUE
	w_class = ITEM_SIZE_HUGE
	var/state = 0
	var/base_icon_state = ""
	var/base_name = "Airlock"
	var/obj/item/electronics/airlock/electronics
	var/airlock_type = "" //the type path of the airlock once completed
	var/glass_type = "/glass"
	var/glass = 0 // 0 = glass can be installed. -1 = glass can't be installed. 1 = glass is already installed. Text = mineral plating is installed instead.
	var/created_name

/obj/structure/door_assembly/Initialize()
	. = ..()
	update_state()

/obj/structure/door_assembly/attackby(obj/item/I, mob/user)

	var/list/usable_qualities = list()
	if(state == 0)
		usable_qualities.Add(QUALITY_BOLT_TURNING)
	if(istext(glass) || glass == 1 || !anchored)
		usable_qualities.Add(QUALITY_WELDING)
	if(state == 2)
		usable_qualities.Add(QUALITY_PRYING, QUALITY_SCREW_DRIVING)
	if(state == 1)
		usable_qualities.Add(QUALITY_WIRE_CUTTING)

	var/tool_type = I.get_tool_type(user, usable_qualities, src)
	switch(tool_type)

		if(QUALITY_BOLT_TURNING)
			if(state == 0)
				if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					if(anchored)
						user.visible_message("[user] begins unsecuring the airlock assembly from the floor.", "You starts unsecuring the airlock assembly from the floor.")
					else
						user.visible_message("[user] begins securing the airlock assembly to the floor.", "You starts securing the airlock assembly to the floor.")
					to_chat(user, SPAN_NOTICE("You [anchored? "un" : ""]secured the airlock assembly!"))
					anchored = !anchored
			update_state()
			return

		if(QUALITY_WELDING)
			if(istext(glass))
				if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You welded the [glass] plating off!"))
					var/M = text2path("/obj/item/stack/material/[glass]")
					new M(src.loc, 2)
					glass = 0
			else if(glass == 1)
				if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You welded the glass panel out!"))
					new /obj/item/stack/material/glass/reinforced(src.loc)
					glass = 0
			else if(!anchored)
				if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You dissasembled the airlock assembly!"))
					new /obj/item/stack/material/steel(src.loc, 8)
					qdel (src)
			update_state()
			return

		if(QUALITY_PRYING)
			if(state == 2)
				if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You removed the airlock electronics!"))
					src.state = 1
					src.name = "Wired Airlock Assembly"
					electronics.loc = src.loc
					electronics = null
			update_state()
			return

		if(QUALITY_WIRE_CUTTING)
			if(state == 1)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You remove the airlock wires!"))
					new/obj/item/stack/cable_coil(src.loc, 1)
					src.state = 0
			update_state()
			return

		if(QUALITY_SCREW_DRIVING)
			if(state == 2)
				if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You finish the airlock!"))
					var/path
					if(istext(glass))
						path = text2path("/obj/machinery/door/airlock/[glass]")
					else if (glass == 1)
						path = text2path("/obj/machinery/door/airlock[glass_type]")
					else
						path = text2path("/obj/machinery/door/airlock[airlock_type]")
					new path(src.loc, src)
					qdel(src)
			update_state()
			return

		if(ABORT_CHECK)
			return

	if(istype(I, /obj/item/stack/cable_coil) && state == 0 && anchored)
		var/obj/item/stack/cable_coil/C = I
		if (C.get_amount() < 1)
			to_chat(user, SPAN_WARNING("You need one length of coil to wire the airlock assembly."))
			return
		user.visible_message("[user] wires the airlock assembly.", "You start to wire the airlock assembly.")
		if(do_after(user, 40,src) && state == 0 && anchored)
			if (C.use(1))
				src.state = 1
				to_chat(user, SPAN_NOTICE("You wire the airlock."))

	else if(istype(I, /obj/item/electronics/airlock) && state == 1)
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		user.visible_message("[user] installs the electronics into the airlock assembly.", "You start to install electronics into the airlock assembly.")

		if(do_after(user, 40,src))
			if(!src) return
			user.drop_item()
			I.loc = src
			to_chat(user, SPAN_NOTICE("You installed the airlock electronics!"))
			src.state = 2
			src.name = "Near finished Airlock Assembly"
			src.electronics = I

	else if(istype(I, /obj/item/stack/material) && !glass)
		var/obj/item/stack/S = I
		var/material_name = S.get_material_name()
		if (S)
			if (S.get_amount() >= 1)
				if(material_name == MATERIAL_RGLASS)
					playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
					user.visible_message("[user] adds [S.name] to the airlock assembly.", "You start to install [S.name] into the airlock assembly.")
					if(do_after(user, 40,src) && !glass)
						if (S.use(1))
							to_chat(user, SPAN_NOTICE("You installed reinforced glass windows into the airlock assembly."))
							glass = 1
				else if(material_name)
					// Ugly hack, will suffice for now. Need to fix it upstream as well, may rewrite mineral walls. ~Z
					if(!(material_name in list(MATERIAL_GOLD, MATERIAL_SILVER, MATERIAL_DIAMOND, MATERIAL_URANIUM, MATERIAL_PLASMA, MATERIAL_SANDSTONE)))
						to_chat(user, "You cannot make an airlock out of that material.")
						return
					if(S.get_amount() >= 2)
						playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
						user.visible_message("[user] adds [S.name] to the airlock assembly.", "You start to install [S.name] into the airlock assembly.")
						if(do_after(user, 40,src) && !glass)
							if (S.use(2))
								to_chat(user, SPAN_NOTICE("You installed [material_display_name(material_name)] plating into the airlock assembly."))
								glass = material_name

	else if(istype(I, /obj/item/pen))
		var/t = sanitizeSafe(input(user, "Enter the name for the door.", src.name, src.created_name), MAX_NAME_LEN)
		if(!t)	return
		if(!in_range(src, usr) && src.loc != usr)	return
		created_name = t
		return

	else
		..()
	update_state()


/obj/structure/door_assembly/proc/update_state()
	icon_state = "door_as_[glass == 1 ? "g" : ""][istext(glass) ? glass : base_icon_state][state]"
	name = ""
	switch (state)
		if(0)
			if (anchored)
				name = "Secured "
		if(1)
			name = "Wired "
		if(2)
			name = "Near Finished "
	name += "[glass == 1 ? "Window " : ""][istext(glass) ? "[glass] Airlock" : base_name] Assembly"


/obj/structure/door_assembly/door_assembly_com
	base_icon_state = "com"
	base_name = "Command Airlock"
	glass_type = "/glass_command"
	airlock_type = "/command"

/obj/structure/door_assembly/door_assembly_sec
	base_icon_state = "sec"
	base_name = "Security Airlock"
	glass_type = "/glass_security"
	airlock_type = "/security"

/obj/structure/door_assembly/door_assembly_eng
	base_icon_state = "eng"
	base_name = "Engineering Airlock"
	glass_type = "/glass_engineering"
	airlock_type = "/engineering"

/obj/structure/door_assembly/door_assembly_min
	base_icon_state = "ming"
	base_name = "Mining Airlock"
	glass_type = "/glass_mining"
	airlock_type = "/mining"

/obj/structure/door_assembly/door_assembly_atmo
	base_icon_state = "atmo"
	base_name = "Atmospherics Airlock"
	glass_type = "/glass_atmos"
	airlock_type = "/atmos"

/obj/structure/door_assembly/door_assembly_research
	base_icon_state = "res"
	base_name = "Research Airlock"
	glass_type = "/glass_research"
	airlock_type = "/research"

/obj/structure/door_assembly/door_assembly_science
	base_icon_state = "sci"
	base_name = "Science Airlock"
	glass_type = "/glass_science"
	airlock_type = "/science"

/obj/structure/door_assembly/door_assembly_med
	base_icon_state = "med"
	base_name = "Medical Airlock"
	glass_type = "/glass_medical"
	airlock_type = "/medical"

/obj/structure/door_assembly/door_assembly_mai
	base_icon_state = "mai"
	base_name = "Maintenance Airlock"
	airlock_type = "/maintenance"
	glass = -1

/obj/structure/door_assembly/door_assembly_maint_cargo
	base_icon_state = "maimin"
	base_name = "Maintenance Hatch"
	airlock_type = "/maintenance_cargo"
	glass = -1

/obj/structure/door_assembly/door_assembly_maint_command
	base_icon_state = "maicom"
	base_name = "Maintenance Hatch"
	airlock_type = "/maintenance_command"
	glass = -1

/obj/structure/door_assembly/door_assembly_maint_engi
	base_icon_state = "maieng"
	base_name = "Maintenance Hatch"
	airlock_type = "/maintenance_engineering"
	glass = -1

/obj/structure/door_assembly/door_assembly_maint_med
	base_icon_state = "maimed"
	base_name = "Maintenance Hatch"
	airlock_type = "/maintenance_medical"
	glass = -1

/obj/structure/door_assembly/door_assembly_maint_rnd
	base_icon_state = "maires"
	base_name = "Maintenance Hatch"
	airlock_type = "/maintenance_rnd"
	glass = -1

/obj/structure/door_assembly/door_assembly_maint_sec
	base_icon_state = "maisec"
	base_name = "Maintenance Hatch"
	airlock_type = "/maintenance_security"
	glass = -1

/obj/structure/door_assembly/door_assembly_maint_common
	base_icon_state = "maicon"
	base_name = "Maintenance Hatch"
	airlock_type = "/maintenance_common"
	glass = -1

/obj/structure/door_assembly/door_assembly_maint_int
	base_icon_state = "maiint"
	base_name = "Maintenance Hatch"
	airlock_type = "/maintenance_interior"
	glass = -1

/obj/structure/door_assembly/door_assembly_ext
	base_icon_state = "ext"
	base_name = "External Airlock"
	airlock_type = "/external"
	glass = -1

/obj/structure/door_assembly/door_assembly_fre
	base_icon_state = "fre"
	base_name = "Freezer Airlock"
	airlock_type = "/freezer"
	glass = -1

/obj/structure/door_assembly/door_assembly_hatch
	base_icon_state = "hatch"
	base_name = "Airtight Hatch"
	airlock_type = "/hatch"
	glass = -1

/obj/structure/door_assembly/door_assembly_mhatch
	base_icon_state = "mhatch"
	base_name = "Maintenance Hatch"
	airlock_type = "/maintenance_hatch"
	glass = -1

/obj/structure/door_assembly/door_assembly_highsecurity // Borrowing this until WJohnston makes sprites for the assembly
	base_icon_state = "highsec"
	base_name = "High Security Airlock"
	airlock_type = "/highsecurity"
	glass = -1

/obj/structure/door_assembly/multi_tile
	icon = 'icons/obj/doors/door_assembly2x1.dmi'
	dir = EAST
	var/width = 1
	base_icon_state = "g" //Remember to delete this line when reverting MATERIAL_GLASS var to 1.
	airlock_type = "/multi_tile/glass"
	glass = -1 //To prevent bugs in deconstruction process.

/obj/structure/door_assembly/multi_tile/Initialize()
	. = ..()
	update_dir()

/obj/structure/door_assembly/multi_tile/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, var/glide_size_override = 0)
	. = ..()
	update_dir()

/obj/structure/door_assembly/multi_tile/proc/update_dir()
	if(dir in list(EAST, WEST))
		bound_width = width * world.icon_size
		bound_height = world.icon_size
	else
		bound_width = world.icon_size
		bound_height = width * world.icon_size

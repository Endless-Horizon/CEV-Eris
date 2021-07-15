/* Windoor (window door) assembly -Nodrak
 * Step 1: Create a windoor out of rglass
 * Step 2: Add r-glass to the assembly to make a secure windoor (Optional)
 * Step 3: Rotate or Flip the assembly to face and open the way you want
 * Step 4: Wrench the assembly in place
 * Step 5: Add cables to the assembly
 * Step 6: Set access for the door.
 * Step 7: Crowbar the door to complete
 */


obj/structure/windoor_assembly
	name = "windoor assembly"
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "l_windoor_assembly0"
	anchored = FALSE
	density = FALSE
	dir = NORTH
	w_class = ITEM_SIZE_NORMAL

	var/obj/item/electronics/airlock/electronics = null

	//Vars to help with the icon's name
	var/facing = "l"	//Does the windoor open to the left or right?
	var/secure = ""		//Whether or not this creates a secure windoor
	var/state = 0		//How far the door assembly has progressed in terms of sprites

obj/structure/windoor_assembly/New(Loc, start_dir=NORTH, constructed=0)
	..()
	if(constructed)
		state = 0
		anchored = FALSE
	switch(start_dir)
		if(NORTH, SOUTH, EAST, WEST)
			set_dir(start_dir)
		else //If the user is facing northeast. northwest, southeast, southwest or north, default to north
			set_dir(NORTH)

	update_nearby_tiles(need_rebuild=1)

obj/structure/windoor_assembly/Destroy()
	density = FALSE
	update_nearby_tiles()
	. = ..()

/obj/structure/windoor_assembly/on_update_icon()
	icon_state = "[facing]_[secure]windoor_assembly[state]"

/obj/structure/windoor_assembly/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		if(air_group) return 0
		return !density
	else
		return 1

/obj/structure/windoor_assembly/CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1


/obj/structure/windoor_assembly/attackby(obj/item/I, mob/user)
	//I really should have spread this out across more states but thin little windoors are hard to sprite.

	var/list/usable_qualities = list()
	if((state == 0 && !anchored) || (state == 0 && anchored))
		usable_qualities.Add(QUALITY_BOLT_TURNING)
	if(state == 0 && !anchored)
		usable_qualities.Add(QUALITY_WELDING)
	if(state == 1 && electronics)
		usable_qualities.Add(QUALITY_PRYING, QUALITY_SCREW_DRIVING)
	if(state == 1 && !electronics)
		usable_qualities.Add(QUALITY_WIRE_CUTTING)

	var/tool_type = I.get_tool_type(user, usable_qualities, src)
	switch(tool_type)

		if(QUALITY_BOLT_TURNING)
			if(state == 0 && !anchored)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You've secured the windoor assembly!"))
					src.anchored = TRUE
					if(src.secure)
						src.name = "Secure Anchored Windoor Assembly"
					else
						src.name = "Anchored Windoor Assembly"
					return
			if(state == 0 && anchored)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You've unsecured the windoor assembly!"))
					anchored = FALSE
					if(src.secure)
						src.name = "Secure Windoor Assembly"
					else
						src.name = "Windoor Assembly"
					return
			return

		if(QUALITY_WELDING)
			if(state == 0 && !anchored)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You dissasembled the windoor assembly!"))
					new /obj/item/stack/material/glass/reinforced(get_turf(src), 5)
					if(secure)
						new /obj/item/stack/rods(get_turf(src), 4)
					qdel(src)
					return
			return

		if(QUALITY_PRYING)
			if(state == 1 && electronics)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					usr << browse(null, "window=windoor_access")
					density = TRUE //Shouldn't matter but just incase
					to_chat(user, SPAN_NOTICE("You finish the windoor!"))

					if(secure)
						var/obj/machinery/door/window/brigdoor/windoor = new /obj/machinery/door/window/brigdoor(src.loc)
						if(src.facing == "l")
							windoor.icon_state = "leftsecureopen"
							windoor.base_state = "leftsecure"
						else
							windoor.icon_state = "rightsecureopen"
							windoor.base_state = "rightsecure"
						windoor.set_dir(src.dir)
						windoor.density = FALSE

						if(src.electronics.one_access)
							windoor.req_access = null
							windoor.req_one_access = src.electronics.conf_access
						else
							windoor.req_access = src.electronics.conf_access
						windoor.electronics = src.electronics
						src.electronics.loc = windoor
					else
						var/obj/machinery/door/window/windoor = new /obj/machinery/door/window(src.loc)
						if(src.facing == "l")
							windoor.icon_state = "leftopen"
							windoor.base_state = "left"
						else
							windoor.icon_state = "rightopen"
							windoor.base_state = "right"
						windoor.set_dir(src.dir)
						windoor.density = FALSE

						if(src.electronics.one_access)
							windoor.req_access = null
							windoor.req_one_access = src.electronics.conf_access
						else
							windoor.req_access = src.electronics.conf_access
						windoor.electronics = src.electronics
						src.electronics.loc = windoor

					qdel(src)
					return
			return

		if(QUALITY_WIRE_CUTTING)
			if(state == 1 && !electronics)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You remove the windoor wires.!"))
					new/obj/item/stack/cable_coil(get_turf(user), 1)
					src.state = 0
					if(src.secure)
						src.name = "Secure Anchored Windoor Assembly"
					else
						src.name = "Anchored Windoor Assembly"
					return
			return

		if(QUALITY_SCREW_DRIVING)
			if(state == 1 && electronics)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You've removed the airlock electronics!"))
					if(src.secure)
						src.name = "Secure Wired Windoor Assembly"
					else
						src.name = "Wired Windoor Assembly"
					var/obj/item/electronics/airlock/ae = electronics
					electronics = null
					ae.loc = src.loc
					return
			return

		if(ABORT_CHECK)
			return

	switch(state)
		if(0)
			//Adding rods makes the assembly a secure windoor assembly. Step 2 (optional) complete.
			if(istype(I, /obj/item/stack/rods) && !secure)
				var/obj/item/stack/rods/R = I
				if(R.get_amount() < 4)
					to_chat(user, SPAN_WARNING("You need more rods to do this."))
					return
				to_chat(user, SPAN_NOTICE("You start to reinforce the windoor with rods."))

				if(do_after(user,40,src) && !secure)
					if (R.use(4))
						to_chat(user, SPAN_NOTICE("You reinforce the windoor."))
						src.secure = "secure_"
						if(src.anchored)
							src.name = "Secure Anchored Windoor Assembly"
						else
							src.name = "Secure Windoor Assembly"

			//Adding cable to the assembly. Step 5 complete.
			else if(istype(I, /obj/item/stack/cable_coil) && anchored)
				user.visible_message("[user] wires the windoor assembly.", "You start to wire the windoor assembly.")

				var/obj/item/stack/cable_coil/CC = I
				if(do_after(user, 40,src))
					if (CC.use(1))
						to_chat(user, SPAN_NOTICE("You wire the windoor!"))
						src.state = 1
						if(src.secure)
							src.name = "Secure Wired Windoor Assembly"
						else
							src.name = "Wired Windoor Assembly"
			else
				..()

		if(1)

			//Adding airlock electronics for access. Step 6 complete.
			if(istype(I, /obj/item/electronics/airlock) && I:icon_state != "door_electronics_smoked")
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
				user.visible_message("[user] installs the electronics into the airlock assembly.", "You start to install electronics into the airlock assembly.")

				if(do_after(user, 40,src))
					if(!src) return

					user.drop_item()
					I.loc = src
					to_chat(user, SPAN_NOTICE("You've installed the airlock electronics!"))
					src.name = "Near finished Windoor Assembly"
					src.electronics = I
				else
					I.loc = src.loc

			else
				..()

	//Update to reflect changes(if applicable)
	update_icon()


//Rotates the windoor assembly clockwise
/obj/structure/windoor_assembly/verb/revrotate()
	set name = "Rotate Windoor Assembly"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		to_chat(usr, "It is fastened to the floor; therefore, you can't rotate it!")
		return 0
	if(src.state != 0)
		update_nearby_tiles(need_rebuild=1) //Compel updates before

	src.set_dir(turn(src.dir, 270))

	if(src.state != 0)
		update_nearby_tiles(need_rebuild=1)

	update_icon()
	return

//Flips the windoor assembly, determines whather the door opens to the left or the right
/obj/structure/windoor_assembly/verb/flip()
	set name = "Flip Windoor Assembly"
	set category = "Object"
	set src in oview(1)

	if(src.facing == "l")
		to_chat(usr, "The windoor will now slide to the right.")
		src.facing = "r"
	else
		src.facing = "l"
		to_chat(usr, "The windoor will now slide to the left.")

	update_icon()
	return

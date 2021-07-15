#define STATE_NONE 		1
#define STATE_WIRES 	2
#define STATE_CIRCUIT 	3

//Circuit boards are in /code/game/objects/items/weapons/circuitboards/machinery/
/obj/machinery/constructable_frame
	icon = 'icons/obj/stock_parts.dmi'
	use_power = NO_POWER_USE
	density = TRUE
	anchored = TRUE
	spawn_frequency = 10 //as /obj/structure/computerframe
	rarity_value = 10
	spawn_tags = SPAWN_TAG_MACHINE_FRAME
	bad_type = /obj/machinery/constructable_frame

/obj/machinery/constructable_frame/machine_frame //Made into a seperate type to make future revisions easier.
	name = "machine frame"
	icon_state = "box_0"
	matter = list(MATERIAL_STEEL = 8)
	frame_type = FRAME_DEFAULT
	var/base_state = "box"			//base icon for creating subtypes of machine frame
	var/list/components
	var/list/req_components
	var/list/req_component_names
	var/state = STATE_NONE

/obj/machinery/constructable_frame/machine_frame/examine(mob/user)
	. = ..()

	if(state == STATE_NONE)
		to_chat(user, "The beginning of a machine. Add wires, a circuit board, and any extra required parts.")
	else if(state == STATE_WIRES)
		to_chat(user, "A wired machine frame. Now it needs a circuit board that will decide what kind of machine it becomes.")
	else if(state == STATE_CIRCUIT)
		to_chat(user, "A machine frame with \a [circuit] in it.")

		var/list/component_list = list()
		if(req_components)
			for(var/I in req_components)
				var/amt = req_components[I]
				if(amt <= 0)
					continue
				component_list += "[amt] [amt == 1 ? req_component_names[I] : "[req_component_names[I]]\s"]"

		if(length(component_list))
			to_chat(user, "Requires [english_list(component_list)].")
		else
			to_chat(user, "It's almost complete! Now just use a screwdriver to apply the finishing touch.")


/obj/machinery/constructable_frame/machine_frame/attackby(obj/item/I, mob/user)

	var/list/usable_qualities = list()
	if(state == STATE_CIRCUIT)
		usable_qualities.Add(QUALITY_SCREW_DRIVING)
	if(state == STATE_WIRES)
		usable_qualities.Add(QUALITY_WIRE_CUTTING)
	if(state == STATE_CIRCUIT)
		usable_qualities.Add(QUALITY_PRYING)
	if(state == STATE_NONE)
		usable_qualities.Add(QUALITY_BOLT_TURNING)


	var/tool_type = I.get_tool_type(user, usable_qualities, src)
	switch(tool_type)

		if(QUALITY_SCREW_DRIVING)
			if(state == STATE_CIRCUIT)

				if(component_check())
					if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_VERY_EASY))
						var/obj/machinery/new_machine = new src.circuit.build_path(src.loc, src.dir)
						qdel(new_machine.circuit)
						new_machine.circuit = circuit

						if(new_machine.component_parts)
							new_machine.component_parts.Cut()
						else
							new_machine.component_parts = list()

						src.circuit.construct(new_machine)

						new_machine.component_parts += circuit
						circuit.loc = null

						for(var/obj/O in src)
							new_machine.component_parts += O
							O.loc = null

						new_machine.RefreshParts()
						qdel(src)
						return
				return

		if(QUALITY_WIRE_CUTTING)
			if(state == STATE_WIRES)
				if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You remove the cables."))
					state = STATE_NONE
					icon_state = "[base_state]_0"
					new /obj/item/stack/cable_coil(drop_location(), 5)
					return
			return

		if(QUALITY_PRYING)
			if(state == STATE_CIRCUIT)
				if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					state = STATE_WIRES
					circuit.forceMove(drop_location())
					circuit = null
					if(components.len == 0)
						to_chat(user, SPAN_NOTICE("You remove the circuit board."))
					else
						to_chat(user, SPAN_NOTICE("You remove the circuit board and other components."))
						for(var/obj/component in components)
							component.forceMove(drop_location())
					desc = initial(desc)
					req_components = null
					components = null
					icon_state = "[base_state]_1"
					return
			return

		if(QUALITY_BOLT_TURNING)
			if(state == STATE_NONE)
				if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You dismantle the frame"))
					drop_materials(drop_location())
					qdel(src)
					return
				return

		if(ABORT_CHECK)
			return

	switch(state)
		if(STATE_NONE)
			if(istype(I, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = I
				if (C.get_amount() < 5)
					to_chat(user, SPAN_WARNING("You need five lengths of cable to add them to the frame."))
					return
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
				to_chat(user, SPAN_NOTICE("You start to add cables to the frame."))
				if(do_after(user, 20, src) && state == STATE_NONE)
					if(C.use(5))
						to_chat(user, SPAN_NOTICE("You add cables to the frame."))
						state = STATE_WIRES
						icon_state = "[base_state]_1"

		if(STATE_WIRES)
			if(istype(I, /obj/item/electronics/circuitboard))
				var/obj/item/electronics/circuitboard/B = I
				if(B.board_type == "machine" && frame_type == B.frame_type)
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					to_chat(user, SPAN_NOTICE("You add the circuit board to the frame."))
					circuit = I
					user.drop_from_inventory(I)
					I.forceMove(src)
					icon_state = "[base_state]_2"
					state = STATE_CIRCUIT
					components = list()
					req_components = circuit.req_components.Copy()

					var/static/list/special_component_names = list(
						/obj/item/cell/large = "L-class power cell",
						/obj/item/cell/medium = "M-class power cell",
						/obj/item/cell/small = "S-class power cell",
						)

					req_component_names = list()
					for(var/A in req_components)
						if(special_component_names[A])
							req_component_names[A] = special_component_names[A]
						else if(ispath(A, /obj/item/stack))
							var/obj/item/stack/ct = A
							req_component_names[A] = initial(ct.singular_name)

						// Still no name? Basic handling it is.
						if(!req_component_names[A])
							var/obj/ct = A
							req_component_names[A] = initial(ct.name)
					examine(user)
				else
					to_chat(user, SPAN_WARNING("This frame does not accept circuit boards of this type!"))

		if(STATE_CIRCUIT)

			if(istype(I, /obj/item))
				for(var/CM in req_components)
					if(istype(I, CM) && (req_components[CM] > 0))
						playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)

						// Stacks get special treatment
						if(istype(I, /obj/item/stack))
							var/obj/item/stack/CP = I

							// amount of stack to take, idealy amount required,
							// but limited by amount provided
							var/amount = min(CP.get_amount(), req_components[CM])

							if(amount > 0 && CP.use(amount))
								var/obj/item/stack/CC = new I.type(src, amount)
								components += CC
								req_components[CM] -= amount
							break
						if(user.drop_from_inventory(I))
							I.forceMove(src)
							components += I
							req_components[CM]--
							break
				if(I && I.loc != src && !istype(I, /obj/item/stack))
					to_chat(user, SPAN_WARNING("You cannot add that component to the machine!"))
				else
					examine(user)
	update_icon()

/obj/machinery/constructable_frame/machine_frame/proc/component_check()
	var/ready = TRUE
	for(var/R in req_components)
		if(req_components[R] > 0)
			ready = FALSE
			break
	return ready

/obj/machinery/constructable_frame/machine_frame/vertical
	name = "vertical machine frame"
	icon_state = "v2box_0"
	base_state = "v2box"
	frame_type = FRAME_VERTICAL
	bad_type = /obj/machinery/constructable_frame/machine_frame/vertical

/obj/machinery/constructable_frame/machine_frame/vertical/New()
	..()
	update_icon()

/obj/machinery/constructable_frame/machine_frame/vertical/on_update_icon()
	cut_overlays()

	var/image/I = image(icon, "[icon_state]1")
	I.layer = WALL_OBJ_LAYER
	I.pixel_z = 32
	add_overlays(I)


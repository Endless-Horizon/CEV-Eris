/obj/machinery/recharger
	name = "recharger"
	desc = "A charging dock for power cells, power tools, computer devices and energy based weaponry."
	icon = 'icons/obj/machines/recharger.dmi'
	icon_state = "recharger"
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 4
	circuit = /obj/item/electronics/circuitboard/recharger
	var/max_power_usage = 40000	//40 kW. This is the highest power the charger can draw and use,
	//though it may draw less when charging weak cells due to their charging rate limits
	active_power_usage = 40000//The actual power the charger uses right now. This is recalculated based on the cell when it's inserted
	var/efficiency = 0.90
	var/obj/item/charging = null
	var/list/allowed_devices = list(
		/obj/item/cell,
		/obj/item/tool, /obj/item/device/scanner,
		/obj/item/gun/energy, /obj/item/melee/baton, /obj/item/modular_computer,
	)
	var/portable = TRUE

/obj/machinery/recharger/examine(user)
	..()
	var/obj/item/cell/cell = charging?.get_cell()
	if(cell)
		to_chat(user, "The charge meter reads [round(cell.percent())]%.")

/obj/machinery/recharger/attackby(obj/item/I, mob/user)
	if(default_deconstruction(I, user))
		return

	if(default_part_replacement(I, user))
		return

	if(portable && I.has_quality(QUALITY_BOLT_TURNING))
		if(charging)
			to_chat(user, SPAN_WARNING("Remove [charging] first!"))
			return
		anchored = !anchored
		to_chat(user, "You [anchored ? "attached" : "detached"] [src].")
		playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
		return

	else if (istype(I, /obj/item/gripper))//Code for allowing cyborgs to use rechargers
		var/obj/item/gripper/Gri = I
		if (charging)//If there's something in the charger
			if (Gri.grip_item(charging, user))//we attempt to grab it
				charging = null
				update_icon()
			else
				to_chat(user, "<span class='danger'>Your gripper cannot hold \the [charging].</span>")

	if(!anchored)
		to_chat(user, SPAN_WARNING("Attach [src] first!"))
		return

	if(!user.canUnEquip(I))
		return

	if(is_type_in_list(I, allowed_devices))
		if(charging)
			to_chat(user, SPAN_WARNING("\A [charging] is already charging here."))
			return
		// Checks to make sure he's not in space doing it, and that the area got proper power.
		if(!powered())
			to_chat(user, SPAN_WARNING("[src] blinks red as you try to insert the item!"))
			return

		if (istype(I, /obj/item/gun/energy))
			var/obj/item/gun/energy/W = I
			if (W.disposable)
				to_chat(user, SPAN_NOTICE("Your gun is disposable, it cannot be charged."))
				return
		if(istype(I, /obj/item/gun/energy/nuclear) || istype(I, /obj/item/gun/energy/crossbow))
			to_chat(user, SPAN_NOTICE("Your gun's recharge port was removed to make room for a miniaturized reactor."))
			return
		var/obj/item/cell/cell = I.get_cell()

		if(!cell && istool(I))
			var/obj/item/tool/T = I

			if(!T.suitable_cell)
				return

			to_chat(user, SPAN_WARNING("This tool does not have a battery installed."))
			return

		if(!cell)
			to_chat(user, SPAN_WARNING("This device does not have a battery installed."))
			return //We don't want to go any farther if we failed to find a cell

		active_power_usage = min(max_power_usage, (cell.maxcharge*cell.max_chargerate)/CELLRATE)
		//If trying to charge a really small cell, we won't waste more power than it can intake

		user.unEquip(I, src)
		charging = I
		update_icon()




/obj/machinery/recharger/attack_hand(mob/user)
	if(issilicon(user))
		return

	add_fingerprint(user)

	if(charging)
		charging.update_icon()
		user.put_in_hands(charging)
		charging = null
		update_icon()

/obj/machinery/recharger/Process()
	if((stat & (NOPOWER|BROKEN)) || !anchored)
		update_icon()
		return

	var/obj/item/cell/cell = charging?.get_cell()

	if(cell && !cell.fully_charged())
		cell.give((active_power_usage*CELLRATE)*efficiency)
		update_use_power(ACTIVE_POWER_USE)
	else
		update_use_power(IDLE_POWER_USE)
	update_icon()

/obj/machinery/recharger/emp_act(severity)
	if(stat & (NOPOWER|BROKEN) || !anchored)
		..(severity)
		return

	var/obj/item/cell/cell = charging?.get_cell()
	if(cell)
		cell.emp_act(severity)

	..(severity)

/obj/machinery/recharger/handle_atom_del(atom/A)
	..()
	if(A == charging)
		charging = null
		update_icon()

/obj/machinery/recharger/on_update_icon()
	icon_state = initial(icon_state)

	if(panel_open)
		icon_state = "[icon_state]_open"

	else if((stat & (NOPOWER|BROKEN)) || !anchored)
		icon_state = "[icon_state]_off"
	else
		var/obj/item/cell/cell = charging?.get_cell()

		if(cell)
			if(cell.fully_charged())
				icon_state = "[icon_state]_done"
			else
				icon_state = "[icon_state]_work"
		else if(charging)
			icon_state = "[icon_state]_done"

/obj/machinery/recharger/RefreshParts()
	..()
	var/rating = 1
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		rating += C.rating - 1

	max_power_usage = initial(max_power_usage) * rating
	efficiency = min(initial(efficiency) + (0.05 * (rating - 1)), 0.99)



/obj/machinery/recharger/wallcharger
	name = "wall recharger"
	desc = "A wall-mounted weapon charging dock."
	icon_state = "wrecharger"
	allowed_devices = list(/obj/item/gun/energy, /obj/item/melee/baton)
	portable = FALSE
	circuit = null

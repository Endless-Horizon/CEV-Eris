obj/machinery/recharger
	name = "recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger0"
	anchored = 1
	use_power = 1
	idle_power_usage = 4
	var/max_power_usage = 24000	//22 kW. This is the highest power the charger can draw and use,
	//though it may draw less when charging weak cells due to their charging rate limits
	active_power_usage = 24000//The actual power the charger uses right now. This is recalculated based on the cell when it's inserted
	var/efficiency = 0.85
	var/obj/item/charging = null
	var/obj/item/weapon/cell/cell = null
	var/list/allowed_devices = list(
		/obj/item/weapon/gun/energy, /obj/item/weapon/melee/baton, /obj/item/laptop,
		/obj/item/weapon/cell, /obj/item/modular_computer
	)
	var/icon_state_charged = "recharger2"
	var/icon_state_charging = "recharger1"
	var/icon_state_idle = "recharger0" //also when unpowered
	var/portable = 1

obj/machinery/recharger/attackby(obj/item/weapon/G as obj, mob/user as mob)
	if(issilicon(user))
		return

	var/allowed = 0
	for (var/allowed_type in allowed_devices)
		if (istype(G, allowed_type))
			allowed = 1
			break

	if(allowed)
		if(charging)
			user << SPAN_WARNING("\A [charging] is already charging here.")
			return
		// Checks to make sure he's not in space doing it, and that the area got proper power.
		if(!powered())
			user << SPAN_WARNING("The [name] blinks red as you try to insert the item!")
			return

		if(istype(G, /obj/item/weapon/gun/energy/gun/nuclear) || istype(G, /obj/item/weapon/gun/energy/crossbow))
			user << SPAN_NOTICE("Your gun's recharge port was removed to make room for a miniaturized reactor.")
			return

		if(istype(G, /obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B = G
			cell = B.cell
		else if(istype(G, /obj/item/weapon/gun/energy))
			var/obj/item/weapon/gun/energy/E = G
			cell = E.cell
		else if(istype(G, /obj/item/weapon/cell))
			cell = G
		else if(istype(G, /obj/item/laptop))
			var/obj/item/laptop/L = G
			if(!L.stored_computer.cpu.battery_module)
				user << "There's no battery in it!"
				return
			else
				cell = L.stored_computer.cpu.battery_module.battery
		if(istype(G, /obj/item/modular_computer))
			var/obj/item/modular_computer/C = G
			if(!C.battery_module)
				user << "This device does not have a battery installed."
				return
			else
				src.cell = C.battery_module.battery

		if (!cell)
			return //We don't want to go any farther if we failed to find a cell
		else
			active_power_usage = min(max_power_usage, (cell.maxcharge*cell.max_chargerate)/CELLRATE)
			//If trying to charge a really small cell, we won't waste more power than it can intake


		user.unEquip(G)
		G.forceMove(src)
		charging = G
		update_icon()

	else if(portable && istype(G, /obj/item/weapon/tool/wrench))
		if(charging)
			user << SPAN_WARNING("Remove [charging] first!")
			return
		anchored = !anchored
		user << "You [anchored ? "attached" : "detached"] the recharger."
		playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)

obj/machinery/recharger/attack_hand(mob/user as mob)
	if(issilicon(user))
		return

	add_fingerprint(user)

	if(charging)
		charging.update_icon()
		user.put_in_hands(charging)
		charging = null
		update_icon()

obj/machinery/recharger/Process()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		update_use_power(0)
		icon_state = icon_state_idle
		return

	if(!charging)
		update_use_power(1)
		icon_state = icon_state_idle
	else
		if(cell)
			if(!cell.fully_charged())
				icon_state = icon_state_charging
				cell.give((active_power_usage*CELLRATE)*efficiency)
				update_use_power(2)
			else
				icon_state = icon_state_charged
				update_use_power(1)
		else
			icon_state = icon_state_idle
			update_use_power(1)

obj/machinery/recharger/emp_act(severity)
	if(stat & (NOPOWER|BROKEN) || !anchored)
		..(severity)
		return

	if(istype(charging,  /obj/item/weapon/gun/energy))
		var/obj/item/weapon/gun/energy/E = charging
		if(E.cell)
			E.cell.emp_act(severity)

	else if(istype(charging, /obj/item/weapon/melee/baton))
		var/obj/item/weapon/melee/baton/B = charging
		if(B.cell)
			B.cell.charge = 0
	..(severity)

obj/machinery/recharger/update_icon()	//we have an update_icon() in addition to the stuff in process to make it feel a tiny bit snappier.
	if(charging)
		icon_state = icon_state_charging
	else
		icon_state = icon_state_idle


obj/machinery/recharger/wallcharger
	name = "wall recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "wrecharger0"
	active_power_usage = 32000	//40 kW , It's more specialized than the standalone recharger (guns and batons only) so make it more powerful
	allowed_devices = list(/obj/item/weapon/gun/energy, /obj/item/weapon/melee/baton)
	icon_state_charged = "wrecharger2"
	icon_state_charging = "wrecharger1"
	icon_state_idle = "wrecharger0"
	portable = 0

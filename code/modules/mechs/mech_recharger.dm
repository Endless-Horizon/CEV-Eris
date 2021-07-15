/obj/machinery/mech_recharger
	name = "mech recharger"
	desc = "A mech recharger, built into the floor."
	icon = 'icons/mechs/mech_bay.dmi'
	icon_state = "recharge_floor"
	anchored = TRUE
	density = FALSE
	layer = TURF_LAYER + 0.1

	use_power = IDLE_POWER_USE
	idle_power_usage = 4
	circuit = /obj/item/electronics/circuitboard/mech_recharger

	var/mob/living/exosuit/charging = null

	var/max_power_usage = 40000	//40 kW. This is the highest power the charger can draw and use,
	//though it may draw less when charging weak cells due to their charging rate limits
	active_power_usage = 40000//The actual power the charger uses right now. This is recalculated based on the cell when it's inserted
	var/efficiency = 0.90

	var/repair = 0

/obj/machinery/mech_recharger/Crossed(var/mob/living/exosuit/M)
	. = ..()
	if(istype(M) && charging != M)
		start_charging(M)

/obj/machinery/mech_recharger/Uncrossed(var/mob/living/exosuit/M)
	. = ..()
	if(M == charging)
		stop_charging()

/obj/machinery/mech_recharger/RefreshParts()
	..()
	var/cap_rating = 1
	repair = -5
	for(var/obj/item/stock_parts/P in component_parts)
		if(istype(P, /obj/item/stock_parts/capacitor))
			cap_rating += P.rating - 1
		if(istype(P, /obj/item/stock_parts/scanning_module))
			repair += P.rating
		if(istype(P, /obj/item/stock_parts/manipulator))
			repair += P.rating * 2

	max_power_usage = initial(max_power_usage) * cap_rating
	efficiency = min(initial(efficiency) + (0.03 * (cap_rating - 1)), 0.99)

/obj/machinery/mech_recharger/Process()
	..()
	if(!charging)
		return
	if(charging.loc != loc) // Could be qdel or teleport or something
		stop_charging()
		return
	var/done = TRUE

	var/obj/item/cell/cell = charging.get_cell()
	if(cell && !cell.fully_charged())
		active_power_usage = min(max_power_usage, (cell.maxcharge*cell.max_chargerate)/CELLRATE)

		cell.give(active_power_usage*CELLRATE*efficiency)
		update_use_power(ACTIVE_POWER_USE)

		if(cell.fully_charged())
			charging.occupant_message(SPAN_NOTICE("Fully charged."))
		else
			done = FALSE
	else
		update_use_power(IDLE_POWER_USE)

	if(repair && charging.health < initial(charging.health))
		charging.health = min(charging.health + repair, initial(charging.health))
		if(charging.health == initial(charging.health))
			charging.occupant_message(SPAN_NOTICE("Fully repaired."))

		else
			done = FALSE
	if(done)
		stop_charging()
	return

/obj/machinery/mech_recharger/attackby(var/obj/item/I, var/mob/user)
	. = ..()
	if(default_deconstruction(I, user))
		return

	if(default_part_replacement(I, user))
		return

/obj/machinery/mech_recharger/proc/start_charging(var/mob/living/exosuit/M)
	if(stat & (NOPOWER | BROKEN))
		M.occupant_message(SPAN_WARNING("Power port not responding. Terminating."))
		return

	if(M.get_cell())
		M.occupant_message(SPAN_NOTICE("Now charging..."))
		charging = M

/obj/machinery/mech_recharger/proc/stop_charging()
	if(!charging)
		return

	charging = null
	update_use_power(IDLE_POWER_USE)

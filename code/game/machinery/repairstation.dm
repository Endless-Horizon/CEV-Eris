#define REPAIR_HULL 1
#define REPAIR_COMPONENTS 2

/obj/machinery/repair_station
	name = "cyborg auto-repair platform"
	desc = "An automated repair system, designed to repair drones and cyborgs that stand on it."
	//PLACEHOLDER
	icon = 'icons/mechs/mech_bay.dmi'
	icon_state = "recharge_floor"
	///PLACEHOLDER
	anchored = TRUE
	density = FALSE
	layer = TURF_LAYER + 0.1

	use_power = IDLE_POWER_USE
	idle_power_usage = 4
	active_power_usage = 4000

	var/mob/living/silicon/robot/repairing

	var/repair_amount = 100 //How much we can heal something for.
	var/repair_rate = 5 //How much HP we restore per second
	var/repair_complexity = REPAIR_HULL //How complex we get regarding repairing things

/obj/machinery/repair_station/examine(mob/user)
	..()
	to_chat(user, "It has [SPAN_NOTICE("[repair_amount]")] repair points remaining.")

/obj/machinery/repair_station/Crossed(var/mob/living/silicon/robot/R)
	. = ..()
	if(istype(R) && repairing != R)
		start_repairing(R)

/obj/machinery/repair_station/Uncrossed(var/mob/living/silicon/R)
	. = ..()
	if(R == repairing)
		stop_repairing()

/obj/machinery/repair_station/RefreshParts()
	..()
	var/manip_level = 1
	var/scan_level = 1
	for(var/obj/item/stock_parts/P in component_parts)
		if(istype(P, /obj/item/stock_parts/scanning_module))
			scan_level += P.rating-1
		if(istype(P, /obj/item/stock_parts/manipulator))
			manip_level += P.rating-1

	repair_rate = initial(repair_rate)+(manip_level*max(1, scan_level/2))
	if(scan_level >= 3)
		repair_complexity |= REPAIR_COMPONENTS
	idle_power_usage *= manip_level*scan_level
	active_power_usage *= manip_level*scan_level

/obj/machinery/repair_station/Process()
	..()
	if(!repairing)
		return

	if(repairing.loc != loc)
		stop_repairing()
		return

	if(!repair_amount)
		visible_message("\The [src] buzzes \"Insufficient material remaining to continue repairs.\".")
		stop_repairing()
		return
	var/repair_count = 0
	if(repair_complexity & REPAIR_HULL && (repairing.getBruteLoss() || repairing.getFireLoss()))
		var/amount_to_heal = min(repair_amount, repair_rate)
		repairing.adjustBruteLoss(-amount_to_heal)
		repairing.adjustFireLoss(-amount_to_heal)
		repairing.updatehealth()
		repair_amount = max(0, repair_amount-amount_to_heal)
		repair_count += amount_to_heal

	if(!repair_amount)
		return

	if(repair_complexity & REPAIR_COMPONENTS)
		for(var/V in repairing.components)
			var/datum/robot_component/C = repairing.components[V]
			if(C.brute_damage || C.electronics_damage)
				var/amount_to_heal = min(repair_amount, repair_rate)
				C.heal_damage(amount_to_heal/2,amount_to_heal/2)
				repair_amount = max(0, repair_amount-amount_to_heal)
				repair_count += amount_to_heal
				break

	if(!repair_count)
		to_chat(repairing, SPAN_NOTICE("Repairs complete. Shutting down."))
		stop_repairing()

/obj/machinery/repair_station/proc/start_repairing(var/mob/living/silicon/robot/R)
	if(stat & (NOPOWER | BROKEN))
		to_chat(R, SPAN_WARNING("Repair system not responding. Terminating."))
		return

	to_chat(R, SPAN_NOTICE("Commencing repairs. Please stand by."))
	repairing = R
	update_use_power(ACTIVE_POWER_USE)

/obj/machinery/repair_station/proc/stop_repairing()
	if(!repairing)
		return

	repairing = null
	update_use_power(IDLE_POWER_USE)

/obj/machinery/repair_station/attackby(var/obj/item/O, var/mob/user)
	.=..()
	if(istype(O,/obj/item/stack/material) && O.get_material_name() == MATERIAL_STEEL)
		var/obj/item/stack/material/S = O
		if(S.use(1))
			to_chat(user, SPAN_NOTICE("You insert a sheet of \the [S]. \The [src] now has [repair_amount] repair points remaining."))
			repair_amount += 25

#undef REPAIR_HULL
#undef REPAIR_COMPONENTS
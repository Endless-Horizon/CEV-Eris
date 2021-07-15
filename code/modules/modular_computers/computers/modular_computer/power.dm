/obj/item/modular_computer/proc/power_failure(var/malfunction = 0)
	if(enabled) // Shut down the computer
		visible_message("<span class='danger'>\The [src]'s screen flickers briefly and then goes dark.</span>", range = 1)
		for(var/p in all_threads)
			var/datum/computer_file/program/PRG = p
			PRG.event_power_failure()
		shutdown_computer(0)

// Tries to use power from battery. Passing 0 as parameter results in this proc returning whether battery is functional or not.
/obj/item/modular_computer/proc/battery_power(power_usage = 0)
	apc_powered = FALSE
	if(!cell || cell.is_empty())
		return FALSE
	if(cell.use(power_usage * CELLRATE * 0.1) || ((power_usage == 0) && cell.charge))
		return TRUE
	return FALSE

// Tries to use power from APC, if present.
/obj/item/modular_computer/proc/apc_power(power_usage = 0)

	// Tesla link was originally limited to machinery only, but this probably works too, and the benefit of being able to power all devices from an APC outweights
	// the possible minor performance loss.
	if(!tesla_link || !tesla_link.check_functionality())
		return FALSE
	var/area/A = get_area(src)
	if(!istype(A) || !A.powered(STATIC_EQUIP))
		return FALSE

	// At this point, we know that APC can power us for this tick. Check if we also need to charge our battery, and then actually use the power.
	if(cell && (!cell.fully_charged()) && (power_usage > 0))
		power_usage += tesla_link.passive_charging_rate
		cell.give(tesla_link.passive_charging_rate * CELLRATE * 0.1)
	apc_powered = TRUE
	A.use_power(power_usage, STATIC_EQUIP)
	return TRUE

// First tries to charge from an APC, if APC is unavailable switches to battery power. If neither works, fails.
/obj/item/modular_computer/proc/try_use_power(power_usage = 0)
	return apc_power(power_usage) || battery_power(power_usage)

// Handles power-related things, such as battery interaction, recharging, shutdown when it's discharged
/obj/item/modular_computer/proc/handle_power()
	var/power_usage = screen_on ? base_active_power_usage : base_idle_power_usage
	for(var/obj/item/computer_hardware/H in get_all_components())
		if(H.enabled)
			power_usage += H.power_usage
	last_power_usage = power_usage

	if(!try_use_power(power_usage))
		power_failure()


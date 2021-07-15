// the power cell
// charge from 0 to 100%
// fits in APC to provide backup power

/obj/item/cell //Basic type of the cells, should't be used by itself
	name = "power cell"
	desc = "A rechargable electrochemical power cell."
	icon = 'icons/obj/power_cells.dmi'
	icon_state = "b_st"
	item_state = "cell"
	origin_tech = list(TECH_POWER = 1)
	force = WEAPON_FORCE_WEAK
	throwforce = WEAPON_FORCE_WEAK
	throw_speed = 3
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	//Spawn_values
	bad_type = /obj/item/cell
	rarity_value = 2
	spawn_tags = SPAWN_TAG_POWERCELL
	var/charge = 0	// note %age conveted to actual charge in New
	var/maxcharge = 100
	var/max_chargerate = 0.08 //Power cells are limited in how much power they can intake per charge tick, to prevent small cells from charging almost instantly
	//Default 8% of maximum
	//A tick is roughly 2 seconds, so this means a cell will take a minimum of 25 seconds to charge
	var/rigged = FALSE		// true if rigged to explode
	var/minor_fault = 0 //If not 100% reliable, it will build up faults.
	var/autorecharging = FALSE //For nucclear cells
	var/autorecharge_rate = BASE_AUTORECHARGE_RATE//0.03
	var/recharge_time = BASE_RECHARGE_TIME//4 //How often nuclear cells will recharge
	var/charge_tick = 0
	var/last_charge_status = -1 //used in update_icon optimization

/obj/item/cell/Initialize()
	. = ..()
	charge = maxcharge
	update_icon()
	if(autorecharging)
		START_PROCESSING(SSobj, src)

/obj/item/cell/Process()
	charge_tick++
	if(charge_tick < recharge_time) return FALSE
	charge_tick = 0
	give(maxcharge * autorecharge_rate)

	// If installed in a gun, update gun icon to reflect new charge level.
	if(istype(loc, /obj/item/gun/energy))
		var/obj/item/gun/energy/I = loc
		I.update_icon()

	return TRUE

//Newly manufactured cells start off empty. You can't create energy
/obj/item/cell/Created()
	charge = 0
	update_icon()

/obj/item/cell/drain_power(drain_check, surge, power = 0)

	if(drain_check)
		return TRUE

	if(is_empty())
		return FALSE

	var/cell_amt = power * CELLRATE

	return use(cell_amt) / CELLRATE

/obj/item/cell/on_update_icon()
	var/charge_status
	var/c = charge/maxcharge
	if (c >=0.95)
		charge_status = 100
	else if (c >=0.75)
		charge_status = 75
	else if (c >=0.50)
		charge_status = 50
	else if (c >=0.25)
		charge_status = 25
	else if (c >=0.01)
		charge_status = 0

	if (charge_status == last_charge_status)
		return

	cut_overlays()
	if (charge_status != null)
		add_overlays(image('icons/obj/power_cells.dmi', "[icon_state]_[charge_status]"))

	last_charge_status = charge_status

/obj/item/cell/proc/is_empty()
	if(charge <= 0)
		return TRUE
	return FALSE

/obj/item/cell/proc/percent()		// return % charge of cell
	return 100*charge/maxcharge

/obj/item/cell/proc/fully_charged()
	return (charge == maxcharge)

// checks if the power cell is able to provide the specified amount of charge
/obj/item/cell/proc/check_charge(amount)
	return (charge >= amount)

// use power from a cell, returns the amount actually used
/obj/item/cell/proc/use(amount)
	if(rigged && amount > 0)
		explode()
		return FALSE
	var/used = min(charge, amount)
	charge -= used
	update_icon()
	return used

// Checks if the specified amount can be provided. If it can, it removes the amount
// from the cell and returns 1. Otherwise does nothing and returns 0.
/obj/item/cell/proc/checked_use(amount)
	if(!check_charge(amount))
		return FALSE
	use(amount)
	return TRUE

// recharge the cell
/obj/item/cell/proc/give(amount)
	if(rigged && amount > 0)
		explode()
		return FALSE

	if(maxcharge < amount)	return FALSE
	var/amount_used = min(maxcharge-charge,amount)
	charge += amount_used
	update_icon()
	return amount_used


/obj/item/cell/examine(mob/user)
	if(!..(user,2))
		return

	to_chat(user, "The manufacturer's label states this cell has a power rating of [maxcharge], and that you should not swallow it.")
	to_chat(user, "The charge meter reads [round(percent() )]%.")

	if(rigged && user.stats?.getStat(STAT_MEC) >= STAT_LEVEL_ADEPT)
		to_chat(user, SPAN_WARNING("This cell is ready to short circuit!"))


/obj/item/cell/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/reagent_containers/syringe))
		var/obj/item/reagent_containers/syringe/S = W

		to_chat(user, "You inject the solution into the power cell.")

		if(S.reagents.has_reagent("plasma", 5))

			rigged = TRUE

			log_admin("LOG: [user.name] ([user.ckey]) injected a power cell with plasma, rigging it to explode.")
			message_admins("LOG: [user.name] ([user.ckey]) injected a power cell with plasma, rigging it to explode.")

		S.reagents.clear_reagents()


/obj/item/cell/proc/explode()
	if(QDELETED(src))
		rigged = FALSE // Prevent error spam
		throw EXCEPTION("A rigged cell has attempted to explode in nullspace. Usually this means that handle_atom_del handling is missing somewhere.")

	var/turf/T = get_turf(loc)
/*
 * 1000-cell	explosion(T, -1, 0, 1, 1)
 * 2500-cell	explosion(T, -1, 0, 1, 1)
 * 10000-cell	explosion(T, -1, 1, 3, 3)
 * 15000-cell	explosion(T, -1, 2, 4, 4)
 * */
	if(is_empty())
		return
	var/devastation_range = -1 //round(charge/11000)
	var/heavy_impact_range = round(sqrt(charge)/60)
	var/light_impact_range = round(sqrt(charge)/30)
	var/flash_range = light_impact_range
	if (light_impact_range==0)
		rigged = FALSE
		corrupt()
		return
	//explosion(T, 0, 1, 2, 2)

	log_admin("LOG: Rigged power cell explosion, last touched by [fingerprintslast]")
	message_admins("LOG: Rigged power cell explosion, last touched by [fingerprintslast]")

	qdel(src)

	explosion(T, devastation_range, heavy_impact_range, light_impact_range, flash_range)

/obj/item/cell/proc/corrupt()
	charge /= 2
	maxcharge /= 2
	if (prob(10))
		rigged = TRUE //broken batterys are dangerous

/obj/item/cell/emp_act(severity)
	//remove this once emp changes on dev are merged in
	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		severity *= R.cell_emp_mult

	// Lose 1/2, 1/4, 1/6 of the current charge per hit or 1/4, 1/8, 1/12 of the max charge per hit, whichever is highest
	charge -= max(charge / (2 * severity), maxcharge/(4 * severity))
	if (charge < 0)
		charge = 0
	..()

/obj/item/cell/ex_act(severity)

	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if (prob(50))
				qdel(src)
				return
			if (prob(50))
				corrupt()
		if(3)
			if (prob(25))
				qdel(src)
				return
			if (prob(25))
				corrupt()
	return

// Calculation of cell shock damage
// Keep in mind that airlocks, the most common source of electrocution, have siemens_coefficent of 0.7, dealing only 70% of electrocution damage
// Also, even the most common gloves and boots have siemens_coefficent < 1, offering a degree of shock protection
/obj/item/cell/proc/get_electrocute_damage()
	switch (charge)
		if (40000 to INFINITY) // Here in case some supercharged superscience cells pop up
			return min(rand(80,180),rand(80,180))
		if (20000 to 40000) // Limit for L-class - only reached by rare Robustcell-X at full charge
			return min(rand(60,160),rand(60,160))
		if (15000 to 20000) // High grade L-class
			return min(rand(50,140),rand(50,140))
		if (10000 to 15000)
			return min(rand(40,120),rand(40,120))
		if (5000 to 10000) // Default APC cell that's fully charged
			return min(rand(25,60),rand(25,60))
		if (1000 to 5000) // Low grade L-class, high grade M-class, default APC cell that's not fully charged
			return min(rand(20,40),rand(20,40))
		if (500 to 1000) // Usual M-class
			return min(rand(15,25),rand(15,25))
		if (250 to 500) // Limit for S-class
			return min(rand(10,20),rand(10,20))
		if (100 to 250) // Usual S-class
			return min(rand(5,15),rand(5,15))
		if (10 to 100) // Low S-class
			return min(rand(1,10),rand(1,10))
		else
			return FALSE

/obj/item/cell/get_cell()
	return src

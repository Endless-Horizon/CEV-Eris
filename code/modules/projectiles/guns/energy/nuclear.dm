/obj/item/gun/energy/nuclear
	name = "Prototype: advanced energy gun"
	desc = "An energy handgun with an experimental miniaturized reactor. Able to fire in two shot bursts."
	icon = 'icons/obj/guns/energy/nucgun.dmi'
	icon_state = "nucgun"
	item_charge_meter = TRUE
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 5, TECH_POWER = 3)
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	self_recharge = TRUE
	twohanded = FALSE
	projectile_type = /obj/item/projectile/beam
	charge_cost = 50
	modifystate = null
	matter = list(MATERIAL_STEEL = 15, MATERIAL_PLASTEEL = 5, MATERIAL_URANIUM = 6)
	price_tag = 4000
	spawn_blacklisted = TRUE

	init_firemodes = list(
		WEAPON_NORMAL,
		BURST_2_ROUND
		)

	var/lightfail = 0

//override for failcheck behaviour
/obj/item/gun/energy/nuclear/Process()
	charge_tick++
	if(charge_tick < 4) return 0
	charge_tick = 0
	if(!cell) return 0
	if((cell.charge / cell.maxcharge) != 1)
		cell.give(charge_cost)
		update_icon()
	return 1

/obj/item/gun/energy/nuclear/proc/update_mode()
	var/datum/firemode/current_mode = firemodes[sel_mode]
	switch(current_mode.name)
		if("stun") overlays += "nucgun-stun"
		if("lethal") overlays += "nucgun-kill"

/obj/item/gun/energy/nuclear/on_update_icon()
	cut_overlays()
	update_mode()

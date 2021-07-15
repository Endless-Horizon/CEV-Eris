/obj/item/gun/energy/ionrifle
	name = "NT IR \"Halicon\""
	desc = "The NT IR Halicon is a man-portable anti-armor weapon designed to disable mechanical threats, produced by NeoTheology. Not the best of its type, but gets the job done."
	icon = 'icons/obj/guns/energy/iongun.dmi'
	icon_state = "ionrifle"
	item_state = "ionrifle"
	item_charge_meter = TRUE
	fire_sound = 'sound/weapons/Laser.ogg'
	origin_tech = list(TECH_COMBAT = 2, TECH_MAGNET = 4)
	w_class = ITEM_SIZE_HUGE
	force = WEAPON_FORCE_PAINFUL
	flags = CONDUCT
	slot_flags = SLOT_BACK
	charge_cost = 200
	matter = list(MATERIAL_PLASTEEL = 24, MATERIAL_WOOD = 8, MATERIAL_SILVER = 10)
	price_tag = 3000
	projectile_type = /obj/item/projectile/ion
	one_hand_penalty = 5
	twohanded = TRUE

/obj/item/gun/energy/ionrifle/emp_act(severity)
	..(max(severity, 2)) //so it doesn't EMP itself, I guess

/obj/item/gun/energy/ionrifle/on_update_icon(ignore_inhands)
	..(TRUE)
	if(!cell || cell.charge < charge_cost)
		set_item_state("-empty", hands = TRUE)
	else
		set_item_state(null, hands = TRUE)
	//Update here instead of parent proc because we override hands icon
	if(!ignore_inhands)
		update_wear_icon()

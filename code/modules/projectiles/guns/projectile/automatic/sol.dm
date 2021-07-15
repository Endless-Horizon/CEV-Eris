/obj/item/gun/projectile/automatic/sol
	name = "FS CAR .25 CS \"Sol\""
	desc = "A standard-issue weapon used by Ironhammer operatives. Compact and reliable. Uses .25 Caseless rounds."
	icon = 'icons/obj/guns/projectile/sol.dmi'
	icon_state = "sol"
	item_state = "sol"
	w_class = ITEM_SIZE_BULKY
	ammo_mag = "ih_sol"
	load_method = MAGAZINE
	mag_well = MAG_WELL_IH
	caliber = CAL_CLRIFLE
	magazine_type = /obj/item/ammo_magazine/ihclrifle
	auto_eject = 1
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 2)
	slot_flags = SLOT_BELT
	matter = list(MATERIAL_PLASTEEL = 20, MATERIAL_PLASTIC = 12)
	price_tag = 2300
	auto_eject_sound = 'sound/weapons/smg_empty_alarm.ogg'
	recoil_buildup = 2
	penetration_multiplier = 1.1
	damage_multiplier = 1.15
	one_hand_penalty = 8 //because otherwise you can shoot it one-handed in bursts and still be very accurate. One-handed recoil is now as much as it was back in the day when wielded.
	gun_parts = list(/obj/item/part/gun = 2 ,/obj/item/stack/material/plasteel = 6)
	init_firemodes = list(
		SEMI_AUTO_NODELAY,
		BURST_3_ROUND
		)

	spawn_tags = SPAWN_TAG_FS_PROJECTILE

/obj/item/gun/projectile/automatic/sol/proc/update_charge()
	if(!ammo_magazine)
		return
	var/ratio = ammo_magazine.stored_ammo.len / ammo_magazine.max_ammo
	if(ratio < 0.25 && ratio != 0)
		ratio = 0.25
	ratio = round(ratio, 0.25) * 100
	add_overlays("sol_[ratio]")

/obj/item/gun/projectile/automatic/sol/on_update_icon()
	..()

	icon_state = initial(icon_state) + (ammo_magazine ? "-full" : "")
	set_item_state(ammo_magazine ? "-full" : "", back = TRUE)
	cut_overlays()
	update_charge()

/obj/item/gun/projectile/automatic/sol/generate_guntags()
	..()
	gun_tags |= GUN_SOL

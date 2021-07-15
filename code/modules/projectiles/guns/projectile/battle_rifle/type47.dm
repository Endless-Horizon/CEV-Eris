/obj/item/gun/projectile/type_47
	name = "OS CAR .25 CS \"Type XLVII\""
	desc = "A standard-issue weapon used by Onestar peacekeeping forces. Compact and reliable. Uses .25 Caseless rounds."
	icon = 'icons/obj/guns/projectile/os/type_47.dmi'
	icon_state = "type_47"
	item_state = "type_47"
	w_class = ITEM_SIZE_BULKY
	ammo_mag = "ih_sol"
	load_method = MAGAZINE
	mag_well = MAG_WELL_IH
	caliber = CAL_CLRIFLE
	magazine_type = /obj/item/ammo_magazine/ihclrifle
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 2)
	slot_flags = SLOT_BELT
	matter = list(MATERIAL_PLASTEEL = 16, MATERIAL_PLATINUM = 4, MATERIAL_PLASTIC = 12)
	price_tag = 2800
	recoil_buildup = 2
	penetration_multiplier = 1.5
	damage_multiplier = 1.5
	one_hand_penalty = 10 
	gun_tags = list(GUN_SILENCABLE)
	gun_parts = list(/obj/item/part/gun = 2 ,/obj/item/stack/material/plasteel = 6)
	init_firemodes = list(
		SEMI_AUTO_NODELAY,
		BURST_3_ROUND
		)
	spawn_blacklisted = TRUE //until loot rework

/obj/item/gun/projectile/type_47/on_update_icon()
	..()

	var/iconstring = initial(icon_state)
	var/itemstring = ""

	if (ammo_magazine)
		iconstring += "_mag"
		itemstring += "_mag"
	
	if (silenced)
		iconstring += "_s"
		itemstring += "_s"

	icon_state = iconstring
	set_item_state(itemstring)

/obj/item/gun/projectile/type_47/Initialize()
	. = ..()
	update_icon()

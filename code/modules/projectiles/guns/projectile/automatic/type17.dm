/obj/item/gun/projectile/automatic/type_17
    name = "OS AR .20 \"Type XVII\""
    desc = "An old Onestar assault rifle. A reliable, if unintuitive, design. Uses .20 Rifle magazines."
    icon = 'icons/obj/guns/projectile/os/type_17.dmi'
    icon_state = "type_17"
    item_state = "type_17"
    w_class = ITEM_SIZE_HUGE
    force = WEAPON_FORCE_PAINFUL
    caliber = CAL_SRIFLE
    origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1)
    slot_flags = SLOT_BACK
    load_method = MAGAZINE
    mag_well = MAG_WELL_RIFLE
    magazine_type = /obj/item/ammo_magazine/srifle
    matter = list(MATERIAL_PLASTEEL = 20, MATERIAL_PLATINUM = 8, MATERIAL_PLASTIC = 10)
    price_tag = 3800
    fire_sound = 'sound/weapons/guns/fire/ltrifle_fire.ogg'
    unload_sound = 'sound/weapons/guns/interact/ltrifle_magout.ogg'
    reload_sound = 'sound/weapons/guns/interact/ltrifle_magin.ogg'
    cocked_sound = 'sound/weapons/guns/interact/ltrifle_cock.ogg'
    zoom_factor = 0.6
    recoil_buildup = 1.5
    one_hand_penalty = 15 //automatic rifle level
    damage_multiplier = 1.3
    penetration_multiplier = 1.7
    spawn_tags = SPAWN_TAG_GUN_OS
    init_firemodes = list(
		BURST_3_ROUND,
        SEMI_AUTO_NODELAY
		)
    spawn_blacklisted = TRUE //until loot rework

/obj/item/gun/projectile/automatic/type_17/on_update_icon()
	..()

	var/iconstring = initial(icon_state)
	var/itemstring = ""

	if (ammo_magazine)
		iconstring += "_mag"
		itemstring += "_mag"

	icon_state = iconstring
	set_item_state(itemstring)

/obj/item/gun/projectile/automatic/type_17/Initialize()
	. = ..()
	update_icon()

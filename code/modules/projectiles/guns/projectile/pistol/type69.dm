/obj/item/gun/projectile/type_69
    name = "OS MP .40 \"Type LXIX\""
    desc = "An Onestar machine pistol. While unwieldy, its users can't deny that it is brutally effective. Uses .40 pistol magazines."
    icon = 'icons/obj/guns/projectile/os/type_69.dmi'
    icon_state = "type_69"
    item_state = "type_69"
    origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 2)
    caliber = CAL_MAGNUM
    load_method = MAGAZINE
    mag_well = MAG_WELL_PISTOL
    magazine_type = /obj/item/ammo_magazine/magnum
    matter = list(MATERIAL_PLASTEEL = 12, MATERIAL_PLATINUM = 8, MATERIAL_PLASTIC = 4)
    can_dual = TRUE
    slot_flags = SLOT_BELT|SLOT_HOLSTER
    one_hand_penalty = 10 //a bit more than smg level
    damage_multiplier = 1.2
    penetration_multiplier = 1.1
    recoil_buildup = 2.5
    init_firemodes = list(
        FULL_AUTO_400,
        SEMI_AUTO_NODELAY
        )
    spawn_tags = SPAWN_TAG_GUN_OS
    price_tag = 2500

    spawn_blacklisted = TRUE //until loot rework

/obj/item/gun/projectile/type_69/on_update_icon()
	..()

	var/iconstring = initial(icon_state)
	var/itemstring = ""

	if (ammo_magazine)
		iconstring += "_mag"
		itemstring += "_mag"

	icon_state = iconstring
	set_item_state(itemstring)

/obj/item/gun/projectile/type_69/Initialize()
	. = ..()
	update_icon()

/obj/item/gun/projectile/type_42
	name = "OS HG .25 CS \"Type XLII\""
	desc = "An old Onestar pistol, designed with esoteric mechanisms. Uses .25 Caseless rounds."
	icon = 'icons/obj/guns/projectile/os/type_42.dmi'
	icon_state = "type_42"
	item_state = "type_42"
	w_class = ITEM_SIZE_SMALL
	can_dual = TRUE
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	matter = list(MATERIAL_PLASTEEL = 10, MATERIAL_PLATINUM = 4, MATERIAL_PLASTIC = 6)
	price_tag = 1800
	caliber = CAL_CLRIFLE
	load_method = MAGAZINE
	mag_well = MAG_WELL_PISTOL
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	magazine_type = /obj/item/ammo_magazine/cspistol
	damage_multiplier = 1.3
	penetration_multiplier = 1.3
	recoil_buildup = 2.5
	spawn_tags = SPAWN_TAG_GUN_OS

	spawn_blacklisted = TRUE //until loot rework


/obj/item/gun/projectile/type_42/on_update_icon()
	..()

	var/iconstring = initial(icon_state)
	var/itemstring = ""

	if (ammo_magazine)
		iconstring += "_mag"
		itemstring += "_mag"

	icon_state = iconstring
	set_item_state(itemstring)

/obj/item/gun/projectile/type_42/Initialize()
	. = ..()
	update_icon()

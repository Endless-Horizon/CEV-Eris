/obj/item/gun/projectile/paco
	name = "FS HG .35 Auto \"Paco\""
	desc = "A modern and reliable sidearm for the soldier in the field. Commonly issued as a sidearm to Ironhammer Operatives. Uses standard .35 and high capacity magazines."
	icon = 'icons/obj/guns/projectile/paco.dmi'
	icon_state = "paco"
	item_state = "paco"
	w_class = ITEM_SIZE_NORMAL
	can_dual = TRUE
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2)
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	ammo_type = /obj/item/ammo_casing/pistol
	caliber = CAL_PISTOL
	load_method = MAGAZINE
	mag_well = MAG_WELL_PISTOL|MAG_WELL_H_PISTOL
	magazine_type = /obj/item/ammo_magazine/pistol
	auto_eject = 1
	matter = list(MATERIAL_PLASTEEL = 14, MATERIAL_PLASTIC = 4)
	price_tag = 1500
	auto_eject_sound = 'sound/weapons/smg_empty_alarm.ogg'
	fire_sound = 'sound/weapons/guns/fire/pistol_fire.ogg'
	damage_multiplier = 1.5
	penetration_multiplier = 0.9
	recoil_buildup = 3
	gun_tags = list(GUN_SILENCABLE)

	spawn_tags = SPAWN_TAG_FS_PROJECTILE

/obj/item/gun/projectile/paco/on_update_icon()
	..()

	var/iconstring = initial(icon_state)
	var/itemstring = ""

	if (ammo_magazine)
		iconstring += "_mag"

	if (!ammo_magazine || !length(ammo_magazine.stored_ammo))
		iconstring += "_slide"

	if (silenced)
		iconstring += "_s"
		itemstring += "_s"

	icon_state = iconstring
	set_item_state(itemstring)

/obj/item/gun/projectile/paco/Initialize()
	. = ..()
	update_icon()

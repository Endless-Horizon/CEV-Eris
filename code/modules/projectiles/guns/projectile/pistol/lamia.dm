/obj/item/gun/projectile/lamia
	name = "FS HG .40 Magnum \"Lamia\""
	desc = "FS HG .40 Magnum \"Lamia\", a heavy pistol of Ironhammer enforcers. Uses 40 Magnum rounds."
	icon = 'icons/obj/guns/projectile/lamia.dmi'
	icon_state = "lamia"
	item_state = "lamia"
	fire_sound = 'sound/weapons/guns/fire/hpistol_fire.ogg'
	ammo_mag = "mag_magnum"
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 4)
	can_dual = TRUE
	caliber = CAL_MAGNUM
	load_method = MAGAZINE
	mag_well = MAG_WELL_PISTOL
	magazine_type = /obj/item/ammo_magazine/magnum
	auto_eject = 1
	matter = list(MATERIAL_PLASTEEL = 15, MATERIAL_PLASTIC = 8)
	price_tag = 2400
	auto_eject_sound = 'sound/weapons/smg_empty_alarm.ogg'
	unload_sound = 'sound/weapons/guns/interact/hpistol_magout.ogg'
	reload_sound = 'sound/weapons/guns/interact/hpistol_magin.ogg'
	cocked_sound = 'sound/weapons/guns/interact/hpistol_cock.ogg'
	damage_multiplier = 1.4
	penetration_multiplier = 1.4
	recoil_buildup = 2

	spawn_tags = SPAWN_TAG_FS_PROJECTILE

/obj/item/gun/projectile/lamia/on_update_icon()
	..()
	if(ammo_magazine)
		icon_state = "lamia-[round(ammo_magazine.stored_ammo.len,2)]"
	else
		icon_state = "lamia"
	return

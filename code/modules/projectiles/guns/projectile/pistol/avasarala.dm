/obj/item/gun/projectile/avasarala
	name = "NT HG .40 Magnum \"Avasarala\""
	desc = "An obvious replica of an old Earth \"Desert Eagle\". Robust and straight, this is a gun for a leader, not just an officer."

	icon = 'icons/obj/guns/projectile/avasarala.dmi'
	icon_state = "avasarala"
	item_state = "avasarala"

	force = WEAPON_FORCE_PAINFUL
	caliber = CAL_MAGNUM
	load_method = MAGAZINE
	mag_well = MAG_WELL_PISTOL

	magazine_type = /obj/item/ammo_magazine/magnum

	matter = list(MATERIAL_PLASTEEL = 15, MATERIAL_PLASTIC = 8)
	can_dual = TRUE
	damage_multiplier = 1.45
	penetration_multiplier = 1.35
	recoil_buildup = 5

	fire_sound = 'sound/weapons/guns/fire/hpistol_fire.ogg'
	unload_sound = 'sound/weapons/guns/interact/hpistol_magout.ogg'
	reload_sound = 'sound/weapons/guns/interact/hpistol_magin.ogg'
	cocked_sound = 'sound/weapons/guns/interact/hpistol_cock.ogg'

	price_tag = 1600
	spawn_tags = SPAWN_TAG_FS_PROJECTILE

/obj/item/gun/projectile/avasarala/on_update_icon()
	..()

	var/iconstring = initial(icon_state)

	if (!ammo_magazine || !length(ammo_magazine.stored_ammo))
		iconstring += "_slide"

	SetIconState(iconstring)

/obj/item/gun/projectile/avasarala/Initialize()
	. = ..()
	update_icon()

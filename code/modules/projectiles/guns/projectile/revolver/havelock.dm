/obj/item/gun/projectile/revolver/havelock
	name = "FS REV .35 Auto \"Havelock\""
	desc = "A cheap Frozen Star knock-off of a Smith & Wesson Model 10. Uses .35 special rounds."
	icon = 'icons/obj/guns/projectile/havelock.dmi'
	icon_state = "havelock"
	drawChargeMeter = FALSE
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	fire_sound = 'sound/weapons/Gunshot_light.ogg'
	max_shells = 6
	caliber = CAL_PISTOL
	ammo_type = /obj/item/ammo_casing/pistol
	magazine_type = /obj/item/ammo_magazine/slpistol
	matter = list(MATERIAL_PLASTEEL = 12, MATERIAL_WOOD = 6)
	price_tag = 700
	damage_multiplier = 1.4 //because pistol round
	penetration_multiplier = 1.4
	recoil_buildup = 3

	spawn_tags = SPAWN_TAG_FS_PROJECTILE

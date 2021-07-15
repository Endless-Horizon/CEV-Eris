/obj/item/gun/projectile/revolver/consul
	name = "FS REV .40 Magnum \"Consul\""
	desc = "When you badly need this case to be closed. Uses .40 Magnum rounds."
	icon = 'icons/obj/guns/projectile/inspector.dmi'
	icon_state = "inspector"
	item_state = "revolver"
	drawChargeMeter = FALSE
	caliber = CAL_MAGNUM
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3)
	max_shells = 6
	ammo_type = /obj/item/ammo_casing/magnum/rubber
	matter = list(MATERIAL_PLASTEEL = 15, MATERIAL_PLASTIC = 8)
	price_tag = 1700
	damage_multiplier = 1.35
	penetration_multiplier = 1.5
	recoil_buildup = 6
	spawn_tags = SPAWN_TAG_FS_PROJECTILE

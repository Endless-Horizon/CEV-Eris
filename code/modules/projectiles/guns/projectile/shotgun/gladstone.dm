/obj/item/gun/projectile/shotgun/pump/gladstone
	name = "FS SG \"Gladstone\""
	desc = "It is a next-generation Frozen Star shotgun intended as a cost-effective competitor to the aging NT \"Regulator 1000\". It has a semi-rifled lightweight full-length barrel which gives it exceptional projectile velocity and armor piercing capabilites with slugs, with a high-capacity magazine tube below it. Can hold up to 9 shells in a tube magazine."
	icon = 'icons/obj/guns/projectile/gladstone.dmi'
	icon_state = "gladstone"
	item_state = "gladstone"
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 2)
	max_shells = 9 //more shells
	penetration_multiplier = 1.3 // and good AP
	proj_step_multiplier = 0.8 // faster than non-shotgun bullets, slower than non-shotgun bullets with an accelerator
	ammo_type = /obj/item/ammo_casing/shotgun
	matter = list(MATERIAL_PLASTEEL = 20, MATERIAL_PLASTIC = 6)
	recoil_buildup = 10
	one_hand_penalty = 15 //full sized shotgun level
	damage_multiplier = 0.8

	price_tag = 1800
	spawn_tags = SPANW_TAG_FS_SHOTGUN

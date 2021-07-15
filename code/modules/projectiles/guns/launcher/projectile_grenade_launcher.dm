/obj/item/gun/projectile/shotgun/pump/china
	name = "China Lake"
	desc = "This centuries-old design was recently rediscovered and adapted for use in modern battlefields. \
		Working similar to a pump-action combat shotgun, its light weight and robust design quickly made it a popular weapon. \
		It uses specialised grenade shells."

	icon = 'icons/obj/guns/projectile/chinalake.dmi'
	icon_state = "china_lake"
	item_state = "china_lake"

	w_class = ITEM_SIZE_HUGE
	slot_flags = SLOT_BACK
	force = WEAPON_FORCE_PAINFUL

	caliber = CAL_GRENADE
	load_method = SINGLE_CASING
	handle_casings = HOLD_CASINGS
	max_shells = 3
	recoil_buildup = 20
	twohanded = TRUE
	ammo_type = /obj/item/ammo_casing/grenade/frag
	fire_sound = 'sound/weapons/guns/fire/grenadelauncher_fire.ogg'
	bulletinsert_sound = 'sound/weapons/guns/interact/batrifle_magin.ogg'	//Placeholder, could use a new sound

	matter = list(MATERIAL_PLASTEEL = 25, MATERIAL_WOOD = 10)
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 2)

	price_tag = 4500

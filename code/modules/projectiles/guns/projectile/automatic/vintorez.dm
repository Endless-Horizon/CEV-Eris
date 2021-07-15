/obj/item/gun/projectile/automatic/vintorez
	name = "Excelsior .20 \"Vintorez\""
	desc = "This gun is a copy of a design from a country that no longer exists. It is still highly prized for its armor piercing capabilities."
	icon = 'icons/obj/guns/projectile/vintorez.dmi'
	icon_state = "vintorez"
	item_state = "vintorez"
	w_class = ITEM_SIZE_BULKY
	force = WEAPON_FORCE_PAINFUL
	caliber = CAL_SRIFLE
	origin_tech = list(TECH_COMBAT = 6, TECH_COVERT = 4, TECH_MATERIAL = 2)
	slot_flags = SLOT_BACK
	ammo_type = /obj/item/ammo_casing/srifle
	load_method = MAGAZINE
	mag_well = MAG_WELL_RIFLE
	magazine_type = /obj/item/ammo_magazine/srifle
	matter = list(MATERIAL_PLASTEEL = 20, MATERIAL_PLASTIC = 5)
	price_tag = 4000
	zoom_factor = 0.8 // double as IH_heavy
	penetration_multiplier = 1.2
	damage_multiplier = 1.2
	recoil_buildup = 1.3
	one_hand_penalty = 15 //automatic rifle level
	silenced = TRUE
	init_firemodes = list(
		SEMI_AUTO_NODELAY,
		FULL_AUTO_400
		)


/obj/item/gun/projectile/automatic/vintorez/on_update_icon()
	var/iconstring = initial(icon_state)
	var/itemstring = initial(item_state)

	if (ammo_magazine)
		iconstring += "_mag"
		itemstring += "_mag"

	if (!ammo_magazine || !length(ammo_magazine.stored_ammo))
		iconstring += "_slide"

	icon_state = iconstring
	item_state = itemstring

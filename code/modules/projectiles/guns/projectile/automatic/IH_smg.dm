/obj/item/weapon/gun/projectile/automatic/IH_smg
	name = "FS SMG \"Straylight\""
	desc = "A compact and lightweight submachinegun that sprays small rounds rapidly. Sacrifices a fire selector to cut mass, so it requires a careful hand. Uses 9mm rounds."
	icon_state = "IH_smg"
	item_state = "IH_smg"
	w_class = ITEM_SIZE_NORMAL
	caliber = "9mm"
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2)
	slot_flags = SLOT_BELT
	ammo_type = "/obj/item/ammo_casing/c9mm"
	load_method = MAGAZINE
	mag_well = list("smg")
	magazine_type = /obj/item/ammo_magazine/smg9mm
	matter = list(MATERIAL_PLASTEEL = 16, MATERIAL_PLASTIC = 4)
	damage_multiplier = 0.7
	silencer_type = /obj/item/weapon/silencer
	firemodes = list(
		FULL_AUTO_600)

/obj/item/weapon/gun/projectile/automatic/IH_smg/update_icon()
	var/iconstring = initial(icon_state)
	var/itemstring = initial(item_state)

	if (ammo_magazine)
		iconstring += "_mag"

	if (silenced)
		iconstring += "_s"
		itemstring += "_s"

	icon_state = iconstring
	item_state = itemstring
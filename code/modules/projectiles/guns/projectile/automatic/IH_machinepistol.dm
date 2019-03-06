/obj/item/weapon/gun/projectile/automatic/IH_machinepistol
	name = "Machine Pistol"
	desc = "An experimental fully automatic pistol. Compact and flexible, but somewhat underpowered"
	icon_state = "IH_mp"
	item_state = "IH_mp"
	w_class = ITEM_SIZE_SMALL
	caliber = "9mm"
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2)
	slot_flags = SLOT_BELT
	ammo_type = "/obj/item/ammo_casing/c9mm"
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/smg9mm
	matter = list(MATERIAL_PLASTEEL = 12, MATERIAL_PLASTIC = 3)
	price_tag = 1250
	silencer_type = /obj/item/weapon/silencer
	damage_multiplier = 0.55
	firemodes = list(
		FULL_AUTO_400,
		list(mode_name="semiauto",       burst=1, fire_delay=0,    move_delay=null, dispersion=null),
		list(mode_name="3-round bursts", burst=3, fire_delay=null, move_delay=6,    dispersion=list(0.0, 0.6, 0.6)),
		)

/obj/item/weapon/gun/projectile/automatic/IH_machinepistol/update_icon()
	var/iconstring = initial(icon_state)
	var/itemstring = initial(item_state)

	if (ammo_magazine)
		iconstring += "_mag"

		if(!ammo_magazine.stored_ammo.len)
			iconstring += "_slide"

	if (silenced)
		iconstring += "_s"
		itemstring += "_s"

	icon_state = iconstring
	item_state = itemstring
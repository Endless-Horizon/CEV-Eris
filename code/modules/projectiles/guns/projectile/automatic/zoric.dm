/obj/item/gun/projectile/automatic/zoric
	name = "SA SMG .40 Magnum \"Zoric\""
	desc = "A Heavy Submachine Gun made by \"Serbian Arms\", for paramilitary and private security use. \
			Rifled to take a larger caliber than a typical submachine gun, it boasts a greater impact, but suffers \
			from poor recoil control and worse than average armor penetration capabilities as a result. \
			Has worse than average fire rate. Uses .40 Magnum rounds."
	icon = 'icons/obj/guns/projectile/zoric.dmi'
	icon_state = "zoric"
	item_state = "zoric"
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2)
	slot_flags = SLOT_BELT
	caliber = CAL_MAGNUM
	load_method = MAGAZINE
	mag_well = MAG_WELL_SMG
	magazine_type = /obj/item/ammo_magazine/msmg
	matter = list(MATERIAL_PLASTEEL = 10, MATERIAL_STEEL = 6, MATERIAL_PLASTIC = 4)
	price_tag = 2000
	damage_multiplier = 1	 // 34 lethal
	penetration_multiplier = 0.5 // 7.5 lethal
	recoil_buildup = 0.7
	twohanded = FALSE
	one_hand_penalty = 5 //smg level

	init_firemodes = list(
		FULL_AUTO_300,
		SEMI_AUTO_NODELAY,
		)

/obj/item/gun/projectile/automatic/zoric/on_update_icon()
	cut_overlays()
	icon_state = "[initial(icon_state)][silenced ? "_s" : ""]"
	if(ammo_magazine)
		add_overlays("mag[silenced ? "_s" : ""][ammo_magazine.ammo_color]")
	if (!ammo_magazine || !length(ammo_magazine.stored_ammo))
		add_overlays("slide[silenced ? "_s" : ""]")

/obj/item/gun/projectile/automatic/zoric/Initialize()
	. = ..()
	update_icon()

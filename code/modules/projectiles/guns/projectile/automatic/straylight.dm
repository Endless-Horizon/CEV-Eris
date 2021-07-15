/obj/item/gun/projectile/automatic/straylight
	name = "FS SMG .35 Auto \"Straylight\""
	desc = "A compact, lightweight and cheap rapid-firing submachine gun. In past was primarily used for testing ammunition and weapon modifications, \
			novadays mass produced for IH security forces. Suffers from poor recoil control and underperforming ballistic impact, \
			but makes up for this through sheer firerate. Especially effective with rubber ammunition. Uses .35 Auto rounds."
	icon = 'icons/obj/guns/projectile/straylight.dmi'
	icon_state = "straylight"
	item_state = "straylight"
	w_class = ITEM_SIZE_NORMAL
	caliber = CAL_PISTOL
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2)
	slot_flags = SLOT_BELT
	load_method = MAGAZINE
	mag_well = MAG_WELL_SMG
	magazine_type = /obj/item/ammo_magazine/smg
	auto_eject = 1
	matter = list(MATERIAL_PLASTEEL = 12, MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 8)
	price_tag = 1400
	auto_eject_sound = 'sound/weapons/smg_empty_alarm.ogg'
	damage_multiplier = 0.65	 //made with rubber rounds in mind. For lethality refer to Wintermute. Still quite lethal if you manage to land most shots.
	penetration_multiplier = 0.5 //practically no AP, 2.5 with regular rounds and 5 with HV. Still deadly to unarmored targets.
	recoil_buildup = 1
	one_hand_penalty = 5 //smg level
	gun_tags = list(GUN_SILENCABLE)

	init_firemodes = list(
		FULL_AUTO_600,
		SEMI_AUTO_NODELAY
		)

	spawn_tags = SPAWN_TAG_FS_PROJECTILE

/obj/item/gun/projectile/automatic/straylight/on_update_icon()
	..()

	var/iconstring = initial(icon_state)
	var/itemstring = ""

	if(ammo_magazine)
		iconstring += "_mag"
		itemstring += "_mag"

	if(!ammo_magazine || !length(ammo_magazine.stored_ammo))
		iconstring += "_slide"

	if(silenced)
		iconstring += "_s"
		itemstring += "_s"

	icon_state = iconstring
	set_item_state(itemstring)

/obj/item/gun/projectile/automatic/straylight/Initialize()
	. = ..()
	update_icon()

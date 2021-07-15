/obj/item/gun/projectile/automatic/molly
	name = "FS MP .35 Auto \"Molly\""
	desc = "An experimental fully automatic pistol, designed as a middle ground between SMGs and Pistols. \
			Primarily employed in CQC scenarios or as a civilian self defence tool. \
			Takes both highcap pistol and smg mags. Uses .35 Auto rounds."

	icon = 'icons/obj/guns/projectile/molly.dmi'
	icon_state = "molly"
	item_state = "molly"

	w_class = ITEM_SIZE_NORMAL
	can_dual = TRUE
	caliber = CAL_PISTOL
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	ammo_type = /obj/item/ammo_casing/pistol
	load_method = MAGAZINE
	mag_well = MAG_WELL_H_PISTOL|MAG_WELL_SMG
	magazine_type = /obj/item/ammo_magazine/smg
	auto_eject_sound = 'sound/weapons/smg_empty_alarm.ogg'

	gun_tags = list(GUN_SILENCABLE)
	init_firemodes = list(
		FULL_AUTO_400,
		SEMI_AUTO_NODELAY,
		)

	can_dual = 1
	auto_eject = 1
	damage_multiplier = 0.7 //good for rubber takedowns or self-defence, not so good to kill someone, you might want to use better smg
	recoil_buildup = 1
	one_hand_penalty = 5 //despine it being handgun, it's better to hold in two hands while shooting. SMG level.

	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 2)
	matter = list(MATERIAL_PLASTEEL = 12, MATERIAL_PLASTIC = 3)

	price_tag = 1700
	spawn_tags = SPAWN_TAG_FS_PROJECTILE

/obj/item/gun/projectile/automatic/molly/on_update_icon()
	..()

	var/iconstring = initial(icon_state)
	var/itemstring = ""

	if (ammo_magazine)
		iconstring += "_mag"

	if (!ammo_magazine || !length(ammo_magazine.stored_ammo))
		iconstring += "_slide"

	if (silenced)
		iconstring += "_s"
		itemstring += "_s"

	if (wielded)
		itemstring += "_doble"

	icon_state = iconstring
	set_item_state(itemstring)

/obj/item/gun/projectile/automatic/molly/Initialize()
	. = ..()
	update_icon()

/obj/item/gun/projectile/giskard
	name = "FS HG .35 Auto \"Giskard\""
	desc = "A popular \"Frozen Star\" brand pocket pistol chambered for the ubiquitous .35 auto round. Uses standard capacity magazines."
	icon = 'icons/obj/guns/projectile/giskard.dmi'
	icon_state = "giskard"
	item_state = "pistol"
	fire_sound = 'sound/weapons/guns/fire/pistol_fire.ogg'
	gun_tags = list(GUN_SILENCABLE)
	w_class = ITEM_SIZE_SMALL
	can_dual = TRUE
	fire_delay = 0.6
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 3)
	caliber = CAL_PISTOL
	load_method = MAGAZINE
	mag_well = MAG_WELL_PISTOL
	magazine_type = /obj/item/ammo_magazine/pistol
	matter = list(MATERIAL_PLASTEEL = 10, MATERIAL_WOOD = 4)
	price_tag = 400
	damage_multiplier = 1.3
	penetration_multiplier = 0.8
	recoil_buildup = 2
	spawn_tags = SPAWN_TAG_FS_PROJECTILE

/obj/item/gun/projectile/giskard/on_update_icon()
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

	icon_state = iconstring
	set_item_state(itemstring)

/obj/item/gun/projectile/giskard/Initialize()
	. = ..()
	update_icon()

/obj/item/gun/projectile/mandella
	name = "OR HG .25 CS \"Mandella\""
	desc = "A rugged, robust operator handgun with inbuilt silencer. Chambered in rifle caseless ammunition, this time-tested handgun is \
			your absolute choise if you need to take someone down silently, as it's deadly, produces no sound and leaves no traces. \
			Built to have enhanced armor penetration abilities. \
			Uses .25 Caseless rounds."
	icon = 'icons/obj/guns/projectile/mandella.dmi'
	icon_state = "mandella"
	item_state = "mandella"
	w_class = ITEM_SIZE_NORMAL
	can_dual = TRUE
	silenced = TRUE

	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	matter = list(MATERIAL_PLASTEEL = 12, MATERIAL_PLASTIC = 6)
	price_tag = 1500
	caliber = CAL_CLRIFLE
	load_method = MAGAZINE
	mag_well = MAG_WELL_PISTOL
	magazine_type = /obj/item/ammo_magazine/cspistol
	damage_multiplier = 1.2
	penetration_multiplier = 1.7
	recoil_buildup = 2

	spawn_tags = SPAWN_TAG_FS_PROJECTILE


/obj/item/gun/projectile/mandella/on_update_icon()
	..()

	var/iconstring = initial(icon_state)

	if (ammo_magazine)
		iconstring += "_mag"

	if (!ammo_magazine || !length(ammo_magazine.stored_ammo))
		iconstring += "_slide"

	icon_state = iconstring

/obj/item/gun/projectile/mandella/Initialize()
	. = ..()
	update_icon()

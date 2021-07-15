/obj/item/gun/projectile/shotgun/bojevic
	name = "SA SG \"Bojevic\""
	desc = "Semi-auto, half polymer, all serbian. \
			It's magazine-fed shotgun designed for close quarters combat, nicknamed 'Striker' by boarding parties. \
			Robust and reliable design allows you to swap magazines on go and dump as many shells at your foes as you want... \
			if you could manage recoil, of course. Compatible only with special M12 8-round drum magazines."
	icon = 'icons/obj/guns/projectile/bojevic.dmi'
	icon_state = "bojevic"
	w_class = ITEM_SIZE_BULKY
	force = WEAPON_FORCE_PAINFUL
	slot_flags = SLOT_BACK
	caliber = CAL_SHOTGUN
	load_method = MAGAZINE
	mag_well = MAG_WELL_RIFLE
	magazine_type = /obj/item/ammo_magazine/m12
	matter = list(MATERIAL_PLASTEEL = 20, MATERIAL_PLASTIC = 10)
	price_tag = 4000
	fire_sound = 'sound/weapons/guns/fire/shotgunp_fire.ogg'
	unload_sound = 'sound/weapons/guns/interact/ltrifle_magout.ogg'
	reload_sound = 'sound/weapons/guns/interact/ltrifle_magin.ogg'
	cocked_sound = 'sound/weapons/guns/interact/ltrifle_cock.ogg'
	damage_multiplier = 0.8
	penetration_multiplier = 1.4 // this is not babies first gun. It's a Serb-level weapon.
	recoil_buildup = 7.4 // at least somewhat controllable
	one_hand_penalty = 20 //automatic shotgun level

					//while also preserving ability to shoot as fast as you can click and maintain recoil good enough
	init_firemodes = list(
		FULL_AUTO_400,
		SEMI_AUTO_NODELAY
		)

/obj/item/gun/projectile/shotgun/bojevic/on_update_icon()
	..()

	var/iconstring = initial(icon_state)
	var/itemstring = ""

	cut_overlays()
	icon_state = "[initial(icon_state)]"

	if(wielded)
		itemstring += "_doble"

	if(ammo_magazine)
		add_overlays("m12[ammo_magazine.ammo_color]")
		itemstring += "_mag"

	if(!ammo_magazine || !length(ammo_magazine.stored_ammo))
		add_overlays("slide")

	icon_state = iconstring
	set_item_state(itemstring)

/obj/item/gun/projectile/shotgun/bojevic/Initialize()
	. = ..()
	update_icon()

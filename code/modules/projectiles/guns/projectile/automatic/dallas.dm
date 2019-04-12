//It's a good day to die

/obj/item/weapon/gun/projectile/automatic/dallas
	name = "PAR 10mm x 24 \"Dallas\""
	desc = "Dallas is a pulse-action air-cooled automatic assault rifle made by unknown manufacturer. This weapon is very rare, but deadly efficient. \
		It's used by elite mercenaries, assassins or bald marines. Makes you feel like a space marine when you hold it."
	icon_state = "dallas"
	item_state = "dallas"
	w_class = ITEM_SIZE_LARGE
	force = WEAPON_FORCE_PAINFUL
	caliber = "10x24"
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1)
	load_method = MAGAZINE
	mag_well = MAG_WELL_CIVI_RIFLE
	magazine_type = /obj/item/ammo_magazine/c10x24
	matter = list(MATERIAL_PLASTEEL = 25, MATERIAL_PLASTIC = 15)
	price_tag = 4500
	fire_sound = 'sound/weapons/guns/fire/m41_shoot.ogg'
	unload_sound 	= 'sound/weapons/guns/interact/ltrifle_magout.ogg'
	reload_sound 	= 'sound/weapons/guns/interact/m41_reload.ogg'
	cocked_sound 	= 'sound/weapons/guns/interact/m41_cocked.ogg'

	firemodes = list(
		FULL_AUTO_400,
		SEMI_AUTO_NODELAY,
		list(mode_name="3-round bursts", burst=3, fire_delay=null, move_delay=3,    dispersion=list(0.0, 0.4, 0.6), icon="burst"),
		)

/obj/item/weapon/gun/projectile/automatic/dallas/update_icon()
	..()
	if(ammo_magazine)
		icon_state = "[initial(icon_state)]-full"
	else
		icon_state = initial(icon_state)
	return

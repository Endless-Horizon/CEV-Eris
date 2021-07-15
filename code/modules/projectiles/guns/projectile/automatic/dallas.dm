/obj/item/gun/projectile/automatic/dallas //it's a good way to die
	name = "PAR .25 CS \"Dallas\""
	desc = "Dallas is a pulse-action air-cooled automatic assault rifle made by unknown manufacturer. This weapon is very rare, but deadly efficient. \
			It's used by elite mercenaries, assassins or bald marines. Uses .25 Caseless rounds."
	icon = 'icons/obj/guns/projectile/dallas.dmi'
	icon_state = "dallas"
	item_state = "dallas"
	w_class = ITEM_SIZE_HUGE
	force = WEAPON_FORCE_PAINFUL
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1)
	caliber = CAL_CLRIFLE
	load_method = MAGAZINE
	mag_well = MAG_WELL_RIFLE
	magazine_type = /obj/item/ammo_magazine/c10x24
	auto_eject = 1
	matter = list(MATERIAL_PLASTEEL = 25, MATERIAL_PLASTIC = 15)
	price_tag = 5000 //99 rounds of pure pain and destruction served in auto-fire, so it basically an upgraded LMG
	fire_sound = 'sound/weapons/guns/fire/m41_shoot.ogg'
	unload_sound = 'sound/weapons/guns/interact/ltrifle_magout.ogg'
	reload_sound = 'sound/weapons/guns/interact/m41_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/m41_cocked.ogg'
	damage_multiplier = 1.35
	penetration_multiplier = 1
	recoil_buildup = 1.3
	one_hand_penalty = 10 //heavy, but very advanced, so bullpup rifle level despite not being bullpup
	rarity_value = 65
	gun_parts = list(/obj/item/part/gun = 5 ,/obj/item/stack/material/plasteel = 6)

	init_firemodes = list(
		FULL_AUTO_400,
		SEMI_AUTO_NODELAY,
		)

/obj/item/gun/projectile/automatic/dallas/on_update_icon()
	..()
	if(ammo_magazine)
		icon_state = "[initial(icon_state)]-full"
	else
		icon_state = initial(icon_state)
	return

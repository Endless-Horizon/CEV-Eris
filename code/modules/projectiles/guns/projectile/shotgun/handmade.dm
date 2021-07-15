/obj/item/gun/projectile/shotgun/slidebarrel
	name = "slide barrel shotgun"
	desc = "Made out of trash, but rather special on its design"
	icon = 'icons/obj/guns/projectile/slideshotgun.dmi'
	icon_state = "slideshotgun"
	item_state = "slideshotgun"
	max_shells = 1
	caliber = CAL_SHOTGUN
	load_method = SINGLE_CASING
	handle_casings = HOLD_CASINGS
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	can_dual = TRUE
	ammo_type = /obj/item/ammo_casing/shotgun
	matter = list(MATERIAL_STEEL = 20, MATERIAL_WOOD = 10)
	w_class = ITEM_SIZE_NORMAL
	force = WEAPON_FORCE_PAINFUL
	damage_multiplier = 0.7
	recoil_buildup = 20 //makin it a bit more than most shotguns
	one_hand_penalty = 5 //compact shotgun level, so same as sawn off
	price_tag = 250 //cheap as they get
	spawn_blacklisted = TRUE

/obj/item/gun/projectile/shotgun/slidebarrel/load_ammo(obj/item/A, mob/user)
	if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/C = A
		if((load_method & SINGLE_CASING) && caliber == C.caliber && loaded.len)
			var/turf/newloc = get_turf(src)
			playsound(user, 'sound/weapons/shotgunpump.ogg', 60, 1)
			if(chambered)//We have a shell in the chamber
				chambered.forceMove(newloc) //Eject casing
				chambered = null
			var/obj/item/ammo_casing/AC = loaded[1]
			loaded -= AC
			chambered = AC
	..()

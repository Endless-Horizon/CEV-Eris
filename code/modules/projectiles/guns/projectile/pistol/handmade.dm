/obj/item/gun/projectile/handmade_pistol
	name = "handmade pistol"
	desc = "Looks unreliable. May blow up in your hands. Due to a strange design, this one can be reload only after shot. Or with the use of a screwdriver."
	icon = 'icons/obj/guns/projectile/hm_pistol.dmi'
	icon_state = "hm_pistol"
	item_state = "pistol"
	caliber = CAL_MAGNUM
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	fire_sound = 'sound/weapons/guns/fire/pistol_fire.ogg'
	can_dual = TRUE
	load_method = SINGLE_CASING
	max_shells = 1
	matter = list(MATERIAL_STEEL = 5, MATERIAL_WOOD = 5)
	gun_parts = list(/obj/item/stack/material/steel = 2)
	ammo_type = /obj/item/ammo_casing/magnum
	damage_multiplier = 1.36
	recoil_buildup = 15
	spawn_frequency = 0
	var/chamber_open = FALSE
	var/jammed = FALSE
	var/jam_chance = 15

/obj/item/gun/projectile/handmade_pistol/New()
	..()
	open_chamber()

/obj/item/gun/projectile/handmade_pistol/special_check(mob/user)
	if(jammed)
		to_chat(user, SPAN_WARNING("[src] is jammed!"))
		return 0
	else
		if(loaded.len && prob(jam_chance)) //you know, when you try to shot and "aaaaawwwww fuk"
			jammed = TRUE
			playsound(src.loc, 'sound/weapons/guns/interact/hpistol_cock.ogg', 70, 1)
			to_chat(user, SPAN_DANGER("[src] is jammed!"))
			return 0
	return ..()

/obj/item/gun/projectile/handmade_pistol/attackby(obj/item/W, mob/user)
	if(!chamber_open)
		if(istype(W, /obj/item/tool/screwdriver) || istype(W, /obj/item/material/kitchen/utensil) || W.sharp)
			open_chamber()
			to_chat(user, SPAN_NOTICE("You force open chamber with [W]."))
	..()

/obj/item/gun/projectile/handmade_pistol/handle_post_fire(mob/user, atom/target, pointblank=0, reflex=0)
	..()
	open_chamber()

/obj/item/gun/projectile/handmade_pistol/load_ammo(var/obj/item/A, mob/user)
	if(istype(A, /obj/item/ammo_casing))
		if(!chamber_open)
			to_chat(user, SPAN_WARNING("You need to open chamber first."))
			return
		..()
		chamber_open = FALSE
		icon_state = "hm_pistol"
		playsound(src.loc, 'sound/weapons/guns/interact/batrifle_magin.ogg', 65, 1)

/obj/item/gun/projectile/handmade_pistol/unload_ammo(mob/user, allow_dump=1)
	return

/obj/item/gun/projectile/handmade_pistol/proc/open_chamber()
	src.jammed = FALSE
	src.chamber_open = TRUE
	icon_state = "hm_pistol_open"
	playsound(src.loc, 'sound/weapons/guns/interact/batrifle_magout.ogg', 65, 1)
	if(loaded.len)
		var/obj/item/ammo_casing/our_bullet = loaded[1]
		our_bullet.loc = get_turf(src)
		loaded -= our_bullet
		chambered = null

/obj/item/gun/projectile/heavysniper
	name = "SA AMR \"Hristov\""
	desc = "A portable anti-armour rifle, fitted with a night-vision scope, it was originally designed for use against armoured exosuits. It is capable of punching through windows and non-reinforced walls with ease, but suffers from overpenetration at close range. Fires armor piercing .60 shells. Can be upgraded using thermal glasses."
	icon = 'icons/obj/guns/projectile/heavysniper.dmi'
	icon_state = "heavysniper"
	item_state = "heavysniper"
	damage_multiplier = 0.9
	w_class = ITEM_SIZE_HUGE
	force = WEAPON_FORCE_PAINFUL
	slot_flags = SLOT_BACK
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2, TECH_COVERT = 2)
	caliber = CAL_ANTIM
	recoil_buildup = 75
	handle_casings = HOLD_CASINGS
	load_method = SINGLE_CASING
	max_shells = 1
	ammo_type = /obj/item/ammo_casing/antim
	fire_sound = 'sound/weapons/guns/fire/sniper_fire.ogg'
	reload_sound = 'sound/weapons/guns/interact/rifle_load.ogg'
	matter = list(MATERIAL_PLASTEEL = 40, MATERIAL_PLASTIC = 20)
	price_tag = 5000
	one_hand_penalty = 10
	zoom_factor = 2
	twohanded = TRUE
	darkness_view = 7
	see_invisible_gun = SEE_INVISIBLE_NOLIGHTING
	var/extra_damage_mult_scoped = 0.2
	gun_tags = list(GUN_AMR, GUN_SCOPE)
	rarity_value = 90
	no_internal_mag = TRUE
	var/bolt_open = 0
	var/item_suffix = ""

/obj/item/gun/projectile/heavysniper/on_update_icon()
	..()

	var/iconstring = initial(icon_state)
	var/itemstring = ""

	if (item_suffix)
		itemstring += "[item_suffix]"

	if (bolt_open)
		iconstring += "_open"
	else
		iconstring += "_closed"

	icon_state = iconstring
	set_item_state(itemstring)

/obj/item/gun/projectile/heavysniper/Initialize()
	. = ..()
	update_icon()

/obj/item/gun/projectile/heavysniper/attack_self(mob/user) //Someone overrode attackself for this class, soooo.
	if(zoom)
		toggle_scope(user)
		return
	bolt_act(user)

/obj/item/gun/projectile/heavysniper/proc/bolt_act(mob/living/user)
	playsound(src.loc, 'sound/weapons/guns/interact/rifle_boltback.ogg', 75, 1)
	bolt_open = !bolt_open
	if(bolt_open)
		if(chambered)
			to_chat(user, SPAN_NOTICE("You work the bolt open, ejecting [chambered]!"))
			chambered.loc = get_turf(src)
			loaded -= chambered
			chambered = null
		else
			to_chat(user, SPAN_NOTICE("You work the bolt open."))
	else
		to_chat(user, SPAN_NOTICE("You work the bolt closed."))
		playsound(src.loc, 'sound/weapons/guns/interact/rifle_boltforward.ogg', 75, 1)
		bolt_open = 0
	add_fingerprint(user)
	update_icon()

/obj/item/gun/projectile/heavysniper/special_check(mob/user)
	if(bolt_open)
		to_chat(user, SPAN_WARNING("You can't fire [src] while the bolt is open!"))
		return 0
	return ..()

/obj/item/gun/projectile/heavysniper/load_ammo(var/obj/item/A, mob/user)
	if(!bolt_open)
		return
	..()

/obj/item/gun/projectile/heavysniper/unload_ammo(mob/user, var/allow_dump=1)
	if(!bolt_open)
		return
	..()

/obj/item/weaponparts
	name = "weaponpart"
	desc = "how did you get it?"
	icon = 'icons/obj/weaponparts.dmi'
	bad_type = /obj/item/weaponparts
	var/part_color = ""

/obj/item/weaponparts/heavysniper
	bad_type = /obj/item/weaponparts/heavysniper

/obj/item/weaponparts/heavysniper/stock
	name = "sniper stock"
	desc = "This is a sniper stock. You need to attach the reciever."
	icon_state = "sniper_stock"

/obj/item/weaponparts/heavysniper/reciever
	name = "sniper reciever"
	desc = "This is a sniper reciever. You need to attach it to the stock."
	icon_state = "sniper_reciever"

/obj/item/weaponparts/heavysniper/stockreciever
	name = "sniper stock with reciever"
	desc = "This is a sniper stock with reciever. Now attach the barrel."
	icon_state = "sniper_stockreciever"

/obj/item/weaponparts/heavysniper/barrel
	name = "sniper rifle barrel"
	desc = "This is a barrel from a sniper rifle."
	icon_state = "sniper_barrel"

/obj/item/weaponparts/heavysniper/stock/attackby(obj/item/W, mob/user,)
	if(istype(W,/obj/item/weaponparts/heavysniper/reciever))
		to_chat(user, "You attach the reciever to the stock")
		var/obj/item/weaponparts/heavysniper/stockreciever/HS = new (get_turf(src))
		if(loc == user)
			equip_slot = user.get_inventory_slot(src)
			if(equip_slot in list(slot_r_hand, slot_l_hand))
				user.drop_from_inventory(src)
				user.equip_to_slot_if_possible(HS, equip_slot)
		qdel(W)
		qdel(src)


/obj/item/weaponparts/heavysniper/stockreciever/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/weaponparts/heavysniper/barrel))
		to_chat(user, "You attach the barrel to the stock")
		var/obj/item/gun/projectile/heavysniper/HS = new (get_turf(src))
		if(loc == user)
			equip_slot = user.get_inventory_slot(src)
			if(equip_slot in list(slot_r_hand, slot_l_hand))
				user.drop_from_inventory(src)
				user.equip_to_slot_if_possible(HS, equip_slot)
		qdel(W)
		qdel(src)

/obj/item/gun/projectile/heavysniper/zoom(tileoffset, viewsize)
	..()
	if(zoom)
		damage_multiplier += extra_damage_mult_scoped
	else
		refresh_upgrades()

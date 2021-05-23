/obj/item/weapon/gun/projectile/boltgun
	name = "Excelsior BR .30 \"Kardashev-Mosin\""
	desc = "Weapon for hunting, or endless trench warfare. \
			If you’re on a budget, it’s a darn good rifle for just about everything."
	icon = 'icons/obj/guns/projectile/boltgun.dmi'
	icon_state = "boltgun"
	item_state = "boltgun"
	w_class = ITEM_SIZE_HUGE
	force = WEAPON_FORCE_ROBUST
	armor_penetration = ARMOR_PEN_DEEP
	slot_flags = SLOT_BACK
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	caliber = CAL_LRIFLE
	fire_delay = 12 // double the standart
	damage_multiplier = 1.4
	penetration_multiplier = 1.5
	recoil_buildup = 40 //same as AMR
	handle_casings = HOLD_CASINGS
	load_method = SINGLE_CASING|SPEEDLOADER
	max_shells = 10
	magazine_type = /obj/item/ammo_magazine/lrifle
	fire_sound = 'sound/weapons/guns/fire/sniper_fire.ogg'
	reload_sound = 'sound/weapons/guns/interact/rifle_load.ogg'
	matter = list(MATERIAL_STEEL = 20, MATERIAL_PLASTIC = 10)
	price_tag = 1000
	one_hand_penalty = 20 //full sized rifle with bayonet is hard to keep on target
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut") // Considering attached bayonet
	sharp = TRUE
	spawn_blacklisted = TRUE
	gun_parts = list(/obj/item/stack/material/steel = 16)
	var/bolt_open = 0
	var/item_suffix = ""

/obj/item/weapon/gun/projectile/boltgun/on_update_icon()
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

/obj/item/weapon/gun/projectile/boltgun/Initialize()
	. = ..()
	update_icon()

/obj/item/weapon/gun/projectile/boltgun/attack_self(mob/user) //Someone overrode attackself for this class, soooo.
	if(zoom)
		toggle_scope(user)
		return
	bolt_act(user)

/obj/item/weapon/gun/projectile/boltgun/proc/bolt_act(mob/living/user)
	playsound(src.loc, 'sound/weapons/guns/interact/rifle_boltback.ogg', 75, 1)
	bolt_open = !bolt_open
	if(bolt_open)
		if(chambered)
			to_chat(user, SPAN_NOTICE("You work the bolt open, ejecting [chambered]!"))
			chambered.forceMove(get_turf(src))
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

/obj/item/weapon/gun/projectile/boltgun/special_check(mob/user)
	if(bolt_open)
		to_chat(user, SPAN_WARNING("You can't fire [src] while the bolt is open!"))
		return 0
	return ..()

/obj/item/weapon/gun/projectile/boltgun/load_ammo(var/obj/item/A, mob/user)
	if(!bolt_open)
		return
	..()

/obj/item/weapon/gun/projectile/boltgun/unload_ammo(mob/user, var/allow_dump=1)
	if(!bolt_open)
		return
	..()

/obj/item/weapon/gun/projectile/boltgun/serbian
	name = "SA BR .30 \"Novakovic\""
	desc = "Weapon for hunting, or endless trench warfare. \
			If you’re on a budget, it’s a darn good rifle for just about everything. \
			This copy, in fact, is a reverse-engineered poor-quality copy of a more perfect copy of an ancient rifle"
	icon_state = "boltgun_wood"
	item_suffix  = "_wood"
	force = 23
	recoil_buildup = 0.4 // Double the excel variant
	matter = list(MATERIAL_STEEL = 20, MATERIAL_WOOD = 10)
	wielded_item_state = "_doble_wood"
	spawn_blacklisted = FALSE
	gun_parts = list(/obj/item/stack/material/steel = 16)

/obj/item/weapon/gun/projectile/boltgun/handmade
	name = "handmade bolt action rifle"
	desc = "A handmade bolt action rifle, made from junk. and some spare parts."
	icon_state = "boltgun_hand"
	item_suffix = "_hand"
	matter = list(MATERIAL_STEEL = 10, MATERIAL_PLASTIC = 5)
	wielded_item_state = "_doble_hand"
	w_class = ITEM_SIZE_HUGE
	slot_flags = SLOT_BACK
	fire_delay = 17 // abit more than the serbian one
	damage_multiplier = 1
	penetration_multiplier = 1
	recoil_buildup = 40 //same as AMR
	max_shells = 5
	fire_sound = 'sound/weapons/guns/fire/sniper_fire.ogg'
	reload_sound = 'sound/weapons/guns/interact/rifle_load.ogg'
	price_tag = 800
	one_hand_penalty = 30 //don't you dare to one hand this
	sharp = FALSE //no bayonet here
	spawn_blacklisted = TRUE

//obrez time

/obj/item/weapon/gun/projectile/boltgun/obrez
    name = "sawn-off Excelsior BR .30 \"Kardashev-Mosin\""
    desc = "Weapon for hunting, or endless trench warfare. \
         This one has been sawed down into an \"Obrez\" style."
    icon = 'icons/obj/guns/projectile/obrez.dmi'
    icon_state = "obrez"
    item_state = "obrez"
    w_class = ITEM_SIZE_NORMAL
    force = WEAPON_FORCE_PAINFUL
    slot_flags = SLOT_BELT|SLOT_HOLSTER
    damage_multiplier = 1.1
    penetration_multiplier = 1
    recoil_buildup = 4
    matter = list(MATERIAL_STEEL = 15, MATERIAL_PLASTIC = 5)
    price_tag = 600
    attack_verb = list("struck","hit","bashed")
    one_hand_penalty = 15 //not a full rifle, but not easy either
    sharp = FALSE

/obj/item/weapon/gun/projectile/boltgun/obrez/serbian
	name = "sawn-off SA BR .30 \"Novakovic\""
	desc = "Weapon for hunting, or endless trench warfare. \
         This one has been sawed down into an \"Obrez\" style."
	icon = 'icons/obj/guns/projectile/obrez.dmi'
	icon_state = "obrez_wood"
	item_suffix  = "_wood"
	recoil_buildup = 6
	wielded_item_state = "_doble_wood"

/obj/item/weapon/gun/projectile/boltgun/attackby(var/obj/item/A as obj, mob/user as mob)
	if(QUALITY_SAWING in A.tool_qualities)
		if (!istype(src, /obj/item/weapon/gun/projectile/boltgun/obrez))
			if(!istype(src, /obj/item/weapon/gun/projectile/boltgun/handmade))
				if (src.item_upgrades.len)
					if("No" == input(user, "There are attachments present. Would you like to destroy them?") in list("Yes", "No"))
						return
				to_chat(user, SPAN_NOTICE("You begin to saw down \the [src]."))
				if(loaded.len)
					for(var/i in 1 to max_shells)
						afterattack(user, user)	//will this work? //it will. we call it twice, for twice the FUN
						playsound(user, fire_sound, 50, 1)
					user.visible_message(SPAN_DANGER("The rifle goes off!"), SPAN_DANGER("The rifle goes off in your face!"))
					return
				if(A.use_tool(user, src, WORKTIME_FAST, QUALITY_SAWING, FAILCHANCE_NORMAL, required_stat = STAT_COG))
					if(istype(src, /obj/item/weapon/gun/projectile/boltgun/serbian))
						qdel(src)
						new /obj/item/weapon/gun/projectile/boltgun/obrez/serbian(usr.loc)
						return
					else
						new /obj/item/weapon/gun/projectile/boltgun/obrez(usr.loc)
					qdel(src)
					to_chat(user, SPAN_WARNING("You saw down \the [src]!"))
			else
				to_chat(user, SPAN_WARNING("You can't remove more if you want \the [src] to keep working!"))	
		else
			to_chat(user, SPAN_WARNING("You cannot saw down \the [src] any further!"))
	else
		..()

/obj/item/gun/projectile/shotgun/doublebarrel
	name = "double-barreled shotgun"
	desc = "An immortal classic."
	icon = 'icons/obj/guns/projectile/dshotgun.dmi'
	icon_state = "dshotgun"
	item_state = "dshotgun"
	//SPEEDLOADER because rapid unloading.
	//In principle someone could make a speedloader for it, so it makes sense.
	load_method = SINGLE_CASING|SPEEDLOADER
	handle_casings = CYCLE_CASINGS
	max_shells = 2
	w_class = ITEM_SIZE_HUGE
	force = WEAPON_FORCE_PAINFUL
	flags = CONDUCT
	slot_flags = SLOT_BACK
	caliber = CAL_SHOTGUN
	recoil_buildup = 7
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 1)
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	bulletinsert_sound = 'sound/weapons/guns/interact/shotgun_insert.ogg'
	fire_sound = 'sound/weapons/guns/fire/shotgunp_fire.ogg'
	matter = list(MATERIAL_PLASTEEL = 20, MATERIAL_WOOD = 10)
	price_tag = 1200
	one_hand_penalty = 15 //full sized shotgun level
	var/bolt_open = 0
	burst_delay = 0
	no_internal_mag = TRUE
	init_firemodes = list(
		list(mode_name="Single-fire", mode_desc="Send Vagabonds flying back several paces", burst=1, icon="semi"),
		list(mode_name="Both Barrels", mode_desc="Give them the side-by-side", burst=2, icon="burst"),
		)

/obj/item/gun/projectile/shotgun/doublebarrel/pellet
	ammo_type = /obj/item/ammo_casing/shotgun/pellet

/obj/item/gun/projectile/shotgun/doublebarrel/flare
	name = "signal shotgun"
	desc = "A double-barreled shotgun meant to fire signal flash shells."
	ammo_type = /obj/item/ammo_casing/shotgun/flash

/obj/item/gun/projectile/shotgun/doublebarrel/on_update_icon()
	..()

	var/iconstring = initial(icon_state)

	if (bolt_open)
		iconstring += "_open"

	icon_state = iconstring

/obj/item/gun/projectile/shotgun/doublebarrel/attack_self(mob/user) //Someone overrode attackself for this class, soooo.
	if(zoom)
		toggle_scope(user)
		return
	bolt_act(user)

/obj/item/gun/projectile/shotgun/doublebarrel/proc/bolt_act(mob/living/user)
	bolt_open = !bolt_open
	if(bolt_open)
		playsound(src.loc, 'sound/weapons/guns/interact/shotgun_break.ogg', 75, 1)
		to_chat(user, SPAN_NOTICE("You snap the barrel open."))
		unload_ammo(user, allow_dump=1)
	else
		playsound(src.loc, 'sound/weapons/guns/interact/shotgun_close.ogg', 75, 1)
		to_chat(user, SPAN_NOTICE("You snap the barrel closed"))
		bolt_open = 0
	add_fingerprint(user)
	update_icon()

/obj/item/gun/projectile/shotgun/doublebarrel/special_check(mob/user)
	if(bolt_open)
		to_chat(user, SPAN_WARNING("You can't fire [src] while the barrel is open!"))
		return 0
	return ..()

/obj/item/gun/projectile/shotgun/doublebarrel/load_ammo(var/obj/item/A, mob/user)
	if(!bolt_open)
		to_chat(user, SPAN_WARNING("You can't load [src] while the barrel is closed!"))
		return
	..()

/obj/item/gun/projectile/shotgun/doublebarrel/unload_ammo(mob/user, var/allow_dump=1)
	if(!bolt_open)
		return
	..()

/obj/item/gun/projectile/shotgun/doublebarrel/attackby(var/obj/item/A as obj, mob/user as mob)
	if(QUALITY_SAWING in A.tool_qualities)
		if (!istype(src, /obj/item/gun/projectile/shotgun/doublebarrel/sawn))
			if (src.item_upgrades.len)
				if("No" == input(user, "There are attachments present. Would you like to destroy them?") in list("Yes", "No"))
					return
			to_chat(user, SPAN_NOTICE("You begin to shorten the barrel of \the [src]."))
			if(loaded.len)
				for(var/i in 1 to max_shells)
					afterattack(user, user)	//will this work? //it will. we call it twice, for twice the FUN
					playsound(user, fire_sound, 50, 1)
				user.visible_message(SPAN_DANGER("The shotgun goes off!"), SPAN_DANGER("The shotgun goes off in your face!"))
				return
			if(A.use_tool(user, src, WORKTIME_FAST, QUALITY_SAWING, FAILCHANCE_NORMAL, required_stat = STAT_COG))
				qdel(src)
				new /obj/item/gun/projectile/shotgun/doublebarrel/sawn(usr.loc)
				to_chat(user, SPAN_WARNING("You shorten the barrel of \the [src]!"))
		else
			to_chat(user, SPAN_WARNING("You cannot shorten \the [src] any further!"))
	else
		..()

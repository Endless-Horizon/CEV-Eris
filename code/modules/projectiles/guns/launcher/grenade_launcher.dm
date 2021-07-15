/obj/item/gun/launcher/grenade
	name = "NT GL \"Protector\""
	desc = "A bulky pump-action grenade launcher. Holds up to 6 grenades in a revolving magazine."
	icon = 'icons/obj/guns/launcher/riotgun.dmi'
	icon_state = "riotgun"
	item_state = "riotgun"
	w_class = ITEM_SIZE_BULKY
	force = WEAPON_FORCE_PAINFUL
	matter = list(MATERIAL_PLASTEEL = 30, MATERIAL_WOOD = 10)

	fire_sound = 'sound/weapons/empty.ogg'
	fire_sound_text = "a metallic thunk"
	recoil_buildup = 0
	throw_distance = 7
	release_force = 5

	zoom_factor = 2
	twohanded = TRUE
	var/obj/item/grenade/chambered
	var/list/grenades = new/list()
	var/max_grenades = 5 //holds this + one in the chamber

//revolves the magazine, allowing players to choose between multiple grenade types
/obj/item/gun/launcher/grenade/proc/pump(mob/user)
	playsound(user, 'sound/weapons/shotgunpump.ogg', 60, 1)

	var/obj/item/grenade/next
	if(grenades.len)
		next = grenades[1] //get this first, so that the chambered grenade can still be removed if the grenades list is empty
	if(chambered)
		grenades += chambered //rotate the revolving magazine
		chambered = null
	if(next)
		grenades -= next //Remove grenade from loaded list.
		chambered = next
		to_chat(user, SPAN_WARNING("Mechanism pumps [src], loading \a [next] into the chamber."))
	else
		to_chat(user, SPAN_WARNING("Mechanism pumps [src], but the magazine is empty."))
	update_icon()

/obj/item/gun/launcher/grenade/examine(mob/user)
	if(..(user, 2))
		var/grenade_count = grenades.len + (chambered? 1 : 0)
		to_chat(user, "Has [grenade_count] grenade\s remaining.")
		if(chambered)
			to_chat(user, "\A [chambered] is chambered.")

/obj/item/gun/launcher/grenade/proc/load(obj/item/grenade/G, mob/user)
	if(!G.loadable)
		to_chat(user, SPAN_WARNING("\The [G] doesn't seem to fit in \the [src]!"))
		return
	if(!chek_grenades(user))
		return
	user.remove_from_mob(G)
	G.forceMove(src)
	grenades.Insert(1, G) //add to the head of the list, so that it is loaded on the next pump
	user.visible_message("\The [user] inserts \a [G] into \the [src].", SPAN_NOTICE("You insert \a [G] into \the [src]."))
	pump(user)
	update_icon()

/obj/item/gun/launcher/grenade/proc/chek_grenades(mob/user)
	. = TRUE
	if(grenades.len >= max_grenades)
		to_chat(user, SPAN_WARNING("\The [src] is full."))
		return FALSE

/obj/item/gun/launcher/grenade/proc/unload(mob/user)
	if(grenades.len)
		var/obj/item/grenade/G = grenades[grenades.len]
		grenades.len--
		user.put_in_hands(G)
		user.visible_message("\The [user] removes \a [G] from [src].", SPAN_NOTICE("You remove \a [G] from \the [src]."))
	else
		to_chat(user, SPAN_WARNING("\The [src] is empty."))
	update_icon()

/obj/item/gun/launcher/grenade/attack_self(mob/user)
	pump(user)

/obj/item/gun/launcher/grenade/attackby(obj/item/I, mob/user)
	if((istype(I, /obj/item/grenade)))
		load(I, user)
	else
		..()

/obj/item/gun/launcher/grenade/attack_hand(mob/user)
	if(user.get_inactive_hand() == src)
		unload(user)
	else
		..()

/obj/item/gun/launcher/grenade/consume_next_projectile()
	if(chambered)
		chambered.det_time = 10
		chambered.activate(null)
	return chambered

/obj/item/gun/launcher/grenade/handle_post_fire(mob/user)
	log_and_message_admins("fired a grenade ([chambered.name]) from a grenade launcher ([src.name]).")
	user.attack_log += "\[[time_stamp()]\] <font color='red'> fired a grenade ([chambered.name]) from a grenade launcher ([src.name])</font>"
	chambered = null
	pump(user)

//Underslung grenade launcher to be used with the Z8
/obj/item/gun/launcher/grenade/underslung
	name = "underslung grenade launcher"
	desc = "Not much more than a tube and a firing mechanism, this grenade launcher is designed to be fitted to a rifle."
	w_class = ITEM_SIZE_NORMAL
	matter = null
	force = 5
	max_grenades = 0
	safety = FALSE
	twohanded = FALSE

/obj/item/gun/launcher/grenade/underslung/attack_self()
	return

//load and unload directly into chambered
/obj/item/gun/launcher/grenade/underslung/load(obj/item/grenade/G, mob/user)
	if(!G.loadable)
		to_chat(user, SPAN_WARNING("[G] doesn't seem to fit in the [src]!"))
		return

	if(chambered)
		to_chat(user, SPAN_WARNING("\The [src] is already loaded."))
		return
	user.remove_from_mob(G)
	G.forceMove(src)
	chambered = G
	user.visible_message("\The [user] load \a [G] into \the [src].", SPAN_NOTICE("You load \a [G] into \the [src]."))

/obj/item/gun/launcher/grenade/underslung/unload(mob/user)
	if(chambered)
		user.put_in_hands(chambered)
		user.visible_message("\The [user] removes \a [chambered] from \the[src].", SPAN_NOTICE("You remove \a [chambered] from \the [src]."))
		chambered = null
	else
		to_chat(user, SPAN_WARNING("\The [src] is empty."))

/* Ironhammer stuff */

/obj/item/gun/launcher/grenade/lenar
	name = "FS GL \"Lenar\""
	desc = "A more than bulky pump-action grenade launcher. Holds up to 6 grenades in a revolving magazine."
	icon = 'icons/obj/guns/launcher/grenadelauncher.dmi'
	icon_state = "Grenadelauncher_PMC"
	item_state = "pneumatic"
	w_class = ITEM_SIZE_HUGE
	slot_flags = SLOT_BACK
	matter = list(MATERIAL_PLASTEEL = 30, MATERIAL_PLASTIC = 10)
	fire_sound = 'sound/weapons/empty.ogg'
	fire_sound_text = "a metallic thunk"
	throw_distance = 10
	release_force = 5

/obj/item/gun/launcher/grenade/lenar/proc/update_charge()
	var/ratio = (grenades.len + (chambered? 1 : 0)) / (max_grenades + 1)
	if(ratio < 0.33 && ratio != 0)
		ratio = 0.33
	ratio = round(ratio, 0.33) * 100
	add_overlays("grenademag_[ratio]")

/obj/item/gun/launcher/grenade/lenar/on_update_icon()
	cut_overlays()
	update_charge()

/obj/item/gun/launcher/grenade/makeshift
	name = "makeshift grenade launcher"
	desc = "Your own, homemade, China Lake."
	icon = 'icons/obj/guns/launcher/makeshift.dmi'
	icon_state = "makeshift"
	item_state = "makeshift"
	w_class = ITEM_SIZE_BULKY
	force = WEAPON_FORCE_PAINFUL
	matter = list(MATERIAL_STEEL = 20, MATERIAL_WOOD = 10)
	force = 5
	price_tag = 500
	max_grenades = 0

/obj/item/gun/launcher/grenade/makeshift/chek_grenades(mob/user)
	. = TRUE
	if(grenades.len > max_grenades)
		to_chat(user, SPAN_WARNING("\The [src] is full."))
		return FALSE

/obj/item/holyvacuum
	desc = "An advanced vacuum cleaner designed by NeoTheology that compresses trash into reusable biomatter bricks. It looks more like a ghost-busting gun than an actual vacuum cleaner. There is no safety switch."
	name = "\"Tersus\" vacuum cleaner"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "vacuum"
	force = WEAPON_FORCE_WEAK
	throwforce = WEAPON_FORCE_WEAK
	throw_speed = 5
	throw_range = 3
	w_class = ITEM_SIZE_BULKY
	attack_verb = list("bashed", "bludgeoned", "whacked")
	matter = list(MATERIAL_PLASTIC = 5, MATERIAL_STEEL = 10, MATERIAL_BIOMATTER = 5)
	spawn_tags = SPAWN_TAG_ITEM_UTILITY
	rarity_value = 100
	spawn_blacklisted = TRUE
	price_tag = 300

	var/amount = 0
	var/max_amount = 30
	var/vacuum_time = 3

/obj/item/holyvacuum/Initialize()
	.=..()
	create_reagents(10)
	refill()
	update_icon()

/obj/item/holyvacuum/examine(mob/user)
	..()
	to_chat(user, "\The [src]'s tank contains [amount] units of compressed filth.")

/obj/item/holyvacuum/on_update_icon()
	.=..()
	cut_overlays()
	if(amount == 0)
		add_overlays("0")
	else if(amount < 0.25*max_amount)
		add_overlays("1")
	else if(amount < 0.5*max_amount)
		add_overlays("2")
	else if(amount < 0.75*max_amount)
		add_overlays("3")
	else if(amount < max_amount)
		add_overlays("4")
	else if(amount == max_amount)
		add_overlays("5")

/obj/item/holyvacuum/proc/refill()
	reagents.add_reagent("cleaner", 10)  // Need to have cleaner in it for /turf/proc/clean

/obj/item/holyvacuum/attack_self(var/mob/user)
	.=..()
	if(amount==0)
		to_chat(user, SPAN_NOTICE("The storage tank of the [src] is already empty."))
	else
		empty(user)

/obj/item/holyvacuum/proc/empty(var/mob/user)
	var/obj/item/compressedfilth/CF = new(user.loc)  // Drop the content of the vacuum cleaner on the ground
	CF.matter[MATERIAL_BIOMATTER] = amount
	amount = 0
	to_chat(user, SPAN_NOTICE("You empty the storage tank of the [src]."))
	update_icon()

/obj/item/holyvacuum/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return
	if(istype(A, /turf) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay))
		if(amount >= max_amount)
			to_chat(user, SPAN_NOTICE("The storage tank of the [src] is full!"))
			return
		var/turf/T = get_turf(A)
		if(!T)
			return
		spawn()
			user.do_attack_animation(T)
		user.setClickCooldown(vacuum_time)
		playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
		if(do_after(user, vacuum_time, T))
			if(T)
				amount += 0.1 * T.clean(src, user)  // Fill the vacuum cleaner with the cleaned filth
			to_chat(user, SPAN_NOTICE("You have vacuumed all the filth!"))
			refill()
			update_icon()

/obj/item/compressedfilth
	desc = "A small block of compressed filth. Gross!"
	name = "compressed filth"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "filth-biomatter"
	force = WEAPON_FORCE_HARMLESS
	throwforce = WEAPON_FORCE_HARMLESS
	throw_speed = 5
	throw_range = 6
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("bashed", "bludgeoned", "whacked")
	matter = list(MATERIAL_BIOMATTER=0)
	spawn_tags = SPAWN_TAG_ITEM_UTILITY
	rarity_value = 100
	spawn_blacklisted = TRUE
	price_tag = 0

	var/amount = 0
	var/max_amount = 0
	var/vacuum_time = 3

/obj/item/glass_jar
	name = "glass jar"
	desc = "A small empty jar."
	icon = 'icons/obj/items.dmi'
	icon_state = "jar"
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_GLASS = 3)
	flags = NOBLUDGEON
	var/list/accept_mobs = list(/mob/living/simple_animal/lizard, /mob/living/simple_animal/mouse)
	var/contains = 0 // 0 = nothing, 1 = money, 2 = animal, 3 = spiderling

/obj/item/glass_jar/New()
	..()
	update_icon()

/obj/item/glass_jar/afterattack(var/atom/A, var/mob/user, var/proximity)
	if(!proximity || contains)
		return
	if(ismob(A))
		var/accept = 0
		for(var/D in accept_mobs)
			if(istype(A, D))
				accept = 1
		if(!accept)
			to_chat(user, "[A] doesn't fit into \the [src].")
			return
		var/mob/L = A
		user.visible_message(SPAN_NOTICE("[user] scoops [L] into \the [src]."), SPAN_NOTICE("You scoop [L] into \the [src]."))
		L.forceMove(src)
		contains = 2
		update_icon()
		return
	else if(istype(A, /obj/effect/spider/spiderling))
		var/obj/effect/spider/spiderling/S = A
		user.visible_message(SPAN_NOTICE("[user] scoops [S] into \the [src]."), SPAN_NOTICE("You scoop [S] into \the [src]."))
		S.forceMove(src)
		STOP_PROCESSING(SSobj, S) // No growing inside jars
		contains = 3
		update_icon()
		return

/obj/item/glass_jar/attack_self(var/mob/user)
	switch(contains)
		if(1)
			for(var/obj/O in src)
				O.loc = user.loc
			to_chat(user, SPAN_NOTICE("You take money out of \the [src]."))
			contains = 0
			update_icon()
			return
		if(2)
			for(var/mob/M in src)
				M.loc = user.loc
				user.visible_message(
					SPAN_NOTICE("[user] releases [M] from \the [src]."),
					SPAN_NOTICE("You release [M] from \the [src].")
				)
			contains = 0
			update_icon()
			return
		if(3)
			for(var/obj/effect/spider/spiderling/S in src)
				S.loc = user.loc
				user.visible_message(
					SPAN_NOTICE("[user] releases [S] from \the [src]."),
					SPAN_NOTICE("You release [S] from \the [src].")
				)
				START_PROCESSING(SSobj, S) // They can grow after being let out though
			contains = 0
			update_icon()
			return

/obj/item/glass_jar/attackby(var/obj/item/W, var/mob/user)
	if(istype(W, /obj/item/spacecash))
		if(contains == 0)
			contains = 1
		if(contains != 1)
			return
		user.visible_message(SPAN_NOTICE("[user] puts [W] into \the [src]."))
		user.drop_from_inventory(W)
		W.forceMove(src)
		update_icon()

/obj/item/glass_jar/on_update_icon() // Also updates name and desc
	underlays.Cut()
	cut_overlays()
	switch(contains)
		if(0)
			name = initial(name)
			desc = initial(desc)
		if(1)
			name = "tip jar"
			desc = "A small jar with money inside."
			for(var/obj/item/spacecash/S in src)
				var/image/money = image(S.icon, S.icon_state)
				money.pixel_x = rand(-2, 3)
				money.pixel_y = rand(-6, 6)
				money.transform *= 0.6
				underlays += money
		if(2)
			for(var/mob/M in src)
				var/image/victim = image(M.icon, M.icon_state)
				victim.pixel_y = 6
				underlays += victim
				name = "glass jar with [M]"
				desc = "A small jar with [M] inside."
		if(3)
			for(var/obj/effect/spider/spiderling/S in src)
				var/image/victim = image(S.icon, S.icon_state)
				underlays += victim
				name = "glass jar with [S]"
				desc = "A small jar with [S] inside."
	return

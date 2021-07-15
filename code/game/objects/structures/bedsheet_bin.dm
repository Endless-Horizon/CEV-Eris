/*
CONTAINS:
BEDSHEETS
LINEN BINS
*/

/obj/item/bedsheet
	name = "bedsheet"
	desc = "A surprisingly soft linen bedsheet."
	icon = 'icons/obj/bedsheets.dmi'
	icon_state = "sheet"
	item_state = "bedsheet"
	layer = 4
	throwforce = WEAPON_FORCE_HARMLESS
	throw_speed = 1
	throw_range = 2
	w_class = ITEM_SIZE_NORMAL
	var/rolled = FALSE
	var/folded = FALSE
	var/inuse = FALSE

/obj/item/bedsheet/Initialize(mapload, nfolded=FALSE)
	.=..()
	folded = nfolded
	update_icon()

/obj/item/bedsheet/afterattack(atom/A, mob/user)
	if(!user || user.incapacitated() || !user.Adjacent(A) || istype(A, /obj/structure/bedsheetbin) || istype(A, /obj/item/storage/))
		return
	if(toggle_fold(user))
		user.drop_item()
		forceMove(get_turf(A))
		add_fingerprint(user)
		return

/obj/item/bedsheet/proc/toggle_roll(mob/living/user, no_message = FALSE)
	if(!user)
		return FALSE
	if(inuse)
		to_chat(user, "Someone already using \the [src]")
		return FALSE
	inuse = TRUE
	if (do_after(user, 6, src, incapacitation_flags = INCAPACITATION_UNCONSCIOUS))
		if(user.loc != loc)
			user.do_attack_animation(src)
		playsound(get_turf(loc), "rustle", 15, 1, -5)
		if(!no_message)
			user.visible_message(
				SPAN_NOTICE("\The [user] [rolled ? "unrolled" : "rolled"] \the [src]."),
				SPAN_NOTICE("You [rolled ? "unrolled" : "rolled"] \the [src].")
			)
		if(!rolled)
			rolled = TRUE
		else
			rolled = FALSE
			if(!user.resting && get_turf(src) == get_turf(user))
				user.lay_down()
		inuse = FALSE
		update_icon()
		return TRUE
	inuse = FALSE
	return FALSE

/obj/item/bedsheet/proc/toggle_fold(mob/user, no_message=FALSE)
	if(!user)
		return FALSE
	if(inuse)
		to_chat(user, "Someone already using \the [src]")
		return FALSE
	inuse = TRUE
	if (do_after(user, 25, src))
		rolled = FALSE
		if(user.loc != loc)
			user.do_attack_animation(src)
		playsound(get_turf(loc), "rustle", 15, 1, -5)
		if(!no_message)
			user.visible_message(
				SPAN_NOTICE("\The [user] [folded ? "unfolded" : "folded"] \the [src]."),
				SPAN_NOTICE("You [folded ? "unfolded" : "folded"] \the [src].")
			)
		if(!folded)
			folded = TRUE
			w_class = ITEM_SIZE_SMALL
		else

			folded = FALSE
			w_class =ITEM_SIZE_NORMAL
		inuse = FALSE
		update_icon()
		return TRUE
	inuse = FALSE
	return FALSE

/obj/item/bedsheet/verb/fold_verb()
	set name = "Fold bedsheet"
	set category = "Object"
	set src in view(1)

	if(ismob(loc))
		to_chat(usr, "Drop \the [src] first.")
	else if(ishuman(usr))
		toggle_fold(usr)

/obj/item/bedsheet/verb/roll_verb()
	set name = "Roll bedsheet"
	set category = "Object"
	set src in view(1)

	if(folded)
		to_chat(usr, "Unfold \the [src] first.")
	else if(ismob(loc))
		to_chat(usr, "Drop \the [src] first.")
	else if(ishuman(usr))
		toggle_roll(usr)

/obj/item/bedsheet/attackby(obj/item/I, mob/user)
	if(is_sharp(I))
		user.visible_message(
			SPAN_NOTICE("\The [user] begins cutting up \the [src] with \a [I]."),
			SPAN_NOTICE("You begin cutting up \the [src] with \the [I].")
		)
		if(do_after(user, 50, src))
			to_chat(user, SPAN_NOTICE("You cut \the [src] into pieces!"))
			for(var/i in 1 to rand(2,5))
				new /obj/item/reagent_containers/glass/rag(get_turf(src))
			qdel(src)
		return
	..()

/obj/item/bedsheet/attack_hand(mob/user)
	if(!user || user.incapacitated(INCAPACITATION_UNCONSCIOUS))
		return
	if(!folded)
		toggle_roll(user)
	else
		.=..()
	add_fingerprint(user)

/obj/item/bedsheet/MouseDrop(over_object, src_location, over_location)
	..()
	if(over_object == usr || istype(over_object, /obj/screen/inventory/hand))
		if(!ishuman(over_object))
			return
		if(!folded)
			toggle_fold(usr)
		if(folded)
			pickup(usr)

/obj/item/bedsheet/on_update_icon()
	if (folded)
		icon_state = "sheet-folded"
	else if (rolled)
		icon_state = "sheet-rolled"
	else
		icon_state = initial(icon_state)

/obj/item/bedsheet/blue
	icon_state = "sheetblue"

/obj/item/bedsheet/green
	icon_state = "sheetgreen"

/obj/item/bedsheet/orange
	icon_state = "sheetorange"

/obj/item/bedsheet/purple
	icon_state = "sheetpurple"

/obj/item/bedsheet/rainbow
	icon_state = "sheetrainbow"

/obj/item/bedsheet/red
	icon_state = "sheetred"

/obj/item/bedsheet/yellow
	icon_state = "sheetyellow"

/obj/item/bedsheet/mime
	icon_state = "sheetmime"

/obj/item/bedsheet/clown
	icon_state = "sheetclown"

/obj/item/bedsheet/captain
	icon_state = "sheetcaptain"

/obj/item/bedsheet/rd
	icon_state = "sheetrd"

/obj/item/bedsheet/medical
	icon_state = "sheetmedical"

/obj/item/bedsheet/hos
	icon_state = "sheethos"

/obj/item/bedsheet/hop
	icon_state = "sheethop"

/obj/item/bedsheet/ce
	icon_state = "sheetce"

/obj/item/bedsheet/brown
	icon_state = "sheetbrown"


/obj/structure/bedsheetbin
	name = "linen bin"
	desc = "A linen bin. It looks rather cosy."
	icon = 'icons/obj/structures.dmi'
	icon_state = "linenbin-full"
	anchored = TRUE
	var/amount = 20
	var/list/sheets = list()
	var/obj/item/hidden


/obj/structure/bedsheetbin/examine(mob/user)
	..(user)

	if(amount < 1)
		to_chat(user, "There are no bed sheets in the bin.")
		return
	if(amount == 1)
		to_chat(user, "There is one bed sheet in the bin.")
		return
	to_chat(user, "There are [amount] bed sheets in the bin.")


/obj/structure/bedsheetbin/on_update_icon()
	switch(amount)
		if(0)				icon_state = "linenbin-empty"
		if(1 to amount / 2)	icon_state = "linenbin-half"
		else				icon_state = "linenbin-full"


/obj/structure/bedsheetbin/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/bedsheet))
		user.drop_item()
		I.loc = src
		sheets.Add(I)
		amount++
		to_chat(user, SPAN_NOTICE("You put [I] in [src]."))
	//make sure there's sheets to hide it among, make sure nothing else is hidden in there.
	else if(amount && !hidden && I.w_class < ITEM_SIZE_BULKY)
		user.drop_item()
		I.loc = src
		hidden = I
		to_chat(user, SPAN_NOTICE("You hide [I] among the sheets."))

/obj/structure/bedsheetbin/attack_hand(mob/user)
	if(amount >= 1)
		amount--

		var/obj/item/bedsheet/B
		if(sheets.len > 0)
			B = sheets[sheets.len]
			sheets.Remove(B)

		else
			B = new /obj/item/bedsheet(loc, TRUE)
		B.loc = user.loc

		user.put_in_hands(B)
		to_chat(user, SPAN_NOTICE("You take [B] out of [src]."))

		if(hidden)
			hidden.loc = user.loc
			to_chat(user, SPAN_NOTICE("[hidden] falls out of [B]!"))
			hidden = null


	add_fingerprint(user)

/obj/structure/bedsheetbin/attack_tk(mob/user)
	if(amount >= 1)
		amount--

		var/obj/item/bedsheet/B
		if(sheets.len > 0)
			B = sheets[sheets.len]
			sheets.Remove(B)

		else
			B = new /obj/item/bedsheet(loc, TRUE)

		B.loc = loc
		to_chat(user, SPAN_NOTICE("You telekinetically remove [B] from [src]."))
		update_icon()

		if(hidden)
			hidden.loc = loc
			hidden = null


	add_fingerprint(user)

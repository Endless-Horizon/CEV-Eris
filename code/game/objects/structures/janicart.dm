/obj/structure/janitorialcart
	name = "janitorial cart"
	desc = "The ultimate in janitorial carts! Has space for water, mops, signs, trash bags, and more!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cart"
	w_class = ITEM_SIZE_BULKY
	anchored = FALSE
	density = TRUE
	reagent_flags = OPENCONTAINER
	climbable = TRUE
	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/weapon/storage/bag/trash/mybag	= null
	var/obj/item/weapon/mop/mymop = null
	var/obj/item/weapon/reagent_containers/spray/myspray = null
	var/obj/item/device/lightreplacer/myreplacer = null
	var/obj/structure/mopbucket/mybucket = null
	var/has_items = FALSE
	var/dismantled = TRUE
	var/signs = 0	//maximum capacity hardcoded below



/obj/structure/janitorialcart/Destroy()
	QDEL_NULL(mybag)
	QDEL_NULL(mymop)
	QDEL_NULL(myspray)
	QDEL_NULL(myreplacer)
	QDEL_NULL(mybucket)
	return ..()

/obj/structure/janitorialcart/examine(mob/user)
	if(..(user, 1))
		if (mybucket)
			var/contains = mybucket.reagents.total_volume
			to_chat(user, "\icon[src] The bucket contains [contains] unit\s of liquid!")
		else
			to_chat(user, "\icon[src] There is no bucket mounted on it!")

/obj/structure/janitorialcart/MouseDrop_T(atom/movable/O as mob|obj, mob/living/user as mob)
	if (istype(O, /obj/structure/mopbucket) && !mybucket)
		O.forceMove(src)
		mybucket = O
		to_chat(user, "You mount the [O] on the janicart.")
		update_icon()
	else
		..()

/obj/structure/janitorialcart/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/mop) || istype(I, /obj/item/weapon/reagent_containers/glass/rag) || istype(I, /obj/item/weapon/soap))
		if (mybucket)
			if(I.reagents.total_volume < I.reagents.maximum_volume)
				if(mybucket.reagents.total_volume < 1)
					to_chat(user, "<span class='notice'>[mybucket] is empty!</span>")
				else
					mybucket.reagents.trans_to_obj(I, 5)	//
					to_chat(user, "<span class='notice'>You wet [I] in [mybucket].</span>")
					playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
			else
				to_chat(user, "<span class='notice'>[I] can't absorb anymore liquid!</span>")
		else
			to_chat(user, "<span class='notice'>There is no bucket mounted here to dip [I] into!</span>")
		return 1

	else if (istype(I, /obj/item/weapon/reagent_containers/glass/bucket) && mybucket)
		I.afterattack(mybucket, usr, 1)
		update_icon()
		return 1

	else if(istype(I, /obj/item/weapon/reagent_containers/spray) && !myspray)
		user.unEquip(I, src)
		myspray = I
		update_icon()
		updateUsrDialog()
		to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
		return 1

	else if(istype(I, /obj/item/device/lightreplacer) && !myreplacer)
		user.unEquip(I, src)
		myreplacer = I
		update_icon()
		updateUsrDialog()
		to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
		return 1

	else if(istype(I, /obj/item/weapon/storage/bag/trash) && !mybag)
		user.unEquip(I, src)
		mybag = I
		update_icon()
		updateUsrDialog()
		to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
		return 1

	else if(istype(I, /obj/item/weapon/caution))
		if(signs < 4)
			user.unEquip(I, src)
			signs++
			update_icon()
			updateUsrDialog()
			to_chat(user, SPAN_NOTICE("You put [I] into [src]."))
		else
			to_chat(user, SPAN_NOTICE("[src] can't hold any more signs."))
		return 1

	else if(mybag)
		return mybag.attackby(I, user)
		//This return will prevent afterattack from executing if the object goes into the trashbag,
		//This prevents dumb stuff like splashing the cart with the contents of a container, after putting said container into trash

	else if (!has_items)
		if (I.has_quality(QUALITY_BOLT_TURNING))
			if (I.use_tool(user, src, WORKTIME_SLOW, QUALITY_BOLT_TURNING, FAILCHANCE_EASY, STAT_MEC))
				dismantle(user)
			return
	..()


//New Altclick functionality!
//Altclick the cart with a mop to stow the mop away
//Altclick the cart with a reagent container to pour things into the bucket without putting the bottle in trash
/obj/structure/janitorialcart/AltClick(mob/living/user)
	if(user.incapacitated() || !Adjacent(user))	return
	var/obj/I = usr.get_active_hand()
	if(istype(I, /obj/item/weapon/mop))
		if(!mymop)
			usr.drop_from_inventory(I,src)
			mymop = I
			update_icon()
			updateUsrDialog()
			to_chat(usr, "<span class='notice'>You put [I] into [src].</span>")
			update_icon()
		else
			to_chat(usr, "<span class='notice'>The cart already has a mop attached</span>")
		return
	else if(istype(I, /obj/item/weapon/reagent_containers) && mybucket)
		var/obj/item/weapon/reagent_containers/C = I
		C.afterattack(mybucket, usr, 1)
		update_icon()


/obj/structure/janitorialcart/attack_hand(mob/user)
	nano_ui_interact(user)
	return

/obj/structure/janitorialcart/nano_ui_interact(var/mob/user, var/ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	var/data[0]
	data["name"] = capitalize(name)
	data["bag"] = mybag ? capitalize(mybag.name) : null
	data["bucket"] = mybucket ? capitalize(mybucket.name) : null
	data["mop"] = mymop ? capitalize(mymop.name) : null
	data["spray"] = myspray ? capitalize(myspray.name) : null
	data["replacer"] = myreplacer ? capitalize(myreplacer.name) : null
	data["signs"] = signs ? "[signs] sign\s" : null

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "janitorcart.tmpl", "Janitorial cart", 240, 160)
		ui.set_initial_data(data)
		ui.open()


/obj/structure/janitorialcart/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!isliving(usr))
		return
	var/mob/living/user = usr

	if(href_list["take"])
		switch(href_list["take"])
			if("garbage")
				if(mybag)
					user.put_in_hands(mybag)
					to_chat(user, SPAN_NOTICE("You take [mybag] from [src]."))
					mybag = null
			if("mop")
				if(mymop)
					user.put_in_hands(mymop)
					to_chat(user, SPAN_NOTICE("You take [mymop] from [src]."))
					mymop = null
			if("spray")
				if(myspray)
					user.put_in_hands(myspray)
					to_chat(user, SPAN_NOTICE("You take [myspray] from [src]."))
					myspray = null
			if("replacer")
				if(myreplacer)
					user.put_in_hands(myreplacer)
					to_chat(user, SPAN_NOTICE("You take [myreplacer] from [src]."))
					myreplacer = null
			if("sign")
				if(signs)
					var/obj/item/weapon/caution/Sign = locate() in src
					if(Sign)
						user.put_in_hands(Sign)
						to_chat(user, SPAN_NOTICE("You take \a [Sign] from [src]."))
						signs--
					else
						warning("[src] signs ([signs]) didn't match contents")
						signs = 0
			if("bucket")
				if(mybucket)
					mybucket.forceMove(get_turf(user))
					to_chat(user, "<span class='notice'>You unmount [mybucket] from [src].</span>")
					mybucket = null

	update_icon()
	updateUsrDialog()



/obj/structure/janitorialcart/on_update_icon()
	cut_overlays()

	if(mybucket)
		add_overlays("cart_bucket")
		if(mybucket.reagents.total_volume >= 1)
			add_overlays("water_cart")
	if(mybag)
		add_overlays("cart_garbage")
	if(mymop)
		add_overlays("cart_mop")
	if(myspray)
		add_overlays("cart_spray")
	if(myreplacer)
		add_overlays("cart_replacer")
	if(signs)
		add_overlays("cart_sign[signs]")






//This is called if the cart is caught in an explosion, or destroyed by weapon fire
/obj/structure/janitorialcart/proc/spill(var/chance = 100)
	var/turf/dropspot = get_turf(src)
	if (mymop && prob(chance))
		mymop.forceMove(dropspot)
		mymop.tumble(2)
		mymop = null

	if (myspray && prob(chance))
		myspray.forceMove(dropspot)
		myspray.tumble(3)
		myspray = null

	if (myreplacer && prob(chance))
		myreplacer.forceMove(dropspot)
		myreplacer.tumble(3)
		myreplacer = null

	if (mybucket && prob(chance*0.5))//bucket is heavier, harder to knock off
		mybucket.forceMove(dropspot)
		mybucket.tumble(1)
		mybucket = null

	if (signs)
		for (var/obj/item/weapon/caution/Sign in src)
			if (prob(min((chance*2),100)))
				signs--
				Sign.forceMove(dropspot)
				Sign.tumble(3)
				if (signs < 0)//safety for something that shouldn't happen
					signs = 0
					update_icon()
					return

	if (mybag && prob(min((chance*2),100)))//Bag is flimsy
		mybag.forceMove(dropspot)
		mybag.tumble(1)
		mybag.spill()//trashbag spills its contents too
		mybag = null

	update_icon()



/obj/structure/janitorialcart/proc/dismantle(var/mob/user = null)
	if (!dismantled)
		if (has_items)
			spill()

		new /obj/item/stack/material/steel(src.loc, 10)
		new /obj/item/stack/material/plastic(src.loc, 10)
		new /obj/item/stack/rods(src.loc, 20)
		dismantled = 1
		qdel(src)


/obj/structure/janitorialcart/ex_act(severity)
	spill(100 / severity)
	..()




//old style retardo-cart
/obj/structure/bed/chair/janicart
	name = "janicart"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "pussywagon"
	anchored = TRUE
	density = FALSE
	reagent_flags = OPENCONTAINER
	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/weapon/storage/bag/trash/mybag	= null
	var/callme = "pimpin' ride"	//how do people refer to it?
	applies_material_colour = 0


/obj/structure/bed/chair/janicart/New()
	..()
	create_reagents(100)


/obj/structure/bed/chair/janicart/examine(mob/user)
	if(!..(user, 1))
		return

	if(mybag)
		to_chat(user, "\A [mybag] is hanging on the [callme].")


/obj/structure/bed/chair/janicart/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/key))
		to_chat(user, "Hold [I] in one of your hands while you drive this [callme].")
	else if(istype(I, /obj/item/weapon/storage/bag/trash))
		to_chat(user, SPAN_NOTICE("You hook the trashbag onto the [callme]."))
		user.drop_item()
		I.loc = src
		mybag = I


/obj/structure/bed/chair/janicart/attack_hand(mob/user)
	if(mybag)
		mybag.loc = get_turf(user)
		user.put_in_hands(mybag)
		mybag = null
	else
		..()


/obj/structure/bed/chair/janicart/relaymove(mob/user, direction)
	if(user.stat || user.stunned || user.weakened || user.paralysis)
		unbuckle_mob()
	if(istype(user.l_hand, /obj/item/key) || istype(user.r_hand, /obj/item/key))
		step(src, direction)
		update_mob()
	else
		to_chat(user, SPAN_NOTICE("You'll need the keys in one of your hands to drive this [callme]."))


/obj/structure/bed/chair/janicart/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, var/glide_size_override = 0)
	. = ..()
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			buckled_mob.forceMove(glide_size_override=glide_size_override)


/obj/structure/bed/chair/janicart/post_buckle_mob(mob/living/M)
	update_mob()
	return ..()


/obj/structure/bed/chair/janicart/unbuckle_mob()
	var/mob/living/M = ..()
	if(M)
		M.pixel_x = 0
		M.pixel_y = 0
	return M


/obj/structure/bed/chair/janicart/set_dir()
	..()
	if(buckled_mob)
		if(buckled_mob.loc != loc)
			buckled_mob.buckled = null //Temporary, so Move() succeeds.
			buckled_mob.buckled = src //Restoring

	update_mob()


/obj/structure/bed/chair/janicart/proc/update_mob()
	if(buckled_mob)
		buckled_mob.set_dir(dir)
		switch(dir)
			if(SOUTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 7
			if(WEST)
				buckled_mob.pixel_x = 13
				buckled_mob.pixel_y = 7
			if(NORTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 4
			if(EAST)
				buckled_mob.pixel_x = -13
				buckled_mob.pixel_y = 7


/obj/structure/bed/chair/janicart/bullet_act(var/obj/item/projectile/Proj)
	if(buckled_mob)
		if(prob(85))
			return buckled_mob.bullet_act(Proj)
	visible_message(SPAN_WARNING("[Proj] ricochets off the [callme]!"))


/obj/item/key
	name = "key"
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "keys"
	w_class = ITEM_SIZE_TINY

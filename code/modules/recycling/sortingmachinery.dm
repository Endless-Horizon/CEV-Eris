/obj/structure/bigDelivery
	desc = "A big wrapped package."
	name = "large parcel"
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycloset"
	density = TRUE
	flags = NOBLUDGEON
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/obj/wrapped
	var/sortTag
	var/examtext
	var/nameset = 0
	var/label_y
	var/label_x
	var/tag_x

/obj/structure/bigDelivery/attack_hand(mob/user as mob)
	unwrap()

/obj/structure/bigDelivery/proc/unwrap()
	if(src.wrapped && (src.wrapped in src.contents)) //sometimes items can disappear. For example, bombs. --rastaf0
		wrapped.forceMove(get_turf(src.loc))
		if(istype(wrapped, /obj/structure/closet))
			var/obj/structure/closet/O = wrapped
			O.welded = 0
	qdel(src)

/obj/structure/bigDelivery/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/device/destTagger))
		var/obj/item/device/destTagger/O = W
		if(O.currTag)
			if(src.sortTag != O.currTag)
				to_chat(user, SPAN_NOTICE("You have labeled the destination as [O.currTag]."))
				if(!src.sortTag)
					src.sortTag = O.currTag
					update_icon()
				else
					src.sortTag = O.currTag
				playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1)
			else
				to_chat(user, SPAN_WARNING("The package is already labeled for [O.currTag]."))
		else
			to_chat(user, SPAN_WARNING("You need to set a destination first!"))

	else if(istype(W, /obj/item/pen))
		switch(alert("What would you like to alter?",,"Title","Description", "Cancel"))
			if("Title")
				var/str = sanitizeSafe(input(usr,"Label text?","Set label",""), MAX_NAME_LEN)
				if(!str || !length(str))
					to_chat(usr, SPAN_WARNING(" Invalid text."))
					return
				user.visible_message("\The [user] titles \the [src] with \a [W], marking down: \"[str]\"",\
				"<span class='notice'>You title \the [src]: \"[str]\"</span>",\
				"You hear someone scribbling a note.")
				playsound(src.loc, 'sound/effects/PEN_Ball_Point_Pen_Circling_01_mono.ogg', 50, 1)
				name = "[name] ([str])"
				if(!examtext && !nameset)
					nameset = 1
					update_icon()
				else
					nameset = 1
			if("Description")
				var/str = sanitize(input(usr,"Label text?","Set label",""))
				if(!str || !length(str))
					to_chat(usr, "\red Invalid text.")
					return
				if(!examtext && !nameset)
					examtext = str
					update_icon()
				else
					examtext = str
				user.visible_message("\The [user] labels \the [src] with \a [W], scribbling down: \"[examtext]\"",\
				"<span class='notice'>You label \the [src]: \"[examtext]\"</span>",\
				"You hear someone scribbling a note.")
				playsound(src.loc, 'sound/effects/PEN_Ball_Point_Pen_Circling_01_mono.ogg', 50, 1)
	return

/obj/structure/bigDelivery/on_update_icon()
	cut_overlays()
	if(nameset || examtext)
		var/image/I = new/image('icons/obj/storage.dmi',"delivery_label")
		if(icon_state == "deliverycloset")
			I.pixel_x = 2
			if(label_y == null)
				label_y = rand(-6, 11)
			I.pixel_y = label_y
		else if(icon_state == "deliverycrate")
			if(label_x == null)
				label_x = rand(-8, 6)
			I.pixel_x = label_x
			I.pixel_y = -3
		add_overlays(I)
	if(src.sortTag)
		var/image/I = new/image('icons/obj/storage.dmi',"delivery_tag")
		if(icon_state == "deliverycloset")
			if(tag_x == null)
				tag_x = rand(-2, 3)
			I.pixel_x = tag_x
			I.pixel_y = 9
		else if(icon_state == "deliverycrate")
			if(tag_x == null)
				tag_x = rand(-8, 6)
			I.pixel_x = tag_x
			I.pixel_y = -3
		add_overlays(I)

/obj/structure/bigDelivery/examine(mob/user)
	if(..(user, 4))
		if(sortTag)
			to_chat(user, "<span class='notice'>It is labeled \"[sortTag]\"</span>")
		if(examtext)
			to_chat(user, "<span class='notice'>It has a note attached which reads, \"[examtext]\"</span>")
	return

/obj/item/smallDelivery
	desc = "A small wrapped package."
	name = "small parcel"
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycrate3"
	var/obj/item/wrapped
	var/sortTag
	var/examtext
	var/nameset = 0
	var/tag_x

/obj/item/smallDelivery/attack_self(mob/user as mob)
	if (src.wrapped && (src.wrapped in src.contents)) //sometimes items can disappear. For example, bombs. --rastaf0
		wrapped.forceMove(user.loc)
		if(ishuman(user))
			user.put_in_hands(wrapped)
		else
			wrapped.forceMove(get_turf(src))

	qdel(src)
	return

/obj/item/smallDelivery/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/device/destTagger))
		var/obj/item/device/destTagger/O = W
		if(O.currTag)
			if(src.sortTag != O.currTag)
				to_chat(user, SPAN_NOTICE("You have labeled the destination as [O.currTag]."))
				if(!src.sortTag)
					src.sortTag = O.currTag
					update_icon()
				else
					src.sortTag = O.currTag
				playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1)
				playsound(src,'sound/effects/FOLEY_Gaffer_Tape_Tear_mono.ogg',100,2)
			else
				to_chat(user, SPAN_WARNING("The package is already labeled for [O.currTag]."))
		else
			to_chat(user, SPAN_WARNING("You need to set a destination first!"))

	else if(istype(W, /obj/item/pen))
		switch(alert("What would you like to alter?",,"Title","Description", "Cancel"))
			if("Title")
				var/str = sanitizeSafe(input(usr,"Label text?","Set label",""), MAX_NAME_LEN)
				if(!str || !length(str))
					to_chat(usr, SPAN_WARNING(" Invalid text."))
					return
				user.visible_message("\The [user] titles \the [src] with \a [W], marking down: \"[str]\"",\
				"<span class='notice'>You title \the [src]: \"[str]\"</span>",\
				"You hear someone scribbling a note.")
				playsound(src.loc, 'sound/effects/PEN_Ball_Point_Pen_Circling_01_mono.ogg', 50, 1)
				name = "[name] ([str])"
				if(!examtext && !nameset)
					nameset = 1
					update_icon()
				else
					nameset = 1

			if("Description")
				var/str = sanitize(input(usr,"Label text?","Set label",""))
				if(!str || !length(str))
					to_chat(usr, "\red Invalid text.")
					return
				if(!examtext && !nameset)
					examtext = str
					update_icon()
				else
					examtext = str
				user.visible_message("\The [user] labels \the [src] with \a [W], scribbling down: \"[examtext]\"",\
				"<span class='notice'>You label \the [src]: \"[examtext]\"</span>",\
				"You hear someone scribbling a note.")
				playsound(src.loc, 'sound/effects/PEN_Ball_Point_Pen_Circling_01_mono.ogg', 50, 1)
	return

/obj/item/smallDelivery/on_update_icon()
	cut_overlays()
	if((nameset || examtext) && icon_state != "deliverycrate1")
		var/image/I = new/image('icons/obj/storage.dmi',"delivery_label")
		if(icon_state == "deliverycrate5")
			I.pixel_y = -1
		add_overlays(I)
	if(src.sortTag)
		var/image/I = new/image('icons/obj/storage.dmi',"delivery_tag")
		switch(icon_state)
			if("deliverycrate1")
				I.pixel_y = -5
			if("deliverycrate2")
				I.pixel_y = -2
			if("deliverycrate3")
				I.pixel_y = 0
			if("deliverycrate4")
				if(tag_x == null)
					tag_x = rand(0,5)
				I.pixel_x = tag_x
				I.pixel_y = 3
			if("deliverycrate5")
				I.pixel_y = -3
		add_overlays(I)

/obj/item/smallDelivery/examine(mob/user)
	if(..(user, 4))
		if(sortTag)
			to_chat(user, "<span class='notice'>It is labeled \"[sortTag]\"</span>")
		if(examtext)
			to_chat(user, "<span class='notice'>It has a note attached which reads, \"[examtext]\"</span>")
	return

/obj/item/packageWrap
	name = "package wrapper"
	icon = 'icons/obj/items.dmi'
	icon_state = "deliveryPaper"
	w_class = ITEM_SIZE_NORMAL
	spawn_tags = SPAWN_TAG_ITEM_UTILITY
	rarity_value = 50
	var/amount = 25.0


/obj/item/packageWrap/afterattack(var/obj/target as obj, mob/user as mob, proximity)
	if(!proximity) return
	if(!istype(target))	//this really shouldn't be necessary (but it is).	-Pete
		return
	if(istype(target, /obj/item/smallDelivery) || istype(target,/obj/structure/bigDelivery) \
	|| istype(target, /obj/item/gift) || istype(target, /obj/item/evidencebag))
		return
	if(target.anchored)
		return
	if(target in user)
		return
	if(user in target) //no wrapping closets that you are inside - it's not physically possible
		return

	user.attack_log += text("\[[time_stamp()]\] <font color='blue'>Has used [src.name] on \ref[target]</font>")
	playsound(src,'sound/machines/PAPER_Fold_01_mono.ogg',100,1)

	if (istype(target, /obj/item) && !(istype(target, /obj/item/storage) && !istype(target,/obj/item/storage/box)))
		var/obj/item/O = target
		if (src.amount > 1)
			var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(get_turf(O.loc))	//Aaannd wrap it up!
			if(!istype(O.loc, /turf))
				if(user.client)
					user.client.screen -= O
			P.wrapped = O
			O.forceMove(P)
			P.w_class = O.w_class
			var/i = round(O.w_class)
			if(i in list(1,2,3,4,5))
				P.icon_state = "deliverycrate[i]"
				switch(i)
					if(1) P.name = "tiny parcel"
					if(3) P.name = "normal-sized parcel"
					if(4) P.name = "large parcel"
					if(5) P.name = "huge parcel"
			if(i < 1)
				P.icon_state = "deliverycrate1"
				P.name = "tiny parcel"
			if(i > 5)
				P.icon_state = "deliverycrate5"
				P.name = "huge parcel"
			P.add_fingerprint(usr)
			O.add_fingerprint(usr)
			src.add_fingerprint(usr)
			src.amount -= 1
			user.visible_message("\The [user] wraps \a [target] with \a [src].",\
			SPAN_NOTICE("You wrap \the [target], leaving [amount] units of paper on \the [src]."),\
			"You hear someone taping paper around a small object.")
	else if (istype(target, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/O = target
		if (src.amount > 3 && !O.opened)
			var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(O.loc))
			P.icon_state = "deliverycrate"
			P.wrapped = O
			O.forceMove(P)
			src.amount -= 3
			user.visible_message("\The [user] wraps \a [target] with \a [src].",\
			SPAN_NOTICE("You wrap \the [target], leaving [amount] units of paper on \the [src]."),\
			"You hear someone taping paper around a large object.")
		else if(src.amount < 3)
			to_chat(user, SPAN_WARNING("You need more paper."))
	else if (istype (target, /obj/structure/closet))
		var/obj/structure/closet/O = target
		if (src.amount > 3 && !O.opened)
			var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(O.loc))
			P.wrapped = O
			O.welded = 1
			O.forceMove(P)
			src.amount -= 3
			user.visible_message("\The [user] wraps \a [target] with \a [src].",\
			SPAN_NOTICE("You wrap \the [target], leaving [amount] units of paper on \the [src]."),\
			"You hear someone taping paper around a large object.")
		else if(src.amount < 3)
			to_chat(user, SPAN_WARNING("You need more paper."))
	else
		to_chat(user, "\blue The object you are trying to wrap is unsuitable for the sorting machinery!")
	if (src.amount <= 0)
		new /obj/item/c_tube( src.loc )
		qdel(src)
		return
	return

/obj/item/packageWrap/examine(mob/user)
	if(..(user, 0))
		to_chat(user, "\blue There are [amount] units of package wrap left!")

	return

/obj/structure/bigDelivery/Destroy()
	if(wrapped) //sometimes items can disappear. For example, bombs. --rastaf0
		wrapped.loc = (get_turf(loc))
		if(istype(wrapped, /obj/structure/closet))
			var/obj/structure/closet/O = wrapped
			O.welded = 0
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in contents)
		AM.loc = T
	. = ..()

/obj/item/device/destTagger
	name = "destination tagger"
	desc = "Used to set the destination of properly wrapped packages."
	icon_state = "dest_tagger"
	matter = list(MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1)
	rarity_value = 50
	var/currTag = 0

	w_class = ITEM_SIZE_SMALL
	item_state = "electronic"
	flags = CONDUCT
	slot_flags = SLOT_BELT

/obj/item/device/destTagger/proc/openwindow(mob/user as mob)
	var/dat = "<tt><center><h1><b>TagMaster 2.3</b></h1></center>"

	dat += "<table style='width:100%; padding:4px;'><tr>"
	for(var/i = 1, i <= tagger_locations.len, i++)
		dat += "<td><a href='?src=\ref[src];nextTag=[tagger_locations[i]]'>[tagger_locations[i]]</a></td>"

		if (i%4==0)
			dat += "</tr><tr>"

	dat += "</tr></table><br>Current Selection: [currTag ? currTag : "None"]</tt>"
	dat += "<br><a href='?src=\ref[src];nextTag=CUSTOM'>Enter custom location.</a>"
	user << browse(dat, "window=destTagScreen;size=450x375")
	onclose(user, "destTagScreen")

/obj/item/device/destTagger/attack_self(mob/user as mob)
	openwindow(user)
	return

/obj/item/device/destTagger/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["nextTag"] && (href_list["nextTag"] in tagger_locations))
		src.currTag = href_list["nextTag"]
	if(href_list["nextTag"] == "CUSTOM")
		var/dest = input("Please enter custom location.", "Location", src.currTag ? src.currTag : "None")
		if(dest != "None")
			src.currTag = dest
		else
			src.currTag = 0
	openwindow(usr)

/obj/machinery/disposal/deliveryChute
	name = "Delivery chute"
	desc = "A chute for big and small packages alike!"
	density = TRUE
	icon_state = "intake"
	layer = BELOW_OBJ_LAYER //So that things being ejected are visible
	var/c_mode = 0

/obj/machinery/disposal/deliveryChute/New()
	..()
	spawn(5)
		trunk = locate() in src.loc
		if(trunk)
			trunk.linked = src	// link the pipe trunk to self

/obj/machinery/disposal/deliveryChute/interact()
	return

/obj/machinery/disposal/deliveryChute/update()
	return

/obj/machinery/disposal/deliveryChute/Bumped(var/atom/movable/AM) //Go straight into the chute
	if(istype(AM, /obj/item/projectile) || istype(AM, /obj/effect))	return
	if(AM.loc && src.loc)
		switch(dir)
			if(NORTH)
				if(AM.loc.y != src.loc.y+1) return
			if(EAST)
				if(AM.loc.x != src.loc.x+1) return
			if(SOUTH)
				if(AM.loc.y != src.loc.y-1) return
			if(WEST)
				if(AM.loc.x != src.loc.x-1) return

	if(isobj(AM) || ismob(AM))
		AM.forceMove(src)
	src.flush()

/obj/machinery/disposal/deliveryChute/flush()
	flushing = 1
	FLICK("intake-closing", src)
	var/obj/structure/disposalholder/H = new()	// virtual holder object which actually
												// travels through the pipes.
	air_contents = new()		// new empty gas resv.

	sleep(10)
	playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, 0)
	sleep(5) // wait for animation to finish

	H.init(src)	// copy the contents of disposer to holder

	H.start(src) // start the holder processing movement
	flushing = 0
	// now reset disposal state
	flush = 0
	if(mode == 2)	// if was ready,
		mode = 1	// switch to charging
	update()
	return

/obj/machinery/disposal/deliveryChute/get_eject_turf()
	return get_ranged_target_turf(src, dir, 10)

/obj/machinery/disposal/deliveryChute/attackby(var/obj/item/I, var/mob/user)

	var/list/usable_qualities = list(QUALITY_SCREW_DRIVING)
	if(c_mode == 1)
		usable_qualities.Add(QUALITY_WELDING)

	var/tool_type = I.get_tool_type(user, usable_qualities, src)
	switch(tool_type)

		if(QUALITY_SCREW_DRIVING)
			if(contents.len > 0)
				to_chat(user, "Eject the items first!")
				return
			if(mode<=0)
				var/used_sound = mode ? 'sound/machines/Custom_screwdriverclose.ogg' : 'sound/machines/Custom_screwdriveropen.ogg'
				if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_EASY, required_stat = STAT_MEC, instant_finish_tier = 30, forced_sound = used_sound))
					if(c_mode==0) // It's off but still not unscrewed
						c_mode=1 // Set it to doubleoff l0l
						to_chat(user, "You remove the screws around the power connection.")
						return
					else if(c_mode==1)
						c_mode=0
						to_chat(user, "You attach the screws around the power connection.")
						return
			return

		if(QUALITY_WELDING)
			if(mode==-1)
				if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_VERY_EASY))
					to_chat(user, "You sliced the floorweld off the disposal unit.")
					var/obj/structure/disposalconstruct/C = new (src.loc)
					src.transfer_fingerprints_to(C)
					C.pipe_type = PIPE_TYPE_INTAKE
					C.anchored = TRUE
					C.density = TRUE
					C.update()
					qdel(src)
			return

/obj/machinery/disposal/deliveryChute/Destroy()
	if(trunk)
		trunk.linked = null
	. = ..()

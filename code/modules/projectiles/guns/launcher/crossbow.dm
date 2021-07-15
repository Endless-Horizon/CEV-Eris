//AMMUNITION

/obj/item/arrow
	name = "bolt"
	desc = "It's got a tip for you - get the point?"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bolt"
	item_state = "bolt"
	throwforce = 8
	w_class = ITEM_SIZE_NORMAL
	sharp = TRUE
	edge = FALSE

/obj/item/arrow/proc/removed() //Helper for metal rods falling apart.
	return

/obj/item/spike
	name = "alloy spike"
	desc = "A foot-long pointed stick made of a strange, silvery metal."
	sharp = TRUE
	edge = FALSE
	throwforce = 5
	w_class = ITEM_SIZE_SMALL
	icon = 'icons/obj/weapons.dmi'
	icon_state = "metal-rod"
	item_state = "bolt"

/obj/item/arrow/quill
	name = "vox quill"
	desc = "An alien-looking barbed quill plucked from who-knows-what kind of creature. It might work as a crossbow projectile."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "quill"
	item_state = "quill"
	throwforce = 5

/obj/item/arrow/rod
	name = "metal rod"
	desc = "A projectile for a crossbow. Don't cry for me, Orithena."
	icon_state = "metal-rod"

/obj/item/arrow/rod/removed(mob/user)
	if(throwforce == 15) // The rod has been superheated - we don't want it to be useable when removed from the bow.
		to_chat(user, "[src] shatters into dozens of superheated metal shards as soon as it is launched from the crossbow!")
		var/obj/item/material/shard/shrapnel/S = new()
		S.loc = get_turf(src)
		qdel(src)

/obj/item/gun/launcher/crossbow
	name = "powered crossbow"
	desc = "A 2557AD twist on an old classic. Pick up that can."
	icon = 'icons/obj/guns/launcher/crossbow-solid.dmi'
	icon_state = "crossbow"
	item_state = "crossbow-solid"
	fire_sound = 'sound/weapons/punchmiss.ogg' // TODO: Decent THWOK noise.
	fire_sound_text = "a solid thunk"
	fire_delay = 25
	slot_flags = SLOT_BACK
	restrict_safety = TRUE
	twohanded = TRUE
	rarity_value = 35//no price tag,then high rarirty

	var/obj/item/bolt
	var/tension = 0						// Current draw on the bow.
	var/max_tension = 5					// Highest possible tension.
	var/release_speed = 5				// Speed per unit of tension.
	var/obj/item/cell/large/cell	// Used for firing superheated rods.
	var/current_user					// Used to check if the crossbow has changed hands since being drawn.
	var/draw_time = 20					// How long it takes to increase the draw on the bow by one "tension"

/obj/item/gun/launcher/crossbow/update_release_force()
	release_force = tension*release_speed

/obj/item/gun/launcher/crossbow/consume_next_projectile(mob/user)
	if(tension <= 0)
		to_chat(user, SPAN_WARNING("\The [src] is not drawn back!"))
		return null
	return bolt

/obj/item/gun/launcher/crossbow/handle_post_fire(mob/user, atom/target)
	bolt = null
	tension = 0
	update_icon()
	..()

/obj/item/gun/launcher/crossbow/attack_self(mob/living/user)
	if(tension)
		if(bolt)
			user.visible_message("[user] relaxes the tension on [src]'s string and removes [bolt].","You relax the tension on [src]'s string and remove [bolt].")
			bolt.loc = get_turf(src)
			var/obj/item/arrow/A = bolt
			bolt = null
			A.removed(user)
		else
			user.visible_message("[user] relaxes the tension on [src]'s string.","You relax the tension on [src]'s string.")
		tension = 0
		update_icon()
	else
		draw(user)

/obj/item/gun/launcher/crossbow/proc/draw(mob/user)

	if(!bolt)
		to_chat(user, "You don't have anything nocked to [src].")
		return

	if(user.restrained())
		return

	current_user = user
	user.visible_message("[user] begins to draw back the string of [src].",SPAN_NOTICE("You begin to draw back the string of [src]."))
	tension = 1

	while(bolt && tension && loc == current_user)
		if(!do_after(user, draw_time, src)) //crossbow strings don't just magically pull back on their own.
			user.visible_message("[usr] stops drawing and relaxes the string of [src].",SPAN_WARNING("You stop drawing back and relax the string of [src]."))
			tension = 0
			update_icon()
			return

		//double check that the user hasn't removed the bolt in the meantime
		if(!(bolt && tension && loc == current_user))
			return

		tension++
		update_icon()

		if(tension >= max_tension)
			tension = max_tension
			to_chat(user, "[src] gives a satisfying clunk as the string is pulled back as far as it can go!")
			return

		user.visible_message("[usr] draws back the string of [src]!",SPAN_NOTICE("You continue drawing back the string of [src]!"))

/obj/item/gun/launcher/crossbow/proc/increase_tension(mob/user)

	if(!bolt || !tension || current_user != user) //Arrow has been fired, bow has been relaxed or user has changed.
		return


/obj/item/gun/launcher/crossbow/attackby(obj/item/I, mob/user)
	if(!bolt)
		if (istype(I,/obj/item/arrow))
			user.drop_from_inventory(I, src)
			bolt = I
			user.visible_message("[user] slides [bolt] into [src].","You slide [bolt] into [src].")
			update_icon()
			return
		else if(istype(I,/obj/item/stack/rods))
			var/obj/item/stack/rods/R = I
			if (R.use(1))
				bolt = new /obj/item/arrow/rod(src)
				bolt.fingerprintslast = fingerprintslast
				bolt.loc = src
				update_icon()
				user.visible_message("[user] jams [bolt] into [src].","You jam [bolt] into [src].")
				superheat_rod(user)
			return

	if(istype(I, /obj/item/cell/large))
		if(!cell)
			user.drop_item()
			cell = I
			cell.loc = src
			to_chat(user, SPAN_NOTICE("You jam [cell] into [src] and wire it to the firing coil."))
			superheat_rod(user)
		else
			to_chat(user, SPAN_NOTICE("[src] already has a cell installed."))

	else if(I.get_tool_type(usr, list(QUALITY_SCREW_DRIVING), src))
		if(cell)
			var/obj/item/C = cell
			C.loc = get_turf(user)
			to_chat(user, SPAN_NOTICE("You jimmy [cell] out of [src] with [I]."))
			cell = null
		else
			to_chat(user, SPAN_NOTICE("[src] doesn't have a cell installed."))

	else
		..()

/obj/item/gun/launcher/crossbow/proc/superheat_rod(mob/user)
	if(!user || !cell || !bolt) return
	if(!cell.check_charge(500)) return
	if(bolt.throwforce >= 15) return
	if(!istype(bolt,/obj/item/arrow/rod)) return

	to_chat(user, SPAN_NOTICE("[bolt] sparks and crackles as it gives off a red-hot glow."))
	bolt.throwforce = 15
	bolt.icon_state = "metal-rod-superheated"
	cell.use(500)

/obj/item/gun/launcher/crossbow/on_update_icon()
	if(tension > 1)
		icon_state = "crossbow-drawn"
	else if(bolt)
		icon_state = "crossbow-nocked"
	else
		icon_state = "crossbow"

/*////////////////////////////
//	Rapid Crossbow Device	//
*/////////////////////////////
/obj/item/arrow/RCD
	name = "flashforged bolt"
	desc = "The ultimate ghetto 'deconstruction' implement."
	throwforce = 6

/obj/item/gun/launcher/crossbow/RCD
	name = "rapid crossbow device"
	desc = "A hacked together RCD turns an innocent construction tool into the penultimate 'deconstruction' tool. Flashforges projectiles using matter units when the string is drawn back."
	icon = 'icons/obj/guns/launcher/rxb.dmi'
	icon_state = "rxb"
	slot_flags = null
	draw_time = 5
	spawn_blacklisted = TRUE
	var/stored_matter = 0
	var/max_stored_matter = 60
	var/boltcost = 5

/obj/item/gun/launcher/crossbow/RCD/proc/genBolt(mob/user)
	if(stored_matter >= boltcost && !bolt)
		bolt = new/obj/item/arrow/RCD(src)
		stored_matter -= boltcost
		to_chat(user, "<span class='notice'>The RXD flashforges a new bolt!</span>")
		update_icon()
	else
		to_chat(user, "<span class='warning'>The \'Low Ammo\' light on the device blinks yellow.</span>")
		FLICK("[icon_state]-empty", src)

/obj/item/gun/launcher/crossbow/RCD/attack_self(mob/living/user)
	if(tension)
		user.visible_message("[user] relaxes the tension on [src]'s string.","You relax the tension on [src]'s string.")
		tension = 0
		update_icon()
	else
		genBolt(user)
		draw(user)

/obj/item/gun/launcher/crossbow/RCD/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/rcd_ammo))
		if((stored_matter + 20) > max_stored_matter)
			to_chat(user, "<span class='notice'>The RXD can't hold that many additional matter-units.</span>")
			return
		stored_matter += 20
		qdel(W)
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, "<span class='notice'>The RXD now holds [stored_matter]/[max_stored_matter] matter-units.</span>")
		update_icon()
		return
	if(istype(W, /obj/item/arrow/RCD))
		var/obj/item/arrow/RCD/A = W
		if((stored_matter + 5) > max_stored_matter)
			to_chat(user, "<span class='notice'>Unable to reclaim flashforged bolt. The RXD can't hold that many additional matter-units.</span>")
			return
		stored_matter += 5
		qdel(A)
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, "<span class='notice'>Flashforged bolt reclaimed. The RXD now holds [stored_matter]/[max_stored_matter] matter-units.</span>")
		update_icon()
		return

/obj/item/gun/launcher/crossbow/RCD/on_update_icon()
	cut_overlays()
	if(bolt)
		add_overlays("rxb-bolt")
	var/ratio = 0
	if(stored_matter < boltcost)
		ratio = 0
	else
		ratio = stored_matter / max_stored_matter
		ratio = max(round(ratio, 0.25) * 100, 25)
	add_overlays("rxb-[ratio]")
	if(tension > 1)
		icon_state = "rxb-drawn"
	else
		icon_state = "rxb"

/obj/item/gun/launcher/crossbow/RCD/examine(user)
	. = ..()
	if(.)
		to_chat(user, "It currently holds [stored_matter]/[max_stored_matter] matter-units.")


/obj/item/arrow/ironrod
	name = "iron rod"
	desc = "The ultimate ghetto 'deconstruction' implement."
	throwforce = 6

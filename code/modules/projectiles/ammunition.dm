/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	flags = CONDUCT
	slot_flags = SLOT_BELT | SLOT_EARS
	throwforce = 1
	w_class = ITEM_SIZE_TINY

	var/leaves_residue = 1
	var/is_caseless = FALSE
	var/caliber = ""					//Which kind of guns it can be loaded into
	var/projectile_type					//The bullet type to create when New() is called
	var/obj/item/projectile/BB			//The loaded bullet - make it so that the projectiles are created only when needed?
	var/spent_icon
	var/amount = 1
	var/maxamount = 15
	var/reload_delay = 0

	var/sprite_update_spawn = FALSE		//defaults to normal sized sprites
	var/sprite_max_rotate = 16
	var/sprite_scale = 1
	var/sprite_use_small = TRUE 		//A var for a later global option to use all big sprites or small sprites for bullets, must be used before startup

/obj/item/ammo_casing/Initialize()
	. = ..()
	if(sprite_update_spawn)
		var/matrix/rotation_matrix = matrix()
		rotation_matrix.Turn(round(45 * rand(0, sprite_max_rotate) / 2))
		if(sprite_use_small)
			src.transform = rotation_matrix * sprite_scale
		else
			src.transform = rotation_matrix
	if(ispath(projectile_type))
		BB = new projectile_type(src)
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	if(amount > 1)
		update_icon()

//removes the projectile from the ammo casing
/obj/item/ammo_casing/proc/expend()
	. = BB
	BB = null
	set_dir(pick(cardinal)) //spin spent casings
	update_icon()

/obj/item/ammo_casing/attack_hand(mob/user)
	if((src.amount > 1) && (src == user.get_inactive_hand()))
		src.amount -= 1
		var/obj/item/ammo_casing/new_casing = new /obj/item/ammo_casing(get_turf(user))
		new_casing.name = src.name
		new_casing.desc = src.desc
		new_casing.caliber = src.caliber
		new_casing.projectile_type = src.projectile_type
		new_casing.icon_state = src.icon_state
		new_casing.spent_icon = src.spent_icon
		new_casing.maxamount = src.maxamount
		if(ispath(new_casing.projectile_type) && src.BB)
			new_casing.BB = new new_casing.projectile_type(new_casing)
		else
			new_casing.BB = null

		new_casing.sprite_max_rotate = src.sprite_max_rotate
		new_casing.sprite_scale = src.sprite_scale
		new_casing.sprite_use_small = src.sprite_use_small
		new_casing.sprite_update_spawn = src.sprite_update_spawn

		if(new_casing.sprite_update_spawn)
			var/matrix/rotation_matrix = matrix()
			rotation_matrix.Turn(round(45 * rand(0, new_casing.sprite_max_rotate) / 2))
			if(new_casing.sprite_use_small)
				new_casing.transform = rotation_matrix * new_casing.sprite_scale
			else
				new_casing.transform = rotation_matrix

		new_casing.is_caseless = src.is_caseless


		new_casing.update_icon()
		src.update_icon()
		user.put_in_active_hand(new_casing)
	else
		return ..()

/obj/item/ammo_casing/attackby(obj/item/I, mob/user)
	if(I.get_tool_type(usr, list(QUALITY_SCREW_DRIVING, QUALITY_CUTTING), src))
		if(!BB)
			to_chat(user, SPAN_NOTICE("There is no bullet in the casing to inscribe anything into."))
			return

		var/tmp_label = ""
		var/label_text = sanitizeSafe(input(user, "Inscribe some text into \the [initial(BB.name)]","Inscription",tmp_label), MAX_NAME_LEN)
		if(length(label_text) > 20)
			to_chat(user, SPAN_WARNING("The inscription can be at most 20 characters long."))
		else if(!label_text)
			to_chat(user, SPAN_NOTICE("You scratch the inscription off of [initial(BB)]."))
			BB.name = initial(BB.name)
		else
			to_chat(user, SPAN_NOTICE("You inscribe \"[label_text]\" into \the [initial(BB.name)]."))
			BB.name = "[initial(BB.name)] (\"[label_text]\")"
		return TRUE
	else if(istype(I, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/merging_casing = I
		if(isturf(src.loc))
			if(merging_casing.amount == merging_casing.maxamount)
				to_chat(user, SPAN_WARNING("[merging_casing] is fully stacked!"))
				return FALSE
			if(merging_casing.mergeCasing(src, null, user))
				return TRUE
		else if (mergeCasing(I, 1, user))
			return TRUE

/obj/item/ammo_casing/proc/mergeCasing(var/obj/item/ammo_casing/AC, var/amountToMerge, var/mob/living/user, var/noMessage = FALSE, var/noIconUpdate = FALSE)
	if(!AC)
		return FALSE
	if(!user && noMessage == FALSE)
		error("Passed no user to mergeCasing() when output messages is active.")
	if(src.caliber != AC.caliber)
		if(!noMessage)
			to_chat(user, SPAN_WARNING("Ammo are different calibers."))
		return FALSE
	if(src.projectile_type != AC.projectile_type)
		if(!noMessage)
			to_chat(user, SPAN_WARNING("Ammo are different types."))
		return FALSE
	if(src.amount == src.maxamount)
		if(!noMessage)
			to_chat(user, SPAN_WARNING("[src] is fully stacked!"))
		return FALSE
	if((!src.BB && AC.BB) || (src.BB && !AC.BB))
		if(!noMessage)
			to_chat(user, SPAN_WARNING("Fired and non-fired ammo wont stack."))
		return FALSE

	var/mergedAmount
	if(!amountToMerge)
		mergedAmount = AC.amount
	else
		mergedAmount = amountToMerge
	if(mergedAmount + src.amount > src.maxamount)
		mergedAmount = src.maxamount - src.amount
	AC.amount -= mergedAmount
	src.amount += mergedAmount
	if(!noIconUpdate)
		src.update_icon()
	if(AC.amount == 0)
		QDEL_NULL(AC)
	else
		if(!noIconUpdate)
			AC.update_icon()
	return TRUE

/obj/item/ammo_casing/on_update_icon()
	if(spent_icon && !BB)
		icon_state = spent_icon
	src.cut_overlays()
	if(amount > 1)
		src.pixel_x = 0
		src.pixel_y = 0

	for(var/icon_amount = 1; icon_amount < src.amount, icon_amount++)
		var/image/temp_image = image(src.icon, src.icon_state)
		var/coef = round(14 * icon_amount/src.maxamount)

		temp_image.pixel_x = rand(coef, -coef)
		temp_image.pixel_y = rand(coef, -coef)
		var/matrix/temp_image_matrix = matrix()
		temp_image_matrix.Turn(round(45 * rand(0, sprite_max_rotate) / 2))
		temp_image.transform = temp_image_matrix
		src.add_overlays(temp_image)

/obj/item/ammo_casing/examine(mob/user)
	..()
	to_chat(user, "There [(amount == 1)? "is" : "are"] [amount] round\s left!")
	if (!BB)
		to_chat(user, "[(amount == 1)? "This one is" : "These ones are"] spent.")

//An item that holds casings and can be used to put them inside guns
/obj/item/ammo_magazine
	name = "magazine"
	desc = "A magazine for some kind of gun."
	icon_state = "place-holder-box"
	icon = 'icons/obj/ammo_mags.dmi'
	flags = CONDUCT
	slot_flags = SLOT_BELT
	item_state = "syringe_kit"
	matter = list(MATERIAL_STEEL = 2)
	throwforce = 5
	w_class = ITEM_SIZE_SMALL
	throw_speed = 4
	throw_range = 10

	spawn_tags = SPAWN_TAG_AMMO
	rarity_value = 10
	bad_type = /obj/item/ammo_magazine

	var/ammo_color = ""		//For use in modular sprites

	var/list/stored_ammo = list()
	var/mag_type = SPEEDLOADER //ammo_magazines can only be used with compatible guns. This is not a bitflag, the load_method var on guns is.
	var/mag_well = MAG_WELL_GENERIC
	var/caliber = CAL_357
	var/ammo_mag = "default"
	var/max_ammo = 7
	var/reload_delay = 0 //when we need to make reload slower

	var/ammo_type = /obj/item/ammo_casing //ammo type that is initially loaded
	var/initial_ammo

	var/multiple_sprites = 0
	//because BYOND doesn't support numbers as keys in associative lists
	var/list/icon_keys = list()		//keys
	var/list/ammo_states = list()	//values

/obj/item/ammo_magazine/New()
	..()
	if(multiple_sprites)
		initialize_magazine_icondata(src)

	if(isnull(initial_ammo))
		initial_ammo = max_ammo

	if(initial_ammo)
		for(var/i in 1 to initial_ammo)
			stored_ammo += new ammo_type(src)
	update_icon()

/obj/item/ammo_magazine/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/C = W
		if(stored_ammo.len >= max_ammo)
			to_chat(user, SPAN_WARNING("\The [src] is full!"))
			return
		if(C.caliber != caliber)
			to_chat(user, SPAN_WARNING("\The [C] does not fit into \the [src]."))
			return
		insertCasing(C)
	else if(istype(W, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/other = W
		if(!src.stored_ammo.len)
			to_chat(user, SPAN_WARNING("There is no ammo in \the [src]!"))
			return
		if(other.stored_ammo.len >= other.max_ammo)
			to_chat(user, SPAN_NOTICE("\The [other] is already full."))
			return
		var/diff = FALSE
		for(var/obj/item/ammo in src.stored_ammo)
			if(other.stored_ammo.len < other.max_ammo && do_after(user, reload_delay/other.max_ammo, src) && other.insertCasing(removeCasing()))
				diff = TRUE
				continue
			break
		if(diff)
			to_chat(user, SPAN_NOTICE("You finish loading \the [other]. It now contains [other.stored_ammo.len] rounds, and \the [src] now contains [stored_ammo.len] rounds."))
		else
			to_chat(user, SPAN_WARNING("You fail to load anything into \the [other]"))
	if(istype(W, /obj/item/gun/projectile))
		var/obj/item/gun/projectile/gun_to_load = W
		if(gun_to_load.can_dual && !gun_to_load.ammo_magazine)
			if(!do_after(user, 0.5 SECONDS, src))
				return
			gun_to_load.load_ammo(src, user)
			to_chat(user, SPAN_NOTICE("It takes a bit of time for you to reload your [W] with [src] using only one hand!"))
			visible_message("[user] tactically reloads [W] using only one hand!")	

/obj/item/ammo_magazine/attack_hand(mob/user)
	if(user.get_inactive_hand() == src && stored_ammo.len)
		var/obj/item/ammo_casing/stack = removeCasing()
		if(stack)
			if(stored_ammo.len)
				// We end on -1 since we already removed one
				for(var/i = 1, i <= stack.maxamount - 1, i++)
					if(!stored_ammo.len)
						break
					var/obj/item/ammo_casing/AC = removeCasing()
					if(!stack.mergeCasing(AC, null, user, noIconUpdate = TRUE))
						insertCasing(AC)
						break
			stack.update_icon()
			user.put_in_active_hand(stack)
		return
	..()

/obj/item/ammo_magazine/AltClick(var/mob/living/user)
	var/obj/item/W = user.get_active_hand()
	if(istype(W, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/C = W
		if(stored_ammo.len >= max_ammo)
			to_chat(user, SPAN_WARNING("[src] is full!"))
			return
		if(C.caliber != caliber)
			to_chat(user, SPAN_WARNING("[C] does not fit into [src]."))
			return
		if(stored_ammo.len)
			var/obj/item/ammo_casing/T = removeCasing()
			if(T)
				if(!C.mergeCasing(T, null, user))
					insertCasing(T)
	else if(!W)
		if(user.get_inactive_hand() == src && stored_ammo.len)
			var/obj/item/ammo_casing/AC = removeCasing()
			if(AC)
				user.put_in_active_hand(AC)

/obj/item/ammo_magazine/proc/insertCasing(var/obj/item/ammo_casing/C)
	if(!istype(C))
		return FALSE
	if(C.caliber != caliber)
		return FALSE
	if(stored_ammo.len >= max_ammo)
		return FALSE
	if(C.amount > 1)
		C.amount -= 1

		var/obj/item/ammo_casing/inserted_casing = new /obj/item/ammo_casing(src)
		inserted_casing.name = C.name
		inserted_casing.desc = C.desc
		inserted_casing.caliber = C.caliber
		inserted_casing.projectile_type = C.projectile_type
		inserted_casing.icon_state = C.icon_state
		inserted_casing.spent_icon = C.spent_icon
		inserted_casing.maxamount = C.maxamount
		if(ispath(inserted_casing.projectile_type) && C.BB)
			inserted_casing.BB = new inserted_casing.projectile_type(inserted_casing)

		inserted_casing.sprite_max_rotate = C.sprite_max_rotate
		inserted_casing.sprite_scale = C.sprite_scale
		inserted_casing.sprite_use_small = C.sprite_use_small
		inserted_casing.sprite_update_spawn = C.sprite_update_spawn

		if(inserted_casing.sprite_update_spawn)
			var/matrix/rotation_matrix = matrix()
			rotation_matrix.Turn(round(45 * rand(0, inserted_casing.sprite_max_rotate) / 2))
			if(inserted_casing.sprite_use_small)
				inserted_casing.transform = rotation_matrix * inserted_casing.sprite_scale
			else
				inserted_casing.transform = rotation_matrix

		inserted_casing.is_caseless = C.is_caseless

		C.update_icon()
		inserted_casing.update_icon()
		stored_ammo.Insert(1, inserted_casing)
	else
		if(ismob(C.loc))
			var/mob/M = C.loc
			M.remove_from_mob(C)
		C.forceMove(src)
		stored_ammo.Insert(1, C) //add to the head of the list
	update_icon()
	return TRUE

/obj/item/ammo_magazine/proc/removeCasing()
	if(stored_ammo.len)
		var/obj/item/ammo_casing/AC = stored_ammo[1]
		stored_ammo -= AC
		if(!stored_ammo.len)
			stored_ammo.Cut()
		update_icon()
		return AC

/obj/item/ammo_magazine/resolve_attackby(atom/A, mob/user)
	//Clicking on tile with no collectible items will empty it, if it has the verb to do that.
	if(isturf(A) && !A.density)
		dump_it(A)
		return TRUE
	return ..()

/obj/item/ammo_magazine/verb/quick_empty()
	set name = "Empty Ammo Container"
	set category = "Object"
	set src in view(1)

	if((!ishuman(usr) && (src.loc != usr)) || usr.stat || usr.restrained())
		return

	var/turf/T = get_turf(src)
	if(!istype(T))
		return
	dump_it(T, usr)

/obj/item/ammo_magazine/proc/dump_it(var/turf/target) //bogpilled
	if(!istype(target))
		return
	if(!Adjacent(usr))
		return
	if(!stored_ammo.len)
		to_chat(usr, SPAN_NOTICE("[src] is already empty!"))
		return
	to_chat(usr, SPAN_NOTICE("You take out ammo from [src]."))
	for(var/i=1 to stored_ammo.len)
		var/obj/item/ammo_casing/C = removeCasing()
		C.forceMove(target)
		C.set_dir(pick(cardinal))
	update_icon()

/obj/item/ammo_magazine/on_update_icon()
	if(multiple_sprites)
		//find the lowest key greater than or equal to stored_ammo.len
		var/new_state = null
		for(var/idx in 1 to icon_keys.len)
			var/ammo_count = icon_keys[idx]
			if (ammo_count >= stored_ammo.len)
				new_state = ammo_states[idx]
				break
		icon_state = (new_state)? new_state : initial(icon_state)

/obj/item/ammo_magazine/examine(mob/user)
	..()
	to_chat(user, "There [(stored_ammo.len == 1)? "is" : "are"] [stored_ammo.len] round\s left!")

//magazine icon state caching
/var/global/list/magazine_icondata_keys = list()
/var/global/list/magazine_icondata_states = list()

/proc/initialize_magazine_icondata(var/obj/item/ammo_magazine/M)
	var/typestr = "[M.type]"
	if(!(typestr in magazine_icondata_keys) || !(typestr in magazine_icondata_states))
		magazine_icondata_cache_add(M)

	M.icon_keys = magazine_icondata_keys[typestr]
	M.ammo_states = magazine_icondata_states[typestr]

/proc/magazine_icondata_cache_add(var/obj/item/ammo_magazine/M)
	var/list/icon_keys = list()
	var/list/ammo_states = list()
	var/list/states = icon_states(M.icon)
	for(var/i = 0, i <= M.max_ammo, i++)
		var/ammo_state = "[M.icon_state]-[i]"
		if(ammo_state in states)
			icon_keys += i
			ammo_states += ammo_state

	magazine_icondata_keys["[M.type]"] = icon_keys
	magazine_icondata_states["[M.type]"] = ammo_states

/*	Photography!
 *	Contains:
 *		Camera
 *		Camera Film
 *		Photos
 *		Photo Albums
 */

/*******
* film *
*******/
/obj/item/device/camera_film
	name = "film cartridge"
	icon = 'icons/obj/items.dmi'
	desc = "A camera film cartridge. Insert it into a camera to reload it."
	icon_state = "film"
	item_state = "electropack"
	w_class = ITEM_SIZE_TINY


/********
* photo *
********/
var/global/photo_count = 0

/obj/item/photo
	name = "photo"
	icon = 'icons/obj/items.dmi'
	icon_state = "photo"
	item_state = "paper"
	w_class = ITEM_SIZE_SMALL
	var/id
	var/icon/img	//Big photo image
	var/scribble	//Scribble on the back.
	var/icon/tiny
	var/photo_size = 3

/obj/item/photo/on_update_icon()
	.=..()
	//When the photo updates, update its container too. This will often be an album or paper bundle
	if (istype(loc, /obj))
		var/obj/O = loc
		O.update_icon()

/obj/item/photo/Initialize(mapload)
	. = ..()
	id = photo_count++

/obj/item/photo/attack_self(mob/user as mob)
	user.examinate(src)

/obj/item/photo/attackby(obj/item/P as obj, mob/user as mob)
	if(istype(P, /obj/item/pen))
		var/txt = sanitize(input(user, "What would you like to write on the back?", "Photo Writing", null)  as text, 128)
		if(loc == user && user.stat == 0)
			scribble = txt
	..()

/obj/item/photo/examine(mob/user)
	if(in_range(user, src))
		show(user)
		to_chat(user, desc)
	else
		to_chat(user, SPAN_NOTICE("It is too far away."))

/obj/item/photo/proc/show(mob/user as mob)
	user << browse_rsc(img, "tmp_photo_[id].png")
	user << browse("<html><head><title>[name]</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='tmp_photo_[id].png' width='[64*photo_size]' style='-ms-interpolation-mode:nearest-neighbor' />" \
		+ "[scribble ? "<br>Written on the back:<br><i>[scribble]</i>" : ""]"\
		+ "</body></html>", "window=book;size=[64*photo_size]x[scribble ? 400 : 64*photo_size]")
	onclose(user, "[name]")
	return

/obj/item/photo/verb/rename()
	set name = "Rename photo"
	set category = "Object"
	set src in usr

	var/n_name = sanitizeSafe(input(usr, "What would you like to label the photo?", "Photo Labelling", null)  as text, MAX_NAME_LEN)
	//loc.loc check is for making possible renaming photos in clipboards
	if(( (loc == usr || (loc.loc && loc.loc == usr)) && usr.stat == 0))
		name = "[(n_name ? text("[n_name]") : "photo")]"
	add_fingerprint(usr)
	return


/**************
* photo album *
**************/
/obj/item/storage/photo_album
	name = "Photo album"
	icon = 'icons/obj/items.dmi'
	icon_state = "album"
	item_state = "briefcase"
	can_hold = list(/obj/item/photo)
	matter = list(MATERIAL_BIOMATTER = 4)


/*********
* camera *
*********/
/obj/item/device/camera
	name = "camera"
	icon = 'icons/obj/items.dmi'
	desc = "A polaroid camera. 10 photos left."
	icon_state = "camera"
	item_state = "electropack"
	w_class = ITEM_SIZE_SMALL
	flags = CONDUCT
	slot_flags = SLOT_BELT
	matter = list(MATERIAL_PLASTIC = 5, MATERIAL_GLASS = 2)
	var/pictures_max = 10
	var/pictures_left = 10
	var/on = TRUE
	var/icon_on = "camera"
	var/icon_off = "camera_off"
	var/radius = 2
	var/flash_power = 6

/obj/item/device/camera/verb/change_size()
	set name = "Set Photo Focus"
	set category = "Object"
	var/nsize = input("Photo Size","Pick a size of resulting photo.") as null|anything in list(3,5,7,9)
	if(nsize)
		radius = (nsize - 1) * 0.5
		to_chat(usr, SPAN_NOTICE("Camera will now take [(radius*2)+1]x[(radius*2)+1] photos."))

/obj/item/device/camera/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/device/camera/attack_self(mob/user as mob)
	on = !on
	if(on)
		src.icon_state = icon_on
	else
		src.icon_state = icon_off
	to_chat(user, "You switch the camera [on ? "on" : "off"].")
	return

/obj/item/device/camera/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/device/camera_film))
		if(pictures_left)
			to_chat(user, SPAN_NOTICE("[src] still has some film in it!"))
			return
		to_chat(user, SPAN_NOTICE("You insert [I] into [src]."))
		user.drop_item()
		qdel(I)
		pictures_left = pictures_max
		return
	..()


/obj/item/device/camera/proc/get_mobs(turf/the_turf as turf)
	var/mob_detail
	for(var/mob/living/carbon/A in the_turf)
		if(A.invisibility) continue
		var/holding = null
		if(A.l_hand || A.r_hand)
			if(A.l_hand) holding = "They are holding \a [A.l_hand]"
			if(A.r_hand)
				if(holding)
					holding += " and \a [A.r_hand]"
				else
					holding = "They are holding \a [A.r_hand]"

		if(!mob_detail)
			mob_detail = "You can see [A] on the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]. "
		else
			mob_detail += "You can also see [A] on the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]."
	return mob_detail

/obj/item/device/camera/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if(!on || !pictures_left || ismob(target.loc)) return
	set_light(light_range + flash_power)
	spawn(3)
		set_light(light_range - flash_power)
	captureimage(target, user)

	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)

	pictures_left--
	desc = "A polaroid camera. It has [pictures_left] photos left."
	to_chat(user, SPAN_NOTICE("[pictures_left] photos left."))
	icon_state = icon_off
	on = FALSE
	spawn(64)
		icon_state = icon_on
		on = TRUE

//Proc for capturing check
/mob/living/proc/can_capture_turf(turf/T)
	var/mob/dummy = new(T)	//Go go visibility check dummy
	var/viewer = src
	if(src.client)		//To make shooting through security cameras possible
		viewer = src.client.eye
	var/can_see = (dummy in viewers(world.view, viewer))

	qdel(dummy)
	return can_see

/obj/item/device/camera/proc/captureimage(atom/target, mob/living/user, capturemode = CAPTURE_MODE_REGULAR)
	var/x_c = target.x - radius
	var/y_c = target.y + radius
	var/z_c	= target.z
	var/mobs = ""
	var/size = (radius*2)+1
	for(var/i = 1; i <= size; i++)
		for(var/j = 1; j <= size; j++)
			var/turf/T = locate(x_c, y_c, z_c)
			if(user.can_capture_turf(T))
				mobs += get_mobs(T)
			x_c++
		y_c--
		x_c = x_c - size

	var/obj/item/photo/p = createpicture(target, user, capturemode, radius)
	p.desc = mobs
	printpicture(user, p)

/proc/createpicture(atom/target, mob/user, var/capturemode = CAPTURE_MODE_REGULAR, var/radius = 3)
	var/x_c = target.x - radius
	var/y_c = target.y - radius
	var/z_c	= target.z


	var/obj/item/photo/p = new()
	p.name = "photo"



	p.pixel_x = rand(-10, 10)
	p.pixel_y = rand(-10, 10)
	p.photo_size = (radius*2)+1


	spawn()
		//We spawn off the actual generation of the image because it is a verrry slow process that takes multiple seconds
		var/icon/photoimage = generate_image(x_c, y_c, z_c, (radius*2)+1, capturemode, user, non_blocking = TRUE)

		var/icon/small_img = icon(photoimage)
		var/icon/tiny_img = icon(photoimage)
		var/icon/ic = icon('icons/obj/items.dmi',"photo")
		var/icon/pc = icon('icons/obj/bureaucracy.dmi', "photo")
		small_img.Scale(8, 8)
		tiny_img.Scale(4, 4)
		ic.Blend(small_img,ICON_OVERLAY, 10, 13)
		pc.Blend(tiny_img,ICON_OVERLAY, 12, 19)
		if (!QDELETED(p))
			p.img = photoimage
			p.icon = ic
			p.tiny = pc
			p.update_icon()

	//The photo object is returned immediately, but its image will only be added a couple seconds later
	return p

/obj/item/device/camera/proc/printpicture(mob/user, obj/item/photo/p)
	if (user)
		user.put_in_hands(p)
	else
		p.forceMove(get_turf(src))

/obj/item/photo/proc/copy(var/copy_id = 0)
	var/obj/item/photo/p = new/obj/item/photo()

	p.name = name
	p.icon = icon(icon, icon_state)
	p.tiny = icon(tiny)
	p.img = icon(img)
	p.desc = desc
	p.pixel_x = pixel_x
	p.pixel_y = pixel_y
	p.photo_size = photo_size
	p.scribble = scribble

	if(copy_id)
		p.id = id

	return p

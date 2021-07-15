/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/crate.dmi'
	icon_state = "crate"
	climbable = TRUE
	dense_when_open = TRUE
	matter = list(MATERIAL_STEEL = 10)
	open_sound = 'sound/machines/click.ogg'
	close_sound = 'sound/machines/click.ogg'
	price_tag = 50

/obj/structure/closet/crate/close()
	if(!src.opened)
		return FALSE
	if(!src.can_close())
		return FALSE

	playsound(src.loc, close_sound, 15, 1, -3)
	var/itemcount = 0
	for(var/obj/O in get_turf(src))
		if(itemcount >= storage_capacity)
			break
		if(O.density || O.anchored || istype(O,/obj/structure/closet))
			continue
		if(istype(O, /obj/structure/bed)) //This is only necessary because of rollerbeds and swivel chairs.
			var/obj/structure/bed/B = O
			if(B.buckled_mob)
				continue
		O.forceMove(src)
		itemcount++

	src.opened = FALSE
	update_icon()
	return TRUE

/obj/structure/closet/crate/ex_act(severity)
	switch(severity)
		if(1)
			for(var/obj/O in src.contents)
				qdel(O)
			qdel(src)
			return
		if(2)
			for(var/obj/O in src.contents)
				if(prob(50))
					qdel(O)
			qdel(src)
			return
		if(3)
			if (prob(50))
				qdel(src)
			return
		else
	return

/obj/structure/closet/crate/MouseDrop_T(mob/target, mob/user)
	var/mob/living/L = user
	if(istype(L) && can_climb(L) && target == user)
		do_climb(target)
	else
		return ..()


/obj/structure/closet/crate/secure
	desc = "A secure crate."
	name = "Secure crate"
	icon_state = "securecrate"
	broken = FALSE
	secure = TRUE
	locked = TRUE

/obj/structure/closet/crate/secure/New()
	..()
	update_icon()

/obj/structure/closet/crate/plastic
	name = "plastic crate"
	desc = "A rectangular plastic crate."
	icon_state = "plasticcrate"
	matter = list(MATERIAL_PLASIC = 10)
	price_tag = 10

/obj/structure/closet/crate/internals
	name = "internals crate"
	desc = "A internals crate."
	icon_state = "o2crate"

/obj/structure/closet/crate/internals/populate_contents()
	new /obj/item/tank/emergency_oxygen(src)
	new /obj/item/tank/emergency_oxygen(src)
	new /obj/item/tank/emergency_oxygen(src)
	new /obj/item/tank/emergency_oxygen(src)
	new /obj/item/tank/emergency_oxygen(src)
	new /obj/item/tank/emergency_oxygen(src)
	new /obj/item/tank/emergency_oxygen(src)
	new /obj/item/tank/emergency_oxygen(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/clothing/mask/breath(src)

/obj/structure/closet/crate/trashcart
	name = "trash cart"
	desc = "A heavy, metal trashcart with wheels."
	icon_state = "trashcart"
	storage_capacity = 6 * MOB_MEDIUM //3x Storage
	max_mob_size = 4 //2 more mobs then normal. Makes clearing mobs faster

/*these aren't needed anymore
/obj/structure/closet/crate/hat
	desc = "A crate filled with Valuable Collector's Hats!."
	name = "Hat Crate"
	icon_state = "crate"
	icon_opened = "crateopen"
	icon_closed = "crate"

/obj/structure/closet/crate/contraband
	name = "Poster crate"
	desc = "A random assortment of posters manufactured by providers NOT listed under Nanotrasen's whitelist."
	icon_state = "crate"
	icon_opened = "crateopen"
	icon_closed = "crate"
*/

/obj/structure/closet/crate/medical
	name = "medical crate"
	desc = "A medical crate."
	icon_state = "medicalcrate"

/obj/structure/closet/crate/rcd
	name = "\improper RCD crate"
	desc = "A crate with rapid construction device."
	icon_state = "crate"

/obj/structure/closet/crate/rcd/populate_contents()
	new /obj/item/rcd_ammo(src)
	new /obj/item/rcd_ammo(src)
	new /obj/item/rcd_ammo(src)
	new /obj/item/rcd(src)

/obj/structure/closet/crate/solar
	name = "solar pack crate"

/obj/structure/closet/crate/solar/populate_contents()
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/electronics/circuitboard/solar_control(src)
	new /obj/item/electronics/tracker(src)
	new /obj/item/paper/solar(src)

/obj/structure/closet/crate/freezer
	name = "freezer"
	desc = "A freezer."
	icon_state = "freezer"

/obj/structure/closet/crate/freezer/rations //Fpr use in the escape shuttle
	name = "emergency rations"
	desc = "A crate of emergency rations."


/obj/structure/closet/crate/freezer/rations/populate_contents()
	new /obj/item/reagent_containers/food/snacks/liquidfood(src)
	new /obj/item/reagent_containers/food/snacks/liquidfood(src)
	new /obj/item/reagent_containers/food/snacks/liquidfood(src)
	new /obj/item/reagent_containers/food/snacks/liquidfood(src)

/obj/structure/closet/crate/bin
	name = "large bin"
	desc = "A large bin."
	icon_state = "largebin"
	icon_welded = null //TODO

/obj/structure/closet/crate/radiation
	name = "radioactive gear crate"
	desc = "A crate with a radiation sign on it."
	icon_state = "radiation"

/obj/structure/closet/crate/radiation/populate_contents()
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)

/obj/structure/closet/crate/secure/weapon
	name = "weapons crate"
	desc = "A secure weapons crate."
	icon_state = "weaponcrate"

/obj/structure/closet/crate/secure/plasma
	name = "plasma crate"
	desc = "A secure plasma crate."
	icon_state = "plasmacrate"

/obj/structure/closet/crate/secure/gear
	name = "gear crate"
	desc = "A secure gear crate."
	icon_state = "secgearcrate"

/obj/structure/closet/crate/secure/hydrosec
	name = "secure hydroponics crate"
	desc = "A crate with a lock on it, painted in the scheme of the ship's botanists."
	icon_state = "hydrosecurecrate"

/obj/structure/closet/crate/secure/hydrosec/prelocked
	req_access = list(access_hydroponics)

/obj/structure/closet/crate/secure/bin
	name = "secure bin"
	desc = "A secure bin."
	icon_state = "largebins"
	icon_lock = "largebin"
	icon_sparking = "largebinbsparks"
	icon_welded = null //TODO

/obj/structure/closet/crate/large
	name = "large crate"
	desc = "A hefty metal crate."
	icon_state = "largemetal"
	icon_welded = null //TODO

/obj/structure/closet/crate/large/close()
	. = ..()
	if (.)//we can hold up to one large item
		var/found = 0
		for(var/obj/structure/S in src.loc)
			if(S == src)
				continue
			if(!S.anchored)
				found = 1
				S.forceMove(src)
				break
		if(!found)
			for(var/obj/machinery/M in src.loc)
				if(!M.anchored)
					M.forceMove(src)
					break
	return

/obj/structure/closet/crate/secure/large
	name = "large crate"
	desc = "A hefty metal crate with an electronic locking system."
	icon_state = "largemetal"
	icon_lock = "largemetal"
	icon_sparking = null
	icon_welded = null //TODO

/obj/structure/closet/crate/secure/large/close()
	. = ..()
	if (.)//we can hold up to one large item
		var/found = 0
		for(var/obj/structure/S in src.loc)
			if(S == src)
				continue
			if(!S.anchored)
				found = 1
				S.forceMove(src)
				break
		if(!found)
			for(var/obj/machinery/M in src.loc)
				if(!M.anchored)
					M.forceMove(src)
					break

//fluff variant
/obj/structure/closet/crate/secure/large/reinforced
	desc = "A hefty, reinforced metal crate with an electronic locking system."
	icon_state = "largermetal"

/obj/structure/closet/crate/hydroponics
	name = "hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon_state = "hydrocrate"

/obj/structure/closet/crate/scicrate
	desc = "A science crate."
	name = "Science crate"
	icon_state = "crate"

/obj/structure/closet/crate/secure/scisecurecrate
	desc = "A secure science crate."
	name = "Science crate"
	icon_state = "securecrate"

/obj/structure/closet/crate/secure/woodseccrate
	desc = "A secure wooden crate."
	name = "Secure wooden crate"
	icon_state = "plasmacrate"

/obj/structure/closet/crate/serbcrate
	desc = "A secure wooden crate."
	name = "Secure wooden crate"
	icon_state = "serbcrate"

/obj/structure/closet/crate/serbcrate_gray
	desc = "A secure metallic crate."
	name = "Secure metallic crate"
	icon_state = "serbcrate_gray"

/obj/structure/closet/crate/germancrate
	desc = "A secure metallic crate."
	name = "Secure metallic crate"
	icon_state = "germancrate"


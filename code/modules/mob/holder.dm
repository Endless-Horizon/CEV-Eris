var/list/holder_mob_icon_cache = list()

//Helper object for picking dionaea (and other creatures) up.
/obj/item/weapon/holder
	name = "holder"
	desc = null
	icon = 'icons/mob/held_mobs.dmi'
	slot_flags = 0
	//sprite_sheets = list("Vox" = 'icons/mob/species/vox/head.dmi')
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items/lefthand_holder.dmi',
		slot_r_hand_str = 'icons/mob/items/righthand_holder.dmi',
	)
	origin_tech = null
	spawn_blacklisted = TRUE
	spawn_frequency = 0
	var/mob/living/contained
	var/icon_state_dead
	var/desc_dead
	var/name_dead
	var/isalive

	var/static/list/unsafe_containers
	pixel_y = 8
	var/last_loc_general	//This stores a general location of the object. Ie, a container or a mob
	var/last_loc_specific	//This stores specific extra information about the location, pocket, hand, worn on head, etc. Only relevant to mobs
	var/last_holder

//A list of things a mob can't be safely released inside.
/obj/item/weapon/holder/proc/setup_unsafe_list()
	unsafe_containers = typecacheof(list(
		/obj/item/weapon/storage,
		/obj/item/weapon/reagent_containers,
		/obj/structure/closet/crate,
		///obj/machinery/appliance,
		/obj/machinery/microwave,
		/obj/machinery/vending
	))

/obj/item/weapon/holder/Initialize()
	. = ..()
	if (!unsafe_containers)
		setup_unsafe_list()

	if (!item_state)
		item_state = icon_state

	//flags_inv |= ALWAYSDRAW //Part of contained sprites overhaul, not ported yet

	START_PROCESSING(SSprocessing, src)

/obj/item/weapon/holder/Destroy()
	reagents = null
	STOP_PROCESSING(SSprocessing, src)
	if (contained)
		release_mob(FALSE)
	return ..()

/obj/item/weapon/holder/examine(mob/user)
	if (contained)
		contained.examine(user)

/obj/item/weapon/holder/attack_self()
	for(var/mob/M in contents)
		M.show_inv(usr)

//Mob specific holders.
/obj/item/weapon/holder/diona
	origin_tech = list(TECH_MAGNET = 3, TECH_BIO = 5)
	slot_flags = SLOT_HEAD | SLOT_OCLOTHING | SLOT_HOLSTER


/obj/item/weapon/holder/borer
	origin_tech = list(TECH_BIO = 8)

/obj/item/weapon/holder/Process()
	if (!contained)
		qdel(src)

	if(!get_holding_mob() || contained.loc != src)
		if (is_unsafe_container(loc) && contained.loc == src)
			return

		release_mob()

		return
	if (isalive && contained.stat == DEAD)
		held_death(1)//If we get here, it means the mob died sometime after we picked it up. We pass in 1 so that we can play its deathmessage


//This function checks if the current location is safe to release inside
//it returns 1 if the creature will bug out when released
/obj/item/weapon/holder/proc/is_unsafe_container(atom/place)
	return is_type_in_typecache(place, unsafe_containers)

//Releases all mobs inside the holder, then deletes it.
//is_unsafe_container should be checked before calling this
//This function releases mobs into wherever the holder currently is. Its not safe to call from a lot of places
//Use release_to_floor for a simple, safe release
/obj/item/weapon/holder/proc/release_mob(var/des_self = TRUE)
	for(var/mob/living/M in contents)
		var/atom/movable/mob_container
		mob_container = M
		mob_container.forceMove(src.loc)//if the holder was placed into a disposal, this should place the animal in the disposal
		M.reset_view()
		M.Released()

	contained = null
	if(des_self)
		qdel(src)

//Similar to above function, but will not deposit things in any container, only directly on a turf.
//Can be called safely anywhere. Notably on holders held or worn on a mob
/obj/item/weapon/holder/proc/release_to_floor()
	var/turf/T = get_turf(src)

	for(var/mob/living/M in contents)
		M.forceMove(T) //if the holder was placed into a disposal, this should place the animal in the disposal
		M.reset_view()
		M.Released()

	contained = null

	qdel(src)

/obj/item/weapon/holder/attackby(obj/item/weapon/W as obj, mob/user as mob)
	for(var/mob/M in src.contents)
		M.attackby(W,user)

/obj/item/weapon/holder/dropped(mob/user)

	///When an object is put into a container, drop fires twice.
	//once with it on the floor, and then once in the container
	//This conditional allows us to ignore that first one. Handling of mobs dropped on the floor is done in process
	if (istype(loc, /turf))
		//Repeat this check
		//If we're still on the turf a few frames later, then we have actually been dropped or thrown
		//Release the mob accordingly
		addtimer(CALLBACK(src, .proc/post_drop), 3)
		return

	if (istype(loc, /obj/item/weapon/storage))	//The second drop reads the container its placed into as the location
		update_location()

/obj/item/weapon/holder/proc/post_drop()
	if (isturf(loc))
		release_mob()

/obj/item/weapon/holder/equipped(var/mob/user, var/slot)
	..()
	update_location(slot)

/obj/item/weapon/holder/proc/update_location(var/slotnumber)
	if(!slotnumber)
		if(ismob(loc))
			slotnumber = get_equip_slot()

	report_onmob_location(1, slotnumber, contained)

/obj/item/weapon/holder/attack_self(mob/M)

	if (contained && !(contained.stat & DEAD))
		if (istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			switch(H.a_intent)
				if(I_HELP)
					H.visible_message("<span class='notice'>[H] pets [contained].</span>")

				if(I_HURT)
					contained.adjustBruteLoss(3)
					H.visible_message("<span class='alert'>[H] crushes [contained].</span>")
	else
		to_chat(M, "[contained] is dead.")


/obj/item/weapon/holder/show_message(var/message, var/m_type)
	for(var/mob/living/M in contents)
		M.show_message(message,m_type)

//Mob procs and vars for scooping up
/mob/living/var/holder_type


/obj/item/weapon/holder/proc/held_death(var/show_deathmessage = 0)
	//This function is called when the mob in the holder dies somehow.
	isalive = 0

	if (icon_state_dead)
		icon_state = icon_state_dead

	if (desc_dead)
		desc = desc_dead

	if (name_dead)
		name = name_dead

	slot_flags = 0
	if (show_deathmessage)//Since we've just crushed a creature in our hands, we want everyone nearby to know that it died
		//We have to play it as a visible message on the grabber, because the normal death message played on the dying mob won't show if it's being held
		var/mob/M = get_holding_mob()
		if (M)
			M.visible_message("<b>[contained.name]</b> dies.")
	//update_icon()


/mob/living/proc/get_scooped(mob/living/carbon/grabber, mob/user)
	if(!holder_type || buckled || pinned.len || !Adjacent(grabber))
		return

	if (user == src)
		if (grabber.r_hand && grabber.l_hand)
			to_chat(user, "<span class='warning'>They have no free hands!</span>")
			return
	else if ((grabber.hand == 0 && grabber.r_hand) || (grabber.hand == 1 && grabber.l_hand))//Checking if the hand is full
		to_chat(grabber, "<span class='warning'>Your hand is full!</span>")
		return

	src.verbs += /mob/living/proc/get_holder_location//This has to be before we move the mob into the holder


	spawn(2)
		var/obj/item/weapon/holder/H = new holder_type(loc)

		var/old_loc = src.loc

		src.forceMove(H)

		H.contained = src
		if (src.stat == DEAD)
			H.held_death()//We've scooped up an animal that's already dead. use the proper dead icons
		else
			H.isalive = 1//We note that the mob is alive when picked up. If it dies later, we can know that its death happened while held, and play its deathmessage for it

		var/success = 0
		if (src == user)
			success = grabber.put_in_hands(H)
		else
			H.attack_hand(grabber)//We put this last to prevent some race conditions
			if (H.loc == grabber)
				success = 1
		if (success)
			if (isturf(old_loc))
				src.do_pickup_animation(grabber,old_loc)
			if (user == src)
				to_chat(grabber, "<span class='notice'>[src.name] climbs up onto you.</span>")
				to_chat(src, "<span class='notice'>You climb up onto [grabber].</span>")
			else
				to_chat(grabber, "<span class='notice'>You scoop up [src].</span>")
				to_chat(src, "<span class='notice'>[grabber] scoops you up.</span>")

			H.sync(src)

		else
			to_chat(user, "Failed, try again!")
			//If the scooping up failed something must have gone wrong
			H.release_mob()

		return


/mob/living/proc/get_holder_location()
	set category = "Abilities"
	set name = "Check held location"
	set desc = "Find out where on their person, someone is holding you."

	if (!usr.get_holding_mob())
		to_chat(src, "Nobody is holding you!")
		return

	if (istype(usr.loc, /obj/item/weapon/holder))
		var/obj/item/weapon/holder/H = usr.loc
		H.report_onmob_location(0, H.get_equip_slot(), src)

/obj/item/weapon/holder/human
	icon = null
	var/holder_icon = 'icons/mob/holder_complex.dmi'
	var/list/generate_for_slots = list(slot_l_hand_str, slot_r_hand_str, slot_back_str)
	slot_flags = SLOT_BACK


/obj/item/weapon/holder/proc/sync(var/mob/living/M)
	dir = 2
	cut_overlays()
	icon = M.icon
	icon_state = M.icon_state
	item_state = M.item_state
	color = M.color
	name = M.name
	desc = M.desc
	associate_with_overlays(M.overlays)
	last_holder = loc
	update_wear_icon()





//#TODO-MERGE








//This function provides a verbose message describing where something is on a person. Intended for mobs in holders
/obj/proc/report_onmob_location(var/justmoved, var/slot = null, var/mob/reportto)
	var/mob/living/carbon/human/H//The person who the item is on
	var/newlocation
	var/preposition= ""
	var/action = ""
	var/action3 = ""
	if (!reportto)
		return 0

	if (istype(loc, /mob/living/carbon/human))//This function is for finding where we are on a human. not valid otherwise
		H = loc

	else
		H = get_holding_mob()


	if (slot != null)

		if (slot_l_hand == slot)
			if (justmoved)
				action += "now "
			preposition = "in"
			action += "being held"
			action3 = "holds"
			newlocation = "left hand"
		else if (slot_r_hand == slot)
			if (justmoved)
				action += "now "
			preposition = "in"
			action += "being held"
			action3 = "holds"
			newlocation = "right hand"
		else if (slot_l_store == slot)
			if (justmoved)
				preposition = "into"
				action = "placed"
				action3 = "places"
			else
				preposition = "inside"
			newlocation = "left pocket"
		else if (slot_r_store == slot)
			if (justmoved)
				preposition = "into"
				action = "placed"
				action3 = "places"
			else
				preposition = "inside"
			newlocation = "right pocket"
		else if (slot_s_store == slot)
			if (justmoved)
				preposition = "into"
				action = "placed"
				action3 = "places"
			else
				preposition = "inside"
			newlocation = "suit storage"
		else
			if (justmoved)
				action += "now "
			action += "being worn"

			if (slot_head == slot)
				preposition = "as"
				action3 = "wears"
				newlocation = "hat"
			else if (slot_wear_suit == slot)
				preposition = "over"
				action3 = "wears"
				newlocation = "uniform"
			else if (slot_wear_mask == slot)
				preposition = "on"
				action3 = "wears"
				newlocation = "face"
			else if (slot_wear_id == slot)
				preposition = "as"
				action3 = "wears"
				newlocation = "ID"
			else if (slot_w_uniform == slot)
				preposition = "on"
				action3 = "wears"
				newlocation = "body"
			else if (slot_gloves == slot)
				preposition = "on"
				action3 = "wears"
				newlocation = "hands"
			else if (slot_belt == slot)
				preposition = "around"
				action3 = "wears"
				newlocation = "waist"
			else if (slot_back == slot)
				preposition = "on"
				action3 = "wears"
				newlocation = "back"
			else if (slot_r_ear == slot)
				preposition = "on"
				action3 = "wears"
				newlocation = "right shoulder"//Ill use ear slots for wearing mobs on the shoulder in future
			else if (slot_l_ear == slot)
				preposition = "on"
				action3 = "wears"
				newlocation = "left shoulder"
			else if (slot_shoes == slot)
				preposition = "on"
				action3 = "wears"
				newlocation = "feet"
	else if (istype(loc,/obj/item/modular_computer/pda))
		var/obj/item/modular_computer/pda/S = loc
		newlocation = S.name
		if (justmoved)
			preposition = "into"
			action = "slotted"
			action3 = "slots"
		else
			action = "installed"
			preposition = "in"
	else if (istype(loc,/obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = loc
		newlocation = S.name
		if (justmoved)
			preposition = "into"
			action = "placed"
			action3 = "places"
		else
			action = "tucked"
			preposition = "inside"

	if (justmoved)
		reportto.visible_message("<span class='notice'>[H] [action3] [reportto] [preposition] their [newlocation]</span>", "<span class='notice'>You are [action] [preposition] [H]'s [newlocation]</span>", "")
	else
		to_chat(reportto, "<span class='notice'>You are [action] [preposition] [H]'s [newlocation]</span>")



/atom/proc/get_holding_mob()
	//This function will return the mob which is holding this holder, or null if it's not held
	//It recurses up the hierarchy out of containers until it reaches a mob, or a turf, or hits the limit
	var/x = 0//As a safety, we'll crawl up a maximum of five layers
	var/atom/A = src
	while (x < 5)
		x++
		if (isnull(A))
			return null

		A = A.loc
		if (istype(A, /turf))
			return null//We must be on a table or a floor, or maybe in a wall. Either way we're not held.

		if (ismob(A))
			return A
		//If none of the above are true, we must be inside a box or backpack or something. Keep recursing up.

	return null//If we get here, the holder must be buried many layers deep in nested containers. Shouldn't happen


//Mob specific holders.
//w_class mainly determines whether they can fit in containers and pockets



/obj/item/weapon/holder/drone
	name = "maintenance drone"
	desc = "It's a small maintenance robot."
	icon_state = "drone"
	item_state = "drone"
	origin_tech = list(TECH_MAGNET = 3, TECH_ENGINEERING = 5)
	slot_flags = SLOT_HEAD
	w_class = ITEM_SIZE_BULKY
	//contained_sprite = 1 //Part of contained sprite overhaul, not yet ported

/obj/item/weapon/holder/drone/heavy
	name = "construction drone"
	desc = "It's a really big maintenance robot."
	icon_state = "constructiondrone"
	item_state = "constructiondrone"
	w_class = ITEM_SIZE_GARGANTUAN//You're not fitting this thing in a backpack


/obj/item/weapon/holder/cat
	name = "cat"
	desc = "It's a cat. Meow."
	desc_dead = "It's a dead cat."
	icon_state = "cat_tabby"
	icon_state_dead = "cat_tabby_dead"
	item_state = "cat"
//Setting item state to cat saves on some duplication for the in-hand versions, but we cant use it for head.
//Instead, the head versions are done by duplicating the cat
	slot_flags = SLOT_HEAD
	w_class = ITEM_SIZE_NORMAL

/obj/item/weapon/holder/cat/black
	icon_state = "cat_black"
	icon_state_dead = "cat_black_dead"
	slot_flags = SLOT_HEAD
	item_state = "cat"

/obj/item/weapon/holder/cat/kitten
	name = "kitten"
	icon_state = "cat_kitten"
	icon_state_dead = "cat_kitten_dead"
	slot_flags = SLOT_HEAD
	w_class = ITEM_SIZE_TINY
	item_state = "cat"

/obj/item/weapon/holder/cat/penny
	name = "Penny"
	desc = "An important cat, straight from Central Command."
	icon_state = "penny"
	icon_state_dead = "penny_dead"
	slot_flags = SLOT_HEAD
	w_class = ITEM_SIZE_TINY
	item_state = "penny"
	//contained_sprite = 1 //Part of contained sprite overhaul, not yet ported


/obj/item/weapon/holder/corgi
	name = "corgi"
	icon_state = "corgi"
	item_state = "corgi"
	//contained_sprite = 1 //Part of contained sprite overhaul, not yet ported
	w_class = ITEM_SIZE_NORMAL

/obj/item/weapon/holder/borer
	name = "cortical borer"
	desc = "It's a slimy brain slug. Gross."
	icon_state = "brainslug"
	origin_tech = list(TECH_BIO = 6)
	w_class = ITEM_SIZE_TINY

/obj/item/weapon/holder/monkey
	name = "monkey"
	desc = "It's a monkey. Ook."
	icon_state = "monkey"
	item_state = "monkey"
	slot_flags = SLOT_HEAD
	//contained_sprite = 1 //Part of contained sprite overhaul, not yet ported
	w_class = ITEM_SIZE_NORMAL


//Holders for mice
/obj/item/weapon/holder/mouse
	name = "mouse"
	desc = "It's a fuzzy little critter."
	desc_dead = "It's filthy vermin, throw it in the trash."
	icon = 'icons/mob/mouse.dmi'
	icon_state = "mouse_brown_sleep"
	item_state = "mouse_brown"
	icon_state_dead = "mouse_brown_dead"
	slot_flags = SLOT_EARS | SLOT_HEAD
	//contained_sprite = 1 //Part of contained sprite overhaul, not yet ported
	origin_tech = list(TECH_BIO = 2)
	w_class = ITEM_SIZE_TINY

/obj/item/weapon/holder/mouse/white
	icon_state = "mouse_white_sleep"
	item_state = "mouse_white"
	icon_state_dead = "mouse_white_dead"

/obj/item/weapon/holder/mouse/gray
	icon_state = "mouse_gray_sleep"
	item_state = "mouse_gray"
	icon_state_dead = "mouse_gray_dead"

/obj/item/weapon/holder/mouse/brown
	icon_state = "mouse_brown_sleep"
	item_state = "mouse_brown"
	icon_state_dead = "mouse_brown_dead"


/obj/item/weapon/holder/GetIdCard()
	for(var/mob/M in contents)
		var/obj/item/I = M.GetIdCard()
		if(I)
			return I
	return null

/*
//Lizards

/obj/item/weapon/holder/lizard
	name = "lizard"
	desc = "It's a hissy little lizard. Is it related to Unathi?"
	desc_dead = "It doesn't hiss anymore."
	icon_state_dead = "lizard_dead"
	icon_state = "lizard"

	slot_flags = 0
	w_class = ITEM_SIZE_TINY

//Chicks and chickens
/obj/item/weapon/holder/chick
	name = "chick"
	desc = "It's a fluffy little chick, until it grows up."
	desc_dead = "How could you do this? You monster!"
	icon_state_dead = "chick_dead"
	slot_flags = 0
	icon_state = "chick"
	w_class = ITEM_SIZE_TINY


/obj/item/weapon/holder/chicken
	name = "chicken"
	desc = "It's a feathery, tasty-looking chicken."
	desc_dead = "Now it's ready for plucking and cooking!"
	icon_state = "chicken_brown"
	icon_state_dead = "chicken_brown_dead"
	slot_flags = 0
	w_class = ITEM_SIZE_SMALL

/obj/item/weapon/holder/chicken/brown
	icon_state = "chicken_brown"
	icon_state_dead = "chicken_brown_dead"

/obj/item/weapon/holder/chicken/black
	icon_state = "chicken_black"
	icon_state_dead = "chicken_black_dead"

/obj/item/weapon/holder/chicken/white
	icon_state = "chicken_white"
	icon_state_dead = "chicken_white_dead"



//Mushroom
/obj/item/weapon/holder/mushroom
	name = "walking mushroom"
	name_dead = "mushroom"
	desc = "It's a massive mushroom... with legs?"
	desc_dead = "Shame, he was a really fun-guy."	// HA
	icon_state = "mushroom"
	icon_state_dead = "mushroom_dead"
	slot_flags = SLOT_HEAD
	w_class = ITEM_SIZE_SMALL



//pAI
/obj/item/weapon/holder/pai
	icon = 'icons/mob/pai.dmi'
	dir = EAST
	contained_sprite = 1
	slot_flags = SLOT_HEAD

/obj/item/weapon/holder/pai/drone
	icon_state = "repairbot_rest"
	item_state = "repairbot"

/obj/item/weapon/holder/pai/cat
	icon_state = "cat_rest"
	item_state = "cat"

/obj/item/weapon/holder/pai/mouse
	icon_state = "mouse_rest"
	item_state = "mouse"

/obj/item/weapon/holder/pai/monkey
	icon_state = "monkey"
	item_state = "monkey"

/obj/item/weapon/holder/pai/rabbit
	icon_state = "rabbit_rest"
	item_state = "rabbit"

//corgi





/obj/item/weapon/holder/monkey/farwa
	name = "farwa"
	desc = "It's a farwa."
	icon_state = "farwa"
	item_state = "farwa"
	slot_flags = SLOT_HEAD
	w_class = ITEM_SIZE_NORMAL

/obj/item/weapon/holder/monkey/stok
	name = "stok"
	desc = "It's a stok. stok."
	icon_state = "stok"
	item_state = "stok"
	slot_flags = SLOT_HEAD
	w_class = ITEM_SIZE_NORMAL

/obj/item/weapon/holder/monkey/neaera
	name = "neaera"
	desc = "It's a neaera."
	icon_state = "neaera"
	item_state = "neaera"
	slot_flags = SLOT_HEAD
	w_class = ITEM_SIZE_NORMAL


/obj/item/weapon/holder/diona
	name = "diona nymph"
	desc = "It's a little plant critter."
	desc_dead = "It used to be a little plant critter."
	icon = 'icons/mob/diona.dmi'
	icon_state = "nymph"
	icon_state_dead = "nymph_dead"
	origin_tech = list(TECH_MAGNET = 3, TECH_BIO = 5)
	slot_flags = SLOT_HEAD | SLOT_OCLOTHING
	w_class = ITEM_SIZE_SMALL
*/

//The block below is for resomi, not currently relevant
/*
/obj/item/weapon/holder/human/sync(var/mob/living/M)
	cut_overlays()
	// Generate appropriate on-mob icons.
	var/mob/living/carbon/human/owner = M
	if(!icon && istype(owner) && owner.species)
		var/icon/I = new /icon()

		var/skin_colour = rgb(owner.r_skin, owner.g_skin, owner.b_skin)
		var/hair_colour = rgb(owner.r_hair, owner.g_hair, owner.b_hair)
		var/eye_colour =  rgb(owner.r_eyes, owner.g_eyes, owner.b_eyes)
		var/species_name = lowertext(owner.species.get_bodytype())

		for(var/cache_entry in generate_for_slots)
			var/cache_key = "[owner.species]-[cache_entry]-[skin_colour]-[hair_colour]"
			if(!holder_mob_icon_cache[cache_key])

				// Generate individual icons.
				var/icon/mob_icon = icon(holder_icon, "[species_name]_holder_[cache_entry]_base")
				mob_icon.Blend(skin_colour, ICON_ADD)
				var/icon/hair_icon = icon(holder_icon, "[species_name]_holder_[cache_entry]_hair")
				hair_icon.Blend(hair_colour, ICON_ADD)
				var/icon/eyes_icon = icon(holder_icon, "[species_name]_holder_[cache_entry]_eyes")
				eyes_icon.Blend(eye_colour, ICON_ADD)

				// Blend them together.
				mob_icon.Blend(eyes_icon, ICON_OVERLAY)
				mob_icon.Blend(hair_icon, ICON_OVERLAY)

				// Add to the cache.
				holder_mob_icon_cache[cache_key] = mob_icon

			var/newstate
			switch (cache_entry)
				if (slot_l_hand_str)
					newstate = "[species_name]_lh"
				if (slot_r_hand_str)
					newstate = "[species_name]_rh"
				if (slot_back_str)
					newstate = "[species_name]_ba"

			I.Insert(holder_mob_icon_cache[cache_key], newstate)


		dir = 2
		var/icon/mob_icon = icon(owner.icon, owner.icon_state)
		I.Insert(mob_icon, species_name)
		icon = I
		icon_state = species_name
		item_state = species_name

		contained_sprite = 1

		color = M.color
		name = M.name
		desc = M.desc
		copy_overlays(M)
		update_wear_icon()

		..()
*/

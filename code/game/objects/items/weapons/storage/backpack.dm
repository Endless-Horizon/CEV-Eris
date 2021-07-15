
/*
 * Backpack
 */

/obj/item/storage/backpack
	name = "grey backpack"
	desc = "You wear this on your back and put items into it."
	icon = 'icons/obj/storage/backpack.dmi'
	icon_state = "backpack"
	contained_sprite = TRUE
	w_class = ITEM_SIZE_HUGE
	slot_flags = SLOT_BACK
	max_w_class = ITEM_SIZE_BULKY
	max_storage_space = DEFAULT_HUGE_STORAGE
	spawn_tags = SPAWN_TAG_BACKPACK
	matter = list(MATERIAL_BIOMATTER = 10, MATERIAL_PLASTIC = 2)
	var/worn_access = FALSE // If the object may be accessed while equipped in a storage slot.
	var/equip_access = TRUE // If the object may be accessed while equipped anywhere on a charcter, including hands.

/obj/item/storage/backpack/Initialize()
	. = ..()
	if (!item_state)
		item_state = icon_state

/obj/item/storage/backpack/attackby(obj/item/W, mob/user)
	if (!worn_check())
		return
	..()

/obj/item/storage/backpack/attack_hand(mob/user)
	if (!worn_check(no_message = TRUE))
		if(src.loc != user || user.incapacitated())
			return
		if (!user.unEquip(src))
			return
		user.put_in_active_hand(src)
		return
	..()

/obj/item/storage/backpack/equipped(mob/user, slot)
	..(user, slot)
	if (use_sound)
		playsound(loc, use_sound, 50, 1, -5)
	if(!worn_access && is_worn()) //currently looking into the backpack
		close(user)


/obj/item/storage/backpack/open(mob/user)
	if (!worn_check())
		return
	..()


/obj/item/storage/backpack/proc/worn_check(no_message = FALSE)
	if(!equip_access && is_equipped())
		var/mob/living/L = loc
		if (istype(L))
			if(!no_message)
				to_chat(L, "<span class='warning'>The [src] is too cumbersome to handle with one hand, you're going to have to set it down somewhere!</span>")
		if (!no_message && use_sound)
			playsound(loc, use_sound, 50, 1, -5)
		return FALSE

	else if(!worn_access && is_worn())
		var/mob/living/L = loc
		if (istype(L))
			if(!no_message)
				to_chat(L, "<span class='warning'>Oh no! Your arms are not long enough to open [src] while it is on your back!</span>")
		if (!no_message && use_sound)
			playsound(loc, use_sound, 50, 1, -5)
		return FALSE

	return TRUE

/*
 * Bag of Holding
 */
/obj/item/storage/backpack/holding
	name = "bag of holding"
	desc = "A backpack that opens into a localized pocket of bluespace."
	origin_tech = list(TECH_BLUESPACE = 4)
	icon_state = "holdingpack"
	max_w_class = ITEM_SIZE_BULKY
	max_storage_space = DEFAULT_HUGE_STORAGE * 2
	matter = list(MATERIAL_STEEL = 10, MATERIAL_GOLD = 10, MATERIAL_DIAMOND = 5, MATERIAL_URANIUM = 5)

/obj/item/storage/backpack/holding/New()
	..()
	bluespace_entropy(6, get_turf(src))

/obj/item/storage/backpack/holding/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/storage/backpack/holding))
		to_chat(user, SPAN_WARNING("The Bluespace interfaces of the two devices conflict and malfunction."))
		qdel(W)
		return
	..()

	//Please don't clutter the parent storage item with stupid hacks.
/obj/item/storage/backpack/holding/can_be_inserted(obj/item/W, stop_messages = 0)
	if(istype(W, /obj/item/storage/backpack/holding))
		return TRUE
	return ..()

/*
 * Backpack Types
 */
/obj/item/storage/backpack/white
	name = "white backpack"
	icon_state = "backpack_white"

/obj/item/storage/backpack/purple
	name = "purple backpack"
	icon_state = "backpack_purple"

/obj/item/storage/backpack/purple/scientist
	name = "scientific backpack"
	desc = "Useful for holding research materials."

/obj/item/storage/backpack/blue
	name = "blue backpack"
	icon_state = "backpack_blue"

/obj/item/storage/backpack/blue/geneticist
	name = "genetical backpack"
	desc = "A sterile backpack with geneticist colours."

/obj/item/storage/backpack/green
	name = "green backpack"
	icon_state = "backpack_green"

/obj/item/storage/backpack/green/virologist
	name = "virological backpack"
	desc = "A sterile backpack with virologist colours."

/obj/item/storage/backpack/orange
	name = "orange backpack"
	icon_state = "backpack_orange"

/obj/item/storage/backpack/orange/chemist
	name = "chemistry backpack"
	desc = "A sterile backpack with chemist colours."

/obj/item/storage/backpack/botanist
	name = "botanical backpack"
	icon_state = "backpack_botanical"
	desc = "A green backpack for plant related work."
	rarity_value = 12.5

/obj/item/storage/backpack/captain
	name = "captain's backpack"
	desc = "It's a special backpack made exclusively for officers."
	icon_state = "backpack_captain"
	rarity_value = 50

/obj/item/storage/backpack/industrial
	name = "industrial backpack"
	desc = "It's a tough backpack for the daily grind of ship life."
	icon_state = "backpack_industrial"
	rarity_value = 8.33

/obj/item/storage/backpack/medical
	name = "medical backpack"
	desc = "It's a backpack especially designed for use in a sterile environment."
	icon_state = "backpack_medical"
	rarity_value = 8.33

/obj/item/storage/backpack/security
	name = "security backpack"
	desc = "It's a very robust backpack."
	icon_state = "backpack_security"
	rarity_value = 8.33

/obj/item/storage/backpack/clown
	name = "Giggles von Honkerton"
	desc = "It's a backpack made by Honk! Co."
	icon_state = "backpack_clown"
	rarity_value = 12.5

//Faction-specific backpacks
/obj/item/storage/backpack/ironhammer
	name = "operator's backpack"
	desc = "Done in a complementing shade for IronHammer Security forces, a staple for military contractors everywhere."
	icon_state = "backpack_ironhammer"
	rarity_value = 25

/obj/item/storage/backpack/neotheology
	name = "cruciformed backpack"
	desc = "For carrying all your holy needs."
	icon_state = "backpack_neotheology"
	rarity_value = 25

//Used by mercenaries
/obj/item/storage/backpack/military
	name = "MOLLE pack"
	desc = "Designed for planetary infantry, holds a lot of equipment."
	icon_state = "backpack_military"
	max_storage_space = DEFAULT_HUGE_STORAGE * 1.3
	rarity_value = 8.33

/*
 * Backsport Types (alternative style)
 */
/obj/item/storage/backpack/sport
	name = "grey sport backpack"
	desc = "A more comfortable version of an old boring backpack."
	icon_state = "backsport"

/obj/item/storage/backpack/sport/white
	name = "white sport backpack"
	icon_state = "backsport_white"

/obj/item/storage/backpack/sport/purple
	name = "purple sport backpack"
	icon_state = "backsport_purple"

/obj/item/storage/backpack/sport/blue
	name = "blue sport backpack"
	icon_state = "backsport_blue"

/obj/item/storage/backpack/sport/green
	name = "green sport backpack"
	icon_state = "backsport_green"

/obj/item/storage/backpack/sport/orange
	name = "orange sport backpack"
	icon_state = "backsport_orange"

/obj/item/storage/backpack/sport/botanist
	name = "botanical sport backpack"
	desc = "A green sport backpack for plant related work."
	icon_state = "backsport_botanical"
	rarity_value = 12.5

//Faction-specific backsports
/obj/item/storage/backpack/sport/ironhammer
	name = "operator's sport backpack"
	desc = "Done in a complementing shade for IronHammer Security forces. It looks as if it belongs on a kindergartener rather than a operative, which is why in actuality this style makes perfect sense."
	icon_state = "backsport_ironhammer"
	rarity_value = 25

/obj/item/storage/backpack/sport/neotheology
	name = "cruciformed sport backpack"
	desc = "For carrying all your holy needs."
	icon_state = "backsport_neotheology"
	rarity_value = 25

/*
 * Satchel Types
 */
/obj/item/storage/backpack/satchel
	name = "grey satchel"
	desc = "A trendy looking satchel."
	icon_state = "satchel"
	max_storage_space = DEFAULT_HUGE_STORAGE * 0.7
	worn_access = TRUE

/obj/item/storage/backpack/satchel/white
	name = "white satchel"
	icon_state = "satchel_white"

/obj/item/storage/backpack/satchel/purple
	name = "purple satchel"
	icon_state = "satchel_purple"

/obj/item/storage/backpack/satchel/purple/scientist
	name = "scientific satchel"
	desc = "Useful for holding research materials."

/obj/item/storage/backpack/satchel/blue
	name = "blue satchel"
	icon_state = "satchel_blue"

/obj/item/storage/backpack/satchel/blue/geneticist
	name = "genetical satchel"
	desc = "A sterile satchel with geneticist colours."

/obj/item/storage/backpack/satchel/green
	name = "green satchel"
	icon_state = "satchel_green"

/obj/item/storage/backpack/satchel/green/virologist
	name = "virological backpack"
	desc = "A sterile backpack with virologist colours."

/obj/item/storage/backpack/satchel/orange
	name = "orange satchel"
	icon_state = "satchel_orange"

/obj/item/storage/backpack/satchel/orange/chemist
	name = "chemistry backpack"
	desc = "A sterile backpack with chemist colours."

/obj/item/storage/backpack/satchel/botanist
	name = "botanical satchel"
	icon_state = "satchel_botanical"
	desc = "A green satchel for plant related work."
	rarity_value = 12.5

/obj/item/storage/backpack/satchel/captain
	name = "captain's satchel"
	desc = "An exclusive satchel for officers."
	icon_state = "satchel_captain"
	rarity_value = 50

/obj/item/storage/backpack/satchel/industrial
	name = "industrial satchel"
	desc = "A tough satchel with extra pockets."
	icon_state = "satchel_industrial"
	rarity_value = 8.33

/obj/item/storage/backpack/satchel/medical
	name = "medical satchel"
	desc = "A sterile satchel used in medical departments."
	icon_state = "satchel_medical"
	rarity_value = 8.33

/obj/item/storage/backpack/satchel/security
	name = "security satchel"
	desc = "A robust satchel for security related needs."
	icon_state = "satchel_security"
	rarity_value = 8.33

/obj/item/storage/backpack/satchel/leather
	name = "leather satchel"
	desc = "It's a very fancy satchel made with fine leather."
	icon_state = "satchel_leather"

/obj/item/storage/backpack/satchel/leather/withwallet
	rarity_value = 4.16

/obj/item/storage/backpack/satchel/leather/withwallet/populate_contents()
	new /obj/item/storage/wallet/random(src)

//Faction-specific satchels
/obj/item/storage/backpack/satchel/ironhammer
	name = "operator's satchel"
	desc = "Done in a complementing shade for IronHammer Security forces, for the itinerant military contractor."
	icon_state = "satchel_ironhammer"
	rarity_value = 12.5

/obj/item/storage/backpack/satchel/neotheology
	name = "cruciformed satchel"
	desc = "Slightly more accessible means for your holy goods."
	icon_state = "satchel_neotheology"
	rarity_value = 12.5

//Used by mercenaries
/obj/item/storage/backpack/satchel/military
	name = "MOLLE patrol pack"
	desc = "Designed for planetary infantry, for quick access to equipment."
	icon_state = "satchel_military"
	max_storage_space = DEFAULT_HUGE_STORAGE * 0.9
	rarity_value = 8.33

/*
 * Duffelbag Types
 */
/obj/item/storage/backpack/duffelbag
	name = "grey duffel bag"
	desc = "You wear this on your back and put items into it."
	icon_state = "duffel"
	max_storage_space = DEFAULT_HUGE_STORAGE * 1.5
	matter = list(MATERIAL_BIOMATTER = 15, MATERIAL_PLASTIC = 2)
	equip_access = FALSE
	rarity_value = 5

/obj/item/storage/backpack/duffelbag/loot
	name = "lootbag"
	icon_state = "lootbag"
	matter = list(MATERIAL_BIOMATTER = 20, MATERIAL_PLASTIC = 3)
	rarity_value = 7.5

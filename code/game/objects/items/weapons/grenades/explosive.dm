/obj/item/grenade/explosive
    name = "NT OBG \"Cracker\""
    desc = "A military-grade offensive blast grenade, designed to be thrown by assaulting troops."
    icon_state = "explosive"
    loadable = TRUE

    var/devastation_range = -1
    var/heavy_range = 1
    var/weak_range = 4
    var/flash_range = 10


/obj/item/grenade/explosive/prime()
    set waitfor = 0
    ..()
    var/turf/O = get_turf(src)
    if(!O) return

    on_explosion(O)

    qdel(src)

/obj/item/grenade/explosive/proc/on_explosion(var/turf/O)
	explosion(O, devastation_range, heavy_range, weak_range, flash_range)

/obj/item/grenade/explosive/nt
	name = "NT OBG \"Holy Grail\""
	desc = "There's an inscription along the bands. \'And the Lord spake, saying: First shalt thou take out the Holy Pin. Then, shalt thou count to three, no more, no less. Three shall be the number thou shalt count, and the number of the counting shall be three. Four shalt thou not count, nor either count thou two, excepting that thou then proceed to three. Five is right out! Once the number three, being the third number, be reached, then lobbest thou thy Holy Hand Grenade of Antioch towards thou foe, who being naughty in my sight, shall snuff it.\'"
	icon_state = "explosive_nt"
	item_state = "explosive_nt"
	heavy_range = 1
	weak_range = 5
	matter = list(MATERIAL_BIOMATTER = 100)

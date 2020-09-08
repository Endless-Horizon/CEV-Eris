//Define a macro that we can use to assemble all the circuit board names
#ifdef T_BOARD
#error T_BOARD already defined elsewhere, we can't use it.
#endif
#define T_BOARD(name)	"circuit board (" + (name) + ")"

/obj/item/weapon/electronics
	spawn_tags = SPAWN_TAG_ELECTRONICS
	rarity_value = 20
	spawn_frequency = 10
	bad_types = /obj/item/weapon/electronics
	hitsound = "swing_hit"

/obj/item/weapon/electronics/Bump(mob/M)
	spawn(0)
		..()
	return

/obj/item/weapon/electronics/circuitboard
	name = "circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	origin_tech = list(TECH_DATA = 2)
	matter = list(MATERIAL_PLASTIC = 2, MATERIAL_STEEL = 2)
	matter_reagents = list("silicon" = 10)
	density = FALSE
	anchored = FALSE
	w_class = ITEM_SIZE_SMALL
	flags = CONDUCT
	force = WEAPON_FORCE_HARMLESS
	throwforce = WEAPON_FORCE_HARMLESS
	throw_speed = 3
	throw_range = 15
	bad_types = /obj/item/weapon/electronics/circuitboard

	var/build_path
	var/frame_type = FRAME_DEFAULT
	var/board_type = "computer"
	var/list/req_components

//Called when the circuitboard is used to contruct a new machine.
/obj/item/weapon/electronics/circuitboard/proc/construct(obj/machinery/M)
	if (istype(M, build_path))
		return TRUE
	return FALSE

//Called when a computer is deconstructed to produce a circuitboard.
//Only used by computers, as other machines store their circuitboard instance.
/obj/item/weapon/electronics/circuitboard/proc/deconstruct(obj/machinery/M)
	if (istype(M, build_path))
		return TRUE
	return FALSE

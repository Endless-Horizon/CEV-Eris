/obj/item/device
	icon = 'icons/obj/device.dmi'
	spawn_tags = SPAWN_TAG_DIVICE
	bad_type = /obj/item/device
	var/starting_cell = TRUE
	var/obj/item/cell/cell
	var/suitable_cell

/obj/item/device/Initialize(mapload)
	. = ..()
	make_starting_cell()

/obj/item/device/Created()
	.=..()
	QDEL_NULL(cell)

/obj/item/device/Destroy()
	QDEL_NULL(cell)
	. = ..()

/obj/item/device/proc/make_starting_cell()
	if(!cell && suitable_cell && starting_cell)
		cell = new suitable_cell(src)

/obj/item/device/get_cell()
	return cell

/obj/item/device/handle_atom_del(atom/A)
	..()
	if(A == cell)
		cell = null
		update_icon()

/obj/item/device/MouseDrop(over_object)
	if((loc == usr) && suitable_cell && istype(over_object, /obj/screen/inventory/hand) && eject_item(cell, usr))
		cell = null
		return
	. = ..()

/obj/item/device/attackby(obj/item/C, mob/living/user)
	if(istype(C, suitable_cell))
		if(cell)
			to_chat(user, "There is a [cell] already installed here.")
		else if(insert_item(C, user))
			cell = C
		update_icon()
		return
	. = ..()

/obj/item/device/examine(mob/user)
	. = ..()
	if(suitable_cell)
		if(cell)
			to_chat(user, SPAN_NOTICE("\The [src]'s cell reads \"[round(cell.percent(),0.1)]%\""))
		else
			to_chat(user, SPAN_WARNING("\The [src] has no cell installed."))

/obj/item/device/proc/cell_use_check(charge, mob/user)
	. = TRUE
	if(!cell || !cell.checked_use(charge))
		if(user)
			to_chat(user, SPAN_WARNING("[src] battery is dead or missing."))
		. = FALSE

/obj/item/device/proc/cell_check(charge, mob/user)
	. = TRUE
	if(!cell || !cell.check_charge(charge))
		if(user)
			to_chat(user, SPAN_WARNING("[src] battery is dead or missing."))
		. = FALSE

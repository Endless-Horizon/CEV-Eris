/obj/item/clothing/glasses/powered
	name = "Powered Goggles"
	icon_state = "night"
	item_state = "glasses"
	action_button_name = "Toggle Optical Matrix"
	toggleable = TRUE
	prescription = TRUE
	active = FALSE
	bad_type = /obj/item/clothing/glasses/powered
	var/tick_cost = 1
	var/obj/item/cell/cell
	var/suitable_cell = /obj/item/cell/small

/obj/item/clothing/glasses/powered/Initialize()
	. = ..()
	if(!cell && suitable_cell)
		cell = new /obj/item/cell/small(src)

/obj/item/clothing/glasses/powered/Process()
	if(active)
		if(!cell || !cell.checked_use(tick_cost))
			if(ismob(src.loc))
				to_chat(src.loc, SPAN_WARNING("[src] shut down."))
			toggle(ismob(loc) && loc, FALSE)

/obj/item/clothing/glasses/powered/get_cell()
	return cell

/obj/item/clothing/glasses/powered/handle_atom_del(atom/A)
	..()
	if(A == cell)
		cell = null

/obj/item/clothing/glasses/powered/toggle(mob/user, new_state)
	if(new_state)
		if(!cell || !cell.check_charge(tick_cost) && user)
			to_chat(user, SPAN_WARNING("[src] battery is dead or missing."))
			return
	..(user, new_state)

/obj/item/clothing/glasses/powered/MouseDrop(over_object)
	if((src.loc == usr) && istype(over_object, /obj/screen/inventory/hand) && eject_item(cell, usr))
		cell = null

/obj/item/clothing/glasses/powered/attackby(obj/item/C, mob/living/user)
	if(istype(C, suitable_cell) && !cell && insert_item(C, user))
		src.cell = C

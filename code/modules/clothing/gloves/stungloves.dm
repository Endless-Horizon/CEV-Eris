/obj/item/clothing/gloves/stungloves
	name = "FS Power Glove"
	desc = "Frozen Star solution for police operations. Punch criminals right in the face instead of prodding them with some feeble rod."
	icon_state = "powerglove"
	item_state = "bgloves"
	action_button_name = "Toggle Power Glove"
	price_tag = 500
	var/stunforce = 0
	var/agonyforce = 30
	var/status = FALSE		//whether the thing is on or not
	var/hitcost = 100
	var/obj/item/cell/cell
	var/suitable_cell = /obj/item/cell/medium

/obj/item/clothing/gloves/stungloves/Initialize()
	. = ..()
	cell = new /obj/item/cell/medium/high(src)
	update_icon()

/obj/item/clothing/gloves/stungloves/get_cell()
	return cell

/obj/item/clothing/gloves/stungloves/handle_atom_del(atom/A)
	..()
	if(A == cell)
		cell = null
		update_icon()

/obj/item/clothing/gloves/stungloves/proc/deductcharge(var/power_drain)
	if(cell)
		if(cell.checked_use(power_drain))
			//do we have enough power for another hit?
			if(!cell.check_charge(hitcost))
				status = FALSE
				update_icon()
			return TRUE
		else
			status = FALSE
			update_icon()
			return FALSE

/obj/item/clothing/gloves/stungloves/on_update_icon()
	if(status)
		icon_state = "powerglove_active"
	else
		icon_state = "powerglove"
	update_wear_icon()

	if(ismob(usr))
		usr.update_action_buttons()

/obj/item/clothing/gloves/stungloves/examine(mob/user)
	if(!..(user, 1))
		return

	if(cell)
		to_chat(user, SPAN_NOTICE("Power Glove is [round(cell.percent())]% charged."))
	else
		to_chat(user, SPAN_WARNING("Power Glove does not have a power source installed."))

/obj/item/clothing/gloves/stungloves/attack_self(mob/user)
	if(cell && cell.check_charge(hitcost))
		status = !status
		to_chat(user, "<span class='notice'>[src] is now [status ? "on" : "off"].</span>")
		playsound(loc, "sparks", 75, 1, -1)
		update_icon()
	else
		status = FALSE
		if(!cell)
			to_chat(user, SPAN_WARNING("[src] does not have a power source!"))
		else
			to_chat(user, SPAN_WARNING("[src] is out of charge."))
	add_fingerprint(user)

/obj/item/clothing/gloves/stungloves/Touch(mob/living/L, var/proximity)
	if(!status)
		return FALSE
	if(!istype(L) || !proximity)
		return ..()
	if(isrobot(L))
		return ..()

	var/mob/living/user = loc
	var/agony = agonyforce
	var/stun = stunforce
	var/obj/item/organ/external/affecting = null
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		affecting = H.get_organ(user.targeted_organ)

	//stun effects
	if(affecting)
		L.visible_message(SPAN_DANGER("[L] has been punched in the [affecting.name] with [src] by [user]!"))
	else
		L.visible_message(SPAN_DANGER("[L] has been punched with [src] by [user]!"))
	playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)

	if(deductcharge(hitcost))
		L.stun_effect_act(stun, agony, user.targeted_organ, src)
		msg_admin_attack("[key_name(user)] stunned [key_name(L)] with the [src].")
		user.attack_log += "\[[time_stamp()]\] <font color='red'>Stunned [key_name(L)] with [src]</font>"
		L.attack_log += "\[[time_stamp()]\] <font color='orange'>Was stunned by [key_name(L)] with [src]</font>"

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.forcesay(hit_appends)


/obj/item/clothing/gloves/stungloves/emp_act(severity)
	if(cell)
		cell.emp_act(severity)	//let's not duplicate code everywhere if we don't have to please.
	..()

/obj/item/clothing/gloves/stungloves/MouseDrop(over_object)
	if((src.loc == usr) && istype(over_object, /obj/screen/inventory/hand) && eject_item(cell, usr))
		cell = null
		status = FALSE
		update_icon()

/obj/item/clothing/gloves/stungloves/attackby(obj/item/C, mob/living/user)
	if(istype(C, suitable_cell) && !cell && insert_item(C, user))
		src.cell = C
		update_icon()

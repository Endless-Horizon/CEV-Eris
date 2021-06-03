/obj/item/device/radio/exosuit
	name = "exosuit radio"
	spawn_tags = null

/obj/item/device/radio/exosuit/get_cell()
	. = ..()
	if(!.)
		var/mob/living/exosuit/E = loc
		if(istype(E)) return E.get_cell()

/obj/item/device/radio/exosuit/nano_host()
	var/mob/living/exosuit/E = loc
	if(istype(E))
		return E
	return null

/obj/item/device/radio/exosuit/attack_self(var/mob/user)
	var/mob/living/exosuit/exosuit = loc
	if(istype(exosuit) && exosuit.head && exosuit.head.radio && exosuit.head.radio.is_functional())
		user.set_machine(src)
		interact(user)
	else
		to_chat(user, SPAN_WARNING("The radio is too damaged to function."))

/obj/item/device/radio/exosuit/CanUseTopic()
	. = ..()
	if(.)
		var/mob/living/exosuit/exosuit = loc
		if(istype(exosuit) && exosuit.head && exosuit.head.radio && exosuit.head.radio.is_functional())
			return ..()

/obj/item/device/radio/exosuit/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = NANOUI_FOCUS, datum/topic_state/state = GLOB.mech_state)
	. = ..()

/obj/item/device/shield_diffuser
	name = "portable shield diffuser"
	desc = "A small handheld device designed to disrupt energy barriers"
	description_info = "This device disrupts shields on directly adjacent tiles (in a + shaped pattern), in a similar way the floor mounted variant does. It is, however, portable and run by an internal battery. Can be recharged with a regular recharger."
	icon = 'icons/obj/machines/shielding.dmi'
	icon_state = "hdiffuser_off"
	suitable_cell = /obj/item/cell/small
	spawn_frequency = 0
	var/active_power_use = 10 KILOWATTS * CELLRATE
	var/enabled = 0

/obj/item/device/shield_diffuser/on_update_icon()
	if(enabled)
		SetIconState("hdiffuser_on")
	else
		SetIconState("hdiffuser_off")

/obj/item/device/shield_diffuser/Destroy()
	if(enabled)
		turn_off()
	. = ..()

/obj/item/device/shield_diffuser/Process()
	if(!enabled)
		return
	for(var/direction in cardinal)
		var/turf/simulated/shielded_tile = get_step(get_turf(src), direction)
		for(var/obj/effect/shield/S in shielded_tile)
			// 10kJ per pulse, but gap in the shield lasts for longer than regular diffusers.
			if(istype(S) && !S.diffused_for && !S.disabled_for && cell.checked_use(active_power_use))
				S.diffuse(20)

	if(!cell_check(active_power_use))
		turn_off()


/obj/item/device/shield_diffuser/attack_self(mob/user)
	if(enabled)
		turn_off(user)
	else
		turn_on(user)
	update_icon()


/obj/item/device/shield_diffuser/proc/turn_on(mob/user)
	if(cell_check(active_power_use, user))
		START_PROCESSING(SSobj, src)
		enabled = TRUE
		to_chat(usr, "\the [src] clicks [enabled ? "on" : "off"].")
	else
		to_chat(usr, "\the [src] clicks uselessly.")
	playsound(loc, 'sound/machines/button.ogg', 50, 1)


/obj/item/device/shield_diffuser/proc/turn_off(mob/user)
	STOP_PROCESSING(SSobj, src)
	enabled = FALSE
	to_chat(user, "\the [src] clicks [enabled ? "on" : "off"].")
	playsound(loc, 'sound/machines/button.ogg', 50, 1)

/obj/item/device/shield_diffuser/examine()
	. = ..()
	to_chat(usr, "It is [enabled ? "enabled" : "disabled"].")
	to_chat(usr, "It has enough charge for [cell ? round(cell.charge / active_power_use) : 0] more uses.")

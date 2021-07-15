/obj/item/tank/onestar_regenerator
	name = "OS Type - 13 \"Tiantipenquan\""
	desc = "This oxygen regenerator can provide seemingly endless supply for one human to breathe."
	icon_state = "onestar_regenerator"
	gauge_icon = null
	gauge_cap = 4
	flags = CONDUCT
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_SMALL
	force = WEAPON_FORCE_NORMAL
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	volume = 2
	spawn_blacklisted = TRUE
	spawn_tags = SPAWN_TAG_ITEM_TECH_OS

/obj/item/tank/onestar_regenerator/Initialize(mapload, ...)
	. = ..()
	ensure_breath()

/obj/item/tank/onestar_regenerator/examine(mob/user)
	. = ..(user, 0)


/obj/item/tank/onestar_regenerator/remove_air(amount)
	var/datum/gas_mixture/M = air_contents.remove(amount)
	if(istype(loc, /mob/living/carbon))
		var/mob/living/carbon/C = loc
		if(C.internal == src)
			ensure_breath()
			air_contents.merge(M)

	return M

/obj/item/tank/onestar_regenerator/update_gauge()
	return

/obj/item/tank/onestar_regenerator/proc/ensure_breath()
	if(!("oxygen" in air_contents.gas) || air_contents.total_moles < BREATH_MOLES*2)
		air_contents.adjust_gas("oxygen", BREATH_MOLES*2-air_contents.total_moles)



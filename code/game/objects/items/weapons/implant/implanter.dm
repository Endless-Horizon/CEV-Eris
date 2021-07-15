/obj/item/implanter
	name = "implanter"
	icon = 'icons/obj/items.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_PLASTIC = 2, MATERIAL_STEEL = 1)
	var/obj/item/implant/implant
	spawn_tags = SPAWN_TAG_JUNK
	rarity_value = 6

/obj/item/implanter/New()
	..()
	if(ispath(implant))
		implant = new implant(src)
		update_icon()


/obj/item/implanter/attack_self(mob/user)
	if(!implant)
		return ..()
	user.put_in_hands(implant)
	to_chat(user, SPAN_NOTICE("You remove \the [implant] from \the [src]."))
	name = "implanter"
	implant = null
	update_icon()
	return

/obj/item/implanter/on_update_icon()
	if(implant)
		icon_state = "implanter1"
	else
		icon_state = "implanter0"
	return

/obj/item/implanter/attack(mob/living/M, mob/living/user)
	if(!istype(M) || !implant)
		return
	if(!implant.is_external())
		if(M.body_part_covered(user.targeted_organ))
			to_chat(user, SPAN_WARNING("You can't implant through clothes."))
			return

	var/obj/item/organ/external/affected = null
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		affected = H.get_organ(user.targeted_organ)

	M.visible_message(SPAN_WARNING("[user] is attemping to implant [M]."))

	user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	user.do_attack_animation(M)

	if(do_mob(user, M, 50) && src && implant)


		if(implant.install(M, user.targeted_organ, user))
			M.visible_message(
			SPAN_WARNING("[user] has implanted [M] in [affected]."),
			SPAN_NOTICE("You implanted \the [implant] into [M]'s [affected].")
			)

			admin_attack_log(user, M,
			"Implanted using \the [src.name] ([implant.name])",
			"Implanted with \the [src.name] ([implant.name])",
			"used an implanter, [src.name] ([implant.name]), on"
			)

			if(istype(implant, /obj/item/implant/excelsior) && ishuman(M))
				var/datum/faction/F = get_faction_by_id(FACTION_EXCELSIOR)
				var/datum/objective/timed/excelsior/E = (locate(/datum/objective/timed/excelsior) in F.objectives)
				if(E)
					if(!E.active)
						E.start_excel_timer()
					else
						E.on_convert()

			implant = null
			update_icon()

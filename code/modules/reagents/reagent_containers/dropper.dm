////////////////////////////////////////////////////////////////////////////////
/// Droppers.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/dropper
	name = "dropper"
	desc = "A dropper. Transfers 5 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dropper"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(1,2,3,4,5)
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	matter = list(MATERIAL_GLASS = 1, MATERIAL_PLASTIC = 1)
	volume = 5
	reagent_flags = TRANSPARENT
	spawn_tags = SPAWN_TAG_JUNK
	rarity_value = 10

/obj/item/reagent_containers/dropper/afterattack(atom/target, mob/user, proximity)
	if(!target.reagents || !proximity)
		return

	if(reagents.total_volume)
		if(!target.reagents.get_free_space())
			to_chat(user, SPAN_NOTICE("[target] is full."))
			return

		if(!ismob(target) && !target.is_injectable()) //You can inject humans and food but you cant remove the shit.
			to_chat(user, SPAN_NOTICE("You cannot directly fill this object."))
			return

		var/trans = 0

		if(ismob(target))
			var/time = 20 //2/3rds the time of a syringe

			if(target != user)
				user.visible_message(SPAN_WARNING("[user] is trying to squirt something into [target]'s eyes!"))

				if(!do_mob(user, target, time))
					return

			if(ishuman(target))
				var/mob/living/carbon/human/victim = target

				var/obj/item/safe_thing = null
				if(victim.wear_mask)
					if (victim.wear_mask.body_parts_covered & EYES)
						safe_thing = victim.wear_mask
				if(victim.head)
					if (victim.head.body_parts_covered & EYES)
						safe_thing = victim.head
				if(victim.glasses)
					if (!safe_thing)
						safe_thing = victim.glasses

				if(safe_thing)
					trans = reagents.trans_to_obj(safe_thing, amount_per_transfer_from_this)
					user.visible_message(
						SPAN_WARNING("[user] tries to squirt something into [target]'s eyes, but fails!"),
						SPAN_NOTICE("You transfer [trans] units of the solution.")
					)
					return

			var/mob/living/M = target
			var/contained = reagents.log_list()
			M.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been squirted with [name] by [user.name] ([user.ckey]). Reagents: [contained]</font>"
			user.attack_log += "\[[time_stamp()]\] <font color='red'>Used the [name] to squirt [M.name] ([M.key]). Reagents: [contained]</font>"
			msg_admin_attack("[user.name] ([user.ckey]) squirted [M.name] ([M.key]) with [name]. Reagents: [contained] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

			trans = reagents.trans_to_mob(target, reagents.total_volume, CHEM_BLOOD)
			user.visible_message(
				SPAN_WARNING("[user] squirts something into [target]'s eyes!"),
				SPAN_NOTICE("You transfer [trans] units of the solution.")
			)

			return

		else
			//sprinkling reagents on generic non-mobs
			trans = reagents.trans_to(target, amount_per_transfer_from_this)
			to_chat(user, SPAN_NOTICE("You transfer [trans] units of the solution."))

	else // Taking from something
		if(!target.is_drainable())
			to_chat(user, SPAN_NOTICE("You cannot directly remove reagents from [target]."))
			return

		if(!target.reagents.total_volume)
			to_chat(user, SPAN_NOTICE("[target] is empty."))
			return

		var/trans = target.reagents.trans_to_obj(src, amount_per_transfer_from_this)

		to_chat(user, SPAN_NOTICE("You fill the dropper with [trans] units of the solution."))

	return

/obj/item/reagent_containers/dropper/on_update_icon()
	cut_overlays()
	if(reagents.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "dropper")
		filling.color = reagents.get_color()
		add_overlay(filling)

/obj/item/reagent_containers/dropper/industrial
	name = "industrial dropper"
	desc = "A large dropper. Transfers 10 units."
	matter = list(MATERIAL_GLASS = 2, MATERIAL_PLASTIC = 1)
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1,2,3,4,5,6,7,8,9,10)
	volume = 10

////////////////////////////////////////////////////////////////////////////////
/// Droppers. END
////////////////////////////////////////////////////////////////////////////////

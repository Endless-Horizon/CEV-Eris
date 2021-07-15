/obj/structure/medical_stand
	name = "medical stand"
	icon = 'icons/obj/medical_stand.dmi'
	desc = "Medical stand used to hang reagents for transfusion and to hold anesthetic tank."
	icon_state = "medical_stand_empty"

	//gas stuff
	var/obj/item/tank/tank
	var/mob/living/carbon/human/breather
	var/obj/screen/internalsHud
	var/obj/item/clothing/mask/breath/contained

	var/spawn_type = null
	var/mask_type = /obj/item/clothing/mask/breath/medical

	var/is_loosen = TRUE
	var/valve_opened = FALSE
	//blood stuff
	var/mob/living/carbon/attached
	var/mode = 1 // 1 is injecting, 0 is taking blood.
	var/obj/item/reagent_containers/beaker
	var/list/transfer_amounts = list(REM, 1, 2)
	var/transfer_amount = 1

/obj/structure/medical_stand/New()
	..()
	if (spawn_type)
		tank = new spawn_type (src)
	contained = new mask_type (src)
	update_icon()

/obj/structure/medical_stand/on_update_icon()
	cut_overlays()

	if (tank)
		if (breather)
			add_overlays("tube_active")
		else
			add_overlays("tube")
		if(istype(tank,/obj/item/tank/anesthetic))
			add_overlays("tank_anest")
		else if(istype(tank,/obj/item/tank/nitrogen))
			add_overlays("tank_nitro")
		else if(istype(tank,/obj/item/tank/oxygen))
			add_overlays("tank_oxyg")
		else if(istype(tank,/obj/item/tank/plasma))
			add_overlays("tank_plasma")
		//else if(istype(tank,/obj/item/tank/hydrogen))
		//	add_overlays("tank_hydro")
		else
			add_overlays("tank_other")

	if(beaker)
		add_overlays("beaker")
		if(attached)
			add_overlays("line_active")
		else
			add_overlays("line")
		var/datum/reagents/reagents = beaker.reagents
		var/percent = round((reagents.total_volume / beaker.volume) * 100)
		if(reagents.total_volume)
			var/image/filling = image('icons/obj/medical_stand.dmi', src, "reagent")

			switch(percent)
				if(10 to 24) 	filling.icon_state = "reagent10"
				if(25 to 49)	filling.icon_state = "reagent25"
				if(50 to 74)	filling.icon_state = "reagent50"
				if(75 to 79)	filling.icon_state = "reagent75"
				if(80 to 90)	filling.icon_state = "reagent80"
				if(91 to INFINITY)	filling.icon_state = "reagent100"
			if (filling.icon)
				filling.icon += reagents.get_color()
				add_overlays(filling)

/obj/structure/medical_stand/Destroy()
	STOP_PROCESSING(SSobj,src)
	if(breather)
		breather.internal = null
		if(internalsHud)
			internalsHud.icon_state = "internal0"
	if(tank)
		qdel(tank)
	if(breather)
		breather.remove_from_mob(contained)
		src.visible_message(SPAN_NOTICE("The mask rapidly retracts just before /the [src] is destroyed!"))
	qdel(contained)
	contained = null
	breather = null

	attached = null
	qdel(beaker)
	beaker = null
	return ..()

/obj/structure/medical_stand/attack_robot(var/mob/user)
	if(Adjacent(user))
		attack_hand(user)

/obj/structure/medical_stand/MouseDrop(var/mob/living/carbon/human/target, src_location, over_location)
	..()
	if(istype(target))
		if(usr.stat == DEAD || !CanMouseDrop(target))
			return
		var/list/available_options = list()
		if (tank)
			available_options += "Gas mask"
		if (beaker)
			available_options += "Drip needle"

		var/action_type
		if(available_options.len > 1)
			action_type = input(usr, "What do you want to attach/detach?") as null|anything in available_options
		else if(available_options.len)
			action_type = available_options[1]
		if(usr.stat == DEAD || !CanMouseDrop(target))
			return
		switch (action_type)
			if("Gas mask")
				if(!can_apply_to_target(target, usr)) // There is no point in attempting to apply a mask if it's impossible.
					return
				if (breather)
					src.add_fingerprint(usr)
					if(!do_mob(usr, target, 20) || !can_apply_to_target(target, usr))
						return
					if(tank)
						tank.forceMove(src)
					if (breather.wear_mask == contained)
						breather.remove_from_mob(contained)
						contained.forceMove(src)
					else
						qdel(contained)
						contained = new mask_type(src)
					breather = null
					src.visible_message(SPAN_NOTICE("\The [contained] slips to \the [src]!"))
					update_icon()
					return
				usr.visible_message(SPAN_NOTICE("\The [usr] begins carefully placing the mask onto [target]."),
							SPAN_NOTICE("You begin carefully placing the mask onto [target]."))
				if(!do_mob(usr, target, 20) || !can_apply_to_target(target, usr))
					return
				// place mask and add fingerprints
				usr.visible_message(SPAN_NOTICE("\The [usr] has placed \the mask on [target]'s mouth."),
									SPAN_NOTICE("You have placed \the mask on [target]'s mouth."))
				if(attach_mask(target))
					src.add_fingerprint(usr)
					update_icon()
					START_PROCESSING(SSobj,src)
				return
			if("Drip needle")
				if(attached)
					if(!do_mob(usr, target, 10))
						return
					visible_message("\The [attached] is taken off \the [src]")
					attached = null
				else if(ishuman(target))
					usr.visible_message(SPAN_NOTICE("\The [usr] begins inserting needle into [target]'s vein."),
									SPAN_NOTICE("You begin inserting needle into [target]'s vein."))
					if(!do_mob(usr, target, 10))
						usr.visible_message(SPAN_NOTICE("\The [usr]'s hand slips and pricks \the [target]."),
									SPAN_NOTICE("Your hand slips and pricks \the [target]."))
						target.apply_damage(3, BRUTE, pick(BP_R_ARM, BP_L_ARM), used_weapon = "Drip needle")
						return
					usr.visible_message(SPAN_NOTICE("\The [usr] hooks \the [target] up to \the [src]."),
									SPAN_NOTICE("You hook \the [target] up to \the [src]."))
					attached = target
					START_PROCESSING(SSobj,src)
				update_icon()


/obj/structure/medical_stand/attack_hand(mob/user as mob)
	var/list/available_options = list()
	if (tank)
		available_options += "Toggle valve"
		available_options += "Remove tank"
	if (beaker)
		available_options += "Remove vessel"

	var/action_type
	if(available_options.len > 1)
		action_type = input(user, "What do you want to do?") as null|anything in available_options
	else if(available_options.len)
		action_type = available_options[1]
	switch (action_type)
		if ("Remove tank")
			if (!tank)
				to_chat(user, SPAN_WARNING("There is no tank in \the [src]!"))
				return
			else if (tank && is_loosen)
				user.visible_message(SPAN_NOTICE("\The [user] removes \the [tank] from \the [src]."), SPAN_WARNING("You remove \the [tank] from \the [src]."))
				user.put_in_hands(tank)
				tank = null
				update_icon()
				return
			else if (!is_loosen)
				user.visible_message(SPAN_NOTICE("\The [user] tries to removes \the [tank] from \the [src] but it won't budge."), SPAN_WARNING("You try to removes \the [tank] from \the [src] but it won't budge."))
				return
		if ("Toggle valve")
			if (!tank)
				to_chat(user, SPAN_WARNING("There is no tank in \the [src]!"))
				return
			else
				if (valve_opened)
					src.visible_message(SPAN_NOTICE("\The [user] closes valve on \the [src]!"),
						SPAN_NOTICE("You close valve on \the [src]."))
					if(breather)
						if(internalsHud)
							internalsHud.icon_state = "internal0"
						breather.internal = null
					valve_opened = FALSE
					update_icon()
				else
					src.visible_message(SPAN_NOTICE("\The [user] opens valve on \the [src]!"),
										SPAN_NOTICE("You open valve on \the [src]."))
					if(breather)
						breather.internal = tank
						if(internalsHud)
							internalsHud.icon_state = "internal1"
					valve_opened = TRUE
					playsound(get_turf(src), 'sound/effects/internals.ogg', 100, 1)
					update_icon()
					START_PROCESSING(SSobj,src)
		if ("Remove vessel")
			if(beaker)
				beaker.forceMove(loc)
				beaker = null
				update_icon()

/obj/structure/medical_stand/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle IV Mode"
	set src in view(1)

	if(!istype(usr, /mob/living))
		to_chat(usr, SPAN_WARNING("You can't do that."))
		return

	if(usr.incapacitated())
		return

	mode = !mode
	to_chat(usr, "The IV drip is now [mode ? "injecting" : "taking blood"].")

/obj/structure/medical_stand/verb/set_APTFT()
	set name = "Set IV transfer amount"
	set category = "Object"
	set src in range(1)
	var/N = input("Amount per transfer from this:","[src]") as null|anything in transfer_amounts
	if(N)
		transfer_amount = N

/obj/structure/medical_stand/proc/attach_mask(var/mob/living/carbon/C)
	if(C && istype(C))
		if(C.equip_to_slot_if_possible(contained, slot_wear_mask))
			if(tank)
				tank.forceMove(C)
			breather = C
			if(breather.HUDneed.Find("internal"))
				internalsHud = breather.HUDneed["internal"]
			return TRUE

/obj/structure/medical_stand/proc/can_apply_to_target(var/mob/living/carbon/human/target, var/mob/user)
	if(!user)
		user = target
	// Check target validity
	if(!istype(target))
		to_chat(user, SPAN_WARNING("\The [target] not compatible with machine."))
		return
	if(!target.organs_by_name[BP_HEAD])
		to_chat(user, SPAN_WARNING("\The [target] doesn't have a head."))
		return
	if(!target.check_has_mouth())
		to_chat(user, SPAN_WARNING("\The [target] doesn't have a mouth."))
		return
	if(target.wear_mask && target != breather)
		to_chat(user, SPAN_WARNING("\The [target] is already wearing a mask."))
		return
	if(target.head && (target.head.body_parts_covered & FACE))
		to_chat(user, SPAN_WARNING("Remove their [target.head] first."))
		return
	if(!tank)
		to_chat(user, SPAN_WARNING("There is no tank in \the [src]."))
		return
	if(is_loosen)
		to_chat(user, SPAN_WARNING("Tighten \the nut with a wrench first."))
		return
	if(!Adjacent(target))
		return
	//when there is a breather:
	if(breather && target != breather)
		to_chat(user, SPAN_WARNING("\The [src] is already in use."))
		return
	//Checking if breather is still valid
	if(target == breather && target.wear_mask != contained)
		to_chat(user, SPAN_WARNING("\The [target] is not using the supplied mask."))
		return
	return 1

/obj/structure/medical_stand/attackby(obj/item/W, mob/user)
	if(istool(W))
		if(valve_opened)
			to_chat(user, SPAN_WARNING("Close the valve first."))
			return
		if(tank)
			if(!W.use_tool(user, src, WORKTIME_NEAR_INSTANT, QUALITY_BOLT_TURNING, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
				return
			if(!is_loosen)
				is_loosen = TRUE
			else
				is_loosen = FALSE
				if (valve_opened)
					START_PROCESSING(SSobj,src)
			user.visible_message(
			SPAN_NOTICE("The [user] [is_loosen == TRUE ? "loosen" : "tighten"] the nut holding [tank] in place."),
			SPAN_NOTICE("You [is_loosen == TRUE ? "loosen" : "tighten"] the nut holding [tank] in place."))

		else
			to_chat(user, SPAN_WARNING("There is no tank in \the [src]."))

	else if(istype(W, /obj/item/tank))
		if(tank)
			to_chat(user, SPAN_WARNING("\The [src] already has a tank installed!"))
		else if(!is_loosen)
			to_chat(user, SPAN_WARNING("Loosen the nut with a wrench first."))
		else
			user.drop_item()
			W.forceMove(src)
			tank = W
			user.visible_message(SPAN_NOTICE("\The [user] attaches \the [tank] to \the [src]."), SPAN_NOTICE("You attach \the [tank] to \the [src]."))
			src.add_fingerprint(user)
			update_icon()

	else if (istype(W, /obj/item/reagent_containers))
		if(!isnull(src.beaker))
			to_chat(user, "There is already a reagent container loaded!")
			return
		user.drop_item()
		W.forceMove(src)
		beaker = W
		to_chat(user, "You attach \the [W] to \the [src].")
		update_icon()
	else
		return ..()

/obj/structure/medical_stand/examine(mob/user)
	. = ..()

	if (get_dist(src, user) > 2)
		return

	if(beaker)
		to_chat(user, "The IV drip is [mode ? "injecting" : "taking blood"].")
		to_chat(user, "It is set to transfer [transfer_amount]u of chemicals per cycle.")
		if(beaker.reagents && beaker.reagents.total_volume)
			to_chat(user, SPAN_NOTICE("Attached is \a [beaker] with [beaker.reagents.total_volume] units of liquid."))
		else
			to_chat(user, SPAN_NOTICE("Attached is an empty [beaker]."))
		to_chat(user, SPAN_NOTICE("[attached ? attached : "No one"] is hooked up to it."))
	else
		to_chat(user, SPAN_NOTICE("There is no vessel."))

	if(tank)
		if (!is_loosen)
			to_chat(user, "\The [tank] connected.")
		to_chat(user, "The meter shows [round(tank.air_contents.return_pressure())]. The valve is [valve_opened == TRUE ? "open" : "closed"].")
		if (tank.distribute_pressure == 0)
			to_chat(user, "Use wrench to replace tank.")
	else
		to_chat(user, SPAN_NOTICE("There is no tank."))

/obj/structure/medical_stand/Process()
	//Gas Stuff
	if(breather)
		if(!can_apply_to_target(breather))
			if(tank)
				tank.forceMove(src)
			if (breather.wear_mask == contained)
				breather.remove_from_mob(contained)
				contained.forceMove(src)
			else
				qdel(contained)
				contained = new mask_type (src)
			src.visible_message(SPAN_NOTICE("\The [contained] slips to \the [src]!"))
			breather = null
			update_icon()
			return
		if(valve_opened)
			if (tank)
				breather.internal = tank
				if(internalsHud)
					internalsHud.icon_state = "internal1"
		else
			if(internalsHud)
				internalsHud.icon_state = "internal0"
			breather.internal = null
	else if (tank && valve_opened)
		var/datum/gas_mixture/removed = tank.remove_air(0.01)
		var/datum/gas_mixture/environment = loc.return_air()
		environment.merge(removed)

	//Reagent Stuff
	if(attached)
		if(!Adjacent(attached))
			visible_message("The needle is ripped out of [src.attached], doesn't that hurt?")
			attached.apply_damage(3, BRUTE, pick(BP_R_ARM, BP_L_ARM), used_weapon = "Drip needle")
			attached = null
			update_icon()

	if(beaker)
		if(mode) // Give blood
			if(beaker.volume > 0)
				beaker.reagents.trans_to_mob(attached, transfer_amount, CHEM_BLOOD)
				update_icon()
		else // Take blood
			var/amount = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			amount = min(amount, 4)

			if(amount == 0) // If the beaker is full, ping
				if(prob(5)) visible_message("\The [src] pings.")
				return

			var/mob/living/carbon/human/H = attached
			if(!istype(H))
				return
			if(!H.dna)
				return
			if(NOCLONE in H.mutations)
				return
			if(H.species.flags & NO_BLOOD)
				return
			if(!H.should_have_process(OP_HEART))
				return

			// If the human is losing too much blood, beep.
			if(H.get_blood_volume() < (H.total_blood_req + BLOOD_VOLUME_SAFE_MODIFIER) * 1.05)
				visible_message("\The [src] beeps loudly.")

			var/datum/reagent/B = H.take_blood(beaker,amount)
			if (B)
				beaker.reagents.reagent_list |= B
				beaker.reagents.update_total()
				beaker.on_reagent_change()
				beaker.reagents.handle_reactions()
				update_icon()

	if ((!valve_opened || tank.distribute_pressure == 0) && !breather && !attached)
		return PROCESS_KILL

/obj/structure/medical_stand/anesthetic
	spawn_type = /obj/item/tank/anesthetic
	mask_type = /obj/item/clothing/mask/breath/medical
	is_loosen = FALSE


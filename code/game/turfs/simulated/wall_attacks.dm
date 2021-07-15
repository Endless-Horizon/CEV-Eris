//Interactions
/turf/simulated/wall/proc/toggle_open(var/mob/user)

	if(can_open == WALL_OPENING)
		return

	if(density)
		can_open = WALL_OPENING
		//FLICK("[material.icon_base]fwall_opening", src)
		sleep(15)
		density = FALSE
		set_opacity(FALSE)
		update_icon()
		set_light(0)
	else
		can_open = WALL_OPENING
		//FLICK("[material.icon_base]fwall_closing", src)
		density = TRUE
		set_opacity(TRUE)
		update_icon()
		sleep(15)
		set_light(1)

	can_open = WALL_CAN_OPEN
	update_icon()

/turf/simulated/wall/proc/fail_smash(var/mob/user)
	to_chat(user, SPAN_DANGER("You smash against the wall!"))
	user.do_attack_animation(src)
	take_damage(rand(25,75))

/turf/simulated/wall/proc/success_smash(var/mob/user)
	to_chat(user, SPAN_DANGER("You smash through the wall!"))
	user.do_attack_animation(src)
	spawn(1)
		dismantle_wall(1)

/turf/simulated/wall/proc/try_touch(var/mob/user, var/rotting)

	if(rotting)
		if(reinf_material)
			to_chat(user, SPAN_DANGER("\The [reinf_material.display_name] feels porous and crumbly."))
		else
			to_chat(user, SPAN_DANGER("\The [material.display_name] crumbles under your touch!"))
			dismantle_wall()
			return 1

	if(!can_open)
		to_chat(user, SPAN_NOTICE("You push the wall, but nothing happens."))
		playsound(src, hitsound, 25, 1)
		user.do_attack_animation(src)
	else
		toggle_open(user)
	return 0


/turf/simulated/wall/attack_hand(var/mob/user)

	radiate()
	add_fingerprint(user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	var/rotting = (locate(/obj/effect/overlay/wallrot) in src)
	if (HULK in user.mutations)
		if (rotting || !prob(material.hardness))
			success_smash(user)
		else
			fail_smash(user)
			return 1

	try_touch(user, rotting)

/turf/simulated/wall/attack_generic(var/mob/user, var/damage, var/attack_message, var/wallbreaker)

	radiate()
	if(!istype(user))
		return

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	var/rotting = (locate(/obj/effect/overlay/wallrot) in src)
	if(!damage || !wallbreaker)
		try_touch(user, rotting)
		return

	if(rotting)
		return success_smash(user)

	if(reinf_material)
		if((wallbreaker == 2) || (damage >= max(material.hardness,reinf_material.hardness)))
			return success_smash(user)
	else if(damage >= material.hardness)
		return success_smash(user)
	return fail_smash(user)

/turf/simulated/wall/attackby(obj/item/I, mob/user)

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if (!user.IsAdvancedToolUser())
		to_chat(user, SPAN_WARNING("You don't have the dexterity to do this!"))
		return

	//get the user's location
	if(!istype(user.loc, /turf))	return	//can't do this stuff whilst inside objects and such

	if(I)
		radiate()
		if(is_hot(I))
			burn(is_hot(I))

	var/list/usable_qualities = list()
	if(construction_stage == 2)
		usable_qualities.Add(QUALITY_BOLT_TURNING)
	if((locate(/obj/effect/overlay/wallrot) in src) || thermite || damage || isnull(construction_stage) || !reinf_material || construction_stage == 4 || construction_stage == 1)
		usable_qualities.Add(QUALITY_WELDING)
	if(construction_stage == 3 || construction_stage == 0)
		usable_qualities.Add(QUALITY_PRYING)
	if(construction_stage == 5)
		usable_qualities.Add(QUALITY_SCREW_DRIVING)
	if(construction_stage == 6)
		usable_qualities.Add(QUALITY_WIRE_CUTTING)

	var/tool_type = I.get_tool_type(user, usable_qualities, src)
	switch(tool_type)

		if(QUALITY_BOLT_TURNING)
			if(construction_stage == 2)
				to_chat(user, SPAN_NOTICE("You begin removing the bolts anchoring the support rods..."))
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					construction_stage = 1
					update_icon()
					to_chat(user, SPAN_NOTICE("You remove the bolts anchoring the support rods."))
					return
			return

		if(QUALITY_WELDING)
			if(locate(/obj/effect/overlay/wallrot) in src)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You burn away the fungi with \the [I]."))
					for(var/obj/effect/overlay/wallrot/WR in src)
						qdel(WR)
					return
			if(thermite)
				if(I.use_tool(user, src, WORKTIME_INSTANT,tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You ignite the termit with the [I]!"))
					thermitemelt(user)
					return
			if(damage)
				if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You repair the damage to [src]."))
					clear_bulletholes()
					take_damage(-damage)
					return
			if(isnull(construction_stage) || !reinf_material)
				to_chat(user, SPAN_NOTICE("You begin removing the outer plating..."))
				if(I.use_tool(user, src, WORKTIME_LONG, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You remove the outer plating."))
					dismantle_wall()
					user.visible_message(SPAN_WARNING("The wall was torn open by [user]!"))
					return
			if(construction_stage == 4)
				to_chat(user, SPAN_NOTICE("You begin removing the outer plating..."))
				if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					construction_stage = 3
					update_icon()
					to_chat(user, SPAN_NOTICE("You press firmly on the cover, dislodging it."))
					return
			if(construction_stage == 1)
				to_chat(user, SPAN_NOTICE("You begin removing the support rods..."))
				if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					construction_stage = 0
					update_icon()
					new /obj/item/stack/rods(user.loc)
					to_chat(user, SPAN_NOTICE("The support rods drop out as you cut them loose from the frame."))
					return
			return

		if(QUALITY_PRYING)
			if(construction_stage == 3)
				to_chat(user, SPAN_NOTICE("You begin to prying off the cover..."))
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					construction_stage = 2
					update_icon()
					to_chat(user, SPAN_NOTICE("You pry off the cover."))
					return
			if(construction_stage == 0)
				to_chat(user, SPAN_NOTICE("You struggle to pry off the outer sheath..."))
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You pry off the outer sheath."))
					dismantle_wall()
					return
			return

		if(QUALITY_WIRE_CUTTING)
			if(construction_stage == 6)
				to_chat(user, SPAN_NOTICE("You begin removing the outer grille..."))
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					construction_stage = 5
					new /obj/item/stack/rods(user.loc)
					to_chat(user, SPAN_NOTICE("You removing the outer grille."))
					update_icon()
					return
			return

		if(QUALITY_SCREW_DRIVING)
			if(construction_stage == 5)
				to_chat(user, SPAN_NOTICE("You begin removing the support lines..."))
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					construction_stage = 4
					update_icon()
					to_chat(user, SPAN_NOTICE("You remove the support lines."))
					return
			return

		if(ABORT_CHECK)
			return

	if(istype(I, /obj/item/stack/rods))
		if(construction_stage == 5)
			var/obj/item/stack/O = I
			if(O.get_amount()>0)
				O.use(1)
				construction_stage = 6
				update_icon()
				to_chat(user, SPAN_NOTICE("You replace the outer grille."))
				return

	if(istype(I,/obj/item/frame))
		var/obj/item/frame/F = I
		F.try_build(src)
		return

	else if(!istype(I,/obj/item/rcd) && !istype(I, /obj/item/reagent_containers))
		if(!I.force)
			return attack_hand(user)
		var/attackforce = I.force*I.structure_damage_factor
		var/dam_threshhold = material.integrity
		if(reinf_material)
			dam_threshhold = CEILING(max(dam_threshhold,reinf_material.integrity) * 0.5, 1)
		var/dam_prob = material.hardness * 1.4
		if (locate(/obj/effect/overlay/wallrot) in src)
			dam_prob *= 0.5 //Rot makes reinforced walls breakable
		if(ishuman(user))
			var/mob/living/carbon/human/attacker = user
			dam_prob -= attacker.stats.getStat(STAT_ROB)
		if(dam_prob < 100 && attackforce > (dam_threshhold/10))
			playsound(src, hitsound, 80, 1)
			if(!prob(dam_prob))
				visible_message(SPAN_DANGER("\The [user] attacks \the [src] with \the [I]!"))
				playsound(src, pick(WALLHIT_SOUNDS), 100, 5)
				take_damage(attackforce)
			else
				visible_message(SPAN_WARNING("\The [user] attacks \the [src] with \the [I]!"))
		else
			visible_message(SPAN_DANGER("\The [user] attacks \the [src] with \the [I], but it bounces off!"))
		user.do_attack_animation(src)
		return

/mob/living/carbon/superior_animal/proc/harvest(mob/user)
	var/actual_meat_amount = max(1,(meat_amount/2))
	if(meat_type && actual_meat_amount>0 && (stat == DEAD))
		drop_embedded()
		for(var/i=0;i<actual_meat_amount;i++)
			var/obj/item/meat = new meat_type(get_turf(src))
			meat.name = "[src.name] [meat.name]"
		if(issmall(src))
			user.visible_message(SPAN_DANGER("[user] chops up \the [src]!"))
			var/obj/effect/decal/cleanable/blood/blood_effect = new/obj/effect/decal/cleanable/blood/splatter(get_turf(src))
			blood_effect.basecolor = bloodcolor
			blood_effect.update_icon()
			qdel(src)
		else
			user.visible_message(SPAN_DANGER("[user] butchers \the [src] messily!"))
			gib()

/mob/living/carbon/superior_animal/update_lying_buckled_and_verb_status()
	..()

	check_AI_act()

/mob/living/carbon/superior_animal/bullet_act(obj/item/projectile/P, def_zone)
	. = ..()
	updatehealth()

/mob/living/carbon/superior_animal/attackby(obj/item/I, mob/living/user, var/params)
	if (meat_type && (stat == DEAD) && (QUALITY_CUTTING in I.tool_qualities))
		if (I.use_tool(user, src, WORKTIME_NORMAL, QUALITY_CUTTING, FAILCHANCE_NORMAL, required_stat = STAT_BIO))
			harvest(user)
	else
		. = ..()
		updatehealth()

/mob/living/carbon/superior_animal/resolve_item_attack(obj/item/I, mob/living/user, var/hit_zone)
	//mob.attackby -> item.attack -> mob.resolve_item_attack -> item.apply_hit_effect
	return 1

/mob/living/carbon/superior_animal/attack_hand(mob/living/carbon/M as mob)
	..()
	var/mob/living/carbon/human/H = M

	switch(M.a_intent)
		if (I_HELP)
			help_shake_act(M)

		if (I_GRAB)
			if(M == src || anchored)
				return 0
			for(var/obj/item/grab/G in src.grabbed_by)
				if(G.assailant == M)
					to_chat(M, SPAN_NOTICE("You already grabbed [src]."))
					return

			var/obj/item/grab/G = new /obj/item/grab(M, src)
			if(buckled)
				to_chat(M, SPAN_NOTICE("You cannot grab [src], \he is buckled in!"))
			if(!G) //the grab will delete itself in New if affecting is anchored
				return

			if (M in friends)
				grabbed_by_friend = TRUE // disables AI for easier wrangling
			M.put_in_active_hand(G)
			G.synch()
			LAssailant = M

			M.do_attack_animation(src)
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message(SPAN_WARNING("[M] has grabbed [src] passively!"))

			return 1

		if (I_DISARM)
			if (!weakened && prob(30))
				M.visible_message("\red [M] has shoved \the [src]")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				Weaken(3)

				return 1
			else
				M.visible_message("\red [M] failed to shove \the [src]")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

			M.do_attack_animation(src)

		if (I_HURT)
			var/damage = 3
			if ((stat == CONSCIOUS) && prob(10))
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				M.visible_message("\red [M] missed \the [src]")
			else
				if (istype(H))
					damage += max(0, (H.stats.getStat(STAT_ROB) / 10))
					if (HULK in H.mutations)
						damage *= 2

				playsound(loc, "punch", 25, 1, -1)
				M.visible_message("\red [M] has punched \the [src]")

				adjustBruteLoss(damage)
				updatehealth()
				M.do_attack_animation(src)

				return 1

/mob/living/carbon/superior_animal/ex_act(severity)
	..()
	if(!blinded)
		if (HUDtech.Find("flash"))
			FLICK("flash", HUDtech["flash"])

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1)
			gib()
			return

		if (2)
			b_loss += 60
			f_loss += 60
			adjustEarDamage(30,120)

		if (3)
			b_loss += 30
			if (prob(50))
				Paralyse(1)
			adjustEarDamage(15,60)

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)

	updatehealth()

/mob/living/carbon/superior_animal/handle_regular_status_updates()
	..()
	if(status_flags & GODMODE)
		return

	if(stat == DEAD)
		blinded = TRUE
		silent = 0
	else
		updatehealth()
		handle_stunned()
		handle_weakened()
		if(health <= 0)
			death()
			blinded = TRUE
			silent = 0
			return 1

		if(paralysis && paralysis > 0)
			handle_paralysed()
			blinded = TRUE
			stat = UNCONSCIOUS
			if(halloss > 0)
				adjustHalLoss(-3)

		if(sleeping)
			adjustHalLoss(-3)
			sleeping = max(sleeping-1, 0)
			blinded = TRUE
			stat = UNCONSCIOUS
		else if(resting)
			if(halloss > 0)
				adjustHalLoss(-3)

		else
			stat = CONSCIOUS
			if(halloss > 0)
				adjustHalLoss(-1)

		update_icons()

	return 1

/mob/living/carbon/superior_animal/adjustBruteLoss(var/amount)
	. = ..()
	if (overkill_gib && (amount >= overkill_gib) && (getBruteLoss() >= maxHealth*2))
		if (bodytemperature > T0C)
			gib()

/mob/living/carbon/superior_animal/adjustFireLoss(var/amount)
	. = ..()
	if (overkill_dust && (amount >= overkill_dust) && (getFireLoss() >= maxHealth*2))
		dust()

/mob/living/carbon/superior_animal/updatehealth()
	. = ..() //health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss() - halloss
	if (health <= 0)
		death()

/mob/living/carbon/superior_animal/gib(var/anim = icon_gib, var/do_gibs = 1)
	if (!anim)
		anim = 0

	sleep(1)

	for(var/obj/item/I in src)
		drop_from_inventory(I)
		I.throw_at(get_edge_target_turf(src,pick(alldirs)), rand(1,3), round(30/I.w_class))

	playsound(src.loc, 'sound/effects/splat.ogg', max(10,min(50,maxHealth)), 1)
	if (do_gibs)
		gibs(src.loc, null, /obj/effect/gibspawner/generic, fleshcolor, bloodcolor)
	. = ..(anim,FALSE)

/mob/living/carbon/superior_animal/dust(var/anim = icon_dust, var/remains = dust_remains)
	if (!anim)
		anim = 0

	playsound(src.loc, 'sound/effects/Custom_flare.ogg', max(10,min(50,maxHealth)), 1)
	. = ..(anim,remains)

/mob/living/carbon/superior_animal/death(var/gibbed,var/message = deathmessage)
	if (stat != DEAD)
		target_mob = null
		stance = initial(stance)
		stop_automated_movement = initial(stop_automated_movement)
		walk(src, 0)

		density = FALSE
		layer = LYING_MOB_LAYER

	. = ..()

/mob/living/carbon/superior_animal/rejuvenate()
	density = initial(density)
	layer = initial(layer)

	. = ..()

/mob/living/carbon/superior_animal/pl_effects()
	. = ..()
	adjustToxLoss(2)

/mob/living/carbon/superior_animal/get_cold_protection(var/temperature)
	return cold_protection

/mob/living/carbon/superior_animal/get_heat_protection(var/temperature)
	return heat_protection

/mob/living/carbon/superior_animal/handle_environment(datum/gas_mixture/environment)
	bad_environment = FALSE
	if(!environment)
		return

	if (!contaminant_immunity)
		for(var/g in environment.gas)
			if(gas_data.flags[g] & XGM_GAS_CONTAMINANT && environment.gas[g] > gas_data.overlay_limit[g] + 1)
				bad_environment = TRUE
				pl_effects()
				break

	if(istype(get_turf(src), /turf/space))
		if (bodytemperature > 1)
			bodytemperature = max(1,bodytemperature - 10*(1-get_cold_protection(0)))

		if (min_air_pressure > 0)
			bad_environment = TRUE
			adjustBruteLoss(2)
	else
		var/loc_temp = T0C
		var/loc_pressure = 0
/*
		if(istype(loc, /mob/living/exosuit))
			var/mob/living/exosuit/M = loc
			loc_temp =  M.return_temperature()
			loc_pressure =  M.return_pressure()
*/
		if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
			var/obj/machinery/atmospherics/unary/cryo_cell/M = loc
			loc_temp = M.air_contents.temperature
			loc_pressure = M.air_contents.return_pressure()
		else
			loc_temp = environment.temperature
			loc_pressure = environment.return_pressure()

		//Body temperature adjusts depending on surrounding atmosphere based on your thermal protection (convection)
		var/temp_adj = 0
		if(loc_temp < bodytemperature) //Place is colder than we are
			var/thermal_protection = get_cold_protection(loc_temp) //0 to 1 value, which corresponds to the percentage of protection
			if(thermal_protection < 1)
				temp_adj = (1-thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_COLD_DIVISOR) //this will be negative
		else if (loc_temp > bodytemperature) //Place is hotter than we are
			var/thermal_protection = get_heat_protection(loc_temp) //0 to 1 value, which corresponds to the percentage of protection
			if(thermal_protection < 1)
				temp_adj = (1-thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR)

		var/relative_density = environment.total_moles / MOLES_CELLSTANDARD
		bodytemperature += between(BODYTEMP_COOLING_MAX, temp_adj*relative_density, BODYTEMP_HEATING_MAX)

		if ((loc_pressure < min_air_pressure) || (loc_pressure > max_air_pressure))
			bad_environment = TRUE
			adjustBruteLoss(2)

	if (overkill_dust && (getFireLoss() >= maxHealth*2))
		if (bodytemperature >= max_bodytemperature*1.5)
			dust()
			return

	if ((bodytemperature > max_bodytemperature) || (bodytemperature < min_bodytemperature))
		bad_environment = TRUE
		adjustFireLoss(5)
		updatehealth()


	//If we're unable to breathe, lets get out of here
	if (can_burrow && !stat && bad_environment)
		evacuate()

/mob/living/carbon/superior_animal/handle_breath(datum/gas_mixture/breath)
	if(status_flags & GODMODE)
		return

	failed_last_breath = 0

	if (!(breath_required_type || breath_poison_type))
		return

	if(breath_required_type && (!breath || (breath.total_moles == 0)))
		failed_last_breath = 1
		adjustOxyLoss(2)
		return

	var/breath_pressure = (breath.total_moles*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

	if (breath_required_type)
		var/inhaling = breath.gas[breath_required_type]
		var/inhale_pp = (inhaling/breath.total_moles)*breath_pressure
		if(inhale_pp < min_breath_required_type)
			adjustOxyLoss(2)
			failed_last_breath = 1

	if (breath_poison_type)
		var/poison = breath.gas[breath_poison_type]
		var/toxins_pp = (poison/breath.total_moles)*breath_pressure
		if(toxins_pp > min_breath_poison_type)
			adjustToxLoss(2)

	return 1

/mob/living/carbon/superior_animal/handle_fire()
	if(..())
		return

	var/burn_temperature = fire_burn_temperature()
	var/thermal_protection = get_heat_protection(burn_temperature)

	if (thermal_protection < 1 && bodytemperature < burn_temperature)
		bodytemperature += round(BODYTEMP_HEATING_MAX*(1-thermal_protection), 1)

/mob/living/carbon/superior_animal/update_fire()
	remove_overlays(image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing"))
	if(on_fire)
		add_overlays(image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing"))

//The most common cause of an airflow stun is a sudden breach. Evac conditions generally
/mob/living/carbon/superior_animal/airflow_stun()
	.=..()
	if (can_burrow && !stat)
		evacuate()


//Called when the environment becomes unlivable, maybe in other situations
//The mobs will request the nearby burrow to take them away somewhere else
/mob/living/carbon/superior_animal/proc/evacuate()
	var/obj/structure/burrow/B = find_visible_burrow(src)
	if (B)
		B.evacuate()

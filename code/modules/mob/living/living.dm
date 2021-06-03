/mob/living/Initialize(mapload)
	. = ..()
	// register_init_signals()
	// if(unique_name)
	// 	set_name()
	// var/datum/atom_hud/data/human/medical/advanced/medhud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	// medhud.add_to_hud(src)
	// for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
	// 	diag_hud.add_to_hud(src)
	// faction += "[REF(src)]"
	GLOB.mob_living_list += src

/mob/living/ComponentInitialize()
	. = ..()
	// AddElement(/datum/element/movetype_handler)

/mob/living/Destroy()
	// if(LAZYLEN(status_effects))
	// 	for(var/s in status_effects)
	// 		var/datum/status_effect/S = s
	// 		if(S.on_remove_on_mob_delete) //the status effect calls on_remove when its mob is deleted
	// 			qdel(S)
	// 		else
	// 			S.be_replaced()
	// if(ranged_ability)
	// 	ranged_ability.remove_ranged_ability(src)
	if(buckled)
		buckled.unbuckle_mob() //src,force=1)

	// remove_from_all_data_huds()
	GLOB.mob_living_list -= src
	// QDEL_LAZYLIST(diseases)
	return ..()

//mob verbs are faster than object verbs. See mob/verb/examine.
/mob/living/verb/pulled(atom/movable/AM as mob|obj in oview(1))
	set name = "Pull"
	set category = "Object"

	if(istype(AM) && Adjacent(AM)) // do not pull areas
		start_pulling(AM)

	return

//mob verbs are faster than object verbs. See above.
/mob/living/pointed(atom/A as mob|obj|turf in view(client.view, src))
	if(stat || !canmove || restrained() || incapacitated())
		return FALSE
	if(src.status_flags & FAKEDEATH)
		return FALSE
	if(!..())
		return FALSE

	visible_message("<span class='infoplain'><span class='name'>[src]</span> points at [A].</span>", "<span class='notice'>You point at [A].</span>")
	return TRUE

/*one proc, four uses
swapping: if it's 1, the mobs are trying to switch, if 0, non-passive is pushing passive
default behaviour is:
 - non-passive mob passes the passive version
 - passive mob checks to see if its mob_bump_flag is in the non-passive's mob_bump_flags
 - if si, the proc returns
*/
/mob/living/proc/can_move_mob(mob/living/swapped, swapping = 0, passive = 0)
	if(!swapped)
		return TRUE
	if(!passive)
		return swapped.can_move_mob(src, swapping, 1)
	else
		var/context_flags = 0
		if(swapping)
			context_flags = swapped.mob_swap_flags
		else
			context_flags = swapped.mob_push_flags
		if(!mob_bump_flag) //nothing defined, go wild
			return TRUE
		if(mob_bump_flag & context_flags)
			return TRUE
		return FALSE

/mob/living/Bump(atom/movable/AM, yes)
	spawn(0)
		if ((!( yes ) || now_pushing) || !loc)
			return
		now_pushing = TRUE
		if (isliving(AM))
			var/mob/living/tmob = AM

			for(var/mob/living/M in range(tmob, 1))
				if(tmob.pinned.len ||  ((M.pulling == tmob && ( tmob.restrained() && !( M.restrained() ) && M.stat == 0)) || locate(/obj/item/weapon/grab, tmob.grabbed_by.len)) )
					if ( !(world.time % 5) )
						to_chat(src, "<span class='warning'>[tmob] is restrained, you cannot push past</span>")
					now_pushing = FALSE
					return
				if( tmob.pulling == M && ( M.restrained() && !( tmob.restrained() ) && tmob.stat == 0) )
					if ( !(world.time % 5) )
						to_chat(src, "<span class='warning'>[tmob] is restraining [M], you cannot push past</span>")
					now_pushing = FALSE
					return

			//Leaping mobs just land on the tile, no pushing, no anything.
			if(status_flags & LEAPING)
				loc = tmob.loc
				status_flags &= ~LEAPING
				now_pushing = FALSE
				return

			if(can_swap_with(tmob)) // mutual brohugs all around!
				var/turf/oldloc = loc
				forceMove(tmob.loc)
				tmob.forceMove(oldloc)
				now_pushing = FALSE
				for(var/mob/living/carbon/slime/slime in view(1,tmob))
					if(slime.Victim == tmob)
						slime.UpdateFeed()
				return

			if(!can_move_mob(tmob, 0, 0))
				now_pushing = FALSE
				return
			if(a_intent == I_HELP || src.restrained())
				now_pushing = FALSE
				return
			if(tmob.r_hand && istype(tmob.r_hand, /obj/item/weapon/shield/riot))
				if(prob(99))
					now_pushing = FALSE
					return
			if(tmob.l_hand && istype(tmob.l_hand, /obj/item/weapon/shield/riot))
				if(prob(99))
					now_pushing = FALSE
					return
			if(!(tmob.status_flags & CANPUSH))
				now_pushing = FALSE
				return

			tmob.LAssailant = src

		now_pushing = FALSE
		spawn(0)
			..()
			if (!istype(AM, /atom/movable))
				return
			if (!now_pushing)
				now_pushing = TRUE

				if (!AM.anchored)
					var/t = get_dir(src, AM)
					if (istype(AM, /obj/structure/window))
						for(var/obj/structure/window/win in get_step(AM,t))
							now_pushing = FALSE
							return
					step_glide(AM, t, glide_size)
					if(ishuman(AM) && AM:grabbed_by)
						for(var/obj/item/weapon/grab/G in AM:grabbed_by)
							step_glide(G:assailant, get_dir(G:assailant, AM), glide_size)
							G.adjust_position()
				now_pushing = FALSE
			return
	return

/proc/swap_density_check(var/mob/swapper, var/mob/swapee)
	var/turf/T = get_turf(swapper)
	if(T.density)
		return TRUE
	for(var/atom/movable/A in T)
		if(A == swapper)
			continue
		if(!A.CanPass(swapee, T, 1))
			return TRUE

/mob/living/proc/can_swap_with(var/mob/living/tmob)
	if(tmob.buckled || buckled)
		return FALSE
	//BubbleWrap: people in handcuffs are always switched around as if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
	if(!(tmob.mob_always_swap || (tmob.a_intent == I_HELP || tmob.restrained()) && (a_intent == I_HELP || src.restrained())))
		return FALSE
	if(!tmob.canmove || !canmove)
		return FALSE

	if(swap_density_check(src, tmob))
		return FALSE

	if(swap_density_check(tmob, src))
		return FALSE

	return can_move_mob(tmob, 1, 0)

/mob/living/verb/succumb()
	set hidden = TRUE
	if ((src.health < 0 && src.health > (5-src.maxHealth))) // Health below Zero but above 5-away-from-death, as before, but variable
		src.adjustOxyLoss(src.health + src.maxHealth * 2) // Deal 2x health in OxyLoss damage, as before but variable.
		src.health = src.maxHealth - src.getOxyLoss() - src.getToxLoss() - src.getFireLoss() - src.getBruteLoss()
		to_chat(src, "\blue You have given up life and succumbed to death.")


/mob/living/proc/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else
		health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss() - halloss


//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(var/pressure)
	return


//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/living/proc/burn_skin(burn_amount)

/mob/living/carbon/human/burn_skin(burn_amount)
	//world << "DEBUG: burn_skin(), mutations=[mutations]"
	if(mShock in mutations) //shockproof
		return FALSE
	if (COLD_RESISTANCE in mutations) //fireproof
		return FALSE
	var/divided_damage = (burn_amount)/(organs.len)
	var/extradam = 0	//added to when organ is at max dam
	for(var/obj/item/organ/external/affecting in organs)
		//TODO: fix the extradam stuff. Or, ebtter yet...rewrite this entire proc ~Carn
		if(affecting.take_damage(0, divided_damage+extradam))
			UpdateDamageIcon()
	updatehealth()
	return TRUE

/mob/living/silicon/ai/burn_skin()
	return FALSE

/mob/living/proc/adjustBodyTemp(actual, desired, incrementboost)
	var/temperature = actual
	var/difference = abs(actual-desired)	//get difference
	var/increments = difference/10 //find how many increments apart they are
	var/change = increments*incrementboost	// Get the amount to change by (x per increment)

	// Too cold
	if(actual < desired)
		temperature += change
		if(actual > desired)
			temperature = desired
	// Too hot
	if(actual > desired)
		temperature -= change
		if(actual < desired)
			temperature = desired
	return temperature


// ++++ROCKDTBEN++++ MOB PROCS -- Ask me before touching.
// Stop! ... Hammertime! ~Carn
// I touched them without asking... I'm soooo edgy ~Erro (added nodamage checks)

/mob/living/proc/getBruteLoss()
	return bruteloss

/mob/living/proc/adjustBruteLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	bruteloss = min(max(bruteloss + amount, 0),(maxHealth*2))

/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/adjustOxyLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	oxyloss = min(max(oxyloss + amount, 0),(maxHealth*2))

/mob/living/proc/setOxyLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	oxyloss = amount

/mob/living/proc/getToxLoss()
	return toxloss

/mob/living/proc/adjustToxLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	toxloss = min(max(toxloss + amount, 0),(maxHealth*2))

/mob/living/proc/setToxLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	toxloss = amount

/mob/living/proc/getFireLoss()
	return fireloss

/mob/living/proc/adjustFireLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	fireloss = min(max(fireloss + amount, 0),(maxHealth*2))

/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/adjustCloneLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	cloneloss = min(max(cloneloss + amount, 0),(maxHealth*2))

/mob/living/proc/setCloneLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	cloneloss = amount

/mob/living/proc/getBrainLoss()
	return brainloss

/mob/living/proc/adjustBrainLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	brainloss = min(max(brainloss + amount, 0),(maxHealth*2))

/mob/living/proc/setBrainLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	brainloss = amount

/mob/living/proc/getHalLoss()
	return halloss

/mob/living/proc/adjustHalLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	halloss = min(max(halloss + amount, 0),(maxHealth*2))

/mob/living/proc/setHalLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	halloss = amount

/mob/living/proc/getMaxHealth()
	return maxHealth

/mob/living/proc/adjustMaxHealth(amount)
	maxHealth += amount

/mob/living/proc/setMaxHealth(newMaxHealth)
	maxHealth = newMaxHealth

/mob/living/proc/get_limb_efficiency(bodypartdefine)
	return 100

/mob/living/proc/get_specific_organ_efficiency(process_define, parent_organ_tag)
	return 100

// ++++ROCKDTBEN++++ MOB PROCS //END

/mob/get_contents()
	return contents


//Recursive function to find everything a mob is holding.
/mob/living/get_contents(var/obj/item/weapon/storage/Storage)
	var/list/L = list()

	if(Storage) //If it called itself
		L += Storage.return_inv()

		//Leave this commented out, it will cause storage items to exponentially add duplicate to the list
		//for(var/obj/item/weapon/storage/S in Storage.return_inv()) //Check for storage items
		//	L += get_contents(S)

		for(var/obj/item/weapon/gift/G in Storage.return_inv()) //Check for gift-wrapped items
			L += G.gift
			if(istype(G.gift, /obj/item/weapon/storage))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in Storage.return_inv()) //Check for package wrapped items
			L += D.wrapped
			if(istype(D.wrapped, /obj/item/weapon/storage)) //this should never happen
				L += get_contents(D.wrapped)
		return L

	else

		L += src.contents
		for(var/obj/item/weapon/storage/S in src.contents)	//Check for storage items
			L += get_contents(S)

		for(var/obj/item/weapon/gift/G in src.contents) //Check for gift-wrapped items
			L += G.gift
			if(istype(G.gift, /obj/item/weapon/storage))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in src.contents) //Check for package wrapped items
			L += D.wrapped
			if(istype(D.wrapped, /obj/item/weapon/storage)) //this should never happen
				L += get_contents(D.wrapped)
		return L

/mob/living/proc/check_contents_for(A)
	var/list/L = src.get_contents()

	for(var/obj/B in L)
		if(B.type == A)
			return TRUE
	return FALSE


/mob/living/proc/can_inject(var/mob/user, var/error_msg, var/target_zone)
	return TRUE

/mob/living/is_injectable(allowmobs = TRUE)
	return (allowmobs && reagents && can_inject())

/mob/living/is_drawable(allowmobs = TRUE)
	return (allowmobs && reagents && can_inject())


/mob/living/proc/get_organ_target()
	var/mob/shooter = src
	var/t = shooter:targeted_organ
	if(t in list(BP_EYES, BP_MOUTH))
		t = BP_HEAD
	var/obj/item/organ/external/def_zone = ran_zone(t)
	return def_zone



/mob/living/proc/restore_all_organs()
	return

/mob/living/proc/revive()
	rejuvenate()
	if(buckled)
		buckled.unbuckle_mob()
	if(iscarbon(src))
		var/mob/living/carbon/C = src

		if (C.handcuffed && !initial(C.handcuffed))
			C.drop_from_inventory(C.handcuffed)
		C.handcuffed = initial(C.handcuffed)

		if (C.legcuffed && !initial(C.legcuffed))
			C.drop_from_inventory(C.legcuffed)
		C.legcuffed = initial(C.legcuffed)
	BITSET(hud_updateflag, HEALTH_HUD)
	BITSET(hud_updateflag, STATUS_HUD)
	BITSET(hud_updateflag, LIFE_HUD)
	ExtinguishMob()
	fire_stacks = 0

/mob/living/proc/rejuvenate()
	if (reagents)
		reagents.clear_reagents()

	// shut down various types of badness
	setToxLoss(0)
	setOxyLoss(0)
	setCloneLoss(0)
	setBrainLoss(0)
	SetParalysis(0)
	SetStunned(0)
	SetWeakened(0)

	// shut down ongoing problems
	radiation = 0
	bodytemperature = T20C
	sdisabilities = 0
	disabilities = 0

	// fix blindness and deafness
	blinded = FALSE
	eye_blind = 0
	eye_blurry = 0
	ear_deaf = 0
	ear_damage = 0
	heal_overall_damage(getBruteLoss(), getFireLoss())

	// fix all of our organs
	restore_all_organs()

	// remove the character from the list of the dead
	if(stat == DEAD)
		GLOB.dead_mob_list -= src
		GLOB.living_mob_list += src
		timeofdeath = 0

	// restore us to conciousness
	stat = CONSCIOUS

	// make the icons look correct
	regenerate_icons()

	BITSET(hud_updateflag, HEALTH_HUD)
	BITSET(hud_updateflag, STATUS_HUD)
	BITSET(hud_updateflag, LIFE_HUD)

	failed_last_breath = 0 //So mobs that died of oxyloss don't revive and have perpetual out of breath.

	return

// The proc despawn() is called by /obj/machinery/cryopod/proc/despawn_occupant() for clean removal of a mob out of the round with the removal of objectives affecting it.
// Not recommended to directly call this proc on a mob without a good reason. It kicks out the player from the game without turning him into a ghost.
/mob/living/despawn()
	//Update any existing objectives involving this mob.
	for(var/datum/objective/O in all_objectives)
		// We don't want revs to get objectives that aren't for heads of staff. Letting
		// them win or lose based on cryo is silly so we remove the objective.
		if(O.target == src.mind)
			if(O.owner && O.owner.current)
				to_chat(O.owner.current, SPAN_WARNING("You get the feeling your target is no longer within your reach..."))
			qdel(O)

	//Same for contract-based objectives.
	for(var/datum/antag_contract/contract in (GLOB.various_antag_contracts + GLOB.excel_antag_contracts))
		contract.on_mob_despawned(src.mind)

	if(src.mind)
		//Handle job slot/tater cleanup.
		var/job = src.mind.assigned_role
		SSjob.FreeRole(job)

		clear_antagonist(src.mind)

	// Delete them from datacore.

	if(PDA_Manifest.len)
		PDA_Manifest.Cut()
	for(var/datum/data/record/R in data_core.medical)
		if ((R.fields["name"] == src.real_name))
			qdel(R)
	for(var/datum/data/record/T in data_core.security)
		if ((T.fields["name"] == src.real_name))
			qdel(T)
	for(var/datum/data/record/G in data_core.general)
		if ((G.fields["name"] == src.real_name))
			qdel(G)

	//This should guarantee that ghosts don't spawn.
	src.ckey = null

	// Delete the mob.
	qdel(src)

/mob/living/proc/UpdateDamageIcon()
	return

/mob/living/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, var/glide_size_override = 0)
	if (buckled)
		return

	if (restrained())
		stop_pulling()


	var/t7 = 1
	if (restrained())
		for(var/mob/living/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if ((t7 && (pulling && ((get_dist(src, pulling) <= 1 || pulling.loc == loc) && (moving)))))
		var/turf/T = loc
		. = ..()

		if (pulling && pulling.loc)
			if(!(isturf(pulling.loc)))
				stop_pulling()
				return

		/////
		if(pulling && pulling.anchored)
			stop_pulling()
			return

		if (!restrained())
			var/diag = get_dir(src, pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, pulling) > 1 || diag))
				if (isliving(pulling))
					var/mob/living/M = pulling
					var/ok = 1
					if (locate(/obj/item/weapon/grab, M.grabbed_by))
						if (prob(75))
							var/obj/item/weapon/grab/G = pick(M.grabbed_by)
							if (istype(G, /obj/item/weapon/grab))
								for(var/mob/O in viewers(M, null))
									O.show_message(text("\red [] has been pulled from []'s grip by []", G.affecting, G.assailant, src), 1)
								//G = null
								qdel(G)
						else
							ok = 0
						if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
							ok = 0
					if (ok)
						var/atom/movable/t = M.pulling
						M.stop_pulling()

						if(!istype(M.loc, /turf/space))
							var/area/A = get_area(M)
							if(A.has_gravity)
								//this is the gay blood on floor shit -- Added back -- Skie
								if (M.lying && (prob(M.getBruteLoss() / 6)))
									var/turf/location = M.loc
									if (istype(location, /turf/simulated))
										location.add_blood(M)
								//pull damage with injured people
									if(prob(25))
										M.adjustBruteLoss(1)
										visible_message("<span class='danger'>\The [M]'s [M.isSynthetic() ? "state worsens": "wounds open more"] from being dragged!</span>")
								if(M.pull_damage())
									if(prob(25))
										M.adjustBruteLoss(2)
										visible_message("<span class='danger'>\The [M]'s [M.isSynthetic() ? "state" : "wounds"] worsen terribly from being dragged!</span>")
										var/turf/location = M.loc
										if (istype(location, /turf/simulated))
											location.add_blood(M)
											if(ishuman(M))
												var/mob/living/carbon/human/H = M
												var/blood_volume = round(H.vessel.get_reagent_amount("blood"))
												if(blood_volume > 0)
													H.vessel.remove_reagent("blood", 0.5)


						step_glide(pulling, get_dir(pulling.loc, T), glide_size)
						if(t)
							M.start_pulling(t)
				else
					if (pulling)
						if (istype(pulling, /obj/structure/window))
							var/obj/structure/window/W = pulling
							if(W.is_full_window())
								for(var/obj/structure/window/win in get_step(pulling,get_dir(pulling.loc, T)))
									stop_pulling()
					if (pulling)
						step_glide(pulling, get_dir(pulling.loc, T), glide_size)
	else
		stop_pulling()
		. = ..()

	if (s_active && !( s_active in contents ) && get_turf(s_active) != get_turf(src))	//check !( s_active in contents ) first so we hopefully don't have to call get_turf() so much.
		s_active.close(src)

	step_count++

	if(update_slimes)
		for(var/mob/living/carbon/slime/M in view(1,src))
			M.UpdateFeed(src)




/mob/living/verb/lay_down()
	set name = "Rest"
	set category = "IC"

	var/state_changed = FALSE
	if(resting && can_stand_up())
		resting = FALSE
		state_changed = TRUE


	else if (!resting)
		if(ishuman(src))
			var/obj/item/weapon/bedsheet/BS = locate(/obj/item/weapon/bedsheet) in get_turf(src)
			// If there is unrolled bedsheet roll and unroll it to get in bed like a proper adult does
			if(BS && !BS.rolled && !BS.folded)
				resting = TRUE
				BS.toggle_roll(src, no_message = TRUE)
				BS.toggle_roll(src)
			else
				resting = TRUE
			state_changed = TRUE
		else
			resting = TRUE
			state_changed = TRUE
	if(state_changed)
		to_chat(src, "<span class='notice'>You are now [resting ? "resting" : "getting up"]</span>")
		update_lying_buckled_and_verb_status()

/mob/living/proc/can_stand_up()
	var/no_blankets = FALSE
	no_blankets = unblanket()

	if(no_blankets)
		return TRUE
	else
		to_chat(src, SPAN_WARNING("You can't stand up, bedsheets are in the way and you struggle to get rid of them."))
		return FALSE

//used to push away bedsheets in order to stand up, only humans will roll them (see overriden human proc)
/mob/living/proc/unblanket()
	var/obj/item/weapon/bedsheet/blankets = (locate(/obj/item/weapon/bedsheet) in loc)
	if (blankets && !blankets.rolled && !blankets.folded)
		return blankets.toggle_roll(src)
	return TRUE

/mob/living/simple_animal/spiderbot/is_allowed_vent_crawl_item(var/obj/item/carried_item)
	if(carried_item == held_item)
		return FALSE
	return ..()

/mob/living/proc/cannot_use_vents()
	return "You can't fit into that vent."

/mob/living/proc/has_brain()
	return TRUE

/mob/living/proc/has_eyes()
	return TRUE

/mob/living/proc/slip(var/slipped_on,stun_duration=8)
	return FALSE

//damage/heal the mob ears and adjust the deaf amount
/mob/living/adjustEarDamage(damage, deaf)
	ear_damage = max(0, ear_damage + damage)
	ear_deaf = max(0, ear_deaf + deaf)

//pass a negative argument to skip one of the variable
/mob/living/setEarDamage(damage, deaf)
	if(damage >= 0)
		ear_damage = damage
	if(deaf >= 0)
		ear_deaf = deaf

/mob/proc/can_be_possessed_by(var/mob/observer/ghost/possessor)
	return istype(possessor) && possessor.client

/mob/living/can_be_possessed_by(var/mob/observer/ghost/possessor)
	if(!..())
		return FALSE
	if(!possession_candidate)
		to_chat(possessor, "<span class='warning'>That animal cannot be possessed.</span>")
		return FALSE
	if(jobban_isbanned(possessor, "Animal"))
		to_chat(possessor, "<span class='warning'>You are banned from animal roles.</span>")
		return FALSE
	if(!possessor.MayRespawn(0 ,ANIMAL))
		return FALSE
	return TRUE

/mob/living/proc/do_possession(var/mob/observer/ghost/possessor)

	if(!(istype(possessor) && possessor.ckey))
		return FALSE

	if(src.ckey || src.client)
		to_chat(possessor, "<span class='warning'>\The [src] already has a player.</span>")
		return FALSE

	message_admins("<span class='adminnotice'>[key_name_admin(possessor)] has taken control of \the [src].</span>")
	log_admin("[key_name(possessor)] took control of \the [src].")
	src.ckey = possessor.ckey
	qdel(possessor)

	to_chat(src, "<b>You are now \the [src]!</b>")
	to_chat(src, "<span class='notice'>Remember to stay in character for a mob of this type!</span>")
	return TRUE

/mob/living/reset_layer()
	if(hiding)
		set_plane(HIDING_MOB_PLANE)
		layer = HIDING_MOB_LAYER
	else
		..()

/mob/living/throw_mode_off()
	src.in_throw_mode = 0
	if (HUDneed.Find("throw"))
		var/obj/screen/HUDthrow/HUD = HUDneed["throw"]
		HUD.update_icon()

/mob/living/throw_mode_on()
	src.in_throw_mode = 1
	if (HUDneed.Find("throw"))
		var/obj/screen/HUDthrow/HUD = HUDneed["throw"]
		HUD.update_icon()

	/*if (var/obj/screen/HUDthrow/HUD in src.client.screen)
		if(HUD.name == "throw") //in case we don't have the HUD and we use the hotkey
			HUD.toggle_throw_mode()
			break*/

/mob/living/stop_pulling()

	set name = "Stop Pulling"
	set category = "IC"

	if(pulling)
		pulling.pulledby = null
		pulling = null
/*		if(pullin)
			pullin.icon_state = "pull0"*/
		if (HUDneed.Find("pull"))
			var/obj/screen/HUDthrow/HUD = HUDneed["pull"]
			HUD.update_icon()

/mob/living/start_pulling(var/atom/movable/AM)

	if (!AM || !usr || src==AM || !isturf(src.loc))	//if there's no person pulling OR the person is pulling themself OR the object being pulled is inside something: abort!
		return

	if (AM.anchored)
		to_chat(src, "<span class='warning'>It won't budge!</span>")
		return

	var/mob/M = AM
	if(ismob(AM))

		if(!can_pull_mobs || !can_pull_size)
			to_chat(src, "<span class='warning'>It won't budge!</span>")
			return

		if((mob_size < M.mob_size) && (can_pull_mobs != MOB_PULL_LARGER))
			to_chat(src, "<span class='warning'>It won't budge!</span>")
			return

		if((mob_size == M.mob_size) && (can_pull_mobs == MOB_PULL_SMALLER))
			to_chat(src, "<span class='warning'>It won't budge!</span>")
			return

		// If your size is larger than theirs and you have some
		// kind of mob pull value AT ALL, you will be able to pull
		// them, so don't bother checking that explicitly.

		if(!iscarbon(src))
			M.LAssailant = null
		else
			M.LAssailant = usr

	else if(isobj(AM))
		var/obj/I = AM
		if(!can_pull_size || can_pull_size < I.w_class)
			to_chat(src, "<span class='warning'>It won't budge!</span>")
			return

	if(pulling)
		var/pulling_old = pulling
		stop_pulling()
		// Are we pulling the same thing twice? Just stop pulling.
		if(pulling_old == AM)
			return

	src.pulling = AM
	AM.pulledby = src

	if (HUDneed.Find("pull"))
		var/obj/screen/HUDthrow/HUD = HUDneed["pull"]
		HUD.update_icon()

	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(H.pull_damage())
			to_chat(src, "\red <B>Pulling \the [H] in their current condition would probably be a bad idea.</B>")

	//Attempted fix for people flying away through space when cuffed and dragged.
	if(ismob(AM))
		var/mob/pulled = AM
		pulled.inertia_dir = 0


// Static Overlays and Stats

/mob/living/proc/generate_static_overlay()
	static_overlay = image(get_static_icon(new/icon(icon, icon_state)), loc = src)
	static_overlay.override = 1

/mob/living/New()
	..()

	//Some mobs may need to create their stats datum farther up
	if (!stats)
		stats = new /datum/stat_holder(src)

	generate_static_overlay()
	for(var/mob/observer/eye/angel/A in GLOB.player_list)
		if(A)
			A.static_overlays |= static_overlay
			A.client.images |= static_overlay
	var/turf/T = get_turf(src)
	if(T)
		update_z(T.z)

/mob/living/Destroy()
	qdel(stats)
	stats = null
	return ..()

/mob/living/proc/vomit()
	return

/mob/living/proc/adjustNutrition(amount)
	nutrition = max(0,min(nutrition + amount, max_nutrition))	//clamp the value

/mob/living/proc/is_asystole()
	return FALSE

//Makes a blood drop, leaking amt units of blood from the mob
/mob/living/proc/drip_blood(var/amt as num)
	blood_splatter(src,src)

/**
 * Handles the biological and general over-time processes of the mob.
 *
 *
 * Arguments:
 * - delta_time: The amount of time that has elapsed since this last fired.
 * - times_fired: The number of times SSmobs has fired
 */
/mob/living/Life(delta_time = SSMOBS_DT, times_fired)
	if (client)
		var/turf/T = get_turf(src)
		if(!T)
			// move_to_error_room() too bad
			var/msg = "[ADMIN_LOOKUPFLW(src)] was found to have no .loc with an attached client, if the cause is unknown it would be wise to ask how this was accomplished."
			message_admins(msg)
			send2adminchat("Mob", msg) //, R_ADMIN)
			log_game("[key_name(src)] was found to have no .loc with an attached client.")

		// This is a temporary error tracker to make sure we've caught everything
		else if (registered_z != T.z)
#ifdef TESTING
			message_admins("[ADMIN_LOOKUPFLW(src)] has somehow ended up in Z-level [T.z] despite being registered in Z-level [registered_z]. If you could ask them how that happened and notify coderbus, it would be appreciated.")
#endif
			log_game("Z-TRACKING: [src] has somehow ended up in Z-level [T.z] despite being registered in Z-level [registered_z].")
			update_z(T.z)
	else if (registered_z)
		log_game("Z-TRACKING: [src] of type [src.type] has a Z-registration despite not having a client.")
		update_z(null)

	if (transforming || HasMovementHandler(/datum/movement_handler/mob/transformation/))
		return
	if(!loc) // you may live. For now
		return

	if(config.enable_mob_sleep)
		if(life_cycles_before_scan > 0)
			life_cycles_before_scan--
		else
			if(check_surrounding_area(7))
				activate_ai()
				life_cycles_before_scan = 3

		if(life_cycles_before_sleep)
			life_cycles_before_sleep--

		if(life_cycles_before_sleep < 1 && !AI_inactive)
			AI_inactive = TRUE


	if(!stasis)
		var/datum/gas_mixture/environment = loc.return_air()

		if(stat != DEAD)
			//Mutations and radiation
			handle_mutations_and_radiation(delta_time, times_fired)

		if(stat != DEAD)
			//Breathing, if applicable
			handle_breathing(delta_time, times_fired)

		if(stat != DEAD) // basicaly wounds
			//Blood
			handle_blood()

		if (QDELETED(src)) // diseases can qdel the mob via transformations
			return


		if(stat != DEAD)
			//Random events (vomiting etc)
			handle_random_events(delta_time, times_fired)

			. = TRUE

		//Handle temperature/pressure differences between body and environment
		// var/datum/gas_mixture/environment = loc.return_air()
		if(environment)
			handle_environment(environment, delta_time, times_fired)

		//Chemicals in the body
		handle_chemicals_in_body()

		//Check if we're on fire
		handle_fire()

		update_pulling()

		for(var/obj/item/weapon/grab/G in src)
			G.Process()

		blinded = FALSE // Placing this here just show how out of place it is.
		// human/handle_regular_status_updates() needs a cleanup, as blindness should be handled in handle_disabilities()
		if(handle_regular_status_updates()) // Status & health update, are we dead or alive etc.
			handle_disabilities() // eye, ear, brain damages
			handle_status_effects() //all special effects, stunned, weakened, jitteryness, hallucination, sleeping, etc

		handle_actions()

		update_lying_buckled_and_verb_status()

		handle_regular_hud_updates()

	if(machine)
		machine.check_eye(src)

	if(stat != DEAD)
		return 1

/mob/living/proc/handle_breathing(delta_time, times_fired)
	return

/mob/living/proc/handle_mutations_and_radiation(delta_time, times_fired)
	return

/mob/living/proc/handle_chemicals_in_body()
	return

/mob/living/proc/handle_blood()
	return

/mob/living/proc/handle_random_events(delta_time, times_fired)
	return

// Base mob environment handler for body temperature
/mob/living/proc/handle_environment(datum/gas_mixture/environment, delta_time, times_fired)
	return

/mob/living/proc/update_pulling()
	if(pulling)
		if(incapacitated())
			stop_pulling()

//This updates the health and status of the mob (conscious, unconscious, dead)
/mob/living/proc/handle_regular_status_updates()
	updatehealth()
	if(stat != DEAD)
		if(paralysis)
			stat = UNCONSCIOUS
		else if (status_flags & FAKEDEATH)
			stat = UNCONSCIOUS
		else
			stat = CONSCIOUS
		return 1

//this updates all special effects: stunned, sleeping, weakened, druggy, stuttering, etc..
/mob/living/proc/handle_status_effects()
	if(paralysis)
		paralysis = max(paralysis-1,0)
	if(stunned)
		stunned = max(stunned-1,0)
		if(!stunned)
			update_icons()

	if(weakened)
		weakened = max(weakened-1,0)
		if(!weakened)
			update_icons()

/mob/living/proc/handle_disabilities()
	//Eyes
	if(sdisabilities & BLIND || stat)	//blindness from disability or unconsciousness doesn't get better on its own
		eye_blind = max(eye_blind, 1)
	else if(eye_blind)			//blindness, heals slowly over time
		eye_blind = max(eye_blind-1,0)
	else if(eye_blurry)			//blurry eyes heal slowly
		eye_blurry = max(eye_blurry-1, 0)

	//Ears
	if(sdisabilities & DEAF)		//disabled-deaf, doesn't get better on its own
		setEarDamage(-1, max(ear_deaf, 1))
	else
		// deafness heals slowly over time, unless ear_damage is over 100
		if(ear_damage < 100)
			adjustEarDamage(-0.05,-1)

//this handles hud updates. Calls update_vision() and handle_hud_icons()
/mob/living/proc/handle_regular_hud_updates()
	if(!client)	return 0

	handle_hud_icons()
	handle_vision()

	return 1

/mob/living/proc/handle_vision()
//	client.screen.Remove(global_hud.blurry, global_hud.druggy, global_hud.vimpaired, global_hud.darkMask, global_hud.nvg, global_hud.thermal, global_hud.meson, global_hud.science)
	update_sight()

	if(stat == DEAD)
		return

/*	if(eye_blind)
		blind.alpha = 255
	else
		blind.alpha = 0
		if (disabilities & NEARSIGHTED)
			client.screen += global_hud.vimpaired
		if (eye_blurry)
			client.screen += global_hud.blurry
		if (druggy)
			client.screen += global_hud.druggy*/
	if(machine)
		var/viewflags = machine.check_eye(src)
		if(viewflags < 0)
			reset_view(null, 0)
		else if(viewflags)
			sight |= viewflags
	else if(eyeobj)
		if(eyeobj.owner != src)
			reset_view(null)
	else if(!client.adminobs)
		reset_view(null)

/mob/living/proc/update_sight()
	set_sight(0)
	set_see_in_dark(0)
	if(stat == DEAD || eyeobj)
		update_dead_sight()
	else
		if (is_ventcrawling)
			sight |= SEE_TURFS|SEE_OBJS|BLIND
		else
			sight &= ~(SEE_TURFS|SEE_MOBS|SEE_OBJS)
			see_in_dark = initial(see_in_dark)
			see_invisible = initial(see_invisible)
	var/list/vision = get_accumulated_vision_handlers()
	set_sight(sight | vision[1])
	set_see_invisible(max(vision[2], see_invisible))

/mob/living/proc/update_dead_sight()
	sight |= SEE_TURFS
	sight |= SEE_MOBS
	sight |= SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO

/mob/living/proc/handle_hud_icons()
	handle_hud_glasses()

/*/mob/living/proc/HUD_create()
	if (!usr.client)
		return
	usr.client.screen.Cut()
	if(ishuman(usr) && (usr.client.prefs.UI_style != null))
		if (!GLOB.HUDdatums.Find(usr.client.prefs.UI_style))
			log_debug("[usr] try update a HUD, but HUDdatums not have [usr.client.prefs.UI_style]!")
		else
			var/mob/living/carbon/human/H = usr
			var/datum/hud/human/HUDdatum = GLOB.HUDdatums[usr.client.prefs.UI_style]
			if (!H.HUDneed.len)
				if (H.HUDprocess.len)
					log_debug("[usr] have object in HUDprocess list, but HUDneed is empty.")
					for(var/obj/screen/health/HUDobj in H.HUDprocess)
						H.HUDprocess -= HUDobj
						qdel(HUDobj)
				for(var/HUDname in HUDdatum.HUDneed)
					if(!H.species.hud.ProcessHUD.Find(HUDname))
						continue
					var/HUDtype = HUDdatum.HUDneed[HUDname]
					var/obj/screen/HUD = new HUDtype()
					to_chat(world, "[HUD] added")
					H.HUDneed += HUD
					if (HUD.type in HUDdatum.HUDprocess)
						to_chat(world, "[HUD] added in process")
						H.HUDprocess += HUD
					to_chat(world, "[HUD] added in screen")
*/

/turf/simulated
	name = "station"
	var/wet = 0
	var/image/wet_overlay = null

	//Mining resources (for the large drills).
	var/has_resources
	var/list/resources

	var/thermite = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	var/to_be_destroyed = 0 //Used for fire, if a melting temperature was reached, it will be destroyed
	var/max_fire_temperature_sustained = 0 //The max temperature of the fire which it was subjected to



/turf/simulated/New()
	..()
	if(istype(loc, /area/eris/neotheology))
		holy = 1
	levelupdate()



/turf/simulated/Entered(atom/A, atom/OL)
	if(movement_disabled && usr.ckey != movement_disabled_exception)
		to_chat(usr, SPAN_DANGER("Movement is admin-disabled.") ) //This is to identify lag problems
		return

	if (isliving(A))
		var/mob/living/M = A
		if(M.lying)
			return ..()

		// Ugly hack :( Should never have multiple plants in the same tile.
		var/obj/effect/plant/plant = locate() in contents
		if(plant) plant.trodden_on(M)


		if(ishuman(M))


			var/mob/living/carbon/human/H = M

			//Footstep sounds. This proc is in footsteps.dm
			H.handle_footstep(src)

			// Tracking blood
			var/list/bloodDNA = null
			var/bloodcolor=""
			if(H.shoes)
				var/obj/item/clothing/shoes/S = H.shoes
				if(istype(S))
					S.handle_movement(src,(MOVING_QUICKLY(H) ? 1 : 0))
					if(S.track_blood && S.blood_DNA)
						bloodDNA = S.blood_DNA
						bloodcolor=S.blood_color
						S.track_blood--
			else
				if(H.track_blood && H.feet_blood_DNA)
					bloodDNA = H.feet_blood_DNA
					bloodcolor = H.feet_blood_color
					H.track_blood--

			if (bloodDNA)
				src.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints,bloodDNA,H.dir,0,bloodcolor) // Coming
				var/turf/simulated/from = get_step(H,reverse_direction(H.dir))
				if(istype(from) && from)
					from.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints,bloodDNA,0,H.dir,bloodcolor) // Going

				bloodDNA = null

			var/obj/item/implant/core_implant/cruciform/C = H.get_core_implant(/obj/item/implant/core_implant/cruciform)
			if(C && C.active)
				var/obj/item/cruciform_upgrade/upgrade = C.upgrade
				if(upgrade && upgrade.active && istype(upgrade, CUPGRADE_CLEANSING_PSESENCE))
					clean_ultimate(H)

		if(src.wet)

			if(M.buckled || (src.wet == 1 && MOVING_DELIBERATELY(M)))
				return

			var/slip_dist = 1
			var/slip_stun = 6
			var/floor_type = "wet"

			switch(src.wet)
				if(2) // Lube
					floor_type = "slippery"
					slip_dist = 4
					slip_stun = 10
				if(3) // Ice
					floor_type = "icy"
					slip_stun = 4

			if(locate(/obj/structure/multiz/ladder) in get_turf(M.loc))  // Avoid slipping on ladder tiles
				visible_message(SPAN_DANGER("\The [M] supports themself with the ladder to avoid slipping."))
				return ..()
			if(locate(/obj/structure/multiz/stairs) in get_turf(M.loc))  // Avoid slipping on stairs tiles
				visible_message(SPAN_DANGER("\The [M] supports themself with the handrail to avoid slipping."))
				return ..()
			if(M.slip("the [floor_type] floor",slip_stun))
				for(var/i = 0;i<slip_dist;i++)
					step(M, M.dir)
					sleep(1)

	..()



/turf/simulated/proc/can_build_cable(var/mob/user)
	return 0

/turf/simulated/attackby(var/obj/item/thing, var/mob/user)
	if(istype(thing, /obj/item/stack/cable_coil) && can_build_cable(user))
		var/obj/item/stack/cable_coil/coil = thing
		coil.turf_place(src, user)
		return
	return ..()

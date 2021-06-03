var/global/universe_has_ended = 0


/datum/universal_state/supermatter_cascade
 	name = "Supermatter Cascade"
 	desc = "Unknown harmonance affecting universal substructure, converting nearby matter to supermatter."

 	decay_rate = 5 // 5% chance of a turf decaying on lighting update/airflow (there's no actual tick for turfs)

/datum/universal_state/supermatter_cascade/OnShuttleCall(var/mob/user)
	if(user)
		to_chat(user, "<span class='sinister'>All you hear on the frequency is static and panicked screaming. There is no escape.</span>")
	return 0

/datum/universal_state/supermatter_cascade/OnTurfChange(var/turf/T)
	var/turf/space/S = T
	if(istype(S))
		S.color = "#0066FF"
	else
		S.color = initial(S.color)

/datum/universal_state/supermatter_cascade/DecayTurf(var/turf/T)
	if(istype(T,/turf/simulated/wall))
		var/turf/simulated/wall/W=T
		W.melt()
		return
	if(istype(T,/turf/simulated/floor))
		var/turf/simulated/floor/F=T
		// Burnt?
		if(!F.burnt)
			F.burn_tile()
		else
			if(!istype(F,/turf/simulated/floor/plating))
				F.break_tile_to_plating()
		return

// Apply changes when entering state
/datum/universal_state/supermatter_cascade/OnEnter()
	set background = 1
	SSgarbage.state = SS_SLEEPING
	to_chat(world, "<span class='sinister' style='font-size:22pt'>You are blinded by a brilliant flash of energy.</span>")

	world << sound('sound/effects/cascade.ogg')

	for(var/mob/living/M in GLOB.player_list)
		if (M.HUDtech.Find("flash"))
			FLICK("e_flash", M.HUDtech["flash"])

	if(evacuation_controller.cancel_evacuation())
		priority_announcement.Announce("The evacuation has been aborted due to bluespace distortion.")

	AreaSet()
	MiscSet()
	APCSet()
	OverlayAndAmbientSet()

	PlayerSet()

	spawn(rand(30,60) SECONDS)
		var/txt = {"
There's been a galaxy-wide electromagnetic pulse.  All of our systems are heavily damaged and many personnel are dead or dying. We are seeing increasing indications of the universe itself beginning to unravel.

[station_name()], you are the only facility nearby a bluespace rift, which is near your research outpost. You are hereby directed to enter the rift using all means necessary, quite possibly as the last of your species alive.

You have five minutes before the universe collapses. Good l\[\[###!!!-

AUTOMATED ALERT: Link to [command_name()] lost.

The access requirements on the Asteroid Shuttles' consoles have now been revoked.
"}
		priority_announcement.Announce(txt,"SUPERMATTER CASCADE DETECTED")

		for(var/obj/machinery/computer/shuttle_control/C in GLOB.machines)
			if(istype(C, /obj/machinery/computer/shuttle_control/research) || istype(C, /obj/machinery/computer/shuttle_control/mining))
				C.req_access = list()
				C.req_one_access = list()

		spawn(5 MINUTES)
			SSticker.station_explosion_cinematic(0,null) // TODO: Custom cinematic
			universe_has_ended = 1
		return

/datum/universal_state/supermatter_cascade/proc/AreaSet()
	for(var/area/A in all_areas)
		if(!istype(A,/area) || istype(A, /area/space))
			continue

		A.updateicon()

/datum/universal_state/supermatter_cascade/OverlayAndAmbientSet()
	spawn(0)
		for(var/atom/movable/lighting_overlay/L in world)
			if(isAdminLevel(L.z))
				L.update_overlay(1,1,1)
			else
				L.update_overlay(0, 0.4, 1)

		for(var/turf/space/T in turfs)
			OnTurfChange(T)

/datum/universal_state/supermatter_cascade/proc/MiscSet()
	for (var/obj/machinery/firealarm/alm in GLOB.machines)
		if (!(alm.stat & BROKEN))
			alm.ex_act(2)

/datum/universal_state/supermatter_cascade/proc/APCSet()
	for (var/obj/machinery/power/apc/APC in GLOB.machines)
		if (!(APC.stat & BROKEN) && is_valid_apc(APC))
			APC.chargemode = 0
			if(APC.cell)
				APC.cell.charge = 0
			APC.emagged = 1
			APC.queue_icon_update()

/datum/universal_state/supermatter_cascade/proc/PlayerSet()
	for(var/datum/antagonist/A in GLOB.current_antags)
		if(!isliving(A.owner.current))
			continue
		if(A.owner.current.stat!=2)
			A.owner.current.Weaken(10)
//			FLICK("e_flash", M.current.flash)
			if (A.owner.current.HUDtech.Find("flash"))
				FLICK("e_flash", A.owner.current.HUDtech["flash"])

		A.remove_antagonist()

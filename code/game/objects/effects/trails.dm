/*********************************
	Trail systems
**********************************

These systems register an Observation proc on their target atom, and generate a
particle whenever the target moves
*****************/


/datum/effect/effect/system/trail
	var/obj/effect/effect/trail_effect = /obj/effect/trail_particle/gasjet
	var/active = FALSE
	var/obj/item/tank/jetpack/jetpack
	var/fromback = TRUE //The trail is being emitted from something on their back
	//When the user is facing north, it will draw ontop of them

/datum/effect/effect/system/trail/Destroy()
	jetpack = null
	return ..()

/datum/effect/effect/system/trail/set_up(var/atom/_holder, var/obj/item/tank/jetpack/J)
	attach(_holder)
	if (J)
		jetpack = J
	else
		jetpack = holder

/datum/effect/effect/system/trail/start()
	//We can't start unless we're attached to an atom
	if (!holder || active)
		return

	//Moved event is a global datum of type /decl/observ/moved
	//It will fire a proc whenever the holder atom moves from one turf to another
	GLOB.moved_event.register(holder, src, /datum/effect/effect/system/trail/proc/holder_moved)

	active = TRUE


/datum/effect/effect/system/trail/proc/holder_moved(var/atom/A, var/atom/old_loc)
	var/obj/effect/trail_particle/E = do_effect(old_loc, get_dir(A, old_loc))
	if (fromback && ismob(holder.loc)) //Makes jetpack particles draw over the user when facing north
		var/mob/M = holder.loc
		if (M.dir == NORTH)
			E.layer = M.layer+0.01

/datum/effect/effect/system/trail/proc/do_effect(var/turf/eloc, var/newdir)
	var/obj/effect/effect/E = new trail_effect(eloc)
	E.set_dir(newdir)
	return E

/datum/effect/effect/system/trail/proc/stop()
	GLOB.moved_event.unregister(holder, src, /datum/effect/effect/system/trail/proc/holder_moved)
	active = FALSE

/////////////////////////////////////////////
	//Ion trail, not used much now
/////////////////////////////////////////////

/datum/effect/effect/system/trail/ion
	trail_effect = /obj/effect/trail_particle/ion_trails


/////////////////////////////////////////////
//Steam trail, unused
/////////////////////////////////////////////

/datum/effect/effect/system/trail/steam
	trail_effect = /obj/effect/trail_particle/gasjet


/////////////////////////////////////////////
//Fire trail
/////////////////////////////////////////////

/datum/effect/effect/system/trail/fire
	trail_effect = /obj/effect/trail_particle/fire


/********************************************************
	Jetpack Trails
	Subtype made to efficiently sync up with a jetpack.
	They should always be attached to a jetpack
	Does a particle only when the jetpack uses some thrust
**************************************************************/
/datum/effect/effect/system/trail/jet
	trail_effect = /obj/effect/trail_particle/gasjet

//Only do a thrust if the holder has the done var set false, and is also turned on
/datum/effect/effect/system/trail/jet/holder_moved(var/atom/A, var/atom/old_loc)
	if (jetpack && jetpack.thrust_fx_done == FALSE && jetpack.on)
		.=..()
		//Set it true after.
		jetpack.thrust_fx_done = TRUE



/*******************************
	Trail particles.
These are spawned by a trail system
Their only special behaviour atm is to delete themselves shortly after creation
********************************/
/obj/effect/trail_particle
	var/lifetime = 10
	icon = 'icons/effects/effects.dmi'
	mouse_opacity = FALSE
	density = FALSE
	opacity = FALSE

/obj/effect/trail_particle/Initialize()
	addtimer(CALLBACK(src, .proc/finish, TRUE), lifetime)

/obj/effect/trail_particle/proc/finish()
	qdel(src)


/obj/effect/trail_particle/gasjet
	name = "pressurised gas"
	icon_state = "jet"

/obj/effect/trail_particle/ion_trails
	name = "ion trails"
	icon_state = "ion_fade"
	anchored = TRUE

/obj/effect/trail_particle/fire
	name = "fire trail"
	icon_state = "fire_trails"

/obj/effect/trail_particle/fire/Initialize()
	..()
	var/turf/T = get_turf(src)
	T?.hotspot_expose(1000,100)
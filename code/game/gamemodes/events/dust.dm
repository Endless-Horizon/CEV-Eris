//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/*
Space dust
Commonish random event that causes small clumps of "space dust" to hit the station at high speeds.
No command report on the common version of this event.
The "dust" will damage the hull of the station causin minor hull breaches.
*/


/datum/storyevent/dust
	id = "space_dust"
	name = "belt of space dust"

	event_type =/datum/event/dust
	event_pools = list(EVENT_LEVEL_MUNDANE = POOL_THRESHOLD_MUNDANE, EVENT_LEVEL_MODERATE = POOL_THRESHOLD_MODERATE)
	tags = list(TAG_DESTRUCTIVE, TAG_NEGATIVE)


//////////////////////////////////////////////////////////
/datum/event/dust
	startWhen	= 10
	endWhen		= 30

/datum/event/dust/announce()
	command_announcement.Announce("The ship is now passing through a belt of space dust.", "Dust Alert")

/datum/event/dust/start()
	log_and_message_admins("Space dust event triggered,")
	dust_swarm(get_severity())

/datum/event/dust/end()
	command_announcement.Announce("The ship has now passed through the belt of space dust.", "Dust Notice")

/datum/event/dust/proc/get_severity()
	switch(severity)
		if(EVENT_LEVEL_MUNDANE)
			return "weak"
		if(EVENT_LEVEL_MODERATE)
			return prob(80) ? "norm" : "strong"
		if(EVENT_LEVEL_MAJOR)
			return "super"
	return "weak"


/proc/dust_swarm(var/strength = "weak")
	var/numbers = 1
	switch(strength)
		if("weak")
		 numbers = rand(8,15)
		 for(var/i = 0 to numbers)
		 	new/obj/effect/space_dust/weak()
		if("norm")
		 numbers = rand(20,40)
		 for(var/i = 0 to numbers)
		 	new/obj/effect/space_dust()
		if("strong")
		 numbers = rand(40,60)
		 for(var/i = 0 to numbers)
		 	new/obj/effect/space_dust/strong()
		if("super")
		 numbers = rand(60,100)
		 for(var/i = 0 to numbers)
		 	new/obj/effect/space_dust/super()
	return


/obj/effect/space_dust
	name = "Space Dust"
	desc = "Dust in space."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "space_dust"
	density = TRUE
	anchored = TRUE
	var/strength = 2 //ex_act severity number
	var/life = 2 //how many things we hit before qdel(src)

	weak
		strength = 3
		life = 1

	strong
		strength = 1
		life = 6

	super
		strength = 1
		life = 40


	New()
		..()
		var/startx = 0
		var/starty = 0
		var/endy = 0
		var/endx = 0
		var/startside = pick(cardinal)

		switch(startside)
			if(NORTH)
				starty = world.maxy-(TRANSITIONEDGE+1)
				startx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
				endy = TRANSITIONEDGE
				endx = rand(TRANSITIONEDGE, world.maxx-TRANSITIONEDGE)
			if(EAST)
				starty = rand((TRANSITIONEDGE+1),world.maxy-(TRANSITIONEDGE+1))
				startx = world.maxx-(TRANSITIONEDGE+1)
				endy = rand(TRANSITIONEDGE, world.maxy-TRANSITIONEDGE)
				endx = TRANSITIONEDGE
			if(SOUTH)
				starty = (TRANSITIONEDGE+1)
				startx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
				endy = world.maxy-TRANSITIONEDGE
				endx = rand(TRANSITIONEDGE, world.maxx-TRANSITIONEDGE)
			if(WEST)
				starty = rand((TRANSITIONEDGE+1), world.maxy-(TRANSITIONEDGE+1))
				startx = (TRANSITIONEDGE+1)
				endy = rand(TRANSITIONEDGE,world.maxy-TRANSITIONEDGE)
				endx = world.maxx-TRANSITIONEDGE
		var/z_level = pick(GLOB.maps_data.station_levels)
		var/goal = locate(endx, endy, z_level)
		src.x = startx
		src.y = starty
		src.z = z_level
		spawn(0)
			walk_towards(src, goal, 1)
		return

	touch_map_edge()
		qdel(src)

	Bump(atom/A)
		spawn(0)
			if(prob(50))
				for(var/mob/M in range(10, src))
					if(!M.stat && !isAI(M))
						shake_camera(M, 3, 1)
			if(A)
				playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, 1)

				if(ismob(A))
					A.ex_act(strength)//This should work for now I guess

				//Protect the singularity from getting released every round!
				else if(!istype(A,/obj/machinery/power/emitter) && !istype(A,/obj/machinery/field_generator))
					//Changing emitter/field gen ex_act would make it immune to bombs and C4
					A.ex_act(strength)

				life--
				if(life <= 0)
					walk(src,0)
					qdel(src)
		return


	Bumped(atom/A)
		Bump(A)
		return


	ex_act(severity)
		qdel(src)
		return




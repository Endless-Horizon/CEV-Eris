//////////////////////////////
// An asteroid object, could be spawned in, or not
// May or may not include phat lewt
//////////////////////////////
/turf/simulated/mineral/random/rogue
	var/floor_under	= /turf/simulated/floor/asteroid

/turf/simulated/mineral/random/rogue/Initialize()
	. = ..() // STOP SLOWING THE world DOWN
	for(var/turf/T in oview(src,1))
		if(istype(get_turf(T),/turf/space))
			var/turf/simulated/floor/asteroid/flooring = new /turf/simulated/floor/asteroid(T)
			flooring.updateMineralOverlays(1)




/datum/rogue/asteroid
	//Composition
	var/type_wall	= /turf/simulated/mineral/random/rogue		//Type of turf used to generate the asteroid
	var/type_under	= /turf/simulated/floor/asteroid	//Type of turf that's under the normal one

	//Dimensions
	var/coresize 	= 3		//The size of the center square
	var/width		= 9

	//Other Attribs
	var/hollow 		= 0		//Might be hollow for loot injection purposes
	var/spawned 	= 0		//Is this asteroid in-play right now

	//Locational stats
	var/obj/effect/landmark/asteroid_spawn/mylandmark	//The landmark I'm spawned at, if any.


	//Asteroid map
	//The map struct is:
	// map list()
	//  0 = list()
	//  1 = list() //These are x coordinates
	//  2 = list()
	//    ^0 = list()
	//     1 = list() //These are y coordinates at x2
	//     2 = list()
	//       ^type1
	//        type2 //These are items/objects at the coordinate
	//        type3 //This would be object 3 at x2,y2
	var/list/map


//Builds an empty map
/datum/rogue/asteroid/New(var/core, var/tw, var/tu)

	if(core)
		coresize = core
	if(tw)
		type_wall = tw
	if(tu)
		type_under = tu

	width = coresize*3

	map = new/list(width,width,0)


/////////////////////////////
// Predefined asteroid maps
/////////////////////////////
/datum/rogue/asteroid/predef
	width = 3 //Small 1-tile room by default.

/datum/rogue/asteroid/predef/New() //Basically just ignore what we're told.
	map = new/list(width,width,0)

/datum/rogue/asteroid/proc/spot_add(var/x,var/y,var/thing)
	if(!x || !y || !thing)
		return

	var/list/work = map[x][y]
	work.Add(thing)

//Abandoned 1-tile hollow cargo box (pressurized).
/datum/rogue/asteroid/predef/cargo
	type_wall	= /turf/simulated/wall/untinted/onestar
	type_under	= /turf/simulated/floor/plating

	New()
		..()
		spot_add(1,1,type_wall) //Bottom left corner
		spot_add(1,2,type_wall)
		spot_add(1,3,type_wall)
		spot_add(2,1,type_wall)
		spot_add(2,2,type_under) //Center floor
		spot_add(2,2,/obj/spawner/contraband/) //Loot!
		spot_add(2,3,type_wall)
		spot_add(3,1,type_wall)
		spot_add(3,2,type_wall)
		spot_add(3,3,type_wall) //Bottom right corner

//Abandoned 1-tile hollow cargo box (ANGRY).
/datum/rogue/asteroid/predef/cargo/angry
	type_wall	= /turf/simulated/wall/untinted/onestar
	type_under	= /turf/simulated/floor/plating

	New()
		..()
		spot_add(2,2,/obj/spawner/contraband) //EXTRA loot!
		spot_add(2,2,/mob/living/simple_animal/hostile/alien) //GRRR

//Longer cargo container for higher difficulties
/datum/rogue/asteroid/predef/cargo_large
	width = 5
	type_wall	= /turf/simulated/wall/untinted/onestar
	type_under	= /turf/simulated/floor/plating

	New()
		..()
		spot_add(1,2,type_wall) //--
		spot_add(1,3,type_wall) //Left end of cargo container
		spot_add(1,4,type_wall) //--

		spot_add(5,2,type_wall) //--
		spot_add(5,3,type_wall) //Right end of cargo container
		spot_add(5,4,type_wall) //--

		spot_add(2,4,type_wall) //--
		spot_add(3,4,type_wall) //Top and
		spot_add(4,4,type_wall) //bottom of
		spot_add(2,2,type_wall) //cargo
		spot_add(3,2,type_wall) //container
		spot_add(4,2,type_wall) //--

		spot_add(2,3,type_under) //Left floor
		spot_add(3,3,type_under) //Mid floor
		spot_add(4,3,type_under) //Right floor

		spot_add(2,3,/obj/spawner/contraband) //Left loot
		spot_add(3,3,/obj/spawner/contraband) //Mid loot
		spot_add(4,3,/obj/spawner/contraband) //Right loot

		if(prob(30))
			spot_add(3,3,/mob/living/simple_animal/hostile/alien) //And maybe a friend.


/datum/rogue/asteroid/predef/teleporter
	type_wall	= /turf/simulated/wall/untinted/onestar
	type_under	= /turf/simulated/floor/plating

	New()
		..()
		spot_add(1,1,type_under) //Bottom left corner
		spot_add(1,2,type_under)
		spot_add(1,3,type_under)
		spot_add(2,1,type_under)
		spot_add(2,2,type_under) //Center floor
		spot_add(2,2,/obj/rogue/teleporter)
		spot_add(2,2,/obj/crawler/teleport_marker)
		spot_add(2,3,type_under)
		spot_add(3,1,type_under)
		spot_add(3,2,type_under)
		spot_add(3,3,type_under) //Bottom right corner

/obj/asteroid_generator
	name = "asteroid generator"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x3"
	alpha = 120
	anchored = TRUE
	unacidable = 1
	simulated = FALSE
	invisibility = 101
	var/delay = 2

	var/area/asteroid/rogue/myarea

	var/list/obj/asteroid_spawner/rockspawns = list()
	var/list/obj/rogue_mobspawner/mobspawns = list()

	var/mobgenlist = list(
	/mob/living/simple_animal/hostile/bear,
	/mob/living/simple_animal/hostile/carp,
	/mob/living/simple_animal/hostile/carp,
	/mob/living/simple_animal/hostile/carp,
	/mob/living/simple_animal/hostile/hivebot,
	/mob/living/simple_animal/hostile/carp/pike)

	var/prefabs = list(
	/datum/rogue/asteroid/predef/cargo,
	/datum/rogue/asteroid/predef/cargo/angry,
	/datum/rogue/asteroid/predef/cargo_large)

/obj/asteroid_generator/New()
	myarea = get_area(loc)
	populate_z_level()

/obj/asteroid_generator/proc/populate_z_level()
	while(1)
		if(Master.current_runlevel)
			break
		else
			sleep(250)
	for(var/obj/asteroid_spawner/SP in myarea.asteroid_spawns)
		if(prob(85))
			rockspawns += SP
	for(var/obj/rogue_mobspawner/MS in myarea.mob_spawns)
		if(prob(50))
			mobspawns += MS
	for(var/obj/asteroid_spawner/SP in rockspawns)
		var/datum/rogue/asteroid/AS = generate_asteroid()
		place_asteroid(AS,SP)
		if(delay)
			sleep(delay)
	for(var/obj/rogue_mobspawner/MS in mobspawns)
		if(!istype(get_turf(MS),/turf/space))
			mobspawns -= MS
			for(var/obj/rogue_mobspawner/NS in myarea.mob_spawns)
				if(NS in mobspawns)
					continue
				if(istype(get_turf(NS),/turf/space))
					MS = NS
					break
		if(MS)
			var/mobchoice = pick(mobgenlist)
			var/mob/living/newmob = new mobchoice(get_turf(MS))
			newmob.faction = "asteroid_belt" //so they won't just kill each other
	var/teleporter = pick(myarea.teleporter_spawns)
	generate_teleporter(teleporter)

/obj/asteroid_generator/proc/generate_teleporter(var/obj/asteroid_spawner/rogue_teleporter/TP)
	var/TPPREFAB = /datum/rogue/asteroid/predef/teleporter
	var/TPBUILD = new TPPREFAB(null)
	place_asteroid(TPBUILD, TP)

/obj/asteroid_generator/proc/generate_asteroid(var/core_min = 2, var/core_max = 5)
	if(prob(15))
		var/prefab = pick(prefabs)
		var/prefabinst = new prefab(null)
		return prefabinst

	var/datum/rogue/asteroid/A = new(rand(core_min,core_max))

	for(var/x = 1; x <= A.coresize, x++)
		for(var/y = 1; y <= A.coresize, y++)
			A.spot_add(A.coresize+x, A.coresize+y, A.type_wall)


	var/max_armlen = A.coresize - 1 //Can tweak to change appearance.

	//Add the arms to the asteroid's map
	//Vertical arms
	for(var/x = A.coresize+1, x <= A.coresize*2, x++) //Start at leftmost side of core, work towards higher X.
		var/B_arm = rand(0,max_armlen)
		var/T_arm = rand(0,max_armlen)

		//Bottom arm
		for(var/y = A.coresize, y > A.coresize-B_arm, y--) //Start at bottom edge of the core, work towards lower Y.
			A.spot_add(x,y,A.type_wall)
		//Top arm
		for(var/y = (A.coresize*2)+1, y < ((A.coresize*2)+1)+T_arm, y++) //Start at top edge of the core, work towards higher Y.
			A.spot_add(x,y,A.type_wall)


	//Horizontal arms
	for(var/y = A.coresize+1, y <= A.coresize*2, y++) //Start at lower side of core, work towards higher Y.
		var/R_arm = rand(0,max_armlen)
		var/L_arm = rand(0,max_armlen)

		//Right arm
		for(var/x = (A.coresize*2)+1, x <= ((A.coresize*2)+1)+R_arm, x++) //Start at right edge of core, work towards higher X.
			A.spot_add(x,y,A.type_wall)
		//Left arm
		for(var/x = A.coresize, x > A.coresize-L_arm, x--) //Start at left edge of core, work towards lower X.
			A.spot_add(x,y,A.type_wall)

	return A


/obj/asteroid_generator/proc/place_asteroid(var/datum/rogue/asteroid/A,var/obj/asteroid_spawner/SP)
	ASSERT(SP && A)

	SP.myasteroid = A

	//Bottom-left corner of our bounding box
	var/BLx = SP.x - (A.width/2)
	var/BLy = SP.y - (A.width/2)


	for(var/Ix=1, Ix <= A.map.len, Ix++)
		var/list/curr_x = A.map[Ix]

		for(var/Iy=1, Iy <= curr_x.len, Iy++)
			var/list/curr_y = curr_x[Iy]

			var/world_x = BLx+Ix
			var/world_y = BLy+Iy
			var/world_z = SP.z

			var/spot = locate(world_x,world_y,world_z)

			for(var/T in curr_y)
				if(ispath(T,/turf)) //We're spawning a turf


					//Make sure we locate()'d a turf and not something else
					if(!isturf(spot))
						spot = get_turf(spot)
					var/turf/P = spot

					if(P)
						var/turf/newturf = P.ChangeTurf(T)
						if(newturf)//check here, because sometimes it runtimes and shits in the logs
							newturf.update_icon(1)

				else //Anything not a turf
					new T(spot)

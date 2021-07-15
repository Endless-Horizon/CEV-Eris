/*
	Meteors damage the station and the shields
*/
/datum/storyevent/meteor
	id = "meteor"
	name = "meteor shower"


	event_type = /datum/event/meteor_wave
	event_pools = list(EVENT_LEVEL_MODERATE = POOL_THRESHOLD_MODERATE,
	EVENT_LEVEL_MAJOR = POOL_THRESHOLD_MAJOR)

	tags = list(TAG_DESTRUCTIVE, TAG_NEGATIVE, TAG_EXTERNAL)
//===========================================

/datum/event/meteor_wave
	startWhen		= 0//90
	endWhen 		= 120
	var/strength = 1
	var/next_meteor = 6
	var/waves = 1
	var/start_side
	var/next_meteor_lower = 3
	var/next_meteor_upper = 10
	var/duration = 10

/datum/event/meteor_wave/setup()
	switch (severity)
		if (EVENT_LEVEL_MUNDANE)
			strength = 1
		if (EVENT_LEVEL_MODERATE)
			strength = 2
			duration = 40
		if (EVENT_LEVEL_MAJOR)
			strength = 3
			duration = 130
	start_side = pick(cardinal)
	endWhen = startWhen + duration

/datum/event/meteor_wave/announce()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			command_announcement.Announce("Meteors have been detected on collision course with the ship. ETA 3 minutes until impact. Crew are advised to raise shields and stay away from the outer hull", "Meteor Alert", new_sound = 'sound/AI/meteors.ogg')

		else
			command_announcement.Announce("Meteors have been detected on collision course with the ship.ETA 3 minutes until impact.", "Meteor Alert", new_sound = 'sound/AI/meteors.ogg')

/datum/event/meteor_wave/tick()
	if(activeFor >= next_meteor)
		var/pick_side = prob(60) ? start_side : (prob(50) ? turn(start_side, 90) : turn(start_side, -90))

		spawn()
			spawn_meteors(rand(0, strength), get_meteors(), pick_side)
		next_meteor += rand(next_meteor_lower, next_meteor_upper)

/datum/event/meteor_wave/end()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			command_announcement.Announce("The ship has cleared the meteor storm.", "Meteor Alert")
		else
			command_announcement.Announce("The ship has cleared the meteor shower", "Meteor Alert")

/datum/event/meteor_wave/proc/get_meteors()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			return meteors_cataclysm
		if(EVENT_LEVEL_MODERATE)
			return meteors_catastrophic
		else
			return meteors_normal


/datum/event/meteor_wave/overmap
	startWhen		= 5
	endWhen 		= 7
	next_meteor_lower = 5
	next_meteor_upper = 10
	next_meteor = 0
	var/obj/effect/overmap/ship/victim

/datum/event/meteor_wave/overmap/Destroy()
	victim = null
	. = ..()

/datum/event/meteor_wave/overmap/announce()
	command_announcement.Announce("Alert: The ship is now passing through an asteroid field. Brace for impact", "Asteroid Alert", new_sound = 'sound/AI/meteors.ogg')


/*
/datum/event/meteor_wave/overmap/worst_case_end()
	if(endWhen == INFINITY)
		return INFINITY
	else
		return ..()
*/

/datum/event/meteor_wave/overmap/tick()
	if(victim && !victim.is_still()) //Meteors mostly fly in your face
		start_side = prob(90) ? victim.fore_dir : pick(cardinal)
	else if (prob(90))
		return //If you're not moving you wont get hit muc
	..()



/var/const/meteor_wave_delay = 1 MINUTES //minimum wait between waves in tenths of seconds
//set to at least 100 unless you want evarr ruining every round

//Meteor groups, used for various random events and the Meteor gamemode.

// Dust, used by space dust event and during earliest stages of meteor mode.
/var/list/meteors_dust = list(/obj/effect/meteor/dust)

// Standard meteors, used during early stages of the meteor gamemode.
/var/list/meteors_normal = list(\
		/obj/effect/meteor/medium=8,\
		/obj/effect/meteor/dust=3,\
		/obj/effect/meteor/irradiated=3,\
		/obj/effect/meteor/big=3,\
		/obj/effect/meteor/flaming=1,\
		/obj/effect/meteor/golden=1,\
		/obj/effect/meteor/silver=1\
		)

// Threatening meteors, used during the meteor gamemode.
/var/list/meteors_threatening = list(\
		/obj/effect/meteor/big=10,\
		/obj/effect/meteor/medium=5,\
		/obj/effect/meteor/golden=3,\
		/obj/effect/meteor/silver=3,\
		/obj/effect/meteor/flaming=3,\
		/obj/effect/meteor/irradiated=3,\
		/obj/effect/meteor/emp=3\
		)

// Catastrophic meteors, pretty dangerous without shields and used during the meteor gamemode.
/var/list/meteors_catastrophic = list(\
		/obj/effect/meteor/big=75,\
		/obj/effect/meteor/flaming=10,\
		/obj/effect/meteor/irradiated=10,\
		/obj/effect/meteor/emp=10,\
		/obj/effect/meteor/medium=5,\
		/obj/effect/meteor/golden=4,\
		/obj/effect/meteor/silver=4,\
		/obj/effect/meteor/tunguska=1\
		)

// Armageddon meteors, very dangerous, and currently used only during the meteor gamemode.
/var/list/meteors_armageddon = list(\
		/obj/effect/meteor/big=25,\
		/obj/effect/meteor/flaming=10,\
		/obj/effect/meteor/irradiated=10,\
		/obj/effect/meteor/emp=10,\
		/obj/effect/meteor/medium=3,\
		/obj/effect/meteor/tunguska=3,\
		/obj/effect/meteor/golden=2,\
		/obj/effect/meteor/silver=2\
		)

// Cataclysm meteor selection. Very very dangerous and effective even against shields. Used in late game meteor gamemode only.
/var/list/meteors_cataclysm = list(\
		/obj/effect/meteor/big=40,\
		/obj/effect/meteor/emp=20,\
		/obj/effect/meteor/tunguska=20,\
		/obj/effect/meteor/irradiated=10,\
		/obj/effect/meteor/golden=10,\
		/obj/effect/meteor/silver=10,\
		/obj/effect/meteor/flaming=10,\
		/obj/effect/meteor/supermatter=1\
		)


///////////////////////////////
//Meteor spawning global procs
///////////////////////////////

/proc/spawn_meteors(var/number = 1, var/list/meteortypes, var/startSide, var/zlevel)
	for(var/i = 0; i < number; i++)
		//If no target zlevel is specified, then we'll throw each meteor at an individually randomly selected ship zlevel
		var/target_level
		if (zlevel)
			target_level = zlevel
		else
			target_level = pick(GLOB.maps_data.station_levels)
		spawn_meteor(meteortypes, startSide, target_level)

/proc/spawn_meteor(var/list/meteortypes, var/startSide, var/zlevel)
	var/turf/pickedstart = spaceDebrisStartLoc(startSide, zlevel)
	var/turf/pickedgoal = spaceDebrisFinishLoc(startSide, zlevel)
	var/Me = pickweight(meteortypes)
	var/obj/effect/meteor/M = new Me(pickedstart)
	M.dest = pickedgoal
	spawn(0)
		walk_towards(M, M.dest, 1)
	return

/proc/spaceDebrisStartLoc(startSide, Z)
	var/starty
	var/startx
	switch(startSide)
		if(NORTH)
			starty = world.maxy-(TRANSITIONEDGE+1)
			startx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
		if(EAST)
			starty = rand((TRANSITIONEDGE+1),world.maxy-(TRANSITIONEDGE+1))
			startx = world.maxx-(TRANSITIONEDGE+1)
		if(SOUTH)
			starty = (TRANSITIONEDGE+1)
			startx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
		if(WEST)
			starty = rand((TRANSITIONEDGE+1), world.maxy-(TRANSITIONEDGE+1))
			startx = (TRANSITIONEDGE+1)
	var/turf/T = locate(startx, starty, Z)
	return T

/proc/spaceDebrisFinishLoc(startSide, Z)
	var/endy
	var/endx
	switch(startSide)
		if(NORTH)
			endy = TRANSITIONEDGE
			endx = rand(TRANSITIONEDGE, world.maxx-TRANSITIONEDGE)
		if(EAST)
			endy = rand(TRANSITIONEDGE, world.maxy-TRANSITIONEDGE)
			endx = TRANSITIONEDGE
		if(SOUTH)
			endy = world.maxy-TRANSITIONEDGE
			endx = rand(TRANSITIONEDGE, world.maxx-TRANSITIONEDGE)
		if(WEST)
			endy = rand(TRANSITIONEDGE,world.maxy-TRANSITIONEDGE)
			endx = world.maxx-TRANSITIONEDGE
	var/turf/T = locate(endx, endy, Z)
	return T

/////////                      ........::::::%%%SPACE_COMET

/var/list/comet_hardcore = list(\
		/obj/effect/meteor/large/ice=40,\
		/obj/effect/meteor/medium/ice=20,\
		/obj/effect/meteor/dust/ice=10
		)

/var/list/comet_mediumrare = list(\
		/obj/effect/meteor/medium/ice=40,\
		/obj/effect/meteor/large/ice=10,\
		/obj/effect/meteor/dust/ice=20
		)

/var/list/comet_mini = list(\
		/obj/effect/meteor/medium/ice=10,\
		/obj/effect/meteor/large/ice=5,\
		/obj/effect/meteor/dust/ice=40
		)

/obj/effect/meteor/large/ice
	name = "comet"
	icon_state = "comet_tail"
	hits = 8
	dropamt = 3

/obj/effect/meteor/medium/ice
	name = "comet"
	icon_state = "comet_tail"
	hits = 6
	dropamt = 3

/obj/effect/meteor/dust/ice
	name = "comet ice"
	icon_state = "comet_tail"
	hits = 1
	hitpwr = 3
	dropamt = 1

/datum/event/meteor_wave/overmap/space_comet/get_meteors()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			return comet_hardcore
		if(EVENT_LEVEL_MODERATE)
			return comet_mediumrare
		else
			return comet_mini

/datum/event/meteor_wave/overmap/space_comet/hard
	startWhen		= 0//90
	endWhen 		= 120
	strength = 7
	duration = 60

/datum/event/meteor_wave/overmap/space_comet/medium
	startWhen		= 0//90
	endWhen 		= 120
	strength = 5
	duration = 30

/datum/event/meteor_wave/overmap/space_comet/mini
	startWhen		= 0//90
	endWhen 		= 120
	strength = 2
	duration = 20

//////                                                                           SPACE_COMET%%%::::::........


///////////////////////
//The meteor effect
//////////////////////

/obj/effect/meteor
	name = "the concept of meteor"
	desc = "You should probably run instead of gawking at this."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small"
	density = TRUE
	anchored = TRUE
	var/hits = 4
	var/hitpwr = 2 //Level of ex_act to be called on hit.
	var/dest
	pass_flags = PASSTABLE
	var/heavy = 0
	var/z_original
	var/meteordrop = /obj/item/ore/iron
	var/dropamt = 1

	var/move_count = 0

	var/turf/hit_location //used for reporting hit locations. The meteor may be deleted and its location nulled by report time

/obj/effect/meteor/proc/get_shield_damage()
	return max(((max(hits, 2)) * (heavy + 1) * rand(100, 140)) / hitpwr , 0)

/obj/effect/meteor/New()
	..()
	z_original = z


/obj/effect/meteor/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, var/glide_size_override = 0)
	. = ..() //process movement...
	move_count++
	if(loc == dest)
		qdel(src)

/obj/effect/meteor/touch_map_edge()
	if(move_count > TRANSITIONEDGE)
		qdel(src)

/obj/effect/meteor/Destroy()
	walk(src,0) //this cancels the walk_towards() proc
	return ..()

/obj/effect/meteor/New()
	..()
	SpinAnimation()

/obj/effect/meteor/Bump(atom/A)
	hit_location = get_turf(src) //We always cache the last hit location before doing anything that might result in deleting the meteor
	..()
	if(A && !QDELETED(src))	// Prevents explosions and other effects when we were deleted by whatever we Bumped() - currently used by shields.
		ram_turf(get_turf(A))
		get_hit() //should only get hit once per move attempt

/obj/effect/meteor/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return istype(mover, /obj/effect/meteor) ? 1 : ..()

/obj/effect/meteor/proc/ram_turf(var/turf/T)
	//first bust whatever is in the turf
	for(var/atom/A in T)
		if(A != src && !A.CanPass(src, src.loc, 0.5, 0)) //only ram stuff that would actually block us
			A.ex_act(hitpwr)

	//then, ram the turf if it still exists
	if(T && !T.CanPass(src, src.loc, 0.5, 0))
		T.ex_act(hitpwr)

//process getting 'hit' by colliding with a dense object
//or randomly when ramming turfs
/obj/effect/meteor/proc/get_hit()
	hits--
	if(hits <= 0)
		make_debris()
		meteor_effect()
		qdel(src)

/obj/effect/meteor/ex_act()
	return

/obj/effect/meteor/attackby(obj/item/W as obj, mob/user as mob, params)
	var/tool_type = W.get_tool_type(user, list(QUALITY_DIGGING, QUALITY_EXCAVATION), src)
	if(tool_type & QUALITY_DIGGING | QUALITY_EXCAVATION)
		if(W.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_VERY_EASY,  required_stat = STAT_ROB))
			qdel(src)
			return
	..()

/obj/effect/meteor/proc/make_debris()
	for(var/throws = dropamt, throws > 0, throws--)
		var/obj/item/O = new meteordrop(get_turf(src))
		O.throw_at(dest, 5, 10)

/obj/effect/meteor/proc/meteor_effect()
	//Logging. A meteor impact sends a message to admins with a clickable link.
	//This allows them to jump over and see what happened, its tremendously interesting
	if (istype(hit_location))
		var/area/A = get_area(hit_location)
		var/where = "[A? A.name : "Unknown Location"] | [hit_location.x], [hit_location.y]"
		var/whereLink = "<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[hit_location.x];Y=[hit_location.y];Z=[hit_location.z]'>[where]</a>"
		message_admins("A meteor has impacted at ([whereLink])", 0, 1)
		log_game("A meteor has impacted at ([where]).")

	if(heavy)
		for(var/mob/M in GLOB.player_list)
			var/turf/T = get_turf(M)
			if(!T || T.z != src.z)
				continue
			var/dist = get_dist(M.loc, src.loc)
			shake_camera(M, dist > 20 ? 3 : 5, dist > 20 ? 1 : 3)


///////////////////////
//Meteor types
///////////////////////

//Dust
/obj/effect/meteor/dust
	name = "space dust"
	icon_state = "dust"
	pass_flags = PASSTABLE | PASSGRILLE
	hits = 1
	hitpwr = 3
	dropamt = 1
	meteordrop = /obj/item/ore/glass

//Medium-sized
/obj/effect/meteor/medium
	name = "meteor"
	dropamt = 2

/obj/effect/meteor/medium/meteor_effect()
	..()
	explosion(src.loc, 0, 1, 2, 3, 0)

//Large-sized
/obj/effect/meteor/big
	name = "large meteor"
	icon_state = "large"
	hits = 6
	heavy = 1
	dropamt = 3

/obj/effect/meteor/big/meteor_effect()
	..()
	explosion(src.loc, 1, 2, 3, 4, 0)

//Flaming meteor
/obj/effect/meteor/flaming
	name = "flaming meteor"
	icon_state = "flaming"
	hits = 5
	heavy = 1
	meteordrop = /obj/item/ore/plasma

/obj/effect/meteor/flaming/meteor_effect()
	..()
	explosion(src.loc, 1, 2, 3, 4, 0, 0, 5)

//Radiation meteor
/obj/effect/meteor/irradiated
	name = "glowing meteor"
	icon_state = "glowing"
	heavy = 1
	meteordrop = /obj/item/ore/uranium

/obj/effect/meteor/irradiated/meteor_effect()
	..()
	explosion(src.loc, 0, 0, 4, 3, 0)
	new /obj/effect/decal/cleanable/greenglow(get_turf(src))
	//SSradiation.radiate(src, 50) //TODO: Port bay radiation system

/obj/effect/meteor/golden
	name = "golden meteor"
	icon_state = "glowing"
	desc = "Shiny! But also deadly."
	meteordrop = /obj/item/ore/gold

/obj/effect/meteor/silver
	name = "silver meteor"
	icon_state = "glowing_blue"
	desc = "Shiny! But also deadly."
	meteordrop = /obj/item/ore/silver

/obj/effect/meteor/emp
	name = "conducting meteor"
	icon_state = "glowing_blue"
	desc = "Hide your floppies!"
	meteordrop = /obj/item/ore/osmium
	dropamt = 2

/obj/effect/meteor/emp/meteor_effect()
	..()
	// Best case scenario: Comparable to a low-yield EMP grenade.
	// Worst case scenario: Comparable to a standard yield EMP grenade.
	empulse(src, rand(2, 4), rand(4, 10))

/obj/effect/meteor/emp/get_shield_damage()
	return ..() * rand(2,4)

//Station buster Tunguska
/obj/effect/meteor/tunguska
	name = "tunguska meteor"
	icon_state = "flaming"
	desc = "Your life briefly passes before your eyes the moment you lay them on this monstrosity."
	hits = 10
	hitpwr = 1
	heavy = 1
	meteordrop = /obj/item/ore/diamond	// Probably means why it penetrates the hull so easily before exploding.

/obj/effect/meteor/tunguska/meteor_effect()
	..()
	explosion(src.loc, 3, 6, 9, 20, 0)

// This is the final solution against shields - a single impact can bring down most shield generators.
/obj/effect/meteor/supermatter
	name = "supermatter shard"
	desc = "Oh god, what will be next..?"
	icon = 'icons/obj/engine.dmi'
	icon_state = "darkmatter"

/obj/effect/meteor/supermatter/meteor_effect()
	..()
	explosion(src.loc, 1, 2, 3, 4, 0)
	for(var/obj/machinery/power/apc/A in range(rand(12, 20), src))
		A.energy_fail(round(10 * rand(8, 12)))

/obj/effect/meteor/supermatter/get_shield_damage()
	return ..() * rand(80, 120)
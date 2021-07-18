/proc/get_storyteller()
	return

GLOBAL_DATUM(storyteller, /datum/storyteller)
/datum/storyevent
	var/id = "event" //An id for internal use. No spaces or punctuation, 12 letter max length
		//Only admins/devs will see it

	var/name = "event" //More publicly visible name. Use proper spacing, capitalize proper nouns
		//Players may see the name
	var/processing = FALSE




	var/enabled = TRUE //Compile time switch to enable/disable the event completely

	var/parallel = TRUE //Set true for storyevents that don't need to do any processing and will finish firing in a single stack
	//When false, multiple copies of this event cannot be queued up at the same time.
	//The storyteller will be forced to wait for the previously scheduled copy to resolve completely


	var/weight_cache = 0

	var/last_spawn_time = 0

/datum/event
	var/name = "unknown event"
	var/startWhen		= 0	//When in the lifetime to call start().
	var/announceWhen	= 0	//When in the lifetime to call announce().
	var/endWhen			= 0	//When in the lifetime the event should end.

	var/severity		= 0 //Severity. Lower means less severe, higher means more severe. Does not have to be supported. Is set on New().
	var/activeFor		= 0	//How long the event has existed. You don't need to change this.
	var/isRunning		= 1 //If this event is currently running. You should not change this.
	var/startedAt		= 0 //When this event started.
	var/endedAt			= 0 //When this event ended.
	var/datum/storyevent/storyevent = null

/proc/is_valid_apc(var/obj/machinery/power/apc/apc)
	var/area/A = get_area(apc)
	return !(A && (A.flags & AREA_FLAG_CRITICAL)) && !apc.emagged && isOnShipLevel(apc)



/datum/event/proc/Initialize()

/datum/event/proc/kill()

/datum/event/meteor_wave/overmap

/datum/event/meteor_wave/overmap/space_comet/mini

/datum/event/meteor_wave/overmap/space_comet/medium

/datum/event/meteor_wave/overmap/space_comet/hard

/datum/event/electrical_storm

/datum/event/dust

/datum/event/ionstorm

/datum/event/carp_migration

/obj/effect/blob/core

/datum/storyteller
	var/config_tag
	var/name = "govno ebanoe"

/proc/lightsout()

/proc/power_restore()

/proc/power_failure()

/proc/power_restore_quick()

/proc/IonStorm()

/proc/set_storyteller()

/obj/effect/blob
	name = "blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob"
	var/icon_scale = 1
	light_range = 3
	desc = "Some blob creature thingy"
	density = FALSE //Normal blobs can be walked over, but it's not a good idea

	opacity = 0
	anchored = TRUE
	mouse_opacity = 2

	var/maxHealth = 20
	var/health = 1
	var/health_regen = 1.7
	var/brute_resist = 1.25
	var/fire_resist = 0.6
	var/expandType = /obj/effect/blob

	//We will periodically update and track neighbors in two lists:
	//One which contains all blobs in cardinal directions, and one which contains all cardinal turfs that dont have blobs
	var/list/blob_neighbors = list()
	var/list/non_blob_neighbors = list()
	var/obj/effect/blob/core/core

	var/obj/effect/blob/parent
	var/active = FALSE

	//World time when we're allowed to expand next.
	//Expansion gets slower as the blob gets farther away from the origin core
	var/next_expansion = 0
	var/coredist = 1
	var/dist_time_scaling = 1.5

/obj/effect/overlay/wallrot

/proc/fill_storyevents_list()

/obj/effect/space_dust

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
	var/meteordrop = /obj/item/weapon/ore/iron
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

/obj/effect/meteor/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
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
	meteordrop = /obj/item/weapon/ore/glass

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
	meteordrop = /obj/item/weapon/ore/plasma

/obj/effect/meteor/flaming/meteor_effect()
	..()
	explosion(src.loc, 1, 2, 3, 4, 0, 0, 5)

//Radiation meteor
/obj/effect/meteor/irradiated
	name = "glowing meteor"
	icon_state = "glowing"
	heavy = 1
	meteordrop = /obj/item/weapon/ore/uranium

/obj/effect/meteor/irradiated/meteor_effect()
	..()
	explosion(src.loc, 0, 0, 4, 3, 0)
	new /obj/effect/decal/cleanable/greenglow(get_turf(src))
	//SSradiation.radiate(src, 50) //TODO: Port bay radiation system

/obj/effect/meteor/golden
	name = "golden meteor"
	icon_state = "glowing"
	desc = "Shiny! But also deadly."
	meteordrop = /obj/item/weapon/ore/gold

/obj/effect/meteor/silver
	name = "silver meteor"
	icon_state = "glowing_blue"
	desc = "Shiny! But also deadly."
	meteordrop = /obj/item/weapon/ore/silver

/obj/effect/meteor/emp
	name = "conducting meteor"
	icon_state = "glowing_blue"
	desc = "Hide your floppies!"
	meteordrop = /obj/item/weapon/ore/osmium
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
	meteordrop = /obj/item/weapon/ore/diamond	// Probably means why it penetrates the hull so easily before exploding.

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

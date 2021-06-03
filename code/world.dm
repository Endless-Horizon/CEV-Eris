//This file is just for the necessary /world definition
//Try looking in game/world.dm

/**
 * # World
 *
 * Two possibilities exist: either we are alone in the Universe or we are not. Both are equally terrifying. ~ Arthur C. Clarke
 *
 * The byond world object stores some basic byond level config, and has a few hub specific procs for managing hub visiblity
 *
 * The world /New() is the root of where a round itself begins
 */
/world
	mob = /mob/new_player
	turf = /turf/space
	area = /area/space
	view = "15x15"
	hub = "Exadv1.spacestation13"
	hub_password = "kMZy3U5jJHSiBQjr"
	name = "Eris Station"
	fps = 20
	/// Eris specific
	cache_lifespan = 0	//stops player uploaded stuff from being kept in the rsc past the current session
#ifdef FIND_REF_NO_CHECK_TICK
	loop_checks = FALSE
#endif

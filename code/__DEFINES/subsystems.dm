
//! ## Timing subsystem
/**
 * Don't run if there is an identical unique timer active
 *
 * if the arguments to addtimer are the same as an existing timer, it doesn't create a new timer,
 * and returns the id of the existing timer
 */
#define TIMER_UNIQUE (1<<0)

///For unique timers: Replace the old timer rather then not start this one
#define TIMER_OVERRIDE (1<<1)

/**
 * Timing should be based on how timing progresses on clients, not the server.
 *
 * Tracking this is more expensive,
 * should only be used in conjuction with things that have to progress client side, such as
 * animate() or sound()
 */
#define TIMER_CLIENT_TIME (1<<2)

///Timer can be stopped using deltimer()
#define TIMER_STOPPABLE (1<<3)

///prevents distinguishing identical timers with the wait variable
///
///To be used with TIMER_UNIQUE
#define TIMER_NO_HASH_WAIT (1<<4)

///Loops the timer repeatedly until qdeleted
///
///In most cases you want a subsystem instead, so don't use this unless you have a good reason
#define TIMER_LOOP (1<<5)

///Delete the timer on parent datum Destroy() and when deltimer'd
#define TIMER_DELETE_ME (1<<6)

///Empty ID define
#define TIMER_ID_NULL -1

//For servers that can't do with any additional lag, set this to none in flightpacks.dm in subsystem/processing.
#define FLIGHTSUIT_PROCESSING_NONE 0
#define FLIGHTSUIT_PROCESSING_FULL 1

#define INITIALIZATION_INSSATOMS 0	//New should not call Initialize
#define INITIALIZATION_INNEW_MAPLOAD 1	//New should call Initialize(TRUE)
#define INITIALIZATION_INNEW_REGULAR 2	//New should call Initialize(FALSE)

//! ### Initialization hints

///Nothing happens
#define INITIALIZE_HINT_NORMAL 0
/**
 * call LateInitialize at the end of all atom Initalization
 *
 * The item will be added to the late_loaders list, this is iterated over after
 * initalization of subsystems is complete and calls LateInitalize on the atom
 * see [this file for the LateIntialize proc](atom.html#proc/LateInitialize)
 */
#define INITIALIZE_HINT_LATELOAD 1

///Call qdel on the atom after intialization
#define INITIALIZE_HINT_QDEL 2

//type and all subtypes should always call Initialize in New()
#define INITIALIZE_IMMEDIATE(X) ##X/New(loc, ...){\
	..();\
	if(!initialized) {\
		args[1] = TRUE;\
		SSatoms.InitAtom(src, args);\
	}\
}

// Subsystem init_order, from highest priority to lowest priority
// Subsystems shutdown in the reverse of the order they initialize in
// The numbers just define the ordering, they are meaningless otherwise.

#define INIT_ORDER_GARBAGE 99
#define INIT_ORDER_DBCORE 95
#define INIT_ORDER_BLACKBOX 94
#define INIT_ORDER_SERVER_MAINT 93
#define INIT_ORDER_JOBS 65
#define INIT_ORDER_SKYBOX 20
#define INIT_ORDER_EVENTS 15
#define INIT_ORDER_TICKER 14
#define INIT_ORDER_SPAWN_DATA 13
#define INIT_ORDER_MAPPING 12
#define INIT_ORDER_LANGUAGE 11
#define INIT_ORDER_INVENTORY 10
#define INIT_ORDER_CHAR_SETUP 9
#define INIT_ORDER_ATOMS 8
#define INIT_ORDER_MACHINES 7
#define INIT_ORDER_TIMER 1
#define INIT_ORDER_DEFAULT 0
#define INIT_ORDER_AIR -1
#define INIT_ORDER_ALARM -2
#define INIT_ORDER_MINIMAP -3
#define INIT_ORDER_HOLOMAPS -4
#define INIT_ORDER_ASSETS -5
#define INIT_ORDER_ICON_SMOOTHING -6
#define INIT_ORDER_OVERLAY -7
#define INIT_ORDER_XKEYSCORE -10
#define INIT_ORDER_STICKY_BAN -10
#define INIT_ORDER_TICKETS -10
#define INIT_ORDER_LIGHTING -20
#define INIT_ORDER_SHUTTLE -21
#define INIT_ORDER_SQUEAK -40
#define INIT_ORDER_XENOARCH	-41 // minor mapping 2
#define INIT_ORDER_PERSISTENCE -94
#define INIT_OPEN_SPACE -95
#define INIT_ORDER_CRAFT -96
#define INIT_ORDER_LATELOAD -97
#define INIT_ORDER_STATPANELS -98
#define INIT_ORDER_CHAT	-100

// SS runlevels

#define RUNLEVEL_INIT 0
#define RUNLEVEL_LOBBY 1
#define RUNLEVEL_SETUP 2
#define RUNLEVEL_GAME 4
#define RUNLEVEL_POSTGAME 8

#define RUNLEVELS_DEFAULT (RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME)

/// ss machine process on a different hook. fucking dumb solution
#define START_PROCESSING_IN_LIST(Datum, List) \
if (Datum.is_processing) {\
	if(Datum.is_processing != "SSmachines.[#List]")\
	{\
		crash_with("Failed to start processing. [log_info_line(Datum)] is already being processed by [Datum.is_processing] but queue attempt occured on SSmachines.[#List]."); \
	}\
} else {\
	START_PROCESSING(SSmachinery, Datum)\
}

#define STOP_PROCESSING_IN_LIST(Datum, List) \
if(Datum.is_processing) {\
	STOP_PROCESSING(SSmachinery, Datum)\
}

#define START_PROCESSING_PIPENET(Datum) START_PROCESSING_IN_LIST(Datum, pipenets)
#define STOP_PROCESSING_PIPENET(Datum) STOP_PROCESSING_IN_LIST(Datum, pipenets)

#define START_PROCESSING_POWERNET(Datum) START_PROCESSING_IN_LIST(Datum, powernets)
#define STOP_PROCESSING_POWERNET(Datum) STOP_PROCESSING_IN_LIST(Datum, powernets)

#define START_PROCESSING_POWER_OBJECT(Datum) START_PROCESSING_IN_LIST(Datum, power_objects)
#define STOP_PROCESSING_POWER_OBJECT(Datum) STOP_PROCESSING_IN_LIST(Datum, power_objects)

/**
	Create a new timer and add it to the queue.
	* Arguments:
	* * callback the callback to call on timer finish
	* * wait deciseconds to run the timer for
	* * flags flags for this timer, see: code\__DEFINES\subsystems.dm
*/
#define addtimer(args...) _addtimer(args, file = __FILE__, line = __LINE__)

// Air subsystem subtasks
#define SSAIR_PIPENETS 1
#define SSAIR_ATMOSMACHINERY 2
#define SSAIR_ACTIVETURFS 3 // (cost_tiles)
#define SSAIR_DEFER_AT 4
#define SSAIR_EDGES 5 // (cost_edges)
#define SSAIR_FIRE 6 // (cost_fire)
#define SSAIR_HOTSPOTS 7 // (cost_hotspot)
#define SSAIR_ZONE 8

// Subsystem delta times or tickrates, in seconds. I.e, how many seconds in between each process() call for objects being processed by that subsystem.
// Only use these defines if you want to access some other objects processing delta_time, otherwise use the delta_time that is sent as a parameter to process()
#define SSFLUIDS_DT (SSfluids.wait/10)
#define SSMACHINES_DT (SSmachines.wait/10)
#define SSMOBS_DT (SSmobs.wait/10)
#define SSOBJ_DT (SSobj.wait/10)

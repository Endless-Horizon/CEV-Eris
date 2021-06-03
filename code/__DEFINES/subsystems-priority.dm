// Something to remember when setting priorities: SS_TICKER runs before Normal, which runs before SS_BACKGROUND.
// Each group has its own priority bracket.
// SS_BACKGROUND handles high server load differently than Normal and SS_TICKER do.
// Higher priority also means a larger share of a given tick before sleep checks.

// SS_TICKER
// < none >

#define FIRE_PRIORITY_DEFAULT 50          // Default priority for both normal and background processes

// Normal

#define FIRE_PRIORITY_TIMER 700
#define FIRE_PRIORITY_TICKER         200	// Gameticker processing.
#define FIRE_PRIORITY_MOB            100	// Mob Life().
#define FIRE_PRIORITY_CHAT		   100  // Chat subsystem.
#define FIRE_PRIORITY_MACHINERY      100	// Machinery + powernet ticks.
#define FIRE_PRIORITY_AIR            80	// ZAS processing.
#define FIRE_PRIORITY_ALARM          20	// Alarm processing.
#define FIRE_PRIORITY_EVENT          20	// Event processing.
#define FIRE_PRIORITY_SHUTTLE        20	// Shuttle movement.
#define FIRE_PRIORITY_PROCESS 25
#define FIRE_PRIORITY_AIRFLOW        15	// Object movement from ZAS airflow.
#define FIRE_PRIORITY_INACTIVITY     10	// Idle kicking.
#define FIRE_PRIORITY_SUPPLY         10	// Supply point accumulation.
#define FIRE_PRIORITY_PING           10	// Client ping.
#define FIRE_PRIORITY_TICKETS	       10

// SS_BACKGROUND
#define FIRE_PRIORITY_TGUI 110 // TGUI go brrrr
#define FIRE_PRIORITY_OBJECTS       60	// processing_objects processing.
#define FIRE_PRIORITY_PROCESSING    30	// Generic datum processor. Replaces objects processor.
#define FIRE_PRIORITY_VINES         25	// Spreading vine effects.
#define FIRE_PRIORITY_TURF          20	// Radioactive walls/blob.
#define FIRE_PRIORITY_NANO          20	// Updates to nanoui uis.
#define FIRE_PRIORITY_EVAC          20	// Processes the evac controller.
#define FIRE_PRIORITY_GARBAGE       15	// Garbage collection.
#define FIRE_PRIORITY_WIRELESS      10	// Wireless connection setup.
#define FIRE_PRIORITY_TIPS          10	// Tips and tricks manager.

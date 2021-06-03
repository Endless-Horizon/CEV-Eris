var/global/defer_powernet_rebuild = 0      // True if net rebuild will be called manually after an event.

#define CELLRATE 0.002 // Multiplier for watts per tick <> cell storage (e.g., 0.02 means if there is a load of 1000 watts, 20 units will be taken from a cell per second)
                       // It's a conversion constant. power_used*CELLRATE = charge_provided, or charge_used/CELLRATE = power_provided

// Doors!
#define DOOR_CRUSH_DAMAGE 15
#define ALIEN_SELECT_AFK_BUFFER  1    // How many minutes that a person can be AFK before not being allowed to be an alien.

// Channel numbers for power.
#define EQUIP   1
#define LIGHT   2
#define ENVIRON 3
#define TOTAL   4 // For total power used only.

//Power use var/use_power
#define NO_POWER_USE		0
#define IDLE_POWER_USE		1
#define ACTIVE_POWER_USE	2

/// Bitflags for a machine's preferences on when it should start processing. For use with machinery's `processing_flags` var.
#define START_PROCESSING_ON_INIT (1<<0) /// Indicates the machine will automatically start processing right after it's `Initialize()` is ran.
#define START_PROCESSING_MANUALLY (1<<1) /// Machines with this flag will not start processing when it's spawned. Use this if you want to manually control when a machine starts processing.

// Bitflags for machine stat variable.
#define BROKEN   0x1
#define NOPOWER  0x2
#define POWEROFF 0x4  // TBD.
#define MAINT    0x8  // Under maintenance.
#define EMPED    0x10 // Temporary broken by EMP pulse.

#define AI_CAMERA_LUMINOSITY 6

//Frame types
#define FRAME_DEFAULT 0
#define FRAME_VERTICAL 1		//For 2-tiles machines
//#define FRAME_HORIZONTAL 2

// Camera networks
#define NETWORK_CRESCENT "Crescent"
#define NETWORK_FIRST_SECTION "First Section"
#define	NETWORK_SECOND_SECTION "Second Section"
#define	NETWORK_THIRD_SECTION "Third Section"
#define	NETWORK_FOURTH_SECTION "Fourth Section"
#define NETWORK_COMMAND "Command"
#define NETWORK_ENGINE "Engine"
#define NETWORK_ENGINEERING "Engineering"
#define NETWORK_CEV_ERIS "CEV Eris"
#define NETWORK_MEDICAL "Medical"
#define NETWORK_MERCENARY "MercurialNet"
#define NETWORK_MINE "Mining Shuttle - Hulk"
#define NETWORK_RESEARCH "Research"
#define NETWORK_RESEARCH_OUTPOST "Research Shuttle - Vasiliy Dokuchaev"
#define NETWORK_ROBOTS "Robots"
#define NETWORK_PRISON "Prison"
#define NETWORK_SECURITY "Security"
#define NETWORK_TELECOM "Tcomsat"
#define NETWORK_THUNDER "Thunderdome"

#define NETWORK_ALARM_ATMOS "Atmosphere Alarms"
#define NETWORK_ALARM_CAMERA "Camera Alarms"
#define NETWORK_ALARM_FIRE "Fire Alarms"
#define NETWORK_ALARM_MOTION "Motion Alarms"
#define NETWORK_ALARM_POWER "Power Alarms"

// Those networks can only be accessed by pre-existing terminals. AIs and new terminals can't use them.
var/list/restricted_camera_networks = list(NETWORK_MERCENARY, "Secret")


//singularity defines
#define STAGE_ONE 	1
#define STAGE_TWO 	3
#define STAGE_THREE	5
#define STAGE_FOUR	7
#define STAGE_FIVE	9
#define STAGE_SUPER	11

// computer3 error codes, move lower in the file when it passes dev -Sayu
#define PROG_CRASH          0x1  // Generic crash.
#define MISSING_PERIPHERAL  0x2  // Missing hardware.
#define BUSTED_ASS_COMPUTER 0x4  // Self-perpetuating error.  BAC will continue to crash forever.
#define MISSING_PROGRAM     0x8  // Some files try to automatically launch a program. This is that failing.
#define FILE_DRM            0x10 // Some files want to not be copied/moved. This is them complaining that you tried.
#define NETWORK_FAILURE     0x20

// NanoUI flags
#define STATUS_INTERACTIVE 2 // GREEN Visability
#define STATUS_UPDATE 1 // ORANGE Visability
#define STATUS_DISABLED 0 // RED Visability
#define STATUS_CLOSE -1 // Close the interface

/*
 *	Atmospherics Machinery.
*/
#define MAX_SIPHON_FLOWRATE   2500 // L/s. This can be used to balance how fast a room is siphoned. Anything higher than CELL_VOLUME has no effect.
#define MAX_SCRUBBER_FLOWRATE 400  // L/s. Max flow rate when scrubbing from a turf.

// These balance how easy or hard it is to create huge pressure gradients with pumps and filters.
// Lower values means it takes longer to create large pressures differences.
// Has no effect on pumping gasses from high pressure to low, only from low to high.
#define ATMOS_PUMP_EFFICIENCY   10 // 10 is maximum value.
#define ATMOS_FILTER_EFFICIENCY 2.5

// Will not bother pumping or filtering if the gas source as fewer than this amount of moles, to help with performance.
#define MINIMUM_MOLES_TO_PUMP   0.01
#define MINIMUM_MOLES_TO_FILTER 0.04

// The flow rate/effectiveness of various atmos devices is limited by their internal volume,
// so for many atmos devices these will control maximum flow rates in L/s.
#define ATMOS_DEFAULT_VOLUME_PUMP   200 // Liters.
#define ATMOS_DEFAULT_VOLUME_FILTER 200 // L.
#define ATMOS_DEFAULT_VOLUME_MIXER  200 // L.
#define ATMOS_DEFAULT_VOLUME_PIPE   70  // L.

//Disposal pipes
#define PIPE_TYPE_STRAIGHT 0
#define PIPE_TYPE_BENT 1
#define PIPE_TYPE_JUNC 2
#define PIPE_TYPE_JUNC_FLIP 3
#define PIPE_TYPE_JUNC_Y 4
#define PIPE_TYPE_TRUNK 5
#define PIPE_TYPE_BIN 6
#define PIPE_TYPE_OUTLET 7
#define PIPE_TYPE_INTAKE 8
#define PIPE_TYPE_JUNC_SORT 9
#define PIPE_TYPE_JUNC_SORT_FLIP 10
#define PIPE_TYPE_UP 11
#define PIPE_TYPE_DOWN 12
#define PIPE_TYPE_TAGGER 13
#define PIPE_TYPE_TAGGER_PART 14

#define SORT_TYPE_NORMAL 0
#define SORT_TYPE_WILDCARD 1
#define SORT_TYPE_UNTAGGED 2


#define KILOWATTS *1000
#define MEGAWATTS *1000000
#define GIGAWATTS *1000000000

// These are used by supermatter and supermatter monitor program, mostly for UI updating purposes. Higher should always be worse!
#define SUPERMATTER_ERROR -1		// Unknown status, shouldn't happen but just in case.
#define SUPERMATTER_INACTIVE 0		// No or minimal energy
#define SUPERMATTER_NORMAL 1		// Normal operation
#define SUPERMATTER_NOTIFY 2		// Ambient temp > 80% of CRITICAL_TEMPERATURE
#define SUPERMATTER_WARNING 3		// Ambient temp > CRITICAL_TEMPERATURE OR integrity damaged
#define SUPERMATTER_DANGER 4		// Integrity < 50%
#define SUPERMATTER_EMERGENCY 5		// Integrity < 25%
#define SUPERMATTER_DELAMINATING 6	// Pretty obvious.

////////////////////////////////////////
//CONTAINS: Air Alarms and Fire Alarms//
////////////////////////////////////////

#define AALARM_MODE_FIRST		1
#define AALARM_MODE_SCRUBBING	1
#define AALARM_MODE_REPLACEMENT	2 //like scrubbing, but faster.
#define AALARM_MODE_PANIC		3 //constantly sucks all air
#define AALARM_MODE_CYCLE		4 //sucks off all air, then refill and switches to scrubbing
#define AALARM_MODE_FILL		5 //emergency fill
#define AALARM_MODE_OFF			6 //Shuts it all down.
#define AALARM_MODE_LAST		6

#define AALARM_SCREEN_MAIN		1
#define AALARM_SCREEN_VENT		2
#define AALARM_SCREEN_SCRUB		3
#define AALARM_SCREEN_MODE		4
#define AALARM_SCREEN_SENSORS	5

#define AALARM_REPORT_TIMEOUT 100

#define RCON_NO		1
#define RCON_AUTO	2
#define RCON_YES	3

#define MAX_TEMPERATURE 90
#define MIN_TEMPERATURE -40

////////////////////////////////////////////


//AUTOLATHE
#define SANITIZE_LATHE_COST(n) round(n * mat_efficiency, 0.01)

//EOTP
#define ARMAMENTS "Armaments"
#define ALERT "Antag Alert"
#define INSPIRATION "Inspiration"
#define ODDITY "Oddity"
#define STAT_BUFF "Stat Buff"
#define MATERIAL_REWARD "Materials"
#define ENERGY_REWARD "Energy"

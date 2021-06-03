#define DEBUG

#define TRANSITIONEDGE 7 // Distance from edge to move to another z-level.
#define RUIN_MAP_EDGE_PAD 15

// Invisibility constants.
#define INVISIBILITY_LIGHTING             20
#define INVISIBILITY_ANGEL                30
#define INVISIBILITY_LEVEL_ONE            35
#define INVISIBILITY_LEVEL_TWO            45
#define INVISIBILITY_OBSERVER             60
#define INVISIBILITY_EYE		          61

#define SEE_INVISIBLE_NOLIGHTING          15
#define SEE_INVISIBLE_LIVING              25
#define SEE_INVISIBLE_ANGEL               30
#define SEE_INVISIBLE_LEVEL_ONE           35
#define SEE_INVISIBLE_LEVEL_TWO           45
#define SEE_INVISIBLE_CULT		          60
#define SEE_INVISIBLE_OBSERVER            61

#define SEE_INVISIBLE_MINIMUM 5
#define INVISIBILITY_MAXIMUM 100

// Some arbitrary defines to be used by self-pruning global lists.
#define PROCESS_KILL 26 // Used to trigger removal from a processing list.
#define MAX_GEAR_COST 5 // Used in chargen for accessory loadout limit.

// For secHUDs and medHUDs and variants. The number is the location of the image on the list hud_list of humans.
#define      HEALTH_HUD 1 // A simple line rounding the mob's number health.
#define      STATUS_HUD 2 // Alive, dead, diseased, etc.
#define          ID_HUD 3 // The job asigned to your ID.
#define      WANTED_HUD 4 // Wanted, released, paroled, security status.
#define     IMPCHEM_HUD 5 // Chemical implant.
#define    IMPTRACK_HUD 6 // Tracking implant.
#define SPECIALROLE_HUD 7 // AntagHUD image.
#define  STATUS_HUD_OOC 8 // STATUS_HUD without virus DB check for someone being ill.
#define        LIFE_HUD 9 // STATUS_HUD that only reports dead or alive
#define   EXCELSIOR_HUD 10 // Used by excelsior to see who else is excel

// These define the time taken for the shuttle to get to the space station, and the time before it leaves again.

#define PODS_PREPTIME 	600	//10 mins = 600 sec - hol long pods will wait before launch
#define PODS_TRANSIT 	120 //2 mins - how long pods takes to get to the centcomm
#define PODS_LOCKDOWN	90	//1.5 mins - how long pods stay opened, if evacuation will be cancelled

// Shuttle moving status.
#define SHUTTLE_IDLE      0
#define SHUTTLE_WARMUP    1
#define SHUTTLE_INTRANSIT 2

// Ferry shuttle processing status.
#define IDLE_STATE   0
#define WAIT_LAUNCH  1
#define FORCE_LAUNCH 2
#define WAIT_ARRIVE  3
#define WAIT_FINISH  4

// Setting this much higher than 1024 could allow spammers to DOS the server easily.
#define MAX_MESSAGE_LEN       1024
#define MAX_PAPER_MESSAGE_LEN 3072
#define MAX_BOOK_MESSAGE_LEN  9216
#define MAX_LNAME_LEN         64
#define MAX_NAME_LEN          26
#define MAX_DESC_LEN          128
#define MAX_TEXTFILE_LENGTH 128000		// 512GQ file


// Cargo-related stuff.
#define MANIFEST_ERROR_CHANCE		5
#define MANIFEST_ERROR_NAME			1
#define MANIFEST_ERROR_CONTENTS		2
#define MANIFEST_ERROR_ITEM			4

//General-purpose life speed define for plants.
#define HYDRO_SPEED_MULTIPLIER 1

#define DEFAULT_JOB_TYPE /datum/job/assistant


//Area flags, possibly more to come
#define AREA_FLAG_RAD_SHIELDED 1 // shielded from radiation, clearly
#define AREA_FLAG_EXTERNAL     2 // External as in exposed to space, not outside in a nice, green, forest
#define AREA_FLAG_ION_SHIELDED 4 // shielded from ionospheric anomalies as an FBP / IPC
#define AREA_FLAG_CRITICAL		8 //Area should not be targeted by very destructive events

// Convoluted setup so defines can be supplied by Bay12 main server compile script.
// Should still work fine for people jamming the icons into their repo.
#ifndef CUSTOM_ITEM_OBJ
#define CUSTOM_ITEM_OBJ 'icons/obj/custom_items_obj.dmi'
#endif
#ifndef CUSTOM_ITEM_MOB
#define CUSTOM_ITEM_MOB 'icons/mob/custom_items_mob.dmi'
#endif
#ifndef CUSTOM_ITEM_SYNTH
#define CUSTOM_ITEM_SYNTH 'icons/mob/custom_synthetic.dmi'
#endif

#define WALL_CAN_OPEN 1
#define WALL_OPENING 2

#define COIN_STANDARD "Coin"
#define COIN_GOLD "Gold coin"
#define COIN_SILVER "Silver coin"
#define COIN_DIAMOND "Diamond coin"
#define COIN_IRON "Iron coin"
#define COIN_PLASMA "Solid plasma coin"
#define COIN_URANIUM "Uranium coin"
#define COIN_PLATINUM "Platunum coin"

#define SHARD_SHARD "shard"
#define SHARD_SHRAPNEL "shrapnel"
#define SHARD_STONE_PIECE "piece"
#define SHARD_SPLINTER "splinters"
#define SHARD_NONE ""

#define MATERIAL_UNMELTABLE 0x1
#define MATERIAL_BRITTLE    0x2
#define MATERIAL_PADDING    0x4

#define TABLE_BRITTLE_MATERIAL_MULTIPLIER 4 // Amount table damage is multiplied by if it is made of a brittle material (e.g. glass)

#define BOMBCAP_DVSTN_RADIUS (max_explosion_range/4)
#define BOMBCAP_HEAVY_RADIUS (max_explosion_range/2)
#define BOMBCAP_LIGHT_RADIUS max_explosion_range
#define BOMBCAP_FLASH_RADIUS (max_explosion_range*1.5)
									// NTNet module-configuration values. Do not change these. If you need to add another use larger number (5..6..7 etc)
#define NTNET_SOFTWAREDOWNLOAD 1 	// Downloads of software from NTNet
#define NTNET_PEERTOPEER 2			// P2P transfers of files between devices
#define NTNET_COMMUNICATION 3		// Communication (messaging)
#define NTNET_SYSTEMCONTROL 4		// Control of various systems, RCon, air alarm control, etc.

// NTNet transfer speeds, used when downloading/uploading a file/program.
#define NTNETSPEED_LOWSIGNAL 0.05	// GQ/s transfer speed when the device is wirelessly connected and on Low signal
#define NTNETSPEED_HIGHSIGNAL 0.15	// GQ/s transfer speed when the device is wirelessly connected and on High signal
#define NTNETSPEED_ETHERNET 0.40		// GQ/s transfer speed when the device is using wired connection
#define NTNETSPEED_DOS_AMPLIFICATION 2	// Multiplier for Denial of Service program. Resulting load on NTNet relay is this multiplied by NTNETSPEED of the device

// Program bitflags
#define PROGRAM_ALL 		0x1F
#define PROGRAM_CONSOLE 	0x1
#define PROGRAM_LAPTOP 		0x2
#define PROGRAM_TABLET 		0x4
#define PROGRAM_TELESCREEN 	0x8
#define PROGRAM_PDA 		0x10

#define PROGRAM_STATE_KILLED 0
#define PROGRAM_STATE_BACKGROUND 1
#define PROGRAM_STATE_ACTIVE 2

// Caps for NTNet logging. Less than 10 would make logging useless anyway, more than 500 may make the log browser too laggy. Defaults to 100 unless user changes it.
#define MAX_NTNET_LOGS 500
#define MIN_NTNET_LOGS 10


// Special return values from bullet_act(). Positive return values are already used to indicate the blocked level of the projectile.
#define PROJECTILE_CONTINUE   -1 //if the projectile should continue flying after calling bullet_act()
#define PROJECTILE_FORCE_MISS -2 //if the projectile should treat the attack as a miss (suppresses attack and admin logs) - only applies to mobs.

//Camera capture modes
#define CAPTURE_MODE_REGULAR 0 //Regular polaroid camera mode
#define CAPTURE_MODE_ALL 1 //Admin camera mode
#define CAPTURE_MODE_PARTIAL 3 //Simular to regular mode, but does not do dummy check
#define CAPTURE_MODE_HISTORICAL 4 //Only turfs and anchored atoms. Attempts to simulate a historical photo

//HUD element hidings flags
#define F12_FLAG 1 // 0001
#define TOGGLE_INVENTORY_FLAG 2 //0010

// Default name for announcement system
#define ANNOUNCER_NAME "CEV Eris System Announcer"


#define LIST_OF_CONSONANT list("a", "b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z", "á", "â", "ã", "ä", "æ", "ç", "é", "ê", "ë", "ì", "í", "ï", "ð", "ñ", "ò", "ô", "õ", "ö", "÷", "ø", "ù")
#define EN_ALPHABET list("a", "b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z")
//Multi-z
#define FALL_GIB_DAMAGE 999

//distance
#define RANGE_ADJACENT -1

//Core implants
#define CORE_ACTIVATED /datum/core_module/activatable

//Cruciform
#define CRUCIFORM_COMMON /datum/core_module/rituals/cruciform/base
#define CRUCIFORM_AGROLYTE /datum/core_module/rituals/cruciform/agrolyte
#define CRUCIFORM_CUSTODIAN /datum/core_module/rituals/cruciform/custodian
#define CRUCIFORM_PRIEST /datum/core_module/rituals/cruciform/priest
#define CRUCIFORM_ACOLYTE /datum/core_module/rituals/cruciform/priest/acolyte
#define CRUCIFORM_INQUISITOR /datum/core_module/rituals/cruciform/inquisitor
#define CRUCIFORM_CRUSADER /datum/core_module/rituals/cruciform/crusader
#define CRUCIFORM_UPLINK /datum/core_module/cruciform/uplink
#define CRUCIFORM_REDLIGHT /datum/core_module/cruciform/red_light
#define CRUCIFORM_CLONING /datum/core_module/cruciform/cloning

#define CRUCIFORM_OBEY /datum/core_module/cruciform/obey
#define CRUCIFORM_PRIEST_CONVERT /datum/core_module/activatable/cruciform/priest_convert
#define CRUCIFORM_OBEY_ACTIVATOR /datum/core_module/activatable/cruciform/obey_activator

#define CUPGRADE_NATURES_BLESSING /obj/item/weapon/cruciform_upgrade/natures_blessing
#define CUPGRADE_FAITHS_SHIELD /obj/item/weapon/cruciform_upgrade/faiths_shield
#define CUPGRADE_CLEANSING_PSESENCE /obj/item/weapon/cruciform_upgrade/cleansing_presence
#define CUPGRADE_MARTYR_GIFT /obj/item/weapon/cruciform_upgrade/martyr_gift
#define CUPGRADE_WRATH_OF_GOD /obj/item/weapon/cruciform_upgrade/wrath_of_god
#define CUPGRADE_SPEED_OF_THE_CHOSEN /obj/item/weapon/cruciform_upgrade/speed_of_the_chosen

//https://secure.byond.com/docs/ref/info.html#/atom/var/mouse_opacity
#define MOUSE_OPACITY_TRANSPARENT 0
#define MOUSE_OPACITY_ICON 1
#define MOUSE_OPACITY_OPAQUE 2

//Filters
#define AMBIENT_OCCLUSION filter(type="drop_shadow", x=0, y=-2, size=4, color="#04080FAA")

//Built-in email accounts
#define EMAIL_DOCUMENTS "document.server@internal-services.net"
#define EMAIL_SYSADMIN  "admin@internal-services.net"
#define EMAIL_BROADCAST "broadcast@internal-services.net"
#define EMAIL_PAYROLL "payroll@internal-services.net"

#define LEGACY_RECORD_STRUCTURE(X, Y) GLOBAL_LIST_EMPTY(##X);/datum/computer_file/data/##Y/var/list/fields[0];/datum/computer_file/data/##Y/New(){..();GLOB.##X.Add(src);}/datum/computer_file/data/##Y/Destroy(){. = ..();GLOB.##X.Remove(src);}

//Number of slots a modular computer has which can be tweaked via gear tweaks.
#define TWEAKABLE_COMPUTER_PART_SLOTS 8

 //Preference save/load cooldown. This is in deciseconds.
#define PREF_SAVELOAD_COOLDOWN 4 //Should be sufficiently hard to achieve without a broken mouse or autoclicker while still fulfilling its intended goal.

#define JOINTEXT(X) jointext(X, null)

//lazy text span classes defines.
#define SPAN_NOTICE(text)  "<span class='notice'>[text]</span>"
#define SPAN_WARNING(text) "<span class='warning'>[text]</span>"
#define SPAN_DANGER(text)  "<span class='danger'>[text]</span>"
#define span(class, text) ("<span class='[class]'>[text]</span>")

#define text_starts_with(text, start) (copytext(text, 1, length(start) + 1) == start)

#define attack_animation(A) if(istype(A)) A.do_attack_animation(src)

#define sequential_id(key) uniqueness_repository.Generate(/datum/uniqueness_generator/id_sequential, key)

#define random_id(key,min_id,max_id) uniqueness_repository.Generate(/datum/uniqueness_generator/id_random, key, min_id, max_id)

#define sound_to(target, sound)                             target << sound
//#define to_chat(target, message)                          target << message
#define to_world(message)                                   to_chat(world, message)
#define to_world_log(message)                               log_world(message)
#define show_browser(target, browser_content, browser_name) target << browse(browser_content, browser_name)
#define to_file(file_entry, source_var)                     file_entry << source_var
#define from_file(file_entry, target_var)                   file_entry >> target_var
#define send_rsc(target, rsc_content, rsc_name)             target << browse_rsc(rsc_content, rsc_name)
#define open_link(target, url)             					target << link(url)

#define send_output(target, msg, control) target << output(msg, control)
#define send_link(target, url) target << link(url)

#define any2ref(x) "\ref[x]"

#define MAP_IMAGE_PATH "nano/images/[GLOB.maps_data.path]/"

#define map_image_file_name(z_level) "[GLOB.maps_data.path]-[z_level].png"

// Spawns multiple objects of the same type
#define cast_new(type, num, args...) if((num) == 1) { new type(args) } else { for(var/i in 1 to num) { new type(args) } }

#define CLIENT_FROM_VAR(I) (ismob(I) ? I:client : (istype(I, /client) ? I : (istype(I, /datum/mind) ? I:current?:client : null)))


// Maploader bounds indices
#define MAP_MINX 1
#define MAP_MINY 2
#define MAP_MINZ 3
#define MAP_MAXX 4
#define MAP_MAXY 5
#define MAP_MAXZ 6

// a place where atoms can be created instead of nullspace
// dont store anything there, only create temporary
#define PURGATORY (GLOB.purgatory_loc ? GLOB.purgatory_loc : error("Purgatory was not created."))
// You can store items in nullspace but dont crete items there
#define NULLSPACE (null)

#define CATALOG_REAGENTS "reagents"
#define CATALOG_CHEMISTRY "chemistry"
#define CATALOG_DRINKS "drinks"
#define CATALOG_ALL "all"

#define get_area(A) (get_step(A, 0)?.loc)


//Misc text define. Does 4 spaces. Used as a makeshift tabulator.
#define FOURSPACES "&nbsp;&nbsp;&nbsp;&nbsp;"



//Planet habitability class
#define HABITABILITY_IDEAL  1
#define HABITABILITY_OKAY  2
#define HABITABILITY_BAD  3


//Map template flags
#define TEMPLATE_FLAG_ALLOW_DUPLICATES 1 // Lets multiple copies of the template to be spawned
#define TEMPLATE_FLAG_SPAWN_GUARANTEED 2 // Makes it ignore away site budget and just spawn (only for away sites)
#define TEMPLATE_FLAG_CLEAR_CONTENTS   4 // if it should destroy objects it spawns on top of
#define TEMPLATE_FLAG_NO_RUINS         8 // if it should forbid ruins from spawning on top of it
#define TEMPLATE_FLAG_NO_RADS          16// Removes all radiation from the template after spawning.


//Flags for exoplanet ruin picking

#define RUIN_HABITAT 	1		//long term habitat
#define RUIN_HUMAN 		2		//human-made structure
#define RUIN_ALIEN 		4		//artificial structure of an unknown origin
#define RUIN_WRECK 		8		//crashed vessel
#define RUIN_NATURAL	16		//naturally occuring structure
#define RUIN_WATER 		32		//ruin depending on planet having water accessible

#define NEWorINITIAL(variable, newvalue) variable = newvalue ? newvalue : initial(variable)

//Matricies
#define MATRIX_GREYSCALE list(0.33, 0.33, 0.33,\
                              0.33, 0.33, 0.33,\
                              0.33, 0.33, 0.33)

//different types of atom colorations
#define ADMIN_COLOUR_PRIORITY 		1 //only used by rare effects like greentext coloring mobs and when admins varedit color
#define TEMPORARY_COLOUR_PRIORITY 	2 //e.g. purple effect of the revenant on a mob, black effect when mob electrocuted
#define WASHABLE_COLOUR_PRIORITY 	3 //color splashed onto an atom (e.g. paint on turf)
#define FIXED_COLOUR_PRIORITY 		4 //color inherent to the atom (e.g. blob color)
#define COLOUR_PRIORITY_AMOUNT      4 //how many priority levels there are.

//Sounds list
#define WALLHIT_SOUNDS list('sound/effects/wallhit.ogg', 'sound/effects/wallhit2.ogg', 'sound/effects/wallhit3.ogg')


//Force the log directory to be something specific in the data/logs folder
#define OVERRIDE_LOG_DIRECTORY_PARAMETER "log-directory"
//Prevent the master controller from starting automatically
#define NO_INIT_PARAMETER "no-init"
//Force the config directory to be something other than "config"
#define OVERRIDE_CONFIG_DIRECTORY_PARAMETER "config-directory"

//Dummy mob reserve slots
#define DUMMY_HUMAN_SLOT_PREFERENCES "dummy_preference_preview"
#define DUMMY_HUMAN_SLOT_ADMIN "admintools"
#define DUMMY_HUMAN_SLOT_MANIFEST "dummy_manifest_generation"

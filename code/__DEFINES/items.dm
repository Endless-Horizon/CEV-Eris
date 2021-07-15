#define REQ_FUEL 1
#define REQ_CELL 2
#define REQ_FUEL_OR_CELL 4

//Aspect defines
#define UPGRADE_PRECISION "precision"
#define UPGRADE_WORKSPEED "workspeed"
#define UPGRADE_DEGRADATION_MULT "degradation_mult"
#define UPGRADE_FORCE_MULT "force_mult"
#define UPGRADE_FORCE_MOD "force_mod"
#define UPGRADE_FUELCOST_MULT "fuelcost_mult"
#define UPGRADE_POWERCOST_MULT "powercost_mult"

#define UPGRADE_BULK "bulk_mod"

#define UPGRADE_HEALTH_THRESHOLD "health_threshold_modifier"

#define UPGRADE_MAXFUEL "max_fuel"

#define UPGRADE_MAXUPGRADES "max_upgrades"

#define UPGRADE_SANCTIFY "sanctify"

#define UPGRADE_COLOR "color"

//boolean
#define UPGRADE_SHARP "sharp"

#define UPGRADE_CELLPLUS "cell_hold_upgrade"

//flags
#define UPGRADE_ITEMFLAGPLUS "item_flag_add"



//Weapon upgrade defines

//Int multiplier
#define GUN_UPGRADE_DAMAGE_MULT "damage_mult"
#define GUN_UPGRADE_PEN_MULT "penetration_mult"
#define GUN_UPGRADE_PIERC_MULT "pierce_mult"
#define GUN_UPGRADE_FIRE_DELAY_MULT "fire_delay_mult"
#define GUN_UPGRADE_MOVE_DELAY_MULT "move_delay_mult"
#define GUN_UPGRADE_RECOIL "recoil_mult"
#define GUN_UPGRADE_MUZZLEFLASH "muzzleflash_mult"
#define GUN_UPGRADE_STEPDELAY_MULT "stepdelay_mult"
#define GUN_UPGRADE_CHARGECOST "chargecost_mult"
#define GUN_UPGRADE_OVERCHARGE_MAX "overcharge_max_mult"
#define GUN_UPGRADE_OVERCHARGE_RATE "overcharge_rate_mult"
#define GUN_UPGRADE_ONEHANDPENALTY "onehandpenalty_mult"
#define GUN_UPGRADE_AGONY_MULT "agony_mult"

//Int additive
#define GUN_UPGRADE_DAMAGEMOD_PLUS "damage_plus"
#define GUN_UPGRADE_MAGUP "magazine_addition"

#define GUN_UPGRADE_DAMAGE_BRUTE "brute_damage"
#define GUN_UPGRADE_DAMAGE_BURN "burn_damage"
#define GUN_UPGRADE_DAMAGE_TOX "toxin_damage"
#define GUN_UPGRADE_DAMAGE_OXY "oxygen_damage"
#define GUN_UPGRADE_DAMAGE_CLONE "clone_damage"
#define GUN_UPGRADE_DAMAGE_HALLOSS "hallucination_damage"
#define GUN_UPGRADE_DAMAGE_RADIATION "radiation_damage"
#define GUN_UPGRADE_DAMAGE_PSY "psy_damage"
#define GUN_UPGRADE_MELEEDAMAGE "melee_damage"
#define GUN_UPGRADE_MELEEPENETRATION "melee_penetration"

#define GUN_UPGRADE_OFFSET "offset" //Constant offset, in degrees
#define GUN_UPGRADE_ZOOM "zoom"



//boolean
#define GUN_UPGRADE_SILENCER "silencable"
#define GUN_UPGRADE_FORCESAFETY "safety force"
#define GUN_UPGRADE_HONK "why"
#define GUN_UPGRADE_FULLAUTO "full auto"
#define GUN_UPGRADE_EXPLODE "self destruct"
#define GUN_UPGRADE_RIGGED "rigged"
#define GUN_UPGRADE_THERMAL "thermal scope"
#define GUN_UPGRADE_BAYONET "bayonet"

//Location Tag defines

#define GUN_UNDERBARREL "underbarrel slot"
#define GUN_BARREL "barrel slot"
#define GUN_TRIGGER "trigger slot"
#define GUN_MUZZLE "muzzle slot"
#define GUN_SCOPE "scope slot"
#define GUN_MECHANISM "misc slot"
#define GUN_GRIP "grip slot"

//Whitelist Tag defines
#define GUN_SILENCABLE "silencable"
#define GUN_PROJECTILE "projectile firing"
#define GUN_ENERGY "energy firing"
#define GUN_LASER "laser firing"
#define GUN_REVOLVER "revolver"
#define GUN_INTERNAL_MAG "internal mag"

#define GUN_CALIBRE_35 "caliber .35"

#define GUN_SOL "Is a FS CAR .25 CS \"Sol\""
#define GUN_AMR "Is a SA AMR \"Hristov\""

// A rare, random item
#define RANDOM_RARE_ITEM list(\
					/obj/spawner/oddities = 8,\
					/obj/spawner/material/resources/rare = 3,\
					/obj/spawner/tool/advanced = 5,\
					/obj/spawner/gun/normal = 3,\
					/obj/spawner/lathe_disk/advanced = 2,\
					/obj/item/cell/small/moebius/nuclear = 1,\
					/obj/item/cell/medium/moebius/hyper = 1,\
					/obj/spawner/rig = 1.5,\
					/obj/spawner/rig/damaged = 1.5,\
					/obj/spawner/voidsuit = 4,\
					/obj/spawner/pouch = 2,\
					/obj/spawner/tool_upgrade/rare = 4,\
					/obj/spawner/rig_module/rare = 4,\
					/obj/spawner/credits/c1000 = 3,\
					/obj/spawner/exosuit_equipment = 3,\
					/obj/spawner/cloth/holster = 4,\
					/obj/item/stash_spawner = 4,\
					/obj/item/storage/deferred/crate/german_uniform = 4)

GLOBAL_LIST_INIT(tool_aspects_blacklist, list(UPGRADE_COLOR, UPGRADE_ITEMFLAGPLUS, UPGRADE_CELLPLUS, UPGRADE_SHARP, UPGRADE_BULK))
GLOBAL_LIST_INIT(weapon_aspects_blacklist, list(GUN_UPGRADE_SILENCER, GUN_UPGRADE_FORCESAFETY, GUN_UPGRADE_HONK, GUN_UPGRADE_FULLAUTO,
											GUN_UPGRADE_EXPLODE, GUN_UPGRADE_RIGGED, UPGRADE_SANCTIFY))

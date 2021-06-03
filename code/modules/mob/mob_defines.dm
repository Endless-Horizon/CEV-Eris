/mob
	datum_flags = DF_USE_TAG
	density = TRUE
	layer = MOB_LAYER
	animate_movement = SLIDE_STEPS
	flags = PROXMOVE

	var/datum/mind/mind
	var/static/next_mob_id = 0

	movement_handlers = list(
	/datum/movement_handler/mob/relayed_movement,
	/datum/movement_handler/mob/death,
	/datum/movement_handler/mob/conscious,
	/datum/movement_handler/mob/eye,
	/datum/movement_handler/mob/delay,
	/datum/movement_handler/move_relay,
	/datum/movement_handler/mob/buckle_relay,
	/datum/movement_handler/mob/stop_effect,
	/datum/movement_handler/mob/physically_capable,
	/datum/movement_handler/mob/physically_restrained,
	/datum/movement_handler/mob/space,
	/datum/movement_handler/mob/movement
	)

	var/lastKnownIP
	var/computer_id

	var/stat = 0 //Whether a mob is alive or dead. TODO: Move this to living - Nodrak

	/*A bunch of this stuff really needs to go under their own defines instead of being globally attached to mob.
	A variable should only be globally attached to turfs/objects/whatever, when it is in fact needed as such.
	The current method unnecessarily clusters up the variable list, especially for humans (although rearranging won't really clean it up a lot but the difference will be noticable for other mobs).
	I'll make some notes on where certain variable defines should probably go.
	Changing this around would probably require a good look-over the pre-existing code.
	*/


	var/use_me = 1 //Allows all mobs to use the me verb by default, will have to manually specify they cannot
	var/damageoverlaytemp = 0
	var/obj/machinery/machine
	var/poll_answer = 0
	var/sdisabilities = 0	//Carbon
	var/disabilities = 0	//Carbon


	var/last_move_attempt = 0 //Last time the mob attempted to move, successful or not
	var/atom/movable/pulling
	var/other_mobs
	var/next_move
	var/transforming	//Carbon
	var/hand
	var/real_name

	var/bhunger = 0			//Carbon
	var/ajourn = 0
	var/seer = 0 //for cult//Carbon, probably Human

	var/druggy = 0			//Carbon
	var/confused = 0		//Carbon
	var/sleeping = 0		//Carbon
	var/resting = 0			//Carbon
	var/lying = 0
	var/lying_prev = 0
	var/canmove = 1


	/*
Allows mobs to move through dense areas without restriction. For instance, in space or out of holder objects.
This var is no longer actually used for incorporeal moving, this is handled by /datum/movement_handler/mob/incorporeal
However this var is still kept as a quick way to check if the mob is incorporeal. This is used in several performance intensive applications
While it would be entirely possible to check the mob's move handlers list for the existence of the incorp handler, that is less optimal for intensive use
*/
	var/incorporeal_move = 0 //0 is off, 1 is normal, 2 is for ninjas.


	var/unacidable = 0
	var/list/pinned = list()            // List of things pinning this creature to walls (see living_defense.dm)
	var/list/embedded = list()          // Embedded items, since simple mobs don't have organs.
	var/list/languages = list()         // For speaking/listening.
	var/list/speak_emote = list("says") // Verbs used when speaking. Defaults to 'say' if speak_emote is null.
	var/emote_type = 1		// Define emote default type, 1 for seen emotes, 2 for heard emotes
	var/facing_dir   // Used for the ancient art of moonwalking.

	var/name_archive //For admin things like possession

	var/timeofdeath = 0

	var/bodytemperature = 310.055	//98.7 F

	var/default_pixel_x = 0
	var/default_pixel_y = 0
	var/old_x = 0
	var/old_y = 0
	var/nutrition = 400  //carbon
	var/max_nutrition = 400
	var/list/eat_sounds = list('sound/items/eatfood.ogg')

	var/shakecamera = 0
	var/a_intent = I_HELP//Living

	var/decl/move_intent/move_intent = /decl/move_intent/run
	var/move_intents = list(/decl/move_intent/run, /decl/move_intent/walk)

	var/obj/buckled //Living
	var/obj/item/l_hand //Living
	var/obj/item/r_hand //Living
	var/obj/item/weapon/back //Human/Monkey
	var/obj/item/weapon/storage/s_active //Carbon
	var/obj/item/clothing/mask/wear_mask //Carbon


	var/datum/hud/hud_used

	var/list/grabbed_by = list(  )
	var/list/requests = list(  )

	var/in_throw_mode = 0



	var/targeted_organ = BP_CHEST

//	var/job = null//Living

	var/can_pull_size = ITEM_SIZE_TITANIC // Maximum w_class the mob can pull.
	var/can_pull_mobs = MOB_PULL_LARGER       // Whether or not the mob can pull other mobs.

	var/datum/dna/dna //Carbon
	var/list/active_genes=list()
	var/list/mutations = list() //Carbon -- Doohl
	//see: setup.dm for list of mutations

	var/radiation = 0//Carbon

	var/voice_name = "unidentifiable voice"

	var/faction = "neutral" //Used for checking whether hostile simple animals will attack you, possibly more stuff later
	var/captured = 0 //Functionally, should give the same effect as being buckled into a chair when true.

	var/blinded
	var/ear_deaf		//Carbon

//The last mob/living/carbon to push/drag/grab this mob (mostly used by slimes friend recognition)
	var/mob/living/carbon/LAssailant

//Wizard mode, but can be used in other modes thanks to the brand new "Give Spell" badmin button
	var/spell/list/spell_list = list()

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	var/update_icon = 1 //Set to 1 to trigger update_icons() at the next life() call

	var/status_flags = CANSTUN|CANWEAKEN|CANPARALYSE|CANPUSH	//bitflags defining which status effects can be inflicted (replaces canweaken, canstun, etc)

	var/area/lastarea

	var/digitalcamo = 0 // Can they be tracked by the AI?

	var/obj/control_object //Used by admins to possess objects. All mobs should have this var

	//Whether or not mobs can understand other mobtypes. These stay in /mob so that ghosts can hear everything.
	var/universal_speak = 0 // Set to 1 to enable the mob to speak to everyone -- TLE
	var/universal_understand = 0 // Set to 1 to enable the mob to understand everyone, not necessarily speak

	//If set, indicates that the client "belonging" to this (clientless) mob is currently controlling some other mob
	//so don't treat them as being SSD even though their client var is null.
	var/mob/teleop

	var/turf/listed_turf  	//the current turf being examined in the stat panel
	var/list/shouldnt_see = list()	//list of objects that this mob shouldn't see in the stat panel. this silliness is needed because of AI alt+click and cult blood runes

	var/mob_size = MOB_MEDIUM

	var/paralysis = 0
	var/stunned = 0
	var/weakened = 0
	var/drowsyness = 0//Carbon

	var/memory = ""
	var/flavor_text = ""


	var/list/HUDneed = list() // What HUD object need see
	var/list/HUDinventory = list()
	var/list/HUDfrippery = list()//flavor
	var/list/HUDprocess = list() //What HUD object need process
	var/list/HUDtech = list()
	var/hud_override = FALSE //Override so a mob no longer calls their own HUD
	var/defaultHUD = "" //Default mob hud

	var/list/progressbars


	var/speed_factor = 1

	var/datum/stat_holder/stats

	var/mob_classification = 0 //Bitfield. Uses TYPE_XXXX defines in defines/mobs.dm.

	var/can_be_fed = 1 //Can be feeded by reagent_container or other things

	///The z level this mob is currently registered in
	var/registered_z

	bad_type = /mob

	var/list/additional_vision_handlers = list() //Basically a list of atoms from which additional vision data is retrieved

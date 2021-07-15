/mob/living/silicon/robot/drone/blitzshell
	icon_state = "blitzshell"
	law_type = /datum/ai_laws/blitzshell
	module_type = /obj/item/robot_module/blitzshell
	hat_x_offset = 1
	hat_y_offset = -12
	can_pull_size = ITEM_SIZE_HUGE
	can_pull_mobs = MOB_PULL_SAME
	communication_channel = LANGUAGE_BLITZ
	station_drone = FALSE
	eyecolor = null
	ai_access = FALSE

/mob/living/silicon/robot/drone/blitzshell/updatename()
	real_name = "\"Blitzshell\" assault drone ([rand(100,999)])"
	name = real_name

/mob/living/silicon/robot/drone/blitzshell/is_allowed_vent_crawl_item()
	return TRUE

/mob/living/silicon/robot/drone/blitzshell/New()
	..()
	verbs |= /mob/living/proc/ventcrawl
	verbs -= /mob/living/silicon/robot/drone/verb/choose_armguard
	verbs -= /mob/living/silicon/robot/drone/verb/choose_eyecolor

	remove_language(LANGUAGE_ROBOT)
	remove_language(LANGUAGE_DRONE)
	add_language(LANGUAGE_BLITZ, 1)
	UnlinkSelf()

/mob/living/silicon/robot/drone/blitzshell/GetIdCard()
	var/obj/ID = locate(/obj/item/card/id/syndicate) in module.modules
	return ID

/mob/living/silicon/robot/drone/blitzshell/request_player()
	var/datum/ghosttrap/G = get_ghost_trap("blitzshell drone")
	G.request_player(src, "A new Blitzshell drone has become active, and is requesting a pilot.", MINISYNTH, 30 SECONDS)

/mob/living/silicon/robot/drone/blitzshell/get_scooped()
	return

/mob/living/silicon/robot/drone/blitzshell/allowed()
	return FALSE

/obj/item/robot_module/blitzshell
	networks = list()
	health = 60 //Able to take 2 bullets
	speed_factor = 1.2
	hide_on_manifest = TRUE


/obj/item/robot_module/blitzshell/New()
	//modules += new /obj/item/gun/energy/laser/mounted/blitz(src) //Deemed too strong for initial loadout
	modules += new /obj/item/gun/energy/plasma/mounted/blitz(src)
	modules += new /obj/item/tool/knife/tacknife(src) //For claiming heads for assassination missions
	//Objective stuff
	modules += new /obj/item/storage/bsdm/permanent(src) //for sending off item contracts
	modules += new /obj/item/gripper/antag(src) //For picking up item contracts
	modules += new /obj/item/reagent_containers/syringe/blitzshell(src) //Blood extraction
	modules += new /obj/item/device/drone_uplink(src)
	//Misc equipment
	modules += new /obj/item/card/id/syndicate(src) //This is our access. Scan cards to get better access
	modules += new /obj/item/device/nanite_container(src) //For self repair. Get more charges via the contract system
	..()

/obj/item/gripper/antag
	name = "Objective Gripper"
	desc = "A special grasping tool specialized in 'dirty' work. Can rip someone's head off if you need it."
	can_hold = list(
		/obj/item/implanter,
		/obj/item/device/spy_sensor,
		/obj/item/computer_hardware/hard_drive,
		/obj/item/reagent_containers,
		/obj/item/spacecash,
		/obj/item/device/mind_fryer,
		/obj/item/organ/external/head,
		/obj/item/oddity/secdocs,
		/obj/item/stack/telecrystal //To reload the uplink
		)

/obj/item/gripper/antag/afterattack(atom/target, var/mob/living/user, proximity, params)
	..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.stat == DEAD)
			if(H.get_organ(BP_HEAD))
				var/obj/item/organ/external/E = H.get_organ(BP_HEAD)
				user.visible_message(SPAN_DANGER("[user] is beginning to rip the [H]'s head off!"),SPAN_DANGER("You are beginning to rip the [H]'s head off."))
				if(!do_mob(user, H, 16 SECONDS))
					to_chat(user, SPAN_DANGER("You was interrupted!"))
					return
				user.visible_message(SPAN_DANGER("[user] is rip the [H]'s head off!"),SPAN_DANGER("You rip the [H]'s head off."))
				E.droplimb(TRUE, DROPLIMB_EDGE)
				grip_item(E, user)
			else
				to_chat(user, SPAN_DANGER("[H] missing his head!"))
		else
			to_chat(user, SPAN_DANGER("You cannot rip someone head while they alive!"))

/obj/item/gripper/antag/New()
	..()
	for(var/i in GLOB.antag_item_targets)
		can_hold |= GLOB.antag_item_targets[i]

/obj/item/device/nanite_container
	name = "nanorepair system"
	icon_state = "nanorepair_tank"
	desc = "Contains several capsules of nanites programmed to repair mechanical and electronic systems."
	spawn_tags = null
	var/charges = 3
	var/cooldown

/obj/item/device/nanite_container/examine(mob/user)
	..()
	to_chat(user, SPAN_NOTICE("It has [charges] charges left."))

/obj/item/device/nanite_container/attack_self(var/mob/user)
	if(istype(user, /mob/living/silicon))
		if(charges)
			if(cooldown > world.time)
				to_chat(user, SPAN_NOTICE("Error: nanorepair system is on cooldown."))
				return
			to_chat(user, SPAN_NOTICE("You begin activating \the [src]."))
			if(!do_after(user, 3 SECONDS, src))
				to_chat(user, SPAN_NOTICE("You need to stay still to fully activate \the [src]!"))
				return
			var/mob/living/silicon/S = user
			S.adjustBruteLoss(-S.maxHealth)
			S.adjustFireLoss(-S.maxHealth)
			charges--
			to_chat(user, SPAN_NOTICE("Charge consumed. Remaining charges: [charges]"))
			cooldown = world.time + 5 MINUTES
			return
		to_chat(user, SPAN_WARNING("Error: No charges remaining."))
		return
	..()

/obj/item/device/smokescreen
	name = "smoke deployment system"
	icon_state = "smokescreen"
	desc = "Contains several capsules filled with smoking agent. Whem used creates a small smoke cloud."
	spawn_tags = null
	var/charges = 3

/obj/item/device/smokescreen/examine(mob/user)
	..()
	to_chat(user, SPAN_NOTICE("It has [charges] charges left."))

/obj/item/device/smokescreen/attack_self(var/mob/user)
	if(istype(user, /mob/living/silicon))
		if(charges)
			to_chat(user, SPAN_NOTICE("You activate \the [src]."))
			var/datum/effect/effect/system/smoke_spread/S = new
			S.set_up(5, 0, src)
			S.start()
			playsound(loc, 'sound/effects/turret/open.ogg', 50, 0)
			charges--
			to_chat(user, SPAN_NOTICE("Charge consumed. Remaining charges: [charges]"))
			return
		to_chat(user, SPAN_WARNING("Error: No charges remaining."))
		return
	..()

/obj/item/device/drone_uplink
	name = "Drone Bounty Uplink"
	icon_state = "uplink_access"
	spawn_tags = null

/obj/item/device/drone_uplink/New()
	..()
	hidden_uplink = new(src, telecrystals = 25)

/obj/item/device/drone_uplink/attack_self(mob/user)
	if(hidden_uplink)
		if(user.mind && hidden_uplink.uplink_owner != user.mind)
			hidden_uplink.uplink_owner = user.mind
		hidden_uplink.trigger(user)

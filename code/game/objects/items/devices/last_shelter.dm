GLOBAL_DATUM(last_shelter, /obj/item/device/last_shelter)

/obj/item/device/last_shelter
	name = "Last Shelter"
	desc = "Powerful scanner that can teleport a cruciforms of pilgrims lost in this sector of space."
	icon = 'icons/obj/faction_item.dmi'
	icon_state = "last_shelter"
	item_state = "last_shelter"
	price_tag = 20000
	origin_tech = list(TECH_MAGNET = 5, TECH_BLUESPACE = 9, TECH_BIO = 3)
	spawn_frequency = 0
	spawn_blacklisted = TRUE
	var/cooldown = 15 MINUTES
	var/last_teleport = -15 MINUTES
	var/scan = FALSE

/obj/item/device/last_shelter/New()
	..()
	GLOB.last_shelter = src
	GLOB.all_faction_items[src] = GLOB.department_church

/obj/item/device/last_shelter/Destroy()
	for(var/mob/living/carbon/human/H in viewers(get_turf(src)))
		SEND_SIGNAL(H, COMSIG_OBJ_FACTION_ITEM_DESTROY, src)
	GLOB.all_faction_items -= src
	GLOB.neotheology_faction_item_loss++
	..()

/obj/item/device/last_shelter/attackby(obj/item/I, mob/living/user, params)
	if(nt_sword_attack(I, user))
		return FALSE
	..()

/obj/item/device/last_shelter/attack_self(mob/user)
	active_effect(user)

/obj/item/device/last_shelter/proc/active_effect(mob/user, alert = FALSE)
	if(world.time >= (last_teleport + cooldown))
		to_chat(user, SPAN_NOTICE("The [src] scans deep space for a cruciforms, it's will take a while..."))
		last_teleport = world.time
		scan = TRUE
		var/obj/item/implant/core_implant/cruciform/cruciform = get_cruciform()
		if(cruciform)
			scan = FALSE
			if(istype(src.loc, /mob/living/carbon/human))
				user.put_in_hands(cruciform)
				to_chat(user, SPAN_NOTICE("The [src] has found the lost cruciform in a deep space. Now this fate of the disciple rests in your hands."))
			else
				visible_message(SPAN_NOTICE("[src] drops [cruciform]."))
				cruciform.forceMove(get_turf(src))
		else
			to_chat(user, SPAN_WARNING("The [src] can't find any working cruciforms in deep space. You can try to use [src] again later."))
			scan = FALSE

		if(alert)
			var/preacher
			for(var/mob/living/carbon/human/H in disciples)
				if(H.mind && istype(H.mind.assigned_job, /datum/job/chaplain))
					preacher = H

			if(!preacher && length(disciples))
				preacher = pick(disciples)
			to_chat(preacher, SPAN_WARNING("[src] has been activated."))


	else if(scan)
		to_chat(user, SPAN_WARNING("The [src] is still woking! Wait a minute!"))

	else
		to_chat(user, SPAN_WARNING("The [src] needs time to recharge!"))

/obj/item/device/last_shelter/proc/get_cruciform()
	var/datum/mind/MN = request_player()
	if(!MN)
		return FALSE
	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src)
	for(var/stat in ALL_STATS)
		H.stats.changeStat(stat, rand(STAT_LEVEL_ADEPT, STAT_LEVEL_PROF))
	var/datum/perk/perk_random = pick(subtypesof(/datum/perk/oddity))
	H.stats.addPerk(perk_random)
	H.stats.addPerk(pick(/datum/perk/survivor, /datum/perk/selfmedicated, /datum/perk/vagabond, /datum/perk/merchant, /datum/perk/inspiration))
	var/obj/item/implant/core_implant/cruciform/cruciform = new /obj/item/implant/core_implant/cruciform(src)
	cruciform.add_module(new CRUCIFORM_CLONING)
	cruciform.activated = TRUE
	MN.name = H.real_name
	MN.assigned_role = "NT disciple"
	MN.original = H
	for(var/datum/core_module/cruciform/cloning/M in cruciform.modules)
		M.write_wearer(H)
		M.ckey = MN.key
		M.mind = MN
	qdel(H)
	return cruciform

/obj/item/device/last_shelter/proc/request_player()
	var/agree_time_out = FALSE
	var/request_timeout = 60 SECONDS
	var/datum/mind/MN

	for(var/mob/observer/ghost/O in GLOB.player_list)
		if(O.client)
			O << 'sound/effects/magic/blind.ogg' //Play this sound to a player whenever when he's chosen to decide.
			if(alert(O, "Do you want to be cloned as NT disciple? Hurry up, you have 60 seconds to make choice!","Player Request","OH YES","No, I'm autist") == "OH YES")
				if(!agree_time_out)
					if(MN)
						to_chat(O, SPAN_WARNING("Somebody already took this place."))
						return

					O.mind = new /datum/mind(O.ckey)
					MN = O.mind
				else
					to_chat(O, SPAN_WARNING("You are too slow. Try to be faster next time."))
					return

	sleep(request_timeout)
	agree_time_out = TRUE
	return MN

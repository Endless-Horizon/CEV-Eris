//Cloning revival method.
//The pod handles the actual cloning while the computer manages the clone profiles

#define CLONE_BIOMASS 150

/obj/machinery/clonepod
	name = "biomass pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_0"
	req_access = list(access_genetics) //For premature unlocking.
	circuit = /obj/item/electronics/circuitboard/clonepod
	var/mob/living/occupant
	var/heal_level = 20 //The clone is released once its health reaches this level.
	var/heal_rate = 1
	var/notoxin = 0
	var/locked = 0
	var/obj/machinery/computer/cloning/connected = null //So we remember the connected clone machine.
	var/mess = 0 //Need to clean out it if it's full of exploded clone.
	var/attempting = 0 //One clone attempt at a time thanks
	var/eject_wait = 0 //Don't eject them as soon as they are created fuckkk
	var/biomass = CLONE_BIOMASS * 3

/obj/machinery/clonepod/New()
	set_extension(src, /datum/extension/multitool, /datum/extension/multitool/store)
	..()
	if(SSticker.current_state != GAME_STATE_PLAYING)
		biomass = CLONE_BIOMASS * 3

/obj/machinery/clonepod/Destroy()
	if(connected)
		connected.release_pod(src)
	return ..()

/obj/machinery/clonepod/attack_ai(mob/user as mob)

	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/clonepod/attack_hand(mob/user as mob)
	if(isnull(occupant) || (stat & NOPOWER))
		return
	if(occupant.stat != DEAD)
		var/completion = (100 * ((occupant.health + 50) / (heal_level + 100))) // Clones start at -150 health
		to_chat(user, "Current clone cycle is [round(completion)]% complete.")
	return

//Clonepod

//Start growing a human clone in the pod!
/obj/machinery/clonepod/proc/growclone(var/datum/dna2/record/R)
	if(mess || attempting)
		return 0
	var/datum/mind/clonemind = locate(R.mind)

	if(!istype(clonemind, /datum/mind))	//not a mind
		return 0
	if(clonemind.current && clonemind.current.stat != DEAD)	//mind is associated with a non-dead body
		return 0
	if(clonemind.active)	//somebody is using that mind
		if(ckey(clonemind.key) != R.ckey)
			return 0
	else
		for(var/mob/observer/ghost/G in GLOB.player_list)
			if(G.ckey == R.ckey)
				if(G.can_reenter_corpse)
					break
				else
					return 0

	attempting = 1 //One at a time!!
	locked = 1

	eject_wait = 1
	spawn(30)
		eject_wait = 0

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src, R.dna.species)
	occupant = H

	if(!R.dna.real_name)	//to prevent null names
		R.dna.real_name = "clone ([rand(0,999)])"
	H.real_name = R.dna.real_name

	//Get the clone body ready
	H.adjustCloneLoss(150) // New damage var so you can't eject a clone early then stab them to abuse the current damage system --NeoFite
	H.Paralyse(4)

	//Here let's calculate their health so the pod doesn't immediately eject them!!!
	H.updatehealth()

	clonemind.transfer_to(H)
	H.ckey = R.ckey
	to_chat(H, SPAN_NOTICE("<b>Consciousness slowly creeps over you as your body regenerates.</b><br><i>So this is what cloning feels like?</i>"))

	// -- Mode/mind specific stuff goes here
	callHook("clone", list(H))
	update_antag_icons(H.mind)
	// -- End mode specific stuff

	if(!R.dna)
		H.dna = new /datum/dna()
		H.dna.real_name = H.real_name
	else
		H.dna = R.dna
	H.UpdateAppearance()
	H.sync_organ_dna()
	if(heal_level < 60)
		randmutb(H) //Sometimes the clones come out wrong.
		H.dna.UpdateSE()
		H.dna.UpdateUI()

	H.set_cloned_appearance()
	update_icon()

	for(var/datum/language/L in R.languages)
		H.add_language(L.name)
	H.flavor_text = R.flavor
	attempting = 0
	return 1

//Grow clones to maturity then kick them out.  FREELOADERS
/obj/machinery/clonepod/Process()

	if(stat & NOPOWER) //Autoeject if power is lost
		if(occupant)
			locked = 0
			go_out()
		return

	if((occupant) && (occupant.loc == src))
		if((occupant.stat == DEAD) || !occupant.key)
			locked = 0
			go_out()
			connected_message("Clone Rejected: Deceased.")
			return

		else if(occupant.health < heal_level && occupant.getCloneLoss() > 0)
			occupant.Paralyse(4)

			 //Slowly get that clone healed and finished.
			occupant.adjustCloneLoss(-2 * heal_rate)

			//Premature clones may have brain damage.
			occupant.adjustBrainLoss(-(CEILING(0.5*heal_rate, 1)))

			//So clones don't die of oxyloss in a running pod.
			if(occupant.reagents.get_reagent_amount("inaprovaline") < 30)
				occupant.reagents.add_reagent("inaprovaline", 60)
			occupant.Sleeping(30)
			//Also heal some oxyloss ourselves because inaprovaline is so bad at preventing it!!
			occupant.adjustOxyLoss(-4)

			use_power(7500) //This might need tweaking.
			return

		else if((occupant.health >= heal_level) && (!eject_wait))
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			src.audible_message("\The [src] signals that the cloning process is complete.")
			connected_message("Cloning Process Complete.")
			locked = 0
			go_out()
			return

	else if((!occupant) || (occupant.loc != src))
		occupant = null
		if(locked)
			locked = 0
		return

	return

//Let's unlock this early I guess.  Might be too early, needs tweaking.
/obj/machinery/clonepod/attackby(var/obj/item/I, mob/user as mob)
	if(isnull(occupant))

		if(default_deconstruction(I, user))
			return

		if(default_part_replacement(I, user))
			return

	if(I.GetIdCard())
		if(!check_access(I))
			to_chat(user, SPAN_WARNING("Access Denied."))
			return
		if(!locked || isnull(occupant))
			return
		if((occupant.health < -20) && (occupant.stat != DEAD))
			to_chat(user, SPAN_WARNING("Access Refused."))
			return
		else
			locked = 0
			to_chat(user, "System unlocked.")
	else
		for(var/type in BIOMASS_TYPES)
			if(istype(I,type))
				to_chat(user, SPAN_NOTICE("\The [src] processes \the [I]."))
				biomass += BIOMASS_TYPES[type]
				user.drop_from_inventory(I)
				qdel(I)
				return
	..()

/obj/machinery/clonepod/emag_act(var/remaining_charges, var/mob/user)
	if(isnull(occupant))
		return NO_EMAG_ACT
	to_chat(user, "You force an emergency ejection.")
	locked = 0
	go_out()
	return 1

//Put messages in the connected computer's temp var for display.
/obj/machinery/clonepod/proc/connected_message(var/message)
	if(isnull(connected) || !istype(connected, /obj/machinery/computer/cloning))
		return 0
	if(!message)
		return 0

	connected.temp = "[name] : [message]"
	connected.updateUsrDialog()
	return 1

/obj/machinery/clonepod/RefreshParts()
	..()
	var/rating = 0
	for(var/obj/item/stock_parts/P in component_parts)
		if(istype(P, /obj/item/stock_parts/scanning_module) || istype(P, /obj/item/stock_parts/manipulator))
			rating += P.rating

	heal_level = rating * 10 - 20
	heal_rate = round(rating / 4)
	if(rating >= 8)
		notoxin = 1
	else
		notoxin = 0

/obj/machinery/clonepod/verb/eject()
	set name = "Eject Cloner"
	set category = "Object"
	set src in oview(1)

	if(usr.stat)
		return
	go_out()
	add_fingerprint(usr)
	return

/obj/machinery/clonepod/proc/go_out()
	if(locked)
		return

	if(mess) //Clean that mess and dump those gibs!
		mess = 0
		gibs(loc)
		update_icon()
		return

	if(!occupant)
		return

	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	occupant.loc = loc
	eject_wait = 0 //If it's still set somehow.
	domutcheck(occupant) //Waiting until they're out before possible transforming.
	occupant = null

	biomass -= CLONE_BIOMASS
	update_icon()
	return

/obj/machinery/clonepod/proc/malfunction()
	if(occupant)
		connected_message("Critical Error!")
		mess = 1
		update_icon()
		occupant.ghostize()
		spawn(5)
			qdel(occupant)
	return

/obj/machinery/clonepod/relaymove(mob/user as mob)
	if(user.stat)
		return
	go_out()
	return

/obj/machinery/clonepod/emp_act(severity)
	if(prob(100/severity))
		malfunction()
	..()

/obj/machinery/clonepod/ex_act(severity)
	switch(severity)
		if(1)
			for(var/atom/movable/A in src)
				A.loc = loc
				ex_act(severity)
			qdel(src)
			return
		if(2)
			if(prob(50))
				for(var/atom/movable/A in src)
					A.loc = loc
					ex_act(severity)
				qdel(src)
				return
		if(3)
			if(prob(25))
				for(var/atom/movable/A in src)
					A.loc = loc
					ex_act(severity)
				qdel(src)
				return
		else
	return

/obj/machinery/clonepod/on_update_icon()
	..()
	icon_state = "pod_0"
	if (occupant && !(stat & NOPOWER))
		icon_state = "pod_1"
	else if (mess)
		icon_state = "pod_g"


/*
	Powers contained here:
	Penance: Deals large amounts of harmless pain to a target disciple
	//Obey: Second step of a two-part process to enslave a disciple with an Obey module
	Convalescence: Moderately powerful selfheal
	Succour: Heals a target disciple within arms reach
	Scrying: Look through the eyes of a target disciple.  Global range, expensive and limited duration
	Sending: Send a telepathic message to a specific disciple. Global range
	Initiation: Promotes a disciple to a preacher
	Knowledge: Checks remaining telecrystals (Inquisitor also has a traitor uplink)
	Bounty: Calls up the uplink to order supplies
*/
/datum/ritual/cruciform/inquisitor
	name = "inquisitor"
	implant_type = /obj/item/implant/core_implant/cruciform
	category = "Inquisitor"
	power = 30

/datum/ritual/targeted/cruciform/inquisitor
	name = "inquisitor targeted"
	implant_type = /obj/item/implant/core_implant/cruciform
	category = "Inquisitor"
	power = 30




/*
	Penance
	Deals pain damage to a targeted disciple
*/
/datum/ritual/targeted/cruciform/inquisitor/penance
	name = "Penance"
	phrase = "Mihi vindicta \[Target human]"
	desc = "Imparts extreme pain on the target disciple. Does no actual harm."
	power = 35

/datum/ritual/targeted/cruciform/inquisitor/penance/perform(mob/living/carbon/human/user, obj/item/implant/core_implant/C,list/targets)
	if(!targets.len)
		fail("Target not found.",user,C,targets)
		return FALSE

	var/obj/item/implant/core_implant/CI = targets[1]

	if(!CI.active || !CI.wearer)

		fail("Cruciform not found.", user, C)
		return FALSE

	var/mob/living/M = CI.wearer

	log_and_message_admins(" inflicted pain on [CI.wearer] with penance litany")
	to_chat(M, SPAN_DANGER("A wave of agony washes over you, the cruciform in your chest searing like a star for a few moments of eternity."))


	var/datum/effect/effect/system/spark_spread/s = new
	s.set_up(1, 1, M.loc)
	s.start()

	M.adjustHalLoss(50)

	return TRUE

/datum/ritual/targeted/cruciform/inquisitor/penance/process_target(var/index, var/obj/item/implant/core_implant/target, var/text)
	target.update_address()
	if(index == 1 && target.address == text)
		if(target.wearer && (target.loc && (target.locs[1] in view())))
			return target



/*
	Obey
	Goes with obey module, disabled for now
*/
/*
/datum/ritual/cruciform/inquisitor/obey
	name = "Obey"
	phrase = "Sicut dilexit me Pater et ego dilexi, vos manete in dilectione mea"
	desc = "Bound believer to your will."

/datum/ritual/cruciform/inquisitor/obey/perform(mob/living/carbon/human/user, obj/item/implant/core_implant/C,list/targets)
	var/obj/item/implant/core_implant/CI = get_implant_from_victim(user, /obj/item/implant/core_implant/cruciform)

	if(!CI || !CI.wearer || !ishuman(CI.wearer) || !CI.active)

		fail("Cruciform not found",user,C)
		return FALSE

	if(CI.get_module(CRUCIFORM_OBEY))
		fail("The target is already obeying.",user,C)
		return FALSE

	var/datum/core_module/activatable/cruciform/obey_activator/OA = CI.get_module(CRUCIFORM_OBEY_ACTIVATOR)

	if(!OA)
		fail("Target must have obey upgrade inside his cruciform.",user,C)
		return FALSE

	OA.activate()

	return TRUE
*/




/*
	Convalescence
	Heals yourself a fair amount
*/
/datum/ritual/cruciform/inquisitor/selfheal
	name = "Convalescence"
	phrase = "Dominus autem dirigat corda vestra in caritate Dei et patientia Christi"
	desc = "Recover from the ravages of wounds and pain."
	cooldown = TRUE
	cooldown_time = 100
	power = 25 //Healing yourself is slightly easier than healing someone else

/datum/ritual/cruciform/inquisitor/selfheal/perform(mob/living/carbon/human/H, obj/item/implant/core_implant/C,list/targets)
	to_chat(H, "<span class='info'>A sensation of relief bathes you, washing away your pain</span>")
	log_and_message_admins("healed himself with convalescence litany")
	H.add_chemical_effect(CE_PAINKILLER, 20)
	H.adjustBruteLoss(-20)
	H.adjustFireLoss(-20)
	H.adjustOxyLoss(-40)
	H.updatehealth()
	set_personal_cooldown(H)
	return TRUE




/*
	Succour
	Heals another person, quite powerfully. Only works on NT disciples
*/
/datum/ritual/cruciform/inquisitor/heal_other
	name = "Succour"
	phrase = "Venite ad me, omnes qui laboratis, et onerati estis et ego reficiam vos"
	desc = "Heal a nearby disciple"
	cooldown = TRUE
	cooldown_time = 100
	power = 35

/datum/ritual/cruciform/inquisitor/heal_other/perform(mob/living/carbon/human/user, obj/item/implant/core_implant/C,list/targets)
	var/obj/item/implant/core_implant/cruciform/CI = get_implant_from_victim(user, /obj/item/implant/core_implant/cruciform)

	if(!CI || !CI.active || !CI.wearer)
		fail("Cruciform not found.", user, C)
		return FALSE



	var/mob/living/carbon/human/H = CI.wearer

	if(!istype(H))
		fail("Target not found.",user,C,targets)
		return FALSE

	//Checking turfs allows this to be done in unusual circumstances
	var/turf/T = get_turf(user)
	if (!(T.Adjacent(get_turf(H))))
		to_chat(user, SPAN_DANGER("[H] is beyond your reach.."))
		return


	user.visible_message("[user] places their hands upon [H] and utters a prayer", "You lay your hands upon [H] and begin speaking the words of convalescence")
	if (do_after(user, 40, H, TRUE))
		T = get_turf(user)
		if (!(T.Adjacent(get_turf(H))))
			to_chat(user, SPAN_DANGER("[H] is beyond your reach.."))
			return
		log_and_message_admins(" healed [CI.wearer] with Succour litany")
		to_chat(H, "<span class='info'>A sensation of relief bathes you, washing away your pain</span>")
		H.add_chemical_effect(CE_PAINKILLER, 20)
		H.adjustBruteLoss(-20)
		H.adjustFireLoss(-20)
		H.adjustOxyLoss(-40)
		H.updatehealth()
		set_personal_cooldown(user)
		return TRUE


/*
	Scrying: Remotely look through someone's eyes. Global range, useful to find fugitives or corpses
	Uses all of your power and has a limited duration
*/
/datum/ritual/cruciform/inquisitor/scrying
	name = "Scrying"
	phrase = "Ecce ego ad te et ad caelum. Scio omnes absconditis tuis. Vos can abscondere, tu es coram me: nudus."
	desc = "Look on the world from the eyes of another believer. Strenuous and can only be maintained for half a minute. The target will sense they are being watched, but not by whom."
	power = 100

/datum/ritual/cruciform/inquisitor/scrying/perform(mob/living/carbon/human/user, obj/item/implant/core_implant/C,list/targets)

	if(!user.client)
		return FALSE

	var/mob/living/M = pick_disciple_global(user, TRUE)
	if (!M)
		return

	if(user == M)
		fail("You feel stupid.",user,C,targets)
		return FALSE
	log_and_message_admins("looks through the eyes of [C] with scrying litany")
	to_chat(M, SPAN_NOTICE("You feel an odd presence in the back of your mind. A lingering sense that someone is watching you..."))

	var/mob/observer/eye/god/eye = new/mob/observer/eye/god(M)
	eye.target = M
	eye.owner_mob = user
	eye.owner_loc = user.loc
	eye.owner = eye
	user.reset_view(eye)

	//After 30 seconds, your view is forced back to yourself
	addtimer(CALLBACK(user, .mob/proc/reset_view, user), 300)

	return TRUE


/datum/ritual/targeted/cruciform/inquisitor/god_eye/process_target(var/index, var/obj/item/implant/core_implant/target, var/text)
	if(index == 1 && target.address == text && target.active)
		if(target.wearer && target.wearer.stat != DEAD)
			return target



/*
	Sends a telepathic message to any disciple
*/
/datum/ritual/cruciform/inquisitor/message
	name = "Sending"
	phrase = "Audit, me audit vocationem. Ego nuntius vobis."
	desc = "Send a message anonymously through the void, straight into the mind of another disciple"
	power = 30

/datum/ritual/cruciform/inquisitor/message/perform(mob/living/carbon/human/user, obj/item/implant/core_implant/C,list/targets)
	var/mob/living/carbon/human/H = pick_disciple_global(user, TRUE)
	if (!H)
		return

	if(user == H)
		fail("You feel stupid.",user,C,targets)
		return FALSE

	var/text = input(user, "What message will you send to the target? The message will be recieved telepathically and they will not know who it is from unless you reveal yourself.", "Sending a message") as text|null
	if (!text)
		return
	log_and_message_admins("sent a message to [H] with text \"[text]\"")
	to_chat(H, "<span class='notice'>A voice speaks in your mind: \"[text]\"</span>")






/datum/ritual/cruciform/inquisitor/initiation
	name = "Initiation"
	phrase = "Habe fiduciam in Domino ex toto corde tuo et ne innitaris prudentiae tuae, in omnibus viis tuis cogita illum et ipse diriget gressus tuos"
	desc = "The second stage of granting a field promotion to a disciple, upgrading them to Preacher. The Preacher ascension kit is the first step."
	power = 100

/datum/ritual/cruciform/inquisitor/initiation/perform(mob/living/carbon/human/user, obj/item/implant/core_implant/C,list/targets)
	var/obj/item/implant/core_implant/CI = get_implant_from_victim(user, /obj/item/implant/core_implant/cruciform)

	if(!CI || !CI.wearer || !ishuman(CI.wearer) || !CI.active)
		fail("Cruciform not found",user,C)
		return FALSE


	if(CI.get_module(CRUCIFORM_PRIEST) || CI.get_module(CRUCIFORM_INQUISITOR))
		fail("The target is already a preacher.",user,C)
		return FALSE

	var/datum/core_module/activatable/cruciform/priest_convert/PC = CI.get_module(CRUCIFORM_PRIEST_CONVERT)

	if(!PC)
		fail("Target must have preacher upgrade inside his cruciform.",user,C)
		return FALSE

	PC.activate()
	log_and_message_admins("promoted disciple [C] to Preacher with initiation litany")

	return TRUE



/datum/ritual/cruciform/inquisitor/check_telecrystals
	name = "Knowledge"
	phrase = "Cor sapientis quaerit doctrinam, et os stultorum pascetur inperitia"
	desc = "Find out the limits of your power, how many telecrystals you have now."
	power = 5

/datum/ritual/cruciform/inquisitor/check_telecrystals/perform(mob/living/carbon/human/user, obj/item/implant/core_implant/C,list/targets)
	var/datum/core_module/cruciform/uplink/I = C.get_module(CRUCIFORM_UPLINK)

	if(I && I.uplink)
		I.telecrystals = I.uplink.uses
		to_chat(user, "<span class='info'>You have [I.telecrystals] telecrystals.</span>")
		return FALSE
	else
		to_chat(user, "<span class='info'>You have no uplink.</span>")
		return FALSE





/*
	Opens the interface for the embedded Uplink, allowing stuff to be purchased
*/
/datum/ritual/targeted/cruciform/inquisitor/spawn_item
	name = "Bounty"
	phrase = "Supra Domini, bona de te peto. Audi me, et libera vocationem ad me munera tua"
	desc = "Request supplies and items from headquarters. Find a private place to do this. Establishing the connection takes a lot of power."
	power = 20

/datum/ritual/targeted/cruciform/inquisitor/spawn_item/perform(mob/living/carbon/human/user, obj/item/implant/core_implant/C,list/targets)
	var/datum/core_module/cruciform/uplink/I = C.get_module(CRUCIFORM_UPLINK)

	if(I && I.uplink)
		I.uplink.trigger(user)

		return TRUE
	return FALSE


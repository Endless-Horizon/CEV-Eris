// All mobs should have custom emote, really..
//m_type == 1 --> visual.
//m_type == 2 --> audible
/mob/proc/custom_emote(var/m_type=1,var/message = null)
	if(usr && stat || !use_me && usr == src)
		to_chat(src, "You are unable to emote.")
		return

	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle) || istype(src.wear_mask, /obj/item/grenade)
	if(m_type == 2 && muzzled) return

	var/input
	if(!message)
		input = sanitize(input(src,"Choose an emote to display.") as text|null)
	else
		input = message
	if(input)
		message = "<B>[src]</B> [input]"
	else
		return


	if (message)
		log_emote("[name]/[key] : [message]")

		send_emote(message, m_type)

/mob/proc/emote_dead(var/message)

	if(client.prefs.muted & MUTE_DEADCHAT)
		to_chat(src, SPAN_DANGER("You cannot send deadchat emotes (muted)."))
		return

	if(get_preference_value(/datum/client_preference/show_dsay) == GLOB.PREF_HIDE)
		to_chat(src, SPAN_DANGER("You have deadchat muted."))
		return

	if(!src.client.holder)
		if(!config.dsay_allowed)
			to_chat(src, SPAN_DANGER("Deadchat is globally muted."))
			return


	var/input
	if(!message)
		input = sanitize(input(src, "Choose an emote to display.") as text|null)
	else
		input = message

	if(input)
		log_emote("Ghost/[src.key] : [input]")
		say_dead_direct(input, src)

//This is a central proc that all emotes are run through. This handles sending the messages to living mobs
/mob/proc/send_emote(var/message, var/type)
	var/list/messageturfs = list()//List of turfs we broadcast to.
	var/list/messagemobs = list()//List of living mobs nearby who can hear it, and distant ghosts who've chosen to hear it
	var/list/messagemobs_neardead = list()//List of nearby ghosts who can hear it. Those that qualify ONLY go in this list
	for (var/turf in view(world.view, get_turf(src)))
		messageturfs += turf

	for(var/mob/M in GLOB.player_list)
		if (!M.client || istype(M, /mob/new_player))
			continue
		if(get_turf(M) in messageturfs)
			if (istype(M, /mob/observer))
				messagemobs_neardead += M
				continue
			else if (istype(M, /mob/living) && !(type == 2 && (sdisabilities & DEAF || ear_deaf)))
				messagemobs += M
		else if(src.client)
			if  (M.stat == DEAD && (M.get_preference_value(/datum/client_preference/ghost_ears) == GLOB.PREF_ALL_SPEECH))
				messagemobs += M
				continue

	for (var/mob/N in messagemobs)
		N.show_message(message, type)

	message = "<B>[message]</B>"

	for (var/mob/O in messagemobs_neardead)
		O.show_message(message, type)
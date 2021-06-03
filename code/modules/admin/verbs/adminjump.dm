/mob/proc/on_mob_jump(var/turf/T)
	if (istype(loc, /mob/living/exosuit))
		var/mob/living/exosuit/M = loc
		M.forceMove(T)
	else
		forceMove(T)

/mob/observer/ghost/on_mob_jump()
	stop_following()
	..()

ADMIN_VERB_ADD(/client/proc/Jump, R_ADMIN|R_DEBUG, FALSE)
/client/proc/Jump(area/A in return_sorted_areas())
	set name = "Jump to Area"
	set desc = "Area to jump to"
	set category = "Admin"
	if(!check_rights(R_ADMIN|R_MOD|R_DEBUG))
		to_chat(src, "Only administrators may use this command.", confidential = TRUE)
		return

	if(!A)
		return

	var/list/turfs = list()
	for(var/turf/T in A)
		if(T.density)
			continue
		turfs.Add(T)

	if(length(turfs))
		var/turf/T = pick(turfs)
		// usr.forceMove(T)
		usr.on_mob_jump(T) // snowflake
		log_admin("[key_name(usr)] jumped to [AREACOORD(T)]")
		message_admins("[key_name_admin(usr)] jumped to [AREACOORD(T)]")
		// SSblackbox.record_feedback("tally", "admin_verb", 1, "Jump To Area") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		to_chat(src, "Nowhere to jump to!", confidential = TRUE)
		return

ADMIN_VERB_ADD(/client/proc/jumptoturf, R_ADMIN, FALSE)
//allows us to jump to a specific turf
/client/proc/jumptoturf(var/turf/T in world)
	set name = "Jump to Turf"
	set category = "Admin"
	if(!check_rights(R_ADMIN|R_MOD|R_DEBUG))
		to_chat(src, "Only administrators may use this command.", confidential = TRUE)
		return

	log_admin("[key_name(usr)] jumped to [AREACOORD(T)]")
	message_admins("[key_name_admin(usr)] jumped to [AREACOORD(T)]")
	//When inside a mech, move the mech instead of teleporting out of it
	usr.on_mob_jump(T)
	return

ADMIN_VERB_ADD(/client/proc/jumptomob, R_ADMIN|R_DEBUG, FALSE)
//allows us to jump to a specific mob
/client/proc/jumptomob(mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Jump to Mob"

	if(!check_rights(R_ADMIN|R_MOD|R_DEBUG))
		to_chat(src, "Only administrators may use this command.", confidential = TRUE)
		return

	log_admin("[key_name(usr)] jumped to [key_name(M)]")
	message_admins("[key_name_admin(usr)] jumped to [ADMIN_LOOKUPFLW(M)] at [AREACOORD(M)]")

	if(src.mob)
		var/mob/A = src.mob
		var/turf/T = get_turf(M)
		if(T && isturf(T))
			A.on_mob_jump(T)
		else
			to_chat(A, "This mob is not located in the game world.", confidential = TRUE)

ADMIN_VERB_ADD(/client/proc/jumptocoord, R_ADMIN|R_DEBUG, FALSE)
//we ghost and jump to a coordinate
/client/proc/jumptocoord(tx as num, ty as num, tz as num)
	set category = "Admin"
	set name = "Jump to Coordinate"

	if(!check_rights(R_ADMIN|R_MOD|R_DEBUG))
		to_chat(src, "Only administrators may use this command.", confidential = TRUE)
		return

	if(src.mob)
		var/mob/A = src.mob
		var/turf/T = locate(tx,ty,tz)
		A.on_mob_jump(T)

	message_admins("[key_name_admin(usr)] jumped to coordinates [tx], [ty], [tz]")

ADMIN_VERB_ADD(/client/proc/jumptokey, R_ADMIN, TRUE)
//allows us to jump to the location of a mob with a certain ckey
/client/proc/jumptokey()
	set category = "Admin"
	set name = "Jump to Key"

	if(!check_rights(R_ADMIN|R_MOD|R_DEBUG))
		to_chat(src, "Only administrators may use this command.", confidential = TRUE)
		return

	var/list/keys = list()
	for(var/mob/M in GLOB.player_list)
		keys += M.client
	var/client/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in sortKey(keys)
	if(!selection)
		to_chat(src, "No keys found.", confidential = TRUE)
		return
	var/mob/M = selection.mob
	log_admin("[key_name(usr)] jumped to [key_name(M)]")
	message_admins("[key_name_admin(usr)] jumped to [ADMIN_LOOKUPFLW(M)]")

	usr.on_mob_jump(get_turf(M))

ADMIN_VERB_ADD(/client/proc/Getmob, R_ADMIN, FALSE)
//teleports a mob to our location
/client/proc/Getmob(var/mob/M in GLOB.mob_list - GLOB.dummy_mob_list)
	set category = "Admin"
	set name = "Get Mob"
	set desc = "Mob to teleport"
	if(!check_rights(R_ADMIN|R_MOD|R_DEBUG))
		return

	log_admin("[key_name(usr)] teleported [key_name(M)]")
	message_admins("[key_name_admin(usr)] teleported [key_name_admin(M)]", 1)
	M.on_mob_jump(get_turf(usr))

ADMIN_VERB_ADD(/client/proc/Getkey, R_ADMIN, FALSE)
//teleports a mob with a certain ckey to our location
/client/proc/Getkey()
	set category = "Admin"
	set name = "Get Key"
	set desc = "Key to teleport"

	if(!check_rights(R_ADMIN|R_MOD|R_DEBUG))
		return

	var/list/keys = list()
	for(var/mob/M in GLOB.player_list)
		keys += M.client
	var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in sortKey(keys)
	if(!selection)
		return
	var/mob/M = selection:mob

	if(!M)
		return
	log_admin("[key_name(usr)] teleported [key_name(M)]")
	message_admins("[key_name_admin(usr)] teleported [key_name(M)]", 1)
	if(M)
		M.on_mob_jump(get_turf(usr))

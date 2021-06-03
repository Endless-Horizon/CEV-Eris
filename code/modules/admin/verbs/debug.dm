ADMIN_VERB_ADD(/client/proc/Debug2, R_DEBUG, FALSE)
/client/proc/Debug2()
	set category = "Debug"
	set name = "Debug-Game"
	if(!check_rights(R_DEBUG))	return

	if(Debug2)
		Debug2 = 0
		message_admins("[key_name(src)] toggled debugging off.")
		log_admin("[key_name(src)] toggled debugging off.")
	else
		Debug2 = 1
		message_admins("[key_name(src)] toggled debugging on.")
		log_admin("[key_name(src)] toggled debugging on.")



// callproc moved to code/modules/admin/callproc


/client/proc/Cell()
	set category = "Debug"
	set name = "Cell"
	if(!mob)
		return
	var/turf/T = mob.loc

	if (!istype(T, /turf))
		return

	var/datum/gas_mixture/env = T.return_air()

	var/t = "\blue Coordinates: [T.x],[T.y],[T.z]\n"
	t += "\red Temperature: [env.temperature]\n"
	t += "\red Pressure: [env.return_pressure()]kPa\n"
	for(var/g in env.gas)
		t += "\blue [g]: [env.gas[g]] / [env.gas[g] * R_IDEAL_GAS_EQUATION * env.temperature / env.volume]kPa\n"

	usr.show_message(t, 1)


/client/proc/cmd_admin_robotize(var/mob/living/M)
	set category = "Fun"
	set name = "Make Robot"

	if(ishuman(M))
		log_admin("[key_name(src)] has robotized [M.key].")
		M.Robotize()

	else
		alert("Invalid mob")

/client/proc/cmd_admin_animalize(mob/M in GLOB.mob_list)
	set category = "Fun"
	set name = "Make Simple Animal"

	if(!M)
		alert("That mob doesn't seem to exist, close the panel and try again.")
		return

	if(isnewplayer(M))
		alert("The mob must not be a new_player.")
		return

	log_admin("[key_name(src)] has animalized [M.key].")
	spawn(10)
		M.Animalize()


/client/proc/makepAI(turf/T)
	set category = "Fun"
	set name = "Make pAI"
	set desc = "Specify a location to spawn a pAI device, then specify a key to play that pAI"

	var/list/available = list()
	for(var/mob/C in GLOB.mob_list)
		if(C.key)
			available.Add(C)
	var/mob/choice = input("Choose a player to play the pAI", "Spawn pAI") in available
	if(!choice)
		return 0
	if(!isghost(choice))
		var/confirm = input("[choice.key] isn't ghosting right now. Are you sure you want to yank them out of them out of their body and place them in this pAI?", "Spawn pAI Confirmation", "No") in list("Yes", "No")
		if(confirm != "Yes")
			return 0
	var/obj/item/device/paicard/card = new(T)
	var/mob/living/silicon/pai/pai = new(card)
	pai.name = sanitizeSafe(input(choice, "Enter your pAI name:", "pAI Name", "Personal AI") as text)
	pai.real_name = pai.name
	pai.key = choice.key
	card.setPersonality(pai)
	for(var/datum/paiCandidate/candidate in SSpai.pai_candidates)
		if(candidate.key == choice.key)
			SSpai.pai_candidates.Remove(candidate)


/client/proc/cmd_admin_slimeize(mob/living/M)
	set category = "Fun"
	set name = "Make slime"

	if(ishuman(M))
		log_admin("[key_name(src)] has slimeized [M.key].")
		spawn(10)
			M.slimeize()

		log_admin("[key_name(usr)] made [key_name(M)] into a slime.")
		message_admins("\blue [key_name_admin(usr)] made [key_name(M)] into a slime.", 1)
	else
		alert("Invalid mob")

/*
/client/proc/cmd_admin_monkeyize(var/mob/M in GLOB.mob_living_list)
	set category = "Fun"
	set name = "Make Monkey"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		var/mob/living/carbon/human/target = M
		log_admin("[key_name(src)] is attempting to monkeyize [M.key].")
		spawn(10)
			target.monkeyize()
	else
		alert("Invalid mob")

/client/proc/cmd_admin_changelinginize(var/mob/M in GLOB.mob_living_list)
	set category = "Fun"
	set name = "Make Changeling"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has made [M.key] a changeling.")
		spawn(10)
			M.absorbed_dna[M.real_name] = M.dna.Clone()
			M.make_changeling()
			if(M.mind)
				M.mind.special_role = "Changeling"
	else
		alert("Invalid mob")
*/
/*
/client/proc/cmd_admin_abominize(var/mob/M in GLOB.mob_living_list)
	set category = null
	set name = "Make Abomination"

	to_chat(usr, "Ruby Mode disabled. Command aborted.")
	return
	if(!ticker)
		alert("Wait until the game starts.")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has made [M.key] an abomination.")

	//	spawn(10)
	//		M.make_abomination()

*/
/*
/client/proc/make_cultist(var/mob/M in GLOB.mob_living_list) // -- TLE, modified by Urist
	set category = "Fun"
	set name = "Make Cultist"
	set desc = "Makes target a cultist"
	if(!cultwords["travel"])
		runerandom()
	if(M)
		if(M.mind in ticker.mode.cult)
			return
		else
			if(alert("Spawn that person a tome?",,"Yes","No")=="Yes")
				to_chat(M, "\red You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie. A tome, a message from your new master, appears on the ground.")
				new /obj/item/weapon/book/tome(M.loc)
			else
				to_chat(M, "\red You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.")
			var/glimpse=pick("1","2","3","4","5","6","7","8")
			switch(glimpse)
				if("1")
					to_chat(M, "\red You remembered one thing from the glimpse... [cultwords["travel"]] is travel...")
				if("2")
					to_chat(M, "\red You remembered one thing from the glimpse... [cultwords["blood"]] is blood...")
				if("3")
					to_chat(M, "\red You remembered one thing from the glimpse... [cultwords["join"]] is join...")
				if("4")
					to_chat(M, "\red You remembered one thing from the glimpse... [cultwords["hell"]] is Hell...")
				if("5")
					to_chat(M, "\red You remembered one thing from the glimpse... [cultwords["destroy"]] is destroy...")
				if("6")
					to_chat(M, "\red You remembered one thing from the glimpse... [cultwords["technology"]] is technology...")
				if("7")
					to_chat(M, "\red You remembered one thing from the glimpse... [cultwords["self"]] is self...")
				if("8")
					to_chat(M, "\red You remembered one thing from the glimpse... [cultwords["see"]] is see...")

			if(M.mind)
				M.mind.special_role = "Cultist"
				ticker.mode.cult += M.mind
			to_chat(src, "Made [M] a cultist.")
*/


//TODO: merge the vievars version into this or something maybe mayhaps
ADMIN_VERB_ADD(/client/proc/cmd_debug_del_all, R_ADMIN|R_DEBUG, FALSE)
/client/proc/cmd_debug_del_all()
	set category = "Debug"
	set name = "Del-All"

	// to prevent REALLY stupid deletions
	var/blocked = list(/obj, /mob, /mob/living, /mob/living/carbon, /mob/living/carbon/human, /mob/observer, /mob/living/silicon, /mob/living/silicon/robot, /mob/living/silicon/ai)
	var/hsbitem = input(usr, "Choose an object to delete.", "Delete:") as null|anything in typesof(/obj) + typesof(/mob) - blocked
	if(hsbitem)
		for(var/atom/O in world)
			if(istype(O, hsbitem))
				qdel(O)
		log_admin("[key_name(src)] has deleted all instances of [hsbitem].")
		message_admins("[key_name_admin(src)] has deleted all instances of [hsbitem].", 0)

ADMIN_VERB_ADD(/client/proc/cmd_display_del_log, R_ADMIN|R_DEBUG, FALSE)
/client/proc/cmd_display_del_log()
	set category = "Debug"
	set name = "Display del() Log"
	set desc = "Display del's log of everything that's passed through it."

	var/list/dellog = list("<B>List of things that have gone through qdel this round</B><BR><BR><ol>")
	sortTim(SSgarbage.items, cmp=/proc/cmp_qdel_item_time, associative = TRUE)
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/I = SSgarbage.items[path]
		dellog += "<li><u>[path]</u><ul>"
		if (I.failures)
			dellog += "<li>Failures: [I.failures]</li>"
		dellog += "<li>qdel() Count: [I.qdels]</li>"
		dellog += "<li>Destroy() Cost: [I.destroy_time]ms</li>"
		if (I.hard_deletes)
			dellog += "<li>Total Hard Deletes [I.hard_deletes]</li>"
			dellog += "<li>Time Spent Hard Deleting: [I.hard_delete_time]ms</li>"
		if (I.slept_destroy)
			dellog += "<li>Sleeps: [I.slept_destroy]</li>"
		if (I.no_respect_force)
			dellog += "<li>Ignored force: [I.no_respect_force]</li>"
		if (I.no_hint)
			dellog += "<li>No hint: [I.no_hint]</li>"
		dellog += "</ul></li>"

	dellog += "</ol>"

	usr << browse(dellog.Join(), "window=dellog")

ADMIN_VERB_ADD(/client/proc/cmd_debug_make_powernets, R_DEBUG, FALSE)
/client/proc/cmd_debug_make_powernets()
	set category = "Debug"
	set name = "Make Powernets"
	SSmachines.makepowernets()
	log_admin("[key_name(src)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(src)] has remade the powernets. makepowernets() called.", 0)

/client/proc/cmd_admin_grantfullaccess(mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Grant Full Access"

	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/weapon/card/id/id = H.GetIdCard()
		if(id)
			id.icon_state = "gold"
			id.access = get_all_accesses()
		else
			var/obj/item/weapon/card/id/new_id = new/obj/item/weapon/card/id(M);
			new_id.icon_state = "gold"
			new_id.access = get_all_accesses()
			new_id.registered_name = H.real_name
			new_id.assignment = "Captain"
			new_id.name = "[new_id.registered_name]'s ID Card ([new_id.assignment])"
			H.equip_to_slot_or_del(new_id, slot_wear_id)
			H.update_inv_wear_id()
	else
		alert("Invalid mob")

	log_admin("[key_name(src)] has granted [M.key] full access.")
	message_admins("\blue [key_name_admin(usr)] has granted [M.key] full access.", 1)

/client/proc/cmd_assume_direct_control(mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Assume direct control"
	set desc = "Direct intervention"

	if(!check_rights(R_DEBUG|R_ADMIN))	return
	if(M.ckey)
		if(alert("This mob is being controlled by [M.ckey]. Are you sure you wish to assume control of it? [M.ckey] will be made a ghost.",,"Yes","No") != "Yes")
			return
		else
			var/mob/observer/ghost/ghost = new/mob/observer/ghost(M,1)
			ghost.ckey = M.ckey
	message_admins("\blue [key_name_admin(usr)] assumed direct control of [M].", 1)
	log_admin("[key_name(usr)] assumed direct control of [M].")
	var/mob/adminmob = src.mob
	M.ckey = src.ckey
	if(isghost(adminmob))
		qdel(adminmob)







/client/proc/cmd_admin_areatest()
	set category = "Mapping"
	set name = "Test areas"

	var/list/areas_all = list()
	var/list/areas_with_APC = list()
	var/list/areas_with_air_alarm = list()
	var/list/areas_with_RC = list()
	var/list/areas_with_light = list()
	var/list/areas_with_LS = list()
	var/list/areas_with_intercom = list()
	var/list/areas_with_camera = list()

	for(var/area/A in world)
		if(!(A.type in areas_all))
			areas_all.Add(A.type)

	for(var/obj/machinery/power/apc/APC in world)
		var/area/A = get_area(APC)
		if(!(A.type in areas_with_APC))
			areas_with_APC.Add(A.type)

	for(var/obj/machinery/alarm/alarm in world)
		var/area/A = get_area(alarm)
		if(!(A.type in areas_with_air_alarm))
			areas_with_air_alarm.Add(A.type)

	for(var/obj/machinery/requests_console/RC in world)
		var/area/A = get_area(RC)
		if(!(A.type in areas_with_RC))
			areas_with_RC.Add(A.type)

	for(var/obj/machinery/light/L in world)
		var/area/A = get_area(L)
		if(!(A.type in areas_with_light))
			areas_with_light.Add(A.type)

	for(var/obj/machinery/light_switch/LS in world)
		var/area/A = get_area(LS)
		if(!(A.type in areas_with_LS))
			areas_with_LS.Add(A.type)

	for(var/obj/item/device/radio/intercom/I in world)
		var/area/A = get_area(I)
		if(!(A.type in areas_with_intercom))
			areas_with_intercom.Add(A.type)

	for(var/obj/machinery/camera/C in world)
		var/area/A = get_area(C)
		if(!(A.type in areas_with_camera))
			areas_with_camera.Add(A.type)

	var/list/areas_without_APC = areas_all - areas_with_APC
	var/list/areas_without_air_alarm = areas_all - areas_with_air_alarm
	var/list/areas_without_RC = areas_all - areas_with_RC
	var/list/areas_without_light = areas_all - areas_with_light
	var/list/areas_without_LS = areas_all - areas_with_LS
	var/list/areas_without_intercom = areas_all - areas_with_intercom
	var/list/areas_without_camera = areas_all - areas_with_camera

	to_chat(world, "<b>AREAS WITHOUT AN APC:</b>")
	for(var/areatype in areas_without_APC)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT AN AIR ALARM:</b>")
	for(var/areatype in areas_without_air_alarm)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT A REQUEST CONSOLE:</b>")
	for(var/areatype in areas_without_RC)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY LIGHTS:</b>")
	for(var/areatype in areas_without_light)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT A LIGHT SWITCH:</b>")
	for(var/areatype in areas_without_LS)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY INTERCOMS:</b>")
	for(var/areatype in areas_without_intercom)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY CAMERAS:</b>")
	for(var/areatype in areas_without_camera)
		to_chat(world, "* [areatype]")


ADMIN_VERB_ADD(/client/proc/cmd_admin_dress, R_FUN, FALSE)
/client/proc/cmd_admin_dress()
	set category = "Fun"
	set name = "Select equipment"

	var/mob/living/carbon/human/M = input("Select mob.", "Select equipment.") as null|anything in GLOB.human_mob_list // CURRENTLY HUMAN, but this should be mob_list in the future!!!
	if(!M) return

	var/list/dresspacks = outfits()
	var/decl/hierarchy/outfit/dresscode = input("Select dress for [M]", "Robust quick dress shop") as null|anything in dresspacks
	if (isnull(dresscode))
		return

	dresscode.equip(M)

/client/proc/startSinglo()
	set category = "Debug"
	set name = "Start Singularity"
	set desc = "Sets up the singularity and all machines to get power flowing through the station"

	if(alert("Are you sure? This will start up the engine. Should only be used during debug!",,"Yes","No") != "Yes")
		return

	for(var/obj/machinery/power/emitter/E in world)
		if(E.anchored)
			E.active = 1

	for(var/obj/machinery/field_generator/F in world)
		if(F.anchored)
			F.Varedit_start = 1
	spawn(30)
		for(var/obj/machinery/the_singularitygen/G in world)
			if(G.anchored)
				var/obj/singularity/S = new /obj/singularity(get_turf(G), 50)
				spawn(0)
					qdel(G)
				S.energy = 1750
				S.current_size = 7
				S.icon = 'icons/effects/224x224.dmi'
				S.icon_state = "singularity_s7"
				S.pixel_x = -96
				S.pixel_y = -96
				S.grav_pull = 0
				//S.consume_range = 3
				S.dissipate = 0
				//S.dissipate_delay = 10
				//S.dissipate_track = 0
				//S.dissipate_strength = 10

	for(var/obj/machinery/power/rad_collector/Rad in world)
		if(Rad.anchored)
			if(!Rad.P)
				var/obj/item/weapon/tank/plasma/Plasma = new/obj/item/weapon/tank/plasma(Rad)
				Plasma.air_contents.gas["plasma"] = 70
				Rad.drainratio = 0
				Rad.P = Plasma
				Plasma.loc = Rad

			if(!Rad.active)
				Rad.toggle_power()

	for(var/obj/machinery/power/smes/SMES in world)
		if(SMES.anchored)
			SMES.input_attempt = 1


ADMIN_VERB_ADD(/client/proc/cmd_debug_mob_lists, R_DEBUG, FALSE)
/client/proc/cmd_debug_mob_lists()
	set category = "Debug"
	set name = "Debug Mob Lists"
	set desc = "For when you just gotta know"

	switch(input("Which list?") in list("Players","Admins","Mobs","Living Mobs","Dead Mobs", "Clients"))
		if("Players")
			to_chat(usr, jointext(GLOB.player_list,","))
		if("Admins")
			to_chat(usr, jointext(admins,","))
		if("Mobs")
			to_chat(usr, jointext(GLOB.mob_list,","))
		if("Living Mobs")
			to_chat(usr, jointext(GLOB.living_mob_list,","))
		if("Dead Mobs")
			to_chat(usr, jointext(GLOB.dead_mob_list,","))
		if("Clients")
			to_chat(usr, jointext(clients,","))

// DNA2 - Admin Hax
/client/proc/cmd_admin_toggle_block(mob/M,var/block)
	if(iscarbon(M))
		M.dna.SetSEState(block,!M.dna.GetSEState(block))
		domutcheck(M,null,MUTCHK_FORCED)
		M.update_mutations()
		var/state="[M.dna.GetSEState(block)?"on":"off"]"
		var/blockname=assigned_blocks[block]
		message_admins("[key_name_admin(src)] has toggled [M.key]'s [blockname] block [state]!")
		log_admin("[key_name(src)] has toggled [M.key]'s [blockname] block [state]!")
	else
		alert("Invalid mob")

ADMIN_VERB_ADD(/client/proc/view_runtimes, R_DEBUG, FALSE)
/client/proc/view_runtimes()
	set category = "Debug"
	set name = "View Runtimes"
	set desc = "Open the runtime Viewer"

	if(!holder)
		return

	GLOB.error_cache.show_to(src)


ADMIN_VERB_ADD(/client/proc/spawn_disciple, R_DEBUG, FALSE)
/client/proc/spawn_disciple()
	set category = "Debug"
	set name = "Spawn Disciple"
	set desc = "Spawns a human with a cruciform, for ritual testing"
	if (!mob)
		return

	var/mob/living/carbon/human/H = new (get_turf(mob))
	var/obj/item/weapon/implant/core_implant/cruciform/C = new /obj/item/weapon/implant/core_implant/cruciform(H)

	C.install(H)
	C.activate()


ADMIN_VERB_ADD(/client/proc/delete_npcs, R_DEBUG, FALSE)
/client/proc/delete_npcs()
	set category = "Debug"
	set name = "Delete NPC mobs"
	set desc = "Deletes every mob that isn't a player"

	if(alert("Are you sure you want to delete all nonplayer mobs?",,"Yes", "No") == "No")
		return

	var/total = 0
	for (var/mob/living/L in world)
		if ((L in GLOB.player_list))
			continue
		qdel(L)
		total++
	to_chat(world, "Deleted [total] mobs")

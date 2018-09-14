ADMIN_VERB_ADD(/client/proc/air_report, R_DEBUG, FALSE)
/client/proc/air_report()
	set category = "Debug"
	set name = "Show Air Report"

	var/active_groups = SSair.active_zones
	var/inactive_groups = SSair.zones.len - active_groups

	var/hotspots = 0
	for(var/obj/fire/hotspot in world)
		hotspots++

	var/active_on_main_station = 0
	var/inactive_on_main_station = 0
	for(var/zone/zone in SSair.zones)
		var/turf/simulated/turf = locate() in zone.contents
		if(isOnStationLevel(turf))
			if(zone.needs_update)
				active_on_main_station++
			else
				inactive_on_main_station++

	var/output = {"<B>AIR SYSTEMS REPORT</B><HR>
<B>General Processing Data</B><BR>
	Cycle: [SSair.times_fired]<br>
	Groups: [SSair.zones.len]<BR>
---- <I>Active:</I> [active_groups]<BR>
---- <I>Inactive:</I> [inactive_groups]<BR><br>
---- <I>Active on station:</i> [active_on_main_station]<br>
---- <i>Inactive on station:</i> [inactive_on_main_station]<br>
<BR>
<B>Special Processing Data</B><BR>
	Hotspot Processing: [hotspots]<BR>
<br>
<B>Geometry Processing Data</B><BR>
	Tile Update: [SSair.tiles_to_update.len]<BR>
"}

	usr << browse(output,"window=airreport")

/client/proc/fix_next_move()
	set category = "Debug"
	set name = "Unfreeze Everyone"
	var/largest_move_time = 0
	var/largest_click_time = 0
	var/mob/largest_move_mob = null
	var/mob/largest_click_mob = null
	for(var/mob/M in world)
		if(!M.client)
			continue
		if(M.next_move >= largest_move_time)
			largest_move_mob = M
			if(M.next_move > world.time)
				largest_move_time = M.next_move - world.time
			else
				largest_move_time = 1
		if(M.next_click >= largest_click_time)
			largest_click_mob = M
			if(M.next_click > world.time)
				largest_click_time = M.next_click - world.time
			else
				largest_click_time = 0
		log_admin("DEBUG: [key_name(M)]  next_move = [M.next_move]  next_click = [M.next_click]  world.time = [world.time]")
		M.next_move = 1
		M.next_click = 0
	message_admins("[key_name_admin(largest_move_mob)] had the largest move delay with [largest_move_time] frames / [largest_move_time/10] seconds!", 1)
	message_admins("[key_name_admin(largest_click_mob)] had the largest click delay with [largest_click_time] frames / [largest_click_time/10] seconds!", 1)
	message_admins("world.time = [world.time]", 1)

	return

/client/proc/radio_report()
	set category = "Debug"
	set name = "Radio report"

	var/output = "<b>Radio Report</b><hr>"
	for (var/fq in radio_controller.frequencies)
		output += "<b>Freq: [fq]</b><br>"
		var/list/datum/radio_frequency/fqs = radio_controller.frequencies[fq]
		if (!fqs)
			output += "&nbsp;&nbsp;<b>ERROR</b><br>"
			continue
		for (var/filter in fqs.devices)
			var/list/f = fqs.devices[filter]
			if (!f)
				output += "&nbsp;&nbsp;[filter]: ERROR<br>"
				continue
			output += "&nbsp;&nbsp;[filter]: [f.len]<br>"
			for (var/device in f)
				if (isobj(device))
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device] ([device:x],[device:y],[device:z] in area [get_area(device:loc)])<br>"
				else
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device]<br>"

	usr << browse(output,"window=radioreport")


ADMIN_VERB_ADD(/client/proc/reload_admins, R_SERVER, FALSE)
/client/proc/reload_admins()
	set name = "Reload Admins"
	set category = "Debug"

	if(!check_rights(R_SERVER))	return

	message_admins("[usr] manually reloaded admins")
	load_admins()


ADMIN_VERB_ADD(/client/proc/reload_mentors, R_SERVER, FALSE)
/client/proc/reload_mentors()
	set name = "Reload Mentors"
	set category = "Debug"

	if(!check_rights(R_SERVER)) return

	message_admins("[usr] manually reloaded Mentors")
	world.load_mods()

/*
//todo:
ADMIN_VERB_ADD(/client/proc/jump_to_dead_group, R_DEBUG, FALSE)
/client/proc/jump_to_dead_group()
	set name = "Jump to dead group"
	set category = "Debug"
	if(!holder)
		src << "Only administrators may use this command."
		return

	var/datum/air_group/dead_groups = list()
	for(var/datum/air_group/group in SSair.air_groups)
		if (!group.group_processing)
			dead_groups += group
	var/datum/air_group/dest_group = pick(dead_groups)
	usr.loc = pick(dest_group.members)

	return
*/

/*
ADMIN_VERB_ADD(/client/proc/kill_airgroup, R_DEBUG, FALSE)
/client/proc/kill_airgroup()
	set name = "Kill Local Airgroup"
	set desc = "Use this to allow manual manupliation of atmospherics."
	set category = "Debug"
	if(!holder)
		src << "Only administrators may use this command."
		return

	var/turf/T = get_turf(usr)
	if(istype(T, /turf/simulated))
		var/datum/air_group/AG = T:parent
		AG.next_check = 30
		AG.group_processing = 0
	else
		usr << "Local airgroup is unsimulated!"

*/

/client/proc/print_jobban_old()
	set name = "Print Jobban Log"
	set desc = "This spams all the active jobban entries for the current round to standard output."
	set category = "Debug"

	usr << "<b>Jobbans active in this round.</b>"
	for(var/t in jobban_keylist)
		usr << "[t]"

/client/proc/print_jobban_old_filter()
	set name = "Search Jobban Log"
	set desc = "This searches all the active jobban entries for the current round and outputs the results to standard output."
	set category = "Debug"

	var/filter = input("Contains what?","Filter") as text|null
	if(!filter)
		return

	usr << "<b>Jobbans active in this round.</b>"
	for(var/t in jobban_keylist)
		if(findtext(t, filter))
			usr << "[t]"

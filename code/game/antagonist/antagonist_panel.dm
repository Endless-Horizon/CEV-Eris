/datum/antagonist/proc/get_panel_entry()

	var/dat = "<tr><td><b>[role_text]:</b>"
	if(!owner)
		dat += "<br><b>This antag datum has no owner.</b> <a href='?src=\ref[src];select_antagonist=1'>\[select\]</a>"
	else
		dat += "<br><b>Owner: </b>[owner.name] <a href='?src=\ref[owner]'>\[memory\]</a>"
	var/extra = get_extra_panel_options()
	if(owner)
		dat += "<br><a href='?src=\ref[src];remove_antagonist=1'>\[remove\]</a>"
		dat += "<a href='?src=\ref[src];equip_antagonist=1'>\[equip\]</a>"
		dat += "<a href='?src=\ref[src];unequip_antagonist=1'>\[unequip\]</a>"
		if(outer)
			dat += "<a href='?src=\ref[src];move_antag_to_spawn=1'>\[move to spawn\]</a>"
		if(extra)
			dat += "[extra]"
	else
		dat += "<br><a href='?src=\ref[src];del_datum=1'><b><font color='red'>\[DELETE DATUM\]</font></b></a>"

	dat += "<br>"

	if(faction_id)
		dat += "<b>Faction: </b>"
		if(faction)
			dat += "<b>\"[faction.name]\" ([faction.antag])</b>"
			dat += "<a href='?src=\ref[src];remove_faction=1'>\[remove\]</a>"
			dat += "<a href='?src=\ref[src];edit_faction=1'>\[panel\]</a>"
		else
			dat += "<i>No faction.</i>"
			dat += "<a href='?src=\ref[src];add_faction=1'>\[add\]</a>"
			dat += "<a href='?src=\ref[src];new_faction=1'>\[new\]</a>"
		dat += "<br><i>Objectives are in faction panel.</i>"
	else if(objectives.len)
		dat += "<b>Objectives</b><br>"
		var/num = 1
		for(var/datum/objective/O in objectives)
			dat += "<b>Objective #[num]:</b>"
			if(O.completed)
				dat += "(<font color='green'>complete</font>)"
			else
				dat += "(<font color='red'>incomplete</font>)"
			dat += " <a href='?src=\ref[src];obj_completed=\ref[O]'>\[toggle\]</a>"
			dat += " <a href='?src=\ref[src];obj_delete=\ref[O]'>\[remove\]</a><br>"
			dat += "<div>[O.get_panel_entry()]</div>"
			num++
		dat += "<br><a href='?src=\ref[src];obj_announce=1'>\[announce objectives\]</a>"
	dat += "<br><a href='?src=\ref[src];obj_add=1'>\[add\]</a>"
	dat += "</td></tr>"
	return dat

/datum/antagonist/proc/antagonist_panel()
	usr << browse(get_panel_entry(),"window=\ref[src]antag")

/datum/antagonist/Topic(href, href_list)
	if(!check_rights(R_ADMIN))
		return TRUE

	if(href_list["select_antagonist"])
		if(!owner)
			if(!outer)
				var/list/MN = list()
				for(var/datum/mind/M in SSticker.minds)
					if(can_become_antag(M))
						MN[M.name] = M
				MN["CANCEL"] = null

				var/datum/mind/M = input("Select mind for role.","Add antagonist",null) in MN
				if(M)
					create_antagonist(M)
			else
				var/list/CD = list()
				for(var/mob/observer/M in GLOB.player_list)
					if(can_become_antag_ghost(M))
						CD[M.name] = M
				CD["CANCEL"] = null

				var/mob/M = input("Select ghost for role.","Add antagonist",null) in CD
				if(M)
					create_from_ghost(M)

	else if(href_list["remove_antagonist"])
		remove_antagonist()

	else if(href_list["equip_antagonist"])
		equip()

	else if(href_list["unequip_antagonist"])
		unequip()

	else if(href_list["move_antag_to_spawn"])
		place_antagonist()


	else if(href_list["obj_announce"])
		show_objectives()

	else if(href_list["obj_add"])
		var/new_obj_type = input("Select objective type:", "Objective type") as null|anything in all_objectives_types
		if(!new_obj_type) return

		var/new_type = all_objectives_types[new_obj_type]
		new new_type(src)

	else if(href_list["obj_delete"])
		var/datum/objective/objective = locate(href_list["obj_delete"])
		if(!istype(objective))
			return
		qdel(objective)

	else if(href_list["obj_completed"])
		var/datum/objective/objective = locate(href_list["obj_completed"])
		if(!istype(objective))
			return
		objective.completed = !objective.completed

	else if(href_list["remove_faction"] && faction)
		faction.remove_member(src)

	else if(href_list["edit_faction"] && faction)
		faction.faction_panel()

	else if(href_list["add_faction"] && faction_id && !faction)
		var/list/L = list()
		for(var/datum/faction/F in GLOB.current_factions)
			L["[F.name], faction of [F.antag] ([F.id])"] = F

		L["CANCEL"] = null

		var/f_id = input("Select faction for this antagonist.", "Select faction", "CANCEL") in L

		var/datum/faction/F = L[f_id]
		if(F)
			F.add_member(src)


	else if(href_list["new_faction"] && faction_id && !faction)
		var/t = GLOB.faction_types[faction_id]
		var/datum/faction/F = new t
		F.customize()
		F.add_leader(src)

	else if(href_list["edit_memory"])
		if(owner)
			owner.edit_memory()

	else if(href_list["del_datum"])
		if(input("Are you sure you want to delete this datum?","Antag del","No","Yes") == "Yes")
			remove_antagonist()
			qdel(src)
			return

	antagonist_panel()

/datum/antagonist/proc/get_extra_panel_options()
	return

/* !TODO: This should be implemented in storyteller_print.dm (GLOB.storyteller.antagonist_report())
/datum/antagonist/proc/get_check_antag_output(var/datum/admins/caller)

	if(!current_antagonists || !current_antagonists.len)
		return ""

	var/dat = "<br><table cellspacing=5><tr><td><B>[role_text_plural]</B></td><td></td></tr>"
	for(var/datum/mind/player in current_antagonists)
		var/mob/M = player.current
		dat += "<tr>"
		if(M)
			dat += "<td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]/([player.key])</a>"
			if(!M.client)      dat += " <i>(logged out)</i>"
			if(M.stat == DEAD) dat += " <b><font color=red>(DEAD)</font></b>"
			dat += "</td>"
			dat += "<td>\[<A href='?src=\ref[caller];priv_msg=\ref[M]'>PM</A>\]\[<A href='?src=\ref[caller];traitor=\ref[M]'>TP</A>\]</td>"
		else
			dat += "<td><i>Mob not found/([player.key])!</i></td>"
		dat += "</tr>"
	dat += "</table>"

	if(flags & ANTAG_HAS_NUKE)
		dat += "<br><table><tr><td><B>Nuclear disk(s)</B></td></tr>"
		for(var/obj/item/disk/nuclear/N in world)
			dat += "<tr><td>[N.name], "
			var/atom/disk_loc = N.loc
			while(!istype(disk_loc, /turf))
				if(ismob(disk_loc))
					var/mob/M = disk_loc
					dat += "carried by <a href='?src=\ref[caller];adminplayeropts=\ref[M]'>[M.real_name]</a> "
				if(isobj(disk_loc))
					var/obj/O = disk_loc
					dat += "in \a [O.name] "
				disk_loc = disk_loc.loc
			dat += "in [disk_loc.loc] at ([disk_loc.x], [disk_loc.y], [disk_loc.z])</td></tr>"
		dat += "</table>"
	dat += get_additional_check_antag_output(caller)
	dat += "<hr>"
	return dat
*/
//Overridden elsewhere.
/datum/antagonist/proc/get_additional_check_antag_output(var/datum/admins/caller)
	return ""

/*
	A tool upgrade is a little attachment for a tool that improves it in some way
	Tool upgrades are generally permanant

	Some upgrades have multiple bonuses. Some have drawbacks in addition to boosts
*/

/*/client/verb/debugupgrades()
	for (var/t in subtypesof(/obj/item/weapon/tool_upgrade))
		new t(usr.loc)
*/
/datum/component/item_upgrade
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/prefix = "upgraded" //Added to the tool's name

	var/gun_tag //Used for checking where the item will be placed on a gun

	//The upgrade can be applied to a tool that has any of these qualities
	var/list/required_qualities = list()

	//The upgrade can not be applied to a tool that has any of these qualities
	var/list/negative_qualities = list()

	//If REQ_FUEL, can only be applied to tools that use fuel. If REQ_CELL, can only be applied to tools that use cell, If REQ_FUEL_OR_CELL, can be applied if it has fuel OR a cell
	var/req_fuel_cell = FALSE

	//Actual effects of upgrades
	var/list/tool_upgrades = list() //variable name(string) -> num

	//Weapon upgrades
	var/list/weapon_upgrades = list() //variable name(string) -> num

/datum/component/item_upgrade/Initialize()
	RegisterSignal(parent, COMSIG_IATTACK, .proc/attempt_install)
	RegisterSignal(parent, COMSIG_EXAMINE, .proc/on_examine)
	RegisterSignal(parent, COMSIG_REMOVE, .proc/uninstall)

/datum/component/item_upgrade/proc/attempt_install(atom/A, var/mob/living/user, params)
	return can_apply(A, user) && apply(A, user)

/datum/component/item_upgrade/proc/can_apply(var/atom/A, var/mob/living/user)
	if (isrobot(A))
		return check_robot(A, user)

	if (isitem(A))
		var/obj/item/T = A
		//No using multiples of the same upgrade
		for (var/obj/item/I in T.item_upgrades)
			if (I.type == parent.type)
				to_chat(user, SPAN_WARNING("An upgrade of this type is already installed!"))
				return FALSE

	if (istool(A))
		return check_tool(A, user)

	if (isgun(A))
		return check_gun(A, user)

	return FALSE

/datum/component/item_upgrade/proc/check_robot(var/mob/living/silicon/robot/R, var/mob/living/user)
	if(!R.opened)
		to_chat(user, SPAN_WARNING("You need to open [R]'s panel to access its tools."))
	var/list/robotools = list()
	for(var/obj/item/weapon/tool/robotool in R.module.modules)
		robotools.Add(robotool)
	if(robotools.len)
		var/obj/item/weapon/tool/chosen_tool = input(user,"Which tool are you trying to modify?","Tool Modification","Cancel") in robotools + "Cancel"
		if(chosen_tool == "Cancel")
			return FALSE
		return can_apply(chosen_tool,user)
	else
		to_chat(user, SPAN_WARNING("[R] has no modifiable tools."))
	return FALSE

/datum/component/item_upgrade/proc/check_tool(var/obj/item/weapon/tool/T, var/mob/living/user)
	if (T.item_upgrades.len >= T.max_upgrades)
		to_chat(user, SPAN_WARNING("This tool can't fit anymore modifications!"))
		return FALSE

	if (required_qualities.len)
		var/qmatch = FALSE
		for (var/q in required_qualities)
			if (T.ever_has_quality(q))
				qmatch = TRUE
				break

		if (!qmatch)
			to_chat(user, SPAN_WARNING("This tool lacks the required qualities!"))
			return FALSE

	if(negative_qualities.len)
		for(var/i in negative_qualities)
			if(T.ever_has_quality(i))
				to_chat(user, SPAN_WARNING("This tool can not accept the modification!"))
				return FALSE

	if ((req_fuel_cell & REQ_FUEL) && !T.use_fuel_cost)
		to_chat(user, SPAN_WARNING("This tool does not use fuel!"))
		return FALSE

	if((req_fuel_cell & REQ_CELL) && !T.use_power_cost)
		to_chat(user, SPAN_WARNING("This tool does not use power!"))
		return FALSE

	if((req_fuel_cell & REQ_FUEL_OR_CELL) && (!T.use_power_cost && !T.use_fuel_cost))
		to_chat(user, SPAN_WARNING("This tool does not use [T.use_power_cost?"fuel":"power"]!"))
		return FALSE

	if(tool_upgrades["cell_hold_upgrades"])
		if(!(T.suitable_cell == /obj/item/weapon/cell/medium || T.suitable_cell == /obj/item/weapon/cell/small))
			to_chat(user, SPAN_WARNING("This tool does not require a cell holding upgrade."))
			return FALSE
		if(T.cell)
			to_chat(user, SPAN_WARNING("Remove the cell from the tool first!"))
			return FALSE

	return TRUE

/datum/component/item_upgrade/proc/check_gun(var/obj/item/weapon/gun/G, var/mob/living/user)
	if(!gun_tag)
		to_chat(user, SPAN_WARNING("\The [parent] can not be applied to guns!"))
		return FALSE //Can't be applied to a weapon
	if(G.item_upgrades[gun_tag])
		to_chat(user, SPAN_WARNING("There is already something attached to \the [G]'s [gun_tag]!"))
		return FALSE
	return TRUE

/datum/component/item_upgrade/proc/apply(var/obj/item/A, var/mob/living/user)
	if (user)
		user.visible_message(SPAN_NOTICE("[user] starts applying [parent] to [A]"), SPAN_NOTICE("You start applying \the [parent] to \the [A]"))
		var/obj/item/I = parent
		if (!I.use_tool(user = user, target =  A, base_time = WORKTIME_FAST, required_quality = null, fail_chance = FAILCHANCE_ZERO, required_stat = STAT_MEC, forced_sound = WORKSOUND_WRENCHING))
			return FALSE
		to_chat(user, SPAN_NOTICE("You have successfully installed \the [parent] in \the [A]"))
		user.drop_from_inventory(parent)
	//If we get here, we succeeded in the applying
	var/obj/item/I = parent
	I.forceMove(A)
	A.item_upgrades.Add(I)
	RegisterSignal(A, COMSIG_APPVAL, .proc/apply_values)
	A.refresh_upgrades()
	return TRUE

/datum/component/item_upgrade/proc/uninstall(var/obj/item/I)
	var/obj/item/P = parent
	I.item_upgrades -= P
	P.forceMove(get_turf(I))
	UnregisterSignal(I, COMSIG_APPVAL)

/datum/component/item_upgrade/proc/apply_values(var/atom/holder)
	if (!holder)
		return
	if(istool(holder))
		apply_values_tool(holder)
	if(isgun(holder))
		apply_values_gun(holder)
	return TRUE

/datum/component/item_upgrade/proc/apply_values_tool(var/obj/item/weapon/tool/T)
	if(tool_upgrades[UPGRADE_PRECISION])
		T.precision += tool_upgrades[UPGRADE_PRECISION]
	if(tool_upgrades[UPGRADE_WORKSPEED])
		T.workspeed += tool_upgrades[UPGRADE_WORKSPEED]
	if(tool_upgrades[UPGRADE_DEGRADATION_MULT])
		T.degradation *= tool_upgrades[UPGRADE_DEGRADATION_MULT]
	if(tool_upgrades[UPGRADE_FORCE_MULT])
		T.force *= tool_upgrades[UPGRADE_FORCE_MULT]
		T.switched_on_force *= tool_upgrades[UPGRADE_FORCE_MULT]
	if(tool_upgrades[UPGRADE_FORCE_MOD])
		T.force += tool_upgrades[UPGRADE_FORCE_MOD]
		T.switched_on_force += tool_upgrades[UPGRADE_FORCE_MOD]
	if(tool_upgrades[UPGRADE_FUELCOST_MULT])
		T.use_fuel_cost *= tool_upgrades[UPGRADE_FUELCOST_MULT]
	if(tool_upgrades[UPGRADE_POWERCOST_MULT])
		T.use_power_cost *= tool_upgrades[UPGRADE_POWERCOST_MULT]
	if(tool_upgrades[UPGRADE_BULK])
		T.extra_bulk += tool_upgrades[UPGRADE_BULK]
	if(tool_upgrades[UPGRADE_HEALTH_THRESHOLD])
		T.health_threshold += tool_upgrades[UPGRADE_HEALTH_THRESHOLD]
	if(tool_upgrades[UPGRADE_MAXFUEL])
		T.max_fuel += tool_upgrades[UPGRADE_MAXFUEL]
	if(tool_upgrades[UPGRADE_MAXUPGRADES])
		T.max_upgrades += tool_upgrades[UPGRADE_MAXUPGRADES]
	if(tool_upgrades[UPGRADE_SHARP])
		T.sharp = tool_upgrades[UPGRADE_SHARP]
	if(tool_upgrades[UPGRADE_COLOR])
		T.color = tool_upgrades[UPGRADE_COLOR]
	if(tool_upgrades[UPGRADE_ITEMFLAGPLUS])
		T.item_flags |= tool_upgrades[UPGRADE_ITEMFLAGPLUS]
	if(tool_upgrades[UPGRADE_CELLPLUS])
		switch(T.suitable_cell)
			if(/obj/item/weapon/cell/medium)
				T.suitable_cell = /obj/item/weapon/cell/large
				prefix = "large-cell"
			if(/obj/item/weapon/cell/small)
				T.suitable_cell = /obj/item/weapon/cell/medium
	T.prefixes |= prefix

/datum/component/item_upgrade/proc/apply_values_gun(var/obj/item/weapon/gun/G)

/datum/component/item_upgrade/proc/on_examine(var/mob/user)
	if (tool_upgrades[UPGRADE_PRECISION] > 0)
		to_chat(user, SPAN_NOTICE("Enhances precision by [tool_upgrades[UPGRADE_PRECISION]]"))
	else if (tool_upgrades[UPGRADE_PRECISION] < 0)
		to_chat(user, SPAN_WARNING("Reduces precision by [abs(tool_upgrades[UPGRADE_PRECISION])]"))
	if (tool_upgrades[UPGRADE_WORKSPEED])
		to_chat(user, SPAN_NOTICE("Enhances workspeed by [tool_upgrades[UPGRADE_WORKSPEED]*100]%"))

	if (tool_upgrades[UPGRADE_DEGRADATION_MULT] < 1)
		to_chat(user, SPAN_NOTICE("Reduces tool degradation by [(1-tool_upgrades[UPGRADE_DEGRADATION_MULT])*100]%"))
	else if	(tool_upgrades[UPGRADE_DEGRADATION_MULT] > 1)
		to_chat(user, SPAN_WARNING("Increases tool degradation by [(tool_upgrades[UPGRADE_DEGRADATION_MULT]-1)*100]%"))

	if (tool_upgrades[UPGRADE_FORCE_MULT] >= 1)
		to_chat(user, SPAN_NOTICE("Increases tool damage by [(tool_upgrades[UPGRADE_FORCE_MULT]-1)*100]%"))
	if (tool_upgrades[UPGRADE_FORCE_MOD])
		to_chat(user, SPAN_NOTICE("Increases tool damage by [tool_upgrades[UPGRADE_FORCE_MOD]]"))
	if (tool_upgrades[UPGRADE_POWERCOST_MULT] >= 1)
		to_chat(user, SPAN_WARNING("Modifies power usage by [(tool_upgrades[UPGRADE_POWERCOST_MULT]-1)*100]%"))
	if (tool_upgrades[UPGRADE_FUELCOST_MULT] >= 1)
		to_chat(user, SPAN_WARNING("Modifies fuel usage by [(tool_upgrades[UPGRADE_FUELCOST_MULT]-1)*100]%"))
	if (tool_upgrades[UPGRADE_MAXFUEL])
		to_chat(user, SPAN_NOTICE("Modifies fuel storage by [tool_upgrades[UPGRADE_MAXFUEL]] units."))
	if (tool_upgrades[UPGRADE_BULK])
		to_chat(user, SPAN_WARNING("Increases tool size by [tool_upgrades[UPGRADE_BULK]]"))

	if (required_qualities.len)
		to_chat(user, SPAN_WARNING("Requires a tool with one of the following qualities:"))
		to_chat(user, english_list(required_qualities, and_text = " or "))

	if(gun_tag)
		to_chat(user, SPAN_NOTICE("Can be attached to a gun's [gun_tag], giving the following benefits to a gun:"))




/obj/item/weapon/tool_upgrade
	name = "tool upgrade"
	icon = 'icons/obj/tool_upgrades.dmi'
	force = WEAPON_FORCE_HARMLESS
	w_class = ITEM_SIZE_SMALL
	price_tag = 200
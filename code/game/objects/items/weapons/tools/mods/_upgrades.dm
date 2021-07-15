/*
	A tool upgrade is a little attachment for a tool that improves it in some way
	Tool upgrades are generally permanant

	Some upgrades have multiple bonuses. Some have drawbacks in addition to boosts
*/

/*/client/verb/debugupgrades()
	for (var/t in subtypesof(/obj/item/tool_upgrade))
		new t(usr.loc)
*/
/datum/component/item_upgrade
	dupe_mode = COMPONENT_DUPE_UNIQUE
	can_transfer = TRUE
	var/prefix = "upgraded" //Added to the tool's name

	var/removal_time = WORKTIME_SLOW
	var/removal_difficulty = FAILCHANCE_CHALLENGING
	var/destroy_on_removal = FALSE
	//The upgrade can be applied to a tool that has any of these qualities
	var/list/required_qualities = list()
	var/removable = TRUE

	//The upgrade can not be applied to a tool that has any of these qualities
	var/list/negative_qualities = list()

	//If REQ_FUEL, can only be applied to tools that use fuel. If REQ_CELL, can only be applied to tools that use cell, If REQ_FUEL_OR_CELL, can be applied if it has fuel OR a cell
	var/req_fuel_cell = FALSE

	var/exclusive_type

	//Actual effects of upgrades
	var/list/tool_upgrades = list() //variable name(string) -> num

	//Weapon upgrades
	var/list/gun_loc_tag //Define(string). For checking if the gun already has something of this installed (No double trigger mods, for instance)
	var/list/req_gun_tags = list() //Define(string). Must match all to be able to install it.
	var/list/weapon_upgrades = list() //variable name(string) -> num

/datum/component/item_upgrade/RegisterWithParent()
	RegisterSignal(parent, COMSIG_IATTACK, .proc/attempt_install)
	RegisterSignal(parent, COMSIG_EXAMINE, .proc/on_examine)
	RegisterSignal(parent, COMSIG_REMOVE, .proc/uninstall)

/datum/component/item_upgrade/proc/attempt_install(atom/A, mob/living/user, params)
	return can_apply(A, user) && apply(A, user)

/datum/component/item_upgrade/proc/can_apply(atom/A, mob/living/user)
	if(isrobot(A))
		return check_robot(A, user)

	if(isitem(A))
		var/obj/item/T = A
		//No using multiples of the same upgrade
		for (var/obj/item/I in T.item_upgrades)
			if(I.type == parent.type || (exclusive_type && istype(I.type, exclusive_type)))
				if(user)
					to_chat(user, SPAN_WARNING("An upgrade of this type is already installed!"))
				return FALSE

	if(istool(A))
		return check_tool(A, user)

	if(isgun(A))
		return check_gun(A, user)

	return FALSE

/datum/component/item_upgrade/proc/check_robot(mob/living/silicon/robot/R, mob/living/user)
	if(!R.opened)
		if(user)
			to_chat(user, SPAN_WARNING("You need to open [R]'s panel to access its tools."))
		return FALSE
	var/list/robotools = list()
	for(var/obj/item/tool/robotool in R.module.modules)
		robotools.Add(robotool)
	if(robotools.len)
		var/obj/item/tool/chosen_tool = input(user,"Which tool are you trying to modify?","Tool Modification","Cancel") in robotools + "Cancel"
		if(chosen_tool == "Cancel")
			return FALSE
		return can_apply(chosen_tool,user)
	if(user)
		to_chat(user, SPAN_WARNING("[R] has no modifiable tools."))
	return FALSE

/datum/component/item_upgrade/proc/check_tool(obj/item/tool/T, mob/living/user)
	if(!tool_upgrades.len)
		to_chat(user, SPAN_WARNING("\The [parent] can not be attached to a tool."))
		return FALSE

	if(T.item_upgrades.len >= T.max_upgrades)
		if(user)
			to_chat(user, SPAN_WARNING("This tool can't fit anymore modifications!"))
		return FALSE

	if(required_qualities.len)
		var/qmatch = FALSE
		for (var/q in required_qualities)
			if(T.ever_has_quality(q))
				qmatch = TRUE
				break

		if(!qmatch)
			if(user)
				to_chat(user, SPAN_WARNING("This tool lacks the required qualities!"))
			return FALSE

	if(negative_qualities.len)
		for(var/i in negative_qualities)
			if(T.ever_has_quality(i))
				if(user)
					to_chat(user, SPAN_WARNING("This tool can not accept the modification!"))
				return FALSE

	if((req_fuel_cell & REQ_FUEL) && !T.use_fuel_cost)
		if(user)
			to_chat(user, SPAN_WARNING("This tool does not use fuel!"))
		return FALSE

	if((req_fuel_cell & REQ_CELL) && !T.use_power_cost)
		if(user)
			to_chat(user, SPAN_WARNING("This tool does not use power!"))
		return FALSE

	if((req_fuel_cell & REQ_FUEL_OR_CELL) && (!T.use_power_cost && !T.use_fuel_cost))
		if(user)
			to_chat(user, SPAN_WARNING("This tool does not use [T.use_power_cost?"fuel":"power"]!"))
		return FALSE

	if(tool_upgrades[UPGRADE_SANCTIFY])
		if(SANCTIFIED in T.aspects)
			if(user)
				to_chat(user, SPAN_WARNING("This tool already sanctified!"))
			return FALSE

	if(tool_upgrades[UPGRADE_CELLPLUS])
		if(!(T.suitable_cell == /obj/item/cell/medium || T.suitable_cell == /obj/item/cell/small))
			if(user)
				to_chat(user, SPAN_WARNING("This tool does not require a cell holding upgrade."))
			return FALSE
		if(T.cell)
			if(user)
				to_chat(user, SPAN_WARNING("Remove the cell from the tool first!"))
			return FALSE

	return TRUE

/datum/component/item_upgrade/proc/check_gun(obj/item/gun/G, mob/living/user)
	if(!weapon_upgrades.len)
		if(user)
			to_chat(user, SPAN_WARNING("\The [parent] can not be applied to guns!"))
		return FALSE //Can't be applied to a weapon

	if(G.item_upgrades.len >= G.max_upgrades)
		if(user)
			to_chat(user, SPAN_WARNING("This weapon can't fit anymore modifications!"))
		return FALSE

	for(var/obj/I in G.item_upgrades)
		var/datum/component/item_upgrade/IU = I.GetComponent(/datum/component/item_upgrade)
		if(IU && IU.gun_loc_tag == gun_loc_tag)
			if(user)
				to_chat(user, SPAN_WARNING("There is already something attached to \the [G]'s [gun_loc_tag]!"))
			return FALSE

	for(var/I in req_gun_tags)
		if(!G.gun_tags.Find(I))
			if(user)
				to_chat(user, SPAN_WARNING("\The [G] lacks the following property: [I]"))
			return FALSE

	if((req_fuel_cell & REQ_CELL) && !istype(G, /obj/item/gun/energy))
		if(user)
			to_chat(user, SPAN_WARNING("This weapon does not use power!"))
		return FALSE
	return TRUE

/datum/component/item_upgrade/proc/apply(obj/item/A, mob/living/user)
	if(user)
		user.visible_message(SPAN_NOTICE("[user] starts applying [parent] to [A]"), SPAN_NOTICE("You start applying \the [parent] to \the [A]"))
		var/obj/item/I = parent
		if(!I.use_tool(user = user, target =  A, base_time = WORKTIME_FAST, required_quality = null, fail_chance = FAILCHANCE_ZERO, required_stat = STAT_MEC, forced_sound = WORKSOUND_WRENCHING))
			return FALSE
		to_chat(user, SPAN_NOTICE("You have successfully installed \the [parent] in \the [A]"))
		user.drop_from_inventory(parent)
	//If we get here, we succeeded in the applying
	var/obj/item/I = parent
	I.forceMove(A)
	A.item_upgrades.Add(I)
	RegisterSignal(A, COMSIG_APPVAL, .proc/apply_values)
	RegisterSignal(A, COMSIG_ADDVAL, .proc/add_values)
	A.AddComponent(/datum/component/upgrade_removal)
	A.refresh_upgrades()
	return TRUE

/datum/component/item_upgrade/proc/uninstall(obj/item/I, mob/living/user)
	var/obj/item/P = parent
	I.item_upgrades -= P
	if(destroy_on_removal)
		UnregisterSignal(I, COMSIG_ADDVAL)
		UnregisterSignal(I, COMSIG_APPVAL)
		qdel(P)
		return
	P.forceMove(get_turf(I))
	UnregisterSignal(I, COMSIG_ADDVAL)
	UnregisterSignal(I, COMSIG_APPVAL)

/datum/component/item_upgrade/proc/apply_values(atom/holder)
	if(!holder)
		return
	if(istool(holder))
		apply_values_tool(holder)
	if(isgun(holder))
		apply_values_gun(holder)
	return TRUE

/datum/component/item_upgrade/proc/add_values(atom/holder)
	ASSERT(holder)
	if(isgun(holder))
		add_values_gun(holder)
	return TRUE

/datum/component/item_upgrade/proc/apply_values_tool(obj/item/tool/T)
	if(tool_upgrades[UPGRADE_SANCTIFY])
		T.aspects += list(SANCTIFIED)
	if(tool_upgrades[UPGRADE_PRECISION])
		T.precision += tool_upgrades[UPGRADE_PRECISION]
	if(tool_upgrades[UPGRADE_WORKSPEED])
		T.workspeed += tool_upgrades[UPGRADE_WORKSPEED]
	if(tool_upgrades[UPGRADE_DEGRADATION_MULT])
		T.degradation *= tool_upgrades[UPGRADE_DEGRADATION_MULT]
	if(tool_upgrades[UPGRADE_FORCE_MULT])
		T.force_upgrade_mults += tool_upgrades[UPGRADE_FORCE_MULT] - 1
	if(tool_upgrades[UPGRADE_FORCE_MOD])
		T.force_upgrade_mods += tool_upgrades[UPGRADE_FORCE_MOD]
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
			if(/obj/item/cell/medium)
				T.suitable_cell = /obj/item/cell/large
				prefix = "large-cell"
			if(/obj/item/cell/small)
				T.suitable_cell = /obj/item/cell/medium
	T.force = initial(T.force) * T.force_upgrade_mults + T.force_upgrade_mods
	T.switched_on_force = initial(T.switched_on_force) * T.force_upgrade_mults + T.force_upgrade_mods
	T.prefixes |= prefix

/datum/component/item_upgrade/proc/apply_values_gun(var/obj/item/gun/G)
	if(weapon_upgrades[GUN_UPGRADE_DAMAGE_MULT])
		G.damage_multiplier *= weapon_upgrades[GUN_UPGRADE_DAMAGE_MULT]
	if(weapon_upgrades[GUN_UPGRADE_DAMAGEMOD_PLUS])
		G.damage_multiplier += weapon_upgrades[GUN_UPGRADE_DAMAGEMOD_PLUS]
	if(weapon_upgrades[GUN_UPGRADE_PEN_MULT])
		G.penetration_multiplier *= weapon_upgrades[GUN_UPGRADE_PEN_MULT]
	if(weapon_upgrades[GUN_UPGRADE_PIERC_MULT])
		G.pierce_multiplier += weapon_upgrades[GUN_UPGRADE_PIERC_MULT]
	if(weapon_upgrades[GUN_UPGRADE_STEPDELAY_MULT])
		G.proj_step_multiplier *= weapon_upgrades[GUN_UPGRADE_STEPDELAY_MULT]
	if(weapon_upgrades[GUN_UPGRADE_FIRE_DELAY_MULT])
		G.fire_delay *= weapon_upgrades[GUN_UPGRADE_FIRE_DELAY_MULT]
	if(weapon_upgrades[GUN_UPGRADE_MOVE_DELAY_MULT])
		G.move_delay *= weapon_upgrades[GUN_UPGRADE_MOVE_DELAY_MULT]
	if(weapon_upgrades[GUN_UPGRADE_RECOIL])
		G.recoil_buildup *= weapon_upgrades[GUN_UPGRADE_RECOIL]
	if(weapon_upgrades[GUN_UPGRADE_MUZZLEFLASH])
		G.muzzle_flash *= weapon_upgrades[GUN_UPGRADE_MUZZLEFLASH]
	if(weapon_upgrades[GUN_UPGRADE_SILENCER])
		G.silenced = weapon_upgrades[GUN_UPGRADE_SILENCER]
	if(weapon_upgrades[GUN_UPGRADE_OFFSET])
		G.init_offset = max(0, G.init_offset+weapon_upgrades[GUN_UPGRADE_OFFSET])
	if(weapon_upgrades[GUN_UPGRADE_DAMAGE_BRUTE])
		G.proj_damage_adjust[BRUTE] += weapon_upgrades[GUN_UPGRADE_DAMAGE_BRUTE]
	if(weapon_upgrades[GUN_UPGRADE_DAMAGE_BURN])
		G.proj_damage_adjust[BURN] += weapon_upgrades[GUN_UPGRADE_DAMAGE_BURN]
	if(weapon_upgrades[GUN_UPGRADE_DAMAGE_TOX])
		G.proj_damage_adjust[TOX] += weapon_upgrades[GUN_UPGRADE_DAMAGE_TOX]
	if(weapon_upgrades[GUN_UPGRADE_DAMAGE_OXY])
		G.proj_damage_adjust[OXY] += weapon_upgrades[GUN_UPGRADE_DAMAGE_OXY]
	if(weapon_upgrades[GUN_UPGRADE_DAMAGE_CLONE])
		G.proj_damage_adjust[CLONE] += weapon_upgrades[GUN_UPGRADE_DAMAGE_CLONE]
	if(weapon_upgrades[GUN_UPGRADE_DAMAGE_HALLOSS])
		G.proj_damage_adjust[HALLOSS] += weapon_upgrades[GUN_UPGRADE_DAMAGE_HALLOSS]
	if(weapon_upgrades[GUN_UPGRADE_DAMAGE_RADIATION])
		G.proj_damage_adjust[IRRADIATE] += weapon_upgrades[GUN_UPGRADE_DAMAGE_RADIATION]
	if(weapon_upgrades[GUN_UPGRADE_DAMAGE_PSY])
		G.proj_damage_adjust[PSY] += weapon_upgrades[GUN_UPGRADE_DAMAGE_PSY]
	if(weapon_upgrades[GUN_UPGRADE_HONK])
		G.fire_sound = 'sound/items/bikehorn.ogg'
	if(weapon_upgrades[GUN_UPGRADE_RIGGED])
		G.rigged = TRUE
	if(weapon_upgrades[GUN_UPGRADE_EXPLODE])
		G.rigged = 2
	if(weapon_upgrades[GUN_UPGRADE_ZOOM])
		G.zoom_factor += weapon_upgrades[GUN_UPGRADE_ZOOM]
		G.initialize_scope()
		if(ismob(G.loc))
			var/mob/user = G.loc
			user.update_action_buttons()
	if(weapon_upgrades[GUN_UPGRADE_THERMAL])
		G.vision_flags = SEE_MOBS

	if(weapon_upgrades[GUN_UPGRADE_BAYONET])
		G.attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
		G.sharp = TRUE
	if(weapon_upgrades[GUN_UPGRADE_MELEEDAMAGE])
		G.force += weapon_upgrades[GUN_UPGRADE_MELEEDAMAGE]
	if(weapon_upgrades[GUN_UPGRADE_MELEEPENETRATION])
		G.armor_penetration += weapon_upgrades[GUN_UPGRADE_MELEEPENETRATION]
	if(weapon_upgrades[GUN_UPGRADE_ONEHANDPENALTY])
		G.one_hand_penalty *= weapon_upgrades[GUN_UPGRADE_ONEHANDPENALTY]
	
	if(!isnull(weapon_upgrades[GUN_UPGRADE_FORCESAFETY]))
		G.restrict_safety = TRUE
		G.safety = weapon_upgrades[GUN_UPGRADE_FORCESAFETY]
	if(istype(G, /obj/item/gun/energy))
		var/obj/item/gun/energy/E = G
		if(weapon_upgrades[GUN_UPGRADE_CHARGECOST])
			E.charge_cost *= weapon_upgrades[GUN_UPGRADE_CHARGECOST]
		if(weapon_upgrades[GUN_UPGRADE_OVERCHARGE_MAX])
			E.overcharge_rate *= weapon_upgrades[GUN_UPGRADE_OVERCHARGE_MAX]
		if(weapon_upgrades[GUN_UPGRADE_OVERCHARGE_MAX])
			E.overcharge_max *= weapon_upgrades[GUN_UPGRADE_OVERCHARGE_MAX]
		if(weapon_upgrades[GUN_UPGRADE_AGONY_MULT])
			E.proj_agony_multiplier *= weapon_upgrades[GUN_UPGRADE_AGONY_MULT]

	if(istype(G, /obj/item/gun/projectile))
		var/obj/item/gun/projectile/P = G
		if(weapon_upgrades[GUN_UPGRADE_MAGUP])
			P.max_shells += weapon_upgrades[GUN_UPGRADE_MAGUP]

	for(var/datum/firemode/F in G.firemodes)
		apply_values_firemode(F)

/datum/component/item_upgrade/proc/add_values_gun(obj/item/gun/G)
	if(weapon_upgrades[GUN_UPGRADE_FULLAUTO])
		G.add_firemode(FULL_AUTO_400)

/datum/component/item_upgrade/proc/apply_values_firemode(datum/firemode/F)
	for(var/i in F.settings)
		switch(i)
			if("fire_delay")
				if(weapon_upgrades[GUN_UPGRADE_FIRE_DELAY_MULT])
					F.settings[i] *= weapon_upgrades[GUN_UPGRADE_FIRE_DELAY_MULT]
			if("move_delay")
				if(weapon_upgrades[GUN_UPGRADE_MOVE_DELAY_MULT])
					F.settings[i] *= weapon_upgrades[GUN_UPGRADE_MOVE_DELAY_MULT]

/datum/component/item_upgrade/proc/on_examine(mob/user)
	if(tool_upgrades[UPGRADE_SANCTIFY])
		to_chat(user, SPAN_NOTICE("Does additional burn damage to mutants."))
	if (tool_upgrades[UPGRADE_PRECISION] > 0)
		to_chat(user, SPAN_NOTICE("Enhances precision by [tool_upgrades[UPGRADE_PRECISION]]"))
	else if(tool_upgrades[UPGRADE_PRECISION] < 0)
		to_chat(user, SPAN_WARNING("Reduces precision by [abs(tool_upgrades[UPGRADE_PRECISION])]"))
	if(tool_upgrades[UPGRADE_WORKSPEED])
		to_chat(user, SPAN_NOTICE("Enhances workspeed by [tool_upgrades[UPGRADE_WORKSPEED]*100]%"))

	if(tool_upgrades[UPGRADE_DEGRADATION_MULT])
		if(tool_upgrades[UPGRADE_DEGRADATION_MULT] < 1)
			to_chat(user, SPAN_NOTICE("Reduces tool degradation by [(1-tool_upgrades[UPGRADE_DEGRADATION_MULT])*100]%"))
		else if	(tool_upgrades[UPGRADE_DEGRADATION_MULT] > 1)
			to_chat(user, SPAN_WARNING("Increases tool degradation by [(tool_upgrades[UPGRADE_DEGRADATION_MULT]-1)*100]%"))

	if(tool_upgrades[UPGRADE_FORCE_MULT] >= 1)
		to_chat(user, SPAN_NOTICE("Increases tool damage by [(tool_upgrades[UPGRADE_FORCE_MULT]-1)*100]%"))
	if(tool_upgrades[UPGRADE_FORCE_MOD])
		to_chat(user, SPAN_NOTICE("Increases tool damage by [tool_upgrades[UPGRADE_FORCE_MOD]]"))
	if(tool_upgrades[UPGRADE_POWERCOST_MULT] >= 1)
		to_chat(user, SPAN_WARNING("Modifies power usage by [(tool_upgrades[UPGRADE_POWERCOST_MULT]-1)*100]%"))
	if(tool_upgrades[UPGRADE_FUELCOST_MULT] >= 1)
		to_chat(user, SPAN_WARNING("Modifies fuel usage by [(tool_upgrades[UPGRADE_FUELCOST_MULT]-1)*100]%"))
	if(tool_upgrades[UPGRADE_MAXFUEL])
		to_chat(user, SPAN_NOTICE("Modifies fuel storage by [tool_upgrades[UPGRADE_MAXFUEL]] units."))
	if(tool_upgrades[UPGRADE_BULK])
		to_chat(user, SPAN_WARNING("Increases tool size by [tool_upgrades[UPGRADE_BULK]]"))
	if(tool_upgrades[UPGRADE_MAXUPGRADES])
		to_chat(user, SPAN_NOTICE("Adds [tool_upgrades[UPGRADE_MAXUPGRADES]] additional modification slots."))
	if(required_qualities.len)
		to_chat(user, SPAN_WARNING("Requires a tool with one of the following qualities:"))
		to_chat(user, english_list(required_qualities, and_text = " or "))

	if(weapon_upgrades.len)
		to_chat(user, SPAN_NOTICE("Can be attached to a firearm, giving the following benefits:"))

		if(weapon_upgrades[GUN_UPGRADE_DAMAGE_MULT])
			var/amount = weapon_upgrades[GUN_UPGRADE_DAMAGE_MULT]-1
			if(amount > 0)
				to_chat(user, SPAN_NOTICE("Increases projectile damage by [amount*100]%"))
			else
				to_chat(user, SPAN_WARNING("Decreases projectile damage by [abs(amount*100)]%"))

		if(weapon_upgrades[GUN_UPGRADE_PEN_MULT])
			var/amount = weapon_upgrades[GUN_UPGRADE_PEN_MULT]-1
			if(amount > 0)
				to_chat(user, SPAN_NOTICE("Increases projectile penetration by [amount*100]%"))
			else
				to_chat(user, SPAN_WARNING("Decreases projectile penetration by [abs(amount*100)]%"))

		if(weapon_upgrades[GUN_UPGRADE_PIERC_MULT])
			var/amount = weapon_upgrades[GUN_UPGRADE_PIERC_MULT]
			if(amount > 1)
				to_chat(user, SPAN_NOTICE("Increases projectile piercing penetration by [amount] walls"))
			else if(amount == 1)
				to_chat(user, SPAN_NOTICE("Increases projectile piercing penetration by [amount] wall"))
			else if(amount == -1)
				to_chat(user, SPAN_WARNING("Decreases projectile piercing penetration by [amount] wall"))
			else
				to_chat(user, SPAN_WARNING("Decreases projectile piercing penetration by [amount] walls"))

		if(weapon_upgrades[GUN_UPGRADE_FIRE_DELAY_MULT])
			var/amount = weapon_upgrades[GUN_UPGRADE_FIRE_DELAY_MULT]-1
			if(amount > 0)
				to_chat(user, SPAN_WARNING("Increases fire delay by [amount*100]%"))
			else
				to_chat(user, SPAN_NOTICE("Decreases fire delay by [abs(amount*100)]%"))

		if(weapon_upgrades[GUN_UPGRADE_MOVE_DELAY_MULT])
			var/amount = weapon_upgrades[GUN_UPGRADE_MOVE_DELAY_MULT]-1
			if(amount > 0)
				to_chat(user, SPAN_WARNING("Increases move delay by [amount*100]%"))
			else
				to_chat(user, SPAN_NOTICE("Decreases move delay by [abs(amount*100)]%"))

		if(weapon_upgrades[GUN_UPGRADE_STEPDELAY_MULT])
			var/amount = weapon_upgrades[GUN_UPGRADE_STEPDELAY_MULT]-1
			if(amount > 0)
				to_chat(user, SPAN_WARNING("Slows down the weapons projectile by [amount*100]%"))
			else
				to_chat(user, SPAN_NOTICE("Speeds up the weapons projectile by [abs(amount*100)]%"))

		if(weapon_upgrades[GUN_UPGRADE_DAMAGE_BRUTE])
			to_chat(user, SPAN_NOTICE("Modifies projectile brute damage by [weapon_upgrades[GUN_UPGRADE_DAMAGE_BRUTE]] damage points"))

		if(weapon_upgrades[GUN_UPGRADE_DAMAGE_BURN])
			to_chat(user, SPAN_NOTICE("Modifies projectile burn damage by [weapon_upgrades[GUN_UPGRADE_DAMAGE_BURN]] damage points"))

		if(weapon_upgrades[GUN_UPGRADE_DAMAGE_TOX])
			to_chat(user, SPAN_NOTICE("Modifies projectile toxic damage by [weapon_upgrades[GUN_UPGRADE_DAMAGE_TOX]] damage points"))

		if(weapon_upgrades[GUN_UPGRADE_DAMAGE_OXY])
			to_chat(user, SPAN_NOTICE("Modifies projectile oxy-loss damage by [weapon_upgrades[GUN_UPGRADE_DAMAGE_OXY]] damage points"))

		if(weapon_upgrades[GUN_UPGRADE_DAMAGE_CLONE])
			to_chat(user, SPAN_NOTICE("Modifies projectile clone damage by [weapon_upgrades[GUN_UPGRADE_DAMAGE_CLONE]] damage points"))

		if(weapon_upgrades[GUN_UPGRADE_DAMAGE_HALLOSS])
			to_chat(user, SPAN_NOTICE("Modifies projectile pseudo damage by [weapon_upgrades[GUN_UPGRADE_DAMAGE_HALLOSS]] damage points"))

		if(weapon_upgrades[GUN_UPGRADE_DAMAGE_RADIATION])
			to_chat(user, SPAN_NOTICE("Modifies projectile radiation damage by [weapon_upgrades[GUN_UPGRADE_DAMAGE_RADIATION]] damage points"))

		if(weapon_upgrades[GUN_UPGRADE_DAMAGE_PSY])
			to_chat(user, SPAN_NOTICE("Modifies projectile psy damage by [weapon_upgrades[GUN_UPGRADE_DAMAGE_PSY]] damage points"))

		if(weapon_upgrades[GUN_UPGRADE_RECOIL])
			var/amount = weapon_upgrades[GUN_UPGRADE_RECOIL]-1
			if(amount > 0)
				to_chat(user, SPAN_WARNING("Increases kickback by [amount*100]%"))
			else
				to_chat(user, SPAN_NOTICE("Decreases kickback by [abs(amount*100)]%"))

		if(weapon_upgrades[GUN_UPGRADE_MUZZLEFLASH])
			var/amount = weapon_upgrades[GUN_UPGRADE_MUZZLEFLASH]-1
			if(amount > 0)
				to_chat(user, SPAN_WARNING("Increases muzzle flash by [amount*100]%"))
			else
				to_chat(user, SPAN_NOTICE("Decreases muzzle flash by [abs(amount*100)]%"))

		if(weapon_upgrades[GUN_UPGRADE_MAGUP])
			var/amount = weapon_upgrades[GUN_UPGRADE_MAGUP]
			if(amount > 1)
				to_chat(user, SPAN_NOTICE("Increases internal magazine size by [amount]"))
			else
				to_chat(user, SPAN_WARNING("Decreases internal magazine size by [amount]"))

		if(weapon_upgrades[GUN_UPGRADE_SILENCER] == 1)
			to_chat(user, SPAN_NOTICE("Silences the weapon."))

		if(weapon_upgrades[GUN_UPGRADE_FORCESAFETY] == 0)
			to_chat(user, SPAN_WARNING("Disables the safety toggle of the weapon."))
		else if(weapon_upgrades[GUN_UPGRADE_FORCESAFETY] == 1)
			to_chat(user, SPAN_WARNING("Forces the safety toggle of the weapon to always be on."))

		if(weapon_upgrades[GUN_UPGRADE_CHARGECOST])
			var/amount = weapon_upgrades[GUN_UPGRADE_CHARGECOST]-1
			if(amount > 0)
				to_chat(user, SPAN_WARNING("Increases cell firing cost by [amount*100]%"))
			else
				to_chat(user, SPAN_NOTICE("Decreases cell firing cost by [abs(amount*100)]%"))

		if(weapon_upgrades[GUN_UPGRADE_OVERCHARGE_MAX])
			var/amount = weapon_upgrades[GUN_UPGRADE_OVERCHARGE_MAX]-1
			if(amount > 0)
				to_chat(user, SPAN_WARNING("Increases overcharge maximum by [amount*100]%"))
			else
				to_chat(user, SPAN_NOTICE("Decreases overcharge maximum by [abs(amount*100)]%"))

		if(weapon_upgrades[GUN_UPGRADE_OVERCHARGE_RATE])
			var/amount = weapon_upgrades[GUN_UPGRADE_OVERCHARGE_RATE]-1
			if(amount > 0)
				to_chat(user, SPAN_NOTICE("Increases overcharge rate by [amount*100]%"))
			else
				to_chat(user, SPAN_WARNING("Decreases overcharge rate by [abs(amount*100)]%"))

		if(weapon_upgrades[GUN_UPGRADE_OFFSET])
			var/amount = weapon_upgrades[GUN_UPGRADE_OFFSET]-1
			if(amount > 0)
				to_chat(user, SPAN_WARNING("Increases weapon inaccuracy by [amount*100]%"))
			else
				to_chat(user, SPAN_NOTICE("Decreases weapon inaccuracy by [abs(amount*100)]%"))

		if(weapon_upgrades[GUN_UPGRADE_HONK])
			to_chat(user, SPAN_WARNING("Cheers up the firing sound of the weapon."))

		if(weapon_upgrades[GUN_UPGRADE_RIGGED])
			to_chat(user, SPAN_WARNING("Rigs the weapon to fire back on its user."))

		if(weapon_upgrades[GUN_UPGRADE_EXPLODE])
			to_chat(user, SPAN_WARNING("Rigs the weapon to explode."))

		if(weapon_upgrades[GUN_UPGRADE_ZOOM])
			var/amount = weapon_upgrades[GUN_UPGRADE_ZOOM]
			if(amount > 0)
				to_chat(user, SPAN_NOTICE("Increases scope zoom by x[amount]"))
			else
				to_chat(user, SPAN_WARNING("Decreases scope zoom by x[amount]"))

		to_chat(user, SPAN_WARNING("Requires a weapon with the following properties"))
		to_chat(user, english_list(req_gun_tags))

/datum/component/item_upgrade/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_IATTACK)
	UnregisterSignal(parent, COMSIG_EXAMINE)
	UnregisterSignal(parent, COMSIG_REMOVE)

/datum/component/item_upgrade/PostTransfer()
	return COMPONENT_TRANSFER

/datum/component/upgrade_removal
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/upgrade_removal/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATTACKBY, .proc/attempt_uninstall)

/datum/component/upgrade_removal/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATTACKBY)

/datum/component/upgrade_removal/proc/attempt_uninstall(obj/item/C, mob/living/user)
	if(!isitem(C))
		return 0

	var/obj/item/upgrade_loc = parent

	var/obj/item/tool/T //For dealing damage to the item

	if(istool(upgrade_loc))
		T = upgrade_loc

	ASSERT(istype(upgrade_loc))
	//Removing upgrades from a tool. Very difficult, but passing the check only gets you the perfect result
	//You can also get a lesser success (remove the upgrade but break it in the process) if you fail
	//Using a laser guided stabilised screwdriver is recommended. Precision mods will make this easier
	if(upgrade_loc.item_upgrades.len && C.has_quality(QUALITY_SCREW_DRIVING))
		var/list/possibles = upgrade_loc.item_upgrades.Copy()
		possibles += "Cancel"
		var/obj/item/tool_upgrade/toremove = input("Which upgrade would you like to try to remove? The upgrade will probably be destroyed in the process","Removing Upgrades") in possibles
		if(toremove == "Cancel")
			return 1
		var/datum/component/item_upgrade/IU = toremove.GetComponent(/datum/component/item_upgrade)
		if(IU.removable == FALSE)
			to_chat(user, SPAN_DANGER("\the [toremove] seems to be fused with the [upgrade_loc]"))
		else
			if(C.use_tool(user = user, target =  upgrade_loc, base_time = IU.removal_time, required_quality = QUALITY_SCREW_DRIVING, fail_chance = IU.removal_difficulty, required_stat = STAT_MEC))
				//If you pass the check, then you manage to remove the upgrade intact
				if(!IU.destroy_on_removal && user)
					to_chat(user, SPAN_NOTICE("You successfully remove \the [toremove] while leaving it intact."))
				SEND_SIGNAL(toremove, COMSIG_REMOVE, upgrade_loc)
				upgrade_loc.refresh_upgrades()
				return 1
			else
				//You failed the check, lets see what happens
				if(prob(50))
					//50% chance to break the upgrade and remove it
					to_chat(user, SPAN_DANGER("You successfully remove \the [toremove], but destroy it in the process."))
					SEND_SIGNAL(toremove, COMSIG_REMOVE, parent)
					QDEL_NULL(toremove)
					upgrade_loc.refresh_upgrades()
					user.update_action_buttons()
					return 1
				else if(T && T.degradation) //Because robot tools are unbreakable
					//otherwise, damage the host tool a bit, and give you another try
					to_chat(user, SPAN_DANGER("You only managed to damage \the [upgrade_loc], but you can retry."))
					T.adjustToolHealth(-(5 * T.degradation), user) // inflicting 4 times use damage
					upgrade_loc.refresh_upgrades()
					user.update_action_buttons()
					return 1
	return 0

/obj/item/tool_upgrade
	name = "tool upgrade"
	icon = 'icons/obj/tool_upgrades.dmi'
	force = WEAPON_FORCE_HARMLESS
	w_class = ITEM_SIZE_SMALL
	spawn_tags = SPAWN_TAG_TOOL_UPGRADE
	price_tag = 200
	rarity_value = 15
	bad_type = /obj/item/tool_upgrade

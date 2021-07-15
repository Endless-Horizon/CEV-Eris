// Defining all of this here so it's centralized.
// Used by the exosuit HUD to get a 1-10 value representing charge, ammo, etc.
/obj/item/mech_equipment
	name = "exosuit hardpoint system"
	icon = MECH_EQUIPMENT_ICON
	icon_state = ""
	matter = list(MATERIAL_STEEL = 40)
	force = 10
	bad_type = /obj/item/mech_equipment
	spawn_tags = SPAWN_TAG_MECH_QUIPMENT
	rarity_value = 10
	spawn_frequency = 10

	var/restricted_hardpoints
	var/mob/living/exosuit/owner
	var/list/restricted_software
	var/equipment_delay = 0
	var/active_power_use = 1 KILOWATTS // How much does it consume to perform and accomplish usage
	var/passive_power_use = 0          // For gear that for some reason takes up power even if it's supposedly doing nothing (mech will idly consume power)
	var/mech_layer = MECH_COCKPIT_LAYER //For the part where it's rendered as mech gear

/obj/item/mech_equipment/attack() //Generally it's not desired to be able to attack with items
	return 0

/obj/item/mech_equipment/afterattack(atom/target, mob/living/user, inrange, params)

	if (owner && loc == owner && ((user in owner.pilots) || user == owner))
		if(target in owner.contents)
			return 0
		var/obj/item/cell/C = owner.get_cell()
		if(!(C && C.check_charge(active_power_use * CELLRATE)))
			to_chat(user, SPAN_WARNING("The power indicator flashes briefly as you attempt to use \the [src]"))
			return 0
		return 1
	else
		return 0

/obj/item/mech_equipment/Click()
	. = ..()
	if(usr && (!owner || !usr.incapacitated() && (usr == owner || usr.loc == owner))) attack_self(usr)

/obj/item/mech_equipment/attack_self(var/mob/user)
	if (owner && loc == owner && ((user in owner.pilots) || user == owner))
		var/obj/item/cell/C = owner.get_cell()
		if(!(C && C.check_charge(active_power_use * CELLRATE)))
			to_chat(user, SPAN_WARNING("The power indicator flashes briefly as you attempt to use \the [src]"))
			return 0
		return 1
	else
		return 0

/obj/item/mech_equipment/proc/installed(var/mob/living/exosuit/_owner)
	owner = _owner
	//generally attached. Nothing should be able to grab it
	canremove = FALSE

/obj/item/mech_equipment/proc/uninstalled()
	owner = null
	canremove = TRUE

/obj/item/mech_equipment/Destroy()
	owner = null
	. = ..()

/obj/item/mech_equipment/proc/get_effective_obj()
	return src

/obj/item/mech_equipment/mounted_system
	var/holding_type
	var/obj/item/holding
	bad_type = /obj/item/mech_equipment/mounted_system

/obj/item/mech_equipment/mounted_system/attack_self(var/mob/user)
	. = ..()
	if(. && holding)
		return holding.attack_self(user)

/obj/item/mech_equipment/mounted_system/proc/forget_holding()
	if(holding) //It'd be strange for this to be called with this var unset
		GLOB.destroyed_event.unregister(holding, src, .proc/forget_holding)
		holding = null

/obj/item/mech_equipment/mounted_system/Initialize()
	. = ..()
	if(holding_type)
		holding = new holding_type(src)
		GLOB.destroyed_event.register(holding, src, .proc/forget_holding)
	if(holding)
		if(!icon_state)
			icon = holding.icon
			icon_state = holding.icon_state
		SetName(holding.name)
		desc = "[holding.desc] This one is suitable for installation on an exosuit."


/obj/item/mech_equipment/mounted_system/Destroy()
	if(holding)
		QDEL_NULL(holding)
	. = ..()


/obj/item/mech_equipment/mounted_system/get_effective_obj()
	return (holding ? holding : src)

/obj/item/mech_equipment/mounted_system/get_hardpoint_status_value()
	return (holding ? holding.get_hardpoint_status_value() : null)

/obj/item/mech_equipment/mounted_system/get_hardpoint_maptext()
	return (holding ? holding.get_hardpoint_maptext() : null)

/obj/item/proc/get_hardpoint_status_value()
	return null

/obj/item/proc/get_hardpoint_maptext()
	return null

/obj/item/mech_equipment/mounted_system/get_cell()
	if(owner && loc == owner)
		return owner.get_cell()
	return null

GLOBAL_LIST_EMPTY(wedge_icon_cache)

/obj/machinery/door/airlock
	name = "Airlock"
	icon = 'icons/obj/doors/Doorint.dmi'
	icon_state = "door_closed"
	power_channel = ENVIRON

	explosion_resistance = 10

	var/aiControlDisabled = 0
	//If 1, AI control is disabled until the AI hacks back in and disables the lock.
	//If 2, the AI has bypassed the lock.
	//If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.

	var/hackProof = 0 // if 1, this door can't be hacked by the AI
	var/electrified_until = 0			//World time when the door is no longer electrified. -1 if it is permanently electrified until someone fixes it.
	var/main_power_lost_until = 0	 	//World time when main power is restored.
	var/backup_power_lost_until = -1	//World time when backup power is restored.
	var/next_beep_at = 0				//World time when we may next beep due to doors being blocked by mobs
	var/spawnPowerRestoreRunning = 0

	var/locked = 0
	var/lights = 1 // bolt lights show by default
	var/aiDisabledIdScanner = 0
	var/aiHacking = 0
	var/obj/machinery/door/airlock/closeOther
	var/closeOtherId
	var/lockdownbyai = 0
	autoclose = 1
	var/assembly_type = /obj/structure/door_assembly
	var/mineral
	var/justzap = 0
	var/safe = 1
	normalspeed = 1
	var/obj/item/weapon/electronics/airlock/electronics
	var/hasShocked = 0 //Prevents multiple shocks from happening
	var/secured_wires = 0
	var/datum/wires/airlock/wires
	var/open_sound_powered = 'sound/machines/airlock_open.ogg'
	var/close_sound = 'sound/machines/airlock_close.ogg'
	var/open_sound_unpowered = 'sound/machines/airlock_creaking.ogg'
	var/_wifi_id
	var/datum/wifi/receiver/button/door/wifi_receiver
	var/obj/item/wedged_item

	damage_smoke = TRUE

/obj/machinery/door/airlock/attack_generic(var/mob/user, var/damage)
	if(stat & (BROKEN|NOPOWER))
		if(damage >= 10)
			if(src.density)
				visible_message(SPAN_DANGER("\The [user] forces \the [src] open!"))
				open(1)
			else
				visible_message(SPAN_DANGER("\The [user] forces \the [src] closed!"))
				close(1)
		else
			visible_message("<span class='notice'>\The [user] strains fruitlessly to force \the [src] [density ? "open" : "closed"].</span>")
		return
	..()

/obj/machinery/door/airlock/get_material()
	if(mineral)
		return get_material_by_name(mineral)
	return get_material_by_name(MATERIAL_STEEL)

/obj/machinery/door/airlock/command
	name = "Airlock"
	icon = 'icons/obj/doors/Doorcom.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_com

/obj/machinery/door/airlock/security
	name = "Airlock"
	icon = 'icons/obj/doors/Doorsec.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_sec
	resistance = RESISTANCE_ARMOURED

/obj/machinery/door/airlock/engineering
	name = "Airlock"
	icon = 'icons/obj/doors/Dooreng.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_eng

/obj/machinery/door/airlock/medical
	name = "Airlock"
	icon = 'icons/obj/doors/Doormed.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_med

/obj/machinery/door/airlock/maintenance
	name = "Maintenance Access"
	icon = 'icons/obj/doors/Doormaint.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_mai

/obj/machinery/door/airlock/external
	name = "External Airlock"
	icon = 'icons/obj/doors/Doorext.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_ext
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/glass
	name = "Glass Airlock"
	icon = 'icons/obj/doors/Doorglass.dmi'
	hitsound = 'sound/effects/Glasshit.ogg'
	maxhealth = 300
	resistance = RESISTANCE_AVERAGE
	explosion_resistance = 5
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/centcom
	name = "Airlock"
	icon = 'icons/obj/doors/Doorele.dmi'
	opacity = 1

/obj/machinery/door/airlock/vault
	name = "Vault"
	icon = 'icons/obj/doors/vault.dmi'
	explosion_resistance = RESISTANCE_ARMOURED
	resistance = RESISTANCE_VAULT
	opacity = 1
	secured_wires = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_highsecurity //Until somebody makes better sprites.

/obj/machinery/door/airlock/vault/bolted
	icon_state = "door_locked"
	locked = 1

/obj/machinery/door/airlock/freezer
	name = "Freezer Airlock"
	icon = 'icons/obj/doors/Doorfreezer.dmi'
	opacity = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_fre

/obj/machinery/door/airlock/hatch
	name = "Airtight Hatch"
	icon = 'icons/obj/doors/Doorhatchele.dmi'
	explosion_resistance = RESISTANCE_ARMOURED
	resistance = RESISTANCE_ARMOURED
	opacity = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_hatch

/obj/machinery/door/airlock/maintenance_hatch
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doorhatchmaint2.dmi'
	explosion_resistance = RESISTANCE_ARMOURED
	resistance = RESISTANCE_ARMOURED
	opacity = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_mhatch

/obj/machinery/door/airlock/glass_command
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doorcomglass.dmi'
	hitsound = 'sound/effects/Glasshit.ogg'
	maxhealth = 300
	resistance = RESISTANCE_AVERAGE
	explosion_resistance = 5
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_com
	glass = 1

/obj/machinery/door/airlock/glass_engineering
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doorengglass.dmi'
	hitsound = 'sound/effects/Glasshit.ogg'
	maxhealth = 300
	resistance = RESISTANCE_AVERAGE
	explosion_resistance = 5
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_eng
	glass = 1

/obj/machinery/door/airlock/glass_security
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doorsecglass.dmi'
	hitsound = 'sound/effects/Glasshit.ogg'
	maxhealth = 300
	resistance = RESISTANCE_AVERAGE
	explosion_resistance = 5
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_sec
	glass = 1

/obj/machinery/door/airlock/glass_medical
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doormedglass.dmi'
	hitsound = 'sound/effects/Glasshit.ogg'
	maxhealth = 300
	resistance = RESISTANCE_AVERAGE
	explosion_resistance = 5
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_med
	glass = 1

/obj/machinery/door/airlock/mining
	name = "Mining Airlock"
	icon = 'icons/obj/doors/Doormining.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_min

/obj/machinery/door/airlock/atmos
	name = "Atmospherics Airlock"
	icon = 'icons/obj/doors/Dooratmo.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_atmo

/obj/machinery/door/airlock/research
	name = "Airlock"
	icon = 'icons/obj/doors/Doorresearch.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_research

/obj/machinery/door/airlock/glass_research
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doorresearchglass.dmi'
	hitsound = 'sound/effects/Glasshit.ogg'
	maxhealth = 300
	resistance = RESISTANCE_AVERAGE
	explosion_resistance = 5
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_research
	glass = 1
	heat_proof = 1

/obj/machinery/door/airlock/glass_mining
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doorminingglass.dmi'
	hitsound = 'sound/effects/Glasshit.ogg'
	maxhealth = 300
	resistance = RESISTANCE_AVERAGE
	explosion_resistance = 5
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_min
	glass = 1

/obj/machinery/door/airlock/glass_atmos
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Dooratmoglass.dmi'
	hitsound = 'sound/effects/Glasshit.ogg'
	maxhealth = 300
	resistance = RESISTANCE_AVERAGE
	explosion_resistance = 5
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_atmo
	glass = 1

/* NEW AIRLOCKS BLOCK */

/obj/machinery/door/airlock/maintenance_cargo
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doormaint_cargo.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_maint_cargo

/obj/machinery/door/airlock/maintenance_command
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doormaint_command.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_maint_command

/obj/machinery/door/airlock/maintenance_engineering
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doormaint_engi.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_maint_engi

/obj/machinery/door/airlock/maintenance_medical
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doormaint_med.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_maint_med

/obj/machinery/door/airlock/maintenance_rnd
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doormaint_rnd.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_maint_rnd

/obj/machinery/door/airlock/maintenance_security
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doormaint_sec.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_maint_sec

/obj/machinery/door/airlock/maintenance_common
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doormaint_common.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_maint_common

/obj/machinery/door/airlock/maintenance_interior
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/Doormaint_int.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_maint_int

/* NEW AIRLOCKS BLOCK END */

/obj/machinery/door/airlock/gold
	name = "Gold Airlock"
	icon = 'icons/obj/doors/Doorgold.dmi'
	mineral = MATERIAL_GOLD

/obj/machinery/door/airlock/silver
	name = "Silver Airlock"
	icon = 'icons/obj/doors/Doorsilver.dmi'
	mineral = MATERIAL_SILVER

/obj/machinery/door/airlock/diamond
	name = "Diamond Airlock"
	icon = 'icons/obj/doors/Doordiamond.dmi'
	mineral = MATERIAL_DIAMOND
	resistance = RESISTANCE_UNBREAKABLE

/obj/machinery/door/airlock/uranium
	name = "Uranium Airlock"
	desc = "And they said I was crazy."
	icon = 'icons/obj/doors/Dooruranium.dmi'
	mineral = MATERIAL_URANIUM
	var/last_event = 0

/obj/machinery/door/airlock/Process()
	// Deliberate no call to parent.
	if(main_power_lost_until > 0 && world.time >= main_power_lost_until)
		regainMainPower()

	if(backup_power_lost_until > 0 && world.time >= backup_power_lost_until)
		regainBackupPower()

	else if(electrified_until > 0 && world.time >= electrified_until)
		electrify(0)

	..()

/obj/machinery/door/airlock/uranium/Process()
	if(world.time > last_event+20)
		if(prob(50))
			radiate()
		last_event = world.time
	..()

/obj/machinery/door/airlock/uranium/proc/radiate()
	for(var/mob/living/L in range (3,src))
		L.apply_effect(15,IRRADIATE,0)
	return

/obj/machinery/door/airlock/plasma
	name = "Plasma Airlock"
	desc = "No way this can end badly."
	icon = 'icons/obj/doors/Doorplasma.dmi'
	mineral = "plasma"

/obj/machinery/door/airlock/plasma/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/PlasmaBurn(temperature)
	for(var/turf/simulated/floor/target_tile in RANGE_TURFS(2,loc))
		target_tile.assume_gas("plasma", 35, 400+T0C)
		spawn (0) target_tile.hotspot_expose(temperature, 400)
	for(var/turf/simulated/wall/W in RANGE_TURFS(3,src))
		W.burn((temperature/4))//Added so that you can't set off a massive chain reaction with a small flame
	for(var/obj/machinery/door/airlock/plasma/D in range(3,src))
		D.ignite(temperature/4)
	new/obj/structure/door_assembly( src.loc )
	qdel(src)

/obj/machinery/door/airlock/sandstone
	name = "Sandstone Airlock"
	icon = 'icons/obj/doors/Doorsand.dmi'
	mineral = MATERIAL_SANDSTONE

/obj/machinery/door/airlock/science
	name = "Airlock"
	icon = 'icons/obj/doors/Doorsci.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_science

/obj/machinery/door/airlock/glass_science
	name = "Glass Airlocks"
	icon = 'icons/obj/doors/Doorsciglass.dmi'
	maxhealth = 300
	resistance = RESISTANCE_AVERAGE
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_science
	glass = 1

/obj/machinery/door/airlock/highsecurity
	name = "Secure Airlock"
	icon = 'icons/obj/doors/hightechsecurity.dmi'
	explosion_resistance = 20
	resistance = RESISTANCE_ARMOURED
	secured_wires = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_highsecurity

/*
About the new airlock wires panel:
*An airlock wire dialog can be accessed by the normal way or by using wirecutters or a multitool on the door while the wire-panel is open.
This would show the following wires, which you can either wirecut/mend or send a multitool pulse through.
There are 9 wires.
*	one wire from the ID scanner.
		Sending a pulse through this flashes the red light on the door (if the door has power).
		If you cut this wire, the door will stop recognizing valid IDs.
		(If the door has 0000 access, it still opens and closes, though)
*	two wires for power.
		Sending a pulse through either one causes a breaker to trip,
		disabling the door for 10 seconds if backup power is connected,
		or 1 minute if not (or until backup power comes back on, whichever is shorter).
		Cutting either one disables the main door power, but unless backup power is also cut,
		the backup power re-powers the door in 10 seconds.
		While unpowered, the door may be open, but bolts-raising will not work.
		Cutting these wires may electrocute the user.
*	one wire for door bolts.
		Sending a pulse through this drops door bolts (whether the door is powered or not) or raises them (if it is).
		Cutting this wire also drops the door bolts, and mending it does not raise them. If the wire is cut, trying to raise the door bolts will not work.
*	two wires for backup power.
		Sending a pulse through either one causes a breaker to trip,
		but this does not disable it unless main power is down too
		(in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter).
		Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
*	one wire for opening the door.
		Sending a pulse through this while the door has power makes it open the door if no access is required.
*	one wire for AI control.
		Sending a pulse through this blocks AI control for a second or so (which is enough to see the AI control light on the panel dialog go off and back on again).
		Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute).
		If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
*	one wire for electrifying the door.
		Sending a pulse through this electrifies the door for 30 seconds.
		Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted.
		(Currently it is also STAYING electrified until someone mends the wire)
*	one wire for controling door safetys.
		When active, door does not close on someone.  When cut, door will ruin someone's shit.
		When pulsed, door will immedately ruin someone's shit.
*	one wire for controlling door speed.
		When active, dor closes at normal rate.  When cut, door does not close manually.
		When pulsed, door attempts to close every tick.
*/



/obj/machinery/door/airlock/bumpopen(mob/living/user) //Airlocks now zap you when you 'bump' them open when they're electrified. --NeoFite
	if(!issilicon(usr))
		if(src.isElectrified())
			if(!src.justzap)
				if(src.shock(user, 100))
					src.justzap = 1
					spawn (10)
						src.justzap = 0
					return
			else /*if(src.justzap)*/
				return
		else if(prob(10) && src.operating == 0)
			var/mob/living/carbon/C = user
			if(istype(C) && C.hallucination_power > 25)
				to_chat(user, "<span class='danger'>You feel a powerful shock course through your body!</span>")
				user.adjustHalLoss(10)
				user.Stun(10)
				return
	..()

/obj/machinery/door/airlock/proc/isElectrified()
	if(src.electrified_until != 0)
		return 1
	return 0

/obj/machinery/door/airlock/proc/isWireCut(var/wireIndex)
	// You can find the wires in the datum folder.
	return wires.IsIndexCut(wireIndex)

/obj/machinery/door/airlock/proc/canAIControl()
	return ((src.aiControlDisabled!=1) && (!src.isAllPowerLoss()));

/obj/machinery/door/airlock/proc/canAIHack()
	return ((src.aiControlDisabled==1) && (!hackProof) && (!src.isAllPowerLoss()));

/obj/machinery/door/airlock/proc/arePowerSystemsOn()
	if (stat & (NOPOWER|BROKEN))
		return 0
	return (src.main_power_lost_until==0 || src.backup_power_lost_until==0)

/obj/machinery/door/airlock/requiresID()
	return !(src.isWireCut(AIRLOCK_WIRE_IDSCAN) || aiDisabledIdScanner)

/obj/machinery/door/airlock/proc/isAllPowerLoss()
	if(stat & (NOPOWER|BROKEN))
		return 1
	if(mainPowerCablesCut() && backupPowerCablesCut())
		return 1
	return 0

/obj/machinery/door/airlock/proc/mainPowerCablesCut()
	return src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1) || src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)

/obj/machinery/door/airlock/proc/backupPowerCablesCut()
	return src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1) || src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)

/obj/machinery/door/airlock/proc/loseMainPower()
	main_power_lost_until = mainPowerCablesCut() ? -1 : world.time + SecondsToTicks(60)

	// If backup power is permanently disabled then activate in 10 seconds if possible, otherwise it's already enabled or a timer is already running
	if(backup_power_lost_until == -1 && !backupPowerCablesCut())
		backup_power_lost_until = world.time + SecondsToTicks(10)

	// Disable electricity if required
	if(electrified_until && isAllPowerLoss())
		electrify(0)

/obj/machinery/door/airlock/proc/loseBackupPower()
	backup_power_lost_until = backupPowerCablesCut() ? -1 : world.time + SecondsToTicks(60)

	// Disable electricity if required
	if(electrified_until && isAllPowerLoss())
		electrify(0)

/obj/machinery/door/airlock/proc/regainMainPower()
	if(!mainPowerCablesCut())
		main_power_lost_until = 0
		// If backup power is currently active then disable, otherwise let it count down and disable itself later
		if(!backup_power_lost_until)
			backup_power_lost_until = -1

/obj/machinery/door/airlock/proc/regainBackupPower()
	if(!backupPowerCablesCut())
		// Restore backup power only if main power is offline, otherwise permanently disable
		backup_power_lost_until = main_power_lost_until == 0 ? -1 : 0

/obj/machinery/door/airlock/proc/electrify(var/duration, var/feedback = 0)
	var/message = ""
	if(isWireCut(AIRLOCK_WIRE_ELECTRIFY) && arePowerSystemsOn())
		message = text("The electrification wire is cut - Door permanently electrified.")
		electrified_until = -1
	else if(duration && !arePowerSystemsOn())
		message = text("The door is unpowered - Cannot electrify the door.")
		electrified_until = 0
	else if(!duration && electrified_until != 0)
		message = "The door is now un-electrified."
		electrified_until = 0
	else if(duration)	//electrify door for the given duration seconds
		if(usr)
			shockedby += text("\[[time_stamp()]\] - [usr](ckey:[usr.ckey])")
			usr.attack_log += text("\[[time_stamp()]\] <font color='red'>Electrified the [name] at [x] [y] [z]</font>")
		else
			shockedby += text("\[[time_stamp()]\] - EMP)")
		message = "The door is now electrified [duration == -1 ? "permanently" : "for [duration] second\s"]."
		electrified_until = duration == -1 ? -1 : world.time + SecondsToTicks(duration)

	if(feedback && message)
		to_chat(usr, message)

/obj/machinery/door/airlock/proc/set_idscan(var/activate, var/feedback = 0)
	var/message = ""
	if(isWireCut(AIRLOCK_WIRE_IDSCAN))
		message = "The IdScan wire is cut - IdScan feature permanently disabled."
	else if(activate && aiDisabledIdScanner)
		aiDisabledIdScanner = 0
		message = "IdScan feature has been enabled."
	else if(!activate && !aiDisabledIdScanner)
		aiDisabledIdScanner = 1
		message = "IdScan feature has been disabled."

	if(feedback && message)
		to_chat(usr, message)

/obj/machinery/door/airlock/proc/set_safeties(var/activate, var/feedback = 0)
	var/message = ""
	// Safeties!  We don't need no stinking safeties!
	if (isWireCut(AIRLOCK_WIRE_SAFETY))
		message = text("The safety wire is cut - Cannot enable safeties.")
	else if (!activate && safe)
		safe = 0
	else if (activate && !safe)
		safe = 1

	if(feedback && message)
		to_chat(usr, message)

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise
// The preceding comment was borrowed from the grille's shock script
/obj/machinery/door/airlock/shock(mob/user, prb)
	if(!arePowerSystemsOn())
		return 0
	if(hasShocked)
		return 0	//Already shocked someone recently?
	if(..())
		hasShocked = 1
		sleep(10)
		hasShocked = 0
		return 1
	else
		return 0

/obj/machinery/door/airlock/proc/force_wedge_item(obj/item/weapon/tool/T)
	T.forceMove(src)
	wedged_item = T
	update_icon()
	verbs -= /obj/machinery/door/airlock/proc/try_wedge_item
	verbs += /obj/machinery/door/airlock/proc/take_out_wedged_item

/obj/machinery/door/airlock/proc/try_wedge_item()
	set name = "Wedge item"
	set category = "Object"
	set src in view(1)

	if(!isliving(usr))
		to_chat(usr, SPAN_WARNING("You can't do this."))
		return
	var/obj/item/weapon/tool/T = usr.get_active_hand()
	if(istype(T) && T.w_class >= ITEM_SIZE_NORMAL) // We do the checks before proc call, because see "proc overhead".
		if(!density)
			usr.drop_item()
			force_wedge_item(T)
			to_chat(usr, SPAN_NOTICE("You wedge [T] into [src]."))
		else
			to_chat(usr, SPAN_NOTICE("[T] can't be wedged into [src], while [src] is open."))

/obj/machinery/door/airlock/proc/take_out_wedged_item()
	set name = "Remove Blockage"
	set category = "Object"
	set src in view(1)

	if(!isliving(usr) || !CanUseTopic(usr))
		return

	if(wedged_item)
		wedged_item.forceMove(drop_location())
		if(usr)
			usr.put_in_hands(wedged_item)
			to_chat(usr, SPAN_NOTICE("You took [wedged_item] out of [src]."))
		wedged_item = null
		verbs -= /obj/machinery/door/airlock/proc/take_out_wedged_item
		verbs += /obj/machinery/door/airlock/proc/try_wedge_item
		update_icon()

/obj/machinery/door/airlock/AltClick(mob/user)
	if(Adjacent(user))
		wedged_item ? take_out_wedged_item() : try_wedge_item()

/obj/machinery/door/airlock/MouseDrop(obj/over_object)
	if(ishuman(usr) && usr == over_object && !usr.incapacitated() && Adjacent(usr))
		take_out_wedged_item(usr)
		return
	return ..()

/obj/machinery/door/airlock/examine(mob/user)
	..()
	if(wedged_item)
		to_chat(user, "You can see \icon[wedged_item] [wedged_item] wedged into it.")

/obj/machinery/door/airlock/proc/generate_wedge_overlay()
	var/cache_string = "[wedged_item.icon]||[wedged_item.icon_state]||[wedged_item.overlays.len]||[wedged_item.underlays.len]"

	if(!GLOB.wedge_icon_cache[cache_string])
		var/icon/I = getFlatIcon(wedged_item, SOUTH, always_use_defdir = TRUE)

		// #define COOL_LOOKING_SHIFT_USING_CROWBAR_RIGHT 14, #define COOL_LOOKING_SHIFT_USING_CROWBAR_DOWN 6 - throw a rock at me if this looks less magic.
		I.Shift(SOUTH, 6) // These numbers I got by sticking the crowbar in and looking what will look good.
		I.Shift(EAST, 14)
		I.Turn(45)

		GLOB.wedge_icon_cache[cache_string] = I
		underlays += I
	else
		underlays += GLOB.wedge_icon_cache[cache_string]

/obj/machinery/door/airlock/on_update_icon()
	set_light(0)
	if(overlays.len)
		cut_overlays()
	if(underlays.len)
		underlays.Cut()
	if(density)
		if(locked && lights && arePowerSystemsOn())
			SetIconState("door_locked")
			set_light(1.5, 0.5, COLOR_RED_LIGHT)
		else
			SetIconState("door_closed")
		if(p_open || welded)
			set_overlays(list())
			if(p_open)
				add_overlays(image(icon, "panel_open"))
			if (!(stat & NOPOWER))
				if(stat & BROKEN)
					add_overlays(image(icon, "sparks_broken"))
				else if (health < maxhealth * 3/4)
					add_overlays(image(icon, "sparks_damaged"))
			if(welded)
				add_overlays(image(icon, "welded"))
		else if (health < maxhealth * 3/4 && !(stat & NOPOWER))
			add_overlays(image(icon, "sparks_damaged"))
	else
		SetIconState("door_open")
		if((stat & BROKEN) && !(stat & NOPOWER))
			add_overlays(image(icon, "sparks_open"))
	if(wedged_item)
		generate_wedge_overlay()

/obj/machinery/door/airlock/do_animate(animation)
	switch(animation)
		if("opening")
			if(overlays.len)
				cut_overlays()
			if(p_open)
				flicker("o_door_opening")
			else
				flicker("door_opening")
			update_icon()
		if("closing")
			if(overlays.len)
				cut_overlays()
			if(p_open)
				flicker("o_door_closing")
			else
				flicker("door_closing")
			update_icon()
		if("spark")
			if(density)
				flicker("door_spark")
		if("deny")
			if(density && arePowerSystemsOn())
				flicker("door_deny")
				playsound(loc, 'sound/machines/Custom_deny.ogg', 50, 1, -2)
	return

/obj/machinery/door/airlock/attack_ai(mob/user as mob)
	if(!isblitzshell(user))
		nano_ui_interact(user)

/obj/machinery/door/airlock/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS, var/datum/topic_state/state = GLOB.default_state)
	var/data[0]

	data["main_power_loss"]		= round(main_power_lost_until 	> 0 ? max(main_power_lost_until - world.time,	0) / 10 : main_power_lost_until,	1)
	data["backup_power_loss"]	= round(backup_power_lost_until	> 0 ? max(backup_power_lost_until - world.time,	0) / 10 : backup_power_lost_until,	1)
	data["electrified"] 		= round(electrified_until		> 0 ? max(electrified_until - world.time, 	0) / 10 	: electrified_until,		1)
	data["open"] = !density

	var/commands[0]
	commands[++commands.len] = list(
		"name" = "IdScan",
		"command" = "idscan",
		"active" = !aiDisabledIdScanner,
		"enabled" = "Enabled",
		"disabled" = "Disable",
		"danger" = 0,
		"act" = 1
	)
	commands[++commands.len] = list(
		"name" = "Bolts",
		"command" = "bolts",
		"active" = !locked,
		"enabled" = "Raised ",
		"disabled" = "Dropped",
		"danger" = 0,
		"act" = 0
	)
	commands[++commands.len] = list(
		"name" = "Bolt Lights",
		"command" = "lights",
		"active" = lights,
		"enabled" = "Enabled",
		"disabled" = "Disable",
		"danger" = 0,
		"act" = 1
	)
	commands[++commands.len] = list(
		"name" = "Safeties",
		"command"= "safeties",
		"active" = safe,
		"enabled" = "Nominal",
		"disabled" = "Overridden",
		"danger" = 1,
		"act" = 0
	)
	commands[++commands.len] = list(
		"name" = "Timing",
		"command" = "timing",
		"active" = normalspeed,
		"enabled" = "Nominal",
		"disabled" = "Overridden",
		"danger" = 1,
		"act" = 0
	)
	commands[++commands.len] = list(
		"name" = "Door State",
		"command" = "open",
		"active" = density,
		"enabled" = "Closed",
		"disabled" = "Opened",
		"danger" = 0,
		"act" = 0
	)

	data["commands"] = commands

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "door_control.tmpl", "Door Controls", 450, 350, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/door/airlock/proc/hack(mob/user as mob)
	if(aiHacking == 0)
		aiHacking = 1
		spawn(20)
			//TODO: Make this take a minute
			to_chat(user, "Airlock AI control has been blocked. Beginning fault-detection.")
			sleep(50)
			if(canAIControl())
				to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
				aiHacking = 0
				return
			else if(!canAIHack(user))
				to_chat(user, "We've lost our connection! Unable to hack airlock.")
				aiHacking = 0
				return
			to_chat(user, "Fault confirmed: airlock control wire disabled or cut.")
			sleep(20)
			to_chat(user, "Attempting to hack into airlock. This may take some time.")
			sleep(200)
			if(canAIControl())
				to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
				aiHacking = 0
				return
			else if(!canAIHack(user))
				to_chat(user, "We've lost our connection! Unable to hack airlock.")
				aiHacking = 0
				return
			to_chat(user, "Upload access confirmed. Loading control program into airlock software.")
			sleep(170)
			if(canAIControl())
				to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
				aiHacking = 0
				return
			else if(!canAIHack(user))
				to_chat(user, "We've lost our connection! Unable to hack airlock.")
				aiHacking = 0
				return
			to_chat(user, "Transfer complete. Forcing airlock to execute program.")
			sleep(50)
			//disable blocked control
			aiControlDisabled = 2
			to_chat(user, "Receiving control information from airlock.")
			sleep(10)
			//bring up airlock dialog
			aiHacking = 0
			if(user)
				attack_ai(user)

/obj/machinery/door/airlock/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(isElectrified())
		if(istype(mover, /obj/item))
			var/obj/item/i = mover
			if(i.matter && (MATERIAL_STEEL in i.matter) && i.matter[MATERIAL_STEEL] > 0)
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
	return ..()

/obj/machinery/door/airlock/attack_hand(mob/user as mob)
	if(!issilicon(usr) && isElectrified() && shock(user, 100))
		return

	// No. -- cib
	/**
	if(ishuman(user) && prob(40) && density)
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60)
			playsound(loc, 'sound/effects/bang.ogg', 25, 1)
			if(!istype(H.head, /obj/item/clothing/head/armor/helmet))
				visible_message(SPAN_WARNING("[user] headbutts the airlock."))
				var/obj/item/organ/external/affecting = H.get_organ(BP_HEAD)
				H.Stun(8)
				H.Weaken(5)
				if(affecting.take_damage(10, 0))
					H.UpdateDamageIcon()
			else
				visible_message(SPAN_WARNING("[user] headbutts the airlock. Good thing they're wearing a helmet."))
			return
	**/

	if(user.a_intent == I_GRAB && wedged_item && !user.get_active_hand())
		take_out_wedged_item(user)
		return

	if(p_open)
		user.set_machine(src)
		wires.Interact(user)
	else
		..(user)
	return

/obj/machinery/door/airlock/CanUseTopic(var/mob/user)
	if(operating < 0) //emagged
		to_chat(user, SPAN_WARNING("Unable to interface: Internal error."))
		return STATUS_CLOSE
	if(issilicon(user) && !canAIControl())
		if(canAIHack(user))
			hack(user)
		else
			if (isAllPowerLoss()) //don't really like how this gets checked a second time, but not sure how else to do it.
				to_chat(user, SPAN_WARNING("Unable to interface: Connection timed out."))
			else
				to_chat(user, SPAN_WARNING("Unable to interface: Connection refused."))
		return STATUS_CLOSE

	return ..()

/obj/machinery/door/airlock/Topic(href, href_list)
	if(..())
		return 1

	var/activate = text2num(href_list["activate"])
	switch (href_list["command"])
		if("idscan")
			set_idscan(activate, 1)
		if("main_power")
			if(!main_power_lost_until)
				loseMainPower()
		if("backup_power")
			if(!backup_power_lost_until)
				loseBackupPower()
		if("bolts")
			if(isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
				to_chat(usr, "The door bolt control wire is cut - Door bolts permanently dropped.")
			else if(activate && lock())
				to_chat(usr, "The door bolts have been dropped.")
			else if(!activate && unlock())
				to_chat(usr, "The door bolts have been raised.")
		if("electrify_temporary")
			electrify(30 * activate, 1)
		if("electrify_permanently")
			electrify(-1 * activate, 1)
		if("open")
			if(welded)
				to_chat(usr, text("The airlock has been welded shut!"))
			else if(locked)
				to_chat(usr, text("The door bolts are down!"))
			else if(activate && density)
				open()
			else if(!activate && !density)
				close()
		if("safeties")
			set_safeties(!activate, 1)
		if("timing")
			// Door speed control
			if(isWireCut(AIRLOCK_WIRE_SPEED))
				to_chat(usr, text("The timing wire is cut - Cannot alter timing."))
			else if (activate && normalspeed)
				normalspeed = 0
			else if (!activate && !normalspeed)
				normalspeed = 1
		if("lights")
			// Bolt lights
			if(isWireCut(AIRLOCK_WIRE_LIGHT))
				to_chat(usr, "The bolt lights wire is cut - The door bolt lights are permanently disabled.")
			else if (!activate && lights)
				lights = 0
				to_chat(usr, "The door bolt lights have been disabled.")
			else if (activate && !lights)
				lights = 1
				to_chat(usr, "The door bolt lights have been enabled.")

	update_icon()
	return 1

/obj/machinery/door/airlock/attackby(obj/item/I, mob/user)
	if(!issilicon(usr))
		if(isElectrified())
			if(shock(user, 75))
				return
	if(istype(I, /obj/item/taperoll))
		return
	add_fingerprint(user)

	//Harm intent overrides other actions
	if(density && user.a_intent == I_HURT && !I.GetIdCard())
		hit(user, I)
		return

	var/tool_type = I.get_tool_type(user, list(QUALITY_PRYING, QUALITY_SCREW_DRIVING, QUALITY_WELDING), src)
	switch(tool_type)
		if(QUALITY_PRYING)
			if(!repairing)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_VERY_EASY,  required_stat = list(STAT_MEC, STAT_ROB)))
					if(p_open && (operating < 0 || (!operating && welded && !arePowerSystemsOn() && density && (!locked || (stat & BROKEN)))) )
						to_chat(user, SPAN_NOTICE("You removed the airlock electronics!"))

						var/obj/structure/door_assembly/da = new assembly_type(loc)
						if (istype(da, /obj/structure/door_assembly/multi_tile))
							da.set_dir(dir)

		 				da.anchored = TRUE
						if(mineral)
							da.glass = mineral
						else if(glass && !da.glass)
							da.glass = 1
						da.state = 1
						da.created_name = name
						da.update_state()

						if(operating == -1 || (stat & BROKEN))
							new /obj/item/weapon/electronics/circuitboard/broken(loc)
							operating = 0
						else
							if (!electronics) create_electronics()

							electronics.loc = loc
							electronics = null

						qdel(src)
						return
					else if(arePowerSystemsOn())
						to_chat(user, SPAN_NOTICE("The airlock's motors resist your efforts to force it."))
					else if(locked)
						to_chat(user, SPAN_NOTICE("The airlock's bolts prevent it from being forced."))
					else
						if(density)
							spawn(0)	open(I)
						else
							spawn(0)	close(I)
			else
				..()
			return

		if(QUALITY_SCREW_DRIVING)
			var/used_sound = p_open ? 'sound/machines/Custom_screwdriveropen.ogg' :  'sound/machines/Custom_screwdriverclose.ogg'
			if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC, instant_finish_tier = 30, forced_sound = used_sound))
				if (p_open)
					if (stat & BROKEN)
						to_chat(usr, SPAN_WARNING("The panel is broken and cannot be closed."))
					else
						p_open = 0
				else
					p_open = 1
				update_icon()
			return

		if(QUALITY_WELDING)
			if(!repairing && !(operating > 0) && density)
				if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					if(!welded)
						welded = 1
					else
						welded = null
					update_icon()
			else
				..()
			return

		if(ABORT_CHECK)
			return

	if(istool(I))
		return attack_hand(user)
	else if(istype(I, /obj/item/device/assembly/signaler))
		return attack_hand(user)
	else if(istype(I, /obj/item/weapon/pai_cable))	// -- TLE
		var/obj/item/weapon/pai_cable/cable = I
		cable.plugin(src, user)

	else
		..()
	return

/obj/machinery/door/airlock/plasma/attackby(C as obj, mob/user)
	if(C)
		ignite(is_hot(C))
	..()

/obj/machinery/door/airlock/set_broken()
	p_open = 1
	stat |= BROKEN

	//If the door has been violently smashed open
	if (health <= 0)
		visible_message("<span class = 'warning'>\The [name] breaks open!</span>")
		unlock() //Then it is open
		open(TRUE)
	else if (secured_wires)
		lock()

	for (var/mob/O in viewers(src, null))
		if ((O.client && !( O.blinded )))
			O.show_message("[name]'s control panel bursts open, sparks spewing out!")

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()

	update_icon()
	return

/obj/machinery/door/airlock/open(forced=0)
	if(!can_open(forced))
		return 0
	use_power(360)	//360 W seems much more appropriate for an actuator moving an industrial door capable of crushing people

	//if the door is unpowered then it doesn't make sense to hear the woosh of a pneumatic actuator
	if(arePowerSystemsOn())
		playsound(loc, open_sound_powered, 70, 1, -2)
	else
		var/obj/item/weapon/tool/T = forced
		if (istype(T) && T.item_flags & SILENT)
			playsound(loc, open_sound_unpowered, 3, 1, -5) //Silenced tools can force open airlocks silently
		else if (istype(T) && T.item_flags & LOUD)
			playsound(loc, open_sound_unpowered, 500, 1, 10) //Loud tools can force open airlocks LOUDLY
		else
			playsound(loc, open_sound_unpowered, 70, 1, -1)

	var/obj/item/weapon/tool/T = forced
	if (istype(T) && T.item_flags & HONKING)
		playsound(loc, WORKSOUND_HONK, 70, 1, -2)

	if(closeOther != null && istype(closeOther, /obj/machinery/door/airlock/) && !closeOther.density)
		closeOther.close()
	return ..()

/obj/machinery/door/airlock/can_open(forced=0)
	if(!forced && (!arePowerSystemsOn() || isWireCut(AIRLOCK_WIRE_OPEN_DOOR)) || locked || welded)
		return FALSE

	return ..()

/obj/machinery/door/airlock/can_close(forced=0)
	if(locked || welded)
		return FALSE

	if(wedged_item)
		shake_animation(12)
		wedged_item.airlock_crush(DOOR_CRUSH_DAMAGE)
		return FALSE

	if(!forced && (!arePowerSystemsOn() || isWireCut(AIRLOCK_WIRE_OPEN_DOOR)))
		return FALSE

	return ..()

/atom/movable/proc/blocks_airlock()
	return density

/obj/machinery/door/blocks_airlock()
	return FALSE

/obj/structure/window/blocks_airlock()
	return FALSE

/obj/machinery/mech_sensor/blocks_airlock()
	return FALSE

/mob/living/blocks_airlock()
	return TRUE

/mob/living/simple_animal/blocks_airlock() //Airlocks crush cockroahes and mouses.
	return mob_size > MOB_SMALL

/atom/movable/proc/airlock_crush(crush_damage)
	return FALSE

/obj/structure/window/airlock_crush(crush_damage)
	ex_act(2)//Smashin windows

/obj/machinery/portable_atmospherics/canister/airlock_crush(crush_damage)
	. = ..()
	health -= crush_damage
	healthcheck()

/obj/structure/closet/airlock_crush(var/crush_damage)
	..()
	damage(crush_damage)
	for(var/atom/movable/AM in src)
		AM.airlock_crush()
	return TRUE

/obj/item/weapon/tool/airlock_crush(crush_damage)
	. = ..()
	health += crush_damage * degradation * (1 - get_tool_quality(QUALITY_PRYING) * 0.01) * 0.4

/mob/living/airlock_crush(var/crush_damage)
	. = ..()

	damage_through_armor(0.2 * crush_damage, BRUTE, BP_HEAD, ARMOR_MELEE)
	damage_through_armor(0.4 * crush_damage, BRUTE, BP_CHEST, ARMOR_MELEE)
	damage_through_armor(0.1 * crush_damage, BRUTE, BP_L_LEG, ARMOR_MELEE)
	damage_through_armor(0.1 * crush_damage, BRUTE, BP_R_LEG, ARMOR_MELEE)
	damage_through_armor(0.1 * crush_damage, BRUTE, BP_L_ARM, ARMOR_MELEE)
	damage_through_armor(0.1 * crush_damage, BRUTE, BP_R_ARM, ARMOR_MELEE)

	SetStunned(5)
	SetWeakened(5)
	var/turf/T = get_turf(src)
	T.add_blood(src)

/mob/living/carbon/airlock_crush(var/crush_damage)
	. = ..()
	if (!(species && (species.flags & NO_PAIN)))
		emote("scream")

/mob/living/silicon/robot/airlock_crush(var/crush_damage)
	adjustBruteLoss(crush_damage)
	return 0

/obj/machinery/door/airlock/close(var/forced=0)
	if(!can_close(forced))
		return 0

	if(safe)
		for(var/turf/turf in locs)
			for(var/atom/movable/AM in turf)
				if(AM.blocks_airlock())
					if(world.time > next_beep_at)
						playsound(loc, 'sound/machines/buzz-two.ogg', 30, 1, -1)
						next_beep_at = world.time + SecondsToTicks(10)
					close_door_at = world.time + 6
					return
				if(istool(AM))
					var/obj/item/weapon/tool/T = AM
					if(T.w_class >= ITEM_SIZE_NORMAL)
						operating = TRUE
						density = TRUE
						do_animate("closing")
						sleep(7)
						force_wedge_item(AM)
						playsound(loc, 'sound/machines/airlock_creaking.ogg', 75, 1)
						shake_animation(12)
						sleep(7)
						playsound(loc, 'sound/machines/buzz-two.ogg', 30, 1, -1)
						density = FALSE
						do_animate("opening")
						operating = FALSE
						return

	for(var/turf/turf in locs)
		for(var/atom/movable/AM in turf)
			if(AM.airlock_crush(DOOR_CRUSH_DAMAGE))
				take_damage(DOOR_CRUSH_DAMAGE)

	use_power(360)	//360 W seems much more appropriate for an actuator moving an industrial door capable of crushing people
	if(arePowerSystemsOn())
		playsound(src.loc, close_sound, 70, 1, -2)
	else
		var/obj/item/weapon/tool/T = forced
		if (istype(T) && T.item_flags & SILENT)
			playsound(src.loc, open_sound_unpowered, 3, 1, -5) //Silenced tools can force airlocks silently
		else if (istype(T) && T.item_flags & LOUD)
			playsound(src.loc, open_sound_unpowered, 500, 1, 10) //Loud tools can force open airlocks LOUDLY
		else
			playsound(src.loc, open_sound_unpowered, 70, 1, -2)

	var/obj/item/weapon/tool/T = forced
	if (istype(T) && T.item_flags & HONKING)
		playsound(src.loc, WORKSOUND_HONK, 70, 1, -2)

	..()

/obj/machinery/door/airlock/proc/lock(var/forced=0)
	if(locked)
		return 0

	if (operating && !forced) return 0

	src.locked = 1
	playsound(src.loc, 'sound/machines/Custom_bolts.ogg', 40, 1, 5)
	for(var/mob/M in range(1,src))
		M.show_message("You hear a click from the bottom of the door.", 2)
	update_icon()
	return 1

/obj/machinery/door/airlock/proc/unlock(var/forced=0)
	if(!src.locked)
		return

	if (!forced)
		if(operating || !src.arePowerSystemsOn() || isWireCut(AIRLOCK_WIRE_DOOR_BOLTS)) return

	src.locked = 0
	playsound(src.loc, 'sound/machines/Custom_boltsup.ogg', 40, 1, 5)
	for(var/mob/M in range(1,src))
		M.show_message("You hear a click from the bottom of the door.", 2)
	update_icon()
	return 1

/obj/machinery/door/airlock/allowed(mob/M)
	if(locked)
		return 0
	return ..(M)

/obj/machinery/door/airlock/New(var/newloc, var/obj/structure/door_assembly/assembly=null)
	..()

	//if assembly is given, create the new door from the assembly
	if (assembly && istype(assembly))
		assembly_type = assembly.type

		electronics = assembly.electronics
		electronics.loc = src

		//update the door's access to match the electronics'
		secured_wires = electronics.secure
		if(electronics.one_access)
			req_access.Cut()
			req_one_access = src.electronics.conf_access
		else
			req_one_access.Cut()
			req_access = src.electronics.conf_access

		//get the name from the assembly
		if(assembly.created_name)
			name = assembly.created_name
		else
			name = "[istext(assembly.glass) ? "[assembly.glass] airlock" : assembly.base_name]"

		//get the dir from the assembly
		set_dir(assembly.dir)

	//wires
	if(isOnAdminLevel(newloc))
		secured_wires = 1
	if (secured_wires)
		wires = new/datum/wires/airlock/secure(src)
	else
		wires = new/datum/wires/airlock(src)

/obj/machinery/door/airlock/Initialize()
	if(src.closeOtherId != null)
		for (var/obj/machinery/door/airlock/A in world)
			if(A.closeOtherId == src.closeOtherId && A != src)
				src.closeOther = A
				break
	verbs += /obj/machinery/door/airlock/proc/try_wedge_item
	. = ..()

/obj/machinery/door/airlock/Destroy()
	qdel(wires)
	wires = null
	qdel(wifi_receiver)
	wifi_receiver = null
	return ..()

// Most doors will never be deconstructed over the course of a round,
// so as an optimization defer the creation of electronics until
// the airlock is deconstructed
/obj/machinery/door/airlock/proc/create_electronics()
	//create new electronics
	if (secured_wires)
		src.electronics = new/obj/item/weapon/electronics/airlock/secure( src.loc )
	else
		src.electronics = new/obj/item/weapon/electronics/airlock( src.loc )

	//update the electronics to match the door's access
	if(!src.req_access)
		src.check_access()
	if(src.req_access.len)
		electronics.conf_access = src.req_access
	else if (src.req_one_access.len)
		electronics.conf_access = src.req_one_access
		electronics.one_access = 1

/obj/machinery/door/airlock/emp_act(var/severity)
	if(prob(20/severity))
		spawn(0)
			open()
	if(prob(40/severity))
		var/duration = SecondsToTicks(30 / severity)
		if(electrified_until > -1 && (duration + world.time) > electrified_until)
			electrify(duration)
	..()

/obj/machinery/door/airlock/power_change() //putting this is obj/machinery/door itself makes non-airlock doors turn invisible for some reason
	..()
	if(stat & NOPOWER)
		// If we lost power, disable electrification
		// Keeping door lights on, runs on internal battery or something.
		electrified_until = 0
	update_icon()

/obj/machinery/door/airlock/proc/prison_open()
	if(arePowerSystemsOn())
		src.unlock()
		src.open()
		src.lock()
	return


//Override to check locked var
/obj/machinery/door/airlock/hit(var/mob/user, var/obj/item/I)
	var/obj/item/weapon/W = I
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN*1.5)
	var/calc_damage = W.force*W.structure_damage_factor
	var/quiet = FALSE
	if (istool(I))
		var/obj/item/weapon/tool/T = I
		quiet = T.item_flags & SILENT

	if (locked)
		calc_damage *= 0.66
	calc_damage -= resistance
	user.do_attack_animation(src)
	if(calc_damage <= 0)
		user.visible_message(SPAN_DANGER("\The [user] hits \the [src] with \the [W] with no visible effect."))
		quiet ? null : playsound(src.loc, hitsound, 20, 1)
	else
		user.visible_message(SPAN_DANGER("\The [user] forcefully strikes \the [src] with \the [W]!"))
		playsound(src.loc, hitsound, quiet? 3: calc_damage*2, 1, 3,quiet?-5 :2)
		take_damage(W.force)


/obj/machinery/door/airlock/take_damage(var/damage)
	if (isnum(damage) && locked)
		damage *= 0.66 //The bolts reinforce the door, reducing damage taken

	return ..(damage)


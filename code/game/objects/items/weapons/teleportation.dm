/* Teleportation devices.
 * Contains:
 *		Hand-tele
 */

/*
 * Hand-tele
 */
/obj/item/hand_tele
	name = "NT BSD \"Jumper\""
	desc = "Also known as a hand teleporter. This is an old and unreliable way to create stable blue-space portals. It was originally popular due its portable size and low energy consumption."
	icon = 'icons/obj/device.dmi'
	icon_state = "hand_tele"
	item_state = "electronic"
	throwforce = WEAPON_FORCE_HARMLESS
	w_class = ITEM_SIZE_SMALL
	throw_speed = 3
	throw_range = 5
	origin_tech = list(TECH_MAGNET = 1, TECH_BLUESPACE = 3)
	matter = list(MATERIAL_PLASTIC = 3, MATERIAL_GLASS = 1, MATERIAL_SILVER = 1, MATERIAL_URANIUM = 1)
	spawn_blacklisted = TRUE///obj/item/hand_tele
	var/obj/item/cell/cell
	var/suitable_cell = /obj/item/cell/small
	var/portal_type = /obj/effect/portal
	var/portal_fail_chance
	var/cell_charge_per_attempt = 33
	var/entropy_value = 1  //for bluespace entropy

/obj/item/hand_tele/Initialize()
	. = ..()
	if(!cell && suitable_cell)
		cell = new suitable_cell(src)

/obj/item/hand_tele/get_cell()
	return cell

/obj/item/hand_tele/handle_atom_del(atom/A)
	..()
	if(A == cell)
		cell = null
		update_icon()

/obj/item/hand_tele/attack_self(mob/user)
	if(!cell || !cell.checked_use( cell_charge_per_attempt ))
		to_chat(user, SPAN_WARNING("[src] battery is dead or missing."))
		return
	var/turf/current_location = get_turf(user)//What turf is the user on?
	if(!current_location||current_location.z==2||current_location.z>=7)//If turf was not found or they're on z level 2 or >7 which does not currently exist.
		to_chat(user, SPAN_NOTICE("\The [src] is malfunctioning!"))
		return
	var/list/L = list()
	for(var/obj/machinery/teleport/hub/R in world)
		var/obj/machinery/computer/teleporter/com = locate(/obj/machinery/computer/teleporter, locate(R.x - 2, R.y, R.z))
		if (istype(com, /obj/machinery/computer/teleporter) && com.locked && !com.one_time_use)
			if(R.icon_state == "tele1")
				L["[com.id] (Active)"] = com.locked
			else
				L["[com.id] (Inactive)"] = com.locked
	var/list/turfs = list()
	var/turf/TLoc = get_turf(src)
	for(var/turf/T in RANGE_TURFS(10, TLoc) - TLoc)
		if(T.x > world.maxx - 8 || T.x < 8) //putting them at the edge is dumb
			continue
		if(T.y > world.maxy - 8 || T.y < 8)
			continue
		turfs += T
	if(turfs.len)
		L["None (Dangerous)"] = pick(turfs)
	var/t1 = input(user, "Please select a teleporter to lock in on.", "Hand Teleporter") in L
	if ((user.get_active_hand() != src || user.stat || user.restrained()))
		return
	var/T = L[t1]
	to_chat(user, SPAN_NOTICE("Portal locked in."))
	var/obj/effect/portal/P = new portal_type(get_turf(src))
	P.set_target(T)
	P.entropy_value += entropy_value
	if(portal_fail_chance)
		P.failchance = portal_fail_chance
	src.add_fingerprint(user)

/obj/item/hand_tele/MouseDrop(over_object)
	if((src.loc == usr) && istype(over_object, /obj/screen/inventory/hand) && eject_item(cell, usr))
		cell = null

/obj/item/hand_tele/attackby(obj/item/C, mob/living/user)
	if(istype(C, suitable_cell) && !cell && insert_item(C, user))
		src.cell = C


///////////////////////////////////////
////////////HANDMADE TELE-STUFF////////
///////////////////////////////////////

/obj/item/hand_tele/handmade
	name = "Handmade hand-teleporter"
	desc = "Handmade version of hand-tele. Woah, that's was they call an experimental science!"
	icon_state = "hm_hand-tele"
	portal_type = /obj/effect/portal/unstable
	portal_fail_chance = 50
	cell_charge_per_attempt = 50
	entropy_value = 3 //for bluespace entropy
	spawn_blacklisted = FALSE
	var/calibration_required = TRUE

/obj/item/hand_tele/handmade/attackby(obj/item/C, mob/living/user)
	..()
	if(istype(C, /obj/item/tool/screwdriver))
		if(user.a_intent == I_HURT)
			if(prob(5))
				var/turf/teleport_location = pick( getcircle(user.loc, 3) )
				user.drop_from_inventory(user.get_active_hand())
				user.drop_from_inventory(user.get_inactive_hand())
				if(teleport_location)
					go_to_bluespace(get_turf(src), entropy_value, TRUE, user, teleport_location, 1)
					return
			if(do_after(user, 30))
				if(calibration_required)
					to_chat(user, SPAN_WARNING("You loosen [src]'s calibration, it'll probably fail when used now."))
					portal_fail_chance = 90
					calibration_required = FALSE
				else
					calibration_required = TRUE
					to_chat(user, SPAN_NOTICE("You recalibrate [src]. It'll probably function now."))
					portal_fail_chance = 50
		else
			if(do_after(user, 30))
				if(calibration_required)
					var/user_intelligence = user.stats.getStat(STAT_COG)
					portal_fail_chance -= user_intelligence
					if(portal_fail_chance < 0)
						portal_fail_chance = 0
					calibration_required = FALSE
					to_chat(user, SPAN_NOTICE("You carefully place the bluespace crystal into slot to the end, and tweak the circuit with your [C]. [src] now looks more reliable."))
				else
					to_chat(user, SPAN_WARNING("[src] is calibrated already. You can decalibrate it to sabotage the device."))

/obj/item/tele_spear
	name = "Telespear"
	desc = "A crude-looking metal stick with some dodgy device tied to the end."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "telespear"
	item_state = "telespear"
	slot_flags = SLOT_BACK
	var/entropy_value = 1 //for bluespace entropy

/obj/item/tele_spear/attack(mob/living/carbon/human/M, mob/living/carbon/user)
	playsound(src.loc, 'sound/effects/EMPulse.ogg', 65, 1)
	var/turf/teleport_location = pick( getcircle(user.loc, 8) )
	if(prob(5))
		go_to_bluespace(get_turf(src), entropy_value, FALSE, user, teleport_location, 1)
	else
		go_to_bluespace(get_turf(src), entropy_value, FALSE, M, teleport_location, 1)
	qdel(src)
	var/obj/item/stack/rods/R = new(M.loc)
	user.put_in_active_hand(R)

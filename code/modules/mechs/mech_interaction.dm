/mob/living/exosuit/MouseDrop_T(atom/dropping, mob/user)
	if(istype(dropping, /obj/machinery/portable_atmospherics/canister))
		body.MouseDrop_T(dropping, user)
	else if(user != src && user == dropping)
		if(body)
			if(user.mob_size >= body.min_pilot_size && user.mob_size <= body.max_pilot_size)
				if(enter(user)) return 0
			else
				to_chat(user, SPAN_WARNING("You cannot pilot a exosuit of this size."))
				return 0
	else . = ..()

/mob/living/exosuit/proc/arms_action_delay()
	return arms ? arms.action_delay : 15

/mob/living/exosuit/setClickCooldown(timeout)
	. = ..()
	for(var/mob/p in pilots)
		p.setClickCooldown(timeout)

/mob/living/exosuit/ClickOn(var/atom/A, var/params, var/mob/user = usr)
	if(!user || incapacitated() || user.incapacitated())
		return

	if(!loc) return
	var/adj = A.Adjacent(src) // Why in the fuck isn't Adjacent() commutative.

	var/modifiers = params2list(params)
	if(modifiers["shift"])
		A.examine(user)
		return

	if(!(user in pilots) && user != src)
		return

	// Are we facing the target?
	if(A.loc != src && !(get_dir(src, A) & dir))
		return

	if(!arms)
		to_chat(user, SPAN_WARNING("\The [src] has no manipulators!"))
		setClickCooldown(3)
		return

	if(!arms.motivator || !arms.motivator.is_functional())
		to_chat(user, SPAN_WARNING("Your motivators are damaged! You can't use your manipulators!"))
		setClickCooldown(15)
		return

	var/obj/item/cell/cell = get_cell()
	if(!cell)
		to_chat(user, SPAN_WARNING("Error: Power cell missing."))
		setClickCooldown(3)
		return

	if(!cell.checked_use(arms.power_use * CELLRATE))
		to_chat(user, SPAN_WARNING("Error: Power levels insufficient."))
		setClickCooldown(3)
		return

	if(istype(selected_system, /obj/item/mech_equipment) && !check_equipment_software(selected_system))
		to_chat(user, SPAN_WARNING("Error: No control software was found for [selected_system]."))
		setClickCooldown(3)
		return

	// User is not necessarily the exosuit, or the same person, so update intent.
	if(user != src)
		a_intent = user.a_intent
		targeted_organ = user.targeted_organ

	// You may attack the target with your exosuit FIST if you're malfunctioning.
	var/failed = FALSE
	if(emp_damage > EMP_ATTACK_DISRUPT && prob(emp_damage*2))
		to_chat(user, SPAN_DANGER("The wiring sparks as you attempt to control the exosuit!"))
		failed = TRUE

	if(!failed && selected_system)
		if(selected_system == A)
			selected_system.attack_self(user)
			setClickCooldown(5)
			return

		// Mounted non-exosuit systems have some hacky loc juggling
		// to make sure that they work.
		var/system_moved = FALSE
		var/obj/item/temp_system
		var/obj/item/mech_equipment/ME
		if(istype(selected_system, /obj/item/mech_equipment))
			ME = selected_system
			temp_system = ME.get_effective_obj()
			if(temp_system in ME)
				system_moved = TRUE
				temp_system.forceMove(src)
		else
			temp_system = selected_system

		// Slip up and attack yourself maybe.
		failed = FALSE
		if(emp_damage > EMP_MOVE_DISRUPT && prob(10))
			failed = TRUE

		if(failed)
			var/list/other_atoms = orange(1, A)
			A = null
			while(LAZYLEN(other_atoms))
				var/atom/picked = pick_n_take(other_atoms)
				if(istype(picked) && picked.simulated)
					A = picked
					break
			if(!A)
				A = src
			adj = A.Adjacent(src)

		var/resolved
		if(adj)
			resolved = A.attackby(temp_system, src)

		if(!resolved && A && temp_system)
			var/mob/ruser = src
			if(!system_moved) //It's more useful to pass along clicker pilot when logic is fully mechside
				ruser = user
			temp_system.afterattack(A,ruser,adj,params)
		if(system_moved) //We are using a proxy system that may not have logging like mech equipment does
			log_attack("[user] used [temp_system] targetting [A]")

		// Mech equipment subtypes can add further click delays
		var/extra_delay = 0
		if(ME != null)
			ME = selected_system
			extra_delay = ME.equipment_delay
		setClickCooldown(arms_action_delay() + extra_delay)

		// If hacky loc juggling was performed, move the system back where it belongs
		if(system_moved)
			temp_system.forceMove(selected_system)
		return

	if(A == src)
		setClickCooldown(5)
		return attack_self(user)
	else if(adj)
		setClickCooldown(arms_action_delay())
		if(arms)
			return A.attack_generic(src, arms.melee_damage, "attacked")


/mob/living/exosuit/proc/set_hardpoint(var/hardpoint_tag)
	clear_selected_hardpoint()
	if(hardpoints[hardpoint_tag])
		// Set the new system.
		selected_system = hardpoints[hardpoint_tag]
		selected_hardpoint = hardpoint_tag
		return 1 // The element calling this proc will set its own icon.
	return 0

/mob/living/exosuit/proc/clear_selected_hardpoint()

	if(selected_hardpoint)
		for(var/hardpoint in hardpoints)
			if(hardpoint != selected_hardpoint) continue
			var/obj/screen/movable/exosuit/hardpoint/H = HUDneed[hardpoint]
			if(istype(H))
				H.icon_state = "hardpoint"
				break
		selected_system = null
		selected_hardpoint = null

/mob/living/exosuit/get_active_hand()
	var/obj/item/mech_equipment/ME = selected_system
	if(istype(ME))
		return ME.get_effective_obj()
	return ..()

/mob/living/exosuit/proc/check_enter(var/mob/user)
	if(!user || user.incapacitated())	return FALSE
	if(!user.Adjacent(src)) 			return FALSE
	if(issilicon(user))					return FALSE
	if (user.buckled)
		to_chat(user, SPAN_WARNING("You cannot enter a mech while buckled, unbuckle first."))
		return FALSE
	if(hatch_locked)
		to_chat(user, SPAN_WARNING("The [body.hatch_descriptor] is locked."))
		return FALSE
	if(hatch_closed)
		to_chat(user, SPAN_WARNING("The [body.hatch_descriptor] is closed."))
		return FALSE
	if(LAZYLEN(pilots) >= LAZYLEN(body.pilot_positions))
		to_chat(user, SPAN_WARNING("\The [src] is occupied to capacity."))
		return FALSE
	return TRUE

/mob/living/exosuit/proc/enter(var/mob/user)
	if(!check_enter(user))
		return
	to_chat(user, SPAN_NOTICE("You start climbing into \the [src]..."))
	if(!do_after(user, body.climb_time) || !check_enter(user)) //allows for specialized cockpits for rapid entry/exit, or slower for more armored ones
		return
	to_chat(user, SPAN_NOTICE("You climb into \the [src]."))

	user.drop_r_hand()
	user.drop_l_hand()
	user.forceMove(src)
	LAZYOR(pilots, user)
	sync_access()
	playsound(get_turf(src), 'sound/machines/windowdoor.ogg', 50, 1)
	user.playsound_local(null, 'sound/mechs/nominal.ogg', 50)
	LAZYDISTINCTADD(user.additional_vision_handlers, src)
	update_pilots()
	return 1

/mob/living/exosuit/proc/sync_access()
	access_card.access = saved_access.Copy()
	if(sync_access)
		for(var/mob/pilot in pilots)
			access_card.access |= pilot.GetAccess()
			to_chat(pilot, SPAN_NOTICE("Security access permissions synchronized."))

/mob/living/exosuit/proc/eject(mob/living/user, silent)
	if(!user || !(user in src.contents)) return
	if(hatch_closed)
		if(hatch_locked)
			if(!silent) to_chat(user, SPAN_WARNING("The [body.hatch_descriptor] is locked."))
			return
		var/obj/screen/movable/exosuit/toggle/hatch_open/H = HUDneed["hatch open"]
		if(H && istype(H))
			H.toggled()
		if(!silent)
			to_chat(user, SPAN_NOTICE("You open the hatch and climb out of \the [src]."))
	else if(!silent)
		to_chat(user, SPAN_NOTICE("You climb out of \the [src]."))

	user.forceMove(get_turf(src))
	LAZYREMOVE(user.additional_vision_handlers, src)
	if(user in pilots)
		a_intent = I_HURT
		LAZYREMOVE(pilots, user)
		update_pilots()
	if(user.client)
		update_mech_hud_4(user)
		user.client.eye = user.client.mob
		user.client.perspective = MOB_PERSPECTIVE
	return 1

/mob/living/exosuit/attackby(obj/item/I, mob/living/user)

	if(user.a_intent != I_HURT && istype(I, /obj/item/mech_equipment))
		if(hardpoints_locked)
			to_chat(user, SPAN_WARNING("Hardpoint system access is disabled."))
			return

		var/obj/item/mech_equipment/realThing = I
		if(realThing.owner)
			return

		var/free_hardpoints = list()
		for(var/hardpoint in hardpoints)
			if(hardpoints[hardpoint] == null)
				free_hardpoints += hardpoint

		var/to_place = input("Where would you like to install it?") as null|anything in (realThing.restricted_hardpoints & free_hardpoints)
		if(install_system(I, to_place, user))
			return
		to_chat(user, SPAN_WARNING("\The [I] could not be installed in that hardpoint."))
		return

	else if(user.a_intent != I_HURT)
		if(attack_tool(I, user))
			return
	return ..()

/mob/living/exosuit/proc/attack_tool(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/cell))
		if(!maintenance_protocols)
			to_chat(user, SPAN_WARNING("The power cell bay is locked while maintenance protocols are disabled."))
			return TRUE

		var/obj/item/cell/cell = get_cell()
		if(cell)
			to_chat(user, SPAN_WARNING("\The [src] already has [cell] installed!"))
			return TRUE

		to_chat(user, SPAN_NOTICE("You start inserting [I] into \the [src]."))
		if(do_mob(user, src, 30) && body.insert_item(I, user))
			body.cell = I

		return TRUE

	else if(istype(I, /obj/item/electronics/circuitboard/exosystem))
		if(!maintenance_protocols)
			to_chat(user, SPAN_WARNING("The software upload bay is locked while maintenance protocols are disabled."))
			return TRUE

		if(!body.computer)
			to_chat(user, SPAN_WARNING("The control computer is missing!"))
			return TRUE

		body.computer.install_software(I, user)
		return TRUE

	else if(istype(I, /obj/item/device/kit/paint))
		user.visible_message(
			SPAN_NOTICE("\The [user] opens \the [I] and spends some quality time customising \the [src]."),
			SPAN_NOTICE("You open \the [I] and spends some quality time customising \the [src].")
			)
		var/obj/item/device/kit/paint/P = I
		SetName(P.new_name)
		desc = P.new_desc
		for(var/obj/item/mech_component/comp in list(arms, legs, head, body))
			comp.decal = P.new_icon
		if(P.new_icon_file)
			icon = P.new_icon_file
		update_icon()
		P.use(1, user)
		return TRUE

	else if(istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = I
		if(coil.amount < 5)
			to_chat(user, SPAN_WARNING("You need at least 5 cable coil pieces in order to replace wiring."))
			return TRUE
		var/obj/item/mech_component/mc = get_targeted_part(user)
		if(!repairing_check(mc, user))
			return TRUE
		if(mc.burn_damage == 0)
			to_chat(user, SPAN_WARNING("Wiring on this part is already repaired."))
			return TRUE
		to_chat(user, SPAN_NOTICE("You start replacing wiring in \the [src]."))
		if(do_mob(user, src, 30) && coil.use(5))
			mc.repair_burn_damage(15)

	var/list/usable_qualities = list(QUALITY_PULSING, QUALITY_BOLT_TURNING, QUALITY_WELDING)

	var/tool_type = I.get_tool_type(user, usable_qualities, src)
	switch(tool_type)
		if(QUALITY_PULSING)
			if(hardpoints_locked)
				to_chat(user, SPAN_WARNING("Hardpoint system access is disabled."))
				return TRUE

			var/list/parts = list()
			for(var/hardpoint in hardpoints)
				if(hardpoints[hardpoint])
					parts += hardpoint

			if(!length(parts))
				to_chat(user, SPAN_WARNING("\The [src] has no hardpoint systems to remove."))
				return TRUE

			var/to_remove = input("Which component would you like to remove") as null|anything in parts
			remove_system(to_remove, user)
			return TRUE

		if(QUALITY_BOLT_TURNING)
			if(!maintenance_protocols)
				to_chat(user, SPAN_WARNING("The securing bolts are not visible while maintenance protocols are disabled."))
				return TRUE

			if(length(pilots))
				to_chat(user, SPAN_WARNING("You cannot dismantle \the [src] with a pilot still inside!"))
				return TRUE

			visible_message(SPAN_WARNING("\The [user] begins unwrenching the securing bolts holding \the [src] together."))
			if(!do_mob(user, src, 60) || !maintenance_protocols || length(pilots))
				return TRUE
			visible_message(SPAN_NOTICE("\The [user] loosens and removes the securing bolts, dismantling \the [src]."))
			dismantle()
			return TRUE

		if(QUALITY_WELDING)
			var/obj/item/mech_component/mc = get_targeted_part(user)
			if(!repairing_check(mc, user))
				return TRUE
			if(mc.brute_damage == 0)
				to_chat(user, SPAN_WARNING("Brute damage on this part is already repaired."))
				return TRUE
			if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
				visible_message(SPAN_WARNING("\The [mc] has been repaired by [user]!"),"You hear welding.")
				mc.repair_brute_damage(15)
				return TRUE

		if(ABORT_CHECK)
			return


/mob/living/exosuit/MouseDrop(atom/over_object)
	var/mob/living/carbon/human/user = usr

	// Clickdragging, either onto a mob or into inventory hand
	if(istype(user) && user.Adjacent(src) && (over_object == user || istype(over_object, /obj/screen/inventory/hand)))
		// Ejecting exosuit power cell
		var/obj/item/cell/cell = get_cell()
		if(cell)
			if(!maintenance_protocols)
				to_chat(user, SPAN_WARNING("The power cell bay is locked while maintenance protocols are disabled."))
				return

			to_chat(user, SPAN_NOTICE("You start removing [cell] from \the [src]."))
			if(do_mob(user, src, 30) && cell == body.cell && body.eject_item(cell, user))
				body.cell = null

		// Removing software boards
		else if(length(body.computer?.contents))
			if(!maintenance_protocols)
				to_chat(user, SPAN_WARNING("The software upload bay is locked while maintenance protocols are disabled."))
				return

			var/obj/item/board = body.computer.contents[length(body.computer.contents)]
			to_chat(user, SPAN_NOTICE("You start removing [board] from \the [src]."))
			if(do_mob(user, src, 30) && (board in body.computer) && body.computer?.eject_item(board, user))
				body.computer.update_software()

		return

	return ..()

/mob/living/exosuit/attack_hand(mob/living/user)
	// Drag the pilot out if possible.
	if(user.a_intent == I_HURT)
		if(!LAZYLEN(pilots))
			to_chat(user, SPAN_WARNING("There is nobody inside \the [src]."))
		else if(!hatch_closed)
			var/mob/pilot = pick(pilots)
			user.visible_message(SPAN_DANGER("\The [user] is trying to pull \the [pilot] out of \the [src]!"))
			if(do_after(user, 30) && user.Adjacent(src) && (pilot in pilots) && !hatch_closed)
				user.visible_message(SPAN_DANGER("\The [user] drags \the [pilot] out of \the [src]!"))
				eject(pilot, silent=1)
		return

	// Otherwise toggle the hatch.
	if(hatch_locked)
		to_chat(user, SPAN_WARNING("The [body.hatch_descriptor] is locked."))
		return
	hatch_closed = !hatch_closed
	to_chat(user, SPAN_NOTICE("You [hatch_closed ? "close" : "open"] the [body.hatch_descriptor]."))
	var/obj/screen/movable/exosuit/toggle/hatch_open/H = HUDneed["hatch open"]
	if(H && istype(H)) H.update_icon()
	update_icon()
	return

/mob/living/exosuit/proc/attack_self(mob/user)
	return visible_message("\The [src] pokes itself.")

/mob/living/exosuit/proc/rename(mob/user)
	if(user != src && !(user in pilots))
		return
	var/new_name = sanitize(input("Enter a new exosuit designation.", "Exosuit Name") as text|null, max_length = MAX_NAME_LEN)
	if(!new_name || new_name == name || (user != src && !(user in pilots)))
		return
	SetName(new_name)
	to_chat(user, SPAN_NOTICE("You have redesignated this exosuit as \the [name]."))

/mob/living/exosuit/proc/get_targeted_part(mob/user)
	var/obj/item/mech_component/mc = null
	switch(user.targeted_organ)
		if(BP_R_ARM, BP_L_ARM)
			mc = arms
		if(BP_HEAD)
			mc = head
		if(BP_CHEST, BP_GROIN)
			mc = body
		if(BP_R_LEG, BP_L_LEG)
			mc = legs
	return mc

/mob/living/exosuit/proc/repairing_check(obj/item/mech_component/mc, mob/user)
	if(!mc || !mc.can_be_repaired())
		to_chat(user, SPAN_WARNING("This part is completely destroyed, you cannot repair it."))
		return FALSE
	if(mc.total_damage == 0)
		to_chat(user, SPAN_WARNING("This part is already fully repaired."))
		return FALSE
	if(!maintenance_protocols)
		to_chat(user, SPAN_WARNING("You cannot repair \the [src] while maintenance protocols are disabled."))
		return FALSE
	return TRUE

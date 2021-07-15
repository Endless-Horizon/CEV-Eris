/obj/structure/AIcore
	density = TRUE
	anchored = FALSE
	name = "\improper AI core"
	icon = 'icons/mob/AI.dmi'
	icon_state = "0"
	var/state = 0
	var/datum/ai_laws/laws = new /datum/ai_laws/eris
	var/obj/item/electronics/circuitboard/circuit
	var/obj/item/device/mmi/brain


/obj/structure/AIcore/attackby(obj/item/I, mob/user)

	var/list/usable_qualities = list()
	if(state == 0 || (state == 1 && !circuit))
		usable_qualities.Add(QUALITY_BOLT_TURNING)
	if(state == 0)
		usable_qualities.Add(QUALITY_WELDING)
	if((state == 1 && circuit) || (state == 2 && circuit) || state == 4)
		usable_qualities.Add(QUALITY_SCREW_DRIVING)
	if((state == 1 && circuit) || (state == 3 && brain) || state == 4)
		usable_qualities.Add(QUALITY_PRYING)
	if(state == 3)
		usable_qualities.Add(QUALITY_WIRE_CUTTING)

	var/tool_type = I.get_tool_type(user, usable_qualities, src)
	switch(tool_type)

		if(QUALITY_BOLT_TURNING)
			if(state == 0)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_HARD, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You wrench the frame into place."))
					anchored = TRUE
					state = 1
					return
			if(state == 1 && !circuit)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_HARD, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You unfasten the frame."))
					anchored = FALSE
					state = 0
					return
			return

		if(QUALITY_WELDING)
			if(state == 0)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_HARD, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You deconstruct the frame."))
					new /obj/item/stack/material/plasteel( loc, 8)
					qdel(src)
					return
			return

		if(QUALITY_PRYING)
			if(state == 1 && circuit)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_HARD, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You remove the circuit board."))
					state = 1
					icon_state = "0"
					circuit.loc = loc
					circuit = null
					return
			if(state == 3 && brain)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_HARD, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You remove the brain."))
					brain.loc = loc
					brain = null
					icon_state = "3"
					return
			if(state == 4)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_HARD, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You remove the glass panel."))
					state = 3
					if (brain)
						icon_state = "3b"
					else
						icon_state = "3"
					new /obj/item/stack/material/glass/reinforced( loc, 2 )
					return
			return

		if(QUALITY_SCREW_DRIVING)
			if(state == 1 && circuit)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_HARD, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You screw the circuit board into place."))
					state = 2
					icon_state = "2"
					return
			if(state == 2 && circuit)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_HARD, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You unfasten the circuit board."))
					state = 1
					icon_state = "1"
					return
			if(state == 4)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_HARD, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You connect the monitor."))
					if(!brain)
						var/open_for_latejoin = alert(user, "Would you like this core to be open for latejoining AIs?", "Latejoin", "Yes", "Yes", "No") == "Yes"
						var/obj/structure/AIcore/deactivated/D = new(loc)
						if(open_for_latejoin)
							empty_playable_ai_cores += D
					else
						var/mob/living/silicon/ai/A = new /mob/living/silicon/ai ( loc, laws, brain )
						if(A) //if there's no brain, the mob is deleted and a structure/AIcore is created
							A.rename_self("ai", 1)
					qdel(src)
					return
			return

		if(QUALITY_WIRE_CUTTING)
			if(state == 3)
				if (brain)
					to_chat(user, "Get that brain out of there first")
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_HARD, required_stat = STAT_MEC))
					to_chat(user, SPAN_NOTICE("You remove the cables."))
					state = 2
					icon_state = "2"
					var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( loc )
					A.amount = 5
					return
			return

		if(ABORT_CHECK)
			return

	switch(state)
		if(1)
			if(istype(I, /obj/item/electronics/circuitboard/aicore) && !circuit)
				playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
				to_chat(user, SPAN_NOTICE("You place the circuit board inside the frame."))
				icon_state = "1"
				circuit = I
				user.drop_item()
				I.loc = src
		if(2)
			if(istype(I, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = I
				if (C.get_amount() < 5)
					to_chat(user, SPAN_WARNING("You need five coils of wire to add them to the frame."))
					return
				to_chat(user, SPAN_NOTICE("You start to add cables to the frame."))
				playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
				if (do_after(user, 20, src) && state == 2)
					if (C.use(5))
						state = 3
						icon_state = "3"
						to_chat(user, SPAN_NOTICE("You add cables to the frame."))
				return
		if(3)
			if(istype(I, /obj/item/stack/material) && I.get_material_name() == MATERIAL_RGLASS)
				var/obj/item/stack/RG = I
				if (RG.get_amount() < 2)
					to_chat(user, SPAN_WARNING("You need two sheets of glass to put in the glass panel."))
					return
				to_chat(user, SPAN_NOTICE("You start to put in the glass panel."))
				playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
				if (do_after(user, 20,src) && state == 3)
					if(RG.use(2))
						to_chat(user, SPAN_NOTICE("You put in the glass panel."))
						state = 4
						icon_state = "4"

			if(istype(I, /obj/item/electronics/ai_module))
				var/obj/item/electronics/ai_module/AIM = I
				AIM.transmitInstructions(src, usr)
				to_chat(usr, "Law module applied.")
				return

			if(istype(I, /obj/item/device/mmi))
				var/obj/item/device/mmi/M = I
				if(!M.brainmob)
					to_chat(user, SPAN_WARNING("Sticking an empty [I] into the frame would sort of defeat the purpose."))
					return
				if(M.brainmob.stat == 2)
					to_chat(user, SPAN_WARNING("Sticking a dead [I] into the frame would sort of defeat the purpose."))
					return

				if(jobban_isbanned(M.brainmob, "AI"))
					to_chat(user, SPAN_WARNING("This [I] does not seem to fit."))
					return

				if(M.brainmob.mind)
					clear_antagonist(M.brainmob.mind)

				user.drop_item()
				I.loc = src
				brain = I
				to_chat(usr, "Added [I].")
				icon_state = "3b"

/obj/structure/AIcore/deactivated
	name = "inactive AI"
	icon = 'icons/mob/AI.dmi'
	icon_state = "ai-empty"
	anchored = TRUE
	state = 20//So it doesn't interact based on the above. Not really necessary.

/obj/structure/AIcore/deactivated/Destroy()
	if(src in empty_playable_ai_cores)
		empty_playable_ai_cores -= src
	. = ..()

/obj/structure/AIcore/deactivated/proc/load_ai(var/mob/living/silicon/ai/transfer, var/obj/item/device/aicard/card, var/mob/user)

	if(!istype(transfer) || locate(/mob/living/silicon/ai) in src)
		return

	transfer.aiRestorePowerRoutine = 0
	transfer.control_disabled = 0
	transfer.aiRadio.disabledAi = 0
	transfer.loc = get_turf(src)
	transfer.create_eyeobj()
	transfer.cancel_camera()
	to_chat(user, "<span class='notice'>Transfer successful:</span> [transfer.name] ([rand(1000,9999)].exe) downloaded to host terminal. Local copy wiped.")
	to_chat(transfer, "You have been uploaded to a stationary terminal. Remote device connection restored.")

	if(card)
		card.clear()

	qdel(src)

/obj/structure/AIcore/deactivated/attackby(var/obj/item/W, var/mob/user)

	if(istype(W, /obj/item/device/aicard))
		var/obj/item/device/aicard/card = W
		var/mob/living/silicon/ai/transfer = locate() in card
		if(transfer)
			load_ai(transfer,card,user)
		else
			to_chat(user, "<span class='danger'>ERROR:</span> Unable to locate artificial intelligence.")
		return
	else if(istype(W, /obj/item/tool/wrench))
		if(anchored)
			user.visible_message(SPAN_NOTICE("\The [user] starts to unbolt \the [src] from the plating..."))
			if(!do_after(user,40,src))
				user.visible_message(SPAN_NOTICE("\The [user] decides not to unbolt \the [src]."))
				return
			user.visible_message(SPAN_NOTICE("\The [user] finishes unfastening \the [src]!"))
			anchored = FALSE
			return
		else
			user.visible_message(SPAN_NOTICE("\The [user] starts to bolt \the [src] to the plating..."))
			if(!do_after(user,40,src))
				user.visible_message(SPAN_NOTICE("\The [user] decides not to bolt \the [src]."))
				return
			user.visible_message(SPAN_NOTICE("\The [user] finishes fastening down \the [src]!"))
			anchored = TRUE
			return
	else
		return ..()

ADMIN_VERB_ADD(/client/proc/empty_ai_core_toggle_latejoin, R_ADMIN, null)
/client/proc/empty_ai_core_toggle_latejoin()
	set name = "Toggle AI Core Latejoin"
	set category = "Server"

	var/list/cores = list()
	for(var/obj/structure/AIcore/deactivated/D in world)
		cores["[D] ([D.loc.loc])"] = D

	var/id = input("Which core?", "Toggle AI Core Latejoin", null) as null|anything in cores
	if(!id) return

	var/obj/structure/AIcore/deactivated/D = cores[id]
	if(!D) return

	if(D in empty_playable_ai_cores)
		empty_playable_ai_cores -= D
		to_chat(src, "\The [id] is now <font color=\"#ff0000\">not available</font> for latejoining AIs.")
	else
		empty_playable_ai_cores += D
		to_chat(src, "\The [id] is now <font color=\"#008000\">available</font> for latejoining AIs.")

	message_admins("[key_name(usr)] has toggled latejoining empty AI core at the core [D] ([D.loc.loc])")
	log_admin("The [D] core at ([D.loc.loc]) is toggled for latejoining AIs by [key_name(usr)]")

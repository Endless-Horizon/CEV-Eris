/mob/living/carbon/human
	name = "unknown"
	real_name = "unknown"
	voice_name = "unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "body_m_s"

	var/list/hud_list[10]
	var/embedded_flag	  //To check if we've need to roll for damage on movement while an item is imbedded in us.
	var/obj/item/weapon/rig/wearing_rig // This is very not good, but it's much much better than calling get_rig() every update_lying_buckled_and_verb_status() call.
	var/obj/item/weapon/gun/using_scope // This is not very good either, because I've copied it. Sorry.

/mob/living/carbon/human/New(var/new_loc, var/new_species)

	if(!dna)
		dna = new /datum/dna(null)
		// Species name is handled by set_species()

	if(!species)
		if(new_species)
			set_species(new_species,1)
		else
			set_species()

	if(species)
		real_name = species.get_random_name(gender)
		name = real_name
		if(mind)
			mind.name = real_name

	hud_list[HEALTH_HUD]      = image('icons/mob/hud.dmi', src, "hudhealth100", ON_MOB_HUD_LAYER)
	hud_list[STATUS_HUD]      = image('icons/mob/hud.dmi', src, "hudhealthy",   ON_MOB_HUD_LAYER)
	hud_list[LIFE_HUD]        = image('icons/mob/hud.dmi', src, "hudhealthy",   ON_MOB_HUD_LAYER)
	hud_list[ID_HUD]          = image('icons/mob/hud.dmi', src, "hudunknown",   ON_MOB_HUD_LAYER)
	hud_list[WANTED_HUD]      = image('icons/mob/hud.dmi', src, "hudblank",     ON_MOB_HUD_LAYER)
	hud_list[IMPCHEM_HUD]     = image('icons/mob/hud.dmi', src, "hudblank",     ON_MOB_HUD_LAYER)
	hud_list[IMPTRACK_HUD]    = image('icons/mob/hud.dmi', src, "hudblank",     ON_MOB_HUD_LAYER)
	hud_list[SPECIALROLE_HUD] = image('icons/mob/hud.dmi', src, "hudblank",     ON_MOB_HUD_LAYER)
	hud_list[STATUS_HUD_OOC]  = image('icons/mob/hud.dmi', src, "hudhealthy",   ON_MOB_HUD_LAYER)
	hud_list[EXCELSIOR_HUD]   = image('icons/mob/hud.dmi', src, "hudblank",     ON_MOB_HUD_LAYER)



	GLOB.human_mob_list |= src
	..()

	if(dna)
		dna.ready_dna(src)
		dna.real_name = real_name
		sync_organ_dna()
	make_blood()

	sanity = new(src)

	AddComponent(/datum/component/fabric)

/mob/living/carbon/human/Destroy()
	GLOB.human_mob_list -= src

	// Prevent death from organ removal
	status_flags |= REBUILDING_ORGANS
	for(var/organ in organs)
		qdel(organ)
	organs.Cut()
	return ..()

/mob/living/carbon/human/Stat()
	. = ..()
	if(statpanel("Status"))
		stat("Intent:", "[a_intent]")
		stat("Move Mode:", "[move_intent.name]")
		if(evacuation_controller)
			var/eta_status = evacuation_controller.get_status_panel_eta()
			if(eta_status)
				stat(null, eta_status)

		if (internal)
			if (!internal.air_contents)
				qdel(internal)
			else
				stat("Internal Atmosphere Info", internal.name)
				stat("Tank Pressure", internal.air_contents.return_pressure())
				stat("Distribution Pressure", internal.distribute_pressure)

		if(back && istype(back,/obj/item/weapon/rig))
			var/obj/item/weapon/rig/suit = back
			var/cell_status = "ERROR"
			if(suit.cell) cell_status = "[suit.cell.charge]/[suit.cell.maxcharge]"
			stat(null, "Suit charge: [cell_status]")

		var/chemvessel_efficiency = get_organ_efficiency(OP_CHEMICALS)
		if(chemvessel_efficiency > 1)
			stat("Chemical Storage", "[carrion_stored_chemicals]/[round(0.5 * chemvessel_efficiency)]")

		var/maw_efficiency = get_organ_efficiency(OP_MAW)
		if(maw_efficiency > 1)
			stat("Gnawing hunger", "[carrion_hunger]/[round(maw_efficiency/10)]")

		var/obj/item/weapon/implant/core_implant/cruciform/C = get_core_implant(/obj/item/weapon/implant/core_implant/cruciform)
		if (C)
			stat("Cruciform", "[C.power]/[C.max_power]")

/mob/living/carbon/human/ex_act(severity)
	if(!blinded)
		if (HUDtech.Find("flash"))
			FLICK("flash", HUDtech["flash"])

	var/shielded = 0
	var/b_loss
	var/f_loss
	var/bomb_defense = getarmor(null, ARMOR_BOMB) + mob_bomb_defense
	switch (severity)
		if (1)
			b_loss += 500
			if (!prob(bomb_defense))
				gib()
				return
			else
				var/atom/target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(target, 200, 4)
			//return
//				var/atom/target = get_edge_target_turf(user, get_dir(src, get_step_away(user, src)))
				//user.throw_at(target, 200, 4)

		if (2)
			if (!shielded)
				b_loss += 150

			if (!istype(l_ear, /obj/item/clothing/ears/earmuffs) && !istype(r_ear, /obj/item/clothing/ears/earmuffs))
				adjustEarDamage(30,120)
			if (prob(70) && !shielded)
				Paralyse(10)

		if(3)
			b_loss += 100
			if (!istype(l_ear, /obj/item/clothing/ears/earmuffs) && !istype(r_ear, /obj/item/clothing/ears/earmuffs))
				adjustEarDamage(15,60)
			if (prob(50) && !shielded)
				Paralyse(10)
	if (bomb_defense)
		b_loss = max(b_loss - bomb_defense, 0)
		f_loss = max(f_loss - bomb_defense, 0)

	var/organ_hit = BP_CHEST //Chest is hit first
	var/exp_damage
	while (b_loss > 0)
		b_loss -= exp_damage = rand(0, b_loss)
		src.apply_damage(exp_damage, BRUTE, organ_hit)
		organ_hit = pickweight(list(BP_HEAD = 0.2, BP_GROIN = 0.2, BP_R_ARM = 0.1, BP_L_ARM = 0.1, BP_R_LEG = 0.1, BP_L_LEG = 0.1))  //We determine some other body parts that should be hit

/mob/living/carbon/human/restrained()
	if (handcuffed)
		return 1
	if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
		return 1
	return 0

/mob/living/carbon/human/var/co2overloadtime
/mob/living/carbon/human/var/temperature_resistance = T0C+75


/mob/living/carbon/human/show_inv(mob/user as mob)
	if(user.incapacitated()  || !user.Adjacent(src))
		return

	var/obj/item/clothing/under/suit
	if (istype(w_uniform, /obj/item/clothing/under))
		suit = w_uniform

	user.set_machine(src)
	var/dat = "<B><HR><FONT size=3>[name]</FONT></B><BR><HR>"

	for(var/entry in species.hud.gear)
		var/slot = species.hud.gear[entry]
		if(slot in list(slot_l_store, slot_r_store))
			continue
		var/obj/item/thing_in_slot = get_equipped_item(slot)
		dat += "<BR><B>[entry]:</b> <a href='?src=\ref[src];item=[slot]'>[istype(thing_in_slot) ? thing_in_slot : "nothing"]</a>"

	dat += "<BR><HR>"

/*	if(species.hud.has_hands)
		dat += "<BR><b>Left hand:</b> <A href='?src=\ref[src];item=[slot_l_hand]'>[istype(l_hand) ? l_hand : "nothing"]</A>"
		dat += "<BR><b>Right hand:</b> <A href='?src=\ref[src];item=[slot_r_hand]'>[istype(r_hand) ? r_hand : "nothing"]</A>"*/

	// Do they get an option to set internals?
	if(istype(wear_mask, /obj/item/clothing/mask) || istype(head, /obj/item/clothing/head/space))
		if(istype(back, /obj/item/weapon/tank) || istype(belt, /obj/item/weapon/tank) || istype(s_store, /obj/item/weapon/tank))
			dat += "<BR><A href='?src=\ref[src];item=internals'>Toggle internals.</A>"

	// Other incidentals.
	if(handcuffed)
		dat += "<BR><A href='?src=\ref[src];item=[slot_handcuffed]'>Handcuffed</A>"
	if(legcuffed)
		dat += "<BR><A href='?src=\ref[src];item=[slot_legcuffed]'>Legcuffed</A>"

	if(suit && suit.accessories.len)
		dat += "<BR><A href='?src=\ref[src];item=tie'>Remove accessory</A>"
	dat += "<BR><A href='?src=\ref[src];item=splints'>Remove splints</A>"
	dat += "<BR><A href='?src=\ref[src];item=pockets'>Empty pockets</A>"
	dat += "<BR><A href='?src=\ref[user];refresh=1'>Refresh</A>"
	dat += "<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>"

	user << browse(dat, text("window=mob[name];size=340x540"))
	onclose(user, "mob[name]")
	return

// called when something steps onto a human
// this handles mulebots and vehicles
/mob/living/carbon/human/Crossed(var/atom/movable/AM)
	if(istype(AM, /obj/machinery/bot/mulebot))
		var/obj/machinery/bot/mulebot/MB = AM
		MB.RunOver(src)

	if(istype(AM, /obj/vehicle))
		var/obj/vehicle/V = AM
		V.RunOver(src)

// Get rank from ID, ID inside PDA, PDA, ID in wallet, etc.
/mob/living/carbon/human/proc/get_authentification_rank(var/if_no_id = "No id", var/if_no_job = "No job")
	var/obj/item/weapon/card/id/id = GetIdCard()
	if(istype(id))
		return id.rank ? id.rank : if_no_job
	else
		return if_no_id

//gets assignment from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_assignment(var/if_no_id = "No id", var/if_no_job = "No job")
	var/obj/item/weapon/card/id/id = GetIdCard()
	if(istype(id))
		return id.assignment ? id.assignment : if_no_job
	else
		return if_no_id

//gets name from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_authentification_name(var/if_no_id = "Unknown")
	var/obj/item/weapon/card/id/id = GetIdCard()
	if(id)
		return id.registered_name || if_no_id
	else
		return if_no_id

//Trust me I'm an engineer
//I think we'll put this shit right here
var/list/rank_prefix = list(\
	"Ironhammer Operative" = "Operative",\
	"Ironhammer Inspector" = "Inspector",\
	"Ironhammer Gunnery Sergeant" = "Sergeant",\
	"Ironhammer Commander" = "Lieutenant",\
	"Captain" = "Captain",\
	)

/mob/living/carbon/human/proc/rank_prefix_name(name)
	if(get_id_rank())
		if(findtext(name, " "))
			name = copytext(name, findtext(name, " "))
		name = get_id_rank() + name
	return name

//repurposed proc. Now it combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a seperate proc as it'll be useful elsewhere
/mob/living/carbon/human/proc/get_visible_name()
	if((wear_mask && (wear_mask.flags_inv&HIDEFACE)) || (head && (head.flags_inv&HIDEFACE)))	//Wearing a mask which hides our face, use id-name if possible	//Likewise for hats
		return rank_prefix_name(get_id_name())

	var/face_name = get_face_name()
	var/id_name = get_id_name("")
	if(id_name)
		if(id_name != face_name)
			return "[face_name] (as [rank_prefix_name(id_name)])"
		else
			return rank_prefix_name(id_name)
	return face_name

//Returns "Unknown" if facially disfigured and real_name if not. Useful for setting name when polyacided or when updating a human's name variable
/mob/living/carbon/human/get_face_name()
	var/obj/item/organ/external/head = get_organ(BP_HEAD)
	if(!head || head.disfigured || head.is_stump() || !real_name || (HUSK in mutations) )	//disfigured. use id-name if possible
		return "Unknown"
	return real_name

//gets name from ID or PDA itself, ID inside PDA doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/human/proc/get_id_name(var/if_no_id = "Unknown")
	. = if_no_id
	var/obj/item/weapon/card/id/I = GetIdCard()
	if(istype(I))
		return I.registered_name

/mob/living/carbon/human/proc/get_id_rank()
	var/rank
	var/obj/item/weapon/card/id/id
	if (istype(wear_id, /obj/item/modular_computer/pda))
		id = wear_id.GetIdCard()
	if(!id)
		id = get_idcard()
	if(id)
		rank = id.rank
		if(rank_prefix[rank])
			return rank_prefix[rank]
	return ""

//gets ID card object from special clothes slot or null.
/mob/living/carbon/human/proc/get_idcard()
	if(wear_id)
		return wear_id.GetIdCard()

//Removed the horrible safety parameter. It was only being used by ninja code anyways.
//Now checks siemens_coefficient of the affected area by default
/mob/living/carbon/human/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, def_zone)
	if(status_flags & GODMODE)	return 0	//godmode

	if (!def_zone)
		def_zone = pick(BP_L_ARM, BP_R_ARM)

	var/obj/item/organ/external/affected_organ = get_organ(check_zone(def_zone))
	siemens_coeff *= get_siemens_coefficient_organ(affected_organ)

	return ..(shock_damage, source, siemens_coeff, def_zone)


/mob/living/carbon/human/Topic(href, href_list)

	if (href_list["refresh"])
		if((machine)&&(in_range(src, usr)))
			show_inv(machine)

	if (href_list["mach_close"])
		var/t1 = text("window=[]", href_list["mach_close"])
		unset_machine()
		src << browse(null, t1)

	if(href_list["item"])
		handle_strip(href_list["item"],usr)

	if (href_list["criminal"])
		if(hasHUD(usr,"security"))

			var/modified = FALSE
			var/perpname = get_id_name(name)

			if(perpname)
				var/datum/computer_file/report/crew_record/R = get_crewmember_record(perpname)
				if(R)
					var/setcriminal = input(usr, "Specify a new criminal status for this person.", "Security HUD", R.get_criminalStatus()) in GLOB.security_statuses + "Cancel"
					if(hasHUD(usr, "security"))
						if(setcriminal != "Cancel")
							R.set_criminalStatus(setcriminal)
							modified = TRUE
							BITSET(hud_updateflag, WANTED_HUD)
							if(ishuman(usr))
								var/mob/living/carbon/human/U = usr
								U.handle_regular_hud_updates()
							if(isrobot(usr))
								var/mob/living/silicon/robot/U = usr
								U.handle_regular_hud_updates()

			if(!modified)
				to_chat(usr, "\red Unable to locate a data core entry for this person.")

	if (href_list["secrecord"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			var/read = 0

			var/obj/item/weapon/card/id/id = GetIdCard()
			if(istype(id))
				perpname = id.registered_name
			else
				perpname = src.name

			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								to_chat(usr, "<b>Name:</b> [R.fields["name"]]	<b>Criminal Status:</b> [R.fields["criminal"]]")
								to_chat(usr, "<b>Minor Crimes:</b> [R.fields["mi_crim"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["mi_crim_d"]]")
								to_chat(usr, "<b>Major Crimes:</b> [R.fields["ma_crim"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["ma_crim_d"]]")
								to_chat(usr, "<b>Notes:</b> [R.fields["notes"]]")
								to_chat(usr, "<a href='?src=\ref[src];secrecordComment=`'>\[View Comment Log\]</a>")
								read = 1

			if(!read)
				to_chat(usr, "\red Unable to locate a data core entry for this person.")

	if (href_list["secrecordComment"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			var/read = 0

			var/obj/item/weapon/card/id/id = GetIdCard()
			if(istype(id))
				perpname = id.registered_name
			else
				perpname = src.name

			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								read = 1
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									to_chat(usr, text("[]", R.fields[text("com_[]", counter)]))
									counter++
								if (counter == 1)
									to_chat(usr, "No comment found")
								to_chat(usr, "<a href='?src=\ref[src];secrecordadd=`'>\[Add comment\]</a>")

			if(!read)
				to_chat(usr, "\red Unable to locate a data core entry for this person.")

	if (href_list["secrecordadd"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			if(wear_id)
				var/obj/item/weapon/card/id/id
				if (istype(wear_id, /obj/item/modular_computer/pda))
					id = wear_id.GetIdCard()
				if(!id)
					id = get_idcard()
					if(id)
						perpname = id.registered_name
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								var/t1 = sanitize(input("Add Comment:", "Sec. records", null, null)  as message)
								if ( !(t1) || usr.stat || usr.restrained() || !(hasHUD(usr,"security")) )
									return
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									counter++
								if(ishuman(usr))
									var/mob/living/carbon/human/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.get_authentification_name()] ([U.get_assignment()]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")
								if(isrobot(usr))
									var/mob/living/silicon/robot/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.name] ([U.modtype] [U.braintype]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")

	if (href_list["medical"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/modified = 0

			var/obj/item/weapon/card/id/id = GetIdCard()
			if(istype(id))
				perpname = id.registered_name
			else
				perpname = src.name

			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.general)
						if (R.fields["id"] == E.fields["id"])

							var/setmedical = input(usr, "Specify a new medical status for this person.", "Medical HUD", R.fields["p_stat"]) in list("*SSD*", "*Deceased*", "Physically Unfit", "Active", "Disabled", "Cancel")

							if(hasHUD(usr,"medical"))
								if(setmedical != "Cancel")
									R.fields["p_stat"] = setmedical
									modified = 1
									if(PDA_Manifest.len)
										PDA_Manifest.Cut()

									spawn()
										if(ishuman(usr))
											var/mob/living/carbon/human/U = usr
											U.handle_regular_hud_updates()
										if(isrobot(usr))
											var/mob/living/silicon/robot/U = usr
											U.handle_regular_hud_updates()

			if(!modified)
				to_chat(usr, "\red Unable to locate a data core entry for this person.")

	if (href_list["medrecord"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				var/obj/item/weapon/card/id/id
				if (istype(wear_id, /obj/item/modular_computer/pda))
					id = wear_id.GetIdCard()
				if(!id)
					id = get_idcard()
					if(id)
						perpname = id.registered_name
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								to_chat(usr, "<b>Name:</b> [R.fields["name"]]	<b>Blood Type:</b> [R.fields["b_type"]]")
								to_chat(usr, "<b>DNA:</b> [R.fields["b_dna"]]")
								to_chat(usr, "<b>Minor Disabilities:</b> [R.fields["mi_dis"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["mi_dis_d"]]")
								to_chat(usr, "<b>Major Disabilities:</b> [R.fields["ma_dis"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["ma_dis_d"]]")
								to_chat(usr, "<b>Notes:</b> [R.fields["notes"]]")
								to_chat(usr, "<a href='?src=\ref[src];medrecordComment=`'>\[View Comment Log\]</a>")
								read = 1

			if(!read)
				to_chat(usr, "\red Unable to locate a data core entry for this person.")

	if (href_list["medrecordComment"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				var/obj/item/weapon/card/id/id
				if (istype(wear_id, /obj/item/modular_computer/pda))
					id = wear_id.GetIdCard()
				if(!id)
					id = get_idcard()
					if(id)
						perpname = id.registered_name
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								read = 1
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									to_chat(usr, text("[]", R.fields[text("com_[]", counter)]))
									counter++
								if (counter == 1)
									to_chat(usr, "No comment found")
								to_chat(usr, "<a href='?src=\ref[src];medrecordadd=`'>\[Add comment\]</a>")

			if(!read)
				to_chat(usr, "\red Unable to locate a data core entry for this person.")

	if (href_list["medrecordadd"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			if(wear_id)
				var/obj/item/weapon/card/id/id
				if (istype(wear_id, /obj/item/modular_computer/pda))
					id = wear_id.GetIdCard()
				if(!id)
					id = get_idcard()
					if(id)
						perpname = id.registered_name
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								var/t1 = sanitize(input("Add Comment:", "Med. records", null, null)  as message)
								if ( !(t1) || usr.stat || usr.restrained() || !(hasHUD(usr,"medical")) )
									return
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									counter++
								if(ishuman(usr))
									var/mob/living/carbon/human/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.get_authentification_name()] ([U.get_assignment()]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")
								if(isrobot(usr))
									var/mob/living/silicon/robot/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.name] ([U.modtype] [U.braintype]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")

	if (href_list["lookitem"])
		var/obj/item/I = locate(href_list["lookitem"])
		src.examinate(I)

	if (href_list["lookmob"])
		var/mob/M = locate(href_list["lookmob"])
		src.examinate(M)

	..()
	return

///eyecheck()
///Returns a number between -1 to 2
/mob/living/carbon/human/eyecheck()
	if(!species.has_process[OP_EYES]) //No eyes, can't hurt them.
		return FLASH_PROTECTION_MAJOR

	var/eye_efficiency = get_organ_efficiency(OP_EYES)
	if(eye_efficiency <= 1)
		return FLASH_PROTECTION_MAJOR

	return flash_protection

//Used by various things that knock people out by applying blunt trauma to the head.
//Checks that the species has a "head" (brain containing organ) and that hit_zone refers to it.
/mob/living/carbon/human/proc/headcheck(var/target_zone, var/brain_tag = BP_BRAIN)
	if(!species.has_process[brain_tag])
		return 0

	var/obj/item/organ/affecting = random_organ_by_process(brain_tag)

	target_zone = check_zone(target_zone)
	if(!affecting || affecting.parent != target_zone)
		return 0

	//if the parent organ is significantly larger than the brain organ, then hitting it is not guaranteed
	var/obj/item/organ/parent = get_organ(target_zone)
	if(!parent)
		return 0

	if(parent.w_class > affecting.w_class + 1)
		return prob(100 / 2**(parent.w_class - affecting.w_class - 1))

	return 1

/mob/living/carbon/human/IsAdvancedToolUser(var/silent)
	if(species.has_fine_manipulation)
		return 1
	if(!silent)
		to_chat(src, SPAN_WARNING("You don't have the dexterity to use that!"))
	return 0

/mob/living/carbon/human/abiotic(var/full_body = 0)
	if(full_body && ((src.l_hand && !( src.l_hand.abstract )) || (src.r_hand && !( src.r_hand.abstract )) || (src.back || src.wear_mask || src.head || src.shoes || src.w_uniform || src.wear_suit || src.glasses || src.l_ear || src.r_ear || src.gloves)))
		return 1

	if( (src.l_hand && !src.l_hand.abstract) || (src.r_hand && !src.r_hand.abstract) )
		return 1

	return 0


/mob/living/carbon/human/proc/check_dna()
	dna.check_integrity(src)
	return

/mob/living/carbon/human/get_species()
	if(!species)
		set_species()
	return species.name

/mob/living/carbon/human/proc/play_xylophone()
	if(!src.xylophone)
		visible_message("\red \The [src] begins playing \his ribcage like a xylophone. It's quite spooky.","\blue You begin to play a spooky refrain on your ribcage.","\red You hear a spooky xylophone melody.")
		var/song = pick('sound/effects/xylophone1.ogg','sound/effects/xylophone2.ogg','sound/effects/xylophone3.ogg')
		playsound(loc, song, 50, 1, -1)
		xylophone = 1
		spawn(1200)
			xylophone=0
	return

/mob/living/carbon/human/proc/check_has_mouth()
	// Todo, check stomach organ when implemented.
	var/obj/item/organ/external/H = get_organ(BP_HEAD)
	if(!H || !(H.functions & BODYPART_REAGENT_INTAKE))
		return FALSE
	return TRUE

/mob/living/carbon/human/vomit()

	if(!check_has_mouth())
		return
	if(stat == DEAD)
		return
	if(!lastpuke)
		lastpuke = 1
		to_chat(src, SPAN_WARNING("You feel nauseous..."))
		spawn(150)	//15 seconds until second warning
			to_chat(src, SPAN_WARNING("You feel like you are about to throw up!"))
			spawn(100)	//and you have 10 more for mad dash to the bucket
				Stun(5)

				src.visible_message(SPAN_WARNING("[src] throws up!"),SPAN_WARNING("You throw up!"))
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)

				var/turf/location = loc
				if (istype(location, /turf/simulated))
					location.add_vomit_floor(src, 1)

				adjustNutrition(-40)
				adjustToxLoss(-3)
				spawn(350)	//wait 35 seconds before next volley
					lastpuke = 0

/mob/living/carbon/human/proc/morph()
	set name = "Morph"
	set category = "Superpower"

	if(stat!=CONSCIOUS)
		reset_view(0)
		remoteview_target = null
		return

	if(!(mMorph in mutations))
		src.verbs -= /mob/living/carbon/human/proc/morph
		return

	var/new_facial = input("Please select facial hair color.", "Character Generation",facial_color) as color
	if(new_facial)
		facial_color = new_facial

	var/new_hair = input("Please select hair color.", "Character Generation",hair_color) as color
	if(new_hair)
		hair_color = new_hair

	var/new_eyes = input("Please select eye color.", "Character Generation",eyes_color) as color
	if(new_eyes)
		eyes_color = new_eyes
		update_eyes()

	var/new_tone = input("Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation", "[35-s_tone]")  as text

	if (!new_tone)
		new_tone = 35
	s_tone = max(min(round(text2num(new_tone)), 220), 1)
	s_tone =  -s_tone + 35

	// hair
	var/list/all_hairs = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair
	var/list/hairs = list()

	// loop through potential hairs
	for(var/x in all_hairs)
		var/datum/sprite_accessory/hair/H = new x // create new hair datum based on type x
		hairs.Add(H.name) // add hair name to hairs
		qdel(H) // delete the hair after it's all done

	var/new_style = input("Please select hair style", "Character Generation",h_style)  as null|anything in hairs

	// if new style selected (not cancel)
	if (new_style)
		h_style = new_style

	// facial hair
	var/list/all_fhairs = typesof(/datum/sprite_accessory/facial_hair) - /datum/sprite_accessory/facial_hair
	var/list/fhairs = list()

	for(var/x in all_fhairs)
		var/datum/sprite_accessory/facial_hair/H = new x
		fhairs.Add(H.name)
		qdel(H)

	new_style = input("Please select facial style", "Character Generation",f_style)  as null|anything in fhairs

	if(new_style)
		f_style = new_style

	var/new_gender = alert(usr, "Please select gender.", "Character Generation", "Male", "Female")
	if (new_gender)
		if(new_gender == "Male")
			gender = MALE
		else
			gender = FEMALE
	regenerate_icons()
	check_dna()

	visible_message("\blue \The [src] morphs and changes [get_visible_gender() == MALE ? "his" : get_visible_gender() == FEMALE ? "her" : "their"] appearance!", "\blue You change your appearance!", "\red Oh, god!  What the hell was that?  It sounded like flesh getting squished and bone ground into a different shape!")

/mob/living/carbon/human/proc/remotesay()
	set name = "Project mind"
	set category = "Superpower"

	if(stat!=CONSCIOUS)
		reset_view(0)
		remoteview_target = null
		return

	if(!(mRemotetalk in src.mutations))
		src.verbs -= /mob/living/carbon/human/proc/remotesay
		return
	var/list/creatures = list()
	for(var/mob/living/carbon/h in world)
		creatures += h
	var/mob/target = input("Who do you want to project your mind to ?") as null|anything in creatures
	if (isnull(target))
		return

	var/say = sanitize(input("What do you wish to say"))
	if(mRemotetalk in target.mutations)
		target.show_message("\blue You hear [src.real_name]'s voice: [say]")
	else
		target.show_message("\blue You hear a voice that seems to echo around the room: [say]")
	usr.show_message("\blue You project your mind into [target.real_name]: [say]")
	log_say("[key_name(usr)] sent a telepathic message to [key_name(target)]: [say]")
	for(var/mob/observer/ghost/G in world)
		G.show_message("<i>Telepathic message from <b>[src]</b> to <b>[target]</b>: [say]</i>")

/mob/living/carbon/human/proc/remoteobserve()
	set name = "Remote View"
	set category = "Superpower"

	if(stat!=CONSCIOUS)
		remoteview_target = null
		reset_view(0)
		return

	if(!(mRemote in src.mutations))
		remoteview_target = null
		reset_view(0)
		src.verbs -= /mob/living/carbon/human/proc/remoteobserve
		return

	if(client.eye != client.mob)
		remoteview_target = null
		reset_view(0)
		return

	var/list/mob/creatures = list()

	for(var/mob/living/carbon/h in world)
		var/turf/temp_turf = get_turf(h)
		if((temp_turf.z != 1 && temp_turf.z != 5) || h.stat!=CONSCIOUS) //Not on mining or the station. Or dead
			continue
		creatures += h

	var/mob/target = input ("Who do you want to project your mind to ?") as mob in creatures

	if (target)
		remoteview_target = target
		reset_view(target)
	else
		remoteview_target = null
		reset_view(0)

/mob/living/carbon/human/proc/get_visible_gender()
	if(wear_suit && wear_suit.flags_inv & HIDEJUMPSUIT && ((head && head.flags_inv & HIDEMASK) || wear_mask))
		return NEUTER
	return gender

/mob/living/carbon/human/proc/increase_germ_level(n)
	if(gloves)
		gloves.germ_level += n
	else
		germ_level += n

/mob/living/carbon/human/revive()

	if(species && !(species.flags & NO_BLOOD))
		vessel.add_reagent("blood",species.blood_volume-vessel.total_volume)
		fixblood()

	// Fix up all organs.
	// This will ignore any prosthetics in the prefs currently.
	rebuild_organs()

	if(!client || !key) //Don't boot out anyone already in the mob.
		for(var/obj/item/organ/internal/brain/H in world)
			if(H.brainmob)
				if(H.brainmob.real_name == src.real_name)
					if(H.brainmob.mind)
						H.brainmob.mind.transfer_to(src)
						qdel(H)


	for (var/ID in virus2)
		var/datum/disease2/disease/V = virus2[ID]
		V.cure(src)

	losebreath = 0

	..()

/mob/living/carbon/human/proc/is_lung_ruptured()
	var/obj/item/organ/internal/lungs/L = random_organ_by_process(OP_LUNGS)
	return L && L.is_bruised()

/mob/living/carbon/human/proc/rupture_lung()
	var/obj/item/organ/internal/lungs/L = random_organ_by_process(OP_LUNGS)

	if(L && !L.is_bruised())
		src.custom_pain("You feel a stabbing pain in your chest!", 1)
		L.bruise()

/*
/mob/living/carbon/human/verb/simulate()
	set name = "sim"
	set background = 1

	var/damage = input("Wound damage","Wound damage") as num

	var/germs = 0
	var/tdamage = 0
	var/ticks = 0
	while (germs < 2501 && ticks < 100000 && round(damage/10)*20)
		log_misc("VIRUS TESTING: [ticks] : germs [germs] tdamage [tdamage] prob [round(damage/10)*20]")
		ticks++
		if (prob(round(damage/10)*20))
			germs++
		if (germs == 100)
			to_chat(world, "Reached stage 1 in [ticks] ticks")
		if (germs > 100)
			if (prob(10))
				damage++
				germs++
		if (germs == 1000)
			to_chat(world, "Reached stage 2 in [ticks] ticks")
		if (germs > 1000)
			damage++
			germs++
		if (germs == 2500)
			to_chat(world, "Reached stage 3 in [ticks] ticks")
	to_chat(world, "Mob took [tdamage] tox damage")
*/
//returns 1 if made bloody, returns 0 otherwise

/mob/living/carbon/human/add_blood(mob/living/carbon/human/M as mob)
	if (!..())
		return 0
	//if this blood isn't already in the list, add it
	if(istype(M))
		if(!blood_DNA[M.dna.unique_enzymes])
			blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
	hand_blood_color = blood_color
	src.update_inv_gloves()	//handles bloody hands overlays and updating
	verbs += /mob/living/carbon/human/proc/bloody_doodle
	return 1 //we applied blood to the item

/mob/living/carbon/human/proc/get_full_print()
	if(!dna ||!dna.uni_identity)
		return
	if(chem_effects[CE_DYNAMICFINGERS])
		return md5(chem_effects[CE_DYNAMICFINGERS])
	return md5(dna.uni_identity)

/mob/living/carbon/human/clean_blood(var/clean_feet)
	.=..()

	if(gloves)
		if(gloves.clean_blood())
			update_inv_gloves()
		gloves.germ_level = 0
	else
		if(bloody_hands)
			bloody_hands = 0
			update_inv_gloves()
		germ_level = 0

	gunshot_residue = null

	if(clean_feet)
		if(shoes)
			if(shoes.clean_blood())
				update_inv_shoes()
		else
			if(feet_blood_DNA && feet_blood_DNA.len)
				feet_blood_color = null
				feet_blood_DNA.Cut()
				update_inv_shoes()

	return

/mob/living/carbon/human/get_visible_implants()
	var/list/visible_implants = list()

	for(var/obj/item/organ/external/organ in organs)
		for(var/obj/item/I in (organ.implants & organ.embedded))
			visible_implants += I

	return visible_implants

/mob/living/carbon/human/embedded_needs_process()
	for(var/obj/item/organ/external/organ in organs)
		for(var/obj/item/O in organ.implants)
			if(is_sharp(O))	// Only sharp items can cause issues
				return TRUE
	return FALSE

/mob/living/carbon/human/proc/handle_embedded_objects()

	for(var/obj/item/organ/external/organ in organs)
		if(organ.status & ORGAN_SPLINTED) //Splints prevent movement.
			continue

		for(var/obj/item/O in organ.implants)
			// Shrapnel hurts when you move, and implanting knives is a bad idea
			if(prob(5) && is_sharp(O))
				if(!organ.can_feel_pain())
					to_chat(src, SPAN_WARNING("You feel [O] moving inside your [organ.name]."))
				else
					var/msg = pick( \
						SPAN_WARNING("A spike of pain jolts your [organ.name] as you bump [O] inside."), \
						SPAN_WARNING("Your movement jostles [O] in your [organ.name] painfully."), \
						SPAN_WARNING("Your movement jostles [O] in your [organ.name] painfully."))
					to_chat(src, msg)
				var/mob/living/carbon/human/H = organ.owner
				if(!MOVING_DELIBERATELY(H))
					organ.take_damage(rand(1,3), 0, 0)
					if(organ.setBleeding())
						src.adjustToxLoss(rand(1,3))

/mob/living/carbon/human/verb/browse_sanity()
	set name		= "Show sanity"
	set desc		= "Browse your character sanity."
	set category	= "IC"
	set src			= usr
	nano_ui_interact(src)

/mob/living/carbon/human/nano_ui_data()
	var/list/data = list()

	data["style"] = get_total_style()
	data["min_style"] = MIN_HUMAN_STYLE
	data["max_style"] = MAX_HUMAN_STYLE
	data["sanity"] = sanity.level
	data["sanity_max_level"] = sanity.max_level
	data["insight"] = sanity.insight
	data["desires"] = sanity.desires
	data["rest"] = sanity.resting
	data["insight_rest"] = sanity.insight_rest

	var/obj/item/weapon/implant/core_implant/cruciform/C = get_core_implant(/obj/item/weapon/implant/core_implant/cruciform)
	if(C)
		data["cruciform"] = TRUE
		data["righteous_life"] = C.righteous_life

	return data

/mob/living/carbon/human/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, state = GLOB.default_state)
	var/list/data = nano_ui_data()

	ui = SSnano.try_update_ui(user, user, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "sanity.tmpl", name, 650, 550, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()

/mob/living/carbon/human/verb/check_pulse()
	set category = "Object"
	set name = "Check pulse"
	set desc = "Approximately count somebody's pulse. Requires you to stand still at least 6 seconds."
	set src in view(1)
	var/self = 0

	if(usr.stat || usr.restrained() || !isliving(usr)) return

	if(usr == src)
		self = 1
	if(!self)
		usr.visible_message(SPAN_NOTICE("[usr] kneels down, puts \his hand on [src]'s wrist and begins counting their pulse."),\
		"You begin counting [src]'s pulse")
	else
		usr.visible_message(SPAN_NOTICE("[usr] begins counting their pulse."),\
		"You begin counting your pulse.")

	if(pulse())
		to_chat(usr, "<span class='notice'>[self ? "You have a" : "[src] has a"] pulse! Counting...</span>")
	else
		to_chat(usr, SPAN_DANGER("[src] has no pulse!")	) //it is REALLY UNLIKELY that a dead person would check his own pulse
		return

	to_chat(usr, "You must[self ? "" : " both"] remain still until counting is finished.")
	if(do_mob(usr, src, 60))
		to_chat(usr, "<span class='notice'>[self ? "Your" : "[src]'s"] pulse is [src.get_pulse(GETPULSE_HAND)].</span>")
	else
		to_chat(usr, SPAN_WARNING("You failed to check the pulse. Try again."))

/mob/living/carbon/human/proc/set_species(var/new_species, var/default_colour)
	if(!dna)
		if(!new_species)
			new_species = SPECIES_HUMAN
	else
		if(!new_species)
			new_species = dna.species
		else
			dna.species = new_species

	// No more invisible screaming wheelchairs because of set_species() typos.
	if(!all_species[new_species])
		new_species = SPECIES_HUMAN

	if(species)

		if(species.name && species.name == new_species)
			return
		if(species.language)
			remove_language(species.language)
		if(species.default_language)
			remove_language(species.default_language)
		// Clear out their species abilities.
		species.remove_inherent_verbs(src)
		holder_type = null

	species = all_species[new_species]

	if(species?.language)
		add_language(species.language)

	if(species.default_language)
		add_language(species.default_language)

	if(species.base_color && default_colour)
		//Apply colour.
		skin_color = species.base_color
	else
		skin_color = "#000000"

	if(species.holder_type)
		holder_type = species.holder_type

	icon_state = lowertext(species.name)

	if(species.has_process.len)
		for(var/process in species.has_process)
			internal_organs_by_efficiency[process] = list()

	rebuild_organs()
	src.sync_organ_dna()
	species.handle_post_spawn(src)

	maxHealth = species.total_health

	update_client_colour(0)

	spawn(0)
		regenerate_icons()
		if(vessel.total_volume < species.blood_volume)
			vessel.maximum_volume = species.blood_volume
			vessel.add_reagent("blood", species.blood_volume - vessel.total_volume)
		else if(vessel.total_volume > species.blood_volume)
			vessel.remove_reagent("blood", vessel.total_volume - species.blood_volume)
			vessel.maximum_volume = species.blood_volume
		fixblood()


	// Rebuild the HUD. If they aren't logged in then login() should reinstantiate it for them.
	check_HUD()
	/*
	if(client && client.screen)//HUD HERE!!!!!!!!!!
		client.screen.Cut()
		if(hud_used)
			qdel(hud_used)
		hud_used = new /datum/hud(src)
		update_hud()
	*/
	if(species)
		return 1
	else
		return 0

//Needed for augmentation
/mob/living/carbon/human/proc/rebuild_organs(from_preference)
	if(!species)
		return FALSE

	status_flags |= REBUILDING_ORGANS

	var/obj/item/organ/internal/carrion/core = random_organ_by_process(BP_SPCORE)
	var/list/organs_to_readd = list()
	if(core) //kinda wack, this whole proc should be remade
		for(var/obj/item/organ/internal/carrion/C in internal_organs)
			C.removed_mob()
			organs_to_readd += C

	var/obj/item/weapon/implant/core_implant/CI = get_core_implant()
	var/checkprefcruciform = FALSE	// To reset the cruciform to original form
	if(CI)
		checkprefcruciform = TRUE
		qdel(CI)


	if(from_preference)
		for(var/obj/item/organ/organ in (organs|internal_organs))
			qdel(organ)

		if(organs.len)
			organs.Cut()
		if(internal_organs.len)
			internal_organs.Cut()
		if(organs_by_name.len)
			organs_by_name.Cut()
		var/datum/preferences/Pref
		if(istype(from_preference, /datum/preferences))
			Pref = from_preference
		else if(client)
			Pref = client.prefs
		else
			return

		var/datum/body_modification/BM

		for(var/tag in species.has_limbs)
			BM = Pref.get_modification(tag)
			var/datum/organ_description/OD = species.has_limbs[tag]
//			var/datum/body_modification/PBM = Pref.get_modification(OD.parent_organ_base)
//			if(PBM && (PBM.nature == MODIFICATION_SILICON || PBM.nature == MODIFICATION_REMOVED))
//				BM = PBM
			if(BM.is_allowed(tag, Pref, src))
				BM.create_organ(src, OD, Pref.modifications_colors[tag])
			else
				OD.create_organ(src)

		for(var/tag in species.has_process)
			BM = Pref.get_modification(tag)
			if(BM.is_allowed(tag, Pref, src))
				BM.create_organ(src, species.has_process[tag], Pref.modifications_colors[tag])
			else
				var/organ_type = species.has_process[tag]
				new organ_type(src)

		var/datum/category_item/setup_option/core_implant/I = Pref.get_option("Core implant")
		if(I.implant_type && (!mind || mind.assigned_role != "Robot"))
			var/obj/item/weapon/implant/core_implant/C = new I.implant_type
			C.install(src)
			C.activate()
			if(mind)
				C.install_default_modules_by_job(mind.assigned_job)
				C.access.Add(mind.assigned_job.cruciform_access)

	else
		var/organ_type

		for(var/limb_tag in species.has_limbs)
			var/datum/organ_description/OD = species.has_limbs[limb_tag]
			var/obj/item/I = organs_by_name[limb_tag]
			if(I && I.type == OD.default_type)
				continue
			else if(I)
				qdel(I)
			OD.create_organ(src)

		for(var/organ_tag in species.has_process)
			organ_type = species.has_process[organ_tag]
			var/obj/item/I = random_organ_by_process(organ_tag)
			if(I && I.type == organ_type)
				continue
			else if(I)
				qdel(I)
			new organ_type(src)

		if(checkprefcruciform)
			var/datum/category_item/setup_option/core_implant/I = client.prefs.get_option("Core implant")
			if(I.implant_type)
				var/obj/item/weapon/implant/core_implant/C = new I.implant_type
				C.install(src)
				C.activate()
				C.install_default_modules_by_job(mind.assigned_job)
				C.access.Add(mind.assigned_job.cruciform_access)

	for(var/obj/item/organ/internal/carrion/C in organs_to_readd)
		C.replaced(get_organ(C.parent_organ_base))

	status_flags &= ~REBUILDING_ORGANS
	species.organs_spawned(src)

	update_body()

/mob/living/carbon/human/proc/post_prefinit()
	var/obj/item/weapon/implant/core_implant/C = locate() in src
	if(C)
		C.install(src)
		C.activate()
		C.install_default_modules_by_job(mind.assigned_job)
		C.access |= mind.assigned_job.cruciform_access

/mob/living/carbon/human/proc/bloody_doodle()
	set category = "IC"
	set name = "Write in blood"
	set desc = "Use blood on your hands to write a short message on the floor or a wall, murder mystery style."

	if (src.stat)
		return

	if (usr != src)
		return 0 //something is terribly wrong

	if (!bloody_hands)
		verbs -= /mob/living/carbon/human/proc/bloody_doodle

	if (src.gloves)
		to_chat(src, SPAN_WARNING("Your [src.gloves] are getting in the way."))
		return

	var/turf/simulated/T = src.loc
	if (!istype(T)) //to prevent doodling out of mechs and lockers
		to_chat(src, SPAN_WARNING("You cannot reach the floor."))
		return

	var/direction = input(src,"Which way?","Tile selection") as anything in list("Here","North","South","East","West")
	if (direction != "Here")
		T = get_step(T,text2dir(direction))
	if (!istype(T))
		to_chat(src, SPAN_WARNING("You cannot doodle there."))
		return

	var/num_doodles = 0
	for (var/obj/effect/decal/cleanable/blood/writing/W in T)
		num_doodles++
	if (num_doodles > 4)
		to_chat(src, SPAN_WARNING("There is no space to write on!"))
		return

	var/max_length = bloody_hands * 30 //tweeter style

	var/message = sanitize(input("Write a message. It cannot be longer than [max_length] characters.","Blood writing", ""))

	if (message)
		var/used_blood_amount = round(length(message) / 30, 1)
		bloody_hands = max(0, bloody_hands - used_blood_amount) //use up some blood

		if (length(message) > max_length)
			message += "-"
			to_chat(src, SPAN_WARNING("You ran out of blood to write with!"))

		var/obj/effect/decal/cleanable/blood/writing/W = new(T)
		W.basecolor = (hand_blood_color) ? hand_blood_color : "#A10808"
		W.update_icon()
		W.message = message
		W.add_fingerprint(src)

/mob/living/carbon/human/can_inject(var/mob/user, var/error_msg, var/target_zone)
	. = 1
	if(!target_zone)
		if(user)
			target_zone = user.targeted_organ
		else
			// Pick an existing non-robotic limb, if possible.
			for(target_zone in BP_ALL_LIMBS)
				var/obj/item/organ/external/affecting = get_organ(target_zone)
				if(affecting && BP_IS_ORGANIC(affecting) || BP_IS_ASSISTED(affecting))
					break


	var/obj/item/organ/external/affecting = get_organ(target_zone)
	var/fail_msg
	if(!affecting)
		. = 0
		fail_msg = "They are missing that limb."
	else if (BP_IS_ROBOTIC(affecting))
		. = 0
		fail_msg = "That limb is robotic."
	else
		switch(target_zone)
			if(BP_HEAD)
				if(head && head.item_flags & THICKMATERIAL)
					. = 0
			else
				if(wear_suit && wear_suit.item_flags & THICKMATERIAL)
					. = 0
	if(!. && error_msg && user)
		if(BP_IS_LIFELIKE(affecting) && user.stats.getStat(STAT_BIO) < STAT_LEVEL_BASIC)
			fail_msg = "Skin is tough and inelastic."
		else if(!fail_msg)
			fail_msg = "There is no exposed flesh or thin material [target_zone == BP_HEAD ? "on their head" : "on their body"] to inject into."
		to_chat(user, SPAN_WARNING(fail_msg))

/mob/living/carbon/human/print_flavor_text(var/shrink = 1)
	var/list/equipment = list(src.head,src.wear_mask,src.glasses,src.w_uniform,src.wear_suit,src.gloves,src.shoes)

	for(var/obj/item/clothing/C in equipment)
		if(C.body_parts_covered & FACE)
			// Do not show flavor if face is hidden
			return

	if(client)
		flavor_text = client.prefs.flavor_text

	if (flavor_text && flavor_text != "" && !shrink)
		var/msg = trim(replacetext(flavor_text, "\n", " "))
		if(!msg) return ""
		if(length(msg) <= 40)
			return "<font color='blue'>[msg]</font>"
		else
			return "<font color='blue'>[copytext_preserve_html(msg, 1, 37)]... <a href='byond://?src=\ref[src];flavor_more=1'>More...</a></font>"
	return ..()

/mob/living/carbon/human/getDNA()
	if(species.flags & NO_SCAN)
		return null
	..()

/mob/living/carbon/human/setDNA()
	if(species.flags & NO_SCAN)
		return
	..()

/mob/living/carbon/human/has_brain()
	if(organ_list_by_process(BP_BRAIN).len)
		return TRUE
	return FALSE

/mob/living/carbon/human/has_eyes()
	if(organ_list_by_process(BP_EYES).len)
		for(var/obj/item/organ/internal/eyes in organ_list_by_process(OP_EYES))
			if(!(eyes && istype(eyes) && !(eyes.status & ORGAN_CUT_AWAY)))
				return FALSE
			return TRUE
	return FALSE

/mob/living/carbon/human/slip(var/slipped_on, stun_duration=8)
	if((species.flags & NO_SLIP) || (shoes && (shoes.item_flags & NOSLIP)))
		return 0
	..(slipped_on,stun_duration)

/mob/living/carbon/human/proc/undislocate()
	set category = "Object"
	set name = "Undislocate Joint"
	set desc = "Pop a joint back into place. Extremely painful."
	set src in view(1)

	if(!isliving(usr) || !usr.can_click())
		return

	usr.setClickCooldown(20)

	if(usr.stat > 0)
		to_chat(usr, "You are unconcious and cannot do that!")
		return

	if(usr.restrained())
		to_chat(usr, "You are restrained and cannot do that!")
		return

	var/mob/S = src
	var/mob/U = usr
	var/self
	if(S == U)
		self = 1 // Removing object from yourself.

	var/list/limbs = list()
	for(var/limb in organs_by_name)
		var/obj/item/organ/external/current_limb = organs_by_name[limb]
		if(current_limb && current_limb.dislocated == 2)
			limbs |= limb
	var/choice = input(usr,"Which joint do you wish to relocate?") as null|anything in limbs

	if(!choice)
		return

	var/obj/item/organ/external/current_limb = organs_by_name[choice]

	if(self)
		to_chat(src, SPAN_WARNING("You brace yourself to relocate your [current_limb.joint]..."))
	else
		to_chat(U, SPAN_WARNING("You begin to relocate [S]'s [current_limb.joint]..."))

	if(!do_after(U, 30, src))
		return
	if(!choice || !current_limb || !S || !U)
		return

	if(self)
		to_chat(src, SPAN_DANGER("You pop your [current_limb.joint] back in!"))
	else
		to_chat(U, SPAN_DANGER("You pop [S]'s [current_limb.joint] back in!"))
		to_chat(S, SPAN_DANGER("[U] pops your [current_limb.joint] back in!"))
	current_limb.undislocate()

/mob/living/carbon/human/reset_view(atom/A, update_hud = 1)
	..()
	if(update_hud)
		handle_regular_hud_updates()


/mob/living/carbon/human/can_stand_overridden()
	if(wearing_rig && wearing_rig.ai_can_move_suit(check_for_ai = 1))
		// Actually missing a leg will screw you up. Everything else can be compensated for.
		for(var/limbcheck in list(BP_L_LEG ,BP_R_LEG))
			var/obj/item/organ/affecting = get_organ(limbcheck)
			if(!affecting)
				return 0
		return 1
	return 0

/mob/living/carbon/human/MouseDrop(var/atom/over_object)
	var/mob/living/carbon/human/H = over_object
	if(holder_type && istype(H) && H.a_intent == I_HELP && !H.lying && !issmall(H) && Adjacent(H))
		get_scooped(H, (usr == src))
		return
	return ..()

/mob/living/carbon/human/verb/pull_punches()
	set name = "Pull Punches"
	set desc = "Try not to hurt them."
	set category = "IC"

	if(stat) return
	pulling_punches = !pulling_punches
	to_chat(src, "<span class='notice'>You are now [pulling_punches ? "pulling your punches" : "not pulling your punches"].</span>")
	return

//generates realistic-ish pulse output based on preset levels
/mob/living/carbon/human/proc/get_pulse(var/method)	//method 0 is for hands, 1 is for machines, more accurate
	var/temp = 0
	switch(pulse())
		if(PULSE_NONE)
			return "0"
		if(PULSE_SLOW)
			temp = rand(40, 60)
		if(PULSE_NORM)
			temp = rand(60, 90)
		if(PULSE_FAST)
			temp = rand(90, 120)
		if(PULSE_2FAST)
			temp = rand(120, 160)
		if(PULSE_THREADY)
			return method ? ">250" : "extremely weak and fast, patient's artery feels like a thread"
	return "[method ? temp : temp + rand(-10, 10)]"
//			output for machines^	^^^^^^^output for people^^^^^^^^^

/mob/living/carbon/human/proc/pulse()
	if(!(organ_list_by_process(OP_HEART).len))
		return PULSE_NONE
	else
		return pulse

/mob/living/carbon/human/verb/lookup()
	set name = "Look up"
	set desc = "If you want to know what's above."
	set category = "IC"

	if(!is_physically_disabled())
		var/turf/above = GetAbove(src)
		if(shadow)
			if(client.eye == shadow)
				reset_view(0)
				return
			if(above.is_hole)
				to_chat(src, SPAN_NOTICE("You look up."))
				if(client)
					reset_view(shadow)
				return
		to_chat(src, SPAN_NOTICE("You can see [above]."))
	else
		to_chat(src, SPAN_NOTICE("You can't do it right now."))
	return

/mob/living/carbon/human/should_have_process(var/organ_check)

	var/obj/item/organ/external/affecting
	if(organ_check in list(OP_HEART, OP_LUNGS, OP_STOMACH))
		affecting = organs_by_name[BP_CHEST]
	else if(organ_check in list(OP_LIVER, OP_KIDNEYS, OP_KIDNEY_LEFT, OP_KIDNEY_RIGHT))
		affecting = organs_by_name[BP_GROIN]

	if(affecting && (BP_IS_ROBOTIC(affecting)))
		return FALSE
	return (species && species.has_process[organ_check])

/mob/living/carbon/human/proc/check_self_for_injuries()
	if(stat)
		return

	to_chat(src, SPAN_NOTICE("You check yourself for injuries."))

	for(var/obj/item/organ/external/org in organs)
		var/list/status = list()
		var/brutedamage = org.brute_dam
		var/burndamage = org.burn_dam
		if(halloss > 0)
			if(prob(30))
				brutedamage += halloss
			if(prob(30))
				burndamage += halloss
		switch(brutedamage)
			if(1 to 20)
				status += "bruised"
			if(20 to 40)
				status += "wounded"
			if(40 to INFINITY)
				status += "mangled"

		switch(burndamage)
			if(1 to 10)
				status += "numb"
			if(10 to 40)
				status += "blistered"
			if(40 to INFINITY)
				status += "peeling away"

		if(org.is_stump())
			status += "MISSING"
		if(org.status & ORGAN_MUTATED)
			status += "weirdly shapen"
		if(org.dislocated == 2)
			status += "dislocated"
		if(org.status & ORGAN_BROKEN)
			status += "hurts when touched"
		if(org.status & ORGAN_DEAD)
			status += "is bruised and necrotic"
		if(!org.is_usable())
			status += "dangling uselessly"

		var/status_text = SPAN_NOTICE("OK")
		if(status.len)
			status_text = SPAN_WARNING(english_list(status))

		src.show_message("My [org.name] is [status_text].",1)

/mob/living/carbon/human/need_breathe()
	if(!(mNobreath in mutations))
		return TRUE
	else
		return FALSE

/mob/living/carbon/human/proc/set_remoteview(var/atom/A)
	remoteview_target = A
	reset_view(A)

/mob/living/carbon/human/proc/resuscitate()
	var/obj/item/organ/internal/heart_organ = random_organ_by_process(OP_HEART)
	var/obj/item/organ/internal/brain_organ = random_organ_by_process(BP_BRAIN)

	if(!is_asystole() && !(heart_organ && brain_organ) || (heart_organ.is_broken() || brain_organ.is_broken()))
		return 0

	if(world.time >= (timeofdeath + NECROZTIME))
		return 0

	var/oxyLoss = getOxyLoss()
	if(oxyLoss > 20)
		setOxyLoss(20)

	if(health <= (HEALTH_THRESHOLD_DEAD - oxyLoss))
		visible_message(SPAN_WARNING("\The [src] twitches a bit, but their body is too damaged to sustain life!"))
		timeofdeath = 0
		return 0

	visible_message(SPAN_NOTICE("\The [src] twitches a bit as their heart restarts!"))
	pulse = PULSE_NORM
	handle_pulse()
	timeofdeath = 0
	stat = UNCONSCIOUS
	jitteriness += 3 SECONDS
	updatehealth()
	switch_from_dead_to_living_mob_list()
	if(mind)
		for(var/mob/observer/ghost/G in GLOB.player_list)
			if(G.can_reenter_corpse && G.mind == mind)
				if(alert("Do you want to enter your body?","Resuscitate","OH YES","No, I'm autist") == "OH YES")
					G.reenter_corpse()
					break
				else
					break
	return 1


//moved these here from code/defines/obj/weapon.dm
//please preference put stuff where it's easy to find - C

/obj/item/autopsy_scanner
	name = "autopsy scanner"
	desc = "Extracts information on wounds."
	icon = 'icons/obj/autopsy_scanner.dmi'
	icon_state = ""
	flags = CONDUCT
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 1)
	rarity_value = 50
	var/list/datum/autopsy_data_scanner/wdata = list()
	var/list/datum/autopsy_data_scanner/chemtraces = list()
	var/target_name
	var/timeofdeath

/obj/item/paper/autopsy_report
	var/list/autopsy_data

/datum/autopsy_data_scanner
	var/weapon // this is the DEFINITE weapon type that was used
	var/list/organs_scanned = list() // this maps a number of scanned organs to
									 // the wounds to those organs with this data's weapon type
	var/organ_names = ""

/datum/autopsy_data
	var/weapon
	var/pretend_weapon
	var/damage = 0
	var/hits = 0
	var/time_inflicted = 0

	proc/copy()
		var/datum/autopsy_data/W = new()
		W.weapon = weapon
		W.pretend_weapon = pretend_weapon
		W.damage = damage
		W.hits = hits
		W.time_inflicted = time_inflicted
		return W

/obj/item/autopsy_scanner/proc/add_data(var/obj/item/organ/external/O, mob/living/carbon/user)
	if(!O.autopsy_data.len && !O.trace_chemicals.len) return

	for(var/V in O.autopsy_data)
		var/datum/autopsy_data/W = O.autopsy_data[V]

		if(!W.pretend_weapon)
			/*
			// the more hits, the more likely it is that we get the right weapon type
			if(prob(50 + W.hits * 10 + W.damage))
			*/

			// Buffing this stuff up for now!
			if(prob(min(20 + (user.stats.getMult(STAT_BIO, STAT_LEVEL_EXPERT) * 100 ), 100)))
				W.pretend_weapon = W.weapon
			else
				W.pretend_weapon = pick("mechanical toolbox", "wirecutters", "revolver", "crowbar", "fire extinguisher", "tomato soup", "oxygen tank", "emergency oxygen tank", "laser", "bullet")


		var/datum/autopsy_data_scanner/D = wdata[V]
		if(!D)
			D = new()
			D.weapon = W.weapon
			wdata[V] = D

		if(!D.organs_scanned[O.name])
			if(D.organ_names == "")
				D.organ_names = O.name
			else
				D.organ_names += ", [O.name]"

		qdel(D.organs_scanned[O.name])
		D.organs_scanned[O.name] = W.copy()

	for(var/V in O.trace_chemicals)
		if(O.trace_chemicals[V] > 0 && !chemtraces.Find(V))
			chemtraces += V

/obj/item/autopsy_scanner/verb/print_data()
	set category = "Object"
	set src in view(usr, 1)
	set name = "Print Data"
	if(usr.stat)
		to_chat(usr, "You must be conscious to do that!")
		return

	if (!usr.IsAdvancedToolUser())
		return

	var/scan_data = ""

	if(timeofdeath)
		scan_data += "<b>Time of death:</b> [worldtime2stationtime(timeofdeath)]<br><br>"

	var/n = 1
	for(var/wdata_idx in wdata)
		var/datum/autopsy_data_scanner/D = wdata[wdata_idx]
		var/total_hits = 0
		var/total_score = 0
		var/list/weapon_chances = list() // maps weapon names to a score
		var/age = 0

		for(var/wound_idx in D.organs_scanned)
			var/datum/autopsy_data/W = D.organs_scanned[wound_idx]
			total_hits += W.hits

			var/wname = W.pretend_weapon

			if(wname in weapon_chances) weapon_chances[wname] += W.damage
			else weapon_chances[wname] = max(W.damage, 1)
			total_score+=W.damage


			var/wound_age = W.time_inflicted
			age = max(age, wound_age)

		var/damage_desc

		var/damaging_weapon = (total_score != 0)

		// total score happens to be the total damage
		switch(total_score)
			if(0)
				damage_desc = "Unknown"
			if(1 to 5)
				damage_desc = "<font color='green'>negligible</font>"
			if(5 to 15)
				damage_desc = "<font color='green'>light</font>"
			if(15 to 30)
				damage_desc = "<font color='orange'>moderate</font>"
			if(30 to 1000)
				damage_desc = "<font color='red'>severe</font>"

		if(!total_score) total_score = D.organs_scanned.len

		scan_data += "<b>Weapon #[n]</b><br>"
		if(damaging_weapon)
			scan_data += "Severity: [damage_desc]<br>"
			scan_data += "Hits by weapon: [total_hits]<br>"
		scan_data += "Approximate time of wound infliction: [worldtime2stationtime(age)]<br>"
		scan_data += "Affected limbs: [D.organ_names]<br>"
		scan_data += "Possible weapons:<br>"
		for(var/weapon_name in weapon_chances)
			scan_data += "\t[100*weapon_chances[weapon_name]/total_score]% [weapon_name]<br>"

		scan_data += "<br>"

		n++

	if(chemtraces.len)
		scan_data += "<b>Trace Chemicals: </b><br>"
		for(var/chemID in chemtraces)
			scan_data += chemID
			scan_data += "<br>"

	for(var/mob/O in viewers(usr))
		O.show_message(SPAN_NOTICE("\The [src] rattles and prints out a sheet of paper."), 1)

	sleep(10)

	var/obj/item/paper/autopsy_report/P = new(usr.loc)
	P.name = "Autopsy Data ([target_name])"
	P.info = "<tt>[scan_data]</tt>"
	P.autopsy_data = list() // Copy autopsy data for science tool
	for(var/wdata_idx in wdata)
		var/datum/autopsy_data_scanner/D = wdata[wdata_idx]
		for(var/wound_idx in D.organs_scanned)
			var/datum/autopsy_data/W = D.organs_scanned[wound_idx]
			P.autopsy_data += W.copy()
	P.icon_state = "paper_words"

	// place the item in the usr's hand if possible
	usr.put_in_hands(P)
	usr.setClickCooldown(DEFAULT_ATTACK_COOLDOWN*4) //To stop people spamclicking and generating tons of paper

/obj/item/autopsy_scanner/attack(mob/living/carbon/human/M, mob/living/carbon/user)
	if(!istype(M))
		return

	if(!can_operate(M, user) == CAN_OPERATE_ALL)
		to_chat(user, SPAN_WARNING("You need to lay the cadaver down on a table first!"))
		return

	if(target_name != M.name)
		target_name = M.name
		src.wdata = list()
		src.chemtraces = list()
		src.timeofdeath = null
		to_chat(user, SPAN_NOTICE("A new patient has been registered.. Purging data for previous patient."))

	src.timeofdeath = M.timeofdeath

	var/obj/item/organ/external/S = M.get_organ(user.targeted_organ)
	if(!S)
		to_chat(usr, SPAN_WARNING("You can't scan this body part."))
		return
	if(!S.open)
		to_chat(usr, SPAN_WARNING("You have to cut the limb open first!"))
		return
	for(var/mob/O in viewers(M))
		O.show_message(SPAN_NOTICE("\The [user] scans the wounds on [M.name]'s [S.name] with \the [src]"), 1)
	SEND_SIGNAL(user, COMSING_AUTOPSY, M)
	if(user.mind && user.mind.assigned_job && (user.mind.assigned_job.department in GLOB.department_moebius))
		GLOB.moebius_autopsies_mobs |= M
	src.add_data(S, user)

	return 1

/obj/item/autopsy_scanner/attack_self()
	print_data()

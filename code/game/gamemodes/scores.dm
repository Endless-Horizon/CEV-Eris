#define MAX_FACTION_SCORE 1000

//moebius
GLOBAL_VAR_INIT(moebius_score, 0)
GLOBAL_VAR_INIT(initial_moebius_score, 0)

GLOBAL_VAR_INIT(moebius_objectives_completed, 0)
GLOBAL_VAR_INIT(moebius_objectives_score, 0)

GLOBAL_VAR_INIT(moebius_faction_item_loss, 0)
GLOBAL_VAR_INIT(score_moebius_faction_item_loss, 0)


GLOBAL_VAR_INIT(crew_dead, 0)
GLOBAL_VAR_INIT(score_crew_dead, 0)


GLOBAL_VAR_INIT(research_point_gained, 0)
GLOBAL_VAR_INIT(score_research_point_gained, 0)


GLOBAL_LIST_EMPTY(moebius_autopsies_mobs)
GLOBAL_VAR_INIT(score_moebius_autopsies_mobs, 0)

//ironhammer
GLOBAL_VAR_INIT(ironhammer_score, 0)
GLOBAL_VAR_INIT(initial_ironhammer_score, 500)

GLOBAL_VAR_INIT(ironhammer_objectives_completed, 0)
GLOBAL_VAR_INIT(ironhammer_objectives_score, 0)

GLOBAL_VAR_INIT(ironhammer_faction_item_loss, 0)
GLOBAL_VAR_INIT(score_ironhammer_faction_item_loss, 0)

GLOBAL_VAR_INIT(completed_antag_contracts, 0)
GLOBAL_VAR_INIT(score_antag_contracts, 0)

GLOBAL_VAR_INIT(captured_or_dead_antags, 0)
GLOBAL_VAR_INIT(captured_or_dead_antags_score, 0)

GLOBAL_VAR_INIT(ironhammer_operative_dead, 0)
GLOBAL_VAR_INIT(ironhammer_operative_dead_score, 0)


GLOBAL_VAR_INIT(ironhammer_escaped_antagonists, 0)
GLOBAL_VAR_INIT(ironhammer_escaped_antagonists_score, 0)

//Neotheology_score
GLOBAL_VAR_INIT(neotheology_score, 0)
GLOBAL_VAR_INIT(initial_neotheology_score, 250)

GLOBAL_VAR_INIT(neotheology_objectives_completed, 0)
GLOBAL_VAR_INIT(neotheology_objectives_score, 0)

GLOBAL_VAR_INIT(score_neotheology_faction_item_loss, 0)
GLOBAL_VAR_INIT(neotheology_faction_item_loss, 0)

GLOBAL_VAR_INIT(dirt_areas, 0) // dirt areas
GLOBAL_VAR_INIT(score_mess, 0)

GLOBAL_VAR_INIT(biomatter_neothecnology_amt, 0)
GLOBAL_VAR_INIT(biomatter_score, 0)

GLOBAL_VAR_INIT(grup_ritual_performed, 0)
GLOBAL_VAR_INIT(grup_ritual_score, 0)

GLOBAL_VAR_INIT(new_neothecnology_convert_score, 0)
GLOBAL_VAR_INIT(new_neothecnology_convert, 0)

//guild
GLOBAL_VAR_INIT(initial_guild_score, 0)
GLOBAL_VAR_INIT(guild_score, 0)

GLOBAL_VAR_INIT(guild_objectives_completed, 0)
GLOBAL_VAR_INIT(guild_objectives_score, 0)

GLOBAL_VAR_INIT(guild_faction_item_loss, 0)
GLOBAL_VAR_INIT(score_guild_faction_item_loss, 0)

GLOBAL_VAR_INIT(supply_profit, 0)
GLOBAL_VAR_INIT(guild_profit_score, 0)

GLOBAL_VAR_INIT(guild_shared_gears_score, 0)
GLOBAL_VAR_INIT(guild_shared_gears, 0)

//TECHNOMANCERS
GLOBAL_VAR_INIT(technomancer_score, 0)
GLOBAL_VAR_INIT(initial_technomancer_score, 0)

GLOBAL_VAR_INIT(area_powerloss, 0) // how many APCs have poor charge?
GLOBAL_VAR_INIT(score_powerloss, 0)

GLOBAL_VAR_INIT(area_fireloss, 0) //air/fire issues
GLOBAL_VAR_INIT(score_fireloss, 0)

GLOBAL_VAR_INIT(score_ship_shield, 0)
GLOBAL_VAR_INIT(field_radius, 0)

GLOBAL_VAR_INIT(all_smes_powered, TRUE)
GLOBAL_VAR_INIT(score_smes_powered, 0)

GLOBAL_VAR_INIT(technomancer_objectives_completed, 0)
GLOBAL_VAR_INIT(score_technomancer_objectives, 0)
GLOBAL_VAR_INIT(technomancer_faction_item_loss, 0)
GLOBAL_VAR_INIT(score_technomancer_faction_item_loss, 0)

/datum/mind
	var/individual_objectives_completed = 0
	var/contracts_completed = 0

/client
	var/survive = FALSE
	var/escaped = FALSE

/datum/controller/subsystem/ticker/proc/scoreboard()
	// Score Calculation and Display
	var/list/guild_fingerprints = new
	for(var/datum/mind/M in SSticker.minds)
		if(!M.current)
			continue
		if(M.current.stat == DEAD)
			if(M.assigned_job && M.assigned_job.faction == "CEV Eris")
				if(M.assigned_job.department == DEPARTMENT_SECURITY)
					GLOB.ironhammer_operative_dead++
				if(!M.antagonist.len)
					GLOB.crew_dead++
			if(M.antagonist.len)
				GLOB.captured_or_dead_antags++
		else
			if(M.antagonist.len)
				var/area/A = get_area(M.current)
				if(istype(A, /area/eris/security/prison) || istype(A, /area/eris/security/brig) || M.current.restrained())
					GLOB.captured_or_dead_antags++
				else if(isOnAdminLevel(M.current))
					GLOB.ironhammer_escaped_antagonists++
			else if(M.assigned_job && M.assigned_job.department == DEPARTMENT_GUILD && ishuman(M.current))
				var/mob/living/carbon/human/H = M.current
				guild_fingerprints += H.get_full_print()

	for(var/mob/living/L in (GLOB.player_list & GLOB.living_mob_list))
		if(L.client)
			L.client.survive = TRUE
			if(isOnAdminLevel(L))
				L.client.escaped = TRUE
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(H.mind && H.mind.assigned_job && H.mind.assigned_job.faction == "CEV Eris" && H.mind.assigned_job.department != DEPARTMENT_GUILD && !H.mind.antagonist.len)
				for(var/obj/item/I in H.GetAllContents())
					var/full_print = H.get_full_print()
					if(full_print in guild_fingerprints)
						GLOB.guild_shared_gears++
						break

	var/obj/item/weapon/cell/large/high/HC = /obj/item/weapon/cell/large/high
	var/min_charge = initial(HC.maxcharge) * 0.6

	//Check station's power levels
	for(var/area/A in ship_areas)
		if(A.fire || A.atmosalm)
			GLOB.area_fireloss++
		if(!A.apc)
			GLOB.area_powerloss++
			continue
		for(var/obj/item/weapon/cell/C in A.apc.contents)
			if(C.charge < min_charge)
				GLOB.area_powerloss++

	var/smes_count = 0
	for(var/obj/machinery/power/smes/S in GLOB.machines)
		if(!isStationLevel(S.z)) continue
		smes_count++
		if(S.charge < S.capacity*0.7)
			GLOB.all_smes_powered = FALSE
			break
	if(smes_count == 0)
		GLOB.all_smes_powered = FALSE

	for(var/obj/machinery/power/shield_generator/S in GLOB.machines)
		if(!isStationLevel(S.z)) continue
		smes_count++
		if(!S.running) continue
		GLOB.field_radius += S.field_radius
	GLOB.field_radius = CLAMP(GLOB.field_radius, 0, world.maxx)

	//Technomancer Modifiers
	if(GLOB.all_smes_powered)
		GLOB.score_smes_powered = 350 //max = 350
	GLOB.score_technomancer_objectives = GLOB.technomancer_objectives_completed * 25 //max: ~= 100
	GLOB.score_ship_shield = 2 * GLOB.field_radius //max ~= 500
	GLOB.score_fireloss -= GLOB.area_fireloss * 25
	GLOB.score_powerloss -= GLOB.area_powerloss * 25
	GLOB.score_technomancer_faction_item_loss -= 150 * GLOB.technomancer_faction_item_loss

	GLOB.technomancer_score = GLOB.initial_technomancer_score + GLOB.score_smes_powered + GLOB.score_technomancer_objectives + GLOB.score_ship_shield + GLOB.score_fireloss + GLOB.score_powerloss + GLOB.score_technomancer_faction_item_loss

	// NeoTheology score
	var/list/dirt_areas = list()
	//Check how much uncleaned mess is on the station
	for(var/obj/effect/decal/cleanable/M in world)
		if(!isStationLevel(M.z)) continue
		var/area/A = get_area(M)
		if(A in dirt_areas) continue
		if(!(A in ship_areas)) continue
		if(A.is_maintenance) continue
		dirt_areas += A
	GLOB.dirt_areas = dirt_areas.len


	//NeoTheology Modifiers
	GLOB.score_neotheology_faction_item_loss -= GLOB.neotheology_faction_item_loss * 150 //300
	GLOB.neotheology_objectives_score = GLOB.neotheology_objectives_completed * 25 // ~100
	GLOB.score_mess -= GLOB.dirt_areas * 10 //~250
	GLOB.biomatter_score = round(GLOB.biomatter_neothecnology_amt/50) //350?  //target_max~350//
	GLOB.grup_ritual_score += GLOB.grup_ritual_performed * 5
	GLOB.new_neothecnology_convert_score = GLOB.new_neothecnology_convert * 50 // ~150-300

	GLOB.neotheology_score = GLOB.initial_neotheology_score + GLOB.score_neotheology_faction_item_loss + GLOB.neotheology_objectives_score + GLOB.score_mess + GLOB.grup_ritual_score + GLOB.biomatter_score + GLOB.new_neothecnology_convert_score


	//Moebius score
	GLOB.score_moebius_faction_item_loss -= GLOB.moebius_faction_item_loss * 150 //300
	GLOB.moebius_objectives_score = GLOB.moebius_objectives_completed * 25 // ~100
	GLOB.score_crew_dead -=	GLOB.crew_dead * 25 // ~200
	GLOB.score_research_point_gained = round(GLOB.research_point_gained/200) // or GLOB.research_point_gained/1000? review it //target_max~500//
	GLOB.score_moebius_autopsies_mobs = GLOB.moebius_autopsies_mobs.len * 15 // ~75

	GLOB.moebius_score = GLOB.initial_moebius_score + GLOB.score_moebius_faction_item_loss + GLOB.moebius_objectives_score + GLOB.score_crew_dead + GLOB.score_research_point_gained + GLOB.score_moebius_autopsies_mobs

	//Ironhammer score
	GLOB.score_ironhammer_faction_item_loss -= 150 * GLOB.ironhammer_faction_item_loss
	GLOB.ironhammer_objectives_score = GLOB.ironhammer_objectives_completed * 25
	GLOB.score_antag_contracts -= GLOB.completed_antag_contracts * 30
	GLOB.ironhammer_operative_dead_score -= GLOB.ironhammer_operative_dead * 50
	GLOB.captured_or_dead_antags_score = 100 * GLOB.captured_or_dead_antags
	GLOB.ironhammer_escaped_antagonists_score -= GLOB.ironhammer_escaped_antagonists * 100

	GLOB.ironhammer_score = GLOB.initial_ironhammer_score + GLOB.ironhammer_objectives_score + GLOB.score_antag_contracts + GLOB.ironhammer_operative_dead_score + GLOB.captured_or_dead_antags_score

	//Guild score
	GLOB.score_guild_faction_item_loss -= 150 * GLOB.guild_faction_item_loss // ~-300
	GLOB.guild_objectives_score = GLOB.guild_objectives_completed * 25 // ~100
	GLOB.guild_profit_score	= round(GLOB.supply_profit/50) // ? review it //target_max~500//
	GLOB.guild_shared_gears_score = GLOB.guild_shared_gears * 30 // ~150-300

	GLOB.guild_score = GLOB.initial_guild_score + GLOB.guild_objectives_score + GLOB.guild_profit_score


	for(var/mob/E in GLOB.player_list)
		if(E.mind)
			E.scorestats()

/proc/get_color_score(msg, score, maxscore=MAX_FACTION_SCORE)
	if(score >= maxscore*0.5)
		return "<font color='green'>[msg]</font>"
	return "<font color='red'>[msg]</font>"

/proc/to_score_color(nnum)
	if(nnum > 0)
		return green_text(nnum)
	if(nnum < 0)
		return red_text(nnum)
	return "[nnum]"

/proc/green_text(msg)
	return "<font color='green'>[msg]</font>"

/proc/red_text(msg)
	return "<font color='red'>[msg]</font>"

/mob/proc/scorestats()
	var/dat = "<b>Faction Scores</b><br><hr><br>"

	//ironhammer
	dat += {"
	<u>Ironhammer scores</u><br>
	<b>Base score:</b> [green_text(GLOB.initial_ironhammer_score)]<br>
	<b>Lost faction items:</b> [GLOB.ironhammer_faction_item_loss] ([to_score_color(GLOB.score_ironhammer_faction_item_loss)] Points)<br>
	<b>Faction objectives completed:</b> [GLOB.ironhammer_objectives_completed] ([to_score_color(GLOB.ironhammer_objectives_score)] Points)<br>
	<b>Antagonist contracts completed:</b> [GLOB.completed_antag_contracts] ([to_score_color(GLOB.score_antag_contracts)] Points)<br>
	<b>Antagonists killed or captured:</b> [GLOB.captured_or_dead_antags] ([to_score_color(GLOB.captured_or_dead_antags_score)] Points)<br>
	<b>Escaped Antagonists:</b> [GLOB.ironhammer_escaped_antagonists] ([to_score_color(GLOB.ironhammer_escaped_antagonists_score)] Points)<br>
	<b>IH operatives killed:</b> [GLOB.ironhammer_operative_dead] ([to_score_color(GLOB.ironhammer_operative_dead_score)] Points)<br>
	<b>Final Ironhammer score:</b> [get_color_score(GLOB.ironhammer_score, GLOB.ironhammer_score)] Points<br><br>
	"}

	//moebius
	dat += {"
	<u>Moebius scores</u><br>
	<b>Base score:</b> [green_text(GLOB.initial_moebius_score)]<br>
	<b>Lost faction items:</b> [GLOB.moebius_faction_item_loss] ([to_score_color(GLOB.score_moebius_faction_item_loss)] Points)<br>
	<b>Faction objectives completed:</b> [GLOB.moebius_objectives_completed] ([to_score_color(GLOB.moebius_objectives_score)] Points)<br>
	<b>Dead crew:</b> [GLOB.crew_dead] ([to_score_color(GLOB.score_crew_dead)] Points)<br>
	<b>Research points gained:</b> [GLOB.research_point_gained] ([to_score_color(GLOB.score_research_point_gained)] Points)<br>
	<b>Autopsies performed:</b> [GLOB.moebius_autopsies_mobs.len] ([to_score_color(GLOB.score_moebius_autopsies_mobs)] Points)<br>
	<b>Final Moebius score:</b> [get_color_score(GLOB.moebius_score, GLOB.moebius_score)] Points<br><br>
	"}

	//nt
	dat += {"
	<u>NeoTheology scores</u><br>
	<b>Base score:</b> [green_text(GLOB.initial_neotheology_score)]<br>
	<b>Lost faction items:</b> [GLOB.neotheology_faction_item_loss] ([to_score_color(GLOB.score_neotheology_faction_item_loss)] Points)<br>
	<b>Faction objectives completed:</b> [GLOB.neotheology_objectives_completed] ([to_score_color(GLOB.neotheology_objectives_score)] Points)<br>
	<b>Dirty areas:</b> [GLOB.dirt_areas] ([to_score_color(GLOB.score_mess)] Points)<br>
	<b>Biomatter produced:</b> [GLOB.biomatter_neothecnology_amt] ([to_score_color(GLOB.biomatter_score)] Points)<br>
	<b>Total of conversions:</b> [GLOB.new_neothecnology_convert] ([to_score_color(GLOB.new_neothecnology_convert_score)] Points)<br>
	<b>Group rituals performed:</b> [GLOB.grup_ritual_performed] ([to_score_color(GLOB.grup_ritual_score)] Points)<br>
	<b>Final Neotheology score:</b> [get_color_score(GLOB.neotheology_score, GLOB.neotheology_score)] Points<br><br>
	"}

	//guild
	dat += {"
	<u>Guild scores</u><br>
	<b>Base score:</b> [green_text(GLOB.initial_guild_score)]<br>
	<b>Lost faction items:</b> [GLOB.guild_faction_item_loss] ([to_score_color(GLOB.score_guild_faction_item_loss)] Points)<br>
	<b>Faction objectives completed:</b> [GLOB.guild_objectives_completed] ([to_score_color(GLOB.guild_objectives_score)] Points)<br>
	<b>Profit profits:</b> [GLOB.supply_profit] ([to_score_color(GLOB.guild_profit_score)] Points)<br>
	<b>Crew with items distributed by the Guild:</b> [GLOB.guild_shared_gears] ([to_score_color(GLOB.guild_shared_gears_score)] Points)<br>
	<b>Final Guild score:</b> [get_color_score(GLOB.guild_score, GLOB.guild_score)] Points<br><br><br>
	"}

	//Technomancers
	dat += {"
	<u>Technomancers scores</u><br>
	<b>Base score:</b> [green_text(GLOB.initial_technomancer_score)]<br>
	<b>Faction objectives completed:</b> [GLOB.technomancer_objectives_completed] ([to_score_color(GLOB.score_technomancer_objectives)] Points)<br>
	<b>All SMES Charged:</b> [GLOB.all_smes_powered ? "Yes" : "No"] ([to_score_color(GLOB.score_smes_powered)] Points)<br>
	<b>Ship shield range:</b> [GLOB.field_radius] ([to_score_color(GLOB.score_ship_shield)] Points)<br>
	<b>Lost faction items:</b> [GLOB.technomancer_faction_item_loss] ([to_score_color(GLOB.score_technomancer_faction_item_loss)] Points)<br>
	<b>Unpowered areas:</b> [GLOB.area_powerloss] ([to_score_color(GLOB.score_powerloss)] Points)<br>
	<b>Areas with atmospheric problems:</b> [GLOB.area_fireloss] ([to_score_color(GLOB.score_fireloss)] Points)<br>
	<b>Final Technomancers score:</b> [get_color_score(GLOB.technomancer_score, GLOB.technomancer_score)] Points<br><br>
	"}

	dat += "<br><hr>"
	dat += "<b><u>Personal Score</u></b><br><hr>"
	var/objectives_score = mind.individual_objectives_completed * 20
	var/contracts_score = mind.contracts_completed * 20
	var/survive_score = 0
	var/scaped_score = 0
	if(client.survive)
		survive_score += 300
		if(client.escaped)
			scaped_score += 200

	var/final_score = objectives_score + contracts_score + survive_score + scaped_score
	var/max_personal_score = 1000

	dat += {"
	<b>Personal Objectives completed:</b> [mind.individual_objectives_completed] ([to_score_color(objectives_score)] Points)<br>
	<b>Antagonist contracts completed:</b> [mind.contracts_completed] ([to_score_color(contracts_score)] Points)<br>
	<b>Survive:</b> [client.survive ? "Yes" : "No"] ([to_score_color(survive_score)] Points)<br>
	<b>Escape:</b> [client.escaped ? "Yes" : "No"] ([to_score_color(scaped_score)] Points)<br>
	<b>Final personal score:</b> [get_color_score(final_score, final_score, max_personal_score)] Points<br><br>
	"}

	if(is_scored_departmen())
		final_score += get_faction_score()
		max_personal_score += MAX_FACTION_SCORE

	dat += "<br><hr>"
	dat += "<b><u>Your total score is:</u></b> [get_color_score(final_score, final_score, max_personal_score)] Points<br>"

	src << browse(dat, "window=roundstats;size=500x600")

/mob/proc/get_faction_score()
	if(mind && mind.assigned_job && mind.assigned_job.department)
		if(mind.assigned_job.department == DEPARTMENT_MEDICAL || mind.assigned_job.department == DEPARTMENT_SCIENCE)
			return GLOB.moebius_score
		else if(mind.assigned_job.department == DEPARTMENT_SECURITY)
			return GLOB.ironhammer_score
		else if(mind.assigned_job.department == DEPARTMENT_ENGINEERING)
			return GLOB.technomancer_score
		else if(mind.assigned_job.department == DEPARTMENT_GUILD)
			return GLOB.guild_score
		else if(mind.assigned_job.department == DEPARTMENT_CHURCH)
			return GLOB.neotheology_score

/mob/proc/is_scored_departmen()
	. = FALSE
	if(mind && mind.assigned_job && mind.assigned_job.department)
		switch(mind.assigned_job.department)
			if(DEPARTMENT_MEDICAL)
				. = TRUE
			if(DEPARTMENT_SCIENCE)
				. = TRUE
			if(DEPARTMENT_SECURITY)
				. = TRUE
			if(DEPARTMENT_ENGINEERING)
				. = TRUE
			if(DEPARTMENT_GUILD)
				. = TRUE
			if(DEPARTMENT_CHURCH)
				. = TRUE

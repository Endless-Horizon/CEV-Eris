
//Sets the storyteller to a new one, and does any heavy lifting for a handover
/proc/set_storyteller(var/datum/storyteller/newST, var/announce = TRUE)
	if (!newST)
		//You can call this without passing anything, we'll go fetch it ourselves
		newST = config.pick_storyteller(STORYTELLER_BASE) //This function is in code/controllers/configuration.dm

	if (!istype(newST))
		if(!istext(newST)) //Welp that failed
			return

		if(!GLOB.storyteller_cache[newST])
			return
		else
			newST = GLOB.storyteller_cache[newST]

	if (get_storyteller() == newST)
		return //Nothing happens if we try to set to the storyteller we already have

	//If there's an existing storyteller, we'll make it do cleanup procedures before the handover
	//we cache it now so we can do that soon
	var/datum/storyteller/oldST = get_storyteller()

	//Finally, we set the new one //and it's set globally.
	GLOB.storyteller = newST

	if (oldST != null)
		GLOB.storyteller.points = oldST.points.Copy()//Transfer over points
		//TODO: Cleanup and handover

	//Configure the new storyteller
	GLOB.storyteller.set_up()

	if (announce)
		GLOB.storyteller.announce()


/proc/get_storyteller()
	RETURN_TYPE(/datum/storyteller)
	return GLOB.storyteller

/datum/storyteller/proc/update_crew_count()
	if(debug_mode)
		return

	crew = 0
	heads = 0
	sec = 0
	eng = 0
	med = 0
	sci = 0

	for(var/mob/M in GLOB.player_list)
		if(M.client && (M.mind && !M.mind.antagonist.len) && M.stat != DEAD && (ishuman(M) || isrobot(M) || isAI(M)))
			var/datum/job/job = SSjob.GetJob(M.mind.assigned_role)
			if(job)
				crew++
				if(job.head_position)
					heads++
				if(job.department == "Engineering")
					eng++
				if(job.department == "Security")
					sec++
				if(job.department == "Medical")
					med++
				if(job.department == "Science")
					sci++



/datum/storyteller/proc/calculate_event_weight(var/datum/storyevent/R)
	var/new_weight = R.weight

	new_weight *= weight_mult(crew,R.req_crew)
	new_weight *= weight_mult(heads,R.req_heads)
	new_weight *= weight_mult(sec,R.req_sec)
	new_weight *= weight_mult(eng,R.req_eng)
	new_weight *= weight_mult(med,R.req_med)
	new_weight *= weight_mult(sci,R.req_sci)

	new_weight = R.get_special_weight(new_weight)

	//Factoring in tag-based weight modifiers
	//Each storyteller has different tag weights
	for (var/etag in tag_weight_mults)
		if (etag in R.tags)
			new_weight *= tag_weight_mults[etag]

	return new_weight


/datum/storyteller/proc/calculate_event_cost(var/datum/storyevent/R, var/severity)
	var/new_cost = R.get_cost(severity)

	//Factoring in tag-based cost modifiers
	//Each storyteller has different tag weights
	for (var/etag in tag_cost_mults)
		if (etag in R.tags)
			new_cost *= tag_cost_mults[etag]

	return new_cost

/datum/storyteller/proc/weight_mult(var/val, var/req)
	if(req <= 0)
		return 1
	if(val <= 0)	//We need to spawn anything
		return 0.75/req
	return 1-((max(0,req-val)**3)/(req**3))


//Since severity are no longer numbers, we need a proc for incrementing it
/proc/get_next_severity(var/input)
	switch (input)
		if (EVENT_LEVEL_MUNDANE)
			return EVENT_LEVEL_MODERATE
		if (EVENT_LEVEL_MODERATE)
			return EVENT_LEVEL_MAJOR
		if (EVENT_LEVEL_MAJOR)
			return EVENT_LEVEL_ROLESET
	return input



var/list/event_last_fired = list()

// Returns how many characters are currently active(not logged out, not AFK for more than 10 minutes)
// with a specific role.
// Note that this isn't sorted by department, because e.g. having a roboticist shouldn't make meteors spawn.
/proc/number_active_with_role()
	var/list/active_with_role = list()
	active_with_role["Engineer"] = 0
	active_with_role["Medical"] = 0
	active_with_role["Security"] = 0
	active_with_role["Scientist"] = 0
	active_with_role["AI"] = 0
	active_with_role["Robot"] = 0
	active_with_role["Janitor"] = 0
	active_with_role["Gardener"] = 0

	for(var/mob/M in GLOB.player_list)
		// longer than 10 minutes AFK counts them as inactive
		if(!M.mind || !M.client || M.client.is_afk(10 MINUTES))
			continue

		active_with_role["Any"]++

		if(isrobot(M))
			var/mob/living/silicon/robot/R = M
			if(R.module)
				if(istype(R.module, /obj/item/robot_module/engineering))
					active_with_role["Engineer"]++
				else if(istype(R.module, /obj/item/robot_module/security))
					active_with_role["Security"]++
				else if(istype(R.module, /obj/item/robot_module/medical))
					active_with_role["Medical"]++
				else if(istype(R.module, /obj/item/robot_module/research))
					active_with_role["Scientist"]++

		if(M.mind.assigned_role in engineering_positions)
			active_with_role["Engineer"]++

		if(M.mind.assigned_role in medical_positions)
			active_with_role["Medical"]++

		if(M.mind.assigned_role in security_positions)
			active_with_role["Security"]++

		if(M.mind.assigned_role in science_positions)
			active_with_role["Scientist"]++

		if(M.mind.assigned_role == "AI")
			active_with_role["AI"]++

		if(M.mind.assigned_role == "Robot")
			active_with_role["Robot"]++

		if(M.mind.assigned_role == "Janitor")
			active_with_role["Janitor"]++

		if(M.mind.assigned_role == "Gardener")
			active_with_role["Gardener"]++

	return active_with_role

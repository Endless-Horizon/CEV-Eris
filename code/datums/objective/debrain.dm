/datum/objective/debrain

/datum/objective/debrain/update_exploration()
	if(target && target.current)
		explanation_text = "Steal the brain of [target.current.real_name]."
	else
		explanation_text = "Target has not arrived today. Did he know that I would come?"

/datum/objective/debrain/check_completion()
	if(!target) //If it's a free objective.
		return TRUE
	if(!owner.current || owner.current.stat == DEAD)//If you're otherwise dead.
		return FALSE
	if(!target.current || !isbrain(target.current))
		return FALSE
	var/atom/A = target.current
	while(A.loc)			//check to see if the brainmob is on our person
		A = A.loc
		if(A == owner.current)
			return TRUE
	return FALSE

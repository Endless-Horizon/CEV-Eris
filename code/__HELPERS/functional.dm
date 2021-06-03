/proc/all_predicates_true(list/input, list/predicates)
	predicates = istype(predicates) ? predicates : list(predicates)

	for(var/i = 1 to predicates.len)
		if(istype(input))
			if(!call(predicates[i])(arglist(input)))
				return FALSE
		else
			if(!call(predicates[i])(input))
				return FALSE
	return TRUE

/proc/any_predicate_true(list/input, list/predicates)
	functional_sanity(input, predicates)

	if(!predicates.len)
		return TRUE

	for(var/i = 1 to predicates.len)
		if(call(predicates[i])(arglist(input)))
			return TRUE
	return FALSE

/proc/functional_sanity(list/input, list/predicates)
	if(!istype(input))
		CRASH("Expected list input. Was [input ? "[input.type]" : "null"]")
	if(!istype(predicates))
		CRASH("Expected predicate list. Was [predicates ? "[predicates.type]" : "null"]")

/proc/can_locate(atom/container, container_thing)
	return (locate(container_thing) in container)

/proc/can_not_locate(atom/container, container_thing)
	return !(locate(container_thing) in container) // We could just do !can_locate(container, container_thing) but BYOND is pretty awful when it comes to deep proc calls

/proc/where(list/list_to_filter, list/predicates, list/extra_predicate_input)
	. = list()
	for(var/entry in list_to_filter)
		var/predicate_input
		if(extra_predicate_input)
			predicate_input = (list(entry) + extra_predicate_input)
		else
			predicate_input = entry

		if(all_predicates_true(predicate_input, predicates))
			. += entry

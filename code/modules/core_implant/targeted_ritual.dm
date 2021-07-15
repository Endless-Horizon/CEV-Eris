#define TARGET_PATTERN "\\\[Target .*?\\]"
#define TARGET_TEXT "\[Target words]"
#define TARGET_CANCEL "\[CANCEL]"

/datum/ritual/targeted
	name = "targeted ritual"
	desc = "Basic ritual that does nothing."
	phrase = null

/datum/ritual/targeted/get_say_phrase()
	if(!phrase || phrase == "")
		return

	var/regex/R = regex("([TARGET_PATTERN])","g")

	var/list/G = list()

	while(R.Find(phrase))
		G |= R.group

	var/final_phrase = phrase

	for(var/i = 1; i<=length(G); i+=1)
		var/list/CL = list()
		var/address = null
		if(G[i] != TARGET_TEXT)
			for(var/obj/item/implant/core_implant/C in world)
				C.update_address()
				if(istype(C, implant_type) && C.address && (get_turf(C) in view()))
					CL.Add(C.address)

			CL.Add(TARGET_CANCEL)
			if(CL.len)
				address = input("Select [copytext(G[i],2,-1)]","Ritual target",null) in CL

			if(!address || address == TARGET_CANCEL)
				return
		else
			address = input("Type words","Words","")

		final_phrase = replacetextEx(final_phrase,G[i],address)
	return final_phrase

/datum/ritual/targeted/get_display_phrase()
	return phrase

/datum/ritual/targeted/compare(var/text)
	if(!phrase || phrase == "")
		return

	var/regex/R = regex("([TARGET_PATTERN])","g")

	var/T = replacetext(R.Replace(REGEX_QUOTE(phrase),".*"),"\\.*",".*")

	R = regex(T)

	R.Find(text)

	return R.index != null && R.index > 0

/datum/ritual/targeted/get_targets(var/text)
	var/regex/R = regex("[TARGET_PATTERN]","g")

	var/T = replacetext(R.Replace(REGEX_QUOTE(phrase),"(.*)"),"\\(.*)","(.*)")

	R = regex(T,"g")

	var/list/G = list()

	while(R.Find(text))
		G |= R.group

	var/list/targets = list()
	var/i = 1
	for(var/AD in G)
		for(var/obj/item/implant/core_implant/C in world)
			if(istype(C, implant_type) && C.loc)
				var/target = process_target(i,C,AD)
				if(target)
					targets.Add(target)
		i += 1

	return targets

//returns object that will be placed in targets list, of null
/datum/ritual/targeted/proc/process_target(var/index, var/obj/item/implant/core_implant/target, var/text)
	return TRUE


/datum/antagonist/excelsior
	id = ROLE_EXCELSIOR_REV
	role_text = "Excelsior Infiltrator"
	role_text_plural = "Infiltrators"
	bantype = ROLE_BANTYPE_EXCELSIOR
	welcome_text = "Viva la revolution!"
	antaghud_indicator = "hudexcelsior"

	faction_id = FACTION_EXCELSIOR
	allow_neotheology = FALSE //Implant causes head asplode

	story_ineligible = list(JOBS_SECURITY, JOBS_COMMAND)

	stat_modifiers = list(
		STAT_ROB = 5,
		STAT_TGH = 5,
		STAT_MEC = 10,
		STAT_COG = 5,
		STAT_VIG = 15
	)

/datum/antagonist/excelsior/equip()
	.=..()

	// Makes sures to exclude the leader implant when used with implanter
	for(var/obj/O in owner.current)
		if(istype(O, /obj/item/implant/excelsior))
			return

	var/obj/item/implant/excelsior/leader/implant = new(owner.current)
	implant.install(owner.current, BP_HEAD)

	var/mob/living/L = owner.current

	for(var/name in stat_modifiers)
		L.stats.changeStat(name, stat_modifiers[name])

/datum/antagonist/excelsior/create_antagonist(datum/mind/target, datum/faction/new_faction, doequip = TRUE, announce = TRUE, update = TRUE, check = TRUE)
	. = ..()
	BITSET(owner.current.hud_updateflag, EXCELSIOR_HUD)

/datum/antagonist/excelsior/remove_antagonist()
	. = ..()
	BITSET(owner.current.hud_updateflag, EXCELSIOR_HUD)

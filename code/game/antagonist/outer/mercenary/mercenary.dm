/datum/antagonist/mercenary
	id = ROLE_MERCENARY
	bantype = ROLE_MERCENARY
	faction_id = FACTION_SERBS
	role_text = "Serbian Mercenary"
	welcome_text = WELCOME_SERBS
	antaghud_indicator = "hudoperative"
	landmark_id = "mercenary-spawn"
	outer = TRUE

	default_access = list(access_mercenary,//This access governs their ship and base
	access_external_airlocks,
	access_maint_tunnels) //Mercs get maintenance access on eris, because being an antag without it is hell
	//They got forged assistant IDs or somesuch
	id_type = /obj/item/weapon/card/id/merc


	appearance_editor = FALSE


	possible_objectives = list()
	survive_objective = null

	stat_modifiers = list(
		STAT_ROB = 30,
		STAT_TGH = 30,
		STAT_VIG = 30,
		STAT_BIO = 10,
		STAT_MEC = 20
	)

	perks = list(PERK_SURVIVOR)

/datum/antagonist/mercenary/equip()
	var/mob/living/L = owner.current

	//Put on the fatigues. Armor not included, they equip that manually from the merc base
	var/decl/hierarchy/outfit/O = outfit_by_type(/decl/hierarchy/outfit/antagonist/mercenary/casual)
	O.equip(L)

	//Set their language, This also adds it to their list
	L.set_default_language(LANGUAGE_SERBIAN)

	//Normal mercs can't speak common
	L.remove_language(LANGUAGE_COMMON)

	//And we'll give them a random serbian name to start off with
	var/datum/language/lang = all_languages[LANGUAGE_SERBIAN]
	lang.set_random_name(L)

	//the missingg parrt was antag's stats!
	for(var/name in stat_modifiers)
		L.stats.changeStat(name, stat_modifiers[name])

	for(var/perk in perks)
		L.stats.addPerk(perk)

	create_id("Soldier")
	..()

/datum/antagonist/mercenary/greet()
	if(!owner || !owner.current)
		return

	owner.current << 'sound/misc/SerbAlert.ogg'

/obj/item/weapon/card/id/merc
	icon_state = "syndicate"

/obj/item/weapon/card/id/merc/Initialize(mapload)
	. = ..()
	access = list(access_mercenary,//This access governs their ship and base
	access_external_airlocks,
	access_maint_tunnels)



#undef WELCOME_SERBS

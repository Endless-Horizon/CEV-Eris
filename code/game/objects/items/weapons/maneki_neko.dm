/obj/item/maneki_neko
	name = "Ancient Maneki Neko"
	icon = 'icons/obj/faction_item.dmi'
	icon_state = "maneki_neko"
	item_state = "maneki_neko"
	desc = "Costs a lot of money, this is ancient relic with no practical purpose. Feels like it's looking at you, with menacingly gaze. Fragile."
	flags = CONDUCT
	force = WEAPON_FORCE_WEAK
	w_class = ITEM_SIZE_SMALL
	throwforce = WEAPON_FORCE_WEAK
	throw_speed = 3
	throw_range = 15
	price_tag = 20000
	origin_tech = list(TECH_MATERIAL = 10)
	spawn_frequency = 0
	spawn_blacklisted = TRUE
	var/affect_radius = 7
	matter = list(MATERIAL_GLASS = 5, MATERIAL_GOLD = 7, MATERIAL_SILVER = 5, MATERIAL_DIAMOND = 1)
	var/list/mob/living/carbon/human/followers = list()

/obj/item/maneki_neko/New()
	GLOB.all_faction_items[src] = GLOB.department_guild
	START_PROCESSING(SSobj, src)
	..()

/obj/item/maneki_neko/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(!istype(src.loc, /obj/item/storage/bsdm))
		destroy_lifes()
	for(var/mob/living/carbon/human/H in viewers(get_turf(src)))
		SEND_SIGNAL(H, COMSIG_OBJ_FACTION_ITEM_DESTROY, src)
	GLOB.all_faction_items -= src
	GLOB.guild_faction_item_loss++
	..()

/obj/item/maneki_neko/Process()
	for(var/list/mob/living/carbon/human/affected in oviewers(affect_radius, src))
		followers |= affected

/obj/item/maneki_neko/attackby(obj/item/W, mob/user, params)
	if(nt_sword_attack(W, user))
		return FALSE

	if(QUALITY_HAMMERING in W.tool_qualities)
		if(W.use_tool(user, src, WORKTIME_INSTANT, QUALITY_HAMMERING, FAILCHANCE_EASY, required_stat = STAT_ROB))
			playsound(src, "shatter", 70, 1)
			new /obj/item/clothing/head/collectable/kitty(get_turf(src))
			qdel(src)

/obj/item/maneki_neko/afterattack(obj/target, mob/user, var/flag)
	if(user.a_intent == I_HURT)
		playsound(src, "shatter", 70, 1)
		new /obj/item/clothing/head/collectable/kitty(get_turf(src))
		qdel(src)

/obj/item/maneki_neko/throw_impact(atom/hit_atom)
	..()
	playsound(src, "shatter", 70, 1)
	new /obj/item/clothing/head/collectable/kitty(get_turf(src))
	qdel(src)

/obj/item/maneki_neko/proc/destroy_lifes()
	for(var/mob/living/carbon/human/H in followers)
		H.sanity.insight = 0
		H.sanity.environment_cap_coeff = 0
		H.sanity.negative_prob += 30
		H.sanity.positive_prob = 0
		H.sanity.level = 0
		for(var/stat in ALL_STATS)
			H.stats.changeStat(stat, -10)
		var/neko = uppertext(src.name)
		to_chat(H, SPAN_DANGER(pick("LIFE IS RUINED FOR ME! I CANNOT FIND [neko]!", "WHO STEAL MY [neko]!", "WHERE IS [neko]?!", "WHY I CANNOT FIND [neko]?!")))

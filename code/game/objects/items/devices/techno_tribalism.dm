/obj/item/device/techno_tribalism
	name = "Techno-Tribalism Enforcer"
	desc = "Feeds on rare tools, tool mods and other tech items. After being fed enough, will produce a strange technological part, that will be useful to train your skills overtime."
	icon = 'icons/obj/faction_item.dmi'
	icon_state = "techno_tribalism"
	item_state = "techno_tribalism"
	origin_tech = list(TECH_MATERIAL = 8, TECH_ENGINEERING = 7, TECH_POWER = 2)
	price_tag = 20000
	spawn_frequency = 0
	spawn_blacklisted = TRUE
	var/list/oddity_stats = list(STAT_MEC = 0, STAT_COG = 0, STAT_BIO = 0, STAT_ROB = 0, STAT_TGH = 0, STAT_VIG = 0)
	var/last_produce = -30 MINUTES
	var/items_count = 0
	var/max_count = 5
	var/cooldown = 30 MINUTES

/obj/item/device/techno_tribalism/New()
	..()
	GLOB.all_faction_items[src] = GLOB.department_engineering

/obj/item/device/techno_tribalism/Destroy()
	for(var/mob/living/carbon/human/H in viewers(get_turf(src)))
		SEND_SIGNAL(H, COMSIG_OBJ_FACTION_ITEM_DESTROY, src)
	GLOB.all_faction_items -= src
	GLOB.technomancer_faction_item_loss++
	..()

/obj/item/device/techno_tribalism/attackby(obj/item/W, mob/user, params)
	if(nt_sword_attack(W, user))
		return FALSE
	if(items_count < max_count)
		if(W in GLOB.all_faction_items)
			if(GLOB.all_faction_items[W] == GLOB.department_moebius)
				oddity_stats[STAT_COG] += 3
				oddity_stats[STAT_BIO] += 3
				oddity_stats[STAT_MEC] += 3
			else if(GLOB.all_faction_items[W] == GLOB.department_security)
				oddity_stats[STAT_VIG] += 3
				oddity_stats[STAT_TGH] += 3
				oddity_stats[STAT_ROB] += 3
			else if(GLOB.all_faction_items[W] == GLOB.department_church)
				oddity_stats[STAT_BIO] += 3
				oddity_stats[STAT_COG] += 2
				oddity_stats[STAT_VIG] += 2
				oddity_stats[STAT_TGH] += 2
			else if(GLOB.all_faction_items[W] == GLOB.department_guild)
				oddity_stats[STAT_COG] += 3
				oddity_stats[STAT_MEC] += 3
				oddity_stats[STAT_ROB] += 1
				oddity_stats[STAT_VIG] += 2
			else if(GLOB.all_faction_items[W] == GLOB.department_engineering)
				oddity_stats[STAT_MEC] += 5
				oddity_stats[STAT_COG] += 2
				oddity_stats[STAT_TGH] += 1
				oddity_stats[STAT_VIG] += 1
			else if(GLOB.all_faction_items[W] == GLOB.department_command)
				oddity_stats[STAT_ROB] += 2
				oddity_stats[STAT_TGH] += 1
				oddity_stats[STAT_BIO] += 1
				oddity_stats[STAT_MEC] += 1
				oddity_stats[STAT_VIG] += 3
				oddity_stats[STAT_COG] += 1
			else if(GLOB.all_faction_items[W] == GLOB.department_civilian)
				oddity_stats[STAT_BIO] += 3
				oddity_stats[STAT_VIG] += 2
				oddity_stats[STAT_COG] += 2
			else
				crash_with("[W], incompatible department")

		else if(istool(W))
			var/useful = FALSE
			if(W.tool_qualities)

				for(var/quality in W.tool_qualities)

					if(W.tool_qualities[quality] >= 35)
						var/stat_cost = round(W.tool_qualities[quality] / 15)
						if(quality == QUALITY_BOLT_TURNING || quality == QUALITY_SCREW_DRIVING || quality == QUALITY_CUTTING)
							oddity_stats[STAT_COG] += stat_cost
							useful = TRUE

						else if (quality == QUALITY_PULSING || quality == QUALITY_ADHESIVE || quality == QUALITY_SEALING)
							oddity_stats[STAT_MEC] += stat_cost
							useful = TRUE

						else if (quality == QUALITY_PRYING || quality == QUALITY_HAMMERING || quality == QUALITY_DIGGING)
							oddity_stats[STAT_ROB] += stat_cost
							useful = TRUE

						else if (quality == QUALITY_WELDING || quality == QUALITY_WIRE_CUTTING || quality == QUALITY_SAWING || quality == QUALITY_LASER_CUTTING)
							oddity_stats[STAT_VIG] += stat_cost
							useful = TRUE

						else if (quality == QUALITY_CLAMPING || quality == QUALITY_CAUTERIZING || quality == QUALITY_RETRACTING || quality == QUALITY_BONE_SETTING)
							oddity_stats[STAT_BIO] += stat_cost
							useful = TRUE

						else if (quality == QUALITY_DRILLING || quality == QUALITY_SHOVELING || quality == QUALITY_EXCAVATION)
							oddity_stats[STAT_TGH] += stat_cost
							useful = TRUE

				if(!useful)
					to_chat(user, SPAN_WARNING("The [W] is not suitable for [src]!"))
					return
			else
				to_chat(user, SPAN_WARNING("The [W] is not suitable for [src]!"))
				return


		else if(istype(W, /obj/item/tool_upgrade))

			var/obj/item/tool_upgrade/T = W

			if(istype(T, /obj/item/tool_upgrade/reinforcement))
				oddity_stats[STAT_TGH] += 3

			else if(istype(T, /obj/item/tool_upgrade/productivity))
				oddity_stats[STAT_COG] += 3

			else if(istype(T, /obj/item/tool_upgrade/refinement))
				oddity_stats[STAT_VIG] += 3

			else if(istype(T, /obj/item/tool_upgrade/augment))
				oddity_stats[STAT_BIO] += 3


		else if(istype(W, /obj/item/cell))
			if(istype(W, /obj/item/cell/small/moebius/nuclear))
				oddity_stats[STAT_ROB] += 2

			else if(istype(W, /obj/item/cell/medium/moebius/nuclear))
				oddity_stats[STAT_ROB] += 3

			else if(istype(W, /obj/item/cell/large/moebius/nuclear))
				oddity_stats[STAT_ROB] += 4

			else
				oddity_stats[STAT_ROB] += 1

		else if(isgun(W))
			oddity_stats[STAT_ROB] += 2
			oddity_stats[STAT_VIG] += 2

		else
			to_chat(user, SPAN_WARNING("The [W] is not suitable for [src]!"))
			return

		to_chat(user, SPAN_NOTICE("You feed [W] to [src]."))
		SEND_SIGNAL(user, COMSIG_OBJ_TECHNO_TRIBALISM, W)
		items_count += 1
		qdel(W)

	else
		to_chat(user, SPAN_WARNING("The [src] is full!"))
		return

/obj/item/device/techno_tribalism/attack_self()
	if(world.time >= (last_produce + cooldown))
		if(items_count >= max_count)
			if(ishuman(src.loc))
				var/mob/living/carbon/human/user = src.loc
				var/obj/item/oddity/techno/T = new /obj/item/oddity/techno(src)
				T.oddity_stats = src.oddity_stats
				T.AddComponent(/datum/component/inspiration, T.oddity_stats, T.perk)
				items_count = 0
				oddity_stats = list(STAT_MEC = 0, STAT_COG = 0, STAT_BIO = 0, STAT_ROB = 0, STAT_TGH = 0, STAT_VIG = 0)
				last_produce = world.time
				user.put_in_hands(T)
			else
				to_chat(src.loc, SPAN_WARNING("The [src] is too complicated to use!"))
		else
			visible_message("\icon The [src] beeps, \"The [src] is not full enough to produce.\".")
	else
		visible_message("\icon The [src] beeps, \"The [src] needs time to cooldown.\".")

/obj/item/device/techno_tribalism/examine(user)
	..()
	to_chat(user, SPAN_NOTICE("The [src] is fed by [items_count]/[max_count]."))

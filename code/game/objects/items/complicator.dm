/obj/item/complicator
	name = "Reality Complicator"
	desc = "Weird device of unknown origin. It can be activated and  have a cooldown of 30 minutes."
	icon = 'icons/obj/faction_item.dmi'
	icon_state = "complicator"
	item_state = "complicator"
	w_class = ITEM_SIZE_SMALL
	price_tag = 20000
	origin_tech = list(TECH_POWER = 7, TECH_BLUESPACE = 4, TECH_MAGNET = 9)
	spawn_frequency = 0
	spawn_blacklisted = TRUE
	var/last_summon = -30 MINUTES
	var/cooldown = 30 MINUTES

/obj/item/complicator/New()
	..()
	GLOB.all_faction_items[src] = GLOB.department_engineering

/obj/item/complicator/Destroy()
	for(var/mob/living/carbon/human/H in viewers(get_turf(src)))
		SEND_SIGNAL(H, COMSIG_OBJ_FACTION_ITEM_DESTROY, src)
	GLOB.all_faction_items -= src
	GLOB.technomancer_faction_item_loss++
	..()

/obj/item/complicator/attack_self()
	var/mob/living/carbon/human/user = src.loc
	if(world.time >= (last_summon + cooldown))
		var/mod = pick(EVENT_LEVEL_MUNDANE, EVENT_LEVEL_MODERATE, EVENT_LEVEL_MAJOR, EVENT_LEVEL_ROLESET)
		var/rand_points = rand(10, 120)
		GLOB.storyteller.points[mod] += rand_points
		last_summon = world.time
		visible_message(SPAN_DANGER("[user] pressed the big red button on [src]!"))
		user.apply_effect((rand_points/10),IRRADIATE)

	else
		to_chat(user, SPAN_WARNING("The [src] need sometime to reload!"))

/obj/item/complicator/attackby(obj/item/I, mob/living/user, params)
	if(nt_sword_attack(I, user))
		return
	..()

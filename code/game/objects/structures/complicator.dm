/obj/structure/complicator
	name = "\improper Reality Complicator"
	desc = "A weird device of unknown origin. A note on the side says 'Do not press.'"
	icon = 'icons/obj/faction_item.dmi'
	icon_state = "complicator"
	item_state = "complicator"
	w_class = ITEM_SIZE_SMALL
	price_tag = 20000
	spawn_frequency = 0
	spawn_blacklisted = TRUE
	var/last_summon = -30 MINUTES
	var/cooldown = 30 MINUTES

/obj/structure/complicator/New()
	..()
	GLOB.all_faction_items[src] = GLOB.department_engineering

/obj/item/structure/complicator/Destroy()
	for(var/mob/living/carbon/human/H in viewers(get_turf(src)))
		SEND_SIGNAL(H, COMSIG_OBJ_FACTION_ITEM_DESTROY, src)
	GLOB.all_faction_items -= src
	..()

/obj/structure/complicator/attack_hand(mob/living/user)
	if(world.time >= (last_summon + cooldown))
		var/mod = pick(EVENT_LEVEL_MUNDANE, EVENT_LEVEL_MODERATE, EVENT_LEVEL_MAJOR, EVENT_LEVEL_ROLESET)
		var/rand_points = rand(10, 120)
//storytodo		GLOB.storyteller.points[mod] += rand_points
		last_summon = world.time
		visible_message(SPAN_DANGER("\the [user] presses \the [src]!"))
		user.apply_effect((rand_points/10),IRRADIATE)
	else
		to_chat(user, SPAN_WARNING("\The [src] needs some time to reload!"))

/obj/structure/complicator/attackby(obj/item/I, mob/living/user, params)
	if(nt_sword_attack(I, user))
		return
	..()

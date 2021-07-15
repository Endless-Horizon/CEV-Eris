/obj/item/biosyphon
	name = "Bluespace Biosyphon"
	desc = "Hunts on flora and fauna that sometimes populates bluespace, and use them to produce donuts endlessly."
	icon = 'icons/obj/faction_item.dmi'
	icon_state = "biosyphon"
	item_state = "biosyphon"
	w_class = ITEM_SIZE_BULKY
	flags = CONDUCT
	throwforce = WEAPON_FORCE_PAINFUL
	throw_speed = 1
	throw_range = 2
	price_tag = 20000
	origin_tech = list(TECH_MATERIAL = 4, TECH_BLUESPACE = 8, TECH_POWER = 7)
	matter = list(MATERIAL_PLASTIC = 6, MATERIAL_GLASS = 7)
	spawn_frequency = 0
	spawn_blacklisted = TRUE
	var/last_produce = 0
	var/cooldown = 15 MINUTES

/obj/item/biosyphon/Initialize()
	. = ..()
	GLOB.all_faction_items[src] = GLOB.department_security
	START_PROCESSING(SSobj, src)

/obj/item/biosyphon/Destroy()
	STOP_PROCESSING(SSobj, src)
	for(var/mob/living/carbon/human/H in viewers(get_turf(src)))
		SEND_SIGNAL(H, COMSIG_OBJ_FACTION_ITEM_DESTROY, src)
	GLOB.all_faction_items -= src
	GLOB.ironhammer_faction_item_loss++
	. = ..()

/obj/item/biosyphon/Process()
	if(world.time >= (last_produce + cooldown))
		var/obj/item/storage/box/donut/D = new /obj/item/storage/box/donut(get_turf(src))
		visible_message(SPAN_NOTICE("[name] drop [D]."))
		last_produce = world.time

/obj/item/biosyphon/attackby(obj/item/I, mob/living/user, params)
	if(nt_sword_attack(I, user))
		return
	..()

/*
 * Crafting Items
 * Items used only in crafting other items
*/

/obj/item/rocket_engine
	name = "rocket engine"
	desc = "A singular rocket engine, used in assisted ballistics."
	icon_state = "rocket_engine"
	origin_tech = list(TECH_ENGINEERING = 3, TECH_POWER = 4)
	matter = list(MATERIAL_PLASTEEL = 3, MATERIAL_GOLD = 1)

/obj/item/part
	icon ='icons/obj/crafts.dmi'
	rarity_value = 10
	spawn_frequency = 10
	price_tag = 300
	bad_type = /obj/item/part
	spawn_tags = SPAWN_TAG_PART

/obj/item/part/armor
	name = "armor part"
	desc = "Spare part of armor."
	icon_state = "armor_part"
	spawn_tags = SPAWN_TAG_PART_ARMOR
	matter = list(MATERIAL_PLASTIC = 5, MATERIAL_WOOD = 5, MATERIAL_CARDBOARD = 5, MATERIAL_STEEL = 5)

/obj/item/part/armor/artwork
	desc = "This is an artistically-made armor part."
	spawn_frequency = 0

/obj/item/part/armor/artwork/Initialize()
	name = get_weapon_name(capitalize = TRUE)
	AddComponent(/datum/component/atom_sanity, 0.2 + pick(0,0.1,0.2), "")
	price_tag += rand(0, 500)
	return ..()

/obj/item/part/armor/artwork/get_item_cost(export)
	. = ..()
	GET_COMPONENT(comp_sanity, /datum/component/atom_sanity)
	. += comp_sanity.affect * 100

/obj/item/part/gun
	name = "gun part"
	desc = "Spare part of gun."
	icon_state = "gun_part_1"
	spawn_tags = SPAWN_TAG_GUN_PART
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_PLASTEEL = 1.2)

/obj/item/part/gun/Initialize()
	. = ..()
	icon_state = "gun_part_[rand(1,6)]"

/obj/item/part/gun/artwork
	desc = "This is an artistically-made gun part."
	spawn_frequency = 0

/obj/item/part/gun/artwork/Initialize()
	name = get_weapon_name(capitalize = TRUE)
	AddComponent(/datum/component/atom_sanity, 0.2 + pick(0,0.1,0.2), "")
	price_tag += rand(0, 500)
	return ..()

/obj/item/part/gun/artwork/get_item_cost(export)
	. = ..()
	GET_COMPONENT(comp_sanity, /datum/component/atom_sanity)
	. += comp_sanity.affect * 100

/obj/item/craft_frame
	name = "item assembly"
	desc = "Debug item"
	icon ='icons/obj/crafts.dmi'
	icon_state = "gun_frame"
	matter = list()
	bad_type = /obj/item/craft_frame
	spawn_frequency = 0
	var/req_sat = STAT_MEC
	var/suitable_part
	var/view_only = 0
	var/tags_to_spawn = list()
	var/req_parts = 15
	var/complete = FALSE
	var/total_items = 20
	var/list/items = list()
	var/list/paths = list()

/obj/item/craft_frame/guns
	name = "gun assembly"
	desc = "Add some weapon parts to complete this, use your knowledge of mechanics and create a gun."
	matter = list(MATERIAL_PLASTEEL = 5)
	suitable_part = /obj/item/part/gun
	spawn_frequency = 0
	tags_to_spawn = list(SPAWN_GUN)

/obj/item/craft_frame/examine(user, distance)
	. = ..()
	if(.)
		if(req_parts > 0)
			to_chat(user, SPAN_NOTICE("Requires [req_parts] gun parts to be complete."))
		else
			to_chat(user, SPAN_NOTICE("[src] is complete."))

/obj/item/craft_frame/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, suitable_part))
		if(complete)
			to_chat(user, SPAN_WARNING("[src] is complete"))
			return
		else if(insert_item(I, user))
			req_parts--
			if(req_parts <= 0)
				complete()
				to_chat(user, SPAN_NOTICE("You have completed [src]."))
			return
	return ..()

/obj/item/craft_frame/proc/complete()
	generate_guns()
	complete = TRUE

/obj/item/craft_frame/proc/generate_guns()
	for(var/i in 1 to total_items)
		var/list/canidates = SSspawn_data.valid_candidates(tags_to_spawn, null, FALSE, i*100, null, TRUE, null, paths, null)
		paths += list(SSspawn_data.pick_spawn(canidates))
	for(var/path in paths)
		items += new path()

/obj/item/craft_frame/proc/drop_parts()
	for(var/obj/item/part/P in contents)
		P.forceMove(get_turf(src))

/obj/item/craft_frame/attack_self(mob/user)
	. = ..()
	if(!complete)
		to_chat(user, SPAN_WARNING("[src] is not yet complete."))
	else
		view_only = round((total_items - 1) * (1 - user.stats.getMult(req_sat, STAT_LEVEL_GODLIKE))) + 1
		nano_ui_interact(user)
		SSnano.update_uis(src)

/obj/item/craft_frame/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui, force_open = NANOUI_FOCUS)
	var/list/data = list()

	var/list/listed_products = list()
	for(var/key = 1 to view_only)
		var/obj/item/I = items[key]

		listed_products.Add(list(list(
			"key" = key,
			"name" = strip_improper(I.name))))

	data["paths"] = listed_products

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "craft_assambly.tmpl", name, 440, 600)
		ui.set_initial_data(data)
		ui.open()

/obj/item/craft_frame/Topic(href, href_list)
	if(usr.stat || usr.restrained())
		return
	if((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))))
		if((href_list["select"]))
			var/key = text2num(href_list["select"])
			var/obj/item/I = items[key]
			make_obj(I, usr)
	SSnano.update_uis(src)

/obj/item/craft_frame/proc/make_obj(obj/O, mob/user)
	var/turf/T = get_turf(src)
	O.forceMove(T)
	user.put_in_hands(O)
	if(istype(O, /obj/item/weapon/gun/projectile))
		var/list/aditional_objects = SSspawn_data.all_accompanying_obj_by_path[O.type]
		var/atom/movable/aditional_obj
		if(islist(aditional_objects) && aditional_objects.len)
			for(var/thing in aditional_objects)
				var/atom/movable/AM = thing
				if(!prob(initial(AM.prob_aditional_object)))
					continue
				aditional_obj = new thing (T)
		user.put_in_hands(aditional_obj)
	to_chat(user, SPAN_NOTICE("You have used [src] to craft a [O.name]."))
	spawn(1)
		if(!QDELETED(src))
			qdel(src)

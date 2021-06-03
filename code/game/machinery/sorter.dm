#define SORT_EXCLUDE 0
#define SORT_INCLUDE 1

#define SORT_TYPE_MATERIAL "material"
#define SORT_TYPE_REAGENT "reagent"
#define SORT_TYPE_NAME "name"
/*
	Sorter will sort items based on rules
*/
/datum/sort_rule
	var/accept
	var/sort_type
	var/value
	var/amount

/datum/sort_rule/New(accept, type, value, amount = 0)
	src.accept = accept
	src.sort_type = type
	src.value = value
	src.amount = amount

/datum/sort_rule/proc/check_match(atom/movable/sorted)
	var/obj/O
	if(istype(sorted, /obj))
		O = sorted

	switch(sort_type)
		if(SORT_TYPE_MATERIAL)
			if(O)
				var/list/materials = O.get_matter()
				if((value in materials) && (!amount || materials[value] >= amount))
					return TRUE

		if(SORT_TYPE_REAGENT)
			if(O && O.reagents && O.reagents.has_reagent(value, amount))
				return TRUE

		if(SORT_TYPE_NAME)
			if(findtext(sorted.name, value))
				return TRUE

	return FALSE


/obj/machinery/sorter
	name = "sorter"
	icon = 'icons/obj/machines/sorter.dmi'
	icon_state = "sorter"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 200

	circuit = /obj/item/weapon/electronics/circuitboard/sorter
	// based on levels of manipulators
	var/speed = 25
	// based on levels of scanners
	var/number_of_settings = 3
	var/input_side = SOUTH
	var/accept_output_side = EAST
	var/refuse_output_side = null //by default it will be reversed input_side

	var/progress = 0

	var/list/sort_settings = list()
	var/atom/movable/current_item

	//UI vars
	var/list/custom_rule = list("accept", "sort_type", "value", "amount")
	var/new_rule_ui = FALSE
	var/show_config = FALSE
	var/show_iconfig = FALSE
	var/show_oconfig = FALSE
	var/show_rconfig = FALSE


/obj/machinery/sorter/Initialize()
	. = ..()
	if(!refuse_output_side)
		refuse_output_side = reverse_direction(input_side)


/obj/machinery/sorter/Destroy()
	if(current_item)
		current_item.forceMove(get_turf(src))
	return ..()


/obj/machinery/sorter/on_update_icon()
	..()
	if(progress)
		icon_state = "sorter-process"
	else
		icon_state = "sorter"


/obj/machinery/sorter/Process()
	if(stat & BROKEN || stat & NOPOWER)
		progress = 0
		use_power(0)
		update_icon()
		return

	if(!sort_settings)
		return

	if(current_item)
		use_power(2)
		progress += speed
		if(progress >= 100)
			sort(current_item)
			grab()
			use_power(1)
		update_icon()
	else
		grab()


/obj/machinery/sorter/proc/sort(atom/movable/item_to_sort)
	if(!current_item || !sort_settings)
		return
	var/sorted = FALSE
	for(var/datum/sort_rule/rule in sort_settings)
		if(rule.check_match(item_to_sort))
			sorted = rule.accept
			if(!sorted)
				break

	eject(sorted)
	progress = 0


/obj/machinery/sorter/proc/grab()
	if(current_item)
		return
	var/turf/T = get_step(src, input_side)
	for(var/atom/movable/O in T)
		if(O.anchored)
			continue

		// Only process dead mobs
		if(ismob(O))
			if(!isliving(O))
				continue
			var/mob/living/M = O
			if(M.stat != DEAD)
				continue

		var/obj/structure/closet/C = O
		if(istype(C))
			C.open()
		current_item = O
		O.forceMove(src)
		if(istype(C) && !C.opened)
			eject()
			return
		state("scanning now: [O]...")
		return


/obj/machinery/sorter/proc/eject(var/sorted = FALSE)
	if(!current_item)
		return
	var/turf/T
	if(sorted)
		T = get_step(src, accept_output_side)
		state("[current_item] accepted.")
	else
		T = get_step(src, refuse_output_side)
		state("[current_item] refused.")
	if(T)
		current_item.forceMove(T)
		current_item = null


/obj/machinery/sorter/RefreshParts()
	..()
	var/manipulator_rating = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		manipulator_rating += M.rating
	var/num_settings = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/S in component_parts)
		num_settings += S.rating
	number_of_settings = num_settings * initial(number_of_settings)
	speed = manipulator_rating*10


/obj/machinery/sorter/attackby(var/obj/item/I, var/mob/user)
	if(default_deconstruction(I, user))
		return

	if(default_part_replacement(I, user))
		return

	..()

/obj/machinery/sorter/attack_hand(mob/user as mob)
	return nano_ui_interact(user)


//UI

/obj/machinery/sorter/nano_ui_data()
	var/list/data = list()
	data["currentItem"] = null
	if(current_item)
		data["currentItem"] = current_item.name
	data["progress"] = progress

	var/list/data_rules = list()
	for(var/datum/sort_rule/rule in sort_settings)
		data_rules.Add(list(list(
				"accept" = rule.accept,
				"sort_type" = rule.sort_type,
				"value" = rule.value,
				"amount" = rule.amount
				)))
	data["rules"] = data_rules
	data["add_new_rule"] = new_rule_ui
	data["max_rule_num"] = number_of_settings
	data["current_rule_num"] = sort_settings.len
	data["new_rule_accept"] = custom_rule["accept"]
	data["new_rule_sort"] = custom_rule["sort_type"]
	data["new_rule_value"] = custom_rule["value"]
	data["new_rule_amount"] = custom_rule["amount"]
	data["sideI"] = capitalize(dir2text(input_side))
	data["sideO"] = capitalize(dir2text(accept_output_side))
	data["sideR"] = capitalize(dir2text(refuse_output_side))
	data["show_config"] = show_config
	data["show_iconfig"] = show_iconfig
	data["show_oconfig"] = show_oconfig
	data["show_rconfig"] = show_rconfig

	return data


/obj/machinery/sorter/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = NANOUI_FOCUS, datum/topic_state/state = GLOB.default_state)
	var/list/data = nano_ui_data()

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "sorter.tmpl", src.name, 600, 400, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)


/obj/machinery/sorter/Topic(href, href_list)
	if (..()) return TRUE

	if (href_list["remove"])
		var/key = text2num(href_list["remove"])
		var/datum/sort_rule/rule_to_remove = sort_settings[key]
		sort_settings.Remove(rule_to_remove)
		qdel(rule_to_remove)
	else if (href_list["add_new"])
		new_rule_ui = !new_rule_ui

	else if (href_list["filter"])
		custom_rule["accept"] = text2num(href_list["filter"])

	else if (href_list["sort_type"])
		custom_rule["sort_type"] = href_list["sort_type"]

	else if (href_list["type_input"])
		switch(custom_rule["sort_type"])
			if(SORT_TYPE_MATERIAL)
				custom_rule["value"] = input("Please, select a material!", "Matter sorting", null, null) as null|anything in MATERIAL_LIST
			if(SORT_TYPE_NAME)
				custom_rule["value"] = input("Please, enter a name to match by!", "Name sorting", null, null) as text
			if(SORT_TYPE_REAGENT)
				custom_rule["value"] = input("Please, enter a reagent to search for!", "Reagent sorting", null, null) as text //Until we make a full reagent ID list

	else if (href_list["amount_input"])
		custom_rule["amount"] = text2num(input("Type amount of [custom_rule["sort_type"]]"))
		if(!isnum(custom_rule["amount"]))
			state("Sorry. Amount should be a number.")
			custom_rule["amount"] = 1

	else if (href_list["add"])
		if(sort_settings.len < number_of_settings)
			sort_settings += new /datum/sort_rule(custom_rule["accept"],
												custom_rule["sort_type"],
												custom_rule["value"],
												custom_rule["amount"])
			state("New rule added. Updating scanners with new info...")
		else
			state("Maximum number of rules reached. Out of Memory.")
		custom_rule = list("accept", "sort_type", "value", "amount")

	else if (href_list["cancel"])
		new_rule_ui = null
		custom_rule = list("accept", "sort_type", "value", "amount")

	if(href_list["setsideI"])
		input_side = text2dir(href_list["setsideI"])

	if(href_list["setsideO"])
		accept_output_side = text2dir(href_list["setsideO"])

	if(href_list["setsideR"])
		refuse_output_side = text2dir(href_list["setsideR"])

	if(href_list["toggle_config"])
		show_config = !show_config

	if(href_list["toggle_iconfig"])
		show_iconfig = !show_iconfig

	if(href_list["toggle_oconfig"])
		show_oconfig = !show_oconfig

	if(href_list["toggle_rconfig"])
		show_rconfig = !show_rconfig


	SSnano.update_uis(src)
	playsound(loc, 'sound/machines/machine_switch.ogg', 100, 1)
	return FALSE








/obj/machinery/sorter/biomatter
	name = "biomatter sorter"

/obj/machinery/sorter/biomatter/Initialize()
	. = ..()
	sort_settings += new /datum/sort_rule(SORT_INCLUDE, SORT_TYPE_MATERIAL, MATERIAL_BIOMATTER, 1)


#undef SORT_EXCLUDE
#undef SORT_INCLUDE

#undef SORT_TYPE_MATERIAL
#undef SORT_TYPE_REAGENT
#undef SORT_TYPE_NAME

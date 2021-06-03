/obj/machinery/autolathe
	name = "autolathe"
	desc = "It produces items using metal and glass."
	icon = 'icons/obj/machines/autolathe.dmi'
	icon_state = "autolathe"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 2000
	circuit = /obj/item/weapon/electronics/circuitboard/autolathe

	var/build_type = AUTOLATHE

	var/obj/item/weapon/computer_hardware/hard_drive/portable/disk

	var/list/stored_material = list()
	var/obj/item/weapon/reagent_containers/glass/container

	var/unfolded
	var/show_category
	var/list/categories

	var/list/special_actions

	// Used by wires - unused for now
	var/hacked = FALSE
	var/disabled = FALSE
	var/shocked = FALSE

	var/working = FALSE
	var/paused = FALSE
	var/error
	var/progress = 0

	var/datum/computer_file/binary/design/current_file
	var/list/queue = list()
	var/queue_max = 8

	var/storage_capacity = 120
	var/speed = 2
	var/mat_efficiency = 1

	var/default_disk	// The disk that spawns in autolathe by default

	// Various autolathe functions that can be disabled in subtypes
	var/have_disk = TRUE
	var/have_reagents = TRUE
	var/have_materials = TRUE
	var/have_recycling = TRUE
	var/have_design_selector = TRUE

	var/list/unsuitable_materials = list(MATERIAL_BIOMATTER)
	var/list/suitable_materials //List that limits autolathes to eating mats only in that list.

	var/global/list/error_messages = list(
		ERR_NOLICENSE = "Not enough license points left.",
		ERR_NOTFOUND = "Design data not found.",
		ERR_NOMATERIAL = "Not enough materials.",
		ERR_NOREAGENT = "Not enough reagents.",
		ERR_PAUSED = "**Construction Paused**",
		ERR_NOINSIGHT = "Not enough insight.",
		ERR_NOODDITY = "catalyst not found."
	)

	var/tmp/datum/wires/autolathe/wires

	// A vis_contents hack for materials loading animation.
	var/tmp/obj/effect/flicker_overlay/image_load
	var/tmp/obj/effect/flicker_overlay/image_load_material

	// If it prints high quality or bulky/deformed/debuffed items, or if it prints good items for one faction only.
	var/low_quality_print = TRUE
	var/list/high_quality_faction_list = list()

	//for nanoforge and/or artist bench
	var/use_oddities = FALSE
	var/datum/component/inspiration/inspiration
	var/obj/item/oddity
	var/is_nanoforge = FALSE
	var/list/saved_designs = list()

/obj/machinery/autolathe/Initialize()
	. = ..()
	wires = new(src)

	image_load = new(src)
	image_load_material = new(src)

	if(have_disk && default_disk)
		disk = new default_disk(src)

	update_icon()

/obj/machinery/autolathe/Destroy()
	QDEL_NULL(wires)
	QDEL_NULL(image_load)
	QDEL_NULL(image_load_material)
	return ..()

/obj/machinery/autolathe/proc/requiere_license(datum/computer_file/binary/design/_design_file)
	if(_design_file in saved_designs)
		return FALSE
	return TRUE

// Also used by R&D console UI.
/obj/machinery/autolathe/proc/materials_data()
	var/list/data = list()

	data["mat_efficiency"] = mat_efficiency
	data["mat_capacity"] = storage_capacity

	data["container"] = !!container
	if(container && container.reagents)
		var/list/L = list()
		for(var/datum/reagent/R in container.reagents.reagent_list)
			var/list/LE = list("name" = R.name, "amount" = R.volume)
			L.Add(list(LE))

		data["reagents"] = L

	var/list/M = list()
	for(var/mtype in stored_material)
		if(stored_material[mtype] <= 0)
			continue

		var/material/MAT = get_material_by_name(mtype)
		var/list/ME = list("name" = MAT.display_name, "id" = mtype, "amount" = stored_material[mtype], "ejectable" = !!MAT.stack_type)

		M.Add(list(ME))

	data["materials"] = M

	return data


/obj/machinery/autolathe/nano_ui_data()
	var/list/data = list()

	data["have_disk"] = have_disk
	data["have_reagents"] = have_reagents
	data["have_materials"] = have_materials
	data["have_design_selector"] = have_design_selector

	data["error"] = error
	data["paused"] = paused

	data["unfolded"] = unfolded

	data["speed"] = speed

	if(disk)
		data["disk"] = list(
			"name" = disk.get_disk_name(),
			"license" = disk.license,
			"read_only" = disk.read_only
		)

	if(categories)
		data["categories"] = categories
		data["show_category"] = show_category

	data["special_actions"] = special_actions

	data |= materials_data()

	var/list/L = list()
	for(var/d in design_list())
		var/datum/computer_file/binary/design/design_file = d
		if(!show_category || design_file.design.category == show_category)
			L.Add(list(design_file.nano_ui_data()))
	data["designs"] = L


	if(current_file)
		data["current"] = current_file.nano_ui_data()
		data["progress"] = progress

	var/list/Q = list()
	var/licenses_used = 0
	var/list/qmats = stored_material.Copy()

	for(var/i = 1; i <= queue.len; i++)
		var/datum/computer_file/binary/design/design_file = queue[i]
		var/list/QR = design_file.nano_ui_data()

		QR["ind"] = i

		QR["error"] = 0

		if(design_file.copy_protected)
			licenses_used++

			if(!disk || licenses_used > disk.license)
				QR["error"] = 1

		for(var/rmat in design_file.design.materials)
			if(!(rmat in qmats))
				qmats[rmat] = 0

			qmats[rmat] -= design_file.design.materials[rmat]
			if(qmats[rmat] < 0)
				QR["error"] = 1

		if(can_print(design_file) != ERR_OK)
			QR["error"] = 2

		Q.Add(list(QR))

	data["queue"] = Q
	data["queue_max"] = queue_max

	data["use_oddities"] = use_oddities

	if(inspiration)
		var/list/stats = list()
		var/list/LE = inspiration.calculate_statistics()
		for(var/stat in LE)
			var/list/LF = list("name" = stat, "level" = LE[stat])
			stats.Add(list(LF))

		data["oddity_name"] = oddity.name
		data["oddity_stats"] = stats

	data["use_license"] = !!disk
	data["is_nanoforge"] = is_nanoforge
	return data


/obj/machinery/autolathe/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	var/list/data = nano_ui_data(user, ui_key)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
		// for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "autolathe.tmpl", capitalize(name), 600, 700)

		// template keys starting with _ are not appended to the UI automatically and have to be called manually
		ui.add_template("_materials", "autolathe_materials.tmpl")
		ui.add_template("_reagents", "autolathe_reagents.tmpl")
		ui.add_template("_designs", "autolathe_designs.tmpl")
		ui.add_template("_queue", "autolathe_queue.tmpl")
		ui.add_template("_oddity", "autolathe_oddity.tmpl")
		ui.add_template("_nanoforge", "nanoforge_actions.tmpl")

		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

/obj/machinery/autolathe/attackby(obj/item/I, mob/user)
	if(default_deconstruction(I, user))
		wires?.Interact(user)
		return

	if(default_part_replacement(I, user))
		return

	if(istype(I, /obj/item/weapon/computer_hardware/hard_drive/portable))
		insert_disk(user, I)

	// Some item types are consumed by default
	if(istype(I, /obj/item/stack) || istype(I, /obj/item/trash) || istype(I, /obj/item/weapon/material/shard))
		eat(user, I)
		return

	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		insert_beaker(user, I)
		return

	if(use_oddities)
		GET_COMPONENT_FROM(C, /datum/component/inspiration, I)
		if(C && C.perk)
			insert_oddity(user, I)
			return

	if(!check_user(user))
		return

	user.set_machine(src)
	nano_ui_interact(user)

/obj/machinery/autolathe/proc/check_user(mob/user)
	return TRUE

/obj/machinery/autolathe/attack_hand(mob/user)
	if(..())
		return TRUE

	if(!check_user(user))
		return TRUE

	user.set_machine(src)
	nano_ui_interact(user)
	wires.Interact(user)

/obj/machinery/autolathe/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)

	if(href_list["insert"])
		eat(usr)
		return 1

	if(href_list["disk"])
		if(disk)
			eject_disk(usr)
		else
			insert_disk(usr)
		return 1

	if(href_list["container"])
		if(container)
			eject_beaker(usr)
		else
			insert_beaker(usr)
		return 1

	if(href_list["category"] && categories)
		var/new_category = text2num(href_list["category"])

		if(new_category && new_category <= length(categories))
			show_category = categories[new_category]
		return 1

	if(href_list["eject_material"] && (!current_file || paused || error))
		var/material = href_list["eject_material"]
		var/material/M = get_material_by_name(material)

		if(!M.stack_type)
			return

		var/num = input("Enter sheets number to eject. 0-[stored_material[material]]","Eject",0) as num
		if(!CanUseTopic(usr))
			return

		num = min(max(num,0), stored_material[material])

		eject(material, num)
		return 1


	if(href_list["add_to_queue"])
		var/recipe_filename = href_list["add_to_queue"]
		var/datum/computer_file/binary/design/design_file

		for(var/f in design_list())
			var/datum/computer_file/temp_file = f
			if(temp_file.filename == recipe_filename)
				design_file = temp_file
				break

		if(design_file)
			var/amount = 1

			if(href_list["several"])
				amount = input("How many \"[design_file.design.name]\" you want to print ?", "Print several") as null|num
				if(!CanUseTopic(usr) || !(design_file in design_list()))
					return

			queue_design(design_file, amount)

		return 1

	if(href_list["remove_from_queue"])
		var/ind = text2num(href_list["remove_from_queue"])
		if(ind >= 1 && ind <= queue.len)
			queue.Cut(ind, ind + 1)
		return 1

	if(href_list["move_up_queue"])
		var/ind = text2num(href_list["move_up_queue"])
		if(ind >= 2 && ind <= queue.len)
			queue.Swap(ind, ind - 1)
		return 1

	if(href_list["move_down_queue"])
		var/ind = text2num(href_list["move_down_queue"])
		if(ind >= 1 && ind <= queue.len-1)
			queue.Swap(ind, ind + 1)
		return 1


	if(href_list["abort_print"])
		abort()
		return 1

	if(href_list["pause"])
		paused = !paused
		return 1

	if(href_list["unfold"])
		if(unfolded == href_list["unfold"])
			unfolded = null
		else
			unfolded = href_list["unfold"]
		return 1

	if(href_list["oddity_name"])
		if(oddity)
			remove_oddity(usr)
		else
			insert_oddity(usr)
		return TRUE

/obj/machinery/autolathe/proc/insert_disk(mob/living/user, obj/item/weapon/computer_hardware/hard_drive/portable/inserted_disk)
	if(!inserted_disk && istype(user))
		inserted_disk = user.get_active_hand()

	if(!istype(inserted_disk))
		return

	if(!Adjacent(user) && !Adjacent(inserted_disk))
		return

	if(!have_disk)
		to_chat(user, SPAN_WARNING("[src] has no slot for a data disk."))
		return

	if(disk)
		to_chat(user, SPAN_NOTICE("There's already \a [disk] inside [src]."))
		return

	if(istype(user) && (inserted_disk in user))
		user.unEquip(inserted_disk, src)

	inserted_disk.forceMove(src)
	disk = inserted_disk
	to_chat(user, SPAN_NOTICE("You insert \the [inserted_disk] into [src]."))
	SSnano.update_uis(src)


/obj/machinery/autolathe/proc/insert_beaker(mob/living/user, obj/item/weapon/reagent_containers/glass/beaker)
	if(!beaker && istype(user))
		beaker = user.get_active_hand()

	if(!istype(beaker))
		return

	if(!Adjacent(user) && !Adjacent(beaker))
		return

	if(!have_reagents)
		to_chat(user, SPAN_WARNING("[src] has no slot for a beaker."))
		return

	if(container)
		to_chat(user, SPAN_WARNING("There's already \a [container] inside [src]."))
		return

	if(istype(user) && (beaker in user))
		user.unEquip(beaker, src)

	beaker.forceMove(src)
	container = beaker
	to_chat(user, SPAN_NOTICE("You put \the [beaker] into [src]."))
	SSnano.update_uis(src)


/obj/machinery/autolathe/proc/eject_beaker(mob/living/user)
	if(!container)
		return

	if(current_file && !paused && !error)
		return

	container.forceMove(drop_location())
	to_chat(usr, SPAN_NOTICE("You remove \the [container] from \the [src]."))

	if(istype(user) && Adjacent(user))
		user.put_in_active_hand(container)

	container = null


//This proc ejects the autolathe disk, but it also does some DRM fuckery to prevent exploits
/obj/machinery/autolathe/proc/eject_disk(mob/living/user)
	if(!disk)
		return

	var/list/design_list = design_list()

	// Go through the queue and remove any recipes we find which came from this disk
	for(var/design in queue)
		if(design in design_list)
			queue -= design

	//Check the current too
	if(current_file in design_list)
		//And abort it if it came from this disk
		abort()


	//Digital Rights have been successfully managed. The corporations win again.
	//Now they will graciously allow you to eject the disk
	disk.forceMove(drop_location())
	to_chat(usr, SPAN_NOTICE("You remove \the [disk] from \the [src]."))

	if(istype(user) && Adjacent(user))
		user.put_in_active_hand(disk)

	disk = null

/obj/machinery/autolathe/AltClick(mob/living/user)
	if(user.incapacitated())
		to_chat(user, SPAN_WARNING("You can't do that right now!"))
		return
	if(!in_range(src, user))
		return
	src.eject_disk(user)

/obj/machinery/autolathe/proc/eat(mob/living/user, obj/item/eating)
	if(!eating && istype(user))
		eating = user.get_active_hand()

	if(!istype(eating))
		return FALSE

	if(stat)
		return FALSE

	if(!Adjacent(user) && !Adjacent(eating))
		return FALSE

	if(is_robot_module(eating))
		return FALSE

	if(!have_recycling && !istype(eating, /obj/item/stack))
		to_chat(user, SPAN_WARNING("[src] does not support material recycling."))
		return FALSE

	if(!length(eating.get_matter()))
		to_chat(user, SPAN_WARNING("\The [eating] does not contain significant amounts of useful materials and cannot be accepted."))
		return FALSE

	if(istype(eating, /obj/item/weapon/computer_hardware/hard_drive/portable))
		var/obj/item/weapon/computer_hardware/hard_drive/portable/DISK = eating
		if(DISK.license)
			to_chat(user, SPAN_WARNING("\The [src] refuses to accept \the [eating] as it has non-null license."))
			return FALSE

	var/filltype = 0       // Used to determine message.
	var/reagents_filltype = 0
	var/total_used = 0     // Amount of material used.
	var/mass_per_sheet = 0 // Amount of material constituting one sheet.

	var/list/total_material_gained = list()

	for(var/obj/O in eating.GetAllContents(includeSelf = TRUE))
		var/list/_matter = O.get_matter()
		if(_matter)
			for(var/material in _matter)
				if(material in unsuitable_materials)
					continue

				if(suitable_materials)
					if(!(material in suitable_materials))
						continue

				if(!(material in stored_material))
					stored_material[material] = 0

				if(!(material in total_material_gained))
					total_material_gained[material] = 0

				if(stored_material[material] + total_material_gained[material] >= storage_capacity)
					continue

				var/total_material = _matter[material]

				//If it's a stack, we eat multiple sheets.
				if(istype(O, /obj/item/stack))
					var/obj/item/stack/material/stack = O
					total_material *= stack.get_amount()

				if(stored_material[material] + total_material > storage_capacity)
					total_material = storage_capacity - stored_material[material]
					filltype = 1
				else
					filltype = 2

				total_material_gained[material] += total_material
				total_used += total_material
				mass_per_sheet += O.matter[material]

		if(O.matter_reagents)
			if(container)
				var/datum/reagents/RG = new(0)
				for(var/r in O.matter_reagents)
					RG.maximum_volume += O.matter_reagents[r]
					RG.add_reagent(r ,O.matter_reagents[r])
				reagents_filltype = 1
				RG.trans_to(container, RG.total_volume)

			else
				reagents_filltype = 2

		if(O.reagents && container)
			O.reagents.trans_to(container, O.reagents.total_volume)

	if(!filltype && !reagents_filltype)
		to_chat(user, SPAN_NOTICE("\The [src] is full or this thing isn't suitable for this autolathe type. Try remove material from [src] in order to insert more."))
		return

	// Determine what was the main material
	var/main_material
	var/main_material_amt = 0
	for(var/material in total_material_gained)
		stored_material[material] += total_material_gained[material]
		if(total_material_gained[material] > main_material_amt)
			main_material_amt = total_material_gained[material]
			main_material = material

	if(istype(eating, /obj/item/stack))
		res_load(get_material_by_name(main_material)) // Play insertion animation.
		var/obj/item/stack/stack = eating
		var/used_sheets = min(stack.get_amount(), round(total_used/mass_per_sheet))

		to_chat(user, SPAN_NOTICE("You add [used_sheets] [main_material] [stack.singular_name]\s to \the [src]."))

		if(!stack.use(used_sheets))
			qdel(stack)	// Protects against weirdness
	else
		res_load() // Play insertion animation.
		to_chat(user, SPAN_NOTICE("You recycle \the [eating] in \the [src]."))
		qdel(eating)

	if(reagents_filltype == 1)
		to_chat(user, SPAN_NOTICE("Some liquid flowed to \the [container]."))
	else if(reagents_filltype == 2)
		to_chat(user, SPAN_NOTICE("Some liquid flowed to the floor from \the [src]."))


/obj/machinery/autolathe/proc/queue_design(datum/computer_file/binary/design/design_file, amount=1)
	if(!design_file || !amount)
		return

	// Copy the designs that are not copy protected so they can be printed even if the disk is ejected.
	if(!design_file.copy_protected)
		design_file = design_file.clone()

	while(amount && queue.len < queue_max)
		queue.Add(design_file)
		amount--

	if(!current_file)
		next_file()

/obj/machinery/autolathe/proc/clear_queue()
	queue.Cut()

/obj/machinery/autolathe/proc/check_craftable_amount_by_material(datum/design/design, material)
	return stored_material[material] / max(1, SANITIZE_LATHE_COST(design.materials[material])) // loaded material / required material

/obj/machinery/autolathe/proc/check_craftable_amount_by_chemical(datum/design/design, reagent)
	if(!container || !container.reagents)
		return 0

	return container.reagents.get_reagent_amount(reagent) / max(1, design.chemicals[reagent])


//////////////////////////////////////////
//Helper procs for derive possibility
//////////////////////////////////////////
/obj/machinery/autolathe/proc/design_list()
	if(!disk)
		return saved_designs

	return disk.find_files_by_type(/datum/computer_file/binary/design)

/obj/machinery/autolathe/proc/icon_off()
	if(stat & NOPOWER)
		return TRUE
	return FALSE

/obj/machinery/autolathe/on_update_icon()
	cut_overlays()

	icon_state = initial(icon_state)

	if(panel_open)
		add_overlays(image(icon, "[icon_state]_panel"))

	if(icon_off())
		return

	if(working) // if paused, work animation looks awkward.
		if(paused || error)
			icon_state = "[icon_state]_pause"
		else
			icon_state = "[icon_state]_work"

//Procs for handling print animation
/obj/machinery/autolathe/proc/print_pre()
	FLICK("[initial(icon_state)]_start", src)

/obj/machinery/autolathe/proc/print_post()
	FLICK("[initial(icon_state)]_finish", src)
	if(!current_file && !queue.len)
		playsound(src.loc, 'sound/machines/ping.ogg', 50, 1, -3)
		visible_message("\The [src] pings, indicating that queue is complete.")


/obj/machinery/autolathe/proc/res_load(material/material)
	FLICK("[initial(icon_state)]_load", image_load)
	if(material)
		image_load_material.color = material.icon_colour
		image_load_material.alpha = max(255 * material.opacity, 200) // The icons are too transparent otherwise
		FLICK("[initial(icon_state)]_load_m", image_load_material)


/obj/machinery/autolathe/proc/check_materials(datum/design/design)

	for(var/rmat in design.materials)
		if(!(rmat in stored_material))
			return ERR_NOMATERIAL

		if(stored_material[rmat] < SANITIZE_LATHE_COST(design.materials[rmat]))
			return ERR_NOMATERIAL

	if(design.chemicals.len)
		if(!container || !container.is_drawable())
			return ERR_NOREAGENT

		for(var/rgn in design.chemicals)
			if(!container.reagents.has_reagent(rgn, design.chemicals[rgn]))
				return ERR_NOREAGENT

	return ERR_OK

/obj/machinery/autolathe/proc/can_print(datum/computer_file/binary/design/design_file)

	if(use_oddities && !oddity)
		return ERR_NOODDITY

	if(paused)
		return ERR_PAUSED

	if(progress <= 0)
		if(!design_file || !design_file.design)
			return ERR_NOTFOUND

		if(requiere_license(design_file) && !design_file.check_license())
			return ERR_NOLICENSE

		var/datum/design/design = design_file.design
		var/error_mat = check_materials(design)
		if(error_mat != ERR_OK)
			return error_mat

	return ERR_OK


/obj/machinery/autolathe/power_change()
	..()
	if(stat & NOPOWER)
		working = FALSE
	update_icon()
	SSnano.update_uis(src)

/obj/machinery/autolathe/Process()
	if(stat & NOPOWER)
		return

	if(current_file)
		var/err = can_print(current_file)

		if(err == ERR_OK)
			error = null

			working = TRUE
			progress += speed

		else if(err in error_messages)
			error = error_messages[err]
		else
			error = "Unknown error."

		if(current_file.design && progress >= current_file.design.time)
			finish_construction()

	else
		error = null
		working = FALSE
		next_file()

	use_power = working ? ACTIVE_POWER_USE : IDLE_POWER_USE

	special_process()
	update_icon()
	SSnano.update_uis(src)


/obj/machinery/autolathe/proc/consume_materials(datum/design/design)
	for(var/material in design.materials)
		var/material_cost = design.adjust_materials ? SANITIZE_LATHE_COST(design.materials[material]) : design.materials[material]
		stored_material[material] = max(0, stored_material[material] - material_cost)

	for(var/reagent in design.chemicals)
		container.reagents.remove_reagent(reagent, design.chemicals[reagent])

	return TRUE


/obj/machinery/autolathe/proc/next_file()
	current_file = null
	progress = 0
	if(queue.len)
		current_file = queue[1]
		print_pre()
		working = TRUE
		queue.Cut(1, 2) // Cut queue[1]
	else
		working = FALSE
	update_icon()

/obj/machinery/autolathe/proc/special_process()
	return

//Autolathes can eject decimal quantities of material as a shard
/obj/machinery/autolathe/proc/eject(material, amount)
	if(!(material in stored_material))
		return

	if(!amount)
		return

	var/material/M = get_material_by_name(material)

	if(!M.stack_type)
		return
	amount = min(amount, stored_material[material])

	var/whole_amount = round(amount)
	var/remainder = amount - whole_amount

	if(whole_amount)
		var/obj/item/stack/material/S = new M.stack_type(drop_location())

		//Accounting for the possibility of too much to fit in one stack
		if(whole_amount <= S.max_amount)
			S.amount = whole_amount
			S.update_strings()
			S.update_icon()
		else
			//There's too much, how many stacks do we need
			var/fullstacks = round(whole_amount / S.max_amount)
			//And how many sheets leftover for this stack
			S.amount = whole_amount % S.max_amount

			if(!S.amount)
				qdel(S)

			for(var/i = 0; i < fullstacks; i++)
				var/obj/item/stack/material/MS = new M.stack_type(drop_location())
				MS.amount = MS.max_amount
				MS.update_strings()
				MS.update_icon()

	//And if there's any remainder, we eject that as a shard
	if(remainder)
		new /obj/item/weapon/material/shard(drop_location(), material, _amount = remainder)

	//The stored material gets the amount (whole+remainder) subtracted
	stored_material[material] -= amount


/obj/machinery/autolathe/on_deconstruction()
	for(var/mat in stored_material)
		eject(mat, stored_material[mat])

	eject_disk()
	..()

//Updates lathe material storage size, production speed and material efficiency.
/obj/machinery/autolathe/RefreshParts()
	..()
	var/mb_rating = 0
	var/mb_amount = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/MB in component_parts)
		mb_rating += MB.rating
		mb_amount++

	storage_capacity = round(initial(storage_capacity)*(mb_rating/mb_amount))

	var/man_rating = 0
	var/man_amount = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		man_rating += M.rating
		man_amount++
	man_rating -= man_amount

	var/las_rating = 0
	var/las_amount = 0
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		las_rating += M.rating
		las_amount++
	las_rating -= las_amount

	speed = initial(speed) + man_rating + las_rating
	mat_efficiency = max(0.2, 1 - (man_rating * 0.1))




//Cancels the current construction
/obj/machinery/autolathe/proc/abort()
	if(working)
		print_post()
	current_file = null
	paused = TRUE
	working = FALSE
	update_icon()

//Finishing current construction
/obj/machinery/autolathe/proc/finish_construction()
	if(!requiere_license(current_file) || current_file.use_license()) //In the case of an an unprotected design, this will always be true
		fabricate_design(current_file.design)
	else
		//If we get here, then the user attempted to print something but the disk had run out of its limited licenses
		//Those dirty cheaters will not get their item. It is aborted before it finishes
		abort()


/obj/machinery/autolathe/proc/fabricate_design(datum/design/design)
	consume_materials(design)
	design.Fabricate(drop_location(), mat_efficiency, src)

	working = FALSE
	current_file = null
	print_post()
	next_file()

/obj/machinery/autolathe/proc/insert_oddity(mob/living/user, obj/item/inserted_oddity) //Not sure if nessecary to name oddity this way. obj/item/weapon/oddity/inserted_oddity
	if(oddity)
		to_chat(user, SPAN_NOTICE("There's already \a [oddity] inside [src]."))
		return

	if(!inserted_oddity && istype(user))
		inserted_oddity = user.get_active_hand()

	if(!istype(inserted_oddity))
		return

	if(!Adjacent(user) || !Adjacent(inserted_oddity))
		return

	GET_COMPONENT_FROM(C, /datum/component/inspiration, inserted_oddity)
	if(!C || !C.perk)
		return

	if(istype(user) && (inserted_oddity in user))
		user.unEquip(inserted_oddity, src)

	inserted_oddity.forceMove(src)
	oddity = inserted_oddity
	inspiration = C
	to_chat(user, SPAN_NOTICE("You insert [oddity] in [src]."))
	SSnano.update_uis(src)

/obj/machinery/autolathe/proc/remove_oddity(mob/living/user, use_perk = FALSE)
	if(!oddity)
		return

	oddity.forceMove(drop_location())
	if(user)
		if(!use_perk)
			to_chat(user, SPAN_NOTICE("You remove [oddity] from [src]."))
		else
			to_chat(user, SPAN_NOTICE("[src] consumes the perk of [oddity]"))
			inspiration.perk = null

		if(istype(user) && Adjacent(user))
			user.put_in_hands(oddity)

	oddity = null
	inspiration = null
	SSnano.update_uis(src)

#undef ERR_OK
#undef ERR_NOTFOUND
#undef ERR_NOMATERIAL
#undef ERR_NOREAGENT
#undef ERR_NOLICENSE
#undef ERR_PAUSED
#undef ERR_NOINSIGHT

// A version with some materials already loaded, to be used on map spawn
/obj/machinery/autolathe/loaded
	stored_material = list(
		MATERIAL_STEEL = 60,
		MATERIAL_PLASTIC = 60,
		MATERIAL_GLASS = 60,
		)

/obj/machinery/autolathe/loaded/Initialize()
	. = ..()
	container = new /obj/item/weapon/reagent_containers/glass/beaker(src)


// You (still) can't flicker overlays in BYOND, and this is a vis_contents hack to provide the same functionality.
// Used for materials loading animation.
/obj/effect/flicker_overlay
	name = ""
	icon_state = ""
	// Acts like a part of the object it's created for when in vis_contents
	// Inherits everything but the icon_state
	vis_flags = VIS_INHERIT_ICON | VIS_INHERIT_DIR | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID

/obj/effect/flicker_overlay/New(atom/movable/loc)
	..()
	// Just VIS_INHERIT_ICON isn't enough: flicker() needs an actual icon to be set
	icon = loc.icon
	loc.vis_contents += src

/obj/effect/flicker_overlay/Destroy()
	if(istype(loc, /atom/movable))
		var/atom/movable/A = loc
		A.vis_contents -= src
	return ..()

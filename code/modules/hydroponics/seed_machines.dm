/obj/machinery/botany
	icon = 'icons/obj/hydroponics_machines.dmi'
	icon_state = "hydrotray"
	density = TRUE
	anchored = TRUE

	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 2000

	var/obj/item/seeds/seed // Currently loaded seed packet
	var/obj/item/weapon/computer_hardware/hard_drive/portable/disk //Currently loaded data disk
	var/datum/computer_file/binary/plantgene/loaded_gene //Currently loaded plant gene

	var/action_time = 5 SECONDS
	var/failed_task = FALSE

/obj/machinery/botany/attack_hand(mob/user)
	nano_ui_interact(user)

/obj/machinery/botany/proc/start_task()
	// UI is updated by "return 1" in Topic()
	use_power = ACTIVE_POWER_USE

	addtimer(CALLBACK(src, .proc/finish_task), action_time)

/obj/machinery/botany/proc/finish_task()
	use_power = IDLE_POWER_USE
	SSnano.update_uis(src)
	if(failed_task)
		failed_task = FALSE
		visible_message("[src] pings unhappily, flashing a red warning light.")
	else
		visible_message("[src] pings happily.")

/obj/machinery/botany/attackby(obj/item/I, mob/user)
	if(default_deconstruction(I, user))
		return

	if(default_part_replacement(I, user))
		return

	if(istype(I, /obj/item/seeds))
		if(seed)
			to_chat(user, SPAN_WARNING("There is already a seed loaded."))
			return
		var/obj/item/seeds/S = I
		if(S.seed && S.seed.get_trait(TRAIT_IMMUTABLE) > 0)
			to_chat(user, SPAN_WARNING("That seed is not compatible with our genetics technology."))
			return

		user.drop_from_inventory(I)
		I.forceMove(src)
		seed = I
		SSnano.update_uis(src)
		to_chat(user, SPAN_NOTICE("You load [I] into [src]."))
		return

	if(istype(I, /obj/item/weapon/computer_hardware/hard_drive/portable))
		if(disk)
			to_chat(user, SPAN_WARNING("There is already a data disk loaded."))
		else
			user.drop_from_inventory(I)
			I.forceMove(src)
			disk = I
			SSnano.update_uis(src)
			to_chat(user, SPAN_NOTICE("You load [I] into [src]."))
		return
	..()

/obj/machinery/botany/nano_ui_data()
	var/list/data = list()
	data["active"] = (use_power == ACTIVE_POWER_USE)

	data["loaded_gene"] = loaded_gene?.nano_ui_data()

	if(disk)
		var/list/disk_genes = list()
		for(var/f in disk.find_files_by_type(/datum/computer_file/binary/plantgene))
			var/datum/computer_file/gene = f
			disk_genes.Add(list(gene.nano_ui_data()))

		data["disk"] = list(
			"max_capacity" = disk.max_capacity,
			"used_capacity" = disk.used_capacity,
			"stored_genes" = disk_genes
		)

	if(seed)
		data["seed"] = list(
			"name" = seed.name,
			"degradation" = seed.modified
		)

	return data

/obj/machinery/botany/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["eject_seed"])
		if(!seed)
			return 1

		if(seed.seed.name == "new line" || isnull(plant_controller.seeds[seed.seed.name]))
			seed.seed.uid = plant_controller.seeds.len + 1
			seed.seed.name = "[seed.seed.uid]"
			plant_controller.seeds[seed.seed.name] = seed.seed

		seed.update_seed()

		to_chat(usr, SPAN_NOTICE("You remove \the [seed] from \the [src]."))

		seed.forceMove(drop_location())
		if(Adjacent(usr))
			usr.put_in_active_hand(seed)

		seed = null
		return 1

	if(href_list["eject_disk"])
		if(!disk)
			return 1

		to_chat(usr, SPAN_NOTICE("You remove \the [disk] from \the [src]."))

		disk.forceMove(drop_location())
		if(Adjacent(usr))
			usr.put_in_active_hand(disk)

		disk = null
		return 1

	if(href_list["clear_gene"])
		loaded_gene = null
		return 1

	if(href_list["load_gene"])
		if(!disk)
			return 1

		var/datum/computer_file/binary/plantgene/gene = disk.find_file_by_name(href_list["load_gene"])
		if(istype(gene))
			loaded_gene = gene.clone()
		return 1

	if(href_list["delete_gene"])
		if(!disk)
			return 1

		disk.remove_file(disk.find_file_by_name(href_list["delete_gene"]))
		return 1

	if(href_list["save_gene"])
		if(!loaded_gene || !disk)
			return 1

		disk.store_file(loaded_gene.clone())
		return 1



// Allows for a trait to be extracted from a seed packet, destroying that seed.
/obj/machinery/botany/extractor
	name = "lysis-isolation centrifuge"
	icon_state = "traitcopier"
	var/genes_processed = FALSE

/obj/machinery/botany/extractor/nano_ui_data()
	var/list/data = ..()

	var/list/geneMasks = list()
	for(var/gene_tag in plant_controller.gene_tag_masks)
		geneMasks.Add(list(list("tag" = gene_tag, "mask" = plant_controller.gene_tag_masks[gene_tag])))
	data["geneMasks"] = geneMasks

	if(seed && genes_processed)
		data["hasGenetics"] = TRUE
		data["sourceName"] = seed.seed.display_name
		if(!seed.seed.roundstart)
			data["sourceName"] += " (variety #[seed.seed.uid])"
	else
		data["hasGenetics"] = FALSE

	return data

/obj/machinery/botany/extractor/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_panel_open = NANOUI_FOCUS)
	var/list/data = nano_ui_data(user)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_panel_open)
	if (!ui)
		ui = new(user, src, ui_key, "botany_isolator.tmpl", "Lysis-isolation Centrifuge", 470, 450)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/botany/extractor/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["scan_genome"])
		if(!seed || genes_processed)
			return 1

		genes_processed = TRUE

		start_task()
		return 1

	if(href_list["get_gene"])
		if(!seed || !genes_processed)
			return 1

		var/datum/computer_file/binary/plantgene/P = seed.seed.get_gene(href_list["get_gene"])
		if(!P)
			return 1
		loaded_gene = P

		var/stat_multiplier = 1
		if(usr.stats)
			// Uses best of BIO and COG
			stat_multiplier = min(usr.stats.getMult(STAT_BIO, STAT_LEVEL_GODLIKE), usr.stats.getMult(STAT_COG, STAT_LEVEL_GODLIKE))

		seed.modified += round(rand(30, 70) * stat_multiplier)
		if(seed.modified >= 100)
			failed_task = TRUE
			QDEL_NULL(seed)
			genes_processed = FALSE

		start_task()
		return 1

	if(href_list["clear_buffer"])
		QDEL_NULL(seed)
		genes_processed = FALSE
		return 1

	if(href_list["eject_seed"] && genes_processed)
		return 1


// Fires an extracted trait into another packet of seeds.
/obj/machinery/botany/editor
	name = "bioballistic delivery system"
	icon_state = "traitgun"

/obj/machinery/botany/editor/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_panel_open = NANOUI_FOCUS)
	var/list/data = nano_ui_data(user)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_panel_open)
	if (!ui)
		ui = new(user, src, ui_key, "botany_editor.tmpl", "Bioballistic Delivery System", 470, 450)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/botany/editor/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["apply_gene"])
		if(!loaded_gene || !seed)
			return 1

		var/stat_multiplier = 1
		if(usr.stats)
			// Uses best of BIO and COG
			stat_multiplier = min(usr.stats.getMult(STAT_BIO, STAT_LEVEL_GODLIKE), usr.stats.getMult(STAT_COG, STAT_LEVEL_GODLIKE))

		if(!isnull(plant_controller.seeds[seed.seed.name]))
			seed.seed = seed.seed.diverge(1)
			seed.seed_type = seed.seed.name
			seed.update_seed()

		if(prob(seed.modified * stat_multiplier))
			failed_task = TRUE
			seed.modified = 100

		seed.seed.apply_gene(loaded_gene)
		seed.modified += round(rand(10, 15) * stat_multiplier)
		seed.modified = max(seed.modified, 100)

		start_task()
		return 1

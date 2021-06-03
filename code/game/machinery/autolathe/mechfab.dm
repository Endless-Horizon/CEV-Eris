/obj/machinery/autolathe/mechfab
	name = "exosuit fabricator"
	desc = "A machine used for construction of robots and exosuits."
	icon_state = "mechfab"
	circuit = /obj/item/weapon/electronics/circuitboard/mechfab

	build_type = MECHFAB
	queue_max = 12
	storage_capacity = 240
	speed = 3

	have_disk = FALSE
	have_reagents = FALSE
	have_recycling = FALSE

	low_quality_print = FALSE

	special_actions = list(
		list("action" = "sync", "name" = "Sync with R&D console", "icon" = "refresh")
	)

	var/datum/research/files


/obj/machinery/autolathe/mechfab/Initialize()
	. = ..()
	files = new /datum/research(src)

/obj/machinery/autolathe/mechfab/design_list()
	var/list/design_files = list()

	for(var/d in files.known_designs)
		var/datum/design/design = d
		if((design.build_type & build_type) && design.file)
			design_files |= design.file

	return design_files

/obj/machinery/autolathe/mechfab/nano_ui_interact()
	if(!categories)
		update_categories()
	..()

/obj/machinery/autolathe/mechfab/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["action"] == "sync")
		sync(usr)
		return 1

/obj/machinery/autolathe/mechfab/proc/sync(mob/user)
	var/sync = FALSE

	for(var/obj/machinery/computer/rdconsole/RDC in get_area_all_atoms(get_area(src)))
		if(!RDC.sync)
			continue
		files.download_from(RDC.files)
		to_chat(user, SPAN_NOTICE("Sync with [RDC] complete."))
		sync = TRUE

	if(!sync)
		to_chat(user, SPAN_WARNING("Error: no research console with enabled sync was found."))

	update_categories()

/obj/machinery/autolathe/mechfab/proc/update_categories()
	categories = files.design_categories_mechfab
	if(!show_category && length(categories))
		show_category = categories[1]



// A version with some materials already loaded, to be used on map spawn
/obj/machinery/autolathe/mechfab/loaded
	stored_material = list(
		MATERIAL_STEEL = 120,
		MATERIAL_PLASTIC = 120,
		MATERIAL_GLASS = 120,
		)

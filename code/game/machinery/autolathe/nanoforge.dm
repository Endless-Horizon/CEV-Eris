/obj/machinery/autolathe/nanoforge
	name = "matter auto-nanoforge"
	desc = "It consumes items and produces compressed matter."
	icon_state = "nanoforge"
	icon = 'icons/obj/machines/autolathe.dmi'
	use_oddities = TRUE
	is_nanoforge = TRUE
	low_quality_print = FALSE
	circuit = /obj/item/electronics/circuitboard/nanoforge
	var/list/tags_to_spawn = list(SPAWN_DESIGN)
	var/list/nano_disks = list()

	var/static/list/matter_to_compressed = list(
	MATERIAL_IRON = 0.6,
	MATERIAL_GLASS = 0.4,
	MATERIAL_STEEL = 0.3,
	MATERIAL_PLASMAGLASS = 0.6,
	MATERIAL_DIAMOND = 0.7,
	MATERIAL_PLASMA = 0.5,
	MATERIAL_GOLD = 0.6,
	MATERIAL_URANIUM = 0.7,
	MATERIAL_SILVER = 0.6,
	MATERIAL_PLASTEEL = 0.6,
	MATERIAL_PLASTIC = 0.4,
	MATERIAL_TRITIUM = 0.7,
	MATERIAL_PLATINUM = 0.7,
	MATERIAL_MHYDROGEN = 0.8,
	MATERIAL_WOOD = 0.1,
	MATERIAL_CLOTH = 0.1,
	MATERIAL_CARDBOARD = 0.1,
	MATERIAL_RGLASS = 0.4,
	MATERIAL_LEATHER = 0.1,
	MATERIAL_TITANIUM = 0.6)

/obj/machinery/autolathe/nanoforge/proc/compress_matter(mob/user)
	if(!inspiration || !inspiration.perk)
		to_chat(user, SPAN_WARNING("Catalyst not found."))
		return
	var/compressed_amt
	for(var/mat in stored_material)
		compressed_amt += stored_material[mat] * matter_to_compressed[mat]
	if(compressed_amt < 1)
		to_chat(user, SPAN_WARNING("Not enough materials."))
	else
		if(user)
			var/list/options = list("yes", "no")
			var/option = input(user, "Proceed?", "Compressing matter will use all of the stored materials", null) as null|anything in options
			if(option == "no")
				return
		stored_material = list()
		playsound(src.loc, 'sound/sanity/hydraulic.ogg', 50, 1)
		spawn(7)
			new /obj/item/stack/material/compressed(drop_location(), round(compressed_amt))

/obj/machinery/autolathe/nanoforge/Topic(href, href_list)
	if(..())
		return
	if(href_list["compress_matter"])
		compress_matter(usr)
		return TRUE

	if(href_list["make_designs"])
		make_designs(usr)
		return TRUE

/obj/machinery/autolathe/nanoforge/remove_oddity(mob/living/user)
	. = ..()
	clear_queue()

/obj/machinery/autolathe/nanoforge/proc/make_designs(mob/user)
	if(!inspiration || !inspiration.perk)
		to_chat(user, SPAN_WARNING("Catalyst not found."))
		return
	var/list/candidates = SSspawn_data.valid_candidates(tags_to_spawn, null, FALSE, null, null, TRUE, null, nano_disks, null)
	if(!candidates.len)
		to_chat(user, SPAN_WARNING("[src] has reached its maximum capacity."))
		return
	var/path = SSspawn_data.pick_spawn(candidates)
	nano_disks += list(path)
	var/obj/item/computer_hardware/hard_drive/portable/design/D = new path
	saved_designs |= D.find_files_by_type(/datum/computer_file/binary/design)
	remove_oddity(user, TRUE)

/obj/machinery/autolathe/nanoforge/icon_off()
	. = ..()
	if(. || !inspiration)
		icon_state = initial(icon_state)
		icon_state = "[icon_state]_off"
		. = TRUE

/obj/machinery/autolathe/nanoforge/check_user(mob/user)
	if(user.stats?.getPerk(PERK_TECHNOMANCER) || user.stat_check(STAT_MEC, STAT_LEVEL_EXPERT))
		return TRUE
	to_chat(user, SPAN_NOTICE("You don't know how to make [src] work."))
	return FALSE

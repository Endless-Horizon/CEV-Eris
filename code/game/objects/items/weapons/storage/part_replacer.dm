/obj/item/storage/part_replacer
	name = "rapid part exchange device"
	desc = "Special mechanical module made to store, sort, and apply standard machine parts."
	icon_state = "RPED"
	item_state = "RPED"
	w_class = ITEM_SIZE_HUGE
	can_hold = list(/obj/item/stock_parts)
	storage_slots = 50
	use_to_pickup = TRUE
	allow_quick_gather = TRUE
	allow_quick_empty = TRUE
	collection_mode = TRUE
	display_contents_with_number = TRUE
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = 100
	matter = list(MATERIAL_PLASTIC = 5, MATERIAL_STEEL = 2)

/obj/item/storage/part_replacer/debugparts
	bad_type = /obj/item/storage/part_replacer/debugparts
	
/obj/item/storage/part_replacer/debugparts/populate_contents()
	new /obj/item/stock_parts/capacitor/debug(src)
	new /obj/item/stock_parts/capacitor/debug(src)
	new /obj/item/stock_parts/capacitor/debug(src)
	new /obj/item/stock_parts/scanning_module/debug(src)
	new /obj/item/stock_parts/scanning_module/debug(src)
	new /obj/item/stock_parts/scanning_module/debug(src)
	new /obj/item/stock_parts/manipulator/debug(src)
	new /obj/item/stock_parts/manipulator/debug(src)
	new /obj/item/stock_parts/manipulator/debug(src)
	new /obj/item/stock_parts/micro_laser/debug(src)
	new /obj/item/stock_parts/micro_laser/debug(src)
	new /obj/item/stock_parts/micro_laser/debug(src)
	new /obj/item/stock_parts/matter_bin/debug(src)
	new /obj/item/stock_parts/matter_bin/debug(src)
	new /obj/item/stock_parts/matter_bin/debug(src)

/datum/trade_station/example
	start_discovered = TRUE
	max_missing_assortiment = 1

	name_pool = list(
		"Name" = "Description",
		"T3-ST" = "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
	)

	//Types of items sold by the station
	assortiment = list(
		"Cells"  = list(
			/obj/item/cell/large = custom_good_name("Large Not a Cell"),
			/obj/item/cell/medium = custom_good_amount_range(list(0,3)),
			/obj/item/cell/small = good_data("Small Not a Cell", list(6, 20)),
		)
	)

	//Types of items the station may ask for
	offer_types = list(
		/obj/item/computer_hardware/hard_drive/cluster,
		/obj/item/computer_hardware/processor_unit/super,
	)

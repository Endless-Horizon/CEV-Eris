/obj/item/reagent_containers/food/drinks/drinkingglass
	name = MATERIAL_GLASS
	desc = "Your standard drinking glass."
	icon_state = "glass_empty"
	amount_per_transfer_from_this = 5
	matter = list(MATERIAL_GLASS = 0.5)
	volume = 30
	unacidable = 1 //glass
	center_of_mass = list("x"=16, "y"=10)
	spawn_tags = SPAWN_TAG_JUNK
	rarity_value = 20

/obj/item/reagent_containers/food/drinks/drinkingglass/on_reagent_change()
	if (reagents.reagent_list.len > 0)
		var/datum/reagent/R = reagents.get_master_reagent()

		if(R.glass_icon_state)
			icon_state = R.glass_icon_state
		else
			icon_state = "glass_brown"

		if(R.glass_name)
			name = "glass of [R.glass_name]"
		else
			name = "glass of.. what?"

		if(R.glass_desc)
			desc = R.glass_desc
		else
			desc = "You can't really tell what this is."

		if(R.glass_center_of_mass)
			center_of_mass = R.glass_center_of_mass
		else
			center_of_mass = list("x"=16, "y"=10)
	else
		icon_state = "glass_empty"
		name = MATERIAL_GLASS
		desc = "Your standard drinking glass."
		center_of_mass = list("x"=16, "y"=10)
		return

// for /obj/machinery/vending/sovietsoda
/obj/item/reagent_containers/food/drinks/drinkingglass/soda
	preloaded_reagents = list("sodawater" = 50)
	rarity_value = 40

/obj/item/reagent_containers/food/drinks/drinkingglass/cola
	preloaded_reagents = list("cola" = 50)
	rarity_value = 40


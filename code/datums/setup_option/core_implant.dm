/datum/category_group/setup_option_category/core_implant
	name = "Core implant"
	category_item_type = /datum/category_item/setup_option/core_implant

/datum/category_item/setup_option/core_implant
	var/implant_type

/datum/category_item/setup_option/core_implant/get_icon()
	var/obj/item/implant/core_implant/CI = implant_type
	if(CI)
		return icon(initial(CI.icon),initial(CI.icon_state))

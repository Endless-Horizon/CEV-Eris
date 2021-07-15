// "Useful" items - I'm guessing things that might be used at work?
/datum/gear/utility
	display_name = "briefcase"
	path = /obj/item/storage/briefcase
	sort_category = "Utility"

/datum/gear/utility/clipboard
	display_name = "clipboard"
	path = /obj/item/clipboard

/datum/gear/utility/folder_colorable
	display_name = "folder, colorable"
	flags = GEAR_HAS_COLOR_SELECTION
	path = /obj/item/folder

/datum/gear/utility/folder_presets
	display_name = "folder"
	path = /obj/item/folder

/datum/gear/utility/folder_presets/New()
	..()
	var/folder = list(
		"Grey"			=	/obj/item/folder,
		"Cyan"			=	/obj/item/folder/cyan,
		"Red"			=	/obj/item/folder/red,
		"Yellow"		=	/obj/item/folder/yellow,
		"Blue"			=	/obj/item/folder/blue,
	)
	gear_tweaks += new /datum/gear_tweak/path(folder)

/datum/gear/utility/paicard
	display_name = "personal AI device"
	path = /obj/item/device/paicard

/datum/gear/utility/cheaptablet
	display_name = "cheap tablet computer"
	path = /obj/item/modular_computer/tablet/preset/custom_loadout/cheap
	cost = 2
/datum/gear/utility/wheelchair
	display_name = "wheelchair"
	path = /obj/item/wheelchair
	cost = 3

/datum/gear/utility/normaltablet
	display_name = "advanced tablet computer"
	path = /obj/item/modular_computer/tablet/preset/custom_loadout/advanced
	cost = 3

/datum/gear/utility/cheaplaptop
	display_name = "military laptop"
	path = /obj/item/modular_computer/laptop/preset/custom_loadout/cheap/elbrus4kk
	cost = 2

/datum/gear/utility/normallaptop
	display_name = "consumer laptop"
	path = /obj/item/modular_computer/laptop/preset/custom_loadout/standard/xenoware
	cost = 3

/datum/gear/utility/advancedlaptop
	display_name = "high-tech laptop"
	path = /obj/item/modular_computer/laptop/preset/custom_loadout/advanced/golden
	cost = 5

/datum/gear/utility/ducttape
	display_name = "duct tape"
	path = /obj/item/tool/tape_roll
	cost = 3
/datum/computer_file/program/chem_catalog
	filename = "chemCatalog"
	filedesc = "MIRC"
	extended_desc = "Moebius Internal Reagent Catalogue - Electronic catalog containing all information about basic chemical reactions and reagents."
	program_icon_state = "generic"
	program_key_state = "generic_key"
	size = 2
	available_on_ntnet = 1
	nanomodule_path = /datum/nano_module/chem_catalog
	usage_flags = PROGRAM_ALL

/datum/nano_module/chem_catalog
	name = "Chemistry Catalog"

/datum/nano_module/chem_catalog/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = NANOUI_REINITIALIZE, state = GLOB.default_state)
	var/list/data = nano_ui_data(user)
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "chemistry_catalog.tmpl", name, 640, 700, state = state)
		ui.set_initial_data(data)
		refresh_catalog_browsing(user, ui)
		ui.auto_update_layout = 1
		ui.open()

/datum/nano_module/chem_catalog/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["greet"])
		browse_catalog(GLOB.catalogs[CATALOG_CHEMISTRY], usr)
		return 0

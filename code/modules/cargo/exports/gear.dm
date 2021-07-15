// Armor, gloves, space suits - it all goes here

/datum/export/gear

// Security gear
/datum/export/gear/sec_helmet
	cost = 100
	include_subtypes = FALSE
	unit_name = "helmet"
	export_types = list(/obj/item/clothing/head/armor/helmet)

/datum/export/gear/sec_armor
	cost = 200
	include_subtypes = FALSE
	unit_name = "armor vest"
	export_types = list(/obj/item/clothing/suit/armor/vest)
	include_subtypes = FALSE


/datum/export/gear/riot_helmet
	cost = 250
	unit_name = "riot helmet"
	export_types = list(/obj/item/clothing/head/armor/faceshield/riot)

/datum/export/gear/riot_armor
	cost = 500
	unit_name = "riot armor suit"
	export_types = list(/obj/item/clothing/suit/armor/heavy/riot)

/datum/export/gear/bulletproof_armor
	cost = 500
	unit_name = "bulletproof armor vest"
	export_types = list(/obj/item/clothing/suit/armor/bulletproof)

/datum/export/gear/reflector_armor
	cost = 650
	unit_name = "reflector armor vest"
	export_types = list(/obj/item/clothing/suit/armor/laserproof)


/datum/export/gear/riot_shield
	cost = 400
	unit_name = "riot shield"
	export_types = list(/obj/item/shield/riot)


// Masks
/datum/export/gear/mask/breath
	cost = 20
	unit_name = "breath mask"
	export_types = list(/obj/item/clothing/mask/breath)

/datum/export/gear/mask/gas
	cost = 50
	unit_name = "gas mask"
	export_types = list(/obj/item/clothing/mask/gas)
	include_subtypes = FALSE



// EVA gear
/datum/export/gear/space
	include_subtypes = TRUE

/datum/export/gear/space/helmet
	cost = 400
	unit_name = "space helmet"
	export_types = list(/obj/item/clothing/head/space)
	include_subtypes = FALSE

/datum/export/gear/space/suit
	cost = 600
	unit_name = "space suit"
	export_types = list(/obj/item/clothing/suit/space)
	include_subtypes = FALSE

/datum/export/gear/space/helmet/emergency
	cost = 200
	unit_name = "emergency space helmet"
	export_types = list(/obj/item/clothing/head/space/emergency)
	include_subtypes = TRUE

/datum/export/gear/space/suit/emergency
	cost = 300
	unit_name = "emergency space suit"
	export_types = list(/obj/item/clothing/suit/space/emergency)
	include_subtypes = TRUE


/datum/export/gear/space/voidsuit
	cost = 1200 //650 for the suit, 550 for the helmet
	unit_name = "void suit"
	export_types = list(/obj/item/clothing/suit/space/void)


/datum/export/gear/space/syndiehelmet
	cost = 1000
	unit_name = "Syndicate space helmet"
	export_types = list(/obj/item/clothing/head/space/syndicate)
	include_subtypes = TRUE

/datum/export/gear/space/syndiesuit
	cost = 1500
	unit_name = "Syndicate space suit"
	export_types = list(/obj/item/clothing/suit/space/syndicate)
	include_subtypes = TRUE

/datum/export/gear/space/syndievoid
	cost = 2500 //1500 for the suit, 1000 for the helmet
	unit_name = "Syndicate void suit"
	export_types = list(/obj/item/clothing/suit/space/void/merc)
	include_subtypes = TRUE

/datum/export/gear/space/helmet/captain
	cost = 1000
	unit_name = "Captain's space helmet"
	export_types = list(/obj/item/clothing/head/space/capspace)

/datum/export/gear/space/suit/captain
	cost = 1500
	unit_name = "Captain's space suit"
	export_types = list(/obj/item/clothing/suit/space/captain)


// Radsuits
/datum/export/gear/radhelmet
	cost = 50
	unit_name = "radsuit hood"
	export_types = list(/obj/item/clothing/head/radiation)

/datum/export/gear/radsuit
	cost = 100
	unit_name = "radsuit"
	export_types = list(/obj/item/clothing/suit/radiation)

// Biosuits
/datum/export/gear/biohood
	cost = 50
	unit_name = "biosuit hood"
	export_types = list(/obj/item/clothing/head/bio_hood)

/datum/export/gear/biosuit
	cost = 100
	unit_name = "biosuit"
	export_types = list(/obj/item/clothing/suit/bio_suit)

//--------------------------------------------
//---------------GLASSES----------------------
//--------------------------------------------

/datum/export/gear/glasses
	cost = 150
	include_subtypes = FALSE
	unit_name = "glasses"
	export_types = list(/obj/item/clothing/glasses)

/datum/export/gear/glasses/hud
	cost = 200
	include_subtypes = TRUE
	unit_name = "hud glasses"
	export_types = list(/obj/item/clothing/glasses/hud)

/datum/export/gear/glasses/meson
	cost = 350
	unit_name = "meson glasses"
	export_types = list(/obj/item/clothing/glasses/powered/meson)

/datum/export/gear/glasses/night
	cost = 2000
	unit_name = "night vision glasses"
	export_types = list(/obj/item/clothing/glasses/powered/night)

/datum/export/gear/glasses/thermal
	cost = 3000
	include_subtypes = TRUE
	unit_name = "thermal vision glasses"
	export_types = list(/obj/item/clothing/glasses/powered/thermal)

/datum/export/gear/glasses/welding
	cost = 100
	include_subtypes = TRUE
	unit_name = "welding glasses"
	export_types = list(/obj/item/clothing/glasses/welding)


//--------------------------------------------
//----------------SHOES-----------------------
//--------------------------------------------


/datum/export/gear/shoes/jackboots
	cost = 100
	unit_name = "jackboots"
	export_types = list(/obj/item/clothing/shoes/jackboots)

/datum/export/gear/shoes/magboots
	cost = 500
	unit_name = "magboots"
	export_types = list(/obj/item/clothing/shoes/magboots)
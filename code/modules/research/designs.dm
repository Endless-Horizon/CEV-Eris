/***************************************************************
**						Design Datums						  **
**	All the data for building stuff and tracking reliability. **
***************************************************************/
/*
For the materials datum, it assumes you need reagents unless specified otherwise. To designate a material that isn't a reagent,
you use one of the material IDs below. These are NOT ids in the usual sense (they aren't defined in the object or part of a datum),
they are simply references used as part of a "has materials?" type proc. They all start with a  to denote that they aren't reagents.
The currently supporting non-reagent materials:

Don't add new keyword/IDs if they are made from an existing one (such as rods which are made from metal). Only add raw materials.

Design Guidlines
- When adding new designs, check rdreadme.dm to see what kind of things have already been made and where new stuff is needed.
- A single sheet of anything is 1 unit of material. Materials besides metal/glass require help from other jobs (mining for
other types of metals and chemistry for reagents).

*/


/datum/design/research				//Datum for object designs, used in construction
	starts_unlocked = FALSE

/datum/design/research/item
	category = "Misc" //We default to misc so that we are sorted
	build_type = AUTOLATHE | PROTOLATHE

/datum/design/research/item/mechfab
	build_type = MECHFAB
	category = "Misc"

/datum/design/research/item/flash
	name = "flash"
	build_type = AUTOLATHE | MECHFAB
	build_path = /obj/item/device/flash
	category = "Misc"

/datum/design/research/item/science_tool
	name = "science tool"
	build_path = /obj/item/device/science_tool

/datum/design/research/item/hud
	name_category = "HUD glasses"

/datum/design/research/item/hud/health
	name = "health scanner"
	build_path = /obj/item/clothing/glasses/hud/health
	sort_string = "GAAAA"
	category = "Medical"

/datum/design/research/item/hud/security
	name = "security records"
	build_path = /obj/item/clothing/glasses/hud/security
	sort_string = "GAAAB"

/datum/design/research/item/medical
	name_category = "biotech device prototype"
	category = "Medical"

/datum/design/research/item/medical/robot_scanner
	desc = "A hand-held scanner able to diagnose robotic injuries."
	build_path = /obj/item/device/robotanalyzer
	sort_string = "MACFA"

/datum/design/research/item/medical/mass_spectrometer
	desc = "A device for analyzing chemicals in blood."
	build_path = /obj/item/device/scanner/mass_spectrometer
	sort_string = "MACAA"

/datum/design/research/item/medical/adv_mass_spectrometer
	desc = "A device for analyzing chemicals in blood and their quantities."
	build_path = /obj/item/device/scanner/mass_spectrometer/adv
	sort_string = "MACAB"

/datum/design/research/item/medical/reagent_scanner
	desc = "A device for identifying chemicals."
	build_path = /obj/item/device/scanner/reagent
	sort_string = "MACBA"

/datum/design/research/item/medical/adv_reagent_scanner
	desc = "A device for identifying chemicals and their proportions."
	build_path = /obj/item/device/scanner/reagent/adv
	sort_string = "MACBB"

/datum/design/research/item/beaker
	name_category = "beaker prototype"
	category = "Medical"

/datum/design/research/item/beaker/noreact
	name = "cryostasis"
	desc = "A cryostasis beaker that allows for chemical storage without reactions. Can hold up to 50 units."
	build_path = /obj/item/reagent_containers/glass/beaker/noreact
	sort_string = "MADAA"

/datum/design/research/item/beaker/bluespace
	name = "bluespace"
	desc = "A bluespace beaker, powered by experimental bluespace technology and Element Cuban combined with the Compound Pete. Can hold up to 300 units."
	build_path = /obj/item/reagent_containers/glass/beaker/bluespace
	sort_string = "MADAB"

/datum/design/research/item/medical/nanopaste
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	build_path = /obj/item/stack/nanopaste
	sort_string = "MBAAA"
	chemicals = list("nanites" = 5)

/datum/design/research/item/scalpel_laser
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field."
	build_path = /obj/item/tool/scalpel/laser
	category = "Medical"
	sort_string = "MBBAA"

/datum/design/research/item/makeshift_centrifuge
	name = "Portable centrifuge"
	desc = "A centrifuge with manual mechanism."
	build_path = /obj/item/device/makeshift_centrifuge
	category = "Medical"
	sort_string = "MBBAA"

/datum/design/research/item/light_replacer
	name = "light replacer"
	desc = "A device to automatically replace lights. Refill with working lightbulbs."
	build_path = /obj/item/device/lightreplacer
	sort_string = "VAAAH"

/datum/design/research/item/paicard
	name = "'pAI', personal artificial intelligence device"
	build_path = /obj/item/device/paicard
	sort_string = "VABAI"

/datum/design/research/item/intellicard
	name = "'intelliCard', AI preservation and transportation system"
	desc = "Allows for the construction of an intelliCard."
	build_path = /obj/item/device/aicard
	sort_string = "VACAA"

/datum/design/research/item/posibrain
	name = "Positronic brain"
	build_type = PROTOLATHE | MECHFAB
	build_path = /obj/item/device/mmi/digital/posibrain
	category = "Medical"
	sort_string = "VACAB"

/datum/design/research/item/mmi
	name = "Man-machine interface"
	build_type = PROTOLATHE | MECHFAB
	build_path = /obj/item/device/mmi
	category = "Medical"
	sort_string = "VACBA"

/datum/design/research/item/mmi_radio
	name = "Radio-enabled man-machine interface"
	build_type = PROTOLATHE | MECHFAB
	build_path = /obj/item/device/mmi/radio_enabled
	category = "Medical"
	sort_string = "VACBB"

/datum/design/research/item/beacon
	name = "Bluespace tracking beacon design"
	build_path = /obj/item/device/radio/beacon
	category = "Telecoms | Bluespace"
	sort_string = "VADAA"

/datum/design/research/item/bag_holding
	name = "'Bag of Holding', an infinite capacity bag prototype"
	desc = "Using localized pockets of bluespace this bag prototype offers incredible storage capacity with the contents weighing nothing. It's a shame the bag itself is pretty heavy."
	build_path = /obj/item/storage/backpack/holding
	category = "Telecoms | Bluespace"
	sort_string = "VAEAA"

/datum/design/research/item/belt_holding
	name = "'Belt of Holding', an infinite capacity belt prototype"
	desc = "Using localized pockets of bluespace this belt prototype offers incredible storage capacity with the contents weighing nothing."
	build_path = /obj/item/storage/belt/holding
	category = "Telecoms | Bluespace"
	sort_string = "VAEAB"

/datum/design/research/item/pouch_holding
	name = "'Pouch of Holding', an infinite capacity pouch prototype"
	desc = "Using localized pockets of bluespace this pouch prototype offers incredible storage capacity with the contents weighing nothing."
	build_path = /obj/item/storage/pouch/holding
	category = "Telecoms | Bluespace"
	sort_string = "VAEAC"

/datum/design/research/item/trashbag_holding
	name = "'Trashbag of Holding', an infinite capacity trashbag prototype"
	desc = "Using localized pockets of bluespace this trashbag prototype offers incredible storage capacity with the contents weighing nothing."
	build_path = /obj/item/storage/bag/trash/holding
	category = "Telecoms | Bluespace"
	sort_string = "VAEAD"

/datum/design/research/item/oresatchel_holding
	name = "'Ore satchel of Holding', an infinite capacity ore satchel prototype"
	desc = "Using localized pockets of bluespace this ore satchel prototype offers incredible storage capacity with the contents weighing nothing."
	build_path = /obj/item/storage/bag/ore/holding
	category = "Telecoms | Bluespace"
	sort_string = "VAEAE"

/datum/design/research/item/binaryencrypt
	name = "Binary encryption key"
	desc = "Allows for deciphering the binary channel on-the-fly."
	build_path = /obj/item/device/encryptionkey/binary
	category = "Telecoms | Bluespace"
	sort_string = "VASAA"

/datum/design/research/item/glowstick
	name = "Undark Glowstick"
	desc = "A refined cocktail of all the needed things to glow in the dark!"
	build_path = /obj/item/device/lighting/glowstick/undark //Yes 1920s were a wild time
	sort_string = "VASAB"
	chemicals = list("radium" = 5, "phosphorus" = 10)
	materials = list(MATERIAL_GLASS = 2, MATERIAL_PLASTIC = 15)

/datum/design/research/item/science_voidsuit
	name = "Moebius combat voidsuit"
	build_path = /obj/item/clothing/suit/space/void/science
	sort_string = "VASAC"


//Why is there a science design to craft a cardboard box full of things? That is not how this works
/*
/datum/design/research/item/chameleon
	name = "Holographic equipment kit"
	desc = "A kit of dangerous, high-tech equipment with changeable looks."
	req_tech = list(TECH_COVERT = 2)
	build_path = /obj/item/storage/box/syndie_kit/chameleon
	sort_string = "VASBA"
*/

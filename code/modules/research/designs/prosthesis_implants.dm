//Prosthesis ====================================

/datum/design/research/item/mechfab/prosthesis
	category = CAT_PROSTHESIS
	starts_unlocked = TRUE

/datum/design/research/item/mechfab/prosthesis/r_arm
	build_path = /obj/item/organ/external/robotic/r_arm

/datum/design/research/item/mechfab/prosthesis/l_arm
	build_path = /obj/item/organ/external/robotic/l_arm

/datum/design/research/item/mechfab/prosthesis/r_leg
	build_path = /obj/item/organ/external/robotic/r_leg

/datum/design/research/item/mechfab/prosthesis/l_leg
	build_path = /obj/item/organ/external/robotic/l_leg

/datum/design/research/item/mechfab/prosthesis/groin
	build_path = /obj/item/organ/external/robotic/groin

//Upgraded prosthesis ========================
/datum/design/research/item/mechfab/prosthesis_moebius
	category = CAT_PROSTHESIS

/datum/design/research/item/mechfab/prosthesis_moebius/r_arm
	build_path = /obj/item/organ/external/robotic/moebius/reinforced/r_arm

/datum/design/research/item/mechfab/prosthesis_moebius/l_arm
	build_path = /obj/item/organ/external/robotic/moebius/reinforced/l_arm

/datum/design/research/item/mechfab/prosthesis_moebius/r_leg
	build_path = /obj/item/organ/external/robotic/moebius/reinforced/r_leg

/datum/design/research/item/mechfab/prosthesis_moebius/l_leg
	build_path = /obj/item/organ/external/robotic/moebius/reinforced/l_leg

/datum/design/research/item/mechfab/prosthesis_moebius/groin
	build_path = /obj/item/organ/external/robotic/moebius/reinforced/groin

/datum/design/research/item/mechfab/prosthesis_moebius/head
	build_path = /obj/item/organ/external/robotic/moebius/reinforced/head

//Modules ====================================

/datum/design/research/item/mechfab/modules
	category = CAT_PROSTHESIS

/datum/design/research/item/mechfab/modules/armor
	name = "subdermal body armor"
	build_path = /obj/item/organ_module/armor

/datum/design/research/item/mechfab/modules/armblade
	name = "Embedded armblade"
	build_path = /obj/item/organ_module/active/simple/armblade

/datum/design/research/item/mechfab/modules/runner
	name = "Mechanical muscles"
	build_path = /obj/item/organ_module/muscle


/datum/design/research/item/mechfab/modules/multitool/surgical
	build_path = /obj/item/organ_module/active/simple/surgical
	name = "Embedded surgical multitool"

/datum/design/research/item/mechfab/modules/multitool/engineer
	build_path = /obj/item/organ_module/active/simple/engineer
	name = "Embedded Technomancer multitool"

/datum/design/research/item/mechfab/modules/multitool/miner
	build_path = /obj/item/organ_module/active/multitool/miner
	name = "Embedded mining multitool"

//Implants
/datum/design/research/item/implant
	build_type = PROTOLATHE | MECHFAB
	name_category = "implantable biocircuit"
	category = CAT_PROSTHESIS

/datum/design/research/item/implant/chemical
	name = "chemical"
	build_path = /obj/item/implantcase/chem
	sort_string = "MFAAA"

/datum/design/research/item/implant/freedom
	name = "freedom"
	build_path = /obj/item/implantcase/freedom
	sort_string = "MFAAB"

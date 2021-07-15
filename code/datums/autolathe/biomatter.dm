/datum/design/bioprinter
	build_type = BIOPRINTER
	materials = list(MATERIAL_BIOMATTER = 6)
	factions = list(FACTION_NEOTHEOLOGY)

/datum/design/bioprinter/meat
	name = "Meat"
	build_path = /obj/item/reagent_containers/food/snacks/meat
	materials = list(MATERIAL_BIOMATTER = 5)

/datum/design/bioprinter/milk
	name = "Milk"
	build_path = /obj/item/reagent_containers/food/drinks/milk

/datum/design/bioprinter/soap
	name = "Soap"
	build_path = /obj/item/soap/nanotrasen

//[NUTRIMENTS]
/datum/design/bioprinter/ez
	name = "EZ-Nutrient"
	build_path = /obj/item/reagent_containers/glass/fertilizer/ez
	materials = list(MATERIAL_BIOMATTER = 3)

/datum/design/bioprinter/l4z
	name = "Left4Zed"
	build_path = /obj/item/reagent_containers/glass/fertilizer/l4z

/datum/design/bioprinter/rh
	name = "Robust Harvestt"
	build_path = /obj/item/reagent_containers/glass/fertilizer/rh
	materials = list(MATERIAL_BIOMATTER = 7.5)
//[/NUTRIMENTS]

//[CLOTHES, ARMOR AND ACCESORIES]
/datum/design/bioprinter/nt_clothes/acolyte_armor
	name = "NT Acolyte Armor"
	build_path = /obj/item/clothing/suit/armor/acolyte

/datum/design/bioprinter/nt_clothes/agrolyte_armor
	name = "NT Agrolyte Armor"
	build_path = /obj/item/clothing/suit/armor/agrolyte

/datum/design/bioprinter/nt_clothes/custodian_armor
	name = "NT Custodian Armor"
	build_path = /obj/item/clothing/suit/armor/custodian

/datum/design/bioprinter/nt_clothes/acolyte_armor_head
	name = "NT Acolyte Hood"
	build_path = /obj/item/clothing/head/armor/acolyte

/datum/design/bioprinter/nt_clothes/agrolyte_armor_head
	name = "NT Agrolyte Helmet"
	build_path = /obj/item/clothing/head/armor/agrolyte

/datum/design/bioprinter/nt_clothes/custodian_armor_head
	name = "NT Custodian Helmet"
	build_path = /obj/item/clothing/head/armor/custodian

/datum/design/bioprinter/nt_clothes/preacher_coat
	name = "NT Preacher Longcoat"
	build_path = /obj/item/clothing/suit/storage/neotheology_coat

/datum/design/bioprinter/nt_clothes/acolyte_jacket
	name = "NT Acolyte Jacket"
	build_path = /obj/item/clothing/suit/storage/neotheology_jacket

/datum/design/bioprinter/nt_clothes/sports_jacket
	name = "NT Sports Jacket"
	build_path = /obj/item/clothing/suit/storage/neotheosports

/datum/design/bioprinter/nt_clothes/acolyte_uniform
	name = "NT Acolyte Garment"
	build_path = /obj/item/clothing/under/rank/acolyte

/datum/design/bioprinter/nt_clothes/sports_uniform
	name = "NT Sport Clothes"
	build_path = /obj/item/clothing/under/rank/church/sport

/datum/design/bioprinter/nt_clothes/church_uniform
	name = "NT Church Garment"
	build_path = /obj/item/clothing/under/rank/church

/datum/design/bioprinter/belt/utility/neotheology
	name = "Neotheologian utility belt"
	build_path = /obj/item/storage/belt/utility/neotheology

/datum/design/bioprinter/belt/security/neotheology
	name = "Neotheologian tactical belt"
	build_path = /obj/item/storage/belt/tactical/neotheology

// This separates regular clothes designs from NT clothes designs //

/datum/design/bioprinter/leather_jacket
	name = "Leather jacket"
	build_path = /obj/item/clothing/suit/storage/leather_jacket

/datum/design/bioprinter/leather/holster
	name = "shoulder holster"
	build_path = /obj/item/clothing/accessory/holster

/datum/design/bioprinter/leather/holster/armpit
	name = "armpit holster"
	build_path = /obj/item/clothing/accessory/holster/armpit

/datum/design/bioprinter/leather/holster/waist
	name = "waist holster"
	build_path = /obj/item/clothing/accessory/holster/waist

/datum/design/bioprinter/leather/holster/hip
	name = "hip holster"
	build_path = /obj/item/clothing/accessory/holster/hip

/datum/design/bioprinter/belt
	materials = list(MATERIAL_BIOMATTER = 30)

/datum/design/bioprinter/belt/utility
	name = "Utility belt"
	build_path = /obj/item/storage/belt/utility

/datum/design/bioprinter/belt/medical
	name = "Medical belt"
	build_path = /obj/item/storage/belt/medical

/datum/design/bioprinter/belt/security
	name = "Tactical belt"
	build_path = /obj/item/storage/belt/tactical

/datum/design/bioprinter/belt/medical/emt
	name = "EMT belt"
	build_path = /obj/item/storage/belt/medical/emt

/datum/design/bioprinter/belt/misc/champion
	name = "Champion belt"
	build_path = /obj/item/storage/belt/champion
	materials = list(MATERIAL_BIOMATTER = 50)

/datum/design/bioprinter/backpack
	name = "grey duffelbag"
	build_path = /obj/item/storage/backpack
	materials = list(MATERIAL_BIOMATTER = 40)

/datum/design/bioprinter/backpack/duffelbag
	name = "grey duffelbag"
	build_path = /obj/item/storage/backpack/duffelbag
	materials = list(MATERIAL_BIOMATTER = 65)

/datum/design/bioprinter/wallet
	name = "Wallet"
	build_path = /obj/item/storage/wallet

/datum/design/bioprinter/botanic_leather
	name = "Botanical gloves"
	build_path = /obj/item/clothing/gloves/botanic_leather
	materials = list(MATERIAL_BIOMATTER = 25)

/datum/design/bioprinter/leather
	materials = list(MATERIAL_BIOMATTER = 40)

/datum/design/bioprinter/satchel
	name = "Leather Satchel"
	build_path = /obj/item/storage/backpack/satchel

/datum/design/bioprinter/small_generic
	name= "Small generic pouch"
	build_path = /obj/item/storage/pouch/small_generic

/datum/design/bioprinter/medium_generic
	name= "Medium generic pouch"
	build_path = /obj/item/storage/pouch/medium_generic

/datum/design/bioprinter/large_generic
	name= "Large generic pouch"
	build_path = /obj/item/storage/pouch/large_generic

/datum/design/bioprinter/medical_supply
	name= "Medical supply pouch"
	build_path = /obj/item/storage/pouch/medical_supply

/datum/design/bioprinter/engineering_tools
	name= "Engineering tools pouch"
	build_path = /obj/item/storage/pouch/engineering_tools

/datum/design/bioprinter/engineering_supply
	name= "Engineering supply pouch"
	build_path = /obj/item/storage/pouch/engineering_supply

/datum/design/bioprinter/ammo
	name= "Ammo pouch"
	build_path = /obj/item/storage/pouch/ammo

/datum/design/bioprinter/tubular
	name= "Tubular pouch"
	build_path = /obj/item/storage/pouch/tubular

/datum/design/bioprinter/tubular/vial
	name= "Vial pouch"
	build_path = /obj/item/storage/pouch/tubular/vial

/datum/design/bioprinter/part
	name = "Part pouch"
	build_path = /obj/item/storage/pouch/gun_part

//[/CLOTHES, ARMOR AND ACCESORIES]

//[MISC]
/datum/design/bioprinter/storage/sheath
	name = "sheath"
	build_path = /obj/item/storage/belt/sheath

/datum/design/bioprinter/leather/cash_bag
	name = "Cash Bag"
	build_path = /obj/item/storage/bag/money

/datum/design/bioprinter/holyvacuum
	name = "\"Tersus\" Vacuum Cleaner"
	build_path = /obj/item/holyvacuum

//[/THINGS]
/datum/design/autolathe/nt
	factions = list(FACTION_NEOTHEOLOGY)

/datum/design/autolathe/firstaid/nt
	name = "NeoTheologian Medkit"
	build_path = /obj/item/storage/firstaid/nt
	factions = list(FACTION_NEOTHEOLOGY)

/datum/design/autolathe/excruciator
	name = "NeoTheology \"EXCRUCIATOR\" giga lens"
	build_path = /obj/item/gun_upgrade/barrel/excruciator
	factions = list(FACTION_NEOTHEOLOGY)

/datum/design/autolathe/cruciform_upgrade
	build_path = /obj/item/cruciform_upgrade
	factions = list(FACTION_NEOTHEOLOGY)

/datum/design/autolathe/cruciform_upgrade/natures_blessing
	name = "Natures blessing"
	build_path = /obj/item/cruciform_upgrade/natures_blessing

/datum/design/autolathe/cruciform_upgrade/faiths_shield
	name = "Faiths shield"
	build_path = /obj/item/cruciform_upgrade/faiths_shield

/datum/design/autolathe/cruciform_upgrade/cleansing_presence
	name = "Cleansing presence"
	build_path = /obj/item/cruciform_upgrade/cleansing_presence

/datum/design/autolathe/cruciform_upgrade/martyr_gift
	name = "Martyr gift"
	build_path = /obj/item/cruciform_upgrade/martyr_gift

/datum/design/autolathe/cruciform_upgrade/wrath_of_god
	name = "Wrath of god"
	build_path = /obj/item/cruciform_upgrade/wrath_of_god

/datum/design/autolathe/cruciform_upgrade/speed_of_the_chosen
	name = "Speed of the chosen"
	build_path = /obj/item/cruciform_upgrade/speed_of_the_chosen

//[MELEE]
/datum/design/autolathe/nt/sword/nt_sword
	name = "NT Shortsword"
	build_path = /obj/item/tool/sword/nt

/datum/design/autolathe/nt/sword/nt_longsword
	name = "NT Longsword"
	build_path = /obj/item/tool/sword/nt/longsword

/datum/design/autolathe/nt/sword/nt_dagger
	name = "NT Dagger"
	build_path = /obj/item/tool/knife/dagger/nt

/datum/design/autolathe/nt/sword/nt_halberd
	name = "NT Halberd"
	build_path = /obj/item/tool/sword/nt/halberd

/datum/design/autolathe/nt/sword/nt_scourge
	name = "NT Scourge"
	build_path = /obj/item/tool/sword/nt/scourge

/datum/design/autolathe/nt/shield/nt_shield
	name = "NT Shield"
	build_path = /obj/item/shield/riot/nt

/datum/design/autolathe/nt/tool_upgrade/sanctifier
	name = "sanctifier"
	build_path = /obj/item/tool_upgrade/augment/sanctifier

//[GRENADES]
/datum/design/autolathe/nt/grenade/nt_smokebomb
	name = "NT SG \"Holy Fog\""
	build_path = /obj/item/grenade/smokebomb/nt

/datum/design/autolathe/nt/grenade/nt_frag
	name = "NT DFG \"Holy Thunder\""
	build_path = /obj/item/grenade/frag/nt

/datum/design/autolathe/nt/grenade/nt_flashbang
	name = "NT FBG \"Holy Light\""
	build_path = /obj/item/grenade/flashbang/nt

/datum/design/autolathe/nt/grenade/nt_explosive
	name = "NT OBG \"Holy Grail\""
	build_path = /obj/item/grenade/explosive/nt

//[CRUSADE]
/datum/design/autolathe/nt/armor/crusader
	name = "crusader armor"
	build_path = /obj/item/clothing/suit/armor/crusader

/datum/design/autolathe/nt/helmet/crusader
	name = "crusader helmet"
	build_path = /obj/item/clothing/head/armor/helmet/crusader

/datum/design/autolathe/clothing/NTvoid
	name = "neotheology voidsuit"
	build_path = /obj/item/clothing/suit/space/void/NTvoid
	factions = list(FACTION_NEOTHEOLOGY)

//[MED]
/datum/design/bioprinter/medical
	materials = list(MATERIAL_BIOMATTER = 10)

/datum/design/bioprinter/medical/bruise
	name = "Roll of gauze"
	build_path = /obj/item/stack/medical/bruise_pack

/datum/design/bioprinter/medical/splints
	name = "Medical splints"
	build_path = /obj/item/stack/medical/splint

/datum/design/bioprinter/medical/ointment
	name = "Ointment"
	build_path = /obj/item/stack/medical/ointment


/datum/design/bioprinter/medical/advanced
	materials = list(MATERIAL_BIOMATTER = 20)

/datum/design/bioprinter/medical/advanced/bruise
	name = "Advanced trauma kit"
	build_path = /obj/item/stack/medical/advanced/bruise_pack

/datum/design/bioprinter/medical/advanced/ointment
	name = "Advanced burn kit"
	build_path = /obj/item/stack/medical/advanced/ointment

/datum/design/bioprinter/lungs
	name = "Extended Lungs"
	materials = list(MATERIAL_BIOMATTER = 30)
	build_path = /obj/item/organ/internal/lungs/long
//[/MED]

/**********
* Medical *
**********/
/datum/uplink_item/item/medical
	category = /datum/uplink_category/medical

/datum/uplink_item/item/medical/sinpockets
	name = "Box of Sin-Pockets"
	item_cost = 2
	path = /obj/item/storage/box/sinpockets

/datum/uplink_item/item/medical/surgery
	name = "Surgery kit"
	item_cost = 5
	path = /obj/item/storage/firstaid/surgery/traitor
	antag_roles = list(ROLE_TRAITOR,ROLE_MARSHAL,ROLE_INQUISITOR,ROLE_MERCENARY,ROLE_CARRION)

/datum/uplink_item/item/medical/combat
	name = "Combat medical kit"
	item_cost = 6
	path = /obj/item/storage/firstaid/combat

/datum/uplink_item/item/medical/nanites
	name = "Raw nanites vial"
	item_cost = 2
	path = /obj/item/reagent_containers/glass/beaker/vial/nanites

/datum/uplink_item/item/medical/uncapnanites
	name = "Raw uncapped nanites vial"
	item_cost = 3
	path = /obj/item/reagent_containers/glass/beaker/vial/uncapnanites

/datum/uplink_item/item/medical/randomstim
	name = "5 Random Stims Kit"
	item_cost = 5
	path = /obj/item/storage/box/syndie_kit/randomstim

/datum/uplink_item/item/medical/gene_vial
	name = "Genetic material vial"
	item_cost = 5
	path = /obj/item/gene_vial
	antag_roles = list(ROLE_CARRION)

/datum/uplink_item/item/medical/nanopaste
	name = "Nanopaste"
	item_cost = 3
	path = /obj/item/stack/nanopaste

/***************************************
* Highly Visible and Dangerous Weapons *
***************************************/
/datum/uplink_item/item/visible_weapons
	category = /datum/uplink_category/visible_weapons

/datum/uplink_item/item/visible_weapons/dartgun
	name = "Dart Gun"
	item_cost = 4
	path = /obj/item/storage/box/syndie_kit/dartgun

/datum/uplink_item/item/visible_weapons/crossbow
	name = "Energy Crossbow"
	item_cost = 6
	path = /obj/item/gun/energy/crossbow

/datum/uplink_item/item/visible_weapons/energy_sword
	name = "Energy Sword"
	item_cost = 6
	path = /obj/item/melee/energy/sword

/datum/uplink_item/item/visible_weapons/pistol
	name = "Silenced .25 Caseless Handgun"
	item_cost = 6
	path = /obj/item/storage/box/syndie_kit/pistol

/datum/uplink_item/item/visible_weapons/riggedlaser
	name = "Exosuit (APLU) Rigged Laser"
	item_cost = 4
	path = /obj/item/mech_equipment/mounted_system/taser/laser


/datum/uplink_item/item/visible_weapons/revolver
	name = "Revolver"
	item_cost = 7
	path = /obj/item/storage/box/syndie_kit/revolver

/datum/uplink_item/item/visible_weapons/submachinegun
	name = "Submachine Gun"
	item_cost = 7
	path = /obj/item/storage/box/syndie_kit/c20r

/datum/uplink_item/item/visible_weapons/assaultrifle
	name = "Assault Rifle"
	item_cost = 10
	path = /obj/item/storage/box/syndie_kit/sts35

/datum/uplink_item/item/visible_weapons/pug
	name = "Pug Shotgun"
	item_cost = 8
	path = /obj/item/storage/box/syndie_kit/pug

/datum/uplink_item/item/visible_weapons/heavysniper
	name = "Anti-material Rifle"
	item_cost = 20
	path = /obj/item/storage/briefcase/antimaterial_rifle

/datum/uplink_item/item/visible_weapons/rigged
	name = "Weapon reverse loader"
	item_cost = 5
	path = /obj/item/gun_upgrade/mechanism/reverse_loader

/datum/uplink_item/item/visible_weapons/boom_trigger
	name = "Syndicate \"Self Desturct\" trigger"
	item_cost = 5
	path = /obj/item/gun_upgrade/trigger/boom

/datum/uplink_item/item/visible_weapons/gauss
	name = "Syndicate \"Gauss Coil\" barrel"
	item_cost = 7
	path = /obj/item/gun_upgrade/barrel/gauss

/datum/uplink_item/item/visible_weapons/psychic_lasercannon
	name = "Prototype: psychic laser cannon"
	desc = "A laser cannon that attacks the minds of people, causing sanity loss and inducing mental breakdowns. Also can be used to complete mind fryer contracts."
	item_cost = 12
	path = /obj/item/gun/energy/psychic/lasercannon

/datum/uplink_item/item/visible_weapons/psychic_lasercannon/buy(obj/item/device/uplink/U)
	. = ..()
	if(.)
		var/obj/item/gun/energy/psychic/lasercannon/L = .
		L.owner = U.uplink_owner
/*
/datum/uplink_item/item/visible_weapons/pickle
	name = "Pickle"
	item_cost = 100
	path = /obj/item/storage/box/syndie_kit/pickle
*/

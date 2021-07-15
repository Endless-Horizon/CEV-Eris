/***********
* Implants *
***********/
/datum/uplink_item/item/implants
	category = /datum/uplink_category/implants

/datum/uplink_item/item/implants/imp_freedom
	name = "Freedom Implant"
	item_cost = 4
	path = /obj/item/storage/box/syndie_kit/imp_freedom

/datum/uplink_item/item/implants/imp_compress
	name = "Compressed Matter Implant"
	item_cost = 4
	path = /obj/item/storage/box/syndie_kit/imp_compress

/datum/uplink_item/item/implants/imp_explosive
	name = "Explosive Implant (DANGER!)"
	item_cost = 10
	path = /obj/item/storage/box/syndie_kit/imp_explosive

/datum/uplink_item/item/implants/imp_spying
	name = "Spying Implant"
	item_cost = 1
	path = /obj/item/storage/box/syndie_kit/imp_spying
	antag_roles = ROLES_CONTRACT

/datum/uplink_item/item/implants/imp_spying/buy(obj/item/device/uplink/U)
	. = ..()
	if(.)
		var/obj/item/storage/box/syndie_kit/imp_spying/B = .
		var/obj/item/implanter/spying/I = locate() in B
		var/obj/item/implant/spying/S = I.implant
		S.owner = U.uplink_owner

/datum/uplink_item/item/implants/imp_uplink
	name = "Uplink Implant"
	path = /obj/item/storage/box/syndie_kit/imp_uplink

/datum/uplink_item/item/implants/imp_uplink/New()
	..()
	item_cost = round(DEFAULT_TELECRYSTAL_AMOUNT / 2)
	desc = "Contains [round((DEFAULT_TELECRYSTAL_AMOUNT / 2) * 0.8)] Telecrystal\s"

/datum/uplink_item/item/implants/energy_blade
	name = "Internal Energy Armblade Implant"
	item_cost = 6
	path = /obj/item/organ_module/active/simple/armblade/energy_blade

/obj/item/gun/energy/sniperrifle
	name = "NT MER \"Valkyrie\""
	desc = "\"Valkyrie\" is an older design of Nanotrasen, \"Lightfall\" was based on it. A designated marksman rifle capable of shooting powerful ionized beams, this is a weapon for killing from a distance."
	icon = 'icons/obj/guns/energy/sniper.dmi'
	icon_state = "sniper"
	item_state = "sniper"
	item_charge_meter = TRUE
	fire_sound = 'sound/weapons/marauder.ogg'
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 5, TECH_POWER = 4)
	projectile_type = /obj/item/projectile/beam/sniper
	slot_flags = SLOT_BACK
	charge_cost = 300
	fire_delay = 35
	force = 10
	w_class = ITEM_SIZE_BULKY
	matter = list(MATERIAL_PLASTEEL = 20, MATERIAL_PLASTIC = 8, MATERIAL_SILVER = 9, MATERIAL_URANIUM = 6)
	price_tag = 5000
	cell_type = /obj/item/cell/medium
	zoom_factor = 2
	init_firemodes = list(
		WEAPON_NORMAL,
		WEAPON_CHARGE
	)
	twohanded = TRUE
	
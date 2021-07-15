/obj/item/gun/energy/decloner
	name = "Prototype: biological demolecularisor"
	desc = "A gun that discharges high amounts of controlled radiation to slowly break a target into component elements."
	icon = 'icons/obj/guns/energy/decloner.dmi'
	icon_state = "decloner"
	item_state = "decloner"
	fire_sound = 'sound/weapons/pulse3.ogg'
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 4, TECH_POWER = 3)
	can_dual = TRUE
	projectile_type = /obj/item/projectile/energy/declone
	charge_cost = 100
	matter = list(MATERIAL_STEEL = 20, MATERIAL_PLASTIC = 10, MATERIAL_URANIUM = 8, MATERIAL_SILVER = 2)
	price_tag = 1500

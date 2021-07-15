/obj/item/gun/energy/toxgun
	name = "Prototype: plasma pistol"
	desc = "A specialized firearm designed to fire lethal bolts of plasma."
	icon = 'icons/obj/guns/energy/toxgun.dmi'
	icon_state = "toxgun"
	fire_sound = 'sound/effects/stealthoff.ogg'
	w_class = ITEM_SIZE_NORMAL
	can_dual = TRUE
	origin_tech = list(TECH_COMBAT = 5, TECH_PLASMA = 4)
	matter = list(MATERIAL_STEEL = 20, MATERIAL_PLASMA = 5)
	price_tag = 2500
	projectile_type = /obj/item/projectile/energy/plasma

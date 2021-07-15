/obj/item/gun/energy/xray
	name = "xray laser gun"
	desc = "A high-power laser gun capable of expelling concentrated xray blasts."
	icon = 'icons/obj/guns/energy/xray.dmi'
	icon_state = "xray"
	item_state = "xray"
	fire_sound = 'sound/weapons/laser3.ogg'
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 3, TECH_MAGNET = 2, TECH_COVERT = 2)
	price_tag = 4000
	projectile_type = /obj/item/projectile/beam/xray
	charge_cost = 100
	fire_delay = 1
	twohanded = TRUE
	
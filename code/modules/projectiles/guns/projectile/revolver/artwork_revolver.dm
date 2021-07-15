/obj/item/gun/projectile/revolver/artwork_revolver
	name = "Weird Revolver"
	desc = "This is an artistically-made revolver."
	icon = 'icons/obj/guns/projectile/artwork_revolver.dmi'
	icon_state = "artwork_revolver_1"
	item_state = "artwork_revolver_1"
	drawChargeMeter = FALSE
	max_shells = 7
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 4) //Arbitrary values
	matter = list(MATERIAL_PLASTEEL = 12, MATERIAL_WOOD = 6)
	price_tag = 1000
	damage_multiplier = 1.4 //because pistol round //From havelock.dm
	penetration_multiplier = 1.4
	recoil_buildup = 30
	spawn_frequency = 0

/obj/item/gun/projectile/revolver/artwork_revolver/Initialize()
	name = get_weapon_name(capitalize = TRUE)
	var/random_icon = rand(1,5)
	icon_state = "artwork_revolver_[random_icon]"
	item_state = "artwork_revolver_[random_icon]"
	set_item_state("_[random_icon]")
	caliber = pick(CAL_MAGNUM,CAL_PISTOL)
	max_shells += rand(-2,7)

	AddComponent(/datum/component/atom_sanity, 0.2 + pick(0,0.1,0.2), "")

	//var/gun_pattern = pick("pistol","magnum","shotgun","rifle","sniper","gyro","cap","rocket","grenade")

	damage_multiplier += pick(-0.2,-0.1,0,0.1,0.2)
	penetration_multiplier += pick(-0.2,-0.1,0,0.1,0.2)
	recoil_buildup += rand(-(recoil_buildup / 5),(recoil_buildup / 5))
	price_tag += rand(0, 2500)
	. = ..()

/obj/item/gun/projectile/revolver/artwork_revolver/get_item_cost(export)
	. = ..()
	GET_COMPONENT(comp_sanity, /datum/component/atom_sanity)
	. += comp_sanity.affect * 100
	. += damage_multiplier * penetration_multiplier * 100

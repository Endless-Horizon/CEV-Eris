/obj/item/gun/projectile/automatic/armsmg
	icon = 'icons/obj/guns/projectile/armsmg.dmi'
	icon_state = "armsmg"
	item_state = null
	name = "embedded SMG"
	desc = "A makeshift SMG deployed from your arm. The favourite hidden weapon of many brutish types. Takes all kinds of .35 auto magazines"
	w_class = ITEM_SIZE_NORMAL
	can_dual = 1
	caliber = CAL_PISTOL
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 2)
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	ammo_type = "/obj/item/ammo_casing/pistol"
	load_method = MAGAZINE
	mag_well = MAG_WELL_PISTOL|MAG_WELL_H_PISTOL|MAG_WELL_SMG
	magazine_type = /obj/item/ammo_magazine/smg
	auto_eject = 1
	matter = list(MATERIAL_PLASTEEL = 12, MATERIAL_PLASTIC = 3)
	auto_eject_sound = 'sound/weapons/smg_empty_alarm.ogg'
	damage_multiplier = 0.8
	penetration_multiplier = 0.5
	gun_tags = list(GUN_SILENCABLE)
	recoil_buildup = 5 // it's stuck in your fucking hand or something
	one_hand_penalty = 1 // see the above
	spawn_blacklisted = TRUE

/obj/item/organ_module/active/simple/armsmg
	name = "embedded SMG"
	desc = "A makeshift SMG designed to be inserted into an arm. Gives you a nice advantage in a firefight"
	verb_name = "Deploy embedded SMG"
	icon_state = "armsmg"
	matter = list(MATERIAL_PLASTEEL = 20, MATERIAL_PLASTIC = 5, MATERIAL_STEEL = 5)
	allowed_organs = list(BP_R_ARM, BP_L_ARM)
	holding_type = /obj/item/gun/projectile/automatic/armsmg
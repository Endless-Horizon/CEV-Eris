/obj/item/weapon/shield/riot/arm
	name = "arm shield"
	desc = "An embedded shield adept at blocking objects from connecting with the torso of the shield wielder."
	icon_state = "riot"
	item_state = "riot"
	armor = list(melee = 15, bullet = 15, energy = 15, bomb = 0, bio = 0, rad = 0)
	attack_verb = list("bashed")
	base_block_chance = 35
	spawn_blacklisted = TRUE

/obj/item/organ_module/active/simple/armshield
	name = "embedded shield"
	desc = "An embedded shield designed to be inserted into an arm."
	verb_name = "Deploy embedded SMG"
	icon_state = "multitool"
	matter = list(MATERIAL_PLASTEEL = 20, MATERIAL_PLASTIC = 5, MATERIAL_STEEL = 5)
	allowed_organs = list(BP_R_ARM, BP_L_ARM)
	holding_type = /obj/item/weapon/shield/riot/arm
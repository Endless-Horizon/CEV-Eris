/obj/item/shield/riot/arm
	name = "arm shield"
	desc = "An embedded shield adept at blocking objects from connecting with the torso of the shield wielder."
	icon_state = "armshield"
	item_state = "eshield1"
	armor = list(melee = 15, bullet = 15, energy = 15, bomb = 0, bio = 0, rad = 0)
	attack_verb = list("bashed")
	base_block_chance = 35
	price_tag = 900
	spawn_blacklisted = TRUE

/obj/item/shield/riot/arm/on_update_icon()
   return

/obj/item/shield/riot/arm/get_block_chance(mob/user, var/damage, atom/damage_source = null, mob/attacker = null)
	if(istype(damage_source, /obj/item/projectile))
		var/obj/item/projectile/P = damage_source	//plastic shields do not stop bullets or lasers, even in space. Will block beanbags, rubber bullets, and stunshots just fine though.
		if((is_sharp(P) && damage > 10) || istype(P, /obj/item/projectile/beam))
			return 0
	return base_block_chance

/obj/item/organ_module/active/simple/armshield
	name = "embedded shield"
	desc = "An embedded shield designed to be inserted into an arm."
	verb_name = "Deploy embedded shield"
	icon_state = "armshield"
	matter = list(MATERIAL_PLASTEEL = 20, MATERIAL_PLASTIC = 5, MATERIAL_STEEL = 5)
	allowed_organs = list(BP_R_ARM, BP_L_ARM)
	holding_type = /obj/item/shield/riot/arm
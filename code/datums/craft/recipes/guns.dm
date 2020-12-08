/obj/item/gun_part//evan, termina esto
	name = "gun part"
	desc = "una parte de arma"
	icon ='icons/obj/crafts.dmi'
	icon_state = "gun"
	spawn_tags = SPAWN_TAG_GUN_PART
	price_tag = 300

/datum/craft_recipe/gun
	category = "Guns"
	icon_state = "gun_frame"//EVAN CHANGE IT
	time = 25
	related_stats = list(STAT_MEC)

/datum/craft_recipe/gun/pistol
	name = "handmade gun"
	result = /obj/item/weapon/gun/projectile/handmade_pistol
	steps = list(
		list(CRAFT_MATERIAL, 5, MATERIAL_STEEL),
		list(QUALITY_WELDING, 10, 20),
		list(CRAFT_MATERIAL, 5, MATERIAL_WOOD),
		list(QUALITY_SCREW_DRIVING, 10)
	)

/datum/craft_recipe/gun/handmaderevolver
	name = "handmade Revolver"
	result = /obj/item/weapon/gun/projectile/revolver/handmade
	steps = list(
		list(/obj/item/gun_part, 2),//no work
		list(QUALITY_ADHESIVE, 15, 70),
		list(CRAFT_MATERIAL, 15, MATERIAL_STEEL),
		list(QUALITY_WELDING, 10, 20),
		list(CRAFT_MATERIAL, 10, MATERIAL_PLASTIC),
		list(QUALITY_SCREW_DRIVING, 10)
	)

/datum/craft_recipe/gun/handmaderifle
	name = "handmade bolt action rifle"
	result = /obj/item/weapon/gun/projectile/boltgun/handmade
	steps = list(
		list(/obj/item/gun_part, 2),
		list(QUALITY_ADHESIVE, 15, 70),
		list(CRAFT_MATERIAL, 10, MATERIAL_STEEL),
		list(QUALITY_WELDING, 10, 20),
		list(CRAFT_MATERIAL, 5, MATERIAL_PLASTIC),
		list(QUALITY_SCREW_DRIVING, 10)
	)

/datum/craft_recipe/gun/makeshiftgl
	name = "makeshift grenade launcher"
	result = /obj/item/weapon/gun/launcher/grenade/makeshift
	steps = list(
		list(/obj/item/gun_part, 2),
		list(QUALITY_ADHESIVE, 15, 70),
		list(CRAFT_MATERIAL, 20, MATERIAL_STEEL),
		list(QUALITY_WELDING, 10, 20),
		list(CRAFT_MATERIAL, 10, MATERIAL_WOOD),
		list(QUALITY_SCREW_DRIVING, 10)
	)

/datum/craft_recipe/gun/slidebarrelshotgun
	name = "slide barrel Shotgun"
	result = /obj/item/weapon/gun/projectile/shotgun/slidebarrel
	steps = list(
		list(/obj/item/gun_part, 3),
		list(QUALITY_ADHESIVE, 15, 70),
		list(CRAFT_MATERIAL, 20, MATERIAL_STEEL),
		list(QUALITY_WELDING, 10, 20),
		list(CRAFT_MATERIAL, 10, MATERIAL_WOOD),
		list(QUALITY_SCREW_DRIVING, 10)
	)

/datum/craft_recipe/gun/motherfucker
	name = "HM Motherfucker .35 \"Punch Hole\""
	result = /obj/item/weapon/gun/projectile/automatic/motherfucker
	steps = list(
		list(/obj/item/gun_part, 5),
		list(QUALITY_ADHESIVE, 15, 70),
		list(CRAFT_MATERIAL, 20, MATERIAL_STEEL),
		list(QUALITY_WELDING, 10, 20),
		list(CRAFT_MATERIAL, 15, MATERIAL_WOOD),
		list(QUALITY_SCREW_DRIVING, 10)
	)

/datum/craft_recipe/gun/makeshiftlaser
	name = "makeshift laser carbine"
	result = /obj/item/weapon/gun/energy/laser/makeshift
	steps = list(
		list(/obj/item/gun_part, 4),
		list(QUALITY_ADHESIVE, 15, 70),
		list(CRAFT_MATERIAL, 20, MATERIAL_STEEL),
		list(QUALITY_WELDING, 10, 20),
		list(CRAFT_MATERIAL, 15, MATERIAL_PLASTIC),
		list(/obj/item/weapon/stock_parts/micro_laser , 4),
		list(QUALITY_SCREW_DRIVING, 10)
	)

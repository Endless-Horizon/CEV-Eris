/datum/craft_recipe/gun
	category = "Guns"
	time = 25
	related_stats = list(STAT_MEC)

/datum/craft_recipe/gun/pistol
	name = "Handmade gun"
	result = /obj/item/gun/projectile/handmade_pistol
	steps = list(
		list(CRAFT_MATERIAL, 5, MATERIAL_STEEL),
		list(QUALITY_WELDING, 10, 20),
		list(CRAFT_MATERIAL, 5, MATERIAL_WOOD),
		list(QUALITY_SCREW_DRIVING, 10)
	)

/datum/craft_recipe/gun/handmaderevolver
	name = "Handmade Revolver"
	result = /obj/item/gun/projectile/revolver/handmade
	steps = list(
		list(/obj/item/part/gun, 2),
		list(QUALITY_ADHESIVE, 15, 70),
		list(CRAFT_MATERIAL, 15, MATERIAL_STEEL),
		list(QUALITY_WELDING, 10, 20),
		list(CRAFT_MATERIAL, 10, MATERIAL_PLASTIC),
		list(QUALITY_SCREW_DRIVING, 10)
	)

/datum/craft_recipe/gun/handmaderifle
	name = "Handmade bolt action rifle"
	result = /obj/item/gun/projectile/boltgun/handmade
	steps = list(
		list(/obj/item/part/gun, 2),
		list(QUALITY_ADHESIVE, 15, 70),
		list(CRAFT_MATERIAL, 10, MATERIAL_STEEL),
		list(QUALITY_WELDING, 10, 20),
		list(CRAFT_MATERIAL, 5, MATERIAL_PLASTIC),
		list(QUALITY_SCREW_DRIVING, 10)
	)

/datum/craft_recipe/gun/makeshiftgl
	name = "makeshift grenade launcher"
	result = /obj/item/gun/launcher/grenade/makeshift
	steps = list(
		list(/obj/item/part/gun, 2),
		list(QUALITY_ADHESIVE, 15, 70),
		list(CRAFT_MATERIAL, 20, MATERIAL_STEEL),
		list(QUALITY_WELDING, 10, 20),
		list(CRAFT_MATERIAL, 10, MATERIAL_WOOD),
		list(QUALITY_SCREW_DRIVING, 10)
	)

/datum/craft_recipe/gun/slidebarrelshotgun
	name = "slide barrel Shotgun"
	result = /obj/item/gun/projectile/shotgun/slidebarrel
	steps = list(
		list(/obj/item/part/gun, 3),
		list(QUALITY_ADHESIVE, 15, 70),
		list(CRAFT_MATERIAL, 20, MATERIAL_STEEL),
		list(QUALITY_WELDING, 10, 20),
		list(CRAFT_MATERIAL, 10, MATERIAL_WOOD),
		list(QUALITY_SCREW_DRIVING, 10)
	)

/datum/craft_recipe/gun/motherfucker
	name = "HM Motherfucker .35 \"Punch Hole\""
	result = /obj/item/gun/projectile/automatic/motherfucker
	steps = list(
		list(/obj/item/part/gun, 5),
		list(QUALITY_ADHESIVE, 15, 70),
		list(CRAFT_MATERIAL, 20, MATERIAL_STEEL),
		list(QUALITY_WELDING, 10, 20),
		list(CRAFT_MATERIAL, 15, MATERIAL_WOOD),
		list(QUALITY_SCREW_DRIVING, 10)
	)

/datum/craft_recipe/gun/makeshiftlaser
	name = "makeshift laser carbine"
	result = /obj/item/gun/energy/laser/makeshift
	steps = list(
		list(/obj/item/part/gun, 4),
		list(QUALITY_ADHESIVE, 15, 70),
		list(CRAFT_MATERIAL, 20, MATERIAL_STEEL),
		list(QUALITY_WELDING, 10, 20),
		list(CRAFT_MATERIAL, 15, MATERIAL_PLASTIC),
		list(/obj/item/stock_parts/micro_laser , 4),
		list(QUALITY_SCREW_DRIVING, 10)
	)

/datum/craft_recipe/gun/kalash
	name = "Makeshift AR .30 \"Kalash\""
	result = /obj/item/gun/projectile/automatic/ak47/makeshift
	steps = list(
		list(/obj/item/part/gun, 4),
		list(QUALITY_ADHESIVE, 15, 70),
		list(CRAFT_MATERIAL, 20, MATERIAL_STEEL),
		list(QUALITY_WELDING, 10, 20),
		list(CRAFT_MATERIAL, 10, MATERIAL_WOOD),
		list(QUALITY_HAMMERING, 10)
	)

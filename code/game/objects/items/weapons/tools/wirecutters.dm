/obj/item/tool/wirecutters
	name = "wirecutters"
	desc = "Cuts wires and other objects with it."
	icon_state = "cutters"
	flags = CONDUCT
	force = WEAPON_FORCE_WEAK
	worksound = WORKSOUND_WIRECUTTING
	origin_tech = list(TECH_MATERIAL = 1, TECH_ENGINEERING = 1)
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 1)
	attack_verb = list("pinched", "nipped")
	sharp = TRUE
	edge = TRUE
	tool_qualities = list(QUALITY_WIRE_CUTTING = 30, QUALITY_RETRACTING = 15, QUALITY_BONE_SETTING = 15)
	rarity_value = 12

//Better and more flexible than most improvised tools, but more bulky and annoying to make
/obj/item/tool/wirecutters/improvised
	name = "wiremanglers"
	desc = "An improvised monstrosity made of bent rods which can sometimes be used to snip things. Could serve you well if you stuff it with enough tool mods."
	icon_state = "impro_cutter"
	w_class = ITEM_SIZE_NORMAL
	force = WEAPON_FORCE_NORMAL
	tool_qualities = list(QUALITY_WIRE_CUTTING = 20, QUALITY_RETRACTING = 10, QUALITY_BONE_SETTING = 10)
	degradation = 1.5
	max_upgrades = 5 //all makeshift tools get more mods to make them actually viable for mid-late game
	rarity_value = 6
	spawn_tags = SPAWN_TAG_JUNKTOOL

/obj/item/tool/wirecutters/armature
	name = "armature cutter"
	desc = "Bigger brother of wirecutter. Can't do much in terms of emergency surgery, but does its main job better."
	icon_state = "arm-cutter"
	w_class = ITEM_SIZE_NORMAL
	force = WEAPON_FORCE_NORMAL
	matter = list(MATERIAL_STEEL = 4, MATERIAL_PLASTEEL = 1, MATERIAL_PLASTIC = 1)
	tool_qualities = list(QUALITY_WIRE_CUTTING = 40, QUALITY_CUTTING = 30)
	degradation = 0.7
	max_upgrades = 4
	rarity_value = 24
	spawn_tags = SPAWN_TAG_TOOL_ADVANCED

/obj/item/tool/wirecutters/pliers //hybrid of wirecutters, wrench and cautery
	name = "pliers"
	desc = "A multitool from the world of maintenance. Useful for pinching, clamping, and occasional bolt turning."
	icon_state = "pliers"
	edge = FALSE
	sharp = FALSE
	tool_qualities = list(QUALITY_WIRE_CUTTING = 10, QUALITY_CLAMPING = 20, QUALITY_BOLT_TURNING = 15, QUALITY_BONE_SETTING = 20)

/obj/item/tool/wirecutters/attack(mob/living/carbon/C, mob/user)
	if(istype(C) && user.a_intent == I_HELP && (C.handcuffed) && (istype(C.handcuffed, /obj/item/handcuffs/cable)))
		usr.visible_message(
			"\The [usr] cuts \the [C]'s restraints with \the [src]!",
			"You cut \the [C]'s restraints with \the [src]!",
			"You hear cable being cut."
		)
		C.handcuffed = null
		if(C.buckled && C.buckled.buckle_require_restraints)
			C.buckled.unbuckle_mob()
		C.update_inv_handcuffed()
		return
	else
		..()

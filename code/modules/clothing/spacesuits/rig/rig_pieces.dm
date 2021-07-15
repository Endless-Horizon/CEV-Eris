/*
 * Defines the helmets, gloves and shoes for rigs.
 */

/obj/item/clothing/head/space/rig
	name = "helmet"
	item_flags = 		 THICKMATERIAL|COVER_PREVENT_MANIPULATION
	flags_inv = 		 HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHAIR
	body_parts_covered = HEAD|FACE|EYES
	heat_protection =    HEAD|FACE|EYES
	cold_protection =    HEAD|FACE|EYES
	brightness_on = 4
	spawn_tags = null

/obj/item/clothing/gloves/rig
	name = "gauntlets"
	item_flags = THICKMATERIAL|COVER_PREVENT_MANIPULATION
	overslot = 1
	body_parts_covered = ARMS
	heat_protection =    ARMS
	cold_protection =    ARMS
	species_restricted = null
	gender = PLURAL
	spawn_tags = null

/obj/item/clothing/shoes/magboots/rig
	name = "boots"
	item_flags = COVER_PREVENT_MANIPULATION
	body_parts_covered = LEGS
	cold_protection = LEGS
	heat_protection = LEGS
	species_restricted = null
	gender = PLURAL
	icon_base = null
	spawn_tags = null

/obj/item/clothing/suit/space/rig
	name = "chestpiece"

	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	heat_protection =    UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	cold_protection =    UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv =          HIDEJUMPSUIT|HIDETAIL
	item_flags =         STOPPRESSUREDAMAGE|THICKMATERIAL|AIRTIGHT|COVER_PREVENT_MANIPULATION
	slowdown = 0
	breach_threshold = 5
	resilience = 0.087
	can_breach = 1
	supporting_limbs = list()
	retract_while_active = FALSE
	spawn_tags = null

//TODO: move this to modules
/obj/item/clothing/head/space/rig/proc/prevent_track()
	return 0

/obj/item/clothing/gloves/rig/Touch(var/atom/A, var/proximity)

	if(!A || !proximity)
		return 0

	var/mob/living/carbon/human/H = loc
	if(!istype(H) || !H.back)
		return 0

	var/obj/item/rig/suit = H.back
	if(!suit || !istype(suit) || !suit.installed_modules.len)
		return 0

	for(var/obj/item/rig_module/module in suit.installed_modules)
		if(module.active && module.activates_on_touch)
			if(module.engage(A))
				return 1

	return 0

//Rig pieces for non-spacesuit based rigs

/obj/item/clothing/head/lightrig
	name = "mask"
	body_parts_covered = HEAD|FACE|EYES
	heat_protection =    HEAD|FACE|EYES
	cold_protection =    HEAD|FACE|EYES
	flags =              THICKMATERIAL|AIRTIGHT|COVER_PREVENT_MANIPULATION
	spawn_tags = null

/obj/item/clothing/suit/lightrig
	name = "suit"
	allowed = list(/obj/item/device/lighting/toggleable/flashlight)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	heat_protection =    UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	cold_protection =    UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv =          HIDEJUMPSUIT
	flags =              THICKMATERIAL|COVER_PREVENT_MANIPULATION
	spawn_tags = null

/obj/item/clothing/shoes/lightrig
	name = "boots"
	body_parts_covered = LEGS
	cold_protection = LEGS
	heat_protection = LEGS
	species_restricted = null
	gender = PLURAL
	spawn_tags = null

/obj/item/clothing/gloves/lightrig
	name = "gloves"
	flags = THICKMATERIAL
	body_parts_covered = LEGS
	heat_protection =    LEGS
	cold_protection =    LEGS
	species_restricted = null
	gender = PLURAL
	spawn_tags = null

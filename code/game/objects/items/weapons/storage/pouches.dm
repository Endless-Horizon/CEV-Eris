/obj/item/weapon/storage/pouch
	name = "pouch"
	desc = "Can hold various things."
	icon = 'icons/inventory/pockets/icon.dmi'
	icon_state = "pouch"
	item_state = "pouch"

	w_class = ITEM_SIZE_SMALL

	storage_slots = 1
	max_w_class = ITEM_SIZE_SMALL
	max_storage_space = base_storage_capacity(ITEM_SIZE_NORMAL)
	attack_verb = list("pouched")

	var/sliding_behavior = FALSE

/obj/item/weapon/storage/pouch/verb/toggle_slide()
	set name = "Toggle Slide"
	set desc = "Toggle the behavior of last item in [src] \"sliding\" into your hand."
	set category = "Object"

	sliding_behavior = !sliding_behavior
	usr << SPAN_NOTICE("Items will now [sliding_behavior ? "" : "not"] slide out of [src]")

/obj/item/weapon/storage/pouch/attack_hand(mob/living/carbon/human/user)
	if(sliding_behavior && contents.len && (src in user))
		var/obj/item/I = contents[contents.len]
		if(istype(I))
			hide_from(usr)
			var/turf/T = get_turf(user)
			remove_from_storage(I, T)
			usr.put_in_hands(I)
			add_fingerprint(user)
	else
		..()

/obj/item/weapon/storage/pouch/small_generic
	name = "small generic pouch"
	desc = "Can hold anything in it, but only about once."
	icon_state = "small_generic"
	item_state = "small_generic"

	max_storage_space = ITEM_SIZE_TINY * 2
	max_w_class = ITEM_SIZE_SMALL

/obj/item/weapon/storage/pouch/medium_generic
	name = "medium generic pouch"
	desc = "Can hold anything in it, but only about twice."
	icon_state = "medium_generic"
	item_state = "medium_generic"

	max_storage_space = ITEM_SIZE_TINY * 4
	max_w_class = ITEM_SIZE_SMALL

/obj/item/weapon/storage/pouch/medical_supply
	name = "medical supply pouch"
	desc = "Can hold medical equipment. But only about three pieces of it."
	icon_state = "medical_supply"
	item_state = "medical_supply"

	storage_slots = 3
	max_w_class = ITEM_SIZE_SMALL

	can_hold = list(
		/obj/item/device/scanner/healthanalyzer,
		/obj/item/weapon/dnainjector,
		/obj/item/weapon/reagent_containers/dropper,
		/obj/item/weapon/reagent_containers/glass/beaker,
		/obj/item/weapon/reagent_containers/glass/bottle,
		/obj/item/weapon/reagent_containers/pill,
		/obj/item/weapon/reagent_containers/syringe,
		/obj/item/weapon/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/head/surgery,
		/obj/item/clothing/gloves/latex,
		/obj/item/weapon/reagent_containers/hypospray,
		/obj/item/clothing/glasses/hud/health,
		)

/obj/item/weapon/storage/pouch/engineering_tools
	name = "engineering tools pouch"
	desc = "Can hold engineering tools. But only about three pieces of them."
	icon_state = "engineering_tool"
	item_state = "engineering_tool"

	storage_slots = 2
	max_w_class = ITEM_SIZE_SMALL

	can_hold = list(
		/obj/item/weapon/tool,
		/obj/item/device/lighting/toggleable/flashlight,
		/obj/item/stack/cable_coil,
		/obj/item/device/t_scanner,
		/obj/item/device/scanner/analyzer,
		/obj/item/taperoll/engineering,
		/obj/item/device/robotanalyzer,
		/obj/item/device/scanner/analyzer/plant_analyzer,
		/obj/item/weapon/extinguisher/mini
		)

/obj/item/weapon/storage/pouch/engineering_supply
	name = "engineering supply pouch"
	desc = "Can hold engineering equipment. But only about two pieces of it."
	icon_state = "engineering_supply"
	item_state = "engineering_supply"

	storage_slots = 2
	w_class = ITEM_SIZE_NORMAL
	max_w_class = ITEM_SIZE_NORMAL

	can_hold = list(
		/obj/item/weapon/cell,
		/obj/item/weapon/circuitboard,
		/obj/item/weapon/tool,
		/obj/item/stack/material,
		/obj/item/weapon/material,
		/obj/item/device/lighting/toggleable/flashlight,
		/obj/item/stack/cable_coil,
		/obj/item/device/t_scanner,
		/obj/item/device/scanner/analyzer,
		/obj/item/taperoll/engineering,
		/obj/item/device/robotanalyzer,
		/obj/item/device/scanner/analyzer/plant_analyzer,
		/obj/item/weapon/extinguisher/mini
		)

/obj/item/weapon/storage/pouch/ammo
	name = "ammo pouch"
	desc = "Can hold ammo magazines and bullets, not the boxes though."
	icon_state = "ammo"
	item_state = "ammo"

	storage_slots = 3
	w_class = ITEM_SIZE_NORMAL
	max_w_class = ITEM_SIZE_NORMAL

	can_hold = list(
		/obj/item/ammo_magazine,
		/obj/item/ammo_casing
		)

/obj/item/weapon/storage/pouch/flare
	name = "flares pouch"
	desc = "Can hold about five flares in."
	icon_state = "flare"
	item_state = "flare"

	storage_slots = 5
	w_class = ITEM_SIZE_SMALL

	can_hold = list(/obj/item/device/lighting/glowstick/flare)

/obj/item/weapon/storage/pouch/flare/update_icon()
	..()
	overlays.Cut()
	if(contents.len)
		overlays += image('icons/inventory/pockets/icon.dmi', "flare_[contents.len]")

/obj/item/weapon/storage/pouch/pistol_holster
	name = "pistol holster"
	desc = "Can hold a pistol in."
	icon_state = "pistol_holster"
	item_state = "pistol_holster"

	storage_slots = 1
	w_class = ITEM_SIZE_NORMAL
	max_w_class = ITEM_SIZE_NORMAL

	can_hold = list(
		/obj/item/weapon/gun/projectile/clarissa,
		/obj/item/weapon/gun/projectile/colt,
		/obj/item/weapon/gun/projectile/deagle,
		/obj/item/weapon/gun/projectile/giskard,
		/obj/item/weapon/gun/projectile/gyropistol,
		/obj/item/weapon/gun/projectile/handmade_pistol,
		/obj/item/weapon/gun/projectile/lamia,
		/obj/item/weapon/gun/projectile/mk58,
		/obj/item/weapon/gun/projectile/olivaw,
		/obj/item/weapon/gun/projectile/silenced,
		/obj/item/weapon/gun/projectile/revolver)

	sliding_behavior = TRUE

/obj/item/weapon/storage/pouch/pistol_holster/update_icon()
	..()
	overlays.Cut()
	if(contents.len)
		overlays += image('icons/inventory/pockets/icon.dmi', "pistol_layer")

/obj/item/weapon/storage/pouch/baton_holster
	name = "baton holster"
	desc = "Can hold a baton in."
	icon_state = "baton_holster"
	item_state = "baton_holster"

	storage_slots = 1
	max_w_class = ITEM_SIZE_NORMAL

	can_hold = list(
		/obj/item/weapon/melee,
		/obj/item/weapon/tool/crowbar
		)

	sliding_behavior = TRUE

/obj/item/weapon/storage/pouch/baton_holster/update_icon()
	..()
	overlays.Cut()
	if(contents.len)
		overlays += image('icons/inventory/pockets/icon.dmi', "baton_layer")
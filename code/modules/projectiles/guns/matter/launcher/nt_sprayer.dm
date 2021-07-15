/obj/item/gun/matter/launcher/nt_sprayer
	name = "NT BCR \"Righteous One\""
	desc = "\"NeoTheology\" brand cleansing carbine. Uses solid biomass as ammo and dispense cleansing liquid on hit."
	icon_state = "nt_sprayer"
	icon = 'icons/obj/guns/matter/nt_sprayer.dmi'
	slot_flags = SLOT_BACK | SLOT_BELT
	fire_sound = 'sound/weapons/Genhit.ogg'
	matter_type = MATERIAL_BIOMATTER

	init_firemodes = list(
		list(mode_name="clean", mode_desc="A slippery cleaning foam, perfect for annoying others", projectile_type=/obj/item/arrow/neotheo/cleansing, icon="stun"),
		list(mode_name="de-weed", mode_desc="Antifungal, Antifloral, all round Herbicide", projectile_type=/obj/item/arrow/neotheo/weedkiller, icon="kill"),
	)
	projectile_cost = 0.5
	projectile_type = /obj/item/arrow/neotheo/cleansing
	spawn_blacklisted = TRUE


/obj/item/arrow/neotheo
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "toxin"
	throwforce = 1
	sharp = FALSE

/obj/item/arrow/neotheo/cleansing/throw_impact()
	..()
	create_reagents(5)
	reagents.add_reagent("cleaner", 1)
	reagents.add_reagent("surfactant", 2)
	reagents.add_reagent("water", 2)

	qdel(src)

/obj/item/arrow/neotheo/weedkiller/throw_impact()
	..()
	create_reagents(5)
	reagents.add_reagent("plantbgone", 1)
	reagents.add_reagent("surfactant", 2)
	reagents.add_reagent("water", 2)

	qdel(src)

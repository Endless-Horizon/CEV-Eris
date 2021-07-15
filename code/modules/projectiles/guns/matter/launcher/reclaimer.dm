/obj/item/gun/matter/launcher/reclaimer
	name = "Excelsior \"Reclaimer\""
	desc = "The weapon of choice for swiftly appropriating matter for communal use. Uses a cellulose based solution to dissolve matter into its original components, not 100% effective."
	icon_state = "reclaimer"
	icon = 'icons/obj/guns/matter/reclaimer.dmi'
	slot_flags = SLOT_BACK
	fire_sound = 'sound/weapons/Genhit.ogg'

	matter = list(MATERIAL_PLASTEEL = 10, MATERIAL_WOOD = 5, MATERIAL_PLASTIC = 20)
	matter_type = MATERIAL_WOOD

	stored_matter = 5
	projectile_cost = 0.5
	projectile_type = /obj/item/arrow/reclaiming
	spawn_blacklisted = TRUE


/obj/item/arrow/reclaiming
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "evil_foam"
	throwforce = 1
	sharp = FALSE

/obj/item/arrow/reclaiming/throw_impact()
	..()

	create_reagents(5)
	reagents.add_reagent("deconstructor", 1)
	reagents.add_reagent("surfactant", 2)
	reagents.add_reagent("water", 2)

	qdel(src)

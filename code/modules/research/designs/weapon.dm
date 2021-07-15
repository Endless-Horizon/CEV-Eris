/datum/design/research/item/weapon
	category = CAT_WEAPON

// Weapons
/datum/design/research/item/weapon/AssembleDesignDesc()
	if(!desc && build_path)
		var/obj/item/I = build_path
		desc = initial(I.desc)
	else
		..()

/datum/design/research/item/weapon/stunrevolver
	build_path = /obj/item/gun/energy/stunrevolver/moebius
	sort_string = "TAAAA"

/datum/design/research/item/weapon/mindflayer
	build_path = /obj/item/gun/energy/psychic/mindflayer
	sort_string = "TAAAB"

/datum/design/research/item/weapon/lasercannon
	desc = "The lasing medium of this prototype is enclosed in a tube lined with uranium-235 and subjected to high neutron flux in a nuclear reactor core."
	build_path = /obj/item/gun/energy/lasercannon
	sort_string = "TAAAC"

/datum/design/research/item/weapon/c20r
	name = "C20M-prototype"
	desc = "The C-20M is a lightweight and rapid-firing SMG. Uses .35 auto rounds."
	build_path = /obj/item/gun/projectile/automatic/c20r/moebius
	sort_string = "TAAAF"

/datum/design/research/item/weapon/plasmapistol
	build_path = /obj/item/gun/energy/plasma/brigador
	sort_string = "TAAAD"

/datum/design/research/item/weapon/decloner
	build_path = /obj/item/gun/energy/decloner
	sort_string = "TAAAE"

/datum/design/research/item/weapon/nuclear
	build_path = /obj/item/gun/energy/nuclear
	sort_string = "TAAAG"

/datum/design/research/item/weapon/chemsprayer
	desc = "An advanced chem spraying device."
	build_path = /obj/item/reagent_containers/spray/chemsprayer
	sort_string = "TABAA"

/datum/design/research/item/weapon/rapidsyringe
	build_path = /obj/item/gun/launcher/syringe/rapid
	sort_string = "TABAB"

/datum/design/research/item/weapon/temp_gun
	desc = "A gun that shoots high-powered glass-encased energy temperature bullets."
	build_path = /obj/item/gun/energy/temperature
	sort_string = "TABAC"

/datum/design/research/item/weapon/large_grenade
	build_path = /obj/item/grenade/chem_grenade/large/moebius
	sort_string = "TACAA"

/datum/design/research/item/weapon/flora_gun
	build_path = /obj/item/gun/energy/floragun
	sort_string = "TBAAA"

/datum/design/research/item/weapon/bluespace_harpoon
	build_path = /obj/item/bluespace_harpoon
	sort_string = "TBAAB"

/datum/design/research/item/weapon/hatton
	name = "Moebius BT \"Q-del\""
	desc = "This breaching tool was reverse engineered from the \"Hatton\" design.\
			Despite the Excelsior \"Hatton\" being traded on the free market through Technomancer League channels,\
			this device suffers from a wide number of reliability issues stemming from it being lathe printed."
	build_path = /obj/item/hatton/moebius
	sort_string = "TBAAD"

/datum/design/research/item/weapon/katana
	name = "Moebius \"Muramasa\" Katana"
	build_path = /obj/item/tool/sword/katana/nano


/datum/design/research/item/weapon/bluespace_dagger
	name = "Moebius \"Displacement Dagger\""
	build_path = /obj/item/tool/knife/dagger/bluespace

// Ammo
/datum/design/research/item/ammo
	name_category = "ammunition"
	category = CAT_WEAPON

/datum/design/research/item/ammo/hatton
	name = "Moebius BT \"Q-del\" gas tube"
	build_path = /obj/item/hatton_magazine/moebius
	sort_string = "TAACC"

/datum/design/research/item/ammo/c20r_ammo
	name = "C20R 35 Auto Magazine"
	desc = "35 Auto SMG magazine for the C-20r"
	build_path = /obj/item/ammo_magazine/smg
	sort_string = "TAACD"

/datum/design/research/item/ammo/shotgun_incendiary
	name = "incendiary shotgun shells"
	desc = "Insendiary ammunition for shotguns"
	build_path = /obj/item/ammo_casing/shotgun/incendiary/prespawned
	sort_string = "TAACF"

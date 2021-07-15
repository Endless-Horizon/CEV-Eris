/obj/item/storage/box/swabs
	name = "box of swab kits"
	desc = "Sterilized equipment within. Do not contaminate."
	icon = 'icons/obj/forensics.dmi'
	icon_state = "dnakit"
	illustration = null
	can_hold = list(/obj/item/forensics/swab)
	storage_slots = 14
	initial_amount = 14
	spawn_type = /obj/item/forensics/swab

/obj/item/storage/box/swabs/populate_contents()
	for(var/i in 1 to initial_amount) // Fill 'er up.
		new spawn_type(src)

/obj/item/storage/box/evidence
	name = "evidence bag box"
	desc = "A box claiming to contain evidence bags."
	can_hold = list(/obj/item/evidencebag)
	initial_amount = 7
	spawn_type = /obj/item/evidencebag

/obj/item/storage/box/evidence/populate_contents()
	for(var/i in 1 to initial_amount)
		new spawn_type(src)

/obj/item/storage/box/fingerprints
	name = "box of fingerprint cards"
	desc = "Sterilized equipment within. Do not contaminate."
	icon = 'icons/obj/forensics.dmi'
	icon_state = "dnakit"
	illustration = null
	can_hold = list(/obj/item/sample/print)
	storage_slots = 14
	initial_amount = 14
	spawn_type = /obj/item/sample/print

/obj/item/storage/box/fingerprints/populate_contents()
	for(var/i in 1 to initial_amount)
		new spawn_type(src)

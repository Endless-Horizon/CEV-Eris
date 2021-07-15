/* First aid storage
 * Contains:
 *		First Aid Kits
 * 		Pill Bottles
 *		Portable Freezer
 */

/*
 * First Aid Kits
 */
/obj/item/storage/firstaid
	name = "first-aid kit"
	desc = "It's an emergency medical kit for those serious boo-boos."
	icon_state = "firstaid"
	throw_speed = 2
	throw_range = 8
	rarity_value = 10
	spawn_tags = SPAWN_TAG_FIRSTAID
	bad_type = /obj/item/storage/firstaid
	var/initial_amount = 0
	var/spawn_type
	var/empty = 0


/obj/item/storage/firstaid/fire
	name = "fire first-aid kit"
	desc = "It's an emergency medical kit for when the toxins lab <i>-spontaneously-</i> burns down."
	icon_state = "ointment"
	item_state = "firstaid-ointment"
	rarity_value = 15
	initial_amount = 2
	spawn_type = /obj/item/stack/medical/ointment

/obj/item/storage/firstaid/fire/populate_contents()
	icon_state = pick("ointment","firefirstaid")

	if (empty) return
	for(var/i in 1 to initial_amount)
		new spawn_type(src)
	new /obj/item/reagent_containers/pill/kelotane(src)
	new /obj/item/reagent_containers/pill/kelotane(src)
	new /obj/item/reagent_containers/pill/kelotane(src) //Replaced ointment with these since they actually work --Errorage
	new /obj/item/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/device/scanner/health(src)


/obj/item/storage/firstaid/regular
	icon_state = "firstaid"
	rarity_value = 10
	initial_amount = 3
	spawn_type = /obj/item/stack/medical/bruise_pack

/obj/item/storage/firstaid/regular/populate_contents()
	if (empty) return
	for(var/i in 1 to initial_amount)
		new spawn_type(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/device/scanner/health(src)


/obj/item/storage/firstaid/toxin
	name = "toxin first aid"
	desc = "Used to treat when you have a high amoutn of toxins in your body."
	icon_state = "antitoxin"
	item_state = "firstaid-toxin"
	rarity_value = 15
	initial_amount = 3
	spawn_type = /obj/item/reagent_containers/syringe/antitoxin

/obj/item/storage/firstaid/toxin/populate_contents()
	icon_state = pick("antitoxin","antitoxfirstaid2","antitoxfirstaid3")

	if (empty) return
	for(var/i in 1 to initial_amount)
		new spawn_type(src)
	new /obj/item/reagent_containers/pill/antitox(src)
	new /obj/item/reagent_containers/pill/antitox(src)
	new /obj/item/reagent_containers/pill/antitox(src)
	new /obj/item/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/device/scanner/health(src)


/obj/item/storage/firstaid/o2
	name = "oxygen deprivation first aid"
	desc = "A box full of oxygen goodies."
	icon_state = "o2"
	item_state = "firstaid-o2"
	rarity_value = 15
	initial_amount = 4
	spawn_type = /obj/item/reagent_containers/pill/dexalin

/obj/item/storage/firstaid/o2/populate_contents()
	if (empty) return
	for(var/i in 1 to initial_amount)
		new spawn_type(src)
	new /obj/item/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/reagent_containers/syringe/inaprovaline(src)
	new /obj/item/device/scanner/health(src)


/obj/item/storage/firstaid/adv
	name = "advanced first-aid kit"
	desc = "Contains advanced medical treatments."
	icon_state = "advfirstaid"
	item_state = "firstaid-advanced"
	rarity_value = 30
	initial_amount = 3
	spawn_type = /obj/item/stack/medical/advanced/bruise_pack

/obj/item/storage/firstaid/adv/populate_contents()
	if (empty) return
	for(var/i in 1 to initial_amount)
		new spawn_type(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/reagent_containers/syringe/inaprovaline(src)
	new /obj/item/device/scanner/health(src)

/obj/item/storage/firstaid/combat
	name = "combat medical kit"
	desc = "Contains advanced medical treatments."
	icon_state = "bezerk"
	item_state = "firstaid-advanced"
	rarity_value = 100
	initial_amount = 1
	spawn_type = /obj/item/stack/medical/splint

/obj/item/storage/firstaid/combat/populate_contents()
	if (empty) return
	for(var/i in 1 to initial_amount)
		new spawn_type(src)
	new /obj/item/storage/pill_bottle/meralyne(src)
	new /obj/item/storage/pill_bottle/dermaline(src)
	new /obj/item/storage/pill_bottle/dexalin_plus(src)
	new /obj/item/storage/pill_bottle/dylovene(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/spaceacillin(src)

/obj/item/storage/firstaid/surgery
	name = "surgery kit"
	desc = "Contains tools for surgery. Has precise foam fitting for safe transport."
	icon_state = "surgeon"
	item_state = "firstaid-surgeon"
	rarity_value = 90
	can_hold = list(
		/obj/item/tool/bonesetter,
		/obj/item/tool/cautery,
		/obj/item/tool/saw,
		/obj/item/tool/hemostat,
		/obj/item/tool/retractor,
		/obj/item/tool/scalpel,
		/obj/item/tool/surgicaldrill,
		/obj/item/device/scanner,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		)

/obj/item/storage/firstaid/surgery/populate_contents()
	if (empty) return
	new /obj/item/tool/bonesetter(src)
	new /obj/item/tool/cautery(src)
	new /obj/item/tool/saw/circular(src)
	new /obj/item/tool/hemostat(src)
	new /obj/item/tool/retractor(src)
	new /obj/item/tool/scalpel(src)
	new /obj/item/tool/surgicaldrill(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	make_exact_fit()

/obj/item/storage/firstaid/surgery/traitor
	spawn_blacklisted = TRUE

/obj/item/storage/firstaid/surgery/traitor/populate_contents()
	if (empty) return
	new /obj/item/tool/bonesetter(src)
	new /obj/item/tool/cautery(src)
	new /obj/item/tool/saw/circular/advanced(src)
	new /obj/item/tool/hemostat(src)
	new /obj/item/tool/retractor(src)
	new /obj/item/tool/scalpel/advanced(src)
	new /obj/item/tool/surgicaldrill(src)
	new /obj/item/device/scanner/health(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/prosurgeon(src)
	make_exact_fit()

/obj/item/storage/firstaid/nt
	name = "NeoTheologian Medkit"
	desc = "A medkit filled with a set of high-end trauma kits and anti-toxins."
	icon_state = "nt_kit"
	item_state = "nt_kit"
	matter = list(MATERIAL_BIOMATTER = 10)
	initial_amount = 2
	spawn_type = /obj/item/stack/medical/advanced/bruise_pack/nt
	spawn_blacklisted = TRUE

/obj/item/storage/firstaid/nt/populate_contents()
	if (empty) return
	for(var/i in 1 to initial_amount)
		new spawn_type(src)
	new /obj/item/stack/medical/advanced/ointment/nt(src)
	new /obj/item/stack/medical/advanced/ointment/nt(src)
	new /obj/item/reagent_containers/syringe/large/antitoxin(src)
	new /obj/item/reagent_containers/syringe/large/dexalin_plus(src)

/obj/item/storage/firstaid/nt/on_update_icon()
	if(!contents.len)
		icon_state = "[initial(icon_state)]_empty"
		item_state = "[initial(item_state)]_empty"
	else
		icon_state = "[initial(icon_state)]"
		item_state = "[initial(item_state)]"
	..()

/*
 * Pill Bottles
 */
/obj/item/storage/pill_bottle
	name = "pill bottle"
	desc = "It's an airtight container for storing medication."
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	item_state = "contsolid"
	w_class = ITEM_SIZE_SMALL
	can_hold = list(/obj/item/reagent_containers/pill,
		/obj/item/dice,
		/obj/item/paper
		)
	allow_quick_gather = TRUE
	use_to_pickup = TRUE
	use_sound = null
	matter = list(MATERIAL_PLASTIC = 1)
	max_storage_space = 12
	rarity_value = 10
	bad_type = /obj/item/storage/pill_bottle
	spawn_tags = SPAWN_TAG_MEDICINE
	var/pill_type
	var/initial_amt = 7

/obj/item/storage/pill_bottle/antitox
	name = "bottle of Dylovene pills"
	desc = "Contains pills used to counter toxins."
	pill_type = /obj/item/reagent_containers/pill/antitox

/obj/item/storage/pill_bottle/antitox/populate_contents()
	for(var/i in 1 to initial_amt)
		new pill_type(src)

/obj/item/storage/pill_bottle/bicaridine
	name = "bottle of Bicaridine pills"
	desc = "Contains pills used to stabilize the severely injured."
	pill_type = /obj/item/reagent_containers/pill/bicaridine

/obj/item/storage/pill_bottle/bicaridine/populate_contents()
	for(var/i in 1 to initial_amt)
		new pill_type(src)

/obj/item/storage/pill_bottle/dexalin_plus
	name = "bottle of Dexalin Plus pills"
	desc = "Contains pills used to treat extreme cases of oxygen deprivation."
	pill_type = /obj/item/reagent_containers/pill/dexalin_plus

/obj/item/storage/pill_bottle/dexalin_plus/populate_contents()
	for(var/i in 1 to initial_amt)
		new pill_type(src)

/obj/item/storage/pill_bottle/dermaline
	name = "bottle of Dermaline pills"
	desc = "Contains pills used to treat burn wounds."
	pill_type = /obj/item/reagent_containers/pill/dermaline

/obj/item/storage/pill_bottle/dermaline/populate_contents()
	for(var/i in 1 to initial_amt)
		new pill_type(src)

/obj/item/storage/pill_bottle/dylovene
	name = "bottle of Dylovene pills"
	desc = "Contains pills used to treat toxic substances in the blood."
	pill_type = /obj/item/reagent_containers/pill/dylovene

/obj/item/storage/pill_bottle/dylovene/populate_contents()
	for(var/i in 1 to initial_amt)
		new pill_type(src)

/obj/item/storage/pill_bottle/inaprovaline
	name = "bottle of Inaprovaline pills"
	desc = "Contains pills used to stabilize patients."
	pill_type = /obj/item/reagent_containers/pill/inaprovaline

/obj/item/storage/pill_bottle/inaprovaline/populate_contents()
	for(var/i in 1 to initial_amt)
		new pill_type(src)

/obj/item/storage/pill_bottle/kelotane
	name = "bottle of Kelotane pills"
	desc = "Contains pills used to treat burns."
	pill_type = /obj/item/reagent_containers/pill/kelotane

/obj/item/storage/pill_bottle/kelotane/populate_contents()
	for(var/i in 1 to initial_amt)
		new pill_type(src)

/obj/item/storage/pill_bottle/spaceacillin
	name = "bottle of Spaceacillin pills"
	desc = "A theta-lactam antibiotic. Effective against many diseases likely to be encountered in space."
	pill_type = /obj/item/reagent_containers/pill/spaceacillin

/obj/item/storage/pill_bottle/spaceacillin/populate_contents()
	for(var/i in 1 to initial_amt)
		new pill_type(src)

/obj/item/storage/pill_bottle/tramadol
	name = "bottle of Tramadol pills"
	desc = "Contains pills used to relieve pain."
	spawn_tags = SPAWN_TAG_MEDICINE_CONTRABAND
	rarity_value = 15
	pill_type = /obj/item/reagent_containers/pill/tramadol

/obj/item/storage/pill_bottle/tramadol/populate_contents()
	for(var/i in 1 to initial_amt)
		new pill_type(src)

/obj/item/storage/pill_bottle/citalopram
	name = "bottle of Citalopram pills"
	desc = "Contains pills used to stabilize a patient's mood."
	pill_type = /obj/item/reagent_containers/pill/citalopram

/obj/item/storage/pill_bottle/citalopram/populate_contents()
	for(var/i in 1 to initial_amt)
		new pill_type(src)

/obj/item/storage/pill_bottle/prosurgeon
	name = "bottle of ProSurgeon pills"
	desc = "Contains pills used to reduce hand tremor."
	pill_type = /obj/item/reagent_containers/pill/prosurgeon
	rarity_value = 20

/obj/item/storage/pill_bottle/prosurgeon/populate_contents()
	for(var/i in 1 to initial_amt)
		new pill_type(src)

/obj/item/storage/pill_bottle/meralyne
	name = "bottle of Meralyne pills"
	desc = "Contains pills used to heal physical harm."
	pill_type = /obj/item/reagent_containers/pill/meralyne
	rarity_value = 20

/obj/item/storage/pill_bottle/meralyne/populate_contents()
	for(var/i in 1 to initial_amt)
		new pill_type(src)

/*
 * Portable Freezers
 */
/obj/item/storage/freezer
	name = "portable freezer"
	desc = "This nifty shock-resistant device will keep your 'groceries' nice and non-spoiled."
	icon_state = "freezer"
	item_state = "medicalpack"
	max_w_class = ITEM_SIZE_NORMAL
	matter = list(MATERIAL_STEEL = 1, MATERIAL_PLASTIC = 2)
	can_hold = list(/obj/item/organ, /obj/item/reagent_containers/food, /obj/item/reagent_containers/glass)
	max_storage_space = DEFAULT_NORMAL_STORAGE
	use_to_pickup = TRUE

/obj/item/storage/freezer/contains_food/populate_contents()
	new /obj/spawner/pizza/low_chance(src)
	new /obj/spawner/soda(src)
	new /obj/spawner/soda/low_chance(src)
	new /obj/spawner/rations/low_chance(src)
	new /obj/spawner/junkfood(src)
	new /obj/spawner/junkfood(src)
	new /obj/spawner/junkfood(src)
	new /obj/spawner/junkfood/low_chance(src)
	new /obj/spawner/junkfood/low_chance(src)
	new /obj/spawner/booze/low_chance(src)

/obj/item/storage/freezer/medical
	name = "organ freezer"
	icon_state = "freezer_red"
	item_state = "medicalpack"
	matter = list(MATERIAL_PLASTEEL = 1, MATERIAL_PLASTIC = 2)
	max_storage_space = DEFAULT_NORMAL_STORAGE * 1.25

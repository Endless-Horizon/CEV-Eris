/*
	Deferred spawn storage containers
*/

/*
	These are a special type of storage container used for less-accessed gear. They create their contents through a
	spawn_contents proc which is called the first time the box is opened or interacted with.

	The key thing here is, these contents are not spawned at roundstart, only when a player actually needs them
	And thusly, if no player ever does, then those items are not sitting around wasting memory and CPU time

	Most of the things in this file are intended for use by external antags, and are thus exceptionally powerful
*/


/obj/item/storage/deferred
	var/list/initial_contents = list() //List of stuff that will be in this box
	//Can be used as an assoc list and allow you to enter a quantity as the value

	var/contents_spawned = FALSE

	name = "box"
	desc = "A steel-cased box."
	icon = 'icons/obj/storage/deferred.dmi'
	icon_state = "box"
	item_state = "box"
	contained_sprite = TRUE

/obj/item/storage/deferred/populate_contents()
	// Do not create contents if they are already spawned
	if(contents_spawned)
		return

	contents_spawned = TRUE
	for(var/a in initial_contents)
		var/quantity = initial_contents[a] ? initial_contents[a] : 1

		for(var/i = 0; i < quantity; i++)
			new a(src)
	expand_to_fit()

/obj/item/storage/deferred/open(mob/user)
	populate_contents()
	. = ..()

/obj/item/storage/deferred/show_to(mob/user)
	populate_contents()
	. = ..()

/obj/item/storage/deferred/can_be_inserted(obj/item/W, stop_messages = 0)
	populate_contents()
	. = ..()


/obj/item/storage/deferred/rations //DO this before merging
	name = "infantryman's rations kit"
	icon_state = "irp_box"
	item_state = "irp_box"
	desc = "A box of preserved, ready-to-eat food for soldiers and spacefarers on the go."
	initial_contents = list(/obj/item/storage/ration_pack = 7)


/obj/item/storage/deferred/toolmod
	name = "tool modifications kit"
	desc = "A sturdy container full of contraptions, bits of material, components and add-ons for modifying tools."
	icon_state = "box_tools"
	initial_contents = list(/obj/spawner/tool_upgrade = 12,
	/obj/spawner/tool_upgrade/rare = 3)


/obj/item/storage/deferred/pouches
	name = "uniform modification kit"
	desc = "A box full of hard-wearing pouches designed for easy attachment to clothing and armor. Good for carrying extra ammo or tools in the field."
	initial_contents = list(/obj/spawner/pouch = 8, /obj/item/storage/pouch/pistol_holster = 1)
	//One guaranteed holster and plenty of randoms

/obj/item/storage/deferred/comms
	name = "communications kit"
	desc = "A box full of radios and beacons"
	initial_contents = list(/obj/item/device/radio/beacon = 6, /obj/item/device/radio = 6)

/obj/item/storage/deferred/lights
	name = "illumination kit"
	desc = "A box of flares and flashlights"
	initial_contents = list(/obj/item/device/lighting/glowstick/flare = 20, /obj/item/device/lighting/toggleable/flashlight/heavy = 6)

/obj/item/storage/deferred/music
	name = "morale kit"
	desc = "All that's required to unite nation, compacted within single box."
	icon_state = "box_serbian"
	initial_contents = list(/obj/item/device/synthesized_instrument/trumpet = 1) //TODO: Add an accordian to this, sprites already made.

/obj/item/storage/deferred/disks //for the beacon, cause we want it priced right and actually functional
	name = "autolathe disk box"
	desc = "A small collection of autolathe disks"
	initial_contents = list(/obj/spawner/lathe_disk = 7)
	price_tag = 2800

//Medical
/obj/item/storage/deferred/surgery
	name = "combat surgery kit"
	desc = "Contains tools for surgery. Has precise foam fitting for safe transport."
	icon_state = "combat_surgery_kit"
	item_state = "combat_medical_kit"
	initial_contents = list(
		/obj/item/tool/bonesetter,
		/obj/item/tool/cautery,
		/obj/item/tool/saw/circular,
		/obj/item/tool/hemostat,
		/obj/item/tool/retractor,
		/obj/item/tool/scalpel,
		/obj/item/tool/surgicaldrill,
		/obj/item/stack/medical/advanced/bruise_pack
		)
	can_hold = list(
		/obj/item/tool/bonesetter,
		/obj/item/tool/cautery,
		/obj/item/tool/saw/circular,
		/obj/item/tool/hemostat,
		/obj/item/tool/retractor,
		/obj/item/tool/scalpel,
		/obj/item/tool/surgicaldrill,
		/obj/item/stack/medical/advanced/bruise_pack
		)


/obj/item/storage/deferred/meds
	name = "combat medical kit"
	desc = "Contains advanced medical treatments."
	icon_state = "combat_medical_kit"
	item_state = "combat_medical_kit"
	initial_contents = list(/obj/item/storage/pill_bottle/bicaridine,
	/obj/item/storage/pill_bottle/dermaline,
	/obj/item/storage/pill_bottle/dexalin_plus,
	/obj/item/storage/pill_bottle/dylovene,
	/obj/item/storage/pill_bottle/tramadol,
	/obj/item/storage/pill_bottle/spaceacillin,
	/obj/item/stack/medical/splint)



//Crates
//These use open topped crate sprites but are still functionally boxes. They can be picked up, but are too large to fit in anything
/obj/item/storage/deferred/crate
	w_class = ITEM_SIZE_HUGE //This is too big to fit in a backpack
	icon_state = "serbcrate_deferred_worn"
	item_state = "crate"


/obj/item/storage/deferred/crate/tools
	name = "tool storage box"
	desc = "A moderately sized crate full of assorted tools."
	icon_state = "serbcrate_deferred_brown"
	initial_contents = list(/obj/spawner/tool = 13,
	/obj/spawner/tool/advanced = 2)


/obj/item/storage/deferred/crate/saw
	name = "infantry support crate"
	desc = "A crate containing two Pulemyot Kalashnikova light machine guns, and 640 rounds of .30 ammunition."
	icon_state = "serbcrate_deferred_green"
	initial_contents = list(/obj/item/gun/projectile/automatic/lmg/pk = 2,
	/obj/item/ammo_magazine/lrifle/pk = 8)


/obj/item/storage/deferred/crate/ak
	name = "rifleman crate"
	desc = "A crate containing six SA AK-47 rifles, and plenty of magazines."
	icon_state = "serbcrate_deferred_green"
	initial_contents = list(/obj/item/gun/projectile/automatic/ak47/sa  = 6,
	/obj/item/ammo_magazine/lrifle = 18)

/obj/item/storage/deferred/crate/kovacs
	name = "designated marksman crate"
	desc = "A crate containing six \"Kovacs\" battle rifles, and plenty of mags."
	icon_state = "serbcrate_deferred_green"
	initial_contents = list(/obj/item/gun/projectile/kovacs = 6,
	/obj/item/ammo_magazine/srifle = 18)

/obj/item/storage/deferred/crate/grenadier
	name = "grenadier crate"
	desc = "A crate containing one \"Lenar\" launcher, and copious quantities of hand-propelled explosive devices."
	icon_state = "serbcrate_deferred_black"
	initial_contents = list(/obj/item/grenade/explosive = 5,
	/obj/item/grenade/frag = 14,
	/obj/item/grenade/empgrenade/low_yield = 4,
	/obj/item/grenade/smokebomb = 8,
	/obj/item/gun/launcher/grenade/lenar = 1)

/obj/item/storage/deferred/crate/antiarmor //change to demolitions, won't do now because will affect map
	name = "demolitions crate"
	icon_state = "serbcrate_deferred_black"
	desc = "A crate containing one \"RPG-7\" launcher, and twelve 40mm PG-7VL warheads."
	initial_contents = list(/obj/item/ammo_casing/rocket = 12,
	/obj/item/storage/pouch/tubular = 1,
	/obj/item/gun/projectile/rpg = 1,
	/obj/item/storage/pouch/tubular = 1)

/obj/item/storage/deferred/crate/demolition
	name = "breaching crate"
	desc = "A crate of tools to deal with stationary hard targets, and remove obstacles."
	icon_state = "serbcrate_deferred_brown"
	initial_contents = list(/obj/item/plastique = 13,
	/obj/item/storage/pouch/tubular = 1,
	/obj/item/hatton = 1,
	/obj/item/hatton_magazine = 5,
	/obj/item/tool/pickaxe/diamonddrill = 1)


/obj/item/storage/deferred/crate/marksman
	name = "marksman crate"
	desc = "A crate containing one \"Penetrator\" rifle, and ten 14.5mm AP shells."
	icon_state = "serbcrate_deferred_black"
	initial_contents = list(/obj/item/gun/projectile/heavysniper = 1,
	/obj/item/storage/box/sniperammo = 2)

/obj/item/storage/deferred/crate/sidearm
	name = "sidearm crate"
	desc = "A crate containing six Makarov .35 pistols, 200 rounds of .35 ammunition, and six fixed-blade combat knives."
	icon_state = "serbcrate_deferred_green"
	initial_contents = list(/obj/item/gun/projectile/selfload/makarov = 6,
	/obj/item/ammo_magazine/hpistol = 20,
	/obj/item/tool/knife/boot = 6)

/obj/item/storage/deferred/crate/specialists_sidearm
	name = "specialists sidearm crate"
	desc = "A crate containing four Zoric heavy submachineguns and 400 rounds of .40 ammunition. For when you need to carry \
			something lighter than AK with your RPG or LMG."
	icon_state = "serbcrate_deferred_green"
	initial_contents = list(
		/obj/item/gun/projectile/automatic/zoric = 4,
		/obj/item/ammo_magazine/msmg = 16,
		)

/obj/item/storage/deferred/crate/cells
	name = "power cell bin"
	desc = "A moderately sized crate full of various power cells."
	icon_state = "serbcrate_deferred_worn"
	initial_contents = list(/obj/spawner/powercell = 16)


/obj/item/storage/deferred/crate/alcohol
	name = "liquor crate"
	desc = "A moderately sized crate full of various alcoholic drinks."
	icon_state = "serbcrate_deferred_worn"
	initial_contents = list(/obj/spawner/booze = 10,
	/obj/spawner/booze/low_chance = 10,
	/obj/item/reagent_containers/food/drinks/bottle/vodka = 3)

/obj/item/storage/deferred/crate/uniform_green
	name = "green uniform kit"
	desc = "A moderately sized crate full of clothes."
	icon_state = "serbcrate_deferred_green"
	initial_contents = list(
	/obj/item/clothing/under/serbiansuit = 1,
	/obj/item/clothing/head/soft/green2soft = 1,
	/obj/item/clothing/suit/armor/bulletproof/serbian/green = 1,
	/obj/item/clothing/head/armor/faceshield/altyn = 1,
	/obj/item/clothing/mask/balaclava/tactical = 1,
	/obj/item/clothing/shoes/jackboots = 1,
	/obj/item/clothing/gloves/fingerless = 1)

/obj/item/storage/deferred/crate/uniform_brown
	name = "brown uniform kit"
	desc = "A moderately sized crate full of clothes."
	icon_state = "serbcrate_deferred_brown"
	initial_contents = list(
	/obj/item/clothing/under/serbiansuit/brown = 1,
	/obj/item/clothing/head/soft/tan2soft = 1,
	/obj/item/clothing/suit/armor/bulletproof/serbian/tan = 1,
	/obj/item/clothing/head/armor/faceshield/altyn/brown = 1,
	/obj/item/clothing/mask/balaclava/tactical = 1,
	/obj/item/clothing/shoes/jackboots = 1,
	/obj/item/clothing/suit/armor/greatcoat/serbian_overcoat_brown = 1)

/obj/item/storage/deferred/crate/uniform_black
	name = "black uniform kit"
	desc = "A moderately sized crate full of clothes."
	icon_state = "serbcrate_deferred_black"
	initial_contents = list(
	/obj/item/clothing/under/serbiansuit/black = 1,
	/obj/item/clothing/suit/armor/bulletproof/serbian = 1,
	/obj/item/clothing/head/armor/faceshield/altyn/black = 1,
	/obj/item/clothing/mask/balaclava/tactical = 1,
	/obj/item/clothing/shoes/jackboots = 1,
	/obj/item/clothing/gloves/fingerless = 1,
	/obj/item/clothing/suit/armor/greatcoat/serbian_overcoat = 1)

/obj/item/storage/deferred/crate/uniform_flak
	name = "flak serbian uniform crate"
	desc = "A moderately sized crate full of clothes."
	icon_state = "serbcrate_deferred_worn"
	initial_contents = list(
	/obj/item/clothing/under/serbiansuit = 1,
	/obj/item/clothing/suit/armor/flak/green = 1,
	/obj/item/clothing/head/armor/faceshield/altyn/maska = 1,
	/obj/item/clothing/mask/balaclava/tactical = 1,
	/obj/item/clothing/shoes/jackboots = 1,
	/obj/item/clothing/gloves/fingerless = 1,
	/obj/item/storage/fancy/cigarettes = 1)

/obj/item/storage/deferred/crate/uniform_light
	name = "light armor kit"
	desc = "A moderately sized crate full of clothes."
	icon_state = "serbcrate_deferred_worn"
	initial_contents = list(
	/obj/item/clothing/under/serbiansuit = 1,
	/obj/item/clothing/head/soft/green2soft = 1,
	/obj/item/clothing/suit/armor/flak = 1,
	/obj/item/clothing/head/armor/steelpot = 1,
	/obj/item/clothing/shoes/jackboots = 1,
	/obj/item/clothing/gloves/fingerless = 1,
	/obj/item/storage/fancy/cigarettes = 1)

/obj/item/storage/deferred/crate/german_uniform
	name = "german uniform crate"
	desc = "A moderately sized crate full of clothes."
	icon_state = "germancrate_deferred"
	initial_contents = list(
	/obj/item/clothing/gloves/german = 1,
	/obj/item/clothing/head/beret/german = 1,
	/obj/item/clothing/mask/gas/german = 1,
	/obj/item/clothing/shoes/jackboots/german = 1,
	/obj/item/clothing/suit/armor/greatcoat/german_overcoat = 1,
	/obj/item/clothing/under/germansuit = 1)

/obj/item/storage/deferred/crate/clown_crime
	name = "mastermind suit bag"
	desc = "A duffelbag filled with clothing and... a second duffelbag?."
	icon = 'icons/obj/storage/backpack.dmi'
	icon_state = "lootbag"
	spawn_blacklisted = TRUE
	initial_contents = list(
	/obj/item/clothing/mask/thief = 1,
	/obj/item/storage/belt/tactical = 1,
	/obj/item/storage/backpack/duffelbag/loot = 1,
	/obj/item/clothing/under/tuxedo = 1,
	/obj/item/clothing/shoes/reinforced = 1,
	/obj/item/clothing/gloves/latex/nitrile = 1,
	/obj/item/clothing/suit/armor/vest = 1)

/obj/item/storage/deferred/crate/clown_crime/wolf
	name = "technician suit bag"
	initial_contents = list(
	/obj/item/clothing/mask/thief/wolf = 1,
	/obj/item/storage/belt/tactical = 1,
	/obj/item/storage/backpack/duffelbag/loot = 1,
	/obj/item/clothing/under/tuxedo = 1,
	/obj/item/clothing/shoes/reinforced = 1,
	/obj/item/clothing/gloves/latex/nitrile = 1,
	/obj/item/clothing/suit/armor/vest = 1)

/obj/item/storage/deferred/crate/clown_crime/hoxton	//whatcocksuckingmotherfuckermeasuredthec4 https://www.youtube.com/watch?v=Hmp1da7pXTw&t=160s
	name = "fugitive suit bag"
	initial_contents = list(
	/obj/item/clothing/mask/thief/hoxton = 1,
	/obj/item/storage/belt/tactical = 1,
	/obj/item/storage/backpack/duffelbag/loot = 1,
	/obj/item/clothing/under/tuxedo = 1,
	/obj/item/clothing/shoes/reinforced = 1,
	/obj/item/clothing/gloves/latex/nitrile = 1,
	/obj/item/clothing/suit/armor/vest = 1)

/obj/item/storage/deferred/crate/clown_crime/chains
	name = "enforcer suit bag"
	initial_contents = list(
	/obj/item/clothing/mask/thief/chains = 1,
	/obj/item/storage/belt/tactical = 1,
	/obj/item/storage/backpack/duffelbag/loot = 1,
	/obj/item/clothing/under/tuxedo = 1,
	/obj/item/clothing/shoes/reinforced = 1,
	/obj/item/clothing/gloves/latex/nitrile = 1,
	/obj/item/clothing/suit/armor/vest = 1)

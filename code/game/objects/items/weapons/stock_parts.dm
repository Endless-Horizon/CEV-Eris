/obj/item/stock_parts
	name = "stock part"
	desc = "What?"
	gender = PLURAL
	icon = 'icons/obj/stock_parts.dmi'
	w_class = ITEM_SIZE_SMALL
	rarity_value = 10
	bad_type = /obj/item/stock_parts
	spawn_tags = SPAWN_TAG_STOCK_PARTS
	var/rating = 1

/obj/item/stock_parts/New()
	src.pixel_x = rand(-5, 5)
	src.pixel_y = rand(-5, 5)
	..()

//Rank 1

/obj/item/stock_parts/console_screen
	name = "console screen"
	desc = "Used in the construction of computers and other devices with a interactive console."
	icon_state = "screen"
	origin_tech = list(TECH_MATERIAL = 1)
	matter = list(MATERIAL_GLASS = 3)

/obj/item/stock_parts/capacitor
	name = "capacitor"
	desc = "A basic capacitor used in the construction of a variety of devices."
	icon_state = "capacitor"
	origin_tech = list(TECH_POWER = 1)
	matter = list(MATERIAL_STEEL = 1, MATERIAL_PLASTIC = 1, MATERIAL_GLASS = 1)
	rarity_value = 15

/obj/item/stock_parts/scanning_module
	name = "scanning module"
	desc = "A compact, high resolution scanning module used in the construction of certain devices."
	icon_state = "scan_module"
	origin_tech = list(TECH_MAGNET = 1)
	matter = list(MATERIAL_STEEL = 1, MATERIAL_PLASTIC = 1, MATERIAL_GLASS = 1)

/obj/item/stock_parts/manipulator
	name = "micro-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "micro_mani"
	origin_tech = list(TECH_MATERIAL = 1, TECH_DATA = 1)
	matter = list(MATERIAL_STEEL = 1, MATERIAL_PLASTIC = 1)

/obj/item/stock_parts/micro_laser
	name = "micro-laser"
	desc = "A tiny laser used in certain devices."
	icon_state = "micro_laser"
	origin_tech = list(TECH_MAGNET = 1)
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1)

/obj/item/stock_parts/matter_bin
	name = "matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "matter_bin"
	origin_tech = list(TECH_MATERIAL = 1)
	matter = list(MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1)
	rarity_value = 9

//Rank 2

/obj/item/stock_parts/capacitor/adv
	name = "advanced capacitor"
	desc = "An advanced capacitor used in the construction of a variety of devices."
	icon_state = "adv_capacitor"
	origin_tech = list(TECH_POWER = 3)
	rating = 2
	matter = list(MATERIAL_STEEL = 1, MATERIAL_PLASTIC = 1, MATERIAL_GLASS = 1)
	spawn_tags = SPAWN_TAG_STOCK_PARTS_TIER_2

/obj/item/stock_parts/scanning_module/adv
	name = "advanced scanning module"
	desc = "A compact, high resolution scanning module used in the construction of certain devices."
	icon_state = "adv_scan_module"
	origin_tech = list(TECH_MAGNET = 3)
	rating = 2
	matter = list(MATERIAL_STEEL = 1, MATERIAL_PLASTIC = 1, MATERIAL_GLASS = 1)
	spawn_tags = SPAWN_TAG_STOCK_PARTS_TIER_2

/obj/item/stock_parts/manipulator/nano
	name = "nano-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "nano_mani"
	origin_tech = list(TECH_MATERIAL = 3, TECH_DATA = 2)
	rating = 2
	matter = list(MATERIAL_STEEL = 1, MATERIAL_PLASTIC = 1)
	spawn_tags = SPAWN_TAG_STOCK_PARTS_TIER_2

/obj/item/stock_parts/micro_laser/high
	name = "high-power micro-laser"
	desc = "A tiny laser used in certain devices."
	icon_state = "high_micro_laser"
	origin_tech = list(TECH_MAGNET = 3)
	rating = 2
	matter = list(MATERIAL_STEEL = 1, MATERIAL_PLASTIC = 1, MATERIAL_GLASS = 1)
	spawn_tags = SPAWN_TAG_STOCK_PARTS_TIER_2

/obj/item/stock_parts/matter_bin/adv
	name = "advanced matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "advanced_matter_bin"
	origin_tech = list(TECH_MATERIAL = 3)
	rating = 2
	matter = list(MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1)
	spawn_tags = SPAWN_TAG_STOCK_PARTS_TIER_2

//Rating 3

/obj/item/stock_parts/capacitor/super
	name = "super capacitor"
	desc = "A super-high capacity capacitor used in the construction of a variety of devices."
	icon_state = "super_capacitor"
	origin_tech = list(TECH_POWER = 5, TECH_MATERIAL = 4)
	rating = 3
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1)

/obj/item/stock_parts/scanning_module/phasic
	name = "phasic scanning module"
	desc = "A compact, high resolution phasic scanning module used in the construction of certain devices."
	icon_state = "super_scan_module"
	origin_tech = list(TECH_MAGNET = 5)
	rating = 3
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1)

/obj/item/stock_parts/manipulator/pico
	name = "pico-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "pico_mani"
	origin_tech = list(TECH_MATERIAL = 5, TECH_DATA = 2)
	rating = 3
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2)

/obj/item/stock_parts/micro_laser/ultra
	name = "ultra-high-power micro-laser"
	icon_state = "ultra_high_micro_laser"
	desc = "A tiny laser used in certain devices."
	origin_tech = list(TECH_MAGNET = 5)
	rating = 3
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1)

/obj/item/stock_parts/matter_bin/super
	name = "super matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "super_matter_bin"
	origin_tech = list(TECH_MATERIAL = 5)
	rating = 3
	matter = list(MATERIAL_PLASTIC = 3, MATERIAL_GLASS = 1)


//excelsior stock parts (rating 4)
/obj/item/stock_parts/capacitor/excelsior
	name = "excelsior capacitor"
	desc = "A super-high capacity capacitor used in the construction of a variety of devices."
	icon_state = "excel_capacitor"
	origin_tech = list(TECH_POWER = 5, TECH_MATERIAL = 4)
	rating = 4
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1)
	spawn_blacklisted = TRUE

/obj/item/stock_parts/scanning_module/excelsior
	name = "excelsior scanning module"
	desc = "A compact, high resolution phasic scanning module used in the construction of certain devices."
	icon_state = "excel_scan_module"
	origin_tech = list(TECH_MAGNET = 5)
	rating = 4
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1)
	spawn_blacklisted = TRUE

/obj/item/stock_parts/manipulator/excelsior
	name = "excelsior manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "excel_mani"
	origin_tech = list(TECH_MATERIAL = 5, TECH_DATA = 2)
	rating = 4
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2)
	spawn_blacklisted = TRUE

/obj/item/stock_parts/micro_laser/excelsior
	name = "excelsior micro-laser"
	icon_state = "excel_laser"
	desc = "A tiny laser used in certain devices."
	origin_tech = list(TECH_MAGNET = 5)
	rating = 4
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1)
	spawn_blacklisted = TRUE

/obj/item/stock_parts/matter_bin/excelsior
	name = "excelsior matter bin"
	desc = "A container for holding compressed matter awaiting re-construction."
	icon_state = "excel_matter"
	origin_tech = list(TECH_MATERIAL = 5)
	rating = 4
	matter = list(MATERIAL_PLASTIC = 3, MATERIAL_GLASS = 1)
	spawn_blacklisted = TRUE

//one star stock parts (rating 5)

/obj/item/stock_parts/capacitor/one_star
	name = "one star capacitor"
	desc = "A super-high capacity capacitor used in the construction of a variety of devices."
	icon_state = "one_capacitor"
	origin_tech = list(TECH_POWER = 5, TECH_MATERIAL = 4)
	rating = 5
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1)
	spawn_blacklisted = TRUE
	spawn_tags = SPAWN_TAG_STOCK_PARTS_OS

/obj/item/stock_parts/scanning_module/one_star
	name = "one star scanning module"
	desc = "A compact, high resolution phasic scanning module used in the construction of certain devices."
	icon_state = "one_scan_module"
	origin_tech = list(TECH_MAGNET = 5)
	rating = 5
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1)
	spawn_blacklisted = TRUE
	spawn_tags = SPAWN_TAG_STOCK_PARTS_OS

/obj/item/stock_parts/manipulator/one_star
	name = "one star manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "one_mani"
	origin_tech = list(TECH_MATERIAL = 5, TECH_DATA = 2)
	rating = 5
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2)
	spawn_blacklisted = TRUE
	spawn_tags = SPAWN_TAG_STOCK_PARTS_OS

/obj/item/stock_parts/micro_laser/one_star
	name = "one star micro-laser"
	icon_state = "one_laser"
	desc = "A tiny laser used in certain devices."
	origin_tech = list(TECH_MAGNET = 5)
	rating = 5
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1)
	spawn_blacklisted = TRUE
	spawn_tags = SPAWN_TAG_STOCK_PARTS_OS

/obj/item/stock_parts/matter_bin/one_star
	name = "one star matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "one_matter"
	origin_tech = list(TECH_MATERIAL = 5)
	rating = 5
	matter = list(MATERIAL_PLASTIC = 3, MATERIAL_GLASS = 1)
	spawn_blacklisted = TRUE
	spawn_tags = SPAWN_TAG_STOCK_PARTS_OS


//alien stock parts (rating 6)

/obj/item/stock_parts/capacitor/alien_capacitor
	name = "Exothermal Seal"
	desc = "A can-shaped brass component, covered in scratch marks and weathered by time. A faint humming can be heard coming from its inner workings. Seems like it can be used in construction of certain devices."
	icon_state = "alien_capacitor"
	origin_tech = list(TECH_POWER = 5, TECH_MATERIAL = 5)
	rating = 6
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 1, MATERIAL_GLASS = 3)
	spawn_blacklisted = TRUE

/obj/item/stock_parts/scanning_module/alien
	name = "Optical receptor"
	desc = "A device, closely resembling a human eye. The pupil dilates and contracts when exposed to different materials. Seems like it can be used in construction of certain devices."
	icon_state = "alien_scan_module"
	origin_tech = list(TECH_MAGNET = 5)
	rating = 6
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1)
	spawn_blacklisted = TRUE

/obj/item/stock_parts/manipulator/alien
	name = "Gripper"
	desc = "This strange chunk of metal opens and closes its claws, as if it was a freshly cut crab arm. Seems like it can be used in construction of certain devices."
	icon_state = "alien_mani"
	origin_tech = list(TECH_MATERIAL = 5, TECH_DATA = 2)
	rating = 6
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2)
	spawn_blacklisted = TRUE

/obj/item/stock_parts/micro_laser/alien
	name = "Pico-emitter"
	icon_state = "alien_laser"
	desc = "A bright glass orb with a port on its back. It glows faint blue from time to time. Seems like it can be used in construction of certain devices."
	origin_tech = list(TECH_MAGNET = 5)
	rating = 6
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1)
	spawn_blacklisted = TRUE

/obj/item/stock_parts/matter_bin/alien
	name = "Recepticle"
	desc = "A twisted and time-weathered metal contraption, that's slightly warm to the touch. Seems like it can be used in construction of certain devices."
	icon_state = "alien_matter"
	origin_tech = list(TECH_MATERIAL = 5)
	rating = 6
	matter = list(MATERIAL_PLASTIC = 3, MATERIAL_GLASS = 1)
	spawn_blacklisted = TRUE

// debug stock parts - rating 100, intended for debugging

/obj/item/stock_parts/capacitor/debug
	name = "bluespace capacitor"
	desc = "An ultra-advanced battery able to store immense amounts of energy in a localized bluespace pocket. Used in construction of certain devices."
	icon_state = "debug_capacitor"
	origin_tech = list(TECH_POWER = 6, TECH_MATERIAL = 6)
	rating = 100 // rating doesn't really matter past a certain point - this makes autolathes print stuff at 1/5th the normal cost (item that costs 5 steel now costs 1 steel)
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 1, MATERIAL_GLASS = 3, MATERIAL_PLASMA = 1)
	bad_type = /obj/item/stock_parts/capacitor/debug

/obj/item/stock_parts/scanning_module/debug
	name = "bluespace scanning module"
	desc = "An ultra-advanced electronic that can rapidly scan objects, as well as their mirror images in bluespace in order to easily understand every detail. Used in construction of certain devices."
	icon_state = "debug_scan_module"
	origin_tech = list(TECH_MAGNET = 6)
	rating = 100
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1, MATERIAL_PLASMA = 1)
	bad_type = /obj/item/stock_parts/scanning_module/debug

/obj/item/stock_parts/manipulator/debug
	name = "bluespace yocto-manipulator"
	desc = "An ultra-advanced device that can manipulate an objects molecular structure. Used in construction of certain devices."
	icon_state = "debug_mani"
	origin_tech = list(TECH_MATERIAL = 6, TECH_DATA = 3)
	rating = 100
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2, MATERIAL_PLASMA = 1)
	bad_type = /obj/item/stock_parts/manipulator/debug

/obj/item/stock_parts/micro_laser/debug
	name = "bluespace yocto-laser"
	icon_state = "debug_micro_laser"
	desc = "An ultra-advanced device that emits a laser that can emit any kind of laser on the spectrum, and several lasers off the spectrum. Used in construction of certain devices."
	origin_tech = list(TECH_MAGNET = 6)
	rating = 100
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1, MATERIAL_PLASMA = 1)
	bad_type = /obj/item/stock_parts/micro_laser/debug

/obj/item/stock_parts/matter_bin/debug
	name = "bluespace matter bin"
	desc = "An ultra-advanced container that opens into a localized pocket dimension meant for holding compressed matter. Used in construction of certain devices."
	icon_state = "debug_matter_bin"
	origin_tech = list(TECH_MATERIAL = 6)
	rating = 100
	matter = list(MATERIAL_PLASTIC = 3, MATERIAL_GLASS = 1, MATERIAL_PLASMA = 1)
	bad_type = /obj/item/stock_parts/matter_bin/debug

// Subspace stock parts
/obj/item/stock_parts/subspace
	rarity_value = 8
	bad_type = /obj/item/stock_parts/subspace

/obj/item/stock_parts/subspace/ansible
	name = "subspace ansible"
	icon_state = "subspace_ansible"
	desc = "A compact module capable of sensing extradimensional activity."
	origin_tech = list(TECH_DATA = 3, TECH_MAGNET = 5 ,TECH_MATERIAL = 4, TECH_BLUESPACE = 2)
	matter = list(MATERIAL_STEEL = 2, MATERIAL_GLASS = 1, MATERIAL_SILVER = 2)

/obj/item/stock_parts/subspace/filter
	name = "hyperwave filter"
	icon_state = "hyperwave_filter"
	desc = "A tiny device capable of filtering and converting super-intense radiowaves."
	origin_tech = list(TECH_DATA = 4, TECH_MAGNET = 2)
	matter = list(MATERIAL_STEEL = 2, MATERIAL_GLASS = 1, MATERIAL_SILVER = 1)

/obj/item/stock_parts/subspace/amplifier
	name = "subspace amplifier"
	icon_state = "subspace_amplifier"
	desc = "A compact micro-machine capable of amplifying weak subspace transmissions."
	origin_tech = list(TECH_DATA = 3, TECH_MAGNET = 4, TECH_MATERIAL = 4, TECH_BLUESPACE = 2)
	matter = list(MATERIAL_STEEL = 2, MATERIAL_GLASS = 1, MATERIAL_SILVER = 1)

/obj/item/stock_parts/subspace/treatment
	name = "subspace treatment disk"
	icon_state = "treatment_disk"
	desc = "A compact micro-machine capable of stretching out hyper-compressed radio waves."
	origin_tech = list(TECH_DATA = 3, TECH_MAGNET = 2, TECH_MATERIAL = 5, TECH_BLUESPACE = 2)
	matter = list(MATERIAL_STEEL = 2, MATERIAL_GLASS = 1, MATERIAL_SILVER = 1)

/obj/item/stock_parts/subspace/analyzer
	name = "subspace wavelength analyzer"
	icon_state = "wavelength_analyzer"
	desc = "A sophisticated analyzer capable of analyzing cryptic subspace wavelengths."
	origin_tech = list(TECH_DATA = 3, TECH_MAGNET = 4, TECH_MATERIAL = 4, TECH_BLUESPACE = 2)
	matter = list(MATERIAL_STEEL = 2, MATERIAL_GLASS = 1, MATERIAL_SILVER = 1)

/obj/item/stock_parts/subspace/crystal
	name = "ansible crystal"
	icon_state = "ansible_crystal"
	desc = "A crystal made from pure glass used to transmit laser databursts to subspace."
	origin_tech = list(TECH_MAGNET = 4, TECH_MATERIAL = 4, TECH_BLUESPACE = 2)
	matter = list(MATERIAL_STEEL = 2, MATERIAL_GLASS = 1, MATERIAL_SILVER = 2)

/obj/item/stock_parts/subspace/transmitter
	name = "subspace transmitter"
	icon_state = "subspace_transmitter"
	desc = "A large piece of equipment used to open a window into the subspace dimension."
	origin_tech = list(TECH_MAGNET = 5, TECH_MATERIAL = 5, TECH_BLUESPACE = 3)
	matter = list(MATERIAL_STEEL = 2, MATERIAL_GLASS = 1, MATERIAL_SILVER = 1)

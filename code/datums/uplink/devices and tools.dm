/********************
* Devices and Tools *
********************/
/datum/uplink_item/item/tools
	category = /datum/uplink_category/tools

/datum/uplink_item/item/tools/toolbox
	name = "Fully Loaded Toolbox"
	item_cost = 5
	path = /obj/item/storage/toolbox/syndicate
	desc = "Danger. Very robust. Filled with advanced tools."

/datum/uplink_item/item/tools/shield_diffuser
	name = "Shield Diffuser"
	item_cost = 4
	path = /obj/item/device/shield_diffuser
	desc = "A handheld device that disrupts shields, allowing you to effortlessly pass through. Be sure to bring some spare power cells!."

/datum/uplink_item/item/tools/money
	name = "Operations Funding"
	item_cost = 13
	path = /obj/item/storage/secure/briefcase/money
	desc = "A briefcase with 10,000 untraceable credits for funding your sneaky activities."

/datum/uplink_item/item/tools/pocketchange
	name = "Spending Money"
	item_cost = 1
	path = /obj/item/spacecash/bundle/c500
	desc = "A bundle of 500 untraceable credits to cover a few basic expenses."

/datum/uplink_item/item/tools/plastique
	name = "C-4 (Destroys walls)"
	item_cost = 3
	path = /obj/item/plastique

/datum/uplink_item/item/tools/heavy_vest
	name = "Heavy Armor Vest"
	item_cost = 6
	path = /obj/item/clothing/suit/storage/vest/merc
	
/datum/uplink_item/item/tools/full_heavy_vest
	name = "Fullbody Heavy Armor Vest"
	item_cost = 12
	path = /obj/item/clothing/suit/storage/vest/merc/full

/datum/uplink_item/item/tools/heavy_helmet
	name = "Heavy Armor Helmet"
	item_cost = 4
	path = /obj/item/clothing/head/armor/helmet/merchelm

/datum/uplink_item/item/tools/encryptionkey_radio
	name = "Encrypted Radio Channel Key"
	item_cost = 4
	path = /obj/item/device/encryptionkey/syndicate

/datum/uplink_item/item/tools/encryptionkey_binary
	name = "Binary Translator Key"
	item_cost = 5
	path = /obj/item/device/encryptionkey/binary

/datum/uplink_item/item/tools/emag
	name = "Cryptographic Sequencer"
	item_cost = 6
	path = /obj/item/card/emag

/datum/uplink_item/item/tools/hacking_tool
	name = "Door Hacking Tool"
	item_cost = 6
	path = /obj/item/tool/multitool/hacktool
	desc = "Appears and functions as a standard multitool until the mode is toggled by applying a screwdriver appropriately. \
			When in hacking mode this device will grant full access to any standard airlock within 20 to 40 seconds. \
			This device will also be able to immediately access the last 6 to 8 hacked airlocks."

/datum/uplink_item/item/tools/space_suit
	name = "Mercenary Voidsuit"
	item_cost = 6
	path = /obj/item/storage/box/syndie_kit/space

/datum/uplink_item/item/tools/thermal
	name = "Thermal Imaging Glasses"
	item_cost = 8
	path = /obj/item/clothing/glasses/powered/thermal/syndi

/datum/uplink_item/item/tools/thermal_lens
	name = "Thermal Imaging Lenses"
	item_cost = 12
	path = /obj/item/clothing/glasses/powered/thermal/lens

/datum/uplink_item/item/tools/powersink
	name = "Powersink (DANGER!)"
	item_cost = 10
	path = /obj/item/device/powersink

/datum/uplink_item/item/tools/teleporter
	name = "Teleporter Circuit Board"
	item_cost = 8
	path = /obj/item/electronics/circuitboard/teleporter

/datum/uplink_item/item/tools/teleporter/New()
	..()
	antag_roles = list(ROLE_MERCENARY)

/datum/uplink_item/item/tools/ai_module
	name = "Hacked AI Upload Module"
	item_cost = 7
	path = /obj/item/electronics/ai_module/syndicate

/datum/uplink_item/item/tools/supply_beacon
	name = "Hacked Supply Beacon (DANGER!)"
	item_cost = 14
	path = /obj/item/supply_beacon

/datum/uplink_item/item/tools/mind_fryer
	name = "Mind Fryer"
	desc = "When activated, attacks the minds of people nearby, causing sanity loss and inducing mental breakdowns. \
			The device owner is immune to this effect."
	item_cost = 2
	path = /obj/item/device/mind_fryer
	antag_roles = list(ROLE_TRAITOR, ROLE_BLITZ)

/datum/uplink_item/item/tools/mind_fryer/buy(obj/item/device/uplink/U)
	. = ..()
	if(.)
		var/obj/item/device/mind_fryer/M = .
		M.owner = U.uplink_owner

/datum/uplink_item/item/tools/spy_sensor
	name = "Spying Sensor (4x)"
	desc = "A set of sensor packages designed to collect some information for your client. \
			Place the sensors in target area, make sure to activate each one and do not move or otherwise disturb them."
	item_cost = 1
	path = /obj/item/storage/box/syndie_kit/spy_sensor
	antag_roles = list(ROLE_TRAITOR, ROLE_BLITZ)

/datum/uplink_item/item/tools/spy_sensor/buy(obj/item/device/uplink/U)
	. = ..()
	if(.)
		var/obj/item/storage/box/syndie_kit/spy_sensor/B = .
		for(var/obj/item/device/spy_sensor/S in B)
			S.owner = U.uplink_owner

/datum/uplink_item/item/tools/bsdm
	name = "Blue Space Direct Mail Unit"
	item_cost = 1
	path = /obj/item/storage/bsdm
	antag_roles = ROLES_CONTRACT

/datum/uplink_item/item/tools/bsdm/can_view(obj/item/device/uplink/U)
	return ..() && (U.bsdm_time > world.time)

/datum/uplink_item/item/tools/bsdm/buy(obj/item/device/uplink/U)
	. = ..()
	if(.)
		var/obj/item/storage/bsdm/B = .
		B.owner = U.uplink_owner

/datum/uplink_item/item/tools/bsdm_free
	name = "Blue Space Direct Mail Unit"
	item_cost = 0
	path = /obj/item/storage/bsdm
	antag_roles = ROLES_CONTRACT

/datum/uplink_item/item/tools/bsdm_free/can_view(obj/item/device/uplink/U)
	return ..() && (U.bsdm_time <= world.time)

/datum/uplink_item/item/tools/bsdm_free/buy(obj/item/device/uplink/U)
	. = ..()
	if(.)
		var/obj/item/storage/bsdm/B = .
		B.owner = U.uplink_owner
		U.bsdm_time = world.time + 10 MINUTES

/datum/uplink_item/item/tools/mental_imprinter
	name = "Mental Imprinter"
	item_cost = 5
	path = /obj/item/device/mental_imprinter
	antag_roles = list(ROLE_TRAITOR,ROLE_MARSHAL,ROLE_INQUISITOR,ROLE_MERCENARY,ROLE_CARRION)

//********** Blitzshell unique uplink items **********//

/datum/uplink_item/item/tools/blitz_hp_upgrade
	name = "Blitzshell Armour Augmentation"
	desc = "Augment your chassis to take more blows before destruction."
	item_cost = 15
	antag_roles = list(ROLE_BLITZ)


/datum/uplink_item/item/tools/blitz_hp_upgrade/get_goods(var/obj/item/device/uplink/U, var/loc, var/mob/living/user)
	if(user && istype(user, /mob/living/silicon/robot/drone/blitzshell))
		var/mob/living/silicon/robot/drone/blitzshell/BS = user
		BS.adjustMaxHealth(30)
		to_chat(BS, SPAN_NOTICE("Your chassis armour is augmented."))
		return 1
	return 0


/datum/uplink_item/item/tools/blitz_cell_upgrade
	name = "Blitzshell Cell Upgrade"
	desc = "Augment your cell charge, to hold additional energy."
	item_cost = 15
	antag_roles = list(ROLE_BLITZ)


/datum/uplink_item/item/tools/blitz_cell_upgrade/get_goods(var/obj/item/device/uplink/U, var/loc, var/mob/living/user)
	if(user && istype(user, /mob/living/silicon/robot/drone/blitzshell))
		var/mob/living/silicon/robot/drone/blitzshell/BS = user
		var/obj/item/cell/C = BS.get_cell()
		if(C)
			C.maxcharge *= 1.5
			to_chat(BS, SPAN_NOTICE("Your cell's maximum charge has been augmented."))
		return 1
	return 0

/datum/uplink_item/item/tools/blitz_speed_upgrade
	name = "Blitzshell Speed Upgrade"
	desc = "Remove limiting factors on your motors, allowing you to move faster."
	item_cost = 20
	antag_roles = list(ROLE_BLITZ)


/datum/uplink_item/item/tools/blitz_speed_upgrade/get_goods(var/obj/item/device/uplink/U, var/loc, var/mob/living/user)
	if(user && istype(user, /mob/living/silicon/robot/drone/blitzshell))
		var/mob/living/silicon/robot/drone/blitzshell/BS = user
		BS.speed_factor += 0.2
		return 1
	return 0

/datum/uplink_item/item/tools/blitz_laserweapon
	name = "Blitzshell Weapons Upgrade"
	desc = "Activates the embedded laser weapon system."
	item_cost = 20
	antag_roles = list(ROLE_BLITZ)


/datum/uplink_item/item/tools/blitz_laserweapon/get_goods(var/obj/item/device/uplink/U, var/loc, var/mob/living/user)
	if(user && istype(user, /mob/living/silicon/robot/drone/blitzshell))
		var/mob/living/silicon/robot/drone/blitzshell/BS = user
		if(locate(/obj/item/gun/energy/laser/mounted/blitz) in BS.module.modules)
			to_chat(BS, SPAN_WARNING("You already have a laser system installed."))
			return 0
		BS.module.modules += new /obj/item/gun/energy/laser/mounted/blitz(BS.module)
		return 1
	return 0

/datum/uplink_item/item/tools/blitz_shotgun
	name = "Blitzshell electro-shrapnel cannon"
	desc = "Activates the embedded pneumatic weapon system."
	item_cost = 30
	antag_roles = list(ROLE_BLITZ)

/datum/uplink_item/item/tools/blitz_shotgun/get_goods(var/obj/item/device/uplink/U, var/loc, var/mob/living/user)
	if(user && istype(user, /mob/living/silicon/robot/drone/blitzshell))
		var/mob/living/silicon/robot/drone/blitzshell/BS = user
		if(locate(/obj/item/gun/energy/shrapnel/mounted) in BS.module.modules)
			to_chat(BS, SPAN_WARNING("You already have a shrapnel cannon installed."))
			return 0
		BS.module.modules += new /obj/item/gun/energy/shrapnel/mounted(BS.module)
		return 1
	return 0

/datum/uplink_item/item/tools/blitz_nanorepair
	name = "Blitzshell Nanorepair Capsule"
	desc = "Reload your nanorepair system, gaining extra charges."
	item_cost = 5
	antag_roles = list(ROLE_BLITZ)


/datum/uplink_item/item/tools/blitz_nanorepair/get_goods(var/obj/item/device/uplink/U, var/loc, var/mob/living/user)
	if(user && istype(user, /mob/living/silicon/robot/drone/blitzshell))
		var/mob/living/silicon/robot/drone/blitzshell/BS = user
		var/obj/item/device/nanite_container/NC = locate() in BS.module.modules
		if(NC)
			NC.charges += 1
			to_chat(BS, SPAN_NOTICE("You now have [NC.charges] charges in your [NC]"))
			return 1
	return 0

/datum/uplink_item/item/tools/blitz_smokescreen
	name = "Blitzshell Smoke Upgade"
	desc = "Activates the embedded smoke deployment system."
	item_cost = 8
	antag_roles = list(ROLE_BLITZ)


/datum/uplink_item/item/tools/blitz_smokescreen/get_goods(var/obj/item/device/uplink/U, var/loc, var/mob/living/user)
	if(user && istype(user, /mob/living/silicon/robot/drone/blitzshell))
		var/mob/living/silicon/robot/drone/blitzshell/BS = user
		if(locate(/obj/item/device/smokescreen) in BS.module.modules)
			to_chat(BS, SPAN_WARNING("You already have a smoke deployment installed."))
			return 0
		BS.module.modules += new /obj/item/device/smokescreen(BS.module)
		return 1
	return 0

/datum/uplink_item/item/tools/blitz_smokescharge
	name = "Blitzshell Smoke Charge"
	desc = "Reload your smoke system, gaining extra charges."
	item_cost = 4
	antag_roles = list(ROLE_BLITZ)


/datum/uplink_item/item/tools/blitz_smokescharge/get_goods(var/obj/item/device/uplink/U, var/loc, var/mob/living/user)
	if(user && istype(user, /mob/living/silicon/robot/drone/blitzshell))
		var/mob/living/silicon/robot/drone/blitzshell/BS = user
		var/obj/item/device/smokescreen/SS = locate() in BS.module.modules
		if(SS)
			SS.charges += 1
			to_chat(BS, SPAN_NOTICE("You now have [SS.charges] charges in your [SS]"))
			return 1
		else
			to_chat(BS, SPAN_NOTICE("You do not have smoke deployment system unlocked"))
	return 0

/datum/uplink_item/item/tools/blitz_reinforcements
	name = "Blitzshell Swarm Request"
	desc = "Request additional reinforcements."
	item_cost = 30
	antag_roles = list(ROLE_BLITZ)


/datum/uplink_item/item/tools/blitz_reinforcements/get_goods(var/obj/item/device/uplink/U, var/loc, var/mob/living/user)
	to_chat(user, SPAN_NOTICE("Additional Blitzshell inbound to your position."))
	spawn(5)
		var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(5, 0, loc)
		sparks.start()
		var/mob/living/silicon/robot/drone/blitzshell/BS = new /mob/living/silicon/robot/drone/blitzshell(loc)
		BS.request_player()
	return 1

/datum/uplink_item/item/tools/blitz_harpoon
	name = "Blitzshell Blue Space Harpoon"
	desc = "Activates the embedded bluespace harpoon."
	item_cost = 12
	antag_roles = list(ROLE_BLITZ)

/datum/uplink_item/item/tools/blitz_harpoon/get_goods(var/obj/item/device/uplink/U, var/loc, var/mob/living/user)
	if(user && istype(user, /mob/living/silicon/robot/drone/blitzshell))
		var/mob/living/silicon/robot/drone/blitzshell/BS = user
		if(locate(/obj/item/bluespace_harpoon/mounted/blitz) in BS.module.modules)
			to_chat(BS, SPAN_WARNING("You already have a bluespace harpoon installed."))
			return
		BS.module.modules += new /obj/item/bluespace_harpoon/mounted/blitz(BS.module)
		return TRUE

/datum/uplink_item/item/tools/mindreader
	name = "Mindreader"
	desc = "Place on your victim's head to extract memories from their brain after a mental breakdown."
	item_cost = 20
	path = /obj/item/clothing/head/mindreader

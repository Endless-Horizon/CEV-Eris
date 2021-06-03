/* Contains:
 * /obj/item/rig_module/device
 * /obj/item/rig_module/device/plasmacutter
 * /obj/item/rig_module/device/healthscanner
 * /obj/item/rig_module/device/drill
 * /obj/item/rig_module/device/orescanner
 * /obj/item/rig_module/device/rcd
 * /obj/item/rig_module/device/anomaly_scanner
 * /obj/item/rig_module/maneuvering_jets
 * /obj/item/rig_module/foam_sprayer
 * /obj/item/rig_module/device/broadcaster
 * /obj/item/rig_module/chem_dispenser
 * /obj/item/rig_module/chem_dispenser/injector
 * /obj/item/rig_module/voice
 * /obj/item/rig_module/device/paperdispenser
 * /obj/item/rig_module/device/pen
 * /obj/item/rig_module/device/stamp
 */

/obj/item/rig_module/device
	name = "mounted device"
	desc = "Some kind of hardsuit mount."
	usable = 0
	selectable = 1
	toggleable = 0
	disruptive = 0
	bad_type = /obj/item/rig_module/device


	var/device_type
	var/obj/item/device

/obj/item/rig_module/device/healthscanner
	name = "health scanner module"
	desc = "A hardsuit-mounted health scanner."
	icon_state = "scanner"
	interface_name = "health scanner"
	interface_desc = "Shows an informative health readout when used on a subject."
	device_type = /obj/item/device/scanner/health
	rarity_value = 2.5
	spawn_tags = SPAWN_TAG_RIG_MODULE_COMMON

/obj/item/rig_module/device/drill
	name = "hardsuit drill mount"
	desc = "A very heavy diamond-tipped drill."
	icon_state = "drill"
	interface_name = "mounted drill"
	interface_desc = "A diamond-tipped industrial drill."
	suit_overlay_active = "mounted-drill"
	suit_overlay_inactive = "mounted-drill"
	use_power_cost = 0.1
	rarity_value = 10


	device_type = /obj/item/weapon/tool/pickaxe/diamonddrill/rig

/obj/item/rig_module/device/anomaly_scanner
	name = "hardsuit anomaly scanner"
	desc = "You think it's called an Elder Sarsparilla or something."
	icon_state = "eldersasparilla"
	interface_name = "Alden-Saraspova counter"
	interface_desc = "An exotic particle detector commonly used by xenoarchaeologists."
	engage_string = "Begin Scan"
	usable = 1
	selectable = 0
	device_type = /obj/item/device/ano_scanner
	spawn_tags = SPAWN_TAG_RIG_MODULE_COMMON


/obj/item/rig_module/device/orescanner
	name = "ore scanner module"
	desc = "A clunky old ore scanner."
	icon_state = "scanner"
	interface_name = "ore detector"
	interface_desc = "A sonar system for detecting large masses of ore."
	engage_string = "Begin Scan"
	usable = 1
	selectable = 0
	device_type = /obj/item/device/scanner/mining
	spawn_tags = SPAWN_TAG_RIG_MODULE_COMMON


/obj/item/rig_module/device/rcd
	name = "RCD mount"
	desc = "A cell-powered rapid construction device for a hardsuit."
	icon_state = "rcd"
	interface_name = "mounted RCD"
	interface_desc = "A device for building or removing walls. Cell-powered."
	usable = 1
	engage_string = "Configure RCD"

	device_type = /obj/item/weapon/rcd/mounted
	rarity_value = 20

/obj/item/rig_module/device/New()
	..()
	if(device_type) device = new device_type(src)

/obj/item/rig_module/device/engage(atom/target)
	if(!..() || !device)
		return 0

	if(!target)
		device.attack_self(holder.wearer)
		return 1

	var/turf/T = get_turf(target)
	if(istype(T) && !T.Adjacent(get_turf(src)))
		return 0

	var/resolved = target.attackby(device,holder.wearer)
	if(!resolved && device && target)
		device.afterattack(target,holder.wearer,1)
	return 1



/obj/item/rig_module/chem_dispenser
	name = "mounted chemical dispenser"
	desc = "A complex web of tubing and needles suitable for hardsuit use."
	icon_state = "injector"
	usable = 1
	selectable = 0
	toggleable = 0
	disruptive = 0


	engage_string = "Inject"

	interface_name = "integrated chemical dispenser"
	interface_desc = "Dispenses loaded chemicals directly into the wearer's bloodstream."

	charges = list(
		list("tricordrazine", "tricordrazine", 0, 80),
		list("tramadol",      "tramadol",      0, 80),
		list("dexalin plus",  "dexalinp",      0, 80),
		list("antibiotics",   "spaceacillin",  0, 80),
		list("antitoxins",    "anti_toxin",    0, 80),
		list("nutrients",     "glucose",     0, 80),
		list("hyronalin",     "hyronalin",     0, 80),
		list("radium",        "radium",        0, 80)
		)

	rarity_value = 12.5
	var/max_reagent_volume = 80 //Used when refilling.

/obj/item/rig_module/chem_dispenser/ninja
	interface_desc = "Dispenses loaded chemicals directly into the wearer's bloodstream. This variant is made to be extremely light and flexible."

	//just over a syringe worth of each. Want more? Go refill. Gives the ninja another reason to have to show their face.
	charges = list(
		list("tricordrazine", "tricordrazine", 0, 20),
		list("tramadol",      "tramadol",      0, 20),
		list("dexalin plus",  "dexalinp",      0, 20),
		list("antibiotics",   "spaceacillin",  0, 20),
		list("antitoxins",    "anti_toxin",    0, 20),
		list("nutrients",     "glucose",     0, 80),
		list("hyronalin",     "hyronalin",     0, 20),
		list("radium",        "radium",        0, 20)
		)
	rarity_value = 5
	spawn_tags = SPAWN_TAG_RIG_MODULE_COMMON

/obj/item/rig_module/chem_dispenser/accepts_item(var/obj/item/input_item, var/mob/living/user)

	if(!input_item.is_drainable())
		return 0

	if(!input_item.reagents || !input_item.reagents.total_volume)
		to_chat(user, "\The [input_item] is empty.")
		return 0

	// Magical chemical filtration system, do not question it.
	var/total_transferred = 0
	for(var/datum/reagent/R in input_item.reagents.reagent_list)
		for(var/chargetype in charges)
			var/datum/rig_charge/charge = charges[chargetype]
			if(charge.display_name == R.id)

				var/chems_to_transfer = R.volume

				if((charge.charges + chems_to_transfer) > max_reagent_volume)
					chems_to_transfer = max_reagent_volume - charge.charges

				charge.charges += chems_to_transfer
				input_item.reagents.remove_reagent(R.id, chems_to_transfer)
				total_transferred += chems_to_transfer

				break

	if(total_transferred)
		to_chat(user, "<font color='blue'>You transfer [total_transferred] units into the suit reservoir.</font>")
	else
		to_chat(user, SPAN_DANGER("None of the reagents seem suitable."))
	return 1

/obj/item/rig_module/chem_dispenser/engage(atom/target)

	if(!..())
		return 0

	var/mob/living/carbon/human/H = holder.wearer

	if(!charge_selected)
		to_chat(H, SPAN_DANGER("You have not selected a chemical type."))
		return 0

	var/datum/rig_charge/charge = charges[charge_selected]

	if(!charge)
		return 0

	var/chems_to_use = 5
	if(charge.charges <= 0)
		to_chat(H, SPAN_DANGER("Insufficient chems!"))
		return 0
	else if(charge.charges < chems_to_use)
		chems_to_use = charge.charges

	var/mob/living/carbon/target_mob
	if(target)
		if(iscarbon(target))
			target_mob = target
		else
			return 0
	else
		target_mob = H

	if(target_mob != H)
		to_chat(H, SPAN_DANGER("You inject [target_mob] with [chems_to_use] unit\s of [charge.display_name]."))
	to_chat(target_mob, "<span class='danger'>You feel a rushing in your veins as [chems_to_use] unit\s of [charge.display_name] [chems_to_use == 1 ? "is" : "are"] injected.</span>")
	target_mob.reagents.add_reagent(charge.display_name, chems_to_use)

	charge.charges -= chems_to_use
	if(charge.charges < 0) charge.charges = 0

	return 1

/obj/item/rig_module/chem_dispenser/combat
	name = "combat chemical injector"
	desc = "A complex web of tubing and needles suitable for hardsuit use."

	charges = list(
		list("synaptizine",   "synaptizine",   0, 30),
		list("hyperzine",     "hyperzine",     0, 30),
		list("oxycodone",     "oxycodone",     0, 30),
		list("nutrients",     "glucose",     0, 80),
		)

	interface_name = "combat chem dispenser"
	interface_desc = "Dispenses loaded chemicals directly into the bloodstream."
	rarity_value = 12.5

/obj/item/rig_module/chem_dispenser/injector
	name = "mounted chemical injector"
	desc = "A complex web of tubing and a large needle suitable for hardsuit use."
	usable = 0
	selectable = 1
	disruptive = 1

	interface_name = "mounted chem injector"
	interface_desc = "Dispenses loaded chemicals via an arm-mounted injector."
	rarity_value = 20

/obj/item/rig_module/voice
	name = "hardsuit voice synthesiser"
	desc = "A speaker box and sound processor."
	icon_state = "megaphone"
	usable = 1
	selectable = 0
	toggleable = 0
	disruptive = 0


	engage_string = "Configure Synthesiser"

	interface_name = "voice synthesiser"
	interface_desc = "A flexible and powerful voice modulator system."
	rarity_value = 5
	var/obj/item/voice_changer/voice_holder

/obj/item/rig_module/voice/New()
	..()
	voice_holder = new(src)
	voice_holder.active = 0

/obj/item/rig_module/voice/installed()
	..()
	holder.speech = src

/obj/item/rig_module/voice/engage()

	if(!..())
		return 0

	var/choice= input("Would you like to toggle the synthesiser or set the name?") as null|anything in list("Enable","Disable","Set Name")

	if(!choice)
		return 0

	switch(choice)
		if("Enable")
			active = 1
			voice_holder.active = 1
			to_chat(usr, "<font color='blue'>You enable the speech synthesiser.</font>")
		if("Disable")
			active = 0
			voice_holder.active = 0
			to_chat(usr, "<font color='blue'>You disable the speech synthesiser.</font>")
		if("Set Name")
			var/raw_choice = sanitize(input(usr, "Please enter a new name.")  as text|null, MAX_NAME_LEN)
			if(!raw_choice)
				return 0
			voice_holder.voice = raw_choice
			to_chat(usr, "<font color='blue'>You are now mimicking <B>[voice_holder.voice]</B>.</font>")
	return 1

/obj/item/rig_module/maneuvering_jets
	name = "hardsuit maneuvering jets"
	desc = "A compact gas thruster system for a hardsuit."
	icon_state = "thrusters"
	usable = 1
	toggleable = 1
	selectable = 0
	disruptive = 0


	suit_overlay_active = "maneuvering_active"
	suit_overlay_inactive = null //"maneuvering_inactive"

	engage_string = "Toggle Stabilizers"
	activate_string = "Activate Thrusters"
	deactivate_string = "Deactivate Thrusters"

	interface_name = "maneuvering jets"
	interface_desc = "An inbuilt EVA maneuvering system that runs off the rig air supply."
	rarity_value = 2
	spawn_tags = SPAWN_TAG_RIG_MODULE_COMMON
	var/obj/item/weapon/tank/jetpack/rig/jets

/obj/item/rig_module/maneuvering_jets/engage()
	if(!..())
		return 0
	jets.toggle_rockets()
	return 1

/obj/item/rig_module/maneuvering_jets/activate()

	if(active)
		return 0

	active = 1

	spawn(1)
		if(suit_overlay_active)
			suit_overlay = suit_overlay_active
		else
			suit_overlay = null
		holder.update_icon()

	if(!jets.on)
		jets.toggle()
	return 1

/obj/item/rig_module/maneuvering_jets/deactivate()
	if(!..())
		return 0
	if(jets.on)
		jets.toggle()
	return 1

/obj/item/rig_module/maneuvering_jets/Initialize()
	. = ..()
	jets = new(src)

//Some slightly complex setup here to make hardsuit jetpacks work right
/obj/item/rig_module/maneuvering_jets/installed()
	..()
	//Holder is the rig core module, the thing the user is wearing
	jets.holder = holder

	//We set the jetpack's gastank to the core's internal airtank.
	//So the jetpack isn't really a tank but more of a pressure valve for another tank
	jets.gastank = holder.air_supply

	//Sets up the trail fx to track movement of the core module, and thusly the user
	jets.trail.set_up(holder)

	//Tells the trail that its jetpack isn't the core module, but the jets
	jets.trail.jetpack = jets

/obj/item/rig_module/maneuvering_jets/uninstalled()
	..()
	jets.holder = null
	jets.trail.set_up(jets)

/obj/item/rig_module/autodoc
	name = "autodoc module"
	desc = "A complex surgery system for almost all your needs."
	use_power_cost = 10
	active = 1
	usable = 1

	interface_name = "Autodoc"
	interface_desc = "Module with set of instruments that is capable to preform surgery on user"
	var/datum/autodoc/autodoc_processor
	var/autodoc_type = /datum/autodoc
	var/turf/wearer_loc

/obj/item/rig_module/autodoc/Initialize()
	. = ..()
	autodoc_processor = new autodoc_type(src)
	autodoc_processor.damage_heal_amount = 20

/obj/item/rig_module/autodoc/Destroy()
	QDEL_NULL(autodoc_processor)
	return ..()

/obj/item/rig_module/autodoc/engage()
	if(!..())
		return 0
	if(autodoc_processor.active)
		autodoc_processor.stop()
	autodoc_processor.set_patient(holder.wearer)
	nano_ui_interact(usr)
	return 1
/obj/item/rig_module/autodoc/Topic(href, href_list)
	return autodoc_processor.Topic(href, href_list)

/obj/item/rig_module/autodoc/Process()
	if(..())
		autodoc_processor.stop()
	if(autodoc_processor.active)
		if(wearer_loc == null)
			wearer_loc = get_turf(holder.wearer)
		if(wearer_loc != get_turf(holder.wearer))
			autodoc_processor.fail()
		passive_power_cost = 5
		engage_string = "Abort operations"
	else
		engage_string = "Interact"
		passive_power_cost = 0
		wearer_loc = null

/obj/item/rig_module/autodoc/nano_ui_interact(mob/user, ui_key, datum/nanoui/ui, force_open, datum/nanoui/master_ui, datum/topic_state/state = GLOB.deep_inventory_state)
	autodoc_processor.nano_ui_interact(user, ui_key, ui, force_open, state = GLOB.deep_inventory_state)
/obj/item/rig_module/autodoc/activate()
	return
/obj/item/rig_module/autodoc/deactivate()
	return

/obj/item/rig_module/autodoc/commercial
	autodoc_type = /datum/autodoc/capitalist_autodoc

/obj/item/rig_module/cape
	name = "cape"
	desc = "A cape designed to be attached to hardsuits."

	interface_name = "Hardsuit Cape"
	interface_desc = "A generic cape for a hardsuit."
	rarity_value = 80

/obj/item/rig_module/cape/te
	name = "technomancer cape"
	desc = "A tough regal cape, imprinted with the emblem of the Technomancer League."
	suit_overlay_active = "cape_te"
	suit_overlay_inactive = "cape_te"
	suit_overlay_mob_only = 1

	interface_name = "Technomancer Cape"
	interface_desc = "A grand yet hardy cape."
	rarity_value = 100

var/global/list/robot_modules = list(
	"Standard"		= /obj/item/robot_module/standard,
	"Service" 		= /obj/item/robot_module/service,
	"Research" 		= /obj/item/robot_module/research,
	"Miner" 		= /obj/item/robot_module/miner,
	"Rescue" 		= /obj/item/robot_module/medical/rescue,
	"Medical" 		= /obj/item/robot_module/medical/general,
	"Security" 		= /obj/item/robot_module/security/general,
	"Engineering"	= /obj/item/robot_module/engineering/general,
	"Construction"	= /obj/item/robot_module/engineering/construction,
	"Custodial" 	= /obj/item/robot_module/custodial
	//"Combat" 		= /obj/item/robot_module/combat,
	)

/obj/item/robot_module
	name = "robot module"
	desc = "This is a robot module parent class. You shouldn't see this description"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_module"
	w_class = 100
	item_state = "electronic"
	flags = CONDUCT
	bad_type = /obj/item/robot_module
	var/hide_on_manifest = FALSE
	var/channels = list()
	var/networks = list()
	var/languages = list(							//Any listed language will be understandable. Any set to 1 will be speakable
					LANGUAGE_SOL_COMMON = 1,
					LANGUAGE_TRADEBAND = 1,
					LANGUAGE_UNATHI = 0,
					LANGUAGE_SIIK_MAAS = 0,
					LANGUAGE_SKRELLIAN = 0,
					LANGUAGE_GUTTER = 1,
					LANGUAGE_VAURCESE = 0,
					LANGUAGE_ROOTSONG = 0,
					LANGUAGE_SIGN = 0,
					LANGUAGE_SIGN_TAJARA = 0,
					LANGUAGE_SIIK_TAJR = 0,
					LANGUAGE_AZAZIBA = 0
					)
	var/sprites = list()
	var/can_be_pushed = 1
	var/no_slip = 0
	var/list/modules = list()
	var/list/datum/matter_synth/synths = list()
	var/obj/item/emag
	var/obj/item/malfAImodule
	var/obj/item/borg/upgrade/jetpack
	var/list/subsystems = list()
	var/list/obj/item/borg/upgrade/supported_upgrades = list()

	// Bookkeeping
	var/list/original_languages = list()
	var/list/added_networks = list()

	//Module stats, these are applied to the robot
	health = 200 //Max health. Apparently this is already defined in item.dm
	var/speed_factor = 1 //Speed factor, applied as a divisor on movement delay
	var/power_efficiency = 1 //Power efficiency, applied as a divisor on power taken from the internal cell

	//Stat modifiers for skillchecks
	var/list/stat_modifiers = list(
		STAT_BIO = 5,
		STAT_COG = 5,
		STAT_ROB = 5,
		STAT_TGH = 5,
		STAT_MEC = 5
	)


/obj/item/robot_module/New(var/mob/living/silicon/robot/R)
	..()
	if(!istype(R))
		return

	R.module = src

	add_camera_networks(R)
	add_languages(R)
	add_subsystems(R)
	apply_status_flags(R)

	if(R.radio)
		R.radio.recalculateChannels()

	//Setting robot stats
	var/healthpercent = R.health / R.maxHealth //We update the health to remain at the same percentage it was before
	R.maxHealth = health
	R.health = R.maxHealth * healthpercent

	R.speed_factor = speed_factor
	R.power_efficiency = power_efficiency

	for(var/name in stat_modifiers)
		R.stats.changeStat(name, stat_modifiers[name])

	R.set_module_sprites(sprites)
	R.icon_selected = 0
	spawn()
		R.choose_icon() //Choose icon recurses and blocks new from completing, so spawn it off


/obj/item/robot_module/Initialize()
	. = ..()
	for(var/obj/item/I in modules)
		I.canremove = 0
		I.set_plane(ABOVE_HUD_PLANE)
		I.layer = ABOVE_HUD_LAYER

	for(var/obj/item/tool/T in modules)
		T.degradation = 0 //We don't want robot tools breaking

	//A quick hack to stop robot modules running out of power
	//Later they'll be wired to the robot's central battery once we code functionality for that
	//Setting it to infinity causes errors, so just a high number is fine
	for(var/obj/item/I in modules)
		if(!istype(I, /obj/item/gun/energy)) // Guns have their own code for drawing charge from cyborg cell
			for(var/obj/item/cell/C in I)
				C.charge = 999999999
	// I wanna make component cell holders soooo bad, but it's going to be a big refactor, and I don't have the time -- ACCount

/obj/item/robot_module/proc/Reset(var/mob/living/silicon/robot/R)
	remove_camera_networks(R)
	remove_languages(R)
	remove_subsystems(R)
	remove_status_flags(R)

	R.maxHealth = initial(R.maxHealth)
	R.speed_factor = initial(R.speed_factor)
	R.power_efficiency = initial(R.power_efficiency)
	for(var/name in stat_modifiers)
		R.stats.changeStat(name, stat_modifiers[name]*-1)

	if(R.radio)
		R.radio.recalculateChannels()
	R.set_module_sprites(list("Default" = "robot"))
	R.icon_selected = 0
	R.choose_icon()

/obj/item/robot_module/Destroy()
	QDEL_NULL_LIST(modules)
	QDEL_NULL_LIST(synths)
	qdel(emag)
	qdel(jetpack)
	qdel(malfAImodule)
	emag = null
	malfAImodule = null
	jetpack = null
	return ..()

/obj/item/robot_module/emp_act(severity)
	if(modules)
		for(var/obj/O in modules)
			O.emp_act(severity)
	if(emag)
		emag.emp_act(severity)
	if(synths)
		for(var/datum/matter_synth/S in synths)
			S.emp_act(severity)
	..()
	return

/obj/item/robot_module/proc/respawn_consumable(mob/living/silicon/robot/R, var/rate)
	var/obj/item/device/flash/F = locate() in src.modules
	if(F)
		if(F.broken)
			F.broken = 0
			F.times_used = 0
			F.icon_state = "flash"
		else if(F.times_used)
			F.times_used--

	if(!synths || !synths.len)
		return

	for(var/datum/matter_synth/T in synths)
		T.add_charge(T.recharge_rate * rate)

/obj/item/robot_module/proc/rebuild()//Rebuilds the list so it's possible to add/remove items from the module
	var/list/temp_list = modules
	modules = list()
	for(var/obj/O in temp_list)
		if(O)
			modules += O

/obj/item/robot_module/proc/add_languages(var/mob/living/silicon/robot/R)
	// Stores the languages as they were before receiving the module, and whether they could be synthezized.
	for(var/datum/language/language_datum in R.languages)
		original_languages[language_datum] = (language_datum in R.speech_synthesizer_langs)

	for(var/language in languages)
		R.add_language(language, languages[language])

/obj/item/robot_module/proc/remove_languages(var/mob/living/silicon/robot/R)
	// Clear all added languages, whether or not we originally had them.
	for(var/language in languages)
		R.remove_language(language)

	// Then add back all the original languages, and the relevant synthezising ability
	for(var/original_language in original_languages)
		R.add_language(original_language, original_languages[original_language])
	original_languages.Cut()

/obj/item/robot_module/proc/add_camera_networks(var/mob/living/silicon/robot/R)
	if(R.camera && (NETWORK_ROBOTS in R.camera.network))
		for(var/network in networks)
			if(!(network in R.camera.network))
				R.camera.add_network(network)
				added_networks |= network

/obj/item/robot_module/proc/remove_camera_networks(var/mob/living/silicon/robot/R)
	if(R.camera)
		R.camera.remove_networks(added_networks)
	added_networks.Cut()

/obj/item/robot_module/proc/add_subsystems(var/mob/living/silicon/robot/R)
	for(var/subsystem_type in subsystems)
		R.init_subsystem(subsystem_type)

/obj/item/robot_module/proc/remove_subsystems(var/mob/living/silicon/robot/R)
	for(var/subsystem_type in subsystems)
		R.remove_subsystem(subsystem_type)

/obj/item/robot_module/proc/apply_status_flags(var/mob/living/silicon/robot/R)
	if(!can_be_pushed)
		R.status_flags &= ~CANPUSH

/obj/item/robot_module/proc/remove_status_flags(var/mob/living/silicon/robot/R)
	if(!can_be_pushed)
		R.status_flags |= CANPUSH


//The generic robot, a good choice for any situation. Moderately good at everything
/obj/item/robot_module/standard
	name = "standard robot module"
	sprites = list(	"Basic" = "robot",
					"Android" = "droid",
					"Default" = "robot_old",
					"Sleek" = "sleekstandard",
					"Drone" = "drone-standard",
					"Spider" = "spider"
				  )

	desc = "The baseline, jack of all trades. Can do a little of everything. Some DIY, some healing, some combat."
	stat_modifiers = list(
		STAT_BIO = 15,
		STAT_COG = 15,
		STAT_ROB = 15,
		STAT_TGH = 15,
		STAT_MEC = 15
	)


/obj/item/robot_module/standard/New(var/mob/living/silicon/robot/R)

	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/melee/baton(src)
	src.modules += new /obj/item/extinguisher(src)
	src.modules += new /obj/item/tool/wrench/robotic(src)
	src.modules += new /obj/item/tool/crowbar/robotic(src)
	src.modules += new /obj/item/device/scanner/health(src)
	src.modules += new /obj/item/gripper(src)
	src.modules += new /obj/item/device/t_scanner(src)
	src.emag = new /obj/item/melee/energy/sword(src)

	var/datum/matter_synth/medicine = new /datum/matter_synth/medicine(10000)
	synths += medicine

	//Comes with bandages and ointment, the basic/weak versions only
	var/obj/item/stack/medical/bruise_pack/B = new /obj/item/stack/medical/bruise_pack(src)
	var/obj/item/stack/medical/ointment/O = new /obj/item/stack/medical/ointment(src)
	B.uses_charge = 1
	B.charge_costs = list(1000)
	B.synths = list(medicine)
	O.uses_charge = 1
	O.charge_costs = list(1000)
	O.synths = list(medicine)
	src.modules += B
	src.modules += O
	..(R)

/obj/item/robot_module/medical
	name = "medical robot module"
	channels = list("Medical" = 1)
	networks = list(NETWORK_MEDICAL)

	can_be_pushed = 0
	sprites = list(
				"Basic" = "robotmedi",
				"Classic" = "medbot",
				"Heavy" = "heavymed",
				"Needles" = "medicalrobot",
				"Standard" = "surgeon",
				"Advanced Droid - Medical" = "droid-medical",
				"Advanced Droid - Chemistry" = "droid-chemistry",
				"Drone - Medical" = "drone-surgery",
				"Drone - Chemistry" = "drone-chemistry",
				"Sleek - Medical" = "sleekmedic",
				"Sleek - Chemistry" = "sleekchemistry"
				)

	desc = "A versatile medical droid, equipped with all the tools necessary for surgery, chemistry, and \
	 general patient treatments. Medical has a vast array of items, but this comes at a hefty cost. \
	 The medical module is essentially shackled to the medbay and can't afford to stray too far. \
	 Its low power efficiency means it needs to charge regularly"

/obj/item/robot_module/medical/general
	name = "medical robot module"
	health = 140 //Fragile
	speed_factor = 0.8 //Kinda slow
	power_efficiency = 0.6 //Very poor, shackled to a charger

	stat_modifiers = list(
		STAT_BIO = 40,
		STAT_COG = 10
	)

/obj/item/robot_module/medical/general/New(var/mob/living/silicon/robot/R)
	src.modules += new /obj/item/tool/crowbar/robotic(src)
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/borg/sight/hud/med(src)
	src.modules += new /obj/item/device/scanner/health(src)
	src.modules += new /obj/item/reagent_containers/borghypo/medical(src)
	src.modules += new /obj/item/tool/scalpel(src)
	src.modules += new /obj/item/tool/hemostat(src)
	src.modules += new /obj/item/tool/retractor(src)
	src.modules += new /obj/item/tool/cautery(src)
	src.modules += new /obj/item/tool/bonesetter(src)
	src.modules += new /obj/item/tool/saw/circular(src)
	src.modules += new /obj/item/tool/surgicaldrill(src)
	src.modules += new /obj/item/gripper/chemistry(src)
	src.modules += new /obj/item/reagent_containers/dropper/industrial(src)
	src.modules += new /obj/item/reagent_containers/syringe(src)
	src.modules += new /obj/item/device/scanner/reagent/adv(src)
	src.modules += new /obj/item/autopsy_scanner(src) // an autopsy scanner
	src.emag = new /obj/item/reagent_containers/spray(src)
	src.emag.reagents.add_reagent("pacid", 250)
	src.emag.name = "Polyacid spray"

	var/datum/matter_synth/medicine = new /datum/matter_synth/medicine(10000)
	synths += medicine

	var/obj/item/stack/nanopaste/N = new /obj/item/stack/nanopaste(src)
	var/obj/item/stack/medical/advanced/bruise_pack/B = new /obj/item/stack/medical/advanced/bruise_pack(src)
	var/obj/item/stack/medical/advanced/ointment/O = new /obj/item/stack/medical/advanced/ointment(src)
	N.uses_charge = 1
	N.charge_costs = list(1000)
	N.synths = list(medicine)
	B.uses_charge = 1
	B.charge_costs = list(1000)
	B.synths = list(medicine)
	O.uses_charge = 1
	O.charge_costs = list(1000)
	O.synths = list(medicine)
	src.modules += N
	src.modules += B
	src.modules += O

	var/obj/item/stack/medical/splint/S = new /obj/item/stack/medical/splint(src)
	S.uses_charge = 1
	S.charge_costs = list(1000)
	S.synths = list(medicine)
	src.modules += S

	..(R)


/obj/item/robot_module/medical/general/respawn_consumable(mob/living/silicon/robot/R, var/amount)
	var/obj/item/reagent_containers/syringe/S = locate() in src.modules
	if(S.mode == 2)
		S.reagents.clear_reagents()
		S.mode = initial(S.mode)
		S.desc = initial(S.desc)
		S.update_icon()

	if(src.emag)
		var/obj/item/reagent_containers/spray/PS = src.emag
		PS.reagents.add_reagent("pacid", 2 * amount)
	..()

/obj/item/robot_module/medical/rescue
	name = "rescue robot module"
	sprites = list(
			"Basic" = "robotmedi",
			"Classic" = "medbot",
			"Standard" = "surgeon",
			"Advanced Droid" = "droid-rescue",
			"Sleek" = "sleekrescue",
			"Needles" = "medicalrobot",
			"Drone" = "drone-medical",
			"Heavy" = "heavymed"
			)

	//Rescue module has built in crew monitor
	//General medical does not, they're expected to stay in medbay and use the computers
	subsystems = list(/datum/nano_module/crew_monitor)


	health = 270 //Tough
	speed_factor = 1.3 //Turbospeed!
	power_efficiency = 1.2 //Good for long journeys

	stat_modifiers = list(
		STAT_BIO = 20,
		STAT_ROB = 10,
		STAT_TGH = 10
	)

	desc = "The rescue borg fills the role of paramedic. \
	Fearlessly venturing out into danger in order to pick up the wounded, stabilise them and bring \
	them home. It has a relatively small toolset, mostly gear for getting where it needs to go and \
	finding its way around. This streamlined design allows it to be the fastest of all droid modules."



//TODO: Give the rescue module some kind of powerful melee weapon to use as a breaching tool.
//Possibly a robot equivilant of the fire axe
/obj/item/robot_module/medical/rescue/New(var/mob/living/silicon/robot/R)
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/borg/sight/hud/med(src)
	src.modules += new /obj/item/device/scanner/health(src)
	src.modules += new /obj/item/tool/crowbar/robotic(src)
	src.modules += new /obj/item/roller_holder(src)
	src.modules += new /obj/item/hatton/robot(src)
	src.modules += new /obj/item/reagent_containers/borghypo/rescue(src)
	src.modules += new /obj/item/reagent_containers/syringe(src)
	src.modules += new /obj/item/extinguisher/mini(src)
	src.modules += new /obj/item/inflatable_dispenser(src) // Allows usage of inflatables. Since they are basically robotic alternative to EMTs, they should probably have them.
	src.modules += new /obj/item/device/gps(src) // for coordinating with medical suit health sensors console
	src.emag = new /obj/item/reagent_containers/spray(src)
	src.emag.reagents.add_reagent("pacid", 250)
	src.emag.name = "Polyacid spray"

	var/datum/matter_synth/medicine = new /datum/matter_synth/medicine(15000)
	synths += medicine

	var/obj/item/stack/medical/advanced/bruise_pack/B = new /obj/item/stack/medical/advanced/bruise_pack(src)
	var/obj/item/stack/medical/advanced/ointment/O = new /obj/item/stack/medical/advanced/ointment(src)
	B.uses_charge = 1
	B.charge_costs = list(1000)
	B.synths = list(medicine)
	O.uses_charge = 1
	O.charge_costs = list(1000)
	O.synths = list(medicine)
	src.modules += B
	src.modules += O

	var/obj/item/stack/medical/splint/S = new /obj/item/stack/medical/splint(src)
	S.uses_charge = 1
	S.charge_costs = list(1000)
	S.synths = list(medicine)
	src.modules += S

	..(R)

/obj/item/robot_module/medical/rescue/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	var/obj/item/reagent_containers/syringe/S = locate() in src.modules
	if(S.mode == 2)
		S.reagents.clear_reagents()
		S.mode = initial(S.mode)
		S.desc = initial(S.desc)
		S.update_icon()

	if(src.emag)
		var/obj/item/reagent_containers/spray/PS = src.emag
		PS.reagents.add_reagent("pacid", 2 * amount)

	..()


/obj/item/robot_module/engineering
	name = "engineering robot module"
	channels = list("Engineering" = 1)
	networks = list(NETWORK_ENGINEERING)
	subsystems = list(/datum/nano_module/power_monitor)
	sprites = list(
					"Basic" = "robotengi",
					"Antique" = "engineerrobot",
					"Landmate" = "landmate",
					"Landmate - Treaded" = "engiborg+tread",
					"Drone" = "drone-engineer",
					"Android" = "droid",
					"Classic" = "engineering",
					"Sleek" = "sleekengineer",
					"Spider" = "spidereng",
					"Plated" = "ceborg",
					"Heavy" = "heavyeng"
					)
	health = 240 //Slightly above average
	speed_factor = 1.1 //Slightly above average
	power_efficiency = 0.9 //Slightly below average

	desc = "The engineering module is designed for setting up and maintaining core ship systems, \
	as well as occasional repair work here and there. It's a good all rounder that can serve most \
	engineering tasks."

	stat_modifiers = list(
		STAT_COG = 20,
		STAT_MEC = 40
	)

/obj/item/robot_module/engineering/construction
	name = "construction robot module"
	no_slip = 1
	health = 270 //tough
	speed_factor = 0.65 //Very slow!
	power_efficiency = 1.3 //Good for the long haul

	desc = "The construction module is a ponderous, overgeared monstrosity, huge and bulky. \
	Designed for constructing new ship sections or repairing major damage, it is equipped for long \
	journeys through maintenance or around the hull. The heavy chassis and power system comes at a great \
	toll in speed though."

/obj/item/robot_module/engineering/construction/New(var/mob/living/silicon/robot/R)
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/borg/sight/meson(src)
	src.modules += new /obj/item/extinguisher(src)
	src.modules += new /obj/item/rcd/borg(src)
	src.modules += new /obj/item/tool/screwdriver/robotic(src)
	src.modules += new /obj/item/tool/wrench/robotic(src)
	src.modules += new /obj/item/tool/crowbar/robotic(src)
	src.modules += new /obj/item/tool/weldingtool/robotic(src)
	src.modules += new /obj/item/tool/wirecutters/robotic(src)
	src.modules += new /obj/item/tool/multitool/robotic(src)
	src.modules += new /obj/item/device/pipe_painter(src)
	src.modules += new /obj/item/gripper/no_use/loader(src)
	src.modules += new /obj/item/gripper(src)
	src.modules += new /obj/item/device/t_scanner(src) // to check underfloor wiring
	src.modules += new /obj/item/device/scanner/gas(src) // to check air pressure in the area
	src.modules += new /obj/item/device/lightreplacer(src) // to install lightning in the area
	src.modules += new /obj/item/device/floor_painter(src)// to make america great again (c)
	src.modules += new /obj/item/inflatable_dispenser(src) // to stop those pesky human beings entering the zone
	src.modules += new /obj/item/rpd/borg(src) //to allow for easier access to pipes
	src.modules += new /obj/item/tool/pickaxe/drill(src)
	src.modules += new /obj/item/hatton/robot(src)
	//src.emag = new /obj/item/gun/energy/plasmacutter/mounted(src)
	//src.malfAImodule += new /obj/item/rtf(src) //We don't have these features

	var/datum/matter_synth/metal = new /datum/matter_synth/metal(80000)
	var/datum/matter_synth/plasteel = new /datum/matter_synth/plasteel(40000)
	var/datum/matter_synth/glass = new /datum/matter_synth/glass(60000)
	var/datum/matter_synth/wire = new /datum/matter_synth/wire(60)
	synths += metal
	synths += plasteel
	synths += glass
	synths += wire

	var/obj/item/stack/material/cyborg/steel/M = new (src)
	M.synths = list(metal)
	src.modules += M

	var/obj/item/stack/material/cyborg/glass/G = new (src)
	G.synths = list(glass)
	src.modules += G

	var/obj/item/stack/rods/cyborg/Ro = new /obj/item/stack/rods/cyborg(src)
	Ro.synths = list(metal)
	src.modules += Ro

	var/obj/item/stack/material/cyborg/plasteel/S = new (src)
	S.synths = list(plasteel)
	src.modules += S

	var/obj/item/stack/material/cyborg/glass/reinforced/RG = new (src)
	RG.synths = list(metal, glass)
	src.modules += RG

	var/obj/item/stack/tile/floor/cyborg/FT = new /obj/item/stack/tile/floor/cyborg(src) // to add floor over the metal rods lattice
	FT.synths = list(metal)
	src.modules += FT

	var/obj/item/stack/cable_coil/cyborg/C = new /obj/item/stack/cable_coil/cyborg(src) // Let there be light electric said and after that did cut the wire
	C.synths = list(wire)
	src.modules += C

	..(R)

/obj/item/robot_module/engineering/general/New(var/mob/living/silicon/robot/R)
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/borg/sight/meson(src)
	src.modules += new /obj/item/extinguisher(src)
	src.modules += new /obj/item/tool/weldingtool/robotic(src)
	src.modules += new /obj/item/tool/screwdriver/robotic(src)
	src.modules += new /obj/item/tool/wrench/robotic(src)
	src.modules += new /obj/item/tool/crowbar/robotic(src)
	src.modules += new /obj/item/tool/wirecutters/robotic(src)
	src.modules += new /obj/item/tool/multitool/robotic(src)
	src.modules += new /obj/item/device/t_scanner(src)
	src.modules += new /obj/item/device/scanner/gas(src)
	src.modules += new /obj/item/taperoll/engineering(src)
	src.modules += new /obj/item/gripper(src)
	src.modules += new /obj/item/gripper/no_use/loader(src)
	src.modules += new /obj/item/device/lightreplacer(src)
	src.modules += new /obj/item/device/pipe_painter(src)
	src.modules += new /obj/item/device/floor_painter(src)
	src.modules += new /obj/item/inflatable_dispenser(src)
	src.modules += new /obj/item/rpd/borg(src)
	src.emag = new /obj/item/melee/baton(src)

	var/datum/matter_synth/metal = new /datum/matter_synth/metal(60000)
	var/datum/matter_synth/glass = new /datum/matter_synth/glass(40000)
	var/datum/matter_synth/plasteel = new /datum/matter_synth/plasteel(20000)
	var/datum/matter_synth/wire = new /datum/matter_synth/wire(45)
	var/datum/matter_synth/wood = new /datum/matter_synth/wood(20000)
	var/datum/matter_synth/plastic = new /datum/matter_synth/plastic(15000)
	synths += metal
	synths += glass
	synths += plasteel
	synths += wire
	synths += wood
	synths += plastic

	var/obj/item/matter_decompiler/MD = new /obj/item/matter_decompiler(src)
	MD.metal = metal
	MD.glass = glass
	src.modules += MD

	var/obj/item/stack/material/cyborg/steel/M = new (src)
	M.synths = list(metal)
	src.modules += M

	var/obj/item/stack/material/cyborg/glass/G = new (src)
	G.synths = list(glass)
	src.modules += G

	var/obj/item/stack/rods/cyborg/Ro = new /obj/item/stack/rods/cyborg(src)
	Ro.synths = list(metal)
	src.modules += Ro

	var/obj/item/stack/cable_coil/cyborg/C = new /obj/item/stack/cable_coil/cyborg(src)
	C.synths = list(wire)
	src.modules += C

	var/obj/item/stack/tile/floor/cyborg/S = new /obj/item/stack/tile/floor/cyborg(src)
	S.synths = list(metal)
	src.modules += S

	var/obj/item/stack/material/cyborg/glass/reinforced/RG = new (src)
	RG.synths = list(metal, glass)
	src.modules += RG

	var/obj/item/stack/material/cyborg/plasteel/PL = new (src)
	PL.synths = list(plasteel)
	src.modules += PL

	var/obj/item/stack/material/cyborg/wood/W = new (src)
	W.synths = list(wood)
	src.modules += W

	var/obj/item/stack/material/cyborg/plastic/PS = new (src)
	PS.synths = list(plastic)
	src.modules += PS

	var/obj/item/stack/tile/wood/cyborg/FWT = new (src)
	FWT.synths = list(wood)
	src.modules += FWT

	..(R)


	//TODO: Insert appropriate tiles here
	//var/obj/item/stack/tile/floor_white/cyborg/FTW = new (src)
	//FTW.synths = list(plastic)
	//src.modules += FTW

	//var/obj/item/stack/tile/floor_freezer/cyborg/FTF = new (src)
	//FTF.synths = list(plastic)
	//src.modules += FTF

	//var/obj/item/stack/tile/floor_dark/cyborg/FTD = new (src)
	//FTD.synths = list(plasteel)
	//src.modules += FTD


//Possible todo: Discuss giving security module some kind of lethal ranged weapon
/obj/item/robot_module/security
	name = "security robot module"
	channels = list("Security" = 1)
	networks = list(NETWORK_SECURITY)
	can_be_pushed = 0
	supported_upgrades = list(/obj/item/borg/upgrade/tasercooler,/obj/item/borg/upgrade/jetpack)

	health = 300 //Very tanky!
	speed_factor = 0.85 //Kinda slow
	power_efficiency = 1.15 //Decent

	desc = "Focused on keeping the peace and fighting off threats to the ship, the security module is a \
	heavily armored, though lightly armed battle unit."

	stat_modifiers = list(
		STAT_ROB = 30,
		STAT_TGH = 20
	)

/obj/item/robot_module/security/general
	sprites = list(
					"Basic" = "robotsecy",
					"Sleek" = "sleeksecurity",
					"Black Knight" = "securityrobot",
					"Bloodhound" = "bloodhound",
					"Bloodhound - Treaded" = "treadhound",
					"Drone" = "drone-sec",
					"Classic" = "secborg",
					"Spider" = "spidersec",
					"Heavy" = "heavysec"
				)

/obj/item/robot_module/security/general/New(var/mob/living/silicon/robot/R)
	src.modules += new /obj/item/tool/crowbar/robotic(src)
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/borg/sight/hud/sec(src)
	src.modules += new /obj/item/handcuffs/cyborg(src)
	src.modules += new /obj/item/melee/baton/robot(src)
	src.modules += new /obj/item/gun/energy/taser/mounted/cyborg(src)
	src.modules += new /obj/item/taperoll/police(src)
	//src.modules += new /obj/item/device/holowarrant(src)
	src.modules += new /obj/item/book/manual/wiki/security_ironparagraphs(src) // book of ironhammer paragraphs
	src.emag = new /obj/item/gun/energy/laser/mounted(src)
	..(R)


/obj/item/robot_module/security/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	..()
	var/obj/item/gun/energy/taser/mounted/cyborg/T = locate() in src.modules
	if(T.cell.charge < T.cell.maxcharge)
		T.cell.give(T.charge_cost * amount)
		T.update_icon()
	else
		T.charge_tick = 0
	var/obj/item/melee/baton/robot/B = locate() in src.modules
	if(B && B.cell)
		B.cell.give(amount)

/obj/item/robot_module/custodial
	name = "custodial robot module"
	channels = list("Service" = 1)
	sprites = list(
					"Basic" = "robotjani",
					"Mopbot"  = "janitorrobot",
					"Mop Gear Rex" = "mopgearrex",
					"Drone" = "drone-janitor",
					"Classic" = "janbot2",
					"Buffer" = "mechaduster",
					"Sleek" = "sleekjanitor",
					"Maid" = "maidbot"
					)
	health = 250 //Bulky
	speed_factor = 1.0 // Normal speed, its a cleaning unit and you wouldnt choose it if you sweep floors with ultra slow movement
	power_efficiency = 0.8 //Poor

	stat_modifiers = list(
		STAT_ROB = 20
	)

	desc = "A vast machine designed for cleaning up trash and scrubbing floors. A fairly specialised task, \
	but requiring a large capacity. The huge chassis consequentially grants it a degree of toughness, \
	though it is slow and cheaply made"


/obj/item/robot_module/custodial/New(var/mob/living/silicon/robot/R)
	src.modules += new /obj/item/tool/crowbar/robotic(src)
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/gripper/service(src)
	src.modules += new /obj/item/soap/nanotrasen(src)
	src.modules += new /obj/item/storage/bag/trash/robot(src)
	src.modules += new /obj/item/mop(src)
	src.modules += new /obj/item/device/lightreplacer(src)
	src.modules += new /obj/item/reagent_containers/glass/bucket(src) // a hydroponist's bucket
	src.modules += new /obj/item/matter_decompiler(src) // free drone remains for all
	src.modules += new /obj/item/device/t_scanner(src)
	src.emag = new /obj/item/reagent_containers/spray(src)
	src.emag.reagents.add_reagent("lube", 250)
	src.emag.name = "Lube spray"



	..(R)


/obj/item/robot_module/custodial/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	..()
	var/obj/item/device/lightreplacer/LR = locate() in src.modules
	LR.Charge(R, amount)
	if(src.emag)
		var/obj/item/reagent_containers/spray/S = src.emag
		S.reagents.add_reagent("lube", 2 * amount)


/obj/item/robot_module/service
	name = "service robot module"
	channels = list("Service" = 1)
	languages = list(
					LANGUAGE_SOL_COMMON = 1,
					LANGUAGE_TRADEBAND = 1,
					LANGUAGE_UNATHI = 1,
					LANGUAGE_SIIK_MAAS = 1,
					LANGUAGE_SKRELLIAN = 1,
					LANGUAGE_GUTTER = 1,
					LANGUAGE_ROOTSONG = 1
					)

	sprites = list(	"Waitress" = "service",
					"Kent" = "toiletbot",
					"Bro" = "brobot",
					"Rich" = "maximillion",
					"Basic" = "robotserv",
					"Drone - Service" = "drone-service",
					"Drone - Hydro" = "drone-hydro",
					"Classic" = "service2",
					"Gardener" = "botany",
					"Mobile Bar" = "heavyserv",
					"Sleek" = "sleekservice",
					"Maid" = "maidbot"
				  	)

	health = 80 //Ultra fragile
	speed_factor = 1.2 //Quick
	power_efficiency = 0.8 //Inefficient

	desc = "A lightweight unit designed to serve humans directly, in housekeeping, cooking, bartending, \
	 gardening, secreterial and similar personal service roles. Their work does not necessitate any \
	 significant durability, and they are typically constructed from civilian grade plastics."


/obj/item/robot_module/service/New(var/mob/living/silicon/robot/R)
	src.modules += new /obj/item/tool/crowbar/robotic(src)
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/gripper/service(src)
	src.modules += new /obj/item/reagent_containers/glass/bucket(src)
	src.modules += new /obj/item/tool/minihoe(src)
	src.modules += new /obj/item/tool/hatchet(src)
	src.modules += new /obj/item/device/scanner/plant(src)
	src.modules += new /obj/item/storage/bag/produce(src)
	src.modules += new /obj/item/robot_harvester(src)
	src.modules += new /obj/item/material/kitchen/rollingpin(src)
	src.modules += new /obj/item/tool/knife(src)
	src.modules += new /obj/item/reagent_containers/food/condiment/enzyme(src)
	src.modules += new /obj/item/soap(src) // a cheap bar of soap
	src.modules += new /obj/item/reagent_containers/glass/rag(src) // a rag for.. yeah.. the primary tool of bartender
	src.modules += new /obj/item/pen/robopen(src)
	src.modules += new /obj/item/form_printer(src)
	src.modules += new /obj/item/gripper/paperwork(src)
	src.modules += new /obj/item/hand_labeler(src)
	src.modules += new /obj/item/tool/tape_roll(src) //allows it to place flyers
	src.modules += new /obj/item/stamp/denied(src) //why was this even a emagged item before smh
	src.modules += new /obj/item/device/synthesized_instrument/synthesizer

	var/obj/item/rsf/M = new /obj/item/rsf(src)
	M.stored_matter = 30
	src.modules += M

	src.modules += new /obj/item/reagent_containers/dropper/industrial(src)

	var/obj/item/flame/lighter/zippo/L = new /obj/item/flame/lighter/zippo(src)
	L.lit = 1
	src.modules += L

	src.modules += new /obj/item/tray/robotray(src)
	src.modules += new /obj/item/reagent_containers/borghypo/service(src)
	src.emag = new /obj/item/reagent_containers/food/drinks/bottle/small/beer(src)

	var/datum/reagents/Re = new/datum/reagents(50)
	src.emag.reagents = Re
	Re.my_atom = src.emag
	Re.add_reagent("beer2", 50)
	src.emag.name = "Mickey Finn's Special Brew"

	..(R)


/obj/item/robot_module/service/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	..()
	var/obj/item/reagent_containers/food/condiment/enzyme/E = locate() in src.modules
	E.reagents.add_reagent("enzyme", 2 * amount)
	if(src.emag)
		var/obj/item/reagent_containers/food/drinks/bottle/small/beer/B = src.emag
		B.reagents.add_reagent("beer2", 2 * amount)

/obj/item/robot_module/miner
	name = "miner robot module"
	channels = list("Supply" = 1)
	networks = list(NETWORK_MINE)
	sprites = list(
					"Basic" = "robotmine",
					"Advanced Droid" = "droid-miner",
					"Sleek" = "sleekminer",
					"Treadhead" = "miner",
					"Drone" = "drone-miner",
					"Classic" = "miner_old",
					"Heavy" = "heavymine",
					"Spider" = "spidermining"
				)
	health = 250 //Pretty tough
	speed_factor = 0.9 //meh
	power_efficiency = 1.5 //Best efficiency

	stat_modifiers = list(
		STAT_ROB = 20,
		STAT_TGH = 20
	)

	desc = "Built for digging on asteroids, excavating the ores and materials to keep the ship running, \
	this is heavy and powerful unit with a fairly singleminded purpose. It needs to withstand impacts \
	from falling boulders, and exist for long periods out on an airless rock, often far from a charging \
	port. It is built with these purposes in mind."

/obj/item/robot_module/miner/New(var/mob/living/silicon/robot/R)
	src.modules += new /obj/item/tool/crowbar/robotic(src)
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/borg/sight/material(src)
	src.modules += new /obj/item/tool/wrench/robotic(src)
	src.modules += new /obj/item/tool/screwdriver/robotic(src)
	src.modules += new /obj/item/storage/bag/ore(src)
	src.modules += new /obj/item/tool/pickaxe/drill(src)
	src.modules += new /obj/item/storage/bag/sheetsnatcher/borg(src)
	src.modules += new /obj/item/gripper/miner(src)
	src.modules += new /obj/item/device/scanner/mining(src)
	src.modules += new /obj/item/device/t_scanner(src)
	//src.emag = new /obj/item/gun/energy/plasmacutter/mounted(src)
	..(R)

/obj/item/robot_module/research
	name = "research module"
	channels = list("Science" = 1)
	networks = list(NETWORK_RESEARCH)
	sprites = list(
					"Droid" = "droid-science",
					"Drone" = "drone-science",
					"Classic" = "robotjani",
					"Sleek" = "sleekscience",
					"Heavy" = "heavysci"
					)

	health = 160 //Weak
	speed_factor = 1 //Average
	power_efficiency = 0.75 //Poor efficiency

	desc = "Built for working in a well-equipped lab, and designed to handle a wide variety of research \
	duties, this module prioritises flexibility over efficiency. Capable of working in R&D, Toxins, \
	chemistry, xenobiology and robotics."

	stat_modifiers = list(
		STAT_BIO = 30,
		STAT_COG = 40,
		STAT_MEC = 30
	)

/obj/item/robot_module/research/New(var/mob/living/silicon/robot/R)
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/portable_destructive_analyzer(src)
	src.modules += new /obj/item/gripper/research(src)
	src.modules += new /obj/item/gripper/no_use/loader(src)
	src.modules += new /obj/item/device/robotanalyzer(src)
	src.modules += new /obj/item/card/robot(src)
	src.modules += new /obj/item/tool/wrench/robotic(src)
	src.modules += new /obj/item/tool/screwdriver/robotic(src)
	src.modules += new /obj/item/tool/crowbar/robotic(src)
	src.modules += new /obj/item/tool/scalpel(src)
	src.modules += new /obj/item/tool/saw/circular(src)
	src.modules += new /obj/item/extinguisher/mini(src)
	src.modules += new /obj/item/reagent_containers/syringe(src)
	src.modules += new /obj/item/gripper/chemistry(src)
	src.modules += new /obj/item/reagent_containers/dropper/industrial(src)
	src.modules += new /obj/item/device/scanner/reagent/adv(src)
	src.modules += new /obj/item/extinguisher(src)
	src.modules += new /obj/item/storage/bag/produce(src)
	src.modules += new /obj/item/pen/robopen(src)
	src.emag = new /obj/item/hand_tele(src)

	var/datum/matter_synth/nanite = new /datum/matter_synth/nanite(10000)
	synths += nanite

	var/obj/item/stack/nanopaste/N = new /obj/item/stack/nanopaste(src)
	N.uses_charge = 1
	N.charge_costs = list(1000)
	N.synths = list(nanite)
	src.modules += N
	..(R)


//Syndicate borg is intended for summoning by traitors. Not currently implemented
/obj/item/robot_module/syndicate
	name = "syndicate robot module"
	hide_on_manifest = TRUE
	languages = list(
					LANGUAGE_SOL_COMMON = 1,
					LANGUAGE_TRADEBAND = 1,
					LANGUAGE_UNATHI = 1,
					LANGUAGE_SIIK_MAAS = 1,
					LANGUAGE_SKRELLIAN = 1,
					LANGUAGE_GUTTER = 1,
					LANGUAGE_ROOTSONG = 1
					)

	sprites = list(
					"Bloodhound" = "syndie_bloodhound",
					"Treadhound" = "syndie_treadhound",
					"Precision" = "syndi-medi",
					"Heavy" = "syndi-heavy",
					"Artillery" = "spidersyndi"
					)
	spawn_blacklisted = TRUE

/obj/item/robot_module/syndicate/New(var/mob/living/silicon/robot/R)
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/borg/sight/thermal(src)
	src.modules += new /obj/item/melee/energy/sword(src)
	//Todo, replace these with suitable weapons from eris
	//src.modules += new /obj/item/gun/energy/mountedsmg(src)
	//src.modules += new /obj/item/gun/energy/net/mounted(src)
	//src.modules += new /obj/item/gun/launcher/grenade/cyborg(src)
	src.modules += new /obj/item/tool/crowbar/robotic(src)
	//src.modules += new /obj/item/robot_emag(src)

	..(R)

//Combat module is a high grade security borg for use in emergencies.
//They have lethal weapons and shielding
//Not currently implemented, needs discussion
/obj/item/robot_module/combat
	name = "combat robot module"
	hide_on_manifest = TRUE
	channels = list("Security" = 1)
	networks = list(NETWORK_SECURITY)
	subsystems = list(/datum/nano_module/crew_monitor)
	sprites = list("Roller" = "droid-combat")
	can_be_pushed = 0

/obj/item/robot_module/combat/New(var/mob/living/silicon/robot/R)
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/borg/sight/hud/sec(src)
	src.modules += new /obj/item/gun/energy/laser/mounted(src)
	//src.modules += new /obj/item/melee/hammer/powered(src)
	src.modules += new /obj/item/borg/combat/shield(src)
	src.modules += new /obj/item/borg/combat/mobility(src)
	src.modules += new /obj/item/tool/crowbar/robotic(src)
	src.emag = new /obj/item/gun/energy/lasercannon/mounted(src)
	..(R)

/obj/item/robot_module/drone
	name = "drone module"
	hide_on_manifest = TRUE
	no_slip = 1
	networks = list(NETWORK_ENGINEERING)
	channels = list("Engineering" = 1, "Common" = 1)
	stat_modifiers = list(
		STAT_COG = 15,
		STAT_MEC = 40
	)

/obj/item/robot_module/drone/New(var/mob/living/silicon/robot/R)
	src.modules += new /obj/item/tool/weldingtool/robotic(src)
	src.modules += new /obj/item/tool/screwdriver/robotic(src)
	src.modules += new /obj/item/tool/wrench/robotic(src)
	src.modules += new /obj/item/tool/crowbar/robotic(src)
	src.modules += new /obj/item/tool/wirecutters/robotic(src)
	src.modules += new /obj/item/tool/multitool/robotic(src)
	src.modules += new /obj/item/tool/shovel/robotic(src)
	src.modules += new /obj/item/device/t_scanner(src)
	src.modules += new /obj/item/device/lightreplacer(src)
	src.modules += new /obj/item/gripper(src)
	src.modules += new /obj/item/soap(src)
	src.modules += new /obj/item/gripper/no_use/loader(src)
	src.modules += new /obj/item/extinguisher(src)
	src.modules += new /obj/item/device/pipe_painter(src)
	src.modules += new /obj/item/device/floor_painter(src)
	src.modules += new /obj/item/rpd/borg(src)
	src.modules += new /obj/item/borg/sight/meson(src)

	//src.emag = new /obj/item/gun/energy/plasmacutter/mounted(src)
	//src.emag.name = "Plasma Cutter"

	var/datum/matter_synth/metal = new /datum/matter_synth/metal(25000)
	var/datum/matter_synth/glass = new /datum/matter_synth/glass(25000)
	var/datum/matter_synth/wood = new /datum/matter_synth/wood(10000)
	var/datum/matter_synth/plastic = new /datum/matter_synth/plastic(10000)
	var/datum/matter_synth/wire = new /datum/matter_synth/wire(30)
	synths += metal
	synths += glass
	synths += wood
	synths += plastic
	synths += wire

	var/obj/item/matter_decompiler/MD = new /obj/item/matter_decompiler(src)
	MD.metal = metal
	MD.glass = glass
	MD.wood = wood
	MD.plastic = plastic
	src.modules += MD

	var/obj/item/stack/material/cyborg/steel/M = new (src)
	M.synths = list(metal)
	src.modules += M

	var/obj/item/stack/material/cyborg/glass/G = new (src)
	G.synths = list(glass)
	src.modules += G

	var/obj/item/stack/rods/cyborg/Ro = new /obj/item/stack/rods/cyborg(src)
	Ro.synths = list(metal)
	src.modules += Ro

	var/obj/item/stack/cable_coil/cyborg/C = new /obj/item/stack/cable_coil/cyborg(src)
	C.synths = list(wire)
	src.modules += C

	var/obj/item/stack/tile/floor/cyborg/S = new /obj/item/stack/tile/floor/cyborg(src)
	S.synths = list(metal)
	src.modules += S

	var/obj/item/stack/material/cyborg/glass/reinforced/RG = new (src)
	RG.synths = list(metal, glass)
	src.modules += RG

	var/obj/item/stack/tile/wood/cyborg/WT = new /obj/item/stack/tile/wood/cyborg(src)
	WT.synths = list(wood)
	src.modules += WT

	var/obj/item/stack/material/cyborg/wood/W = new (src)
	W.synths = list(wood)
	src.modules += W

	var/obj/item/stack/material/cyborg/plastic/P = new (src)
	P.synths = list(plastic)
	src.modules += P
	..(R)

/obj/item/robot_module/drone/construction
	name = "construction drone module"
	channels = list("Engineering" = 1)
	languages = list()

/obj/item/robot_module/drone/construction/New(var/mob/living/silicon/robot/R)
	src.modules += new /obj/item/rcd/borg(src)
	..(R)

/obj/item/robot_module/drone/respawn_consumable(var/mob/living/silicon/robot/R, var/amount)
	var/obj/item/device/lightreplacer/LR = locate() in src.modules
	LR.Charge(R, amount)
	..()
	return


//A borg intended to serve as an antag in itself, though generally reserved for adminspawning
//Sort of like a robot ninja
//Not currently implemented
/obj/item/robot_module/hunter_seeker
	name = "hunter seeker robot module"
	languages = list(
					LANGUAGE_SOL_COMMON = 1,
					LANGUAGE_TRADEBAND = 1,
					LANGUAGE_UNATHI = 1,
					LANGUAGE_SIIK_MAAS = 1,
					LANGUAGE_SKRELLIAN = 1,
					LANGUAGE_GUTTER = 1,
					LANGUAGE_ROOTSONG = 1,
					LANGUAGE_TERMINATOR = 1
					)

	sprites = list(
					"Hunter Seeker" = "hunter_seeker"
					)

/obj/item/robot_module/hunter_seeker/New(var/mob/living/silicon/robot/R)
	src.modules += new /obj/item/device/flash(src)
	src.modules += new /obj/item/tool/pickaxe/drill(src)
	src.modules += new /obj/item/borg/sight/thermal(src)
	src.modules += new /obj/item/tool/crowbar/robotic(src)
	src.modules += new /obj/item/tool/wrench/robotic(src)
	src.modules += new /obj/item/tool/screwdriver/robotic(src)
	src.modules += new /obj/item/tool/multitool/robotic(src)
	src.modules += new /obj/item/tool/wirecutters/robotic(src)
	src.modules += new /obj/item/tool/weldingtool/robotic(src)

	..(R)

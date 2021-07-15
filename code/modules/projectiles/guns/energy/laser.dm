/obj/item/gun/energy/laser
	name = "NT LG \"Lightfall\""
	desc = "\"NeoTheology\" brand laser carbine. Deadly and radiant, like the ire of God it represents."
	icon = 'icons/obj/guns/energy/laser.dmi'
	icon_state = "laser"
	item_state = "laser"
	item_charge_meter = TRUE
	fire_sound = 'sound/weapons/Laser.ogg'
	slot_flags = SLOT_BELT|SLOT_BACK
	w_class = ITEM_SIZE_NORMAL
	force = WEAPON_FORCE_NORMAL
	origin_tech = list(TECH_COMBAT = 3, TECH_MAGNET = 2)
	matter = list(MATERIAL_PLASTEEL = 20, MATERIAL_WOOD = 8, MATERIAL_SILVER = 5)
	zoom_factor = 0.5
	damage_multiplier = 1.3
	charge_cost = 50
	price_tag = 2500
	projectile_type = /obj/item/projectile/beam/midlaser
	init_firemodes = list(
		WEAPON_NORMAL,
		WEAPON_CHARGE
	)
	twohanded = TRUE

/obj/item/gun/energy/laser/mounted
	self_recharge = TRUE
	use_external_power = TRUE
	safety = FALSE
	restrict_safety = TRUE
	twohanded = FALSE
	zoom_factor = 0
	damage_multiplier = 1
	charge_cost = 100
	spawn_blacklisted = TRUE

/obj/item/gun/energy/laser/mounted/blitz
	name = "SDF LR \"Strahl\""
	desc = "A miniaturized laser rifle, remounted for robotic use only."
	icon_state = "laser_turret"
	charge_meter = FALSE
	zoom_factor = 0
	damage_multiplier = 1
	charge_cost = 100
	spawn_tags = null

/obj/item/gun/energy/laser/practice
	name = "NT LG \"Lightfall\" - P"
	desc = "A modified version of \"NeoTheology\" brand laser carbine, this one fires less concentrated energy bolts, designed for target practice."
	matter = list(MATERIAL_PLASTEEL = 20, MATERIAL_WOOD = 8, MATERIAL_SILVER = 2)
	price_tag = 1000
	projectile_type = /obj/item/projectile/beam/practice
	zoom_factor = 0

/obj/item/gun/energy/retro
	name = "OS LG \"Cog\""
	icon = 'icons/obj/guns/energy/retro.dmi'
	icon_state = "retro"
	item_state = "retro"
	desc = "A One Star cheaply produced laser gun. In the distant past - this was the main weapon of low-rank police forces, billions of copies of this gun were made. They are ubiquitous."
	fire_sound = 'sound/weapons/Laser.ogg'
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_NORMAL
	can_dual = TRUE
	matter = list(MATERIAL_STEEL = 10, MATERIAL_PLASTIC = 15, MATERIAL_GLASS = 5)
	projectile_type = /obj/item/projectile/beam
	fire_delay = 10 //old technology
	zoom_factor = 0
	damage_multiplier = 1
	charge_cost = 100
	price_tag = 2000
	init_firemodes = list(
		WEAPON_NORMAL,
		BURST_2_ROUND
	)
	twohanded = TRUE

/obj/item/gun/energy/captain
	name = "NT LG \"Destiny\""
	icon = 'icons/obj/guns/energy/capgun.dmi'
	icon_state = "caplaser"
	item_state = "caplaser"
	item_charge_meter = TRUE
	desc = "This weapon is old, yet still robust and reliable. It's marked with old Nanotrasen brand, a distant reminder of what this corporation was, before the Church took control of everything."
	force = WEAPON_FORCE_PAINFUL
	fire_sound = 'sound/weapons/Laser.ogg'
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	w_class = ITEM_SIZE_NORMAL
	can_dual = TRUE
	projectile_type = /obj/item/projectile/beam/midlaser
	zoom_factor = 0
	damage_multiplier = 1.2
	origin_tech = null
	self_recharge = TRUE
	charge_cost = 100
	price_tag = 4500
	init_firemodes = list(
		WEAPON_NORMAL,
		WEAPON_CHARGE
	)
	twohanded = FALSE
	spawn_blacklisted = TRUE//antag_item_targets

/obj/item/gun/energy/lasercannon
	name = "Prototype: laser cannon"
	desc = "With the laser cannon, the lasing medium is enclosed in a tube lined with uranium-235 and subjected to high neutron flux in a nuclear reactor core. This incredible technology may help YOU achieve high excitation rates with small laser volumes!"
	icon = 'icons/obj/guns/energy/lascannon.dmi'
	icon_state = "lasercannon"
	item_state = "lasercannon"
	item_charge_meter = TRUE
	fire_sound = 'sound/weapons/lasercannonfire.ogg'
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 3, TECH_POWER = 3)
	w_class = ITEM_SIZE_HUGE
	slot_flags = SLOT_BELT|SLOT_BACK
	projectile_type = /obj/item/projectile/beam/heavylaser
	charge_cost = 100
	fire_delay = 20
	zoom_factor = 0
	damage_multiplier = 1
	matter = list(MATERIAL_STEEL = 25, MATERIAL_SILVER = 4, MATERIAL_URANIUM = 1)
	price_tag = 3000
	init_firemodes = list(
		WEAPON_NORMAL
		)
	twohanded = TRUE

/obj/item/gun/energy/lasercannon/mounted
	name = "mounted laser cannon"
	self_recharge = TRUE
	use_external_power = TRUE
	recharge_time = 35
	safety = FALSE
	restrict_safety = TRUE
	twohanded = FALSE
	zoom_factor = 0
	damage_multiplier = 1
	charge_cost = 300
	spawn_blacklisted = TRUE

/obj/item/gun/energy/psychic
	icon = 'icons/obj/guns/energy/psychiccannon.dmi'
	icon_state = "psychic_lasercannon"
	item_state = "psychic_lasercannon"
	projectile_type = /obj/item/projectile/beam/psychic
	icon_contained = TRUE
	spawn_blacklisted = TRUE
	var/traitor = FALSE //Check if it's a traitor psychic weapon
	var/datum/mind/owner
	var/list/victims = list()
	var/datum/antag_contract/derail/contract
	pierce_multiplier = 2

/obj/item/gun/energy/psychic/Initialize()
	..()
	if(traitor)
		START_PROCESSING(SSobj, src)

/obj/item/gun/energy/psychic/Destroy()
	if(traitor)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gun/energy/psychic/Process()
	if(owner && !contract)
		find_contract()
		if(contract)
			STOP_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/gun/energy/psychic/proc/find_contract()
	for(var/datum/antag_contract/derail/C in GLOB.various_antag_contracts)
		if(C.completed)
			continue
		contract = C
		victims = list()
		if(src in owner.current.GetAllContents(includeSelf = FALSE))
			to_chat(owner.current, SPAN_NOTICE("[src] has found new contract."))
		break

/obj/item/gun/energy/psychic/proc/reg_break(mob/living/carbon/human/victim)
	if(victim.get_species() != SPECIES_HUMAN)
		return

	if(!contract)
		return

	if(owner && owner.current)
		if(victim == owner.current)
			return

		// If in owner's inventory, give a signal that the break was registred and counted towards contract
		if((src in owner.current.GetAllContents(includeSelf = FALSE)) && !(victim in victims))
			to_chat(owner.current, SPAN_DANGER("[src] clicks."))

	victims |= victim

	if(contract.completed)
		to_chat(owner.current, SPAN_DANGER("Somebody all ready have comleted targeted contract."))
		contract = null
		START_PROCESSING(SSobj, src)

	else if(victims.len >= contract.count)
		contract.report(src)
		contract = null
		START_PROCESSING(SSobj, src)

/obj/item/gun/energy/psychic/lasercannon
	name = "Prototype: psychic laser cannon"
	desc = "A laser cannon that attacks the minds of people, causing sanity loss and inducing mental breakdowns."
	icon = 'icons/obj/guns/energy/psychiccannon.dmi'
	icon_state = "psychic_lasercannon"
	item_state = "psychic_lasercannon"
	fire_sound = 'sound/weapons/lasercannonfire.ogg'
	item_charge_meter = FALSE
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 3, TECH_POWER = 3, TECH_COVERT = 5)
	projectile_type = /obj/item/projectile/beam/psychic/heavylaser
	w_class = ITEM_SIZE_NORMAL
	force = WEAPON_FORCE_NORMAL
	slot_flags = SLOT_BELT|SLOT_BACK
	traitor = TRUE
	pierce_multiplier = 2
	zoom_factor = 0
	damage_multiplier = 1
	charge_cost = 50
	fire_delay = 20
	price_tag = 6000
	matter = list(MATERIAL_STEEL = 25, MATERIAL_SILVER = 4, MATERIAL_URANIUM = 1)
	init_firemodes = list(
		WEAPON_NORMAL,
		WEAPON_CHARGE
		)
	twohanded = FALSE

/obj/item/gun/energy/psychic/mindflayer
	name = "Prototype: mind flayer"
	desc = "A cruel weapon designed to break the minds of those it targets, causing sanity loss and mental breakdowns."
	icon = 'icons/obj/guns/energy/xray.dmi'
	icon_state = "xray"
	projectile_type = /obj/item/projectile/beam/psychic
	fire_sound = 'sound/weapons/Laser.ogg'
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	fire_delay = 10
	price_tag = 2200
	matter = list(MATERIAL_PLASTEEL = 15, MATERIAL_SILVER = 5, MATERIAL_PLASMA = 3)
	twohanded = FALSE

/obj/item/gun/energy/laser/makeshift
	name = "makeshift laser carbine"
	desc = "A makeshift laser carbine, rather wastefull on its chage, but nonetheless reliable"
	icon = 'icons/obj/guns/energy/makeshift_carbine.dmi'
	icon_state = "makeshift"
	item_state = "makeshift"
	origin_tech = list(TECH_COMBAT = 2, TECH_MAGNET = 1)
	matter = list(MATERIAL_STEEL = 20, MATERIAL_PLASTIC = 15)
	item_charge_meter = TRUE
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_NORMAL
	force = WEAPON_FORCE_NORMAL
	zoom_factor = 0
	charge_cost = 100 //worst lightfall
	fire_delay = 10 //ditto
	price_tag = 500
	init_firemodes = list(
		WEAPON_NORMAL
	)
	spawn_blacklisted = TRUE

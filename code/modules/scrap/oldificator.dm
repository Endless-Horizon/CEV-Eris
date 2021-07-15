/datum/component/oldficator
	var/obj/old_obj
	var/list/armor
	var/list/all_vars = list()

/datum/component/oldficator/Initialize() //turn_connects for wheter or not we spin with the object to change our pipes
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE
	all_vars = duplicate_vars(parent)
	if(isitem(parent))
		var/obj/item/I = parent
		armor = I.armor.getList()

/datum/component/oldficator/proc/make_young()
	for(var/V in all_vars)
		if(istype(parent.vars[V], /datum) || ismob(parent.vars[V]) || isHUDobj(parent.vars[V]) || isobj(parent.vars[V]))
			continue	// Best not to mess with by-reference variables
		parent.vars[V] = all_vars[V]
	var/obj/O = parent
	if(isitem(parent))
		var/obj/item/I = parent
		I.armor = getArmor(arglist(armor))
	O.update_icon()
	QDEL_NULL(src)

//Defined at atom level for convenience, not currently used for mobs and turfs, but there are possible applications
/obj/proc/make_young()
	SHOULD_CALL_PARENT(TRUE)
	GET_COMPONENT(oldified, /datum/component/oldficator)
	if(oldified)
		oldified.make_young()
		return TRUE
	return FALSE

/obj/proc/make_old(low_quality_oldification)	//low_quality_oldification changes names and colors to fit with "bad prints" instead of "very old items" asthetic
	GET_COMPONENT(oldified, /datum/component/oldficator)
	if(oldified)
		return FALSE
	AddComponent(/datum/component/oldficator)
	light_color = color
	if(!low_quality_oldification)
		name = "[pick("old", "worn", "rusted", "weathered", "expired", "dirty", "frayed", "beaten", "ancient", "tarnished")] [name]"
		desc += "\n "
		desc += pick("Its warranty has expired.",
		 "The inscriptions on this thing have been erased by time.",
		  "Looks completely ruined.",
		   "It is difficult to make out what this thing once was.",
	 	   "A relic from a bygone age.")
		germ_level = max(germ_level, pick(80,110,160))

		if(prob(80))
			color = pick("#AA7744", "#774411", "#777777")

		//Deplete matter and matter_reagents
		for(var/a in matter)
			matter[a] *= RAND_DECIMAL(0.5, 1)

		for(var/a in matter_reagents)
			matter_reagents[a] *= RAND_DECIMAL(0.5, 1)

	else
		name = "[pick("bulky", "deformed", "misshapen", "warped", "unwieldy", "crooked", "distorted", "cracked", "layer-shifted", "fragile")] [name]"
		desc += "\n "
		desc += pick("Its shaped rather strangely.",
			"The fine details on this thing have been erased.",
			"Looks completely crooked.",
	 		"Looks like it could break at any moment.")

	price_tag *= RAND_DECIMAL(0.1, 0.6) //Tank the price of it

	for(var/obj/item/sub_item in contents)
		if(prob(80))
			sub_item.make_old(low_quality_oldification)
	spawn(1)
		update_icon()
	return TRUE


/obj/item/make_old(low_quality_oldification)
	.=..()
	if(.)
		if(prob(75) && (!low_quality_oldification))
			origin_tech = list()
		siemens_coefficient += 0.3

/obj/item/tool/make_old(low_quality_oldification)
	.=..()
	if(.)
		adjustToolHealth(-(rand(40, 150) * degradation))

/obj/item/storage/make_old(low_quality_oldification)
	.=..()
	if(.)
		var/del_count = rand(0, contents.len)
		for(var/i = 1 to del_count)
			var/removed_item = pick(contents)
			contents -= removed_item
			QDEL_NULL(removed_item)

		if(storage_slots && prob(75))
			storage_slots = max(contents.len, max(0, storage_slots - pick(2, 2, 2, 3, 3, 4)))
		if(max_storage_space && prob(75))
			max_storage_space = max_storage_space / 2

//Old pill bottles get a name that disguises their contents
/obj/item/storage/pill_bottle/make_old(low_quality_oldification)
	GET_COMPONENT(oldified, /datum/component/oldficator)
	if(!oldified && prob(85) && (!low_quality_oldification))
		name = "bottle of [pick("generic ", "unknown ", "")]pills"
		desc = "Contains pills of some kind. The label has long since worn away"
		for(var/obj/item/reagent_containers/pill/P in contents)
			P.make_old(low_quality_oldification)
	.=..()

//Make sure old pills always hide their contents too
/obj/item/reagent_containers/pill/make_old(low_quality_oldification)
	GET_COMPONENT(oldified, /datum/component/oldficator)
	if(!oldified && (!low_quality_oldification))
		name = "pill"
		desc = "Some kind of pill. The imprints have worn away."
	.=..()

/obj/structure/reagent_dispensers/make_old(low_quality_oldification)
	.=..()
	if(. && reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			reagents.remove_reagent(R.id,rand(0, R.volume),TRUE)

/obj/item/reagent_containers/make_old(low_quality_oldification)
	.=..()
	if(. && (!low_quality_oldification))
		var/actual_volume = reagents.total_volume
		for(var/datum/reagent/R in reagents.reagent_list)
			reagents.remove_reagent(R.id,rand(0, R.volume),TRUE)
		reagents.add_reagent("toxin", rand(0, actual_volume - reagents.total_volume))

/obj/item/reagent_containers/food/snacks/make_old(low_quality_oldification)
	.=..()
	if(.)
		junk_food = TRUE

//Sealed survival food, always edible
/obj/item/reagent_containers/food/snacks/liquidfood/make_old(low_quality_oldification)
	return

/obj/item/ammo_magazine/make_old(low_quality_oldification)
	var/del_count = rand(0, stored_ammo.len)
	if(low_quality_oldification)
		del_count = rand(0, contents.len / 2)

	for(var/i = 1 to del_count)
		var/removed_item = pick(stored_ammo)
		stored_ammo -= removed_item
		QDEL_NULL(removed_item)
	..()

/obj/item/cell/make_old(low_quality_oldification)
	.=..()
	if(.)
		// It's silly to have old self-charging cells spawn partially discharged
		if(!low_quality_oldification)
			autorecharging = FALSE

		maxcharge = rand(maxcharge/2, maxcharge)
		use(RAND_DECIMAL(0, maxcharge))
		if(prob(10))
			rigged = TRUE

/obj/item/stock_parts/make_old(low_quality_oldification)
	.=..()
	if(.)
		var/degrade = pick(0,1,1,1,2)
		rating = max(rating - degrade, 1)


/obj/item/stack/material/make_old(low_quality_oldification)
	return

/obj/item/stack/rods/make_old(low_quality_oldification)
	return

/obj/item/ore/make_old(low_quality_oldification)
	return

/obj/item/grenade/make_old(low_quality_oldification)
	. =..()
	if(.)
		det_time = RAND_DECIMAL(0, det_time)

/obj/item/tank/make_old(low_quality_oldification)
	.=..()
	if(.)
		air_contents.remove(pick(0.2, 0.4 ,0.6, 0.8))

/obj/item/electronics/circuitboard/make_old(low_quality_oldification)
	.=..()
	if(. && prob(75) && (!low_quality_oldification))
		name = T_BOARD("unknown")
		build_path = pick(/obj/machinery/washing_machine, /obj/machinery/broken, /obj/machinery/shower, /obj/machinery/holoposter, /obj/machinery/holosign)


/obj/item/electronics/ai_module/make_old(low_quality_oldification)
	GET_COMPONENT(oldified, /datum/component/oldficator)
	if(!oldified && prob(75) && !istype(src, /obj/item/electronics/ai_module/broken))
		var/obj/item/electronics/ai_module/brokenmodule = new /obj/item/electronics/ai_module/broken(loc)
		brokenmodule.name = src.name
		brokenmodule.desc = src.desc
		brokenmodule.make_old(low_quality_oldification)
		QDEL_NULL(src)
	else
		.=..()

/obj/item/clothing/suit/space/make_old(low_quality_oldification)
	.=..()
	if(. && prob(50))
		create_breaches(pick(BRUTE, BURN), rand(10, 50))

/obj/item/clothing/make_old(low_quality_oldification)
	.=..()
	if(.)
		if(prob(30))
			slowdown += pick(0.5, 0.5, 1, 1.5)
		if(prob(40))/*
			if(islist(armor)) //Possible to run before the initialize proc, thus having to modify the armor list
				var/list/armorList = armor	// Typecasting to a list from datum
				for(var/i in armorList)
					armorList[i] = rand(0, armorList[i])*/ //NOPE
			armor = armor.setRating(melee = rand(0, armor.getRating(ARMOR_MELEE)), bullet =  rand(0, armor.getRating(ARMOR_BULLET)), energy = rand(0, armor.getRating(ARMOR_ENERGY)), bomb = rand(0, armor.getRating(ARMOR_BOMB)), bio = rand(0, armor.getRating(ARMOR_BIO)), rad = rand(0, armor.getRating(ARMOR_RAD)))
		if(prob(40))
			heat_protection = rand(0, round(heat_protection * 0.5))
		if(prob(40))
			cold_protection = rand(0, round(cold_protection * 0.5))

		if(!low_quality_oldification)
			if(prob(20))
				contaminate()
			if(prob(15))
				add_blood()
		if(prob(60)) // I mean, the thing is ew gross.
			equip_delay += rand(0, 6 SECONDS)
		style += STYLE_NEG_LOW

/obj/item/electronics/ai_module/broken
	name = "\improper broken core AI module"
	desc = "broken Core AI Module: 'Reconfigures the AI's core laws.'"

/obj/machinery/broken/Initialize()
	..()
	explosion(loc, 1, 2, 3, 3)
	return INITIALIZE_HINT_QDEL

/obj/machinery/broken/Destroy()
	contents.Cut()
	return ..()

/obj/machinery/broken/make_old(low_quality_oldification)
	return

/obj/item/electronics/ai_module/broken/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	IonStorm(0)
	explosion(sender.loc, 1, 1, 1, 3)
	sender.drop_from_inventory(src)
	QDEL_NULL(src)

/obj/item/dnainjector/make_old(low_quality_oldification)
	.=..()
	if(.)
		if(prob(75))
			name = "DNA-Injector (unknown)"
			desc = pick("1mm0r74l17y 53rum", "1ncr3d1bl3 73l3p47y hNlk", "5up3rhum4n m16h7")
			value = 0xFFF
		if(prob(75))
			block = pick(MONKEYBLOCK, HALLUCINATIONBLOCK, DEAFBLOCK, BLINDBLOCK, NERVOUSBLOCK, TWITCHBLOCK, CLUMSYBLOCK, COUGHBLOCK, HEADACHEBLOCK, GLASSESBLOCK)


/obj/item/clothing/glasses/hud/make_old(low_quality_oldification)
	GET_COMPONENT(oldified, /datum/component/oldficator)
	if(!oldified && prob(75) && !istype(src, /obj/item/clothing/glasses/hud/broken))
		var/obj/item/clothing/glasses/hud/broken/brokenhud = new /obj/item/clothing/glasses/hud/broken(loc)
		brokenhud.name = src.name
		brokenhud.desc = src.desc
		brokenhud.icon = src.icon
		brokenhud.icon_state = src.icon_state
		brokenhud.item_state = src.item_state
		brokenhud.make_old(low_quality_oldification)
		QDEL_NULL(src)
	else
		.=..()

/obj/item/clothing/glasses/make_old(low_quality_oldification)
	.=..()
	if(.)
		if(prob(75))
			vision_flags = 0
		if(prob(75))
			darkness_view = -1

/obj/item/device/lighting/glowstick/make_old(low_quality_oldification)
	.=..()
	if(. && prob(75))
		fuel = rand(0, fuel)

/obj/item/device/lighting/toggleable/make_old(low_quality_oldification)
	.=..()
	if(. && prob(75))
		brightness_on = brightness_on / 2

/obj/machinery/floodlight/make_old(low_quality_oldification)
	.=..()
	if(. && prob(75))
		brightness_on = brightness_on / 2

/obj/machinery/make_old(low_quality_oldification)
	.=..()
	if(.)
		if(prob(60))
			stat |= BROKEN
		if(prob(60))
			emagged = TRUE

/obj/machinery/vending/make_old(low_quality_oldification)
	.=..()
	if(.)
		if(prob(60))
			vend_power_usage *= pick(1, 1.3, 1.5, 1.7, 2)
		if(prob(60))
			seconds_electrified = -1
		if(prob(60))
			shut_up = FALSE
			slogan_delay = rand(round(slogan_delay * 0.5), slogan_delay)
		if(prob(60))
			shoot_inventory = TRUE

		var/del_count = rand(0, product_records.len)
		for(var/i in 1 to del_count)
			product_records.Remove(pick(product_records))

/obj/item/clothing/glasses/sunglasses/sechud/make_old(low_quality_oldification)
	.=..()
	if(. && hud && prob(75))
		hud = new /obj/item/clothing/glasses/hud/broken
/*
/obj/effect/decal/mecha_wreckage/make_old(low_quality_oldification)
	.=..()
	if (.)
		salvage_num = max(1, salvage_num - pick(1, 2, 3))
*/
/obj/item/part/gun/make_old(low_quality_oldification)
	return

/mob/living/exosuit
	var/oldified = FALSE//Todo: inprove it.

/mob/living/exosuit/proc/make_old(low_quality_oldification)
	if(oldified)
		return FALSE
	oldified = TRUE
	name = "[pick("old", "rusted", "weathered", "ancient")] [name]"
	emp_act(rand(1,6))
	adjustFireLoss(rand(0, health))
	adjustBruteLoss(rand(0, health))
	/*
	for(var/obj/item/mech_component/comp in list(arms, legs, head, body))
		comp.make_old(low_quality_oldification)
	updatehealth()
	*/

/obj/item/gun/make_old(low_quality_oldification)
	.=..()
	if(. && prob(90))
		var/list/trash_mods = TRASH_GUNMODS
		while(trash_mods.len)
			var/trash_mod_path = pick_n_take(trash_mods)
			var/obj/item/trash_mod = new trash_mod_path
			if(SEND_SIGNAL(trash_mod, COMSIG_IATTACK, src, null))
				break
			QDEL_NULL(trash_mod)

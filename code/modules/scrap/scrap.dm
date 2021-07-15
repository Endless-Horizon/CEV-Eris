GLOBAL_LIST_EMPTY(scrap_base_cache)

#define SAFETY_COOLDOWN 100

/obj/structure/scrap_spawner
	name = "scrap pile"
	desc = "Pile of industrial debris. It could use a shovel and pair of hands in gloves."
	appearance_flags = TILE_BOUND
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	icon_state = "small"
	icon = 'icons/obj/structures/scrap/base.dmi'
	//Rarity_values
	rarity_value = 7.5
	spawn_frequency = 10
	spawn_tags = SPAWN_TAG_SCRAP
	sanity_damage = 0.1
	var/loot_generated = FALSE
	var/icontype = "general"
	var/obj/item/storage/internal/updating/loot	//the visible loot
	var/loot_min = 6
	var/loot_max = 12
	var/list/loot_tags = list(
		SPAWN_JUNK, SPAWN_CLEANABLE,
		SPAWN_MATERIAL_JUNK
	)
	var/list/rare_loot = list(SPAWN_RARE_ITEM)
	var/list/restricted_tags = list(SPAWN_ORGAN_ORGANIC)
	var/dig_amount = 4
	var/parts_icon = 'icons/obj/structures/scrap/trash.dmi'
	var/base_min = 5	//min and max number of random pieces of base icon
	var/base_max = 8
	var/base_spread = 12 //limits on pixel offsets of base pieces
	var/big_item_chance = 40
	var/obj/big_item
	var/list/ways = list("pokes around in", "searches", "scours", "digs through", "rummages through", "goes through","picks through")
	var/beacon = FALSE // If this junk pile is getting pulled by the junk beacon or not.
	var/rare_item_chance = 50
	var/rare_item = FALSE
	var/prob_make_old = 80

/obj/structure/scrap_spawner/proc/make_cube()
	try_make_loot() //don't have a cube without materials
	var/obj/container = new /obj/structure/scrap_cube(loc, loot_max)
	forceMove(container)

/obj/structure/scrap_spawner/Initialize()
	. = ..()
	update_icon(TRUE)

/obj/structure/scrap_spawner/examine(mob/user)
	.=..()
	if(isliving(user))
		try_make_loot() //Make the loot when examined so the big item check below will work
	to_chat(user, SPAN_NOTICE("You could sift through it with a shoveling tool to uncover more contents"))
	if(big_item && big_item.loc == src)
		to_chat(user, SPAN_DANGER("You can make out the corners of something large buried in here. Keep digging and removing things to uncover it"))

/obj/effect/scrapshot
	name = "This thing shoots scrap everywhere with a delay"
	desc = "no data"
	invisibility = 101
	anchored = TRUE
	density = FALSE

/obj/effect/scrapshot/Initialize(mapload, severity = 1)
	..()
	switch(severity)
		if(1)
			for(var/i in 1 to 12)
				var/projtype = pick(/obj/item/stack/rods, /obj/item/material/shard)
				var/obj/item/projectile = new projtype(loc)
				projectile.throw_at(locate(loc.x + rand(40) - 20, loc.y + rand(40) - 20, loc.z), 81, pick(1,3,80,80))
		if(2)
			for(var/i in 1 to 4)
				var/projtype = pick(subtypesof(/obj/item/trash))
				var/obj/item/projectile = new projtype(loc)
				projectile.throw_at(locate(loc.x + rand(10) - 5, loc.y + rand(10) - 5, loc.z), 3, 1)
	return INITIALIZE_HINT_QDEL

/obj/structure/scrap_spawner/ex_act(severity)
	set waitfor = FALSE
	if(prob(25))
		new /obj/effect/effect/smoke(src.loc)
	switch(severity)
		if(1)
			new /obj/effect/scrapshot(src.loc, 1)
			dig_amount = 0
		if(2)
			new /obj/effect/scrapshot(src.loc, 2)
			dig_amount = dig_amount / 3
		if(3)
			dig_amount = dig_amount / 2
	if(dig_amount < 4)
		qdel(src)
	else
		update_icon(TRUE)

/obj/structure/scrap_spawner/proc/make_big_loot()
	if(prob(big_item_chance))
		var/obj/randomcatcher/CATCH = new /obj/randomcatcher(src)
		if(beacon)
			big_item = CATCH.get_item(/obj/spawner/pack/junk_machine/beacon)
		else
			big_item = CATCH.get_item(/obj/spawner/pack/junk_machine)
		big_item.forceMove(src)
		if(prob(prob_make_old))
			big_item.make_old()
		qdel(CATCH)

/obj/structure/scrap_spawner/proc/try_make_loot()
	if(loot_generated)
		return
	loot_generated = TRUE
	if(!big_item)
		make_big_loot()

	var/amt = rand(loot_min, loot_max)
	var/list/junk_tags = list(SPAWN_JUNK,SPAWN_CLEANABLE,SPAWN_MATERIAL_JUNK)
	for(var/x in 1 to amt)
		var/rare = FALSE
		var/rare_items_amt = rand(1,2)
		if((x > amt-rare_items_amt) && prob(rare_item_chance))
			rare = TRUE
		var/list/loot_tags_copy = loot_tags.Copy()
		if(rare)
			loot_tags_copy -= junk_tags
			loot_tags_copy |= list(pickweight(rare_loot))
		var/list/true_loot_tags = list()
		var/tags_amt = max(round(loot_tags_copy.len/3),1)
		for(var/y in 1 to tags_amt)
			true_loot_tags += pickweight_n_take(loot_tags_copy)
		var/list/candidates = SSspawn_data.valid_candidates(true_loot_tags, restricted_tags - rare_loot, FALSE, null, null, TRUE)
		if(SPAWN_ITEM in true_loot_tags)
			var/top_price = CHEAP_ITEM_PRICE
			true_loot_tags = list()
			var/list/tags = SSspawn_data.lowkeyrandom_tags.Copy()
			var/new_tags_amt = max(round(tags.len*0.10),1)
			for(var/i in 1 to new_tags_amt)
				true_loot_tags += pick_n_take(tags)
			if(rare)
				top_price = CHEAP_ITEM_PRICE * 1.5
				true_loot_tags -= junk_tags
				true_loot_tags |= list(pickweight(rare_loot))
			candidates = SSspawn_data.valid_candidates(true_loot_tags, restricted_tags - rare_loot, FALSE, 1, top_price, TRUE, list(/obj/item/stash_spawner))
		var/loot_path = SSspawn_data.pick_spawn(candidates)
		new loot_path(src)
		var/list/aditional_objects = SSspawn_data.all_accompanying_obj_by_path[loot_path]
		if(islist(aditional_objects) && aditional_objects.len)
			for(var/thing in aditional_objects)
				var/atom/movable/AM = thing
				if(!prob(initial(AM.prob_aditional_object)*0.8))
					continue
				new thing(src)

	for(var/obj/item/loot in contents)
		if(prob(prob_make_old))
			loot.make_old()
		if(istype(loot, /obj/item/reagent_containers/food/snacks))
			var/obj/item/reagent_containers/food/snacks/S = loot
			S.junk_food = TRUE
			if(prob(20))
				S.reagents.add_reagent("toxin", rand(2, 15))

	loot = new(src)
	loot.max_w_class = ITEM_SIZE_HUGE
	shuffle_loot()

/obj/structure/scrap_spawner/Destroy()
	for(var/obj/item in loot)
		qdel(item)
	if(big_item)
		QDEL_NULL(big_item)
	QDEL_NULL(loot)
	return ..()

//stupid shard copypaste
/obj/structure/scrap_spawner/Crossed(atom/movable/AM)
	..()
	if(isliving(AM))
		var/mob/M = AM

		if(M.buckled) //wheelchairs, office chairs, rollerbeds
			return

		playsound(loc, 'sound/effects/glass_step.ogg', 50, 1) // not sure how to handle metal shards with sounds
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.species.siemens_coefficient < 0.5) //Thick skin.
				return

			if(H.shoes)
				return

			to_chat(M, SPAN_DANGER("You step on \the [src]!"))

			var/list/check = list(BP_L_LEG, BP_R_LEG)
			while(check.len)
				var/picked = pick(check)
				var/obj/item/organ/external/affecting = H.get_organ(picked)
				if(affecting)
					if(BP_IS_ROBOTIC(affecting))
						return
					if(affecting.take_damage(5, 0))
						H.UpdateDamageIcon()
					H.reagents.add_reagent("toxin", pick(prob(50);0,prob(50);5,prob(10);10,prob(1);25))
					H.updatehealth()
					if(!(H.species.flags & NO_PAIN))
						H.Weaken(3)
					return
				check -= picked

/obj/structure/scrap_spawner/proc/shuffle_loot()
	try_make_loot()
	loot.close_all()

	for(var/A in loot)
		loot.remove_from_storage(A,src)

	var/total_storage_space = 0

	if(contents.len)
		contents = shuffle(contents)
		var/num = rand(2, loot_min)
		for(var/obj/item/O in contents)
			if(!num)
				break
			if(O == loot || O == big_item)
				continue
			total_storage_space += O.get_storage_cost()
			O.forceMove(loot)
			num--
	loot.max_storage_space = max(10, total_storage_space)
	update_icon()

/obj/structure/scrap_spawner/proc/randomize_image(image/I)
	I.pixel_x = rand(-base_spread,base_spread)
	I.pixel_y = rand(-base_spread,base_spread)
	var/matrix/M = matrix()
	M.Turn(pick(0,90,180,270))
	I.transform = M
	return I

/obj/structure/scrap_spawner/on_update_icon(rebuild_base=FALSE)
	if(clear_if_empty())
		return

	if(rebuild_base)
		var/ID = rand(40)
		if(!GLOB.scrap_base_cache["[icontype][icon_state][ID]"])
			var/num = rand(base_min,base_max)
			var/image/base_icon = image(icon, icon_state = icon_state)
			for(var/i in 1 to num)
				var/image/I = image(parts_icon,pick(icon_states(parts_icon)))
				I.color = pick("#996633", "#663300", "#666666", "")
				base_icon.overlays.Add(randomize_image(I))
			GLOB.scrap_base_cache["[icontype][icon_state][ID]"] = base_icon
		add_overlays(GLOB.scrap_base_cache["[icontype][icon_state][ID]"])
	if(loot_generated)
		underlays.Cut()
		for(var/obj/O in loot.contents)
			var/image/I = image(O.icon,O.icon_state)
			I.color = O.color
			underlays |= randomize_image(I)
	if(big_item)
		var/image/I = image(big_item.icon,big_item.icon_state)
		I.color = big_item.color
		underlays |= I



/obj/structure/scrap_spawner/proc/hurt_hand(mob/user)
	if(prob(15))
		if(!ishuman(user))
			return FALSE
		var/mob/living/carbon/human/victim = user
		if(victim.species.flags & NO_MINOR_CUT)
			return FALSE
		if(victim.gloves && prob(90))
			return FALSE
		var/obj/item/organ/external/BP = victim.get_organ(victim.hand ? BP_L_ARM : BP_R_ARM)
		if(!BP)
			return FALSE
		to_chat(user, SPAN_DANGER("Ouch! You cut yourself while picking through \the [src]."))
		BP.take_damage(5, null, TRUE, TRUE, "Sharp debris")
		if(!BP_IS_ROBOTIC(BP))
			victim.reagents.add_reagent("toxin", pick(prob(50);0,prob(50);5,prob(10);10,prob(1);25))
		if(victim.species.flags & NO_PAIN) // So we still take damage, but actually dig through.
			return FALSE
		return TRUE
	return FALSE

/obj/structure/scrap_spawner/attack_hand(mob/user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if(hurt_hand(user))
		return
	try_make_loot()
	loot.open(user)
	playsound(src, "rummage", 50, 1)
	.=..()

/obj/structure/scrap_spawner/attack_generic(mob/user)
	if(isliving(user) && loot)
		loot.open(user)
	.=..()


/obj/structure/scrap_spawner/proc/dig_out_lump(newloc = loc)
	if(dig_amount > 0)
		dig_amount--
		for (var/a in matter)
			matter[a] *=RAND_DECIMAL(0.6, 0.8)//remove some amount of matter from the pile
		//new /obj/item/scrap_lump(src) //Todo: uncomment this once purposes and machinery for scrap are implemented
		return TRUE


/obj/structure/scrap_spawner/proc/clear_if_empty()
	if(dig_amount <= 0)
		for (var/obj/item/i in contents)
			if((i != big_item) && (i != loot)) //These two dont stop the pile from being cleared
				return FALSE

		//Anything in the internal storage prevents deletion
		if(loot)
			for (var/obj/item/i in loot.contents)
				return FALSE

		clear()
		return TRUE
	return FALSE

/obj/structure/scrap_spawner/proc/clear()
	visible_message(SPAN_NOTICE("\The [src] is cleared out!"))
	if(big_item)
		visible_message(SPAN_NOTICE("\A hidden [big_item] is uncovered from beneath the [src]!"))
		big_item.forceMove(get_turf(src))
		big_item = null
	else if(rare_item && prob(rare_item_chance))
		var/obj/O = pickweight(RANDOM_RARE_ITEM - /obj/item/stash_spawner)
		O = new O(get_turf(src))
		visible_message(SPAN_NOTICE("\A hidden [O] is uncovered from beneath the [src]!"))
	qdel(src)

/obj/structure/scrap_spawner/attackby(obj/item/W, mob/living/carbon/human/user)
	user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	if((W.has_quality(QUALITY_SHOVELING)) && W.use_tool(user, src, WORKTIME_NORMAL, QUALITY_SHOVELING, FAILCHANCE_VERY_EASY, required_stat = STAT_ROB, forced_sound = "rummage"))
		user.visible_message(SPAN_NOTICE("[user] [pick(ways)] \the [src]."))
		user.do_attack_animation(src)
		if(user.stats.getPerk(PERK_JUNKBORN))
			rare_item = TRUE
		else
			rare_item = FALSE
		dig_out_lump(user.loc, 0)
		shuffle_loot()
		clear_if_empty()

/obj/structure/scrap_spawner/large
	name = "large scrap pile"
	opacity = TRUE
	density = TRUE
	icon_state = "big"
	loot_min = 9
	loot_max = 18
	dig_amount = 6
	base_min = 9
	base_max = 14
	base_spread = 16
	spawn_tags = SPAWN_TAG_LARGE_SCRAP

/obj/structure/scrap_spawner/medical
	icontype = "medical"
	name = "medical refuse pile"
	desc = "Pile of medical refuse. They sure don't cut expenses on these. "
	parts_icon = 'icons/obj/structures/scrap/medical_trash.dmi'
	rarity_value = 25
	loot_tags = list(
		SPAWN_MEDICAL,
		SPAWN_SURGERY_TOOL,
		SPAWN_JUNK, SPAWN_CLEANABLE,
		SPAWN_MATERIAL_JUNK
	)

/obj/structure/scrap_spawner/vehicle
	icontype = "vehicle"
	name = "industrial debris pile"
	desc = "Pile of used machinery. You could use tools from this to build something."
	parts_icon = 'icons/obj/structures/scrap/vehicle.dmi'
	rarity_value = 16.66
	loot_tags = list(
		SPAWN_DESIGN,
		SPAWN_ELECTRONICS,
		SPAWN_KNIFE,
		SPAWN_ITEM,
		SPAWN_MATERIAL,
		SPAWN_MECH_QUIPMENT,
		SPAWN_POWERCELL,
		SPAWN_ASSEMBLY,SPAWN_STOCK_PARTS,SPAWN_DESIGN_COMMON,SPAWN_COMPUTER_HARDWERE,
		SPAWN_TOOL, SPAWN_DIVICE, SPAWN_JETPACK, SPAWN_ITEM_UTILITY,SPAWN_TOOL_UPGRADE,SPAWN_TOOLBOX,SPAWN_VOID_SUIT,
		SPAWN_GUN_UPGRADE,
		SPAWN_POUCH,
		SPAWN_MATERIAL_BUILDING = 2,
		SPAWN_JUNK = 3, SPAWN_CLEANABLE = 3,
		SPAWN_ORE,SPAWN_MATERIAL_JUNK = 3,
		SPAWN_PART_ARMOR = 2
	)

/obj/structure/scrap_spawner/food
	icontype = "food"
	name = "food trash pile"
	desc = "Pile of thrown away food. Someone sure have lots of spare food while children on Mars are starving."
	parts_icon = 'icons/obj/structures/scrap/food_trash.dmi'
	rarity_value = 5.77
	loot_tags = list(
		SPAWN_JUNKFOOD,
		SPAWN_BOOZE,
		SPAWN_JUNK, SPAWN_CLEANABLE,
		SPAWN_MATERIAL_JUNK,
		SPAWN_PART_ARMOR = 0.1
	)

/obj/structure/scrap_spawner/guns
	icontype = "guns"
	name = "gun refuse pile"
	desc = "Pile of military supply refuse. Who thought it was a clever idea to throw that out?"
	parts_icon = 'icons/obj/structures/scrap/guns_trash.dmi'
	loot_min = 7
	loot_max = 10
	rarity_value = 90
	loot_tags = list(
		SPAWN_GUN = 0.3,
		SPAWN_PART_GUN = 3,
		SPAWN_AMMO_S,
		SPAWN_KNIFE,
		SPAWN_HOLSTER,
		SPAWN_GUN_UPGRADE,
		SPAWN_POWERCELL,
		SPAWN_MECH_QUIPMENT,
		SPAWN_TOY_WEAPON,
		SPAWN_JUNK = 2.5, SPAWN_CLEANABLE = 2.5,
		SPAWN_MATERIAL_JUNK = 2.5
	)

/obj/structure/scrap_spawner/science
	icontype = "science"
	name = "scientific trash pile"
	desc = "Pile of refuse from research department."
	parts_icon = 'icons/obj/structures/scrap/science.dmi'
	rarity_value = 25
	loot_tags = list(
		SPAWN_DESIGN,
		SPAWN_ELECTRONICS,
		SPAWN_KNIFE,
		SPAWN_ITEM,
		SPAWN_MATERIAL,
		SPAWN_MECH_QUIPMENT,
		SPAWN_POWERCELL,
		SPAWN_ASSEMBLY,SPAWN_STOCK_PARTS,
		SPAWN_DESIGN_COMMON,
		SPAWN_COMPUTER_HARDWERE,
		SPAWN_TOOL, SPAWN_DIVICE,
		SPAWN_JETPACK,
		SPAWN_ITEM_UTILITY = 0.5,
		SPAWN_TOOL_UPGRADE,
		SPAWN_TOOLBOX,
		SPAWN_VOID_SUIT = 0.5,
		SPAWN_GUN_UPGRADE,
		SPAWN_SCIENCE,
		SPAWN_ORE,
		SPAWN_RARE_ITEM,
		SPAWN_JUNK = 4,
		SPAWN_TOOL_ADVANCED = 0.5,
		SPAWN_MATERIAL_JUNK = 4,
		SPAWN_PART_ARMOR = 1
		)
	rare_loot = list(SPAWN_ODDITY, SPAWN_RARE_ITEM)

/obj/structure/scrap_spawner/cloth
	icontype = "cloth"
	name = "cloth pile"
	desc = "Pile of second hand clothing for charity."
	parts_icon = 'icons/obj/structures/scrap/cloth.dmi'
	rarity_value = 10
	loot_tags = list(SPAWN_CLOTHING, SPAWN_PART_ARMOR = 0.3)
	restricted_tags = list(SPAWN_VOID_SUIT)
	rare_loot = list(SPAWN_RARE_ITEM,SPAWN_VOID_SUIT)

/obj/structure/scrap_spawner/poor
	icontype = "poor"
	name = "mixed rubbish"
	desc = "Pile of mixed rubbish. Useless and rotten, mostly."
	parts_icon = 'icons/obj/structures/scrap/all_mixed.dmi'
	rarity_value = 2.5
	loot_tags = list(
		SPAWN_ITEM,
		SPAWN_JUNK = 2, SPAWN_CLEANABLE,
		SPAWN_ORE,
		SPAWN_MATERIAL_JUNK = 2
	)
	restricted_tags = list(SPAWN_MATERIAL_RESOURCES, SPAWN_ORGAN_ORGANIC)
	rare_loot = list(SPAWN_RARE_ITEM, SPAWN_ODDITY)

/obj/structure/scrap_spawner/poor/large
	name = "large mixed rubbish"
	icon_state = "big"
	opacity = TRUE
	density = TRUE
	loot_min = 11
	loot_max = 18
	base_min = 9
	base_max = 14
	big_item_chance = 75
	spawn_frequency = 9
	rarity_value = 2.7
	spawn_tags = SPAWN_TAG_LARGE_SCRAP

/obj/structure/scrap_spawner/poor/large/beacon
	beacon = TRUE
	rarity_value = 2.7
	spawn_tags = SPAWN_TAG_BEACON_SCRAP

/obj/structure/scrap_spawner/vehicle/large
	name = "large industrial debris pile"
	icon_state = "big"
	opacity = TRUE
	density = TRUE
	loot_min = 11
	loot_max = 18
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 100
	rarity_value = 15
	spawn_tags = SPAWN_TAG_LARGE_SCRAP

/obj/structure/scrap_spawner/vehicle/large/beacon
	beacon = TRUE
	rarity_value = 15
	spawn_tags = SPAWN_TAG_BEACON_SCRAP

/obj/structure/scrap_spawner/food/large
	name = "large food trash pile"
	icon_state = "big"
	opacity = TRUE
	density = TRUE
	loot_min = 13
	loot_max = 20
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 50
	rarity_value = 7.5
	spawn_tags = SPAWN_TAG_LARGE_SCRAP

/obj/structure/scrap_spawner/food/large/beacon
	beacon = TRUE
	spawn_tags = SPAWN_TAG_BEACON_SCRAP
	rarity_value = 7.5

/obj/structure/scrap_spawner/medical/large
	name = "large medical refuse pile"
	icon_state = "big"
	opacity = TRUE
	density = TRUE
	loot_min = 7
	loot_max = 18
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 60
	rarity_value = 21.42
	spawn_tags = SPAWN_TAG_LARGE_SCRAP

/obj/structure/scrap_spawner/medical/large/beacon
	beacon = TRUE
	rarity_value = 21.42
	spawn_tags = SPAWN_TAG_BEACON_SCRAP

/obj/structure/scrap_spawner/guns/large
	name = "large gun refuse pile"
	icon_state = "big"
	opacity = TRUE
	density = TRUE
	loot_min = 10
	loot_max = 18
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 50
	spawn_tags = SPAWN_TAG_LARGE_SCRAP

/obj/structure/scrap_spawner/guns/large/beacon
	beacon = TRUE
	spawn_tags = SPAWN_TAG_BEACON_SCRAP

/obj/structure/scrap_spawner/science/large
	name = "large scientific trash pile"
	icon_state = "big"
	opacity = TRUE
	density = TRUE
	loot_min = 11
	loot_max = 18
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 80
	rarity_value = 21.42
	spawn_tags = SPAWN_TAG_LARGE_SCRAP

/obj/structure/scrap_spawner/science/large/beacon
	beacon = TRUE
	rarity_value = 21.42
	spawn_tags = SPAWN_TAG_BEACON_SCRAP

/obj/structure/scrap_spawner/cloth/large
	name = "large cloth pile"
	icon_state = "big"
	opacity = TRUE
	density = TRUE
	loot_min = 7
	loot_max = 16
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 65
	rarity_value = 11.53
	spawn_tags = SPAWN_TAG_LARGE_SCRAP

/obj/structure/scrap_spawner/cloth/large/beacon
	beacon = TRUE
	rarity_value = 11.53
	spawn_tags = SPAWN_TAG_BEACON_SCRAP

/obj/structure/scrap_spawner/poor/structure
	name = "large mixed rubbish"
	icon_state = "med"
	opacity = TRUE
	density = TRUE
	loot_min = 4
	loot_max = 7
	dig_amount = 3
	base_min = 3
	base_max = 6
	big_item_chance = 100
	rarity_value = 3.33
	spawn_tags = SPAWN_TAG_LARGE_SCRAP

/obj/structure/scrap_spawner/poor/structure/beacon
	beacon = TRUE
	rarity_value = 3.33
	spawn_tags = SPAWN_TAG_BEACON_SCRAP


/obj/structure/scrap_spawner/poor/structure/on_update_icon(rebuild_base=FALSE) //make big trash icon for this
	..()
	if(!loot_generated)
		underlays += image(icon, icon_state = "underlay_big")

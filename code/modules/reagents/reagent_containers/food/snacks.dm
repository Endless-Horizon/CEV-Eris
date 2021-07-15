//Food items that are eaten normally and don't leave anything behind.
/obj/item/reagent_containers/food
	bad_type = /obj/item/reagent_containers/food

/obj/item/reagent_containers/food/snacks
	name = "snack"
	desc = "yummy"
	icon = 'icons/obj/food.dmi'
	icon_state = null
	center_of_mass = list("x"=16, "y"=16)
	w_class = ITEM_SIZE_SMALL
	spawn_tags = SPAWN_TAG_COOKED_FOOD
	bad_type = /obj/item/reagent_containers/food/snacks
	var/bitesize = 1
	var/bitecount = 0
	var/trash
	var/slice_path
	var/slices_num
	var/dried_type
	var/dry = FALSE
	var/dryness = 0 //Used by drying rack. Represents progress towards Dry state
	var/nutriment_amt = 0
	var/list/nutriment_desc = list("food" = 1)

	var/sanity_gain = 0.2 //per nutriment
	var/junk_food = FALSE //if TRUE, sanity gain per nutriment will be zero
	var/cooked = FALSE
	var/list/taste_tag = list(BLAND_FOOD)

/obj/item/reagent_containers/food/snacks/Initialize()
	. = ..()
	if(nutriment_amt)
		reagents.add_reagent("nutriment", nutriment_amt, nutriment_desc)

/obj/item/reagent_containers/food/snacks/proc/get_sanity_gain(mob/living/carbon/eater) //sanity_gain Per bite
	var/current_nutriment = reagents.get_reagent_amount("nutriment")
	var/nutriment_percent = current_nutriment/reagents.total_volume
	var/nutriment_eaten = min(reagents.total_volume, bitesize) * nutriment_percent
	var/base_sanity_gain_pb = nutriment_eaten * sanity_gain
	var/message
	if(!iscarbon(eater))
		return  list(0, message)
	if(eater.nutrition > eater.max_nutrition*0.95)
		message = "You are satisfied and you don't need to eat more."
		return  list(0, SPAN_WARNING(message))
	if(!base_sanity_gain_pb)
		message = "This food does not help calm your nerves."
		return  list(0, SPAN_WARNING(message))
	var/sanity_gain_pb = base_sanity_gain_pb
	message = "Food helps you relax."
	if(cooked)
		sanity_gain_pb += base_sanity_gain_pb * 0.2
	if(junk_food || !cooked)
		message += " But, only healthy food helps you grow."
		return  list(sanity_gain_pb, SPAN_NOTICE(message))
	var/table = FALSE
	var/companions = FALSE
	var/view_death = FALSE
	for(var/C in circleview(eater, 3))
		if(istype(C, /obj/structure/table))
			if(!in_range(C, eater) || table)
				continue
			table = TRUE
			message += " Eating is more comfortable using a table."
			sanity_gain_pb += base_sanity_gain_pb * 0.1

		else if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(H == eater)
				continue
			if(H.is_dead())
				view_death = TRUE
			companions = TRUE
	if(companions)
		sanity_gain_pb += base_sanity_gain_pb * 0.3
		message += " The company make the food taste much better."
		if(view_death && !eater.stats.getPerk(PERK_NIHILIST))
			message = "You gaze at the cadaver... Your food doesn't taste so good anymore."
			sanity_gain_pb = 0
			return list(sanity_gain_pb, SPAN_WARNING(message))

	return list(sanity_gain_pb, SPAN_NOTICE(message))

	//Placeholder for effect that trigger on eating that aren't tied to reagents.
/obj/item/reagent_containers/food/snacks/proc/On_Consume(mob/eater, mob/feeder = null)
	if(!reagents.total_volume)
		eater.visible_message(
			SPAN_NOTICE("[eater] finishes eating \the [src]."),
			SPAN_NOTICE("You finish eating \the [src].")
		)
		if (!feeder)
			feeder = eater

		feeder.drop_from_inventory(src)	//so icons update :[

		if(trash)
			if(ispath(trash,/obj/item))
				var/obj/item/TrashItem = new trash(feeder)
				if(isanimal(feeder))
					TrashItem.forceMove(loc)
				else
					feeder.put_in_hands(TrashItem)
			else if(istype(trash,/obj/item))
				feeder.put_in_hands(trash)
		qdel(src)

/obj/item/reagent_containers/food/snacks/attack_self(mob/user as mob)
	return

/obj/item/reagent_containers/food/snacks/attack(mob/M as mob, mob/user as mob, def_zone)
	if(!reagents.total_volume)
		to_chat(user, SPAN_DANGER("None of [src] left!"))
		user.drop_from_inventory(src)
		qdel(src)
		return 0

	if(iscarbon(M))
		//TODO: replace with standard_feed_mob() call.
		var/mob/living/carbon/C = M
		var/mob/living/carbon/human/H = M
		var/fullness_modifier = 1
		if(istype(H))
			fullness_modifier = 100 / H.get_organ_efficiency(OP_STOMACH)
		var/fullness = (C.nutrition + (C.reagents.get_reagent_amount("nutriment") * 25)) * fullness_modifier
		if(C == user)								//If you're eating it yourself
			if(istype(H))
				if(!H.check_has_mouth())
					to_chat(user, "Where do you intend to put \the [src]? You don't have a mouth!")
					return
				var/obj/item/blocked = H.check_mouth_coverage()
				if(blocked)
					to_chat(user, SPAN_WARNING("\The [blocked] is in the way!"))
					return

			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN) //puts a limit on how fast people can eat/drink things
			if (fullness <= 50)
				to_chat(C, SPAN_DANGER("You hungrily chew out a piece of [src] and gobble it!"))
			if (fullness > 50 && fullness <= 150)
				to_chat(C, SPAN_NOTICE("You hungrily begin to eat [src]."))
			if (fullness > 150 && fullness <= 350)
				to_chat(C, SPAN_NOTICE("You take a bite of [src]."))
			if (fullness > 350 && fullness <= 550)
				to_chat(C, SPAN_NOTICE("You unwillingly chew a bit of [src]."))
			if (fullness > 550)
				to_chat(C, SPAN_DANGER("You cannot force any more of [src] to go down your throat."))
				return 0
		else
			if(!M.can_force_feed(user, src))
				return

			if (fullness <= 550)
				user.visible_message(SPAN_DANGER("[user] attempts to feed [M] [src]."))
			else
				user.visible_message(SPAN_DANGER("[user] cannot force anymore of [src] down [M]'s throat."))
				return 0

			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
			if(!do_mob(user, M)) return

			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: [reagents.log_list()]</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [src.name] by [M.name] ([M.ckey]) Reagents: [reagents.log_list()]</font>")
			msg_admin_attack("[key_name(user)] fed [key_name(M)] with [src.name] Reagents: [reagents.log_list()] (INTENT: [uppertext(user.a_intent)])")

			user.visible_message(SPAN_DANGER("[user] feeds [M] [src]."))

		if(reagents)			//Handle ingestion of the reagent.
			playsound(M.loc,pick(M.eat_sounds), rand(10,50), 1)
			if(reagents.total_volume)
				var/amount_eaten = min(reagents.total_volume, bitesize)
				var/list/sanity_vars = get_sanity_gain(M)
				reagents.trans_to_mob(M, amount_eaten, CHEM_INGEST)
				if(istype(H))
					H.sanity.onEat(src, sanity_vars[1], sanity_vars[2])
				bitecount++
				On_Consume(M, user)
			return 1

	else if (isanimal(M))
		var/mob/living/simple_animal/SA = M
		SA.scan_interval = SA.min_scan_interval//Feeding an animal will make it suddenly care about food

		var/m_bitesize = bitesize * SA.bite_factor//Modified bitesize based on creature size
		var/amount_eaten = m_bitesize

		if(reagents && SA.reagents)
			m_bitesize = min(m_bitesize, reagents.total_volume)
			//If the creature can't even stomach half a bite, then it eats nothing
			if (!SA.can_eat() || ((user.reagents.maximum_volume - user.reagents.total_volume) < m_bitesize * 0.5))
				amount_eaten = 0
			else
				amount_eaten = reagents.trans_to_mob(SA, m_bitesize, CHEM_INGEST)
		else
			return 0//The target creature can't eat

		if (amount_eaten)
			playsound(M.loc,pick(M.eat_sounds), rand(10,30), 1)
			bitecount++
			if (amount_eaten >= m_bitesize)
				user.visible_message(SPAN_NOTICE("[user] feeds [src] to [M]."))
			else
				user.visible_message(SPAN_NOTICE("[user] feeds [M] a tiny bit of [src]. <b>It looks full.</b>"))
				if (!istype(M.loc, /turf))
					to_chat(M, SPAN_NOTICE("[user] feeds you a tiny bit of [src]. <b>You feel pretty full!</b>"))
			On_Consume(M, user)
			return 1
		else
			to_chat(user, SPAN_WARNING("[M.name] can't stomach anymore food!"))

	return 0

/obj/item/reagent_containers/food/snacks/examine(mob/user)
	if(!..(user, 1))
		return
	if(junk_food)
		to_chat(user, SPAN_WARNING("\The [src] its a junk food!"))
	else if(taste_tag.len)
		to_chat(user, SPAN_NOTICE("\The [src] tastes like [english_list(taste_tag)]"))
	if (bitecount==0)
		return
	else if (bitecount==1)
		to_chat(user, SPAN_NOTICE("\The [src] was bitten by someone!"))
	else if (bitecount<=3)
		to_chat(user, SPAN_NOTICE("\The [src] was bitten [bitecount] time\s!"))
	else
		to_chat(user, SPAN_NOTICE("\The [src] was bitten multiple times!"))

/obj/item/reagent_containers/food/snacks/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/storage))
		..() // -> item/attackby()
		return

	// Eating with forks
	if(istype(W,/obj/item/material/kitchen/utensil))
		var/obj/item/material/kitchen/utensil/U = W
		if(U.scoop_food)
			if(!U.reagents)
				U.create_reagents(5)

			if (U.reagents.total_volume > 0)
				to_chat(user, SPAN_WARNING("You already have something on your [U]."))
				return

			user.visible_message( \
				"\The [user] scoops up some [src] with \the [U]!", \
				SPAN_NOTICE("You scoop up some [src] with \the [U]!") \
			)

			src.bitecount++
			U.cut_overlays()
			U.loaded = "[src]"
			var/image/I = new(U.icon, "loadedfood")
			I.color = src.filling_color
			U.add_overlays(I)

			reagents.trans_to_obj(U, min(reagents.total_volume,5))

			if (reagents.total_volume <= 0)
				qdel(src)
			return

	if (is_sliceable())
		//these are used to allow hiding edge items in food that is not on a table/tray
		var/can_slice_here = isturf(src.loc) && ((locate(/obj/structure/table) in src.loc) || (locate(/obj/machinery/optable) in src.loc) || (locate(/obj/item/tray) in src.loc))
		var/hide_item = !has_edge(W) || !can_slice_here

		if (hide_item)
			if (W.w_class >= src.w_class || is_robot_module(W))
				return

			to_chat(user, SPAN_WARNING("You slip \the [W] inside \the [src]."))
			user.remove_from_mob(W)
			W.dropped(user)
			add_fingerprint(user)
			contents += W
			return

		if (has_edge(W))
			if (!can_slice_here)
				to_chat(user, SPAN_WARNING("You cannot slice \the [src] here! You need a table or at least a tray to do it."))
				return

			var/slices_lost = 0
			if (W.w_class > ITEM_SIZE_NORMAL)
				user.visible_message(SPAN_NOTICE("\The [user] crudely slices \the [src] with [W]!"), SPAN_NOTICE("You crudely slice \the [src] with your [W]!"))
				slices_lost = rand(1,min(1,round(slices_num/2)))
			else
				user.visible_message(SPAN_NOTICE("\The [user] slices \the [src]!"), SPAN_NOTICE("You slice \the [src]!"))

			var/reagents_per_slice = reagents.total_volume/slices_num
			for(var/i=1 to (slices_num-slices_lost))
				var/obj/slice = new slice_path (src.loc)
				reagents.trans_to_obj(slice, reagents_per_slice)
			qdel(src)
			return

/obj/item/reagent_containers/food/snacks/proc/is_sliceable()
	return (slices_num && slice_path && slices_num > 0)

/obj/item/reagent_containers/food/snacks/Destroy()
	if(contents)
		for(var/atom/movable/something in contents)
			something.forceMove(get_turf(src))
	. = ..()

////////////////////////////////////////////////////////////////////////////////
/// FOOD END
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/food/snacks/attack_generic(var/mob/living/user)
	if(!isanimal(user))
		return

	var/amount_eaten = bitesize
	var/m_bitesize = bitesize

	if (isanimal(user))
		var/mob/living/simple_animal/SA = user
		m_bitesize = bitesize * SA.bite_factor//Modified bitesize based on creature size
		amount_eaten = m_bitesize
		if (!SA.can_eat())
			to_chat(user, "<span class='danger'>You're too full to eat anymore!</span>")
			return

	if(reagents && user.reagents)
		reagents.trans_to_mob(user, bitesize, CHEM_INGEST)
		m_bitesize = min(m_bitesize, reagents.total_volume)
		//If the creature can't even stomach half a bite, then it eats nothing
		if (((user.reagents.maximum_volume - user.reagents.total_volume) < m_bitesize * 0.5))
			amount_eaten = 0
		else
			amount_eaten = reagents.trans_to_mob(user, m_bitesize, CHEM_INGEST)
	if (amount_eaten)
		playsound(user.loc,pick(user.eat_sounds), rand(10,30), 1)
		shake_animation(5)
		bitecount++
		if (amount_eaten < m_bitesize)
			to_chat(user, SPAN_NOTICE("You reluctantly nibble a tiny part of \the [src]. <b>You can't stomach much more!</b>."))
		else
			to_chat(user, SPAN_NOTICE("You nibble away at \the [src]."))
	else
		to_chat(user, "<span class='danger'>You're too full to eat anymore!</span>")

	spawn(5)
		if(!src && !user.client)
			user.custom_emote(1,"[pick("burps", "cries for more", "burps twice", "looks at the area where the food was")]")
			qdel(src)
	On_Consume(user)

//////////////////////////////////////////////////
////////////////////////////////////////////Snacks
//////////////////////////////////////////////////
//Items in the "Snacks" subcategory are food items that people actually eat. The key points are that they are created
//	already filled with reagents and are destroyed when empty. Additionally, they make a "munching" noise when eaten.

//Notes by Darem: Food in the "snacks" subtype can hold a maximum of 50 units Generally speaking, you don't want to go over 40
//	total for the item because you want to leave space for extra condiments. If you want effect besides healing, add a reagent for
//	it. Try to stick to existing reagents when possible (so if you want a stronger healing effect, just use Tricordrazine). On use
//	effect (such as the old officer eating a donut code) requires a unique reagent (unless you can figure out a better way).

//The nutriment reagent and bitesize variable replace the old heal_amt and amount variables. Each unit of nutriment is equal to
//	2 of the old heal_amt variable. Bitesize is the rate at which the reagents are consumed. So if you have 6 nutriment and a
//	bitesize of 2, then it'll take 3 bites to eat. Unlike the old system, the contained reagents are evenly spread among all
//	the bites. No more contained reagents = no more bites.

//Here is an example of the new formatting for anyone who wants to add more food items.
///obj/item/reagent_containers/food/snacks/xenoburger		//Identification path for the object.
//	name = "Xenoburger"												//Name that displays in the UI.
//	desc = "Smells caustic. Tastes like heresy."					//Duh
//	icon_state = "xburger"											//Refers to an icon in food.dmi
//	bitesize = 3													//This is the amount each bite consumes.
//	preloaded_reagents = list("xenomicrobes" = 10, "nutriment" = 2)			//This is what is in the food item.




/obj/item/reagent_containers/food/snacks/aesirsalad
	name = "Aesir salad"
	desc = "Probably too incredible for mortal men to fully enjoy."
	icon_state = "aesirsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#468C00"
	center_of_mass = list("x"=17, "y"=11)
	nutriment_amt = 8
	nutriment_desc = list("apples" = 3,"salad" = 5)
	preloaded_reagents = list("doctorsdelight" = 8, "tricordrazine" = 8)
	bitesize = 3
	cooked = TRUE
	taste_tag = list(VEGETARIAN_FOOD,VEGAN_FOOD)

/obj/item/reagent_containers/food/snacks/candy
	name = "candy"
	desc = "Nougat, love it or hate it."
	icon_state = "candy"
	trash = /obj/item/trash/candy
	filling_color = "#7D5F46"
	bitesize = 2
	center_of_mass = list("x"=15, "y"=15)
	nutriment_amt = 1
	nutriment_desc = list("candy" = 1)
	preloaded_reagents = list("sugar" = 3)
	junk_food = TRUE
	spawn_tags = SPAWN_TAG_JUNKFOOD_RATIONS
	taste_tag = list(SWEET_FOOD)

/obj/item/reagent_containers/food/snacks/candy/donor
	name = "Donor Candy"
	desc = "A little treat for blood donors."
	bitesize = 5
	trash = /obj/item/trash/candy
	nutriment_desc = list("candy" = 10)
	preloaded_reagents = list("nutriment" = 10, "sugar" = 6)

/obj/item/reagent_containers/food/snacks/candy_corn
	name = "candy corn"
	desc = "It's a handful of candy corn. Cannot be stored in a detective's hat, alas."
	icon_state = "candy_corn"
	filling_color = "#FFFCB0"
	bitesize = 2
	center_of_mass = list("x"=14, "y"=10)
	nutriment_amt = 4
	nutriment_desc = list("candy corn" = 4)
	preloaded_reagents = list("nutriment" = 4, "sugar" = 2)

/obj/item/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps"
	icon_state = "chips"
	trash = /obj/item/trash/chips
	filling_color = "#E8C31E"
	bitesize = 1
	center_of_mass = list("x"=15, "y"=15)
	nutriment_amt = 3
	nutriment_desc = list("salt" = 1, "chips" = 2)
	junk_food = TRUE
	spawn_tags = SPAWN_TAG_JUNKFOOD
	rarity_value = 15

/obj/item/reagent_containers/food/snacks/cookie
	name = "cookie"
	desc = "COOKIE!!!"
	icon_state = "COOKIE!!!"
	filling_color = "#DBC94F"
	bitesize = 1
	center_of_mass = list("x"=17, "y"=18)
	nutriment_amt = 5
	nutriment_desc = list("sweetness" = 3, "cookie" = 2)
	taste_tag = list(SWEET_FOOD)

/obj/item/reagent_containers/food/snacks/chocolatebar
	name = "Chocolate Bar"
	desc = "Such sweet, fattening food."
	icon_state = "chocolatebar"
	filling_color = "#7D5F46"
	bitesize = 2
	center_of_mass = list("x"=15, "y"=15)
	nutriment_amt = 2
	nutriment_desc = list("chocolate" = 5)
	preloaded_reagents = list("sugar" = 2, "coco" = 2)
	taste_tag = list(SWEET_FOOD, COCO_FOOD)

/obj/item/reagent_containers/food/snacks/chocolateegg
	name = "Chocolate Egg"
	desc = "Such sweet, fattening food."
	icon_state = "chocolateegg"
	filling_color = "#7D5F46"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=13)
	nutriment_amt = 3
	nutriment_desc = list("chocolate" = 5)
	preloaded_reagents = list("sugar" = 2, "coco" = 2)
	taste_tag = list(SWEET_FOOD, COCO_FOOD)

/obj/item/reagent_containers/food/snacks/donut
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
	filling_color = "#D9C386"
	var/overlay_state = "box-donut1"
	center_of_mass = list("x"=13, "y"=16)
	nutriment_desc = list("sweetness" = 2, "donut" = 3)
	taste_tag = list(SWEET_FOOD)

/obj/item/reagent_containers/food/snacks/donut/normal
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
	bitesize = 3
	nutriment_amt = 3
	preloaded_reagents = list("sprinkles" = 1)
	New()
		..()
		if(prob(30))
			src.icon_state = "donut2"
			src.overlay_state = "box-donut2"
			src.name = "frosted donut"
			reagents.add_reagent("sprinkles", 2)
			center_of_mass = list("x"=19, "y"=16)

/obj/item/reagent_containers/food/snacks/donut/chaos
	name = "Chaos Donut"
	desc = "Like life, it never quite tastes the same."
	icon_state = "donut1"
	filling_color = "#ED11E6"
	nutriment_amt = 2
	bitesize = 10
	preloaded_reagents = list("sprinkles" = 1)
	New()
		..()
		var/chaosselect = pick(1,2,3,4,5,6,7,8,9,10)
		switch(chaosselect)
			if(1)
				reagents.add_reagent("nutriment", 3)
			if(2)
				reagents.add_reagent("capsaicin", 3)
			if(3)
				reagents.add_reagent("frostoil", 3)
			if(4)
				reagents.add_reagent("sprinkles", 3)
			if(5)
				reagents.add_reagent("plasma", 3)
			if(6)
				reagents.add_reagent("coco", 3)
			if(7)
				reagents.add_reagent("slimejelly", 3)
			if(8)
				reagents.add_reagent("banana", 3)
			if(9)
				reagents.add_reagent("berryjuice", 3)
			if(10)
				reagents.add_reagent("tricordrazine", 3)
		if(prob(30))
			src.icon_state = "donut2"
			src.overlay_state = "box-donut2"
			src.name = "Frosted Chaos Donut"
			reagents.add_reagent("sprinkles", 2)


/obj/item/reagent_containers/food/snacks/donut/jelly
	name = "Jelly Donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#ED1169"
	center_of_mass = list("x"=16, "y"=11)
	nutriment_amt = 3
	bitesize = 5
	preloaded_reagents = list("sprinkles" = 1, "berryjuice" = 5)
	New()
		..()
		if(prob(30))
			src.icon_state = "jdonut2"
			src.overlay_state = "box-donut2"
			src.name = "Frosted Jelly Donut"
			reagents.add_reagent("sprinkles", 2)

/obj/item/reagent_containers/food/snacks/donut/slimejelly
	name = "Jelly Donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#ED1169"
	center_of_mass = list("x"=16, "y"=11)
	nutriment_amt = 3
	bitesize = 5
	preloaded_reagents = list("sprinkles" = 1, "slimejelly" = 5)
	New()
		..()
		if(prob(30))
			src.icon_state = "jdonut2"
			src.overlay_state = "box-donut2"
			src.name = "Frosted Jelly Donut"
			reagents.add_reagent("sprinkles", 2)

/obj/item/reagent_containers/food/snacks/donut/cherryjelly
	name = "Jelly Donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#ED1169"
	bitesize = 5
	center_of_mass = list("x"=16, "y"=11)
	nutriment_amt = 3
	preloaded_reagents = list("sprinkles" = 1, "cherryjelly" = 5)
	New()
		..()
		if(prob(30))
			src.icon_state = "jdonut2"
			src.overlay_state = "box-donut2"
			src.name = "Frosted Jelly Donut"
			reagents.add_reagent("sprinkles", 2)

/obj/item/reagent_containers/food/snacks/donut/stat_buff
	name = "Masterpiece Donut"
	desc = "The taste you will never forget."
	filling_color = "#ED1169"
	bitesize = 5
	center_of_mass = list("x"=16, "y"=11)
	var/list/stats_buff = list()
	var/buff_power = 10
	price_tag = 500
	var/buff_time = 20 MINUTES
	nutriment_amt = 3
	preloaded_reagents = list("sprinkles" = 2)

/obj/item/reagent_containers/food/snacks/donut/stat_buff/On_Consume(var/mob/eater, var/mob/feeder = null)
	..()
	if(eater.stats)
		for(var/stat in stats_buff)
			if(eater.stats.getTempStat(stat, "donut"))
				eater.stats.removeTempStat(stat, "donut")
				eater.stats.addTempStat(stat, buff_power, buff_time, "donut")
				to_chat(eater, SPAN_NOTICE("Your knowledge of [stat] feels renewed."))
			eater.stats.addTempStat(stat, buff_power, buff_time, "donut")
			to_chat(eater, SPAN_NOTICE("Your knowledge of [stat] are increased for a short period of time. Make use of it."))

/obj/item/reagent_containers/food/snacks/donut/stat_buff/mec
	name = "Yellow Masterpiece Donut"
	desc = "The sour citrus flavor you will never forget. A choice sweet of mechanics."
	icon_state = "donut_mec"
	overlay_state = "donut_mec_c"
	stats_buff = list(STAT_MEC)
	preloaded_reagents = list("sprinkles" = 1, "lemonjuice" = 1)

/obj/item/reagent_containers/food/snacks/donut/stat_buff/cog
	name = "Purple Masterpiece Donut"
	desc = "The too-sweet artificial grape taste you will never forget. An intellectual's favorite."
	icon_state = "donut_cog"
	overlay_state = "donut_cog_c"
	stats_buff = list(STAT_COG)

/obj/item/reagent_containers/food/snacks/donut/stat_buff/bio
	name = "Green Masterpiece Donut"
	desc = "The fresh spearmint flavor you will never forget. Perfect for an immaculate doctor."
	icon_state = "donut_bio"
	overlay_state = "donut_bio_c"
	stats_buff = list(STAT_BIO)
	preloaded_reagents = list("sprinkles" = 1, "mint" = 1)

/obj/item/reagent_containers/food/snacks/donut/stat_buff/rob
	name = "Brown Masterpiece Donut"
	desc = "A near-chocolate taste you will never forget. A robust flavor for the strong."
	icon_state = "donut_rob"
	overlay_state = "donut_rob_c"
	stats_buff = list(STAT_ROB)
	preloaded_reagents = list("sprinkles" = 1, "coco" = 1)

/obj/item/reagent_containers/food/snacks/donut/stat_buff/tgh
	name = "Cream Masterpiece Donut"
	desc = "The classic donut flavor you will never forget. Specially panders to tough people."
	icon_state = "donut_tgh"
	overlay_state = "donut_tgh_c"
	stats_buff = list(STAT_TGH)

/obj/item/reagent_containers/food/snacks/donut/stat_buff/vig
	name = "Blue Masterpiece Donut"
	desc = "A tart blueberry taste you will never forget. A go-to choice for the vigilant watchman."
	icon_state = "donut_vig"
	overlay_state = "donut_vig_c"
	stats_buff = list(STAT_VIG)
	preloaded_reagents = list("sprinkles" = 1, "berryjuice" = 1)

/obj/item/reagent_containers/food/snacks/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"
	filling_color = "#FDFFD1"
	volume = 10
	center_of_mass = list("x"=16, "y"=13)
	preloaded_reagents = list("egg" = 3)

/obj/item/reagent_containers/food/snacks/egg/afterattack(obj/O as obj, mob/user as mob, proximity)
	if(istype(O,/obj/machinery/microwave))
		return ..()
	if(!proximity || !O.is_refillable())
		return
	to_chat(user, "You crack \the [src] into \the [O].")
	reagents.trans_to(O, reagents.total_volume)
	user.drop_from_inventory(src)
	qdel(src)

/obj/item/reagent_containers/food/snacks/egg/throw_impact(atom/hit_atom)
	..()
	new/obj/effect/decal/cleanable/egg_smudge(src.loc)
	src.reagents.splash(hit_atom, reagents.total_volume)
	src.visible_message(
		SPAN_WARNING("\The [src] has been squashed!"),
		SPAN_WARNING("You hear a smack.")
	)
	qdel(src)

/obj/item/reagent_containers/food/snacks/egg/attackby(obj/item/W as obj, mob/user as mob)
	if(istype( W, /obj/item/pen/crayon ))
		var/obj/item/pen/crayon/C = W
		var/clr = C.colourName
		if(!(clr in list("blue","green","mime","orange","purple","rainbow","red","yellow")))
			to_chat(usr, SPAN_NOTICE("The egg refuses to take on this color!"))
			return
		to_chat(user, SPAN_NOTICE("You color \the [src] [clr]"))
		icon_state = "egg-[clr]"
	else
		..()

/obj/item/reagent_containers/food/snacks/egg/blue
	icon_state = "egg-blue"

/obj/item/reagent_containers/food/snacks/egg/green
	icon_state = "egg-green"

/obj/item/reagent_containers/food/snacks/egg/mime
	icon_state = "egg-mime"

/obj/item/reagent_containers/food/snacks/egg/orange
	icon_state = "egg-orange"

/obj/item/reagent_containers/food/snacks/egg/purple
	icon_state = "egg-purple"

/obj/item/reagent_containers/food/snacks/egg/rainbow
	icon_state = "egg-rainbow"

/obj/item/reagent_containers/food/snacks/egg/red
	icon_state = "egg-red"

/obj/item/reagent_containers/food/snacks/egg/yellow
	icon_state = "egg-yellow"

/obj/item/reagent_containers/food/snacks/friedegg
	name = "Fried egg"
	desc = "A fried egg, with a touch of salt and pepper."
	icon_state = "friedegg"
	filling_color = "#FFDF78"
	bitesize = 1
	center_of_mass = list("x"=16, "y"=14)
	preloaded_reagents = list("protein" = 3, "sodiumchloride" = 1, "blackpepper" = 1)
	cooked = TRUE
	taste_tag = list(SALTY_FOOD,SPICY_FOOD)
/obj/item/reagent_containers/food/snacks/boiledegg
	name = "Boiled egg"
	desc = "A hard boiled egg."
	icon_state = "egg"
	filling_color = "#FFFFFF"
	preloaded_reagents = list("protein" = 2)
	taste_tag = list(BLAND_FOOD)

/obj/item/reagent_containers/food/snacks/tofu
	name = "Tofu"
	icon_state = "tofu"
	desc = "We all love tofu."
	filling_color = "#FFFEE0"
	bitesize = 3
	center_of_mass = list("x"=17, "y"=10)
	nutriment_amt = 3
	nutriment_desc = list("tofu" = 3, "goeyness" = 3)
	taste_tag = list(VEGETARIAN_FOOD, BLAND_FOOD)

/obj/item/reagent_containers/food/snacks/tofurkey
	name = "Tofurkey"
	desc = "A fake turkey made from tofu."
	icon_state = "tofurkey"
	filling_color = "#FFFEE0"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=8)
	nutriment_amt = 12
	nutriment_desc = list("turkey" = 3, "tofu" = 5, "goeyness" = 4)
	preloaded_reagents = list("stoxin" = 3)
	cooked = TRUE
	taste_tag = list(VEGETARIAN_FOOD,VEGAN_FOOD)

/obj/item/reagent_containers/food/snacks/stuffing
	name = "Stuffing"
	desc = "Moist, peppery breadcrumbs for filling the body cavities of dead birds. Dig in!"
	icon_state = "stuffing"
	filling_color = "#C9AC83"
	bitesize = 1
	center_of_mass = list("x"=16, "y"=10)
	nutriment_amt = 3
	nutriment_desc = list("dryness" = 2, "bread" = 2)
	taste_tag = list(MEAT_FOOD)

/obj/item/reagent_containers/food/snacks/fishfingers
	name = "Fish Fingers"
	desc = "A finger of fish."
	icon_state = "fishfingers"
	filling_color = "#FFDEFE"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=13)
	preloaded_reagents = list("protein" = 4, "carpotoxin" = 3)
	cooked = TRUE
	taste_tag = list(MEAT_FOOD)

/obj/item/reagent_containers/food/snacks/hugemushroomslice
	name = "huge mushroom slice"
	desc = "A slice from a huge mushroom."
	icon_state = "hugemushroomslice"
	filling_color = "#E0D7C5"
	bitesize = 6
	center_of_mass = list("x"=17, "y"=16)
	nutriment_amt = 3
	nutriment_desc = list("raw" = 2, "mushroom" = 2)
	preloaded_reagents = list("psilocybin" = 3)
	taste_tag = list(VEGAN_FOOD,VEGAN_FOOD,UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/tomatomeat
	name = "tomato slice"
	desc = "A slice from a huge tomato"
	icon_state = "tomatomeat"
	filling_color = "#DB0000"
	bitesize = 6
	center_of_mass = list("x"=17, "y"=16)
	nutriment_amt = 3
	nutriment_desc = list("raw" = 2, "tomato" = 3)
	taste_tag = list(VEGAN_FOOD,VEGETARIAN_FOOD)

/obj/item/reagent_containers/food/snacks/meatball
	name = "meatball"
	desc = "A great meal all round."
	icon_state = "meatball"
	filling_color = "#DB0000"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=16)
	preloaded_reagents = list("protein" = 3)
	taste_tag = list(MEAT_FOOD,SALTY_FOOD)

/obj/item/reagent_containers/food/snacks/sausage
	name = "Sausage"
	desc = "A piece of mixed, long meat."
	icon_state = "sausage"
	filling_color = "#DB0000"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=16)
	preloaded_reagents = list("protein" = 6)
	taste_tag = list(MEAT_FOOD,SALTY_FOOD)

/obj/item/reagent_containers/food/snacks/donkpocket
	name = "Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	filling_color = "#DEDEAB"
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("heartiness" = 1, "dough" = 2)
	nutriment_amt = 2
	preloaded_reagents = list("protein" = 2)

	var/warm = 0
	var/list/heated_reagents = list("tricordrazine" = 5)
	proc/heat()
		warm = 1
		for(var/reagent in heated_reagents)
			reagents?.add_reagent(reagent, heated_reagents[reagent])
		bitesize = 6
		name = "Warm " + name
		cooltime()

	proc/cooltime()
		if (src.warm)
			spawn(4200)
				if(src)
					src.warm = 0
					src.name = initial(name)
					if(src.reagents)
						for(var/reagent in heated_reagents)
							src.reagents.del_reagent(reagent)

/obj/item/reagent_containers/food/snacks/donkpocket/sinpocket
	name = "\improper Sin-pocket"
	desc = "The food of choice for the veteran. Do <B>NOT</B> overconsume."
	filling_color = "#6D6D00"
	heated_reagents = list("doctorsdelight" = 5, "hyperzine" = 1)
	rarity_value = 20
	spawn_tags = SPAWN_TAG_RATIONS
	var/has_been_heated = 0


/obj/item/reagent_containers/food/snacks/donkpocket/sinpocket/attack_self(mob/user)
	if(has_been_heated)
		to_chat(user, SPAN_NOTICE("The heating chemicals have already been spent."))
		return
	has_been_heated = 1
	user.visible_message(
		SPAN_NOTICE("[user] crushes \the [src] package."),
		"You crush \the [src] package and feel a comfortable heat build up."
	)
	spawn(200)
		to_chat(user, "You think \the [src] is ready to eat about now.")
		heat()

/obj/item/reagent_containers/food/snacks/brainburger
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	filling_color = "#F2B6EA"
	center_of_mass = list("x"=15, "y"=11)
	preloaded_reagents = list("protein" = 6, "alkysine" = 6)
	bitesize = 2
	taste_tag = list(MEAT_FOOD,SALTY_FOOD)

/obj/item/reagent_containers/food/snacks/human
	var/hname = ""
	var/job = null
	filling_color = "#D63C3C"
	taste_tag = list(MEAT_FOOD)

/obj/item/reagent_containers/food/snacks/human/burger
	name = "-burger"
	desc = "A bloody burger."
	icon_state = "hburger"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=11)
	preloaded_reagents = list("protein" = 6)
	taste_tag = list(MEAT_FOOD)

/obj/item/reagent_containers/food/snacks/cheeseburger
	name = "cheeseburger"
	desc = "The cheese adds a good flavor."
	icon_state = "cheeseburger"
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("cheese" = 2, "bun" = 2)
	nutriment_amt = 2
	preloaded_reagents = list("protein" = 2)
	cooked = TRUE
	taste_tag = list(CHEESE_FOOD,MEAT_FOOD)

/obj/item/reagent_containers/food/snacks/monkeyburger
	name = "burger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "hburger"
	filling_color = "#D63C3C"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("bun" = 2)
	nutriment_amt = 3
	preloaded_reagents = list("protein" = 3)
	cooked = TRUE
	taste_tag = list(MEAT_FOOD)

/obj/item/reagent_containers/food/snacks/fishburger
	name = "Fillet -o- Carp Sandwich"
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon_state = "fishburger"
	filling_color = "#FFDEFE"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=10)
	preloaded_reagents = list("protein" = 6, "carpotoxin" = 3)
	cooked = TRUE
	taste_tag = list(MEAT_FOOD) //fish taste would be nice here. but fish is something hard to get

/obj/item/reagent_containers/food/snacks/tofuburger
	name = "Tofu Burger"
	desc = "What.. is that meat?"
	icon_state = "tofuburger"
	filling_color = "#FFFEE0"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("bun" = 2, "pseudo-soy meat" = 3)
	nutriment_amt = 6
	cooked = TRUE
	taste_tag = list(VEGETARIAN_FOOD,VEGAN_FOOD)

/obj/item/reagent_containers/food/snacks/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	filling_color = "#CCCCCC"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("bun" = 2, "metal" = 3)
	nutriment_amt = 2
	New()
		..()
		if(prob(5))
			reagents.add_reagent("nanites", 2)
	taste_tag = list(BLAND_FOOD)

/obj/item/reagent_containers/food/snacks/roburgerbig
	name = "roburger"
	desc = "This massive patty looks like poison. Beep."
	icon_state = "roburger"
	filling_color = "#CCCCCC"
	bitesize = 0.1
	volume = 100
	center_of_mass = list("x"=16, "y"=11)

	New()
		..()
		reagents.add_reagent("nanites", 100)
		bitesize = 0.1
	taste_tag = list(INSECTS_FOOD)

/obj/item/reagent_containers/food/snacks/xenoburger
	name = "xenoburger"
	desc = "Smells caustic. Tastes like heresy."
	icon_state = "xburger"
	filling_color = "#43DE18"
	center_of_mass = list("x"=16, "y"=11)

	New()
		..()
		reagents.add_reagent("protein", 8)
		bitesize = 2
	taste_tag = list(INSECTS_FOOD)

/obj/item/reagent_containers/food/snacks/clownburger
	name = "Clown Burger"
	desc = "This tastes funny..."
	icon_state = "clownburger"
	filling_color = "#FF00FF"
	bitesize = 2
	center_of_mass = list("x"=17, "y"=12)
	nutriment_desc = list("bun" = 2, "clown shoe" = 3)
	nutriment_amt = 6

/obj/item/reagent_containers/food/snacks/mimeburger
	name = "Mime Burger"
	desc = "Its taste defies language."
	icon_state = "mimeburger"
	filling_color = "#FFFFFF"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("bun" = 2, "mime paint" = 3)
	nutriment_amt = 6

/obj/item/reagent_containers/food/snacks/kampferburger
	name = "Kampfer Burger"
	desc = "Tasty but it's a bit of a struggle to get it down"
	icon_state = "kampferburger"
	bitesize = 1
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("bun" = 2)
	nutriment_amt = 2
	preloaded_reagents = list("protein" = 4)
	cooked = TRUE
	taste_tag = list(INSECTS_FOOD,MEAT_FOOD)

/obj/item/reagent_containers/food/snacks/panzerburger
	name = "Panzer Burger"
	desc = "Surprisingly heavy but seems to be made up of mostly shell"
	icon_state = "panzerburger"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("bun" = 2)
	nutriment_amt = 1
	preloaded_reagents = list("protein" = 8)
	cooked = TRUE
	taste_tag = list(INSECTS_FOOD,MEAT_FOOD)
/obj/item/reagent_containers/food/snacks/jagerburger
	name = "Jager Burger"
	desc = "The hunter becomes the hunted"
	icon_state = "jagerburger"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("bun" = 2)
	nutriment_amt = 3
	preloaded_reagents = list("protein" = 6)
	cooked = TRUE
	taste_tag = list(INSECTS_FOOD,MEAT_FOOD)
/obj/item/reagent_containers/food/snacks/seucheburger
	name = "Seuche Burger"
	desc = "The Burger that anti vaxxers love"
	icon_state = "seucheburger"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("bun" = 2)
	nutriment_amt = 2
	preloaded_reagents = list("protein" = 4)
	cooked = TRUE
	taste_tag = list(INSECTS_FOOD,MEAT_FOOD)
/obj/item/reagent_containers/food/snacks/bigroachburger
	name = "Big Roach Burger"
	desc = "Delicious finally some good food"
	icon_state = "bigroachburger"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("bun" = 2)
	nutriment_amt = 3
	preloaded_reagents = list("protein" = 8)
	cooked = TRUE
	taste_tag = list(INSECTS_FOOD,MEAT_FOOD)

/obj/item/reagent_containers/food/snacks/fuhrerburger
	name = "Fuhrer Burger"
	desc = "Its inability to take criticism makes this  one of the worst tasting burgers in existence"
	icon_state = "fuhrerburger"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("bun" = 2)
	nutriment_amt = 3
	preloaded_reagents = list("protein" = 8, "fuhrerole" = 3)
	cooked = TRUE
	taste_tag = list(INSECTS_FOOD,MEAT_FOOD)

/obj/item/reagent_containers/food/snacks/kaiserburger
	name = "Kaiser Burger"
	desc = "The rare experience for your taste buds"
	icon_state = "kaiserburger"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("bun" = 2)
	nutriment_amt = 3
	preloaded_reagents = list("protein" = 10)
	cooked = TRUE
	taste_tag = list(INSECTS_FOOD,MEAT_FOOD)

/obj/item/reagent_containers/food/snacks/roach_egg
	name = "boiled roach egg"
	desc = "A cockroach egg that has been boiled in salted water. It no longer pulses with an inner life."
	icon = 'icons/effects/effects.dmi'
	icon_state = "roach_egg"
	w_class = ITEM_SIZE_TINY
	bitesize = 4
	nutriment_amt = 8
	preloaded_reagents = list("protein" = 14)
	cooked = TRUE
	taste_tag = list(INSECTS_FOOD,MEAT_FOOD)


/obj/item/reagent_containers/food/snacks/omelette
	name = "Omelette Du Fromage"
	desc = "That's all you can say!"
	icon_state = "omelette"
	trash = /obj/item/trash/plate
	filling_color = "#FFF9A8"
	bitesize = 1
	center_of_mass = list("x"=16, "y"=13)
	preloaded_reagents = list("protein" = 8)
	cooked = TRUE
	taste_tag = list(CHEESE_FOOD)

/obj/item/reagent_containers/food/snacks/muffin
	name = "Muffin"
	desc = "A delicious and spongy little cake"
	icon_state = "muffin"
	filling_color = "#E0CF9B"
	bitesize = 2
	center_of_mass = list("x"=17, "y"=4)
	nutriment_desc = list("sweetness" = 3, "muffin" = 3)
	nutriment_amt = 6
	cooked = TRUE
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/pie
	name = "Banana Cream Pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	trash = /obj/item/trash/plate
	filling_color = "#FBFFB8"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=13)
	nutriment_desc = list("pie" = 3, "cream" = 2)
	nutriment_amt = 4
	preloaded_reagents = list("banana" = 5)
	cooked = TRUE
	junk_food = TRUE
	spawn_tags = SPAWN_TAG_JUNKFOOD
	rarity_value = 20
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/pie/throw_impact(atom/hit_atom)
	..()
	new/obj/effect/decal/cleanable/pie_smudge(src.loc)
	src.visible_message(
		SPAN_DANGER("\The [src.name] splats."),
		SPAN_DANGER("You hear a splat.")
	)
	qdel(src)

/obj/item/reagent_containers/food/snacks/berryclafoutis
	name = "Berry Clafoutis"
	desc = "No black birds, this is a good sign."
	icon_state = "berryclafoutis"
	bitesize = 3
	trash = /obj/item/trash/plate
	center_of_mass = list("x"=16, "y"=13)
	nutriment_desc = list("sweetness" = 2, "pie" = 3)
	nutriment_amt = 4
	preloaded_reagents = list("berryjuice" = 5)
	cooked = TRUE
	taste_tag = list(SWEET_FOOD,UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Mmm, waffles"
	icon_state = "waffles"
	trash = /obj/item/trash/waffles
	filling_color = "#E6DEB5"
	center_of_mass = list("x"=15, "y"=11)
	nutriment_desc = list("waffle" = 8)
	nutriment_amt = 8
	bitesize = 2
	cooked = TRUE
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/eggplantparm
	name = "Eggplant Parmigiana"
	desc = "The only good recipe for eggplant."
	icon_state = "eggplantparm"
	trash = /obj/item/trash/plate
	filling_color = "#4D2F5E"
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("cheese" = 3, "eggplant" = 3)
	nutriment_amt = 6
	bitesize = 2
	cooked = TRUE
	taste_tag = list(CHEESE_FOOD,VEGETARIAN_FOOD)

/obj/item/reagent_containers/food/snacks/soylentgreen
	name = "Soylent Green"
	desc = "Not made of people. Honest." //Totally people.
	icon_state = "soylent_green"
	trash = /obj/item/trash/waffles
	filling_color = "#B8E6B5"
	bitesize = 2
	center_of_mass = list("x"=15, "y"=11)
	preloaded_reagents = list("protein" = 10)
	cooked = TRUE
	taste_tag = list(VEGAN_FOOD,VEGETARIAN_FOOD)

/obj/item/reagent_containers/food/snacks/soylenviridians
	name = "Soylen Virdians"
	desc = "Not made of people. Honest." //Actually honest for once.
	icon_state = "soylent_yellow"
	trash = /obj/item/trash/waffles
	filling_color = "#E6FA61"
	bitesize = 2
	center_of_mass = list("x"=15, "y"=11)
	nutriment_desc = list("some sort of protein" = 10) //seasoned VERY well.
	nutriment_amt = 10
	cooked = TRUE
	taste_tag = list(MEAT_FOOD,UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/meatpie
	name = "Meat-pie"
	icon_state = "meatpie"
	desc = "An old barber recipe, very delicious!"
	trash = /obj/item/trash/plate
	filling_color = "#948051"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=13)
	preloaded_reagents = list("protein" = 10)
	cooked = TRUE
	taste_tag = list(MEAT_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/tofupie
	name = "Tofu-pie"
	icon_state = "meatpie"
	desc = "A delicious tofu pie."
	trash = /obj/item/trash/plate
	filling_color = "#FFFEE0"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=13)
	nutriment_desc = list("tofu" = 2, "pie" = 8)
	nutriment_amt = 10
	cooked = TRUE
	taste_tag = list(VEGETARIAN_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"
	filling_color = "#FFCCCC"
	bitesize = 3
	center_of_mass = list("x"=17, "y"=9)
	nutriment_desc = list("sweetness" = 3, "mushroom" = 3, "pie" = 2)
	nutriment_amt = 5
	preloaded_reagents = list("amatoxin" = 3, "psilocybin" = 1)
	cooked = TRUE
	taste_tag = list(SWEET_FOOD, UMAMI_FOOD,CHEESE_FOOD)

/obj/item/reagent_containers/food/snacks/plump_pie
	name = "plump pie"
	desc = "I bet you love stuff made out of plump helmets!"
	icon_state = "plump_pie"
	filling_color = "#B8279B"
	bitesize = 2
	center_of_mass = list("x"=17, "y"=9)
	nutriment_desc = list("heartiness" = 2, "mushroom" = 3, "pie" = 3)
	nutriment_amt = 8
	cooked = TRUE
	taste_tag = list(SWEET_FOOD)
	New()
		..()
		if(prob(10))
			name = "exceptional plump pie"
			desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump pie!"
			reagents.add_reagent("tricordrazine", 5)
	taste_tag = list(SWEET_FOOD, UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/xemeatpie
	name = "Xeno-pie"
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	trash = /obj/item/trash/plate
	filling_color = "#43DE18"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=13)
	preloaded_reagents = list("protein" = 10)
	taste_tag = list(MEAT_FOOD)

/obj/item/reagent_containers/food/snacks/wingfangchu
	name = "Wing Fang Chu"
	desc = "A savory dish of alien wing wang in soy."
	icon_state = "wingfangchu"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#43DE18"
	bitesize = 2
	center_of_mass = list("x"=17, "y"=9)
	preloaded_reagents = list("protein" = 6)
	taste_tag = list(MEAT_FOOD,SALTY_FOOD)

/obj/item/reagent_containers/food/snacks/human/kabob
	name = "-kabob"
	icon_state = "kabob"
	desc = "A human meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#A85340"
	bitesize = 2
	center_of_mass = list("x"=17, "y"=15)
	preloaded_reagents = list("protein" = 8)
	taste_tag = list(MEAT_FOOD,SALTY_FOOD)

/obj/item/reagent_containers/food/snacks/monkeykabob
	name = "Meat-kabob"
	icon_state = "kabob"
	desc = "Delicious meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#A85340"
	bitesize = 2
	center_of_mass = list("x"=17, "y"=15)
	preloaded_reagents = list("protein" = 8)
	taste_tag = list(MEAT_FOOD,SALTY_FOOD)

/obj/item/reagent_containers/food/snacks/tofukabob
	name = "Tofu-kabob"
	icon_state = "kabob"
	desc = "Vegan meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#FFFEE0"
	bitesize = 2
	center_of_mass = list("x"=17, "y"=15)
	nutriment_desc = list("tofu" = 3, "metal" = 1)
	nutriment_amt = 8
	cooked = TRUE
	taste_tag = list(VEGETARIAN_FOOD, VEGAN_FOOD)

/obj/item/reagent_containers/food/snacks/cubancarp
	name = "Cuban Carp"
	desc = "A sandwich that burns your tongue and then leaves it numb!"
	icon_state = "cubancarp"
	trash = /obj/item/trash/plate
	filling_color = "#E9ADFF"
	bitesize = 3
	center_of_mass = list("x"=12, "y"=5)
	nutriment_desc = list("toasted bread" = 3)
	nutriment_amt = 3
	preloaded_reagents = list("protein" = 3, "carpotoxin" = 3, "capsaicin" = 3)
	cooked = TRUE
	taste_tag = list(MEAT_FOOD,SALTY_FOOD)

/obj/item/reagent_containers/food/snacks/popcorn
	name = "Popcorn"
	desc = "Now let's find some cinema."
	icon_state = "popcorn"
	trash = /obj/item/trash/popcorn
	var/unpopped = 0
	filling_color = "#FFFAD4"
	center_of_mass = list("x"=16, "y"=8)
	nutriment_desc = list("popcorn" = 3)
	nutriment_amt = 2
	bitesize = 0.1 //this snack is supposed to be eating during looooong time. And this it not dinner food! --rastaf0
	junk_food = TRUE
	spawn_tags = SPAWN_TAG_JUNKFOOD
	New()
		..()
		unpopped = rand(1,10)
	On_Consume()
		if(prob(unpopped))	//lol ...what's the point?
			to_chat(usr, SPAN_WARNING("You bite down on an un-popped kernel!"))
			unpopped = max(0, unpopped-1)
		..()

/obj/item/reagent_containers/food/snacks/sosjerky
	name = "Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"
	desc = "Beef jerky made from the finest space cows."
	trash = /obj/item/trash/sosjerky
	filling_color = "#631212"
	bitesize = 2
	center_of_mass = list("x"=15, "y"=9)
	preloaded_reagents = list("protein" = 4, "ammonia" = 2)
	junk_food = TRUE
	spawn_tags = SPAWN_TAG_JUNKFOOD

/obj/item/reagent_containers/food/snacks/no_raisin
	name = "4no Raisins"
	icon_state = "4no_raisins"
	desc = "Best raisins in the universe. Not sure why."
	trash = /obj/item/trash/raisins
	filling_color = "#343834"
	center_of_mass = list("x"=15, "y"=4)
	nutriment_desc = list("dried raisins" = 6)
	nutriment_amt = 6
	junk_food = TRUE
	spawn_tags = SPAWN_TAG_JUNKFOOD_RATIONS

/obj/item/reagent_containers/food/snacks/spacetwinkie
	name = "Space Twinkie"
	icon_state = "space_twinkie"
	desc = "Guaranteed to survive longer then you will."
	filling_color = "#FFE591"
	bitesize = 2
	center_of_mass = list("x"=15, "y"=11)
	preloaded_reagents = list("sugar" = 4)
	junk_food = TRUE
	spawn_tags = SPAWN_TAG_JUNKFOOD

/obj/item/reagent_containers/food/snacks/cheesiehonkers
	name = "Cheesie Honkers"
	icon_state = "cheesie_honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth"
	trash = /obj/item/trash/cheesie
	filling_color = "#FFA305"
	bitesize = 2
	center_of_mass = list("x"=15, "y"=9)
	nutriment_desc = list("cheese" = 5, "chips" = 2)
	nutriment_amt = 4
	junk_food = TRUE
	spawn_tags = SPAWN_TAG_JUNKFOOD
	taste_tag = list(CHEESE_FOOD)

/obj/item/reagent_containers/food/snacks/syndicake
	name = "Syndi-Cakes"
	icon_state = "syndi_cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	filling_color = "#FF5D05"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("sweetness" = 3, "cake" = 1)
	nutriment_amt = 4
	trash = /obj/item/trash/syndi_cakes
	preloaded_reagents = list("doctorsdelight" = 5)
	taste_tag = list(SWEET_FOOD)

/obj/item/reagent_containers/food/snacks/loadedbakedpotato
	name = "Loaded Baked Potato"
	desc = "Totally baked."
	icon_state = "loadedbakedpotato"
	filling_color = "#9C7A68"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("baked potato" = 3)
	nutriment_amt = 3
	preloaded_reagents = list("protein" = 3)
	cooked = TRUE

/obj/item/reagent_containers/food/snacks/fries
	name = "Space Fries"
	desc = "AKA: French Fries, Freedom Fries, etc."
	icon_state = "fries"
	trash = /obj/item/trash/plate
	filling_color = "#EDDD00"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("fresh fries" = 4)
	nutriment_amt = 4
	cooked = TRUE

/obj/item/reagent_containers/food/snacks/soydope
	name = "Soy Dope"
	desc = "Dope from a soy."
	icon_state = "soydope"
	trash = /obj/item/trash/plate
	filling_color = "#C4BF76"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("slime" = 2, "soy" = 2)
	nutriment_amt = 2
	taste_tag = list(BLAND_FOOD,VEGETARIAN_FOOD,VEGAN_FOOD)

/obj/item/reagent_containers/food/snacks/spagetti
	name = "Spaghetti"
	desc = "A bundle of raw spaghetti."
	icon_state = "spagetti"
	filling_color = "#EDDD00"
	bitesize = 1
	center_of_mass = list("x"=16, "y"=16)
	nutriment_desc = list("noodles" = 2)
	nutriment_amt = 1
	taste_tag = list(BLAND_FOOD,SALTY_FOOD)

/obj/item/reagent_containers/food/snacks/cheesyfries
	name = "Cheesy Fries"
	desc = "Fries. Covered in cheese. Duh."
	icon_state = "cheesyfries"
	trash = /obj/item/trash/plate
	filling_color = "#EDDD00"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("fresh fries" = 3, "cheese" = 3)
	nutriment_amt = 4
	preloaded_reagents = list("protein" = 2)
	cooked = TRUE
	taste_tag = list(CHEESE_FOOD,SALTY_FOOD)

/obj/item/reagent_containers/food/snacks/fortunecookie
	name = "Fortune cookie"
	desc = "A true prophecy in each cookie!"
	icon_state = "fortune_cookie"
	filling_color = "#E8E79E"
	bitesize = 2
	center_of_mass = list("x"=15, "y"=14)
	nutriment_desc = list("fortune cookie" = 2)
	nutriment_amt = 3
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/badrecipe
	name = "Burned mess"
	desc = "Someone should be demoted from chef for this."
	icon_state = "badrecipe"
	filling_color = "#211F02"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=12)
	preloaded_reagents = list("toxin" = 1, "carbon" = 3)

/obj/item/reagent_containers/food/snacks/meatsteak
	name = "Meat steak"
	desc = "A piece of hot spicy meat."
	icon_state = "meatstake"
	trash = /obj/item/trash/plate
	filling_color = "#7A3D11"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=13)
	preloaded_reagents = list("protein" = 4, "sodiumchloride" = 1, "blackpepper" = 1)
	cooked = TRUE
	taste_tag = list(MEAT_FOOD,SALTY_FOOD)

/obj/item/reagent_containers/food/snacks/spacylibertyduff
	name = "Spacy Liberty Duff"
	desc = "Jello gelatin, from Alfred Hubbard's cookbook"
	icon_state = "spacylibertyduff"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#42B873"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=8)
	nutriment_desc = list("mushroom" = 6)
	nutriment_amt = 6
	preloaded_reagents = list("psilocybin" = 6)
	cooked = TRUE
	taste_tag = list(BLAND_FOOD,UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/amanitajelly
	name = "Amanita Jelly"
	desc = "Looks curiously toxic"
	icon_state = "amanitajelly"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#ED0758"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=5)
	nutriment_desc = list("jelly" = 3, "mushroom" = 3)
	nutriment_amt = 6
	preloaded_reagents = list("amatoxin" = 6, "psilocybin" = 3)
	cooked = TRUE
	taste_tag = list(BLAND_FOOD,UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/poppypretzel
	name = "Poppy pretzel"
	desc = "It's all twisted up!"
	icon_state = "poppypretzel"
	bitesize = 2
	filling_color = "#916E36"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("poppy seeds" = 2, "pretzel" = 3)
	nutriment_amt = 5
	cooked = TRUE
	taste_tag = list(SWEET_FOOD,VEGAN_FOOD,VEGETARIAN_FOOD)

/obj/item/reagent_containers/food/snacks/meatballsoup
	name = "Meatball soup"
	desc = "You've got balls kid, BALLS!"
	icon_state = "meatballsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#785210"
	bitesize = 5
	center_of_mass = list("x"=16, "y"=8)
	preloaded_reagents = list("protein" = 8, "water" = 5)
	cooked = TRUE
	taste_tag = list(MEAT_FOOD,UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/slimesoup
	name = "slime soup"
	desc = "If no water is available, you may substitute tears."
	icon_state = "slimesoup" //nonexistant?
	filling_color = "#C4DBA0"
	bitesize = 5
	preloaded_reagents = list("slimejelly" = 5, "water" = 10)
	taste_tag = list(BLAND_FOOD,UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/bloodsoup
	name = "Tomato soup"
	desc = "Smells like copper."
	icon_state = "tomatosoup"
	filling_color = "#FF0000"
	bitesize = 5
	center_of_mass = list("x"=16, "y"=7)
	preloaded_reagents = list("protein" = 2, "blood" = 10, "water" = 5)
	taste_tag = list(BLAND_FOOD,MEAT_FOOD,SALTY_FOOD)

/obj/item/reagent_containers/food/snacks/clownstears
	name = "Clown's Tears"
	desc = "Not very funny."
	icon_state = "clownstears"
	filling_color = "#C4FBFF"
	center_of_mass = list("x"=16, "y"=7)
	nutriment_desc = list("salt" = 1, "the worst joke" = 3)
	nutriment_amt = 4
	bitesize = 5
	preloaded_reagents = list("banana" = 5, "water" = 10)
	taste_tag = list(SWEET_FOOD,SALTY_FOOD)

/obj/item/reagent_containers/food/snacks/vegetablesoup
	name = "Vegetable soup"
	desc = "A true vegan meal" //TODO
	icon_state = "vegetablesoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#AFC4B5"
	center_of_mass = list("x"=16, "y"=8)
	nutriment_desc = list("carot" = 2, "corn" = 2, "eggplant" = 2, "potato" = 2)
	nutriment_amt = 8
	bitesize = 5
	preloaded_reagents = list("water" = 5)
	cooked = TRUE
	taste_tag = list(VEGETARIAN_FOOD, VEGAN_FOOD)

/obj/item/reagent_containers/food/snacks/nettlesoup
	name = "Nettle soup"
	desc = "To think, the botanist would've beat you to death with one of these."
	icon_state = "nettlesoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#AFC4B5"
	center_of_mass = list("x"=16, "y"=7)
	nutriment_desc = list("salad" = 4, "egg" = 2, "potato" = 2)
	nutriment_amt = 8
	bitesize = 5
	preloaded_reagents = list("water" = 5, "tricordrazine" = 5)
	cooked = TRUE
	taste_tag = list(VEGETARIAN_FOOD, VEGAN_FOOD)

/obj/item/reagent_containers/food/snacks/mysterysoup
	name = "Mystery soup"
	desc = "The mystery is, why aren't you eating it?"
	icon_state = "mysterysoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#F082FF"
	center_of_mass = list("x"=16, "y"=6)
	nutriment_desc = list("backwash" = 1)
	nutriment_amt = 1
	bitesize = 5
	New()
		..()
		var/mysteryselect = pick(1,2,3,4,5,6,7,8,9,10)
		switch(mysteryselect)
			if(1)
				reagents.add_reagent("nutriment", 6)
				reagents.add_reagent("capsaicin", 3)
				reagents.add_reagent("tomatojuice", 2)
			if(2)
				reagents.add_reagent("nutriment", 6)
				reagents.add_reagent("frostoil", 3)
				reagents.add_reagent("tomatojuice", 2)
			if(3)
				reagents.add_reagent("nutriment", 5)
				reagents.add_reagent("water", 5)
				reagents.add_reagent("tricordrazine", 5)
			if(4)
				reagents.add_reagent("nutriment", 5)
				reagents.add_reagent("water", 10)
			if(5)
				reagents.add_reagent("nutriment", 2)
				reagents.add_reagent("banana", 10)
			if(6)
				reagents.add_reagent("nutriment", 6)
				reagents.add_reagent("blood", 10)
			if(7)
				reagents.add_reagent("slimejelly", 10)
				reagents.add_reagent("water", 10)
			if(8)
				reagents.add_reagent("carbon", 10)
				reagents.add_reagent("toxin", 10)
			if(9)
				reagents.add_reagent("nutriment", 5)
				reagents.add_reagent("tomatojuice", 10)
			if(10)
				reagents.add_reagent("nutriment", 6)
				reagents.add_reagent("tomatojuice", 5)
				reagents.add_reagent("imidazoline", 5)

/obj/item/reagent_containers/food/snacks/wishsoup
	name = "Wish Soup"
	desc = "I wish this was soup."
	icon_state = "wishsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#D1F4FF"
	center_of_mass = list("x"=16, "y"=11)
	bitesize = 5
	preloaded_reagents = list("water" = 10)
	New()
		..()
		if(prob(25))
			src.desc = "A wish come true!"
			reagents.add_reagent("nutriment", 8, list("something good" = 8))
	taste_tag = list(VEGETARIAN_FOOD, VEGAN_FOOD,BLAND_FOOD)

/obj/item/reagent_containers/food/snacks/hotchili
	name = "Hot Chili"
	desc = "A five alarm Texan Chili!"
	icon_state = "hotchili"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#FF3C00"
	center_of_mass = list("x"=15, "y"=9)
	nutriment_desc = list("chilli peppers" = 3)
	nutriment_amt = 3
	bitesize = 5
	preloaded_reagents = list("protein" = 3, "capsaicin" = 3, "tomatojuice" = 2)
	cooked = TRUE
	taste_tag = list(MEAT_FOOD,SPICY_FOOD)


/obj/item/reagent_containers/food/snacks/coldchili
	name = "Cold Chili"
	desc = "This slush is barely a liquid!"
	icon_state = "coldchili"
	filling_color = "#2B00FF"
	center_of_mass = list("x"=15, "y"=9)
	nutriment_desc = list("ice peppers" = 3)
	nutriment_amt = 3
	trash = /obj/item/trash/snack_bowl
	bitesize = 5
	preloaded_reagents = list("protein" = 3, "frostoil" = 3, "tomatojuice" = 2)
	cooked = TRUE
	taste_tag = list(MEAT_FOOD,SPICY_FOOD)

/obj/item/reagent_containers/food/snacks/monkeycube
	name = "monkey cube"
	desc = "Just add water!"
	reagent_flags = REFILLABLE
	icon_state = "monkeycube"
	bitesize = 12
	filling_color = "#ADAC7F"
	center_of_mass = list("x"=16, "y"=14)

	var/wrapped = FALSE
	var/monkey_type = "Monkey"
	preloaded_reagents = list("protein" = 10)
	taste_tag = list(MEAT_FOOD,SALTY_FOOD)

/obj/item/reagent_containers/food/snacks/monkeycube/attack_self(mob/user as mob)
	if(wrapped)
		Unwrap(user)

/obj/item/reagent_containers/food/snacks/monkeycube/proc/Expand()
	src.visible_message(SPAN_NOTICE("\The [src] expands!"))
	var/turf/T = get_turf(src)
	if(istype(T))
		new /mob/living/carbon/human/monkey(T)
	qdel(src)
	return TRUE

/obj/item/reagent_containers/food/snacks/monkeycube/proc/Unwrap(mob/user as mob)
	icon_state = "monkeycube"
	desc = "Just add water!"
	to_chat(user, "You unwrap the cube.")
	wrapped = FALSE
	reagent_flags |= REFILLABLE

/obj/item/reagent_containers/food/snacks/monkeycube/on_reagent_change()
	if(reagents.has_reagent("water"))
		Expand()

/obj/item/reagent_containers/food/snacks/monkeycube/wrapped
	desc = "Still wrapped in some paper."
	icon_state = "monkeycubewrap"
	reagent_flags = NONE
	wrapped = TRUE

/obj/item/reagent_containers/food/snacks/roachcube
	name = "Roach cube"
	desc = "It still twitches. Just add blood!"
	spawn_tags = SPAWN_TAG_ROACH
	spawn_frequency = 5
	rarity_value = 65
	reagent_flags = REFILLABLE
	icon_state = "roach"
	bitesize = 12
	bad_type = /obj/item/reagent_containers/food/snacks/roachcube
	preloaded_reagents = list("protein" = 10, "diplopterum" = 2)
	taste_tag = list(MEAT_FOOD)
	var/roach_type

/obj/item/reagent_containers/food/snacks/roachcube/on_reagent_change()
	if(reagents.has_reagent("blood"))
		Expand()

/obj/item/reagent_containers/food/snacks/roachcube/proc/Expand()
	visible_message(SPAN_NOTICE("\The [src] expands!"))
	var/turf/T = get_turf(src)
	if(istype(T))
		new roach_type(T)
	qdel(src)

/obj/item/reagent_containers/food/snacks/roachcube/kampfer
	name = "Kampfer cube"
	icon_state = "roach"
	roach_type = /mob/living/carbon/superior_animal/roach

/obj/item/reagent_containers/food/snacks/roachcube/roachling
	name = "Roachling cube"
	rarity_value = 60
	icon_state = "roachling"
	roach_type = /mob/living/carbon/superior_animal/roach/roachling

/obj/item/reagent_containers/food/snacks/roachcube/jager
	name = "Jager cube"
	rarity_value = 80
	icon_state = "jager"
	roach_type = /mob/living/carbon/superior_animal/roach/hunter

/obj/item/reagent_containers/food/snacks/roachcube/panzer
	name = "Panzer cube"
	rarity_value = 85
	icon_state = "panzer"
	roach_type = /mob/living/carbon/superior_animal/roach/tank

/obj/item/reagent_containers/food/snacks/roachcube/seuche
	name = "Seuche cube"
	rarity_value = 80
	icon_state = "seuche"
	roach_type = /mob/living/carbon/superior_animal/roach/support

/obj/item/reagent_containers/food/snacks/roachcube/gestrahlte
	name = "Gestrahlte cube"
	rarity_value = 85
	icon_state = "toxic"
	roach_type = /mob/living/carbon/superior_animal/roach/toxic

/obj/item/reagent_containers/food/snacks/roachcube/kraftwerk
	name = "Kraftwerk cube"
	rarity_value = 85
	icon_state = "techno"
	roach_type = /mob/living/carbon/superior_animal/roach/nanite

/obj/item/reagent_containers/food/snacks/roachcube/fuhrer
	name = "Fuhrer cube"
	rarity_value = 98
	icon_state = "fuhrer"
	roach_type = /mob/living/carbon/superior_animal/roach/fuhrer

/obj/item/reagent_containers/food/snacks/spellburger
	name = "Spell Burger"
	desc = "This is absolutely Ei Nath."
	icon_state = "spellburger"
	filling_color = "#D505FF"
	bitesize = 2
	nutriment_desc = list("magic" = 3, "buns" = 3)
	nutriment_amt = 6
	taste_tag = list(MEAT_FOOD,UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/bigbiteburger
	name = "Big Bite Burger"
	desc = "Forget the Big Mac. THIS is the future! It has big \"R\" stamped on it's bun."
	icon_state = "bigbiteburger"
	filling_color = "#E3D681"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("buns" = 4)
	nutriment_amt = 4
	preloaded_reagents = list("protein" = 10)
	cooked = TRUE
	taste_tag = list(MEAT_FOOD,SALTY_FOOD)

/obj/item/reagent_containers/food/snacks/enchiladas
	name = "Enchiladas"
	desc = "Viva La Mexico!"
	icon_state = "enchiladas"
	trash = /obj/item/trash/tray
	filling_color = "#A36A1F"
	bitesize = 4
	center_of_mass = list("x"=16, "y"=13)
	nutriment_desc = list("tortilla" = 3, "corn" = 3)
	nutriment_amt = 2
	preloaded_reagents = list("protein" = 6, "capsaicin" = 6)
	cooked = TRUE
	taste_tag = list(MEAT_FOOD,SPICY_FOOD)

/obj/item/reagent_containers/food/snacks/monkeysdelight
	name = "monkey's Delight"
	desc = "Eeee Eee!"
	icon_state = "monkeysdelight"
	trash = /obj/item/trash/tray
	filling_color = "#5C3C11"
	bitesize = 6
	center_of_mass = list("x"=16, "y"=13)
	preloaded_reagents = list("protein" = 10, "banana" = 5, "blackpepper" = 1, "sodiumchloride" = 1)
	cooked = TRUE
	taste_tag = list(MEAT_FOOD,SWEET_FOOD)

/obj/item/reagent_containers/food/snacks/baguette
	name = "Baguette"
	desc = "Bon appetit!"
	icon_state = "baguette"
	filling_color = "#E3D796"
	bitesize = 3
	center_of_mass = list("x"=18, "y"=12)
	nutriment_desc = list("french bread" = 6)
	nutriment_amt = 6
	preloaded_reagents = list("blackpepper" = 1, "sodiumchloride" = 1)
	cooked = TRUE
	taste_tag = list(BLAND_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/fishandchips
	name = "Fish and Chips"
	desc = "I do say so myself chap."
	icon_state = "fishandchips"
	filling_color = "#E3D796"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=16)
	nutriment_desc = list("salt" = 1, "chips" = 3)
	nutriment_amt = 3
	preloaded_reagents = list("protein" = 3, "carpotoxin" = 3)
	cooked = TRUE
	taste_tag = list(MEAT_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/sandwich
	name = "Sandwich"
	desc = "A grand creation of meat, cheese, bread, and several leaves of lettuce! Arthur Dent would be proud."
	icon_state = "sandwich"
	trash = /obj/item/trash/plate
	filling_color = "#D9BE29"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=4)
	nutriment_desc = list("bread" = 3, "cheese" = 3)
	nutriment_amt = 3
	preloaded_reagents = list("protein" = 3)
	cooked = TRUE
	junk_food = TRUE
	spawn_tags = SPAWN_TAG_JUNKFOOD
	rarity_value = 20
	taste_tag = list(CHEESE_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/toastedsandwich
	name = "Toasted Sandwich"
	desc = "Now if you only had a pepper bar."
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/plate
	filling_color = "#D9BE29"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=4)
	nutriment_desc = list("toasted bread" = 3, "cheese" = 3)
	nutriment_amt = 3
	preloaded_reagents = list("protein" = 3, "carbon" = 2)
	cooked = TRUE
	taste_tag = list(CHEESE_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/grilledcheese
	name = "Grilled Cheese Sandwich"
	desc = "Goes great with Tomato soup!"
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/plate
	filling_color = "#D9BE29"
	bitesize = 2
	nutriment_desc = list("toasted bread" = 3, "cheese" = 3)
	nutriment_amt = 3
	preloaded_reagents = list("protein" = 4)
	cooked = TRUE
	taste_tag = list(CHEESE_FOOD)

/obj/item/reagent_containers/food/snacks/tomatosoup
	name = "Tomato Soup"
	desc = "Drinking this feels like being a vampire! A tomato vampire..."
	icon_state = "tomatosoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#D92929"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=7)
	nutriment_desc = list("soup" = 5)
	nutriment_amt = 5
	preloaded_reagents = list("tomatojuice" = 10)
	cooked = TRUE
	taste_tag = list(BLAND_FOOD,SALTY_FOOD,VEGAN_FOOD,VEGETARIAN_FOOD)

/obj/item/reagent_containers/food/snacks/rofflewaffles
	name = "Roffle Waffles"
	desc = "Waffles from Roffle. Co."
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles
	filling_color = "#FF00F7"
	bitesize = 4
	center_of_mass = list("x"=15, "y"=11)
	nutriment_desc = list("waffle" = 7, "sweetness" = 1)
	nutriment_amt = 8
	preloaded_reagents = list("psilocybin" = 8)
	cooked = TRUE
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/stew
	name = "Stew"
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	filling_color = "#9E673A"
	bitesize = 10
	center_of_mass = list("x"=16, "y"=5)
	nutriment_desc = list("tomato" = 2, "potato" = 2, "carrot" = 2, "eggplant" = 2, "mushroom" = 2)
	nutriment_amt = 6
	preloaded_reagents = list("protein" = 4, "tomatojuice" = 5, "imidazoline" = 5, "water" = 5)
	cooked = TRUE
	taste_tag = list(VEGETARIAN_FOOD,SALTY_FOOD,UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/jelliedtoast
	name = "Jellied Toast"
	desc = "A slice of bread covered with delicious jam."
	icon_state = "jellytoast"
	trash = /obj/item/trash/plate
	filling_color = "#B572AB"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=8)
	nutriment_desc = list("toasted bread" = 2)
	nutriment_amt = 1
	taste_tag = list(SWEET_FOOD)

/obj/item/reagent_containers/food/snacks/jelliedtoast/cherry
	preloaded_reagents = list("cherryjelly" = 5)
	taste_tag = list(SWEET_FOOD)
/obj/item/reagent_containers/food/snacks/jelliedtoast/slime
	preloaded_reagents = list("slimejelly" = 5)
	taste_tag = list(UMAMI_FOOD)
/obj/item/reagent_containers/food/snacks/jellyburger
	name = "Jelly Burger"
	desc = "Culinary delight..?"
	icon_state = "jellyburger"
	filling_color = "#B572AB"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("buns" = 5)
	nutriment_amt = 5
	taste_tag = list(UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/jellyburger/slime
	preloaded_reagents = list("slimejelly" = 5)
	taste_tag = list(SWEET_FOOD)
/obj/item/reagent_containers/food/snacks/jellyburger/cherry
	preloaded_reagents = list("cherryjelly" = 5)
	taste_tag = list(UMAMI_FOOD)
/obj/item/reagent_containers/food/snacks/milosoup
	name = "Milosoup"
	desc = "The universes best soup! Yum!!!"
	icon_state = "milosoup"
	trash = /obj/item/trash/snack_bowl
	bitesize = 4
	center_of_mass = list("x"=16, "y"=7)
	nutriment_desc = list("soy" = 8)
	nutriment_amt = 8
	preloaded_reagents = list("water" = 5)
	cooked = TRUE
	taste_tag = list(VEGETARIAN_FOOD,VEGAN_FOOD,VEGETARIAN_FOOD)

/obj/item/reagent_containers/food/snacks/stewedsoymeat
	name = "Stewed Soy Meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	trash = /obj/item/trash/plate
	bitesize = 2
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("soy" = 4, "tomato" = 4)
	nutriment_amt = 8
	cooked = TRUE
	taste_tag = list(VEGETARIAN_FOOD,VEGAN_FOOD)

/obj/item/reagent_containers/food/snacks/boiledspagetti
	name = "Boiled Spaghetti"
	desc = "A plain dish of noodles, this sucks."
	icon_state = "spagettiboiled"
	trash = /obj/item/trash/plate
	filling_color = "#FCEE81"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("noodles" = 2)
	nutriment_amt = 2
	taste_tag = list(BLAND_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/boiledrice
	name = "Boiled Rice"
	desc = "A boring dish of boring rice."
	icon_state = "boiledrice"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#FFFBDB"
	bitesize = 2
	center_of_mass = list("x"=17, "y"=11)
	nutriment_desc = list("rice" = 2)
	nutriment_amt = 2
	taste_tag = list(BLAND_FOOD,VEGAN_FOOD,VEGETARIAN_FOOD)

/obj/item/reagent_containers/food/snacks/ricepudding
	name = "Rice Pudding"
	desc = "Where's the jam?"
	icon_state = "rpudding"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#FFFBDB"
	bitesize = 2
	center_of_mass = list("x"=17, "y"=11)
	nutriment_desc = list("rice" = 2)
	nutriment_amt = 4
	cooked = TRUE
	taste_tag = list(BLAND_FOOD,VEGAN_FOOD,VEGETARIAN_FOOD)

/obj/item/reagent_containers/food/snacks/pastatomato
	name = "Spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon_state = "pastatomato"
	trash = /obj/item/trash/plate
	filling_color = "#DE4545"
	bitesize = 4
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("tomato" = 3, "noodles" = 3)
	nutriment_amt = 6
	preloaded_reagents = list("tomatojuice" = 10)
	cooked = TRUE
	taste_tag = list(BLAND_FOOD,VEGAN_FOOD,VEGETARIAN_FOOD)

/obj/item/reagent_containers/food/snacks/meatballspagetti
	name = "Spaghetti & Meatballs"
	desc = "Now thats a nic'e meatball!"
	icon_state = "meatballspagetti"
	trash = /obj/item/trash/plate
	filling_color = "#DE4545"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("noodles" = 4)
	nutriment_amt = 4
	preloaded_reagents = list("protein" = 4)
	cooked = TRUE
	taste_tag = list(MEAT_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/spesslaw
	name = "Spesslaw"
	desc = "A lawyers favourite"
	icon_state = "spesslaw"
	filling_color = "#DE4545"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("noodles" = 4)
	nutriment_amt = 4
	preloaded_reagents = list("protein" = 4)
	cooked = TRUE
	taste_tag = list(MEAT_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/carrotfries
	name = "Carrot Fries"
	desc = "Tasty fries from fresh Carrots."
	icon_state = "carrotfries"
	trash = /obj/item/trash/plate
	filling_color = "#FAA005"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("carrot" = 3, "salt" = 1)
	nutriment_amt = 3
	preloaded_reagents = list("imidazoline" = 3)
	cooked = TRUE
	taste_tag = list(VEGETARIAN_FOOD,VEGAN_FOOD,UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/superbiteburger
	name = "Super Bite Burger"
	desc = "This is a mountain of a burger. FOOD!"
	icon_state = "superbiteburger"
	filling_color = "#CCA26A"
	bitesize = 10
	center_of_mass = list("x"=16, "y"=3)
	nutriment_desc = list("buns" = 25)
	nutriment_amt = 25
	preloaded_reagents = list("protein" = 25)
	cooked = TRUE
	taste_tag = list(MEAT_FOOD)

/obj/item/reagent_containers/food/snacks/candiedapple
	name = "Candied Apple"
	desc = "An apple coated in sugary sweetness."
	icon_state = "candiedapple"
	filling_color = "#F21873"
	bitesize = 3
	center_of_mass = list("x"=15, "y"=13)
	nutriment_desc = list("apple" = 3, "caramel" = 3, "sweetness" = 2)
	nutriment_amt = 3
	cooked = TRUE
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/applepie
	name = "Apple Pie"
	desc = "A pie containing sweet sweet love... or apple."
	icon_state = "applepie"
	filling_color = "#E0EDC5"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=13)
	nutriment_desc = list("sweetness" = 2, "apple" = 2, "pie" = 2)
	nutriment_amt = 4
	cooked = TRUE
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/cherrypie
	name = "Cherry Pie"
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"
	filling_color = "#FF525A"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("sweetness" = 2, "cherry" = 2, "pie" = 2)
	nutriment_amt = 4
	cooked = TRUE
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/twobread
	name = "Two Bread"
	desc = "It is very bitter and winy."
	icon_state = "twobread"
	filling_color = "#DBCC9A"
	bitesize = 3
	center_of_mass = list("x"=15, "y"=12)
	nutriment_desc = list("sourness" = 2, "bread" = 2)
	nutriment_amt = 2
	cooked = TRUE
	taste_tag = list(BLAND_FOOD,SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/jellysandwich
	name = "Jelly Sandwich"
	desc = "You wish you had some peanut butter to go with this..."
	icon_state = "jellysandwich"
	trash = /obj/item/trash/plate
	filling_color = "#9E3A78"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=8)
	nutriment_desc = list("bread" = 2)
	nutriment_amt = 2
	taste_tag = list(BLAND_FOOD,UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/jellysandwich/slime
	preloaded_reagents = list("slimejelly" = 5)
	taste_tag = list(UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/jellysandwich/cherry
	preloaded_reagents = list("cherryjelly" = 5)
	taste_tag = list(SWEET_FOOD)

/obj/item/reagent_containers/food/snacks/boiledslimecore
	name = "Boiled slime Core"
	desc = "A boiled red thing."
	icon_state = "boiledslimecore" //nonexistant?
	bitesize = 3
	preloaded_reagents = list("slimejelly" = 5)
	taste_tag = list(UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/mint
	name = "mint"
	desc = "it is only wafer thin."
	icon_state = "mint"
	filling_color = "#F2F2F2"
	bitesize = 1
	center_of_mass = list("x"=16, "y"=14)
	preloaded_reagents = list("mint" = 1)
	taste_tag = list(UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/mushroomsoup
	name = "chantrelle soup"
	desc = "A delicious and hearty mushroom soup."
	icon_state = "mushroomsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#E386BF"
	bitesize = 3
	center_of_mass = list("x"=17, "y"=10)
	nutriment_desc = list("mushroom" = 8, "milk" = 2)
	nutriment_amt = 8
	cooked = TRUE
	taste_tag = list(BLAND_FOOD,UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit
	name = "plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet, and well-minced dwarven wheat flour."
	icon_state = "phelmbiscuit"
	filling_color = "#CFB4C4"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=13)
	nutriment_desc = list("mushroom" = 4)
	nutriment_amt = 5
	cooked = TRUE
	New()
		..()
		if(prob(10))
			name = "exceptional plump helmet biscuit"
			desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump helmet biscuit!"
			reagents.add_reagent("nutriment", 3)
			reagents.add_reagent("tricordrazine", 5)
	taste_tag = list(BLAND_FOOD,UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#F0F2E4"
	bitesize = 1
	center_of_mass = list("x"=17, "y"=10)
	preloaded_reagents = list("protein" = 5)
	cooked = TRUE
	taste_tag = list(BLAND_FOOD,UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/beetsoup
	name = "beet soup"
	desc = "Wait, how do you spell it again..?"
	icon_state = "beetsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#FAC9FF"
	bitesize = 2
	center_of_mass = list("x"=15, "y"=8)
	nutriment_desc = list("tomato" = 4, "beet" = 4)
	nutriment_amt = 8
	cooked = TRUE
	New()
		..()
		name = pick(list("borsch","bortsch","borstch","borsh","borshch","borscht"))
	taste_tag = list(BLAND_FOOD,VEGAN_FOOD,VEGETARIAN_FOOD,UMAMI_FOOD)
/obj/item/reagent_containers/food/snacks/tossedsalad
	name = "tossed salad"
	desc = "A proper salad, basic and simple, with little bits of carrot, tomato and apple intermingled. Vegan!"
	icon_state = "herbsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#76B87F"
	center_of_mass = list("x"=17, "y"=11)
	nutriment_desc = list("salad" = 2, "tomato" = 2, "carrot" = 2, "apple" = 2)
	nutriment_amt = 8
	bitesize = 3
	cooked = TRUE
	taste_tag = list(VEGETARIAN_FOOD, VEGAN_FOOD)


/obj/item/reagent_containers/food/snacks/validsalad
	name = "valid salad"
	desc = "It's just a salad of questionable 'herbs' with meatballs and fried potato slices. Nothing suspicious about it."
	icon_state = "validsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#76B87F"
	center_of_mass = list("x"=17, "y"=11)
	nutriment_desc = list("100% real salad" = 2)
	nutriment_amt = 6
	bitesize = 3
	preloaded_reagents = list("protein" = 2)
	cooked = TRUE
	taste_tag = list(MEAT_FOOD)

/obj/item/reagent_containers/food/snacks/appletart
	name = "golden apple streusel tart"
	desc = "A tasty dessert that won't make it through a metal detector."
	icon_state = "gappletart"
	trash = /obj/item/trash/plate
	filling_color = "#FFFF00"
	center_of_mass = list("x"=16, "y"=18)
	nutriment_desc = list("apple" = 8)
	nutriment_amt = 8
	bitesize = 3
	preloaded_reagents = list("gold" = 5)
	cooked = TRUE
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

//mre food
/obj/item/reagent_containers/food/snacks/mre
	name = "mre"
	desc = "A closed mre, ready to be opened."
	icon_state = "mre"
	trash = /obj/item/trash/mre
	filling_color = "#948051"
	nutriment_desc = list("heartiness" = 1, "beans" = 3)
	nutriment_amt = 6
	preloaded_reagents = list("protein" = 3, "iron" = 10)
	cooked = TRUE
	reagent_flags = NONE
	var/warm = FALSE
	var/open = FALSE
	var/list/heated_reagents = list("tricordrazine" = 10)
	taste_tag = list(BLAND_FOOD)

/obj/item/reagent_containers/food/snacks/mre/attack_self(mob/user)
	if(!open)
		open()
		to_chat(user, SPAN_NOTICE("You tear \the [src] open."))
		return
	if(warm)
		to_chat(user, SPAN_NOTICE("You are pretty sure \the [src] can't be heated again."))
		return
	user.visible_message(
		SPAN_NOTICE("[user] crushes \the [src] package."),
		"You crush \the [src] package and feel a comfortable heat build up."
	)
	warm = TRUE
	spawn(300)
		to_chat(user, "You think \the [src] is ready to eat about now.")
		heat()

/obj/item/reagent_containers/food/snacks/mre/attack(mob/M as mob, mob/user as mob, def_zone)
	. = ..()
	if(!open)
		open()
		to_chat(user, SPAN_WARNING("You viciously open \the [src] with your teeth, you animal."))

/obj/item/reagent_containers/food/snacks/mre/proc/heat()
	for(var/reagent in heated_reagents)
		reagents.add_reagent(reagent, heated_reagents[reagent])
	bitesize = 6
	name = "warm " + name
	icon_state = "[initial(icon_state)]_hot"

/obj/item/reagent_containers/food/snacks/mre/proc/open(mob/user)
	icon_state = "[initial(icon_state)]_open"
	desc = "A plethora of steaming beans mixed with meat, ready for consumption."
	open = TRUE
	reagent_flags |= REFILLABLE

/obj/item/reagent_containers/food/snacks/mre/can
	name = "ration can"
	desc = "Can of stew meat, tab right on top for easy opening."
	icon_state = "ration_can"
	trash = /obj/item/trash/mre_can
	filling_color = "#948051"
	nutriment_desc = list("heartiness" = 1, "meat" = 3)
	nutriment_amt = 5
	preloaded_reagents = list("protein" = 6, "iron" = 2)
	heated_reagents = list("bicaridine" = 5, "kelotane" = 5)

/obj/item/reagent_containers/food/snacks/mre_paste
	name = "nutrient paste"
	desc = "A peachy looking paste."
	icon_state = "paste"
	trash = /obj/item/trash/mre_paste
	filling_color = "#DEDEAB"
	nutriment_desc = list("acrid peaches" = 2)
	bitesize = 2
	nutriment_amt = 3
	preloaded_reagents = list("hyperzine" = 8, "paracetamol" = 5)
	taste_tag = list(BLAND_FOOD)

/obj/item/reagent_containers/food/snacks/mre_cracker
	name = "enriched cracker"
	desc = "It's a salted cracker, the surface looks saturated with oil."
	icon_state = "mre_cracker"
	filling_color = "#F5DEB8"
	center_of_mass = list("x"=17, "y"=6)
	nutriment_desc = list("salt" = 1, "cracker" = 2)
	bitesize = 2
	nutriment_amt = 1
	preloaded_reagents = list("dexalinp" = 1, "steady" = 1, "nicotine" = 1)
	taste_tag = list(BLAND_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/candy/mre
	name = "morale bar"
	desc = "Some brand of non-melting military chocolate."
	icon_state = "mre_candy"
	trash = /obj/item/trash/mre_candy
	preloaded_reagents = list("sugar" = 3, "serotrotium" = 2)
	var/open = FALSE
	taste_tag = list(COCO_FOOD, SWEET_FOOD)

/obj/item/reagent_containers/food/snacks/candy/mre/attack_self(mob/user)
	if(!open)
		open()
		to_chat(user, SPAN_NOTICE("You tear \the [src] open."))
		return

/obj/item/reagent_containers/food/snacks/candy/mre/attack(mob/M as mob, mob/user as mob, def_zone)
	. = ..()
	if(!open)
		open()
		to_chat(user, SPAN_WARNING("You viciously rip \the [src] open with your teeth, swallowing some plastic in the process, you animal."))

/obj/item/reagent_containers/food/snacks/candy/mre/proc/open(mob/user)
	icon_state = "mre_candy_open"
	open = TRUE


/////////////////////////////////////////////////Sliceable////////////////////////////////////////
// All the food items that can be sliced into smaller bits like Meatbread and Cheesewheels

// sliceable is just an organization type path, it doesn't have any additional code or variables tied to it.

/obj/item/reagent_containers/food/snacks/sliceable
	w_class = ITEM_SIZE_NORMAL //Whole pizzas and cakes shouldn't fit in a pocket, you can slice them if you want to do that.

/obj/item/reagent_containers/food/snacks/sliceable/meatbread
	name = "meatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	icon_state = "meatbread"
	slice_path = /obj/item/reagent_containers/food/snacks/meatbreadslice
	slices_num = 5
	filling_color = "#FF7575"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=9)
	nutriment_desc = list("bread" = 10)
	nutriment_amt = 10
	preloaded_reagents = list("protein" = 20)
	taste_tag = list(MEAT_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/meatbreadslice
	name = "meatbread slice"
	desc = "A slice of delicious meatbread."
	icon_state = "meatbreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#FF7575"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=13)
	preloaded_reagents = list("protein" = 4, "nutriment" = 2)
	cooked = TRUE
	taste_tag = list(MEAT_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/sliceable/xenomeatbread
	name = "xenomeatbread loaf"
	desc = "The culinary base of every self-respecting eloquent gentleman. Extra Heretical."
	icon_state = "xenomeatbread"
	slice_path = /obj/item/reagent_containers/food/snacks/xenomeatbreadslice
	slices_num = 5
	filling_color = "#8AFF75"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=9)
	nutriment_desc = list("bread" = 10)
	nutriment_amt = 10
	preloaded_reagents = list("protein" = 20)
	taste_tag = list(MEAT_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/xenomeatbreadslice
	name = "xenomeatbread slice"
	desc = "A slice of delicious meatbread. Extra Heretical."
	icon_state = "xenobreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#8AFF75"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=13)
	nutriment_amt = 2
	nutriment_desc = list("bread" = 2)
	preloaded_reagents = list("protein" = 4)
	taste_tag = list(MEAT_FOOD,FLOURY_FOOD)


/obj/item/reagent_containers/food/snacks/sliceable/bananabread
	name = "Banana-nut bread"
	desc = "A heavenly and filling treat."
	icon_state = "bananabread"
	slice_path = /obj/item/reagent_containers/food/snacks/bananabreadslice
	slices_num = 5
	filling_color = "#EDE5AD"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=9)
	nutriment_desc = list("bread" = 10)
	nutriment_amt = 10
	preloaded_reagents = list("banana" = 20)
	taste_tag = list(VEGETARIAN_FOOD,SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/bananabreadslice
	name = "Banana-nut bread slice"
	desc = "A slice of delicious banana bread."
	icon_state = "bananabreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#EDE5AD"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=8)
	preloaded_reagents = list("banana" = 4, "nutriment" = 4)
	cooked = TRUE
	taste_tag = list(VEGETARIAN_FOOD,SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/sliceable/tofubread
	name = "Tofubread"
	icon_state = "Like meatbread but for vegetarians. Not guaranteed to give superpowers."
	icon_state = "tofubread"
	slice_path = /obj/item/reagent_containers/food/snacks/tofubreadslice
	slices_num = 5
	filling_color = "#F7FFE0"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=9)
	nutriment_desc = list("tofu" = 10)
	nutriment_amt = 30
	taste_tag = list(VEGETARIAN_FOOD,VEGETARIAN_FOOD,SALTY_FOOD)

/obj/item/reagent_containers/food/snacks/tofubreadslice
	name = "Tofubread slice"
	desc = "A slice of delicious tofubread."
	icon_state = "tofubreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#F7FFE0"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=13)
	nutriment_amt = 6
	nutriment_desc = list("tofu" = 2)
	cooked = TRUE
	taste_tag = list(VEGETARIAN_FOOD,VEGAN_FOOD)

/obj/item/reagent_containers/food/snacks/sliceable/carrotcake
	name = "Carrot Cake"
	desc = "A favorite desert of a certain wascally wabbit. Not a lie."
	icon_state = "carrotcake"
	slice_path = /obj/item/reagent_containers/food/snacks/carrotcakeslice
	slices_num = 5
	filling_color = "#FFD675"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("cake" = 10, "sweetness" = 10, "carrot" = 15)
	nutriment_amt = 25
	preloaded_reagents = list("imidazoline" = 10)
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/carrotcakeslice
	name = "Carrot Cake slice"
	desc = "Carrotty slice of Carrot Cake, carrots are good for your eyes! Also not a lie."
	icon_state = "carrotcake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FFD675"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=14)
	nutriment_amt = 5
	nutriment_desc = list("cake" = 2, "sweetness" = 2, "carrot" = 3)
	preloaded_reagents = list("imidazoline" = 2)
	cooked = TRUE
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/sliceable/braincake
	name = "Brain Cake"
	desc = "A squishy cake-thing."
	icon_state = "braincake"
	slice_path = /obj/item/reagent_containers/food/snacks/braincakeslice
	slices_num = 5
	filling_color = "#E6AEDB"
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("cake" = 10, "sweetness" = 10, "slime" = 15)
	nutriment_amt = 5
	bitesize = 2
	preloaded_reagents = list("protein" = 25, "alkysine" = 10)
	taste_tag = list(SWEET_FOOD,MEAT_FOOD)

/obj/item/reagent_containers/food/snacks/braincakeslice
	name = "Brain Cake slice"
	desc = "Lemme tell you something about prions. THEY'RE DELICIOUS."
	icon_state = "braincakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#E6AEDB"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=12)
	preloaded_reagents = list("protein" = 5, "nutriment" = 1, "alkysine" = 2)
	taste_tag = list(MEAT_FOOD,SWEET_FOOD)

/obj/item/reagent_containers/food/snacks/sliceable/cheesecake
	name = "Cheese Cake"
	desc = "DANGEROUSLY cheesy."
	icon_state = "cheesecake"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesecakeslice
	slices_num = 5
	filling_color = "#FAF7AF"
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("cake" = 10, "cream" = 10, "cheese" = 15)
	nutriment_amt = 10
	bitesize = 2
	preloaded_reagents = list("protein" = 15)
	taste_tag = list(CHEESE_FOOD)

/obj/item/reagent_containers/food/snacks/cheesecakeslice
	name = "Cheese Cake slice"
	desc = "Slice of pure cheestisfaction"
	icon_state = "cheesecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FAF7AF"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=14)
	preloaded_reagents = list("protein" = 3, "nutriment" = 2)
	cooked = TRUE
	taste_tag = list(CHEESE_FOOD)

/obj/item/reagent_containers/food/snacks/sliceable/plaincake
	name = "Vanilla Cake"
	desc = "A plain cake, not a lie."
	icon_state = "plaincake"
	slice_path = /obj/item/reagent_containers/food/snacks/plaincakeslice
	slices_num = 5
	filling_color = "#F7EDD5"
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("cake" = 10, "sweetness" = 10, "vanilla" = 15)
	nutriment_amt = 20
	taste_tag = list(BLAND_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/plaincakeslice
	name = "Vanilla Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "plaincake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#F7EDD5"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=14)
	preloaded_reagents = list("nutriment" = 4)
	cooked = TRUE
	taste_tag = list(FLOURY_FOOD,BLAND_FOOD)

/obj/item/reagent_containers/food/snacks/sliceable/orangecake
	name = "Orange Cake"
	desc = "A cake with added orange."
	icon_state = "orangecake"
	slice_path = /obj/item/reagent_containers/food/snacks/orangecakeslice
	slices_num = 5
	filling_color = "#FADA8E"
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("cake" = 10, "sweetness" = 10, "orange" = 15)
	nutriment_amt = 20
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/orangecakeslice
	name = "Orange Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "orangecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FADA8E"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=14)
	preloaded_reagents = list("nutriment" = 4)
	cooked = TRUE
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/sliceable/limecake
	name = "Lime Cake"
	desc = "A cake with added lime."
	icon_state = "limecake"
	slice_path = /obj/item/reagent_containers/food/snacks/limecakeslice
	slices_num = 5
	filling_color = "#CBFA8E"
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("cake" = 10, "sweetness" = 10, "lime" = 15)
	nutriment_amt = 20
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/limecakeslice
	name = "Lime Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "limecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#CBFA8E"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=14)
	preloaded_reagents = list("nutriment" = 4)
	cooked = TRUE
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/sliceable/lemoncake
	name = "Lemon Cake"
	desc = "A cake with added lemon."
	icon_state = "lemoncake"
	slice_path = /obj/item/reagent_containers/food/snacks/lemoncakeslice
	slices_num = 5
	filling_color = "#FAFA8E"
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("cake" = 10, "sweetness" = 10, "lemon" = 15)
	nutriment_amt = 20
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/lemoncakeslice
	name = "Lemon Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "lemoncake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FAFA8E"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=14)
	preloaded_reagents = list("nutriment" = 4)
	cooked = TRUE
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/sliceable/chocolatecake
	name = "Chocolate Cake"
	desc = "A cake with added chocolate"
	icon_state = "chocolatecake"
	slice_path = /obj/item/reagent_containers/food/snacks/chocolatecakeslice
	slices_num = 5
	filling_color = "#805930"
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("cake" = 10, "sweetness" = 10, "chocolate" = 15)
	nutriment_amt = 20
	taste_tag = list(COCO_FOOD, SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/chocolatecakeslice
	name = "Chocolate Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "chocolatecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#805930"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=14)
	preloaded_reagents = list("nutriment" = 4)
	cooked = TRUE
	taste_tag = list(COCO_FOOD, SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/sliceable/cheesewheel
	name = "Cheese wheel"
	desc = "A big wheel of delcious Cheddar."
	icon_state = "cheesewheel"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge
	slices_num = 5
	filling_color = "#FFF700"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("cheese" = 10)
	nutriment_amt = 10
	preloaded_reagents = list("protein" = 10)
	taste_tag = list(CHEESE_FOOD)

/obj/item/reagent_containers/food/snacks/cheesewedge
	name = "Cheese wedge"
	desc = "A wedge of delicious Cheddar. The cheese wheel it was cut from can't have gone far."
	icon_state = "cheesewedge"
	filling_color = "#FFF700"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=10)
	taste_tag = list(CHEESE_FOOD)

/obj/item/reagent_containers/food/snacks/sliceable/birthdaycake
	name = "Birthday Cake"
	desc = "Happy Birthday..."
	icon_state = "birthdaycake"
	slice_path = /obj/item/reagent_containers/food/snacks/birthdaycakeslice
	slices_num = 5
	filling_color = "#FFD6D6"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("cake" = 10, "sweetness" = 10)
	nutriment_amt = 20
	preloaded_reagents = list("sprinkles" = 10)
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/birthdaycakeslice
	name = "Birthday Cake slice"
	desc = "A slice of your birthday."
	icon_state = "birthdaycakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#FFD6D6"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=14)
	preloaded_reagents = list("nutriment" = 4, "sprinkles" = 2)
	taste_tag = list(SWEET_FOOD)

/obj/item/reagent_containers/food/snacks/sliceable/bread
	name = "Bread"
	icon_state = "Some plain old Earthen bread."
	icon_state = "bread"
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice
	slices_num = 5
	filling_color = "#FFE396"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=9)
	nutriment_desc = list("bread" = 6)
	nutriment_amt = 6
	taste_tag = list(BLAND_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/breadslice
	name = "Bread slice"
	desc = "A slice of home."
	icon_state = "breadslice"
	trash = /obj/item/trash/plate
	filling_color = "#D27332"
	nutriment_amt = 1
	bitesize = 2
	center_of_mass = list("x"=16, "y"=4)
	taste_tag = list(BLAND_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/sliceable/creamcheesebread
	name = "Cream Cheese Bread"
	desc = "Yum yum yum!"
	icon_state = "creamcheesebread"
	slice_path = /obj/item/reagent_containers/food/snacks/creamcheesebreadslice
	slices_num = 5
	filling_color = "#FFF896"
	center_of_mass = list("x"=16, "y"=9)
	nutriment_desc = list("bread" = 6, "cream" = 3, "cheese" = 3)
	nutriment_amt = 5
	bitesize = 2
	preloaded_reagents = list("protein" = 15)
	taste_tag = list(CHEESE_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/creamcheesebreadslice
	name = "Cream Cheese Bread slice"
	desc = "A slice of yum!"
	icon_state = "creamcheesebreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#FFF896"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=13)
	preloaded_reagents = list("protein" = 3)
	cooked = TRUE
	taste_tag = list(CHEESE_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/watermelonslice
	name = "Watermelon Slice"
	desc = "A slice of watery goodness."
	icon_state = "watermelonslice"
	filling_color = "#FF3867"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=10)
	preloaded_reagents = list("watermelonjuice" = 1)
	cooked = TRUE
	taste_tag = list(SWEET_FOOD)

/obj/item/reagent_containers/food/snacks/sliceable/applecake
	name = "Apple Cake"
	desc = "A cake centred with Apple"
	icon_state = "applecake"
	slice_path = /obj/item/reagent_containers/food/snacks/applecakeslice
	slices_num = 5
	filling_color = "#EBF5B8"
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("cake" = 10, "sweetness" = 10, "apple" = 15)
	nutriment_amt = 15
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/applecakeslice
	name = "Apple Cake slice"
	desc = "A slice of heavenly cake."
	icon_state = "applecakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#EBF5B8"
	bitesize = 2
	nutriment_amt = 3
	center_of_mass = list("x"=16, "y"=14)
	cooked = TRUE
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/sliceable/pumpkinpie
	name = "Pumpkin Pie"
	desc = "A delicious treat for the autumn months."
	icon_state = "pumpkinpie"
	slice_path = /obj/item/reagent_containers/food/snacks/pumpkinpieslice
	slices_num = 5
	filling_color = "#F5B951"
	center_of_mass = list("x"=16, "y"=10)
	nutriment_desc = list("pie" = 5, "cream" = 5, "pumpkin" = 5)
	nutriment_amt = 15
	taste_tag = list(SWEET_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/pumpkinpieslice
	name = "Pumpkin Pie slice"
	desc = "A slice of pumpkin pie, with whipped cream on top. Perfection."
	icon_state = "pumpkinpieslice"
	trash = /obj/item/trash/plate
	filling_color = "#F5B951"
	bitesize = 2
	nutriment_amt = 3
	center_of_mass = list("x"=16, "y"=12)
	cooked = TRUE
	taste_tag = list(SWEET_FOOD)

/obj/item/reagent_containers/food/snacks/cracker
	name = "Cracker"
	desc = "It's a salted cracker."
	icon_state = "cracker"
	filling_color = "#F5DEB8"
	center_of_mass = list("x"=17, "y"=6)
	nutriment_desc = list("salt" = 1, "cracker" = 2)
	nutriment_amt = 1
	taste_tag = list(BLAND_FOOD,SPICY_FOOD)



/////////////////////////////////////////////////PIZZA////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/sliceable/pizza
	slices_num = 6
	filling_color = "#BAA14C"
	taste_tag = list(CHEESE_FOOD)
	spawn_tags = SPAWN_TAG_PIZZA
	bad_type = /obj/item/reagent_containers/food/snacks/sliceable/pizza

/obj/item/reagent_containers/food/snacks/sliceable/pizza/margherita
	name = "Margherita"
	desc = "The golden standard of pizzas."
	icon_state = "pizzamargherita"
	slice_path = /obj/item/reagent_containers/food/snacks/margheritaslice
	slices_num = 6
	bitesize = 2
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("pizza crust" = 10, "tomato" = 10, "cheese" = 15)
	nutriment_amt = 35
	preloaded_reagents = list("protein" = 5, "tomatojuice" = 6)

/obj/item/reagent_containers/food/snacks/margheritaslice
	name = "Margherita slice"
	desc = "A slice of the classic pizza."
	icon_state = "pizzamargheritaslice"
	filling_color = "#BAA14C"
	bitesize = 2
	center_of_mass = list("x"=18, "y"=13)
	preloaded_reagents = list("nutriment" = 5, "protein" = 1, "tomatojuice" = 1)
	cooked = TRUE
	taste_tag = list(CHEESE_FOOD)

/obj/item/reagent_containers/food/snacks/sliceable/pizza/meatpizza
	name = "Meatpizza"
	desc = "A pizza with meat topping."
	icon_state = "meatpizza"
	slice_path = /obj/item/reagent_containers/food/snacks/meatpizzaslice
	slices_num = 6
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("pizza crust" = 10, "tomato" = 10, "cheese" = 15)
	nutriment_amt = 10
	bitesize = 2
	preloaded_reagents = list("protein" = 34, "tomatojuice" = 6)
	taste_tag = list(MEAT_FOOD, CHEESE_FOOD)

/obj/item/reagent_containers/food/snacks/meatpizzaslice
	name = "Meatpizza slice"
	desc = "A slice of a meaty pizza."
	icon_state = "meatpizzaslice"
	filling_color = "#BAA14C"
	bitesize = 2
	center_of_mass = list("x"=18, "y"=13)
	preloaded_reagents = list("protein" = 7, "tomatojuice" = 1)
	cooked = TRUE
	taste_tag = list(MEAT_FOOD, CHEESE_FOOD)

/obj/item/reagent_containers/food/snacks/sliceable/pizza/mushroompizza
	name = "Mushroompizza"
	desc = "Very special pizza"
	icon_state = "mushroompizza"
	slice_path = /obj/item/reagent_containers/food/snacks/mushroompizzaslice
	slices_num = 6
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("pizza crust" = 10, "tomato" = 10, "cheese" = 5, "mushroom" = 10)
	nutriment_amt = 35
	bitesize = 2
	preloaded_reagents = list("protein" = 5)
	taste_tag = list(CHEESE_FOOD,UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/mushroompizzaslice
	name = "Mushroompizza slice"
	desc = "Maybe it is the last slice of pizza in your life."
	icon_state = "mushroompizzaslice"
	filling_color = "#BAA14C"
	bitesize = 2
	center_of_mass = list("x"=18, "y"=13)
	preloaded_reagents = list("nutriment" = 5, "protein" = 1)
	cooked = TRUE
	taste_tag = list(CHEESE_FOOD,UMAMI_FOOD)


/obj/item/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza
	name = "Vegetable pizza"
	desc = "No one of Tomato Sapiens were harmed during making this pizza"
	icon_state = "vegetablepizza"
	slice_path = /obj/item/reagent_containers/food/snacks/vegetablepizzaslice
	slices_num = 6
	center_of_mass = list("x"=16, "y"=11)
	nutriment_desc = list("pizza crust" = 10, "tomato" = 10, "cheese" = 5, "eggplant" = 5, "carrot" = 5, "corn" = 5)
	nutriment_amt = 25
	bitesize = 2
	preloaded_reagents = list("protein" = 5, "tomatojuice" = 6, "imidazoline" = 12)
	taste_tag = list(VEGETARIAN_FOOD, CHEESE_FOOD)

/obj/item/reagent_containers/food/snacks/vegetablepizzaslice
	name = "Vegetable pizza slice"
	desc = "A slice of the most green pizza of all pizzas not containing green ingredients "
	icon_state = "vegetablepizzaslice"
	filling_color = "#BAA14C"
	bitesize = 2
	center_of_mass = list("x"=18, "y"=13)
	preloaded_reagents = list("nutriment" = 4, "protein" = 1, "tomatojuice" = 1, "imidazoline" = 2)
	cooked = TRUE
	taste_tag = list(VEGETARIAN_FOOD, CHEESE_FOOD)

/obj/item/pizzabox
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'icons/obj/food.dmi'
	icon_state = "pizzabox1"

	var/open = 0 // Is the box open?
	var/ismessy = 0 // Fancy mess on the lid
	var/obj/item/reagent_containers/food/snacks/sliceable/pizza/pizza // Content pizza
	var/type_pizza
	var/list/boxes = list() // If the boxes are stacked, they come here
	var/boxtag = ""

/obj/item/pizzabox/Initialize(mapload)
	. = ..()
	if(type_pizza)
		pizza = new type_pizza(src)

/obj/item/pizzabox/on_update_icon()
	set_overlays(list())

	// Set appropriate description
	if(open && pizza )
		desc = "A box suited for pizzas. It appears to have a [pizza.name] inside."
	else if(boxes.len > 0 )
		desc = "A pile of boxes suited for pizzas. There appears to be [boxes.len + 1] boxes in the pile."

		var/obj/item/pizzabox/topbox = boxes[boxes.len]
		var/toptag = topbox.boxtag
		if(toptag != "" )
			desc = "[desc] The box on top has a tag, it reads: '[toptag]'."
	else
		desc = "A box suited for pizzas."

		if(boxtag != "" )
			desc = "[desc] The box has a tag, it reads: '[boxtag]'."

	// Icon states and overlays
	if(open )
		if(ismessy )
			icon_state = "pizzabox_messy"
		else
			icon_state = "pizzabox_open"

		if(pizza )
			var/image/pizzaimg = image("food.dmi", icon_state = pizza.icon_state)
			pizzaimg.pixel_y = -3
			add_overlays(pizzaimg)

		return
	else
		// Stupid code because byondcode sucks
		var/doimgtag = 0
		if(boxes.len > 0 )
			var/obj/item/pizzabox/topbox = boxes[boxes.len]
			if(topbox.boxtag != "" )
				doimgtag = 1
		else
			if(boxtag != "" )
				doimgtag = 1

		if(doimgtag )
			var/image/tagimg = image("food.dmi", icon_state = "pizzabox_tag")
			tagimg.pixel_y = boxes.len * 3
			add_overlays(tagimg)

	icon_state = "pizzabox[boxes.len+1]"

/obj/item/pizzabox/attack_hand( mob/user as mob )

	if(open && pizza )
		user.put_in_hands( pizza )

		to_chat(user, SPAN_WARNING("You take \the [src.pizza] out of \the [src]."))
		src.pizza = null
		update_icon()
		return

	if(boxes.len > 0 )
		if(user.get_inactive_hand() != src )
			..()
			return

		var/obj/item/pizzabox/box = boxes[boxes.len]
		boxes -= box

		user.put_in_hands( box )
		to_chat(user, SPAN_WARNING("You remove the topmost [src] from your hand."))
		box.update_icon()
		update_icon()
		return
	..()

/obj/item/pizzabox/attack_self( mob/user as mob )

	if(boxes.len > 0 )
		return

	open = !open

	if(open && pizza )
		ismessy = 1

	update_icon()

/obj/item/pizzabox/attackby( obj/item/I as obj, mob/user as mob )
	if(istype(I, /obj/item/pizzabox/) )
		var/obj/item/pizzabox/box = I

		if(!box.open && !src.open )
			// Make a list of all boxes to be added
			var/list/boxestoadd = list()
			boxestoadd += box
			for(var/obj/item/pizzabox/i in box.boxes)
				boxestoadd += i

			if((boxes.len+1) + boxestoadd.len <= 5 )
				user.drop_from_inventory(box, src)
				box.boxes = list() // Clear the box boxes so we don't have boxes inside boxes. - Xzibit
				src.boxes.Add( boxestoadd )

				box.update_icon()
				update_icon()

				to_chat(user, SPAN_WARNING("You put \the [box] ontop of \the [src]!"))
			else
				to_chat(user, SPAN_WARNING("The stack is too high!"))
		else
			to_chat(user, SPAN_WARNING("Close \the [box] first!"))

		return

	if(istype(I, /obj/item/reagent_containers/food/snacks/sliceable/pizza) ) // Long ass fucking object name

		if(src.open )
			user.drop_from_inventory(I, src)
			src.pizza = I

			update_icon()

			to_chat(user, SPAN_WARNING("You put \the [I] in \the [src]!"))
		else
			to_chat(user, SPAN_WARNING("You try to push \the [I] through the lid but it doesn't work!"))
		return

	if(istype(I, /obj/item/pen/) )

		if(src.open )
			return

		var/t = sanitize(input("Enter what you want to add to the tag:", "Write", null, null) as text, 30)

		var/obj/item/pizzabox/boxtotagto = src
		if(boxes.len > 0 )
			boxtotagto = boxes[boxes.len]

		boxtotagto.boxtag = copytext("[boxtotagto.boxtag][t]", 1, 30)

		update_icon()
		return
	..()

/obj/item/pizzabox/margherita
	type_pizza = /obj/item/reagent_containers/food/snacks/sliceable/pizza/margherita
	boxtag = "Margherita Deluxe"

/obj/item/pizzabox/vegetable
	type_pizza = /obj/item/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza
	boxtag = "Gourmet Vegatable"

/obj/item/pizzabox/mushroom
	type_pizza = /obj/item/reagent_containers/food/snacks/sliceable/pizza/mushroompizza
	boxtag = "Mushroom Special"

/obj/item/pizzabox/meat
	type_pizza = /obj/item/reagent_containers/food/snacks/sliceable/pizza/meatpizza
	boxtag = "Meatlover's Supreme"


///////////////////////////////////////////
// new old food stuff from bs12
///////////////////////////////////////////
/obj/item/reagent_containers/food/snacks/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "dough"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=13)
	nutriment_desc = list("dough" = 3)
	nutriment_amt = 3
	preloaded_reagents = list("protein" = 1)
	taste_tag = list(BLAND_FOOD,FLOURY_FOOD)

// Dough + rolling pin = flat dough
/obj/item/reagent_containers/food/snacks/dough/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/material/kitchen/rollingpin))
		new /obj/item/reagent_containers/food/snacks/sliceable/flatdough(src)
		to_chat(user, "You flatten the dough.")
		qdel(src)

// slicable into 3xdoughslices
/obj/item/reagent_containers/food/snacks/sliceable/flatdough
	name = "flat dough"
	desc = "A flattened dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "flat dough"
	slice_path = /obj/item/reagent_containers/food/snacks/doughslice
	slices_num = 3
	center_of_mass = list("x"=16, "y"=16)
	preloaded_reagents = list("protein" = 1, "nutriment" = 3)
	taste_tag = list(BLAND_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/doughslice
	name = "dough slice"
	desc = "A building block of an impressive dish."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "doughslice"
	slice_path = /obj/item/reagent_containers/food/snacks/spagetti
	slices_num = 1
	bitesize = 2
	center_of_mass = list("x"=17, "y"=19)
	nutriment_desc = list("dough" = 1)
	nutriment_amt = 1
	taste_tag = list(BLAND_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/bun
	name = "bun"
	desc = "A base for any self-respecting burger."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "bun"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=12)
	nutriment_desc = list("bun" = 4)
	nutriment_amt = 4
	taste_tag = list(BLAND_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/bun/attackby(obj/item/W as obj, mob/user as mob)
	// Bun + meatball = burger
	if(istype(W,/obj/item/reagent_containers/food/snacks/meatball))
		new /obj/item/reagent_containers/food/snacks/monkeyburger(src)
		to_chat(user, "You make a burger.")
		qdel(W)
		qdel(src)

	// Bun + cutlet = hamburger
	else if(istype(W,/obj/item/reagent_containers/food/snacks/cutlet))
		new /obj/item/reagent_containers/food/snacks/monkeyburger(src)
		to_chat(user, "You make a burger.")
		qdel(W)
		qdel(src)

	// Bun + sausage = hotdog
	else if(istype(W,/obj/item/reagent_containers/food/snacks/sausage))
		new /obj/item/reagent_containers/food/snacks/hotdog(src)
		to_chat(user, "You make a hotdog.")
		qdel(W)
		qdel(src)

// Burger + cheese wedge = cheeseburger
/obj/item/reagent_containers/food/snacks/monkeyburger/attackby(obj/item/reagent_containers/food/snacks/cheesewedge/W as obj, mob/user as mob)
	if(istype(W))// && !istype(src,/obj/item/reagent_containers/food/snacks/cheesewedge))
		new /obj/item/reagent_containers/food/snacks/cheeseburger(src)
		to_chat(user, "You make a cheeseburger.")
		qdel(W)
		qdel(src)
		return
	else
		..()

// Human Burger + cheese wedge = cheeseburger
/obj/item/reagent_containers/food/snacks/human/burger/attackby(obj/item/reagent_containers/food/snacks/cheesewedge/W as obj, mob/user as mob)
	if(istype(W))
		new /obj/item/reagent_containers/food/snacks/cheeseburger(src)
		to_chat(user, "You make a cheeseburger.")
		qdel(W)
		qdel(src)
		return
	else
		..()

/obj/item/reagent_containers/food/snacks/taco
	name = "taco"
	desc = "Take a bite!"
	icon_state = "taco"
	bitesize = 3
	center_of_mass = list("x"=21, "y"=12)
	nutriment_desc = list("cheese" = 2, "taco shell" = 2)
	nutriment_amt = 4
	preloaded_reagents = list("protein" = 3)
	cooked = TRUE
	taste_tag = list(CHEESE_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/rawcutlet
	name = "raw cutlet"
	desc = "A thin piece of raw meat."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "rawcutlet"
	bitesize = 1
	center_of_mass = list("x"=17, "y"=20)
	preloaded_reagents = list("protein" = 1)
	taste_tag = list(MEAT_FOOD,FLOURY_FOOD)

/obj/item/reagent_containers/food/snacks/cutlet
	name = "cutlet"
	desc = "A tasty meat slice."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "cutlet"
	bitesize = 2
	center_of_mass = list("x"=17, "y"=20)
	preloaded_reagents = list("protein" = 2)
	taste_tag = list(MEAT_FOOD,SPICY_FOOD)

/obj/item/reagent_containers/food/snacks/rawmeatball
	name = "raw meatball"
	desc = "A raw meatball."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "rawmeatball"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=15)
	preloaded_reagents = list("protein" = 2)
	taste_tag = list(MEAT_FOOD)

/obj/item/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	desc = "Unrelated to dogs, maybe."
	icon_state = "hotdog"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=17)
	preloaded_reagents = list("protein" = 6)
	junk_food = TRUE
	spawn_tags = SPAWN_TAG_JUNKFOOD
	rarity_value = 20
	taste_tag = list(MEAT_FOOD)

/obj/item/reagent_containers/food/snacks/flatbread
	name = "flatbread"
	desc = "Bland but filling."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "flatbread"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=16)
	nutriment_desc = list("bread" = 3)
	nutriment_amt = 3
	taste_tag = list(BLAND_FOOD)

// potato + knife = raw sticks
/obj/item/reagent_containers/food/snacks/grown/potato/attackby(obj/item/I, mob/user) //this is obsolete??
	if(QUALITY_CUTTING in I.tool_qualities)
		if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, QUALITY_CUTTING, FAILCHANCE_ZERO, required_stat = STAT_BIO))
			new /obj/item/reagent_containers/food/snacks/rawsticks(src)
			to_chat(user, "You cut the potato.")
			qdel(src)
	else
		..()

/obj/item/reagent_containers/food/snacks/rawsticks
	name = "raw potato sticks"
	desc = "Raw fries, not very tasty."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "rawsticks"
	bitesize = 2
	center_of_mass = list("x"=16, "y"=12)
	nutriment_desc = list("raw potato" = 3)
	nutriment_amt = 3
	taste_tag = list(BLAND_FOOD,VEGAN_FOOD,VEGETARIAN_FOOD)

/obj/item/reagent_containers/food/snacks/liquidfood
	name = "\improper LiquidFood Ration"
	desc = "A prepackaged grey slurry of all the essential nutrients for a spacefarer on the go. Should this be crunchy?"
	icon_state = "liquidfood"
	trash = /obj/item/trash/liquidfood
	filling_color = "#A8A8A8"
	bitesize = 4
	center_of_mass = list("x"=16, "y"=15)
	nutriment_desc = list("chalk" = 6)
	preloaded_reagents = list("iron" = 3)
	nutriment_amt = 20
	junk_food = TRUE
	spawn_tags = SPAWN_TAG_JUNKFOOD_RATIONS
	rarity_value = 70
	taste_tag = list(BLAND_FOOD,UMAMI_FOOD)

/obj/item/reagent_containers/food/snacks/tastybread
	name = "bread tube"
	desc = "Bread in a tube. Chewy...and surprisingly tasty."
	icon_state = "tastybread"
	trash = /obj/item/trash/tastybread
	filling_color = "#A66829"
	bitesize = 2
	center_of_mass = list("x"=17, "y"=16)
	nutriment_desc = list("bread" = 2, "sweetness" = 3)
	nutriment_amt = 6
	junk_food = TRUE
	spawn_tags = SPAWN_TAG_JUNKFOOD_RATIONS
	taste_tag = list(SWEET_FOOD)

/obj/item/reagent_containers/food/snacks/pickle
	name = "pickle"
	desc = "A pickle. You smirk just from looking at it. \red Still funniest shit ever."
	icon = 'icons/obj/food.dmi'
	icon_state = "pickle"
	filling_color = "#5bd63c"
	preloaded_reagents = list("protein" = 100)

/obj/item/reagent_containers/food/snacks/pickle/On_Consume(mob/eater, mob/feeder)
	. = ..()
	to_chat(eater, SPAN_DANGER("You are feeling kind of funny"))
	var/mob/living/simple_animal/hostile/pickle/XD = new /mob/living/simple_animal/hostile/pickle(get_turf(eater))
	eater.mind?.transfer_to(XD)
	eater.gib()

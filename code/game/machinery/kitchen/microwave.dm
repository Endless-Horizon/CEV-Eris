
/obj/machinery/microwave
	name = "Microwave"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mw"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	reagent_flags = OPENCONTAINER | NO_REACT
	var/operating = 0 // Is it on?
	var/dirty = 0 // = {0..100} Does it need cleaning?
	var/broken = 0 // ={0,1,2} How broken is it???
	var/dinger = TRUE //so we don't have the campfire dinging
	var/global/list/datum/recipe/available_recipes // List of the recipes you can use
	var/global/list/acceptable_items // List of the items you can put in
	var/global/list/acceptable_reagents // List of the reagents you can put in
	var/global/max_n_of_items = 0


// see code/modules/food/recipes_microwave.dm for recipes

/*******************
*   Initialising
********************/

/obj/machinery/microwave/New()
	..()
	create_reagents(100)
	if(!available_recipes)
		available_recipes = new
		for (var/type in (typesof(/datum/recipe)-/datum/recipe))
			available_recipes+= new type
		acceptable_items = new
		acceptable_reagents = new
		for (var/datum/recipe/recipe in available_recipes)
			for (var/item in recipe.items)
				acceptable_items |= item
			for (var/reagent in recipe.reagents)
				acceptable_reagents |= reagent
			if(recipe.items)
				max_n_of_items = max(max_n_of_items,recipe.items.len)
		// This will do until I can think of a fun recipe to use dionaea in -
		// will also allow anything using the holder item to be microwaved into
		// impure carbon. ~Z
		acceptable_items |= /obj/item/holder
		acceptable_items |= /obj/item/reagent_containers/food/snacks/grown

/*******************
*   Item Adding
********************/

/obj/machinery/microwave/attackby(var/obj/item/I, var/mob/user)
	if(src.broken > 0)

		var/list/usable_qualities = list()
		if(broken == 2)
			usable_qualities.Add(QUALITY_SCREW_DRIVING)
		if(broken == 1)
			usable_qualities.Add(QUALITY_BOLT_TURNING)


		var/tool_type = I.get_tool_type(user, usable_qualities, src)
		switch(tool_type)

			if(QUALITY_SCREW_DRIVING)
				if(broken == 2)
					user.visible_message( \
						SPAN_NOTICE("\The [user] starts to fix part of the [src]."), \
						SPAN_NOTICE("You start to fix part of the [src].") \
					)
					if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
						user.visible_message( \
							SPAN_NOTICE("\The [user] fixes part of the [src]."), \
							SPAN_NOTICE("You have fixed part of the [src].") \
						)
						src.broken = 1
						return
					return

			if(QUALITY_BOLT_TURNING)
				if(broken == 1)
					user.visible_message( \
						SPAN_NOTICE("\The [user] starts to fix part of the [src]."), \
						SPAN_NOTICE("You start to fix part of the [src].") \
					)
					if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
						user.visible_message( \
							SPAN_NOTICE("\The [user] fixes the [src]."), \
							SPAN_NOTICE("You have fixed the [src].") \
						)
						src.icon_state = "mw"
						src.broken = 0 // Fix it!
						src.dirty = 0 // just to be sure
						src.reagent_flags = OPENCONTAINER
						return
					return

			if(ABORT_CHECK)
				return

//If we dont fix it with code above - return
		to_chat(user, SPAN_WARNING("It's broken!"))
		return

	else if(src.dirty==100) // The microwave is all dirty so can't be used!
		if(istype(I, /obj/item/reagent_containers/spray/cleaner)) // If they're trying to clean it then let them
			user.visible_message( \
				SPAN_NOTICE("\The [user] starts to clean the [src]."), \
				SPAN_NOTICE("You start to clean the [src].") \
			)
			if(do_after(user, 20, src))
				user.visible_message( \
					SPAN_NOTICE("\The [user] has cleaned the [src]."), \
					SPAN_NOTICE("You have cleaned the [src].") \
				)
				src.dirty = 0 // It's clean!
				src.broken = 0 // just to be sure
				src.icon_state = "mw"
				src.reagent_flags = OPENCONTAINER
		else //Otherwise bad luck!!
			to_chat(user, SPAN_WARNING("It's dirty!"))
			return 1
	else if(is_type_in_list(I,acceptable_items))
		if(length(contents) >= max_n_of_items)
			to_chat(user, SPAN_WARNING("This [src] is full of ingredients, you cannot put more."))
			return 1
		if(istype(I, /obj/item/stack) && I:get_amount() > 1) // This is bad, but I can't think of how to change it
			var/obj/item/stack/S = I
			new I.type (src)
			S.use(1)
			user.visible_message( \
				SPAN_NOTICE("\The [user] has added one of [I] to \the [src]."), \
				SPAN_NOTICE("You add one of [I] to \the [src]."))
			return
		else
		//	user.remove_from_mob(O)	//This just causes problems so far as I can tell. -Pete
			user.drop_item()
			I.loc = src
			user.visible_message( \
				SPAN_NOTICE("\The [user] has added \the [I] to \the [src]."), \
				SPAN_NOTICE("You add \the [I] to \the [src]."))
			return
	else if(istype(I,/obj/item/reagent_containers/glass) || \
	        istype(I,/obj/item/reagent_containers/food/drinks) || \
	        istype(I,/obj/item/reagent_containers/food/condiment) \
		)
		if(!I.reagents)
			return 1
		for (var/datum/reagent/R in I.reagents.reagent_list)
			if(!acceptable_reagents.Find(R.id))
				to_chat(user, SPAN_WARNING("Your [I] contains components unsuitable for cookery."))
				return 1
		return
	if(QUALITY_BOLT_TURNING in I.tool_qualities)
		user.visible_message( \
		"<span class='notice'>\The [user] begins [src.anchored ? "securing" : "unsecuring"] the [src].</span>", \
		"<span class='notice'>You attempt to [src.anchored ? "secure" : "unsecure"] the [src].</span>"
		)
		if(I.use_tool(user, src, WORKTIME_FAST, QUALITY_BOLT_TURNING, FAILCHANCE_EASY,  required_stat = STAT_MEC))
			user.visible_message( \
			"<span class='notice'>\The [user] [src.anchored ? "secures" : "unsecures"] the [src].</span>", \
			"<span class='notice'>You [src.anchored ? "secure" : "unsecure"] the [src].</span>"
			)
			src.anchored = !src.anchored
	else

		to_chat(user, SPAN_WARNING("You have no idea what you can cook with this [I]."))
	..()
	src.updateUsrDialog()

/obj/machinery/microwave/affect_grab(var/mob/user, var/mob/target)
	to_chat(user, SPAN_WARNING("This is ridiculous. You can not fit \the [target] in this [src]."))
	return FALSE

/obj/machinery/microwave/attack_ai(mob/user as mob)
	if(isrobot(user) && Adjacent(user))
		attack_hand(user)

/obj/machinery/microwave/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/*******************
*   Microwave Menu
********************/

/obj/machinery/microwave/interact(mob/user as mob) // The microwave Menu
	var/dat = ""
	if(src.broken > 0)
		dat = {"<TT>Bzzzzttttt</TT>"}
	else if(src.operating)
		dat = {"<TT>Cooking in progress!<BR>Please wait...!</TT>"}
	else if(src.dirty==100)
		dat = {"<TT>This [src] is dirty!<BR>Please clean it before use!</TT>"}
	else
		var/list/items_counts = new
		var/list/items_measures = new
		var/list/items_measures_p = new
		for (var/obj/O in contents)
			var/display_name = O.name
			if(istype(O,/obj/item/reagent_containers/food/snacks/egg))
				items_measures[display_name] = "egg"
				items_measures_p[display_name] = "eggs"
			if(istype(O,/obj/item/reagent_containers/food/snacks/tofu))
				items_measures[display_name] = "tofu chunk"
				items_measures_p[display_name] = "tofu chunks"
			if(istype(O,/obj/item/reagent_containers/food/snacks/meat)) //any meat
				items_measures[display_name] = "slab of meat"
				items_measures_p[display_name] = "slabs of meat"
			if(istype(O,/obj/item/reagent_containers/food/snacks/donkpocket))
				display_name = "Turnovers"
				items_measures[display_name] = "turnover"
				items_measures_p[display_name] = "turnovers"
			if(istype(O,/obj/item/reagent_containers/food/snacks/meat/carp))
				items_measures[display_name] = "fillet of meat"
				items_measures_p[display_name] = "fillets of meat"
			items_counts[display_name]++
		for (var/O in items_counts)
			var/N = items_counts[O]
			if(!items_measures.Find(O))
				dat += {"<B>[capitalize(O)]:</B> [N] [lowertext(O)]\s<BR>"}
			else
				if(N == 1)
					dat += {"<B>[capitalize(O)]:</B> [N] [items_measures[O]]<BR>"}
				else
					dat += {"<B>[capitalize(O)]:</B> [N] [items_measures_p[O]]<BR>"}

		for (var/datum/reagent/R in reagents.reagent_list)
			var/display_name = R.name
			if(R.id == "capsaicin")
				display_name = "Hotsauce"
			if(R.id == "frostoil")
				display_name = "Coldsauce"
			dat += {"<B>[display_name]:</B> [R.volume] unit\s<BR>"}

		if(length(items_counts) == 0 && length(reagents.reagent_list) == 0)
			dat = {"<B>The [src] is empty</B><BR>"}
		else
			dat = {"<b>Ingredients:</b><br>[dat]"}
		dat += {"<HR><BR>\
<A href='?src=\ref[src];action=cook'>Turn on!<BR>\
<A href='?src=\ref[src];action=dispose'>Eject ingredients!<BR>\
"}

	user << browse("<HEAD><TITLE>[src] Controls</TITLE></HEAD><TT>[dat]</TT>", "window=[src]")
	onclose(user, "[src]")
	return



/***********************************
*   Microwave Menu Handling/Cooking
************************************/

/obj/machinery/microwave/proc/cook()
	if(stat & (NOPOWER|BROKEN))
		return
	start()
	if(reagents.total_volume == 0 && !(locate(/obj) in contents)) //dry run
		if(!wzhzhzh(10))
			abort()
			return
		stop()
		return

	var/datum/recipe/recipe = select_recipe(available_recipes,src)
	var/obj/cooked
	if(!recipe)
		dirty += 1
		if(prob(max(10, dirty * 5)))
			if(!wzhzhzh(4))
				abort()
				return
			muck_start()
			wzhzhzh(4)
			muck_finish()
			cooked = fail()
			cooked.loc = src.loc
			return
		else if(has_extra_item())
			if(!wzhzhzh(4))
				abort()
			cooked = fail()
			cooked.loc = src.loc
			return
		else
			if(!wzhzhzh(10))
				abort()
				return
			stop()
			cooked = fail()
			cooked.loc = src.loc
			return
	else
		var/halftime = round(recipe.time/10/2)
		if(!wzhzhzh(halftime))
			abort()
			return
		if(!wzhzhzh(halftime))
			abort()
			cooked = fail()
			cooked.loc = src.loc
			return
		cooked = recipe.make_food(src)
		stop()
		if(cooked)
			cooked.loc = src.loc
		return

/obj/machinery/microwave/proc/wzhzhzh(var/seconds as num) // Whoever named this proc is fucking literally Satan. ~ Z
	for (var/i=1 to seconds)
		if(stat & (NOPOWER|BROKEN))
			return 0
		use_power(500)
		sleep(10)
	return 1

/obj/machinery/microwave/proc/has_extra_item()
	for (var/obj/O in contents)
		if(!istype(O,/obj/item/reagent_containers/food) && !istype(O, /obj/item/grown))
			return 1
	return 0

/obj/machinery/microwave/proc/start()
	src.visible_message(SPAN_NOTICE("The [src] turns on."), SPAN_NOTICE("You hear a [src]."))
	src.operating = 1
	src.icon_state = "mw1"
	src.updateUsrDialog()

/obj/machinery/microwave/proc/abort()
	src.operating = 0 // Turn it off again aferwards
	src.icon_state = "mw"
	src.updateUsrDialog()

/obj/machinery/microwave/proc/stop()
	if(dinger)
		playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	src.operating = 0 // Turn it off again aferwards
	src.icon_state = "mw"
	src.updateUsrDialog()

/obj/machinery/microwave/proc/dispose()
	for (var/obj/O in contents)
		O.loc = src.loc
	if(reagents.total_volume)
		dirty++
	reagents.clear_reagents()
	to_chat(usr, SPAN_NOTICE("You dispose of the [src] contents."))
	src.updateUsrDialog()

/obj/machinery/microwave/proc/muck_start()
	playsound(src.loc, 'sound/effects/splat.ogg', 50, 1) // Play a splat sound
	src.icon_state = "mwbloody1" // Make it look dirty!!

/obj/machinery/microwave/proc/muck_finish()
	if(dinger)
		playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	src.visible_message(SPAN_WARNING("The [src] gets covered in muck!"))
	src.dirty = 100 // Make it dirty so it can't be used util cleaned
	src.reagent_flags = NONE //So you can't add condiments
	src.icon_state = "mwbloody" // Make it look dirty too
	src.operating = 0 // Turn it off again aferwards
	src.updateUsrDialog()

/obj/machinery/microwave/proc/fail()
	var/obj/item/reagent_containers/food/snacks/badrecipe/ffuu = new(src)
	var/amount = 0
	for (var/obj/O in contents-ffuu)
		amount++
		if(O.reagents)
			var/id = O.reagents.get_master_reagent_id()
			if(id)
				amount+=O.reagents.get_reagent_amount(id)
		qdel(O)
	src.reagents.clear_reagents()
	ffuu.reagents.add_reagent("carbon", amount)
	ffuu.reagents.add_reagent("toxin", amount/10)
	return ffuu

/obj/machinery/microwave/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	if(src.operating)
		src.updateUsrDialog()
		return

	switch(href_list["action"])
		if("cook")
			cook()

		if("dispose")
			dispose()
	return

/obj/machinery/microwave/campfire
	name = "burn barrel"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "barrelfire"
	desc = "A fire in an old barrel. Perfect for campouts in the far corners of the ship."
	use_power = FALSE
	idle_power_usage = 0
	active_power_usage = 0
	dinger = FALSE
	var/lit = FALSE

/obj/machinery/microwave/campfire/verb/ToggleLight()
	set name = "Toggle Fire"
	set category = "Object"
	set src in view(1)

	if (!Adjacent(usr))
		to_chat(usr, SPAN_WARNING("You need to be in arm's reach for that!"))
		return

	if (usr.incapacitated())
		return

	if(!lit)
		playsound(loc, 'sound/effects/flare.ogg', 50, 1)
		visible_message(SPAN_NOTICE("The fire is stoked up."), SPAN_NOTICE("You hear a crackling fire."))
		icon_state = "barrelfire1"
		set_light(3,2)
		lit = TRUE
	else
		playsound(loc, 'sound/effects/flare.ogg', 50, 1)
		icon_state = "barrelfire"
		set_light(0)
		lit = FALSE

/obj/machinery/microwave/campfire/start()
	..()
	if(!lit)
		playsound(loc, 'sound/effects/flare.ogg', 50, 1)
		//playsound(loc, 'sound/effects/campfirecrackle.ogg', 50, 1) // I don't  know how to loop stuff
		visible_message(SPAN_NOTICE("The fire is stoked up."), SPAN_NOTICE("You hear a crackling fire."))
		icon_state = "barrelfire1"
		set_light(3,2)
		lit = TRUE
	else
		playsound(loc, 'sound/effects/flare.ogg', 50, 1)
		icon_state = "barrelfire1"
		visible_message(SPAN_NOTICE("You hear a crackling fire."))

/obj/machinery/microwave/campfire/abort()
	..()
	playsound(loc, 'sound/effects/flare.ogg', 50, 1)
	icon_state = "barrelfire1"	

/obj/machinery/microwave/campfire/stop()
	..()
	playsound(loc, 'sound/effects/flare.ogg', 50, 1)
	icon_state = "barrelfire1"
	
/obj/machinery/microwave/campfire/dispose()
	..()
	playsound(loc, 'sound/effects/flare.ogg', 50, 1)
	icon_state = "barrelfire1"

/obj/machinery/microwave/campfire/muck_start()
	..()
	icon_state = "barrelfire1"

/obj/machinery/microwave/campfire/muck_finish()
	..()
	playsound(loc, 'sound/effects/flare.ogg', 50, 1)
	icon_state = "barrelfire"
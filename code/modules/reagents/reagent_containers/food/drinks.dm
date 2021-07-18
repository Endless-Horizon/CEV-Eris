////////////////////////////////////////////////////////////////////////////////
/// Drinks.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food/drinks
	name = "drink"
	desc = "yummy"
	icon = 'icons/obj/drinks.dmi'
	icon_state = null
	reagent_flags = OPENCONTAINER
	amount_per_transfer_from_this = 5
	volume = 50
	bad_type = /obj/item/weapon/reagent_containers/food/drinks
	var/base_name // Name to put in front of drinks, i.e. "[base_name] of [contents]"
	var/base_icon // Base icon name for fill states

/obj/item/weapon/reagent_containers/food/drinks/Initialize()
	. = ..()
	if(is_drainable())
		verbs += /obj/item/weapon/reagent_containers/food/drinks/proc/gulp_whole

/obj/item/weapon/reagent_containers/food/drinks/on_reagent_change()
	update_icon()
	return

/obj/item/weapon/reagent_containers/food/drinks/attack_self(mob/user as mob)
	if(!is_open_container())
		open(user)

/obj/item/weapon/reagent_containers/food/drinks/proc/open(mob/user)
	playsound(loc, 'sound/effects/canopen.ogg', rand(10,50), 1)
	to_chat(user, SPAN_NOTICE("You open [src] with an audible pop!"))
	reagent_flags |= OPENCONTAINER
	verbs += /obj/item/weapon/reagent_containers/food/drinks/proc/gulp_whole

/obj/item/weapon/reagent_containers/food/drinks/attack(mob/M as mob, mob/user as mob, def_zone)
	if(force && !(flags & NOBLUDGEON) && user.a_intent == I_HURT)
		return ..()

	if(standard_feed_mob(user, M))
		return

	return 0

/obj/item/weapon/reagent_containers/food/drinks/afterattack(obj/target, mob/user, proximity)
	if(!proximity) return

	if(standard_pour_into(user, target))
		return
	if(standard_dispenser_refill(user, target))
		return
	return ..()

/obj/item/weapon/reagent_containers/food/drinks/is_closed_message(mob/user)
	to_chat(user, SPAN_NOTICE("You need to open [src] first!"))

/obj/item/weapon/reagent_containers/food/drinks/self_feed_message(var/mob/user)
	to_chat(user, SPAN_NOTICE("You swallow a gulp from \the [src]."))

/obj/item/weapon/reagent_containers/food/drinks/feed_sound(var/mob/user)
	playsound(user.loc, 'sound/items/drink.ogg', rand(10, 50), 1)

/obj/item/weapon/reagent_containers/food/drinks/on_update_icon()
	cut_overlays()
	if(reagents && reagents.total_volume)
		if(base_name)
			var/datum/reagent/R = reagents.get_master_reagent()
			SetName("[base_name] of [R.glass_name ? R.glass_name : "something"]")
			desc = R.glass_desc ? R.glass_desc : initial(desc)
		if(filling_states)
			var/mutable_appearance/filling = mutable_appearance(icon, "[base_icon][get_filling_state()]")
			filling.color = reagents.get_color()
			add_overlay(filling)
	else
		SetName(initial(name))
		desc = initial(desc)

/obj/item/weapon/reagent_containers/food/drinks/proc/gulp_whole()
	set category = "Object"
	set name = "Gulp Down"
	set src in view(1)

	if(isghost(usr))
		to_chat(usr, "You ghost!")
		return

	if(is_drainable())
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			if(!H.check_has_mouth())
				to_chat(H, "Where do you intend to put \the [src]? You don't have a mouth!")
				return
			var/obj/item/blocked = H.check_mouth_coverage()
			if(blocked)
				to_chat(H, SPAN_WARNING("\The [blocked] is in the way!"))
				return

		if(reagents.total_volume > 30) // 30 equates to 3 SECONDS.
			usr.visible_message(SPAN_NOTICE("[usr] prepares to gulp down [src]."), SPAN_NOTICE("You prepare to gulp down [src]."))
		if(!do_after(usr, reagents.total_volume))
			standard_splash_mob(usr, usr)
			return

		if(!Adjacent(usr))
			return

		usr.visible_message(SPAN_NOTICE("[usr] gulped down the whole [src]!"),SPAN_NOTICE("You gulped down the whole [src]!"))
		reagents.trans_to_mob(usr, reagents.total_volume, CHEM_INGEST)
		feed_sound(usr)
	else
		is_closed_message(usr)

////////////////////////////////////////////////////////////////////////////////
/// Drinks. END
////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/golden_cup
	desc = "A golden cup"
	name = "golden cup"
	icon_state = "golden_cup"
	item_state = "" //nope :(
	w_class = ITEM_SIZE_BULKY
	force = WEAPON_FORCE_PAINFUL
	throwforce = 10
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = null
	volume = 150
	flags = CONDUCT

///////////////////////////////////////////////Drinks
//Notes by Darem: Drinks are simply containers that start preloaded. Unlike condiments, the contents can be ingested directly
//	rather then having to add it to something else first. They should only contain liquids. They have a default container size of 50.
//	Formatting is the same as food.

/obj/item/weapon/reagent_containers/food/drinks/milk
	name = "Space Milk"
	desc = "It's milk. White and nutritious goodness!"
	icon_state = "milk"
	item_state = "carton"
	center_of_mass = list("x"=16, "y"=9)
	preloaded_reagents = list("milk" = 50)

/obj/item/weapon/reagent_containers/food/drinks/soymilk
	name = "SoyMilk"
	desc = "It's soy milk. White and nutritious goodness!"
	icon_state = "soymilk"
	item_state = "carton"
	center_of_mass = list("x"=16, "y"=9)
	preloaded_reagents = list("soymilk" = 50)

/obj/item/weapon/reagent_containers/food/drinks/coffee
	name = "Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "cup"
	center_of_mass = list("x"=15, "y"=10)
	base_icon = "cup"
	filling_states = "100"
	preloaded_reagents = list("coffee" = 30)

/obj/item/weapon/reagent_containers/food/drinks/ice
	name = "Ice Cup"
	desc = "Careful, cold ice, do not chew."
	icon_state = "cup"
	center_of_mass = list("x"=15, "y"=10)
	base_icon = "cup"
	filling_states = "100"
	preloaded_reagents = list("ice" = 30)

/obj/item/weapon/reagent_containers/food/drinks/h_chocolate
	name = "Dutch Hot Coco"
	desc = "Made in Space South America."
	icon_state = "hot_coco"
	item_state = "coffee"
	center_of_mass = list("x"=15, "y"=13)
	preloaded_reagents = list("hot_coco" = 30)

/obj/item/weapon/reagent_containers/food/drinks/dry_ramen
	name = "Cup Ramen"
	desc = "Just add 10ml water, self heats! A taste that reminds you of your school years."
	icon_state = "ramen"
	center_of_mass = list("x"=16, "y"=11)
	base_icon = "cup"
	filling_states = "100"
	preloaded_reagents = list("dry_ramen" = 30)
	spawn_tags = SPAWN_TAG_JUNKFOOD
	rarity_value = 15

/obj/item/weapon/reagent_containers/food/drinks/sillycup
	name = "paper cup"
	desc = "A paper water cup."
	icon_state = "water_cup_e"
	possible_transfer_amounts = null
	volume = 10
	center_of_mass = list("x"=16, "y"=12)

/obj/item/weapon/reagent_containers/food/drinks/sillycup/on_update_icon()
	if(reagents && reagents.total_volume)
		icon_state = "water_cup"
	else
		icon_state = "water_cup_e"


//////////////////////////pitchers, pots, flasks and cups//
//Note by Darem: This code handles the mixing of drinks. New drinks go in three places: In Chemistry-Reagents.dm (for the drink
//	itself), in Chemistry-Recipes.dm (for the reaction that changes the components into the drink), and here (for the drinking glass
//	icon states.

/obj/item/weapon/reagent_containers/food/drinks/shaker
	name = "shaker"
	desc = "A metal shaker to mix drinks in."
	icon_state = "shaker"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,20,30,60,120)
	volume = 120
	center_of_mass = list("x"=17, "y"=10)

/obj/item/weapon/reagent_containers/food/drinks/teapot
	name = "teapot"
	desc = "An elegant teapot. It simply oozes class."
	icon_state = "teapot"
	item_state = "teapot"
	matter = list(MATERIAL_STEEL = 1)
	amount_per_transfer_from_this = 10
	volume = 120
	center_of_mass = list("x"=17, "y"=7)

/obj/item/weapon/reagent_containers/food/drinks/pitcher
	name = "insulated pitcher"
	desc = "A stainless steel insulated pitcher. Everyone's best friend in the morning."
	icon_state = "pitcher"
	volume = 120
	amount_per_transfer_from_this = 10
	matter = list(MATERIAL_STEEL = 1)
	possible_transfer_amounts = list(5,10,20,30,60,120)
	center_of_mass = "x=16;y=9"
	filling_states = "15;30;50;70;85;100"
	base_icon = "pitcher"

/obj/item/weapon/reagent_containers/food/drinks/carafe
	name = "pitcher"
	desc = "A handled glass pitcher."
	icon_state = "carafe"
	item_state = "beaker"
	base_name = "pitcher"
	base_icon = "carafe"
	filling_states = "10;20;30;40;50;60;70;80;90;100"
	volume = 120
	matter = list(MATERIAL_GLASS = 1)
	possible_transfer_amounts = list(5,10,20,30,60,120)
	center_of_mass = "x=16;y=7"

/obj/item/weapon/reagent_containers/food/drinks/flask
	name = "Captain's Flask"
	desc = "A metal flask belonging to the captain"
	icon_state = "flask"
	volume = 60
	center_of_mass = list("x"=17, "y"=7)

/obj/item/weapon/reagent_containers/food/drinks/flask/shiny
	name = "shiny flask"
	desc = "A shiny metal flask. It appears to have a Greek symbol inscribed on it."
	icon_state = "shinyflask"

/obj/item/weapon/reagent_containers/food/drinks/flask/lithium
	name = "lithium flask"
	desc = "A flask with a Lithium Atom symbol on it."
	icon_state = "lithiumflask"

/obj/item/weapon/reagent_containers/food/drinks/flask/detflask
	name = "Inspector's Flask"
	desc = "A metal flask with a leather band and golden badge belonging to the inspector."
	icon_state = "detflask"
	volume = 60
	center_of_mass = list("x"=17, "y"=8)

/obj/item/weapon/reagent_containers/food/drinks/flask/barflask
	name = "flask"
	desc = "For those who can't be bothered to hang out at the bar to drink."
	icon_state = "barflask"
	volume = 60
	center_of_mass = list("x"=17, "y"=7)
	spawn_tags = SPAWN_TAG_JUNK
	matter = list(MATERIAL_STEEL = 1)
	rarity_value = 20

/obj/item/weapon/reagent_containers/food/drinks/flask/vacuumflask
	name = "vacuum flask"
	desc = "Keeping your drinks at the perfect temperature since 1892."
	icon_state = "vacuumflask"
	volume = 60
	matter = list(MATERIAL_STEEL = 1)
	center_of_mass = list("x"=15, "y"=4)

/obj/item/weapon/reagent_containers/food/drinks/mug
	name = "mug"
	desc = "A plain white mug."
	icon_state = "mug"
	item_state = "coffee"
	volume = 30
	matter = list(MATERIAL_GLASS = 1)
	center_of_mass = "x=15;y=13"
	filling_states = "40;80;100"
	base_name = "mug"
	base_icon = "mug"

/obj/item/weapon/reagent_containers/food/drinks/mug/black
	name = "black mug"
	desc = "A sleek black mug."
	icon_state = "mug_black"
	base_name = "black mug"

/obj/item/weapon/reagent_containers/food/drinks/mug/green
	name = "green mug"
	desc = "A pale green and pink mug."
	icon_state = "mug_green"
	base_name = "green mug"

/obj/item/weapon/reagent_containers/food/drinks/mug/blue
	name = "blue mug"
	desc = "A blue and black mug."
	icon_state = "mug_blue"
	base_name = "blue mug"

/obj/item/weapon/reagent_containers/food/drinks/mug/red
	name = "red mug"
	desc = "A red and black mug."
	icon_state = "mug_red"
	base_name = "red mug"

/obj/item/weapon/reagent_containers/food/drinks/mug/heart
	name = "heart mug"
	desc = "A white mug, it prominently features a red heart."
	icon_state = "mug_heart"
	base_name = "heart mug"

/obj/item/weapon/reagent_containers/food/drinks/mug/one
	name = "#1 mug"
	desc = "A white mug, it prominently features a #1."
	icon_state = "mug_one"
	base_name = "#1 mug"

/obj/item/weapon/reagent_containers/food/drinks/mug/metal
	name = "metal mug"
	desc = "A metal mug. You're not sure which metal."
	icon_state = "mug_metal"
	matter = list(MATERIAL_STEEL = 1)
	flags = CONDUCT
	base_name = "metal mug"

/obj/item/weapon/reagent_containers/food/drinks/mug/rainbow
	name = "rainbow mug"
	desc = "A rainbow mug. The colors are almost as blinding as a welder."
	icon_state = "mug_rainbow"
	base_name = "rainbow mug"

/obj/item/weapon/reagent_containers/food/drinks/mug/brit
	name = "flag mug"
	desc = "A mug with an unknown flag emblazoned on it. You feel like tea might be the only beverage that belongs in it."
	icon_state = "britmug"

/obj/item/weapon/reagent_containers/food/drinks/mug/moebius
	name = "\improper Moebius mug"
	desc = "A mug with a Moebius Laboratories logo on it. Not even your morning coffee is safe from corporate advertising."
	icon_state = "mug_moebius"

/obj/item/weapon/reagent_containers/food/drinks/mug/teacup
	name = "cup"
	desc = "A plain white porcelain teacup."
	icon_state = "teacup"
	item_state = "coffee"
	volume = 20
	center_of_mass = "x=15;y=13"
	filling_states = "100"
	base_name = "cup"
	base_icon = "teacup"

/obj/item/weapon/reagent_containers/food/drinks/britcup //Delete this when Clockrigger is done with map changes.
	name = "mug"
	desc = "A mug with an unknown flag emblazoned on it."
	icon_state = "britmug"
	volume = 30
	center_of_mass = list("x"=15, "y"=13)
	filling_states = "40;80;100"
	base_name = "mug"
	base_icon = "mug"

//tea and tea accessories
/obj/item/weapon/reagent_containers/food/drinks/tea
	name = "cup of tea master item"
	desc = "A tall plastic cup full of the concept and ideal of tea."
	icon_state = "cup"
	item_state = "coffee"
	center_of_mass = "x=16;y=14"
	filling_states = "100"
	base_name = "cup"
	base_icon = "cup"

/obj/item/weapon/reagent_containers/food/drinks/tea/black
	name = "cup of black tea"
	desc = "A tall plastic cup of hot black tea."
	preloaded_reagents = list("tea" = 30)

/obj/item/weapon/reagent_containers/food/drinks/tea/green
	name = "cup of green tea"
	desc = "A tall plastic cup of hot green tea."
	preloaded_reagents = list("greentea" = 30)

/datum/gear/bible
	display_name = "NeoTheology ritual book"
	path = /obj/item/book/ritual/cruciform
	cost = 2

/datum/gear/flashlight
	display_name = "Flashlight"
	path = /obj/item/device/lighting/toggleable/flashlight

/datum/gear/crowbar
	display_name = "Crowbar"
	path = /obj/item/tool/crowbar

/datum/gear/cane
	display_name = "cane"
	path = /obj/item/cane

/datum/gear/clown
	display_name = "clown pack"
	path = /obj/item/storage/box/clown
	cost = 3
	allowed_roles = list("Vagabond")

/datum/gear/dice
	display_name = "dice pack"
	path = /obj/item/storage/pill_bottle/dice

/datum/gear/cards
	display_name = "deck of cards"
	path = /obj/item/deck/cards

/datum/gear/tarot
	display_name = "deck of tarot cards"
	path = /obj/item/deck/tarot

/datum/gear/holder
	display_name = "card holder"
	path = /obj/item/deck/holder

/datum/gear/cardemon_pack
	display_name = "Cardemon booster pack"
	path = /obj/item/pack/cardemon

/datum/gear/spaceball_pack
	display_name = "Spaceball booster pack"
	path = /obj/item/pack/spaceball

/datum/gear/mug
	display_name = "mug selection"
	path = /obj/item/reagent_containers/food/drinks/mug
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/pitcher
	display_name = "insulated pitcher"
	path = /obj/item/reagent_containers/food/drinks/pitcher

/datum/gear/flask
	display_name = "flask"
	path = /obj/item/reagent_containers/food/drinks/flask/barflask

// TODO: enable after reagents
/*
/datum/gear/flask/New()
	..()
	gear_tweaks += new/datum/gear_tweak/reagents(lunchables_ethanol_reagents())
*/
/datum/gear/vacflask
	display_name = "vacuum-flask"
	path = /obj/item/reagent_containers/food/drinks/flask/vacuumflask
// TODO: enable after reagents
/*
/datum/gear/vacflask/New()
	..()
	gear_tweaks += new/datum/gear_tweak/reagents(lunchables_drink_reagents())
*/
// TODO: enable after reagents
/*
/datum/gear/lunchbox
	display_name = "lunchbox"
	description = "A little lunchbox."
	cost = 2
	path = /obj/item/storage/lunchbox

/datum/gear/lunchbox/New()
	..()
	var/list/lunchboxes = list()
	for(var/lunchbox_type in typesof(/obj/item/storage/lunchbox))
		var/obj/item/storage/lunchbox/lunchbox = lunchbox_type
		if(!initial(lunchbox.filled))
			lunchboxes[initial(lunchbox.name)] = lunchbox_type
	gear_tweaks += new/datum/gear_tweak/path(lunchboxes)
	gear_tweaks += new/datum/gear_tweak/contents(lunchables_lunches(), lunchables_snacks(), lunchables_drinks())
*/

/datum/gear/plush_toy
	display_name = "plush toy"
	description = "A plush toy."
	path = /obj/item/toy/plushie

/datum/gear/plush_toy/New()
	..()
	var/plushes = list(
		"mouse plush"	=	/obj/item/toy/plushie/mouse,
		"kitten plush"	=	/obj/item/toy/plushie/kitten,
		"lizard plush"	=	/obj/item/toy/plushie/lizard,
		"spider plush"	=	/obj/item/toy/plushie/spider,
	)
	gear_tweaks += new /datum/gear_tweak/path(plushes)

/datum/gear/mirror/
	display_name = "handheld mirror"
	sort_category = "Cosmetics"
	path = /obj/item/mirror

/datum/gear/lipstick
	display_name = "lipstick selection"
	path = /obj/item/lipstick
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/comb
	display_name = "plastic comb"
	path = /obj/item/haircomb
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/mask
	display_name = "sterile mask"
	path = /obj/item/clothing/mask/surgical
	cost = 2

/datum/gear/smokingpipe
	display_name = "pipe, smoking"
	path = /obj/item/clothing/mask/smokable/pipe

/datum/gear/cornpipe
	display_name = "pipe, corn"
	path = /obj/item/clothing/mask/smokable/pipe/cobpipe

/datum/gear/matchbook
	display_name = "matchbook"
	path = /obj/item/storage/box/matches

/datum/gear/lighter
	display_name = "cheap lighter"
	path = /obj/item/flame/lighter

/datum/gear/zippo
	display_name = "zippo"
	path = /obj/item/flame/lighter/zippo

/datum/gear/cigars
	display_name = "fancy cigar case"
	path = /obj/item/storage/fancy/cigar
	cost = 2

/datum/gear/cigarettes
	display_name = "cigarette packet"
	path = /obj/item/storage/fancy/cigarettes

/datum/gear/cigarettes/New()
	..()
	var/cigarettes_type = list(
		"Space Cigarettes"	=	/obj/item/storage/fancy/cigarettes,
		"DromedaryCo Cigarettes"	=	/obj/item/storage/fancy/cigarettes/dromedaryco,
		"AcmeCo Cigarettes"	=	/obj/item/storage/fancy/cigarettes/killthroat,
		//"Nomads Cigarettes"	=	/obj/item/storage/fancy/cigarettes/homeless
	)
	gear_tweaks += new/datum/gear_tweak/path(cigarettes_type)

/datum/gear/cigar
	display_name = "fancy cigar"
	path = /obj/item/clothing/mask/smokable/cigarette/cigar

/datum/gear/cigar/New()
	..()
	var/cigar_type = list()
	cigar_type["premium"] = /obj/item/clothing/mask/smokable/cigarette/cigar
	cigar_type["Cohiba Robusto"] = /obj/item/clothing/mask/smokable/cigarette/cigar/cohiba
	gear_tweaks += new/datum/gear_tweak/path(cigar_type)

// For convenience and easier comparing and maintaining of item prices,
// all these will be defined here and sorted in different sections.

// The item price in credits. atom/movable so we can also assign a price to animals and other things.
// /atom/movable/var/price_tag atoms_movable.dm line: 22 var/price_tag = 0

// The proc that is called when the price is being asked for. Use this to refer to another object if necessary.
/atom/movable/proc/get_item_cost(export)
	. = price_tag


//***************//
//---Beverages---//
//***************//

/datum/reagent/var/price_tag


// Juices, soda and similar //

/datum/reagent/water
	price_tag = 20

/datum/reagent/drink/juice
	price_tag = 20

/datum/reagent/toxin/poisonberryjuice
	price_tag = 20

/datum/reagent/drink/milk
	price_tag = 20

/datum/reagent/drink/soda
	price_tag = 20

/datum/reagent/drink/doctor_delight
	price_tag = 20

/datum/reagent/drink/nothing
	price_tag = 20

/datum/reagent/drink/milkshake
	price_tag = 20

/datum/reagent/drink/roy_rogers
	price_tag = 20

/datum/reagent/drink/shirley_temple
	price_tag = 20

/datum/reagent/drink/arnold_palmer
	price_tag = 20

/datum/reagent/drink/collins_mix
	price_tag = 20


// Beer //

/datum/reagent/ethanol/ale
	price_tag = 20

/datum/reagent/ethanol/beer
	price_tag = 20


// Hot Drinks //

/datum/reagent/drink/rewriter
	price_tag = 10

/datum/reagent/drink/tea
	price_tag = 10

/datum/reagent/drink/coffee
	price_tag = 10

/datum/reagent/drink/hot_coco
	price_tag = 10

/obj/item/reagent_containers/food
	price_tag = 10

/obj/item/reagent_containers/food/drinks/coffee
	price_tag = 10

/obj/item/reagent_containers/food/drinks/tea
	price_tag = 10

/obj/item/reagent_containers/food/drinks/h_chocolate
	price_tag = 10


// Spirituous liquors //

/datum/reagent/ethanol/irish_cream
	price_tag = 50

/datum/reagent/ethanol/absinthe
	price_tag = 50

/datum/reagent/ethanol/bluecuracao
	price_tag = 50

/datum/reagent/ethanol/deadrum
	price_tag = 50

/datum/reagent/ethanol/gin
	price_tag = 50

/datum/reagent/ethanol/coffee/kahlua
	price_tag = 50

/datum/reagent/ethanol/melonliquor
	price_tag = 50

/datum/reagent/ethanol/rum
	price_tag = 5

/datum/reagent/ethanol/tequilla
	price_tag = 50

/datum/reagent/ethanol/thirteenloko
	price_tag = 50

/datum/reagent/ethanol/vodka
	price_tag = 50

/datum/reagent/ethanol/whiskey
	price_tag = 50

/datum/reagent/ethanol/specialwhiskey
	price_tag = 50

/datum/reagent/ethanol/patron
	price_tag = 50

/datum/reagent/ethanol/goldschlager
	price_tag = 50

/datum/reagent/ethanol/coffee/brave_bull // Not an original liquor in its own. But since it's a mix of purely Tequila
	price_tag = 50						 // and Kahlua, it's basically just another one and gets the same price.


// Wines //

/datum/reagent/ethanol/wine
	price_tag = 80

/datum/reagent/ethanol/cognac
	price_tag = 80

/datum/reagent/ethanol/sake
	price_tag = 80

/datum/reagent/ethanol/vermouth
	price_tag = 80

/datum/reagent/ethanol/pwine
	price_tag = 80


// Cocktails //
/*
/datum/reagent/ethanol/acid_spit
	price_tag = 40

/datum/reagent/ethanol/alliescocktail
	price_tag = 40

/datum/reagent/ethanol/aloe
	price_tag = 4

/datum/reagent/ethanol/amasec
	price_tag = 4

/datum/reagent/ethanol/andalusia
	price_tag = 4

/datum/reagent/ethanol/antifreeze
	price_tag = 4

/datum/reagent/ethanol/atomicbomb
	price_tag = 4

/datum/reagent/ethanol/coffee/b52
	price_tag = 4

/datum/reagent/ethanol/bahama_mama
	price_tag = 4

/datum/reagent/ethanol/barefoot
	price_tag = 4

/datum/reagent/ethanol/beepsky_smash
	price_tag = 4

/datum/reagent/ethanol/bilk
	price_tag = 4

/datum/reagent/ethanol/black_russian
	price_tag = 4

/datum/reagent/ethanol/bloody_mary
	price_tag = 4

/datum/reagent/ethanol/booger
	price_tag = 4

/datum/reagent/ethanol/brave_bull
	price_tag = 4

/datum/reagent/ethanol/changeling_sting
	price_tag = 4

/datum/reagent/ethanol/martini
	price_tag = 4

/datum/reagent/ethanol/cuba_libre
	price_tag = 4

/datum/reagent/ethanol/demonsblood
	price_tag = 4

/datum/reagent/ethanol/devilskiss
	price_tag = 4

/datum/reagent/ethanol/driestmartini
	price_tag = 4

/datum/reagent/ethanol/ginfizz
	price_tag = 4

/datum/reagent/ethanol/grog
	price_tag = 4

/datum/reagent/ethanol/erikasurprise
	price_tag = 4

/datum/reagent/ethanol/gargle_blaster
	price_tag = 4

/datum/reagent/ethanol/gintonic
	price_tag = 4

/datum/reagent/ethanol/hippies_delight
	price_tag = 4

/datum/reagent/ethanol/hooch
	price_tag = 4

/datum/reagent/ethanol/iced_beer
	price_tag = 4

/datum/reagent/ethanol/irishcarbomb
	price_tag = 4

/datum/reagent/ethanol/coffee/irishcoffee
	price_tag = 4

/datum/reagent/ethanol/longislandicedtea
	price_tag = 4

/datum/reagent/ethanol/manhattan
	price_tag = 4

/datum/reagent/ethanol/manhattan_proj
	price_tag = 4

/datum/reagent/ethanol/manly_dorf
	price_tag = 4

/datum/reagent/ethanol/margarita
	price_tag = 4

/datum/reagent/ethanol/mead
	price_tag = 4

/datum/reagent/ethanol/moonshine
	price_tag = 4

/datum/reagent/ethanol/neurotoxin
	price_tag = 4

/datum/reagent/ethanol/red_mead
	price_tag = 4

/datum/reagent/ethanol/sbiten
	price_tag = 4

/datum/reagent/ethanol/screwdrivercocktail
	price_tag = 4

/datum/reagent/ethanol/silencer
	price_tag = 4

/datum/reagent/ethanol/singulo
	price_tag = 4

/datum/reagent/ethanol/snowwhite
	price_tag = 4

/datum/reagent/ethanol/suidream
	price_tag = 4

/datum/reagent/ethanol/syndicatebomb
	price_tag = 4

/datum/reagent/ethanol/tequillasunrise
	price_tag = 4

/datum/reagent/ethanol/threemileisland
	price_tag = 4

/datum/reagent/ethanol/toxins_special
	price_tag = 4

/datum/reagent/ethanol/vodkamartini
	price_tag = 4

/datum/reagent/ethanol/vodkatonic
	price_tag = 4

/datum/reagent/ethanol/white_russian
	price_tag = 4

/datum/reagent/ethanol/whiskey_cola
	price_tag = 4

/datum/reagent/ethanol/whiskeysoda
	price_tag = 4


// Cocktails without alcohol //

/datum/reagent/ethanol/bananahonk
	price_tag = 3

*/

// From the machine //

/obj/item/reagent_containers/food/drinks/cans/cola
	price_tag = 10

/obj/item/reagent_containers/food/drinks/cans/space_mountain_wind
	price_tag = 10

/obj/item/reagent_containers/food/drinks/cans/dr_gibb
	price_tag = 10

/obj/item/reagent_containers/food/drinks/cans/starkist
	price_tag = 10

/obj/item/reagent_containers/food/drinks/cans/waterbottle
	price_tag = 15

/obj/item/reagent_containers/food/drinks/cans/space_up
	price_tag = 10

/obj/item/reagent_containers/food/drinks/cans/iced_tea
	price_tag = 10

/obj/item/reagent_containers/food/drinks/cans/grape_juice
	price_tag = 10


//***************//
//----Bottles----//
//***************//

// Juices, soda and similar //

/obj/item/reagent_containers/food/drinks/bottle/cola
	price_tag = 60

/obj/item/reagent_containers/food/drinks/bottle/space_up
	price_tag = 60

/obj/item/reagent_containers/food/drinks/bottle/space_mountain_wind
	price_tag = 60

/obj/item/reagent_containers/food/drinks/bottle/orangejuice
	price_tag = 60

/obj/item/reagent_containers/food/drinks/bottle/cream
	price_tag = 60

/obj/item/reagent_containers/food/drinks/bottle/tomatojuice
	price_tag = 60

/obj/item/reagent_containers/food/drinks/bottle/limejuice
	price_tag = 60


// Beer //

/obj/item/reagent_containers/food/drinks/bottle/small/beer
	price_tag = 80

/obj/item/reagent_containers/food/drinks/bottle/small/ale
	price_tag = 80


// Spirituous Liquors //

/obj/item/reagent_containers/food/drinks/bottle/absinthe
	price_tag = 150

/obj/item/reagent_containers/food/drinks/bottle/bluecuracao
	price_tag = 150

/obj/item/reagent_containers/food/drinks/bottle/gin
	price_tag = 150

/obj/item/reagent_containers/food/drinks/bottle/kahlua
	price_tag = 150

/obj/item/reagent_containers/food/drinks/bottle/melonliquor
	price_tag = 150

/obj/item/reagent_containers/food/drinks/bottle/rum
	price_tag = 150

/obj/item/reagent_containers/food/drinks/bottle/tequilla
	price_tag = 150

/obj/item/reagent_containers/food/drinks/bottle/vodka
	price_tag = 150

/obj/item/reagent_containers/food/drinks/bottle/whiskey
	price_tag = 150


/obj/item/reagent_containers/food/drinks/bottle/patron
	price_tag = 150

/obj/item/reagent_containers/food/drinks/bottle/goldschlager
	price_tag = 150

/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing
	price_tag = 150

/obj/item/reagent_containers/food/drinks/bottle/grenadine
	price_tag = 150


// Wines //

/obj/item/reagent_containers/food/drinks/bottle/wine
	price_tag = 250

/obj/item/reagent_containers/food/drinks/bottle/cognac
	price_tag = 250

/obj/item/reagent_containers/food/drinks/bottle/vermouth
	price_tag = 250

/obj/item/reagent_containers/food/drinks/bottle/pwine
	price_tag = 250


//***************//
//---Foodstuff---//
//***************//

// Snacks //
/obj/item/reagent_containers/food/snacks
	price_tag = 30

/obj/item/reagent_containers/food/snacks/candy
	price_tag = 10

/obj/item/reagent_containers/food/snacks/sosjerky
	price_tag = 20

/obj/item/reagent_containers/food/snacks/unajerky
	price_tag = 120

/obj/item/reagent_containers/food/snacks/cheesiehonkers
	price_tag = 10

/obj/item/reagent_containers/food/snacks/tastybread
	price_tag = 20

/obj/item/reagent_containers/food/snacks/no_raisin
	price_tag = 10

/obj/item/reagent_containers/food/snacks/spacetwinkie
	price_tag = 10


/obj/item/reagent_containers/food/snacks/chips
	price_tag = 10

/obj/item/reagent_containers/food/drinks/dry_ramen
	price_tag = 50


// Burger //

/obj/item/reagent_containers/food/snacks/brainburger
	price_tag = 20

/obj/item/reagent_containers/food/snacks/ghostburger
	price_tag = 20

/obj/item/reagent_containers/food/snacks/human/burger
	price_tag = 20

/obj/item/reagent_containers/food/snacks/cheeseburger
	price_tag = 20

/obj/item/reagent_containers/food/snacks/monkeyburger
	price_tag = 20

/obj/item/reagent_containers/food/snacks/fishburger
	price_tag = 20

/obj/item/reagent_containers/food/snacks/tofuburger
	price_tag = 20

/obj/item/reagent_containers/food/snacks/roburger
	price_tag = 20

/obj/item/reagent_containers/food/snacks/roburgerbig
	price_tag = 20

/obj/item/reagent_containers/food/snacks/xenoburger
	price_tag = 20

/obj/item/reagent_containers/food/snacks/clownburger
	price_tag = 20

/obj/item/reagent_containers/food/snacks/mimeburger
	price_tag = 20

/obj/item/reagent_containers/food/snacks/spellburger
	price_tag = 49.9

/obj/item/reagent_containers/food/snacks/jellyburger
	price_tag = 35

/obj/item/reagent_containers/food/snacks/bigbiteburger
	price_tag = 89.9

/obj/item/reagent_containers/food/snacks/superbiteburger
	price_tag = 139


// Sandwiches //

/obj/item/reagent_containers/food/snacks/sandwich
	price_tag = 15

/obj/item/reagent_containers/food/snacks/toastedsandwich
	price_tag = 15

/obj/item/reagent_containers/food/snacks/grilledcheese
	price_tag = 15

/obj/item/reagent_containers/food/snacks/jellysandwich
	price_tag = 15


// Cookies and Candies //

/obj/item/reagent_containers/food/snacks/cookie
	price_tag = 10

/obj/item/reagent_containers/food/snacks/chocolatebar
	price_tag = 10

/obj/item/reagent_containers/food/snacks/chocolateegg
	price_tag = 10

/obj/item/reagent_containers/food/snacks/candy_corn
	price_tag = 10

/obj/item/reagent_containers/food/snacks/donut
	price_tag = 10

/obj/item/reagent_containers/food/snacks/donut/chaos
	price_tag = 25

/obj/item/reagent_containers/food/snacks/popcorn
	price_tag = 15

/obj/item/reagent_containers/food/snacks/fortunecookie
	price_tag = 10

/obj/item/reagent_containers/food/snacks/candiedapple
	price_tag = 20

/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit
	price_tag = 10

/obj/item/reagent_containers/food/snacks/chawanmushi
	price_tag = 20

/obj/item/reagent_containers/food/snacks/cracker
	price_tag = 10


// Full meals //

/obj/item/reagent_containers/food/snacks/friedegg
	price_tag = 25

/obj/item/reagent_containers/food/snacks/tofurkey
	price_tag = 25

/obj/item/reagent_containers/food/snacks/meat/carp
	price_tag = 200
/obj/item/reagent_containers/food/snacks/meat
	price_tag = 100
/obj/item/reagent_containers/food/snacks/meat/corgi
	price_tag = 500
/obj/item/reagent_containers/food/snacks/fishfingers
	price_tag = 25

/obj/item/reagent_containers/food/snacks/omelette
	price_tag = 25

/obj/item/reagent_containers/food/snacks/berryclafoutis
	price_tag = 25

/obj/item/reagent_containers/food/snacks/waffles
	price_tag = 25

/obj/item/reagent_containers/food/snacks/eggplantparm
	price_tag = 25

/obj/item/reagent_containers/food/snacks/soylentgreen
	price_tag = 25

/obj/item/reagent_containers/food/snacks/soylenviridians
	price_tag = 25

/obj/item/reagent_containers/food/snacks/wingfangchu
	price_tag = 25

/obj/item/reagent_containers/food/snacks/kabob
	price_tag = 25

/obj/item/reagent_containers/food/snacks/monkeykabob
	price_tag = 25

/obj/item/reagent_containers/food/snacks/tofukabob
	price_tag = 25

/obj/item/reagent_containers/food/snacks/cubancarp
	price_tag = 25

/obj/item/reagent_containers/food/snacks/loadedbakedpotato
	price_tag = 25

/obj/item/reagent_containers/food/snacks/fries
	price_tag = 25

/obj/item/reagent_containers/food/snacks/spagetti
	price_tag = 25

/obj/item/reagent_containers/food/snacks/cheesyfries
	price_tag = 25

/obj/item/reagent_containers/food/snacks/enchiladas
	price_tag = 25

/obj/item/reagent_containers/food/snacks/taco
	price_tag = 25

/obj/item/reagent_containers/food/snacks/monkeysdelight
	price_tag = 25

/obj/item/reagent_containers/food/snacks/fishandchips
	price_tag = 40

/obj/item/reagent_containers/food/snacks/rofflewaffles
	price_tag = 25

/obj/item/reagent_containers/food/snacks/stew
	price_tag = 25

/obj/item/reagent_containers/food/snacks/stewedsoymeat
	price_tag = 25

/obj/item/reagent_containers/food/snacks/boiledspagetti
	price_tag = 25

/obj/item/reagent_containers/food/snacks/boiledrice
	price_tag = 25

/obj/item/reagent_containers/food/snacks/ricepudding
	price_tag = 25

/obj/item/reagent_containers/food/snacks/pastatomato
	price_tag = 25

/obj/item/reagent_containers/food/snacks/meatballspagetti
	price_tag = 25

/obj/item/reagent_containers/food/snacks/spesslaw
	price_tag = 25

/obj/item/reagent_containers/food/snacks/carrotfries
	price_tag = 25

/obj/item/reagent_containers/food/snacks/appletart
	price_tag = 25

/obj/item/reagent_containers/food/snacks/sliceable/pizza
	price_tag = 25

/obj/item/reagent_containers/food/snacks/slice/margherita
	price_tag = 10

/obj/item/reagent_containers/food/snacks/slice/meatpizza
	price_tag = 10

/obj/item/reagent_containers/food/snacks/slice/mushroompizza
	price_tag = 10

/obj/item/reagent_containers/food/snacks/slice/vegetablepizza
	price_tag = 10


// Baked Goods //

/obj/item/reagent_containers/food/snacks/poppypretzel
	price_tag = 20

/obj/item/reagent_containers/food/snacks/baguette
	price_tag = 20

/obj/item/reagent_containers/food/snacks/jelliedtoast
	price_tag = 10

/obj/item/reagent_containers/food/snacks/twobread
	price_tag = 20

/obj/item/reagent_containers/food/snacks/sliceable/meatbread
	price_tag = 50

/obj/item/reagent_containers/food/snacks/slice/meatbread
	price_tag = 10

/obj/item/reagent_containers/food/snacks/sliceable/xenomeatbread
	price_tag = 50

/obj/item/reagent_containers/food/snacks/slice/xenomeatbread
	price_tag = 10

/obj/item/reagent_containers/food/snacks/sliceable/bananabread
	price_tag = 50

/obj/item/reagent_containers/food/snacks/slice/bananabread
	price_tag = 10

/obj/item/reagent_containers/food/snacks/sliceable/tofubread
	price_tag = 50

/obj/item/reagent_containers/food/snacks/slice/tofubread
	price_tag = 10

/obj/item/reagent_containers/food/snacks/sliceable/bread
	price_tag = 50

/obj/item/reagent_containers/food/snacks/slice/bread
	price_tag = 10

/obj/item/reagent_containers/food/snacks/sliceable/creamcheesebread
	price_tag = 50

/obj/item/reagent_containers/food/snacks/slice/creamcheesebread
	price_tag = 10


// Soups //

/obj/item/reagent_containers/food/snacks/meatballsoup
	price_tag = 30

/obj/item/reagent_containers/food/snacks/slimesoup
	price_tag = 30

/obj/item/reagent_containers/food/snacks/bloodsoup
	price_tag = 30

/obj/item/reagent_containers/food/snacks/clownstears
	price_tag = 30

/obj/item/reagent_containers/food/snacks/vegetablesoup
	price_tag = 30

/obj/item/reagent_containers/food/snacks/nettlesoup
	price_tag = 30

/obj/item/reagent_containers/food/snacks/mysterysoup
	price_tag = 30

/obj/item/reagent_containers/food/snacks/wishsoup
	price_tag = 30

/obj/item/reagent_containers/food/snacks/hotchili
	price_tag = 30

/obj/item/reagent_containers/food/snacks/coldchili
	price_tag = 30

/obj/item/reagent_containers/food/snacks/tomatosoup
	price_tag = 30

/obj/item/reagent_containers/food/snacks/milosoup
	price_tag = 30

/obj/item/reagent_containers/food/snacks/mushroomsoup
	price_tag = 30

/obj/item/reagent_containers/food/snacks/beetsoup
	price_tag = 30


// Pies //

/obj/item/reagent_containers/food/snacks/pie
	price_tag = 40

/obj/item/reagent_containers/food/snacks/meatpie
	price_tag = 40

/obj/item/reagent_containers/food/snacks/tofupie
	price_tag = 40

/obj/item/reagent_containers/food/snacks/plump_pie
	price_tag = 40

/obj/item/reagent_containers/food/snacks/xemeatpie
	price_tag = 40

/obj/item/reagent_containers/food/snacks/applepie
	price_tag = 40

/obj/item/reagent_containers/food/snacks/cherrypie
	price_tag = 40


// Cakes //
/obj/item/reagent_containers/food/snacks/slice
	price_tag = 10

/obj/item/reagent_containers/food/snacks/sliceable/get_item_cost(export)
	. = ..() + SStrade.get_import_cost(slice_path) * slices_num

// Misc //

/obj/item/reagent_containers/food/snacks/boiledegg
	price_tag = 20

/obj/item/reagent_containers/food/snacks/donkpocket
	price_tag = 10

/obj/item/reagent_containers/food/snacks/sausage
	price_tag = 20

/obj/item/reagent_containers/food/snacks/muffin
	price_tag = 20

/obj/item/reagent_containers/food/snacks/tossedsalad
	price_tag = 20

/obj/item/reagent_containers/food/snacks/validsalad
	price_tag = 20

/obj/item/reagent_containers/food/snacks/dionaroast
	price_tag = 250

/obj/item/reagent_containers/food/snacks/csandwich
	price_tag = 50

/obj/item/pizzabox/get_item_cost()
	. = pizza?.get_item_cost()


//***************//
//----Smokes-----//
//***************//

/obj/item/clothing/mask/smokable
	price_tag = 5 //cigarette monopoly no more

/obj/item/flame/lighter
	price_tag = 20

/obj/item/flame/lighter/zippo
	price_tag = 50

/obj/item/bluespace_crystal
	price_tag = 500

/obj/item/storage/get_item_cost(export)
	. = ..()
	for(var/atom/movable/i in src)
		. += SStrade.get_new_cost(i)

/obj/machinery
	price_tag = 100

/obj/machinery/get_item_cost(export)
	. = ..()
	for(var/atom/movable/i in component_parts)
		. += SStrade.get_new_cost(i)

/obj/machinery/portable_atmospherics
	price_tag = 200

/obj/machinery/power/supermatter
	price_tag = 5000

/obj/machinery/portable_atmospherics/canister/get_item_cost(export)
	. = price_tag + (price_tag * log(10, air_contents.volume)) //todo, prices of gases

/obj/structure/reagent_dispensers/price_tag = 5
/obj/structure/reagent_dispensers/get_item_cost()
	var/ratio = reagents.total_volume / reagents.maximum_volume

	return ..() + round(contents_cost * ratio)


/obj/item/tank
	price_tag = 50
/obj/item/tank/plasma
	price_tag = 75
/obj/item/tank/get_item_cost(export)
	. = price_tag + (price_tag * log(10, air_contents.volume)) //todo, prices of gases

/obj/item/electronics/circuitboard
	price_tag = 150

/obj/item/electronics/circuitboard/get_item_cost(export)
	. = ..()
	for(var/atom/movable/i in req_components)
		if(ispath(i))
			. += SStrade.get_new_cost(i) * log(10, price_tag / 2)

/obj/item/stock_parts
	price_tag = 100

/obj/item/stock_parts/get_item_cost(export)
	. = ..() * rating

/obj/item/organ
	price_tag = 500

/mob/living/exosuit/get_item_cost(export)
	. = ..() + SStrade.get_import_cost(body)

/obj/item/stack/get_item_cost(export)
	return amount * ..()

/obj/item/ammo_magazine/price_tag = 60

/obj/item/ammo_magazine/ammobox/price_tag = 40

/obj/item/ammo_magazine/get_item_cost(export)
	. = ..()
	for(var/obj/item/ammo_casing/i in stored_ammo)
		. += i.get_item_cost(export)

/obj/item/ammo_casing/price_tag = 0

/obj/item/ammo_casing/get_item_cost(export)
	. = ..() * amount

/obj/item/tool/price_tag = 20
/obj/item/tool/get_item_cost(export)
	. = 1
	for(var/i in tool_qualities)
		. += tool_qualities[i] / 5
	. *= ..()

/obj/structure/medical_stand/price_tag = 100
/obj/item/virusdish/price_tag = 300

/obj/item/reagent_containers/price_tag = 20
/obj/item/reagent_containers/glass/beaker/bluespace/price_tag = 300
/obj/item/reagent_containers/get_item_cost(export)
	. = ..()
	. += reagents?.get_price() //TODO assign an apprpriate price_per_unit

/obj/item/reagent_containers/blood
	price_tag = 50

/obj/item/clothing/price_tag = 30

/obj/item/solar_assembly/price_tag = 100
/obj/item/tracker_electronics/price_tag = 150
/obj/item/handcuffs/price_tag = 30
/obj/item/handcuffs/get_item_cost(export)
	. = ..()
	. += breakouttime / 20

/obj/item/grenade/price_tag = 50

/obj/item/robot_parts/price_tag = 100
/obj/item/robot_parts/robot_component/armour/exosuit/price_tag = 300
/obj/item/robot_parts/robot_component/armour/exosuit/radproof/price_tag = 500
/obj/item/robot_parts/robot_component/armour/exosuit/em/price_tag = 550
/obj/item/robot_parts/robot_component/armour/exosuit/combat/price_tag = 1000

/obj/item/mech_component/price_tag = 150
/obj/item/mech_equipment/price_tag = 200

/obj/item/gun/launcher/grenade/price_tag = 1500

/obj/item/storage/briefcase/price_tag = 50

/obj/item/inflatable/price_tag = 40

/obj/item/tool/knife/dagger/bluespace/price_tag = 400


/obj/item/reagent_containers/food/snacks/meat/roachmeat/price_tag = 75
/obj/item/reagent_containers/food/snacks/meat/roachmeat/seuche/price_tag = 100
/obj/item/reagent_containers/food/snacks/meat/roachmeat/kraftwerk/price_tag = 100
/obj/item/reagent_containers/food/snacks/meat/roachmeat/jager/price_tag = 125

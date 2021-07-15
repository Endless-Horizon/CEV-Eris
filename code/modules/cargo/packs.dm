//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: hidden packs only show up when the computer has been hacked.
//ANOTER NOTE: Contraband is obtainable through modified supplycomp circuitboards.
//BIG NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NEW NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.

var/list/all_supply_groups = list("Operations","Security","Hospitality","Engineering","Medical / Science","Hydroponics","Mining","Supply","Resource Integration Gear","Miscellaneous")

/datum/supply_pack
	var/name = "Crate"
	var/group = "Operations"
	var/true_manifest = ""
	var/hidden = FALSE
	var/contraband = FALSE
	var/cost = 400 // Minimum cost, or infinite points are possible.
	var/access = FALSE
	var/list/contains = null
	var/crate_name = "crate"
	var/containertype = /obj/structure/closet/crate
	var/dangerous = FALSE // Should we message admins?
	var/special = FALSE //Event/Station Goals/Admin enabled packs
	var/special_enabled = FALSE
	var/amount = 0

/datum/supply_pack/New()
	true_manifest += "<ul>"
	for(var/path in contains)
		if(!path)
			continue
		var/atom/movable/AM = path
		true_manifest += "<li>[initial(AM.name)]</li>"
	true_manifest += "</ul>"

/datum/supply_pack/proc/generate(turf/T)
	var/obj/structure/closet/crate/C = new containertype(T)
	C.name = crate_name
	if(access)
		C.req_access = list(access)

	fill(C)

	return C

/datum/supply_pack/proc/fill(obj/structure/closet/crate/C)
	for(var/item in contains)
		var/atom/movable/n_item
		if(ispath(item, /obj/spawner))
			var/obj/randomcatcher/CATCH = new /obj/randomcatcher
			n_item = CATCH.get_item(item)
		else
			n_item = new item(C)
		n_item.surplus_tag = TRUE
		var/list/n_contents = n_item.GetAllContents()
		for(var/atom/movable/I in n_contents)
			n_item.surplus_tag = TRUE
		/*So you can't really just buy crates, then instantly resell them for a potential profit depending on if the crate hasn't had its cost scaled properly.
		* Yes, there are limits, I could itterate over every content of the item too and set its surplus_tag to TRUE
		* But that doesn't work with stackables when you can just make a new stack, and gets comp-expensive and not worth it just to spite people getting extra numbers
		*/
		if(src.amount && istype(n_item, /obj/item/stack/material/steel))
			var/obj/item/stack/material/n_sheet = n_item
			n_sheet.amount = src.amount

//----------------------------------------------
//-----------------OPERATIONS-------------------
//----------------------------------------------

/datum/supply_pack/mule
	name = "MULEbot Crate"
	contains = list(/obj/machinery/bot/mulebot)
	cost = 1200
	containertype = /obj/structure/largecrate/mule
	crate_name = "MULEbot Crate"
	group = "Operations"

/datum/supply_pack/lunchboxes
	name = "Lunchboxes"
	contains = list(/obj/item/storage/lunchbox/cat,
					/obj/item/storage/lunchbox/cat,
					/obj/item/storage/lunchbox/cat,
					/obj/item/storage/lunchbox/cat,
					/obj/item/storage/lunchbox,
					/obj/item/storage/lunchbox,
					/obj/item/storage/lunchbox,
					/obj/item/storage/lunchbox,
					/obj/item/storage/lunchbox/rainbow,
					/obj/item/storage/lunchbox/rainbow,
					/obj/item/storage/lunchbox/rainbow,
					/obj/item/storage/lunchbox/rainbow)
	cost = 400
	containertype = /obj/structure/closet/crate
	crate_name  = "\improper Lunchboxes"
	group = "Operations"

/datum/supply_pack/artscrafts
	name = "Arts and Crafts supplies"
	contains = list(/obj/item/storage/fancy/crayons,
	/obj/item/device/camera,
	/obj/item/device/camera_film,
	/obj/item/device/camera_film,
	/obj/item/storage/photo_album,
	/obj/item/packageWrap,
	/obj/item/reagent_containers/glass/paint/red,
	/obj/item/reagent_containers/glass/paint/green,
	/obj/item/reagent_containers/glass/paint/blue,
	/obj/item/reagent_containers/glass/paint/yellow,
	/obj/item/reagent_containers/glass/paint/purple,
	/obj/item/reagent_containers/glass/paint/black,
	/obj/item/reagent_containers/glass/paint/white,
	/obj/item/contraband/poster,
	/obj/item/wrapping_paper,
	/obj/item/wrapping_paper,
	/obj/item/wrapping_paper)
	cost = 700
	crate_name = "Arts and Crafts crate"
	group = "Operations"

/datum/supply_pack/price_scanner
	name = "Export scanners"
	contains = list(/obj/item/device/scanner/price,
					/obj/item/device/scanner/price)
	cost = 700
	crate_name = "Export scanners crate"
	group = "Operations"

//----------------------------------------------
//-----------------SECURITY---------------------
//----------------------------------------------

/datum/supply_pack/specialops
	name = "Special Ops supplies"
	contains = list(/obj/item/storage/box/emps,
					/obj/item/grenade/smokebomb,
					/obj/item/grenade/smokebomb,
					/obj/item/grenade/smokebomb,
					/obj/item/grenade/chem_grenade/incendiary)
	cost = 1700
	crate_name = "Special Ops crate"
	group = "Security"
	hidden = TRUE

/datum/supply_pack/fsenergy
	name = "FS Energy Weapons"
	contains = list(/obj/item/gun/energy/plasma/cassad,
				/obj/item/gun/energy/gun,
				/obj/item/gun/energy/gun,
				/obj/item/gun/energy/gun/martin,
				/obj/item/gun/energy/gun/martin)
	cost = 6000
	containertype = /obj/structure/closet/crate/secure/weapon
	crate_name = "FS Energy Weapons"
	group = "Security"

/datum/supply_pack/fssmall
	name = "FS Handgun Pack"
	contains = list(/obj/item/gun/projectile/colt,
			/obj/item/gun/projectile/paco,
			/obj/item/gun/projectile/selfload,
			/obj/item/gun/projectile/olivaw)
	cost = 3000
	containertype = /obj/structure/closet/crate/secure/weapon
	crate_name = "FS Handgun Pack"
	group = "Security"

/datum/supply_pack/fsrevolver
	name = "FS Revolver Pack"
	contains = list(/obj/item/gun/projectile/revolver/havelock,
					/obj/item/gun/projectile/revolver/havelock,
					/obj/item/gun/projectile/revolver/consul)
	cost = 3300
	containertype = /obj/structure/closet/crate/secure/weapon
	crate_name = "FS Revolver Pack"
	group = "Security"

/datum/supply_pack/fshunting	//3 hunting rifles
	name = "FS Hunting Rifle Pack"
	contains = list(/obj/item/gun/projectile/automatic/ak47/fs,
			/obj/item/gun/projectile/automatic/ak47/fs,
			/obj/item/gun/projectile/automatic/ak47/fs)
	cost = 6000
	containertype = /obj/structure/closet/crate/secure/weapon
	crate_name = "FS Hunting Rifle Pack"
	group = "Security"

/datum/supply_pack/fsassault
	name = "FS Assault Pack"
	contains = list(/obj/item/gun/projectile/automatic/ak47/fs/ih,
			/obj/item/gun/projectile/automatic/z8,
			/obj/item/gun/projectile/automatic/atreides)
	cost = 6000
	containertype = /obj/structure/closet/crate/secure/weapon
	crate_name = "FS Assault Pack"
	group = "Security"

/datum/supply_pack/ntweapons
	name = "NT Energy Weapons"
	contains = list(/obj/item/gun/energy/laser,
				/obj/item/gun/energy/laser,
				/obj/item/gun/energy/taser,
				/obj/item/gun/energy/taser,
				/obj/item/gun/energy/nt_svalinn,
				/obj/item/gun/energy/nt_svalinn)
	cost = 6000
	containertype = /obj/structure/closet/crate/secure/weapon
	crate_name = "FS Energy Weapons"
	group = "Security"

/datum/supply_pack/eweapons
	name = "Incendiary weapons crate"
	contains = list(/obj/item/flamethrower/full,
					/obj/item/tank/plasma,
					/obj/item/tank/plasma,
					/obj/item/tank/plasma,
					/obj/item/grenade/chem_grenade/incendiary,
					/obj/item/grenade/chem_grenade/incendiary,
					/obj/item/grenade/chem_grenade/incendiary,
					/obj/item/storage/box/shotgunammo/incendiaryshells)
	cost = 2500
	containertype = /obj/structure/closet/crate/secure/weapon
	crate_name = "Incendiary weapons crate"
	group = "Security"

/datum/supply_pack/armor
	name = "IH Surplus Armor"
	contains = list(/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest/security,
					/obj/item/clothing/suit/armor/vest/detective,
					/obj/item/clothing/suit/storage/vest,
					/obj/item/clothing/head/armor/helmet,
					/obj/item/clothing/head/armor/helmet)
	cost = 1500
	containertype = /obj/structure/closet/crate/secure
	crate_name = "IH Surplus Amor"
	group = "Security"

/datum/supply_pack/riot
	name = "IH Riot gear crate"
	contains = list(/obj/item/melee/baton,
					/obj/item/melee/baton,
					/obj/item/melee/baton,
					/obj/item/shield/riot,
					/obj/item/shield/riot,
					/obj/item/shield/riot,
					/obj/item/storage/box/flashbangs,
					/obj/item/storage/box/flashbangs,
					/obj/item/storage/box/flashbangs,
					/obj/item/handcuffs,
					/obj/item/handcuffs,
					/obj/item/handcuffs,
					/obj/item/clothing/head/armor/riot_hud,
					/obj/item/clothing/suit/armor/heavy/riot,
					/obj/item/clothing/head/armor/riot_hud,
					/obj/item/clothing/suit/armor/heavy/riot,
					/obj/item/clothing/head/armor/riot_hud,
					/obj/item/clothing/suit/armor/heavy/riot)
	cost = 6100
	containertype = /obj/structure/closet/crate/secure
	crate_name = "IH Riot gear crate"
	group = "Security"
/*
/datum/supply_pack/loyalty
	name = "Moebius Loyalty implant crate"
	contains = list (/obj/item/storage/lockbox/loyalty)
	cost = 6000
	containertype = /obj/structure/closet/crate/secure
	crate_name = "Moebius Loyalty implant crate"
	group = "Security"
*/
/datum/supply_pack/ballisticarmor
	name = "IH Ballistic Armor"
	contains = list(/obj/item/clothing/suit/armor/bulletproof/ironhammer,
					/obj/item/clothing/suit/armor/bulletproof/ironhammer,
					/obj/item/clothing/head/armor/bulletproof/ironhammer_nvg,
					/obj/item/clothing/head/armor/bulletproof/ironhammer_nvg)
	cost = 3000
	containertype = /obj/structure/closet/crate/secure
	crate_name = "IH Ballistic Armor Pack"
	group = "Security"

/datum/supply_pack/shotgunammo_beanbag
	name = "FS Shotgun shells (Beanbag)"
	contains = list(/obj/item/storage/box/shotgunammo/beanbags,
					/obj/item/storage/box/shotgunammo/beanbags,
					/obj/item/storage/box/shotgunammo/beanbags,
					/obj/item/storage/box/shotgunammo/beanbags,
					/obj/item/storage/box/shotgunammo/beanbags)
	cost = 1000
	crate_name = "FS Shotgun shells (Beanbag)"
	group = "Security"

/datum/supply_pack/shotgunammo_slug
	name = "FS Shotgun shells (slug)"
	contains = list(/obj/item/storage/box/shotgunammo/slug,
					/obj/item/storage/box/shotgunammo/slug,
					/obj/item/storage/box/shotgunammo/slug,
					/obj/item/storage/box/shotgunammo/slug,
					/obj/item/storage/box/shotgunammo/slug)
	cost = 1500
	containertype = /obj/structure/closet/crate/secure
	crate_name = "FS Shotgun shells (slug)"
	group = "Security"

/datum/supply_pack/shotgunammo_buckshot
	name = "FS Shotgun shells (buckshot)"
	contains = list(/obj/item/storage/box/shotgunammo/buckshot,
					/obj/item/storage/box/shotgunammo/buckshot,
					/obj/item/storage/box/shotgunammo/buckshot,
					/obj/item/storage/box/shotgunammo/buckshot,
					/obj/item/storage/box/shotgunammo/buckshot)
	cost = 1500
	containertype = /obj/structure/closet/crate/secure
	crate_name = "FS Shotgun shells (buckshot)"
	group = "Security"


/datum/supply_pack/energyarmor
	name = "IH Ablative Armor"
	contains = list(/obj/item/clothing/suit/armor/laserproof/full,
					/obj/item/clothing/suit/armor/laserproof/full,
					/obj/item/clothing/head/armor/laserproof,
					/obj/item/clothing/head/armor/laserproof)
	cost = 3500
	containertype = /obj/structure/closet/crate/secure
	crate_name = "IH Ablative Armor crate"
	group = "Security"

/datum/supply_pack/securitybarriers
	name = "IH Security Barrier crate"
	contains = list(/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier)
	cost = 2000
	containertype = /obj/structure/closet/crate/secure/gear
	crate_name = "IH Security Barrier crate"
	group = "Security"

/datum/supply_pack/securitywallshield
	name = "Wall shield Generators"
	contains = list(/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen)
	cost = 2000
	containertype = /obj/structure/closet/crate/secure
	crate_name = "wall shield generators crate"
	group = "Security"

//----------------------------------------------
//-----------------HOSPITALITY------------------
//----------------------------------------------
/*

/datum/supply_pack/vending_coffee
	name = "Hotdrinks supply crate"
	contains = list(/obj/item/vending_refill/coffee,
					/obj/item/vending_refill/coffee,
					/obj/item/vending_refill/coffee)
	cost = 1000
	containertype = /obj/structure/closet/crate/freezer
	crate_name = "hotdrinks supply crate"
	group = "Hospitality"

/datum/supply_pack/vending_snack
	name = "Snack supply crate"
	contains = list(/obj/item/vending_refill/snack,
					/obj/item/vending_refill/snack,
					/obj/item/vending_refill/snack)
	cost = 1000
	containertype = /obj/structure/closet/crate/freezer
	crate_name = "snack supply crate"
	group = "Hospitality"

/datum/supply_pack/vending_cola
	name = "Softdrinks supply crate"
	contains = list(/obj/item/vending_refill/cola,
					/obj/item/vending_refill/cola,
					/obj/item/vending_refill/cola)
	cost = 1000
	containertype = /obj/structure/closet/crate/freezer
	crate_name = "softdrinks supply crate"
	group = "Hospitality"

/datum/supply_pack/vending_cigarette
	name = "Cigarette supply crate"
	contains = list(/obj/item/vending_refill/cigarette,
					/obj/item/vending_refill/cigarette,
					/obj/item/vending_refill/cigarette)
	cost = 1000
	containertype = /obj/structure/closet/crate/freezer
	crate_name = "cigarette supply crate"
	group = "Hospitality"
*/

/datum/supply_pack/bardrinks
	name = "Bartending resupply crate"
	contains = list(/obj/item/reagent_containers/food/drinks/bottle/gin = 2,/obj/item/reagent_containers/food/drinks/bottle/whiskey = 2,
					/obj/item/reagent_containers/food/drinks/bottle/tequilla = 2,/obj/item/reagent_containers/food/drinks/bottle/vodka = 2,
					/obj/item/reagent_containers/food/drinks/bottle/vermouth = 2,/obj/item/reagent_containers/food/drinks/bottle/rum = 2,
					/obj/item/reagent_containers/food/drinks/bottle/wine = 3,/obj/item/reagent_containers/food/drinks/bottle/cognac = 2,
					/obj/item/reagent_containers/food/drinks/bottle/kahlua = 3,/obj/item/reagent_containers/food/drinks/bottle/small/beer = 6,
					/obj/item/reagent_containers/food/drinks/bottle/small/ale = 6,/obj/item/reagent_containers/food/drinks/bottle/orangejuice = 2,
					/obj/item/reagent_containers/food/drinks/bottle/tomatojuice = 2,/obj/item/reagent_containers/food/drinks/bottle/limejuice = 2,
					/obj/item/reagent_containers/food/drinks/bottle/cream = 2,/obj/item/reagent_containers/food/drinks/cans/tonic = 6,
					/obj/item/reagent_containers/food/drinks/bottle/cola = 5,/obj/item/reagent_containers/food/drinks/bottle/space_up = 5,
					/obj/item/reagent_containers/food/drinks/bottle/space_mountain_wind = 5,/obj/item/reagent_containers/food/drinks/cans/sodawater = 15,
					/obj/item/reagent_containers/food/drinks/flask/barflask = 2,/obj/item/reagent_containers/food/drinks/bottle/bluecuracao = 2,
					/obj/item/reagent_containers/food/drinks/drinkingglass = 30,/obj/item/reagent_containers/food/drinks/bottle/grenadine = 5,
					/obj/item/reagent_containers/food/drinks/bottle/melonliquor = 2,/obj/item/reagent_containers/food/drinks/bottle/absinthe = 1)
	cost = 3000
	containertype = /obj/structure/closet/crate/freezer
	crate_name = "bartending resupply crate"
	group = "Hospitality"

/datum/supply_pack/party
	name = "Party equipment"
	contains = list(/obj/item/storage/box/drinkingglasses,
					/obj/item/reagent_containers/food/drinks/shaker,
					/obj/item/reagent_containers/food/drinks/flask/barflask,
					/obj/item/reagent_containers/food/drinks/bottle/patron,
					/obj/item/reagent_containers/food/drinks/bottle/goldschlager,
					/obj/item/storage/fancy/cigarettes/dromedaryco,
					/obj/item/lipstick/random,
					/obj/item/reagent_containers/food/drinks/bottle/small/ale,
					/obj/item/reagent_containers/food/drinks/bottle/small/ale,
					/obj/item/reagent_containers/food/drinks/bottle/small/beer,
					/obj/item/reagent_containers/food/drinks/bottle/small/beer,
					/obj/item/reagent_containers/food/drinks/bottle/small/beer,
					/obj/item/reagent_containers/food/drinks/bottle/small/beer)
	cost = 1200
	containertype = /obj/structure/closet/crate
	crate_name = "Party equipment"
	group = "Hospitality"

/datum/supply_pack/cakes
	name = "Party Cakes"
	contains = list(
		/obj/item/reagent_containers/food/snacks/sliceable/carrotcake,
		/obj/item/reagent_containers/food/snacks/sliceable/cheesecake,
		/obj/item/reagent_containers/food/snacks/sliceable/plaincake,
		/obj/item/reagent_containers/food/snacks/sliceable/orangecake,
		/obj/item/reagent_containers/food/snacks/sliceable/limecake,
		/obj/item/reagent_containers/food/snacks/sliceable/lemoncake,
		/obj/item/reagent_containers/food/snacks/sliceable/chocolatecake
	)
	cost = 2000
	containertype = /obj/structure/closet/crate
	crate_name = "Party Cake Box"
	group = "Hospitality"

//----------------------------------------------
//-----------------ENGINEERING------------------
//----------------------------------------------

/datum/supply_pack/internals
	name = "Internals crate"
	contains = list(/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/tank/air,
					/obj/item/tank/air,
					/obj/item/tank/air)
	cost = 600
	containertype = /obj/structure/closet/crate/internals
	crate_name = "Internals crate"
	group = "Engineering"

/datum/supply_pack/sleeping_agent
	name = "Canister: \[N2O\]"
	contains = list(/obj/machinery/portable_atmospherics/canister/sleeping_agent)
	cost = 2000
	containertype = /obj/structure/largecrate
	crate_name = "N2O crate"
	group = "Engineering"

/datum/supply_pack/oxygen
	name = "Canister: \[O2\]"
	contains = list(/obj/machinery/portable_atmospherics/canister/oxygen)
	cost = 1500
	containertype = /obj/structure/largecrate
	crate_name = "O2 crate"
	group = "Engineering"

/datum/supply_pack/nitrogen
	name = "Canister: \[N2\]"
	contains = list(/obj/machinery/portable_atmospherics/canister/nitrogen)
	cost = 1500
	containertype = /obj/structure/largecrate
	crate_name = "N2 crate"
	group = "Engineering"

/datum/supply_pack/air
	name = "Canister \[Air\]"
	contains = list(/obj/machinery/portable_atmospherics/canister/air)
	cost = 1500
	containertype = /obj/structure/largecrate
	crate_name = "Air crate"
	group = "Engineering"

/datum/supply_pack/evacuation
	name = "Emergency equipment"
	contains = list(/obj/item/storage/toolbox/emergency,
					/obj/item/storage/toolbox/emergency,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/tank/emergency_oxygen,
					/obj/item/tank/emergency_oxygen,
					/obj/item/tank/emergency_oxygen,
					/obj/item/tank/emergency_oxygen,
					/obj/item/tank/emergency_oxygen,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas)
	cost = 1000
	containertype = /obj/structure/closet/crate/internals
	crate_name = "Emergency crate"
	group = "Engineering"

/datum/supply_pack/inflatable
	name = "Inflatable barriers"
	contains = list(/obj/item/storage/briefcase/inflatable,
					/obj/item/storage/briefcase/inflatable,
					/obj/item/storage/briefcase/inflatable,
					/obj/item/storage/briefcase/inflatable,
					/obj/item/storage/briefcase/inflatable)
	cost = 1500
	containertype = /obj/structure/closet/crate/secure
	crate_name = "Inflatable Barrier Crate"
	group = "Engineering"

/datum/supply_pack/lightbulbs
	name = "Replacement lights"
	contains = list(/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed)
	cost = 700
	containertype = /obj/structure/closet/crate
	crate_name = "Replacement lights"
	group = "Engineering"

/datum/supply_pack/metal120
	name = "120 metal sheets"
	contains = list(/obj/item/stack/material/steel)
	amount = 120
	cost = 500
	containertype = /obj/structure/closet/crate/secure
	crate_name = "Metal sheets crate"
	group = "Engineering"

/datum/supply_pack/metal480
	name = "Bulk metal crate"
	contains = list(/obj/item/stack/material/steel/full,
	/obj/item/stack/material/steel/full,
	/obj/item/stack/material/steel/full,
	/obj/item/stack/material/steel/full)
	cost = 1200
	containertype = /obj/structure/largecrate
	crate_name = "Bulk metal crate"
	group = "Engineering"

/datum/supply_pack/glass50
	name = "120 glass sheets"
	contains = list(/obj/item/stack/material/glass)
	amount = 120
	cost = 500
	containertype = /obj/structure/closet/crate/secure
	crate_name = "Glass sheets crate"
	group = "Engineering"

/datum/supply_pack/wood50
	name = "120 wooden planks"
	contains = list(/obj/item/stack/material/wood)
	amount = 120
	cost = 2500
	containertype = /obj/structure/closet/crate
	crate_name = "Wooden planks crate"
	group = "Engineering"

/datum/supply_pack/plasteel60
	name = "60 Plasteel Sheets"
	contains = list(/obj/item/stack/material/plasteel)
	amount = 60
	cost = 3000
	containertype = /obj/structure/closet/crate/secure
	crate_name = "Plasteel sheets crate"
	group = "Engineering"

/datum/supply_pack/electrical
	name = "Electrical maintenance crate"
	contains = list(/obj/item/storage/toolbox/electrical,
					/obj/item/storage/toolbox/electrical,
					/obj/item/clothing/gloves/insulated,
					/obj/item/clothing/gloves/insulated,
					/obj/item/cell/large,
					/obj/item/cell/large,
					/obj/item/cell/large/high,
					/obj/item/cell/large/high)
	cost = 1200
	containertype = /obj/structure/closet/crate
	crate_name = "Electrical maintenance crate"
	group = "Engineering"

/datum/supply_pack/mechanical
	name = "Mechanical maintenance crate"
	contains = list(/obj/item/storage/belt/utility/full,
					/obj/item/storage/belt/utility/full,
					/obj/item/storage/belt/utility/full,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/hardhat)
	cost = 1000
	containertype = /obj/structure/closet/crate
	crate_name = "Mechanical maintenance crate"
	group = "Engineering"

/datum/supply_pack/toolmods
	contains = list(/obj/spawner/tool_upgrade,
					/obj/spawner/tool_upgrade,
					/obj/spawner/tool_upgrade,
					/obj/spawner/tool_upgrade,
					/obj/spawner/tool_upgrade,
					/obj/spawner/tool_upgrade,
					/obj/spawner/tool_upgrade,
					/obj/spawner/tool_upgrade,
					/obj/spawner/tool_upgrade,
					/obj/spawner/tool_upgrade,
					/obj/spawner/tool_upgrade)
	name = "Unsorted Tool Upgrades"
	cost = 2000
	containertype = /obj/structure/closet/crate
	crate_name = "Tool upgrade Crate"
	group = "Engineering"

/datum/supply_pack/omnitool
	contains = list(/obj/item/tool/omnitool,
					/obj/item/tool/omnitool)
	name = "\"Munchkin 5000\" omnitool"
	cost = 2500
	containertype = /obj/structure/closet/crate
	crate_name = "omnitool crate"
	group = "Engineering"

/datum/supply_pack/fueltank
	name = "Fuel tank crate"
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	cost = 800
	containertype = /obj/structure/largecrate
	crate_name = "fuel tank crate"
	group = "Engineering"

/datum/supply_pack/solar
	name = "Solar Pack crate"
	contains  = list(/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly, // 21 Solar Assemblies. 1 Extra for the controller
					/obj/item/electronics/circuitboard/solar_control,
					/obj/item/electronics/tracker,
					/obj/item/paper/solar)
	cost = 2000
	containertype = /obj/structure/closet/crate
	crate_name = "Solar pack crate"
	group = "Engineering"

/datum/supply_pack/engine
	name = "Emitter crate"
	contains = list(/obj/machinery/power/emitter,
					/obj/machinery/power/emitter)
	cost = 1500
	containertype = /obj/structure/closet/crate/secure
	crate_name = "Emitter crate"
	group = "Engineering"

/datum/supply_pack/engine/field_gen
	name = "Field Generator crate"
	contains = list(/obj/machinery/field_generator,
					/obj/machinery/field_generator)
	containertype = /obj/structure/closet/crate/secure
	crate_name = "Field Generator crate"

/datum/supply_pack/engine/sing_gen
	name = "Singularity Generator crate"
	contains = list(/obj/machinery/the_singularitygen)
	containertype = /obj/structure/closet/crate/secure
	crate_name = "Singularity Generator crate"

/datum/supply_pack/engine/collector
	name = "Collector crate"
	contains = list(/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector)
	containertype = /obj/structure/closet/crate/secure
	crate_name = "Collector crate"

/datum/supply_pack/engine/PA
	name = "Particle Accelerator crate"
	cost = 4000
	contains = list(/obj/structure/particle_accelerator/fuel_chamber,
					/obj/machinery/particle_accelerator/control_box,
					/obj/structure/particle_accelerator/particle_emitter/center,
					/obj/structure/particle_accelerator/particle_emitter/left,
					/obj/structure/particle_accelerator/particle_emitter/right,
					/obj/structure/particle_accelerator/power_box,
					/obj/structure/particle_accelerator/end_cap)
	containertype = /obj/structure/closet/crate/secure
	crate_name = "Particle Accelerator crate"

/datum/supply_pack/mech_ripley
	name = "exosuit assembly crate"
	contains = list(
		/obj/item/mech_equipment/drill,
		/obj/item/mech_equipment/clamp,
		/obj/item/mech_equipment/light,
		/obj/item/mech_component/sensors/cheap,
		/obj/item/mech_component/chassis/cheap,
		/obj/item/mech_component/manipulators/cheap,
		/obj/item/mech_component/propulsion/cheap,
		/obj/item/robot_parts/robot_component/exosuit_control,
		/obj/item/robot_parts/robot_component/armour/exosuit
	)
	cost = 3000
	containertype = /obj/structure/closet/crate/secure/scisecurecrate
	crate_name = "standart exosuit assembly crate"
	group = "Engineering"

/datum/supply_pack/robotics
	name = "Robotics assembly crate"
	contains = list(/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/storage/toolbox/electrical,
					/obj/item/device/flash,
					/obj/item/device/flash,
					/obj/item/device/flash,
					/obj/item/device/flash,
					/obj/item/cell/large/high,
					/obj/item/cell/large/high)
	cost = 1000
	containertype = /obj/structure/closet/crate/secure/scisecurecrate
	crate_name = "Robotics assembly"
	access = access_robotics
	group = "Engineering"

//Contains six, you'll probably want to build several of these
/datum/supply_pack/shield_diffuser
	contains = list(/obj/item/electronics/circuitboard/shield_diffuser,
	/obj/item/electronics/circuitboard/shield_diffuser,
	/obj/item/electronics/circuitboard/shield_diffuser,
	/obj/item/electronics/circuitboard/shield_diffuser,
	/obj/item/electronics/circuitboard/shield_diffuser,
	/obj/item/electronics/circuitboard/shield_diffuser,
	/obj/item/electronics/circuitboard/shield_diffuser)
	name = "Shield diffuser circuitry"
	cost = 3000
	containertype = /obj/structure/closet/crate/secure
	crate_name = "Shield diffuser circuitry crate"
	group = "Engineering"
	access = access_ce

/datum/supply_pack/shield_gen
	contains = list(/obj/item/electronics/circuitboard/shield_generator)
	name = "Hull shield generator circuitry"
	cost = 5000
	containertype = /obj/structure/closet/crate/secure
	crate_name = "hull shield generator circuitry crate"
	group = "Engineering"

/*/datum/supply_pack/shield_cap
	contains = list(/obj/item/electronics/circuitboard/shield_cap)
	name = "Bubble shield capacitor circuitry"
	cost = 5000
	containertype = /obj/structure/closet/crate/secure
	crate_name = "shield capacitor circuitry crate"
	group = "Engineering"
	*/

/datum/supply_pack/lrange_scanner
	contains = list(/obj/item/electronics/circuitboard/long_range_scanner)
	name = "Long range scanner circuitry"
	cost = 5000
	containertype = /obj/structure/closet/crate/secure
	crate_name = "long range scanner circuitry crate"
	group = "Engineering"

/datum/supply_pack/smbig
	name = "Supermatter Core (CAUTION)"
	contains = list(/obj/machinery/power/supermatter)
	cost = 20000
	containertype = /obj/structure/closet/crate/secure/woodseccrate
	crate_name = "Supermatter crate (CAUTION)"
	group = "Engineering"
	access = access_ce

/datum/supply_pack/teg
	contains = list(/obj/machinery/power/generator)
	name = "Mark I Thermoelectric Generator"
	cost = 3000
	containertype = /obj/structure/closet/crate/secure/large
	crate_name = "Mk1 TEG crate"
	group = "Engineering"

/datum/supply_pack/circulator
	contains = list(/obj/machinery/atmospherics/binary/circulator)
	name = "Binary atmospheric circulator"
	cost = 1500
	containertype = /obj/structure/closet/crate/secure/large
	crate_name = "Atmospheric circulator crate"
	group = "Engineering"

/datum/supply_pack/air_dispenser
	contains = list(/obj/machinery/pipedispenser/orderable)
	name = "Pipe Dispenser"
	cost = 900
	containertype = /obj/structure/closet/crate/secure/large
	crate_name = "Pipe Dispenser Crate"
	group = "Engineering"

/datum/supply_pack/disposals_dispenser
	contains = list(/obj/machinery/pipedispenser/disposal/orderable)
	name = "Disposals Pipe Dispenser"
	cost = 900
	containertype = /obj/structure/closet/crate/secure/large
	crate_name = "Disposal Dispenser Crate"
	group = "Engineering"


//----------------------------------------------
//------------MEDICAL / SCIENCE-----------------
//----------------------------------------------

/datum/supply_pack/medical
	name = "Medical kits crate"
	contains = list(/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/fire,
					/obj/item/storage/firstaid/toxin,
					/obj/item/storage/firstaid/o2,
					/obj/item/storage/firstaid/adv,
					/obj/item/reagent_containers/glass/bottle/antitoxin,
					/obj/item/reagent_containers/glass/bottle/inaprovaline,
					/obj/item/reagent_containers/glass/bottle/stoxin,
					/obj/item/storage/box/syringes,
					/obj/item/storage/box/autoinjectors)
	cost = 1000
	containertype = /obj/structure/closet/crate/medical
	crate_name = "Medical kits crate"
	group = "Medical / Science"

/datum/supply_pack/medical
	name = "Medical supply crate"
	contains = list(/obj/item/stack/medical/bruise_pack,
					/obj/item/stack/medical/bruise_pack,
					/obj/item/stack/medical/bruise_pack,
					/obj/item/stack/medical/bruise_pack,
					/obj/item/stack/medical/bruise_pack,
					/obj/item/stack/medical/ointment,
					/obj/item/stack/medical/ointment,
					/obj/item/stack/medical/ointment,
					/obj/item/stack/medical/ointment,
					/obj/item/stack/medical/ointment)
	cost = 1000
	containertype = /obj/structure/closet/crate/medical
	crate_name = "Medical supply crate"
	group = "Medical / Science"

/datum/supply_pack/virus
	name = "Virus sample crate"
	contains = list(/obj/item/virusdish/random,
					/obj/item/virusdish/random,
					/obj/item/virusdish/random,
					/obj/item/virusdish/random)
	cost = 2500
	containertype = /obj/structure/closet/crate/secure
	crate_name = "Virus sample crate"
	access = access_cmo
	group = "Medical / Science"

/datum/supply_pack/research
	name = "Research Data crate"
	contains = list(/obj/item/computer_hardware/hard_drive/portable/research_points,
					/obj/item/computer_hardware/hard_drive/portable/research_points)
	cost = 5000
	containertype = /obj/structure/closet/crate/secure
	crate_name = "Research data crate"
	access = access_moebius
	group = "Medical / Science"

/datum/supply_pack/coolanttank
	name = "Coolant tank crate"
	contains = list(/obj/structure/reagent_dispensers/coolanttank)
	cost = 1600
	containertype = /obj/structure/largecrate
	crate_name = "Coolant tank crate"
	group = "Medical / Science"

/datum/supply_pack/plasma
	name = "Plasma assembly crate"
	contains = list(/obj/item/tank/plasma,
					/obj/item/tank/plasma,
					/obj/item/tank/plasma,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer)
	cost = 1500
	containertype = /obj/structure/closet/crate/secure/scisecurecrate
	crate_name = "Plasma assembly crate"
	access = access_tox_storage
	group = "Medical / Science"

/datum/supply_pack/surgery
	name = "Surgery crate"
	contains = list(/obj/item/tool/cautery,
					/obj/item/tool/surgicaldrill,
					/obj/item/clothing/mask/breath/medical,
					/obj/item/tank/anesthetic,
					/obj/item/tool/hemostat,
					/obj/item/tool/scalpel,
					/obj/item/tool/retractor,
					/obj/item/tool/bonesetter,
					/obj/item/tool/saw/circular)
	cost = 1200
	containertype = /obj/structure/closet/crate/secure
	crate_name = "Surgery crate"
	access = access_moebius
	group = "Medical / Science"

/datum/supply_pack/sterile
	name = "Sterile equipment crate"
	contains = list(/obj/item/clothing/under/rank/medical/green,
					/obj/item/clothing/under/rank/medical/green,
					/obj/item/clothing/head/surgery/green,
					/obj/item/clothing/head/surgery/green,
					/obj/item/storage/box/masks,
					/obj/item/storage/box/gloves)
	cost = 900
	containertype = /obj/structure/closet/crate
	crate_name = "Sterile equipment crate"
	group = "Medical / Science"

/datum/supply_pack/bloodpacks
	name = "Blood Pack Variety Crate"
	cost = 1500
	contains = list(/obj/item/reagent_containers/blood/empty,
					/obj/item/reagent_containers/blood/empty,
					/obj/item/reagent_containers/blood/APlus,
					/obj/item/reagent_containers/blood/AMinus,
					/obj/item/reagent_containers/blood/BPlus,
					/obj/item/reagent_containers/blood/BMinus,
					/obj/item/reagent_containers/blood/OPlus,
					/obj/item/reagent_containers/blood/OMinus)
	containertype = /obj/structure/closet/crate/freezer
	crate_name = "blood freezer"
	group = "Medical / Science"

/datum/supply_pack/medical_stand
	name = "Medical stand Crate"
	cost = 700
	contains = list(/obj/structure/medical_stand)
	containertype = /obj/structure/closet/crate/medical
	crate_name = "medical stand crate"
	group = "Medical / Science"

/datum/supply_pack/body_bags
	name = "Body Bags Crate"
	cost = 600
	contains = list(/obj/item/storage/box/bodybags,
					/obj/item/storage/box/bodybags,
					/obj/item/storage/box/bodybags,
					/obj/item/storage/box/bodybags)
	crate_name = "body bags crate"
	group = "Medical / Science"

/datum/supply_pack/suspension_gen
	name = "Suspension Field Generetor Crate"
	cost = 2500
	contains = list(/obj/machinery/suspension_gen)
	containertype = /obj/structure/closet/crate/secure/scisecurecrate
	crate_name = "Suspension Field Generetor Crate"
	group = "Medical / Science"

/datum/supply_pack/floodlight
	name = "Emergency Floodlight Crate"
	cost = 1400
	contains = list(/obj/machinery/floodlight,
					/obj/machinery/floodlight)
	containertype = /obj/structure/closet/crate/scicrate
	crate name = "Emergency Floodlight Crate"
	group = "Medical / Science"

/datum/supply_pack/nanites
	name = "Raw Nanites"
	contains = list(
		/obj/item/reagent_containers/glass/beaker/vial/nanites
	)
	cost = 1500
	crate_name = "Raw Nanites Container"
	group = "Medical / Science"
	containertype = /obj/structure/closet/crate/medical

/datum/supply_pack/uncapnanites
	name = "Raw Uncapped Nanites"
	contains = list(
		/obj/item/reagent_containers/glass/beaker/vial/uncapnanites
	)
	cost = 2000
	crate_name = "Raw Nanites Container"
	group = "Medical / Science"
	contraband = TRUE
	containertype = /obj/structure/closet/crate/medical

//----------------------------------------------
//-----------------HYDROPONICS------------------
//----------------------------------------------

/datum/supply_pack/monkey
	name = "Monkey crate"
	contains = list (/obj/item/storage/box/monkeycubes)
	cost = 1500
	containertype = /obj/structure/closet/crate/freezer
	crate_name = "Monkey crate"
	group = "Hydroponics"

/datum/supply_pack/hydroponics // -- Skie
	name = "Hydroponics Supply Crate"
	contains = list(/obj/item/reagent_containers/spray/plantbgone,
					/obj/item/reagent_containers/spray/plantbgone,
					/obj/item/reagent_containers/glass/bottle/ammonia,
					/obj/item/reagent_containers/glass/bottle/ammonia,
					/obj/item/tool/hatchet,
					/obj/item/tool/minihoe,
					/obj/item/device/scanner/plant,
					/obj/item/clothing/gloves/botanic_leather,
					/obj/item/clothing/suit/apron) // Updated with new things
	cost = 900
	containertype = /obj/structure/closet/crate/hydroponics
	crate_name = "Hydroponics crate"
	group = "Hydroponics"

// Bees
/datum/supply_pack/bees
	name = "Bee crate"
	contains = list(/obj/item/bee_pack,
					/obj/item/bee_smoker,
					/obj/item/electronics/circuitboard/honey_extractor)
	cost = 700
	containertype = /obj/structure/closet/crate
	crate_name = "Bee crate"
	group = "Hydroponics"

//farm animals - useless and annoying, but potentially a good source of food
/datum/supply_pack/cow
	name = "Cow crate"
	cost = 3000
	containertype = /obj/structure/largecrate/animal/cow
	crate_name = "Cow crate"
	group = "Hydroponics"

/datum/supply_pack/goat
	name = "Goat crate"
	cost = 2500
	containertype = /obj/structure/largecrate/animal/goat
	crate_name = "Goat crate"
	group = "Hydroponics"

/datum/supply_pack/chicken
	name = "Chicken crate"
	cost = 1500
	containertype = /obj/structure/largecrate/animal/chick
	crate_name = "Chicken crate"
	group = "Hydroponics"

/datum/supply_pack/corgi
	name = "Corgi crate"
	cost = 4000
	containertype = /obj/structure/largecrate/animal/corgi
	crate_name = "Corgi crate"
	group = "Hydroponics"

/datum/supply_pack/cat
	name = "Cat crate"
	cost = 3000
	containertype = /obj/structure/largecrate/animal/cat
	crate_name = "Cat crate"
	group = "Hydroponics"

/datum/supply_pack/seeds
	name = "Seeds crate"
	contains = list(/obj/item/seeds/chiliseed,
					/obj/item/seeds/berryseed,
					/obj/item/seeds/cornseed,
					/obj/item/seeds/eggplantseed,
					/obj/item/seeds/tomatoseed,
					/obj/item/seeds/appleseed,
					/obj/item/seeds/soyaseed,
					/obj/item/seeds/wheatseed,
					/obj/item/seeds/carrotseed,
					/obj/item/seeds/harebell,
					/obj/item/seeds/lemonseed,
					/obj/item/seeds/orangeseed,
					/obj/item/seeds/grassseed,
					/obj/item/seeds/sunflowerseed,
					/obj/item/seeds/chantermycelium,
					/obj/item/seeds/potatoseed,
					/obj/item/seeds/sugarcaneseed)
	cost = 800
	containertype = /obj/structure/closet/crate/hydroponics
	crate_name = "Seeds crate"
	group = "Hydroponics"

/datum/supply_pack/weedcontrol
	name = "Weed control crate"
	contains = list(/obj/item/clothing/mask/gas,
					/obj/item/grenade/chem_grenade/antiweed,
					/obj/item/grenade/chem_grenade/antiweed,
					/obj/item/grenade/chem_grenade/antiweed,
					/obj/item/grenade/chem_grenade/antiweed)
	cost = 1000
	containertype = /obj/structure/closet/crate/secure/hydrosec
	crate_name = "Weed control crate"
	group = "Hydroponics"

/datum/supply_pack/exoticseeds
	name = "Exotic seeds crate"
	contains = list(/obj/item/seeds/libertymycelium,
					/obj/item/seeds/reishimycelium,
					/obj/item/seeds/random,
					/obj/item/seeds/random,
					/obj/item/seeds/random,
					/obj/item/seeds/random,
					/obj/item/seeds/random,
					/obj/item/seeds/random,
					/obj/item/seeds/kudzuseed)
	cost = 1500
	containertype = /obj/structure/closet/crate/hydroponics
	crate_name = "Exotic Seeds crate"
	group = "Hydroponics"

/datum/supply_pack/watertank
	name = "Water tank crate"
	contains = list(/obj/structure/reagent_dispensers/watertank)
	cost = 800
	containertype = /obj/structure/largecrate
	crate_name = "Water tank crate"
	group = "Hydroponics"
/*
/datum/supply_pack/bee_keeper
	name = "Beekeeping crate"
	contains = list(/obj/item/beezeez,
					/obj/item/bee_net,
					/obj/item/apiary,
					/obj/item/queen_bee)
	cost = 2000
	contraband = TRUE
	containertype = /obj/structure/closet/crate/hydroponics
	crate_name = "Beekeeping crate"
	group = "Hydroponics"
*/
//----------------------------------------------
//--------------------MINING--------------------
//----------------------------------------------
/*
/datum/supply_pack/mining
	name = "Mining Explosives Crate"
	contains = list(/obj/item/mining_charge,
					/obj/item/mining_charge,
					/obj/item/mining_charge,
					/obj/item/mining_charge,
					/obj/item/mining_charge,
					/obj/item/mining_charge,
					/obj/item/mining_charge,
					/obj/item/mining_charge,
					/obj/item/mining_charge,
					/obj/item/mining_charge,)
	cost = 1500
	containertype = /obj/structure/closet/crate/secure/gear
	crate_name = "Mining Explosives Crate"
	access = access_mining
	group = "Mining"
*/
/datum/supply_pack/mining_drill
	name = "Drill Crate"
	contains = list(/obj/machinery/mining/drill)
	cost = 3000
	containertype = /obj/structure/closet/crate/secure/large
	crate_name = "Drill Crate"
	group = "Mining"

/datum/supply_pack/mining_brace
	name = "Brace Crate"
	contains = list(/obj/machinery/mining/brace)
	cost = 1500
	containertype = /obj/structure/closet/crate/secure/large
	crate_name = "Brace Crate"
	group = "Mining"

/datum/supply_pack/mining_supply
	name = "Mining Supply Crate"
	contains = list(
					/obj/item/reagent_containers/spray/cleaner,
					/obj/item/device/lighting/toggleable/flashlight,
					/obj/item/tool/pickaxe/jackhammer)
	cost = 1000
	containertype = /obj/structure/closet/crate/secure/gear
	crate_name = "Mining Supply Crate"
	group = "Mining"

//----------------------------------------------
//--------------------SUPPLY--------------------
//----------------------------------------------

/datum/supply_pack/food
	name = "Kitchen supply crate"
	contains = list(/obj/item/reagent_containers/food/condiment/flour,
					/obj/item/reagent_containers/food/condiment/flour,
					/obj/item/reagent_containers/food/condiment/flour,
					/obj/item/reagent_containers/food/condiment/flour,
					/obj/item/reagent_containers/food/drinks/milk,
					/obj/item/reagent_containers/food/drinks/milk,
					/obj/item/storage/fancy/egg_box,
					/obj/item/reagent_containers/food/snacks/tofu,
					/obj/item/reagent_containers/food/snacks/tofu,
					/obj/item/reagent_containers/food/snacks/meat,
					/obj/item/reagent_containers/food/snacks/meat,
					/obj/item/reagent_containers/food/condiment/enzyme,
					/obj/item/reagent_containers/food/condiment/enzyme,)

	cost = 900
	containertype = /obj/structure/closet/crate/freezer
	crate_name = "Food crate"
	group = "Supply"

/datum/supply_pack/toner
	name = "Toner cartridges"
	contains = list(/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner)
	cost = 600
	crate_name = "Toner cartridges"
	group = "Supply"

/datum/supply_pack/misc/posters
	name = "Corporate Posters Crate"
	contains = list(/obj/item/contraband/poster,
					/obj/item/contraband/poster,
					/obj/item/contraband/poster,
					/obj/item/contraband/poster,
					/obj/item/contraband/poster)
	cost = 700
	crate_name = "Corporate Posters Crate"
	group = "Supply"

/datum/supply_pack/janitor
	name = "Janitorial supplies"
	contains = list(/obj/item/reagent_containers/glass/bucket,
					/obj/item/mop,
					/obj/item/mop,
					/obj/item/mop,
					/obj/item/mop,
					/obj/item/caution,
					/obj/item/caution,
					/obj/item/caution,
					/obj/item/caution,
					/obj/item/storage/bag/trash,
					/obj/item/device/lightreplacer,
					/obj/item/reagent_containers/spray/cleaner,
					/obj/item/reagent_containers/glass/rag,
					/obj/item/grenade/chem_grenade/cleaner,
					/obj/item/grenade/chem_grenade/cleaner,
					/obj/item/grenade/chem_grenade/cleaner,
					/obj/structure/mopbucket)
	cost = 1000
	crate_name = "Janitorial supplies"
	group = "Supply"

/datum/supply_pack/boxes
	name = "Empty boxes"
	contains = list(/obj/item/storage/box,
	/obj/item/storage/box,
	/obj/item/storage/box,
	/obj/item/storage/box,
	/obj/item/storage/box,
	/obj/item/storage/box,
	/obj/item/storage/box,
	/obj/item/storage/box,
	/obj/item/storage/box,
	/obj/item/storage/box)
	cost = 800
	crate_name = "Empty box crate"
	group = "Supply"

//----------------------------------------------
//-----------------R.I.G------------------------
//----------------------------------------------

/datum/supply_pack/eva
	name = "EVA Suit Control Module Crate"
	contains = list(/obj/item/rig/eva)
	cost = 600
	crate_name = "EVA Suit Control Module Crate"
	group = "Resource Integration Gear"

/datum/supply_pack/hazard
	name = "Hazard Hardsuit Control Module Crate"
	contains = list(/obj/item/rig/hazard)
	cost = 1100
	crate_name = "Hazard Hardsuit Control Module Crate"
	group = "Resource Integration Gear"

/datum/supply_pack/industrial
	name = "Industrial Hardsuit Control Module Crate"
	contains = list(/obj/item/rig/industrial)
	cost = 3000
	crate_name = "Industrial Hardsuit Control Module Crate"
	group = "Resource Integration Gear"

/datum/supply_pack/flash
	name = "Mounted Flash Module Crate"
	contains = list(/obj/item/rig_module/device/flash)
	cost = 300
	crate_name = "Mouned Flash Module Crate"
	group = "Resource Integration Gear"

/datum/supply_pack/egun
	name = "Mounted Energy Gun Module Crate"
	contains = list(/obj/item/rig_module/mounted/egun)
	cost = 2100
	crate_name = "Mouned Energy Gun Module Crate"
	group = "Resource Integration Gear"

/datum/supply_pack/taser
	name = "Mounted Taser Gun Module Crate"
	contains = list(/obj/item/rig_module/mounted/taser)
	cost = 900
	crate_name = "Mouned Taser Gun Module Crate"
	group = "Resource Integration Gear"

/datum/supply_pack/drill
	name = "Hardsuit Mounted Drill Crate"
	contains = list(/obj/item/rig_module/device/drill)
	cost = 600
	crate_name = "Hardsuit Mounted Drill Crate"
	group = "Resource Integration Gear"

/datum/supply_pack/orescanner
	name = "Hardsuit Mounted Ore Scanner Crate"
	contains = list(/obj/item/rig_module/device/orescanner)
	cost = 300
	crate_name = "Hardsuit Mounted Ore Scanner Crate"
	group = "Resource Integration Gear"

/datum/supply_pack/healthscanner
	name = "Hardsuit Mounted Health Scanner Crate"
	contains = list(/obj/item/rig_module/device/healthscanner)
	cost = 300
	crate_name = "Hardsuit Mounted Health Scanner Crate"
	group = "Resource Integration Gear"

/datum/supply_pack/maneuverjet
	name = "Hardsuit Maneuvering Jet Crate"
	contains = list(/obj/item/rig_module/maneuvering_jets)
	cost = 1200
	crate_name = "Hardsuit Maneuvering Jet Crate"
	group = "Resource Integration Gear"

/datum/supply_pack/storage
	name = "Internal Hardsuit Storage Compartment Crate"
	contains = list(/obj/item/rig_module/storage)
	cost = 1200
	crate_name = "Internal Hardsuit Storage Compartment Crate"
	group = "Resource Integration Gear"

/datum/supply_pack/meson
	name = "Hardsut Meson Scanner Crate"
	contains = list(/obj/item/rig_module/vision/meson)
	cost = 300
	crate_name = "Hardsut Meson Scanner Crate"
	group = "Resource Integration Gear"

/datum/supply_pack/medhud
	name = "Hardsuit Medical Hud Crate"
	contains = list(/obj/item/rig_module/vision/medhud)
	cost = 300
	crate_name = "Hardsuit Medical Hud Crate"
	group = "Resource Integration Gear"

/datum/supply_pack/sechud
	name = "Hardsuit Security Hud Crate"
	contains = list(/obj/item/rig_module/vision/sechud)
	cost = 300
	crate_name = "Hardsuit Security Hud Crate"
	group = "Resource Integration Gear"

/datum/supply_pack/nvgrig
	name = "Hardsuit Night vision Interface Crate"
	contains = list(/obj/item/rig_module/vision/nvg)
	cost = 1800
	crate_name = "Hardsuit Night vision Interface Crate"
	group = "Resource Integration Gear"
//----------------------------------------------
//--------------MISCELLANEOUS-------------------
//----------------------------------------------

/datum/supply_pack/formal_wear
	contains = list(/obj/item/clothing/head/bowler,
					/obj/item/clothing/head/that,
					/obj/item/clothing/under/suit_jacket,
					/obj/item/clothing/under/suit_jacket/red,
					/obj/item/clothing/shoes/color/black,
					/obj/item/clothing/shoes/color/black,
					/obj/item/clothing/shoes/leather,
					/obj/item/clothing/suit/wcoat)
	name = "Formalwear closet"
	cost = 1500
	containertype = /obj/structure/closet
	crate_name = "Formalwear for the best occasions."
	group = "Miscellaneous"

/datum/supply_pack/eftpos
	contains = list(/obj/item/device/eftpos)
	name = "EFTPOS scanner"
	cost = 700
	crate_name = "EFTPOS crate"
	group = "Miscellaneous"

/datum/supply_pack/discs
	contains = list(/obj/item/computer_hardware/hard_drive/portable/design,
					/obj/item/computer_hardware/hard_drive/portable/design,
					/obj/item/computer_hardware/hard_drive/portable/design,
					/obj/item/computer_hardware/hard_drive/portable/design,
					/obj/item/computer_hardware/hard_drive/portable/design,
					/obj/item/computer_hardware/hard_drive/portable/design)
	name = "Empty Design Disk Crate"
	cost = 1000
	crate_name ="Empty disks crate"
	group = "Miscellaneous"

//----------------------------------------------
//-----------------RANDOMISED-------------------
//----------------------------------------------

/datum/supply_pack/randomised
	name = "Collectable Hats Crate!"
	cost = 20000
	var/num_contained = 4 //number of items picked to be contained in a randomised crate
	contains = list(/obj/item/clothing/head/collectable/chef,
					/obj/item/clothing/head/collectable/paper,
					/obj/item/clothing/head/collectable/tophat,
					/obj/item/clothing/head/collectable/captain,
					/obj/item/clothing/head/collectable/beret,
					/obj/item/clothing/head/collectable/welding,
					/obj/item/clothing/head/collectable/flatcap,
					/obj/item/clothing/head/collectable/pirate,
					/obj/item/clothing/head/collectable/kitty,
					/obj/item/clothing/head/collectable/rabbitears,
					/obj/item/clothing/head/collectable/wizard,
					/obj/item/clothing/head/collectable/hardhat,
					/obj/item/clothing/head/collectable/thunderdome,
					/obj/item/clothing/head/collectable/swat,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/police,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/xenom,
					/obj/item/clothing/head/collectable/petehat)
	crate_name = "Collectable hats crate! Brought to you by Bass.inc!"
	group = "Miscellaneous"

/datum/supply_pack/randomised/fill(obj/structure/closet/crate/C)
	var/list/L = contains.Copy()
	var/item
	if(num_contained <= L.len)
		for(var/i in 1 to num_contained)
			item = pick_n_take(L)
			new item(C)
	else
		for(var/i in 1 to num_contained)
			item = pick(L)
			new item(C)

/datum/supply_pack/randomised/contraband
	num_contained = 5
	contains = list(/obj/item/seeds/bloodtomatoseed,
					/obj/item/storage/pill_bottle/zoom,
					/obj/item/seeds/kudzuseed,
					/obj/item/storage/pill_bottle/happy,
					/obj/item/contraband/poster,
					/obj/item/reagent_containers/food/drinks/bottle/pwine)
	name = "Contraband crate"
	cost = 3000
	containertype = /obj/structure/closet/crate
	crate_name = "Unlabeled crate"
	contraband = TRUE
	group = "Operations"

/datum/supply_pack/randomised/pizza
	num_contained = 5
	contains = list(/obj/item/pizzabox/margherita,
					/obj/item/pizzabox/mushroom,
					/obj/item/pizzabox/meat,
					/obj/item/pizzabox/vegetable)
	name = "Surprise pack of five pizzas"
	cost = 1500
	containertype = /obj/structure/closet/crate/freezer
	crate_name = "Pizza crate"
	group = "Hospitality"

/datum/supply_pack/randomised/costume
	num_contained = 2
	contains = list(/obj/item/clothing/suit/pirate,
					/obj/item/clothing/suit/judgerobe,
					/obj/item/clothing/suit/wcoat,
					/obj/item/clothing/suit/nun,
					/obj/item/clothing/under/rank/fo_suit,
					/obj/item/clothing/suit/bio_suit/plaguedoctorsuit,
					/obj/item/clothing/under/schoolgirl,
					/obj/item/clothing/under/owl,
					/obj/item/clothing/under/waiter,
					/obj/item/clothing/under/gladiator,
					/obj/item/clothing/under/soviet,
					/obj/item/clothing/under/bride_white,
					/obj/item/clothing/suit/chef,
					/obj/item/clothing/under/kilt)
	name = "Costumes crate"
	cost = 1000
	containertype = /obj/structure/closet/crate/secure
	crate_name = "Actor Costumes"
	access = access_theatre
	group = "Miscellaneous"

/datum/supply_pack/randomised/guns
	num_contained = 4
	contains = list(/obj/spawner/gun/cheap,
					/obj/spawner/gun/cheap,
					/obj/spawner/gun/cheap,
					/obj/spawner/gun/cheap)
	name = "Surplus Weaponry"
	cost = 3500
	crate_name = "Surplus Weapons Crate"
	containertype = /obj/structure/closet/crate/secure/weapon
	group = "Security"

/datum/supply_pack/randomised/ammo
	num_contained = 8
	contains = list(/obj/spawner/ammo/low_cost,
			/obj/spawner/ammo/low_cost,
			/obj/spawner/ammo/low_cost,
			/obj/spawner/ammo/low_cost,
			/obj/spawner/ammo/low_cost,
			/obj/spawner/ammo/low_cost,
			/obj/spawner/ammo/low_cost,
			/obj/spawner/ammo/low_cost,
				)
	name = "Surplus Ammo"
	cost = 1500
	crate_name = "Surplus Ammo Crate"
	containertype = /obj/structure/closet/crate/secure/weapon
	group = "Security"

/datum/supply_pack/randomised/pouches
	num_contained = 5
	contains = list(/obj/spawner/pouch,
				/obj/spawner/pouch,
				/obj/spawner/pouch,
				/obj/spawner/pouch,
				/obj/spawner/pouch)
	name = "Surplus Storage Pouches"
	cost = 1500
	crate_name = "Surplus Pouches Crate"
	containertype = /obj/structure/closet/crate
	group = "Operations"


/datum/supply_pack/randomised/holsters
	num_contained = 4
	contains = list(/obj/spawner/cloth/holster,
					/obj/spawner/cloth/holster,
					/obj/spawner/cloth/holster,
					/obj/spawner/cloth/holster)
	name = "Surplus Unform Holsters"
	cost = 1000
	crate_name = "Surplus Uniform Holsters Crate"
	containertype = /obj/structure/closet/crate
	group = "Operations"

/datum/supply_pack/randomised/voidsuit
	num_contained = 1
	contains = list(/obj/spawner/voidsuit,
					/obj/spawner/voidsuit/damaged)
	name = "Surplus Voidsuit"
	cost = 1500
	crate_name = "Surplus Voidsuit Crate"
	containertype = /obj/structure/closet/crate
	group = "Operations"

/datum/supply_pack/randomised/rig
	num_contained = 1
	contains = list(/obj/spawner/rig,
					/obj/spawner/rig/damaged)
	name = "Surplus Rig Suit"
	cost = 5000
	crate_name = "Surplus Rig Crate"
	containertype = /obj/structure/closet/crate
	group = "Operations"

/datum/supply_pack/randomised/rigmods
	num_contained = 2
	contains = list(/obj/spawner/rig_module,
				/obj/spawner/rig_module)
	name = "Surplus Rig Modules"
	cost = 2500
	crate_name = "Surplus Rig Modules"
	containertype = /obj/structure/closet/crate
	group = "Operations"

/datum/supply_pack/randomised/cartons
	num_contained = 2
	contains = list(/obj/item/storage/fancy/cigcartons,
				/obj/item/storage/fancy/cigcartons/dromedaryco,
				/obj/item/storage/fancy/cigcartons/killthroat,
				/obj/item/storage/fancy/cigcartons/homeless)
	name = "Cigarettes Cartons"
	cost = 1200
	crate_name = "Cigarettes Cartons Crate"
	containertype = /obj/structure/closet/crate
	group = "Supply"

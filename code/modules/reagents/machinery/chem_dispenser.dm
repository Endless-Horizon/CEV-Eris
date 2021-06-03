#define chemical_dispenser_ENERGY_COST (CHEM_SYNTH_ENERGY * CELLRATE) //How many cell charge do we use per unit of chemical?
#define BOTTLE_SPRITES list("bottle") //list of available bottle sprites

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/obj/machinery/chemical_dispenser
	name = "chem dispenser"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE // Handles power use in Process()
	layer = BELOW_OBJ_LAYER
	circuit = /obj/item/weapon/electronics/circuitboard/chemical_dispenser

	var/ui_title = "Chem Dispenser 5000"
	var/obj/item/weapon/cell/medium/cell
	var/amount = 30
	var/accept_beaker = TRUE //At TRUE, ONLY accepts beakers.
	var/hackedcheck = FALSE
	var/list/dispensable_reagents = list(
		"hydrazine","lithium","carbon",
		"ammonia","acetone","sodium",
		"aluminum","silicon","phosphorus",
		"sulfur","hclacid","potassium",
		"iron","copper","mercury",
		"radium","water","ethanol",
		"sugar","sacid","tungsten"
	)
	var/list/hacked_reagents = list()
	var/obj/item/weapon/reagent_containers/beaker

/obj/machinery/chemical_dispenser/RefreshParts()
	cell = locate() in component_parts

/obj/machinery/chemical_dispenser/proc/recharge()
	if(stat & (BROKEN|NOPOWER)) return
	var/addenergy = cell.give(min(24, cell.maxcharge*cell.max_chargerate))
	if(addenergy)
		use_power(addenergy / CELLRATE)
		SSnano.update_uis(src) // update all UIs attached to src

/obj/machinery/chemical_dispenser/power_change()
	..()
	update_icon()
	SSnano.update_uis(src) // update all UIs attached to src

/obj/machinery/chemical_dispenser/Process()
	if(cell && cell.percent() < 100)
		recharge()

/obj/machinery/chemical_dispenser/Initialize()
	. = ..()
	dispensable_reagents = sortList(dispensable_reagents)


/obj/machinery/chemical_dispenser/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
			return
		if(2)
			if (prob(50))
				del(src)
				return


/obj/machinery/chemical_dispenser/nano_ui_data()
	var/list/data = list()
	data["amount"] = amount
	data["energy"] = round(cell.charge)
	data["maxEnergy"] = round(cell.maxcharge)
	data["accept_beaker"] = accept_beaker

	var/list/chemicals = list()
	for (var/re in dispensable_reagents)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[re]
		if(temp)
			chemicals.Add(list(list("title" = temp.name, "id" = temp.id, "commands" = list("dispense" = temp.id)))) // list in a list because Byond merges the first list...
	data["chemicals"] = chemicals

	if(beaker)
		data["beaker"] = beaker.reagents.nano_ui_data()

	return data

/obj/machinery/chemical_dispenser/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = NANOUI_FOCUS)
	var/list/data = nano_ui_data()

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "chem_dispenser.tmpl", ui_title, 390, 655)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

/obj/machinery/chemical_dispenser/proc/detach()
	if(beaker)
		var/obj/item/weapon/reagent_containers/B = beaker
		B.loc = loc
		beaker = null
		update_icon()

/obj/machinery/chemical_dispenser/AltClick(mob/living/user)
	if(user.incapacitated())
		to_chat(user, SPAN_WARNING("You can't do that right now!"))
		return
	if(!in_range(src, user))
		return
	src.detach()


/obj/machinery/chemical_dispenser/Topic(href, href_list)
	if(..())
		return

	if(href_list["amount"])
		// Since the user can actually type the commands himself, some sanity checking
		amount = round(text2num(href_list["amount"]), 5) // round to nearest 5
		amount = CLAMP(amount, 0, 120)

	if(href_list["dispense"])
		if (dispensable_reagents.Find(href_list["dispense"]) && beaker && beaker.is_refillable())
			var/obj/item/weapon/reagent_containers/B = src.beaker
			var/datum/reagents/R = B.reagents
			var/space = R.maximum_volume - R.total_volume

			var/added_amount = min(amount, cell.charge / chemical_dispenser_ENERGY_COST, space)
			R.add_reagent(href_list["dispense"], added_amount)
			cell.use(added_amount * chemical_dispenser_ENERGY_COST)
			investigate_log("dispensed [href_list["dispense"]] into [B], while being operated by [key_name(usr)]", "chemistry")

	if(href_list["ejectBeaker"])
		src.detach()

	return 1 // update UIs attached to this object


/obj/machinery/chemical_dispenser/MouseDrop_T(atom/movable/I, mob/user, src_location, over_location, src_control, over_control, params)
	if(!Adjacent(user) || !I.Adjacent(user) || user.stat)
		return ..()
	if(istype(I, /obj/item/weapon/reagent_containers) && I.is_open_container() && !beaker)
		user.unEquip(I, src)
		I.add_fingerprint(user)
		beaker = I
		to_chat(user, SPAN_NOTICE("You add [I] to [src]."))
		SSnano.update_uis(src) // update all UIs attached to src
		return
	. = ..()

/obj/machinery/chemical_dispenser/attackby(obj/item/I, mob/living/user)
	if(default_deconstruction(I, user))
		return

	if(default_part_replacement(I, user))
		return

	var/obj/item/weapon/reagent_containers/B = I
	if(beaker)
		to_chat(user, "Something is already loaded into the machine.")
		return
	if(istype(B, /obj/item/weapon/reagent_containers/glass) || istype(B, /obj/item/weapon/reagent_containers/food))
		if(accept_beaker && istype(B, /obj/item/weapon/reagent_containers/food))
			to_chat(user, SPAN_NOTICE("This machine only accepts beakers"))
		src.beaker =  B
		if (user.unEquip(B, src))
			to_chat(user, "You set [B] on the machine.")
			update_icon()
			SSnano.update_uis(src) // update all UIs attached to src
			return

/obj/machinery/chemical_dispenser/attack_hand(mob/living/user)
	if(stat & BROKEN)
		return
	nano_ui_interact(user)

/obj/machinery/chemical_dispenser/soda
	icon_state = "soda_dispenser"
	name = "soda fountain"
	desc = "A drink fabricating machine, capable of producing many sugary drinks with just one touch."
	layer = OBJ_LAYER
	ui_title = "Soda Dispens-o-matic"
	var/icon_on = "soda_dispenser"

	circuit = /obj/item/weapon/electronics/circuitboard/chemical_dispenser/soda

	accept_beaker = FALSE
	density = FALSE
	dispensable_reagents = list("water","ice","coffee","cream","tea","greentea","icetea","icegreentea","cola","spacemountainwind","dr_gibb","space_up","tonic","sodawater","lemon_lime","sugar","orangejuice","limejuice","watermelonjuice")
	hacked_reagents = list("thirteenloko","grapesoda")

/obj/machinery/chemical_dispenser/soda/attackby(obj/item/I, mob/living/user)
	..()
	if(istype(I, /obj/item/weapon/tool/multitool) && length(hacked_reagents))
		hackedcheck = !hackedcheck
		if(!hackedcheck)
			to_chat(user, "You change the mode from 'McNano' to 'Pizza King'.")
			dispensable_reagents += hacked_reagents

		else
			to_chat(user, "You change the mode from 'Pizza King' to 'McNano'.")
			dispensable_reagents -= hacked_reagents

obj/machinery/chemical_dispenser/soda/on_update_icon()
	cut_overlays()
	if(stat & (BROKEN|NOPOWER))
		icon_state = icon_on+"_off"
	else
		icon_state = icon_on

	if(beaker)
		add_overlays(image(icon, icon_on+"_loaded"))


/obj/machinery/chemical_dispenser/beer
	icon_state = "booze_dispenser"
	name = "booze dispenser"
	layer = OBJ_LAYER
	ui_title = "Booze Portal 9001"

	circuit = /obj/item/weapon/electronics/circuitboard/chemical_dispenser/beer

	accept_beaker = FALSE
	density = FALSE
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	dispensable_reagents = list("lemon_lime","sugar","orangejuice","limejuice","sodawater","tonic","beer","kahlua","whiskey","wine","vodka","gin","rum","tequilla","vermouth","cognac","ale","mead")
	hacked_reagents = list("goldschlager","patron","watermelonjuice","berryjuice")

/obj/machinery/chemical_dispenser/beer/attackby(obj/item/I, mob/living/user)
	..()

	if(istype(I, /obj/item/weapon/tool/multitool) && length(hacked_reagents))
		hackedcheck = !hackedcheck
		if(!hackedcheck)
			to_chat(user, "You disable the 'cheap bastards' lock, enabling hidden and very expensive boozes.")
			dispensable_reagents += hacked_reagents

		else
			to_chat(user, "You re-enable the 'cheap bastards' lock, disabling hidden and very expensive boozes.")
			dispensable_reagents -= hacked_reagents

/obj/machinery/chemical_dispenser/admin
	name = "debug chem dispenser"
	desc = "A mysterious chemical dispenser that can produce all sorts of highly advanced medicines at the press of a button."
	ui_title = "Cheat Synthesizer 1337"
	dispensable_reagents = list(
		"inaprovaline","ryetalyn","paracetamol",
		"tramadol","oxycodone","sterilizine",
		"leporazine","kelotane","dermaline",
		"dexalin","dexalinp","tricordrazine",
		"anti_toxin","synaptizine","hyronalin",
		"arithrazine","alkysine","imidazoline",
		"peridaxon","bicaridine","meralyne","hyperzine",
		"rezadone","spaceacillin","ethylredoxrazine",
		"stoxin","chloralhydrate","cryoxadone",
		"clonexadone","ossisine","noexcutite","kyphotorin",
		"detox","polystem","purger","addictol","aminazine",
		"vomitol","haloperidol","paroxetine","citalopram",
		"methylphenidate"
	)

/obj/machinery/chemical_dispenser/industrial
	name = "industrial chem dispenser"
	icon = 'icons/obj/machines/chemistry.dmi'
	icon_state = "industrial_dispenser"
	ui_title = "Industrial Dispenser 4835"

	circuit = /obj/item/weapon/electronics/circuitboard/chemical_dispenser/industrial

	dispensable_reagents = list(
		"acetone","aluminum","ammonia",
		"copper","ethanol","hydrazine",
		"iron","radium","sacid",
		"hclacid","silicon","tungsten"
	)

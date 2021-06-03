/**
 *  Datum used to hold information about a product in a vending machine
 */
/datum/data/vending_product
	var/product_name = "generic" // Display name for the product
	var/product_desc
	var/product_path
	var/amount = 0            // The original amount held in the vending machine
	var/price = 0              // Price to buy one
	var/display_color   // Display color for vending machine listing
	var/category = CAT_NORMAL  // CAT_HIDDEN for contraband, CAT_COIN for premium
	var/obj/machinery/vending/vending_machine   // The vending machine we belong to
	var/list/instances = list()		   // Stores inserted items. Instances are only used for things added during the round, and not for things spawned at initialize


/datum/data/vending_product/New(vending_machine, path, name = null, amount = 1, price = 0, color = null, category = CAT_NORMAL)
	..()

	product_path = path
	product_name = name
	src.price = price
	src.amount = amount
	display_color = color
	src.category = category

	var/obj/tmp = path

	if(!product_name)
		product_name = initial(tmp.name)
		if(ispath(tmp, /obj/item/weapon/computer_hardware/hard_drive/portable))
			var/obj/item/weapon/computer_hardware/hard_drive/portable/tmp_disk = tmp
			if(initial(tmp_disk.disk_name))
				product_name = initial(tmp_disk.disk_name)

	product_desc = initial(tmp.desc)

	src.vending_machine = vending_machine

	if(src.price <= 0 && src.vending_machine.auto_price)
		src.price = initial(tmp.price_tag)

/datum/data/vending_product/Destroy()
	vending_machine.product_records.Remove(src)
	vending_machine = null
	. = ..()

/datum/data/vending_product/proc/get_amount()
	return amount

/datum/data/vending_product/proc/add_product(var/atom/movable/product)
	if(product.type != product_path)
		return 0
	playsound(vending_machine.loc, 'sound/machines/vending_drop.ogg', 100, 1)
	instances.Add(product)
	product.forceMove(vending_machine)
	amount += 1

/datum/data/vending_product/proc/get_product(var/product_location)
	if(get_amount() <= 0 || !product_location)
		return
	var/atom/movable/product
	if(instances && instances.len)
		product = instances[instances.len]
		instances.Remove(product)
	else
		product = new product_path
	amount -= 1
	GET_COMPONENT_FROM(oldified, /datum/component/oldficator, vending_machine)
	if(oldified && isobj(product) && prob(30))
		var/obj/O = product
		O.make_old()
	product.forceMove(product_location)
	return product



/**
 *  A vending machine
 */
/obj/machinery/vending
	name = "Vendomat"
	desc = "A generic vending machine."
	icon = 'icons/obj/vending.dmi'
	icon_state = "generic"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	density = TRUE

	var/icon_vend //Icon_state when vending
	var/icon_deny //Icon_state when denying access
	var/icon_type //For overlays after remodeling a custom vending machine

	// Power
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	var/vend_power_usage = 150 //actuators and stuff

	// Vending-related
	var/active = 1 //No sales pitches if off!
	var/vend_ready = 1 //Are we ready to vend?? Is it time??
	var/vend_delay = 10 //How long does it take to vend?
	var/categories = CAT_NORMAL // Bitmask of cats we're currently showing
	var/datum/data/vending_product/currently_vending = null // What we're requesting payment for right now
	var/managing = 0 //Are we in the vendor management screen?
	var/status_message = "" // Status screen messages like "insufficient funds", displayed in NanoUI
	var/status_error = 0 // Set to 1 if status_message is an error

	/*
		Variables used to initialize the product list
		These are used for initialization only, and so are optional if
		product_records is specified
	*/
	var/list/products	= list() // For each, use the following pattern:
	var/list/contraband	= list() // list(/type/path = amount,/type/path2 = amount2)
	var/list/premium 	= list() // No specified amount = only one in stock
	var/list/prices     = list() // Prices for each item, list(/type/path = price), items not in the list don't have a price.

	// List of vending_product items available.
	var/list/product_records = list()


	// Variables used to initialize advertising
	var/product_slogans = "" //String of slogans spoken out loud, separated by semicolons
	var/product_ads = "" //String of small ad messages in the vending screen

	var/list/ads_list = list()

	// Stuff relating vocalizations
	var/list/slogan_list = list()
	var/shut_up = 0 //Let spouting those godawful pitches!
	var/vend_reply //Thank you for shopping!
	var/last_reply = 0
	var/last_slogan = 0 //When did we last pitch?
	var/slogan_delay = 6000 //How long until we can pitch again?

	// Things that can go wrong
	emagged = 0 //Ignores if somebody doesn't have card access to that machine.
	var/seconds_electrified = 0 //Shock customers like an airlock.
	var/shoot_inventory = 0 //Fire items at customers! We're broken!

	var/custom_vendor = FALSE //If it's custom, it can be loaded with stuff as long as it's unlocked.
	var/locked = TRUE
	var/datum/money_account/machine_vendor_account //Owner of this vendomat. Used for access.
	var/datum/money_account/earnings_account //Money flows in and out of this account.
	var/vendor_department = null //If set, members can manage this vendomat. earnings_account is set to the department's account automatically.
	var/buying_percentage = 0 //If set, the vendomat will accept people selling items to it, and in return will give (percentage * listed item price) in cash
	var/scan_id = 1
	var/auto_price = TRUE //The vendomat will automatically set prices on products if their price is not specified.
	var/obj/item/weapon/coin/coin
	var/datum/wires/vending/wires = null
	var/always_open	=	FALSE  // If true, this machine allows products to be inserted without requirinf the maintenance hatch to be screwed open first
	var/list/can_stock = list()	//A whitelist of objects which can be stocked into this vendor
	//Note that a vendor can always accept restocks of things it has had in the past. This is in addition to that
	var/no_criminals = FALSE //If true, the machine asks if you're wanted by security when you try to order.

/obj/machinery/vending/New()
	..()
	wires = new(src)
	icon_type = initial(icon_state)
	power_change()


/obj/machinery/vending/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/vending/LateInitialize()
	..()
	if(product_slogans)
		slogan_list += splittext(product_slogans, ";")

		// So not all machines speak at the exact same time.
		// The first time this machine says something will be at slogantime + this random value,
		// so if slogantime is 10 minutes, it will say it at somewhere between 10 and 20 minutes after the machine is crated.
		last_slogan = world.time + rand(0, slogan_delay)

	if(product_ads)
		ads_list += splittext(src.product_ads, ";")

	build_inventory()
	power_change()


/**
 * Add item to the machine
 *
 * Checks if item is vendable in this machine should be performed before
 * calling. W is the item being inserted, R is the associated vending_product entry.
 	R can be null, in which case the user is inserting something that wasnt previously here.
 	In that case we create a new inventory record for the item
 */
/obj/machinery/vending/proc/stock(obj/item/weapon/W, var/datum/data/vending_product/R, var/mob/user)
	if(!user.unEquip(W))
		return

	to_chat(user, SPAN_NOTICE("You insert \the [W] in the product receptor."))
	if(R)
		R.add_product(W)
	else
		new_inventory(W)

	SSnano.update_uis(src)

/obj/machinery/vending/proc/try_to_buy(obj/item/weapon/W, var/datum/data/vending_product/R, var/mob/user)
	if(!earnings_account)
		to_chat(user, SPAN_WARNING("[src] flashes a message: Vendomat not registered to an account."))
		return
	if(vendor_department)
		to_chat(user, SPAN_WARNING("[src] flashes a message: Vendomat not authorized to accept sales. Please contact a member of [GLOB.all_departments[vendor_department]]."))
		return
	if(buying_percentage <= 0)
		to_chat(user, SPAN_WARNING("[src] flashes a message: Vendomat not accepting sales."))
		return

	if(!user.unEquip(W))
		return

	var/buying_price = round(R.price * buying_percentage/100,5)
	if(earnings_account.money < buying_price)
		to_chat(user, SPAN_WARNING("[src] flashes a message: Account is unable to make this purchase."))
		return
	var/datum/transaction/T = new(-buying_price, "[user.name]", "Sale of [R.product_name]", src)
	T.apply_to(earnings_account)

	R.add_product(W)

	spawn_money(buying_price,loc,usr)

	to_chat(user, SPAN_NOTICE("[src] accepts the sale of [W] and dispenses [buying_price] credits."))


	SSnano.update_uis(src)


/**
 *  Build src.produdct_records from the products lists
 *
 *  src.products, src.contraband, src.premium, and src.prices allow specifying
 *  products that the vending machine is to carry without manually populating
 *  src.product_records.
 */
/obj/machinery/vending/proc/build_inventory()
	var/list/all_products = list(
		list(products, CAT_NORMAL),
		list(contraband, CAT_HIDDEN),
		list(premium, CAT_COIN))

	for(var/current_list in all_products)
		var/category = current_list[2]

		for(var/entry in current_list[1])
			var/datum/data/vending_product/product = new/datum/data/vending_product(src, entry)

			product.price = (entry in prices) ? prices[entry] : product.price
			product.amount = (current_list[1][entry]) ? current_list[1][entry] : 1
			product.category = category

			product_records.Add(product)


//This is used when a user inserts something during the round which wasn't previously a product
/obj/machinery/vending/proc/new_inventory(var/obj/item/I)
	var/datum/data/vending_product/product = new/datum/data/vending_product(src, I.type, I.name)
	product.amount = 1
	product.price = I.get_item_cost()
	playsound(loc, 'sound/machines/vending_drop.ogg', 100, 1)
	product_records.Add(product)
	product.instances.Add(I)
	I.forceMove(src)
	return product


/obj/machinery/vending/Destroy()
	qdel(wires)
	wires = null
	qdel(coin)
	coin = null
	for(var/datum/data/vending_product/R in product_records)
		qdel(R)
	product_records.Cut()
	return ..()

/obj/machinery/vending/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if(prob(50))
				qdel(src)
				return
		if(3)
			if(prob(25))
				spawn(0)
					malfunction()
					return
				return
		else
	return

/obj/machinery/vending/emag_act(var/remaining_charges, var/mob/user)
	if(machine_vendor_account || vendor_department || earnings_account)
		to_chat(user, "You override the ownership protocols on \the [src] and unlock it. You can now register it in your name.")
		machine_vendor_account = null
		vendor_department = null
		earnings_account = null
		return 1
	if(!emagged)
		emagged = 1
		to_chat(user, "You short out the product lock on \the [src]")
		return 1

/obj/machinery/vending/attackby(obj/item/I, mob/user)

	var/tool_type = I.get_tool_type(user, list(QUALITY_BOLT_TURNING, QUALITY_SCREW_DRIVING, QUALITY_WELDING), src)
	switch(tool_type)

		if(QUALITY_BOLT_TURNING)
			if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
				to_chat(user, SPAN_NOTICE("You [anchored? "un" : ""]secured \the [src]!"))
				anchored = !anchored
			return

		if(QUALITY_SCREW_DRIVING)
			var/used_sound = panel_open ? 'sound/machines/Custom_screwdriveropen.ogg' :  'sound/machines/Custom_screwdriverclose.ogg'
			if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC, instant_finish_tier = 30, forced_sound = used_sound))
				panel_open = !panel_open
				to_chat(user, SPAN_NOTICE("You [panel_open ? "open" : "close"] the maintenance panel."))
				cut_overlays()
				if(panel_open)
					add_overlays(image(icon, "[icon_type]-panel"))
				SSnano.update_uis(src)
			return

		if(QUALITY_WELDING)
			if(custom_vendor)
				if(!panel_open)
					to_chat(usr, SPAN_WARNING("The maintenance panel on \the [src] needs to be open before deconstructing it."))
					return
				if(I.use_tool(user, src, WORKTIME_EXTREMELY_LONG, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					visible_message(SPAN_WARNING("\The [src] has been dismantled by [user]!"),"You hear welding.")
					new /obj/item/stack/material/steel(loc, 8)
					for(var/datum/data/vending_product/R in product_records)
						for(var/obj/O in R.instances)
							O.forceMove(loc)
					new /obj/item/weapon/electronics/circuitboard/vending(loc)
					qdel(src)

		if(ABORT_CHECK)
			return

	var/obj/item/weapon/card/id/ID = I.GetIdCard()

	if(currently_vending && earnings_account && !earnings_account.suspended)
		var/paid = 0
		var/handled = 0

		if(ID) //for IDs and PDAs and wallets with IDs
			paid = pay_with_card(ID,I)
			handled = 1
			playsound(usr.loc, 'sound/machines/id_swipe.ogg', 100, 1)
		else if(istype(I, /obj/item/weapon/spacecash/ewallet))
			var/obj/item/weapon/spacecash/ewallet/C = I
			paid = pay_with_ewallet(C)
			handled = 1
			playsound(usr.loc, 'sound/machines/id_swipe.ogg', 100, 1)
		else if(istype(I, /obj/item/weapon/spacecash/bundle))
			var/obj/item/weapon/spacecash/bundle/C = I
			paid = pay_with_cash(C)
			handled = 1

		if(paid)
			vend(currently_vending, usr)
			return
		else if(handled)
			SSnano.update_uis(src)
			return // don't smack that machine with your 2 credits

	if(custom_vendor && ID)
		var/datum/money_account/user_account = get_account(ID.associated_account_number)
		managing = 1
		if(!user_account)
			status_message = "Error: Unable to access account. Please contact technical support if problem persists."
			status_error = 1
			SSnano.update_uis(src)
			return 0

		if(user_account.suspended)
			status_message = "Unable to access account: account suspended."
			status_error = 1
			SSnano.update_uis(src)
			return 0


		if(machine_vendor_account == user_account || !machine_vendor_account || vendor_department)
			if(vendor_department)
				var/datum/computer_file/report/crew_record/CR = get_crewmember_record(user_account.owner_name)
				var/datum/job/userjob = SSjob.GetJob(CR.get_job())
				if(userjob.department == vendor_department)
					locked = !locked
					status_error = 0
					status_message = "Affiliation confirmed. Vendor has been [locked ? "" : "un"]locked."
				else
					status_error = 1
					status_message = "Error: You are not authorized to manage this Vendomat."
				SSnano.update_uis(src)
				return
			// Enter PIN, so you can't loot a vending machine with only the owner's ID card (as long as they increased the sec level)
			if(user_account.security_level != 0)
				var/attempt_pin = input("Enter pin code", "Vendor transaction") as num | null
				user_account = attempt_account_access(ID.associated_account_number, attempt_pin, 2)

				if(!user_account)
					status_message = "Unable to access account: incorrect credentials."
					status_error = 1
					SSnano.update_uis(src)
					return 0
			if(!machine_vendor_account)
				machine_vendor_account = user_account
				earnings_account = user_account

			locked = !locked
			status_error = 0
			status_message = "Owner confirmed. Vendor has been [locked ? "" : "un"]locked."
			playsound(usr.loc, 'sound/machines/id_swipe.ogg', 60, 1)
			visible_message("<span class='info'>\The [usr] swipes \the [ID] through \the [src], [locked ? "" : "un"]locking it.</span>")
			SSnano.update_uis(src)
			return

	if(I && istype(I, /obj/item/weapon/spacecash))
		attack_hand(user)
		return

	else if((QUALITY_CUTTING in I.tool_qualities) || (QUALITY_WIRE_CUTTING in I.tool_qualities) || (QUALITY_PULSING in I.tool_qualities))
		if(panel_open)
			attack_hand(user)
		return
	else if(istype(I, /obj/item/weapon/coin) && premium.len > 0)
		user.drop_item()
		I.loc = src
		coin = I
		categories |= CAT_COIN
		to_chat(user, SPAN_NOTICE("You insert \the [I] into \the [src]."))
		SSnano.update_uis(src)
		return

	for(var/datum/data/vending_product/R in product_records)
		if(I.type == R.product_path && I.name == R.product_name)
			if(!locked || always_open || (panel_open && !custom_vendor))
				stock(I, R, user)
				return 1
			else if(custom_vendor)
				try_to_buy(I, R, user)
				return 1

	for(var/a in can_stock)
		if(istype(I, a))
			if(!locked || always_open || !custom_vendor)
				stock(I, null, user)
				return 1
	..()

/**
 *  Receive payment with cashmoney.
 */
/obj/machinery/vending/proc/pay_with_cash(var/obj/item/weapon/spacecash/bundle/cashmoney)
	if(currently_vending.price > cashmoney.worth)
		// This is not a status display message, since it's something the character
		// themselves is meant to see BEFORE putting the money in
		to_chat(usr, "\icon[cashmoney] <span class='warning'>That is not enough money.</span>")
		return 0

	visible_message("<span class='info'>\The [usr] inserts some cash into \the [src].</span>")
	cashmoney.worth -= currently_vending.price

	if(cashmoney.worth <= 0)
		usr.drop_from_inventory(cashmoney)
		qdel(cashmoney)
	else
		cashmoney.update_icon()

	// Vending machines have no idea who paid with cash
	credit_purchase("(cash)")
	return 1

/**
 * Scan a chargecard and deduct payment from it.
 *
 * Takes payment for whatever is the currently_vending item. Returns 1 if
 * successful, 0 if failed.
 */
/obj/machinery/vending/proc/pay_with_ewallet(var/obj/item/weapon/spacecash/ewallet/wallet)
	visible_message("<span class='info'>\The [usr] swipes \the [wallet] through \the [src].</span>")
	if(currently_vending.price > wallet.worth)
		status_message = "Insufficient funds on chargecard."
		status_error = 1
		return 0
	else
		wallet.worth -= currently_vending.price
		credit_purchase("[wallet.owner_name] (chargecard)")
		return 1

/**
 * Scan a card and attempt to transfer payment from associated account.
 *
 * Takes payment for whatever is the currently_vending item. Returns 1 if
 * successful, 0 if failed
 */
/obj/machinery/vending/proc/pay_with_card(var/obj/item/weapon/card/id/I, var/obj/item/ID_container)
	if(I==ID_container || ID_container == null)
		visible_message("<span class='info'>\The [usr] swipes \the [I] through \the [src].</span>")
	else
		visible_message("<span class='info'>\The [usr] swipes \the [ID_container] through \the [src].</span>")
	var/datum/money_account/customer_account = get_account(I.associated_account_number)
	if(!customer_account)
		status_message = "Error: Unable to access account. Please contact technical support if problem persists."
		status_error = 1
		return 0

	if(customer_account.suspended)
		status_message = "Unable to access account: account suspended."
		status_error = 1
		return 0

	// Have the customer punch in the PIN before checking if there's enough money. Prevents people from figuring out acct is
	// empty at high security levels
	if(customer_account.security_level != 0) //If card requires pin authentication (ie seclevel 1 or 2)
		var/attempt_pin = input("Enter pin code", "Vendor transaction") as num
		customer_account = attempt_account_access(I.associated_account_number, attempt_pin, 2)

		if(!customer_account)
			status_message = "Unable to access account: incorrect credentials."
			status_error = 1
			return 0

	if(currently_vending.price > customer_account.money)
		status_message = "Insufficient funds in account."
		status_error = 1
		return 0
	else
		// Okay to move the money at this point

		// create entry in the purchaser's account log
		var/datum/transaction/T = new(-currently_vending.price, earnings_account.get_name(), "Purchase of [currently_vending.product_name]", src)
		T.apply_to(customer_account)

		// Give the vendor the money. We use the account owner name, which means
		// that purchases made with stolen/borrowed card will look like the card
		// owner made them
		credit_purchase(customer_account.owner_name)
		return 1

/**
 *  Add money for current purchase to the vendor account.
 *
 *  Called after the money has already been taken from the customer.
 */
/obj/machinery/vending/proc/credit_purchase(target)
	var/datum/transaction/T = new(currently_vending.price, target, "Purchase of [currently_vending.product_name]", src)
	T.apply_to(earnings_account)

/obj/machinery/vending/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/vending/attack_hand(mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return

	if(seconds_electrified != 0)
		if(src.shock(user, 100))
			return

	wires.Interact(user)
	nano_ui_interact(user)

/**
 *  Display the NanoUI window for the vending machine.
 *
 *  See NanoUI documentation for details.
 */
/obj/machinery/vending/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	user.set_machine(src)

	var/list/data = list()

	data["unlocked"] = !locked
	data["custom"] = custom_vendor
	if(custom_vendor && machine_vendor_account && machine_vendor_account.owner_name)
		data["owner_name"] = machine_vendor_account.get_name()

	if(managing)
		data["mode"] = 2
		data["message"] = status_message
		data["message_err"] = status_error
	else if(currently_vending)
		data["mode"] = 1
		data["product"] = currently_vending.product_name
		data["description"] = currently_vending.product_desc
		data["price"] = currently_vending.price
		data["message_err"] = 0
		data["message"] = status_message
		data["message_err"] = status_error
	else
		data["advertisement"] = ads_list.len ? pick(ads_list) : null
		data["markup"] = buying_percentage
		data["mode"] = 0
		var/list/listed_products = list()

		for(var/key = 1 to product_records.len)
			var/datum/data/vending_product/I = product_records[key]

			if(!(I.category & categories))
				continue

			listed_products.Add(list(list(
				"key" = key,
				"name" = strip_improper(I.product_name),
				"price" = I.price,
				"color" = I.display_color,
				"amount" = I.get_amount())))

		data["products"] = listed_products

	if(coin)
		data["coin"] = coin.name

	if(panel_open)
		data["panel"] = 1
		data["speaker"] = shut_up ? 0 : 1
	else
		data["panel"] = 0

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "vending_machine.tmpl", name, 440, 600)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/vending/Topic(href, href_list)
	if(stat & (BROKEN|NOPOWER))
		return
	if(usr.stat || usr.restrained())
		return

	if(href_list["remove_coin"] && !issilicon(usr))
		if(!coin)
			to_chat(usr, "There is no coin in this machine.")
			return

		coin.loc = loc
		if(!usr.get_active_hand())
			usr.put_in_hands(coin)
		to_chat(usr, SPAN_NOTICE("You remove the [coin] from the [src]"))
		coin = null
		categories &= ~CAT_COIN

	if((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))))
		if((href_list["vend"]) && (vend_ready) && (!currently_vending))
			if((!allowed(usr)) && !emagged && scan_id)	//For SECURE VENDING MACHINES YEAH
				to_chat(usr, SPAN_WARNING("Access denied."))	//Unless emagged of course
				FLICK(icon_deny,src)
				return

			var/key = text2num(href_list["vend"])
			var/datum/data/vending_product/R = product_records[key]

			// This should not happen unless the request from NanoUI was bad
			if(!(R.category & categories))
				return

			if(R.price <= 0 || !locked)
				vend(R, usr)
			else if(issilicon(usr)) //If the item is not free, provide feedback if a synth is trying to buy something.
				to_chat(usr, SPAN_DANGER("Artificial unit recognized.  Artificial units cannot complete this transaction.  Purchase canceled."))
				return
			else
				currently_vending = R
				if(!earnings_account || earnings_account.suspended)
					status_message = "This machine is currently unable to process payments due to problems with the associated account."
					status_error = 1
				else
					status_message = "Please swipe a card or insert cash to pay for the item."
					if(no_criminals)
						status_message += " We are legally required to ask if you are currently wanted by any law enforcement organizations. If so, please cancel the purchase, announce your location to local law enforcement and wait for them to collect you."
					status_error = 0

		else if(href_list["setprice"] && !locked)
			var/key = text2num(href_list["setprice"])
			var/datum/data/vending_product/R = product_records[key]

			R.price = input("Enter item price.", "Item price") as num | null

		else if(href_list["remove"] && !locked)
			var/key = text2num(href_list["remove"])
			var/datum/data/vending_product/R = product_records[key]

			qdel(R)

		else if(href_list["return"])
			managing = FALSE

		else if(href_list["management"])
			managing = TRUE
			status_message = "Welcome to the management screen."
			status_error = 0

		else if(href_list["setaccount"])
			var/datum/money_account/newaccount = get_account(input("Please enter the number of the account that will handle transactions for this Vendomat.", "Vendomat Account", null) as num | null)
			if(!newaccount)
				status_message = "No account specified. No change to earnings account has been made."
			else
				var/input_pin = input("Please enter the PIN for this account.", "Account PIN", null) as num | null
				if(input_pin == newaccount.remote_access_pin)
					status_message = "This Vendomat will now use the specified account, owned by [newaccount.get_name()]."
					status_error = 0
					earnings_account = newaccount
				else
					status_message = "Error: PIN incorrect. No change to earnings account has been made."
					status_error = 1

		else if(href_list["markup"])
			if(vendor_department)
				status_message = "Error: Department Vendomats are not authorized to buy items for fraud concerns."
				status_error = 1
			else
				var/newpercent = input("Please enter the percentage of the sale value the Vendomat should offer when purchasing items. Set to 0 to deny sales.", "Markup", null) as num | null
				if(newpercent)
					buying_percentage = max(0, min(newpercent,100))

		else if(href_list["setdepartment"])
			set_department()

		else if(href_list["unregister"])
			machine_vendor_account = null
			earnings_account = null

		else if(href_list["cancelpurchase"])
			currently_vending = null

		else if((href_list["togglevoice"]) && (panel_open))
			shut_up = !shut_up

		add_fingerprint(usr)
		playsound(usr.loc, 'sound/machines/button.ogg', 100, 1)
		SSnano.update_uis(src)

/obj/machinery/vending/proc/vend(datum/data/vending_product/R, mob/user)
	if((!allowed(usr)) && !emagged && scan_id)	//For SECURE VENDING MACHINES YEAH
		to_chat(usr, SPAN_WARNING("Access denied."))	//Unless emagged of course
		FLICK(icon_deny,src)
		return
	vend_ready = 0 //One thing at a time!!
	status_message = "Vending..."
	status_error = 0
	SSnano.update_uis(src)

	if(R.category & CAT_COIN)
		if(!coin)
			to_chat(user, SPAN_NOTICE("You need to insert a coin to get this item."))
			return
		if(coin.string_attached)
			if(prob(50))
				to_chat(user, SPAN_NOTICE("You successfully pull the coin out before \the [src] could swallow it."))
			else
				to_chat(user, SPAN_NOTICE("You weren't able to pull the coin out fast enough, the machine ate it, string and all."))
				qdel(coin)
				categories &= ~CAT_COIN
		else
			qdel(coin)
			categories &= ~CAT_COIN

	if(((last_reply + (vend_delay + 200)) <= world.time) && vend_reply)
		spawn(0)
			speak(vend_reply)
			last_reply = world.time

	use_power(vend_power_usage)	//actuators and stuff
	if(icon_vend) //Show the vending animation if needed
		FLICK(icon_vend,src)
	spawn(vend_delay)
		if(R.get_product(get_turf(src)))
			playsound(loc, 'sound/machines/vending_drop.ogg', 100, 1)
		status_message = ""
		status_error = 0
		vend_ready = 1
		currently_vending = null
		SSnano.update_uis(src)



/obj/machinery/vending/Process()
	if(stat & (BROKEN|NOPOWER))
		return

	if(!active)
		return

	if(seconds_electrified > 0)
		seconds_electrified--

	//Pitch to the people!  Really sell it!
	if(((last_slogan + slogan_delay) <= world.time) && (slogan_list.len > 0 || custom_vendor) && (!shut_up) && prob(5))
		if(custom_vendor && product_records.len)
			var/datum/data/vending_product/advertised = pick(product_records)
			if(advertised)
				var/advertisement = "[pick("Come get","Come buy","Buy","Sale on","We have")] \an [advertised.product_name], [pick("for only","only","priced at")] [advertised.price] credits![pick(" What a deal!"," Can you believe it?","")]"
				speak(advertisement)
				last_slogan = world.time
		else
			if(slogan_list.len)
				var/slogan = pick(slogan_list)
				speak(slogan)
				last_slogan = world.time

	if(shoot_inventory && prob(2))
		throw_item()

	return

/obj/machinery/vending/proc/speak(var/message)
	if(stat & NOPOWER)
		return

	if(!message)
		return

	for(var/mob/O in hearers(src, null))
		O.show_message("<span class='game say'><span class='name'>\The [src]</span> beeps, \"[message]\"</span>",2)
	return

/obj/machinery/vending/power_change()
	..()
	if(stat & BROKEN)
		icon_state = "[icon_type]-broken"
	else
		if( !(stat & NOPOWER) )
			icon_state = icon_type
		else
			spawn(rand(0, 15))
				icon_state = "[icon_type]-off"

//Oh no we're malfunctioning!  Dump out some product and break.
/obj/machinery/vending/proc/malfunction()
	for(var/datum/data/vending_product/R in product_records)
		while(R.get_amount()>0)
			R.get_product(loc)
		break

	stat |= BROKEN
	icon_state = "[icon_type]-broken"
	return

//Somebody cut an important wire and now we're following a new definition of "pitch."
/obj/machinery/vending/proc/throw_item()
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return 0
	var/obj/item/projectile/P = new /obj/item/projectile/coin(get_turf(src))
	P.shot_from = src
	playsound(src, \
		pick('sound/weapons/Gunshot.ogg','sound/weapons/guns/fire/Revolver_fire.ogg','sound/weapons/Gunshot_light.ogg',\
		'sound/weapons/guns/fire/shotgunp_fire.ogg','sound/weapons/guns/fire/ltrifle_fire.ogg','sound/weapons/guns/fire/lmg_fire.ogg',\
		'sound/weapons/guns/fire/ltrifle_fire.ogg','sound/weapons/guns/fire/batrifle_fire.ogg'),\
		60, 1)
	P.launch(target)
	visible_message(SPAN_WARNING("\The [src] launches \a [P] at \the [target]!"))
	return 1

/obj/machinery/vending/proc/set_department()
	var/list/possible_departments = list("Privately Owned" = null)
	for(var/d in GLOB.all_departments)
		possible_departments[GLOB.all_departments[d]] = department_accounts[d]
	var/newdepartment = input("Which organization should be considered the owner of this Vendomat? This will also allow members to manage it.", "Vendomat Department", null) in possible_departments
	if(!newdepartment)
		return
	if(newdepartment == "Privately Owned")
		status_message = "This Vendomat now belongs only to you."
		desc = "A custom Vendomat."
		vendor_department = null
		earnings_account = null
	else
		status_message = "This Vendomat is now property of \"[newdepartment]\"."
		desc = "A custom Vendomat. It bears the logo of [newdepartment]."
		vendor_department = newdepartment:id
		earnings_account = department_accounts[vendor_department]
		buying_percentage = 0
	status_error = 0

/*
 * Vending machine types
 */

/*

/obj/machinery/vending/[vendors name here]   // --vending machine template   :)
	name = ""
	desc = ""
	icon = ''
	icon_state = ""
	vend_delay = 15
	products = list()
	contraband = list()
	premium = list()

*/

/*
/obj/machinery/vending/atmospherics //Commenting this out until someone ponies up some actual working, broken, and unpowered sprites - Quarxink
	name = "Tank Vendor"
	desc = "A vendor with a wide variety of masks and gas tanks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	product_paths = "/obj/item/weapon/tank/oxygen;/obj/item/weapon/tank/plasma;/obj/item/weapon/tank/emergency_oxygen;/obj/item/weapon/tank/emergency_oxygen/engi;/obj/item/clothing/mask/breath"
	productamounts = "10;10;10;5;25"
	vend_delay = 0
*/

/obj/machinery/vending/boozeomat
	name = "Booze-O-Mat"
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	icon_state = "boozeomat"        //////////////18 drink entities below, plus the glasses, in case someone wants to edit the number of bottles
	icon_deny = "boozeomat-deny"
	products = list(/obj/item/weapon/reagent_containers/food/drinks/bottle/gin = 5,/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/tequilla = 5,/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth = 5,/obj/item/weapon/reagent_containers/food/drinks/bottle/rum = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/wine = 5,/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua = 5,/obj/item/weapon/reagent_containers/food/drinks/bottle/small/beer = 6,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/small/ale = 6,/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice = 4,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice = 4,/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice = 4,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/cream = 4,/obj/item/weapon/reagent_containers/food/drinks/cans/tonic = 8,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/cola = 5, /obj/item/weapon/reagent_containers/food/drinks/bottle/space_up = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/space_mountain_wind = 5, /obj/item/weapon/reagent_containers/food/drinks/cans/sodawater = 15,
					/obj/item/weapon/reagent_containers/food/drinks/flask/barflask = 2, /obj/item/weapon/reagent_containers/food/drinks/flask/vacuumflask = 2,
					/obj/item/weapon/reagent_containers/food/drinks/drinkingglass = 30,/obj/item/weapon/reagent_containers/food/drinks/ice = 9,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/melonliquor = 2,/obj/item/weapon/reagent_containers/food/drinks/bottle/bluecuracao = 2,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe = 2,/obj/item/weapon/reagent_containers/food/drinks/bottle/grenadine = 5)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/tea/green = 10, /obj/item/weapon/reagent_containers/food/drinks/tea/black = 10)
	vend_delay = 15
	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.
	product_slogans = "I hope nobody asks me for a bloody cup o' tea...;Alcohol is humanity's friend. Would you abandon a friend?;Quite delighted to serve you!;Is nobody thirsty on this station?"
	product_ads = "Drink up!;Booze is good for you!;Alcohol is humanity's best friend.;Quite delighted to serve you!;Care for a nice, cold beer?;Nothing cures you like booze!;Have a sip!;Have a drink!;Have a beer!;Beer is good for you!;Only the finest alcohol!;Best quality booze since 2053!;Award-winning wine!;Maximum alcohol!;Man loves beer.;A toast for progress!"
	auto_price = FALSE

/obj/machinery/vending/assist
	products = list(
		/obj/item/device/assembly/prox_sensor = 5,/obj/item/device/assembly/igniter = 3,
		/obj/item/device/assembly/signaler = 6,/obj/item/weapon/tool/wirecutters = 1, /obj/item/weapon/tool/wirecutters/pliers = 1
	)
	contraband = list(/obj/item/device/lighting/toggleable/flashlight = 5,/obj/item/device/assembly/timer = 2)
	product_ads = "Only the finest!;Have some tools.;The most robust equipment.;The finest gear in space!"
	auto_price = FALSE

/obj/machinery/vending/coffee
	name = "Hot Drinks machine"
	desc = "A vending machine which dispenses hot drinks."
	product_ads = "Have a drink!;Drink up!;It's good for you!;Would you like a hot joe?;I'd kill for some coffee!;The best beans in the galaxy.;Only the finest brew for you.;Mmmm. Nothing like a coffee.;I like coffee, don't you?;Coffee helps you work!;Try some tea.;We hope you like the best!;Try our new chocolate!"
	icon_state = "coffee"
	icon_vend = "coffee-vend"
	vend_delay = 34
	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.
	vend_power_usage = 85000 //85 kJ to heat a 250 mL cup of coffee
	products = list(/obj/item/weapon/reagent_containers/food/drinks/coffee = 25,/obj/item/weapon/reagent_containers/food/drinks/tea/black = 25,
					/obj/item/weapon/reagent_containers/food/drinks/tea/green = 25,/obj/item/weapon/reagent_containers/food/drinks/h_chocolate = 25)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/ice = 10)
	prices = list(/obj/item/weapon/reagent_containers/food/drinks/coffee = 3, /obj/item/weapon/reagent_containers/food/drinks/tea/black = 3,
					/obj/item/weapon/reagent_containers/food/drinks/tea/green = 3, /obj/item/weapon/reagent_containers/food/drinks/h_chocolate = 3)




/obj/machinery/vending/snack
	name = "Getmore Chocolate Corp"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation."
	product_slogans = "Try our new nougat bar!;Twice the calories for half the price!"
	product_ads = "The healthiest!;Award-winning chocolate bars!;Mmm! So good!;Oh my god it's so juicy!;Have a snack.;Snacks are good for you!;Have some more Getmore!;Best quality snacks straight from mars.;We love chocolate!;Try our new jerky!"
	icon_state = "snack"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/candy = 6,/obj/item/weapon/reagent_containers/food/drinks/dry_ramen = 6,/obj/item/weapon/reagent_containers/food/snacks/chips =6,
					/obj/item/weapon/reagent_containers/food/snacks/sosjerky = 6,/obj/item/weapon/reagent_containers/food/snacks/no_raisin = 6,/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie = 6,
					/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers = 6, /obj/item/weapon/reagent_containers/food/snacks/tastybread = 6)
	contraband = list(/obj/item/weapon/reagent_containers/food/snacks/syndicake = 6)
	prices = list(/obj/item/weapon/reagent_containers/food/snacks/candy = 40,/obj/item/weapon/reagent_containers/food/drinks/dry_ramen = 45,/obj/item/weapon/reagent_containers/food/snacks/chips = 40,
					/obj/item/weapon/reagent_containers/food/snacks/sosjerky = 45,/obj/item/weapon/reagent_containers/food/snacks/no_raisin = 40,/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie = 40,
					/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers = 40, /obj/item/weapon/reagent_containers/food/snacks/tastybread = 50,
					/obj/item/weapon/reagent_containers/food/snacks/syndicake = 60)


/obj/machinery/vending/weapon_machine
	name = "Frozen Star Guns&Ammo"
	desc = "A self-defense equipment vending machine. When you need to take care of that clown."
	product_slogans = "The best defense is good offense!;Buy for your whole family today!;Nobody can outsmart bullet!;God created man - Frozen Star made them EQUAL!;Stupidity can be cured! By LEAD.;Dead kids can't bully your children!"
	product_ads = "Stunning!;Take justice in your own hands!;LEADearship!"
	icon_state = "weapon"
	no_criminals = TRUE
	products = list(/obj/item/device/flash = 6,
					/obj/item/weapon/reagent_containers/spray/pepper = 6,
					/obj/item/weapon/gun/projectile/olivaw = 5,
					/obj/item/weapon/gun/projectile/giskard = 5,
					/obj/item/weapon/gun/energy/gun/martin = 5,
					/obj/item/weapon/gun/projectile/revolver/havelock = 5,
					/obj/item/weapon/gun/projectile/automatic/atreides = 3,
					/obj/item/weapon/gun/projectile/shotgun/pump = 3,
					/obj/item/weapon/gun/projectile/automatic/slaught_o_matic = 30,
					/obj/item/ammo_magazine/pistol/rubber = 20,
					/obj/item/ammo_magazine/hpistol/rubber = 5,
					/obj/item/ammo_magazine/slpistol/rubber = 20,
					/obj/item/ammo_magazine/smg/rubber = 15,
					/obj/item/ammo_magazine/ammobox/pistol/rubber = 20,
					/obj/item/ammo_magazine/sllrifle = 10,
					/obj/item/weapon/storage/box/shotgunammo/beanbags = 10,
					/obj/item/weapon/storage/box/shotgunammo/flashshells = 10,
					/obj/item/weapon/storage/box/shotgunammo/blanks = 10,
					/obj/item/clothing/accessory/holster = 5,
					/obj/item/clothing/accessory/holster/armpit = 5,
					/obj/item/clothing/accessory/holster/waist = 5,
					/obj/item/clothing/accessory/holster/hip = 5,
					/obj/item/ammo_magazine/slpistol = 5,
					/obj/item/ammo_magazine/pistol = 5,
					/obj/item/ammo_magazine/hpistol = 5,
					/obj/item/ammo_magazine/smg = 3,
					/obj/item/ammo_magazine/ammobox/pistol = 5,
					/obj/item/weapon/storage/box/shotgunammo/slug = 3,
					/obj/item/weapon/storage/box/shotgunammo/buckshot = 3,
					/obj/item/weapon/tool/knife/tacknife = 5,
					/obj/item/weapon/storage/box/smokes = 3)

	prices = list(
					/obj/item/ammo_magazine/ammobox/pistol/rubber = 200,
					/obj/item/ammo_magazine/slpistol/rubber = 100,
					/obj/item/ammo_magazine/pistol/rubber = 150,
					/obj/item/ammo_magazine/hpistol = 300,
					/obj/item/ammo_magazine/hpistol/rubber = 200,
					/obj/item/weapon/storage/box/shotgunammo/beanbags = 300,
					/obj/item/weapon/storage/box/shotgunammo/flashshells = 300,
					/obj/item/weapon/storage/box/shotgunammo/blanks = 50,
					/obj/item/ammo_magazine/sllrifle = 300,
					/obj/item/ammo_magazine/slpistol = 100,
					/obj/item/ammo_magazine/smg/rubber = 200,
					/obj/item/ammo_magazine/smg = 400,
					/obj/item/ammo_magazine/ammobox/pistol = 500,
					/obj/item/weapon/storage/box/shotgunammo/slug = 600,
					/obj/item/weapon/storage/box/shotgunammo/buckshot = 600,
					/obj/item/weapon/tool/knife/tacknife = 300,
					/obj/item/weapon/storage/box/smokes = 200,
					/obj/item/ammo_magazine/pistol = 300,)

//This one's from bay12
/obj/machinery/vending/cart
	name = "PTech"
	desc = "PDAs and hardware."
	product_slogans = "PDAs for everyone!"
	icon_state = "cart"
	icon_deny = "cart-deny"
	products = list(/obj/item/modular_computer/pda = 10,/obj/item/weapon/computer_hardware/scanner/medical = 6,
					/obj/item/weapon/computer_hardware/scanner/reagent = 6,/obj/item/weapon/computer_hardware/scanner/atmos = 6,
					/obj/item/weapon/computer_hardware/scanner/paper = 10,/obj/item/weapon/computer_hardware/printer = 10,
					/obj/item/weapon/computer_hardware/card_slot = 3,/obj/item/weapon/computer_hardware/ai_slot = 4)
	auto_price = FALSE


/obj/machinery/vending/cola
	name = "Robust Softdrinks"
	desc = "A softdrink vendor provided by Robust Industries, LLC."
	icon_state = "Cola_Machine"
	product_slogans = "Robust Softdrinks: More robust than a toolbox to the head!"
	product_ads = "Refreshing!;Hope you're thirsty!;Over 1 million drinks sold!;Thirsty? Why not have some cola?;Please, have a drink!;Drink up!;The best drinks in space."
	products = list(/obj/item/weapon/reagent_containers/food/drinks/cans/cola = 10,/obj/item/weapon/reagent_containers/food/drinks/cans/space_mountain_wind = 10,
					/obj/item/weapon/reagent_containers/food/drinks/cans/dr_gibb = 10,/obj/item/weapon/reagent_containers/food/drinks/cans/starkist = 10,
					/obj/item/weapon/reagent_containers/food/drinks/cans/waterbottle = 10,/obj/item/weapon/reagent_containers/food/drinks/cans/space_up = 10,
					/obj/item/weapon/reagent_containers/food/drinks/cans/iced_tea = 10, /obj/item/weapon/reagent_containers/food/drinks/cans/grape_juice = 10)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/cans/thirteenloko = 5, /obj/item/weapon/reagent_containers/food/snacks/liquidfood = 6)
	prices = list(/obj/item/weapon/reagent_containers/food/drinks/cans/cola = 30,/obj/item/weapon/reagent_containers/food/drinks/cans/space_mountain_wind = 30,
					/obj/item/weapon/reagent_containers/food/drinks/cans/dr_gibb = 1000,/obj/item/weapon/reagent_containers/food/drinks/cans/starkist = 30,
					/obj/item/weapon/reagent_containers/food/drinks/cans/waterbottle = 32,/obj/item/weapon/reagent_containers/food/drinks/cans/space_up = 30,
					/obj/item/weapon/reagent_containers/food/drinks/cans/iced_tea = 30,/obj/item/weapon/reagent_containers/food/drinks/cans/grape_juice = 30,
					/obj/item/weapon/reagent_containers/food/drinks/cans/thirteenloko = 50, /obj/item/weapon/reagent_containers/food/snacks/liquidfood = 60)
	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.

/obj/machinery/vending/cigarette
	name = "Cigarette machine" //OCD had to be uppercase to look nice with the new formating
	desc = "If you want to get cancer, might as well do it in style!"
	product_slogans = "Space cigs taste good like a cigarette should.;I'd rather toolbox than switch.;Smoke!;Don't believe the reports - smoke today!"
	product_ads = "Probably not bad for you!;Don't believe the scientists!;It's good for you!;Don't quit, buy more!;Smoke!;Nicotine heaven.;Best cigarettes since 2150.;Award-winning cigs."
	vend_delay = 34
	icon_state = "cigs"
	products = list(/obj/item/weapon/storage/fancy/cigarettes = 10,
					/obj/item/weapon/storage/fancy/cigcartons = 5,
					/obj/item/clothing/mask/smokable/cigarette/cigar = 4,
					/obj/item/weapon/flame/lighter/zippo = 4,
					/obj/item/weapon/storage/box/matches = 10,
					/obj/item/weapon/flame/lighter/random = 4,
					/obj/item/weapon/storage/fancy/cigar = 5,
					/obj/item/weapon/storage/fancy/cigarettes/killthroat = 5,
					/obj/item/clothing/mask/vape = 5,
					/obj/item/weapon/reagent_containers/glass/beaker/vial/vape/berry = 10,
					/obj/item/weapon/reagent_containers/glass/beaker/vial/vape/banana = 10,
					/obj/item/weapon/reagent_containers/glass/beaker/vial/vape/lemon = 10,
					/obj/item/weapon/reagent_containers/glass/beaker/vial/vape/nicotine = 5
				   )

	prices = list(/obj/item/clothing/mask/smokable/cigarette/cigar = 200,
				  /obj/item/weapon/storage/fancy/cigarettes = 100,
				  /obj/item/weapon/storage/fancy/cigcartons = 800,
				  /obj/item/weapon/storage/box/matches = 10,
				  /obj/item/weapon/flame/lighter/random = 5,
				  /obj/item/weapon/storage/fancy/cigar = 450,
				  /obj/item/weapon/storage/fancy/cigarettes/killthroat = 100,
				  /obj/item/weapon/flame/lighter/zippo = 250,
				  /obj/item/clothing/mask/vape = 300,
				  /obj/item/weapon/reagent_containers/glass/beaker/vial/vape/berry = 100,
				  /obj/item/weapon/reagent_containers/glass/beaker/vial/vape/banana = 100,
				  /obj/item/weapon/reagent_containers/glass/beaker/vial/vape/lemon = 100,
				  /obj/item/weapon/reagent_containers/glass/beaker/vial/vape/nicotine = 100
				  )


/obj/machinery/vending/medical
	name = "MiniPharma Plus"
	desc = "Medical drug dispenser."
	icon_state = "med"
	icon_deny = "med-deny"
	req_access = list(access_medical_equip)
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	products = list(/obj/item/weapon/reagent_containers/glass/bottle/antitoxin = 8,/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline = 8,
					/obj/item/weapon/reagent_containers/glass/bottle/stoxin = 4,/obj/item/weapon/reagent_containers/glass/bottle/toxin = 4,
					/obj/item/weapon/reagent_containers/syringe/spaceacillin = 8,/obj/item/weapon/reagent_containers/syringe = 12,
					/obj/item/device/scanner/health = 5,/obj/item/weapon/reagent_containers/glass/beaker = 4, /obj/item/weapon/reagent_containers/dropper = 2,
					/obj/item/stack/medical/advanced/bruise_pack = 3, /obj/item/stack/medical/advanced/ointment = 3, /obj/item/stack/medical/splint = 6, /obj/item/bodybag/cryobag = 2)
	contraband = list(/obj/item/weapon/reagent_containers/pill/tox = 3,/obj/item/weapon/reagent_containers/pill/stox = 4,/obj/item/weapon/reagent_containers/pill/antitox = 6)
	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.
	auto_price = FALSE


//This one's from bay12
/obj/machinery/vending/plasmaresearch
	name = "Toximate 3000"
	desc = "All the fine parts you need in one vending machine!"
	products = list(/obj/item/clothing/under/rank/scientist = 6,/obj/item/clothing/suit/bio_suit = 6,/obj/item/clothing/head/bio_hood = 6,
					/obj/item/device/transfer_valve = 6,/obj/item/device/assembly/timer = 6,/obj/item/device/assembly/signaler = 6,
					/obj/item/device/assembly/prox_sensor = 6,/obj/item/device/assembly/igniter = 6)
	auto_price = FALSE

/obj/machinery/vending/wallmed
	name = "MicroMed"
	desc = "Wall-mounted medical dispenser."
	density = FALSE //It is wall-mounted, and thus, not dense. --Superxpdude
	icon_state = "wallmed"
	light_color = COLOR_LIGHTING_GREEN_BRIGHT
	icon_deny = "wallmed-deny"
	product_ads = "Self-medication can be healthy!;Natural chemicals!;This stuff saves lives.;Don't you want some?;Hook it up to your veins!"

/obj/machinery/vending/wallmed/minor
	products = list(
		/obj/item/stack/medical/bruise_pack = 2, /obj/item/stack/medical/ointment = 2,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector = 4,
		/obj/item/device/scanner/health = 1,
		/obj/item/stack/medical/splint = 6
		)
	contraband = list(
		/obj/item/weapon/reagent_containers/syringe/antitoxin = 2,
		/obj/item/weapon/reagent_containers/syringe/spaceacillin = 2,
		/obj/item/weapon/reagent_containers/pill/tox = 1
		)
	prices = list(
		/obj/item/device/scanner/health = 50,

		/obj/item/stack/medical/bruise_pack = 100, /obj/item/stack/medical/ointment = 100,
		/obj/item/device/scanner/health = 50,

		/obj/item/weapon/reagent_containers/hypospray/autoinjector = 100,

		/obj/item/stack/medical/splint = 200,

		/obj/item/weapon/reagent_containers/syringe/antitoxin = 200,
		/obj/item/weapon/reagent_containers/syringe/spaceacillin = 200,
		/obj/item/weapon/reagent_containers/pill/tox = 100
		)
	auto_price = FALSE

/obj/machinery/vending/wallmed/lobby
	products = list(
		/obj/item/device/scanner/health = 6,

		/obj/item/stack/medical/bruise_pack = 2, /obj/item/stack/medical/ointment = 2,
		/obj/item/stack/medical/advanced/bruise_pack = 1, /obj/item/stack/medical/advanced/ointment = 1,
		/obj/item/stack/nanopaste = 1,

		/obj/item/weapon/reagent_containers/hypospray/autoinjector/antitoxin = 5, /obj/item/weapon/reagent_containers/syringe/antitoxin = 5,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/tricordrazine = 5, /obj/item/weapon/reagent_containers/syringe/tricordrazine = 5,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/spaceacillin = 1, /obj/item/weapon/reagent_containers/syringe/spaceacillin = 1,

		/obj/item/weapon/implantcase/death_alarm = 2,
		/obj/item/weapon/implanter = 2,
		/obj/item/stack/medical/splint = 6
		)
	contraband = list(
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/hyperzine = 2,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/drugs = 2,
		)
	prices = list(
		/obj/item/device/scanner/health = 50,

		/obj/item/stack/medical/bruise_pack = 100, /obj/item/stack/medical/ointment = 100,
		/obj/item/stack/medical/advanced/bruise_pack = 200, /obj/item/stack/medical/advanced/ointment = 200,
		/obj/item/stack/nanopaste = 1000,
		/obj/item/stack/medical/splint = 200,

		/obj/item/weapon/reagent_containers/hypospray/autoinjector/antitoxin = 100, /obj/item/weapon/reagent_containers/syringe/antitoxin = 200,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/tricordrazine = 150, /obj/item/weapon/reagent_containers/syringe/tricordrazine = 300,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/spaceacillin = 100, /obj/item/weapon/reagent_containers/syringe/spaceacillin = 200,

		/obj/item/weapon/implantcase/death_alarm = 500,
		/obj/item/weapon/implanter = 50,

		/obj/item/weapon/reagent_containers/hypospray/autoinjector/hyperzine = 500,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/drugs = 500,
		)
	vendor_department = DEPARTMENT_MEDICAL
	auto_price = FALSE

/obj/machinery/vending/security
	name = "SecTech"
	desc = "A security equipment vendor."
	product_ads = "Crack some skulls!;Beat some heads in!;Don't forget - harm is good!;Your weapons are right here.;Handcuffs!;Freeze, scumbag!;Don't tase me bro!;Tase them, bro.;Why not have a donut?"
	icon_state = "sec"
	icon_deny = "sec-deny"
	req_access = list(access_security)
	products = list(/obj/item/weapon/handcuffs = 8,
					/obj/item/weapon/handcuffs/zipties = 8,
					/obj/item/weapon/grenade/flashbang = 8,
					/obj/item/weapon/grenade/chem_grenade/teargas = 8,
					/obj/item/weapon/grenade/smokebomb = 8,
					/obj/item/device/flash = 8,
					/obj/item/weapon/reagent_containers/spray/pepper = 8,
					/obj/item/ammo_magazine/ihclrifle/rubber = 8,
					/obj/item/ammo_magazine/pistol/rubber = 8,
					/obj/item/ammo_magazine/smg/rubber = 4,
					/obj/item/ammo_magazine/slmagnum/rubber = 4,
					/obj/item/ammo_magazine/magnum/rubber = 4,
					/obj/item/weapon/storage/box/shotgunammo/beanbags = 2,
					/obj/item/ammo_magazine/ammobox/pistol/rubber = 4,
					/obj/item/ammo_magazine/ammobox/magnum/rubber = 4,
					/obj/item/ammo_magazine/ammobox/clrifle_small/rubber = 4,
					/obj/item/device/hailer = 8,
					/obj/item/taperoll/police = 8,
					/obj/item/device/holowarrant = 8,
					/obj/item/weapon/storage/box/evidence = 2,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/security = 2,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/armor/ih = 2,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/armor/ih/bulletproof = 1)
	contraband = list(/obj/item/weapon/tool/knife/tacknife = 4,/obj/item/weapon/reagent_containers/food/snacks/donut/normal = 12)
	auto_price = FALSE

/obj/machinery/vending/hydronutrients
	name = "NutriMax"
	desc = "A plant nutrients vendor."
	product_slogans = "Aren't you glad you don't have to fertilize the natural way?;Now with 50% less stink!;Plants are people too!"
	product_ads = "We like plants!;Don't you want some?;The greenest thumbs ever.;We like big plants.;Soft soil..."
	icon_state = "nutri"
	products = list(/obj/item/weapon/reagent_containers/glass/fertilizer/ez = 6,/obj/item/weapon/reagent_containers/glass/fertilizer/l4z = 4,/obj/item/weapon/reagent_containers/glass/fertilizer/rh = 4,/obj/item/weapon/plantspray/pests = 20,
					/obj/item/weapon/reagent_containers/syringe = 5,/obj/item/weapon/storage/bag/produce = 5)
	premium = list(/obj/item/weapon/reagent_containers/glass/bottle/ammonia = 10,/obj/item/weapon/reagent_containers/glass/bottle/diethylamine = 5)
	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.
	auto_price = FALSE

/obj/machinery/vending/hydroseeds
	name = "MegaSeed Servitor"
	desc = "When you need seeds fast!"
	product_slogans = "THIS'S WHERE TH' SEEDS LIVE! GIT YOU SOME!;Hands down the best seed selection on the station!;Also certain mushroom varieties available, more for experts! Get certified today!"
	product_ads = "We like plants!;Grow some crops!;Grow, baby, growww!;Aw h'yeah son!"
	icon_state = "seeds"
	always_open = TRUE
	can_stock = list(/obj/item/seeds)

	products = list(/obj/item/seeds/bananaseed = 3,/obj/item/seeds/berryseed = 3,/obj/item/seeds/carrotseed = 3,/obj/item/seeds/chantermycelium = 3,/obj/item/seeds/chiliseed = 3,
					/obj/item/seeds/cornseed = 3, /obj/item/seeds/eggplantseed = 3, /obj/item/seeds/potatoseed = 3, /obj/item/seeds/soyaseed = 3,
					/obj/item/seeds/sunflowerseed = 3,/obj/item/seeds/tomatoseed = 3,/obj/item/seeds/towermycelium = 3,/obj/item/seeds/wheatseed = 3,/obj/item/seeds/appleseed = 3,
					/obj/item/seeds/poppyseed = 3,/obj/item/seeds/sugarcaneseed = 3,/obj/item/seeds/ambrosiavulgarisseed = 3,/obj/item/seeds/peanutseed = 3,/obj/item/seeds/whitebeetseed = 3,/obj/item/seeds/watermelonseed = 3,/obj/item/seeds/limeseed = 3,
					/obj/item/seeds/lemonseed = 3,/obj/item/seeds/orangeseed = 3,/obj/item/seeds/grassseed = 3,/obj/item/seeds/cocoapodseed = 3,/obj/item/seeds/plumpmycelium = 2,
					/obj/item/seeds/cabbageseed = 3,/obj/item/seeds/grapeseed = 3,/obj/item/seeds/pumpkinseed = 3,/obj/item/seeds/cherryseed = 3,/obj/item/seeds/plastiseed = 3,/obj/item/seeds/riceseed = 3, /obj/item/seeds/tobaccoseed = 3)
	contraband = list(/obj/item/seeds/amanitamycelium = 2,/obj/item/seeds/glowshroom = 2,/obj/item/seeds/libertymycelium = 2,/obj/item/seeds/mtearseed = 2,
					  /obj/item/seeds/nettleseed = 2,/obj/item/seeds/reishimycelium = 2,/obj/item/seeds/reishimycelium = 2,/obj/item/seeds/shandseed = 2,)
	premium = list(/obj/item/toy/waterflower = 1)
	auto_price = FALSE

/**
 *  Populate hydroseeds product_records
 *
 *  This needs to be customized to fetch the actual names of the seeds, otherwise
 *  the machine would simply list "packet of seeds" times 20
 */
/obj/machinery/vending/hydroseeds/build_inventory()
	var/list/all_products = list(
		list(products, CAT_NORMAL),
		list(contraband, CAT_HIDDEN),
		list(premium, CAT_COIN))

	for(var/current_list in all_products)
		var/category = current_list[2]

		for(var/entry in current_list[1])
			var/obj/item/seeds/S = new entry(src)
			var/name = S.name
			var/datum/data/vending_product/product = new/datum/data/vending_product(src, entry, name)

			product.price = (entry in prices) ? prices[entry] : product.price
			product.amount = (current_list[1][entry]) ? current_list[1][entry] : 1
			product.category = category

			product_records.Add(product)
			qdel(S)


/obj/machinery/vending/dinnerware
	name = "Dinnerware"
	desc = "A kitchen and restaurant equipment vendor."
	product_ads = "Mm, food stuffs!;Food and food accessories.;Get your plates!;You like forks?;I like forks.;Woo, utensils.;You don't really need these..."
	icon_state = "dinnerware"
	products = list(/obj/item/weapon/tray = 8,/obj/item/weapon/material/kitchen/utensil/fork = 6, /obj/item/weapon/tool/knife = 6, /obj/item/weapon/material/kitchen/utensil/spoon = 6, /obj/item/weapon/tool/knife = 3,/obj/item/weapon/reagent_containers/food/drinks/drinkingglass = 8,/obj/item/clothing/suit/chef/classic = 2,/obj/item/weapon/storage/lunchbox = 3,/obj/item/weapon/storage/lunchbox/rainbow = 3,/obj/item/weapon/storage/lunchbox/cat = 3,
					/obj/item/weapon/reagent_containers/food/drinks/pitcher = 3,/obj/item/weapon/reagent_containers/food/drinks/teapot = 3,/obj/item/weapon/reagent_containers/food/drinks/mug = 3,/obj/item/weapon/reagent_containers/food/drinks/mug/black = 3,/obj/item/weapon/reagent_containers/food/drinks/mug/green = 3,/obj/item/weapon/reagent_containers/food/drinks/mug/blue = 3,
					/obj/item/weapon/reagent_containers/food/drinks/mug/red = 3,/obj/item/weapon/reagent_containers/food/drinks/mug/heart = 3,/obj/item/weapon/reagent_containers/food/drinks/mug/one = 3,/obj/item/weapon/reagent_containers/food/drinks/mug/metal = 3,
					/obj/item/weapon/reagent_containers/food/drinks/mug/rainbow = 3,/obj/item/weapon/reagent_containers/food/drinks/mug/brit = 3,/obj/item/weapon/reagent_containers/food/drinks/mug/moebius = 3,/obj/item/weapon/reagent_containers/food/drinks/mug/teacup = 10,)
	contraband = list(/obj/item/weapon/material/kitchen/rollingpin = 2, /obj/item/weapon/tool/knife/butch = 2)
	auto_price = FALSE

/obj/machinery/vending/sovietsoda
	name = "BODA"
	desc = "An old sweet water vending machine,how did this end up here?"
	icon_state = "sovietsoda"
	product_ads = "For Tsar and Country.;Have you fulfilled your nutrition quota today?;Very nice!;We are simple people, for this is all we eat.;If there is a person, there is a problem. If there is no person, then there is no problem."
	products = list(/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/soda = 30)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/cola = 20)
	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.
	auto_price = FALSE

/obj/machinery/vending/tool
	name = "YouTool"
	desc = "Tools for tools."
	icon_state = "tool"
	icon_deny = "tool-deny"
	products = list(/obj/item/stack/cable_coil/random = 10,/obj/item/weapon/tool/crowbar = 5,/obj/item/weapon/tool/weldingtool = 5,/obj/item/weapon/tool/wirecutters = 3, /obj/item/weapon/tool/wirecutters/pliers = 3,
					/obj/item/weapon/tool/wrench = 5,/obj/item/weapon/tool/hammer = 5,/obj/item/device/scanner/gas = 5,/obj/item/device/t_scanner = 5, /obj/item/weapon/tool/screwdriver = 5, /obj/item/clothing/gloves/insulated/cheap  = 2, /obj/item/clothing/gloves/insulated = 1,
					/obj/item/weapon/storage/pouch/engineering_tools = 2, /obj/item/weapon/storage/pouch/engineering_supply = 2)
	prices = list(/obj/item/weapon/tool/hammer = 30,/obj/item/stack/cable_coil/random = 100,/obj/item/weapon/tool/crowbar = 30,/obj/item/weapon/tool/weldingtool = 50,/obj/item/weapon/tool/wirecutters = 30, /obj/item/weapon/tool/wirecutters/pliers = 30,
					/obj/item/weapon/tool/wrench = 30,/obj/item/device/scanner/gas = 50,/obj/item/device/t_scanner = 50, /obj/item/weapon/tool/screwdriver = 30, /obj/item/clothing/gloves/insulated/cheap  = 80, /obj/item/clothing/gloves/insulated = 600,
					/obj/item/weapon/storage/pouch/engineering_tools = 300, /obj/item/weapon/storage/pouch/engineering_supply = 600)

/obj/machinery/vending/engivend
	name = "Engi-Vend"
	desc = "Spare tool vending. What? Did you expect some witty description?"
	icon_state = "engivend"
	icon_deny = "engivend-deny"
	products = list(/obj/item/clothing/glasses/powered/meson = 2,/obj/item/weapon/tool/multitool = 4,/obj/item/weapon/electronics/airlock = 10,/obj/item/weapon/electronics/circuitboard/apc = 10,/obj/item/weapon/electronics/airalarm = 10,/obj/item/weapon/cell/large/high = 10,/obj/item/weapon/rpd = 3)
	contraband = list(/obj/item/weapon/cell/large/potato = 3)
	premium = list(/obj/item/weapon/storage/belt/utility = 3)
	auto_price = FALSE

//This one's from bay12
/obj/machinery/vending/engineering
	name = "Robco Tool Maker"
	desc = "Everything you need for do-it-yourself station repair."
	icon_state = "engi"
	icon_deny = "engi-deny"
	products = list(/obj/item/clothing/head/hardhat = 4,
					/obj/item/weapon/storage/belt/utility = 4,/obj/item/clothing/glasses/powered/meson = 4,/obj/item/clothing/gloves/insulated = 4, /obj/item/weapon/tool/screwdriver = 12,
					/obj/item/weapon/tool/crowbar = 12,/obj/item/weapon/tool/wirecutters = 6, /obj/item/weapon/tool/wirecutters/pliers = 6, /obj/item/weapon/tool/multitool = 12,/obj/item/weapon/tool/wrench = 12,/obj/item/weapon/tool/hammer = 10,/obj/item/device/t_scanner = 12,
					/obj/item/weapon/cell/large = 8, /obj/item/weapon/tool/weldingtool = 8,/obj/item/clothing/head/welding = 8,
					/obj/item/weapon/light/tube = 10,/obj/item/clothing/suit/fire = 4, /obj/item/weapon/stock_parts/scanning_module = 5,/obj/item/weapon/stock_parts/micro_laser = 5,
					/obj/item/weapon/stock_parts/matter_bin = 5,/obj/item/weapon/stock_parts/manipulator = 5,/obj/item/weapon/stock_parts/console_screen = 5)
	prices = list(/obj/item/clothing/head/hardhat = 4,/obj/item/weapon/tool/hammer = 30,
					/obj/item/weapon/storage/belt/utility = 150,/obj/item/clothing/glasses/powered/meson = 300,/obj/item/clothing/gloves/insulated = 600, /obj/item/weapon/tool/screwdriver = 30,
					/obj/item/weapon/tool/crowbar = 30,/obj/item/weapon/tool/wirecutters = 30,/obj/item/weapon/tool/wirecutters/pliers = 30,/obj/item/weapon/tool/multitool = 40,/obj/item/weapon/tool/wrench = 40,/obj/item/device/t_scanner = 50,
					/obj/item/weapon/cell/large = 500, /obj/item/weapon/tool/weldingtool = 40,/obj/item/clothing/head/welding = 80,
					/obj/item/weapon/light/tube = 10,/obj/item/clothing/suit/fire = 150, /obj/item/weapon/stock_parts/scanning_module = 40,/obj/item/weapon/stock_parts/micro_laser = 40,
					/obj/item/weapon/stock_parts/matter_bin = 40,/obj/item/weapon/stock_parts/manipulator = 40,/obj/item/weapon/stock_parts/console_screen = 40)

//This one's from bay12
/obj/machinery/vending/robotics
	name = "Robotech Deluxe"
	desc = "All the tools you need to create your own robot army."
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	products = list(/obj/item/clothing/suit/storage/toggle/labcoat = 4,/obj/item/clothing/under/rank/roboticist = 4,/obj/item/stack/cable_coil = 4,/obj/item/device/flash = 4,
					/obj/item/weapon/cell/large/high = 12, /obj/item/device/assembly/prox_sensor = 3,/obj/item/device/assembly/signaler = 3,/obj/item/device/scanner/health = 3,
					/obj/item/weapon/tool/scalpel = 2,/obj/item/weapon/tool/saw/circular = 2,/obj/item/weapon/tank/anesthetic = 2,/obj/item/clothing/mask/breath/medical = 5,
					/obj/item/weapon/tool/screwdriver = 5,/obj/item/weapon/tool/crowbar = 5)
	auto_price = FALSE

//FOR ACTORS GUILD - mainly props that cannot be spawned otherwise
/obj/machinery/vending/props
	name = "prop dispenser"
	desc = "All the props an actor could need. Probably."
	icon_state = "Theater"
	products = list(/obj/structure/flora/pottedplant = 2, /obj/item/device/lighting/toggleable/lamp = 2, /obj/item/device/lighting/toggleable/lamp/green = 2, /obj/item/weapon/reagent_containers/food/drinks/jar = 1,
					/obj/item/toy/cultsword = 4, /obj/item/toy/katana = 2, /obj/item/weapon/phone = 3, /obj/item/clothing/head/centhat = 3, /obj/item/clothing/head/richard = 1)
	auto_price = FALSE

//FOR ACTORS GUILD - Containers
/obj/machinery/vending/containers
	name = "container dispenser"
	desc = "A container that dispenses containers."
	icon_state = "robotics"
	products = list(/obj/structure/closet/crate/freezer = 2, /obj/structure/closet = 3, /obj/structure/closet/crate = 3)
	auto_price = FALSE

/obj/machinery/vending/theomat
	name = "NeoTheology Theo-Mat"
	desc = "A NeoTheology dispensary for disciples and new converts."
	product_slogans = "Immortality is the reward of the faithful.; Help humanity ascend, join your brethren today!; Come and seek a new life!"
	product_ads = "Praise!;Pray!;Obey!"
	icon_state = "teomat"
	vendor_department = DEPARTMENT_CHURCH
	products = list(/obj/item/weapon/book/ritual/cruciform = 10, /obj/item/weapon/storage/fancy/candle_box = 10, /obj/item/weapon/reagent_containers/food/drinks/bottle/ntcahors = 20)
	contraband = list(/obj/item/weapon/implant/core_implant/cruciform = 3)
	prices = list(/obj/item/weapon/book/ritual/cruciform = 500, /obj/item/weapon/storage/fancy/candle_box = 200, /obj/item/weapon/reagent_containers/food/drinks/bottle/ntcahors = 250,
				/obj/item/weapon/implant/core_implant/cruciform = 1000)

/obj/machinery/vending/powermat
	name = "Asters Guild Power-Mat"
	desc = "Trust is power, and there's no power you can trust like Robustcell."
	product_slogans = "Trust is power, and there's no cell you can trust like Robustcell.;No battery is stronger nor lasts longer.;One that Lasts!;You can't top the copper top!"
	product_ads = "Robust!;Trustworthy!;Durable!"
	icon_state = "powermat"
	products = list(/obj/item/weapon/cell/large = 10, /obj/item/weapon/cell/large/high = 10, /obj/item/weapon/cell/medium = 15, /obj/item/weapon/cell/medium/high = 15, /obj/item/weapon/cell/small = 20, /obj/item/weapon/cell/small/high = 20)
	contraband = list(/obj/item/weapon/cell/large/super = 5, /obj/item/weapon/cell/medium/super = 5, /obj/item/weapon/cell/small/super = 5)
	prices = list(/obj/item/weapon/cell/large = 500, /obj/item/weapon/cell/large/high = 700, /obj/item/weapon/cell/medium = 300, /obj/item/weapon/cell/medium/high = 400, /obj/item/weapon/cell/small = 100, /obj/item/weapon/cell/small/high = 200,
				/obj/item/weapon/cell/large/super = 1200, /obj/item/weapon/cell/medium/super = 700, /obj/item/weapon/cell/small/super = 350)

/obj/machinery/vending/printomat
	name = "Asters Guild Print-o-Mat"
	desc = "Everything you can imagine (not really) on a disc! Print your own gun TODAY."
	product_slogans = "Print your own gun TODAY!;The future is NOW!;Can't stop the industrial revolution!"
	product_ads = "Almost free!;Print it yourself!;Don't copy that floppy!"
	icon_state = "discomat"
	products = list(
					/obj/item/weapon/computer_hardware/hard_drive/portable = 20,
					/obj/item/weapon/storage/box/data_disk/basic = 5,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/misc = 10,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/devices = 10,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/tools = 10,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/components = 10,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/adv_tools = 5,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/circuits = 5,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/conveyors = 2,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/computer = 10,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/medical = 10,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/security = 5,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/armor/generic = 5,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/guns/fs_cheap_guns = 5,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/guns/fs_slaught_o_matic = 5,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/nonlethal_ammo = 10,
					/obj/item/weapon/electronics/circuitboard/autolathe = 3,
					/obj/item/weapon/electronics/circuitboard/vending = 10)
	contraband = list(/obj/item/weapon/computer_hardware/hard_drive/portable/design/lethal_ammo = 3, /obj/item/weapon/electronics/circuitboard/autolathe_disk_cloner = 3)
	prices = list(/obj/item/weapon/computer_hardware/hard_drive/portable = 50,
					/obj/item/weapon/storage/box/data_disk/basic = 100,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/misc = 300,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/devices = 400,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/tools = 400,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/components = 500,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/adv_tools = 1800,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/circuits = 600,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/conveyors = 400,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/medical = 400,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/computer = 500,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/security = 600,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/armor/generic = 800,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/guns/fs_cheap_guns = 3000,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/guns/fs_slaught_o_matic = 600,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/nonlethal_ammo = 700,
					/obj/item/weapon/electronics/circuitboard/autolathe = 700,
					/obj/item/weapon/electronics/circuitboard/autolathe_disk_cloner = 1000,
					/obj/item/weapon/electronics/circuitboard/vending = 500,
					/obj/item/weapon/computer_hardware/hard_drive/portable/design/lethal_ammo = 1200,)

/obj/machinery/vending/serbomat
	name = "From Serbia with love"
	desc = "How did this end up here?"
	icon_state = "serbomat"
	product_ads = "For Tsar and Country.;Have you fulfilled your nutrition quota today?;Very nice!;We are simple people, for this is all we eat.;If there is a person, there is a problem. If there is no person, then there is no problem.;Our ERPs are definitely free of food additives and totally not laced to the brim with harmful chems. Try it out!."
	products = list(
					/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka = 60, // ghetto antihacking, have fun
					/obj/item/weapon/storage/deferred/crate/uniform_green = 4,
					/obj/item/weapon/storage/deferred/crate/uniform_brown = 4,
					/obj/item/weapon/storage/deferred/crate/uniform_black = 4,
					/obj/item/weapon/storage/deferred/crate/uniform_flak  = 2,
					/obj/item/weapon/storage/deferred/crate/uniform_light = 2,
					/obj/item/weapon/gun/projectile/kovacs = 2,
					/obj/item/ammo_magazine/srifle = 6,
					/obj/item/weapon/gun/projectile/boltgun/serbian = 10,
					/obj/item/ammo_magazine/ammobox/lrifle_small = 30,
					/obj/item/weapon/storage/ration_pack = 10,
					/obj/item/clothing/mask/balaclava = 50
					)
	prices = list(
					/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka = 50,
          			/obj/item/weapon/storage/deferred/crate/uniform_green = 2000,
          			/obj/item/weapon/storage/deferred/crate/uniform_brown = 2000,
					/obj/item/weapon/storage/deferred/crate/uniform_black = 2000,
					/obj/item/weapon/storage/deferred/crate/uniform_flak  = 2200,
					/obj/item/weapon/storage/deferred/crate/uniform_light = 1800,
					/obj/item/weapon/gun/projectile/kovacs = 3000,
					/obj/item/ammo_magazine/ammobox/lrifle_small = 400,
					/obj/item/ammo_magazine/srifle = 200,
					/obj/item/weapon/storage/ration_pack = 800,
					/obj/item/clothing/mask/balaclava = 100
					)
	idle_power_usage = 211
	vendor_department = DEPARTMENT_CIVILIAN

/obj/machinery/vending/billomat
	name = "Bill Trustworthy's Discount Guns and Enterprising Detritus"
	desc = "Some relic of an arms dealer's business, its owner most likely long dead."
	product_slogans = "Discount guns for discount prices!;Also see our used ship line!;From the home of Challenge Pissing!"
	product_ads = "Brought to you by the man behind Bill Trustworthy's Used Ships!;Don't wait! Don't delay! Don't fuck with us!;No refunds before you die.;Coolness sold seperately."
	icon_state = "trashvend"
	products = list(
					/obj/item/ammo_magazine/lrifle = 12,
					/obj/item/ammo_magazine/hpistol = 12,
					/obj/item/ammo_magazine/srifle = 12,
					/obj/item/ammo_magazine/smg = 12,
					/obj/item/part/armor = 20,
					/obj/item/part/gun = 20,
					/obj/item/weapon/gun/projectile/automatic/ak47/fs = 4,
					/obj/item/weapon/gun/energy/retro = 4,
					/obj/item/weapon/gun/projectile/mk58  = 2,
					/obj/item/weapon/gun/projectile/mk58/wood = 2,
					/obj/item/weapon/gun/projectile/revolver/deckard = 2,
					/obj/item/weapon/gun/projectile/automatic/z8 = 4,
					/obj/item/weapon/gun/projectile/automatic/molly = 4,
					/obj/item/weapon/gun/projectile/shotgun/pump/gladstone = 4,
					/obj/item/weapon/storage/deferred/crate/clown_crime = 2,
					/obj/item/weapon/storage/deferred/crate/clown_crime/wolf = 2,
					/obj/item/weapon/storage/deferred/crate/clown_crime/hoxton = 2,
					/obj/item/weapon/storage/deferred/crate/clown_crime/chains = 2
					)
	contraband = list(/obj/item/weapon/gun/projectile/mandella = 4,/obj/item/ammo_magazine/cspistol = 12)
	prices = list(
					/obj/item/ammo_magazine/lrifle = 400,
					/obj/item/ammo_magazine/hpistol = 300,
					/obj/item/ammo_magazine/cspistol = 400,
					/obj/item/ammo_magazine/srifle = 300,
					/obj/item/ammo_magazine/smg = 400,
					/obj/item/part/armor = 700,
					/obj/item/part/gun = 700,
					/obj/item/weapon/gun/projectile/automatic/ak47/fs = 3200,
					/obj/item/weapon/gun/energy/retro = 2000,
					/obj/item/weapon/gun/projectile/mk58  = 1500,
					/obj/item/weapon/gun/projectile/mk58/wood = 1500,
					/obj/item/weapon/gun/projectile/mandella = 1800,
					/obj/item/weapon/gun/projectile/revolver/deckard = 3600,
					/obj/item/weapon/gun/projectile/automatic/z8 = 3500,
					/obj/item/weapon/gun/projectile/automatic/molly = 2000,
					/obj/item/weapon/gun/projectile/shotgun/pump/gladstone = 2200,
					/obj/item/weapon/storage/deferred/crate/clown_crime = 1800,
					/obj/item/weapon/storage/deferred/crate/clown_crime/wolf = 1800,
					/obj/item/weapon/storage/deferred/crate/clown_crime/hoxton = 1800,
					/obj/item/weapon/storage/deferred/crate/clown_crime/chains = 1800
					)
	idle_power_usage = 211
	vendor_department = DEPARTMENT_CIVILIAN

/obj/machinery/vending/custom
	name = "Custom Vendomat"
	desc = "A custom vending machine."
	custom_vendor = TRUE
	locked = TRUE
	can_stock = list(/obj/item)

/obj/machinery/vending/custom/verb/remodel()
	set name = "Remodel Vendomat"
	set category = "Object"
	set src in oview(1)

	if(locked)
		to_chat(usr, SPAN_WARNING("[src] needs to be unlocked to remodel it."))
		return
	var/choice = input(usr, "How do you want your Vendomat to look? You can remodel it again later.", "Vendomat Remodeling", null) in CUSTOM_VENDOMAT_MODELS
	if(!choice)
		return
	icon_type = CUSTOM_VENDOMAT_MODELS[choice]
	power_change()

/obj/machinery/vending/custom/verb/rename()
	set name = "Rename Vendomat"
	set category = "Object"
	set src in oview(1)

	if(locked)
		to_chat(usr, SPAN_WARNING("[src] needs to be unlocked to rename it."))
		return

	var/choice = sanitize(input("What do you want to name your Vendomat? You can rename it again later.", "Vendomat Renaming", name) as text|null, MAX_NAME_LEN)
	if(choice)
		SetName(choice)


#undef CUSTOM_VENDOMAT_MODELS

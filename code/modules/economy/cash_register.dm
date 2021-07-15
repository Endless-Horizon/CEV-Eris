/obj/machinery/cash_register
	name = "cash register"
	desc = "Swipe your ID card to make purchases electronically."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "register_idle"
	flags = NOBLUDGEON
	req_access = list()
	anchored = TRUE

	var/locked = 1
	var/cash_locked = 1
	var/cash_open = 0
	var/machine_id = ""
	var/transaction_amount = 0 // cumulatd amount of money to pay in a single purchase
	var/transaction_purpose = null // text that gets used in ATM transaction logs
	var/list/transaction_logs = list() // list of strings using html code to visualise data
	var/list/item_list = list()  // entities and according
	var/list/price_list = list() // prices for each purchase
	var/manipulating = 0
	var/pin_code = null

	var/cash_stored = 0
	var/obj/item/confirm_item
	var/datum/money_account/linked_account
	var/account_to_connect = null


// Claim machine ID
/obj/machinery/cash_register/New()
	. = ..()
	machine_id = "[station_name()] RETAIL #[num_financial_terminals++]"
	cash_stored = rand(10, 70)*10
	transaction_devices += src // Global reference list to be properly set up by /proc/setup_economy()


/obj/machinery/cash_register/examine(mob/user)
	..(user)
	if(cash_open)
		if(cash_stored)
			to_chat(user, "It holds [cash_stored] Credit\s of money.")
		else
			to_chat(user, "It's completely empty.")


/obj/machinery/cash_register/attack_hand(mob/user as mob)
	// Don't be accessible from the wrong side of the machine
	if(get_dir(src, user) & reverse_dir[src.dir]) return

	if(cash_open)
		if(cash_stored)
			spawn_money(cash_stored, loc, user)
			cash_stored = 0
			remove_overlays("register_cash")
		else
			open_cash_box()
	else
		user.set_machine(src)
		interact(user)

/obj/machinery/cash_register/AltClick(mob/user)
	if(Adjacent(user))
		open_cash_box()


/obj/machinery/cash_register/interact(mob/user as mob)
	var/dat = "<h2>Cash Register<hr></h2>"
	if (locked)
		dat += "<a href='?src=\ref[src];choice=toggle_lock'>Unlock</a><br>"
		dat += "Linked account: <b>[linked_account ? linked_account.owner_name : "None"]</b><br>"
		dat += "<b>[cash_locked? "Unlock" : "Lock"] Cash Box</b> | "
	else
		dat += "<a href='?src=\ref[src];choice=toggle_lock'>Lock</a><br>"
		dat += "Linked account: <a href='?src=\ref[src];choice=link_account'>[linked_account ? linked_account.owner_name : "None"]</a><br>"
		dat += "<a href='?src=\ref[src];choice=toggle_cash_lock'>[cash_locked? "Unlock" : "Lock"] Cash Box</a> | "
	dat += "<a href='?src=\ref[src];choice=custom_order'>Custom Order</a><hr>"

	if(item_list.len)
		dat += get_current_transaction()
		dat += "<br>"

	for(var/i=transaction_logs.len, i>=1, i--)
		dat += "[transaction_logs[i]]<br>"

	if(transaction_logs.len)
		dat += locked ? "<br>" : "<a href='?src=\ref[src];choice=reset_log'>Reset Log</a><br>"
		dat += "<br>"
	dat += "<i>Device ID:</i> [machine_id]"
	user << browse(dat, "window=cash_register;size=350x500")
	onclose(user, "cash_register")


/obj/machinery/cash_register/Topic(var/href, var/href_list)
	if(..())
		return

	usr.set_machine(src)

	if(href_list["choice"])
		switch(href_list["choice"])
			if("toggle_lock")
				if(pin_code == null)
					pin_code = input("Please set a lock code") as num
				if(locked == 1)
					if(pin_code != null)
						var/try_pin = input("Cash register lock code") as num
						if(try_pin == pin_code)
							locked = !locked
						else
							to_chat(usr, "\icon[src]<span class='warning'>Insufficient access.</span>")
				else
					locked = !locked
					to_chat(usr, "You lock cash register.")
			if("toggle_cash_lock")
				cash_locked = !cash_locked
			if("link_account")
				var/attempt_account_num = input("Enter account number", "New account number") as num
				var/attempt_pin = input("Enter PIN", "Account PIN") as num
				linked_account = attempt_account_access(attempt_account_num, attempt_pin, 2)
				if(linked_account)
					if(linked_account.suspended)
						linked_account = null
						src.visible_message("\icon[src]<span class='warning'>Account has been suspended.</span>")
				else
					to_chat(usr, "\icon[src]<span class='warning'>Account not found.</span>")
			if("custom_order")
				var/t_purpose = sanitize(input("Enter purpose", "New purpose") as text)
				if (!t_purpose || !Adjacent(usr)) return
				transaction_purpose = t_purpose
				item_list += t_purpose
				var/t_amount = round(input("Enter price", "New price") as num)
				if (!t_amount || !Adjacent(usr)) return
				transaction_amount += t_amount
				price_list += t_amount
				playsound(src, 'sound/machines/twobeep.ogg', 25)
				src.visible_message("\icon[src][transaction_purpose]: [t_amount] Credit\s.")
			if("set_amount")
				var/item_name = locate(href_list["item"])
				var/n_amount = round(input("Enter amount", "New amount") as num)
				n_amount = CLAMP(n_amount, 0, 20)
				if (!item_list[item_name] || !Adjacent(usr)) return
				transaction_amount += (n_amount - item_list[item_name]) * price_list[item_name]
				if(!n_amount)
					item_list -= item_name
					price_list -= item_name
				else
					item_list[item_name] = n_amount
			if("subtract")
				var/item_name = locate(href_list["item"])
				if(item_name)
					transaction_amount -= price_list[item_name]
					item_list[item_name]--
					if(item_list[item_name] <= 0)
						item_list -= item_name
						price_list -= item_name
			if("add")
				var/item_name = locate(href_list["item"])
				if(item_list[item_name] >= 20) return
				transaction_amount += price_list[item_name]
				item_list[item_name]++
			if("clear")
				var/item_name = locate(href_list["item"])
				if(item_name)
					transaction_amount -= price_list[item_name] * item_list[item_name]
					item_list -= item_name
					price_list -= item_name
				else
					transaction_amount = 0
					item_list.Cut()
					price_list.Cut()
			if("reset_log")
				transaction_logs.Cut()
				to_chat(usr, "\icon[src]<span class='notice'>Transaction log reset.</span>")
	updateDialog()



/obj/machinery/cash_register/attackby(obj/O as obj, user as mob)
	// Check for a method of paying (ID, PDA, e-wallet, cash, ect.)
	var/obj/item/card/id/I = O.GetIdCard()
	if(I)
		scan_card(I, O)
	else if (istype(O, /obj/item/spacecash/ewallet))
		var/obj/item/spacecash/ewallet/E = O
		scan_wallet(E)
	else if (istype(O, /obj/item/spacecash))
		var/obj/item/spacecash/SC = O
		if(cash_open)
			to_chat(user, "You neatly sort the cash into the box.")
			cash_stored += SC.worth
			associate_with_overlays("register_cash")
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.drop_from_inventory(SC)
			qdel(SC)
		else
			scan_cash(SC)
	else if(istype(O, /obj/item/card/emag))
		return ..()
	else if(istype(O, /obj/item/tool/wrench))
		var/obj/item/tool/wrench/W = O
		toggle_anchors(W, user)
	// Not paying: Look up price and add it to transaction_amount
	else
		scan_item_price(O)


/obj/machinery/cash_register/MouseDrop_T(atom/dropping, mob/user)
	if(Adjacent(dropping) && Adjacent(user) && !user.stat)
		attackby(dropping, user)


/obj/machinery/cash_register/proc/confirm(obj/item/I)
	if(confirm_item == I)
		return 1
	else
		confirm_item = I
		src.visible_message("\icon[src]<b>Total price:</b> [transaction_amount] Credit\s. Swipe again to confirm.")
		playsound(src, 'sound/machines/twobeep.ogg', 25)
		return 0


/obj/machinery/cash_register/proc/scan_card(obj/item/card/id/I, obj/item/ID_container)
	if (!transaction_amount)
		return

	if (cash_open)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 25)
		to_chat(usr, "\icon[src]<span class='warning'>The cash box is open.</span>")
		return

	if((item_list.len > 1 || item_list[item_list[1]] > 1) && !confirm(I))
		return

	if (!linked_account)
		usr.visible_message("\icon[src]<span class='warning'>Unable to connect to linked account.</span>")
		return

	// Access account for transaction
	if(check_account())
		var/datum/money_account/D = get_account(I.associated_account_number)
		var/attempt_pin = ""
		if(D && D.security_level)
			attempt_pin = input("Enter PIN", "Transaction") as num
			D = null
		D = attempt_account_access(I.associated_account_number, attempt_pin, 2)

		if(!D)
			src.visible_message("\icon[src]<span class='warning'>Unable to access account. Check security settings and try again.</span>")
		else
			if(D.suspended)
				src.visible_message("\icon[src]<span class='warning'>Your account has been suspended.</span>")
			else
				if(transaction_amount > D.money)
					src.visible_message("\icon[src]<span class='warning'>Not enough funds.</span>")
				else
					// Transfer the money
					D.money -= transaction_amount
					linked_account.money += transaction_amount

					// Create log entry in client's account
					var/datum/transaction/T = new()
					T.target_name = "[linked_account.owner_name]"
					T.purpose = transaction_purpose
					T.amount = "([transaction_amount])"
					T.source_terminal = machine_id
					T.date = current_date_string
					T.time = stationtime2text()
					D.transaction_log.Add(T)

					// Create log entry in owner's account
					T = new()
					T.target_name = D.owner_name
					T.purpose = transaction_purpose
					T.amount = "[transaction_amount]"
					T.source_terminal = machine_id
					T.date = current_date_string
					T.time = stationtime2text()
					linked_account.transaction_log.Add(T)

					// Save log
					add_transaction_log(I.registered_name ? I.registered_name : "n/A", "ID Card", transaction_amount)

					// Confirm and reset
					transaction_complete()


/obj/machinery/cash_register/proc/scan_wallet(obj/item/spacecash/ewallet/E)
	if (!transaction_amount)
		return

	if (cash_open)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 25)
		to_chat(usr, "\icon[src]<span class='warning'>The cash box is open.</span>")
		return

	if((item_list.len > 1 || item_list[item_list[1]] > 1) && !confirm(E))
		return

	// Access account for transaction
	if(check_account())
		if(transaction_amount > E.worth)
			src.visible_message("\icon[src]<span class='warning'>Not enough funds.</span>")
		else
			// Transfer the money
			E.worth -= transaction_amount
			linked_account.money += transaction_amount

			// Create log entry in owner's account
			var/datum/transaction/T = new()
			T.target_name = E.owner_name
			T.purpose = transaction_purpose
			T.amount = "[transaction_amount]"
			T.source_terminal = machine_id
			T.date = current_date_string
			T.time = stationtime2text()
			linked_account.transaction_log.Add(T)

			// Save log
			add_transaction_log(E.owner_name, "E-Wallet", transaction_amount)

			// Confirm and reset
			transaction_complete()


/obj/machinery/cash_register/proc/scan_cash(obj/item/spacecash/SC)
	if (!transaction_amount)
		return

	if (cash_open)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 25)
		to_chat(usr, "\icon[src]<span class='warning'>The cash box is open.</span>")
		return

	if((item_list.len > 1 || item_list[item_list[1]] > 1) && !confirm(SC))
		return

	if(transaction_amount > SC.worth)
		src.visible_message("\icon[src]<span class='warning'>Not enough money.</span>")
	else
		// Insert cash into magical slot
		SC.worth -= transaction_amount
		SC.update_icon()
		if(!SC.worth)
			if(ishuman(SC.loc))
				var/mob/living/carbon/human/H = SC.loc
				H.drop_from_inventory(SC)
			qdel(SC)
		cash_stored += transaction_amount

		// Save log
		add_transaction_log("n/A", "Cash", transaction_amount)

		// Confirm and reset
		transaction_complete()


/obj/machinery/cash_register/proc/scan_item_price(obj/O)
	if(!istype(O))	return
	if(item_list.len > 10)
		src.visible_message("\icon[src]<span class='warning'>Only up to ten different items allowed per purchase.</span>")
		return
	if (cash_open)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 25)
		to_chat(usr, "\icon[src]<span class='warning'>The cash box is open.</span>")
		return

	// First check if item has a valid price
	var/price = O.get_item_cost()
	if(isnull(price))
		src.visible_message("\icon[src]<span class='warning'>Unable to find item in database.</span>")
		return
	// Call out item cost
	src.visible_message("\icon[src]\A [O]: [price ? "[price] Credit\s" : "free of charge"].")
	// Note the transaction purpose for later use
	if(transaction_purpose)
		transaction_purpose += "<br>"
	transaction_purpose += "[O]: [price] Credit\s"
	transaction_amount += price
	for(var/previously_scanned in item_list)
		if(price == price_list[previously_scanned] && O.name == previously_scanned)
			. = item_list[previously_scanned]++
	if(!.)
		item_list[O.name] = 1
		price_list[O.name] = price
		. = 1
	// Animation and sound
	playsound(src, 'sound/machines/twobeep.ogg', 25)
	// Reset confirmation
	confirm_item = null
	updateDialog()


/obj/machinery/cash_register/proc/get_current_transaction()
	var/dat = {"
	<head><style>
		.tx-title-r {text-align: center; background-color:#ffdddd; font-weight: bold}
		.tx-name-r {background-color: #eebbbb}
		.tx-data-r {text-align: right; background-color: #ffcccc;}
	</head></style>
	<table width=300>
	<tr><td colspan="2" class="tx-title-r">New Entry</td></tr>
	<tr></tr>"}
	var/item_name
	for(var/i=1, i<=item_list.len, i++)
		item_name = item_list[i]
		dat += "<tr><td class=\"tx-name-r\">[item_list[item_name] ? "<a href='?src=\ref[src];choice=subtract;item=\ref[item_name]'>-</a> <a href='?src=\ref[src];choice=set_amount;item=\ref[item_name]'>Set</a> <a href='?src=\ref[src];choice=add;item=\ref[item_name]'>+</a> [item_list[item_name]] x " : ""][item_name] <a href='?src=\ref[src];choice=clear;item=\ref[item_name]'>Remove</a></td><td class=\"tx-data-r\" width=50>[price_list[item_name] * item_list[item_name]] &thorn</td></tr>"
	dat += "</table><table width=300>"
	dat += "<tr><td class=\"tx-name-r\"><a href='?src=\ref[src];choice=clear'>Clear Entry</a></td><td class=\"tx-name-r\" style='text-align: right'><b>Total Amount: [transaction_amount] &thorn</b></td></tr>"
	dat += "</table></html>"
	return dat


/obj/machinery/cash_register/proc/add_transaction_log(var/c_name, var/p_method, var/t_amount)
	var/dat = {"
	<head><style>
		.tx-title {text-align: center; background-color:#ddddff; font-weight: bold}
		.tx-name {background-color: #bbbbee}
		.tx-data {text-align: right; background-color: #ccccff;}
	</head></style>
	<table width=300>
	<tr><td colspan="2" class="tx-title">Transaction #[transaction_logs.len+1]</td></tr>
	<tr></tr>
	<tr><td class="tx-name">Customer</td><td class="tx-data">[c_name]</td></tr>
	<tr><td class="tx-name">Pay Method</td><td class="tx-data">[p_method]</td></tr>
	<tr><td class="tx-name">Station Time</td><td class="tx-data">[stationtime2text()]</td></tr>
	</table>
	<table width=300>
	"}
	var/item_name
	for(var/i=1, i<=item_list.len, i++)
		item_name = item_list[i]
		dat += "<tr><td class=\"tx-name\">[item_list[item_name] ? "[item_list[item_name]] x " : ""][item_name]</td><td class=\"tx-data\" width=50>[price_list[item_name] * item_list[item_name]] &thorn</td></tr>"
	dat += "<tr></tr><tr><td colspan=\"2\" class=\"tx-name\" style='text-align: right'><b>Total Amount: [transaction_amount] &thorn</b></td></tr>"
	dat += "</table></html>"

	transaction_logs += dat


/obj/machinery/cash_register/proc/check_account()
	if (!linked_account)
		usr.visible_message("\icon[src]<span class='warning'>Unable to connect to linked account.</span>")
		return 0

	if(linked_account.suspended)
		src.visible_message("\icon[src]<span class='warning'>Connected account has been suspended.</span>")
		return 0
	return 1


/obj/machinery/cash_register/proc/transaction_complete()
	/// Visible confirmation
	playsound(src, 'sound/machines/chime.ogg', 25)
	src.visible_message("\icon[src]<span class='notice'>Transaction complete.</span>")
	FLICK("register_approve", src)
	reset_memory()
	updateDialog()


/obj/machinery/cash_register/proc/reset_memory()
	transaction_amount = null
	transaction_purpose = ""
	item_list.Cut()
	price_list.Cut()
	confirm_item = null


/obj/machinery/cash_register/verb/open_cash_box()
	set category = "Object"
	set name = "Open Cash Box"
	set desc = "Open/closes the register's cash box."
	set src in view(1)

	if(usr.stat) return

	if(cash_open)
		cash_open = 0
		remove_overlays("register_approve")
		remove_overlays("register_open")
		remove_overlays("register_cash")
	else if(!cash_locked)
		cash_open = 1
		add_overlays("register_approve")
		add_overlays("register_open")
		if(cash_stored)
			add_overlays("register_cash")
	else
		to_chat(usr, SPAN_WARNING("The cash box is locked."))


/obj/machinery/cash_register/proc/toggle_anchors(obj/item/tool/wrench/W, mob/user)
	if(manipulating) return
	manipulating = 1
	if(!anchored)
		user.visible_message("\The [user] begins securing \the [src] to the floor.",
	                         "You begin securing \the [src] to the floor.")
	else
		user.visible_message(SPAN_WARNING("\The [user] begins unsecuring \the [src] from the floor."),
	                         "You begin unsecuring \the [src] from the floor.")
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	if(!do_after(user, 20))
		manipulating = 0
		return
	if(!anchored)
		user.visible_message(SPAN_NOTICE("\The [user] has secured \the [src] to the floor."),
	                         SPAN_NOTICE("You have secured \the [src] to the floor."))
	else
		user.visible_message(SPAN_WARNING("\The [user] has unsecured \the [src] from the floor."),
	                         SPAN_NOTICE("You have unsecured \the [src] from the floor."))
	anchored = !anchored
	manipulating = 0
	return



/obj/machinery/cash_register/emag_act(var/remaining_charges, var/mob/user)
	if(!emagged)
		src.visible_message(SPAN_DANGER("The [src]'s cash box springs open as [user] swipes the card through the scanner!"))
		playsound(src, "sparks", 50, 1)
		req_access = list()
		emagged = 1
		locked = 0
		cash_locked = 0
		open_cash_box()

/*
//--Premades--//

/obj/machinery/cash_register/command
	account_to_connect = "Command"
	..()

/obj/machinery/cash_register/medical
	account_to_connect = "Medical"
	..()

/obj/machinery/cash_register/engineering
	account_to_connect = "Engineering"
	..()

/obj/machinery/cash_register/science
	account_to_connect = "Science"
	..()

/obj/machinery/cash_register/security
	account_to_connect = "Security"
	..()

/obj/machinery/cash_register/cargo
	account_to_connect = "Guild"
	..()

/obj/machinery/cash_register/civilian
	account_to_connect = "Civilian"
	..()
*/

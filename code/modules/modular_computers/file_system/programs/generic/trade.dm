#define GOODS_SCREEN TRUE
#define OFFER_SCREEN FALSE
/datum/computer_file/program/trade
	filename = "trade"
	filedesc = "Trading Program"
	nanomodule_path = /datum/nano_module/program/trade
	program_icon_state = "supply"
	program_key_state = "rd_key"
	program_menu_icon = "cart"
	extended_desc = "A trade tool, require sending and reseiving beacons."
	size = 21
	available_on_ntnet = FALSE
	requires_ntnet = TRUE

	var/trade_screen = GOODS_SCREEN

	var/list/shoppinglist = list()
	var/choosed_category

	var/obj/machinery/trade_beacon/sending/sending
	var/obj/machinery/trade_beacon/receiving/receiving

	var/datum/trade_station/station

	var/datum/money_account/account

/datum/computer_file/program/trade/proc/set_choosed_category(value)
	choosed_category = value

/datum/computer_file/program/trade/proc/reset_shoplist()
	RecursiveCut(shoppinglist)
	if(station)
		for(var/i in station.assortiment)
			shoppinglist[i] = list()

/datum/computer_file/program/trade/proc/get_price_of_cart()
	. = 0
	for(var/i in shoppinglist)
		var/list/l = shoppinglist[i]
		if(islist(l))
			for(var/b in l)
				. += l[b] * SStrade.get_import_cost(b, station)

/datum/computer_file/program/trade/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["PRG_goods_category"])
		if(!choosed_category || !(choosed_category in station.assortiment))
			set_choosed_category()
		set_choosed_category((text2num(href_list["PRG_goods_category"]) <= length(station.assortiment)) ? station.assortiment[text2num(href_list["PRG_goods_category"])] : "")
		return 1

	if(href_list["PRG_trade_screen"])
		trade_screen = !trade_screen
		return 1

	if(href_list["PRG_account"])
		var/acc_num = input("Enter account number", "Account linking", computer?.card_slot?.stored_card?.associated_account_number) as num|null
		if(!acc_num)
			return

		var/acc_pin = input("Enter PIN", "Account linking") as num|null
		if(!acc_pin)
			return

		var/card_check = computer?.card_slot?.stored_card?.associated_account_number == acc_num
		var/datum/money_account/A = attempt_account_access(acc_num, acc_pin, card_check ? 2 : 1, TRUE)
		if(!A)
			to_chat(usr, SPAN_WARNING("Unable to link account: access denied."))
			return

		account = A
		return 1

	if(href_list["PRG_station"])
		var/datum/trade_station/S = LAZYACCESS(SStrade.discovered_stations, text2num(href_list["PRG_station"]))
		set_choosed_category()
		station = S
		reset_shoplist()
		return 1

	if(href_list["PRG_receiving"])
		var/obj/machinery/trade_beacon/receiving/B = LAZYACCESS(SStrade.beacons_receiving, text2num(href_list["PRG_receiving"]))
		receiving = B
		return 1

	if(href_list["PRG_sending"])
		var/obj/machinery/trade_beacon/sending/B = LAZYACCESS(SStrade.beacons_sending, text2num(href_list["PRG_sending"]))
		sending = B
		return 1

	if(href_list["PRG_cart_reset"])
		reset_shoplist()
		return 1

	if(href_list["PRG_cart_add"] || href_list["PRG_cart_add_input"])
		var/ind
		var/count2buy = 1
		if(href_list["PRG_cart_add_input"])
			count2buy = input(usr, "Input how many you want to add", "Trade", 2) as num
			ind = text2num(href_list["PRG_cart_add_input"])
		else
			ind = text2num(href_list["PRG_cart_add"])
		var/list/category = station.assortiment[choosed_category]
		if(!islist(category))
			return
		var/path = LAZYACCESS(category, ind)
		if(!path)
			return
		var/good_amount = station.get_good_amount(choosed_category, ind)
		if(!good_amount)
			return

		set_2d_matrix_cell(shoppinglist, choosed_category, path, clamp(get_2d_matrix_cell(shoppinglist, choosed_category, path) + count2buy, 0, good_amount))
		return 1

	if(href_list["PRG_cart_remove"])
		var/list/category = station.assortiment[choosed_category]
		if(!islist(category))
			return
		var/path = LAZYACCESS(category, text2num(href_list["PRG_cart_remove"]))
		if(!path)
			return
		var/good_amount = station.get_good_amount(choosed_category, text2num(href_list["PRG_cart_remove"]))

		set_2d_matrix_cell(shoppinglist, choosed_category, path, clamp(get_2d_matrix_cell(shoppinglist, choosed_category, path) - 1, 0, good_amount))
		return 1

	if(account)
		if(href_list["PRG_receive"])
			SStrade.buy(receiving, account, shoppinglist, station)
			reset_shoplist()
			return 1
		if(href_list["PRG_account_unlink"])
			account = null
			return 1

		if(href_list["PRG_offer_fulfill"])
			var/datum/trade_station/S = LAZYACCESS(SStrade.discovered_stations, text2num(href_list["PRG_offer_fulfill"]))
			if(!S)
				return
			SStrade.fulfill_offer(sending, account, station)
			return 1

		var/t2n = text2num(href_list["PRG_sell"])
		if(isnum(t2n) && station)
			var/path = get_2d_matrix_cell(station.assortiment, choosed_category, t2n)
			SStrade.sell_thing(sending, account, locate(path) in SStrade.assess_offer(sending, station, path), station)
			return 1

/datum/nano_module/program/trade
	name = "Trading Program"

/datum/nano_module/program/trade/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = NANOUI_FOCUS, state = GLOB.default_state)
	var/list/data = nano_ui_data()

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "trade.tmpl", name, 750, 700, state = state)
		ui.set_auto_update(1)
		ui.set_initial_data(data)
		ui.open()

/datum/nano_module/program/trade/nano_ui_data()
	. = ..()
	var/datum/computer_file/program/trade/PRG = program
	if(!istype(PRG))
		return

	.["tradescreen"] = PRG.trade_screen

	.["station_name"] = PRG.station?.name
	.["station_desc"] = PRG.station?.desc
	.["station_index"] = SStrade.discovered_stations.Find(PRG.station)

	.["receiving_index"] =  SStrade.beacons_receiving.Find(PRG.receiving)
	.["sending_index"] = SStrade.beacons_sending.Find(PRG.sending)

	if(PRG.account)
		.["account"] = "[PRG.account.get_name()] #[PRG.account.account_number]"

	if(!QDELETED(PRG.receiving))
		.["receiving"] = PRG.receiving.get_id()

	if(!QDELETED(PRG.sending))
		.["sending"] = PRG.sending.get_id()

	.["station_list"] = list()
	for(var/datum/trade_station/S in SStrade.discovered_stations)
		.["station_list"] += list(list("name" = S.name, "desc" = S.desc, "index" = SStrade.discovered_stations.Find(S)))

	.["receiving_list"] = list()
	for(var/obj/machinery/trade_beacon/receiving/B in SStrade.beacons_receiving)
		.["receiving_list"] += list(list("id" = B.get_id(), "index" = SStrade.beacons_receiving.Find(B)))

	.["sending_list"] = list()
	for(var/obj/machinery/trade_beacon/sending/B in SStrade.beacons_sending)
		.["sending_list"] += list(list("id" = B.get_id(), "index" = SStrade.beacons_sending.Find(B)))

	if(PRG.station)
		if(!PRG.choosed_category || !(PRG.choosed_category in PRG.station.assortiment))
			PRG.set_choosed_category()
		.["commision"] = PRG.station.commision
		.["current_category"] = PRG.choosed_category ? PRG.station.assortiment.Find(PRG.choosed_category) : null
		.["goods"] = list()
		.["categories"] = list()
		.["total"] = PRG.get_price_of_cart()
		for(var/i in PRG.station.assortiment)
			if(istext(i))
				.["categories"] += list(list("name" = i, "index" = PRG.station.assortiment.Find(i)))
		if(PRG.choosed_category)
			var/list/assort = PRG.station.assortiment[PRG.choosed_category]
			if(islist(assort))
				for(var/path in assort)
					if(!ispath(path, /atom/movable))
						continue
					var/atom/movable/AM = path

					var/index = assort.Find(path)

					var/amount = PRG.station.get_good_amount(PRG.choosed_category, index)

					var/amount2sell = 0
					if(PRG.station && PRG.sending)
						amount2sell = length(SStrade.assess_offer(PRG.sending, PRG.station, path))
					var/pathname = initial(AM.name)
					var/list/good_packet = assort[path]
					if(islist(good_packet))
						pathname = good_packet["name"] ? good_packet["name"] : pathname
					var/price = SStrade.get_import_cost(path, PRG.station)

					var/count = max(0, get_2d_matrix_cell(PRG.shoppinglist, PRG.choosed_category, path))

					.["goods"] += list(list(
						"name" = pathname,
						"price" = price,
						"count" = count ? count : 0,
						"amount_available" = amount,
						"amount_available_around" = amount2sell,
						"index" = index
					))
		if(!recursiveLen(.["goods"]))
			.["goods"] = null

	.["offers"] = list()
	for(var/datum/trade_station/S in SStrade.discovered_stations)
		var/atom/movable/offer_type = S.offer_type
		var/list/offer = list("station" = S.name, "name" = initial(offer_type.name), "amount" = S.offer_amount, "price" = S.offer_price, "index" = SStrade.discovered_stations.Find(S))
		if(PRG.sending)
			offer["available"] = length(SStrade.assess_offer(PRG.sending, S))
		.["offers"] += list(offer)
	if(!recursiveLen(.["offers"]))
		.["offers"] = null


#undef GOODS_SCREEN
#undef OFFER_SCREEN

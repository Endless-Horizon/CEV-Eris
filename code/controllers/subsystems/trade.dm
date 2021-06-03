#define TRADE_SYSTEM_IC_NAME "Asters Automated Trading System"
GLOBAL_LIST_EMPTY(price_cache)
SUBSYSTEM_DEF(trade)
	name = "Trade"
	priority = FIRE_PRIORITY_SUPPLY
	flags = SS_NO_FIRE

	var/trade_stations_budget = 8 //how many trade stations should spawned

	var/list/obj/machinery/trade_beacon/sending/beacons_sending = list()
	var/list/obj/machinery/trade_beacon/receiving/beacons_receiving = list()

	var/list/datum/trade_station/all_stations = list()
	var/list/datum/trade_station/discovered_stations = list()

/datum/controller/subsystem/trade/proc/DiscoverAllTradeStations()
	discovered_stations = all_stations.Copy()

/datum/controller/subsystem/trade/Initialize()
	InitStations()
	. = ..()

/datum/controller/subsystem/trade/proc/ReInitStations()
	DeInitStations()
	InitStations()

/datum/controller/subsystem/trade/Destroy()
	DeInitStations()
	. = ..()

/datum/controller/subsystem/trade/proc/DeInitStations()
	for(var/datum/trade_station/s in all_stations)
		s.regain_trade_stations_budget()
		qdel(s)
		discovered_stations -= s
		all_stations -= s

/datum/controller/subsystem/trade/proc/InitStations()
	var/list/weightstationlist = collect_trade_stations()
	var/list/stations2init = collect_spawn_always()

	while(trade_stations_budget && length(weightstationlist))
		var/datum/trade_station/station_instance = pickweight(weightstationlist)
		if(istype(station_instance))
			stations2init += station_instance
			station_instance.cost_trade_stations_budget()
		weightstationlist.Remove(station_instance)
	init_stations_by_list(stations2init)

/datum/controller/subsystem/trade/proc/collect_trade_stations()
	. = list()
	for(var/path in subtypesof(/datum/trade_station))
		var/datum/trade_station/s = new path()
		if(!s.spawn_always && s.spawn_probability)
			.[s] = s.spawn_probability
		else
			qdel(s)

/datum/controller/subsystem/trade/proc/collect_spawn_always()
	. = list()
	for(var/path in subtypesof(/datum/trade_station))
		var/datum/trade_station/s = new path()
		if(s.spawn_always)
			. += s
		else
			qdel(s)

/datum/controller/subsystem/trade/proc/init_station(stype)
	var/datum/trade_station/station
	if(istype(stype, /datum/trade_station))
		station = stype
		if(!station.name)
			station.init_src()
	else if(ispath(stype, /datum/trade_station))
		station = new stype(TRUE)
	. = station

/datum/controller/subsystem/trade/proc/init_stations_by_list(list/L)
	. = list()
	for(var/i in try_json_decode(L))
		var/a = init_station(i)
		if(a)
			. += a

//Returns cost of an existing object including contents
/datum/controller/subsystem/trade/proc/get_cost(atom/movable/target)
	. = 0
	for(var/atom/movable/A in target.GetAllContents(includeSelf = TRUE))
		. += A.get_item_cost(TRUE)

//Returns cost of a newly created object including contents
/datum/controller/subsystem/trade/proc/get_new_cost(path)
	if(!ispath(path))
		var/atom/movable/A = path
		if(istype(A))
			path = A.type
		else
			crash_with("Unacceptable get_new_cost() by path ([path]) and type ([A?.type]).")
			return 0

	if(!GLOB.price_cache[path])
		var/atom/movable/AM = new path
		GLOB.price_cache[path] = get_cost(AM)
		qdel(AM)
	return GLOB.price_cache[path]

/datum/controller/subsystem/trade/proc/get_export_cost(atom/movable/target)
	. = get_cost(target) * 0.6

/datum/controller/subsystem/trade/proc/get_import_cost(path, datum/trade_station/trade_station)
	. = get_new_cost(path)
	var/markup = 1.2
	if(istype(trade_station))
		markup += trade_station.markup
	. *= markup

/datum/controller/subsystem/trade/proc/assess_offer(obj/machinery/trade_beacon/sending/beacon, datum/trade_station/station, offer_type = station.offer_type)
	if(QDELETED(beacon) || !station)
		return

	. = list()

	for(var/atom/movable/AM in beacon.get_objects())
		if(AM.anchored || !istype(AM, offer_type))
			continue
		. += AM

/datum/controller/subsystem/trade/proc/fulfill_offer(obj/machinery/trade_beacon/sending/beacon, datum/money_account/account, datum/trade_station/station)
	var/list/exported = assess_offer(beacon, station)

	if(!exported || length(exported) < station.offer_amount)
		return

	exported.Cut(station.offer_amount + 1)

	for(var/atom/movable/AM in exported)
		qdel(AM)

	beacon.activate()

	if(account)
		var/datum/money_account/A = account
		var/datum/transaction/T = new(station.offer_price, account.get_name(), "Special deal", station.name)
		T.apply_to(A)

	station.generate_offer()

/datum/controller/subsystem/trade/proc/collect_counts_from(list/shopList)
	. = 0
	for(var/categoryName in shopList)
		var/category = shopList[categoryName]
		if(length(category))
			for(var/path in category)
				. += category[path]

/datum/controller/subsystem/trade/proc/collect_price_for_list(list/shopList)
	. = 0
	for(var/categoryName in shopList)
		var/category = shopList[categoryName]
		if(length(category))
			for(var/path in category)
				. += get_import_cost(path) * category[path]

/datum/controller/subsystem/trade/proc/buy(obj/machinery/trade_beacon/receiving/senderBeacon, datum/money_account/account, list/shopList, datum/trade_station/station)
	if(QDELETED(senderBeacon) || !istype(senderBeacon) || !account || !recursiveLen(shopList) || !istype(station))
		return

	var/obj/structure/closet/crate/C
	var/count_of_all = collect_counts_from(shopList)
	var/price_for_all = collect_price_for_list(shopList)
	if(isnum(count_of_all) && count_of_all > 1)
		price_for_all += station.commision
		C = senderBeacon.drop(/obj/structure/closet/crate)
	if(price_for_all && get_account_credits(account) < price_for_all)
		return

	for(var/categoryName in shopList)
		var/list/shoplist_category = shopList[categoryName]
		var/list/assortiment_category = station.assortiment[categoryName]
		if(length(shoplist_category) && length(assortiment_category))
			for(var/pathOfGood in shoplist_category)
				var/count_of_good = shoplist_category[pathOfGood] //in shoplist
				var/index_of_good = assortiment_category.Find(pathOfGood) //in assortiment
				for(var/i in 1 to count_of_good)
					istype(C) ? new pathOfGood(C) : senderBeacon.drop(pathOfGood)
				if(isnum(index_of_good))
					station.set_good_amount(categoryName, index_of_good, max(0, station.get_good_amount(categoryName, index_of_good) - count_of_good))
	charge_to_account(account.account_number, account.get_name(), "Purchase", station.name, price_for_all)

/datum/controller/subsystem/trade/proc/sell_thing(obj/machinery/trade_beacon/sending/senderBeacon, datum/money_account/account, atom/movable/thing, datum/trade_station/station)
	if(QDELETED(senderBeacon) || !istype(senderBeacon) || !account || !istype(thing) || !istype(station))
		return

	var/cost = get_export_cost(thing)

	qdel(thing)
	senderBeacon.activate()

	charge_to_account(account.account_number, account.get_name(), "Selling", station.name, -cost)

#define ERRORCODE_INVALID	1
#define ERRORCODE_NOFUNDS	2

/obj/machinery/computer/supplycomp
	name = "supply control console"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "tech_key"
	icon_screen = "supply"
	light_color = COLOR_LIGHTING_ORANGE_MACHINERY
	req_access = list(access_cargo)
	circuit = /obj/item/electronics/circuitboard/supplycomp
	var/temp
	var/reqtime = 0 //Cooldown for requisitions - Quarxink
	var/last_viewed_group = "categories"
	var/can_order_contraband = FALSE
	var/requestonly = FALSE
	var/contraband = FALSE
	var/hacked = FALSE

/obj/machinery/computer/supplycomp/attack_hand(mob/user)
	if(!allowed(user))
		to_chat(user, SPAN_WARNING("Access Denied."))
		return

	if(..())
		return
	user.set_machine(src)
	post_signal("supply")
	var/dat
	if (temp)
		dat = temp
	else
		var/datum/shuttle/autodock/ferry/supply/shuttle = SSsupply.shuttle
		if (shuttle)
			dat += "<BR><B>Supply shuttle</B><HR>"
			dat += "\nLocation: "

			if (shuttle.has_arrive_time())
				dat += "In transit ([shuttle.eta_minutes()] Mins.)"

			else if(shuttle.at_station())
				if (!shuttle.can_launch())
					dat += "Docking/Undocking"
				else
					dat += "Vessel"
			else
				dat += "Away"

			dat += "<BR>"

			if(!requestonly)
				if(shuttle.can_launch())
					if(shuttle.at_station())
						dat += "<A href='?src=\ref[src];send=1'>Send away</A>"
					else
						dat += "<A href='?src=\ref[src];send=1'>Request supply shuttle</A>"

				else if (shuttle.can_cancel())
					dat += "<A href='?src=\ref[src];cancel_send=1'>Cancel request</A>"
				else
					dat += "*Shuttle is busy*"
			dat += "<BR>\n<BR>"

		if(!requestonly)
			dat += "<HR>\n"
			dat += "<b>Guild Credits: [get_account_credits(department_accounts[DEPARTMENT_GUILD])][CREDS]</b><BR><BR>"

		dat += "<A href='?src=\ref[src];order=categories'>[requestonly ? "Request" : "Order"] items</A><BR>"

		if(!requestonly)
			dat += "<A href='?src=\ref[src];viewmes=1'>View messages</A><BR>"
			dat += "<A href='?src=\ref[src];viewaccount=\ref[department_accounts[DEPARTMENT_GUILD]]'>View banking data</A><BR>"

		dat += {"
		<A href='?src=\ref[src];viewrequests=1'>View requests</A><BR>
		<A href='?src=\ref[src];vieworders=1'>View orders</A>"}


	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return

/obj/machinery/computer/supplycomp/emag_act(remaining_charges, mob/user)
	if(!hacked)
		to_chat(user, SPAN_NOTICE("Special supplies unlocked."))
		hacked = TRUE
		return TRUE

/obj/machinery/computer/supplycomp/Topic(href, href_list)
	var/datum/shuttle/autodock/ferry/supply/shuttle = SSsupply.shuttle
	if (!shuttle)
		log_world("## ERROR: Eek. The supply/shuttle datum is missing somehow.")
		return
	if(..())
		return TRUE

	var/datum/money_account/supply_account = department_accounts[DEPARTMENT_GUILD]

	if(isturf(loc) && ( in_range(src, usr) || issilicon(usr) ) )
		usr.set_machine(src)

	//Calling the shuttle
	if(href_list["send"])
		if(shuttle.at_station())
			if (shuttle.forbidden_atoms_check())
				temp = "For safety reasons the automated supply shuttle cannot transport live organisms, classified nuclear weaponry or homing beacons."
			else
				shuttle.launch(src)
				temp = "Initiating launch sequence. \[<span class='warning'><A href='?src=\ref[src];force_send=1'>Force Launch</A></span>\]"
		else
			shuttle.launch(src)
			temp = "The supply shuttle has been called and will arrive in approximately [round(SSsupply.movetime/600,1)] minutes."
			post_signal("supply")
		temp += "<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	if(href_list["viewmes"])
		if(SSsupply.centcom_message)
			temp += "Latest message: <BR><BR>"
			temp +=  SSsupply.centcom_message
			temp += "<BR>"
		else
			temp += "Can not find any messages from Commercial barge. <BR>"
		temp += "<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	if(href_list["viewaccount"])
		var/datum/money_account/account = locate(href_list["viewaccount"]) in all_money_accounts
		if(!account)
			updateUsrDialog()
			return

		temp = "<A href='?src=\ref[src];mainmenu=1'>Main Menu</a><HR><BR>"

		temp += "<b>[account.get_name()]</b><br>"
		temp += "Account number: #[account.account_number]<br>"
		temp += "Balance: [num2text(account.money, 12)][CREDS]<br>"

		temp += "<br><b>Transaction logs</b>"
		temp += "<table border=1 style='width:100%'>"
		temp += "<tr>"
		temp += "<td><b>Date</b></td>"
		temp += "<td><b>Time</b></td>"
		temp += "<td><b>Target</b></td>"
		temp += "<td><b>Purpose</b></td>"
		temp += "<td><b>Value</b></td>"
		temp += "<td><b>Source terminal</b></td>"
		temp += "</tr>"
		for(var/datum/transaction/T in reverseList(account.transaction_log))
			temp += "<tr>"
			temp += "<td>[T.date]</td><td>[T.time]</td>"
			temp += "<td>[T.target_name]</td><td>[T.purpose]</td>"
			temp += "<td>[num2text(T.amount,12)][CREDS]</td>"
			temp += "<td>[T.source_terminal]</td>"
			temp += "</tr>"
		temp += "</table><br>"

		temp += "<A href='?src=\ref[src];viewaccount=\ref[account]'>Refresh</A>"

	if (href_list["force_send"])
		shuttle.force_launch(src)

	if (href_list["cancel_send"])
		shuttle.cancel_launch(src)

	else if (href_list["order"])
		if(requestonly)
			temp = ""
		else
			temp = "<b>Guild Credits: [get_account_credits(supply_account)][CREDS]</b><BR>"

		if(href_list["order"] == "categories")
			//all_supply_groups
			//Request what?
			last_viewed_group = "categories"
			temp += "<A href='?src=\ref[src];mainmenu=1'>Main Menu</A><HR><BR>"
			temp += "<b>Select a category</b><BR><BR>"
			for(var/supply_group_name in all_supply_groups )
				temp += "<A href='?src=\ref[src];order=[supply_group_name]'>[supply_group_name]</A><BR>"
		else
			last_viewed_group = href_list["order"]
			temp += "<A href='?src=\ref[src];order=categories'>Back to all categories</A><HR><BR>"
			temp += "<b>Request from: [last_viewed_group]</b><BR><BR>"
			for(var/supply_name in SSsupply.supply_packs)
				var/datum/supply_pack/N = SSsupply.supply_packs[supply_name]
				if((N.hidden && !hacked) || (N.contraband && !can_order_contraband) || N.group != last_viewed_group)
					continue
				temp += "<A href='?src=\ref[src];doorder=[supply_name]'>[supply_name]</A> Cost: [N.cost]<BR>"
				//Have to send the type instead of a reference to the obj because it would get caught by GC

	else if (href_list["doorder"])
		if(world.time < reqtime)
			for(var/mob/V in hearers(src))
				V.show_message("<b>[src]</b>'s monitor flashes, \"[world.time - reqtime] seconds remaining until another requisition form may be printed.\"")
			return

		//Find the correct supply_pack datum
		var/datum/supply_pack/P = SSsupply.supply_packs[href_list["doorder"]]
		if(!istype(P))	return

		var/reason = sanitize(input(usr, "Reason:", "Why do you require this item?","") as null|text)
		if(!reason || !CanUseTopic(usr))
			return

		var/idname = "*None Provided*"
		var/idrank = "*None Provided*"
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			idname = H.get_authentification_name()
			idrank = H.get_assignment()
		else if(issilicon(usr))
			idname = usr.real_name

		//make our supply_order datum
		var/datum/supply_order/O = new /datum/supply_order(P, idname, idrank, null, reason)
		SSsupply.requestlist += O

		O.generateRequisition(loc)

		reqtime = (world.time + 5) % 1e5

		temp = "Order request placed.<BR>"
		temp += "<BR><A href='?src=\ref[src];order=[last_viewed_group]'>Back</A> | <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
		if(!requestonly)
			temp += " | <A href='?src=\ref[src];confirmorder=[O.id]'>Authorize Order</A>"

	else if(href_list["confirmorder"])
		//Find the correct supply_order datum
		var/ordernum = text2num(href_list["confirmorder"])
		var/error = approve_order(ordernum)

		//An errorcode of 0 means success
		if (!error)
			temp = "Thanks for your order.<BR>"
		else if (error == ERRORCODE_NOFUNDS)
			temp = "Not enough credits.<BR>"
		else if (error == ERRORCODE_INVALID)
			temp = "Invalid Request<br>"

		temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"

	else if (href_list["vieworders"])
		temp = "Current approved orders: <BR><BR>"
		for(var/S in SSsupply.shoppinglist)
			var/datum/supply_order/SO = S
			temp += "#[SO.id] - [SO.object.name] ordered by [SO.orderer][SO.reason ? " ([SO.reason])":""]<BR>"// <A href='?src=\ref[src];cancelorder=[S]'>(Cancel)</A><BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	/*
	//Cancelling already authorised orders gets messy, disabled for now
	//Just don't authorise it til you're sure
	else if (href_list["cancelorder"])
		var/datum/supply_order/remove_supply = href_list["cancelorder"]
		SSsupply.requestlist -= remove_supply
		get_supply_credits() += remove_supply.object.cost
		temp += "Canceled: [remove_supply.object.name]<BR><BR><BR>"

		for(var/S in SSsupply.requestlist)
			var/datum/supply_order/SO = S
			temp += "[SO.object.name] approved by [SO.orderedby][SO.comment ? " ([SO.comment])":""] <A href='?src=\ref[src];cancelorder=[S]'>(Cancel)</A><BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
	*/

	else if (href_list["viewrequests"])
		temp = "Current requests: <BR><BR>"
		for(var/S in SSsupply.requestlist)
			var/datum/supply_order/SO = S
			temp += "#[SO.id] - [SO.object.name] requested by [SO.orderer] "
			if(!requestonly)
				temp += "<A href='?src=\ref[src];confirmorder=[SO.id]'>Approve</A> "
			temp += "<A href='?src=\ref[src];rreq=[SO.id]'>Remove</A><BR>"

		if(!requestonly)
			temp += "<BR><A href='?src=\ref[src];clearreq=1'>Clear list</A>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["rreq"])
		var/ordernum = text2num(href_list["rreq"])
		temp = "Invalid Request.<BR>"
		for (var/i in 1 to SSsupply.requestlist.len)
			var/datum/supply_order/SO = SSsupply.requestlist[i]
			if(SO.id == ordernum)
				SSsupply.requestlist.Cut(i,i+1)
				temp = "Request removed.<BR>"
				break
		temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"

	else if (href_list["clearreq"])
		SSsupply.requestlist.Cut()
		temp = "List cleared.<BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["mainmenu"])
		temp = null

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/supplycomp/proc/approve_order(ordernum)
	var/datum/supply_order/O
	for (var/i in 1 to SSsupply.requestlist.len)
		var/datum/supply_order/SO = SSsupply.requestlist[i]
		if(SO.id == ordernum)
			O = SO
			if (pay_for_order(O, src))
				SSsupply.requestlist.Cut(i,i+1)
				SSsupply.shoppinglist += O
				return 0

			else
				return ERRORCODE_NOFUNDS

/obj/machinery/computer/supplycomp/proc/post_signal(var/command)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(1435)

	if(!frequency) return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	frequency.post_signal(src, status_signal)

#undef ERRORCODE_INVALID
#undef ERRORCODE_NOFUNDS


/obj/machinery/computer/supplycomp/order
	name = "supply ordering console"
	icon_screen = "request"
	circuit = /obj/item/electronics/circuitboard/ordercomp
	requestonly = TRUE
	req_access = list()

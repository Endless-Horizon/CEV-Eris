/datum/computer_file/program/signaller
	filename = "signalman"
	filedesc = "Signal Manager"
	extended_desc = "A tool that uses a wireless network card to send simple control signals."
	program_icon_state = "generic"
	program_key_state = "generic_key"
	program_menu_icon = "signal-diag"
	size = 4
	requires_ntnet = 0
	available_on_ntnet = TRUE
	usage_flags = PROGRAM_ALL

	var/code = 30
	var/max_saved = 10
	var/list/saved_signals = list()

/datum/computer_file/program/signaller/clone()
	var/datum/computer_file/program/signaller/F = ..()
	F.code = code
	for(var/list/L in saved_signals)
		F.saved_signals.Add(list(L.Copy()))
	return F

/datum/computer_file/program/signaller/is_supported_by_hardware(obj/item/modular_computer/hardware, mob/user, loud)
	if(!..())
		return FALSE

	if(!hardware?.network_card.check_functionality() || hardware.network_card.ethernet)
		if(loud)
			to_chat(user, SPAN_WARNING("Hardware Error - Wireless network card required"))
		return FALSE

	return TRUE

/datum/computer_file/program/signaller/nano_ui_data()
	var/list/data = computer.get_header_data()

	data["freq"] = computer?.network_card.frequency
	data["code"] = code
	data["max_saved"] = max_saved
	data["saved_signals"] = saved_signals

	return data


/datum/computer_file/program/signaller/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui, force_open = NANOUI_FOCUS, datum/topic_state/state = GLOB.default_state)
	var/list/data = nano_ui_data(user)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "mpc_signaller.tmpl", filedesc, 450, 600, state = state)
		ui.set_initial_data(data)
		ui.open()


/datum/computer_file/program/signaller/Topic(href, href_list)
	if(..())
		return 1

	if(!computer?.network_card.check_functionality())
		to_chat(usr, SPAN_WARNING("Hardware Error - Network card failure"))
		return 1

	if(href_list["signal"])
		computer.network_card.signal(text2num(href_list["freq"]), text2num(href_list["code"]))
		return 1

	if(href_list["change_code"])
		code = clamp(round(code + text2num(href_list["change_code"])), 1, 100)
		return 1

	if(href_list["edit_code"])
		var/input_code = input("Enter signal code (1-100):", "Signal parameters", code) as num|null
		if(input_code && CanUseTopic(usr))
			code = clamp(round(input_code), 1, 100)
		return 1

	if(href_list["change_freq"])
		computer.network_card.set_frequency(computer.network_card.frequency + text2num(href_list["change_freq"]))
		return 1

	if(href_list["edit_freq"])
		var/input_freq = input("Enter signal frequency ([RADIO_LOW_FREQ]-[RADIO_HIGH_FREQ]):", "Signal parameters", computer.network_card.frequency) as num|null
		if(input_freq && CanUseTopic(usr) && computer && computer.network_card)
			if(input_freq < RADIO_LOW_FREQ) // A decimal input maybe?
				input_freq *= 10

			computer.network_card.set_frequency(round(input_freq))
		return 1

	if(href_list["save_signal"])
		if(length(saved_signals) >= max_saved)
			return 1
		saved_signals.Add(list(list("freq"=computer.network_card.frequency, "code"=code)))
		return 1

	if(href_list["delete_signal"])
		var/delete_index = clamp(round(text2num(href_list["PRG_delete_signal"])), 1, length(saved_signals))
		saved_signals.Cut(delete_index, delete_index+1)
		return 1

/datum/computer_file/program/signaller/proc/receive_signal(datum/signal/signal)
	if(signal.encryption == code)
		for(var/mob/O in hearers(1, computer.loc))
			O.show_message("\icon[computer] *beep* *beep*", 3, "*beep* *beep*", 2)

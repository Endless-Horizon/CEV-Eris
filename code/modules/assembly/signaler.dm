/obj/item/device/assembly/signaler
	name = "remote signaling device"
	desc = "Used to remotely activate devices."
	icon_state = "signaller"
	item_state = "signaler"
	origin_tech = list(TECH_MAGNET = 1)
	matter = list(MATERIAL_PLASTIC = 1)
	wires = WIRE_RECEIVE | WIRE_PULSE | WIRE_RADIO_PULSE | WIRE_RADIO_RECEIVE

	secured = 1

	var/code = 30
	var/frequency = 1457
	var/delay = 0
	var/airlock_wire
	var/datum/wires/connected
	var/datum/radio_frequency/radio_connection
	var/deadman = 0

/obj/item/device/assembly/signaler/New()
	..()
	spawn(40)
		set_frequency(frequency)
	return


/obj/item/device/assembly/signaler/activate()
	if(cooldown > 0)	return 0
	cooldown = 2
	spawn(10)
		process_cooldown()

	signal()
	return 1

/obj/item/device/assembly/signaler/on_update_icon()
	if(holder)
		holder.update_icon()
	return

/obj/item/device/assembly/signaler/proc/set_code(new_code)
	code = clamp(round(new_code), 1, 100)

/obj/item/device/assembly/signaler/proc/set_freq(new_freq)
	set_frequency(sanitize_frequency(round(new_freq), RADIO_LOW_FREQ, RADIO_HIGH_FREQ))

/obj/item/device/assembly/signaler/interact(mob/user, flag1)
	nano_ui_interact(user)

/obj/item/device/assembly/signaler/nano_ui_data()
	var/list/data = list(
		"freq" = frequency,
		"code" = code
		)
	return data

/obj/item/device/assembly/signaler/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = NANOUI_FOCUS, datum/topic_state/state = GLOB.default_state)
	var/list/data = nano_ui_data(user)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "mpc_signaller.tmpl", name, 350, 200, state = state)
		ui.set_initial_data(data)
		ui.open()

/obj/item/device/assembly/signaler/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["signal"])
		set_freq(text2num(href_list["freq"]))
		set_code(text2num(href_list["code"]))

		spawn(0)
			signal()
		return 1

	if(href_list["change_code"])
		set_code(code + text2num(href_list["change_code"]))
		return 1

	if(href_list["edit_code"])
		var/input_code = input("Enter signal code (1-100):", "Signal parameters", code) as num|null
		if(input_code && CanUseTopic(usr))
			set_code(input_code)
		return 1

	if(href_list["change_freq"])
		set_freq(frequency + text2num(href_list["change_freq"]))
		return 1

	if(href_list["edit_freq"])
		var/input_freq = input("Enter signal frequency ([RADIO_LOW_FREQ]-[RADIO_HIGH_FREQ]):", "Signal parameters", frequency) as num|null
		if(input_freq && CanUseTopic(usr))
			if(input_freq < RADIO_LOW_FREQ) // A decimal input maybe?
				input_freq *= 10

			set_freq(input_freq)
		return 1


/obj/item/device/assembly/signaler/proc/signal()
	if(!radio_connection)
		return

	var/datum/signal/signal = new
	signal.source = src
	signal.encryption = code
	signal.data["message"] = "ACTIVATE"
	radio_connection.post_signal(src, signal)


/obj/item/device/assembly/signaler/pulse(var/radio = 0)
	if(src.connected && src.wires)
		connected.Pulse(src)
	else if(holder)
		holder.process_activation(src, 1, 0)
	else
		..(radio)


/obj/item/device/assembly/signaler/receive_signal(datum/signal/signal)
	if(!signal)
		return
	if(signal.encryption != code)
		return
	if(!(src.wires & WIRE_RADIO_RECEIVE))
		return
	pulse(1)

	if(!holder)
		for(var/mob/O in hearers(1, src.loc))
			O.show_message("\icon[src] *beep* *beep*", 3, "*beep* *beep*", 2)


/obj/item/device/assembly/signaler/proc/set_frequency(new_frequency)
	if(!frequency)
		return
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_CHAT)
	return


/obj/item/device/assembly/signaler/Process()
	if(!deadman)
		STOP_PROCESSING(SSobj, src)
	var/mob/M = src.loc
	if(!M || !ismob(M))
		if(prob(5))
			signal()
		deadman = 0
		STOP_PROCESSING(SSobj, src)
	else if(prob(5))
		M.visible_message("[M]'s finger twitches a bit over [src]'s signal button!")
	return


/obj/item/device/assembly/signaler/verb/deadman_it()
	set src in usr
	set name = "Threaten to push the button!"
	set desc = "BOOOOM!"
	deadman = 1
	START_PROCESSING(SSobj, src)
	log_and_message_admins("is threatening to trigger a signaler deadman's switch")
	usr.visible_message("\red [usr] moves their finger over [src]'s signal button...")

/obj/item/device/assembly/signaler/Destroy()
	SSradio.remove_object(src,frequency)
	frequency = 0
	. = ..()

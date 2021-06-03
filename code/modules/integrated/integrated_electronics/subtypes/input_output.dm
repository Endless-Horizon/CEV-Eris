#define qdel_null(x) if(x) { qdel(x) ; x = null }


/obj/item/integrated_circuit/input
	var/can_be_asked_input = 0
	category_text = "Input"
	power_draw_per_use = 5

/obj/item/integrated_circuit/input/proc/ask_for_input(mob/user)
	return

/obj/item/integrated_circuit/input/button
	name = "button"
	desc = "This tiny button must do something, right?"
	icon_state = "button"
	complexity = 1
	can_be_asked_input = 1
	inputs = list()
	outputs = list()
	activators = list("\<PULSE OUT\> on pressed")
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/input/button/ask_for_input(mob/user) //Bit misleading name for this specific use.
	to_chat(user, SPAN_NOTICE("You press the button labeled '[src.name]'."))
	activate_pin(1)

/obj/item/integrated_circuit/input/toggle_button
	name = "toggle button"
	desc = "It toggles on, off, on, off..."
	icon_state = "toggle_button"
	complexity = 1
	can_be_asked_input = 1
	inputs = list()
	outputs = list("\<NUM\> on" = 0)
	activators = list("\<PULSE OUT\> on toggle")
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/input/toggle_button/ask_for_input(mob/user) // Ditto.
	set_pin_data(IC_OUTPUT, 1, !get_pin_data(IC_OUTPUT, 1))
	push_data()
	activate_pin(1)
	to_chat(user, "<span class='notice'>You toggle the button labeled '[src.name]' [get_pin_data(IC_OUTPUT, 1) ? "on" : "off"].</span>")

/obj/item/integrated_circuit/input/numberpad
	name = "number pad"
	desc = "This small number pad allows someone to input a number into the system."
	icon_state = "numberpad"
	complexity = 2
	can_be_asked_input = 1
	inputs = list()
	outputs = list("\<NUM\> number entered")
	activators = list("\<PULSE OUT\> on entered")
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 4

/obj/item/integrated_circuit/input/numberpad/ask_for_input(mob/user)
	var/new_input = input(user, "Enter a number, please.","Number pad") as null|num
	if(isnum(new_input) && CanInteract(user,GLOB.physical_state))
		set_pin_data(IC_OUTPUT, 1, new_input)
		push_data()
		activate_pin(1)

/obj/item/integrated_circuit/input/textpad
	name = "text pad"
	desc = "This small text pad allows someone to input a string into the system."
	icon_state = "textpad"
	complexity = 2
	can_be_asked_input = 1
	inputs = list()
	outputs = list("\<TEXT\> string entered")
	activators = list("\<PULSE OUT\> on entered")
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 4

/obj/item/integrated_circuit/input/textpad/ask_for_input(mob/user)
	var/new_input = input(user, "Enter some words, please.","Number pad") as null|text
	if(istext(new_input) && CanInteract(user,GLOB.physical_state))
		set_pin_data(IC_OUTPUT, 1, new_input)
		push_data()
		activate_pin(1)

/obj/item/integrated_circuit/input/med_scanner
	name = "integrated medical analyser"
	desc = "A very small version of the common medical analyser.  This allows the machine to know how healthy someone is."
	icon_state = "medscan"
	complexity = 4
	inputs = list("\<REF\> target")
	outputs = list("\<NUM\> total health %", "\<NUM\> total missing health")
	activators = list("\<PULSE IN\> scan", "\<PULSE OUT\> on scanned")
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2, TECH_BIO = 2)
	power_draw_per_use = 40

/obj/item/integrated_circuit/input/med_scanner/do_work()
	var/mob/living/carbon/human/H = get_pin_data_as_type(IC_INPUT, 1, /mob/living/carbon/human)
	if(!istype(H)) //Invalid input
		return
	if(H.Adjacent(get_turf(src))) // Like normal analysers, it can't be used at range.
		var/total_health = round(H.health/H.getMaxHealth(), 0.1)*100
		var/missing_health = H.getMaxHealth() - H.health

		set_pin_data(IC_OUTPUT, 1, total_health)
		set_pin_data(IC_OUTPUT, 2, missing_health)

	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/input/adv_med_scanner
	name = "integrated advanced medical analyser"
	desc = "A very small version of the common medical analyser.  This allows the machine to know how healthy someone is.  \
	This type is much more precise, allowing the machine to know much more about the target than a normal analyzer."
	icon_state = "medscan_adv"
	complexity = 12
	inputs = list("\<REF\> target")
	outputs = list(
		"\<NUM\> total health %",
		"\<NUM\> total missing health",
		"\<NUM\> brute damage",
		"\<NUM\> burn damage",
		"\<NUM\> tox damage",
		"\<NUM\> oxy damage",
		"\<NUM\> clone damage"
	)
	activators = list("\<PULSE IN\> scan", "\<PULSE OUT\> on scanned")
	spawn_flags = IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 3, TECH_DATA = 3, TECH_BIO = 4)
	power_draw_per_use = 80

/obj/item/integrated_circuit/input/adv_med_scanner/do_work()
	var/mob/living/carbon/human/H = get_pin_data_as_type(IC_INPUT, 1, /mob/living/carbon/human)
	if(!istype(H)) //Invalid input
		return
	if(H.Adjacent(get_turf(src))) // Like normal analysers, it can't be used at range.
		var/total_health = round(H.health/H.getMaxHealth(), 0.1)*100
		var/missing_health = H.getMaxHealth() - H.health

		set_pin_data(IC_OUTPUT, 1, total_health)
		set_pin_data(IC_OUTPUT, 2, missing_health)
		set_pin_data(IC_OUTPUT, 3, H.getBruteLoss())
		set_pin_data(IC_OUTPUT, 4, H.getFireLoss())
		set_pin_data(IC_OUTPUT, 5, H.getToxLoss())
		set_pin_data(IC_OUTPUT, 6, H.getOxyLoss())
		set_pin_data(IC_OUTPUT, 7, H.getCloneLoss())

	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/input/local_locator
	name = "local locator"
	desc = "This is needed for certain devices that demand a reference for a target to act upon.  This type only locates something \
	that is holding the machine containing it."
	inputs = list()
	outputs = list("located ref")
	activators = list("locate")
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 20

/obj/item/integrated_circuit/input/local_locator/do_work()
	var/datum/integrated_io/O = outputs[1]
	O.data = null
	if(assembly)
		if(istype(assembly.loc, /mob/living)) // Now check if someone's holding us.
			O.data = WEAKREF(assembly.loc)

	O.push_data()

/obj/item/integrated_circuit/input/adjacent_locator
	name = "adjacent locator"
	desc = "This is needed for certain devices that demand a reference for a target to act upon.  This type only locates something \
	that is standing a meter away from the machine."
	extended_desc = "The first pin requires a ref to a kind of object that you want the locator to acquire.  This means that it will \
	give refs to nearby objects that are similar.  If more than one valid object is found nearby, it will choose one of them at \
	random."
	inputs = list("desired type ref")
	outputs = list("located ref")
	activators = list("locate")
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 30

/obj/item/integrated_circuit/input/adjacent_locator/do_work()
	var/datum/integrated_io/I = inputs[1]
	var/datum/integrated_io/O = outputs[1]
	O.data = null

	if(!isweakref(I.data))
		return
	var/atom/A = I.data.resolve()
	if(!A)
		return
	var/desired_type = A.type

	var/list/nearby_things = range(1, get_turf(src))
	var/list/valid_things = list()
	for(var/atom/thing in nearby_things)
		if(thing.type != desired_type)
			continue
		valid_things.Add(thing)
	if(valid_things.len)
		O.data = WEAKREF(pick(valid_things))
	O.push_data()

/obj/item/integrated_circuit/input/signaler
	name = "integrated signaler"
	desc = "Signals from a signaler can be received with this, allowing for remote control.  Additionally, it can send signals as well."
	extended_desc = "When a signal is received from another signaler, the 'on signal received' activator pin will be pulsed.  \
	The two input pins are to configure the integrated signaler's settings.  Note that the frequency should not have a decimal in it.  \
	Meaning the default frequency is expressed as 1457, not 145.7.  To send a signal, pulse the 'send signal' activator pin."
	icon_state = "signal"
	complexity = 4
	inputs = list("\<NUM\> frequency","\<NUM\> code")
	outputs = list()
	activators = list("\<PULSE IN\> send signal","\<PULSE OUT\> on signal sent", "\<PULSE OUT\> on signal received")
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2, TECH_MAGNET = 2)
	power_draw_idle = 5
	power_draw_per_use = 40

	var/frequency = 1457
	var/code = 30
	var/datum/radio_frequency/radio_connection

/obj/item/integrated_circuit/input/signaler/Initialize()
	. = ..()
	set_frequency(frequency)
	// Set the pins so when someone sees them, they won't show as null
	set_pin_data(IC_INPUT, 1, frequency)
	set_pin_data(IC_INPUT, 2, code)

/obj/item/integrated_circuit/input/signaler/Destroy()
	SSradio.remove_object(src,frequency)
	frequency = 0
	. = ..()

/obj/item/integrated_circuit/input/signaler/on_data_written()
	var/new_freq = get_pin_data(IC_INPUT, 1)
	var/new_code = get_pin_data(IC_INPUT, 2)
	if(isnum(new_freq) && new_freq > 0)
		set_frequency(new_freq)
	if(isnum(new_code))
		code = new_code


/obj/item/integrated_circuit/input/signaler/do_work() // Sends a signal.
	if(!radio_connection)
		return

	var/datum/signal/signal = new()
	signal.source = src
	signal.encryption = code
	signal.data["message"] = "ACTIVATE"
	radio_connection.post_signal(src, signal)
	activate_pin(2)

/obj/item/integrated_circuit/input/signaler/proc/set_frequency(new_frequency)
	if(!frequency)
		return
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_CHAT)

/obj/item/integrated_circuit/input/signaler/receive_signal(datum/signal/signal)
	var/new_code = get_pin_data(IC_INPUT, 2)
	var/code = 0

	if(isnum(new_code))
		code = new_code
	if(!signal)
		return 0
	if(signal.encryption != code)
		return 0
	if(signal.source == src) // Don't trigger ourselves.
		return 0

	activate_pin(3)

	var/turf/location = get_turf(src)
	if(!location)
		return

	for(var/mob/O in hearers(1, location))
		O.show_message("\icon[src] *beep* *beep*", 3, "*beep* *beep*", 2)

/obj/item/integrated_circuit/input/EPv2
	name = "\improper EPv2 circuit"
	desc = "Enables the sending and receiving of messages on the Exonet with the EPv2 protocol."
	extended_desc = "An EPv2 address is a string with the format of XXXX:XXXX:XXXX:XXXX.  Data can be send or received using the \
	second pin on each side, with additonal data reserved for the third pin.  When a message is received, the second activaiton pin \
	will pulse whatever's connected to it.  Pulsing the first activation pin will send a message."
	icon_state = "signal"
	complexity = 4
	inputs = list("\<TEXT\> target EPv2 address", "\<TEXT\> data to send", "\<TEXT\> secondary text")
	outputs = list("\<TEXT\> address received", "\<TEXT\> data received", "\<TEXT\> secondary text received")
	activators = list("\<PULSE IN\> send data", "\<PULSE OUT\> on data received")
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2, TECH_MAGNET = 2, TECH_BLUESPACE = 2)
	power_draw_per_use = 50
	var/datum/exonet_protocol/exonet = null


/*  !!!!Remove when the communicators are ported!!!



/obj/item/integrated_circuit/input/EPv2/New()
	..()
	exonet = new(src)
	exonet.make_address("EPv2_circuit-\ref[src]")
	desc += "<br>This circuit's EPv2 address is: [exonet.address]"

/obj/item/integrated_circuit/input/EPv2/Destroy()
	if(exonet)
		exonet.remove_address()
		qdel(exonet)
		exonet = null
	return ..()

/obj/item/integrated_circuit/input/EPv2/do_work()
	var/target_address = get_pin_data(IC_INPUT, 1)
	var/message = get_pin_data(IC_INPUT, 2)
	var/text = get_pin_data(IC_INPUT, 3)

	if(target_address && istext(target_address))
		exonet.send_message(target_address, message, text)

/obj/item/integrated_circuit/input/receive_exonet_message(var/atom/origin_atom, var/origin_address, var/message, var/text)
	set_pin_data(IC_OUTPUT, 1, origin_address)
	set_pin_data(IC_OUTPUT, 2, message)
	set_pin_data(IC_OUTPUT, 3, text)

	push_data()
	activate_pin(2)
*/
//This circuit gives information on where the machine is.
/obj/item/integrated_circuit/input/gps
	name = "global positioning system"
	desc = "This allows you to easily know the position of a machine containing this device."
	extended_desc = "The GPS's coordinates it gives is absolute, not relative."
	icon_state = "gps"
	complexity = 4
	inputs = list()
	outputs = list("\<NUM\> X", "\<NUM\> Y")
	activators = list("\<PULSE IN\> get coordinates", "\<PULSE OUT\> on get coordinates")
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 30

/obj/item/integrated_circuit/input/gps/do_work()
	var/turf/T = get_turf(src)

	set_pin_data(IC_OUTPUT, 1, null)
	set_pin_data(IC_OUTPUT, 2, null)
	if(!T)
		return

	set_pin_data(IC_OUTPUT, 1, T.x)
	set_pin_data(IC_OUTPUT, 2, T.y)

	push_data()
	activate_pin(2)


/obj/item/integrated_circuit/input/microphone
	name = "microphone"
	desc = "Useful for spying on people or for voice activated machines."
	extended_desc = "This will automatically translate most languages it hears to Galactic Common.  \
	The first activation pin is always pulsed when the circuit hears someone talk, while the second one \
	is only triggered if it hears someone speaking a language other than Galactic Common."
	icon_state = "recorder"
	complexity = 8
	inputs = list()
	outputs = list("\<TEXT\> speaker", "\<TEXT\> message")
	activators = list("\<PULSE OUT\> on message received", "\<PULSE OUT\> on translation")
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 15

/obj/item/integrated_circuit/input/microphone/New()
	..()
	add_hearing()

/obj/item/integrated_circuit/input/microphone/Destroy()
	remove_hearing()
	return ..()

/obj/item/integrated_circuit/input/microphone/hear_talk(mob/living/M, msg, var/verb="says", datum/language/speaking=null, speech_volume)
	var/translated = FALSE
	if(M && msg)
		if(speaking)
			if(!speaking.machine_understands)
				msg = speaking.scramble(msg)
			if(!istype(speaking, /datum/language/common))
				translated = TRUE
		set_pin_data(IC_OUTPUT, 1, M.GetVoice())
		set_pin_data(IC_OUTPUT, 2, msg)

	push_data()
	activate_pin(1)
	if(translated)
		activate_pin(2)



/obj/item/integrated_circuit/input/sensor
	name = "sensor"
	desc = "Scans and obtains a reference for any objects or persons near you.  All you need to do is shove the machine in their face."
	extended_desc = "If 'ignore storage' pin is set to 1, the sensor will disregard scanning various storage containers such as backpacks."
	icon_state = "recorder"
	complexity = 12
	inputs = list("\<NUM\> ignore storage" = 1)
	outputs = list("\<REF\> scanned")
	activators = list("\<PULSE OUT\> on scanned")
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 120

/obj/item/integrated_circuit/input/sensor/proc/scan(var/atom/A)
	var/ignore_bags = get_pin_data(IC_INPUT, 1)
	if(ignore_bags)
		if(istype(A, /obj/item/weapon/storage))
			return FALSE

	set_pin_data(IC_OUTPUT, 1, WEAKREF(A))
	push_data()
	activate_pin(1)
	return TRUE

/obj/item/integrated_circuit/output
	category_text = "Output"

/obj/item/integrated_circuit/output/screen
	name = "small screen"
	desc = "This small screen can display a single piece of data, when the machine is examined closely."
	icon_state = "screen"
	inputs = list("\<TEXT/NUM\> displayed data")
	outputs = list()
	activators = list("\<PULSE IN\> load data")
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 10
	autopulse = 1
	var/stuff_to_display = null


/obj/item/integrated_circuit/output/screen/disconnect_all()
	..()
	stuff_to_display = null

/obj/item/integrated_circuit/output/screen/any_examine(mob/user)
	to_chat(user, "There is a little screen labeled '[name]', which displays [stuff_to_display ? "'[stuff_to_display]'" : "nothing"].")

/obj/item/integrated_circuit/output/screen/do_work()
	var/datum/integrated_io/I = inputs[1]
	if(isweakref(I.data))
		var/datum/d = I.data_as_type(/datum)
		if(d)
			stuff_to_display = "[d]"
	else
		stuff_to_display = I.data

/obj/item/integrated_circuit/output/screen/medium
	name = "screen"
	desc = "This screen allows for people holding the device to see a piece of data."
	icon_state = "screen_medium"
	power_draw_per_use = 20

/obj/item/integrated_circuit/output/screen/medium/do_work()
	..()
	var/list/nearby_things = range(0, get_turf(src))
	for(var/mob/M in nearby_things)
		var/obj/O = assembly ? assembly : src
		to_chat(M, SPAN_NOTICE("\icon[O] [stuff_to_display]"))

/obj/item/integrated_circuit/output/screen/large
	name = "large screen"
	desc = "This screen allows for people able to see the device to see a piece of data."
	icon_state = "screen_large"
	power_draw_per_use = 40

/obj/item/integrated_circuit/output/screen/large/do_work()
	..()
	var/obj/O = assembly ? loc : assembly
	O.visible_message(SPAN_NOTICE("\icon[O] [stuff_to_display]"))

/obj/item/integrated_circuit/output/light
	name = "light"
	desc = "This light can turn on and off on command."
	icon_state = "light"
	complexity = 4
	inputs = list()
	outputs = list()
	activators = list("\<PULSE IN\> toggle light")
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/light_toggled = 0
	var/light_brightness = 3
	var/light_rgb = "#FFFFFF"
	power_draw_idle = 0 // Adjusted based on brightness.

/obj/item/integrated_circuit/output/light/do_work()
	light_toggled = !light_toggled
	update_lighting()

/obj/item/integrated_circuit/output/light/proc/update_lighting()
	if(light_toggled)
		set_light(l_range = light_brightness, l_power = light_brightness, l_color = light_rgb)
	else
		set_light(0)
	power_draw_idle = light_toggled ? light_brightness * 2 : 0

/obj/item/integrated_circuit/output/light/advanced/update_lighting()
	var/R = get_pin_data(IC_INPUT, 1)
	var/G = get_pin_data(IC_INPUT, 2)
	var/B = get_pin_data(IC_INPUT, 3)
	var/brightness = get_pin_data(IC_INPUT, 4)

	if(isnum(R) && isnum(G) && isnum(B) && isnum(brightness))
		R = CLAMP(R, 0, 255)
		G = CLAMP(G, 0, 255)
		B = CLAMP(B, 0, 255)
		brightness = CLAMP(brightness, 0, 6)
		light_rgb = rgb(R, G, B)
		light_brightness = brightness

	..()

/obj/item/integrated_circuit/output/light/power_fail() // Turns off the flashlight if there's no power left.
	light_toggled = FALSE
	update_lighting()

/obj/item/integrated_circuit/output/light/advanced
	name = "advanced light"
	desc = "This light can turn on and off on command, in any color, and in various brightness levels."
	icon_state = "light_adv"
	complexity = 8
	inputs = list(
		"\<NUM\> R",
		"\<NUM\> G",
		"\<NUM\> B",
		"\<NUM\> Brightness"
	)
	outputs = list()
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 3, TECH_DATA = 3)

/obj/item/integrated_circuit/output/light/advanced/on_data_written()
	update_lighting()

/obj/item/integrated_circuit/output/sound
	name = "speaker circuit"
	desc = "A miniature speaker is attached to this component."
	icon_state = "speaker"
	complexity = 8
	cooldown_per_use = 4 SECONDS
	inputs = list(
		"\<TEXT\> sound ID",
		"\<NUM\> volume",
		"\<NUM\> frequency"
	)
	outputs = list()
	activators = list("play sound")
	power_draw_per_use = 20
	var/list/sounds = list()

/obj/item/integrated_circuit/output/text_to_speech
	name = "text-to-speech circuit"
	desc = "A miniature speaker is attached to this component."
	extended_desc = "This unit is more advanced than the plain speaker circuit, able to transpose any valid text to speech."
	icon_state = "speaker"
	complexity = 12
	cooldown_per_use = 4 SECONDS
	inputs = list("text")
	outputs = list()
	activators = list("to speech")
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 60

/obj/item/integrated_circuit/output/text_to_speech/do_work()
	var/datum/integrated_io/text = inputs[1]
	if(istext(text.data))
		var/obj/O = assembly ? loc : assembly
		audible_message("\icon[O] \The [O.name] states, \"[text.data]\"")

/obj/item/integrated_circuit/output/sound/New()
	..()
	extended_desc = list()
	extended_desc += "The first input pin determines which sound is used. The choices are; "
	extended_desc += jointext(sounds, ", ")
	extended_desc += ". The second pin determines the volume of sound that is played"
	extended_desc += ", and the third determines if the frequency of the sound will vary with each activation."
	extended_desc = jointext(extended_desc, null)

/obj/item/integrated_circuit/output/sound/do_work()
	var/datum/integrated_io/ID = inputs[1]
	var/datum/integrated_io/vol = inputs[2]
	var/datum/integrated_io/frequency = inputs[3]
	if(istext(ID.data) && isnum(vol.data) && isnum(frequency.data))
		var/selected_sound = sounds[ID.data]
		if(!selected_sound)
			return
		vol.data = CLAMP(vol.data, 0, 100)
		frequency.data = round(CLAMP(frequency.data, 0, 1))
		playsound(get_turf(src), selected_sound, vol.data, frequency.data, -1)

/obj/item/integrated_circuit/output/sound/beeper
	name = "beeper circuit"
	desc = "A miniature speaker is attached to this component.  This is often used in the construction of motherboards, which use \
	the speaker to tell the user if something goes very wrong when booting up.  It can also do other similar synthetic sounds such \
	as buzzing, pinging, chiming, and more."
	sounds = list(
		"beep"			= 'sound/machines/twobeep.ogg',
		"chime"			= 'sound/machines/chime.ogg',
		"buzz sigh"		= 'sound/machines/buzz-sigh.ogg',
		"buzz twice"	= 'sound/machines/buzz-two.ogg',
		"ping"			= 'sound/machines/ping.ogg',
		"synth yes"		= 'sound/machines/synth_yes.ogg',
		"synth no"		= 'sound/machines/synth_no.ogg',
		"warning buzz"	= 'sound/machines/warning-buzzer.ogg'
		)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/output/sound/beepsky
	name = "securitron sound circuit"
	desc = "A miniature speaker is attached to this component.  Considered by some to be the essential component for a securitron."
	sounds = list(
		"creep"			= 'sound/voice/bcreep.ogg',
		"criminal"		= 'sound/voice/bcriminal.ogg',
		"freeze"		= 'sound/voice/bfreeze.ogg',
		"god"			= 'sound/voice/bgod.ogg',
		"i am the law"	= 'sound/voice/biamthelaw.ogg',
		"insult"		= 'sound/voice/binsult.ogg',
		"radio"			= 'sound/voice/bradio.ogg',
		"secure day"	= 'sound/voice/bsecureday.ogg',
		)
	spawn_flags = IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2, TECH_COVERT = 1)

/obj/item/integrated_circuit/output/video_camera
	name = "video camera circuit"
	desc = "This small camera allows a remote viewer to see what it sees."
	extended_desc = "The camera is linked to the Research camera network."
	icon_state = "video_camera"
	w_class = ITEM_SIZE_SMALL
	complexity = 10
	inputs = list("camera name" = "video camera circuit", "camera active" = 0)
	outputs = list()
	activators = list()
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_idle = 5 // Raises to 80 when on.
	var/obj/machinery/camera/network/research/camera

/obj/item/integrated_circuit/output/video_camera/New()
	..()
	camera = new(src)
	on_data_written()

/obj/item/integrated_circuit/output/video_camera/Destroy()
	qdel_null(camera)
	return ..()

/obj/item/integrated_circuit/output/video_camera/proc/set_camera_status(var/status)
	if(camera)
		camera.set_status(status)
		power_draw_idle = camera.status ? 80 : 5
		if(camera.status) // Ensure that there's actually power.
			if(!draw_idle_power())
				power_fail()

/obj/item/integrated_circuit/output/video_camera/on_data_written()
	if(camera)
		var/datum/integrated_io/cam_name = inputs[1]
		var/datum/integrated_io/cam_active = inputs[2]
		if(istext(cam_name.data))
			camera.c_tag = cam_name.data
		if(isnum(cam_active.data))
			set_camera_status(cam_active.data)

/obj/item/integrated_circuit/output/video_camera/power_fail()
	if(camera)
		set_camera_status(0)
		var/datum/integrated_io/cam_active = inputs[2]
		cam_active.data = FALSE

/obj/item/integrated_circuit/output/led
	name = "light-emitting diode"
	desc = "This a LED that is lit whenever there is TRUE-equivalent data on its input."
	extended_desc = "TRUE-equivalent values are: Non-empty strings, non-zero numbers, and valid refs."
	complexity = 0.1
	icon_state = "led"
	inputs = list("lit")
	outputs = list()
	activators = list()
	power_draw_idle = 0 // Raises to 1 when lit.
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/led_color

/obj/item/integrated_circuit/output/led/on_data_written()
	power_draw_idle = get_pin_data(IC_INPUT, 1) ? 1 : 0

/obj/item/integrated_circuit/output/led/power_fail()
	set_pin_data(IC_INPUT, 1, FALSE)

/obj/item/integrated_circuit/output/led/any_examine(mob/user)
	var/text_output = list()
	var/initial_name = initial(name)

	// Doing all this work just to have a color-blind friendly output.
	text_output += "There is "
	if(name == initial_name)
		text_output += "\an [name]"
	else
		text_output += "\an ["\improper[initial_name]"] labeled '[name]'"
	text_output += " which is currently [get_pin_data(IC_INPUT, 1) ? "lit <font color=[led_color]>�</font>" : "unlit."]"
	user << jointext(text_output,null)

/obj/item/integrated_circuit/output/led/red
	name = "red LED"
	led_color = COLOR_RED

/obj/item/integrated_circuit/output/led/orange
	name = "orange LED"
	led_color = COLOR_ORANGE

/obj/item/integrated_circuit/output/led/yellow
	name = "yellow LED"
	led_color = COLOR_YELLOW

/obj/item/integrated_circuit/output/led/green
	name = "green LED"
	led_color = COLOR_GREEN

/obj/item/integrated_circuit/output/led/blue
	name = "blue LED"
	led_color = COLOR_BLUE

/obj/item/integrated_circuit/output/led/purple
	name = "purple LED"
	led_color = COLOR_PURPLE

/obj/item/integrated_circuit/output/led/cyan
	name = "cyan LED"
	led_color = COLOR_CYAN

/obj/item/integrated_circuit/output/led/white
	name = "white LED"
	led_color = COLOR_WHITE

/obj/item/integrated_circuit/output/led/pink
	name = "pink LED"
	led_color = COLOR_PINK

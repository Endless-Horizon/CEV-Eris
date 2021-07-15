#define AIRLOCK_CONTROL_RANGE 22

// This code allows for airlocks to be controlled externally by setting an id_tag and comm frequency (disables ID access)
/obj/machinery/door/airlock
	var/id_tag
	var/frequency
	var/shockedby = list()
	var/datum/radio_frequency/radio_connection
	var/cur_command = null	//the command the door is currently attempting to complete

/obj/machinery/door/airlock/Process()
	..()
	if(arePowerSystemsOn())
		execute_current_command()

/obj/machinery/door/airlock/receive_signal(datum/signal/signal)
	if(!arePowerSystemsOn()) return //no power

	if(!signal || signal.encryption) return

	if(id_tag != signal.data["tag"] || !signal.data["command"]) return

	cur_command = signal.data["command"]
	spawn()
		execute_current_command()

/obj/machinery/door/airlock/proc/execute_current_command()
	if(operating)
		return //emagged or busy doing something else

	if(!cur_command)
		return

	do_command(cur_command)
	if(command_completed(cur_command))
		cur_command = null

/obj/machinery/door/airlock/proc/do_command(var/command)
	switch(command)
		if("open")
			open()

		if("close")
			close()

		if("unlock")
			unlock()

		if("lock")
			lock()

		if("secure_open")
			unlock()

			sleep(2)
			open()

			lock()

		if("secure_close")
			unlock()
			close()

			lock()
			sleep(2)

	send_status()

/obj/machinery/door/airlock/proc/command_completed(var/command)
	switch(command)
		if("open")
			return !density

		if("close")
			return density

		if("unlock")
			return !locked

		if("lock")
			return locked

		if("secure_open")
			return (locked && !density)

		if("secure_close")
			return (locked && density)

	return 1	//Unknown command. Just assume it's completed.

/obj/machinery/door/airlock/proc/send_status(var/bumped = 0)
	if(radio_connection)
		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.data["tag"] = id_tag
		signal.data["timestamp"] = world.time

		signal.data["door_status"] = density?("closed"):("open")
		signal.data["lock_status"] = locked?("locked"):("unlocked")

		if (bumped)
			signal.data["bumped_with_access"] = 1

		radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)


/obj/machinery/door/airlock/open(surpress_send)
	. = ..()
	if(!surpress_send) send_status()


/obj/machinery/door/airlock/close(surpress_send)
	. = ..()
	if(!surpress_send) send_status()


/obj/machinery/door/airlock/Bumped(atom/AM)
	..(AM)
	if(istype(AM, /mob/living/exosuit))
		var/mob/living/exosuit/exosuit = AM
		if(density && radio_connection && exosuit.pilots && (allowed(exosuit.pilots[1]) || check_access_list(exosuit.saved_access)))
			send_status(1)
	return

/obj/machinery/door/airlock/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	if(new_frequency)
		frequency = new_frequency
		radio_connection = SSradio.add_object(src, frequency, RADIO_AIRLOCK)


/obj/machinery/door/airlock/Initialize()
	. = ..()
	if(frequency)
		set_frequency(frequency)

	//wireless connection
	if(_wifi_id)
		wifi_receiver = new(_wifi_id, src)

	update_icon()

/obj/machinery/door/airlock/New()
	..()

	set_frequency(frequency)

/obj/machinery/door/airlock/Destroy()
	if(frequency)
		SSradio.remove_object(src,frequency)
	. = ..()

/obj/machinery/airlock_sensor
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_sensor_off"
	name = "airlock sensor"

	anchored = TRUE
	power_channel = STATIC_ENVIRON

	var/id_tag
	var/master_tag
	var/frequency = 1379
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = TRUE
	var/alert = 0
	var/previousPressure

/obj/machinery/airlock_sensor/on_update_icon()
	if(on)
		if(alert)
			SetIconState("airlock_sensor_alert")
		else
			SetIconState("airlock_sensor_standby")
	else
		SetIconState("airlock_sensor_off")

/obj/machinery/airlock_sensor/attack_hand(mob/user)
	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.data["tag"] = master_tag
	signal.data["command"] = command

	radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)
	flicker("airlock_sensor_cycle")

/obj/machinery/airlock_sensor/Process()
	if(on)
		var/datum/gas_mixture/air_sample = return_air()
		var/pressure = round(air_sample.return_pressure(),0.1)

		if(abs(pressure - previousPressure) > 0.001 || previousPressure == null)
			var/datum/signal/signal = new
			signal.transmission_method = 1 //radio signal
			signal.data["tag"] = id_tag
			signal.data["timestamp"] = world.time
			signal.data["pressure"] = num2text(pressure)

			radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)

			previousPressure = pressure

			alert = (pressure < ONE_ATMOSPHERE*0.8)

			update_icon()

/obj/machinery/airlock_sensor/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_AIRLOCK)

/obj/machinery/airlock_sensor/Initialize()
	. = ..()
	set_frequency(frequency)

/obj/machinery/airlock_sensor/New()
	..()
	set_frequency(frequency)

/obj/machinery/airlock_sensor/Destroy()
	SSradio.remove_object(src,frequency)
	. = ..()

/obj/machinery/airlock_sensor/airlock_interior
	command = "cycle_interior"

/obj/machinery/airlock_sensor/airlock_exterior
	command = "cycle_exterior"


/*
	Shuttle exterior sensors.
*/

/*
	These should be placed onto the same tile as a shuttle exterior door, one for each cycling airlock setup.
	They should obviously be visually offset onto a wall using pixel_x/y

	They need a sensor direction which should be edited onto the instance when mapping in

	When asked to return atmosphere, these sensors will move their search up to 3 tiles in the specified direction
	Until they find a nondense tile which doesn't contain a closed door - ie, is clear and walkable.
	Then they return air from that tile.

	This sensor will never return air from its own tile, even if the external door is open. It will always move at least one step out
*/

/obj/machinery/airlock_sensor/shuttle_exterior
	var/sensor_dir = NORTH
	/*
	1 = NORTH
	2 = SOUTH
	4 = EAST
	8 = WEST
	*/
	var/max_steps = 3

//Checks for walls and closed airlocks blocking the tile. Ignores other dense objects
/obj/machinery/airlock_sensor/shuttle_exterior/proc/turf_open(var/turf/T)
	if (T.is_wall)
		return FALSE

	for (var/obj/machinery/door/D in T)
		if (D.density)
			return FALSE

	return TRUE

/obj/machinery/airlock_sensor/shuttle_exterior/return_air()
	var/turf/T = loc
	var/steps = 0
	while (steps <= max_steps)
		steps++
		var/turf/U = get_step(T, sensor_dir)

		//U could maybe be null if we're at the edge of a map boundary
		if (U)
			T = U
			//If T is open, grab air from there
			if (turf_open(T))
				return T.return_air()
		else
			break


	//If we get here, then either every tile in a line outside the airlock was blocked, or we're too close to a map edge
	//Either way, we failed to find a valid air sample. We'll return an empty one to avoid errors
	return new /datum/gas_mixture


/obj/machinery/access_button
	icon = 'icons/obj/airlock_machines.dmi'
	var/base_of_state = "access_button"
	icon_state = "access_button_standby"
	name = "access button"

	anchored = TRUE
	power_channel = STATIC_ENVIRON

	var/master_tag
	var/frequency = 1449
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = TRUE


/obj/machinery/access_button/on_update_icon()
	. = ..()
	SetIconState("[base_of_state]_[on?"standby":"off"]")

/obj/machinery/access_button/attackby(obj/item/I as obj, mob/user as mob)
	//Swiping ID on the access button
	if (istype(I, /obj/item/card/id) || istype(I, /obj/item/modular_computer))
		attack_hand(user)
		return
	..()

/obj/machinery/access_button/attack_hand(mob/user)
	playsound(loc, 'sound/machines/button.ogg', 100, 1)
	add_fingerprint(usr)
	if(!allowed(user))
		to_chat(user, SPAN_WARNING("Access Denied"))

	else if(radio_connection)
		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.data["tag"] = master_tag
		signal.data["command"] = command

		radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)
	flicker("access_button_cycle")


/obj/machinery/access_button/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_AIRLOCK)


/obj/machinery/access_button/Initialize()
	. = ..()
	set_frequency(frequency)


/obj/machinery/access_button/New()
	..()

	set_frequency(frequency)

/obj/machinery/access_button/Destroy()
	SSradio.remove_object(src, frequency)
	. = ..()

/obj/machinery/access_button/airlock_interior
	frequency = 1379
	command = "cycle_interior"

/obj/machinery/access_button/airlock_exterior
	frequency = 1379
	command = "cycle_exterior"

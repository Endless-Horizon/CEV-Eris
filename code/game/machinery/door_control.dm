/obj/machinery/button/remote
	name = "remote object control"
	desc = "It controls objects, remotely."
	icon_state = "doorctrl0"
	power_channel = ENVIRON
	var/desiredstate = 0
	var/exposedwires = 0
	var/wires = 3
	/*
	Bitflag,	1=checkID
				2=Network Access
	*/

	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/button/remote/attack_ai(mob/user as mob)
	if(wires & 2)
		return attack_hand(user)
	else
		to_chat(user, "Error, no route to host.")

/obj/machinery/button/remote/attackby(obj/item/weapon/W, mob/user as mob)
	return attack_hand(user)

/obj/machinery/button/remote/emag_act(var/remaining_charges, var/mob/user)
	if(req_access.len || req_one_access.len)
		req_access = list()
		req_one_access = list()
		playsound(src.loc, "sparks", 100, 1)
		return 1

/obj/machinery/button/remote/attack_hand(mob/user as mob)
	if(..())
		return 1

	if(!allowed(user) && (wires & 1))
		to_chat(user, SPAN_WARNING("Access Denied"))
		FLICK("doorctrl-denied",src)
		return

	use_power(5)
	icon_state = "doorctrl1"
	desiredstate = !desiredstate
	trigger(user)
	spawn(15)
		update_icon()

/obj/machinery/button/remote/proc/trigger()
	return

/obj/machinery/button/remote/power_change()
	..()
	update_icon()

/obj/machinery/button/remote/on_update_icon()
	if(stat & NOPOWER)
		icon_state = "doorctrl-p"
	else
		icon_state = "doorctrl0"

/*
	Airlock remote control
*/

// Bitmasks for door switches.
#define OPEN   0x1
#define IDSCAN 0x2
#define BOLTS  0x4
#define SHOCK  0x8
#define SAFE   0x10

/obj/machinery/button/remote/airlock
	name = "remote door-control"
	desc = "It controls doors, remotely."

	var/specialfunctions = 1
	/*
	Bitflag, 	1= open
				2= idscan,
				4= bolts
				8= shock
				16= door safties
	*/

/obj/machinery/button/remote/airlock/trigger()
	for(var/obj/machinery/door/airlock/D in GLOB.machines)
		if(D.id_tag == id)
			if(specialfunctions & OPEN)
				if(D.density)
					spawn(0)
						D.open()
						return
				else
					spawn(0)
						D.close()
						return
			if(desiredstate == 1)
				if(specialfunctions & IDSCAN)
					D.set_idscan(0)
				if(specialfunctions & BOLTS)
					D.lock()
				if(specialfunctions & SHOCK)
					D.electrify(-1)
				if(specialfunctions & SAFE)
					D.set_safeties(0)
			else
				if(specialfunctions & IDSCAN)
					D.set_idscan(1)
				if(specialfunctions & BOLTS)
					D.unlock()
				if(specialfunctions & SHOCK)
					D.electrify(0)
				if(specialfunctions & SAFE)
					D.set_safeties(1)

#undef OPEN
#undef IDSCAN
#undef BOLTS
#undef SHOCK
#undef SAFE

/*
	Blast door remote control
*/
/obj/machinery/button/remote/blast_door
	name = "remote blast door-control"
	desc = "It controls blast doors, remotely."

/obj/machinery/button/remote/blast_door/trigger()
	for(var/obj/machinery/door/blast/M in GLOB.machines)
		if(M.id == id)
			if(M.density)
				spawn(0)
					M.open()
					return
			else
				spawn(0)
					M.close()
					return


/obj/machinery/button/remote/blast_door/id_card
	name = "remote blast id card door-control"
	desc = "It controls blast doors, remotely. But need id_card with access to it."
	icon_state = "doorid0"

/obj/machinery/button/remote/blast_door/id_card/attackby(obj/item/weapon/W, mob/user as mob)
	if(istype(W, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/id_card = W
		if(has_access(req_access, list(), id_card.access))
			use_power(5)
			icon_state = "doorid1"
			desiredstate = !desiredstate
			trigger(user)
			spawn(15)
				update_icon()
		else
			to_chat(user, SPAN_WARNING("Access Denied"))
			FLICK("doorid-denied",src)
	else
		to_chat(user, SPAN_WARNING("You need a id card to operate."))
		FLICK("doorid-denied",src)

/obj/machinery/button/remote/blast_door/id_card/attack_hand(mob/user as mob)
	to_chat(user, SPAN_WARNING("You need a id card to operate."))
	FLICK("doorid-denied",src)

/obj/machinery/button/remote/blast_door/id_card/on_update_icon()
	if(stat & NOPOWER)
		icon_state = "doorid-p"
	else
		icon_state = "doorid0"

/*
	Emitter remote control
*/
/obj/machinery/button/remote/emitter
	name = "remote emitter control"
	desc = "It controls emitters, remotely."

/obj/machinery/button/remote/emitter/trigger(mob/user as mob)
	for(var/obj/machinery/power/emitter/E in GLOB.machines)
		if(E.id == id)
			spawn(0)
				E.activate(user)
				return

/*
	Mass driver remote control
*/
/obj/machinery/button/remote/driver
	name = "mass driver button"
	desc = "A remote control switch for a mass driver."
	icon_state = "launcher0"

/obj/machinery/button/remote/driver/trigger(mob/user as mob)
	active = 1
	update_icon()

	for(var/obj/machinery/door/blast/M in GLOB.machines)
		if(M.id == id)
			spawn(0)
				M.open()
				return

	sleep(20)

	for(var/obj/machinery/mass_driver/M in GLOB.machines)
		if(M.id == id)
			M.drive()

	sleep(50)

	for(var/obj/machinery/door/blast/M in GLOB.machines)
		if(M.id == id)
			spawn(0)
				M.close()
				return

	active = 0
	icon_state = "launcher0"
	update_icon()

	return

/obj/machinery/button/remote/driver/on_update_icon()
	if(active)
		icon_state = "launcher1"
	else if(stat & (NOPOWER))
		icon_state = "launcher-p"
	else
		icon_state = "launcher0"

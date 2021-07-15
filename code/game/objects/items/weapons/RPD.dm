//Contains the rapid piping device. Copied over largely from pipe_dispenser and RCD files.
/obj/item/rpd
	name = "rapid piping device"
	desc = "A device used to rapidly build pipes."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rpd" //By Toriate, according to Kurgis.
	opacity = 0
	density = FALSE
	anchored = FALSE
	flags = CONDUCT
	force = WEAPON_FORCE_PAINFUL
	throwforce = WEAPON_FORCE_PAINFUL
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_ENGINEERING = 2, TECH_MATERIAL = 2) //Redundant values that yer free ta' change later.
	matter = list(MATERIAL_STEEL = 10, MATERIAL_PLASMA = 2, MATERIAL_PLASTIC = 5) //Redundant values that yer free ta' change later.
	price_tag = 500 //Redundant values that yer free ta' change later.
	var/use_power_cost = 1.5
	var/obj/item/cell/cell
	var/suitable_cell = /obj/item/cell/medium
	var/wait = 0
	var/pipe_type = 0
	var/p_dir = 1

/obj/item/rpd/attack()
	return 0

/obj/item/rpd/proc/can_use(var/mob/user,var/turf/T)
	return (user.Adjacent(T) && user.get_active_hand() == src && !user.stat && !user.restrained())

/obj/item/rpd/MouseDrop(over_object)
	if((src.loc == usr) && istype(over_object, /obj/screen/inventory/hand) && eject_item(cell, usr))
		cell = null
	else
		return ..()

/obj/item/rpd/attackby(obj/item/C, mob/living/user, obj/item/I)
	if(istype(C, suitable_cell) && !cell && insert_item(C, user))
		src.cell = C
	return

/obj/item/rpd/proc/useCharge()
	//Use charge from the cell.
	if(!cell||!cell.checked_use(use_power_cost))
		return 0
	return 1

/obj/item/rpd/proc/deletePipe(var/turf/T)
	if(istype(T, /obj/item/pipe) || istype(T, /obj/item/pipe_meter))
		qdel(T)
		return 1
	return 0

/obj/item/rpd/attack_self(mob/user)
	//Open pipe dispenser window.
	.=..()
	if(.) return
	var/dat = {"
<b>Regular pipes:</b><BR>
<A href='?src=\ref[src];make=[PIPE_SIMPLE_STRAIGHT];dir=1'>Pipe</A><BR>
<A href='?src=\ref[src];make=[PIPE_SIMPLE_BENT];dir=5'>Bent Pipe</A><BR>
<A href='?src=\ref[src];make=[PIPE_MANIFOLD];dir=1'>Manifold</A><BR>
<A href='?src=\ref[src];make=[PIPE_MVALVE];dir=1'>Manual Valve</A><BR>
<A href='?src=\ref[src];make=[PIPE_CAP];dir=1'>Pipe Cap</A><BR>
<A href='?src=\ref[src];make=[PIPE_MANIFOLD4W];dir=1'>4-Way Manifold</A><BR>
<A href='?src=\ref[src];make=[PIPE_MTVALVE];dir=1'>Manual T-Valve</A><BR>
<A href='?src=\ref[src];make=[PIPE_MTVALVEM];dir=1'>Manual T-Valve - Mirrored</A><BR>
<A href='?src=\ref[src];make=[PIPE_UP];dir=1'>Upward Pipe</A><BR>
<A href='?src=\ref[src];make=[PIPE_DOWN];dir=1'>Downward Pipe</A><BR>
<b>Supply pipes:</b><BR>
<A href='?src=\ref[src];make=[PIPE_SUPPLY_STRAIGHT];dir=1'>Pipe</A><BR>
<A href='?src=\ref[src];make=[PIPE_SUPPLY_BENT];dir=5'>Bent Pipe</A><BR>
<A href='?src=\ref[src];make=[PIPE_SUPPLY_MANIFOLD];dir=1'>Manifold</A><BR>
<A href='?src=\ref[src];make=[PIPE_SUPPLY_CAP];dir=1'>Pipe Cap</A><BR>
<A href='?src=\ref[src];make=[PIPE_SUPPLY_MANIFOLD4W];dir=1'>4-Way Manifold</A><BR>
<A href='?src=\ref[src];make=[PIPE_SUPPLY_UP];dir=1'>Upward Pipe</A><BR>
<A href='?src=\ref[src];make=[PIPE_SUPPLY_DOWN];dir=1'>Downward Pipe</A><BR>
<b>Scrubbers pipes:</b><BR>
<A href='?src=\ref[src];make=[PIPE_SCRUBBERS_STRAIGHT];dir=1'>Pipe</A><BR>
<A href='?src=\ref[src];make=[PIPE_SCRUBBERS_BENT];dir=5'>Bent Pipe</A><BR>
<A href='?src=\ref[src];make=[PIPE_SCRUBBERS_MANIFOLD];dir=1'>Manifold</A><BR>
<A href='?src=\ref[src];make=[PIPE_SCRUBBERS_CAP];dir=1'>Pipe Cap</A><BR>
<A href='?src=\ref[src];make=[PIPE_SCRUBBERS_MANIFOLD4W];dir=1'>4-Way Manifold</A><BR>
<A href='?src=\ref[src];make=[PIPE_SCRUBBERS_UP];dir=1'>Upward Pipe</A><BR>
<A href='?src=\ref[src];make=[PIPE_SCRUBBERS_DOWN];dir=1'>Downward Pipe</A><BR>
<b>Devices:</b><BR>
<A href='?src=\ref[src];make=[PIPE_UNIVERSAL];dir=1'>Universal pipe adapter</A><BR>
<A href='?src=\ref[src];make=[PIPE_CONNECTOR];dir=1'>Connector</A><BR>
<A href='?src=\ref[src];make=[PIPE_UVENT];dir=1'>Unary Vent</A><BR>
<A href='?src=\ref[src];make=[PIPE_PUMP];dir=1'>Gas Pump</A><BR>
<A href='?src=\ref[src];make=[PIPE_PASSIVE_GATE];dir=1'>Pressure Regulator</A><BR>
<A href='?src=\ref[src];make=[PIPE_VOLUME_PUMP];dir=1'>High Power Gas Pump</A><BR>
<A href='?src=\ref[src];make=[PIPE_SCRUBBER];dir=1'>Scrubber</A><BR>
<A href='?src=\ref[src];makemeter=1;dir=0'>Meter</A><BR>
<A href='?src=\ref[src];make=[PIPE_GAS_FILTER];dir=1'>Gas Filter</A><BR>
<A href='?src=\ref[src];make=[PIPE_GAS_FILTER_M];dir=1'>Gas Filter - Mirrored</A><BR>
<A href='?src=\ref[src];make=[PIPE_GAS_MIXER];dir=1'>Gas Mixer</A><BR>
<A href='?src=\ref[src];make=[PIPE_GAS_MIXER_M];dir=1'>Gas Mixer - Mirrored</A><BR>
<A href='?src=\ref[src];make=[PIPE_GAS_MIXER_T];dir=1'>Gas Mixer - T</A><BR>
<A href='?src=\ref[src];make=[PIPE_OMNI_MIXER];dir=1'>Omni Gas Mixer</A><BR>
<A href='?src=\ref[src];make=[PIPE_OMNI_FILTER];dir=1'>Omni Gas Filter</A><BR>
<b>Heat exchange:</b><BR>
<A href='?src=\ref[src];make=[PIPE_HE_STRAIGHT];dir=1'>Pipe</A><BR>
<A href='?src=\ref[src];make=[PIPE_HE_BENT];dir=5'>Bent Pipe</A><BR>
<A href='?src=\ref[src];make=[PIPE_JUNCTION];dir=1'>Junction</A><BR>
<A href='?src=\ref[src];make=[PIPE_HEAT_EXCHANGE];dir=1'>Heat Exchanger</A><BR>
<b>Insulated pipes:</b><BR>
<A href='?src=\ref[src];make=[PIPE_INSULATED_STRAIGHT];dir=1'>Pipe</A><BR>
<A href='?src=\ref[src];make=[PIPE_INSULATED_BENT];dir=5'>Bent Pipe</A><BR>

"}
///// Z-Level stuff
//What number the make points to is in the define # at the top of construction.dm in same folder

	user << browse("<HEAD><TITLE>[src]</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	onclose(user, "pipedispenser")
	return

/obj/item/rpd/Topic(href, href_list)

	if(..())
		return
	if(href_list["make"])
		pipe_type = text2num(href_list["make"])
		p_dir = text2num(href_list["dir"])
	if(href_list["makemeter"])
		p_dir = text2num(href_list["dir"]) //If direction is 0, the pipe is pipe_meter.

/obj/item/rpd/afterattack(atom/A, mob/user, proximity)
	if(wait)
		return 0
	if(!proximity)
		return
	if(!can_use(user,A))
		return 0
	if(istype(get_area(A),/area/shuttle)||istype(get_area(A),/turf/space/transit))
		return 0
	if(!useCharge(user))
		to_chat(user, SPAN_WARNING("[src] battery is dead or missing."))
		return 0
	if(deletePipe(A))
		to_chat(user, SPAN_NOTICE("You put [A] back to [src]."))
		return
	if(!p_dir == 0) //If direction is 0, the pipe is pipe_meter, otherwise it's one of the pipes.
		if(!wait)
			var/obj/item/pipe/P = new (A, pipe_type=pipe_type, dir=p_dir)
			P.update()
			P.add_fingerprint(usr)
			wait = 1
			spawn(10)
				wait = 0
	if(!wait)
		new /obj/item/pipe_meter(A)
		wait = 1
		spawn(15)
			wait = 0
	return

/obj/item/rpd/borg
	spawn_tags = null


/obj/item/rpd/borg/useCharge(mob/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		return R.cell && R.cell.checked_use(use_power_cost*30) //Redundant power use multiplier.
	return ..()

/obj/item/rpd/borg/attackby()
	return

/obj/item/rpd/borg/can_use(var/mob/user,var/turf/T)
	return (user.Adjacent(T) && !user.stat)
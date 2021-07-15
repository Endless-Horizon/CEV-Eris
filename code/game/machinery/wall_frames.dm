/obj/item/frame
	name = "frame"
	desc = "Used for building machines."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire_bitem"
	flags = CONDUCT
	bad_type = /obj/item/frame
	var/build_machine_type
	var/build_floormachine_type
	var/refund_amt = 2
	var/refund_type = /obj/item/stack/material/steel
	var/reverse = 0 //if resulting object faces opposite its dir (like light fixtures)

/obj/item/frame/attackby(obj/item/I, mob/user)
	if(I.get_tool_type(user, QUALITY_BOLT_TURNING, src))
		if(I.use_tool(user, src, WORKTIME_FAST, QUALITY_BOLT_TURNING, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
			new refund_type( get_turf(src.loc), refund_amt)
			qdel(src)
			return
	..()

/obj/item/frame/proc/try_build(turf/on_wall)
	if(!build_machine_type)
		return

	if (get_dist(on_wall,usr)>1)
		return

	var/ndir
	if(reverse)
		ndir = get_dir(usr,on_wall)
	else
		ndir = get_dir(on_wall,usr)

	if (!(ndir in cardinal))
		return

	var/turf/loc = get_turf(usr)
	var/area/A = loc.loc
	if (!istype(loc, /turf/simulated/floor))
		to_chat(usr, SPAN_DANGER("\The [src] Alarm cannot be placed on this spot."))
		return
	if (A.requires_power == 0 || A.name == "Space")
		to_chat(usr, SPAN_DANGER("\The [src] Alarm cannot be placed in this area."))
		return

	if(gotwallitem(loc, ndir))
		to_chat(usr, SPAN_DANGER("There's already an item on this wall!"))
		return

	var/obj/machinery/M = new build_machine_type(loc, ndir, 1)
	M.fingerprints = src.fingerprints
	M.fingerprintshidden = src.fingerprintshidden
	M.fingerprintslast = src.fingerprintslast
	qdel(src)

/obj/item/frame/proc/try_floorbuild(turf/on_floor) // For build machines on floor
	if(!build_floormachine_type)
		return

	if (get_dist(on_floor,usr)>1)
		return

	var/ndir
	if(reverse)
		ndir = get_dir(usr,on_floor)
	else
		ndir = get_dir(on_floor,usr)

	if (!(ndir in cardinal))
		return

	var/turf/loc = get_turf(on_floor)
	//var/area/A = loc.loc
	/*if (!istype(loc, /turf/simulated/floor)) //TODO rework this
		to_chat(usr, SPAN_DANGER("\The [src] Alarm cannot be placed on this spot."))
		return
	if (A.requires_power == 0 || A.name == "Space")
		to_chat(usr, SPAN_DANGER("\The [src] Alarm cannot be placed in this area."))
		return*/

	if(gotflooritem(loc, ndir))
		to_chat(usr, SPAN_DANGER("There's already an item on this floor!"))
		return

	var/obj/machinery/M = new build_floormachine_type(loc, ndir, 1)
	M.fingerprints = src.fingerprints
	M.fingerprintshidden = src.fingerprintshidden
	M.fingerprintslast = src.fingerprintslast
	qdel(src)

/obj/item/frame/fire_alarm
	name = "fire alarm frame"
	desc = "Used for building fire alarms."
	icon_state = "fire_bitem"
	build_machine_type = /obj/machinery/firealarm

/obj/item/frame/air_alarm
	name = "air alarm frame"
	desc = "Used for building air alarms."
	icon_state = "alarm_bitem"
	build_machine_type = /obj/machinery/alarm

/obj/item/frame/light
	name = "light fixture frame"
	desc = "Used for building lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-item"
	build_machine_type = /obj/machinery/light_construct
	reverse = 1

/obj/item/frame/light/small
	name = "small light fixture frame"
	icon_state = "bulb-construct-item"
	refund_amt = 1
	build_machine_type = /obj/machinery/light_construct/small

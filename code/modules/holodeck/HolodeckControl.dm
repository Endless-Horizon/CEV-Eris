/obj/machinery/computer/HolodeckControl
	name = "holodeck control console"
	desc = "A computer used to control a nearby holodeck."
	icon_keyboard = "tech_key"
	icon_screen = "holocontrol"

	use_power = IDLE_POWER_USE
	active_power_usage = 8000 //8kW for the scenery + 500W per holoitem

	circuit = /obj/item/electronics/circuitboard/holodeckcontrol

	var/item_power_usage = 500

	var/area/linkedholodeck = null
	var/linkedholodeck_area
	var/active = 0
	var/list/holographic_objs = list()
	var/list/holographic_mobs = list()
	var/damaged = 0
	var/safety_disabled = 0
	var/mob/last_to_emag = null
	var/last_change = 0
	var/last_gravity_change = 0
	var/list/supported_programs
	var/list/restricted_programs

/obj/machinery/computer/HolodeckControl/New()
	..()
	linkedholodeck = locate(linkedholodeck_area)
	supported_programs = list()
	restricted_programs = list()

/obj/machinery/computer/HolodeckControl/attack_hand(var/mob/user as mob)
	if(..())
		return 1
	user.set_machine(src)
	var/dat

	dat += "<B>Holodeck Control System</B><BR>"
	dat += "<HR>Current Loaded Programs:<BR>"

	if(!linkedholodeck)
		dat += SPAN_DANGER("Warning: Unable to locate holodeck.<br>")
		user << browse(dat, "window=computer;size=400x500")
		onclose(user, "computer")
		return

	if(!supported_programs.len)
		dat += SPAN_DANGER("Warning: No supported holo-programs loaded.<br>")
		user << browse(dat, "window=computer;size=400x500")
		onclose(user, "computer")
		return

	for(var/prog in supported_programs)
		dat += "<A href='?src=\ref[src];program=[supported_programs[prog]]'>([prog])</A><BR>"

	dat += "<BR>"
	dat += "<A href='?src=\ref[src];program=turnoff'>(Turn Off)</A><BR>"

	dat += "<BR>"
	dat += "Please ensure that only holographic weapons are used in the holodeck if a combat simulation has been loaded.<BR>"

	if(issilicon(user))
		dat += "<BR>"
		if(safety_disabled)
			if (emagged)
				dat += "<font color=red><b>ERROR</b>: Cannot re-enable Safety Protocols.</font><BR>"
			else
				dat += "<A href='?src=\ref[src];AIoverride=1'>(<font color=green>Re-Enable Safety Protocols?</font>)</A><BR>"
		else
			dat += "<A href='?src=\ref[src];AIoverride=1'>(<font color=red>Override Safety Protocols?</font>)</A><BR>"

	dat += "<BR>"

	if(safety_disabled)
		for(var/prog in restricted_programs)
			dat += "<A href='?src=\ref[src];program=[restricted_programs[prog]]'>(<font color=red>Begin [prog]</font>)</A><BR>"
			dat += "Ensure the holodeck is empty before testing.<BR>"
			dat += "<BR>"
		dat += "Safety Protocols are <font color=red> DISABLED </font><BR>"
	else
		dat += "Safety Protocols are <font color=green> ENABLED </font><BR>"

	if(linkedholodeck.has_gravity)
		dat += "Gravity is <A href='?src=\ref[src];gravity=1'><font color=green>(ON)</font></A><BR>"
	else
		dat += "Gravity is <A href='?src=\ref[src];gravity=1'><font color=blue>(OFF)</font></A><BR>"

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/HolodeckControl/Topic(href, href_list)
	if(..())
		return 1

	usr.set_machine(src)

	if(href_list["program"])
		var/prog = href_list["program"]
		if(prog in holodeck_programs)
			loadProgram(holodeck_programs[prog])

	else if(href_list["AIoverride"])
		if(!issilicon(usr))
			return

		if(safety_disabled && emagged)
			return //if a traitor has gone through the trouble to emag the thing, let them keep it.

		safety_disabled = !safety_disabled
		update_projections()
		if(safety_disabled)
			message_admins("[key_name_admin(usr)] overrode the holodeck's safeties")
			log_game("[key_name(usr)] overrided the holodeck's safeties")
		else
			message_admins("[key_name_admin(usr)] restored the holodeck's safeties")
			log_game("[key_name(usr)] restored the holodeck's safeties")

	else if(href_list["gravity"])
		toggleGravity(linkedholodeck)

	src.updateUsrDialog()
	return

/obj/machinery/computer/HolodeckControl/emag_act(var/remaining_charges, var/mob/user as mob)
	playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
	last_to_emag = user //emag again to change the owner
	if (!emagged)
		emagged = 1
		safety_disabled = 1
		update_projections()
		to_chat(user, SPAN_NOTICE("You vastly increase projector power and override the safety and security protocols."))
		to_chat(user, "Warning.  Automatic shutoff and derezing protocols have been corrupted.  Please call [company_name] maintenance and do not use the simulator.")
		log_game("[key_name(usr)] emagged the Holodeck Control Computer")
		src.updateUsrDialog()
		return 1
	else
		..()

/obj/machinery/computer/HolodeckControl/proc/update_projections()
	if (safety_disabled)
		item_power_usage = 2500
		for(var/obj/item/holo/esword/H in linkedholodeck)
			H.damtype = BRUTE
	else
		item_power_usage = initial(item_power_usage)
		for(var/obj/item/holo/esword/H in linkedholodeck)
			H.damtype = initial(H.damtype)

	for(var/mob/living/simple_animal/hostile/carp/holodeck/C in holographic_mobs)
		C.set_safety(!safety_disabled)
		if (last_to_emag)
			C.friends = list(last_to_emag)

//This could all be done better, but it works for now.
/obj/machinery/computer/HolodeckControl/Destroy()
	emergencyShutdown()
	. = ..()

/obj/machinery/computer/HolodeckControl/ex_act(severity)
	emergencyShutdown()
	..()

/obj/machinery/computer/HolodeckControl/power_change()
	var/oldstat
	..()
	if (stat != oldstat && active && (stat & NOPOWER))
		emergencyShutdown()

/obj/machinery/computer/HolodeckControl/Process()
	for(var/item in holographic_objs) // do this first, to make sure people don't take items out when power is down.
		if(!(get_turf(item) in linkedholodeck))
			derez(item, 0)

	if (!safety_disabled)
		for(var/mob/living/simple_animal/hostile/carp/holodeck/C in holographic_mobs)
			if (get_area(C.loc) != linkedholodeck)
				holographic_mobs -= C
				C.derez()

	if(!..())
		return
	if(active)
		use_power(item_power_usage * (holographic_objs.len + holographic_mobs.len))

		if(!checkInteg(linkedholodeck))
			damaged = 1
			loadProgram(holodeck_programs["turnoff"], 0)
			active = 0
			use_power = IDLE_POWER_USE
			for(var/mob/M in range(10,src))
				M.show_message("The holodeck overloads!")


			for(var/turf/T in linkedholodeck)
				if(prob(30))
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(2, 1, T)
					s.start()
				T.ex_act(3)
				T.hotspot_expose(1000,500,1)

/obj/machinery/computer/HolodeckControl/proc/derez(var/obj/obj , var/silent = 1)
	holographic_objs.Remove(obj)

	if(obj == null)
		return

	if(isobj(obj))
		var/mob/M = obj.loc
		if(ismob(M))
			M.remove_from_mob(obj)
			M.update_icons()	//so their overlays update

	if(!silent)
		var/obj/oldobj = obj
		visible_message("The [oldobj.name] fades away!")
	qdel(obj)

/obj/machinery/computer/HolodeckControl/proc/checkInteg(var/area/A)
	for(var/turf/T in A)
		if(istype(T, /turf/space))
			return 0

	return 1

//Why is it called toggle if it doesn't toggle?
/obj/machinery/computer/HolodeckControl/proc/togglePower(var/toggleOn = 0)
	if(toggleOn)
		loadProgram(holodeck_programs["emptycourt"], 0)
	else
		loadProgram(holodeck_programs["turnoff"], 0)



		if(!linkedholodeck.has_gravity)
			linkedholodeck.has_gravity = TRUE
			linkedholodeck.update_gravity()

		active = 0
		use_power = IDLE_POWER_USE


/obj/machinery/computer/HolodeckControl/proc/loadProgram(var/datum/holodeck_program/HP, var/check_delay = 1)
	if(!HP)
		return
	var/area/A = locate(HP.target)
	if(!A)
		return

	if(check_delay)
		if(world.time < (last_change + 25))
			if(world.time < (last_change + 15))//To prevent super-spam clicking, reduced process size and annoyance -Sieve
				return
			for(var/mob/M in range(3,src))
				M.show_message("\b ERROR. Recalibrating projection apparatus.")
				last_change = world.time
				return

	last_change = world.time
	active = 1
	use_power = ACTIVE_POWER_USE

	for(var/item in holographic_objs)
		derez(item)

	for(var/mob/living/simple_animal/hostile/carp/holodeck/C in holographic_mobs)
		holographic_mobs -= C
		C.derez()

	for(var/obj/effect/decal/cleanable/blood/B in linkedholodeck)
		qdel(B)

	holographic_objs = A.copy_contents_to(linkedholodeck , 1)
	for(var/obj/holo_obj in holographic_objs)
		holo_obj.alpha *= 0.8 //give holodeck objs a slight transparency
		holo_obj.plane = 95 //This makes all objects load on the plane that Eris's 4th z-level uses for objects. This is not dynamic.

	if(HP.ambience)
		linkedholodeck.forced_ambience = HP.ambience
	else
		linkedholodeck.forced_ambience = list()

	for(var/mob/living/M in mobs_in_area(linkedholodeck))
		if(M.mind)
			linkedholodeck.play_ambience(M)

	spawn(30)
		for(var/obj/landmark/L in linkedholodeck)
			if(L.name=="Atmospheric Test Start")
				spawn(20)
					var/turf/T = get_turf(L)
					var/datum/effect/effect/system/spark_spread/s = new
					s.set_up(2, 1, T)
					s.start()
					if(T)
						T.temperature = 5000
						T.hotspot_expose(50000,50000,1)
			if(istype(L, /obj/landmark/mob/holocarpspawn))
				holographic_mobs += new /mob/living/simple_animal/hostile/carp/holodeck(L.loc)

			if(istype(L, /obj/landmark/mob/holocarprandom))
				if(prob(4)) //With 4 spawn points, carp should only appear 15% of the time.
					holographic_mobs += new /mob/living/simple_animal/hostile/carp/holodeck(L.loc)

		update_projections()


/obj/machinery/computer/HolodeckControl/proc/toggleGravity(var/area/A)
	if(world.time < (last_gravity_change + 25))
		if(world.time < (last_gravity_change + 15))//To prevent super-spam clicking
			return
		for(var/mob/M in range(3,src))
			M.show_message("\b ERROR. Recalibrating gravity field.")
			last_change = world.time
			return

	last_gravity_change = world.time
	active = 1
	use_power = IDLE_POWER_USE


	if(A.has_gravity)
		A.has_gravity = FALSE
	else
		A.has_gravity = TRUE
	linkedholodeck.update_gravity()

/obj/machinery/computer/HolodeckControl/proc/emergencyShutdown()
	//Turn it back to the regular non-holographic room
	loadProgram(holodeck_programs["turnoff"], 0)


	linkedholodeck.has_gravity = TRUE

	active = 0
	use_power = IDLE_POWER_USE

/obj/machinery/computer/HolodeckControl/Exodus
	linkedholodeck_area = /area/holodeck/alphadeck

/obj/machinery/computer/HolodeckControl/Exodus/New()
	..()
	supported_programs = list(
	"Empty Court" 		= "emptycourt",
	"Basketball Court" 	= "basketball",
	"Thunderdome Court"	= "thunderdomecourt",
	"Boxing Ring"		= "boxingcourt",
	"Beach" 			= "beach",
	"Desert" 			= "desert",
	"Space" 			= "space",
	"Picnic Area" 		= "picnicarea",
	"Snow Field" 		= "snowfield",
	"Theatre" 			= "theatre",
	"Meeting Hall" 		= "meetinghall",
	"Courtroom" 		= "courtroom"
	)

	restricted_programs = list(
	"Atmospheric Burn Simulation" = "burntest",
	"Wildlife Simulation" = "wildlifecarp"
	)

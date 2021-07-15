
/obj/machinery/mindswapper
	name = "experimental mind swapper"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "mindswap_off"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	// req_access = list(access_kitchen,access_morgue)
	circuit = /obj/item/electronics/circuitboard/mindswapper

	var/operating = FALSE  // Is it on?
	var/swap_time = 200  // Time from starting until minds are swapped
	var/swap_range = 1
	var/list/swap_blacklist = list(/mob/living/simple_animal/hostile/megafauna,
	                               /mob/living/simple_animal/cat/runtime)

	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 500

/obj/machinery/mindswapper/on_update_icon()
	if(stat & (NOPOWER|BROKEN))
		return
	if (operating)
		icon_state = "mindswap_on"
	else
		icon_state = "mindswap_off"

/obj/machinery/mindswapper/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(operating)
		to_chat(user, SPAN_DANGER("The mind swapping process has been launched, there is no going back now."))
		return
	else
		startswapping(user)

/obj/machinery/mindswapper/attackby(obj/item/I, mob/user)
	..()
	var/tool_type = I.get_tool_type(user, list(QUALITY_BOLT_TURNING), src)
	switch(tool_type)
		if(QUALITY_BOLT_TURNING)
			if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_VERY_EASY,  required_stat = STAT_MEC))
				anchored = anchored ? FALSE : TRUE

/obj/machinery/mindswapper/examine()
	..()
	to_chat(usr, "The safety is [emagged ? SPAN_DANGER("disabled") : "enabled"].")

/obj/machinery/mindswapper/emag_act(var/remaining_charges, var/mob/user)
	emagged = !emagged
	to_chat(user, SPAN_DANGER("You [emagged ? "disable" : "enable"] the mind swapper safety."))
	if(emagged)
		swap_time = 50
	else
		swap_time = 200
	return 1

/obj/machinery/mindswapper/proc/startswapping(mob/user as mob)
	if(operating)
		return

	use_power(1000)
	visible_message(SPAN_DANGER("You hear an increasingly loud humming coming from the mind swapper."))
	operating = TRUE
	update_icon()

	user.attack_log += "\[[time_stamp()]\] Triggered the mind swapper</b>"
	msg_admin_attack("[user.name] ([user.ckey]) triggered the mind swapper (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	addtimer(CALLBACK(src, .proc/performswapping), swap_time, TIMER_STOPPABLE)

/obj/machinery/mindswapper/proc/performswapping(mob/user as mob)
	operating = FALSE
	playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
	operating = FALSE

	// Get all candidates in range for the mind swapping
	var/list/swapBoddies = list()
	var/list/swapMinds = list()
	for(var/mob/living/M in range(swap_range,src))
		if (M.stat != DEAD && M.mob_classification != CLASSIFICATION_SYNTHETIC && !(M.type in swap_blacklist))  // candidates should not be dead
			swapBoddies += M
			swapMinds += M.ghostize(0)
	// Shuffle the list containing the candidates' boddies
	swapBoddies = shuffle(swapBoddies)

	// Perform the mind swapping
	var/i = 1
	for(var/mob/observer/ghost in swapMinds)
		ghost.mind.transfer_to(swapBoddies[i])
		if(ghost.key)
			var/mob/living/L = swapBoddies[i]
			if(istype(L))
				L.key = ghost.key	//have to transfer the key since the mind was not active
		qdel(ghost)
		i += 1

	// Knock out all candidates
	for(var/mob/living/M in swapBoddies)
		M.Stun(2)
		M.Weaken(10)

	visible_message(SPAN_DANGER("You hear a loud electrical crack before the mind swapper shuts down."))
	update_icon()

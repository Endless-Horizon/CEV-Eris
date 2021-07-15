/obj/machinery/slotmachine
	name = "slotmachine"
	desc = "Wasting your credits with style."
	icon = 'icons/obj/machines/slotmachine.dmi'
	icon_state = "slotmachine"
	density = TRUE
	anchored = TRUE
	var/spinning = FALSE
	var/bet = 0
	var/jackpot = 0
	var/plays = 0
	var/slots = list()
	var/variants = list("Diamond", "Heart", "Cherry","Bar","Lemon", "Watermelon", "Seven")
	var/weights = list("Diamond" = 10, "Heart" = 8, "Cherry" = 8,"Bar" = 6,"Lemon" = 4, "Watermelon" = 2, "Seven" = 1)
	var/icon_type
	use_power = TRUE
	idle_power_usage = 10

/obj/machinery/slotmachine/New()
	..()
	icon_type = initial(icon_state)
	power_change()

/obj/machinery/slotmachine/Initialize()
	. = ..()
	jackpot = rand(5000,20000);
	plays = rand(10,50)
	slots = list("1" = "Seven","2" = "Seven","3" = "Seven")
	update_icon()

/obj/machinery/slotmachine/power_change()
	..()
	if(stat & BROKEN)
		icon_state = "[icon_type]_broken"
	else
		if( !(stat & NOPOWER) )
			icon_state = icon_type
		else
			spawn(rand(0, 15))
				icon_state = "[icon_type]_off"

/obj/machinery/slotmachine/on_update_icon()
	cut_overlays()
	//From left to right
	var/offset = -6
	var/image/img
	for(var/slot in slots)
		img = new/image(icon, "slot_[slots[slot]]")
		img.pixel_x += offset
		add_overlays(img)
		offset += 6

/obj/machinery/slotmachine/proc/check_streak()
	var/win_slot = null
	for(var/slot in slots)
		if(win_slot == null)
			win_slot = slots[slot]
		else if (win_slot != slots[slot])
			return FALSE
	return TRUE

/obj/machinery/slotmachine/proc/set_spin_ovarlay()
	for(var/slot in slots)
		slots[slot] = "spin"
	update_icon()

/obj/machinery/slotmachine/proc/set_pull_overlay()
	icon_state = "[icon_type]_pull"
	update_icon()

/obj/machinery/slotmachine/proc/set_slots_overlay()
	var/last_slot = null
	for(var/slot in slots)
		sleep(10)
		if(prob(plays) && (last_slot != null))
			plays = 0
			slots[slot] = last_slot
		else
			slots[slot] = pick(variants)
			last_slot = slots[slot]
		icon_state = "[icon_type]"

		update_icon()

		src.visible_message(SPAN_NOTICE("The reel stops at... \the [slots[slot]]!"))

		playsound(src.loc, 'sound/machines/ping.ogg', 50, 1)

/obj/machinery/slotmachine/proc/check_win(mob/user)
	if(check_streak())
		playsound(src.loc, 'sound/machines/ping.ogg', 50, 1)
		var/weight = weights[slots["1"]]
		var/prize = bet * weight

		if (weight == "Seven")//cccccombo win, jackpot!
			prize = jackpot
			jackpot = 0
			src.visible_message("<b>[name]</b> states, \"Damn son! JACKPOT!!! Congratulations!\"")
		else//regular small win, jackpot increased
			src.visible_message("<b>[name]</b> states, \"Congratulations! You won [prize] Credits!\"")

		spawn_money(prize, src.loc, user)
		return TRUE
	else
		return FALSE

/obj/machinery/slotmachine/proc/pull_leaver(mob/user)
	sleep(5)
	if(!check_win(user))// if we have not won anything - jackpot or regular bet
		playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 1)
		src.visible_message("<b>[name]</b> states, \"Sorry, maybe, next time..\"")
		jackpot += bet

/obj/machinery/slotmachine/attack_hand(mob/user)
	if (spinning)
		to_chat(user, SPAN_WARNING("It is currently spinning."))
		return

	if (bet == 0)
		to_chat(user, SPAN_NOTICE("Today's jackpot: $[jackpot]. Insert 1-1000 Credits."))
	else
		spinning = TRUE
		plays++

		src.visible_message("<b>[name]</b> states, \"Your bet is $[bet]. Goodluck, buddy!\"")
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)

		set_spin_ovarlay()
		
		set_pull_overlay()

		set_slots_overlay()

		pull_leaver(user)

	src.add_fingerprint(user)
	update_icon()
	bet = 0
	spinning = FALSE

/obj/machinery/slotmachine/attackby(obj/item/S, mob/user)
	if (spinning)
		return

	if(default_deconstruction(S, user))
		return

	if (istype(S, /obj/item/spacecash))
		var/obj/item/spacecash/cash = S
		if ((cash.worth > 0) && (bet + cash.worth <= 1000))
			to_chat(user, SPAN_NOTICE("You insert [cash.worth] Credits into [src]."))
			bet += cash.worth
			user.drop_from_inventory(cash)
			qdel(cash)
		else
			to_chat(user, SPAN_WARNING("You must bet 1-[1000 - bet] Credits! Can't insert [cash.worth], that's too much."))

	else if (istype(S, /obj/item/coin))
		to_chat(user, SPAN_NOTICE("You add the [S.name] into the [src]. It will slightly increase chance to win."))
		user.drop_from_inventory(S)
		bet = 100
		plays += 10
		qdel(S)

	src.add_fingerprint(user)

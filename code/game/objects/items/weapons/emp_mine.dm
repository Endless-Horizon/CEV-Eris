/obj/item/emp_mine
	name = "OS Type - 183 \"Hei'an\""
	desc = "Self-rechargeable EMP Chinese mine. It still works, despite all the age."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "empmine0"
	w_class = ITEM_SIZE_BULKY

	var/armed = FALSE

	var/cooldown = 60 SECONDS
	var/trigger_range = 1

	var/emp_range = 5

	var/cooldown_timer = 0


/obj/item/emp_mine/proc/arm()
	if(armed)
		return

	armed = TRUE

	START_PROCESSING(SSobj, src)
	update_icon()


/obj/item/emp_mine/proc/disarm()
	if(!armed)
		return

	armed = FALSE

	STOP_PROCESSING(SSobj, src)
	update_icon()


/obj/item/emp_mine/on_update_icon()
	icon_state = "empmine[armed ? "1":"0"]"


/obj/item/emp_mine/Process()
	if(world.time - cooldown_timer > cooldown)
		var/turf/T = get_turf(src)
		if(!T)
			return

		for(var/mob/M in range(trigger_range, T))
			if(ishuman(M) || istype(M,/mob/living/silicon))
				cooldown_timer = world.time
				empulse(T, emp_range, emp_range, TRUE)
				break


/obj/item/emp_mine/attack_self(mob/user as mob)
	src.add_fingerprint(user)
	if(armed)
		disarm()
		to_chat(user, SPAN_NOTICE("You disarm \the [src]"))
	else
		cooldown_timer = world.time - cooldown + 100
		arm()
		to_chat(user, SPAN_WARNING("You arm \the [src]! You have 10 seconds to run away."))

//Pre-armed mine
/obj/item/emp_mine/armed/New()
	..()
	arm()

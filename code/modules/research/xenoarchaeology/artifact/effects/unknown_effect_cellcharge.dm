
//todo
/datum/artifact_effect/cellcharge
	effecttype = "cellcharge"
	effect_type = 3
	var/last_message

/datum/artifact_effect/cellcharge/DoEffectTouch(var/mob/user)
	if(user)
		if(isrobot(user))
			var/mob/living/silicon/robot/R = user
			for (var/obj/item/cell/large/D in R.contents)
				D.give(rand() * 100 + 50)
				to_chat(R, "\blue SYSTEM ALERT: Large energy boost detected!")
			return TRUE

/datum/artifact_effect/cellcharge/DoEffectAura()
	if(holder)
		var/turf/T = get_turf(holder)
		for (var/obj/machinery/power/apc/C in range(200, T))
			for (var/obj/item/cell/large/B in C.contents)
				B.give(25)
		for (var/obj/machinery/power/smes/S in range (effectrange,src))
			S.charge += 25
		for (var/mob/living/silicon/robot/M in range(50, T))
			for (var/obj/item/cell/large/D in M.contents)
				D.give(25)
				if(world.time - last_message > 200)
					to_chat(M, "\blue SYSTEM ALERT: Energy boost detected!")
					last_message = world.time
		return TRUE

/datum/artifact_effect/cellcharge/DoEffectPulse()
	if(holder)
		var/turf/T = get_turf(holder)
		for (var/obj/machinery/power/apc/C in range(200, T))
			for (var/obj/item/cell/large/B in C.contents)
				B.give(rand() * 100)
		for (var/obj/machinery/power/smes/S in range (effectrange,src))
			S.charge += 250
		for (var/mob/living/silicon/robot/M in range(100, T))
			for (var/obj/item/cell/large/D in M.contents)
				D.give(rand() * 100)
				if(world.time - last_message > 200)
					to_chat(M, "\blue SYSTEM ALERT: Energy boost detected!")
					last_message = world.time
		return TRUE

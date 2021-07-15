/obj/item/reagent_containers/borghypo
	name = "cyborg hypospray"
	desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	icon_state = "borghypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = null
	spawn_frequency = 0
	var/mode = 1
	var/charge_cost = 50
	var/charge_tick = 0
	var/recharge_time = 5 //Time it takes for shots to recharge (in seconds)

	var/list/reagent_ids = list("tricordrazine", "inaprovaline", "spaceacillin")
	var/list/reagent_volumes = list()
	var/list/reagent_names = list()

/obj/item/reagent_containers/borghypo/medical
	reagent_ids = list("bicaridine", "kelotane", "anti_toxin", "dexalin", "inaprovaline", "tramadol", "spaceacillin", "stoxin")

/obj/item/reagent_containers/borghypo/rescue
	reagent_ids = list("tricordrazine", "inaprovaline", "tramadol")

/obj/item/reagent_containers/borghypo/New()
	..()

	for(var/T in reagent_ids)
		reagent_volumes[T] = volume
		var/datum/reagent/R = GLOB.chemical_reagents_list[T]
		reagent_names += R.name

	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/borghypo/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/reagent_containers/borghypo/Process() //Every [recharge_time] seconds, recharge some reagents for the cyborg+
	if(++charge_tick < recharge_time)
		return FALSE
	charge_tick = 0

	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		if(R && R.cell)
			for(var/T in reagent_ids)
				if(reagent_volumes[T] < volume)
					R.cell.use(charge_cost)
					reagent_volumes[T] = min(reagent_volumes[T] + 5, volume)
	return TRUE

/obj/item/reagent_containers/borghypo/attack(var/mob/living/M, var/mob/user)
	if(!istype(M))
		return

	if(!reagent_volumes[reagent_ids[mode]])
		to_chat(user, SPAN_WARNING("The injector is empty."))
		return

	if (M.can_inject(user, 1))
		to_chat(user, SPAN_NOTICE("You inject [M] with the injector."))
		to_chat(M, SPAN_NOTICE("You feel a tiny prick!"))

		if(M.reagents)
			var/t = min(amount_per_transfer_from_this, reagent_volumes[reagent_ids[mode]])
			M.reagents.add_reagent(reagent_ids[mode], t)
			reagent_volumes[reagent_ids[mode]] -= t
			admin_inject_log(user, M, src, reagent_ids[mode], t)
			to_chat(user, SPAN_NOTICE("[t] units injected. [reagent_volumes[reagent_ids[mode]]] units remaining."))
	return

/obj/item/reagent_containers/borghypo/attack_self(mob/user as mob) //Change the mode
	var/t = ""
	for(var/i = 1 to reagent_ids.len)
		if(t)
			t += ", "
		if(mode == i)
			t += "<b>[reagent_names[i]]</b>"
		else
			t += "<a href='?src=\ref[src];reagent=[reagent_ids[i]]'>[reagent_names[i]]</a>"
	t = "Available reagents: [t]."
	to_chat(user, t)

	return

/obj/item/reagent_containers/borghypo/Topic(var/href, var/list/href_list)
	if(href_list["reagent"])
		var/t = reagent_ids.Find(href_list["reagent"])
		if(t)
			playsound(loc, 'sound/effects/pop.ogg', 50, 0)
			mode = t
			var/datum/reagent/R = GLOB.chemical_reagents_list[reagent_ids[mode]]
			to_chat(usr, SPAN_NOTICE("Synthesizer is now producing '[R.name]'."))

/obj/item/reagent_containers/borghypo/examine(mob/user)
	if(!..(user, 2))
		return

	var/datum/reagent/R = GLOB.chemical_reagents_list[reagent_ids[mode]]

	to_chat(user, SPAN_NOTICE("It is currently producing [R.name] and has [reagent_volumes[reagent_ids[mode]]] out of [volume] units left."))

/obj/item/reagent_containers/borghypo/service
	name = "cyborg drink synthesizer"
	desc = "A portable drink dispencer."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "shaker"
	charge_cost = 20
	recharge_time = 3
	volume = 60
	possible_transfer_amounts = list(5, 10, 20, 30)
	reagent_ids = list("beer", "kahlua", "whiskey", "wine", "vodka", "gin", "rum", "tequilla", "vermouth", "cognac", "ale", "mead", "water", "sugar", "ice", "tea", "greentea", "icetea", "icegreentea", "cola", "spacemountainwind", "dr_gibb", "space_up", "tonic", "sodawater", "lemon_lime", "orangejuice", "limejuice", "watermelonjuice")

/obj/item/reagent_containers/borghypo/service/attack(var/mob/M, var/mob/user)
	return

/obj/item/reagent_containers/borghypo/service/afterattack(var/obj/target, var/mob/user, var/proximity)
	if(!proximity)
		return

	if(!target.is_refillable())
		return

	if(!reagent_volumes[reagent_ids[mode]])
		to_chat(user, SPAN_NOTICE("[src] is out of this reagent, give it some time to refill."))
		return

	if(!target.reagents.get_free_space())
		to_chat(user, SPAN_NOTICE("[target] is full."))
		return

	var/t = min(amount_per_transfer_from_this, reagent_volumes[reagent_ids[mode]])
	target.reagents.add_reagent(reagent_ids[mode], t)
	reagent_volumes[reagent_ids[mode]] -= t
	to_chat(user, SPAN_NOTICE("You transfer [t] units of the solution to [target]."))
	return

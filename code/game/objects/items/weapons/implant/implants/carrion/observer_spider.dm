/obj/item/implant/carrion_spider/observer
	name = "observer spider"
	desc = "A small spider with a giant blue eye. \red It's looking right at you."
	icon_state = "spiderling_observer"
	spider_price = 10
	var/owner_loc
	var/active = FALSE

	var/observing = FALSE
	var/datum/mind/owner_mind
	var/list/obj/item/implant/carrion_spider/observer/group
	var/timer


/obj/item/implant/carrion_spider/observer/activate()
	..()
	if(active && owner_mob)
		owner_mob.reset_view(null)
		active = FALSE
		return


	owner_loc = owner_mob.loc

	if(!owner_mob || !owner_mob.client)
		return

	owner_mob.reset_view(src)
	active = TRUE

/obj/item/implant/carrion_spider/observer/Process()
	..()
	if(active)
		if(owner_mob && !(owner_mob.loc == owner_loc))
			owner_mob.reset_view(null)
			active = FALSE

/obj/item/implant/carrion_spider/observer/Destroy()
	if(owner_mob)
		owner_mob.reset_view(null)
	group = null
	. = ..()

// Code for spy sensor contract completion
/obj/item/implant/carrion_spider/observer/Move()
	. = ..()
	if(.)
		reset()

/obj/item/implant/carrion_spider/observer/forceMove()
	. = ..()
	if(.)
		reset()

/obj/item/implant/carrion_spider/observer/verb/observe()
	set name = "Begin observations"
	set category = "Object"
	set src in oview(1)

	owner_mind = owner_mob?.mind

	if(usr.incapacitated() || !Adjacent(usr) || !isturf(loc))
		return
	if(locate(/obj/item/implant/carrion_spider/observer) in orange(src,1))
		to_chat(usr, SPAN_WARNING("Another spider in proximity prevents anchoring."))
		return
	observing = TRUE
	start()

	var/spider_amount = length(get_local_spiders())
	to_chat(usr, SPAN_NOTICE("Spider is observing. [spider_amount] spider\s active in the area."))
	if(spider_amount >= 3 && timer)
		to_chat(usr, SPAN_NOTICE("Data observation initiated."))
		if(owner_mind)
			for(var/datum/antag_contract/recon/C in GLOB.various_antag_contracts)
				if(C.completed)
					continue
				if(get_area(src) in C.targets)
					to_chat(usr, SPAN_NOTICE("Recon contract locked in."))
					return

/obj/item/implant/carrion_spider/observer/proc/get_local_spiders()
	var/list/local_spiders = list()
	for(var/obj/item/implant/carrion_spider/observer/S in get_area(src))
		if(S.owner_mind != owner_mind || !S.observing)
			continue
		local_spiders += S
	return local_spiders

/obj/item/implant/carrion_spider/observer/proc/start()
	var/list/local_spiders = get_local_spiders()
	if(local_spiders.len >= 3)
		timer = addtimer(CALLBACK(src, .proc/finish), 10 MINUTES, TIMER_STOPPABLE)
		for(var/obj/item/implant/carrion_spider/observer/S in local_spiders)
			S.timer = timer
			S.group = local_spiders

/obj/item/implant/carrion_spider/observer/proc/reset()
	if(!timer || !group)
		return

	if(length(group) > 3)
		group -= src
		return

	deltimer(timer)
	for(var/obj/item/implant/carrion_spider/observer/S in group)
		S.timer = null
		S.group = null
	start()

/obj/item/implant/carrion_spider/observer/proc/finish()
	for(var/datum/antag_contract/recon/C in GLOB.various_antag_contracts)
		if(C.completed)
			continue
		if(get_area(src) in C.targets)
			C.complete(owner_mind)

	for(var/obj/item/implant/carrion_spider/observer/S in group)
		S.die()

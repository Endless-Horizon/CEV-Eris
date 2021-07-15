/obj/item/implant/carrion_spider/control
	name = "control spider"
	icon_state = "spiderling_control"
	spider_price = 25
	var/active = FALSE
	var/last_use = - 2 MINUTES
	var/cooldown = 2 MINUTES
	var/mob/living/captive_brain/host_brain
	var/datum/mind/owner_mind_last
	var/mob/living/wearer_last

/obj/item/implant/carrion_spider/control/activate()
	..()
	if(!owner_mob || !owner_mob?.mind)
		return
	if(!wearer)
		to_chat(owner_mob, SPAN_WARNING("[src] doesn't have a host"))
		return
	if(wearer.stat == DEAD)
		to_chat(owner_mob, SPAN_WARNING("[wearer] is dead"))
		return
	if(wearer == owner_mob)
		to_chat(owner_mob, SPAN_DANGER("You feel dumb"))
		return
	if(wearer.has_brain_worms() || is_carrion(wearer) || wearer.mind || ishuman(wearer))
		to_chat(owner_mob, SPAN_DANGER("A strong mind inside this creature prevents activation"))
		return
	if(wearer.mob_classification == CLASSIFICATION_SYNTHETIC)
		to_chat(owner_mob, SPAN_DANGER("This creature is robotic, you can't control it"))
		return
	if(last_use + cooldown > world.time)
		to_chat(owner_mob, SPAN_WARNING("The mind control spider is spent, and needs 2 minutes to regenerate."))
		return

	var/datum/mind/owner_mind = owner_mob.mind

	to_chat(owner_mob, SPAN_NOTICE("You assume control of the host."))
	to_chat(wearer, SPAN_DANGER("You feel a strange shifting sensation as another consciousness displaces yours."))
	message_admins("[owner_mob] ([key_name_admin(owner_mob)]) took control of [wearer]([key_name_admin(wearer)]")
	owner_mind_last = owner_mind
	wearer_last = wearer
	qdel(host_brain)
	host_brain = new(src)
	wearer.mind?.transfer_to(host_brain)
	owner_mind.transfer_to(wearer)
	active = TRUE
	last_use = world.time

	addtimer(CALLBACK(src, .proc/return_mind), rand(50 SECONDS, 60 SECONDS))

/obj/item/implant/carrion_spider/control/on_uninstall()
	..()
	return_mind()

/obj/item/implant/carrion_spider/control/Destroy()
	. = ..()
	return_mind()

/obj/item/implant/carrion_spider/control/proc/return_mind()
	if(!active)
		return
	active = FALSE
	if(owner_mob)
		if(isghost(owner_mind_last.current))
			to_chat(owner_mind_last.current, SPAN_NOTICE("You are yanked back to your body from beyond the void."))
		owner_mind_last.transfer_to(owner_mob)
	if(wearer_last && host_brain)
		host_brain.mind?.transfer_to(wearer_last)
		qdel(host_brain)

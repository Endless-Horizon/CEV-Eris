/mob/living/proc/trigger_aiming(var/trigger_type)
	if(!aimed.len)
		return
	for(var/obj/aiming_overlay/AO in aimed)
		if(AO.aiming_at == src)
			AO.update_aiming()
			if(AO.aiming_at == src)
				AO.trigger(trigger_type)
				AO.update_aiming_deferred()

/obj/aiming_overlay/proc/trigger(var/perm)
	if(!owner || !aiming_with || !aiming_at || !locked)
		return
	if(perm && (target_permissions & perm))
		return
	if(!owner.canClick())
		return
	owner.setClickCooldown(5) // Spam prevention, essentially.
	if(owner.a_intent == I_HELP)
		owner << SPAN_WARNING("You refrain from firing \the [aiming_with] as your intent is set to help.")
		return
	owner.visible_message("<span class='danger'>\The [owner] pulls the trigger reflexively!</span>")
	var/obj/item/weapon/gun/G = aiming_with
	if(istype(G))
		G.Fire(aiming_at, owner)

/mob/living/ClickOn(var/atom/A, var/params)
	. = ..()
	trigger_aiming(TARGET_CAN_CLICK)

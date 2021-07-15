/obj/item/rig/proc/can_install(var/obj/item/rig_module/mod, var/mob/user, var/feedback = FALSE)
	if(is_worn())
		if (user && feedback)
			to_chat(user, SPAN_DANGER("You can't install a hardsuit module while the suit is being worn."))
		return FALSE

	if(installed_modules.len)
		for(var/obj/item/rig_module/installed_mod in installed_modules)
			if(!installed_mod.redundant && istype(installed_mod,mod.type))
				if (user && feedback)
					to_chat(user, "The hardsuit already has a module of that class installed.")
				return FALSE

	if (!mod.can_install(src, user, feedback))
		return FALSE

	return TRUE

/obj/item/rig/proc/can_uninstall(var/obj/item/rig_module/mod, var/mob/user, var/feedback = FALSE)
	if (!mod.can_uninstall(src, user, feedback))
		return FALSE

	return TRUE

/obj/item/rig/proc/install(var/obj/item/rig_module/mod, var/mob/user)

	if (user)
		to_chat(user, "You begin installing \the [mod] into \the [src].")
		if(!do_after(user,40,src))
			return FALSE
		if(!user || !mod)
			return FALSE
		if(mod.loc == user && !user.unEquip(mod))
			return FALSE
		to_chat(user, "You install \the [mod] into \the [src].")
	installed_modules |= mod
	mod.holder = src
	mod.forceMove(src)
	mod.installed(user)
	update_icon()
	return TRUE


//Cleanly uninstalls the rig module to prevent runtime/GC errors
/obj/item/rig/proc/uninstall(var/obj/item/rig_module/mod, var/mob/living/user, var/delete = FALSE)
	mod.deactivate()

	//Remove ourselves from the host's installed modules
	installed_modules -= mod
	if (selected_module == mod)
		selected_module = null

	if (visor == mod)
		visor = null

	if (speech == mod)
		speech = null

	mod.holder = null

	if (user)
		to_chat(user, "You detatch \the [mod] from \the [src].")

	mod.uninstalled(src, user)
	if (delete)
		//The module is about to be deleted
		//We're running uninstall to make sure it cleans up after it
		//That is done now, so we return
		return TRUE

	//If we get here, the module is going to be ejected and continue existing outside of this suit

	//If a mob is doing this, we'll try to put it in their hands
	if (user)
		user.put_in_hands(mod)
		return

	else
		mod.forceMove(loc)
		return
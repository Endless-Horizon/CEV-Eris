/datum/core_module
	var/obj/item/implant/core_implant/implant
	var/implant_type = /obj/item/implant/core_implant
	var/install_time = 0
	var/time = 0
	var/list/access = list()
	var/mob/living/user

	var/unique = TRUE

/datum/core_module/proc/can_install(var/obj/item/implant/core_implant/I)
	return TRUE

/datum/core_module/proc/install()

/datum/core_module/proc/uninstall()

/datum/core_module/proc/preinstall()

/datum/core_module/proc/set_up()

/datum/core_module/proc/GetAccess()
	return access.Copy()

/datum/core_module/proc/on_implant_uninstall()


//ACTIVATABLE

/datum/core_module/activatable
	var/active = FALSE
	var/datum/core_module/module

/datum/core_module/activatable/New(var/datum/core_module/M)
	if(istype(M))
		module = M

/datum/core_module/activatable/proc/activate()
	if(implant && istype(module) && !(module in implant.modules))
		implant.add_module(module)
		active = TRUE

/datum/core_module/activatable/proc/deactivate()
	if(implant && istype(module))
		implant.remove_module(module)
		active = FALSE

/datum/core_module/activatable/uninstall()
	deactivate()

//RITUAL HOLDER

/datum/core_module/rituals
	unique = TRUE
	var/list/module_rituals = list()
	implant_type = /obj/item/implant/core_implant

/datum/core_module/rituals/install()
	implant.update_rituals()

/datum/core_module/rituals/uninstall()
	implant.update_rituals()

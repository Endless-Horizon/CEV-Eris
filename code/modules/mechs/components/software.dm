/obj/item/robot_parts/robot_component/exosuit_control
	name = "exosuit control computer"
	desc = "An arrangement of screens, circuitry and software disk ports used to operate an exosuit."
	icon_state = "control"
	icon = MECH_EQUIPMENT_ICON
	gender = NEUTER
	color = null
	matter = list(MATERIAL_STEEL = 10, MATERIAL_PLASTIC = 5, MATERIAL_GLASS = 5, MATERIAL_GOLD = 2)
	var/list/installed_software = list()
	var/max_installed_software = 2

/obj/item/robot_parts/robot_component/exosuit_control/Initialize(newloc)
	. = ..()
	// HACK
	// All robot components add "robot" to the name on init - remove that on exosuit computer
	name = initial(name)

/obj/item/robot_parts/robot_component/exosuit_control/examine(mob/user)
	. = ..()
	if(.)
		to_chat(user, SPAN_NOTICE("It has [max_installed_software - length(installed_software)] empty slot\s remaining out of [max_installed_software]."))

/obj/item/robot_parts/robot_component/exosuit_control/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/electronics/circuitboard/exosystem))
		install_software(I, user)
		return

	if(I.use_tool(user, src, WORKTIME_INSTANT, QUALITY_SCREW_DRIVING, FAILCHANCE_ZERO))
		var/result = ..()
		update_software()
		return result
	else
		return ..()

/obj/item/robot_parts/robot_component/exosuit_control/proc/install_software(obj/item/electronics/circuitboard/exosystem/software, mob/living/user)
	if(installed_software.len >= max_installed_software)
		if(user)
			to_chat(user, SPAN_WARNING("\The [src] can only hold [max_installed_software] software modules."))
		return
	if(user && !user.unEquip(software))
		return

	if(user)
		to_chat(user, SPAN_NOTICE("You load \the [software] into \the [src]'s memory."))

	software.forceMove(src)
	update_software()

/obj/item/robot_parts/robot_component/exosuit_control/proc/update_software()
	installed_software = list()
	for(var/obj/item/electronics/circuitboard/exosystem/program in contents)
		installed_software |= program.contains_software



#define T_BOARD_MECH(name)	"exosuit software (" + (name) + ")"

/obj/item/electronics/circuitboard/exosystem
	name = T_BOARD_MECH("template")
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	var/list/contains_software = list()

/obj/item/electronics/circuitboard/exosystem/engineering
	name = T_BOARD_MECH("engineering systems")
	contains_software = list(MECH_SOFTWARE_ENGINEERING)
	origin_tech = list(TECH_DATA = 1)

/obj/item/electronics/circuitboard/exosystem/utility
	name = T_BOARD_MECH("utility systems")
	contains_software = list(MECH_SOFTWARE_UTILITY)
	icon_state = "mcontroller"
	origin_tech = list(TECH_DATA = 1)

/obj/item/electronics/circuitboard/exosystem/medical
	name = T_BOARD_MECH("medical systems")
	contains_software = list(MECH_SOFTWARE_MEDICAL)
	icon_state = "mcontroller"
	origin_tech = list(TECH_DATA = 3,TECH_BIO = 2)

/obj/item/electronics/circuitboard/exosystem/weapons
	name = T_BOARD_MECH("basic weapon systems")
	contains_software = list(MECH_SOFTWARE_WEAPONS)
	icon_state = "mainboard"
	origin_tech = list(TECH_DATA = 4, TECH_COMBAT = 3)

/obj/item/electronics/circuitboard/exosystem/advweapons
	name = T_BOARD_MECH("advanced weapon systems")
	contains_software = list(MECH_SOFTWARE_ADVWEAPONS)
	icon_state = "mainboard"
	origin_tech = list(TECH_DATA = 4, TECH_COMBAT = 5)

#undef T_BOARD_MECH
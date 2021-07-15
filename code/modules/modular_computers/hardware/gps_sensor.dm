/obj/item/computer_hardware/gps_sensor
	name = "relay positioning receiver"
	desc = "A module that connects a computer to the ship navigation system, commonly installed in PDAs."
	power_usage = 5 //W
	icon_state = "gps_basic"
	hardware_size = 1
	matter = list(MATERIAL_STEEL = 1, MATERIAL_PLASTIC = 2)
	matter_reagents = list("silicon" = 10)
	origin_tech = list(TECH_BLUESPACE = 2)
	usage_flags = PROGRAM_ALL
	var/datum/gps_data/gps

/obj/item/computer_hardware/gps_sensor/Initialize()
	. = ..()
	var/prefix = "MPC"
	if(istype(loc, /obj/item/modular_computer/pda))
		prefix = "PDA"
	else if(istype(loc, /obj/item/modular_computer/tablet))
		prefix = "TAB"

	gps = new /datum/gps_data/modular_pc(src, new_prefix=prefix)

/obj/item/computer_hardware/gps_sensor/Destroy()
	QDEL_NULL(gps)
	return ..()

/obj/item/computer_hardware/gps_sensor/examine(mob/user)
	..()
	to_chat(user, "Serial number is [gps.serial_number].")

/obj/item/computer_hardware/gps_sensor/proc/get_position_text()
	var/error_text = "<span class='average'>ERROR: Unable to reach positioning system relays.</span>"
	return gps.get_coordinates_text(default=error_text)


// Only works if installed in MPC, enabled and not too damaged
/datum/gps_data/modular_pc

/datum/gps_data/modular_pc/is_functioning()
	var/obj/item/computer_hardware/H = holder
	if(!H.holder2?.enabled || !H.check_functionality())
		return FALSE

	return ..()

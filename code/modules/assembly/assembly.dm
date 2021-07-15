/obj/item/device/assembly
	name = "assembly"
	desc = "A small electronic device that should never exist."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = ""
	flags = CONDUCT
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_PLASTIC = 1)
	throwforce = WEAPON_FORCE_HARMLESS
	throw_speed = 3
	throw_range = 10
	origin_tech = list(TECH_MAGNET = 1)

	bad_type = /obj/item/device/assembly
	rarity_value = 10
	spawn_tags = SPAWN_TAG_ASSEMBLY

	var/secured = TRUE
	var/list/attached_overlays
	var/obj/item/device/assembly_holder/holder
	var/cooldown = 0 //To prevent spam
	var/wires = WIRE_RECEIVE | WIRE_PULSE

	var/const/WIRE_RECEIVE = 1			//Allows Pulsed(0) to call Activate()
	var/const/WIRE_PULSE = 2				//Allows Pulse(0) to act on the holder
	var/const/WIRE_PULSE_SPECIAL = 4		//Allows Pulse(0) to act on the holders special assembly
	var/const/WIRE_RADIO_RECEIVE = 8		//Allows Pulsed(1) to call Activate()
	var/const/WIRE_RADIO_PULSE = 16		//Allows Pulse(1) to send a radio message


/obj/item/device/assembly/proc/activate()
	if(!secured || (cooldown > 0))
		return FALSE
	cooldown = 2
	spawn(10)
		process_cooldown()
	return TRUE


/obj/item/device/assembly/proc/process_cooldown()
	cooldown--
	if(cooldown <= 0)
		return FALSE
	spawn(10)
		process_cooldown()
	return TRUE


/obj/item/device/assembly/proc/pulsed(radio = 0)
	if(holder && wires & WIRE_RECEIVE)
		activate()
	if(radio && wires & WIRE_RADIO_RECEIVE)
		activate()


/obj/item/device/assembly/proc/pulse(radio = 0)
	if(holder && (wires & WIRE_PULSE))
		holder.process_activation(src, 1, 0)
	if(holder && (wires & WIRE_PULSE_SPECIAL))
		holder.process_activation(src, 0, 1)
	return 1


/obj/item/device/assembly/proc/toggle_secure()
	secured = !secured
	update_icon()
	return secured


/obj/item/device/assembly/proc/attach_assembly(obj/item/device/assembly/A, mob/user)
	holder = new/obj/item/device/assembly_holder(get_turf(src))
	if(holder.attach(A, src, user))
		to_chat(user, SPAN_NOTICE("You attach \the [A] to \the [src]!"))


/obj/item/device/assembly/attackby(obj/item/I, mob/user)
	if(is_assembly(I))
		var/obj/item/device/assembly/A = I
		if((!A.secured) && (!secured))
			attach_assembly(A, user)
			return
	if(QUALITY_SCREW_DRIVING in I.tool_qualities)
		if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, QUALITY_SCREW_DRIVING, FAILCHANCE_EASY, required_stat = STAT_COG))
			if(toggle_secure())
				to_chat(user, SPAN_NOTICE("\The [src] is ready!"))
			else
				to_chat(user, SPAN_NOTICE("\The [src] can now be attached!"))
			return
	..()


/obj/item/device/assembly/Process()
	STOP_PROCESSING(SSobj, src)


/obj/item/device/assembly/examine(mob/user)
	..(user)
	if(in_range(src, user) || loc == user)
		if(secured)
			to_chat(user, SPAN_NOTICE("\The [src] is ready!"))
		else
			to_chat(user, SPAN_NOTICE("\The [src] can be attached!"))

/obj/item/device/assembly/attack_self(mob/user)
	if(!user)
		return 0
	user.set_machine(src)
	interact(user)
	return 1


/obj/item/device/assembly/interact(mob/user)
	return //HTML MENU FOR WIRES GOES HERE

/obj/item/device/assembly/proc/holder_movement()
	return

/obj/item/device/assembly/nano_host()
    if(istype(loc, /obj/item/device/assembly_holder))
        return loc.nano_host()
    return ..()

/obj/item/device/assembly/proc/is_attachable()
	if(secured)
		return FALSE
	return TRUE

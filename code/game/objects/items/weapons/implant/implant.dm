#define MALFUNCTION_NONE 0
#define MALFUNCTION_TEMPORARY 1
#define MALFUNCTION_PERMANENT 2

/obj/item/implant
	name = "implant"
	icon = 'icons/obj/device.dmi'
	icon_state = "implant"
	w_class = ITEM_SIZE_TINY
	matter = list(MATERIAL_STEEL = 1, MATERIAL_GLASS = 1)
	var/implanted = FALSE
	var/mob/living/carbon/human/wearer
	var/obj/item/organ/external/part
	var/implant_color = "b"
	var/allow_reagents = FALSE
	var/malfunction = MALFUNCTION_NONE
	var/is_legal = TRUE
	var/list/allowed_organs = list()
	var/position_flag = 0
	var/external = FALSE
	var/cruciform_resist = FALSE

/obj/item/implant/attackby(obj/item/I, mob/user)
	..()
	if(istype(I, /obj/item/implanter))
		var/obj/item/implanter/M = I
		if(is_external())
			return
		if(!M.implant && user.unEquip(src, M))
			M.implant = src
			M.update_icon()


/obj/item/implant/proc/trigger(emote, mob/living/source)
/obj/item/implant/proc/activate()
	return TRUE

/obj/item/implant/proc/deactivate()
	return TRUE

/obj/item/implant/proc/malfunction(var/severity)

/obj/item/implant/proc/is_external()
	return external

//return TRUE for implanter icon update.
/obj/item/implant/proc/install(mob/living/target, organ, mob/user)
	var/obj/item/organ/external/affected
	if (ishuman(target))
		var/mob/living/carbon/human/H = target
		affected = H.organs_by_name[organ]
		if(!affected)
			if(allowed_organs.len)
				organ = pick(allowed_organs)
			else
				organ = BP_CHEST
		affected = H.organs_by_name[organ]

		if(!affected)
			to_chat(user, SPAN_WARNING("[H] is missing that body part!."))
			return

		if(allowed_organs && allowed_organs.len && !(organ in allowed_organs))
			to_chat(user, SPAN_WARNING("[src] cannot be implanted in this limb."))
			return

	if(!can_install(target, affected))
		to_chat(user, SPAN_WARNING("You can't install [src]."))
		return
	forceMove(target)
	wearer = target
	implanted = TRUE
	if(affected)
		affected.implants |= src
		part = affected
		SSnano.update_uis(affected) // Update surgery UI window, if any

	on_install(target, affected)
	wearer.update_implants()
	for(var/mob/living/carbon/human/H in viewers(target))
		SEND_SIGNAL(H, COMSIG_HUMAN_INSTALL_IMPLANT, target, src)
	return TRUE

/obj/item/implant/proc/can_install(var/mob/living/target, var/obj/item/organ/external/E)
	return TRUE

/obj/item/implant/proc/on_install(var/mob/living/target, var/obj/item/organ/external/E)

/obj/item/implant/proc/uninstall()
	on_uninstall()
	forceMove(get_turf(wearer))
	if(part)
		part.implants.Remove(src)
	part = null
	implanted = FALSE
	if(ishuman(wearer))
		var/mob/living/carbon/human/H = wearer
		H.update_implants()
	wearer = null

/obj/item/implant/proc/on_uninstall()

/obj/item/implant/proc/get_data()
	return "No information available"

/obj/item/implant/proc/hear(message, mob/source)

/obj/item/implant/proc/meltdown()	//breaks it down, making implant unrecongizible
	to_chat(wearer, "<span class='warning'>You feel something melting inside [part ? "your [part.name]" : "you"]!</span>")
	if (part)
		part.take_damage(burn = 15, used_weapon = "Electronics meltdown")
	else
		var/mob/living/M = wearer
		M.apply_damage(15,BURN)
	name = "melted implant"
	desc = "Charred circuit in melted plastic case. Wonder what that used to be..."
	icon_state = "implant_melted"
	malfunction = MALFUNCTION_PERMANENT

/obj/item/implant/proc/restore()
	name = initial(name)
	desc = initial(desc)
	icon_state = initial(icon_state)
	malfunction = initial(malfunction)

/obj/item/implant/proc/get_mob_overlay(var/gender)
	return null

/obj/item/implant/Destroy()
	if(part)
		part.implants.Remove(src)
	return ..()

/obj/item/implant/explosive/emp_act(severity)
	malfunction(severity)

/obj/item/implant/proc/get_scanner_name()
	return name

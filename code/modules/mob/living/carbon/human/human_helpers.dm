#define HUMAN_EATING_NO_ISSUE		0
#define HUMAN_EATING_NO_MOUTH		1
#define HUMAN_EATING_BLOCKED_MOUTH	2

#define add_clothing_protection(A)	\
	var/obj/item/clothing/C = A; \
	flash_protection += C.flash_protection; \
	equipment_tint_total += C.tint;

/mob/living/carbon/human/can_eat(var/food, var/feedback = 1)
	var/list/status = can_eat_status()
	if(status[1] == HUMAN_EATING_NO_ISSUE)
		return 1
	if(feedback)
		if(status[1] == HUMAN_EATING_NO_MOUTH)
			to_chat(src, "Where do you intend to put \the [food]? You don't have a mouth!")
		else if(status[1] == HUMAN_EATING_BLOCKED_MOUTH)
			to_chat(src, SPAN_WARNING("\The [status[2]] is in the way!"))
	return 0

/mob/living/carbon/human/can_force_feed(var/feeder, var/food, var/feedback = 1)
	var/list/status = can_eat_status()
	if(status[1] == HUMAN_EATING_NO_ISSUE)
		return 1
	if(feedback)
		if(status[1] == HUMAN_EATING_NO_MOUTH)
			to_chat(feeder, "Where do you intend to put \the [food]? \The [src] doesn't have a mouth!")
		else if(status[1] == HUMAN_EATING_BLOCKED_MOUTH)
			to_chat(feeder, SPAN_WARNING("\The [status[2]] is in the way!"))
	return 0

/mob/living/carbon/human/proc/can_eat_status()
	if(!check_has_mouth())
		return list(HUMAN_EATING_NO_MOUTH)
	var/obj/item/blocked = check_mouth_coverage()
	if(blocked)
		return list(HUMAN_EATING_BLOCKED_MOUTH, blocked)
	return list(HUMAN_EATING_NO_ISSUE)

#undef HUMAN_EATING_NO_ISSUE
#undef HUMAN_EATING_NO_MOUTH
#undef HUMAN_EATING_BLOCKED_MOUTH

/mob/living/carbon/human/proc/update_equipment_vision()
	flash_protection = 0
	equipment_tint_total = 0
	equipment_see_invis	= 0
	equipment_vision_flags = 0
	equipment_prescription = FALSE
	equipment_darkness_modifier = 0
//	equipment_overlays.Cut()

	if(istype(src.head, /obj/item/clothing/head))
		add_clothing_protection(head)
	if(istype(src.glasses, /obj/item/clothing/glasses))
		process_glasses(glasses)
	if(istype(src.wear_mask, /obj/item/clothing/mask))
		add_clothing_protection(wear_mask)
	if(istype(wearing_rig,/obj/item/rig))
		process_rig(wearing_rig)
	if(istype(using_scope,/obj/item/gun))
		process_scope(using_scope)

/mob/living/carbon/human/proc/process_glasses(obj/item/clothing/glasses/G, var/forceactive)
	if(G && (G.active || forceactive))
		equipment_darkness_modifier += G.darkness_view
		equipment_vision_flags |= G.vision_flags
		equipment_prescription = equipment_prescription || G.prescription
//		if(G.overlay)
//			equipment_overlays |= G.overlay
//		if (src.HUDtech.Find("glassesoverlay"))//i process that ocerlay
//			var/obj/screen/glasses_overlay/GO = src.HUDtech["glassesoverlay"]
//			GO.update_icon()
		if(G.see_invisible >= 0)
			if(equipment_see_invis)
				equipment_see_invis = min(equipment_see_invis, G.see_invisible)
			else
				equipment_see_invis = G.see_invisible

		add_clothing_protection(G)
		G.process_hud(src)

/mob/living/carbon/human/proc/process_rig(var/obj/item/rig/O)
	if(O.helmet && O.helmet == head && (O.helmet.body_parts_covered & EYES))
		if((O.offline && O.offline_vision_restriction == 2) || (!O.offline && O.vision_restriction == 2))
			equipment_tint_total += TINT_BLIND
	var/obj/item/clothing/glasses/G = O.getCurrentGlasses()
	if(G && O.visor.active)
		process_glasses(G,TRUE)

/mob/living/carbon/human/reset_layer()
	if(hiding)
		set_plane(HIDING_MOB_PLANE)
		layer = HIDING_MOB_LAYER
	else if(lying)
		set_plane(LYING_HUMAN_PLANE)
		layer = LYING_HUMAN_LAYER
	else
		..()

/mob/living/carbon/human/proc/process_scope(mob/user)
	var/obj/item/gun/A = using_scope
	equipment_darkness_modifier += A.darkness_view
	equipment_vision_flags |= A.vision_flags
	if(A.see_invisible_gun >= 0)
		if(equipment_see_invis)
			equipment_see_invis = min(equipment_see_invis, A.see_invisible_gun)
		else
			equipment_see_invis = A.see_invisible_gun
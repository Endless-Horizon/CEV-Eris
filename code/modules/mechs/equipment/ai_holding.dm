/mob/living/silicon/ai/proc/add_mecha_verbs()
	verbs += /mob/living/silicon/ai/proc/view_mecha_stats
	verbs += /mob/living/silicon/ai/proc/AIeject


/mob/living/silicon/ai/proc/remove_mecha_verbs()
	verbs -= /mob/living/silicon/ai/proc/view_mecha_stats
	verbs -= /mob/living/silicon/ai/proc/AIeject

/mob/living/silicon/ai/proc/view_mecha_stats()
	set name = "View Stats"
	set category = "Exosuit Interface"
	set popup_menu = 0
	if(controlled_mech)
		controlled_mech.view_stats()


/mob/living/silicon/ai/proc/AIeject()
	set name = "AI Eject"
	set category = "Exosuit Interface"
	set popup_menu = 0
	if(controlled_mech)
		controlled_mech.AIeject()

/mob/living/silicon/ai/proc/set_mecha(var/mob/living/exosuit/M)
	if(M)
		if(controlled_mech == M)
			return
		if(controlled_mech)
			controlled_mech.go_out()
		destroy_eyeobj(M)
	controlled_mech = M

/obj/item/mech_equipment/tool/ai_holder
	name = "AI holder"
	desc = "This is AI holder, thats allow AI control exo-suits."
	icon_state = "ai_holder"
	origin_tech = list(TECH_POWER = 3, TECH_ENGINEERING = 3)
	matter = list(MATERIAL_STEEL = 20, MATERIAL_GLASS = 3)
	energy_drain = 2
	equip_cooldown = 20
	salvageable = 0
	var/obj/machinery/camera/Cam = null
	var/mob/living/silicon/ai/occupant = null
	var/mob/living/prev_occupant = null


/obj/item/mech_equipment/tool/ai_holder/proc/occupied(var/mob/living/silicon/ai/AI)
	if(chassis.occupant && !isAI(chassis.occupant))
		prev_occupant = chassis.occupant
		prev_occupant.forceMove(src)
	AI.set_mecha(chassis)
	occupant = AI
	chassis.occupant = occupant
	chassis.update_icon()
	AI.add_mecha_verbs()

/obj/item/mech_equipment/tool/ai_holder/interact(var/mob/living/silicon/ai/user)
	if(!chassis) return
	if(occupant)
		if(occupant == user) go_out()
		else to_chat(user, "Controller is already occupied!")
	else if(isAI(user)) occupied(user)

/mob/living/exosuit/verb/AIeject()
	set name = "AI Eject"
	set category = "Exosuit Interface"
	set popup_menu = 0

	var/atom/movable/mob_container
	if(ishuman(pilots[1]) || isAI(pilots[1]))
		mob_container = pilots[1]

	if(usr != pilots[1])
		return

	if(isAI(mob_container))
		var/obj/item/mech_equipment/tool/ai_holder/AH = locate() in src
		if(AH)
			AH.eject()

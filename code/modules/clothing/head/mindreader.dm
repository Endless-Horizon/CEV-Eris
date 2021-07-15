/obj/item/clothing/head/mindreader
	name = "Mindreader"
	desc = "Extracts knowledge from the mentally broken wearer mind and writes it on papers."
	icon_state = "mindreader"
	item_state = "mindreader"
	flags_inv = HIDEEARS
	action_button_name = "Extract Memory"
	w_class = ITEM_SIZE_NORMAL
	armor = list(
		melee = 10,
		bullet = 10,
		energy = 10,
		bomb = 0,
		bio = 0,
		rad = 0
	)
	spawn_blacklisted = TRUE
	var/self_cooldown = 2 MINUTES
	var/last_use = 0

/obj/item/clothing/head/mindreader/ui_action_click()
	if(ismob(loc))
		if(world.time >= (last_use + self_cooldown))
			last_use = world.time
			var/mob/user = loc
			extract_memory(user)
		else
			visible_message("\icon The [src] beeps, \"The [src] is not ready for manual use.\".")
	else
		return

/obj/item/clothing/head/mindreader/proc/extract_memory(var/user)
	if (!user) return

	if (src.loc != user || !ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	var/output = "<B>[H.real_name]'s Memory</B><HR>"
	output += H.mind.memory

	for(var/datum/antagonist/A in H.mind.antagonist)
		if(!A.objectives.len)
			break
		if(A.faction)
			output += "<br><b>[H.real_name]'s [A.faction.name] faction objectives:</b>"
		else
			output += "<br><b>[H.real_name]'s [A.role_text] objectives:</b>"
		output += "[A.print_objectives(FALSE)]"

	new /obj/item/paper(drop_location(), output, "[H.real_name]'s Memory")
	H.visible_message(SPAN_NOTICE("[src] printed a paper with writed [H] memory."))

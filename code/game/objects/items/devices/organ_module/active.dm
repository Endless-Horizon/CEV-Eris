//Toggleable embedded module
/obj/item/organ_module/active
	var/verb_name = "Activate"
	var/verb_desc = "activate embedded module"

/obj/item/organ_module/active/onInstall(var/obj/item/organ/external/E)
	new /obj/item/organ/external/proc/activate_module(E, verb_name, verb_desc)
	E.update_bionics_hud()

/obj/item/organ_module/active/onRemove(var/obj/item/organ/external/E)
	E.verbs -= /obj/item/organ/external/proc/activate_module
	E.update_bionics_hud()

/obj/item/organ_module/active/organ_removed(obj/item/organ/external/E, mob/living/carbon/human/H)
	onRemove(E)

/obj/item/organ_module/active/organ_installed(obj/item/organ/external/E, mob/living/carbon/human/H)
	onInstall(E)

/obj/item/organ_module/active/proc/can_activate(var/mob/living/carbon/human/H, var/obj/item/organ/external/E)
	//As long as you're awake you can toggle your own body
	if(H.incapacitated(INCAPACITATION_UNCONSCIOUS))
		to_chat(H, SPAN_WARNING("You can't do that now!"))
		return
/*
	for(var/obj/item/implant/prosthesis_inhibition/I in H)
		if(I.malfunction)
			continue
		to_chat(H, SPAN_WARNING("[I] in your [I.part] prevent [src] activation!"))
		return FALSE
*/
	return TRUE

/obj/item/organ_module/active/proc/activate(var/mob/living/carbon/human/H, var/obj/item/organ/external/E)
/obj/item/organ_module/active/proc/deactivate(var/mob/living/carbon/human/H, var/obj/item/organ/external/E)



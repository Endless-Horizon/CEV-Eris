/obj/item/clothing/accessory/bs_silk
	name = "bluespace snare"
	desc = "A bluespace snare. Looking at the edges of this thing, you see a faint blue ripple and spatial distortion."
	icon = 'icons/obj/rig_modules.dmi'
	icon_state = "teleporter"
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_BLUESPACE = 6)
	//var/locking_access = access_rd
	var/silk_id = "" //using by snare controller to teleport user to controller's mark

/obj/item/clothing/accessory/bs_silk/New()
	. = ..()
	matter = list(MATERIAL_STEEL = 8, MATERIAL_GLASS = 5, MATERIAL_SILVER = 10)
/*/obj/item/clothing/accessory/bs_silk/proc/toggle_lock()
	removable = !removable*/

/obj/item/clothing/accessory/bs_silk/attackby(obj/item/I, mob/user)
	if((QUALITY_PULSING in I.tool_qualities))// || removable)
		var/input_id = input("Enter new BS Snare ID", "Snare ID", silk_id)
		silk_id = input_id
		return

	/*if(istype(I, /obj/item/card/id))
		var/obj/item/card/id/ID = I
		if(locking_access in ID.GetAccess())
			toggle_lock()
			var/isLocked = removable ? "unlocked and can be removed." : "locked and can\'t be removed."
			to_chat(user, SPAN_NOTICE("You toggle lock of [src.name]. Now it is [isLocked]"))
		else
			to_chat(user, SPAN_WARNING("ERROR: Incorrect access."))*/

/obj/item/clothing/accessory/bs_silk/examine()
	..()
	var/s_id = silk_id != "" ? silk_id : "NOT SETTED"
	to_chat(usr, "<br>On small display you can notice label that mean: \"DEVICE ID: <b>[s_id]</b>\".")
	//to_chat(usr, "<br>It[removable ? " can be removed" : "'s locked by access: " + locking_access].")
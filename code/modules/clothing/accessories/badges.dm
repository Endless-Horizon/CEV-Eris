/*
	Badges are worn on the belt or neck, and can be used to show that the holder is an authorized
	Security agent - the user details can be imprinted on holobadges with a Security-access ID card,
	or they can be emagged to accept any ID for use in disguises.
*/

/obj/item/clothing/accessory/badge
	name = "Inspector's badge"
	desc = "A Ironhammer Security badge, made from gold and set on false leather."
	icon_state = "badge"
	item_state = "marshalbadge"
	slot_flags = SLOT_BELT | SLOT_ACCESSORY_BUFFER
	price_tag = 200

	var/stored_name
	var/badge_string = "Ironhammer Security"

/obj/item/clothing/accessory/badge/old
	name = "faded badge"
	desc = "A faded badge, backed with leather. It bears the emblem of the Forensic division."
	icon_state = "badge_round"

/obj/item/clothing/accessory/badge/proc/set_name(var/new_name)
	stored_name = new_name
	name = "[initial(name)] ([stored_name])"

/obj/item/clothing/accessory/badge/attack_self(mob/user as mob)

	if(!stored_name)
		to_chat(user, "You polish your badge fondly, shining up the surface.")
		set_name(user.real_name)
		return

	if(isliving(user))
		if(stored_name)
			user.visible_message(SPAN_NOTICE("[user] displays their [src.name].\nIt reads: [stored_name], [badge_string]."),SPAN_NOTICE("You display your [src.name].\nIt reads: [stored_name], [badge_string]."))
		else
			user.visible_message(SPAN_NOTICE("[user] displays their [src.name].\nIt reads: [badge_string]."),SPAN_NOTICE("You display your [src.name]. It reads: [badge_string]."))

/obj/item/clothing/accessory/badge/attack(mob/living/carbon/human/M, mob/living/user)
	if(isliving(user))
		user.visible_message(SPAN_DANGER("[user] invades [M]'s personal space, thrusting [src] into their face insistently."),SPAN_DANGER("You invade [M]'s personal space, thrusting [src] into their face insistently."))

//.Holobadges.
/obj/item/clothing/accessory/badge/holo
	name = "holobadge"
	desc = "This glowing blue badge marks the holder as a member of Ironhammer Security."
	icon_state = "holobadge"
	item_state = "holobadge"
	var/emagged //Emagging removes Sec check.

/obj/item/clothing/accessory/badge/holo/cord
	icon_state = "holobadge-cord"
	slot_flags = SLOT_MASK | SLOT_ACCESSORY_BUFFER

/obj/item/clothing/accessory/badge/holo/attack_self(mob/user as mob)
	if(!stored_name)
		to_chat(user, "Waving around a holobadge before swiping an ID would be pretty pointless.")
		return
	return ..()

/obj/item/clothing/accessory/badge/holo/emag_act(var/remaining_charges, var/mob/user)
	if (emagged)
		to_chat(user, SPAN_DANGER("\The [src] is already cracked."))
		return
	else
		emagged = 1
		to_chat(user, SPAN_DANGER("You crack the holobadge security checks."))
		return 1

/obj/item/clothing/accessory/badge/holo/attackby(var/obj/item/O as obj, var/mob/user as mob)
	var/obj/item/card/id/id_card = O.GetIdCard()
	if(!id_card)
		return

	if(access_security in id_card.access || emagged)
		to_chat(user, "You imprint your ID details onto the badge.")
		set_name(user.real_name)
	else
		to_chat(user, "[src] rejects your insufficient access rights.")
	return

/obj/item/storage/box/holobadge
	name = "holobadge box"
	desc = "A box claiming to contain holobadges."
	New()
		new /obj/item/clothing/accessory/badge/holo(src)
		new /obj/item/clothing/accessory/badge/holo(src)
		new /obj/item/clothing/accessory/badge/holo(src)
		new /obj/item/clothing/accessory/badge/holo(src)
		new /obj/item/clothing/accessory/badge/holo/cord(src)
		new /obj/item/clothing/accessory/badge/holo/cord(src)
		..()
		return


/obj/item/clothing/accessory/badge/warden
	name = "Gunnery Sergeant badge"
	desc = "A silver Ironhammer Security badge. Stamped with the words 'Sergeant.'"
	icon_state = "silverbadge"
	slot_flags = SLOT_ACCESSORY_BUFFER
	spawn_blacklisted = TRUE


/obj/item/clothing/accessory/badge/hos
	name = "Commander's badge"
	desc = "An immaculately polished gold Ironhammer Security badge. Labeled 'Commander.'"
	icon_state = "goldbadge"
	slot_flags = SLOT_ACCESSORY_BUFFER
	spawn_blacklisted = TRUE

/obj/item/clothing/accessory/badge/marshal
	name = "Marshal's badge"
	desc = "A leather-backed gold badge displaying the crest of the Ironhammer Marshals."
	icon_state = "marshalbadge"
	badge_string = "Ironhammer Marshal Bureau"
	spawn_blacklisted = TRUE

//NASA Voidsuit
/obj/item/clothing/head/space/void
	name = "void helmet"
	desc = "A high-tech dark red space suit helmet. Used for AI satellite maintenance."
	icon_state = "void"

	heat_protection = HEAD
	armor = list(
		melee = 30,
		bullet = 20,
		energy = 15,
		bomb = 25,
		bio = 100,
		rad = 75
	)
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	flash_protection = FLASH_PROTECTION_MAJOR
	light_overlay = "helmet_light"
	spawn_tags = null

/obj/item/clothing/suit/space/void
	name = "voidsuit"
	icon_state = "void"
	item_state = "void"
	desc = "A high-tech dark red space suit. Used for AI satellite maintenance."
	slowdown = 0.3
	armor = list(
		melee = 30,
		bullet = 20,
		energy = 15,
		bomb = 25,
		bio = 100,
		rad = 75
	)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	action_button_name = "Toggle Helmet"
	breach_threshold = 5
	resilience = 0.09
	can_breach = 1
	spawn_tags = SPAWN_TAG_VOID_SUIT
	accompanying_object = /obj/item/clothing/shoes/magboots

	//Inbuilt devices.
	var/obj/item/clothing/shoes/magboots/boots // Deployable boots, if any.
	var/obj/item/clothing/head/armor/helmet/helmet = /obj/item/clothing/head/space/void   // Deployable helmet, if any.
	var/obj/item/tank/tank              // Deployable tank, if any.

/obj/item/clothing/suit/space/void/Initialize()
	. = ..()
	if(boots && ispath(boots))
		boots = new boots(src)
	if(helmet && ispath(helmet))
		helmet = new helmet(src)
	if(tank && ispath(tank))
		tank = new tank(src)

/obj/item/clothing/suit/space/void/examine(user)
	..(user)
	var/list/part_list = new
	for(var/obj/item/I in list(helmet,boots,tank))
		part_list += "\a [I]"
	to_chat(user, "\The [src] has [english_list(part_list)] installed.")
	if(tank && in_range(src,user))
		to_chat(user, SPAN_NOTICE("The wrist-mounted pressure gauge reads [max(round(tank.air_contents.return_pressure()),0)] kPa remaining in \the [tank]."))

/obj/item/clothing/suit/space/void/ui_action_click(mob/living/user, action_name)
	if(..())
		return TRUE
	toggle_helmet()

/obj/item/clothing/suit/space/void/clean_blood()
	//So that you dont have to detach the components to clean them, also since you can't detach the helmet
	if(boots) boots.clean_blood()
	if(helmet) helmet.clean_blood()
	if(tank) tank.clean_blood()

	return ..()

/obj/item/clothing/suit/space/void/decontaminate()
	if(boots) boots.decontaminate()
	if(helmet) helmet.decontaminate()
	if(tank) tank.decontaminate()

	return ..()

/obj/item/clothing/suit/space/void/make_young()
	..()
	if(boots) boots.make_young()
	if(helmet) helmet.make_young()
	if(tank) tank.make_young()

/obj/item/clothing/suit/space/void/equipped(mob/M)
	..()

	if(is_held())
		retract()

	var/mob/living/carbon/human/H = M

	if(!istype(H)) return

	if(H.wear_suit != src)
		return

	if(boots)
		if(H.equip_to_slot_if_possible(boots, slot_shoes))
			boots.canremove = 0

	if(helmet)
		toggle_helmet()

	if(tank)
		if(H.s_store) //In case someone finds a way.
			to_chat(M, "Alarmingly, the valve on your suit's installed tank fails to engage.")
		else if(H.equip_to_slot_if_possible(tank, slot_s_store))
			to_chat(M, "The valve on your suit's installed tank safely engages.")
			tank.canremove = 0


/obj/item/clothing/suit/space/void/dropped()
	..()
	retract()


/obj/item/clothing/suit/space/void/proc/retract()
	var/mob/living/carbon/human/H

	if(helmet)
		helmet.canremove = 1
		H = helmet.loc
		if(istype(H))
			if(helmet && H.head == helmet)
				H.drop_from_inventory(helmet)
				helmet.forceMove(src)
				if(helmet.overslot)
					helmet.remove_overslot_contents(H)

	if(boots)
		boots.canremove = 1
		H = boots.loc
		if(istype(H))
			if(boots && H.shoes == boots)
				H.drop_from_inventory(boots)
				boots.forceMove(src)
				if(boots.overslot)
					boots.remove_overslot_contents(H)

	if(tank)
		tank.canremove = 1
		tank.forceMove(src)

/obj/item/clothing/suit/space/void/verb/toggle_helmet()
	set name = "Toggle Helmet"
	set category = "Object"
	set src in usr

	if(!isliving(loc))
		return

	if(!helmet)
		to_chat(usr, "There is no helmet installed.")
		return

	var/mob/living/carbon/human/H = usr

	if(!istype(H)) return
	if(H.stat) return
	if(H.wear_suit != src) return

	if(H.head == helmet)
		to_chat(H, SPAN_NOTICE("You retract your suit helmet."))
		helmet.canremove = 1
		H.drop_from_inventory(helmet)
		helmet.forceMove(src)
		playsound(src.loc, 'sound/weapons/guns/interact/pistol_magin.ogg', 75, 1)
	else
		if(H.head)
			to_chat(H, SPAN_DANGER("You cannot deploy your helmet while wearing \the [H.head]."))
			return
		if(H.equip_to_slot_if_possible(helmet, slot_head))
			helmet.canremove = 0
			to_chat(H, "<span class='info'>You deploy your suit helmet, sealing you off from the world.</span>")
			playsound(src.loc, 'sound/weapons/guns/interact/pistol_magin.ogg', 75, 1)
	helmet.update_light(H)

/obj/item/clothing/suit/space/void/verb/eject_tank()

	set name = "Eject Voidsuit Tank"
	set category = "Object"
	set src in view(1)

	if(!isliving(usr))
		return

	if(!Adjacent(usr, get_turf(src)))
		to_chat(usr, SPAN_WARNING("You're too far away to eject the tank."))
		return

	if(!tank)
		to_chat(usr, "<span class='warning'>There is no tank inserted.</span>")
		return



	var/mob/living/H = usr

	if(!istype(H))
		return
	if(H.stat)
		return

	H.visible_message(
	"<span class='info'>[H] presses the emergency release, ejecting \the [tank] from the suit.</span>",
	"<span class='info'>You press the emergency release, ejecting \the [tank] from the suit.</span>",
	"<span class='info'>You hear a click and a hiss</span>"
	)
	tank.canremove = 1
	H.drop_from_inventory(tank)
	src.tank = null

/obj/item/clothing/suit/space/void/attackby(obj/item/W as obj, mob/user as mob)

	if(!isliving(user))
		return

	if(istype(W,/obj/item/clothing/accessory) || istype(W, /obj/item/hand_labeler))
		return ..()

	if(is_worn())
		to_chat(user, SPAN_WARNING("You cannot modify \the [src] while it is being worn."))
		return

	if(istype(W,/obj/item/tool/screwdriver))
		if(boots || tank)
			var/choice = input("What component would you like to remove?") as null|anything in list(boots,tank)
			if(!choice) return

			if(choice == tank)	//No, a switch doesn't work here. Sorry. ~Techhead
				to_chat(user, "You pop \the [tank] out of \the [src]'s storage compartment.")
				tank.forceMove(get_turf(src))
				src.tank = null
			else if(choice == boots)
				to_chat(user, "You detatch \the [boots] from \the [src]'s boot mounts.")
				boots.forceMove(get_turf(src))
				src.boots = null
		else
			to_chat(user, "\The [src] does not have anything installed.")
		return
	else if(istype(W,/obj/item/clothing/shoes/magboots))
		if(boots)
			to_chat(user, "\The [src] already has magboots installed.")
		else
			to_chat(user, "You attach \the [W] to \the [src]'s boot mounts.")
			user.drop_item()
			W.forceMove(src)
			boots = W
			playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
		return
	if(istype(W,/obj/item/tank))
		if(tank)
			to_chat(user, "\The [src] already has an airtank installed.")
		else if(istype(W,/obj/item/tank/plasma))
			to_chat(user, "\The [W] cannot be inserted into \the [src]'s storage compartment.")
		else
			to_chat(user, "You insert \the [W] into \the [src]'s storage compartment.")
			user.drop_item()
			W.forceMove(src)
			tank = W
			playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
		return

	..()

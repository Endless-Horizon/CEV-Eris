#define STYLE_NEG_HIGH -2
#define STYLE_NEG_LOW -1
#define STYLE_NONE 0
#define STYLE_LOW 1
#define STYLE_HIGH 2

/obj/item/clothing
	name = "clothing"
	siemens_coefficient = 0.9
	item_flags = DRAG_AND_DROP_UNEQUIP
	bad_type = /obj/item/clothing
	rarity_value = 5
	spawn_frequency = 10
	spawn_tags = SPAWN_TAG_CLOTHING
	var/flash_protection = FLASH_PROTECTION_NONE	// Sets the item's level of flash protection.
	var/tint = TINT_NONE							// Sets the item's level of visual impairment tint.
	var/list/species_restricted				// Only these species can wear this kit.
	var/gunshot_residue								// Used by forensics.
	var/initial_name = "clothing"					// For coloring

	var/list/accessories = list()
	var/list/valid_accessory_slots
	var/list/restricted_accessory_slots
	var/equip_delay = 0 //If set to a nonzero value, the item will require that much time to wear and remove

	//Used for hardsuits. If false, this piece cannot be retracted while the core module is engaged
	var/retract_while_active = TRUE

	var/style = STYLE_NONE

/obj/item/clothing/Initialize(mapload, ...)
	. = ..()

	var/obj/screen/item_action/action = new /obj/screen/item_action/top_bar/clothing_info
	action.owner = src
	if(!islist(hud_actions)) hud_actions = list()
	hud_actions += action

	if(matter)
		return

	else if(!matter)
		matter = list()

	matter.Add(list(MATERIAL_BIOMATTER = 5 * w_class))    // based of item size

/obj/item/clothing/Destroy()
	for(var/obj/item/clothing/accessory/A in accessories)
		qdel(A)
	accessories = null
	return ..()

/obj/item/clothing/proc/get_style()
	var/real_style = style
	if(blood_DNA)
		real_style -= 1
	return real_style

// Aurora forensics port.
/obj/item/clothing/clean_blood()
	. = ..()
	gunshot_residue = null

//Delayed equipping
/obj/item/clothing/pre_equip(mob/user, slot)
	..(user, slot)
	if (equip_delay > 0)
		//If its currently worn, we must be taking it off
		if (is_worn())
			user.visible_message(
				SPAN_NOTICE("[user] starts taking off \the [src]..."),
				SPAN_NOTICE("You start taking off \the [src]...")
			)
			if(!do_after(user,equip_delay,src))
				return TRUE //A nonzero return value will cause the equipping operation to fail

		else if (is_held() && !(slot in unworn_slots))
			user.visible_message(
				SPAN_NOTICE("[user] starts putting on \the [src]..."),
				SPAN_NOTICE("You start putting on \the [src]...")
			)
			if(!do_after(user,equip_delay,src))
				return TRUE //A nonzero return value will cause the equipping operation to fail

// To catch MouseDrop on clothing
/obj/item/clothing/MouseDrop(over_object)
	if(!(item_flags & DRAG_AND_DROP_UNEQUIP))
		return ..()
	if(!pre_equip(usr, over_object))
		..()

/proc/body_part_coverage_to_string(body_parts)
	var/list/body_partsL = list()
	if(body_parts & HEAD)
		body_partsL.Add("head")
	if(body_parts & FACE)
		body_partsL.Add("face")
	if(body_parts & EYES)
		body_partsL.Add("eyes")
	if(body_parts & EARS)
		body_partsL.Add("ears")
	if(body_parts & UPPER_TORSO)
		body_partsL.Add("upper torso")
	if(body_parts & LOWER_TORSO)
		body_partsL.Add("lower torso")
	if(body_parts & LEGS)
		body_partsL.Add("legs")
	else
		if(body_parts & LEG_LEFT)
			body_partsL.Add("left leg")
		if(body_parts & LEG_RIGHT)
			body_partsL.Add("right leg")
	if(body_parts & ARMS)
		body_partsL.Add("arms")
	else
		if(body_parts & ARM_LEFT)
			body_partsL.Add("left arm")
		if(body_parts & ARM_RIGHT)
			body_partsL.Add("right arm")

	return english_list(body_partsL)

/obj/item/clothing/nano_ui_data()
	var/list/data = list()
	var/list/armorlist = armor.getList()
	if(armorlist.len)
		var/list/armor_vals = list()
		for(var/i in armorlist)
			if(armorlist[i])
				armor_vals += list(list(
					"name" = i,
					"value" = armorlist[i]
					))
		data["armor_info"] = armor_vals
	if(body_parts_covered)
		var/body_part_string = body_part_coverage_to_string(body_parts_covered)
		data["body_coverage"] = body_part_string
	data["slowdown"] = slowdown
	if(heat_protection)
		data["heat_protection"] = body_part_coverage_to_string(heat_protection)
		data["heat_protection_temperature"] = max_heat_protection_temperature
	if(cold_protection)
		data["cold_protection"] = body_part_coverage_to_string(cold_protection)
		data["cold_protection_temperature"] = min_cold_protection_temperature
	data["equip_delay"] = equip_delay
	return data

/obj/item/clothing/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, state = GLOB.default_state)
	var/list/data = nano_ui_data(user)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "clothing_stats.tmpl", name, 650, 550, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()

/obj/item/clothing/ui_action_click(mob/living/user, action_name)
	if(action_name == "Clothing information")
		nano_ui_interact(user)
		return TRUE
	return ..()

/obj/screen/item_action/top_bar/clothing_info
	icon = 'icons/mob/screen/gun_actions.dmi'
	screen_loc = "8,1:13"
	minloc = "7,2:13"
	name = "Clothing information"
	icon_state = "info"


///////////////////////////////////////////////////////////////////////
// Ears: headsets, earmuffs and tiny objects
/obj/item/clothing/ears
	name = "ears"
	w_class = ITEM_SIZE_TINY
	throwforce = 2
	slot_flags = SLOT_EARS
	bad_type = /obj/item/clothing/ears

/obj/item/clothing/ears/attack_hand(mob/user)
	if (!user) return

	if (src.loc != user || !ishuman(user))
		..()
		return

	var/mob/living/carbon/human/H = user
	if(H.l_ear != src && H.r_ear != src)
		..()
		return

	if(!canremove)
		return

	var/obj/item/clothing/ears/O
	if(slot_flags & SLOT_TWOEARS )
		O = (H.l_ear == src ? H.r_ear : H.l_ear)
		user.u_equip(O)
		if(!istype(src,/obj/item/clothing/ears/offear))
			qdel(O)
			O = src
	else
		O = src

	user.u_equip(src)

	if (O)
		user.put_in_hands(O)
		O.add_fingerprint(user)

	if(istype(src,/obj/item/clothing/ears/offear))
		qdel(src)

/obj/item/clothing/ears/offear
	name = "Other ear"
	w_class = ITEM_SIZE_HUGE
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "blocked"
	slot_flags = SLOT_EARS | SLOT_TWOEARS
	spawn_tags = null
	var/obj/item/master_item

/obj/item/clothing/ears/offear/New(obj/O)
	.=..()
	name = O.name
	desc = O.desc
	icon = O.icon
	icon_state = O.icon_state
	w_class = O.w_class
	set_dir(O.dir)
	master_item = O

/obj/item/clothing/ears/offear/can_be_equipped(mob/living/user, slot, disable_warning)
	var/other_slot = (slot == slot_l_ear) ? slot_r_ear : slot_l_ear
	if(user.get_equipped_item(other_slot) != master_item || user.get_equipped_item(slot))
		return FALSE
	return ..()

/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	slot_flags = SLOT_EARS | SLOT_TWOEARS


///////////////////////////////////////////////////////////////////////
//Glasses
/*
SEE_SELF  // can see self, no matter what
SEE_MOBS  // can see all mobs, no matter what
SEE_OBJS  // can see all objs, no matter what
SEE_TURFS // can see all turfs (and areas), no matter what
SEE_PIXELS// if an object is located on an unlit area, but some of its pixels are
          // in a lit area (via pixel_x,y or smooth movement), can see those pixels
BLIND     // can't see anything
*/
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/inventory/eyes/icon.dmi'
	w_class = ITEM_SIZE_SMALL
	body_parts_covered = EYES
	slot_flags = SLOT_EYES
	bad_type = /obj/item/clothing/glasses
	var/vision_flags = 0
	var/darkness_view = 0//Base human is 2
	var/see_invisible = -1
	var/have_lenses = 0
	var/protection = 0

///////////////////////////////////////////////////////////////////////
//Gloves
/obj/item/clothing/gloves
	name = "gloves"
	gender = PLURAL //Carn: for grammarically correct text-parsing
	w_class = ITEM_SIZE_SMALL
	icon = 'icons/inventory/hands/icon.dmi'
	siemens_coefficient = 0.75
	bad_type = /obj/item/clothing/gloves
	spawn_tags = SPAWN_TAG_GLOVES
	body_parts_covered = ARMS
	armor = list(melee = 10, bullet = 0, energy = 15, bomb = 0, bio = 0, rad = 0)
	slot_flags = SLOT_GLOVES
	attack_verb = list("challenged")
	var/wired = 0
	var/clipped = 0

// Called just before an attack_hand(), in mob/UnarmedAttack()
/obj/item/clothing/gloves/proc/Touch(atom/A, proximity)
	return 0 // return 1 to cancel attack_hand()

/obj/item/clothing/gloves/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/tool/wirecutters) || istype(W, /obj/item/weapon/tool/scalpel))
		if (clipped)
			to_chat(user, SPAN_NOTICE("The [src] have already been clipped!"))
			update_icon()
			return

		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		user.visible_message("\red [user] cuts the fingertips off of the [src].","\red You cut the fingertips off of the [src].")

		clipped = 1
		name = "modified [name]"
		desc = "[desc]<br>They have had the fingertips cut off of them."
		return

///////////////////////////////////////////////////////////////////////
//Head
/obj/item/clothing/head
	name = "head"
	icon = 'icons/inventory/head/icon.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items/lefthand_hats.dmi',
		slot_r_hand_str = 'icons/mob/items/righthand_hats.dmi',
		)
	body_parts_covered = HEAD
	slot_flags = SLOT_HEAD
	w_class = ITEM_SIZE_SMALL
	bad_type = /obj/item/clothing/head
	spawn_tags = SPAWN_TAG_CLOTHING_HEAD
	style = STYLE_HIGH

	var/light_overlay = "helmet_light"
	var/light_applied
	var/brightness_on
	var/on = FALSE

/obj/item/clothing/head/attack_self(mob/user)
	if(brightness_on)
		if(!isturf(user.loc))
			to_chat(user, "You cannot turn the light on while in this [user.loc]")
			return
		on = !on
		to_chat(user, "You [on ? "enable" : "disable"] the helmet light.")
		update_flashlight(user)
	else
		return ..(user)

/obj/item/clothing/head/proc/update_flashlight(mob/user = null)
	if(on && !light_applied)
		set_light(brightness_on)
		light_applied = 1
	else if(!on && light_applied)
		set_light(0)
		light_applied = 0
	update_icon(user)
	user.update_action_buttons()

/obj/item/clothing/head/attack_ai(mob/user)
	if(!mob_wear_hat(user))
		return ..()

/obj/item/clothing/head/attack_generic(mob/user)
	if(!istype(user) || !mob_wear_hat(user))
		return ..()

/obj/item/clothing/head/proc/mob_wear_hat(mob/user)
	if(!Adjacent(user))
		return 0
	var/success
	if(isdrone(user))
		var/mob/living/silicon/robot/drone/D = user
		if(D.hat)
			success = 2
		else
			D.wear_hat(src)
			success = 1

	if(!success)
		return 0
	else if(success == 2)
		to_chat(user, SPAN_WARNING("You are already wearing a hat."))
	else if(success == 1)
		to_chat(user, SPAN_NOTICE("You crawl under \the [src]."))
	return 1

/obj/item/clothing/head/on_update_icon(mob/user)

	cut_overlays()
	var/mob/living/carbon/human/H
	if(ishuman(user))
		H = user

	if(on)

		// Generate object icon.
		if(!light_overlay_cache["[light_overlay]_icon"])
			light_overlay_cache["[light_overlay]_icon"] = image('icons/obj/light_overlays.dmi', light_overlay)
		associate_with_overlays(light_overlay_cache["[light_overlay]_icon"])

		// Generate and cache the on-mob icon, which is used in update_inv_head().
		var/cache_key = "[light_overlay][H ? "_[H.species.get_bodytype()]" : ""]"
		if(!light_overlay_cache[cache_key])
			light_overlay_cache[cache_key] = image('icons/mob/light_overlays.dmi', light_overlay)

	if(H)
		H.update_inv_head()

///////////////////////////////////////////////////////////////////////
//Mask
/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/inventory/face/icon.dmi'
	body_parts_covered = HEAD
	slot_flags = SLOT_MASK
	body_parts_covered = FACE|EYES
	bad_type = /obj/item/clothing/mask
	spawn_tags = SPAWN_TAG_MASK

	var/voicechange = 0
	var/list/say_messages
	var/list/say_verbs

/obj/item/clothing/mask/proc/filter_air(datum/gas_mixture/air)
	return

///////////////////////////////////////////////////////////////////////
//Shoes
/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/inventory/feet/icon.dmi'
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammarically correct text-parsing
	siemens_coefficient = 0.9
	body_parts_covered = LEGS
	slot_flags = SLOT_FEET
	spawn_tags = SPAWN_TAG_SHOES
	bad_type = /obj/item/clothing/shoes

	armor = list(melee = 10, bullet = 0, energy = 10, bomb = 0, bio = 0, rad = 0)
	permeability_coefficient = 0.50
	slowdown = SHOES_SLOWDOWN
	force = 2

	var/can_hold_knife = 0
	var/obj/item/holding
	var/noslip = 0
	var/module_inside = 0

/obj/item/clothing/shoes/proc/draw_knife()
	set name = "Draw Boot Knife"
	set desc = "Pull out your boot knife."
	set category = "IC"
	set src in usr

	if(usr.stat || usr.restrained() || usr.incapacitated())
		return

	if(!holding)
		to_chat(usr, SPAN_WARNING("\The [src] has no knife."))
		return

	holding.forceMove(get_turf(usr))

	if(usr.put_in_hands(holding))
		usr.visible_message(SPAN_DANGER("\The [usr] pulls a knife out of their boot!"))
		holding = null
	else
		to_chat(usr, SPAN_WARNING("You need an empty, unbroken hand to do that."))
		holding.forceMove(src)

	if(!holding)
		verbs -= /obj/item/clothing/shoes/proc/draw_knife

	update_icon()
	return

/obj/item/clothing/shoes/AltClick()
	if((src in usr) && holding)
		draw_knife()
	else
		..()

/obj/item/clothing/shoes/attack_hand()
	if((src in usr) && holding)
		draw_knife()
	else
		..()

/obj/item/clothing/shoes/attackby(obj/item/I, mob/user)
	var/global/knifes
	if(istype(I,/obj/item/noslipmodule))
		if (item_flags != 0)
			noslip = item_flags
		module_inside = 1
		to_chat(user, "You attached no slip sole")
		permeability_coefficient = 0.05
		item_flags = NOSLIP | SILENT
		origin_tech = list(TECH_COVERT = 3)
		siemens_coefficient = 0 // DAMN BOI
		qdel(I)

	if(!knifes)
		knifes = list(
			/obj/item/weapon/tool/knife,
			/obj/item/weapon/material/shard,
			/obj/item/weapon/tool/knife/butterfly,
			/obj/item/weapon/material/kitchen/utensil,
			/obj/item/weapon/tool/knife/tacknife,
			/obj/item/weapon/tool/shiv,
		)
	if(can_hold_knife && is_type_in_list(I, knifes))
		if(holding)
			to_chat(user, SPAN_WARNING("\The [src] is already holding \a [holding]."))
			return
		if(user.unEquip(I, src))
			holding = I
			user.visible_message(SPAN_NOTICE("\The [user] shoves \the [I] into \the [src]."))
			verbs |= /obj/item/clothing/shoes/proc/draw_knife
			update_icon()
	else
		return ..()

/obj/item/clothing/shoes/verb/detach_noslipmodule()
	set name = "Detach acccessory"
	set category = "Object"
	set src in view(1)

	if (module_inside == 1 )
		if (noslip != 0)
			item_flags = noslip
		var/obj/item/noslipmodule/NSM = new()
		usr.put_in_hands(NSM)
	else to_chat(usr, "You haven't got any accessories in your shoes")


/obj/item/clothing/shoes/on_update_icon()
	cut_overlays()
	if(holding)
		add_overlays(image(icon, "[icon_state]_knife"))
	return ..()

/obj/item/clothing/shoes/proc/handle_movement(turf/walking, running)
	return


///////////////////////////////////////////////////////////////////////
//Suit
/obj/item/clothing/suit
	icon = 'icons/inventory/suit/icon.dmi'
	name = "suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	allowed = list(
		/obj/item/weapon/clipboard,
		/obj/item/weapon/storage/pouch/,
		/obj/item/weapon/gun,
		/obj/item/weapon/melee,
		/obj/item/weapon/tool,
		/obj/item/weapon/material,
		/obj/item/ammo_magazine,
		/obj/item/ammo_casing,
		/obj/item/weapon/handcuffs,
		/obj/item/weapon/tank,
		/obj/item/device/suit_cooling_unit,
		/obj/item/weapon/cell,
		/obj/item/weapon/storage/fancy,
		/obj/item/weapon/flamethrower,
		/obj/item/device/lighting,
		/obj/item/device/scanner,
		/obj/item/weapon/reagent_containers/spray,
		/obj/item/device/radio,
		/obj/item/clothing/mask)
	slot_flags = SLOT_OCLOTHING
	var/blood_overlay_type = "suit"
	siemens_coefficient = 0.9
	w_class = ITEM_SIZE_NORMAL
	equip_delay = 1 SECONDS
	bad_type = /obj/item/clothing/suit
	var/fire_resist = T0C+100
	var/list/extra_allowed = list()
	style = STYLE_HIGH

/obj/item/clothing/suit/Initialize(mapload, ...)
	.=..()
	allowed |= extra_allowed

///////////////////////////////////////////////////////////////////////
//Under clothing
/obj/item/clothing/under
	icon = 'icons/inventory/uniform/icon.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items/lefthand_uniforms.dmi',
		slot_r_hand_str = 'icons/mob/items/righthand_uniforms.dmi',
		)
	name = "jumpsuit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	permeability_coefficient = 0.90
	slot_flags = SLOT_ICLOTHING
	w_class = ITEM_SIZE_NORMAL
	spawn_tags = SPAWN_TAG_CLOTHING_UNDER
	bad_type = /obj/item/clothing/under
	var/has_sensor = 1 //For the crew computer 2 = unable to change mode
	var/sensor_mode = 0
		/*
		1 = Report living/dead
		2 = Report detailed damages
		3 = Report location
		*/
	var/displays_id = 1
	equip_delay = 2 SECONDS

	//convenience var for defining the icon state for the overlay used when the clothing is worn.

	valid_accessory_slots = list("utility","armband","decor")
	restricted_accessory_slots = list("utility", "armband")


/obj/item/clothing/under/attack_hand(mob/user)
	if(accessories && accessories.len)
		..()
	if ((ishuman(usr) || issmall(usr)) && src.loc == user)
		return
	..()

/obj/item/clothing/under/New()
	..()
	item_state_slots[slot_w_uniform_str] = icon_state //TODO: drop or gonna use it?

/obj/item/clothing/under/examine(mob/user)
	..(user)
	switch(src.sensor_mode)
		if(0)
			to_chat(user, "Its sensors appear to be disabled.")
		if(1)
			to_chat(user, "Its binary life sensors appear to be enabled.")
		if(2)
			to_chat(user, "Its vital tracker appears to be enabled.")
		if(3)
			to_chat(user, "Its vital tracker and tracking beacon appear to be enabled.")

/obj/item/clothing/under/proc/set_sensors(mob/M)
	if(has_sensor >= 2)
		to_chat(usr, "The controls are locked.")
		return 0
	if(has_sensor <= 0)
		to_chat(usr, "This suit does not have any sensors.")
		return 0

	if(sensor_mode == 3)
		sensor_mode = 0
	else
		sensor_mode++

	if (src.loc == usr)
		switch(sensor_mode)
			if(0)
				to_chat(usr, "You disable your suit's remote sensing equipment.")
			if(1)
				to_chat(usr, "Your suit will now report whether you are live or dead.")
			if(2)
				to_chat(usr, "Your suit will now report your vital lifesigns.")
			if(3)
				to_chat(usr, "Your suit will now report your vital lifesigns as well as your coordinate position.")
	else if (ismob(loc))
		switch(sensor_mode)
			if(0)
				for(var/mob/V in viewers(usr, 1))
					V.show_message("\red [usr] disables [src.loc]'s remote sensing equipment.", 1)
			if(1)
				for(var/mob/V in viewers(usr, 1))
					V.show_message("[usr] turns [src.loc]'s remote sensors to binary.", 1)
			if(2)
				for(var/mob/V in viewers(usr, 1))
					V.show_message("[usr] sets [src.loc]'s sensors to track vitals.", 1)
			if(3)
				for(var/mob/V in viewers(usr, 1))
					V.show_message("[usr] sets [src.loc]'s sensors to maximum.", 1)

/obj/item/clothing/under/rank
	bad_type = /obj/item/clothing/under/rank
	spawn_blacklisted = TRUE

/obj/item/clothing/under/rank/New()
	sensor_mode = 3
	..()

/obj/item/clothing/under/attackby(obj/item/I, mob/U)
	if(I.get_tool_type(usr, list(QUALITY_SCREW_DRIVING), src) && ishuman(U))
		set_sensors(U)
	else
		return ..()

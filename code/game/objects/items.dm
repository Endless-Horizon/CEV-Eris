/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'
	w_class = ITEM_SIZE_NORMAL

	//spawn_values
	price_tag = 0
	//spawn_tags = SPAWN_TAG_ITEM
	rarity_value = 10
	spawn_frequency = 10
	bad_type = /obj/item

	pass_flags = PASSTABLE
	var/image/blood_overlay //this saves our blood splatter overlay, which will be processed not to go over the edges of the sprite
	var/randpixel = 6
	var/abstract = 0
	var/r_speed = 1
	var/health
	var/max_health
	var/burn_point
	var/burning
	var/hitsound
	var/worksound
	var/no_attack_log = 0			//If it's an item we don't want to log attack_logs with, set this to 1

	var/obj/item/master
	var/list/origin_tech = list()	//Used by R&D to determine what research bonuses it grants.
	var/list/attack_verb = list() //Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"


	var/heat_protection = 0 //flags which determine which body parts are protected from heat. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/cold_protection = 0 //flags which determine which body parts are protected from cold. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by heat_protection flags
	var/min_cold_protection_temperature //Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by cold_protection flags

	var/datum/action/item_action/action
	var/action_button_name //It is also the text which gets displayed on the action button. If not set it defaults to 'Use [name]'. If it's not set, there'll be no button.
	var/action_button_is_hands_free = 0 //If 1, bypass the restrained, lying, and stunned checks action buttons normally test for

	//This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	//It should be used purely for appearance. For gameplay effects caused by items covering body parts, use body_parts_covered.
	var/flags_inv = 0
	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags

	var/list/tool_qualities// List of item qualities for tools system. See qualities.dm.
	var/list/aspects = list()

	//var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown = 0 // How much clothing is slowing you down. Negative values speeds you up
	var/datum/armor/armor // Ref to the armor datum
	var/list/allowed = list() //suit storage stuff.
	var/obj/item/device/uplink/hidden/hidden_uplink // All items can have an uplink hidden inside, just remember to add the triggers.
	var/zoomdevicename //name used for message when binoculars/scope is used
	var/zoom = 0 //1 if item is actively being used to zoom. For scoped guns and binoculars.

	var/contained_sprite = FALSE //TRUE if object icon and related mob overlays are all in one dmi

	var/icon_override  //Used to override hardcoded clothing dmis in human clothing proc.

	//** These specify item/icon overrides for _slots_

	var/list/item_state_slots = list() //overrides the default item_state for particular slots.

	// Used to specify the icon file to be used when the item is worn. If not set the default icon for that slot will be used.
	// If icon_override or sprite_sheets are set they will take precendence over this, assuming they apply to the slot in question.
	// Only slot_l_hand/slot_r_hand are implemented at the moment. Others to be implemented as needed.
	var/list/item_icons = list()

	// HUD action buttons. Only used by guns atm.
	var/list/hud_actions

	//Damage vars
	var/force = 0	//How much damage the weapon deals
	var/embed_mult = 0.5 //Multiplier for the chance of embedding in mobs. Set to zero to completely disable embedding
	var/structure_damage_factor = STRUCTURE_DAMAGE_NORMAL	//Multiplier applied to the damage when attacking structures and machinery
	//Does not affect damage dealt to mobs

	var/list/item_upgrades = list()
	var/max_upgrades = 3

/obj/item/Initialize()
	if(islist(armor))
		armor = getArmor(arglist(armor))
	else if(!armor)
		armor = getArmor()
	else if(!istype(armor, /datum/armor))
		error("Invalid type [armor.type] found in .armor during /obj Initialize()")
	. = ..()

/obj/item/Destroy()
	QDEL_NULL(hidden_uplink)
	QDEL_NULL(blood_overlay)
	QDEL_NULL(action)
	if(ismob(loc))
		var/mob/m = loc
		m.u_equip(src)
		remove_hud_actions(m)
		loc = null
	if(hud_actions)
		for(var/action in hud_actions)
			qdel(action)
		hud_actions = null

	return ..()

/obj/item/get_fall_damage()
	return w_class * 2

/obj/item/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50))
				qdel(src)
		if(3)
			if(prob(5))
				qdel(src)

/obj/item/verb/move_to_top()
	set name = "Move To Top"
	set category = "Object"
	set src in oview(1)

	if(!istype(loc, /turf) || usr.stat || usr.restrained() )
		return

	var/turf/T = loc

	loc = null

	loc = T

/obj/item/examine(user, distance = -1)
	var/message
	var/size
	switch(w_class)
		if(ITEM_SIZE_TINY)
			size = "tiny"
		if(ITEM_SIZE_SMALL)
			size = "small"
		if(ITEM_SIZE_NORMAL)
			size = "normal-sized"
		if(ITEM_SIZE_BULKY)
			size = "bulky"
		if(ITEM_SIZE_HUGE)
			size = "huge"
		if(ITEM_SIZE_GARGANTUAN)
			size = "gargantuan"
		if(ITEM_SIZE_COLOSSAL)
			size = "colossal"
		if(ITEM_SIZE_TITANIC)
			size = "titanic"
	message += "\nIt is a [size] item."

	for(var/Q in tool_qualities)
		message += "\n<blue>It possesses [tool_qualities[Q]] tier of [Q] quality.<blue>"

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.stats.getPerk(PERK_MARKET_PROF))
			message += SPAN_NOTICE("\nThis item cost: [get_item_cost()][CREDITS]")

	return ..(user, distance, "", message)

/obj/item/attack_hand(mob/user as mob)
	if(pre_pickup(user))
		pickup(user)
		return TRUE
	return FALSE

//	Places item in active hand and invokes pickup animation
//	NOTE: This proc was created and replaced previous pickup() proc which is now called pre_pickup() as it makes more sense
//	keep that in mind when porting items form other builds
/obj/item/proc/pickup(mob/target)
	throwing = 0
	var/atom/old_loc = loc
	if(target.put_in_active_hand(src) && old_loc )
		if((target != old_loc) && (target != old_loc.get_holding_mob()))
			do_pickup_animation(target,old_loc)
		SEND_SIGNAL(src, COMSIG_ITEM_PICKED, src, target)
	add_hud_actions(target)

/obj/item/attack_ai(mob/user as mob)
	if(istype(loc, /obj/item/weapon/robot_module))
		//If the item is part of a cyborg module, equip it
		if(!isrobot(user))
			return
		var/mob/living/silicon/robot/R = user
		R.activate_module(src)
	//R.hud_used.update_robot_modules_display()

/obj/item/proc/talk_into(mob/living/M, message, channel, verb = "says", datum/language/speaking = null, speech_volume)
	return

/obj/item/proc/moved(mob/user as mob, old_loc as turf)
	return

// Called whenever an object is moved out of a mob's equip slot. Possibly into another slot, possibly to elsewhere
// Linker proc: mob/proc/prepare_for_slotmove, which is referenced in proc/handle_item_insertion and obj/item/attack_hand.
// This exists so that dropped() could exclusively be called when an item is dropped.
/obj/item/proc/on_slotmove(mob/user)
	if(wielded)
		unwield(user)
	if(zoom)
		zoom(user)


//	Called before an item is picked up (loc is not yet changed)
//	NOTE: This proc name was changed form pickup() as it makes more sense
//	keep that in mind when porting items form other builds
/obj/item/proc/pre_pickup(mob/user)
	return TRUE

// called when this item is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/obj/item/proc/on_exit_storage(obj/item/weapon/storage/the_storage)
	SEND_SIGNAL(the_storage, COMSIG_STORAGE_TAKEN, src, the_storage)
	return

// called when this item is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/obj/item/proc/on_enter_storage(obj/item/weapon/storage/the_storage)
	SEND_SIGNAL(the_storage, COMSIG_STORAGE_INSERTED, src, the_storage)
	return

// called when "found" in pockets and storage items. Returns 1 if the search should end.
/obj/item/proc/on_found(mob/finder as mob)
	return
/obj/item/verb/verb_pickup()
	set src in oview(1)
	set category = "Object"
	set name = "Pick up"

	if(!usr) //BS12 EDIT
		return
	if(!usr.canmove || usr.stat || usr.restrained() || !Adjacent(usr))
		return
	if(!iscarbon(usr) || isbrain(usr))//Is humanoid, and is not a brain
		to_chat(usr, SPAN_WARNING("You can't pick things up!"))
		return
	if( usr.stat || usr.restrained() )//Is not asleep/dead and is not restrained
		to_chat(usr, SPAN_WARNING("You can't pick things up!"))
		return
	if(anchored) //Object isn't anchored
		to_chat(usr, SPAN_WARNING("You can't pick that up!"))
		return
	if(!usr.hand && usr.r_hand) //Right hand is not full
		to_chat(usr, SPAN_WARNING("Your right hand is full."))
		return
	if(usr.hand && usr.l_hand) //Left hand is not full
		to_chat(usr, SPAN_WARNING("Your left hand is full."))
		return
	if(!istype(loc, /turf)) //Object is on a turf
		to_chat(usr, SPAN_WARNING("You can't pick that up!"))
		return
	//All checks are done, time to pick it up!
	usr.UnarmedAttack(src)


//This proc is executed when someone clicks the on-screen UI button. To make the UI button show, set the 'icon_action_button' to the icon_state of the image of the button in screen1_action.dmi
//The default action is attack_self().
//Checks before we get to here are: mob is alive, mob is not restrained, paralyzed, asleep, resting, laying, item is on the mob.
/obj/item/proc/ui_action_click(mob/living/user, action_name)
	attack_self(usr)

//RETURN VALUES
//handle_shield should return a positive value to indicate that the attack is blocked and should be prevented.
//If a negative value is returned, it should be treated as a special return value for bullet_act() and handled appropriately.
//For non-projectile attacks this usually means the attack is blocked.
//Otherwise should return 0 to indicate that the attack is not affected in any way.
/obj/item/proc/handle_shield(mob/user, damage, atom/damage_source = null, mob/attacker = null, def_zone = null, attack_text = "the attack")
	return 0

/obj/item/proc/get_loc_turf()
	var/atom/L = loc
	while(L && !istype(L, /turf/))
		L = L.loc
	return loc

/obj/item/proc/eyestab(mob/living/carbon/M as mob, mob/living/carbon/user as mob)

	var/mob/living/carbon/human/H = M
	if(istype(H))
		for(var/obj/item/protection in list(H.head, H.wear_mask, H.glasses))
			if(protection && (protection.body_parts_covered & EYES))
				// you can't stab someone in the eyes wearing a mask!
				to_chat(user, SPAN_WARNING("You're going to need to remove the eye covering first."))
				return

	if(!M.has_eyes())
		to_chat(user, SPAN_WARNING("You cannot locate any eyes on [M]!"))
		return

	user.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [M.name] ([M.ckey]) with [name] (INTENT: [uppertext(user.a_intent)])</font>"
	M.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [user.name] ([user.ckey]) with [name] (INTENT: [uppertext(user.a_intent)])</font>"
	msg_admin_attack("[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [name] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)") //BS12 EDIT ALG

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	user.do_attack_animation(M)

	add_fingerprint(user)
	//if((CLUMSY in user.mutations) && prob(50))
	//	M = user
		/*
		to_chat(M, SPAN_WARNING("You stab yourself in the eye."))
		M.sdisabilities |= BLIND
		M.weakened += 4
		M.adjustBruteLoss(10)
		*/

	if(istype(H))

		var/obj/item/organ/internal/eyes/eyes = H.random_organ_by_process(OP_EYES)

		if(!eyes)
			return

		if(H != user)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message(SPAN_DANGER("[M] has been stabbed in the eye with [src] by [user]."), 1)
			to_chat(M, SPAN_DANGER("[user] stabs you in the eye with [src]!"))
			to_chat(user, SPAN_DANGER("You stab [M] in the eye with [src]!"))
		else
			user.visible_message( \
				SPAN_DANGER("[user] has stabbed themself with [src]!"), \
				SPAN_DANGER("You stab yourself in the eyes with [src]!") \
			)

		eyes.damage += rand(3,4)
		if(eyes.damage >= eyes.min_bruised_damage)
			if(M.stat != DEAD)
				if(BP_IS_ORGANIC(eyes) || BP_IS_ASSISTED(eyes)) //robot eyes bleeding might be a bit silly
					to_chat(M, SPAN_DANGER("Your eyes start to bleed profusely!"))
			if(prob(50))
				if(M.stat != DEAD)
					to_chat(M, SPAN_WARNING("You drop what you're holding and clutch at your eyes!"))
					M.drop_item()
				M.eye_blurry += 10
				M.Paralyse(1)
				M.Weaken(4)
			if(eyes.damage >= eyes.min_broken_damage)
				if(M.stat != 2)
					to_chat(M, SPAN_WARNING("You go blind!"))
		var/obj/item/organ/external/affecting = H.get_organ(BP_HEAD)
		if(affecting.take_damage(7))
			M:UpdateDamageIcon()
	else
		M.take_organ_damage(7)
	M.eye_blurry += rand(3,4)

/obj/item/clean_blood()
	. = ..()
	if(blood_overlay)
		overlays.Remove(blood_overlay)

/obj/item/clothing/gloves/clean_blood()
	.=..()
	transfer_blood = 0

/obj/item/reveal_blood()
	if(was_bloodied && !fluorescent)
		fluorescent = 1
		blood_color = COLOR_LUMINOL
		blood_overlay.color = COLOR_LUMINOL
		update_icon()

/obj/item/add_blood(mob/living/carbon/human/M as mob)
	if(!..())
		return 0

	if(istype(src, /obj/item/weapon/melee/energy))
		return

	if((flags & NOBLOODY)||(item_flags & NOBLOODY))
		return

	//if we haven't made our blood_overlay already
	if( !blood_overlay )
		generate_blood_overlay()

	//apply the blood-splatter overlay if it isn't already in there
	if(!blood_DNA.len)
		blood_overlay.color = blood_color
		add_overlays(blood_overlay)

	//if this blood isn't already in the list, add it
	if(istype(M))
		if(blood_DNA[M.dna.unique_enzymes])
			return 0 //already bloodied with this blood. Cannot add more.
		blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
	return 1 //we applied blood to the item

var/global/list/items_blood_overlay_by_type = list()
/obj/item/proc/generate_blood_overlay()
	if(blood_overlay)
		return

	var/image/IMG = items_blood_overlay_by_type[type]
	if(IMG)
		blood_overlay = IMG
	else
		var/icon/ICO = new /icon(icon, icon_state)
		ICO.Blend(new /icon('icons/effects/blood.dmi', rgb(255, 255, 255)), ICON_ADD) // fills the icon_state with white (except where it's transparent)
		ICO.Blend(new /icon('icons/effects/blood.dmi', "itemblood"), ICON_MULTIPLY)   // adds blood and the remaining white areas become transparant
		IMG = image("icon" = ICO)
		items_blood_overlay_by_type[type] = IMG
		blood_overlay = IMG

/obj/item/proc/showoff(mob/user)
	for (var/mob/M in view(user))
		M.show_message("[user] holds up [src]. <a HREF=?src=\ref[M];lookitem=\ref[src]>Take a closer look.</a>",1)

/mob/living/carbon/verb/showoff()
	set name = "Show Held Item"
	set category = "Object"

	var/obj/item/I = get_active_hand()
	if(I && !I.abstract)
		I.showoff(src)

/*
For zooming with scope or binoculars. This is called from
modules/mob/mob_movement.dm if you move you will be zoomed out
modules/mob/living/carbon/human/life.dm if you die, you will be zoomed out.
*/
//Looking through a scope or binoculars should /not/ improve your periphereal vision. Still, increase viewsize a tiny bit so that sniping isn't as restricted to NSEW
/obj/item/proc/zoom(tileoffset = 14,viewsize = 9) //tileoffset is client view offset in the direction the user is facing. viewsize is how far out this thing zooms. 7 is normal view
	if(!usr)
		return

	var/devicename

	if(zoomdevicename)
		devicename = zoomdevicename
	else
		devicename = name

	var/cannotzoom

	if(usr.stat || !(ishuman(usr)))
		to_chat(usr, "You are unable to focus through the [devicename]")
		cannotzoom = 1
	else if(!zoom && (global_hud.darkMask[1] in usr.client.screen))
		to_chat(usr, "Your visor gets in the way of looking through the [devicename]")
		cannotzoom = 1
	else if(!zoom && usr.get_active_hand() != src)
		to_chat(usr, "You are too distracted to look through the [devicename]. Perhaps if it was in your active hand you could look through it.")
		cannotzoom = 1

	if(!zoom && !cannotzoom)
		//if(usr.hud_used.hud_shown)
			//usr.toggle_zoom_hud()	// If the user has already limited their HUD this avoids them having a HUD when they zoom in
		usr.client.view = viewsize
		zoom = 1

		var/tilesize = 32
		var/viewoffset = tilesize * tileoffset

		switch(usr.dir)
			if(NORTH)
				usr.client.pixel_x = 0
				usr.client.pixel_y = viewoffset
			if(SOUTH)
				usr.client.pixel_x = 0
				usr.client.pixel_y = -viewoffset
			if(EAST)
				usr.client.pixel_x = viewoffset
				usr.client.pixel_y = 0
			if(WEST)
				usr.client.pixel_x = -viewoffset
				usr.client.pixel_y = 0

		usr.visible_message("[usr] peers through the [zoomdevicename ? "[zoomdevicename] of the [name]" : "[name]"].")

	else
		usr.client.view = world.view
		//if(!usr.hud_used.hud_shown)
			//usr.toggle_zoom_hud()
		zoom = 0

		usr.client.pixel_x = 0
		usr.client.pixel_y = 0

		if(!cannotzoom)
			usr.visible_message("[zoomdevicename ? "[usr] looks up from the [name]" : "[usr] lowers the [name]"].")
	usr.parallax.update()
	return

/obj/item/proc/pwr_drain()
	return PROCESS_KILL // Process Kill


//Called when a human swaps hands to a hand which is holding this item
/obj/item/proc/swapped_to(mob/user)
	add_hud_actions(user)

//Called when a human swaps hands away from a hand which is holding this item
/obj/item/proc/swapped_from(mob/user)
	remove_hud_actions(user)

/obj/item/proc/add_hud_actions(mob/user)
	if(!hud_actions || !user.client)
		return

	update_hud_actions()

	for(var/action in hud_actions)
		user.client.screen |= action

/obj/item/proc/remove_hud_actions(mob/user)
	if(!user)
		return
	if(!hud_actions || !user.client)
		return

	for(var/action in hud_actions)
		user.client.screen -= action

/obj/item/proc/update_hud_actions()
	if(!hud_actions)
		return

	for(var/A in hud_actions)
		var/obj/item/action = A
		action.update_icon()

/obj/item/proc/refresh_upgrades()
	return

/obj/item/proc/on_embed(mob/user)
	return

/obj/item/proc/on_embed_removal(mob/living/user)
	return

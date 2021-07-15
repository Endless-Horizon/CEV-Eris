//replaces our stun baton code with /tg/station's code
/obj/item/melee/baton
	name = "stunbaton"
	desc = "A stun baton for incapacitating people with."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "stunbaton"
	item_state = "baton"
	slot_flags = SLOT_BELT
	force = WEAPON_FORCE_PAINFUL
	sharp = FALSE
	edge = FALSE
	throwforce = WEAPON_FORCE_PAINFUL
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_COMBAT = 2)
	attack_verb = list("beaten")
	price_tag = 500
	var/stunforce = 0
	var/agonyforce = 40
	var/status = FALSE		//whether the thing is on or not
	var/hitcost = 100
	var/obj/item/cell/cell
	var/obj/item/cell/starting_cell = /obj/item/cell/medium/high
	var/suitable_cell = /obj/item/cell/medium
	light_color = COLOR_LIGHTING_ORANGE_BRIGHT
	structure_damage_factor = STRUCTURE_DAMAGE_BLUNT

/obj/item/melee/baton/Initialize()
	. = ..()
	if(!cell && suitable_cell && starting_cell)
		cell = new starting_cell(src)
	update_icon()

/obj/item/melee/baton/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/melee/baton/get_cell()
	return cell

/obj/item/melee/baton/proc/set_status(s)
	status = s
	tool_qualities = status ? list(QUALITY_PULSING = 1) : null
	update_icon()

/obj/item/melee/baton/handle_atom_del(atom/A)
	..()
	if(A == cell)
		cell = null
		update_icon()

/obj/item/melee/baton/proc/deductcharge(var/power_drain)
	if(cell)
		. = cell.checked_use(power_drain) //try to use enough power
		if(!cell.check_charge(hitcost))	//do we have enough power for another hit?
			set_status(FALSE)

/obj/item/melee/baton/on_update_icon()
	if(status)
		icon_state = "[initial(icon_state)]_active"
	else if(!cell)
		icon_state = "[initial(icon_state)]_nocell"
	else
		icon_state = "[initial(icon_state)]"

	if(icon_state == "[initial(icon_state)]_active")
		set_light(1.5, 1)
	else
		set_light(0)

/obj/item/melee/baton/examine(mob/user)
	if(!..(user, 1))
		return

	if(cell)
		to_chat(user, SPAN_NOTICE("The baton is [round(cell.percent())]% charged."))
	else
		to_chat(user, SPAN_WARNING("The baton does not have a power source installed."))

/obj/item/melee/baton/attack_self(mob/user)
	if(cell && cell.check_charge(hitcost))
		set_status(!status)
		to_chat(user, SPAN_NOTICE("[src] is now [status ? "on" : "off"]."))
		playsound(loc, "sparks", 75, 1, -1)
	else
		set_status(FALSE)
		if(!cell)
			to_chat(user, SPAN_WARNING("[src] does not have a power source!"))
		else
			to_chat(user, SPAN_WARNING("[src] is out of charge."))
	add_fingerprint(user)

/obj/item/melee/baton/attack(mob/M, mob/user)
	if(status && (CLUMSY in user.mutations) && prob(50))
		to_chat(user, SPAN_DANGER("You accidentally hit yourself with the [src]!"))
		user.Weaken(30)
		deductcharge(hitcost)
		return
	return ..()

/obj/item/melee/baton/apply_hit_effect(mob/living/target, mob/living/user, var/hit_zone)
	if(isrobot(target))
		return ..()

	var/agony = agonyforce
	var/stun = stunforce
	var/obj/item/organ/external/affecting
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		affecting = H.get_organ(hit_zone)

	if(user.a_intent == I_HURT)
		. = ..()
		if (!.)	//item/attack() does it's own messaging and logs
			return 0	// item/attack() will return 1 if they hit, 0 if they missed.

		//whacking someone causes a much poorer electrical contact than deliberately prodding them.
		stun *= 0.5
		if(status)		//Checks to see if the stunbaton is on.
			agony *= 0.5	//whacking someone causes a much poorer contact than prodding them.
		else
			agony = 0	//Shouldn't really stun if it's off, should it?
		//we can't really extract the actual hit zone from ..(), unfortunately. Just act like they attacked the area they intended to.
	else if(!status)
		if(affecting)
			target.visible_message(SPAN_WARNING("[target] has been prodded in the [affecting.name] with [src] by [user]. Luckily it was off."))
		else
			target.visible_message(SPAN_WARNING("[target] has been prodded with [src] by [user]. Luckily it was off."))
	else
		if(affecting)
			target.visible_message(SPAN_DANGER("[target] has been prodded in the [affecting.name] with [src] by [user]!"))
		else
			target.visible_message(SPAN_DANGER("[target] has been prodded with [src] by [user]!"))
		playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)

	//stun effects
	if(status && deductcharge(hitcost))
		target.stun_effect_act(stun, agony, hit_zone, src)
		msg_admin_attack("[key_name(user)] stunned [key_name(target)] with the [src].")

		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			H.forcesay(hit_appends)

/obj/item/melee/baton/emp_act(severity)
	if(cell)
		cell.emp_act(severity)	//let's not duplicate code everywhere if we don't have to please.
	..()

//secborg stun baton module
/obj/item/melee/baton/robot
	bad_type = /obj/item/melee/baton/robot

/obj/item/melee/baton/robot/attack_self(mob/user)
	//try to find our power cell
	var/mob/living/silicon/robot/R = loc
	if (istype(R))
		cell = R.cell
	return ..()

/obj/item/melee/baton/robot/attackby(obj/item/W, mob/user)
	return

/obj/item/melee/baton/MouseDrop(over_object)
	if((loc == usr) && istype(over_object, /obj/screen/inventory/hand) && eject_item(cell, usr))
		cell = null
		set_status(FALSE)
		update_icon()

/obj/item/melee/baton/attackby(obj/item/C, mob/living/user)
	if(istype(C, suitable_cell) && !cell && insert_item(C, user))
		cell = C
		update_icon()

//Makeshift stun baton. Replacement for stun gloves.
/obj/item/melee/baton/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton."
	icon_state = "stunprod"
	item_state = "prod"
	force = WEAPON_FORCE_NORMAL
	throwforce = WEAPON_FORCE_NORMAL
	stunforce = 0
	agonyforce = 40	//same force as a stunbaton, but uses way more charge.
	hitcost = 150
	attack_verb = list("poked")
	slot_flags = null
	starting_cell = null
	structure_damage_factor = STRUCTURE_DAMAGE_NORMAL

/obj/item/melee/baton/excelbaton
	name = "Expropriator"
	desc = "A cheap and effective way to feed the red tide."
	icon_state = "sovietbaton"
	item_state = "soviet"
	light_color = COLOR_LIGHTING_CYAN_BRIGHT
	force = WEAPON_FORCE_PAINFUL
	throwforce = WEAPON_FORCE_PAINFUL
	stunforce = 0
	agonyforce = 40
	hitcost = 100
	attack_verb = list("battered")
	slot_flags = SLOT_BELT
	structure_damage_factor = STRUCTURE_DAMAGE_NORMAL
	matter = list(MATERIAL_STEEL = 15, MATERIAL_PLASTEEL = 5)
	starting_cell = /obj/item/cell/medium/excelsior

//excelsior baton has 2 inhand sprites
/obj/item/melee/baton/excelbaton/set_status(s)
	..()
	item_state = initial(item_state) + (status ? "_active" : "")
	update_wear_icon()

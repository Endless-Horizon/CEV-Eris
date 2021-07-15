//cleansed 9/15/2012 17:48

/*
CONTAINS:
MATCHES
CIGARETTES
CIGARS
SMOKING PIPES
CHEAP LIGHTERS
ZIPPO
VAPE

CIGARETTE PACKETS ARE IN FANCY.DM
*/

//For anything that can light stuff on fire
/obj/item/flame
	heat = 1670
	bad_type = /obj/item/flame
	var/lit = 0

/obj/item/flame/is_hot()
	if (lit)
		return heat

/proc/isflamesource(A)
	if(istype(A, /obj/item))
		var/obj/item/I = A
		if(QUALITY_WELDING in I.tool_qualities)
			return TRUE
		if(QUALITY_CAUTERIZING in I.tool_qualities)
			return TRUE
		if (I.is_hot())
			return TRUE
	if(istype(A, /obj/item/flame))
		var/obj/item/flame/F = A
		return (F.lit)
	if(istype(A, /obj/item/device/assembly/igniter))
		return TRUE
	return FALSE

///////////
//MATCHES//
///////////
/obj/item/flame/match
	name = "match"
	desc = "A simple match stick, used for lighting fine smokables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unlit"
	w_class = ITEM_SIZE_TINY
	origin_tech = list(TECH_MATERIAL = 1)
	slot_flags = SLOT_EARS
	attack_verb = list("burnt", "singed")
	preloaded_reagents = list("sulfur" = 3, "potassium" = 3, "hydrazine" = 3, "carbon" = 5)
	var/burnt = 0
	var/smoketime = 5

/obj/item/flame/match/Process()
	if(isliving(loc))
		var/mob/living/M = loc
		M.IgniteMob()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime < 1)
		burn_out()
		return
	if(location)
		location.hotspot_expose(700, 5)
		return

/obj/item/flame/match/dropped(mob/user as mob)
	//If dropped, put ourselves out
	//not before lighting up the turf we land on, though.
	if(lit)
		spawn(0)
			var/turf/location = src.loc
			if(istype(location))
				location.hotspot_expose(700, 5)
			burn_out()
	return ..()

/obj/item/flame/match/proc/burn_out()
	lit = 0
	burnt = 1
	tool_qualities = list()
	damtype = "brute"
	icon_state = "match_burnt"
	item_state = "cigoff"
	name = "burnt match"
	desc = "A match. This one has seen better days."
	STOP_PROCESSING(SSobj, src)

//////////////////
//FINE SMOKABLES//
//////////////////
/obj/item/clothing/mask/smokable
	name = "smokable item"
	desc = "You're not sure what this is. You should probably ahelp it."
	body_parts_covered = 0
	bad_type = /obj/item/clothing/mask/smokable
	var/lit = 0
	var/icon_on
	var/icon_off
	var/type_butt
	var/chem_volume = 0
	var/smoketime = 0
	var/quality_multiplier = 1 // Used for sanity and insight gain
	var/matchmes = "USER lights NAME with FLAME"
	var/lightermes = "USER lights NAME with FLAME"
	var/zippomes = "USER lights NAME with FLAME"
	var/weldermes = "USER lights NAME with FLAME"
	var/ignitermes = "USER lights NAME with FLAME"
//	preloaded_reagents = list("nicotine" = 5)

/obj/item/clothing/mask/smokable/Initialize()
	reagent_flags |= NO_REACT // so it doesn't react until you light it
	// Make the cigarrete a chemical holder of given volume before preloaded_reagents are spawned in
	create_reagents(chem_volume)
	. = ..()

/obj/item/clothing/mask/smokable/Process()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime < 0)
		die()
		return
	if(location)
		location.hotspot_expose(700, 5)
	var/mob/living/carbon/human/C = loc
	if(istype(C))
		C.sanity.onSmoke(src)
	if(smoketime % 10 == 0)
		if(reagents && reagents.total_volume) // check if it has any reagents at all
			if(ishuman(loc))
				if (src == C.wear_mask && C.check_has_mouth()) // if it's in the human/monkey mouth, transfer reagents to the mob
					reagents.trans_to_mob(C, REM, CHEM_INGEST, 0.2) // Most of it is not inhaled... balance reasons.
			else // else just remove some of the reagents
				reagents.remove_any(REM)

/obj/item/clothing/mask/smokable/proc/light(var/flavor_text = "[usr] lights the [name].")
	if(!src.lit)
		src.lit = 1
		damtype = "fire"
		if(reagents.get_reagent_amount("plasma")) // the plasma explodes when exposed to fire
			var/datum/effect/effect/system/reagents_explosion/e = new()
			e.set_up(round(reagents.get_reagent_amount("plasma") / 2.5, 1), get_turf(src), 0, 0)
			e.start()
			qdel(src)
			return
		if(reagents.get_reagent_amount("fuel")) // the fuel explodes, too, but much less violently
			var/datum/effect/effect/system/reagents_explosion/e = new()
			e.set_up(round(reagents.get_reagent_amount("fuel") / 5, 1), get_turf(src), 0, 0)
			e.start()
			qdel(src)
			return
		reagent_flags &= ~NO_REACT // allowing reagents to react after being lit
		reagents.handle_reactions()
		icon_state = icon_on
		item_state = icon_on
		update_wear_icon()
		var/turf/T = get_turf(src)
		T.visible_message(flavor_text)
		set_light(2, 0.25, COLOR_LIGHTING_ORANGE_DARK)
		START_PROCESSING(SSobj, src)

/obj/item/clothing/mask/smokable/proc/die(var/nomessage = 0)
	var/turf/T = get_turf(src)
	set_light(0)
	if (type_butt)
		var/obj/item/butt = new type_butt(T)
		transfer_fingerprints_to(butt)
		if(ismob(loc))
			var/mob/living/M = loc
			if (!nomessage)
				to_chat(M, SPAN_NOTICE("Your [name] goes out."))
			M.remove_from_mob(src) //un-equip it so the overlays can update
			M.update_inv_wear_mask(0)
			M.update_inv_l_hand(0)
			M.update_inv_r_hand(1)
		STOP_PROCESSING(SSobj, src)
		qdel(src)
	else
		new /obj/effect/decal/cleanable/ash(T)
		if(ismob(loc))
			var/mob/living/M = loc
			if (!nomessage)
				to_chat(M, SPAN_NOTICE("Your [name] goes out, and you empty the ash."))
			lit = 0
			icon_state = icon_off
			item_state = icon_off
			update_wear_icon()
		STOP_PROCESSING(SSobj, src)

/obj/item/clothing/mask/smokable/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(isflamesource(W))
		var/text = matchmes
		if(istype(W, /obj/item/flame/match))
			playsound(src, 'sound/items/smoking.ogg', 20, 1, 1)
			text = matchmes
		else if(istype(W, /obj/item/flame/lighter/zippo))
			playsound(src, 'sound/items/smoking.ogg', 20, 1, 1)
			text = zippomes
		else if(istype(W, /obj/item/flame/lighter))
			playsound(src, 'sound/items/smoking.ogg', 20, 1, 1)
			text = lightermes
		else if(istype(W, /obj/item/tool/weldingtool))
			playsound(src, 'sound/items/smoking.ogg', 20, 1, 1)
			text = weldermes
		else if(istype(W, /obj/item/device/assembly/igniter))
			playsound(src, 'sound/items/smoking.ogg', 20, 1, 1)
			text = ignitermes
		text = replacetext(text, "USER", "[user]")
		text = replacetext(text, "NAME", "[name]")
		text = replacetext(text, "FLAME", "[W.name]")
		light(text)

/obj/item/clothing/mask/smokable/attack(var/mob/living/M, var/mob/living/user, def_zone)
	if(istype(M) && M.on_fire)
		user.do_attack_animation(M)
		light(SPAN_NOTICE("\The [user] coldly lights the \the [src] with the burning body of \the [M]."))
		return 1
	else
		return ..()

/obj/item/clothing/mask/smokable/cigarette
	name = "cigarette"
	desc = "A roll of tobacco and nicotine."
	icon_state = "cigoff"
	throw_speed = 0.5
	item_state = "cigoff"
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS | SLOT_MASK
	attack_verb = list("burnt", "singed")
	icon_on = "cigon"  //Note - these are in masks.dmi not in cigarette.dmi
	icon_off = "cigoff"
	type_butt = /obj/item/trash/cigbutt
	chem_volume = 15
	smoketime = 300
	preloaded_reagents = list("nicotine" = 6)
	matchmes = "<span class='notice'>USER lights their NAME with their FLAME.</span>"
	lightermes = "<span class='notice'>USER manages to light their NAME with FLAME.</span>"
	zippomes = "<span class='rose'>With a flick of their wrist, USER lights their NAME with their FLAME.</span>"
	weldermes = "<span class='notice'>USER casually lights the NAME with FLAME.</span>"
	ignitermes = "<span class='notice'>USER fiddles with FLAME, and manages to light their NAME.</span>"

/obj/item/clothing/mask/smokable/cigarette/attackby(obj/item/W as obj, mob/user as mob)
	..()

	if(istype(W, /obj/item/melee/energy/sword))
		var/obj/item/melee/energy/sword/S = W
		if(S.active)
			light(SPAN_WARNING("[user] swings their [W], barely missing their nose. They light their [name] in the process."))

	return

/obj/item/clothing/mask/smokable/cigarette/afterattack(obj/item/reagent_containers/glass/glass, mob/user as mob, proximity)
	..()
	if(!proximity)
		return
	if(istype(glass)) //you can dip cigarettes into beakers
		var/transfered = glass.reagents.trans_to_obj(src, chem_volume)
		if(transfered)	//if reagents were transfered, show the message
			to_chat(user, SPAN_NOTICE("You dip \the [src] into \the [glass]."))
		else			//if not, either the beaker was empty, or the cigarette was full
			if(!glass.reagents.total_volume)
				to_chat(user, SPAN_NOTICE("[glass] is empty."))
			else
				to_chat(user, SPAN_NOTICE("[src] is full."))

/obj/item/clothing/mask/smokable/cigarette/attack_self(mob/user as mob)
	if(lit == 1)
		user.visible_message(SPAN_NOTICE("[user] calmly drops and treads on the lit [src], putting it out instantly."))
		die(1)
	return ..()

/obj/item/clothing/mask/smokable/cigarette/dromedaryco
	desc = "A roll of tobacco and nicotine. They are just cancer sticks."
	preloaded_reagents = list("nicotine" = 10)

/obj/item/clothing/mask/smokable/cigarette/killthroat
	desc = "A roll of tobacco and nicotine. Gives the best bang for buck for your throat."
	preloaded_reagents = list("nicotine" = 10, "poisonberryjuice" = 3)

/obj/item/clothing/mask/smokable/cigarette/homeless
	desc = "A roll of tobacco and nicotine. Gives the feeling of fight."
	preloaded_reagents = list("nicotine" = 6, "adrenaline" = 3)


////////////
// CIGARS //
////////////
/obj/item/clothing/mask/smokable/cigarette/cigar
	name = "premium cigar"
	desc = "A brown roll of tobacco and... well, you're not quite sure. This thing's huge!"
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	type_butt = /obj/item/trash/cigbutt/cigarbutt
	throw_speed = 0.5
	item_state = "cigaroff"
	smoketime = 700
	chem_volume = 20
	preloaded_reagents = list("nicotine" = 14)
	quality_multiplier = 2
	matchmes = "<span class='notice'>USER lights their NAME with their FLAME.</span>"
	lightermes = "<span class='notice'>USER manages to offend their NAME by lighting it with FLAME.</span>"
	zippomes = "<span class='rose'>With a flick of their wrist, USER lights their NAME with their FLAME.</span>"
	weldermes = "<span class='notice'>USER insults NAME by lighting it with FLAME.</span>"
	ignitermes = "<span class='notice'>USER fiddles with FLAME, and manages to light their NAME with the power of science.</span>"

/obj/item/clothing/mask/smokable/cigarette/cigar/cohiba
	name = "\improper Cohiba Robusto cigar"
	desc = "There's little more you could want from a cigar."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"

/obj/item/clothing/mask/smokable/cigarette/cigar/havana
	name = "premium Havanian cigar"
	desc = "A cigar fit for only the best of the best."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	smoketime = 1000
	chem_volume = 30
	preloaded_reagents = list("nicotine" = 20)
	quality_multiplier = 3

/obj/item/trash/cigbutt
	name = "cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'icons/inventory/face/icon.dmi'
	icon_state = "cigbutt"
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	matter = list(MATERIAL_BIOMATTER = 1)
	throwforce = 1
	rarity_value = 3.5

/obj/item/trash/cigbutt/New()
	..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	transform = turn(transform,rand(0,360))

/obj/item/trash/cigbutt/cigarbutt
	name = "cigar butt"
	desc = "A manky old cigar butt."
	icon_state = "cigarbutt"

/////////////////
//SMOKING PIPES//
/////////////////
/obj/item/clothing/mask/smokable/pipe
	name = "smoking pipe"
	desc = "A pipe, for smoking. Probably made of meershaum or something."
	icon_state = "pipeoff"
	item_state = "pipeoff"
	icon_on = "pipeon"  //Note - these are in masks.dmi
	icon_off = "pipeoff"
	smoketime = 0
	chem_volume = 50
	preloaded_reagents = list("nicotine" = 1)
	matchmes = "<span class='notice'>USER lights their NAME with their FLAME.</span>"
	lightermes = "<span class='notice'>USER manages to light their NAME with FLAME.</span>"
	zippomes = "<span class='rose'>With much care, USER lights their NAME with their FLAME.</span>"
	weldermes = "<span class='notice'>USER recklessly lights NAME with FLAME.</span>"
	ignitermes = "<span class='notice'>USER fiddles with FLAME, and manages to light their NAME with the power of science.</span>"
	quality_multiplier = 2 // Fancy!

/obj/item/clothing/mask/smokable/pipe/New()
	..()
	name = "empty [initial(name)]"

/obj/item/clothing/mask/smokable/pipe/light(var/flavor_text = "[usr] lights the [name].")
	if(!src.lit && src.smoketime)
		src.lit = 1
		damtype = "fire"
		icon_state = icon_on
		item_state = icon_on
		var/turf/T = get_turf(src)
		T.visible_message(flavor_text)
		START_PROCESSING(SSobj, src)
		update_wear_icon()

/obj/item/clothing/mask/smokable/pipe/attack_self(mob/user)
	if(lit == 1)
		user.visible_message(SPAN_NOTICE("[user] puts out [src]."), SPAN_NOTICE("You put out [src]."))
		lit = 0
		icon_state = icon_off
		item_state = icon_off
		STOP_PROCESSING(SSobj, src)
	else if (smoketime)
		var/turf/location = get_turf(user)
		user.visible_message(SPAN_NOTICE("[user] empties out [src]."), SPAN_NOTICE("You empty out [src]."))
		new /obj/effect/decal/cleanable/ash(location)
		smoketime = 0
		reagents.clear_reagents()
		name = "empty [initial(name)]"

/obj/item/clothing/mask/smokable/pipe/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/melee/energy/sword))
		return

	..()

	if (istype(W, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/grown/G = W
		if (!G.dry)
			to_chat(user, SPAN_NOTICE("[G] must be dried before you stuff it into [src]."))
			return
		if (smoketime)
			to_chat(user, SPAN_NOTICE("[src] is already packed."))
			return
		smoketime = 1000
		if(G.reagents)
			G.reagents.trans_to_obj(src, G.reagents.total_volume)
		name = "[G.name]-packed [initial(name)]"
		qdel(G)

	else if(istype(W, /obj/item/flame/lighter))
		var/obj/item/flame/lighter/L = W
		if(L.lit)
			light(SPAN_NOTICE("[user] manages to light their [name] with [W]."))

	else if(istype(W, /obj/item/flame/match))
		var/obj/item/flame/match/M = W
		if(M.lit)
			light(SPAN_NOTICE("[user] lights their [name] with their [W]."))

	else if(istype(W, /obj/item/device/assembly/igniter))
		light(SPAN_NOTICE("[user] fiddles with [W], and manages to light their [name] with the power of science."))

/obj/item/clothing/mask/smokable/pipe/cobpipe
	name = "corn cob pipe"
	desc = "A nicotine delivery system popularized by folksy backwoodsmen, kept popular in the modern age and beyond by space hipsters."
	icon_state = "cobpipeoff"
	item_state = "cobpipeoff"
	icon_on = "cobpipeon"  //Note - these are in masks.dmi
	icon_off = "cobpipeoff"
	chem_volume = 35
	quality_multiplier = 1 // Not nearly as fancy as the other one

/////////
//ZIPPO//
/////////
/obj/item/flame/lighter
	name = "cheap lighter"
	desc = "A cheap-as-free lighter."
	icon = 'icons/obj/items.dmi'
	icon_state = "lighter-g"
	item_state = "lighter-g"
	w_class = ITEM_SIZE_TINY
	throwforce = 4
	flags = CONDUCT
	slot_flags = SLOT_BELT
	attack_verb = list("burnt", "singed")
	var/base_state

/obj/item/flame/lighter/zippo
	name = "\improper Zippo lighter"
	desc = "The zippo."
	icon_state = "zippo"
	item_state = "zippo"

/obj/item/flame/lighter/random

/obj/item/flame/lighter/random/Initialize(mapload)
	. = ..()
	icon_state = "lighter-[pick("r","c","y","g")]"
	item_state = icon_state
	base_state = icon_state

/obj/item/flame/lighter/attack_self(mob/living/user)
	if(!base_state)
		base_state = icon_state
	if(user.r_hand == src || user.l_hand == src)
		if(!lit)
			lit = 1
			icon_state = "[base_state]-on"
			item_state = "[base_state]-on"
			if(istype(src, /obj/item/flame/lighter/zippo) )
				playsound(src, 'sound/items/zippo.ogg', 20, 1, 1)
				user.visible_message("<span class='rose'>Without even breaking stride, [user] flips open and lights [src] in one smooth movement.</span>")
			else
				playsound(src, 'sound/items/lighter.ogg', 20, 1, 1)
				if(prob(95))
					user.visible_message(SPAN_NOTICE("After a few attempts, [user] manages to light the [src]."))
				else
					to_chat(user, SPAN_WARNING("You burn yourself while lighting the lighter."))
					if (user.l_hand == src)
						user.apply_damage(2, BURN, BP_L_ARM, used_weapon = src)
					else
						user.apply_damage(2, BURN, BP_R_ARM, used_weapon = src)
					user.visible_message(SPAN_NOTICE("After a few attempts, [user] manages to light the [src], they however burn their finger in the process."))
			tool_qualities = list(QUALITY_CAUTERIZING = 10)
			set_light(2)
			START_PROCESSING(SSobj, src)
		else
			lit = 0
			icon_state = "[base_state]"
			item_state = "[base_state]"
			if(istype(src, /obj/item/flame/lighter/zippo) )
				playsound(src, 'sound/items/zippo.ogg', 20, 1, 1)
				user.visible_message("<span class='rose'>You hear a quiet click, as [user] shuts off [src] without even looking at what they're doing.</span>")
			else
				playsound(src, 'sound/items/lighter.ogg', 20, 1, 1)
				user.visible_message(SPAN_NOTICE("[user] quietly shuts off the [src]."))
			tool_qualities = initial(tool_qualities)
			set_light(0)
			STOP_PROCESSING(SSobj, src)
	else
		return ..()
	return


/obj/item/flame/lighter/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!ismob(M))
		return
	M.IgniteMob()

	if(istype(M.wear_mask, /obj/item/clothing/mask/smokable/cigarette) && user.targeted_organ == BP_MOUTH && lit)
		var/obj/item/clothing/mask/smokable/cigarette/cig = M.wear_mask
		if(M == user)
			cig.attackby(src, user)
		else
			if(istype(src, /obj/item/flame/lighter/zippo))
				cig.light("<span class='rose'>[user] whips the [name] out and holds it for [M].</span>")
			else
				cig.light(SPAN_NOTICE("[user] holds the [name] out for [M], and lights the [cig.name]."))
	else
		..()

/obj/item/flame/lighter/Process()
	var/turf/location = get_turf(src)
	if(location)
		location.hotspot_expose(700, 5)
	return

////////
//VAPE//
////////
/obj/item/clothing/mask/vape
	name = "\improper Vapour mask"
	desc = "A classy and highly sophisticated electronic cigarette, for classy and dignified gentlemen. A warning label reads \"Warning: Do not fill with flammable materials.\""
	icon_state = "vape_mask"
	item_state = "vape_mask"
	w_class = ITEM_SIZE_TINY
	var/chem_volume = 50
	var/vapetime = 0
	var/screw = 0
	var/emagged = 0
	var/waste = 0.8
	var/transfer_amount = 0.2
	var/voltage = 0
	var/quality_multiplier = 1

	var/charge_per_use = 0.5
	var/obj/item/cell/cell
	var/suitable_cell = /obj/item/cell/small

/obj/item/clothing/mask/vape/Initialize(mapload)
	. = ..()
	create_reagents(chem_volume, NO_REACT)
	reagents.add_reagent("nicotine", 20)
	reagents.add_reagent(pick(list("banana","berryjuice","grapejuice","lemonjuice","limejuice","orangejuice","watermelonjuice")), 10)
	if(!cell && suitable_cell)
		cell = new suitable_cell(src)

/obj/item/clothing/mask/vape/get_cell()
	return cell

/obj/item/clothing/mask/vape/handle_atom_del(atom/A)
	..()
	if(A == cell)
		cell = null
		update_icon()

/obj/item/clothing/mask/vape/MouseDrop(over_object)
	if(screw)
		if((loc == usr) && istype(over_object, /obj/screen/inventory/hand) && eject_item(cell, usr))
			cell = null

/obj/item/clothing/mask/vape/attackby(obj/item/O, mob/user, params)
	if(istype(O, suitable_cell) && !cell && insert_item(O, user))
		if(screw)
			cell = O
		else
			to_chat(user, SPAN_WARNING("You need to close the cap of [src]."))
	if(QUALITY_SCREW_DRIVING in O.tool_qualities)
		if(!screw)
			if(O.use_tool(user, src, WORKTIME_INSTANT, QUALITY_SCREW_DRIVING, FAILCHANCE_EASY, required_stat = STAT_MEC))
				screw = TRUE
				to_chat(user, SPAN_NOTICE("You open the cap on [src]."))
				reagent_flags |= OPENCONTAINER
				icon_state = "vape_mask_open"
				item_state = "vape_mask_open"
				update_icon()
		else
			if(O.use_tool(user, src, WORKTIME_INSTANT, QUALITY_SCREW_DRIVING, FAILCHANCE_EASY, required_stat = STAT_MEC))
				screw = FALSE
				to_chat(user, SPAN_NOTICE("You close the cap on [src]."))
				reagent_flags &= ~(OPENCONTAINER)
				icon_state = "vape_mask"
				item_state = "vape_mask"
				update_icon()

	if(istype(O, /obj/item/tool/multitool))
		if(screw && (!emagged))
			if(!voltage)
				transfer_amount = transfer_amount*2
				voltage = 1
				to_chat(user, SPAN_NOTICE("You increase the voltage of [src]."))
			else
				transfer_amount = transfer_amount/2
				voltage = 0
				to_chat(user, SPAN_NOTICE("You decrease the voltage of [src]."))

		if(screw && (emagged))
			to_chat(user, SPAN_WARNING("[src] can't be modified!"))
		else
			..()

/obj/item/clothing/mask/vape/emag_act(var/remaining_charges, mob/user)
	if(screw)
		if(!emagged)
			emagged = 1
			to_chat(user, SPAN_WARNING("You maximize the voltage of [src]."))
			var/datum/effect/effect/system/spark_spread/sp = new /datum/effect/effect/system/spark_spread //for effect
			sp.set_up(5, 1, src)
			sp.start()
		else
			to_chat(user, SPAN_WARNING("[src] is already emagged!"))
	else
		to_chat(user, SPAN_WARNING("You need to open the cap to do that!"))

/obj/item/clothing/mask/vape/attack_self(mob/user)
	if(screw)
		if(reagents.total_volume > 0)
			to_chat(user, SPAN_NOTICE("You empty [src] of all reagents."))
			reagents.clear_reagents()

/obj/item/clothing/mask/vape/equipped(mob/user, slot)
	. = ..()
	switch(slot)
		if(slot_wear_mask)
			if(!screw)
				to_chat(user, SPAN_NOTICE("You start puffing on the vape."))
				reagent_flags &= ~(NO_REACT)
				update_icon()
				START_PROCESSING(SSobj, src)
			else
				to_chat(user, SPAN_WARNING("You need to close the cap first!"))
		if(slot_l_hand, slot_r_hand)
			reagent_flags |= NO_REACT
			update_icon()
			STOP_PROCESSING(SSobj, src)

/obj/item/clothing/mask/vape/proc/hand_reagents()
	var/mob/living/carbon/human/C = loc
	vapetime = 0
	if(reagents && reagents.total_volume)
		if(ishuman(C))
			if(reagents.get_reagent_amount("plasma"))
				var/datum/effect/effect/system/reagents_explosion/e = new()
				playsound(get_turf(src), 'sound/effects/Explosion1.ogg', 50, FALSE)
				C.apply_damage(20, BURN, BP_HEAD)
				C.Stun(5)
				e.set_up(round(reagents.get_reagent_amount("plasma") / 2.5, 1), get_turf(src), 0, 0)
				e.start()
				qdel(src)
			if(reagents.get_reagent_amount("fuel"))
				var/datum/effect/effect/system/reagents_explosion/e = new()
				playsound(get_turf(src), 'sound/effects/Explosion1.ogg', 50, FALSE)
				C.apply_damage(20, BURN, BP_HEAD)
				C.Stun(5)
				e.set_up(round(reagents.get_reagent_amount("fuel") / 5, 1), get_turf(src), 0, 0)
				e.start()
				qdel(src)
			else
				reagents.trans_to_mob(C, REM, CHEM_INGEST, transfer_amount)
				C.sanity.onSmoke(src)
		else
			reagents.remove_any(waste)
			cell.use(charge_per_use)

/obj/item/clothing/mask/vape/Process()
	var/mob/living/M = loc

	if(isliving(loc))
		M.IgniteMob()

	vapetime++

	if(!reagents.total_volume)
		if(ismob(loc))
			to_chat(M, SPAN_WARNING("[src] is empty!"))
			STOP_PROCESSING(SSobj, src)
			//it's reusable so it won't unequip when empty
		return

	if(emagged && vapetime > 3)
		var/datum/effect/effect/system/smoke_spread/chem/s = new /datum/effect/effect/system/smoke_spread/chem
		s.set_up(reagents, 4, 24, loc)
		s.start()
		if(prob(5))//small chance for the vape to break and deal damage if it's emagged
			playsound(get_turf(src), 'sound/effects/Explosion1.ogg', 50, FALSE)
			M.apply_damage(20, BURN, BP_HEAD)
			M.Stun(5)
			var/datum/effect/effect/system/spark_spread/sp = new /datum/effect/effect/system/spark_spread //for effect
			sp.set_up(5, 1, src)
			sp.start()
			to_chat(M, SPAN_WARNING("[src] suddenly explodes in your mouth!"))
			qdel(src)
			return

	if(!cell || !cell.checked_use(charge_per_use))
		to_chat(M, SPAN_WARNING("[src] battery is dead or missing."))
		STOP_PROCESSING(SSobj, src)
		return

	if(cell || cell.checked_use(charge_per_use))
		if(reagents && reagents.total_volume)
			if(vapetime > 4)
				hand_reagents()

/obj/item/clothing/mask/vape/better
	name = "\improper Vapour mask"
	desc = "A classy and highly sophisticated electronic cigarette, for classy and dignified gentlemen. A warning label reads \"Warning: Do not fill with flammable materials.\" It seems different from the others"

/obj/item/clothing/mask/vape/better/New(mapload)
	. = ..()
	waste = pick(0.4, 0.7)
	transfer_amount = pick(0.3, 1)
	charge_per_use = pick(0.2, 0.5)

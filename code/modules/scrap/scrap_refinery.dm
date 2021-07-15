/obj/item/electronics/circuitboard/recycler
	name = T_BOARD("Recycler")
	build_path = /obj/machinery/recycler
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 3)
	req_components = list(
		/obj/item/stock_parts/manipulator = 1
	)

/obj/machinery/recycler
	name = "recycler"
	desc = "A large crushing machine which is used to grind lumps of trash down; there are lights on the side of it."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-o0"
	layer = ABOVE_MOB_LAYER // Overhead
	anchored = TRUE
	density = TRUE
	var/safety_mode = FALSE // Temporality stops the machine if it detects a mob
	var/grinding = FALSE
	var/icon_name = "grinder-o"
	var/blood = FALSE
	var/eat_dir = WEST
	var/chance_to_recycle = 1

/obj/machinery/recycler/Initialize()
	// On us
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/electronics/circuitboard/recycler(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	RefreshParts()
	update_icon()

/obj/machinery/recycler/RefreshParts()
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		chance_to_recycle = 25 * M.rating //% of materials salvaged
	chance_to_recycle = min(100, chance_to_recycle)

/obj/machinery/recycler/examine(mob/user)
	.=..()
	to_chat(user, "The power light is [(stat & NOPOWER) ? "off" : "on"].")
	to_chat(user, "The safety-mode light is [safety_mode ? "on" : "off"].")
	to_chat(user, "The safety-sensors status light is [emagged ? "off" : "on"].")

/obj/machinery/recycler/power_change()
	.=..()
	update_icon()


/obj/machinery/recycler/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/emag))
		emag_act(user)
		user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)

	if(default_deconstruction(I, user))
		return

	if(default_part_replacement(I, user))
		return

	..()

/obj/machinery/recycler/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		if(safety_mode)
			safety_mode = FALSE
			update_icon()
		playsound(loc, "sparks", 75, 1, -1)
		to_chat(user, SPAN_NOTICE("You use the cryptographic sequencer on the [name]."))

/obj/machinery/recycler/on_update_icon()
	.=..()
	var/is_powered = !(stat & (BROKEN|NOPOWER))
	if(safety_mode)
		is_powered = FALSE
	icon_state = icon_name + "[is_powered]" + "[(blood ? "bld" : "")]" // add the blood tag at the end

// This is purely for admin possession !FUN!.
/obj/machinery/recycler/Bump(atom/movable/AM)
	.=..()
	if(AM)
		Bumped(AM)

/obj/machinery/recycler/Bumped(atom/movable/AM)
	if(stat & (BROKEN|NOPOWER))
		return
	if(!anchored)
		return
	if(safety_mode)
		return

	var/move_dir = get_dir(loc, AM.loc)
	if(move_dir == eat_dir)
		if(isliving(AM))
			if(emagged)
				eat(AM)
			else
				stop(AM)
		else if(istype(AM, /obj/item))
			recycle(AM)
		else // Can't recycle
			playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
			AM.forceMove(loc)

/obj/machinery/recycler/proc/recycle(obj/item/I, sound = 1)
	I.forceMove(loc)
	if(!istype(I))
		return

	if(sound)
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	var/chance_mod = 1
	if(!istype(I, /obj/item/scrap_lump))
		chance_mod = 5
	if(prob(chance_to_recycle / chance_mod))
		new /obj/item/stack/refined_scrap(loc)
	qdel(I)

/obj/machinery/recycler/proc/stop(mob/living/L)
	set waitfor = FALSE

	playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
	safety_mode = TRUE
	update_icon()
	L.forceMove(loc)

	sleep(SAFETY_COOLDOWN)
	playsound(loc, 'sound/machines/ping.ogg', 50, 0)
	safety_mode = FALSE
	update_icon()

/obj/machinery/recycler/proc/eat(mob/living/L)
	L.forceMove(src.loc)

	if(issilicon(L))
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	else
		L.emote("scream", , , 1)

	var/gib = TRUE
	// By default, the emagged recycler will gib all non-carbons. (human simple animal mobs don't count)
	if(iscarbon(L))
		gib = FALSE
		if(L.stat == CONSCIOUS)
			L.emote("scream", , , 1)
		add_blood(L)

	if(!blood && !issilicon(L))
		blood = TRUE
		update_icon()

	// Remove and recycle the equipped items.
	for(var/obj/item/I in L.get_equipped_items())
		if(L.unEquip(I))
			recycle(I, 0)

	// Instantly lie down, also go unconscious from the pain, before you die.
	L.Paralyse(5)
	L.anchored = TRUE
	// For admin fun, var edit emagged to 2.
	if(gib || emagged == 2)
		L.gib()
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)
	else if(emagged == 1)
		for(var/i in 1 to 3)
			sleep(10)
			L.adjustBruteLoss(80)
	L.anchored = FALSE

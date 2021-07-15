/obj/item/electronics/circuitboard/pile_ripper
	name = T_BOARD("Pile Ripper")
	build_path = /obj/machinery/pile_ripper
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 3)
	req_components = list(
		/obj/item/stock_parts/manipulator = 1
	)

/obj/machinery/pile_ripper
	name = "pile ripper"
	desc = "This machine rips everything in front of it apart."
	icon = 'icons/obj/structures/scrap/recycling.dmi'
	icon_state = "grinder-b0"
	layer = MOB_LAYER + 1 // Overhead
	anchored = TRUE
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 300

	var/safety_mode = FALSE // Temporality stops the machine if it detects a mob
	var/icon_name = "grinder-b"
	var/blood = 0
	var/rating = 1
	var/last_ripped = 0

	var/turf/ripped_turf

/obj/machinery/pile_ripper/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/pile_ripper/LateInitialize()
	ripped_turf = get_turf(get_step(src, 8))

/obj/machinery/pile_ripper/Process()
	if(last_ripped >= world.time)
		return
	last_ripped = world.time
	if(safety_mode)
		playsound(loc, 'sound/machines/ping.ogg', 50, 0)
		safety_mode = FALSE
		update_icon()
	for(var/mob/living/poor_soul in ripped_turf)
		if(emagged || prob(25))
			eat(poor_soul)
		else
			stop(poor_soul)
	var/count = 0
	for(var/obj/ripped_item in ripped_turf)
		if(count >= rating)
			break
		if(istype(ripped_item, /obj/structure/scrap_spawner))
			var/obj/structure/scrap_spawner/pile = ripped_item
			while(pile.dig_out_lump(loc, 1))
				if(prob(20))
					break
			count++
		else if(istype(ripped_item, /obj/item))
			ripped_item.forceMove(src.loc)
			if(prob(20))
				qdel(ripped_item)
		else if(istype(ripped_item, /obj/structure/scrap_cube))
			var/obj/structure/scrap_cube/cube = ripped_item
			cube.make_pile()

/obj/machinery/pile_ripper/examine(mob/user)
	..()
	to_chat(user, "The power light is [(stat & NOPOWER) ? "off" : "on"].")
	to_chat(user, "The safety-mode light is [safety_mode ? "on" : "off"].")
	to_chat(user, "The safety-sensors status light is [emagged ? "off" : "on"].")

/obj/machinery/pile_ripper/power_change()
	..()
	update_icon()

/obj/machinery/pile_ripper/proc/stop(mob/living/L)
	playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
	safety_mode = TRUE
	update_icon()
	L.forceMove(loc)

	last_ripped += SAFETY_COOLDOWN
	update_icon()

/obj/machinery/pile_ripper/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/emag))
		emag_act(user)
		user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)

	if(default_deconstruction(I, user))
		return

	if(default_part_replacement(I, user))
		return

	.=..()

/obj/machinery/pile_ripper/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		if(safety_mode)
			safety_mode = FALSE
			update_icon()
		playsound(loc, "sparks", 75, 1, -1)
		to_chat(user, SPAN_NOTICE("You use the cryptographic sequencer on the [name]."))

/obj/machinery/pile_ripper/on_update_icon()
	..()
	var/is_powered = !(stat & (BROKEN|NOPOWER))
	if(safety_mode)
		is_powered = FALSE
	icon_state = icon_name + "[is_powered]" + "[(blood ? "bld" : "")]" // add the blood tag at the end


/obj/machinery/pile_ripper/proc/eat(mob/living/L)
	if(issilicon(L))
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	else
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)

	var/gib = TRUE
	// By default, the emagged pile_ripper will gib all non-carbons. (human simple animal mobs don't count)
	if(iscarbon(L))
		gib = FALSE
		if(!L.stat)
			L.emote("scream", , , 1)
		add_blood(L)
	if(!blood && !issilicon(L))
		blood = TRUE
		update_icon()
	if(gib)
		L.gib()

	// Instantly lie down, also go unconscious from the pain, before you die.
	L.Paralyse(5)
	// Strip some clothing

	for(var/obj/item/I in L.get_equipped_items())
		if(L.unEquip(I))
			I.forceMove(loc)
			if(prob(15)) //saved by ripped cloth
				return

	// Start shredding meat

	var/slab_name = L.name
	var/slab_type = /obj/item/reagent_containers/food/snacks/meat

	L.adjustBruteLoss(45)
	if(istype(L, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = L
		H.adjustNutrition(-100)
		if(H.nutrition <= 0)
			H.gib()
		if(H.isMonkey())
			slab_type = /obj/item/reagent_containers/food/snacks/meat/monkey
		else
			slab_name = H.real_name
			slab_type = /obj/item/reagent_containers/food/snacks/meat/human

	var/obj/item/reagent_containers/food/snacks/meat/new_meat = new slab_type(get_turf(get_step(src, 4)))
	new_meat.name = "[slab_name] [new_meat.name]"

	new_meat.reagents.add_reagent("nutriment", 10)

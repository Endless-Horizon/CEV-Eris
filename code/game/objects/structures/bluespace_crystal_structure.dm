/obj/structure/bs_crystal_structure
	name = "strange crystal structure"
	desc = "Strange blue crystal structure."
	icon = 'icons/obj/bluespace_crystal_structure.dmi'
	icon_state = "crystal"
	anchored = TRUE
	density = TRUE
	layer = BELOW_OBJ_LAYER

	var/next_teleportation
	var/teleportation_timer
	var/list/turf/simulated/floor/destination_candidates = list()

	var/teleportation_range = 16  // Maximum range that crystal can teleport mobs and items it's been hit with.
	var/crystal_amount = 3
	var/timer_min = 1 MINUTES  // Minimum possible time until next teleportation
	var/timer_max = 3 MINUTES  // Maximum possible time until next teleportation

	var/list/explosion_items = list(
		/obj/item/bluespace_crystal,
		/obj/item/hand_tele,
		/obj/item/device/radio/uplink,
		/obj/item/tool/knife/dagger/bluespace,
		/obj/item/reagent_containers/glass/beaker/bluespace,
		/obj/item/bluespace_harpoon,
		/obj/item/seeds/bluespacetomatoseed
	)
	var/entropy_value = 8

/obj/structure/bs_crystal_structure/New()
	..()
	for(var/turf/simulated/floor/F in range(2, src.loc))
		if(!F.is_wall && !F.is_hole)
			destination_candidates.Add(F)

	next_teleportation = pick(timer_min, timer_max)
	teleportation_timer = addtimer(CALLBACK(src, .proc/teleport_random_item), next_teleportation)
	bluespace_entropy(entropy_value, get_turf(src), TRUE)

/obj/structure/bs_crystal_structure/Destroy()
	..()
	deltimer(teleportation_timer)

/obj/structure/bs_crystal_structure/attackby(obj/item/I, mob/user)
	if(user.a_intent == I_HELP && user.Adjacent(src) && I.has_quality(QUALITY_EXCAVATION))
		src.visible_message(SPAN_NOTICE("[user] starts excavating crystals from [src]."), SPAN_NOTICE("You start excavating crystal from [src]."))
		if(do_after(user, WORKTIME_SLOW, src))
			for(var/i = 0, i < crystal_amount, i++)
				new /obj/item/bluespace_crystal(src.loc)
			src.visible_message(SPAN_NOTICE("[user] excavates crystals from [src]."), SPAN_NOTICE("You excavate crystal from [src]."))
			qdel(src)
		else
			to_chat(user, SPAN_WARNING("You must stay still to finish excavation."))

	if(user.a_intent == I_HURT && user.Adjacent(src))
		if(!(I.flags & NOBLUDGEON))
			user.do_attack_animation(src)
			if(I.type in explosion_items)
				explosion(src.loc, 0, 1, 2, 3, 0)
				qdel(I)
				qdel(src)
			if(I.hitsound)
				var/calc_damage = I.force * I.structure_damage_factor
				var/volume = calc_damage * 3.5
				playsound(src, I.hitsound, volume, 1, -1)
			user.drop_item()
			go_to_bluespace(get_turf(src), entropy_value, TRUE, I, src, aprecision=teleportation_range)
			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN * 1.75)
			user.visible_message(SPAN_NOTICE("[user] hits [src] with [I] and it disappears!"), SPAN_NOTICE("You hit [src] with [I] and it disappears!"))

/obj/structure/bs_crystal_structure/attack_hand(mob/user)
	..()
	if(user.a_intent == I_HURT)
		go_to_bluespace(get_turf(src), entropy_value, TRUE, user, src, aprecision=teleportation_range)

/obj/structure/bs_crystal_structure/hitby(AM as mob|obj)
	..()
	if(isobj(AM))
		var/obj/O = AM
		if(O.type in explosion_items)
			explosion(src.loc, 0, 1, 2, 3, 0)
			qdel(AM)
			qdel(src)
	if(ismob(AM) || isobj(AM))
		visible_message(SPAN_DANGER("[AM] smashes in [src] and disappears!"))
		go_to_bluespace(get_turf(src), entropy_value, TRUE, AM, src, aprecision=teleportation_range)

/obj/structure/bs_crystal_structure/proc/teleport_random_item()
	var/turf/simulated/floor/teleport_destination = pick(destination_candidates)
	var/area/target_area = random_ship_area()
	var/turf/simulated/floor/target_turf = target_area.random_space()
	if(target_turf)
		var/list/target_turf_contents = target_turf.contents

		if(!teleport_destination || !target_turf_contents.len)
			return
		for(var/obj/item/I in target_turf_contents)
			go_to_bluespace(get_turf(src), entropy_value, FALSE, I, teleport_destination)
		for(var/mob/M in target_turf_contents)
			go_to_bluespace(get_turf(src), entropy_value, FALSE, M, teleport_destination)
			new /obj/item/bluespace_dust(target_turf)

			next_teleportation = pick(timer_min, timer_max)
			teleportation_timer = addtimer(CALLBACK(src, .proc/teleport_random_item), next_teleportation)

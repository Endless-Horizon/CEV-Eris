
/obj/machinery/gibber
	name = "gibber"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	req_access = list(access_kitchen,access_morgue)

	var/operating = 0 //Is it on?
	var/dirty = 0 // Does it need cleaning?
	var/mob/living/occupant // Mob who has been put inside
	var/gib_time = 40        // Time from starting until meat appears
	var/gib_throw_dir = WEST // Direction to spit meat and gibs in.

	var/hack_require = 6 //for hacking with multitool
	var/hack_stage = 0

	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 500

//auto-gibs anything that bumps into it
/obj/machinery/gibber/autogibber
	var/input_dir = 0

/obj/machinery/gibber/autogibber/New()
	..()
	spawn()
		var/obj/landmark/machinery/input/input = locate() in orange(1, src)
		if(input)
			input_dir = get_dir(src, input)
		else
			log_misc("a [src] didn't find an input plate.")

/obj/machinery/gibber/autogibber/Bumped(var/atom/A)
	if(!input_dir)
		return

	if(ismob(A))
		var/mob/M = A
		if(M.loc == get_step(src, input_dir))
			M.forceMove(src)
			M.gib()


/obj/machinery/gibber/New()
	..()
	update_icon()
	spawn()
		var/obj/landmark/machinery/output/output = locate() in orange(1, src)
		if(output)
			gib_throw_dir = get_dir(src, output)

/obj/machinery/gibber/on_update_icon()
	cut_overlays()
	if (dirty)
		src.add_overlays(image('icons/obj/kitchen.dmi', "grbloody"))
	if(stat & (NOPOWER|BROKEN))
		return
	if (!occupant)
		src.add_overlays(image('icons/obj/kitchen.dmi', "grjam"))
	else if (operating)
		src.add_overlays(image('icons/obj/kitchen.dmi', "gruse"))
	else
		src.add_overlays(image('icons/obj/kitchen.dmi', "gridle"))

/obj/machinery/gibber/relaymove(mob/user as mob)
	src.go_out()

/obj/machinery/gibber/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(operating)
		to_chat(user, SPAN_DANGER("The gibber is locked and running, wait for it to finish."))
		return
	else
		src.startgibbing(user)

/obj/machinery/gibber/attackby(obj/item/I, mob/user)
	..()
	if(QUALITY_PULSING in I.tool_qualities)
		user.visible_message(
		SPAN_WARNING("[user] picks in wires of the [src.name] with a multitool"), \
		SPAN_WARNING("[pick("Picking wires in [src.name] lock", "Hacking [src.name] security systems", "Pulsing in locker controller")].")
		)
		if(I.use_tool(user, src, WORKTIME_LONG, QUALITY_PULSING, FAILCHANCE_HARD, required_stat = STAT_MEC))
			if(hack_stage < hack_require)
				playsound(loc, 'sound/items/glitch.ogg', 60, 1, -3)
				hack_stage++
				to_chat(user, SPAN_NOTICE("Multitool blinks <b>([hack_stage]/[hack_require])</b> on screen."))
			else if(hack_stage >= hack_require)
				emagged = !emagged
				src.update_icon()
				user.visible_message(
				SPAN_WARNING("[user] [emagged?"disable":"enable"] the safety guard of [name] with a multitool,"), \
				SPAN_WARNING("You [emagged? "disable" : "enable"] the safety guard of [name] with multitool")
				)
				return

/obj/machinery/gibber/examine()
	..()
	to_chat(usr, "The safety guard is [emagged ? SPAN_DANGER("disabled") : "enabled"].")

/obj/machinery/gibber/emag_act(var/remaining_charges, var/mob/user)
	emagged = !emagged
	to_chat(user, SPAN_DANGER("You [emagged ? "disable" : "enable"] the gibber safety guard."))
	return 1

/obj/machinery/gibber/affect_grab(var/mob/user, var/mob/target, var/state)
	if(state < GRAB_NECK)
		to_chat(user, SPAN_DANGER("You need a better grip to do that!"))
		return FALSE
	move_into_gibber(user, target)
	return TRUE

/obj/machinery/gibber/MouseDrop_T(mob/target, mob/user)
	if(user.stat || user.restrained())
		return
	move_into_gibber(user,target)

/obj/machinery/gibber/proc/move_into_gibber(var/mob/user,var/mob/living/victim)

	if(src.occupant)
		to_chat(user, SPAN_DANGER("The gibber is full, empty it first!"))
		return

	if(operating)
		to_chat(user, SPAN_DANGER("The gibber is locked and running, wait for it to finish."))
		return

	if(!(iscarbon(victim)) && !(isanimal(victim)) )
		to_chat(user, SPAN_DANGER("This is not suitable for the gibber!"))
		return

	if(ishuman(victim) && !emagged)
		to_chat(user, SPAN_DANGER("The gibber safety guard is engaged!"))
		return


	if(victim.abiotic(1))
		to_chat(user, SPAN_DANGER("Subject may not have abiotic items on."))
		return

	user.visible_message(SPAN_DANGER("[user] starts to put [victim] into the gibber!"))
	src.add_fingerprint(user)
	if(do_after(user, 30, src) && victim.Adjacent(src) && user.Adjacent(src) && victim.Adjacent(user) && !occupant)
		user.visible_message(SPAN_DANGER("\The [user] stuffs \the [victim] into the gibber!"))
		victim.forceMove(src)
		victim.reset_view(src)
		src.occupant = victim
		update_icon()

/obj/machinery/gibber/verb/eject()
	set category = "Object"
	set name = "Empty Gibber"
	set src in oview(1)

	if (usr.stat != 0)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/gibber/proc/go_out()
	if(operating || !src.occupant)
		return
	for(var/obj/O in src)
		O.loc = src.loc
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	update_icon()
	return


/obj/machinery/gibber/proc/startgibbing(mob/user as mob)
	if(src.operating)
		return
	if(!src.occupant)
		visible_message(SPAN_DANGER("You hear a loud metallic grinding sound."))
		return
	use_power(1000)
	visible_message(SPAN_DANGER("You hear a loud squelchy grinding sound."))
	src.operating = 1
	update_icon()

	var/slab_name = occupant.name
	var/slab_count = 3
	var/slab_type = /obj/item/reagent_containers/food/snacks/meat
	var/slab_nutrition = 20
	if(iscarbon(occupant))
		var/mob/living/carbon/C = occupant
		slab_nutrition = C.nutrition / 15

	// Some mobs have specific meat item types.
	if(isanimal(src.occupant))
		var/mob/living/simple_animal/critter = src.occupant
		if(critter.meat_amount)
			slab_count = critter.meat_amount
		if(critter.meat_type)
			slab_type = critter.meat_type

	else if(isroach(occupant))
		var/mob/living/carbon/superior_animal/roach/H = occupant
		slab_type = H.meat_type
		slab_count = H.meat_amount

	else if(ishuman(occupant))
		var/mob/living/carbon/human/H = occupant
		slab_name = src.occupant.real_name
		slab_type = H.species.meat_type

	// Small mobs don't give as much nutrition.
	if(issmall(src.occupant))
		slab_nutrition *= 0.5
	slab_nutrition /= slab_count

	for(var/i=1 to slab_count)
		var/obj/item/reagent_containers/food/snacks/meat/new_meat = new slab_type(src)
		new_meat.name = "[slab_name] [new_meat.name]"
		new_meat.reagents.add_reagent("nutriment",slab_nutrition)

		if(src.occupant.reagents)
			src.occupant.reagents.trans_to_obj(new_meat, round(occupant.reagents.total_volume/slab_count,1))

	src.occupant.attack_log += "\[[time_stamp()]\] Was gibbed by <b>[user]/[user.ckey]</b>" //One shall not simply gib a mob unnoticed!
	user.attack_log += "\[[time_stamp()]\] Gibbed <b>[src.occupant]/[src.occupant.ckey]</b>"
	msg_admin_attack("[user.name] ([user.ckey]) gibbed [src.occupant] ([src.occupant.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	src.occupant.ghostize()

	spawn(gib_time)

		src.operating = 0
		src.occupant.gib()
		qdel(src.occupant)

		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
		operating = 0
		for (var/obj/thing in contents)
			// Todo: unify limbs and internal organs
			// There's a chance that the gibber will fail to destroy some evidence.
			if((istype(thing,/obj/item/organ) || istype(thing,/obj/item/organ)) && prob(80))
				qdel(thing)
				continue
			thing.loc = get_turf(thing) // Drop it onto the turf for throwing.
			thing.throw_at(get_edge_target_turf(src,gib_throw_dir),rand(0,3),emagged ? 100 : 50) // Being pelted with bits of meat and bone would hurt.

		update_icon()



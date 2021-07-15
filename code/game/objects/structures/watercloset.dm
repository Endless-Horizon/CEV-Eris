//todo: toothbrushes, and some sort of "toilet-filthinator" for the hos

/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00"
	density = FALSE
	anchored = TRUE
	layer = SIGN_LAYER
	var/open = 0			//if the lid is up
	var/cistern = 0			//if the cistern bit is open
	var/w_items = 0			//the combined w_class of all the items in the cistern
	var/mob/living/swirlie = null	//the mob being given a swirlie

/obj/structure/toilet/New()
	open = round(rand(0, 1))
	update_icon()

/obj/structure/toilet/attack_hand(mob/living/user as mob)
	if(swirlie)
		usr.visible_message(
			SPAN_DANGER("[user] slams the toilet seat onto [swirlie.name]'s head!"),
			SPAN_NOTICE("You slam the toilet seat onto [swirlie.name]'s head!"),
			"You hear reverberating porcelain."
		)
		swirlie.adjustBruteLoss(8)
		return

	if(cistern && !open)
		if(!contents.len)
			to_chat(user, SPAN_NOTICE("The cistern is empty."))
			return
		else
			var/obj/item/I = pick(contents)
			if(ishuman(user))
				user.put_in_hands(I)
			else
				I.loc = get_turf(src)
			to_chat(user, SPAN_NOTICE("You find \an [I] in the cistern."))
			w_items -= I.w_class
			return

	open = !open
	update_icon()

/obj/structure/toilet/on_update_icon()
	icon_state = "toilet[open][cistern]"

/obj/structure/toilet/attackby(obj/item/I as obj, mob/living/user as mob)
	if(QUALITY_PRYING in I.tool_qualities)
		to_chat(user, "<span class='notice'>You start to [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"].</span>")
		if(I.use_tool(user, src, WORKTIME_NORMAL, QUALITY_PRYING, FAILCHANCE_EASY, required_stat = STAT_MEC))
			user.visible_message("<span class='notice'>[user] [cistern ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!</span>", "<span class='notice'>You [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]!</span>", "You hear grinding porcelain.")
			cistern = !cistern
			update_icon()
			return

	if(cistern && !isrobot(user)) //STOP PUTTING YOUR MODULES IN THE TOILET.
		if(I.w_class >= ITEM_SIZE_BULKY)
			to_chat(user, SPAN_NOTICE("\The [I] does not fit."))
			return
		if(w_items + I.w_class > ITEM_SIZE_HUGE)
			to_chat(user, SPAN_NOTICE("The cistern is full."))
			return
		user.drop_item()
		I.loc = src
		w_items += I.w_class
		to_chat(user, "You carefully place \the [I] into the cistern.")
		return

/obj/structure/toilet/AltClick(var/mob/living/user)
	if(!open)
		return
	var/H = user.get_active_hand()
	if(istype(H,/obj/item/reagent_containers/glass) || istype(H,/obj/item/reagent_containers/food/drinks))
		var/obj/item/reagent_containers/O = user.get_active_hand()
		if(O.reagents && O.reagents.total_volume)
			O.reagents.clear_reagents()
			to_chat(user, SPAN_NOTICE("You empty the [O] into the [src]."))


/obj/structure/toilet/affect_grab(var/mob/user, var/mob/living/target, var/state)
	if(state == GRAB_PASSIVE)
		to_chat(user, SPAN_NOTICE("You need a tighter grip."))
		return FALSE
	if(!target.loc == loc)
		to_chat(user, SPAN_NOTICE("[target] needs to be on the toilet."))
		return FALSE
	if(open && !swirlie)
		user.visible_message(
			SPAN_DANGER("[user] starts to give [target] a swirlie!"),
			SPAN_NOTICE("You start to give [target] a swirlie!")
		)
		swirlie = target
		if (do_after(user, 30, src) || !Adjacent(target))
			user.visible_message(
				SPAN_DANGER("[user] gives [target] a swirlie!"),
				SPAN_NOTICE("You give [target] a swirlie!"),
				"You hear a toilet flushing."
			)
			var/mob/living/carbon/C = target
			if(!istype(C) || !C.internal)
				target.adjustOxyLoss(5)
		swirlie = null
	else
		user.visible_message(
			SPAN_DANGER("[user] slams [target] into the [src]!"),
			SPAN_NOTICE("You slam [target] into the [src]!")
		)
		admin_attack_log(user, target,
			"slams <b>[key_name(target)]</b> into the [src]",
			"Was slamed by <b>[key_name(user)] into the [src]</b>",
			"slamed into the [src]"
		)
		target.adjustBruteLoss(8)
	return TRUE


/obj/structure/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "urinal"
	density = FALSE
	anchored = TRUE

/obj/structure/urinal/affect_grab(var/mob/living/user, var/mob/living/target, var/state)
	if(state == GRAB_PASSIVE)
		to_chat(user, SPAN_NOTICE("You need a tighter grip."))
		return FALSE
	if(!target.loc == loc)
		to_chat(user, SPAN_NOTICE("[target] needs to be on the urinal."))
		return
	user.visible_message(
		SPAN_DANGER("[user] slams [target] into the [src]!"),
		SPAN_NOTICE("You slam [target] into the [src]!")
	)
	admin_attack_log(user, target,
		"slams <b>[key_name(target)]</b> into the [src]",
		"Was slamed by <b>[key_name(user)] into the [src]</b>",
		"slamed into the [src]"
	)
	target.adjustBruteLoss(8)
	return TRUE


/obj/machinery/shower
	name = "shower"
	desc = "The HS-451. Installed in the 2550s by the Hygiene Division."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	density = FALSE
	anchored = TRUE
	use_power = NO_POWER_USE
	var/on = FALSE
	var/obj/effect/mist/mymist = null
	var/ismist = 0				//needs a var so we can make it linger~
	var/watertemp = "normal"	//freezing, normal, or boiling
	var/is_washing = 0
	var/list/temperature_settings = list("normal" = 310, "boiling" = T0C+100, "freezing" = T0C)

/obj/machinery/shower/New()
	..()
	create_reagents(50)

//add heat controls? when emagged, you can freeze to death in it?

/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	layer = FLY_LAYER
	anchored = TRUE
	mouse_opacity = 0

/obj/machinery/shower/attack_hand(mob/M as mob)
	on = !on
	update_icon()
	if(on)
		if (M.loc == loc)
			wash(M)
			process_heat(M)
		for (var/atom/movable/G in loc)
			G.clean_blood()

/obj/machinery/shower/attackby(obj/item/I, mob/user)
	if(QUALITY_PULSING in I.tool_qualities)
		to_chat(user, SPAN_NOTICE("The water temperature seems to be [watertemp]."))
	if(QUALITY_BOLT_TURNING in I.tool_qualities)
		var/newtemp = input(user, "What setting would you like to set the temperature valve to?", "Water Temperature Valve") in temperature_settings
		if(I.use_tool(user, src, WORKTIME_FAST, QUALITY_BOLT_TURNING, FAILCHANCE_VERY_EASY,  required_stat = STAT_MEC))
			watertemp = newtemp
			user.visible_message(SPAN_NOTICE("\The [user] adjusts \the [src] with \the [I]."), SPAN_NOTICE("You adjust the shower with \the [I]."))
			add_fingerprint(user)

/obj/machinery/shower/on_update_icon()	//this is terribly unreadable, but basically it makes the shower mist up
	cut_overlays()					//once it's been on for a while, in addition to handling the water overlay.
	if(mymist)
		qdel(mymist)
		mymist = null

	if(on)
		add_overlays(image('icons/obj/watercloset.dmi', src, "water", ABOVE_MOB_LAYER, dir))
		if(temperature_settings[watertemp] < T20C)
			return //no mist for cold water
		if(!ismist)
			spawn(50)
				if(src && on)
					ismist = 1
					mymist = new(loc)
		else
			mymist = new(loc)
	else if(ismist)
		mymist = new(loc)
		spawn(250)
			if(src && !on)
				qdel(mymist)
				mymist = null
				ismist = 0

//Yes, showers are super powerful as far as washing goes.
/obj/machinery/shower/proc/wash(atom/movable/O as obj|mob)
	if(!on) return

	if(isliving(O))
		var/mob/living/L = O
		L.ExtinguishMob()
		L.fire_stacks = -20 //Douse ourselves with water to avoid fire more easily

	if(iscarbon(O))
		var/mob/living/carbon/M = O
		if(M.r_hand)
			M.r_hand.clean_blood()
		if(M.l_hand)
			M.l_hand.clean_blood()
		if(M.back)
			if(M.back.clean_blood())
				M.update_inv_back(0)

		//flush away reagents on the skin
		if(M.touching)
			var/remove_amount = M.touching.maximum_volume * M.reagent_permeability() //take off your suit first
			M.touching.remove_any(remove_amount)

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/washgloves = 1
			var/washshoes = 1
			var/washmask = 1
			var/washears = 1
			var/washglasses = 1

			if(H.wear_suit)
				washgloves = !(H.wear_suit.flags_inv & HIDEGLOVES)
				washshoes = !(H.wear_suit.flags_inv & HIDESHOES)

			if(H.head)
				washmask = !(H.head.flags_inv & HIDEMASK)
				washglasses = !(H.head.flags_inv & HIDEEYES)
				washears = !(H.head.flags_inv & HIDEEARS)

			if(H.wear_mask)
				if (washears)
					washears = !(H.wear_mask.flags_inv & HIDEEARS)
				if (washglasses)
					washglasses = !(H.wear_mask.flags_inv & HIDEEYES)

			if(H.head)
				if(H.head.clean_blood())
					H.update_inv_head(0)
			if(H.wear_suit)
				if(H.wear_suit.clean_blood())
					H.update_inv_wear_suit(0)
			else if(H.w_uniform)
				if(H.w_uniform.clean_blood())
					H.update_inv_w_uniform(0)
			if(H.gloves && washgloves)
				if(H.gloves.clean_blood())
					H.update_inv_gloves(0)
			if(H.shoes && washshoes)
				if(H.shoes.clean_blood())
					H.update_inv_shoes(0)
			if(H.wear_mask && washmask)
				if(H.wear_mask.clean_blood())
					H.update_inv_wear_mask(0)
			if(H.glasses && washglasses)
				if(H.glasses.clean_blood())
					H.update_inv_glasses(0)
			if(H.l_ear && washears)
				if(H.l_ear.clean_blood())
					H.update_inv_ears(0)
			if(H.r_ear && washears)
				if(H.r_ear.clean_blood())
					H.update_inv_ears(0)
			if(H.belt)
				if(H.belt.clean_blood())
					H.update_inv_belt(0)
			H.clean_blood(washshoes)
			H.update_icons()
		else
			if(M.wear_mask)						//if the mob is not human, it cleans the mask without asking for bitflags
				if(M.wear_mask.clean_blood())
					M.update_inv_wear_mask(0)
			M.clean_blood()
	else
		O.clean_blood()

	if(isturf(loc))
		var/turf/tile = loc
		for(var/obj/effect/E in tile)
			if(istype(E,/obj/effect/decal/cleanable) || istype(E,/obj/effect/overlay))
				qdel(E)

	reagents.splash(O, 10)

/obj/machinery/shower/Process()
	if(!on) return

	for(var/thing in loc)
		var/atom/movable/AM = thing
		var/mob/living/L = thing
		if(istype(AM) && AM.simulated)
			wash(AM)
			if(istype(L))
				process_heat(L)
	wash_floor()
	reagents.add_reagent("water", reagents.get_free_space())

/obj/machinery/shower/proc/wash_floor()
	if(!ismist && is_washing)
		return
	is_washing = 1
	var/turf/T = get_turf(src)
	reagents.splash(T, reagents.total_volume)
	T.clean(src)
	spawn(100)
		is_washing = 0

/obj/machinery/shower/proc/process_heat(mob/living/M)
	if(!on || !istype(M)) return

	var/temperature = temperature_settings[watertemp]
	var/temp_adj = between(BODYTEMP_COOLING_MAX, temperature - M.bodytemperature, BODYTEMP_HEATING_MAX)
	M.bodytemperature += temp_adj

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(temperature >= H.species.heat_level_1)
			to_chat(H, SPAN_DANGER("The water is searing hot!"))
		else if(temperature <= H.species.cold_level_1)
			to_chat(H, SPAN_WARNING("The water is freezing cold!"))

/obj/item/bikehorn/rubberducky
	name = "rubber ducky"
	desc = "Rubber ducky you're so fine, you make bathtime lots of fuuun. Rubber ducky I'm awfully fooooond of yooooouuuu~"	//thanks doohl
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	item_state = "rubberducky"



/obj/structure/sink
	name = "sink"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	anchored = TRUE
	reagent_flags = OPENCONTAINER
	var/busy = 0 	//Something's being washed at the moment

/obj/structure/sink/MouseDrop_T(var/obj/item/thing, var/mob/user)
	. = ..()
	if(!istype(thing) || !thing.is_drainable())
		return
	if(!usr.Adjacent(src))
		return
	if(!thing.reagents || thing.reagents.total_volume == 0)
		to_chat(usr, SPAN_WARNING("\The [thing] is empty."))
		return FALSE
	// Clear the vessel.
	visible_message(SPAN_NOTICE("\The [usr] tips the contents of \the [thing] into \the [src]."))
	thing.reagents.clear_reagents()

/obj/structure/sink/attack_hand(mob/user as mob)
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.organs_by_name[BP_R_ARM]
		if (user.hand)
			temp = H.organs_by_name[BP_L_ARM]
		if(temp && !temp.is_usable())
			to_chat(user, SPAN_NOTICE("You try to move your [temp.name], but cannot!"))
			return

	if(isrobot(user) || isAI(user))
		return

	if(!Adjacent(user))
		return

	if(busy)
		to_chat(user, SPAN_WARNING("Someone's already washing here."))
		return

	to_chat(usr, SPAN_NOTICE("You start washing your hands."))

	playsound(loc, 'sound/effects/watersplash.ogg', 100, 1)

	busy = 1
	sleep(40)
	busy = 0

	if(!Adjacent(user)) return		//Person has moved away from the sink

	user.clean_blood()
	if(ishuman(user))
		user:update_inv_gloves()
	for(var/mob/V in viewers(src, null))
		V.show_message(SPAN_NOTICE("[user] washes their hands using \the [src]."))


/obj/structure/sink/attackby(obj/item/O as obj, mob/living/user as mob)
	if(busy)
		to_chat(user, SPAN_WARNING("Someone's already washing here."))
		return

	var/obj/item/reagent_containers/RG = O
	if (istype(RG) && RG.is_refillable())
		RG.reagents.add_reagent("water", min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
		user.visible_message(SPAN_NOTICE("[user] fills \the [RG] using \the [src]."),SPAN_NOTICE("You fill \the [RG] using \the [src]."))
		playsound(loc, 'sound/effects/watersplash.ogg', 100, 1)
		return 1

	else if (istype(O, /obj/item/melee/baton))
		var/obj/item/melee/baton/B = O
		if(B.cell)
			if(B.cell.charge > 0 && B.status == 1)
				FLICK("baton_active", src)
				user.Stun(10)
				user.stuttering = 10
				user.Weaken(10)
				if(isrobot(user))
					var/mob/living/silicon/robot/R = user
					R.cell.charge -= 20
				else
					B.deductcharge(B.hitcost)
				user.visible_message(
					SPAN_DANGER("[user] was stunned by \his wet [O]!"),
					"<span class='userdanger'>[user] was stunned by \his wet [O]!</span>"
				)
				return 1
	else if(istype(O, /obj/item/mop))
		return

	var/turf/location = user.loc
	if(!isturf(location)) return

	var/obj/item/I = O
	if(!I || !istype(I,/obj/item)) return

	to_chat(usr, SPAN_NOTICE("You start washing \the [I]."))

	busy = 1
	sleep(40)
	busy = 0

	if(user.loc != location) return				//User has moved
	if(!I) return 								//Item's been destroyed while washing
	if(user.get_active_hand() != I) return		//Person has switched hands or the item in their hands

	O.clean_blood()
	user.visible_message( \
		SPAN_NOTICE("[user] washes \a [I] using \the [src]."), \
		SPAN_NOTICE("You wash \a [I] using \the [src]."))

/obj/structure/sink/AltClick(var/mob/living/user)
	var/H = user.get_active_hand()
	if(istype(H,/obj/item/reagent_containers/glass) || istype(H,/obj/item/reagent_containers/food/drinks))
		var/obj/item/reagent_containers/O = user.get_active_hand()
		if(O.reagents && O.reagents.total_volume)
			O.reagents.clear_reagents()
			to_chat(user, SPAN_NOTICE("You empty the [O] into the [src]."))


/obj/structure/sink/kitchen
	name = "kitchen sink"
	icon_state = "sink_alt"

/obj/structure/sink/puddle	//splishy splashy ^_^
	name = "puddle"
	icon_state = "puddle"

/obj/structure/sink/puddle/attack_hand(mob/M as mob)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"

/obj/structure/sink/puddle/attackby(obj/item/O as obj, mob/user as mob)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"

/obj/structure/window
	name = "window"
	desc = "A window."
	icon = 'icons/obj/structures.dmi'

	density = TRUE
	layer = ABOVE_OBJ_LAYER //Just above doors
	anchored = TRUE
	flags = ON_BORDER
	var/maxhealth = 20
	var/resistance = RESISTANCE_NONE	//Incoming damage is reduced by this flat amount before being subtracted from health. Defines found in code\__defines\weapons.dm
	var/maximal_heat = T0C + 100 		// Maximal heat before this window begins taking damage from fire
	var/damage_per_fire_tick = 2 		// Amount of damage per fire tick. Regular windows are not fireproof so they might as well break quickly.
	var/health
	var/ini_dir = null
	var/state = 2
	var/reinf = 0
	var/basestate
	var/shardtype = /obj/item/material/shard
	var/glasstype = null // Set this in subtypes. Null is assumed strange or otherwise impossible to dismantle, such as for shuttle glass.
	var/silicate = 0 // number of units of silicate
	var/no_color = FALSE //If true, don't apply a color to the base

/obj/structure/window/can_prevent_fall()
	return !is_fulltile()

/obj/structure/window/get_fall_damage(var/turf/from, var/turf/dest)
	var/damage = health * 0.4

	if (from && dest)
		damage *= abs(from.z - dest.z)

	return damage

/obj/structure/window/examine(mob/user)
	. = ..(user)

	if(health == maxhealth)
		to_chat(user, SPAN_NOTICE("It looks fully intact."))
	else
		var/perc = health / maxhealth
		if(perc > 0.75)
			to_chat(user, SPAN_NOTICE("It has a few cracks."))
		else if(perc > 0.5)
			to_chat(user, SPAN_WARNING("It looks slightly damaged."))
		else if(perc > 0.25)
			to_chat(user, SPAN_WARNING("It looks moderately damaged."))
		else
			to_chat(user, SPAN_DANGER("It looks heavily damaged."))
	if(silicate)
		if (silicate < 30)
			to_chat(user, SPAN_NOTICE("It has a thin layer of silicate."))
		else if (silicate < 70)
			to_chat(user, SPAN_NOTICE("It is covered in silicate."))
		else
			to_chat(user, SPAN_NOTICE("There is a thick layer of silicate covering it."))


//Subtracts resistance from damage then applies it
//Returns the actual damage taken after resistance is accounted for. This is useful for audio volumes
/obj/structure/window/proc/take_damage(var/damage = 0,  var/sound_effect = 1, var/ignore_resistance = FALSE)
	var/initialhealth = health

	if (!ignore_resistance)
		damage = damage * (1 - silicate / 200) // up to 50% damage resistance 
		damage -= resistance // then flat resistance from material
	if (damage <= 0)
		return 0

	health = max(0, health - damage)

	if(health <= 0)
		if (prob(damage*2))//Heavy hits are more likely to send shards flying
			shatter(FALSE, TRUE)
		else
			//To break it safely, use a lighter hit to deal the finishing touch, or throw things from afar
			shatter()
	else
		if(sound_effect)
			playsound(loc, 'sound/effects/Glasshit.ogg', 100, 1)
		if(health < maxhealth / 4 && initialhealth >= maxhealth / 4)
			visible_message("[src] looks like it's about to shatter!" )
		else if(health < maxhealth / 2 && initialhealth >= maxhealth / 2)
			visible_message("[src] looks seriously damaged!" )
		else if(health < maxhealth * 3/4 && initialhealth >= maxhealth * 3/4)
			visible_message("Cracks begin to appear in [src]!" )
	return damage

/obj/structure/window/proc/apply_silicate(var/amount)
	if(health < maxhealth) // Mend the damage
		health = min(health + amount * 3, maxhealth)
		if(health == maxhealth)
			visible_message("[src] looks fully repaired." )
	else // Reinforce
		silicate = min(silicate + amount, 100)
		updateSilicate()

/obj/structure/window/proc/updateSilicate()
	if (is_full_window())
		return
	if (overlays)
		cut_overlays()

	var/image/img = image(src.icon, src.icon_state)
	img.color = "#ffffff"
	img.alpha = silicate * 255 / 100
	add_overlays(img)

//Setting the explode var makes the shattering louder and more violent, possibly injuring surrounding mobs
/obj/structure/window/proc/shatter(var/display_message = 1, var/explode = FALSE)
	alpha = 0
	if (explode)
		playsound(src, "shatter", 100, 1, 5,5)
	else
		playsound(src, "shatter", 70, 1)

	//Cache a list of nearby turfs for throwing shards at
	var/list/turf/nearby
	if (explode)
		nearby = (RANGE_TURFS(2, src) - get_turf(src))

	if(display_message)
		visible_message("[src] shatters!")
	if(is_full_window())
		var/index = null
		index = 0
		if(reinf)
			new /obj/item/stack/rods(loc)
		while(index < rand(4,6))
			var/obj/item/material/shard/S = new shardtype(loc)
			if (explode && nearby.len > 0)
				var/turf/target = pick(nearby)
				spawn()
					S.throw_at(target,40,3)
			index++
	else
		new shardtype(loc) //todo pooling?
		if(reinf)
			new /obj/item/stack/rods(loc)
	qdel(src)
	return


/obj/structure/window/bullet_act(var/obj/item/projectile/Proj)

	var/proj_damage = Proj.get_structure_damage()
	if(!proj_damage) return

	..()
	hit(proj_damage)
	return


/obj/structure/window/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			shatter(0,TRUE)
			return
		if(3)
			if(prob(50))
				shatter(0,TRUE)
				return

//TODO: Make full windows a separate type of window.
//Once a full window, it will always be a full window, so there's no point
//having the same type for both.
/obj/structure/window/proc/is_full_window()
	return (dir == SOUTHWEST || dir == SOUTHEAST || dir == NORTHWEST || dir == NORTHEAST)

/obj/structure/window/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(is_full_window())
		return 0	//full tile window, you can't move into it!
	if(get_dir(loc, target) & dir)
		return !density
	else
		return 1


/obj/structure/window/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(istype(O) && O.checkpass(PASSGLASS))
		return 1
	if(get_dir(O.loc, target) == dir)
		return !density
	return 1


/obj/structure/window/hitby(AM as mob|obj)
	..()
	visible_message(SPAN_DANGER("[src] was hit by [AM]."))
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else if(isobj(AM))
		var/obj/item/I = AM
		tforce = I.throwforce
	if(reinf) tforce *= 0.25
	if(health - tforce <= 7 && !reinf)
		set_anchored(FALSE)
		step(src, get_dir(AM, src))
	hit(tforce)
	mount_check()

/obj/structure/window/attack_tk(mob/user as mob)
	user.visible_message(SPAN_NOTICE("Something knocks on [src]."))
	playsound(loc, 'sound/effects/Glasshit.ogg', 50, 1)

/obj/structure/window/attack_hand(mob/user as mob)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if(HULK in user.mutations)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
		user.visible_message(SPAN_DANGER("[user] smashes through [src]!"))
		user.do_attack_animation(src)
		shatter(TRUE,TRUE)

	else if (usr.a_intent == I_HURT)

		if (ishuman(usr))
			var/mob/living/carbon/human/H = usr
			if(H.species.can_shred(H))
				attack_generic(H,25)
				return
		playsound(src.loc, 'sound/effects/glassknock.ogg', 100, 1, 10, 10)
		user.do_attack_animation(src)
		usr.visible_message(SPAN_DANGER("\The [usr] bangs against \the [src]!"),
							SPAN_DANGER("You bang against \the [src]!"),
							"You hear a banging sound.")
	else
		playsound(src.loc, 'sound/effects/glassknock.ogg', 80, 1, 5, 5)
		usr.visible_message("[usr.name] knocks on the [src.name].",
							"You knock on the [src.name].",
							"You hear a knocking sound.")
	return

/obj/structure/window/attack_generic(var/mob/user, var/damage)
	if(istype(user))
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		user.do_attack_animation(src)
	if(damage >= resistance)
		visible_message(SPAN_DANGER("[user] smashes into [src]!"))
		hit(damage)
	else
		visible_message(SPAN_NOTICE("\The [user] bonks \the [src] harmlessly."))
		playsound(src.loc, 'sound/effects/glasshit.ogg', 40, 1)
		return
	return 1

/obj/structure/window/affect_grab(var/mob/living/user, var/mob/living/target, var/state)
	target.do_attack_animation(src, FALSE) //This is to visually create the appearance of the victim being bashed against the window
	//So we pass false on the use_item flag so it doesn't look like they hit the window with something
	switch(state)
		if(GRAB_PASSIVE)
			visible_message(SPAN_WARNING("[user] slams [target] against \the [src]!"))
			target.damage_through_armor(6, BRUTE, BP_HEAD, ARMOR_MELEE)
			hit(10)
		if(GRAB_AGGRESSIVE)
			visible_message(SPAN_DANGER("[user] bashes [target] against \the [src]!"))
			if(prob(30))
				target.Weaken(1)
			target.damage_through_armor(8, BRUTE, BP_HEAD, ARMOR_MELEE)
			hit(15)
		if(GRAB_NECK)
			visible_message(SPAN_DANGER("<big>[user] crushes [target] against \the [src]!</big>"))
			target.Weaken(5)
			target.damage_through_armor(12, BRUTE, BP_HEAD, ARMOR_MELEE)
			hit(20)
	admin_attack_log(user, target,
		"Smashed [key_name(target)] against \the [src]",
		"Smashed against \the [src] by [key_name(user)]",
		"smashed [key_name(target)] against \the [src]."
	)
	sleep(5) //Allow a littleanimating time
	return TRUE


/obj/structure/window/attackby(obj/item/I, mob/user)

	var/list/usable_qualities = list()
	if(!anchored && (!state || !reinf))
		usable_qualities.Add(QUALITY_BOLT_TURNING)
	if((reinf && state >= 1) || (reinf && state == 0) || (!reinf))
		usable_qualities.Add(QUALITY_SCREW_DRIVING)
	if(reinf && state <= 1)
		usable_qualities.Add(QUALITY_PRYING)
	if (health < maxhealth)
		usable_qualities.Add(QUALITY_SEALING)

	//If you set intent to harm, you can hit the window with tools to break it. Set to any other intent to use tools on it
	if (usr.a_intent != I_HURT)
		var/tool_type = I.get_tool_type(user, usable_qualities, src)
		switch(tool_type)
			if(QUALITY_SEALING)
				user.visible_message("[user] starts sealing up cracks in [src] with the [I]", "You start sealing up cracks in [src] with the [I]")
				if (I.use_tool(user, src, 60 + ((maxhealth - health)*3), QUALITY_SEALING, FAILCHANCE_NORMAL, STAT_MEC))
					to_chat(user, SPAN_NOTICE("The [src] looks pretty solid now!"))
					health = maxhealth
			if(QUALITY_BOLT_TURNING)
				if(!anchored && (!state || !reinf))
					if(!glasstype)
						to_chat(user, SPAN_NOTICE("You're not sure how to dismantle \the [src] properly."))
						return
					if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_EASY, required_stat = STAT_MEC))
						visible_message(SPAN_NOTICE("[user] dismantles \the [src]."))
						if(is_fulltile())
							new glasstype(loc, 6)
						else
							new glasstype(loc, 1)
						qdel(src)
						return
				return 1 //No whacking the window with tools unless harm intent

			if(QUALITY_PRYING)
				if(reinf && state <= 1)
					if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_EASY, required_stat = STAT_MEC))
						state = 1 - state
						to_chat(user, (state ? SPAN_NOTICE("You have pried the window into the frame.") : SPAN_NOTICE("You have pried the window out of the frame.")))
				return 1 //No whacking the window with tools unless harm intent


			if(QUALITY_SCREW_DRIVING)
				if(reinf && state >= 1)
					if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_EASY, required_stat = STAT_MEC))
						state = 3 - state
						update_nearby_icons()
						to_chat(user, (state == 1 ? SPAN_NOTICE("You have unfastened the window from the frame.") : SPAN_NOTICE("You have fastened the window to the frame.")))
						return
				if(reinf && state == 0)
					if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_EASY, required_stat = STAT_MEC))
						set_anchored(!anchored)
						to_chat(user, (anchored ? SPAN_NOTICE("You have fastened the frame to the floor.") : SPAN_NOTICE("You have unfastened the frame from the floor.")))
						return
				if(!reinf)
					if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_VERY_EASY))
						set_anchored(!anchored)
						to_chat(user, (anchored ? SPAN_NOTICE("You have fastened the window to the floor.") : SPAN_NOTICE("You have unfastened the window.")))
						return
				return 1 //No whacking the window with tools unless harm intent

			if(ABORT_CHECK)
				return

	if(!istype(I)) return//I really wish I did not need this
	if(I.flags & NOBLUDGEON) return

	else
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		if(I.damtype == BRUTE || I.damtype == BURN)
			user.do_attack_animation(src)
			hit(I.force*I.structure_damage_factor)
			if(health <= 7)
				set_anchored(FALSE)
				step(src, get_dir(user, src))
		else
			playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
		..()
	return

/obj/structure/window/proc/hit(damage, sound_effect = TRUE, ignore_resistance = FALSE)
	damage = take_damage(damage, TRUE, ignore_resistance)
	if(sound_effect && loc) // If the window was shattered and, thus, nullspaced, don't try to play hit sound
		playsound(loc, 'sound/effects/glasshit.ogg', damage*4.5, 1, damage*0.6, damage*0.6) //The harder the hit, the louder and farther travelling the sound


/obj/structure/window/proc/rotate()
	set name = "Rotate Window Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return 0

	if(anchored)
		to_chat(usr, "It is fastened to the floor therefore you can't rotate it!")
		return 0

	update_nearby_tiles(need_rebuild=1) //Compel updates before
	set_dir(turn(dir, 90))
	updateSilicate()
	update_nearby_tiles(need_rebuild=1)
	return


/obj/structure/window/proc/revrotate()
	set name = "Rotate Window Clockwise"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return 0

	if(anchored)
		to_chat(usr, "It is fastened to the floor therefore you can't rotate it!")
		return 0

	update_nearby_tiles(need_rebuild=1) //Compel updates before
	set_dir(turn(dir, 270))
	updateSilicate()
	update_nearby_tiles(need_rebuild=1)
	return

/obj/structure/window/New(Loc, start_dir=null)
	..()

	//player-constructed windows

	if (start_dir)
		set_dir(start_dir)

	health = maxhealth

	ini_dir = dir

	update_nearby_tiles(need_rebuild=1)
	update_nearby_icons()

/obj/structure/window/Created()
	set_anchored(FALSE)


/obj/structure/window/Destroy()
	density = FALSE
	update_nearby_tiles()
	var/turf/location = loc
	loc = null
	for(var/obj/structure/window/W in orange(location, 1))
		W.update_icon()
	loc = location
	. = ..()

/obj/structure/window/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, var/glide_size_override = 0)
	var/ini_dir = dir
	update_nearby_tiles(need_rebuild=1)
	. = ..()
	set_dir(ini_dir)
	update_nearby_tiles(need_rebuild=1)
	mount_check()

//checks if this window is full-tile one
/obj/structure/window/proc/is_fulltile()
	if(dir & (dir - 1))
		return 1
	return 0

/obj/structure/window/set_anchored(new_anchored)
	. = ..()
	if(!.)
		return FALSE
	update_verbs()
	update_nearby_icons()

//This proc is used to update the icons of nearby windows. It should not be confused with update_nearby_tiles(), which is an atmos proc!
/obj/structure/window/proc/update_nearby_icons()
	update_icon()
	for(var/obj/structure/window/W in orange(src, 1))
		W.update_icon()

//Updates the availabiliy of the rotation verbs
/obj/structure/window/proc/update_verbs()
	if(anchored)
		verbs -= /obj/structure/window/proc/rotate
		verbs -= /obj/structure/window/proc/revrotate
	else
		verbs += /obj/structure/window/proc/rotate
		verbs += /obj/structure/window/proc/revrotate

//merges adjacent full-tile windows into one (blatant ripoff from game/smoothwall.dm)
/obj/structure/window/on_update_icon()
	//A little cludge here, since I don't know how it will work with slim windows. Most likely VERY wrong.
	//this way it will only update full-tile ones
	cut_overlays()
	if(!is_fulltile())
		icon_state = "[basestate]"
		return
	/*
	var/list/dirs = list()
	if(anchored)
		for(var/obj/structure/window/W in orange(src,1))
			if(W.anchored && W.density && W.type == src.type && W.is_fulltile()) //Only counts anchored, not-destroyed fill-tile windows.
				dirs += get_dir(src, W)

	for(var/turf/simulated/wall/T in RANGE_TURFS(1, src) - src)
		var/T_dir = get_dir(src, T)
		dirs |= T_dir
		if(propagate)
			spawn(0)
				T.update_connections()
				T.update_icon()
	*/
	//Since fulltile windows can't exist without an underlying wall, we will just copy connections from our wall
	var/list/connections = list("0", "0", "0", "0")
	var/obj/structure/low_wall/LW = (locate(/obj/structure/low_wall) in loc)
	if (istype(LW))
		connections = LW.connections

	icon_state = ""
	for(var/i = 1 to 4)
		var/image/I = image(icon, "[basestate][connections[i]]", dir = 1<<(i-1))
		add_overlays(I)

	return

/obj/structure/window/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > maximal_heat)
		hit(damage_per_fire_tick, TRUE, TRUE)
	..()



/obj/structure/window/basic
	desc = "It looks thin and flimsy. A few knocks with... anything, really should shatter it."
	icon_state = "window"
	basestate = "window"
	glasstype = /obj/item/stack/material/glass
	maximal_heat = T0C + 200	// Was 100. Spaceship windows surely surpass coffee pots.
	damage_per_fire_tick = 3	// Was 2. Made weaker than rglass per tick.
	maxhealth = 15
	resistance = RESISTANCE_NONE

/obj/structure/window/basic/full
	dir = SOUTH|EAST
	icon = 'icons/obj/structures/windows.dmi'
	icon_state = "fwindow"
	alpha = 120
	maxhealth = 40
	resistance = RESISTANCE_NONE
	flags = null

/obj/structure/window/plasmabasic
	name = "plasma window"
	desc = "A borosilicate alloy window. It seems to be quite strong."

	icon_state = "plasmawindow"
	shardtype = /obj/item/material/shard/plasma
	glasstype = /obj/item/stack/material/glass/plasmaglass
	maximal_heat = T0C + 5227  // Safe use temperature at 5500 kelvin. Easy to remember.
	damage_per_fire_tick = 1.5 // Lowest per-tick damage so overheated supermatter chambers have some time to respond to it. Will still shatter before a delam.
	maxhealth = 150
	resistance = RESISTANCE_AVERAGE

/obj/structure/window/plasmabasic/full
	dir = SOUTH|EAST
	icon = 'icons/obj/structures/windows.dmi'
	basestate = "pwindow"
	icon_state = "plasmawindow_mask"
	alpha = 150
	maxhealth = 200
	resistance = RESISTANCE_AVERAGE
	flags = null

/obj/structure/window/reinforced
	name = "reinforced window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."
	icon_state = "rwindow"
	basestate = "rwindow"
	reinf = 1
	maximal_heat = T0C + 750	// Fused quartz.
	damage_per_fire_tick = 2
	glasstype = /obj/item/stack/material/glass/reinforced

	maxhealth = 50
	resistance = RESISTANCE_FRAGILE

/obj/structure/window/New(Loc, constructed=0)
	..()

	//player-constructed windows
	if (constructed)
		state = 0

/obj/structure/window/reinforced/full
	dir = SOUTH|EAST
	icon = 'icons/obj/structures/windows.dmi'
	icon_state = "fwindow"
	alpha = 150
	maxhealth = 80
	resistance = RESISTANCE_FRAGILE
	flags = null

/obj/structure/window/reinforced/plasma
	name = "reinforced plasma window"
	desc = "A borosilicate alloy window, with rods supporting it. It seems to be very strong."
	basestate = "plasmarwindow"
	icon_state = "plasmarwindow"
	shardtype = /obj/item/material/shard/plasma
	glasstype = /obj/item/stack/material/glass/plasmarglass
	maximal_heat = T0C + 5453 // Safe use temperature at 6000 kelvin.
	damage_per_fire_tick = 1.5
	maxhealth = 200
	resistance = RESISTANCE_IMPROVED

/obj/structure/window/reinforced/plasma/full
	dir = SOUTH|EAST
	icon = 'icons/obj/structures/windows.dmi'
	basestate = "rpwindow"
	icon_state = "plasmarwindow_mask"
	alpha = 150
	maxhealth = 250
	resistance = RESISTANCE_IMPROVED
	flags = null

/obj/structure/window/reinforced/tinted
	name = "tinted window"
	desc = "It looks rather strong and opaque. Might take a few good hits to shatter it."
	icon_state = "twindow"
	basestate = "twindow"
	opacity = 1

/obj/structure/window/reinforced/tinted/frosted
	name = "frosted window"
	desc = "It looks rather strong and frosted over. Looks like it might take a few less hits then a normal reinforced window."
	icon_state = "fwindow"
	basestate = "fwindow"

/obj/structure/window/shuttle
	name = "shuttle window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."
	icon = 'icons/obj/podwindows.dmi'
	icon_state = "window"
	basestate = "window"
	maxhealth = 300
	resistance = RESISTANCE_IMPROVED
	reinf = 1
	basestate = "w"
	dir = 5

/obj/structure/window/reinforced/polarized
	name = "electrochromic window"

	desc = "Adjusts its tint with voltage. Might take a few good hits to shatter it."
	var/id

/obj/structure/window/reinforced/polarized/full
	dir = SOUTH|EAST
	icon = 'icons/obj/structures/windows.dmi'
	icon_state = "fwindow"
	flags = null

/obj/structure/window/reinforced/polarized/proc/toggle()
	if(opacity)
		animate(src, color="#FFFFFF", time=5)
		set_opacity(0)
		alpha = initial(alpha)
	else
		animate(src, color="#222222", time=5)
		set_opacity(1)
		alpha = 255

/obj/structure/window/reinforced/crescent/attack_hand()
	return

/obj/structure/window/reinforced/crescent/attackby()
	return

/obj/structure/window/reinforced/crescent/ex_act()
	return

/obj/structure/window/reinforced/crescent/hitby()
	return

/obj/structure/window/reinforced/crescent/take_damage()
	return

/obj/structure/window/reinforced/crescent/shatter()
	return

/obj/machinery/button/windowtint
	name = "window tint control"
	icon = 'icons/obj/power.dmi'
	icon_state = "light0"
	desc = "A remote control switch for polarized windows."
	var/range = 7

/obj/machinery/button/windowtint/attack_hand(mob/user as mob)
	if(..())
		return 1

	toggle_tint()

/obj/machinery/button/windowtint/proc/toggle_tint()
	use_power(5)

	active = !active
	update_icon()

	for(var/obj/structure/window/reinforced/polarized/W in range(src,range))
		if (W.id == src.id || !W.id)
			spawn(0)
				W.toggle()
				return

/obj/machinery/button/windowtint/power_change()
	..()
	if(active && !powered(power_channel))
		toggle_tint()

/obj/machinery/button/windowtint/on_update_icon()
	icon_state = "light[active]"


//Fulltile windows can only exist ontop of a low wall
//If they're ever not on a wall, they will drop to the floor and smash.
/obj/structure/window/proc/mount_check()
	if(QDELETED(src))
		return

	if (!is_full_window())
		return

	//If there's a wall under us, we're safe, stop here.
	if (locate(/obj/structure/low_wall) in loc)
		return

	//This is where the fun begins
	//First of all, lets be sure we're on a tile that has a floor
	var/turf/T = get_turf(src)

	//Hole tiles are empty space and openspace. Can't fall here.
	//But if its openspace we'll probably fall through and smash below. fall_impact will handle that
	if (T.is_hole)
		return

	//Check for gravity
	var/area/A = get_area(T)
	if (!A.has_gravity)
		//No gravity, cant fall here
		return


	//We're good, lets do this
	shatterfall()


//Used when the window finds itself no longer on a tile. For example if someone drags it out of the wall
//The window will do a litle animation of falling to the floor, giving them a brief moment to regret their mistake
/obj/structure/window/proc/shatterfall()
	sleep(5)
	animate(src, pixel_y = -12, time = 7, easing = QUAD_EASING)
	spawn(8)
		shatter(TRUE, TRUE) //Use explosive shattering, might injure nearby mobs with shards

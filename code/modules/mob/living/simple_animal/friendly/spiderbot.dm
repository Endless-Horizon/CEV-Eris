/mob/living/simple_animal/spiderbot

	min_oxy = 0
	max_tox = 0
	max_co2 = 0
	minbodytemp = 0
	maxbodytemp = 500
	mob_size = MOB_SMALL

	var/obj/item/device/radio/borg/radio = null
	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/cell/large/cell
	var/obj/machinery/camera/camera = null
	var/obj/item/device/mmi/mmi = null
	var/list/req_access = list(access_robotics) //Access needed to pop out the brain.
	var/positronic

	name = "spider-bot"
	desc = "A skittering robotic friend!"
	icon = 'icons/mob/robots.dmi'
	icon_state = "spiderbot-chassis"
	icon_dead = "spiderbot-smashed"

	wander = 0

	health = 10
	maxHealth = 10
	hunger_enabled = 0

	attacktext = "shocked"
	melee_damage_lower = 1
	melee_damage_upper = 3

	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"

	var/emagged = 0
	var/obj/item/held_item = null //Storage for single item they can hold.
	speed = -1                    //Spiderbots gotta go fast.
	pass_flags = PASSTABLE
	speak_emote = list("beeps","clicks","chirps")
	can_burrow = TRUE

/mob/living/simple_animal/spiderbot/New()
	..()
	add_language(LANGUAGE_COMMON)
	default_language = all_languages[LANGUAGE_COMMON]
	verbs |= /mob/living/proc/ventcrawl
	verbs |= /mob/living/proc/hide

/mob/living/simple_animal/spiderbot/attackby(var/obj/item/O as obj, var/mob/user as mob)

	if(istype(O, /obj/item/device/mmi))
		var/obj/item/device/mmi/B = O
		if(src.mmi)
			to_chat(user, SPAN_WARNING("There's already a brain in [src]!"))
			return
		if(!B.brainmob)
			to_chat(user, SPAN_WARNING("Sticking an empty MMI into the frame would sort of defeat the purpose."))
			return
		if(!B.brainmob.key)
			var/ghost_can_reenter = 0
			if(B.brainmob.mind)
				for(var/mob/observer/ghost/G in GLOB.player_list)
					if(G.can_reenter_corpse && G.mind == B.brainmob.mind)
						ghost_can_reenter = 1
						break
			if(!ghost_can_reenter)
				to_chat(user, SPAN_NOTICE("[O] is completely unresponsive; there's no point."))
				return

		if(B.brainmob.stat == DEAD)
			to_chat(user, SPAN_WARNING("[O] is dead. Sticking it into the frame would sort of defeat the purpose."))
			return

		if(jobban_isbanned(B.brainmob, "Robot"))
			to_chat(user, SPAN_WARNING("\The [O] does not seem to fit."))
			return

		to_chat(user, SPAN_NOTICE("You install \the [O] in \the [src]!"))

		if(istype(O, /obj/item/device/mmi/digital))
			positronic = 1
			add_language(LANGUAGE_ROBOT)

		user.drop_item()
		src.mmi = O
		src.transfer_personality(O)

		O.loc = src
		src.update_icon()
		return 1

	if(QUALITY_WELDING in O.tool_qualities)
		if(health < maxHealth)
			if(O.use_tool(user, src, WORKTIME_FAST, QUALITY_WELDING, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
				health += pick(1,1,1,2,2,3)
				if(health > maxHealth)
					health = maxHealth
				add_fingerprint(user)
				src.visible_message(SPAN_NOTICE("\The [user] has spot-welded some of the damage to \the [src]!"))
		else
			to_chat(user, SPAN_WARNING("\The [src] is undamaged!"))
		return

	else if(istype(O, /obj/item/card/id)||istype(O, /obj/item/modular_computer/pda))
		if (!mmi)
			to_chat(user, SPAN_DANGER("There's no reason to swipe your ID - \the [src] has no brain to remove."))
			return 0

		var/obj/item/card/id/id_card

		if(istype(O, /obj/item/card/id))
			id_card = O
		else
			id_card = O.GetIdCard()

		if(access_robotics in id_card.access)
			to_chat(user, SPAN_NOTICE("You swipe your access card and pop the brain out of \the [src]."))
			eject_brain()
			if(held_item)
				held_item.loc = src.loc
				held_item = null
			return 1
		else
			to_chat(user, SPAN_DANGER("You swipe your card with no effect."))
			return 0

	else
		O.attack(src, user, user.targeted_organ)

/mob/living/simple_animal/spiderbot/emag_act(var/remaining_charges, var/mob/user)
	if (emagged)
		to_chat(user, SPAN_WARNING("[src] is already overloaded - better run."))
		return 0
	else
		to_chat(user, SPAN_NOTICE("You short out the security protocols and overload [src]'s cell, priming it to explode in a short time."))
		spawn(100)	to_chat(src, SPAN_DANGER("Your cell seems to be outputting a lot of power..."))
		spawn(200)	to_chat(src, SPAN_DANGER("Internal heat sensors are spiking! Something is badly wrong with your cell!"))
		spawn(300)	src.explode()

/mob/living/simple_animal/spiderbot/proc/transfer_personality(var/obj/item/device/mmi/M as obj)

		src.mind = M.brainmob.mind
		src.mind.key = M.brainmob.key
		src.ckey = M.brainmob.ckey
		src.name = "spider-bot ([M.brainmob.name])"

/mob/living/simple_animal/spiderbot/proc/explode() //When emagged.
	src.visible_message(SPAN_DANGER("\The [src] makes an odd warbling noise, fizzles, and explodes!"))
	explosion(get_turf(loc), -1, -1, 3, 5)
	eject_brain()
	death()

/mob/living/simple_animal/spiderbot/on_update_icon()
	. = ..()
	if(mmi)
		if(positronic)
			icon_state = "spiderbot-chassis-posi"
			icon_living = "spiderbot-chassis-posi"
		else
			icon_state = "spiderbot-chassis-mmi"
			icon_living = "spiderbot-chassis-mmi"
	else
		icon_state = "spiderbot-chassis"
		icon_living = "spiderbot-chassis"

/mob/living/simple_animal/spiderbot/proc/eject_brain()
	if(mmi)
		var/turf/T = get_turf(loc)
		if(T)
			mmi.loc = T
		if(mind)	mind.transfer_to(mmi.brainmob)
		mmi = null
		real_name = initial(real_name)
		name = real_name
		update_icon()
	remove_language(LANGUAGE_ROBOT)
	positronic = null

/mob/living/simple_animal/spiderbot/Destroy()
	eject_brain()
	. = ..()

/mob/living/simple_animal/spiderbot/New()

	radio = new /obj/item/device/radio/borg(src)
	camera = new /obj/machinery/camera(src)
	camera.c_tag = "spiderbot-[real_name]"
	camera.replace_networks(list("SS13"))

	..()

/mob/living/simple_animal/spiderbot/death()

	GLOB.living_mob_list -= src
	GLOB.dead_mob_list += src

	if(camera)
		camera.status = 0

	if (held_item) // if the spiderbot is holding an item
		held_item.loc = src.loc
		held_item = null

	gibs(loc, null, null, /obj/effect/gibspawner/robot) //TODO: use gib() or refactor spiderbots into synthetics.
	qdel(src)
	return

//Cannibalized from the parrot mob. ~Zuhayr
/mob/living/simple_animal/spiderbot/verb/drop_held_item()
	set name = "Drop held item"
	set category = "Spiderbot"
	set desc = "Drop the item you're holding."

	if(stat)
		return

	if(!held_item)
		to_chat(usr, "\red You have nothing to drop!")
		return 0

	if(istype(held_item, /obj/item/grenade))
		visible_message(SPAN_DANGER("\The [src] launches \the [held_item]!"), \
			SPAN_DANGER("You launch \the [held_item]!"), \
			"You hear a skittering noise and a thump!")
		var/obj/item/grenade/G = held_item
		G.loc = src.loc
		G.prime()
		held_item = null
		return 1

	visible_message(SPAN_NOTICE("\The [src] drops \the [held_item]."), \
		SPAN_NOTICE("You drop \the [held_item]."), \
		"You hear a skittering noise and a soft thump.")

	held_item.loc = src.loc
	held_item = null
	return 1

/mob/living/simple_animal/spiderbot/verb/get_item()
	set name = "Pick up item"
	set category = "Spiderbot"
	set desc = "Allows you to take a nearby small item."

	if(stat)
		return -1

	if(held_item)
		to_chat(src, SPAN_WARNING("You are already holding \the [held_item]"))
		return 1

	var/list/items = list()
	for(var/obj/item/I in view(1,src))
		if(I.loc != src && I.w_class <= ITEM_SIZE_SMALL && I.Adjacent(src) )
			items.Add(I)

	var/obj/selection = input("Select an item.", "Pickup") in items

	if(selection)
		for(var/obj/item/I in view(1, src))
			if(selection == I)
				held_item = selection
				selection.loc = src
				visible_message(SPAN_NOTICE("\The [src] scoops up \the [held_item]."), \
					SPAN_NOTICE("You grab \the [held_item]."), \
					"You hear a skittering noise and a clink.")
				return held_item
		to_chat(src, SPAN_WARNING("\The [selection] is too far away."))
		return 0

	to_chat(src, SPAN_WARNING("There is nothing of interest to take."))
	return 0

/mob/living/simple_animal/spiderbot/examine(mob/user)
	..(user)
	if(src.held_item)
		to_chat(user, "It is carrying \icon[src.held_item] \a [src.held_item].")

/mob/living/simple_animal/spiderbot/cannot_use_vents()
	return

/mob/living/simple_animal/spiderbot/binarycheck()
	return positronic
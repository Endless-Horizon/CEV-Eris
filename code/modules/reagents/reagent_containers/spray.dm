/obj/item/reagent_containers/spray
	name = "spray bottle"
	desc = "A spray bottle, with an unscrewable top."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cleaner"
	item_state = "cleaner"
	flags = NOBLUDGEON
	reagent_flags = OPENCONTAINER
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = ITEM_SIZE_SMALL
	throw_speed = 2
	throw_range = 10
	amount_per_transfer_from_this = 10
	unacidable = TRUE //plastic
	possible_transfer_amounts = list(5,10) //Set to null instead of list, if there is only one.
	matter = list(MATERIAL_PLASTIC = 2)
	volume = 250
	var/spray_size = 3
	var/list/spray_sizes = list(1,3)

/obj/item/reagent_containers/spray/Initialize()
	. = ..()
	src.verbs -= /obj/item/reagent_containers/verb/set_APTFT

/obj/item/reagent_containers/spray/afterattack(atom/A as mob|obj, mob/user as mob, proximity)
	if(proximity)
		if(standard_dispenser_refill(user, A))
			return

	if(loc != user)
		return ..()

	if(istype(A, /obj/item/reagent_containers) || istype(A, /obj/structure/sink))
		return ..()

	if(reagents.total_volume < amount_per_transfer_from_this)
		to_chat(user, SPAN_NOTICE("\The [src] is empty!"))
		return

	Spray_at(A, user, proximity)

	playsound(src.loc, 'sound/effects/spray2.ogg', 50, 1, -6)

	user.setClickCooldown(4)

	if(reagents.has_reagent("sacid"))
		message_admins("[key_name_admin(user)] fired sulphuric acid from \a [src].")
		log_game("[key_name(user)] fired sulphuric acid from \a [src].")
	if(reagents.has_reagent("pacid"))
		message_admins("[key_name_admin(user)] fired Polyacid from \a [src].")
		log_game("[key_name(user)] fired Polyacid from \a [src].")
	if(reagents.has_reagent("lube"))
		message_admins("[key_name_admin(user)] fired Space lube from \a [src].")
		log_game("[key_name(user)] fired Space lube from \a [src].")
	return

/obj/item/reagent_containers/spray/proc/Spray_at(atom/A as mob|obj, mob/user as mob, proximity)
	if (A.density && proximity)
		A.visible_message("[usr] sprays [A] with [src].")
		reagents.splash(A, amount_per_transfer_from_this)
	else
		spawn(0)
			var/obj/effect/effect/water/chempuff/D = new/obj/effect/effect/water/chempuff(get_turf(src))
			var/turf/my_target = get_turf(A)
			D.create_reagents(amount_per_transfer_from_this)
			if(!src)
				return
			reagents.trans_to_obj(D, amount_per_transfer_from_this)
			D.set_color()
			D.set_up(my_target, spray_size, 10)
	return

/obj/item/reagent_containers/spray/attack_self(var/mob/user)
	if(!possible_transfer_amounts)
		return
	amount_per_transfer_from_this = next_list_item(amount_per_transfer_from_this, possible_transfer_amounts)
	spray_size = next_list_item(spray_size, spray_sizes)
	to_chat(user, SPAN_NOTICE("You adjusted the pressure nozzle. You'll now use [amount_per_transfer_from_this] units per spray."))

/obj/item/reagent_containers/spray/examine(mob/user)
	if(..(user, 0) && loc == user)
		to_chat(user, "[round(reagents.total_volume)] units left.")

/obj/item/reagent_containers/spray/verb/empty()

	set name = "Empty Spray Bottle"
	set category = "Object"
	set src in usr

	if (alert(usr, "Are you sure you want to empty that?", "Empty Bottle:", "Yes", "No") != "Yes")
		return
	if(isturf(usr.loc))
		to_chat(usr, SPAN_NOTICE("You empty \the [src] onto the floor."))
		reagents.splash(usr.loc, reagents.total_volume)

//space cleaner
/obj/item/reagent_containers/spray/cleaner
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"
	preloaded_reagents = list("cleaner" = 250)

/obj/item/reagent_containers/spray/cleaner/drone
	volume = 50
	preloaded_reagents = list("cleaner" = 50)

/obj/item/reagent_containers/spray/sterilizine
	name = "sterilizine"
	desc = "Great for hiding incriminating bloodstains and sterilizing scalpels."
	preloaded_reagents = list("sterilizine" = 250)

/obj/item/reagent_containers/spray/pepper
	name = "pepperspray"
	desc = "Manufactured by UhangInc, used to blind and down an opponent quickly."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "pepperspray"
	item_state = "pepperspray"
	possible_transfer_amounts = null
	price_tag = 300
	volume = 40
	var/safety = 1
	preloaded_reagents = list("condensedcapsaicin" = 40)

/obj/item/reagent_containers/spray/pepper/examine(mob/user)
	if(..(user, 1))
		to_chat(user, "The safety is [safety ? "on" : "off"].")

/obj/item/reagent_containers/spray/pepper/attack_self(var/mob/user)
	safety = !safety
	to_chat(usr, "<span class = 'notice'>You switch the safety [safety ? "on" : "off"].</span>")

/obj/item/reagent_containers/spray/pepper/Spray_at(atom/A as mob|obj)
	if(safety)
		to_chat(usr, "<span class = 'warning'>The safety is on!</span>")
		return
	..()

/obj/item/reagent_containers/spray/waterflower
	name = "water flower"
	desc = "A seemingly innocent sunflower...with a twist."
	icon = 'icons/obj/device.dmi'
	icon_state = "sunflower"
	item_state = "sunflower"
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = list(1, 5, 10)
	preloaded_reagents = list("water" = 50)

/obj/item/reagent_containers/spray/chemsprayer
	name = "chem sprayer"
	desc = "A utility used to spray large amounts of reagent in a given area."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "chemsprayer"
	item_state = "chemsprayer"
	throwforce = 3
	w_class = ITEM_SIZE_NORMAL
	matter = list(MATERIAL_STEEL = 20, MATERIAL_PLASTIC = 4)
	possible_transfer_amounts = null
	volume = 600
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3, TECH_ENGINEERING = 3)

/obj/item/reagent_containers/spray/chemsprayer/Spray_at(atom/A as mob|obj)
	var/direction = get_dir(src, A)
	var/turf/T = get_turf(A)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))
	var/list/the_targets = list(T, T1, T2)

	for(var/a = 1 to 3)
		spawn(0)
			if(reagents.total_volume < 1) break
			var/obj/effect/effect/water/chempuff/D = new/obj/effect/effect/water/chempuff(get_turf(src))
			var/turf/my_target = the_targets[a]
			D.create_reagents(amount_per_transfer_from_this)
			if(!src)
				return
			reagents.trans_to_obj(D, amount_per_transfer_from_this)
			D.set_color()
			D.set_up(my_target, rand(6, 8), 2)
	return

/obj/item/reagent_containers/spray/plantbgone
	name = "Plant-B-Gone"
	desc = "Kills those pesky weeds!"
	icon = 'icons/obj/hydroponics_machines.dmi'
	icon_state = "plantbgone"
	item_state = "plantbgone"
	volume = 100
	preloaded_reagents = list("plantbgone" = 100)

/obj/item/reagent_containers/spray/plantbgone/afterattack(atom/A as mob|obj, mob/user as mob, proximity)
	if(!proximity) return

	if(istype(A, /obj/effect/blob)) // blob damage in blob code
		return
	..()


/obj/item/reagent_containers/spray/vvd40
	name = "VVD-40"
	desc = "Relic of ancient times, rumoured to fix anything duct tape can't."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rejuvenating_agent_spray"
	volume = 100
	preloaded_reagents = list("rejuvenating_agent" = 50)
	spawn_blacklisted = TRUE
	rarity_value = 40
	spawn_tags = SPAWN_TAG_TOOL

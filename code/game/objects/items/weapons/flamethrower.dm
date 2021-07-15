/obj/item/flamethrower
	name = "flamethrower"
	desc = "You are a firestarter!"
	icon = 'icons/obj/flamethrower.dmi'
	icon_state = "flamethrowerbase"
	item_state = "flamethrower_0"
	flags = CONDUCT | NOBLUDGEON
	force = WEAPON_FORCE_NORMAL
	throwforce = WEAPON_FORCE_NORMAL
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_COMBAT = 2, TECH_PLASMA = 1)
	slot_flags = SLOT_BELT
	matter = list(MATERIAL_STEEL = 5)
	var/throw_amount = 50
	var/lit = FALSE	//on or off
	var/operating = 0//cooldown
	var/turf/previousturf = null
	var/obj/item/tank/plasma/ptank = null

	var/flamerange = 2
	var/gas_mult = 2.5


/obj/item/flamethrower/Destroy()
	if(ptank)
		qdel(ptank)

	return ..()


/obj/item/flamethrower/Process()
	if(ptank.air_contents.gas["plasma"] < 1)
		lit = FALSE
		STOP_PROCESSING(SSobj, src)
		var/turf/T = get_turf(src)
		T.visible_message(SPAN_WARNING("The flame on \the [src] went out."))
		update_icon()
		return
	var/turf/location = loc
	if(istype(location, /mob/))
		var/mob/M = location
		if(M.l_hand == src || M.r_hand == src)
			location = M.loc
	if(isturf(location)) //start a fire if possible
		location.hotspot_expose(700, 2)
	return


/obj/item/flamethrower/on_update_icon()
	cut_overlays()
	if(ptank)
		add_overlays("+ptank")
	if(lit)
		add_overlays("+lit")
	return

/obj/item/flamethrower/afterattack(atom/target, mob/user, proximity)
	if (!lit)
		to_chat(user, SPAN_WARNING("You press the trigger but nothing happens."))
	if (istype(target,/obj/item) && user == target.get_holding_mob())
		return
	if (get_dist(target, user) <= flamerange)
		// Make sure our user is still holding us
		var/turf/target_turf = get_turf(target)
		if(target_turf)
			var/turflist = getline(user, target_turf)
			flame_turf(turflist)

/obj/item/flamethrower/attackby(obj/item/W as obj, mob/user as mob)
	if(user.stat || user.restrained() || user.lying)	return

	if(istype(W,/obj/item/tank/plasma))
		if(ptank)
			to_chat(user, SPAN_NOTICE("There appears to already be a plasma tank loaded in [src]!"))
			return
		user.drop_item()
		ptank = W
		W.loc = src
		update_icon()
		return
	..()
	return


/obj/item/flamethrower/attack_self(mob/user as mob)
	if(user.stat || user.restrained() || user.lying)	return
	user.set_machine(src)
	var/dat = text("<TT><B>Flamethrower (<A HREF='?src=\ref[src];light=1'>[!lit ? "<font color='red'>Ignite</font>" : "Extinguish"]</a>)</B><BR>\n [ptank ? "Tank Pressure: [ptank.air_contents.return_pressure()]" : "No tank installed"]<BR>\nAmount to throw: <A HREF='?src=\ref[src];amount=-100'>-</A> <A HREF='?src=\ref[src];amount=-10'>-</A> <A HREF='?src=\ref[src];amount=-1'>-</A> [throw_amount] <A HREF='?src=\ref[src];amount=1'>+</A> <A HREF='?src=\ref[src];amount=10'>+</A> <A HREF='?src=\ref[src];amount=100'>+</A><BR>\n[ptank ? "<A HREF='?src=\ref[src];remove=1'>Remove plasmatank</A> - " : ""]<A HREF='?src=\ref[src];close=1'>Close</A></TT>")
	user << browse(dat, "window=flamethrower;size=340x160")
	onclose(user, "flamethrower")
	return


/obj/item/flamethrower/Topic(href,href_list[])
	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=flamethrower")
		return
	if(usr.stat || usr.restrained() || usr.lying)	return
	usr.set_machine(src)
	if(href_list["light"])
		if(!ptank || ptank.air_contents.gas["plasma"] < 1)
			to_chat(usr, SPAN_WARNING("You press the ignite button but nothing happens."))
			return
		lit = !lit
		if (lit)
			usr.visible_message(SPAN_WARNING("\The [usr] ignites \the [src]."), SPAN_WARNING("You ignite \the [src]."), "You hear sparking.")
			playsound(src.loc, 'sound/effects/sparks4.ogg', 50, 1)
			START_PROCESSING(SSobj, src)
		else
			usr.visible_message(SPAN_NOTICE("\The [usr] extinguish \the [src]."), SPAN_NOTICE("You extinguish \the [src]."))
			STOP_PROCESSING(SSobj, src)

	if(href_list["amount"])
		throw_amount = throw_amount + text2num(href_list["amount"])
		throw_amount = max(50, min(5000, throw_amount))
	if(href_list["remove"])
		if(!ptank)	return
		to_chat(usr, SPAN_NOTICE("You remove \the [ptank]."))
		usr.put_in_hands(ptank)
		ptank = null
		lit = 0
		usr.unset_machine()
		usr << browse(null, "window=flamethrower")
	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)
	update_icon()
	return


//Called from turf.dm turf/dblclick
/obj/item/flamethrower/proc/flame_turf(var/list/turflist)
	if(!lit || operating)	return
	operating = 1
	for(var/turf/T in turflist)
		if(T.density || istype(T, /turf/space))
			break
		if(!previousturf && length(turflist)>1)
			previousturf = get_turf(src)
			continue	//so we don't burn the tile we be standin on
		if(previousturf && LinkBlocked(previousturf, T))
			break
		ignite_turf(T)
		sleep(1)
	previousturf = null
	operating = 0
	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)
	return


/obj/item/flamethrower/proc/ignite_turf(turf/target)
	//TODO: DEFERRED Consider checking to make sure tank pressure is high enough before doing this...
	//Transfer 5% of current tank air contents to turf
	var/datum/gas_mixture/air_transfer = ptank.air_contents.remove_ratio(0.02*(throw_amount/100))

	new/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel(target,air_transfer.gas["plasma"]*gas_mult,get_dir(loc,target), get_turf(src))
	qdel(air_transfer)
	//Burn it based on transfered gas
	target.hotspot_expose((ptank.air_contents.temperature*2) + 380,500) // -- More of my "how do I shot fire?" dickery. -- TLE
	return

/obj/item/flamethrower/full/New(var/loc)
	..()
	ptank = new /obj/item/tank/plasma/(src)
	update_icon()
	return

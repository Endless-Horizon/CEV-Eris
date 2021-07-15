//The hatton is a breaching tool in the form of a melee-range "gun" which uses compressed gas to breach walls, airlocks and similar obstacles.
//The gas is supplied in expendable tubes, magazines essentially
//There's also a robot version which uses power instead of gas tubes.

/obj/item/hatton
	name = "Excelsior BT \"Hatton\""
	desc = "More an instrument than a weapon, this breaching tool was designed for emergency situations."
	icon = 'icons/obj/guns/breacher.dmi'
	icon_state = "Hatton_Hammer_1"
	item_state = "Hatton_Hammer_1"
	flags = PASSTABLE | CONDUCT
	slot_flags = SLOT_BELT
	//m_amt = 2000
	w_class = ITEM_SIZE_NORMAL
	attack_verb = list("struck", "hit", "bashed")
	price_tag = 1000
	spawn_blacklisted = TRUE
	var/obj/item/hatton_magazine/magazine
	origin_tech = list(TECH_COMBAT = 2)
	matter = list(MATERIAL_PLASTEEL = 10, MATERIAL_PLASTIC = 2)
	var/fire_sound = 'sound/weapons/pulse.ogg'
	var/fire_cooldown = 0
	var/last_fired = 0


/obj/item/hatton/Initialize()
	. = ..()
	update_icon()

/obj/item/hatton/on_update_icon()
	cut_overlays()
	if(magazine)
		if(magazine.charge)
			icon_state = "Hatton_Hammer_1"
			add_overlays(icon(icon, "[magazine.charge]/3"))
		else
			icon_state = "Hatton_Hammer_1_empty"
			add_overlays(icon(icon, "1/3"))
	else
		icon_state="Hatton_Hammer_0"


/obj/item/hatton/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/hatton_magazine))
		if(!magazine)
			user.drop_item()
			magazine = W
			magazine.loc = src
			update_icon()
			return
	return


/obj/item/hatton/attack_self(mob/living/user as mob)
	if(magazine)
		magazine.loc = get_turf(src.loc)
		user.put_in_hands(magazine)
		magazine.update_icon()
		magazine = null
		to_chat(user, SPAN_NOTICE("You pull the magazine out of \the [src]!"))
	update_icon()
	return


/obj/item/hatton/afterattack(atom/A as mob|obj|turf, mob/living/user as mob|obj, flag, params)
	if(!flag)
		return
	if(A.loc==user || istype(A, /obj/structure/closet) || istype(A,/obj/structure/table) || istype(A,/obj/item/storage))
		return
	Fire(A,user,params)


/obj/item/hatton/proc/click_empty(mob/user = null)
	if (user)
		user.visible_message(SPAN_DANGER("*click*"), SPAN_DANGER("*click*"))
	else
		src.visible_message(SPAN_DANGER("*click*"))
	playsound(src.loc, 'sound/weapons/empty.ogg', 100, 1)


/obj/item/hatton/proc/use_charge()
	if (magazine && magazine.charge > 0)
		magazine.charge--
		return TRUE
	return FALSE

/obj/item/hatton/proc/Fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, params)
	if (world.time < last_fired + fire_cooldown)
		to_chat(user, SPAN_WARNING("[src] is still cooling down, wait for [((last_fired + fire_cooldown) - world.time)*0.1] seconds"))
		click_empty()
		return

	if(isliving(user))
		var/mob/living/M = user
		if (HULK in M.mutations)
			to_chat(M, SPAN_WARNING("Your meaty finger is much too large for the trigger guard!"))
			return
	if (!Adjacent(loc, target))
		to_chat(user, SPAN_WARNING("You're too far away to breach that!"))
		return
	/*if(ishuman(user))
		if(user.dna && user.dna.mutantrace == "adamantine")
			to_chat(user, "\red Your metal fingers don't fit in the trigger guard!")
			return*/

	add_fingerprint(user)



	if(isliving(user))
		var/mob/living/M = user
		if ((CLUMSY in M.mutations) && prob(50))
			to_chat(user, SPAN_DANGER("[src] blows up in your face."))
			M.drop_item()
			Fire(get_turf(M))
			del(src)
			return

	if (use_charge())
		last_fired = world.time
		playsound(user, fire_sound, 70, 1)
		update_icon()
		var/turf/target_turf = get_turf(target)

		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(4, 1, target_turf)
		s.start()

		new /obj/effect/effect/smoke(target_turf)

		//The recoil stops you for a few seconds
		user.Stun(2)
		shake_camera(user, 3, 1)
		//and knocks you back a tile
		var/dir = turn(get_dir(get_turf(src), target_turf), 180)
		user.Move(get_step(get_turf(src), dir))

		for(var/atom/A in target_turf.contents)
			A.hatton_act()
		target_turf.hatton_act()
		new /obj/effect/effect/smoke(src.loc)
	else
		click_empty()


// Magazine
/obj/item/hatton_magazine
	name = "Excelsior BT \"Hatton\" gas tube"
	icon = 'icons/obj/guns/breacher.dmi'
	icon_state = "Hatton_box1"
	w_class = ITEM_SIZE_SMALL
	//m_amt = 15
	origin_tech = list(TECH_MATERIAL = 2)
	matter = list(MATERIAL_PLASMA = 10, MATERIAL_PLASTEEL = 2, MATERIAL_PLASTIC = 2)
	price_tag = 100
	spawn_blacklisted = TRUE

	var/charge = 3

/obj/item/hatton_magazine/Initialize()
	. = ..()
	update_icon()

/obj/item/hatton_magazine/on_update_icon()
	if(charge)
		icon_state = "Hatton_box1"
	else
		icon_state = "Hatton_box0"

/obj/item/hatton_magazine/moebius
	name = "Moebius BT \"Q-del\" gas tube"
	icon_state = "Moebius_box1"
	matter = list(MATERIAL_PLASMA = 10, MATERIAL_PLASTEEL = 2, MATERIAL_PLASTIC = 2)
	charge = 2

/obj/item/hatton_magazine/moebius/on_update_icon()
	if(charge)
		icon_state = "Moebius_box1"
	else
		icon_state = "Moebius_box0"


//Variants
//Robot variation draws power from internal cell instead of using magazines
//Just imagine the robot is using that power to run an internal air compressor to refill the tube.
//This also explains the cooldown between uses
/obj/item/hatton/robot
	fire_cooldown = 150 //fifteen second cooldown between uses
	desc = "More an instrument than a weapon, this breaching device was designed for emergency situations. It uses a massive surge of power to break down obstacles."
	spawn_frequency = 0
	var/power_cost = 200 KILOWATTS //This uses about 7.5% of the charge on a rescue robot

/obj/item/hatton/robot/use_charge()
	var/mob/living/silicon/robot/R = loc
	if (!istype(R))
		return FALSE

	if (R.cell_use_power(power_cost))
		return TRUE
	return FALSE

/obj/item/hatton/robot/attack_self(mob/living/user as mob)
	return

/obj/item/hatton/moebius
	name = "Moebius BT \"Q-del\""
	desc = {"This breaching tool was reverse engineered from the \"Hatton\" design.
	Despite the Excelsior \"Hatton\" being traded on the free market through Technomancer League channels,
	this device suffers from a wide number of reliability issues stemming from it being lathe printed."}
	icon_state = "Moebius_Hammer_1"
	item_state = "Moebius_Hammer_1"
	matter = list(MATERIAL_PLASTEEL = 8, MATERIAL_SILVER = 5, MATERIAL_PLASTIC = 5)
	spawn_blacklisted = TRUE

/obj/item/hatton/moebius/on_update_icon()
	cut_overlays()
	if(magazine)
		if(magazine.charge)
			icon_state = "Moebius_Hammer_1"
			add_overlays(icon(icon, "[magazine.charge]/3"))
		else
			icon_state = "Moebius_Hammer_1_empty"
			add_overlays(icon(icon, "1/3"))
	else
		icon_state = "Moebius_Hammer_0"

/obj/item/hatton/moebius/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/hatton_magazine/moebius))
		if(!magazine)
			user.drop_item()
			magazine = W
			magazine.loc = src
			update_icon()
			return
	return

//reactions

/atom/proc/hatton_act()
	return


/mob/hatton_act()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		H.take_overall_damage(35, 10)
	else
		ex_act(2)
//turfs

/turf/simulated/wall/hatton_act()
	src.ChangeTurf("/turf/simulated/floor")

/turf/simulated/wall/r_wall/hatton_act()
	take_damage(1000)

/turf/simulated/mineral/hatton_act()
	ex_act(1)



//strucutres


/*/obj/structure/mineral_door/hatton_act()
	Dismantle()*/

/obj/structure/hatton_act()
	ex_act(1)

/obj/machinery/deployable/barrier/hatton_act()
	visible_message(SPAN_DANGER("The [src] is blown apart!"))
	qdel(src)




//machines

/obj/machinery/hatton_act()
	ex_act(2)

/obj/machinery/computer/hatton_act()
	..()
	set_broken()
	return

/obj/machinery/door/hatton_act()
	ex_act(1)


//ignore

/obj/machinery/atmospherics/hatton_act()
	return

/obj/structure/cable/hatton_act()
	return




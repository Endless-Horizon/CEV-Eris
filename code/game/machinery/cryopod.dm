/*
 * Cryogenic refrigeration unit. Basically a despawner.
 * Stealing a lot of concepts/code from sleepers due to massive laziness.
 * The despawn tick will only fire if it's been more than time_till_despawned ticks
 * since time_entered, which is world.time when the occupant moves in.
 * ~ Zuhayr
 */


//Main cryopod console.

/obj/machinery/computer/cryopod
	name = "cryogenic oversight console"
	desc = "An interface between crew and the cryogenic storage oversight systems."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "cellconsole"
	light_power = 1.5
	light_color = COLOR_LIGHTING_BLUE_MACHINERY
	circuit = /obj/item/electronics/circuitboard/cryopodcontrol
	density = FALSE
	interact_offline = 1
	var/mode = null

	//Used for logging people entering cryosleep and important items they are carrying.
	var/list/frozen_crew = list()
	var/list/frozen_items = list()
	var/list/_admin_logs = list() // _ so it shows first in VV

	var/storage_type = "crewmembers"
	var/storage_name = "Cryogenic Oversight Control"
	var/allow_items = 1

/obj/machinery/computer/cryopod/robot
	name = "robotic storage console"
	desc = "An interface between crew and the robotic storage systems"
	icon = 'icons/obj/robot_storage.dmi'
	icon_state = "console"
	circuit = /obj/item/electronics/circuitboard/robotstoragecontrol

	storage_type = "cyborgs"
	storage_name = "Robotic Storage Control"
	allow_items = 0

/obj/machinery/computer/cryopod/attack_hand(mob/user = usr)
	if(stat & (NOPOWER|BROKEN))
		return

	user.set_machine(src)
	src.add_fingerprint(usr)

	var/dat

	dat += "<hr/><br/><b>[storage_name]</b><br/>"
	dat += "<i>Welcome, [user.real_name].</i><br/><br/><hr/>"
	dat += "<a href='?src=\ref[src];log=1'>View storage log</a>.<br>"
	if(allow_items)
		dat += "<a href='?src=\ref[src];view=1'>View objects</a>.<br>"
		dat += "<a href='?src=\ref[src];item=1'>Recover object</a>.<br>"
		dat += "<a href='?src=\ref[src];allitems=1'>Recover all objects</a>.<br>"

	user << browse(dat, "window=cryopod_console")
	onclose(user, "cryopod_console")

/obj/machinery/computer/cryopod/Topic(href, href_list)

	if(..())
		return

	var/mob/user = usr

	src.add_fingerprint(user)

	if(href_list["log"])

		var/dat = "<b>Recently stored [storage_type]</b><br/><hr/><br/>"
		for(var/person in frozen_crew)
			dat += "[person]<br/>"
		dat += "<hr/>"

		user << browse(dat, "window=cryolog")

	if(href_list["view"])
		if(!allow_items) return

		var/dat = "<b>Recently stored objects</b><br/><hr/><br/>"
		for(var/obj/item/I in frozen_items)
			dat += "[I.name]<br/>"
		dat += "<hr/>"

		user << browse(dat, "window=cryoitems")

	else if(href_list["item"])
		if(!allow_items) return

		if(frozen_items.len == 0)
			to_chat(user, "<span class='notice'>There is nothing to recover from storage.</span>")
			return

		var/obj/item/I = input(usr, "Please choose which object to retrieve.","Object recovery",null) as null|anything in frozen_items
		if(!I)
			return

		if(!(I in frozen_items))
			to_chat(user, "<span class='notice'>\The [I] is no longer in storage.</span>")
			return

		visible_message("<span class='notice'>The console beeps happily as it disgorges \the [I].</span>")

		I.forceMove(get_turf(src))
		frozen_items -= I

	else if(href_list["allitems"])
		if(!allow_items) return

		if(frozen_items.len == 0)
			to_chat(user, "<span class='notice'>There is nothing to recover from storage.</span>")
			return

		visible_message("<span class='notice'>The console beeps happily as it disgorges the desired objects.</span>")

		for(var/obj/item/I in frozen_items)
			I.forceMove(get_turf(src))
			frozen_items -= I

	src.updateUsrDialog()
	return

/obj/item/electronics/circuitboard/cryopodcontrol
	name = "Circuit board (Cryogenic Oversight Console)"
	build_path = /obj/machinery/computer/cryopod
	origin_tech = list(TECH_DATA = 3)

/obj/item/electronics/circuitboard/robotstoragecontrol
	name = "Circuit board (Robotic Storage Console)"
	build_path = /obj/machinery/computer/cryopod/robot
	origin_tech = list(TECH_DATA = 3)

//Decorative structures to go alongside cryopods.
/obj/structure/cryofeed
	name = "cryogenic feed"
	desc = "A bewildering tangle of machinery and pipes."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "cryo_rear"
	density = TRUE
	anchored = TRUE
	dir = WEST

//Cryopods themselves.
/obj/machinery/cryopod
	name = "cryogenic freezer"
	desc = "A man-sized pod for entering suspended animation."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "cryopod"
	density = TRUE
	anchored = TRUE
	dir = WEST

	var/on_store_message = "has entered long-term storage."
	var/on_store_name = "Cryogenic Oversight"
	var/on_enter_occupant_message = "You feel cool air surround you. You go numb as your senses turn inward."
	var/allow_occupant_types = list(/mob/living/carbon/human)
	var/disallow_occupant_types = list()

	var/mob/occupant = null       // Person waiting to be despawned.
	var/time_till_despawn = 6000  // 10 minutes-ish safe period before being despawned.
	var/time_entered = 0          // Used to keep track of the safe period.
	var/obj/item/device/radio/intercom/announce //

	var/obj/machinery/computer/cryopod/control_computer
	var/last_no_computer_message = 0
	var/applies_stasis = 1

	// These items are preserved when the process() despawn proc occurs.
	var/list/preserve_items = list(
		/obj/item/hand_tele,
		/obj/item/card/id/captains_spare,
		/obj/item/device/aicard,
		/obj/item/device/mmi,
		/obj/item/device/paicard,
		/obj/item/gun,
		/obj/item/pinpointer,
		/obj/item/clothing/suit,
		/obj/item/clothing/shoes/magboots,
		/obj/item/blueprints,
		/obj/item/clothing/head/space,
		/obj/item/storage/internal
	)

/obj/machinery/cryopod/robot
	name = "robotic storage unit"
	desc = "A storage unit for robots."
	icon = 'icons/obj/robot_storage.dmi'
	icon_state = "pod"
	on_store_message = "has entered robotic storage."
	on_store_name = "Robotic Storage Oversight"
	on_enter_occupant_message = "The storage unit broadcasts a sleep signal to you. Your systems start to shut down, and you enter low-power mode."
	allow_occupant_types = list(/mob/living/silicon/robot)
	disallow_occupant_types = list(/mob/living/silicon/robot/drone)
	applies_stasis = 0

/obj/machinery/cryopod/New()
	announce = new /obj/item/device/radio/intercom(src)
	update_icon()
	..()

/obj/machinery/cryopod/Destroy()
	if(occupant)
		occupant.forceMove(loc)
		occupant.resting = 1
	. = ..()

/obj/machinery/cryopod/Initialize()
	. = ..()

	find_control_computer()

/obj/machinery/cryopod/on_update_icon()
	if(occupant)
		icon_state = "[initial(icon_state)]_1"
	else
		icon_state = "[initial(icon_state)]_0"

/obj/machinery/cryopod/proc/find_control_computer(urgent=0)
	// Workaround for http://www.byond.com/forum/?post=2007448
	for(var/obj/machinery/computer/cryopod/C in src.loc.loc)
		control_computer = C
		break
	// control_computer = locate(/obj/machinery/computer/cryopod) in src.loc.loc

	// Don't send messages unless we *need* the computer, and less than five minutes have passed since last time we messaged
	if(!control_computer && urgent && last_no_computer_message + 5*60*10 < world.time)
		log_admin("Cryopod in [src.loc.loc] could not find control computer!")
		message_admins("Cryopod in [src.loc.loc] could not find control computer!")
		last_no_computer_message = world.time

	return control_computer != null

/obj/machinery/cryopod/proc/check_occupant_allowed(mob/M)
	var/correct_type = 0
	for(var/type in allow_occupant_types)
		if(istype(M, type))
			correct_type = 1
			break

	if(!correct_type) return 0

	for(var/type in disallow_occupant_types)
		if(istype(M, type))
			return 0

	return 1

//Lifted from Unity stasis.dm and refactored. ~Zuhayr
/obj/machinery/cryopod/Process()
	if(occupant)
		//Allow a ten minute gap between entering the pod and actually despawning.
		if(world.time - time_entered < time_till_despawn)
			return

		if(!occupant.client && occupant.stat<2) //Occupant is living and has no client.
			if(!control_computer)
				if(!find_control_computer(urgent=1))
					return

			despawn_occupant()

// This function can not be undone; do not call this unless you are sure
// Also make sure there is a valid control computer
/obj/machinery/cryopod/robot/despawn_occupant()
	var/mob/living/silicon/robot/R = occupant
	if(!istype(R)) return ..()

	qdel(R.mmi)

	// Cryopod code to extract items from cyborgs before calling ..() so the cybrog is in clean state for proc/despawn_occupant()
	for(var/obj/item/I in R.module) // the tools the borg has; metal, glass, guns etc
		for(var/obj/item/O in I) // the things inside the tools, if anything; mainly for janiborg trash bags
			O.forceMove(R)
		qdel(I)

	qdel(R.module)

	return ..()

// This function can not be undone; do not call this unless you are sure
// Also make sure there is a valid control computer
/obj/machinery/cryopod/proc/despawn_occupant()
	var/mob/living/carbon/human/H = occupant
	var/list/occupant_organs
	if(istype(H))
		occupant_organs = H.organs | H.internal_organs

	//Drop all items into the pod.
	//// Local pod code
	for(var/obj/item/W in occupant)
		// Don't delete the organs!
		if(W in occupant_organs)
			continue

		occupant.drop_from_inventory(W)
		W.forceMove(src)

		if(W.contents.len) //Make sure we catch anything not handled by qdel() on the items.
			for(var/obj/item/O in W.contents)
				if(istype(O,/obj/item/storage/internal)) //Stop eating pockets, you fuck!
					continue
				O.forceMove(src)

	//Delete all items not on the preservation list.
	var/list/items = src.contents.Copy()
	items -= occupant // Don't delete the occupant
	items -= announce // or the autosay radio.

	// Preserve the mmi brain, quite snowflake code here
	for(var/obj/item/W in items)
		var/preserve = null
		// Snowflaaaake.
		if(istype(W, /obj/item/device/mmi))
			var/obj/item/device/mmi/brain = W
			if(brain.brainmob && brain.brainmob.client && brain.brainmob.key)
				preserve = 1
			else
				continue
		else
			for(var/T in preserve_items)
				if(istype(W,T))
					preserve = 1
					break

		if(!preserve)
			qdel(W)
		else
			if(control_computer && control_computer.allow_items)
				control_computer.frozen_items += W
				W.loc = null
			else
				W.forceMove(src.loc)

	//Make an announcement and log the person entering storage.
	control_computer.frozen_crew += "[occupant.real_name]" + "[occupant.mind ? ", [occupant.mind.assigned_role]" : ""]" + " - [stationtime2text()]"
	control_computer._admin_logs += "[key_name(occupant)]" + "[occupant.mind ? ", ([occupant.mind.assigned_role])" : ""]" + " at [stationtime2text()]"
	log_and_message_admins("[key_name(occupant)]" + "[occupant.mind ? " ([occupant.mind.assigned_role])" : ""]" + " entered cryostorage.")

	announce.autosay("[occupant.real_name]" + "[occupant.mind ? ", [occupant.mind.assigned_role]" : ""]" + ", [on_store_message]", "[on_store_name]")
	visible_message("<span class='notice'>\The [initial(name)] hums and hisses as it moves [occupant.real_name] into storage.</span>")

	//When the occupant is put into storage, their respawn time is reduced.
	//This check exists for the benefit of people who get put into cryostorage while SSD and come back later
	if (occupant.in_perfect_health())
		if (occupant.mind && occupant.mind.key)

			//Whoever inhabited this body is long gone, we need some black magic to find where and who they are now
			var/mob/M = key2mob(occupant.mind.key)
			if (istype(M))
				if (!(M.get_respawn_bonus("CRYOSLEEP")))
					//We send a message to the occupant's current mob - probably a ghost, but who knows.
					to_chat(M, SPAN_NOTICE("Because your body was put into cryostorage, your crew respawn time has been reduced by [CRYOPOD_SPAWN_BONUS_DESC]."))
					M << 'sound/effects/magic/blind.ogg' //Play this sound to a player whenever their respawn time gets reduced

				//Going safely to cryo will allow the patient to respawn more quickly
				M.set_respawn_bonus("CRYOSLEEP", CRYOPOD_SPAWN_BONUS)

	// This despawn is not a gib() in this sense, it is used to remove objectives tied on these despawned mobs in cryos
	occupant.despawn()
	set_occupant(null)

/obj/machinery/cryopod/affect_grab(var/mob/user, var/mob/target)
	try_put_inside(target, user)
	return TRUE

/obj/machinery/cryopod/MouseDrop_T(var/mob/living/L, mob/living/user)
	if(istype(L) && istype(user))
		try_put_inside(L, user)

/obj/machinery/cryopod/proc/try_put_inside(var/mob/living/affecting, var/mob/living/user)
	if(occupant)
		to_chat(user, "<span class='notice'>\The [src] is in use.</span>")
		return

	if(!ismob(affecting) || !Adjacent(affecting) || !Adjacent(user))
		return

	if(!check_occupant_allowed(affecting))
		return

	var/willing = null //We don't want to allow people to be forced into despawning.

	if(affecting != user && affecting.client)
		if(alert(affecting,"Would you like to enter long-term storage?",,"Yes","No") == "Yes")
			if(!affecting)
				return
			willing = 1
	else
		willing = 1

	if(willing)

		visible_message("[user] starts putting [affecting] into \the [src].")

		if(!do_after(user, 20, src))
			return

		if(!user || !Adjacent(user))
			return
		if(!affecting || !Adjacent(affecting))
			return

		set_occupant(affecting)

		// Book keeping!
		var/turf/location = get_turf(src)
		log_admin("[key_name_admin(affecting)] has entered a stasis pod. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[location.x];Y=[location.y];Z=[location.z]'>JMP</a>)")
		message_admins("<span class='notice'>[key_name_admin(affecting)] has entered a stasis pod.</span>")
		if(user == affecting)
			src.add_fingerprint(affecting)

		//Despawning occurs when process() is called with an occupant without a client.
		src.add_fingerprint(user)



/obj/machinery/cryopod/verb/eject()
	set name = "Eject Pod"
	set category = "Object"
	set src in oview(1)
	if(!usr) // when called from preferences_spawnpoints.dm there is no usr since it is called indirectly. If there is no occupant and usr something really bad has happened here so just keep them in the pod - Hopek
		if(!occupant)
			return
		usr = occupant
	if(usr.stat != 0)
		return

	//Eject any items that aren't meant to be in the pod. Attempts to put the items back on the occupant otherwise drops them.
	var/list/items = src.contents
	if(occupant)
		if(usr != occupant && !occupant.client && occupant.stat != DEAD)
			to_chat(usr, SPAN_WARNING("It's locked inside!"))
			return
		items -= occupant
	if(announce)
		items -= announce

	for(var/obj/item/W in items)
		W.forceMove(get_turf(src))
		occupant.equip_to_appropriate_slot(W) // Items are now ejected. Tries to put them items on the occupant so they don't leave them behind

	src.go_out()
	add_fingerprint(usr)

	name = initial(name)
	return

/obj/machinery/cryopod/verb/move_inside()
	set name = "Enter Pod"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0 || !check_occupant_allowed(usr))
		return

	if(src.occupant)
		to_chat(usr, "<span class='notice'><B>\The [src] is in use.</B></span>")
		return

	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			to_chat(usr, "You're too busy getting your life sucked out of you.")
			return

	visible_message("[usr] starts climbing into \the [src].")

	if(do_after(usr, 20, src))

		if(!usr || !usr.client)
			return

		if(src.occupant)
			to_chat(usr, "<span class='notice'><B>\The [src] is in use.</B></span>")
			return

		usr.stop_pulling()
		set_occupant(usr)

		src.add_fingerprint(usr)

	return

/obj/machinery/cryopod/relaymove(var/mob/user)
	..()
	eject()

/obj/machinery/cryopod/proc/go_out()

	if(!occupant)
		return

	set_occupant(null)

	spawn(30)
		state("Please remember to check inside the cryopod if any belongings are missing.")
		playsound(loc, "robot_talk_light", 100, 0, 0)

//Notifications is set false when someone spawns in here
/obj/machinery/cryopod/proc/set_occupant(var/mob/living/new_occupant, var/notifications = TRUE)
	name = initial(name)
	if(new_occupant)
		occupant = new_occupant
		if (occupant.name)
			name = "[name] ([occupant.name])"
		else
			//Name isn't set during spawning, but real_name is. This is used for people spawning in cryopods
			name = "[name] ([occupant.real_name])"

		time_entered = world.time
		if(ishuman(occupant) && applies_stasis)
			var/mob/living/carbon/human/H = occupant
			H.EnterStasis()
		new_occupant.forceMove(src)

		if (notifications)
			to_chat(occupant, SPAN_NOTICE("[on_enter_occupant_message]"))
			to_chat(occupant, SPAN_NOTICE("<b>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</b>"))
		if (occupant.in_perfect_health() && notifications)
			to_chat(occupant, SPAN_NOTICE("<b>Your respawn time will be reduced by 20 minutes, allowing you to respawn as a crewmember much more quickly.</b>"))
		else if (notifications)
			to_chat(occupant, SPAN_DANGER("<b>Because you are not in perfect health, going into cryosleep will not reduce your crew respawn time. \
			If you wish to respawn as a different crewmember, you should treat your injuries at medical first</b>"))

	else
		if(!QDELETED(occupant))
			occupant.forceMove(get_turf(src))
			occupant.reset_view(null)
			if(ishuman(occupant) && applies_stasis)
				var/mob/living/carbon/human/H = occupant
				H.ExitStasis()
		occupant = null

	update_icon()

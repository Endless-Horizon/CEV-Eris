#define WASHSTATE_EMPTYOPENDOOR 1
#define WASHSTATE_EMPTYCLOSEDDOOR 2
#define WASHSTATE_FULLOPENDOOR 3
#define WASHSTATE_FULLCLOSEDDOOR 4
#define WASHSTATE_RUNNING 5
#define WASHSTATE_BLOODOPENDOOR 6
#define WASHSTATE_BLOODCLOSEDDOOR 7
#define WASHSTATE_BLOODRUNNING 8

//Halved as the Machinery SS takes 2 seconds to fire
#define WASH_BASETIME 30
#define WASH_ADDTIME 2.5

/obj/machinery/washing_machine
	name = "Washing Machine"
	desc = "Always able to clean your muddy clothes."
	icon = 'icons/obj/machines/washing_machine.dmi'
	icon_state = "wm_10"
	density = TRUE
	anchored = TRUE
	active_power_usage = 400
	var/state = WASHSTATE_EMPTYOPENDOOR
	//1 = empty, open door
	//2 = empty, closed door
	//3 = full, open door
	//4 = full, closed door
	//5 = running
	//6 = blood, open door
	//7 = blood, closed door
	//8 = blood, running
	var/panel = 0
	//0 = closed
	//1 = open
	var/hacked = 1 //Bleh, screw hacking, let's have it hacked by default.
	//0 = not hacked
	//1 = hacked
	var/gibs_ready = 0
	var/obj/crayon

	var/tick = 0

	var/list/allowed_types = list(/obj/item/clothing,
	/obj/item/storage/pouch,
	/obj/item/stack/material/hairlesshide,
	/obj/item/bedsheet,
	/obj/item/storage/belt,
	/obj/item/storage/backpack,
	/obj/item/rig)

/obj/machinery/washing_machine/Destroy()
	qdel(crayon)
	crayon = null
	. = ..()


//A washing machine cleans away most of the bad effects of old clothes
//Armor penalties and name/desc changes are left
/obj/machinery/washing_machine/proc/wash(atom/A)
	A.clean_blood()
	if(isobj(A))
		var/obj/O = A
		if(istype(A, /obj/item))
			var/obj/item/I = A
			I.decontaminate()
		O.make_young()

/obj/machinery/washing_machine/Process()
	if(tick > 0 && (state in list(WASHSTATE_BLOODRUNNING, WASHSTATE_RUNNING)))
		if(--tick <= 0)
			for(var/atom/A in contents)
				wash(A)
				if(istype(A, /obj/item))
					var/obj/item/I = A

					if(istype(crayon,/obj/item/pen/crayon) && (istype(I, /obj/item/clothing/gloves/color) || istype(I, /obj/item/clothing/head/soft) || istype(I, /obj/item/clothing/shoes/color) || istype(I, /obj/item/clothing/under/color)))
						var/obj/item/clothing/C = I
						var/obj/item/pen/crayon/CR = crayon
						C.color = CR.colour
						C.name = "[CR.colourName] dyed [C.initial_name]"

			//Tanning!
			for(var/obj/item/stack/material/hairlesshide/HH in contents)
				var/obj/item/stack/material/wetleather/WL = new(src)
				WL.amount = HH.amount
				qdel(HH)

			if( locate(/mob,contents) )
				state = WASHSTATE_BLOODCLOSEDDOOR
				gibs_ready = 1
			else
				state = WASHSTATE_FULLCLOSEDDOOR
			use_power = IDLE_POWER_USE
			update_icon()

/obj/machinery/washing_machine/examine(mob/user)
	..()
	if(tick > 0 && (state in list(WASHSTATE_BLOODRUNNING, WASHSTATE_RUNNING)))
		to_chat(user, SPAN_NOTICE("It has [tick*(SSmachines.wait/10)] seconds remaining on this cycle."))


/obj/machinery/washing_machine/verb/start()
	set name = "Start Washing"
	set category = "Object"
	set src in oview(1)

	if(!isliving(usr)) //ew ew ew usr, but it's the only way to check.
		return

	if( state != WASHSTATE_FULLCLOSEDDOOR )
		to_chat(usr, "The washing machine cannot run in this state.")
		return

	if( locate(/mob,contents) )
		state = WASHSTATE_BLOODRUNNING
	else
		state = WASHSTATE_RUNNING
	update_icon()
	tick = WASH_BASETIME
	for(var/atom/A in contents)
		tick += WASH_ADDTIME
	use_power = ACTIVE_POWER_USE
	update_icon()

/obj/machinery/washing_machine/verb/climb_out()
	set name = "Climb out"
	set category = "Object"
	set src in usr.loc

	sleep(20)
	if(state in list(WASHSTATE_EMPTYOPENDOOR,WASHSTATE_FULLOPENDOOR,WASHSTATE_BLOODOPENDOOR) )
		usr.loc = src.loc


/obj/machinery/washing_machine/on_update_icon()
	icon_state = "wm_[state][panel]"

/obj/machinery/washing_machine/affect_grab(var/mob/user, var/mob/target)
	if((state == WASHSTATE_EMPTYOPENDOOR) && hacked)
		if(ishuman(user) && iscorgi(target))
			target.forceMove(src)
			state = WASHSTATE_FULLOPENDOOR
			return TRUE

/obj/machinery/washing_machine/attackby(obj/item/W as obj, mob/user as mob)
	/*if(istype(W,/obj/item/tool/screwdriver))
		panel = !panel
		to_chat(user, "<span class='notice'>You [panel ? "open" : "close"] the [src]'s maintenance panel</span>")*/
	if(istype(W,/obj/item/pen/crayon))
		if( state in list(WASHSTATE_EMPTYOPENDOOR,WASHSTATE_FULLOPENDOOR,WASHSTATE_BLOODOPENDOOR) )
			if(!crayon)
				user.drop_item()
				crayon = W
				crayon.loc = src
			else
				..()
		else
			..()
	else if(is_type_in_list(W, allowed_types))
		if(contents.len < 10)
			if( state in list(WASHSTATE_EMPTYOPENDOOR, WASHSTATE_FULLOPENDOOR) )
				user.unEquip(W, src)
				state = WASHSTATE_FULLOPENDOOR
			else
				to_chat(user, SPAN_NOTICE("You can't put the item in right now."))
		else
			to_chat(user, SPAN_NOTICE("The washing machine is full."))
		update_icon()
		return
	update_icon()
	..()


/obj/machinery/washing_machine/attack_hand(mob/user as mob)
	switch(state)
		if(WASHSTATE_EMPTYOPENDOOR)
			state = WASHSTATE_EMPTYCLOSEDDOOR
		if(WASHSTATE_EMPTYCLOSEDDOOR)
			state = WASHSTATE_EMPTYOPENDOOR
			for(var/atom/movable/O in contents)
				O.loc = src.loc
		if(WASHSTATE_FULLOPENDOOR)
			state = WASHSTATE_FULLCLOSEDDOOR
		if(WASHSTATE_FULLCLOSEDDOOR)
			for(var/atom/movable/O in contents)
				O.loc = src.loc
			crayon = null
			state = WASHSTATE_EMPTYOPENDOOR
		if(WASHSTATE_RUNNING)
			to_chat(user, SPAN_WARNING("The [src] is busy."))
		if(WASHSTATE_BLOODOPENDOOR)
			state = WASHSTATE_BLOODCLOSEDDOOR
		if(WASHSTATE_BLOODCLOSEDDOOR)
			if(gibs_ready)
				gibs_ready = 0
				if(locate(/mob,contents))
					var/mob/M = locate(/mob,contents)
					M.gib()
			for(var/atom/movable/O in contents)
				O.loc = src.loc
			crayon = null
			state = WASHSTATE_EMPTYOPENDOOR


	update_icon()

#undef WASHSTATE_EMPTYOPENDOOR
#undef WASHSTATE_EMPTYCLOSEDDOOR
#undef WASHSTATE_FULLOPENDOOR
#undef WASHSTATE_FULLCLOSEDDOOR
#undef WASHSTATE_RUNNING
#undef WASHSTATE_BLOODOPENDOOR
#undef WASHSTATE_BLOODCLOSEDDOOR
#undef WASHSTATE_BLOODRUNNING

#undef WASH_BASETIME
#undef WASH_ADDTIME

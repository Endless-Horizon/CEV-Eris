/obj/item/handcuffs
	name = "handcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = WEAPON_FORCE_WEAK
	w_class = ITEM_SIZE_SMALL
	throw_speed = 2
	throw_range = 5
	origin_tech = list(TECH_MATERIAL = 1)
	matter = list(MATERIAL_STEEL = 2)
	var/elastic
	var/dispenser = 0
	var/breakouttime = 1200 //Deciseconds = 120s = 2 minutes
	var/cuff_sound = 'sound/weapons/handcuffs.ogg'
	var/cuff_type = "handcuffs"

/obj/item/handcuffs/attack(var/mob/living/carbon/C, var/mob/living/user)

	if(!user.IsAdvancedToolUser())
		return

	if ((CLUMSY in user.mutations) && prob(50))
		to_chat(user, SPAN_WARNING("Uh ... how do those things work?!"))
		place_handcuffs(user, user)
		return

	if(C.handcuffed)
		to_chat(user,SPAN_WARNING("\The [C] is already handcuffed."))
		return

	if (C == user) //cool shit bro
		place_handcuffs(user, user)
		return

	var/cuff_delay = 4 SECONDS
	for (var/obj/item/grab/G in C.grabbed_by)
		if (G.loc == user)
			if(G.state >= GRAB_PASSIVE)
				cuff_delay -= 1 SECONDS //3
			if(G.state >= GRAB_AGGRESSIVE)
				cuff_delay /= 2 //1.5
			if(G.state >= GRAB_NECK)
				cuff_delay /= 2 //0.75
			if(G.state >= GRAB_KILL)
				cuff_delay = 0
	if(C.handcuffed)
		to_chat(user,SPAN_WARNING("\The [C] is already handcuffed."))
		return
	place_handcuffs(C, user, cuff_delay)

/obj/item/handcuffs/proc/place_handcuffs(var/mob/living/carbon/target, var/mob/user, var/delay)
	playsound(src.loc, cuff_sound, 30, 1, -2)

	var/mob/living/carbon/human/H = target
	if(!istype(H))
		return 0

	if(!mob_can_equip(H, src, slot_handcuffed))
		to_chat(user, SPAN_DANGER("\The [H] needs at least two wrists before you can cuff them together!"))
		return 0

	if(istype(H.gloves,/obj/item/clothing/gloves/rig) && !elastic) // Can't cuff someone who's in a deployed hardsuit.
		to_chat(user, SPAN_DANGER("\The [src] won't fit around \the [H.gloves]!"))
		return 0

	//user.visible_message(SPAN_DANGER("\The [user] is attempting to put [cuff_type] on \the [H]!"))

	if(!do_after(user, delay, target))
		return 0

	H.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been handcuffed by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Handcuff [H.name] ([H.ckey])</font>")
	msg_admin_attack("[key_name(user)] handcuff [key_name(H)]")


	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	user.do_attack_animation(H)

	user.visible_message(SPAN_DANGER("\The [user] has put [cuff_type] on \the [H]!"))

	// Apply cuffs.
	var/obj/item/handcuffs/cuffs = src
	if(dispenser)
		cuffs = new(get_turf(user))
	else
		user.drop_from_inventory(cuffs)
	cuffs.forceMove(target)
	target.handcuffed = cuffs
	target.update_inv_handcuffed()
	return 1

var/last_chew = 0
/mob/living/carbon/human/RestrainedClickOn(var/atom/A)
	if (A != src) return ..()
	if (last_chew + 26 > world.time) return

	var/mob/living/carbon/human/H = A
	if (!H.handcuffed) return
	if (H.a_intent != I_HURT) return
	if (H.targeted_organ != BP_MOUTH) return
	if (H.wear_mask) return
	if (istype(H.wear_suit, /obj/item/clothing/suit/straight_jacket)) return

	var/obj/item/organ/external/O = H.organs_by_name[H.hand ? BP_L_ARM : BP_R_ARM]
	if (!O) return

	var/s = SPAN_WARNING("[H.name] chews on \his [O.name]!")
	H.visible_message(s, SPAN_WARNING("You chew on your [O.name]!"))
	H.attack_log += text("\[[time_stamp()]\] <font color='red'>[s] ([H.ckey])</font>")
	log_attack("[s] ([H.ckey])")

	if(O.take_damage(3,0,1,1,"teeth marks"))
		H:UpdateDamageIcon()

	last_chew = world.time

/obj/item/handcuffs/zipties
	name = "zip ties"
	desc = "Plastic, disposable zipties that can be used to restrain someone."
	icon_state = "cuff_white"
	matter = list(MATERIAL_PLASTIC = 2)
	breakouttime = 700 //Deciseconds = 70s, this is higher than usual ss13 because breakout time is subtracted by 1 second for every robustness stat
	cuff_sound = 'sound/weapons/cablecuff.ogg'
	cuff_type = "zip ties"
	elastic = 1

/obj/item/handcuffs/cable
	name = "cable restraints"
	desc = "Looks like some cables tied together. Could be used to tie something up."
	icon_state = "cuff_white"
	breakouttime = 300 //Deciseconds = 30s
	cuff_sound = 'sound/weapons/cablecuff.ogg'
	cuff_type = "cable restraints"
	elastic = 1

/obj/item/handcuffs/cable/red
	color = "#DD0000"

/obj/item/handcuffs/cable/yellow
	color = "#DDDD00"

/obj/item/handcuffs/cable/blue
	color = "#0000DD"

/obj/item/handcuffs/cable/green
	color = "#00DD00"

/obj/item/handcuffs/cable/pink
	color = "#DD00DD"

/obj/item/handcuffs/cable/orange
	color = "#DD8800"

/obj/item/handcuffs/cable/cyan
	color = "#00DDDD"

/obj/item/handcuffs/cable/white
	color = "#FFFFFF"

/obj/item/handcuffs/cable/attackby(var/obj/item/I, mob/user as mob)
	..()
	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if (R.use(1))
			var/obj/item/material/wirerod/W = new(get_turf(user))
			user.put_in_hands(W)
			to_chat(user, SPAN_NOTICE("You wrap the cable restraint around the top of the rod."))
			qdel(src)
			update_icon(user)

/obj/item/handcuffs/cyborg
	dispenser = 1
	spawn_tags = null

/obj/item/handcuffs/cyborg/afterattack(atom/A, mob/user, proximity)
	if (istype(A,/obj/item/handcuffs))
		qdel(A)

/obj/item/handcuffs/cable/tape
	name = "tape restraints"
	desc = "DIY!"
	icon_state = "tape_cross"
	item_state = null
	icon = 'icons/obj/bureaucracy.dmi'
	breakouttime = 200
	cuff_type = "duct tape"

/obj/item/handcuffs/fake
	name = "handcuffs"
	desc = "Fake handcuffs meant for gag purposes."
	breakouttime = 10 //

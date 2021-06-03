/atom
	var/can_buckle = FALSE
	var/buckle_movable = 0
	var/buckle_dir = 0
	var/buckle_lying = -1 //bed-like behavior, forces mob.lying = buckle_lying if != -1
	var/buckle_pixel_shift = "x=0;y=0" //where the buckled mob should be pixel shifted to, or null for no pixel shift control
	var/buckle_require_restraints = 0 //require people to be handcuffed before being able to buckle. eg: pipes
	var/mob/living/buckled_mob = null

/atom/attack_hand(mob/living/user)
	. = ..()
	if(can_buckle && buckled_mob)
		user_unbuckle_mob(user)

/atom/MouseDrop_T(mob/living/M, mob/living/user)
	. = ..()
	if(can_buckle && istype(M))
		user_buckle_mob(M, user)

/atom/Destroy()
	unbuckle_mob()
	return ..()


/atom/proc/buckle_mob(mob/living/M)
	if(buckled_mob) //unless buckled_mob becomes a list this can cause problems
		return 0
	if(!istype(M) || (M.loc != loc) || M.buckled || M.pinned.len || (buckle_require_restraints && !M.restrained()))
		return 0


	M.buckled = src
	M.facing_dir = null
	M.set_dir(buckle_dir ? buckle_dir : dir)
	M.update_lying_buckled_and_verb_status()
	M.update_floating()
	buckled_mob = M

	post_buckle_mob(M)
	return 1

/**
 * Set a mob as unbuckled from src
 *
 * The mob must actually be buckled to src or else bad things will happen.
 * Arguments:
 * buckled_mob - The mob to be unbuckled
 * force - TRUE if we should ignore buckled_mob.can_buckle_to
 * (args are a lie, adding those soon:tm: also move to AM)
 */
/atom/proc/unbuckle_mob()
	if(buckled_mob && buckled_mob.buckled == src)
		. = buckled_mob
		buckled_mob.buckled = null
		buckled_mob.anchored = initial(buckled_mob.anchored)
		buckled_mob.update_lying_buckled_and_verb_status()
		buckled_mob.update_floating()
		buckled_mob = null

		post_buckle_mob(.)

/atom/proc/post_buckle_mob(mob/living/M)
	if(buckle_pixel_shift)
		if(M == buckled_mob)
			var/list/pixel_shift = cached_key_number_decode(buckle_pixel_shift)
			animate(M, pixel_x = M.default_pixel_x + pixel_shift["x"], pixel_y = M.default_pixel_y + pixel_shift["y"], 4, 1, LINEAR_EASING)
		else
			animate(M, pixel_x = M.default_pixel_x, pixel_y = M.default_pixel_y, 4, 1, LINEAR_EASING)

/atom/proc/user_buckle_mob(mob/living/M, mob/user)
	if(!user.Adjacent(M) || user.restrained() || user.stat || istype(user, /mob/living/silicon/pai))
		return 0
	if(M == buckled_mob)
		return 0
	if(isslime(M))
		to_chat(user, SPAN_WARNING("\The [M] is too squishy to buckle in."))
		return 0
	if(user.mob_size < M.mob_size)
		to_chat(user, SPAN_WARNING("\The [M] is too heavy to buckle in."))
		return 0

	add_fingerprint(user)
	unbuckle_mob()

	//can't buckle unless you share locs so try to move M to the atom.
	if(M.loc != src.loc)
		step_towards(M, src)

	. = buckle_mob(M)
	if(.)
		if(M == user)
			M.visible_message(\
				SPAN_NOTICE("\The [M.name] buckles themselves to \the [src]."),\
				SPAN_NOTICE("You buckle yourself to \the [src]."),\
				SPAN_NOTICE("You hear metal clanking."))
		else
			M.visible_message(\
				SPAN_DANGER("\The [M.name] is buckled to \the [src] by \the [user.name]!"),\
				SPAN_DANGER("You are buckled to \the [src] by \the [user.name]!"),\
				SPAN_NOTICE("You hear metal clanking."))

/atom/proc/user_unbuckle_mob(mob/user)
	var/mob/living/M = unbuckle_mob()
	if(M)
		if(M != user)
			M.visible_message(\
				SPAN_NOTICE("\The [M.name] was unbuckled by \the [user.name]!"),\
				SPAN_NOTICE("You were unbuckled from \the [src] by \the [user.name]."),\
				SPAN_NOTICE("You hear metal clanking."))
		else
			M.visible_message(\
				SPAN_NOTICE("\The [M.name] unbuckled themselves!"),\
				SPAN_NOTICE("You unbuckle yourself from \the [src]."),\
				SPAN_NOTICE("You hear metal clanking."))
		add_fingerprint(user)
	return M


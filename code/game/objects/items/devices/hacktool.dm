/obj/item/weapon/tool/multitool/hacktool
	spawn_blacklisted = TRUE//traitor item
	var/is_hacking = 0
	var/max_known_targets

	var/in_hack_mode = 0
	var/list/known_targets
	var/list/supported_types
	var/datum/topic_state/default/must_hack/hack_state

/obj/item/weapon/tool/multitool/hacktool/New()
	..()
	known_targets = list()
	max_known_targets = 5 + rand(1,3)
	supported_types = list(/obj/machinery/door/airlock)
	hack_state = new(src)

/obj/item/weapon/tool/multitool/hacktool/Destroy()
	for(var/T in known_targets)
		var/atom/target = T
		GLOB.destroyed_event.unregister(target, src)
	known_targets.Cut()
	qdel(hack_state)
	hack_state = null
	return ..()

/obj/item/weapon/tool/multitool/hacktool/attackby(obj/item/I, mob/user)
	if(QUALITY_SCREW_DRIVING in I.tool_qualities)
		if(I.use_tool(user, src, WORKTIME_FAST, QUALITY_SCREW_DRIVING, FAILCHANCE_EASY, required_stat = STAT_COG))
			in_hack_mode = !in_hack_mode
			to_chat(user, SPAN_NOTICE("You [in_hack_mode? "enable" : "disable"] the hack mode."))
	else
		..()

/obj/item/weapon/tool/multitool/hacktool/resolve_attackby(atom/A, mob/user)
	sanity_check()

	if(!in_hack_mode)
		return ..()

	if(!attempt_hack(user, A))
		return 0

	A.nano_ui_interact(user, state = hack_state)
	return 1

/obj/item/weapon/tool/multitool/hacktool/proc/attempt_hack(var/mob/user, var/atom/target)
	if(is_hacking)
		to_chat(user, SPAN_WARNING("You are already hacking!"))
		return 0
	if(!is_type_in_list(target, supported_types))
		to_chat(user, "\icon[src] <span class='warning'>Unable to hack this target!</span>")
		return 0
	var/found = known_targets.Find(target)
	if(found)
		known_targets.Swap(1, found)	// Move the last hacked item first
		return 1

	to_chat(user, SPAN_NOTICE("You begin hacking \the [target]..."))
	is_hacking = 1
	// without any cog, hacking takes 30 seconds. every point of cog lowers the time needed to hack by 0,5 seconds, up to a maximum reduction of 20 seconds.
	var/hack_result = do_after(user, min(60 SECONDS, 30 SECONDS - min(20 SECONDS, user.stats.getStat(STAT_COG) / 2 SECONDS)) , progress = 0)
	is_hacking = 0

	if(hack_result && in_hack_mode)
		to_chat(user, SPAN_NOTICE("Your hacking attempt was succesful!"))
		playsound(src.loc, 'sound/piano/A#6.ogg', 75)
	else
		to_chat(user, SPAN_WARNING("Your hacking attempt failed!"))
		return 0

	known_targets.Insert(1, target)	// Insert the newly hacked target first,
	GLOB.destroyed_event.register(target, src, /obj/item/weapon/tool/multitool/hacktool/proc/on_target_destroy)
	return 1

/obj/item/weapon/tool/multitool/hacktool/proc/sanity_check()
	if(max_known_targets < 1) max_known_targets = 1
	// Cut away the oldest items if the capacity has been reached
	if(known_targets.len > max_known_targets)
		for(var/i = (max_known_targets + 1) to known_targets.len)
			var/atom/A = known_targets[i]
			GLOB.destroyed_event.unregister(A, src)
		known_targets.Cut(max_known_targets + 1)

/obj/item/weapon/tool/multitool/hacktool/proc/on_target_destroy(var/target)
	known_targets -= target

/datum/topic_state/default/must_hack
	var/obj/item/weapon/tool/multitool/hacktool/hacktool

/datum/topic_state/default/must_hack/New(var/hacktool)
	src.hacktool = hacktool
	..()

/datum/topic_state/default/must_hack/Destroy()
	hacktool = null
	return ..()

/datum/topic_state/default/must_hack/can_use_topic(var/src_object, var/mob/user)
	if(!hacktool || !hacktool.in_hack_mode || !(src_object in hacktool.known_targets))
		return STATUS_CLOSE
	return ..()

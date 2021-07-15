/obj/item/assembly
	bad_type = /obj/item/assembly

/obj/item/assembly/shock_kit
	name = "electrohelmet assembly"
	desc = "This appears to be made from both an electropack and a helmet."
	icon_state = "shock_kit"
	w_class = ITEM_SIZE_HUGE
	flags = CONDUCT
	var/obj/item/clothing/head/armor/helmet/part1
	var/obj/item/device/radio/electropack/part2
	var/status = 0

/obj/item/assembly/shock_kit/Destroy()
	qdel(part1)
	qdel(part2)
	. = ..()

/obj/item/assembly/shock_kit/attackby(obj/item/tool/tool, mob/user)
	var/list/usable_qualities = list(QUALITY_BOLT_TURNING, QUALITY_SCREW_DRIVING)
	var/tool_type = tool.get_tool_type(user, usable_qualities, src)
	switch(tool_type)
		if(QUALITY_SCREW_DRIVING)
			if(tool.use_tool(user, src, WORKTIME_NORMAL, QUALITY_SCREW_DRIVING, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
				status = !status
				to_chat(user, SPAN_NOTICE("[src] is now [status ? "secured" : "unsecured"]!"))
		if(QUALITY_BOLT_TURNING)
			if(!status)
				if(tool.use_tool(user, src, WORKTIME_NORMAL, QUALITY_BOLT_TURNING, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					var/turf/T = loc
					if(ismob(T))
						T = T.loc
					part1.loc = T
					part2.loc = T
					part1.master = null
					part2.master = null
					part1 = null
					part2 = null
					qdel(src)
	add_fingerprint(user)

/obj/item/assembly/shock_kit/attack_self(mob/user as mob)
	part1.attack_self(user, status)
	part2.attack_self(user, status)
	add_fingerprint(user)

/obj/item/assembly/shock_kit/receive_signal()
	if(istype(loc, /obj/structure/bed/chair/e_chair))
		var/obj/structure/bed/chair/e_chair/C = loc
		C.shock()

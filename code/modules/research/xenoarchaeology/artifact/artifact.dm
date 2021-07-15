
///////////////////////////////////////////////////////////////////////////
// Large finds - (Potentially) active alien machinery from the dawn of time

/datum/artifact_find
	var/artifact_id
	var/artifact_find_type
	var/artifact_detect_range

/datum/artifact_find/New()
	artifact_detect_range = rand(5,300)

	artifact_id = "[pick("kappa","sigma","antaeres","beta","omicron","iota","epsilon","omega","gamma","delta","tau","alpha")]-[rand(100,999)]"

	artifact_find_type = pick(\
		5;/obj/machinery/power/supermatter,
//		5;/obj/machinery/syndicate_beacon,
		25;/obj/machinery/power/supermatter/shard,
		100;/obj/machinery/auto_cloner,
		100;/obj/machinery/giga_drill,
		100;/obj/machinery/replicator,
		150;/obj/structure/crystal,
		1000;/obj/machinery/artifact\
	)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Boulders - sometimes turn up after excavating turf - excavate further to try and find large xenoarch finds

/obj/structure/boulder
	name = "rocky debris"
	desc = "Leftover rock from an excavation, it's been partially dug out already but there's still a lot to go."
	icon = 'icons/obj/mining.dmi'
	icon_state = "boulder1"
	density = TRUE
	opacity = 1
	anchored = TRUE
	var/excavation_level = 0
	var/datum/geosample/geological_data
	var/datum/artifact_find/artifact_find
	var/last_act = 0

/obj/structure/boulder/Initialize()
	. = ..()
	icon_state = "boulder[rand(1,4)]"
	excavation_level = rand(5,50)

/obj/structure/boulder/attackby(obj/item/I, mob/user )

	var/tool_type = I.get_tool_type(user, list(QUALITY_DIGGING, QUALITY_EXCAVATION), src)
	switch(tool_type)

		if(QUALITY_EXCAVATION)
			var/excavation_amount = input("How deep are you going to dig?", "Excavation depth", 0) as num
			if(excavation_amount)
				to_chat(user, SPAN_NOTICE("You start exacavating [src]."))
				if(I.use_tool(user, src, WORKTIME_SLOW, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_COG))
					to_chat(user, SPAN_NOTICE("You finish exacavating [src]."))
					excavation_level += excavation_amount

					if(excavation_level > 100)
						//failure
						user.visible_message(SPAN_DANGER("[src] suddenly crumbles away."),\
						SPAN_WARNING("[src] has disintegrated under your onslaught, any secrets it was holding are long gone."))
						qdel(src)
						return

					if(prob(excavation_level))
						//success
						if(artifact_find)
							var/spawn_type = artifact_find.artifact_find_type
							var/obj/O = new spawn_type(get_turf(src))
							if(istype(O,/obj/machinery/artifact))
								var/obj/machinery/artifact/X = O
								if(X.my_effect)
									X.my_effect.artifact_id = artifact_find.artifact_id
							src.visible_message("<font color='red'><b>[src] suddenly crumbles away.</b></font>")
						else
							user.visible_message("<font color='red'><b>[src] suddenly crumbles away.</b></font>",\
							"\blue [src] has been whittled away under your careful excavation, but there was nothing of interest inside.")
						qdel(src)
					return
			return

		if(QUALITY_DIGGING)
			if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_ZERO, required_stat = STAT_ROB))
				user.visible_message(SPAN_DANGER("[src] suddenly crumbles away."),\
				SPAN_WARNING("[src] has disintegrated under your onslaught, any secrets it was holding are long gone."))
				qdel(src)
				return
			return

		if(ABORT_CHECK)
			return

	if (istype(I, /obj/item/device/core_sampler))
		src.geological_data.artifact_distance = rand(-100,100) / 100
		src.geological_data.artifact_id = artifact_find.artifact_id

		var/obj/item/device/core_sampler/C = I
		C.sample_item(src, user)
		return

	if (istype(I, /obj/item/device/depth_scanner))
		var/obj/item/device/depth_scanner/C = I
		C.scan_atom(user, src)
		return

	if (istype(I, /obj/item/device/measuring_tape))
		var/obj/item/device/measuring_tape/P = I
		user.visible_message("<span class='notice'>[user] extends [P] towards [src].","\blue You extend [P] towards [src].</span>")
		if(do_after(user,40,src))
			to_chat(user, SPAN_NOTICE("[src] has been excavated to a depth of [2*src.excavation_level]cm."))
		return

/obj/structure/boulder/Bumped(AM)
	. = ..()
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(!H.hand && H.l_hand && (QUALITY_DIGGING in H.l_hand.tool_qualities))
			attackby(H.l_hand,H)
		else if(H.hand && H.r_hand && (QUALITY_DIGGING in H.r_hand.tool_qualities))
			attackby(H.r_hand,H)

	else if(isrobot(AM))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active,/obj/item))
			var/obj/item/I = R.module_active
			if(QUALITY_DIGGING in I.tool_qualities)
				attackby(I,R)

	else if(istype(AM,/mob/living/exosuit))
		var/mob/living/exosuit/M = AM
		if(istype(M.selected_system, /obj/item/mech_equipment/drill))
			var/obj/item/mech_equipment/drill/D = M.selected_system
			D.afterattack(src)

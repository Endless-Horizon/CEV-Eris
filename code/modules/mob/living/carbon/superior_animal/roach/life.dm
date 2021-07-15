#define MOVING_TO_TARGET 1
#define EATING_TARGET 2
#define LAYING_EGG 3

/mob/living/carbon/superior_animal/roach/proc/GiveUp(var/C)
	spawn(100)
		if(busy == MOVING_TO_TARGET)
			if(eat_target == C && get_dist(src,eat_target) > 1)
				eat_target = null
				busy = 0
				stop_automated_movement = 0

/mob/living/carbon/superior_animal/roach/Life()
	. = ..()
	if(check_AI_act()) // if the roach is able to act
		if(stance == HOSTILE_STANCE_IDLE)
			switch(busy)
				if(0)
					if(prob(5))	// 5 percents chance that the roach is hungry
						//first, check for potential food nearby
						var/list/eatTargets = new
						for(var/mob/living/carbon/C in getPotentialTargets())
							if ((C.stat == DEAD) && ((istype(C, /mob/living/carbon/human)) || (istype(C, /mob/living/carbon/superior_animal))))
								eatTargets += C

						eat_target = safepick(nearestObjectsInList(eatTargets,src,1))
						if (eat_target)
							busy = MOVING_TO_TARGET
							set_glide_size(DELAY2GLIDESIZE(move_to_delay))
							walk_to(src, eat_target, 1, move_to_delay)
							GiveUp(eat_target) //give up if we can't reach target
							return
					else if(prob(probability_egg_laying)) // chance to lay an egg
						var/obj/effect/spider/eggcluster/tastyobstacle = locate(/obj/effect/spider/eggcluster) in get_turf(src)
						if(tastyobstacle)
							visible_message(SPAN_WARNING("[src] eats [tastyobstacle]."),"", SPAN_NOTICE("You hear something eating something."))
							tastyobstacle.Destroy()
							fed += rand(3, 12) // this would otherwise pop out this many big spiders
						else if(fed <= 0)
							return
						busy = LAYING_EGG
						src.visible_message(SPAN_NOTICE("\The [src] begins to lay an egg."))
						stop_automated_movement = 1
						busy_start_time = world.timeofday
				if(MOVING_TO_TARGET)
					if (eat_target)
						if(get_dist(src, eat_target) <= 1)
							busy = EATING_TARGET
							stop_automated_movement = 1
							src.visible_message(SPAN_NOTICE("\The [src] begins to eat \the [eat_target]."))
							walk(src,0)
							busy_start_time = world.timeofday
							if (istype(eat_target, /mob/living/carbon/superior_animal))
								busy_time = 30 SECONDS
							else if (ishuman(eat_target))
								busy_time = 5 MINUTES
								// how much time it takes to it a corpse
		    					// Set to 5 minutes to let the crew enough time to get the corpse
								// Several roaches eating at the same time do not speed up the process
								// If disturbed the roach has to start back from 0

				if(EATING_TARGET)
					if (world.timeofday >= busy_start_time + busy_time)
						if(eat_target && istype(eat_target.loc, /turf) && get_dist(src,eat_target) <= 1)
							var/turf/targetTurf = eat_target.loc
							var/mob/living/carbon/M = eat_target
							if((M.stat == DEAD)) // Don't try to eat something that is alive
								if ((istype(M, /mob/living/carbon/human)) && (M.icon)) // Eating a human
									// Icon check is to check if another roach has already finished eating this human
									var/mob/living/carbon/human/H = M
									// Process Cruciform
									var/obj/item/implant/core_implant/cruciform/CI = H.get_core_implant(/obj/item/implant/core_implant/cruciform, FALSE)
									if (CI)
										var/mob/N = CI.wearer
										CI.name = "[N]'s Cruciform"
										CI.uninstall()
									// Gib victim but remove non synthetic organs
									H.gib(max_range=1, keep_only_robotics=TRUE)
									// Spawn human remains
									var/remainsType = /obj/item/remains/human
									new remainsType(targetTurf)
									// End message
									src.visible_message(SPAN_WARNING("\The [src] finishes eating \the [eat_target], leaving only bones."))
									// Get fed
									fed += rand(4,6)
								else if (istype(M, /mob/living/carbon/superior_animal) && (M.icon)) // Eating a spider or roach
									// Gib victim
									var/mob/living/carbon/superior_animal/tasty = M
									M.gib(null, FALSE)
									gibs(targetTurf, null, /obj/effect/gibspawner/generic, fleshcolor, bloodcolor)
									// End message
									src.visible_message(SPAN_WARNING("\The [src] finishes eating \the [eat_target], leaving only bones."))
									// Get fed
									fed += rand(1,tasty.meat_amount)
									if (isroach(tasty))
										var/mob/living/carbon/superior_animal/roach/cannibalism = tasty
										fed += cannibalism.fed
									if(istype(src, /mob/living/carbon/superior_animal/roach/roachling))
										if(tasty.meat_amount >= 6)// ate a fuhrer or kaiser
											var/mob/living/carbon/superior_animal/roach/roachling/bigboss = src
											bigboss.big_boss = TRUE
							eat_target = null
						busy = 0
						stop_automated_movement = 0

				if(LAYING_EGG)
					if (world.timeofday >= busy_start_time + busy_time)				
						if (istype(src, /mob/living/carbon/superior_animal/roach/kaiser))// kaiser roaches now lay roachcubes
							var/roachcube = pick(subtypesof(/obj/item/reagent_containers/food/snacks/roachcube))
							new roachcube(get_turf(src))
						else
							new /obj/item/roach_egg(loc, src)
						fed--
						update_openspace()
						busy = 0
						stop_automated_movement = 0
		else
			busy = 0
			stop_automated_movement = 0

#undef MOVING_TO_TARGET
#undef EATING_TARGET
#undef LAYING_EGG

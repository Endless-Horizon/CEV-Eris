#define SPINNING_WEB 1
#define LAYING_EGGS 2
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4

//nursemaids - these create webs and eggs
/mob/living/carbon/superior_animal/giant_spider/nurse
	name = "Kouchiku Spider"
	desc = "A massive tangleweb spider. It's abdomen takes up the majority of the creature's mass. For a giant arachnid, this one seems especially fragile."
	icon_state = "nurse"
	icon_living = "nurse"
	maxHealth = 40
	health = 40
	melee_damage_lower = 5
	melee_damage_upper = 10
	poison_per_bite = 2
	var/atom/cocoon_target
	poison_type = "pararein"
	meat_type = /obj/item/reagent_containers/food/snacks/meat/spider/nurse
	meat_amount = 3
	rarity_value = 75
	var/fed = 0

/mob/living/carbon/superior_animal/giant_spider/nurse/attemptAttackOnTarget()
	var/target = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(prob(poison_per_bite))
			var/obj/item/organ/external/O = safepick(H.organs)
			if(O && !BP_IS_ROBOTIC(O))
				var/eggs = new /obj/effect/spider/eggcluster(O, src)
				O.implants += eggs

/mob/living/carbon/superior_animal/giant_spider/nurse/proc/GiveUp(var/C)
	spawn(100)
		if(busy == MOVING_TO_TARGET)
			if(cocoon_target == C && get_dist(src,cocoon_target) > 1)
				cocoon_target = null
				busy = 0
				stop_automated_movement = 0

/mob/living/carbon/superior_animal/giant_spider/nurse/Life()
	..()
	if(!stat && !AI_inactive)
		if(stance == HOSTILE_STANCE_IDLE)
			//30% chance to stop wandering and do something
			if(!busy && prob(30))
				//first, check for potential food nearby to cocoon
				var/list/cocoonTargets = new
				for(var/mob/living/C in getPotentialTargets())
					if(C.stat != CONSCIOUS)
						cocoonTargets += C

				cocoon_target = safepick(nearestObjectsInList(cocoonTargets,src,1))
				if (cocoon_target)
					busy = MOVING_TO_TARGET
					set_glide_size(DELAY2GLIDESIZE(move_to_delay))
					walk_to(src, cocoon_target, 1, move_to_delay)
					GiveUp(cocoon_target) //give up if we can't reach target
					return

				//second, spin a sticky spiderweb on this tile
				if(!(locate(/obj/effect/spider/stickyweb) in get_turf(src)))
					busy = SPINNING_WEB
					src.visible_message(SPAN_NOTICE("\The [src] begins to secrete a sticky substance."))
					stop_automated_movement = 1
					spawn(40)
						if(busy == SPINNING_WEB)
							if(!(locate(/obj/effect/spider/stickyweb) in get_turf(src)))
								new /obj/effect/spider/stickyweb(src.loc)
								update_openspace()
							busy = 0
							stop_automated_movement = 0
				else
					//third, lay an egg cluster there
					if((fed > 0) && !(locate(/obj/effect/spider/eggcluster) in get_turf(src)))
						busy = LAYING_EGGS
						src.visible_message(SPAN_NOTICE("\The [src] begins to lay a cluster of eggs."))
						stop_automated_movement = 1
						spawn(50)
							if(busy == LAYING_EGGS)
								if(!(locate(/obj/effect/spider/eggcluster) in get_turf(src)))
									new /obj/effect/spider/eggcluster(loc, src)
									fed--
									update_openspace()
								busy = 0
								stop_automated_movement = 0
					else
						//fourthly, cocoon any nearby items so those pesky pinkskins can't use them
						var/list/nearestObjects = nearestObjectsInList(getObjectsInView(),src,1)
						for(var/obj/O in nearestObjects)
							if(O.anchored)
								continue
							if(istype(O, /obj/item) || istype(O, /obj/structure) || istype(O, /obj/machinery))
								cocoonTargets += O

						cocoon_target = safepick(cocoonTargets)
						if (cocoon_target)
							busy = MOVING_TO_TARGET
							stop_automated_movement = 1
							set_glide_size(DELAY2GLIDESIZE(move_to_delay))
							walk_to(src, cocoon_target, 1, move_to_delay)
							GiveUp(cocoon_target) //give up if we can't reach target

			else if(busy == MOVING_TO_TARGET && cocoon_target)
				if(get_dist(src, cocoon_target) <= 1)
					busy = SPINNING_COCOON
					src.visible_message(SPAN_NOTICE("\The [src] begins to secrete a sticky substance around \the [cocoon_target]."))
					stop_automated_movement = 1
					walk(src,0)
					spawn(50)
						if(busy == SPINNING_COCOON)
							if(cocoon_target && istype(cocoon_target.loc, /turf) && get_dist(src,cocoon_target) <= 1)
								var/obj/effect/spider/cocoon/C = locate() in cocoon_target.loc
								var/large_cocoon
								var/turf/targetTurf = cocoon_target.loc

								for(var/obj/O in targetTurf)
									if (O.anchored)
										continue
									if (istype(O, /obj/item))
									else if (istype(O, /obj/structure) || istype(O, /obj/machinery))
										large_cocoon = 1
									else
										continue

									C = C || new(targetTurf)
									O.forceMove(C)

								for(var/mob/living/M in targetTurf)
									if((M.stat == CONSCIOUS) || istype(M, /mob/living/carbon/superior_animal/giant_spider) || is_carrion(M))
										continue
									large_cocoon = 1

									if (istype(M, /mob/living/carbon/human))
										var/mob/living/carbon/human/H = M
										if (H.get_blood_volume() >= 1)
											src.visible_message(SPAN_WARNING("\The [src] sticks a proboscis into \the [cocoon_target] and sucks a viscous substance out."))
											H.drip_blood(H.species.blood_volume)
											fed++

									C = C || new(targetTurf)
									M.forceMove(C)
									break

								if (C)
									if(large_cocoon || C.is_large_cocoon)
										C.becomeLarge()
									C.update_openspace()

								cocoon_target = null

							busy = 0
							stop_automated_movement = 0

		else
			busy = 0
			stop_automated_movement = 0

#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON

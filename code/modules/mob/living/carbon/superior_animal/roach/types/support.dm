/mob/living/carbon/superior_animal/roach/support
	name = "Seuche Roach"
	desc = "A monstrous, dog-sized cockroach. This one smells like hell and secretes strange vapors."
	icon_state = "seuche"
	turns_per_move = 6
	maxHealth = 20
	health = 20
	melee_damage_upper = 3
	meat_type = /obj/item/reagent_containers/food/snacks/meat/roachmeat/seuche
	meat_amount = 3
	rarity_value = 11.25
	var/datum/reagents/gas_sac //Stores gas. Can't use the default reagents since that is now bloodstream

/mob/living/carbon/superior_animal/roach/support/New()
	.=..()
	gas_sac = new /datum/reagents(100, src)

/mob/living/carbon/superior_animal/roach/support/proc/gas_attack()
	if (!gas_sac.has_reagent("blattedin", 20) || stat != CONSCIOUS)
		return

	var/location = get_turf(src)
	var/datum/effect/effect/system/smoke_spread/chem/S = new

	S.attach(location)
	S.set_up(gas_sac, gas_sac.total_volume, 0, location)
	src.visible_message(SPAN_DANGER("\the [src] secretes strange vapors!"))

	spawn(0)
		S.start()

	gas_sac.clear_reagents()
	return TRUE

/mob/living/carbon/superior_animal/roach/support/Life()
	. = ..()
	if(stat != CONSCIOUS)
		return

	if(stat != AI_inactive)
		return

	gas_sac.add_reagent("blattedin", 1)

	if(!target_mob)
		return

	if(prob(7))
		gas_attack()

/mob/living/carbon/superior_animal/roach/support/findTarget()
	. = ..()
	if(. && gas_attack())
		visible_emote("charges at [.] in clouds of poison!")

/mob/living/carbon/superior_animal/roach/UnarmedAttack(var/atom/A, var/proximity)
	if(isliving(A))
		var/mob/living/L = A
		var/mob/living/carbon/human/H
		if(ishuman(L))
			H = L
		if(H)
			var/obj/item/reagent_containers/food/snacks/grown/howdoitameahorseinminecraft = H.get_active_hand()
			if(istype(howdoitameahorseinminecraft))
				if(try_tame(H, howdoitameahorseinminecraft))
					return FALSE //If they manage to tame the roach, stop the attack
		if(istype(L) && !L.weakened && prob(5))
			if(H && H.has_shield())
				L.visible_message(SPAN_DANGER("\the [src] tried to knocks down \the [L]! But [L] blocks \the [src] attack!"))
			else
				L.Weaken(3)
				L.visible_message(SPAN_DANGER("\the [src] knocks down \the [L]!"))

	. = ..()



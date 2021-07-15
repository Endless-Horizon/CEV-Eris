/datum/perk/oddity
	gain_text = "You feel different. Exposure to oddities has changed you. Now you can't go back."

/datum/perk/oddity/fast_walker
	name = "Fast Walker"
	desc = "Slow and steady wins the race. Prove them wrong. \
			You move slightly faster."
	icon_state = "fast" // https://game-icons.net/1x1/delapouite/fast-forward-button.html

/datum/perk/oddity/ear_of_quicksilver
	name = "Ear of Silver"
	desc = "Secrets do not escape your ears. Beware, loud noises are especially dangerous to you. \
			You have further listening range, but flashbangs stun you for double the time."
	icon_state = "ear" // https://game-icons.net

/datum/perk/oddity/gunslinger
	name = "Gunslinger"
	desc = "Point, shoot, aim, shoot again. You are the fastest gun in space! \
			You fire 33% faster with a one handed gun."
	icon_state = "dual_shot" // https://game-icons.net/1x1/delapouite/bullet-impacts.html

/datum/perk/oddity/terrible_fate
	name = "Terrible Fate"
	desc = "You realize the painful truth of death. You don't want to die and despise death - dying is a unmistakable horror to you. \
			Anyone who is around you at the moment of your death must roll a Vigilance sanity check. If they fail, their sanity will instantly be dropped to 0."
	icon_state = "murder" // https://game-icons.net/1x1/delapouite/chalk-outline-murder.html

/datum/perk/oddity/unfinished_delivery
	name = "Unfinished Delivery"
	desc = "Even though destination is your death, you have not reached it yet. \
			You have a 33% to get revived after death."
	icon_state = "regrowth" // https://game-icons.net/1x1/delapouite/stump-regrowth.html

/datum/perk/oddity/lungs_of_iron
	name = "Lungs of Iron"
	desc = "Your lungs have improved volume. You could easily win a diving contest. \
			You take only half breathing damage."
	icon_state = "lungs" // https://game-icons.net/1x1/lorc/one-eyed.html

/datum/perk/oddity/blood_of_lead
	name = "Blood of Lead"
	desc = "Rotten food, disgusting garbage, poisons - all is less harmful to you now. \
			You only take half toxin damage."
	icon_state = "liver" // https://game-icons.net

/datum/perk/oddity/space_asshole
	name = "Space Asshole"
	desc = "Holes, gravity, falling, tumbling. It's all the same. \
			You take less damage from falling."
	icon_state = "bomb" // https://game-icons.net

/datum/perk/oddity/space_asshole/assign(mob/living/carbon/human/H)
	..()
	if(holder)
		holder.mob_bomb_defense += 25
		holder.falls_mod -= 0.4

/datum/perk/oddity/space_asshole/remove()
	if(holder)
		holder.mob_bomb_defense -= 25
		holder.falls_mod += 0.4
	..()

/datum/perk/oddity/parkour
	name = "Parkour"
	desc = "You can climb tables and ladders faster."
	icon_state = "parkour" //https://game-icons.net/1x1/delapouite/jump-across.html

/datum/perk/oddity/parkour/assign(mob/living/carbon/human/H)
	..()
	if(holder)
		holder.mod_climb_delay -= 0.5

/datum/perk/oddity/parkour/remove()
	if(holder)
		holder.mod_climb_delay += 0.5
	..()

/datum/perk/oddity/charming_personality
	name = "Charming Personality"
	desc = "A little wink and a confident smile goes far in this place. People are more comfortable with your company. \
			They will recover sanity around you."
	icon_state = "flowers" // https://game-icons.net/1x1/lorc/flowers.html

/datum/perk/oddity/charming_personality/assign(mob/living/carbon/human/H)
	..()
	if(holder)
		holder.sanity_damage -= 2

/datum/perk/oddity/charming_personality/remove()
	if(holder)
		holder.sanity_damage += 2
	..()

/datum/perk/oddity/horrible_deeds
	name = "Horrible Deeds"
	desc = "The itch. The blood. They see the truth in your actions and are horrified. \
			People around you lose sanity."
	icon_state = "bad_breath" // https://game-icons.net

/datum/perk/oddity/horrible_deeds/assign(mob/living/carbon/human/H)
	..()
	if(holder)
		holder.sanity_damage += 2

/datum/perk/oddity/horrible_deeds/remove()
	if(holder)
		holder.sanity_damage -= 2
	..()

/datum/perk/oddity/chaingun_smoker
	name = "Chaingun Smoker"
	desc = "The cigarette is your way of life. It makes you feel less sick and tougher when you chomp down on cigars. \
			You heal a slight amount by smoking and recover sanity more quickly."
	icon_state = "cigarette" // https://game-icons.net

/datum/perk/oddity/nightcrawler
	name = "Nightcrawler"
	desc = "You are faster in the darkness."
	icon_state = "night" // https://game-icons.net/1x1/lorc/night-sky.html

/datum/perk/oddity/fast_fingers
	name = "Fast Fingers"
	desc = "Nothing is safe around your hands. You are a true kleptomaniac. \
			Taking items off others is without sound and prompts, it's also quicker, and you can slip pills into drinks unnoticed."
	icon_state = "robber_hand" // https://game-icons.net/1x1/darkzaitzev/robber-hand.html

/datum/perk/oddity/quiet_as_mouse
	name = "Quiet as a Mouse"
	desc = "Being deadly, easy. Silent? Even easier now. \
			You are 50% more quiet."
	icon_state = "footsteps" // https://game-icons.net

/datum/perk/oddity/quiet_as_mouse/assign(mob/living/carbon/human/H)
	..()
	if(holder)
		holder.noise_coeff -= 0.5

/datum/perk/oddity/quiet_as_mouse/remove()
	if(holder)
		holder.noise_coeff += 0.5
	..()

/datum/perk/oddity/balls_of_plasteel
	name = "Balls of Plasteel"
	desc = "Pain comes and goes. You have gotten used to it. \
			Your paincrit tolerance is higher."
	icon_state = "golem" // https://game-icons.net

/datum/perk/oddity/junkborn
	name = "Junkborn"
	desc = "One man's trash is a another man's comeup. \
			You have a higher chance of finding a rare item in trash piles."
	icon_state = "treasure" // https://game-icons.net

/datum/perk/oddity/ass_of_concrete
	name = "Ass of Concrete"
	desc = "Years of training your body made you a hulk of a person. No more pushing around. \
			Nobody can move past you, even on help intent. You wont slip in gravity."
	icon_state = "muscular" // https://game-icons.net

/datum/perk/oddity/ass_of_concrete/assign(mob/living/carbon/human/H)
	..()
	if(holder)
		holder.mob_bump_flag = HEAVY

/datum/perk/oddity/ass_of_concrete/remove()
	if(holder)
		holder.mob_bump_flag = ~HEAVY
	..()

/datum/perk/oddity/toxic_revenger
	name = "Toxic Revenger"
	desc = "A heart of gold does not matter when blood is toxic. Those who breathe your air, share your fate. \
			People around you receive toxin damage."
	icon_state = "Hazmat" // https://game-icons.net
	var/cooldown = 1 MINUTES
	var/initial_time

/datum/perk/oddity/toxic_revenger/assign(mob/living/carbon/human/H)
	..()
	initial_time = world.time

/datum/perk/oddity/toxic_revenger/on_process()
	if(!..())
		return
	if(holder.species.flags & NO_BREATHE || holder.internal)
		return
	if(world.time < initial_time + cooldown)
		return
	initial_time = world.time
	for(var/mob/living/L in viewers(holder, 5))
		if(!L)
			continue
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(H.stat == DEAD || H.internal || H.stats.getPerk(PERK_TOXIC_REVENGER) || (H.species.flags & NO_BREATHE))
				continue
		L.reagents?.add_reagent("toxin", 5)
		L.emote("cough")
		to_chat(L, SPAN_WARNING("[holder] emits a strange smell."))

/datum/perk/oddity/absolute_grab
	name = "Absolute Grab"
	desc = "It pays to be a predator. You don't grab, You lunge. \
			You can grab people 1 tile away. Does not work with objects in between you."
	icon_state = "grab" // https://game-icons.net

/datum/perk/oddity/sure_step
	name = "Sure Step"
	desc = " You are more likely to avoid traps."
	icon_state = "mantrap"

/datum/perk/oddity/market_prof
	name = "Market Professional"
	desc = "Just by looking at the item you can know how much it cost."
	icon_state = "market_prof"

/datum/perk/oddity/gunsmith
	name = "Gunsmith"
	desc = "You are skilled in gun production. \
			You produce twice as much ammo from ammo kits, and have more options to pick from when assembling a gun."
	icon_state = "ammo_box" //https://game-icons.net/1x1/sbed/ammo-box.html

///////////////////////////////////////
//////// NT ODDITYS PERKS /////////////
///////////////////////////////////////

/datum/perk/nt_oddity
	gain_text = "God chose you to expand his will."

/datum/perk/nt_oddity/holy_light
	name = "Holy Light"
	desc = "You have been touched by the divine. You now provide a weak healing aura, healing both brute and burn damage to any NeoThelogists nearby as well as yourself."
	icon_state = "third_eye"  //https://game-icons.net/1x1/lorc/third-eye.html
	var/healing_power = 0.1
	var/cooldown = 1 SECONDS // Just to make sure that perk don't go berserk.
	var/initial_time

/datum/perk/nt_oddity/holy_light/assign(mob/living/carbon/human/H)
	..()
	initial_time = world.time

/datum/perk/nt_oddity/holy_light/on_process()
	if(!..())
		return
	if(!holder.get_core_implant(/obj/item/implant/core_implant/cruciform))
		return
	if(world.time < initial_time + cooldown)
		return
	initial_time = world.time
	for(var/mob/living/L in viewers(holder, 7))
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(H.stat == DEAD || !(H.get_core_implant(/obj/item/implant/core_implant/cruciform)))
				continue
			H.adjustBruteLoss(-healing_power)
			H.adjustFireLoss(-healing_power)

/datum/perk/oddity/hive_born
	name = "Hiveborn"
	desc = "You feel electricty flow within your body to your hands. Powercells recharge in your hands."
	icon_state = "circuitry"  //https://game-icons.net/1x1/lorc/circuitry.html
	gain_text = "You feel a stabbing pain of something being injected into you, and with it a painfully pleaseant feeling of being improved."
	var/cooldown = 10 SECONDS
	var/initial_time
	var/obj/item/cell/C

/datum/perk/oddity/hive_born/assign(mob/living/carbon/human/H)
	..()
	initial_time = world.time

/datum/perk/oddity/hive_born/on_process()
	if(!..())
		return
	if(world.time < initial_time + cooldown)
		return
	initial_time = world.time
	if((holder.l_hand && istype(holder.l_hand, /obj/item/cell)))
		C = holder.l_hand
		if(!C.fully_charged())
			C.give(50)
	if((holder.r_hand && istype(holder.r_hand, /obj/item/cell)))
		C = holder.r_hand
		if(!C.fully_charged())
			C.give(50)

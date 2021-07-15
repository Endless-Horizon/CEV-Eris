/mob/living/simple_animal/spider_core
	name = "spider core"
	desc = "A horrifying face on spider-like legs."
	speak_emote = list("creaks")
	response_help  = "pokes"
	response_disarm = "prods"
	response_harm   = "stomps on"
	icon_state = "spider_core"

	health = 60
	maxHealth = 60 //Same as post nerf blitz hp

	speed = -1
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	a_intent = I_HURT
	stop_automated_movement = 1
	status_flags = CANPUSH
	attacktext = "stabed"
	friendly = "punched"
	harm_intent_damage = 1
	wander = 0
	hunger_enabled = FALSE
	pass_flags = PASSTABLE
	universal_understand = 1
	density = TRUE //Should be 0, but then these things would be a nightmare to kill.
	faction = "spiders"

/mob/living/simple_animal/spider_core/New()
	. = ..()
	verbs |= /mob/living/proc/ventcrawl
	verbs |= /mob/living/proc/hide
	verbs |= /mob/living/simple_animal/spider_core/proc/generate_body

/mob/living/simple_animal/spider_core/death()
	gibs(loc, null, /obj/effect/gibspawner/generic, "#666600", "#666600")
	qdel(src)
	

/mob/living/simple_animal/spider_core/proc/generate_body()
	set name = "Build a Body"
	set desc = "Build a new body for you to inhabit."
	set category = "Abilities"

	to_chat(src, SPAN_NOTICE("You start building a body"))

	if(!do_after(src, 1 MINUTES, src))
		to_chat(src, SPAN_NOTICE("The new body is not ready yet, it takes a minute to make one. You have to stand still."))
		return

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(loc)
	visible_message(SPAN_DANGER("[src] morphs into a human body!"))
	gibs(loc, null)
	var/obj/item/organ/internal/carrion/core/core = locate(/obj/item/organ/internal/carrion/core) in contents
	
	var/list/powers_to_buy = list()

	H.faction = "spiders"
	if(core)
		core.spiderlist.Cut()
		core.geneticpoints = round(core.geneticpoints / 2)
		for(var/datum/power/carrion/P in core.purchasedpowers)
			if(P.genomecost) //Free powers are bought automaticaly
				if(prob(50))
					powers_to_buy += P.name
			else
				powers_to_buy += P.name

		core.purchasedpowers.Cut()
		if(!powerinstances.len)
			for(var/P in powers)
				powerinstances += new P()

		var/obj/item/organ/external/chest/chest = H.get_organ(BP_CHEST) // get_organ with no arguments defaults to BP_CHEST, but it makes it less readable
		core.replaced(chest)
		for(var/item in core.active_spiders)
			var/obj/item/implant/carrion_spider/CS = item
			if(istype(CS))
				CS.update_owner_mob()

		usr.mind.transfer_to(H)
		for(var/CP in powers_to_buy)
			core.purchasePower(CP, TRUE)

		core.associated_spider = null

	qdel(src)

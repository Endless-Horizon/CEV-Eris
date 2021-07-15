 ////////////////////////////////////////////////////////////////////////////////
/// Syringes.
////////////////////////////////////////////////////////////////////////////////
#define SYRINGE_DRAW 0
#define SYRINGE_INJECT 1
#define SYRINGE_BROKEN 2

/obj/item/reagent_containers/syringe
	name = "syringe"
	desc = "A syringe."
	icon = 'icons/obj/syringe.dmi'
	item_state = "syringe"
	icon_state = "0"
	matter = list(MATERIAL_GLASS = 1, MATERIAL_STEEL = 1)
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null
	volume = 15
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	sharp = TRUE
	unacidable = 1 //glass
	reagent_flags = TRANSPARENT
	var/mode = SYRINGE_DRAW
	var/breakable = TRUE
	var/image/filling //holds a reference to the current filling overlay
	var/visible_name = "a syringe"
	var/time = 30

/obj/item/reagent_containers/syringe/on_reagent_change()
	if(mode == SYRINGE_INJECT && !reagents.total_volume)
		mode = SYRINGE_DRAW
	else if(mode == SYRINGE_DRAW && !reagents.get_free_space())
		mode = SYRINGE_INJECT
	..()

/obj/item/reagent_containers/syringe/pickup(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/syringe/dropped(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/syringe/attack_self(mob/user as mob)
	switch(mode)
		if(SYRINGE_DRAW)
			mode = SYRINGE_INJECT
		if(SYRINGE_INJECT)
			mode = SYRINGE_DRAW
		if(SYRINGE_BROKEN)
			return
	update_icon()

/obj/item/reagent_containers/syringe/attack_hand()
	..()
	update_icon()

/obj/item/reagent_containers/syringe/attackby(obj/item/I as obj, mob/user as mob)
	return

/obj/item/reagent_containers/syringe/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !target.reagents)
		return

	if(mode == SYRINGE_BROKEN)
		to_chat(user, SPAN_WARNING("This syringe is broken!"))
		return

	if(user.a_intent == I_HURT && ismob(target))
		if((CLUMSY in user.mutations) && prob(50))
			target = user
		syringestab(target, user)
		return

	switch(mode)
		if(SYRINGE_DRAW)
			if(!reagents.get_free_space())
				to_chat(user, SPAN_WARNING("The syringe is full."))
				mode = SYRINGE_INJECT
				return

			else if(ismob(target))//Blood!
				if(reagents.has_reagent("blood"))
					to_chat(user, SPAN_NOTICE("There is already a blood sample in this syringe."))
					return
				if(iscarbon(target))
					if(isslime(target))
						to_chat(user, SPAN_WARNING("You are unable to locate any blood."))
						return
					var/amount = reagents.get_free_space()
					var/mob/living/carbon/T = target
					if(!T.dna)
						to_chat(user, SPAN_WARNING("You are unable to locate any blood. (To be specific, your target seems to be missing their DNA datum)."))
						return
					if(NOCLONE in T.mutations) //target done been et, no more blood in him
						to_chat(user, SPAN_WARNING("You are unable to locate any blood."))
						return

					var/datum/reagent/B
					if(ishuman(T))
						var/mob/living/carbon/human/H = T
						if(H.species && H.species.flags & NO_BLOOD)
							H.reagents.trans_to_obj(src, amount)
						else
							B = T.take_blood(src, amount)
					else
						B = T.take_blood(src,amount)

					if (B)
						reagents.reagent_list += B
						reagents.update_total()
						on_reagent_change()
						reagents.handle_reactions()
					to_chat(user, SPAN_NOTICE("You take a blood sample from [target]."))
					for(var/mob/O in viewers(4, user))
						O.show_message(SPAN_NOTICE("[user] takes a blood sample from [target]."), 1)

			else //if not mob
				if(!target.reagents.total_volume)
					to_chat(user, SPAN_NOTICE("[target] is empty."))
					return

				if(!target.is_drawable())
					to_chat(user, SPAN_NOTICE("You cannot directly remove reagents from this object."))
					return

				var/trans = target.reagents.trans_to_obj(src, amount_per_transfer_from_this)
				to_chat(user, SPAN_NOTICE("You fill the syringe with [trans] units of the solution."))


		if(SYRINGE_INJECT)
			if(!reagents.total_volume)
				to_chat(user, SPAN_NOTICE("The syringe is empty."))
				mode = SYRINGE_DRAW
				return
			if(istype(target, /obj/item/implantcase/chem))
				return

			if(!ismob(target) && !target.is_injectable())
				to_chat(user, SPAN_NOTICE("You cannot directly fill this object."))
				return

			if(!target.reagents.get_free_space())
				to_chat(user, SPAN_NOTICE("[target] is full."))
				return
			if(isliving(target))
				var/mob/living/L = target
				var/injtime = time - (user.stats.getStat(STAT_BIO)*0.375) // 375 was choosen to make a steady increase on speed from 0 being default time and 80 being 0, even if its never really 0
				if(injtime < 10) injtime=10 //should make the "fastest" injection take at least 10

				//Injecting through a hardsuit takes longer due to needing to find a port.
				// Handling errors and injection duration
				var/mob/living/carbon/human/H = target
				if(istype(H))
					var/obj/item/clothing/suit/space/SS = H.get_equipped_item(slot_wear_suit)
					var/obj/item/rig/RIG = H.get_equipped_item(slot_back)
					if((istype(RIG) && RIG.suit_is_deployed()) || istype(SS))
						injtime = injtime * 2
						var/obj/item/organ/external/affected = H.get_organ(BP_CHEST)
						if(BP_IS_ROBOTIC(affected))
							to_chat(user, SPAN_WARNING("Injection port on [target]'s suit is refusing your [src]."))
							// I think rig is advanced enough for this, and people will learn what causes this error
							if(RIG)
								playsound(src.loc, 'sound/machines/buzz-two.ogg', 30, 1, -3)
								RIG.visible_message("\icon[RIG]\The [RIG] states \"Attention: User of this suit appears to be synthetic origin\".")
							return
					// check without message
					else if(!H.can_inject(user, FALSE))
						// lets check if user is easily fooled
						var/obj/item/organ/external/affected = H.get_organ(user.targeted_organ)
						if(BP_IS_LIFELIKE(affected) && user && user.stats.getStat(STAT_BIO) < STAT_LEVEL_BASIC)
							break_syringe(user = user)
							to_chat(user, SPAN_WARNING("\The [src] have broken while trying to inject [target]."))
							return
						else
							// if he is not lets show him what actually happened
							H.can_inject(user, TRUE)
							return

				else if(!L.can_inject(user, TRUE))
					return

				if(target != user)
					user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
					user.do_attack_animation(target)
					if(injtime == time - (user.stats.getStat(STAT_BIO)*0.375))
						user.visible_message(SPAN_WARNING("[user] is trying to inject [target] with [visible_name]!"), SPAN_WARNING("You are trying to inject [target] with [visible_name]!"))
						to_chat(target, SPAN_NOTICE("You feel a tiny prick!"))
					else
						user.visible_message(SPAN_WARNING("[user] begins hunting for an injection port on [target]'s suit!"),SPAN_WARNING("You begin hunting for an injection port on [target]'s suit!"))

					if(do_mob(user, target, injtime))
						user.visible_message(SPAN_WARNING("[user] injects [target] with [src]!"),SPAN_WARNING("You inject [target] with [src]!"))
					else
						return
				else
					user.visible_message(SPAN_WARNING("[user] injects \himself with [src]!"), SPAN_WARNING("You inject yourself with [src]."), range = 3)
			var/trans
			if(ismob(target))
				trans = reagents.trans_to_mob(target, amount_per_transfer_from_this, CHEM_BLOOD)
				admin_inject_log(user, target, src, reagents.log_list(), trans)
				// user's stat check that causing pain if they are amateur
				var/mob/living/carbon/human/H = target
				if(istype(H))
					var/obj/item/organ/external/affecting = H.get_organ(user.targeted_organ)
					if(user && user.stats.getStat(STAT_BIO) < STAT_LEVEL_BASIC)
						if(prob(affecting.get_damage() - user.stats.getStat(STAT_BIO)))
							var/pain = rand(min(30,affecting.get_damage()), max(affecting.get_damage() + 30,60) - user.stats.getStat(STAT_BIO))
							H.pain(affecting, pain)
							if(user != H)
								to_chat(H, "<span class='[pain > 50 ? "danger" : "warning"]'>\The [user]'s amateur actions caused you [pain > 50 ? "a lot of " : ""]pain.</span>")
								to_chat(user, SPAN_WARNING("Your amateur actions caused [H] [pain > 50 ? "a lot of " : ""]pain."))
							else
								to_chat(user, "<span class='[pain > 50 ? "danger" : "warning"]'>Your amateur actions caused you [pain > 50 ? "a lot of " : ""]pain.</span>")
				else
					to_chat(target, SPAN_NOTICE("You feel a tiny prick!"))
			else
				trans = reagents.trans_to(target, amount_per_transfer_from_this)
			to_chat(user, SPAN_NOTICE("You inject [trans] units of the solution. [src] now contains [src.reagents.total_volume] units."))


/obj/item/reagent_containers/syringe/on_update_icon()
	..()
	cut_overlays()

	var/iconstring = initial(item_state)
	if(mode == SYRINGE_BROKEN)
		icon_state = "broken"
		return

	var/rounded_vol
	if(reagents && reagents.total_volume)
		rounded_vol = CLAMP(round((reagents.total_volume / volume * 15),5), 1, 15)
		var/image/filling_overlay = mutable_appearance('icons/obj/reagentfillings.dmi', "[iconstring][rounded_vol]")
		filling_overlay.color = reagents.get_color()
		add_overlay(filling_overlay)
	else
		rounded_vol = 0
	icon_state = "[rounded_vol]"
	item_state = "[iconstring]_[rounded_vol]"
	if(ismob(loc))
		var/injoverlay
		switch(mode)
			if (SYRINGE_DRAW)
				injoverlay = "draw"
			if (SYRINGE_INJECT)
				injoverlay = "inject"
		add_overlay(injoverlay)
		update_wear_icon()

/obj/item/reagent_containers/syringe/proc/syringestab(mob/living/carbon/target as mob, mob/living/carbon/user as mob)
	if(ishuman(target))

		var/mob/living/carbon/human/H = target

		var/target_zone = ran_zone(check_zone(user.targeted_organ, target))
		var/obj/item/organ/external/affecting = H.get_organ(target_zone)

		if (!affecting || affecting.is_stump())
			to_chat(user, SPAN_DANGER("They are missing that limb!"))
			return

		var/hit_area = affecting.name

		if((user != target) && H.check_shields(7, src, user, "\the [src]"))
			return

		if (target != user && H.getarmor(target_zone, ARMOR_MELEE) > 5 && prob(50))
			for(var/mob/O in viewers(world.view, user))
				O.show_message(text("\red <B>[user] tries to stab [target] in \the [hit_area] with [src.name], but the attack is deflected by armor!</B>"), 1)
			user.remove_from_mob(src)
			qdel(src)

			user.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [target.name] ([target.ckey]) with \the [src] (INTENT: HARM).</font>"
			target.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [user.name] ([user.ckey]) with [src.name] (INTENT: HARM).</font>"
			msg_admin_attack("[key_name_admin(user)] attacked [key_name_admin(target)] with [src.name] (INTENT: HARM) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

			return

		user.visible_message(SPAN_DANGER("[user] stabs [target] in \the [hit_area] with [src.name]!"))

		if(affecting.take_damage(3))
			H.UpdateDamageIcon()

	else
		user.visible_message(SPAN_DANGER("[user] stabs [target] with [src.name]!"))
		target.take_organ_damage(3)// 7 is the same as crowbar punch

	var/syringestab_amount_transferred = rand(0, (reagents.total_volume - 5)) //nerfed by popular demand
	var/contained_reagents = reagents.log_list()
	var/trans = reagents.trans_to_mob(target, syringestab_amount_transferred, CHEM_BLOOD)
	if(isnull(trans)) trans = 0
	admin_inject_log(user, target, src, contained_reagents, trans, violent=1)
	break_syringe(target, user)

/obj/item/reagent_containers/syringe/proc/break_syringe(mob/living/carbon/target, mob/living/carbon/user)
	if(!breakable)
		return

	desc += " It is broken."
	mode = SYRINGE_BROKEN
	if(target)
		add_blood(target)
	if(user)
		add_fingerprint(user)
	update_icon()

/obj/item/reagent_containers/syringe/blitzshell
	name = "blitzshell syringe"
	desc = "A blitzshell syringe."
	breakable = FALSE
	spawn_tags = null

/obj/item/reagent_containers/syringe/ld50_syringe
	name = "lethal injection syringe"
	desc = "A syringe used for lethal injections."
	amount_per_transfer_from_this = 60
	volume = 60
	visible_name = "a giant syringe"
	time = 300

/obj/item/reagent_containers/syringe/ld50_syringe/afterattack(obj/target, mob/user, flag)
	if(mode == SYRINGE_DRAW && ismob(target)) // No drawing 50 units of blood at once
		to_chat(user, SPAN_NOTICE("This needle isn't designed for drawing blood."))
		return
	if(user.a_intent == "hurt" && ismob(target)) // No instant injecting
		to_chat(user, SPAN_NOTICE("This syringe is too big to stab someone with it."))
		return
	..()

/obj/item/reagent_containers/syringe/large
	name = "large syringe"
	desc = "A large syringe for those patients who needs a little more"
	icon = 'icons/obj/large_syringe.dmi'
	item_state = "large_syringe"
	icon_state = "0"
	matter = list(MATERIAL_GLASS = 1, MATERIAL_STEEL = 1,MATERIAL_SILVER = 1)
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5,10)
	volume = 30
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	sharp = TRUE
	unacidable = 1 //glass
	reagent_flags = TRANSPARENT

////////////////////////////////////////////////////////////////////////////////
/// Syringes. END
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_containers/syringe/inaprovaline
	name = "syringe (inaprovaline)"
	desc = "Contains inaprovaline - a stimulant used to stabilize patients."
	preloaded_reagents = list("inaprovaline" = 15)
	spawn_tags = SPAWN_TAG_MEDICINE_COMMON
	rarity_value = 10

/obj/item/reagent_containers/syringe/antitoxin
	name = "syringe (anti-toxin)"
	desc = "Contains dylovene - a broad spectrum antitoxin."
	preloaded_reagents = list("anti_toxin" = 15)
	spawn_tags = SPAWN_TAG_MEDICINE_COMMON
	rarity_value = 10

/obj/item/reagent_containers/syringe/tricordrazine
	name = "syringe (tricordrazine)"
	desc = "Contains tricordrazine - a stimulant that can be used to treat a wide range of injuries."
	preloaded_reagents = list("tricordrazine" = 15)
	spawn_tags = SPAWN_TAG_MEDICINE_COMMON
	rarity_value = 15

/obj/item/reagent_containers/syringe/spaceacillin
	name = "syringe (spaceacillin)"
	desc = "Contains spaceacillin - an antibacterial agent."
	preloaded_reagents = list("spaceacillin" = 15)
	spawn_tags = SPAWN_TAG_MEDICINE
	rarity_value = 20

/obj/item/reagent_containers/syringe/hyperzine
	name = "syringe (hyperzine)"
	desc = "Contains hyperzine - a long lasting muscle stimulant."
	preloaded_reagents = list("hyperzine" = 15)

/obj/item/reagent_containers/syringe/drugs
	name = "syringe (drugs)"
	desc = "Contains aggressive drugs meant for torture."
	preloaded_reagents = list("space_drugs" = 5, "mindbreaker" = 5, "cryptobiolin" = 5)
	spawn_tags = SPAWN_ITEM_CONTRABAND
	rarity_value = 50

/obj/item/reagent_containers/syringe/drugs_recreational
	name = "syringe (drugs)"
	desc = "Contains recreational drugs."
	preloaded_reagents = list("space_drugs" = 15)
	spawn_tags = SPAWN_ITEM_CONTRABAND
	rarity_value = 40

/obj/item/reagent_containers/syringe/ld50_syringe/choral
	preloaded_reagents = list("chloralhydrate" = 50)

/obj/item/reagent_containers/syringe/stim
	name = "syringe (stim)"

/obj/item/reagent_containers/syringe/stim/mbr
	name = "syringe (Machine binding ritual)"
	desc = "Contains ethanol based stimulator. Used as ritual drink during technomancers initiation into tribe."
	preloaded_reagents = list("machine binding ritual" = 15)

/obj/item/reagent_containers/syringe/stim/cherrydrops
	name = "syringe (Cherry Drops)"
	desc = "Contains a cherry drops stimulator."
	preloaded_reagents = list("cherry drops" = 15)

/obj/item/reagent_containers/syringe/stim/pro_surgeon
	name = "syringe (ProSurgeon)"
	desc = "Contains a prosurgeon stimulating drug, used to reduce tremor to minimum."
	preloaded_reagents = list("prosurgeon" = 15)

/obj/item/reagent_containers/syringe/stim/violence
	name = "syringe (Violence)"
	desc = "Contains stimulator famous for it's ability to increase peak muscle strength."
	preloaded_reagents = list("violence" = 15)

/obj/item/reagent_containers/syringe/stim/bouncer
	name = "syringe (Bouncer)"
	desc = "Contains stimulator that boost regenerative capabilities."
	preloaded_reagents = list("bouncer" = 15)

/obj/item/reagent_containers/syringe/stim/steady
	name = "syringe (Steady)"
	desc = "Contains stimulator with ability to enchant reaction time."
	preloaded_reagents = list("steady" = 15)

/obj/item/reagent_containers/syringe/stim/machine_spirit
	name = "syringe (Machine Spirit)"
	desc = "Contains ethanol based stimulator. Used to initiate technomancer into inner cirle."
	preloaded_reagents = list("machine spirit" = 15)

/obj/item/reagent_containers/syringe/stim/grape_drops
	name = "syringe (Grape Drops)"
	desc = "Contains powerful stimulator which boosts creativity. Often used by scientists."
	preloaded_reagents = list("grape drops" = 15)

/obj/item/reagent_containers/syringe/stim/ultra_surgeon
	name = "syringe (UltraSurgeon)"
	desc = "Contains strong stimulating drug, which stabilizes muscle motility. Used as last resort during complex surgeries."
	preloaded_reagents = list("ultrasurgeon" = 15)

/obj/item/reagent_containers/syringe/stim/violence_ultra
	name = "syringe (Violence Ultra)"
	desc = "Contains effective electrolyte based muscle stimulant. Often used by most violent gangs"
	preloaded_reagents = list("violence ultra" = 15)

/obj/item/reagent_containers/syringe/stim/boxer
	name = "syringe (Boxer)"
	desc = "Contains stimulator which boosts robustness of human body. Known for its use by boxers."
	preloaded_reagents = list("boxer" = 15)

/obj/item/reagent_containers/syringe/stim/turbo
	name = "syringe (TURBO)"
	desc = "Contains potent mix of cardiovascular and neuro stimulators. Used by sharpshooters to increase accuracy."
	preloaded_reagents = list("turbo" = 15)

/obj/item/reagent_containers/syringe/stim/party_drops
	name = "syringe (Party Drops)"
	desc = "Contains stimulating substance which pumps intelectual capabilities to theoretical maximum. Used as delicacy by some high ranking scientists."
	preloaded_reagents = list("party drops" = 15)

/obj/item/reagent_containers/syringe/stim/menace
	name = "syringe (MENACE)"
	desc = "Contains awfully potent stimulant. Notorious for its usage by suicide troops."
	preloaded_reagents = list("menace" = 15)

////////////////////////////////////////////////////////////////////////////////
/// Large Syringes.
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_containers/syringe/large/antitoxin
	name = "large syringe (anti-toxin)"
	desc = "Contains dylovene - a broad spectrum antitoxin."
	preloaded_reagents = list("anti_toxin" = 30)
	matter = list(MATERIAL_BIOMATTER = 5)
	spawn_blacklisted = TRUE

/obj/item/reagent_containers/syringe/large/dexalin_plus
	name = "large syringe (dexalin+)"
	desc = "Contains dexalin plus - a treatment of oxygen deprivation."
	preloaded_reagents = list("dexalinp" = 30)
	matter = list(MATERIAL_BIOMATTER = 5)
	spawn_blacklisted = TRUE

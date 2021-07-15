/datum/objective/steal
	var/obj/item/steal_target
	var/target_name

	var/global/possible_items[] = list(
		"the captain's antique laser gun" = /obj/item/gun/energy/captain,
		"a hand teleporter" = /obj/item/hand_tele,
		"an RCD" = /obj/item/rcd,
		"a jetpack" = /obj/item/tank/jetpack,
		"a captain's jumpsuit" = /obj/item/clothing/under/rank/captain,
		"a functional AI" = /obj/item/device/aicard,
		"the Technomancer Exultant's advanced voidsuit control module" = /obj/item/rig/ce,
		"the ship blueprints" = /obj/item/blueprints,
		"28 moles of plasma (full tank)" = /obj/item/tank,
		"a sample of slime extract" = /obj/item/slime_extract,
		"a piece of corgi meat" = /obj/item/reagent_containers/food/snacks/meat/corgi,
		"a Moebius expedition overseer's jumpsuit" = /obj/item/clothing/under/rank/expedition_overseer,
		"a exultant's jumpsuit" = /obj/item/clothing/under/rank/exultant,
		"a Moebius biolab officer's jumpsuit" = /obj/item/clothing/under/rank/moebius_biolab_officer,
		"a Ironhammer commander's jumpsuit" = /obj/item/clothing/under/rank/ih_commander,
		"a First Officer's jumpsuit" = /obj/item/clothing/under/rank/first_officer,
		"the hypospray" = /obj/item/reagent_containers/hypospray,
		"the captain's pinpointer" = /obj/item/pinpointer,
		"an ablative armor vest" = /obj/item/clothing/suit/armor/laserproof,
		"an Ironhammer hardsuit control module" = /obj/item/rig/combat/ironhammer,
		"a Bluespace Biosyphon" = /obj/item/biosyphon,
		"a S REV .35 Auto \"Sky Driver\"" = /obj/item/gun/projectile/revolver/sky_driver,
		"Von-Krabin Stimulator" = /obj/item/device/von_krabin,
		"Molitor-Riedel Enricher" = /obj/item/reagent_containers/enricher,
		"an Ancient Maneki Neko" = /obj/item/maneki_neko,
		"a Techno-Tribalism Enforcer" = /obj/item/device/techno_tribalism,
		"an Random wave radio" = /obj/item/device/radio/random_radio,
		"the Sword of Truth" = /obj/item/tool/sword/nt_sword,
		"the Last Shelter" = /obj/item/device/last_shelter,
		"an Atomic Distillery" = /obj/item/reagent_containers/atomic_distillery,
		"the Laurelin bonsai" = /obj/item/reagent_containers/bonsai
	)

	var/global/possible_items_special[] = list(
		"mindflayer" = /obj/item/gun/energy/psychic/mindflayer,
		"advanced energy gun" = /obj/item/gun/energy/nuclear,
		"diamond drill" = /obj/item/tool/pickaxe/diamonddrill,
		"bag of holding" = /obj/item/storage/backpack/holding,
		"hyper-capacity cell" = /obj/item/cell/large/hyper,
		"10 diamonds" = /obj/item/stack/material/diamond,
		"50 gold bars" = /obj/item/stack/material/gold,
		"25 refined uranium bars" = /obj/item/stack/material/uranium,
	)


/datum/objective/steal/set_target(var/item_name)
	target_name = item_name
	steal_target = possible_items[target_name]
	if(!steal_target)
		steal_target = possible_items_special[target_name]
	update_explanation()
	return steal_target

/datum/objective/steal/find_target()
	var/list/valid_items = possible_items - get_owner_targets()
	return set_target(pick(valid_items))


/datum/objective/steal/proc/select_target(var/mob/user)
	var/list/possible_items_all = possible_items + possible_items_special
	var/new_target = input(user, "Select target:", "Objective target", target_name) as null|anything in possible_items_all
	if(!new_target)
		return

	set_target(new_target)
	return steal_target

/datum/objective/steal/check_completion()
	if (failed)
		return FALSE
	if(!steal_target)
		return FALSE
	if(owner && !isliving(owner.current))
		return FALSE
	var/list/all_items = get_owner_inventory()
	switch(target_name)
		if("28 moles of plasma (full tank)", "10 diamonds", "50 gold bars", "25 refined uranium bars")
			var/target_amount = text2num(target_name)//Non-numbers are ignored.
			var/found_amount = 0//Always starts as zero.

			for(var/obj/item/I in all_items) //Check for plasma tanks
				if(istype(I, steal_target))
					found_amount += (target_name == "28 moles of plasma (full tank)" ? (I:air_contents:gas["plasma"]) : (I:amount))
			return found_amount >= target_amount

		if("50 coins (in bag)")
			var/obj/item/moneybag/B = locate() in all_items

			if(B)
				var/target = text2num(target_name)
				var/found_amount = 0
				for(var/obj/item/coin/C in B)
					found_amount++
				return found_amount>=target

		if("a functional AI")

			for(var/obj/item/device/aicard/C in all_items) //Check for ai card
				for(var/mob/living/silicon/ai/M in C)
					//See if any AI's are alive inside that card.
					if(isAI(M) && M.stat != DEAD)
						return TRUE

			for(var/mob/living/silicon/ai/ai in world)
				var/turf/T = get_turf(ai)
				if(istype(T))
					var/area/check_area = get_area(ai)
					if(istype(check_area, /area/shuttle/escape_pod1/centcom))
						return TRUE
					if(istype(check_area, /area/shuttle/escape_pod2/centcom))
						return TRUE
		else
			for(var/obj/I in all_items) //Check for items
				if(istype(I, steal_target))
					return TRUE
	return FALSE

/datum/objective/steal/get_panel_entry()
	return "Steal <a href='?src=\ref[src];switch_item=1'>[target_name]</a>."

/datum/objective/steal/update_explanation()
	explanation_text = "Steal [target_name]."

/datum/objective/steal/Topic(href, href_list)
	if(..())
		return TRUE
	if(href_list["switch_item"])
		select_target(usr)
		antag.antagonist_panel()

/datum/objective/steal/get_target()
	return target_name

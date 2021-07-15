GLOBAL_LIST_EMPTY(all_bounty_entries)

/datum/computer_file/report/bounty_entry
	filetype = "BTE"
	size = 1
	var/obj/item/card/id/owner_id_card //Who set this bounty
	var/obj/item/card/id/claimedby_id_card //Who completed this bounty, and was confirmed by the owner?

// Kept as a computer file for possible future expansion into servers. I guess ?
/datum/computer_file/report/bounty_entry/New()
	..()

/datum/computer_file/report/bounty_entry/Destroy()
	. = ..()
	GLOB.all_bounty_entries.Remove(src)

/datum/computer_file/report/bounty_entry/generate_fields()
	..()
	add_field(/datum/report_field/simple_text, "Title")
	add_field(/datum/report_field/pencode_text, "Job description")
	add_field(/datum/report_field/number/module, "Reward")

	add_field(/datum/report_field/signature/anon, "Employer")
	add_field(/datum/report_field/array/signed_people, "People who signed for job")

/datum/computer_file/report/bounty_entry/proc/publish(var/mob/user)
	if(user)
		if(field_from_name("Title").get_value() && field_from_name("Job description").get_value() && field_from_name("Reward").get_value() && field_from_name("Employer").get_value())
			if(!owner_id_card)
				return
			var/obj/item/card/id/held_card = user.GetIdCard()
			var/datum/money_account/authenticated_account
			if(held_card == owner_id_card)
				if("Yes" == input(usr, "Use your ID card ?", "Credits will be instantly debited from your account.<br>Would you like to use your ID associated account for that?", list("Yes", "No")) as null|anything in list("Yes", "No"))
					authenticated_account = get_account(held_card.associated_account_number)
			if(!authenticated_account || held_card != owner_id_card)
				var/tried_account_num = input("Enter account number", "") as num
				var/tried_pin = input("Enter PIN number", "") as num
				if(!tried_account_num || !tried_pin)
					to_chat(user, "<span class='warning'>You must enter a valid bank account + PIN to create a bounty!</span>")
					return
				authenticated_account = attempt_account_access(tried_account_num, tried_pin, held_card && held_card.associated_account_number == tried_account_num ? 2 : 1, TRUE)
			if(authenticated_account)
				//TODO FEE that captain can set
				/*var/fee = (reward*fee_multiplier) //Service charge. Craptain can configure, defaults to 5%
				var/charge = (reward + fee)*/
				var/datum/transaction/T = new(-field_from_name("Reward").get_value(), authenticated_account.owner_name, "Bounty Placed", "Bounty board system")
				if(T.apply_to(authenticated_account))
					to_chat(user, "<span class='warning'>Bounty created. You will have to manually confirm completion by chosing right contractor from the list of all signed up people!</span>")
				else
					to_chat(user, "<span class='warning'>You don't have enough funds to do that!</span>")
					return
			else
				to_chat(user, "<span class='warning'>You must enter a valid bank account + PIN to create a bounty!</span>")
				return
			GLOB.all_bounty_entries += src
			log_game("Bounty: [field_from_name("Title").get_value()] created by [user]")
			for(var/mob/living/carbon/human/H in GLOB.human_mob_list)
				if(ishuman(H))
					if (H == user)
						continue
					var/obj/item/modular_computer/C = locate(/obj/item/modular_computer) in H.GetAllContents()
					if(C)
						var/datum/computer_file/program/P = C.getProgramByType(/datum/computer_file/program/bounty_board_app)
						if(P)
							C.visible_message("\The [C] buzz softly and states \"New bounty avaliable on online bounty board\".", 1)
							playsound(C, 'sound/machines/buzz-two.ogg', 50, 1)
			return TRUE
		else
			return FALSE


/datum/computer_file/report/bounty_entry/proc/remove(mob/living/carbon/human/contractor)
	var/destroy = FALSE
	if(istype(contractor))
		claimedby_id_card = contractor.GetIdCard()
		if(!claimedby_id_card)
			return
		var/datum/money_account/authenticated_account = get_account(claimedby_id_card.associated_account_number)
		if(authenticated_account)
			var/datum/transaction/T = new(field_from_name("Reward").get_value(), authenticated_account.owner_name, "Bounty Claimed", "Bounty board system")
			T.apply_to(authenticated_account)
	else
		if(owner_id_card)
			var/datum/money_account/authenticated_account = get_account(owner_id_card.associated_account_number)
			if(authenticated_account)
				var/datum/transaction/T = new(field_from_name("Reward").get_value(), authenticated_account.owner_name, "Bounty Claimed", "Bounty board system")
				T.apply_to(authenticated_account)
		destroy = TRUE
	for(var/mob/living/carbon/human/H in GLOB.human_mob_list)
		if(ishuman(H))
			var/obj/item/modular_computer/C = locate(/obj/item/modular_computer) in H.GetAllContents()
			if(C)
				var/datum/computer_file/program/P = C.getProgramByType(/datum/computer_file/program/bounty_board_app)
				if(P)
					if (H == contractor)
						playsound(src, 'sound/machines/buzz-two.ogg', 50, 1)
						C.visible_message("\The [C] buzz softly and states \"Bounty reward was transfered to your account\".")
					else
						var/datum/report_field/array/signed_people/SP = field_from_name("People who signed for job")
						if(H in SP.get_raw())
							if(istype(contractor))
								C.visible_message("\The [C] buzz loudly and states \"Bounty reward that you signed for was claimed by someone else\".", 1)
								playsound(C, 'sound/machines/buzz-two.ogg', 50, 1)
							else
								C.visible_message("\The [C] buzz loudly and states \"Bounty reward that you signed for was removed\".", 1)
								playsound(C, 'sound/machines/buzz-two.ogg', 50, 1)
	if(destroy)
		qdel(src)
	return TRUE

/datum/report_field/array/signed_people
	can_edit = FALSE

/datum/report_field/array/signed_people/New()
	add_value("Nobody")

/datum/report_field/array/signed_people/get_value()
	var/dat = ""
	for(var/i = 2, i<=value_list.len, i++)
		if(i > 2)
			dat += "<br>"
		dat += "[value_list[i]]"
	return dat
/datum/report_field
	var/datum/computer_file/report/owner //The report to which this field belongs.
	var/name = "generic field"     //The name the field will be labeled with.
	var/value                      //Only used internally.
	var/can_edit = 1               //Whether the field gives the user the option to edit it.
	var/required = 0               //Whether the field is required to submit the report.
	var/ID                         //A unique (per report) id; don't set manually.
	var/needs_big_box = 0          //Suggests that the output won't look good in-line. Useful in nanoui logic.
	var/ignore_value = 0           //Suggests that the value should not be displayed.
	var/list/access_edit = list(list())  //The access required to edit the field.
	var/list/access = list(list())       //The access required to view the field.

/datum/report_field/New(datum/computer_file/report/report)
	owner = report
	..()

/datum/report_field/Destroy()
	owner = null
	. = ..()

//Access stuff. Can be given access constants or lists. See report access procs for documentation.
/datum/report_field/proc/set_access(access, access_edit, override = 1)
	if(access)
		if(!islist(access))
			access = list(access)
		override ? (src.access = list(access)) : (src.access += list(access))
	if(access_edit)
		if(!islist(access_edit))
			access_edit = list(access_edit)
		override ? (src.access_edit = list(access_edit)) : (src.access_edit += list(access_edit))

/datum/report_field/proc/verify_access(given_access)
	return has_access_pattern(access, given_access)

/datum/report_field/proc/verify_access_edit(given_access)
	if(!verify_access(given_access))
		return
	return has_access_pattern(access_edit, given_access)

//Assumes the old and new fields are of the same type. Override if the field stores information differently.
/datum/report_field/proc/copy_value(datum/report_field/old_field)
	value = old_field.value
	access = old_field.access
	access_edit = old_field.access_edit

//Gives the user prompts to fill out the field.
/datum/report_field/proc/ask_value(mob/user)

//Sanitizes and sets the value from input.
/datum/report_field/proc/set_value(given_value)
	value = given_value

//Exports the contents of the field into html for viewing.
/datum/report_field/proc/get_value()
	return value

//In case the name needs to be displayed dynamically.
/datum/report_field/proc/display_name()
	return name

/*
Basic field subtypes.
*/

//For information between fields.
/datum/report_field/instruction
	can_edit = 0
	ignore_value = 1

//Basic text field, for short strings.
/datum/report_field/simple_text
	value = ""

/datum/report_field/simple_text/set_value(given_value)
	if(istext(given_value))
		value = sanitizeSafe(given_value) || ""

/datum/report_field/simple_text/ask_value(mob/user)
	var/input = input(user, "[display_name()]:", "Form Input", get_value()) as null|text
	set_value(input)

//Inteded for sizable text blocks.
/datum/report_field/pencode_text
	value = ""
	needs_big_box = 1

/datum/report_field/pencode_text/get_value()
	return pencode2html(value)

/datum/report_field/pencode_text/set_value(given_value)
	if(istext(given_value))
		value = sanitizeSafe(replacetext(given_value, "\n", "\[br\]"), MAX_PAPER_MESSAGE_LEN) || ""

/datum/report_field/pencode_text/ask_value(mob/user)
	set_value(input(user, "[display_name()] (You may use HTML paper formatting tags):", "Form Input", replacetext(html_decode(value), "\[br\]", "\n")) as null|message)

//Uses hh:mm format for times.
/datum/report_field/time
	value = "00:00"

/datum/report_field/time/set_value(given_value)
	value = sanitize_time(given_value, value, "hh:mm")

/datum/report_field/time/ask_value(mob/user)
	set_value(input(user, "[display_name()] (time as hh:mm):", "Form Input", get_value()) as null|text)

//Uses YYYY-MM-DD format for dates.
/datum/report_field/date/New()
	..()
	value = stationdate2text()

/datum/report_field/date/set_value(given_value)
	value = sanitize_time(given_value, value, "YEAR-MM-DD")

/datum/report_field/date/ask_value(mob/user)
	set_value(input(user, "[display_name()] (date as YYYY-MM-DD):", "Form Input", get_value()) as null|text)

//Will prompt for numbers.
/datum/report_field/number
	value = 0

/datum/report_field/number/set_value(given_value)
	if(isnum(given_value))
		value = abs(given_value)

/datum/report_field/number/module/ask_value(mob/user)
	var/input_value = input(user, "[display_name()]:", "Form Input", get_value()) as null|num

	if(input_value < 0)
		to_chat(user,SPAN_WARNING("Value has to be positive."))
		return
	var/obj/item/card/id/held_card = user.GetIdCard()
	if(!held_card)
		to_chat(user, SPAN_WARNING("Your ID is missing."))
		return
	var/datum/money_account/used_account = get_account(held_card.associated_account_number)
	var/datum/transaction/T_post = new(-input_value, used_account.owner_name, "Bounty Edited", "Bounty board system")
	if(T_post.apply_to(used_account)) //Charges the new money
		to_chat(user, SPAN_WARNING("Bounty modified. Your previous funds have been refunded."))
		var/datum/transaction/T_pre = new(value, used_account.owner_name, "Bounty Refund", "Bounty board system")
		T_pre.apply_to(used_account) //Refunds the old money
	else
		to_chat(user, SPAN_WARNING("You don't have enough funds to do that!"))
		return

	set_value(input_value)

/datum/report_field/number/module/set_value(given_value)
	if(isnum(given_value))
		value = given_value

/datum/report_field/number/ask_value(mob/user)
	set_value(input(user, "[display_name()]:", "Form Input", get_value()) as null|num)

//Gives a list of choices to pick one from.
/datum/report_field/options/proc/get_options()

/datum/report_field/options/set_value(given_value)
	if(given_value in get_options())
		value = given_value

/datum/report_field/options/ask_value(mob/user)
	set_value(input(user, "[display_name()] (select one):", "Form Input", get_value()) as null|anything in get_options())

//Yes or no field.
/datum/report_field/options/yes_no
	value = "No"

/datum/report_field/options/yes_no/get_options()
	return list("Yes", "No")

//Signature field; ask_value will obtain the user's signature.
/datum/report_field/signature/get_value()
	return "<font face=\"Times New Roman\"><i>[value]</i></font>"

/datum/report_field/signature/ask_value(mob/user)
	set_value((user && user.real_name) ? user.real_name : "Anonymous")

/datum/report_field/signature/anon/ask_value(mob/user)
	if(user)
		if("No" == input(user, "Would you like be anonymous ?", "", get_value()) as null|anything in list("No", "Yes"))
			set_value(user.real_name ? user.real_name : "Anonymous")
		else
			set_value("Anonymous")

/datum/report_field/array
	var/list/value_list = list()

/datum/report_field/array/proc/get_raw(var/position)
	if(position)
		return value_list[position]
	else
		return value_list

/datum/report_field/array/get_value()
	var/dat = ""
	for(var/i = 1, i<=value_list.len, i++)
		if(i > 1)
			dat += "<br>"
		dat += "[value_list[i]]"
		return dat

/datum/report_field/array/set_value()
	error("Use add_value()")
	return

/datum/report_field/array/proc/add_value(var/given_value)
	value_list.Add(given_value)

/datum/report_field/array/proc/remove_value(var/given_value)
	value_list.Remove(given_value)

/datum/report_field/array/ask_value(mob/user)
	add_value(input(user, "Add value", "") as null|text)

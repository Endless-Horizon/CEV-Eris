/datum/money_account
	var/owner_name = ""
	var/account_name = "" //Some accounts have a name that is distinct from the name of the owner
	var/account_number = 0
	var/remote_access_pin = 0
	var/money = 0
	var/list/transaction_log = list()
	var/suspended = 0
	var/security_level = 0	//0 - auto-identify from worn ID, require only account number
							//1 - require manual login / account number and pin
							//2 - require card and manual login

//One-stop safety checks for accounts
/datum/money_account/proc/is_valid()
	if (suspended)
		return FALSE

	return TRUE

//Try to get the name of the account
/datum/money_account/proc/get_name()
	if (account_name)
		return account_name
	return owner_name

//Attempts to return the associated data record for this account
/datum/money_account/proc/get_record()
	return find_general_record("pay_account", account_number)

/datum/transaction
	var/target_name = ""
	var/target_account = 0
	var/purpose = ""
	var/amount = 0
	var/date = ""
	var/time = ""
	var/source_terminal = ""

/datum/transaction/New(_amount = 0, _target_name, _purpose, _source_terminal, _date = null, _time = null)
	amount = _amount
	target_name = _target_name
	purpose = _purpose
	source_terminal = _source_terminal

	if(istype(_source_terminal, /atom))
		var/atom/terminal_atom = _source_terminal
		source_terminal = "[terminal_atom.name] at [get_area(terminal_atom)]"

	if(_date)
		date = _date
	else
		date = current_date_string
	if(_time)
		time = _time
	else
		time = stationtime2text()

/datum/transaction/proc/apply_to(var/datum/money_account/account)
	if(!istype(account) || !account.is_valid())
		return FALSE

	if(isnum(amount))
		if(amount < 0 && (account.money + amount) < 0)
			return FALSE
		account.money += amount

	account.transaction_log.Add(src.Copy())
	return TRUE

/datum/transaction/proc/set_amount(var/amount, var/update_time = TRUE)
	src.amount = amount
	if(update_time)
		src.time = stationtime2text()

/datum/transaction/proc/Copy()
	return new/datum/transaction(amount, target_name, purpose, source_terminal, date, time)

/proc/create_account(new_owner_name = "Default user", starting_funds = 0, obj/machinery/account_database/source_db)

	//create a new account
	var/datum/money_account/M = new()
	M.owner_name = new_owner_name
	M.remote_access_pin = rand(1111, 9999)
	M.money = starting_funds

	//create an entry in the account transaction log for when it was created
	var/datum/transaction/T = new()
	T.target_name = new_owner_name
	T.purpose = "Account creation"
	T.amount = starting_funds
	if(!source_db)
		//set a random date, time and location some time over the past few decades
		T.date = "[num2text(rand(1,31))] [pick("January","February","March","April","May","June","July","August","September","October","November","December")], 25[rand(10,56)]"
		T.time = "[rand(0,24)]:[rand(11,59)]"
		T.source_terminal = "Asters Guild Banking Terminal #[rand(111,1111)]"

		M.account_number = rand(11111, 99999)
	else
		T.date = current_date_string
		T.time = stationtime2text()
		T.source_terminal = source_db.machine_id

		M.account_number = next_account_number
		next_account_number += rand(1,25)

		//create a sealed package containing the account details
		var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(source_db.loc)

		var/obj/item/paper/R = new /obj/item/paper(P)
		P.wrapped = R
		R.name = "Account information: [M.owner_name]"
		R.info = "<b>Account details (confidential)</b><br><hr><br>"
		R.info += "<i>Account holder:</i> [M.owner_name]<br>"
		R.info += "<i>Account number:</i> [M.account_number]<br>"
		R.info += "<i>Account pin:</i> [M.remote_access_pin]<br>"
		R.info += "<i>Starting balance:</i> [M.money][CREDS]<br>"
		R.info += "<i>Date and time:</i> [stationtime2text()], [current_date_string]<br><br>"
		R.info += "<i>Creation terminal ID:</i> [source_db.machine_id]<br>"
		R.info += "<i>Authorised official overseeing creation:</i> [source_db.held_card.registered_name]<br>"

		//stamp the paper
		var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
		stampoverlay.icon_state = "paper_stamp-cent"
		if(!R.stamped)
			R.stamped = new
		R.stamped += /obj/item/stamp
		R.add_overlays(stampoverlay)
		R.stamps += "<HR><i>This paper has been stamped by the Accounts Database.</i>"

	//add the account
	M.transaction_log.Add(T)
	all_money_accounts.Add(M)

	return M

//Charges an account a certain amount of money which is functionally just removed from existence
/proc/charge_to_account(attempt_account_number, target_name, purpose, terminal_id, amount)
	var/datum/money_account/D = get_account(attempt_account_number)
	if (D)
		//create a transaction log entry
		var/datum/transaction/T = new(-amount, target_name, purpose, terminal_id)
		return T.apply_to(D)

	return FALSE

//Creates money from nothing and deposits it in an account
/proc/deposit_to_account(attempt_account_number, source_name, purpose, terminal_id, amount)
	var/datum/money_account/D = get_account(attempt_account_number)
	if (D)
		//create a transaction log entry
		var/datum/transaction/T = new(amount, source_name, purpose, terminal_id)
		return T.apply_to(D)

	return FALSE

//Transfers funds from one account to another
/proc/transfer_funds(source_account, target_account, purpose, terminal_id, amount)
	var/datum/money_account/source = get_account(source_account)
	var/datum/money_account/target = get_account(target_account)

	if (!source || !target)
		return FALSE
	if (!source.is_valid() || !target.is_valid())
		return FALSE

	//We've got both accounts and confirmed they are valid

	//The transaction to take the money
	var/datum/transaction/T1 = new(amount*-1, target.get_name(), purpose, terminal_id)
	if (T1.apply_to(source))

		//The transaction to give the money
		var/datum/transaction/T2 = new(amount, source.get_name(), purpose, terminal_id)
		SEND_SIGNAL(source, COMSIG_TRANSATION, source, target, amount)
		return T2.apply_to(target)

	return FALSE

//this returns the first account datum that matches the supplied accnum/pin combination, it returns null if the combination did not match any account
/proc/attempt_account_access(account_number, attempt_pin_number, security_level_passed = 0, force_security = FALSE)
	var/datum/money_account/D = get_account(account_number)

	if(!D || D.security_level > security_level_passed)
		return

	if((!D.security_level && !force_security) || D.remote_access_pin == attempt_pin_number)
		return D


/proc/get_account(account_number)
	// For convinience's sake
	if(istype(account_number, /datum/money_account))
		return account_number

	for(var/datum/money_account/D in all_money_accounts)
		if(D.account_number == account_number)
			return D


// Accepts both account numbers and actual account datums
/proc/get_account_credits(account_number)
	var/datum/money_account/account = get_account(account_number)
	if(!account || !account.is_valid())
		return 0

	return account.money

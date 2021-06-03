
#define RIOTS 1
#define WILD_ANIMAL_ATTACK 2
#define INDUSTRIAL_ACCIDENT 3
#define BIOHAZARD_OUTBREAK 4
#define WARSHIPS_ARRIVE 5
#define PIRATES 6
#define CORPORATE_ATTACK 7
#define ALIEN_RAIDERS 8
#define AI_LIBERATION 9
#define MOURNING 10
#define CULT_CELL_REVEALED 11
#define SECURITY_BREACH 12
#define ANIMAL_RIGHTS_RAID 13
#define FESTIVAL 14

#define RESEARCH_BREAKTHROUGH 15
#define BARGAINS 16
#define SONG_DEBUT 17
#define MOVIE_RELEASE 18
#define BIG_GAME_HUNTERS 19
#define ELECTION 20
#define GOSSIP 21
#define TOURISM 22
#define CELEBRITY_DEATH 23
#define RESIGNATION 24

#define DEFAULT 1

#define ADMINISTRATIVE 2
#define CLOTHING 3
#define SECURITY 4
#define SPECIAL_SECURITY 5

#define FOOD 6
#define ANIMALS 7

#define MINERALS 8

#define EMERGENCY 9
#define MAINTENANCE 11
#define ELECTRICAL 12
#define ROBOTICS 13
#define BIOMEDICAL 14

#define GEAR_EVA 15


/var/list/economic_species_modifier = list(/datum/species/human	= 10)

//---- Descriptions of destination types
//Space stations can be purpose built for a number of different things, but generally require regular shipments of essential supplies.
//Corvettes are small, fast warships generally assigned to border patrol or chasing down smugglers.
//Battleships are large, heavy cruisers designed for slugging it out with other heavies or razing planets.
//Yachts are fast civilian craft, often used for pleasure or smuggling.
//Destroyers are medium sized vessels, often used for escorting larger ships but able to go toe-to-toe with them if need be.
//Frigates are medium sized vessels, often used for escorting larger ships. They will rapidly find themselves outclassed if forced to face heavy warships head on.

var/global/current_date_string

var/global/datum/money_account/vendor_account
var/global/datum/money_account/station_account
var/global/list/datum/money_account/department_accounts = list()
var/global/num_financial_terminals = 1
var/global/next_account_number = 0
var/global/list/all_money_accounts = list()
var/global/list/transaction_devices = list()
var/global/economy_init = 0

//Email account used to send notifications about salaries. Payments made, funding failed, etc
var/global/datum/computer_file/data/email_account/service/payroll/payroll_mailer = null

/proc/setup_economy()
	if(economy_init)
		return 2

	payroll_mailer = new

	news_network.CreateFeedChannel("Nyx Daily", "SolGov Minister of Information", 1, 1)
	news_network.CreateFeedChannel("The Gibson Gazette", "Editor Mike Hammers", 1, 1)

	for(var/loc_type in typesof(/datum/trade_destination) - /datum/trade_destination)
		var/datum/trade_destination/D = new loc_type
		weighted_randomevent_locations[D] = D.viable_random_events.len
		weighted_mundaneevent_locations[D] = D.viable_mundane_events.len


	//Create all the department accounts
	for(var/d in GLOB.all_departments)
		create_department_account(GLOB.all_departments[d])

	station_account = department_accounts[DEPARTMENT_COMMAND]
	vendor_account = department_accounts[DEPARTMENT_GUILD] //Vendors are operated by the guild and purchases pay into their stock

	for(var/obj/machinery/vending/V in GLOB.machines)
		if(!V.custom_vendor)
			V.earnings_account = V.vendor_department ? department_accounts[V.vendor_department] : vendor_account

	current_date_string = "[num2text(rand(1,31))] [pick("January","February","March","April","May","June","July","August","September","October","November","December")], [game_year]"

	economy_init = 1
	return 1


/proc/create_department_account(var/datum/department/department)
	next_account_number = rand(111111, 999999)

	var/datum/money_account/department_account = new()
	department_account.account_name = "[department.name] Account"
	department_account.account_number = rand(111111, 999999)
	department.account_number = department_account.account_number

	department_account.remote_access_pin = rand(1111, 111111)
	department.account_pin = department_account.remote_access_pin

	//create an entry in the account transaction log for when it was created
	var/datum/transaction/T = new(department.account_initial_balance, department_account.owner_name, "Account creation", "Asters Guild Terminal #277")
	T.date = "2 April, 2555"
	T.time = "11:24"

	//add the account
	T.apply_to(department_account)
	all_money_accounts.Add(department_account)

	department_accounts[department.id] = department_account

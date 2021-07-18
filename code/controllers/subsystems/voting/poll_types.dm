
///////////////////////////////////////////////
///////////////////VOTES//////////////////////
//////////////////////////////////////////////

/datum/poll/restart
	name = "Restart"
	question = "Restart Round"
	time = 60
	choice_types = list(/datum/vote_choice/restart, /datum/vote_choice/countinue_round)

	only_admin = TRUE

	multiple_votes = FALSE
	can_revote = TRUE
	can_unvote = FALSE

	see_votes = TRUE

/datum/vote_choice/restart
	text = "Restart Round"

/datum/vote_choice/restart/on_win()
	to_chat(world, "<b>World restarting due to vote...<b>")
	sleep(50)
	log_game("Rebooting due to restart vote")
	world.Reboot()

/datum/vote_choice/countinue_round
	text = "Continue Round"






/* STORYTODO

/*********************
	Storyteller
**********************/
/datum/poll/storyteller
	name = "Storyteller"
	question = "Choose storyteller"
	time = 120
	choice_types = list()
	minimum_voters = 0
	only_admin = FALSE

	multiple_votes = FALSE
	can_revote = TRUE
	can_unvote = TRUE
	cooldown = 30 MINUTES
	see_votes = TRUE

	var/pregame = FALSE

//We will sort the storyteller choices carefully. Guide is always first, all the rest are in a random order
/datum/poll/storyteller/init_choices()
	master_storyteller = null
	var/datum/vote_choice/storyteller/base = null
	for(var/ch in GLOB.storyteller_cache)
		var/datum/vote_choice/storyteller/CS = new
		var/datum/storyteller/S = GLOB.storyteller_cache[ch]
		CS.text = S.name
		CS.desc = S.description
		CS.new_storyteller = ch

		//The base storyteller, Guide, is put aside for a moment
		if (S.config_tag == STORYTELLER_BASE)
			base = CS
			continue
		//Storytellers are inserted at a random spot so they will be randomly sorted
		var/index = rand(1, max(choices.len, 1))
		if(S.votable)
			choices.Insert(index, CS)
		else
			qdel(CS)

	//After everything else is in, the guide is inserted at the top,
	//so it will always be the first option in the poll
	choices.Insert(1, base)

/datum/poll/storyteller/Process()
	if(pregame && SSticker.current_state != GAME_STATE_PREGAME)
		SSvote.stop_vote()
		to_chat(world, "<b>Voting aborted due to game start.</b>")
	return



/datum/poll/storyteller/on_start()
	if (SSticker.current_state == GAME_STATE_PREGAME)
		pregame = TRUE
		round_progressing = FALSE
		to_chat(world, "<b>Game start has been delayed due to voting.</b>")

//If one wins, on_end is called after on_win, so the new storyteller will be set in master_storyteller
/datum/poll/storyteller/on_end()
	..()
	//This happens if the vote was skipped with force start
	if (!master_storyteller)
		master_storyteller = STORYTELLER_BASE
		world.save_storyteller(master_storyteller)

	SSticker.story_vote_ended = TRUE


	set_storyteller(config.pick_storyteller(master_storyteller), announce = !(pregame)) //This does the actual work //Even if master storyteller is null, this will pick the default
	if (pregame)
		round_progressing = TRUE
		to_chat(world, "<b>The game will start in [SSticker.pregame_timeleft] seconds.</b>")
		spawn(10 SECONDS)
			var/tipsAndTricks/T = SStips.getRandomTip()
			if(T)
				var/typeText = ""
				if(istype(T, /tipsAndTricks/gameplay))
					typeText = "Gameplay"
				else if(istype(T, /tipsAndTricks/mobs))
					var/tipsAndTricks/mobs/MT = T
					var/mob/M = pick(MT.mobs_list)
					// I suppose this will be obsolete someday
					if(M == /mob/living/carbon/human)
						typeText = SPECIES_HUMAN
					else
						typeText = initial(M.name)
				else if(istype(T, /tipsAndTricks/roles))
					var/tipsAndTricks/roles/RT = T
					var/datum/antagonist/A = pick(RT.roles_list)
					typeText = initial(A.role_text)
				else if(istype(T, /tipsAndTricks/jobs))
					var/tipsAndTricks/jobs/JT = T
					var/datum/job/J = pick(JT.jobs_list)
					typeText = initial(J.title)
				to_chat(world, SStips.formatTip(T, "Random Tip \[[typeText]\]: "))
	pregame = FALSE

/datum/vote_choice/storyteller
	text = "You shouldn't see this."
	var/new_storyteller = STORYTELLER_BASE

//on_end will be called after this, so that's where we actually call set_storyteller
/datum/vote_choice/storyteller/on_win()
	if (master_storyteller == new_storyteller)
		poll.next_vote = world.time + (poll.cooldown * 0.5) //If the storyteller didn't actually change, the cooldown is half as long
	master_storyteller = new_storyteller
	world.save_storyteller(master_storyteller)


*/



/*********************
	Evacuate Ship
**********************/
/datum/poll/evac
	name = "Initiate Bluespace Jump"
	question = "Do you want to initiate a bluespace jump and restart the round?"
	time = 120
	minimum_win_percentage = 0.6
	cooldown = 20 MINUTES
	next_vote = 90 MINUTES //Minimum round length before it can be called for the first time
	choice_types = list()
	description = "You will have more voting power if you are head of staff or antag, less if you are observing or dead."

/*To prevent abuse and rule-by-salt, the evac vote weights each player's vote based on a few parameters
	If you are alive and have been for a while, then you have the normal 1 vote
	If you are dead, or just spawned, you get only 0.3 votes
	If you are an antag or a head of staff, you get 2 votes
*/
#define VOTE_WEIGHT_LOW	0.3
#define VOTE_WEIGHT_NORMAL	1
#define VOTE_WEIGHT_HIGH	2
#define MINIMUM_VOTE_LIFETIME	15 MINUTES
/datum/poll/evac
	choice_types = list(/datum/vote_choice/evac, /datum/vote_choice/noevac)
	only_admin = FALSE
	can_revote = TRUE
	can_unvote = TRUE


/datum/poll/evac/get_vote_power(var/client/C)
	if (!istype(C))
		return 0 //Shouldnt be possible, but safety

	var/mob/M = C.mob
	if (!M || isghost(M) || isnewplayer(M) || ismouse(M) || isdrone(M))
		return VOTE_WEIGHT_LOW

	var/datum/mind/mind = M.mind
	if (!mind)
		//If you don't have a mind in your mob, you arent really alive
		return VOTE_WEIGHT_LOW

	//Antags control the story of the round, they should be able to delay evac in order to enact their
	//fun and interesting plans
	if (player_is_antag(mind))
		return VOTE_WEIGHT_HIGH

	//How long has this player been alive
	//This comes after the antag check because that's more important
	var/lifetime = world.time - mind.creation_time
	if (lifetime <= MINIMUM_VOTE_LIFETIME)
		//If you just spawned for the vote, your weight is still low
		return VOTE_WEIGHT_LOW


	//Heads of staff are in a better position to understand the state of the ship and round,
	//their vote is more important.
	//This is after the lifetime check to prevent exploits of instaspawning as a head when a vote is called
	if (M.is_head_role())
		return VOTE_WEIGHT_HIGH



	//If we get here, its just a normal player who's been playing for at least 15 minutes. Normal weight
	return VOTE_WEIGHT_NORMAL

#undef VOTE_WEIGHT_LOW
#undef VOTE_WEIGHT_NORMAL
#undef VOTE_WEIGHT_HIGH
#undef MINIMUM_VOTE_LIFETIME

/datum/vote_choice/evac
	text = "Initiate a bluespace jump!"

/datum/vote_choice/evac/on_win()
	evacuation_controller.call_evacuation(null, FALSE, TRUE, FALSE, TRUE)

/datum/vote_choice/noevac
	text = "No need to depart yet!"





/datum/poll/custom
	name = "Custom"
	question = "Why is there no text here?"
	time = 60
	choice_types = list()

	only_admin = TRUE

	multiple_votes = TRUE
	can_revote = TRUE
	can_unvote = FALSE

	see_votes = TRUE

/datum/poll/custom/init_choices()
	multiple_votes = FALSE
	can_revote = TRUE
	can_unvote = FALSE
	see_votes = TRUE

	question = input("What's your vote question?","Custom vote","Custom vote question")

	var/choice_text = ""
	var/ch_num = 1
	do
		choice_text = input("Vote choice [ch_num]. Type nothing to stop.","Custom vote","")
		ch_num += 1
		if(choice_text != "")
			var/datum/vote_choice/custom/C = new
			C.text = choice_text
			choices.Add(C)
	while(choice_text != "" && ch_num < 10)

	if(alert("Should the voters be able to vote multiple options?","Custom vote","Yes","No") == "Yes")
		multiple_votes = TRUE

	if(alert("Should the voters be able to change their choice?","Custom vote","Yes","No") == "No")
		can_revote = FALSE

	if(alert("Should the voters be able to remove their votes?","Custom vote","Yes","No") == "Yes")
		can_unvote = TRUE

	if(alert("Should the voters see another voters votes?","Custom vote","Yes","No") == "No")
		see_votes = FALSE

	if(alert("Are you sure you want to continue?","Custom vote","Yes","No") == "No")
		choices.Cut()

/datum/vote_choice/custom
	text = "Vote choice"

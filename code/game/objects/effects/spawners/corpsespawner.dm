//These are meant for spawning on maps, namely Away Missions.

//If someone can do this in a neater way, be my guest-Kor

//To do: Allow corpses to appear mangled, bloody, etc. Allow customizing the bodies appearance (they're all bald and white right now).

/obj/landmark/corpse
	name = "Corpse Spawner"
	icon_state = "player-black"
	var/mobname = "Unknown"  //Unused now but it'd fuck up maps to remove it now
	var/corpseuniform //Set this to an object path to have the slot filled with said object on the corpse.
	var/corpsesuit
	var/corpseshoes
	var/corpsegloves
	var/corpseradio
	var/corpseglasses
	var/corpsemask
	var/corpsehelmet
	var/corpsebelt
	var/corpsepocket1
	var/corpsepocket2
	var/corpseback
	var/corpseid = 0     //Just set to 1 if you want them to have an ID
	var/corpseidjob // Needs to be in quotes, such as "Clown" or "Chef." This just determines what the ID reads as, not their access
	var/corpseidaccess //This is for access. See access.dm for which jobs give what access. Again, put in quotes. Use "Captain" if you want it to be all access.
	var/species = SPECIES_HUMAN

/obj/landmark/corpse/Initialize()
	..()
	createCorpse()
	return INITIALIZE_HINT_QDEL

/obj/landmark/corpse/proc/createCorpse() //Creates a mob and checks for gear in each slot before attempting to equip it.
	var/mob/living/carbon/human/M = new /mob/living/carbon/human(get_turf(src), species)
	M.real_name = mobname // you fucking pepega we have mobname for a reason
	M.death(TRUE) //Kills the new mob
	if(src.corpseuniform)
		M.equip_to_slot_or_del(new src.corpseuniform(M), slot_w_uniform)
	if(src.corpsesuit)
		M.equip_to_slot_or_del(new src.corpsesuit(M), slot_wear_suit)
	if(src.corpseshoes)
		M.equip_to_slot_or_del(new src.corpseshoes(M), slot_shoes)
	if(src.corpsegloves)
		M.equip_to_slot_or_del(new src.corpsegloves(M), slot_gloves)
	if(src.corpseradio)
		M.equip_to_slot_or_del(new src.corpseradio(M), slot_l_ear)
	if(src.corpseglasses)
		M.equip_to_slot_or_del(new src.corpseglasses(M), slot_glasses)
	if(src.corpsemask)
		M.equip_to_slot_or_del(new src.corpsemask(M), slot_wear_mask)
	if(src.corpsehelmet)
		M.equip_to_slot_or_del(new src.corpsehelmet(M), slot_head)
	if(src.corpsebelt)
		M.equip_to_slot_or_del(new src.corpsebelt(M), slot_belt)
	if(src.corpsepocket1)
		M.equip_to_slot_or_del(new src.corpsepocket1(M), slot_r_store)
	if(src.corpsepocket2)
		M.equip_to_slot_or_del(new src.corpsepocket2(M), slot_l_store)
	if(src.corpseback)
		M.equip_to_slot_or_del(new src.corpseback(M), slot_back)

	var/datum/job/jobdatum = corpseidjob && SSjob.GetJob(corpseidjob)
	if(jobdatum)
		jobdatum.equip(M)

	if(src.corpseid)
		var/datum/job/job_access = jobdatum
		if(corpseidaccess)
			job_access = SSjob.GetJob(corpseidaccess)
		var/obj/item/weapon/card/id/W = new(M)
		if(job_access)
			W.access = job_access.get_access()
		else
			W.access = list()
		W.assignment = corpseidjob
		M.set_id_info(W)
		M.equip_to_slot_or_del(W, slot_wear_id)



// I'll work on making a list of corpses people request for maps, or that I think will be commonly used. Syndicate operatives for example.





/obj/landmark/corpse/syndicatesoldier
	name = "Syndicate Operative"
	corpseuniform = /obj/item/clothing/under/syndicate
	corpsesuit = /obj/item/clothing/suit/armor/vest
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpsegloves = /obj/item/clothing/gloves/security
	corpseradio = /obj/item/device/radio/headset
	corpsemask = /obj/item/clothing/mask/gas
	corpsehelmet = /obj/item/clothing/head/armor/helmet
	corpseback = /obj/item/weapon/storage/backpack
	corpseid = 1
	corpseidjob = "Operative"
	corpseidaccess = "Syndicate"



/obj/landmark/corpse/syndicatecommando
	name = "Syndicate Commando"
	corpseuniform = /obj/item/clothing/under/syndicate
	corpsesuit = /obj/item/clothing/suit/space/void/merc
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpsegloves = /obj/item/clothing/gloves/security
	corpseradio = /obj/item/device/radio/headset
	corpsemask = /obj/item/clothing/mask/gas/syndicate
	corpseback = /obj/item/weapon/tank/jetpack/oxygen
	corpsepocket1 = /obj/item/weapon/tank/emergency_oxygen
	corpseid = 1
	corpseidjob = "Operative"
	corpseidaccess = "Syndicate"



///////////Civilians//////////////////////

/obj/landmark/corpse/chef
	name = "Chef"
	corpseuniform = /obj/item/clothing/under/rank/chef
	corpsesuit = /obj/item/clothing/suit/chef
	corpseshoes = /obj/item/clothing/shoes/reinforced
	corpseradio = /obj/item/device/radio/headset
	corpsehelmet = /obj/item/clothing/head/chefhat
	corpseid = 1
	corpseidjob = "Chef"

/obj/landmark/corpse/doctor
	name = "Medical doctor"
	corpseuniform = /obj/item/clothing/under/rank/medical
	corpseshoes = /obj/item/clothing/shoes/reinforced
	corpseradio = /obj/item/device/radio/headset
	corpsepocket1 = /obj/item/device/lighting/toggleable/flashlight/pen
	corpsebelt = /obj/item/weapon/storage/belt/medical/
	corpseid = 1
	corpseidjob = "Medical doctor"

/obj/landmark/corpse/engineer
	name = "Technomancer"
	corpseid = 1
	corpseidjob = "Technomancer"

/obj/landmark/corpse/engineer/rig
	corpsesuit = /obj/item/clothing/suit/space/void/engineering
	corpsemask = /obj/item/clothing/mask/breath

/obj/landmark/corpse/clown
	name = "Clown"
	corpseuniform = /obj/item/clothing/under/rank/clown
	corpseshoes = /obj/item/clothing/shoes/clown_shoes
	corpseradio = /obj/item/device/radio/headset
	corpsemask = /obj/item/clothing/mask/gas/clown_hat
	corpsepocket1 = /obj/item/weapon/bikehorn
	corpseback = /obj/item/weapon/storage/backpack/clown
	corpseid = 1
	corpseidjob = "Clown"
	//corpseidaccess = "Clown" //not exist

/obj/landmark/corpse/scientist
	name = "Scientist"
	corpseuniform = /obj/item/clothing/under/rank/scientist
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpseradio = /obj/item/device/radio/headset
	corpsesuit = /obj/item/clothing/suit/storage/toggle/labcoat/science
	corpseid = 1
	corpseidjob = "Scientist"

/obj/landmark/corpse/miner
	name = "Guild Miner"
	corpseid = 1
	corpseidjob = "Guild Miner"

/obj/landmark/corpse/miner/rig
	corpsesuit = /obj/item/clothing/suit/space/void/mining
	corpsemask = /obj/item/clothing/mask/breath


/////////////////Officers//////////////////////

/obj/landmark/corpse/bridgeofficer
	name = "Bridge Officer"
	corpseradio = /obj/item/device/radio/headset
	corpseuniform = /obj/item/clothing/under/rank/first_officer
	corpsesuit = /obj/item/clothing/suit/armor/bulletproof
	corpseshoes = /obj/item/clothing/shoes/color/black
	corpseglasses = /obj/item/clothing/glasses/sunglasses
	corpseid = 1
	corpseidjob = "Bridge Officer"
	// corpseidaccess = "Captain"  // No reason for them to have all access on Eris

/obj/landmark/corpse/commander
	name = "Commander"
	corpseuniform = /obj/item/clothing/under/rank/first_officer
	corpsesuit = /obj/item/clothing/suit/armor/bulletproof
	corpseradio = /obj/item/device/radio/headset/heads/captain
	corpseglasses = /obj/item/clothing/glasses/eyepatch
	corpsemask = /obj/item/clothing/mask/smokable/cigarette/cigar/cohiba
	corpsehelmet = /obj/item/clothing/head/centhat
	corpsegloves = /obj/item/clothing/gloves/security
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpsepocket1 = /obj/item/weapon/flame/lighter/zippo
	corpseid = 1
	corpseidjob = "Commander"
	// corpseidaccess = "Captain"  // No reason for them to have all access on Eris


/////////////////Enemies//////////////////////

/obj/landmark/corpse/pirate
	name = "Pirate"
	corpseuniform = /obj/item/clothing/under/pirate
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpseglasses = /obj/item/clothing/glasses/eyepatch
	corpsehelmet = /obj/item/clothing/head/bandana



/obj/landmark/corpse/pirate/ranged
	name = "Pirate Gunner"
	corpsesuit = /obj/item/clothing/suit/pirate
	corpsehelmet = /obj/item/clothing/head/pirate



/obj/landmark/corpse/russian
	name = "Russian"
	corpseuniform = /obj/item/clothing/under/soviet
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpsehelmet = /obj/item/clothing/head/bearpelt

/obj/landmark/corpse/russian/ranged
	corpsehelmet = /obj/item/clothing/head/ushanka

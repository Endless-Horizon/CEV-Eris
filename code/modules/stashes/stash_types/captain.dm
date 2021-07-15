/*
	This category is for scenarios where a captain dies and their effects can be found.
	Can also contain the special items of other heads of staff
*/
/datum/stash/command
	base_type = /datum/stash/command
	loot_type = "Command"
	directions = DIRECTION_LANDMARK
	contents_list_base = list(/obj/item/clothing/under/rank/captain = 1,
	/obj/item/clothing/gloves/captain = 1)
	contents_list_extra = list()
	contents_list_random = list(/obj/item/clothing/head/space/capspace = 70,
	/obj/item/clothing/suit/space/captain = 70,
	/obj/item/tank/jetpack/oxygen = 55,
	/obj/item/tool/chainofcommand = 65,
	/obj/item/reagent_containers/food/drinks/flask = 50,
	/obj/item/gun/energy/captain = 65,
	/obj/item/card/id/captains_spare = 10,
	/obj/item/clothing/under/captainformal = 65,
	/obj/item/clothing/head/caphat/formal = 65,
	/obj/item/device/radio/headset/heads/captain = 40,
	/obj/item/bedsheet/captain = 30,
	/obj/item/storage/backpack/satchel/captain = 40,
	/obj/item/clothing/mask/smokable/cigarette/cigar/havana = 15,
	/obj/item/modular_computer/tablet/lease/preset/command = 25,
	/obj/item/stamp/captain = 35,
	/obj/item/disk/nuclear = 15,
	/obj/item/hand_tele = 25,
	/obj/item/bluespace_harpoon = 15,
	/obj/item/reagent_containers/hypospray = 15,
	/obj/item/hatton = 15,
	/obj/item/rcd = 15,
	/obj/item/melee/telebaton = 15,
	/obj/item/clothing/suit/armor/greatcoat = 15)
	weight = 0.2


/datum/stash/command/kismet
	contents_list_external = list(/obj/item/remains/human = 1)
	lore = "A hundred thousand credits of education fallen to a ten cent rubber bullet to the temple.<br>\
<br>\
 Kismet, my captain.<br>\
 You were too vainglorious for anything but that damned fine hat. As for your effects, the mutineers won't have them.<br>\
<br>\
 Lest I forget, %D"

/datum/stash/command/mutiny
 	lore = "Killed that tee-totaling bastard good, we did.<br>\
<br>\
 Teach him to cut the rum ration. Like how rowdy we were now ya screaming pig?<br>\
<br>\
 The boys took his shit off him and we'll sort it out later, once we pretend the good stuff was missing after we divvy with the crew.<br>\
 Keeping it here to be safe. %D"


/datum/stash/command/pirateslave
	lore = "Typical merchant. Security consisted of a bunch of overcompensating wifebeaters who couldn't face a man's fist to the jaw.<br>\
<br>\
 We've divvied up the new slaves, old hands getting first pick. Pirate code.<br>\
 A lot sold them. But I? Pirate skippers get first pick. <br>\
<br>\
And who better than that haughty thing in a dress uniform. Think I'll stick her here until the party dies down %D.<br>\
<br>\
 I'll play the savior being all protective. We'll come to an arrangement."


/datum/stash/command/aloof
	contents_list_external = list(/obj/item/remains/human = 1)
	lore = "Aloof!<br>\
<br>\
 Of all the things to call me, a Star-lord and Elector-count, aloof!<br>\
 I will have them know I am neither aloof, nor foolish, nor hare-brained, nor all the other petty little words they call me!<br>\
 I will let them call me tyrant and monster! <br>\
<br>\
First, I will put the accouterments of my ship somewhere safe. Then, I shall roam among the swine and take names of the ringleaders.<br>\
 Lastly, the airlocks will need to be waxed down, extra slick. Oh. But I admit, I can be prone to slips of the mind.<br>\
<br>\
%D, and godspeed my return."


/datum/stash/command/surgery
	lore = "We ran out of pay.<br>\
<br>\
 This happens. This happened last time.<br>\
 I gave the order for double spirits and told the surgeon where to meet.<br>\
<br>\
 All I have to do is get my face rearranged a little, maybe replace my leg augs to be a little shorter. Put on some overalls and turn a wrench for a few months.<br>\
 Get my credentials back when its time to talk to the salvage yard. <br>\
<br>\
Remember this spot when the anesthetic wears off<br>\
<br>\
 %D;<br>\
 <br>\
 don't go stumbling around for a week like last time. "
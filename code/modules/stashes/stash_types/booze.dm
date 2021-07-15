/datum/stash/booze
	base_type = /datum/stash/booze
	loot_type = "Booze"
	contents_list_base = list(/obj/spawner/booze = 10, /obj/spawner/booze/low_chance = 10, /obj/spawner/credits/c1000 = 1)

/*
/datum/stash/booze/distillers
	story_type = STORY_CRIME
	directions = DIRECTION_IMAGE
	contents_list_random = list(/obj/spawner/pack/rare = 30,
	/obj/spawner/pack/rare = 30,
	/obj/spawner/lowkeyrandom = 40,
	/obj/spawner/lowkeyrandom = 40,
	/obj/spawner/lowkeyrandom = 40,
	/obj/spawner/credits/c1000 = 50,
	/obj/spawner/credits/c1000 = 50)
	lore = "My best swindle yet. After my boys got roaring drunk and tore up the bar for the\
	 \"last damned time\",old skipper closed it all down.<br>\
	 <br>\
 Well now the cookie and I are scraping the applesauce nobody seems to eat anymore into a bucket. Off its all going to the still my boys run. <br>\
Best part? Crew gives us both the sugar and pays in stolen junk. <br>\
<br>\
Now, just in case this rocket juice blacks me out again, its here, you dumbass. %D"
*/

/datum/stash/booze/distillers
	story_type = STORY_CRIME
	lore = "Heya sugar. The captain's shut down my bar, but no worries boys, Jane's got you covered.<br>\
<br>\
 I've been preparing for this ta happen for a while, and have a nice little stash saved up. I'll be running a little private bar at %D.<br>\
 <br>\
 Bring your friends, if you can trust 'em. Be careful who you give my info out to. And bring your credits too, prices have naturally doubled under the circumstances."
	contents_list_random = list(/obj/spawner/credits/c1000 = 70,
/obj/spawner/credits/c1000 = 70,
/obj/spawner/credits/c1000 = 70)

/datum/stash/booze/teenage_girls
	story_type = STORY_CRIME
	contents_list_extra = list(/obj/item/haircomb = 1, /obj/item/lipstick/random = 2)
	contents_list_random = list(/obj/item/reagent_containers/syringe/drugs = 50,
	/obj/item/reagent_containers/syringe/drugs = 50,
	/obj/item/reagent_containers/syringe/drugs_recreational = 50,
	/obj/item/reagent_containers/syringe/drugs_recreational = 50)
	lore = "Ugh my mom is being such a pain, i'm grounded in our quarters for a few days.<br>\
 But fuck her, once I get out, we're gonna have a party. I've been stealing some stuff from my dad's bar and stashing it away at %D.<br>\
I'll try to sneak out through maintenance tomorrow night, meet me there. And Jenna, bring some boys!"

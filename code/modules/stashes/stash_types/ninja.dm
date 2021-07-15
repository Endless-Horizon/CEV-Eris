/*
	Ninja Gear
	Foreshadowing a future and past antag
	Contains tons of stealthy gear
*/
/datum/stash/ninja
	base_type = /datum/stash/ninja
	weight = 0.2
	nonmaint_reroll = 100
	contents_list_base = list(/obj/item/storage/box/smokes)
	contents_list_random = list(

		/obj/item/storage/box/anti_photons = 60,
		/obj/item/gun/projectile/mandella = 50)

/datum/stash/ninja/haiku
	lore = "Swift electric ghost<br>\
 Yakuza of cold lightning<br>\
 Hide stars underfoot<br>\
%D"

/datum/stash/ninja/seppuku
	contents_list_external = list(/obj/item/remains/human = 1)
	lore = "My mission has failed, and I have brought dishonour upon the clan.<br>\
	Worse still, my suit has malfunctioned, the self destruct module will not activate.<br>\
	I am crippled, unable to walk, and soldiers hunt for me all over the ship. I cannot even crawl to an airlock.<br>\
	Our technology must remain hidden, death in battle is not an option.<br>\
	My only remaining recourse is to hide in the darkest corner I can find, and die with some semblance of honour. %D<br>\
	If you, reader are not of our clan, then I ask one final favour. Destroy everything you find with my body. Erase my existence from history"
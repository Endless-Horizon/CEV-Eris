/*
	Excelsior Stashes:
	Contain a wide variety of excelsior gear, allowing people to organically find them and join the cause
	Also useful to established excelsior for more stuff
*/
/datum/stash/excelsior
	base_type = /datum/stash/excelsior
	loot_type = "Excelsior"
	nonmaint_reroll = 100
	contents_list_base = list(/obj/item/electronics/circuitboard/excelsiorautolathe = 1,
	 /obj/item/implanter/excelsior/broken = 2)

	contents_list_random = list(/obj/item/implantcase/excelsior/broken = 70,
	/obj/item/implantcase/excelsior/broken = 40,
	/obj/item/clothing/suit/space/void/excelsior = 70,
	/obj/item/gun/projectile/automatic/ak47 = 30,
	/obj/item/gun/projectile/automatic/ak47 = 30,
	/obj/item/ammo_magazine/lrifle = 50,
	/obj/item/ammo_magazine/lrifle = 50
	)
	weight = 0.5

/datum/stash/excelsior/shipyard
	lore = "Our comrades in the shipyard planted the seeds of Revolution aboard this vessel during her refitting.<br>\
 Infiltrator, secure this cache and seize the means of production before it is found by chance. Its location is %D"

/*
/datum/stash/excelsior/legacy
	directions = DIRECTION_IMAGE
	contents_list_external = list(/obj/item/remains/human = 1)//He died near his stash
	lore = "Comrade, the means of production have been concealed aboard this ship by a prior agent.<br>\
  He was insufficiently capable to complete the revolution, although loyal enough to conceal it at the cost of his life.<br>\
  Seek out our cache and hope it has not been discovered. The last visual capture received over his implant places it here.<br>\
 %D"
*/
/datum/stash/excelsior/lastmessage
	lore = "Comrade, I have been discovered before beginning the Revolution.<br>\
  My misfortune is nothing in the scheme of our progress.<br>\
  The cache remains at %D with all of the required tools still there for your use.<br>\
  Send my regards to the Committee and I hope to pull a few pigs out the airlock with me."


/datum/stash/excelsior/lastmessage
	lore = "Some months ago a comrade was entrusted to establish the Revolution aboard this vessel, but she has not reported success.<br>\
  It appears the excesses of uncollectivized life broke her will for struggle, and so she was dispatched by another agent.<br>\
  Her cache, however, remained undetected. Proceed to %D and collect it, recalling for yourself the price of disloyalty."

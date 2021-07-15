#define CASH_PER_STAT 5000 // The cost of a single level of a statistic

/obj/item/spacecash
	name = "0 credit"
	desc = "It's worth 0 credits."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "spacecash1"
	opacity = 0
	density = FALSE
	anchored = FALSE
	force = 1
	throwforce = 1
	throw_speed = 1
	throw_range = 2
	w_class = ITEM_SIZE_SMALL
	bad_type = /obj/item/spacecash
	spawn_tags = null
	var/access = list()
	access = access_crate_cash
	var/worth = 0

/obj/item/spacecash/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/spacecash))
		if(istype(W, /obj/item/spacecash/ewallet))
			return FALSE

		var/obj/item/spacecash/bundle/bundle
		if(!istype(W, /obj/item/spacecash/bundle))
			var/obj/item/spacecash/cash = W
			user.drop_from_inventory(cash)
			bundle = new (src.loc)
			bundle.worth += cash.worth
			qdel(cash)
		else //is bundle
			bundle = W
		bundle.worth += src.worth
		bundle.update_icon()
		if(ishuman(user))
			var/mob/living/carbon/human/h_user = user
			h_user.drop_from_inventory(src)
			h_user.drop_from_inventory(bundle)
			h_user.put_in_hands(bundle)
		to_chat(user, SPAN_NOTICE("You add [src.worth] credits worth of money to the bundles.<br>It holds [bundle.worth] credits now."))
		qdel(src)

/obj/item/spacecash/Destroy()
	. = ..()
	worth = 0		// Prevents money from be duplicated anytime.

/obj/item/spacecash/bundle
	name = "pile of credits"
	icon_state = ""
	desc = "They are worth 0 credits."
	worth = 0

/obj/item/spacecash/bundle/on_update_icon()
	cut_overlays()
	var/sum = src.worth
	var/num = 0
	var/list/denominations = list(1000,500,200,100,50,20,10,1)
	for(var/i in denominations)
		while(sum >= i && num < 50)
			sum -= i
			num++
			var/image/banknote = image('icons/obj/items.dmi', "spacecash[i]")
			var/matrix/M = matrix()
			M.Translate(rand(-6, 6), rand(-4, 8))
			M.Turn(pick(-45, -27.5, 0, 0, 0, 0, 0, 0, 0, 27.5, 45))
			banknote.transform = M
			src.add_overlays(banknote)
	if(num == 0) // Less than one credit, let's just make it look like 1 for ease
		var/image/banknote = image('icons/obj/items.dmi', "spacecash1")
		var/matrix/M = matrix()
		M.Translate(rand(-6, 6), rand(-4, 8))
		M.Turn(pick(-45, -27.5, 0, 0, 0, 0, 0, 0, 0, 27.5, 45))
		banknote.transform = M
		src.add_overlays(banknote)
	src.desc = "They are worth [worth] credits."
	if(worth in denominations)
		src.name = "[worth] credit"
	else
		src.name = "pile of credits"

/obj/item/spacecash/bundle/attack_self()
	var/amount = input(usr, "How many credits do you want to take? (0 to [src.worth])", "Take Money", 20) as num
	amount = round(CLAMP(amount, 0, src.worth))
	if(amount==0) return 0
	else if(!Adjacent(usr))
		to_chat(usr, SPAN_WARNING("You need to be in arm's reach for that!"))
		return

	src.worth -= amount
	src.update_icon()
	if(!worth)
		usr.drop_from_inventory(src)
		qdel(src)
	if(amount in list(1000,500,200,100,50,20,1))
		var/cashtype = text2path("/obj/item/spacecash/bundle/c[amount]")
		var/obj/cash = new cashtype (usr.loc)
		usr.put_in_hands(cash)
	else
		var/obj/item/spacecash/bundle/bundle = new (usr.loc)
		bundle.worth = amount
		bundle.update_icon()
		usr.put_in_hands(bundle)

/obj/item/spacecash/bundle/Initialize()
	. = ..()
	AddComponent(/datum/component/inspiration, CALLBACK(src, .proc/return_stats))

/// Returns a list to use with inspirations. It can be empty if there's not enough money in the bundle. Important side-effects: converts worth to points, thus reducing worth.
/obj/item/spacecash/bundle/proc/return_stats()
	RETURN_TYPE(/list)
	var/points = min(worth/CASH_PER_STAT, 10) // capped at 10 points per bundle, costs 50k
	var/list/stats = list()
	// Distribute points evenly with random statistics. Just skips the loop if there's not enough money in the bundle, resulting in an empty list.
	while(points > 0)
		stats[pick(ALL_STATS)] += 1 // Picks a random stat, if not present it adds it with a value of 1, else it increases the value by 1
		points--
	worth -= points*CASH_PER_STAT
	update_icon()
	if(!worth)
		qdel(src)
	return stats

/obj/item/spacecash/bundle/c1
	name = "1 credit"
	icon_state = "spacecash1"
	desc = "It's worth 1 credit."
	worth = 1

/obj/item/spacecash/bundle/c10
	name = "10 credits"
	icon_state = "spacecash10"
	desc = "It's worth 10 credits."
	worth = 10

/obj/item/spacecash/bundle/c20
	name = "20 credits"
	icon_state = "spacecash20"
	desc = "It's worth 20 credits."
	worth = 20

/obj/item/spacecash/bundle/c50
	name = "50 credits"
	icon_state = "spacecash50"
	desc = "It's worth 50 credits."
	worth = 50

/obj/item/spacecash/bundle/c100
	name = "100 credits"
	icon_state = "spacecash100"
	desc = "It's worth 100 credits."
	worth = 100

/obj/item/spacecash/bundle/c200
	name = "200 credits"
	icon_state = "spacecash200"
	desc = "It's worth 200 credits."
	worth = 200

/obj/item/spacecash/bundle/c500
	name = "500 credits"
	icon_state = "spacecash500"
	desc = "It's worth 500 credits."
	worth = 500

// exists here specifically for vagabond since they do not have bank accounts and used to have around 800 credits.
/obj/item/spacecash/bundle/vagabond
	name = "pile of credits"
	icon_state = "spacecash500"

/obj/item/spacecash/bundle/vagabond/Initialize()
	var/rand_amount = rand(700,900)
	desc = "They are worth [rand_amount] credits."
	worth = rand_amount
	. = ..()

/obj/item/spacecash/bundle/c1000
	name = "1000 credits"
	icon_state = "spacecash1000"
	desc = "It's worth 1000 credits."
	worth = 1000

proc/spawn_money(var/sum, spawnloc, mob/living/carbon/human/human_user)
	if(sum in list(1000,500,200,100,50,20,10,1))
		var/cash_type = text2path("/obj/item/spacecash/bundle/c[sum]")
		var/obj/cash = new cash_type (usr.loc)
		if(ishuman(human_user) && !human_user.get_active_hand())
			human_user.put_in_hands(cash)
	else
		var/obj/item/spacecash/bundle/bundle = new(spawnloc)
		bundle.worth = sum
		bundle.update_icon()
		if(ishuman(human_user) && !human_user.get_active_hand())
			human_user.put_in_hands(bundle)
	return

/obj/item/spacecash/ewallet
	name = "Charge card"
	icon_state = "efundcard"
	desc = "A card that holds an amount of money."
	var/owner_name = "" //So the ATM can set it so the EFTPOS can put a valid name on transactions.

/obj/item/spacecash/ewallet/examine(mob/user)
	..(user)
	if(!(user in view(2)) && user!=src.loc) return
	to_chat(user, "\blue Charge card's owner: [src.owner_name]. Credits remaining: [src.worth].")

#undef CASH_PER_STAT

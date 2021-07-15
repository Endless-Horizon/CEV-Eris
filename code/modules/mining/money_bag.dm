/*****************************Money bag********************************/

/obj/item/moneybag
	icon = 'icons/obj/storage.dmi'
	name = "Money bag"
	icon_state = "moneybag"
	flags = CONDUCT
	force = 10
	throwforce = 2
	w_class = ITEM_SIZE_BULKY

/obj/item/moneybag/attack_hand(user as mob)
	if (!is_held())
		return ..()
	var/amt_gold = 0
	var/amt_silver = 0
	var/amt_diamond = 0
	var/amt_iron = 0
	var/amt_plasma = 0
	var/amt_uranium = 0

	for (var/obj/item/coin/C in contents)
		if (istype(C,/obj/item/coin/diamond))
			amt_diamond++;
		if (istype(C,/obj/item/coin/plasma))
			amt_plasma++;
		if (istype(C,/obj/item/coin/iron))
			amt_iron++;
		if (istype(C,/obj/item/coin/silver))
			amt_silver++;
		if (istype(C,/obj/item/coin/gold))
			amt_gold++;
		if (istype(C,/obj/item/coin/uranium))
			amt_uranium++;

	var/dat = text("<b>The contents of the moneybag reveal...</b><br>")
	if (amt_gold)
		dat += text("Gold coins: [amt_gold] <A href='?src=\ref[src];remove=gold'>Remove one</A><br>")
	if (amt_silver)
		dat += text("Silver coins: [amt_silver] <A href='?src=\ref[src];remove=silver'>Remove one</A><br>")
	if (amt_iron)
		dat += text("Metal coins: [amt_iron] <A href='?src=\ref[src];remove=iron'>Remove one</A><br>")
	if (amt_diamond)
		dat += text("Diamond coins: [amt_diamond] <A href='?src=\ref[src];remove=diamond'>Remove one</A><br>")
	if (amt_plasma)
		dat += text("Plasma coins: [amt_plasma] <A href='?src=\ref[src];remove=plasma'>Remove one</A><br>")
	if (amt_uranium)
		dat += text("Uranium coins: [amt_uranium] <A href='?src=\ref[src];remove=uranium'>Remove one</A><br>")
	user << browse("[dat]", "window=moneybag")

/obj/item/moneybag/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/coin))
		var/obj/item/coin/C = W
		to_chat(user, "\blue You add the [C.name] into the bag.")
		usr.drop_item()
		contents += C
	if (istype(W, /obj/item/moneybag))
		var/obj/item/moneybag/C = W
		for (var/obj/O in C.contents)
			contents += O;
		to_chat(user, "\blue You empty the [C.name] into the bag.")
	return

/obj/item/moneybag/Topic(href, href_list)
	if(..())
		return 1
	usr.set_machine(src)
	if(href_list["remove"])
		var/obj/item/coin/COIN
		switch(href_list["remove"])
			if(MATERIAL_GOLD)
				COIN = locate(/obj/item/coin/gold,src.contents)
			if(MATERIAL_SILVER)
				COIN = locate(/obj/item/coin/silver,src.contents)
			if("iron")
				COIN = locate(/obj/item/coin/iron,src.contents)
			if(MATERIAL_DIAMOND)
				COIN = locate(/obj/item/coin/diamond,src.contents)
			if("plasma")
				COIN = locate(/obj/item/coin/plasma,src.contents)
			if(MATERIAL_URANIUM)
				COIN = locate(/obj/item/coin/uranium,src.contents)
		if(!COIN)
			return
		COIN.loc = src.loc
	return



/obj/item/moneybag/vault

/obj/item/moneybag/vault/New()
	..()
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/gold(src)
	new /obj/item/coin/gold(src)
/*****************************Coin********************************/

/obj/item/coin
	icon = 'icons/obj/items.dmi'
	name = COIN_STANDARD
	icon_state = "coin"
	flags = CONDUCT
	force = 0
	throwforce = 0
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	var/string_attached
	var/sides = 2

/obj/item/coin/Initialize(mapload)
	. = ..()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

/obj/item/coin/gold
	name = COIN_GOLD
	icon_state = "coin_gold"

/obj/item/coin/silver
	name = COIN_SILVER
	icon_state = "coin_silver"

/obj/item/coin/diamond
	name = COIN_DIAMOND
	icon_state = "coin_diamond"

/obj/item/coin/iron
	name = COIN_IRON
	icon_state = "coin_iron"

/obj/item/coin/plasma
	name = COIN_PLASMA
	icon_state = "coin_plasma"

/obj/item/coin/uranium
	name = COIN_URANIUM
	icon_state = "coin_uranium"

/obj/item/coin/platinum
	name = COIN_PLATINUM
	icon_state = "coin_adamantine"

/obj/item/coin/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = W
		if(string_attached)
			to_chat(user, SPAN_NOTICE("There already is a string attached to this coin."))
			return
		if (CC.use(1))
			add_overlays(image('icons/obj/items.dmi',"coin_string_overlay"))
			string_attached = 1
			to_chat(user, SPAN_NOTICE("You attach a string to the coin."))
		else
			to_chat(user, SPAN_NOTICE("This cable coil appears to be empty."))
		return
	else if(istype(W,/obj/item/tool/wirecutters))
		if(!string_attached)
			..()
			return

		new /obj/item/stack/cable_coil(user.loc, 1)
		set_overlays(list())
		string_attached = null
		to_chat(user, "\blue You detach the string from the coin.")
	else ..()

/obj/item/coin/attack_self(mob/user as mob)
	var/result = rand(1, sides)
	var/comment = ""
	if(result == 1)
		comment = "tails"
	else if(result == 2)
		comment = "heads"
	user.visible_message(SPAN_NOTICE("[user] has thrown \the [src]. It lands on [comment]! "), \
						 SPAN_NOTICE("You throw \the [src]. It lands on [comment]! "))

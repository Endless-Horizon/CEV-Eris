/obj/item/clothing/gloves/boxing
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon_state = "boxing"
	item_state = "boxing"
	armor = list(melee = 25, bullet = 0, energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/gloves/boxing/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/tool/wirecutters) || istype(W, /obj/item/tool/scalpel))
		to_chat(user, SPAN_NOTICE("That won't work."))	//Nope
		return
	..()

/obj/item/clothing/gloves/boxing/green
	icon_state = "boxinggreen"
	item_state = "boxinggreen"

/obj/item/clothing/gloves/boxing/blue
	icon_state = "boxingblue"
	item_state = "boxingblue"

/obj/item/clothing/gloves/boxing/yellow
	icon_state = "boxingyellow"
	item_state = "boxingyellow"

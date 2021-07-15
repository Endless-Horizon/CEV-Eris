// COLOR SHOES
/obj/item/clothing/shoes/color
	name = "shoes"
	initial_name = "shoes"
	desc = "A pair of shoes."
	icon_state = "white"
	cold_protection = LEGS
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = LEGS
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	bad_type = /obj/item/clothing/shoes/color

/obj/item/clothing/shoes/color/black
	name = "black shoes"
	icon_state = "black"

/obj/item/clothing/shoes/color/white
	name = "white shoes"
	icon_state = "white"

/obj/item/clothing/shoes/color/blue
	name = "blue shoes"
	initial_name = "blue shoes"
	icon_state = "blue"

/obj/item/clothing/shoes/color/green
	name = "green shoes"
	initial_name = "green shoes"
	icon_state = "green"

/obj/item/clothing/shoes/color/yellow
	name = "yellow shoes"
	initial_name = "yellow shoes"
	icon_state = "yellow"

/obj/item/clothing/shoes/color/purple
	name = "purple shoes"
	initial_name = "purple shoes"
	icon_state = "purple"

/obj/item/clothing/shoes/color/brown
	name = "brown shoes"
	initial_name = "brown shoes"
	icon_state = "brown"

/obj/item/clothing/shoes/color/red
	name = "red shoes"
	initial_name = "red shoes"
	desc = "Stylish red shoes."
	icon_state = "red"

/obj/item/clothing/shoes/color/rainbow
	name = "rainbow shoes"
	name = "rainbow shoes"
	desc = "Very gay shoes."
	icon_state = "rain_bow"

/obj/item/clothing/shoes/color/orange
	name = "orange shoes"
	initial_name = "orange shoes"
	icon_state = "orange"
	var/obj/item/handcuffs/chained = null

/obj/item/clothing/shoes/color/orange/proc/attach_cuffs(var/obj/item/handcuffs/cuffs, mob/user as mob)
	if (src.chained) return

	user.drop_item()
	cuffs.loc = src
	src.chained = cuffs
	src.slowdown = 15
	src.icon_state = "orange1"

/obj/item/clothing/shoes/color/orange/proc/remove_cuffs(mob/user as mob)
	if (!src.chained) return

	user.put_in_hands(src.chained)
	src.chained.add_fingerprint(user)

	src.slowdown = initial(slowdown)
	src.icon_state = "orange"
	src.chained = null

/obj/item/clothing/shoes/color/orange/attack_self(mob/user as mob)
	..()
	remove_cuffs(user)

/obj/item/clothing/shoes/color/orange/attackby(H as obj, mob/user as mob)
	..()
	if (istype(H, /obj/item/handcuffs))
		attach_cuffs(H, user)



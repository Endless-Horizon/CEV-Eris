/obj/item/dice
	name = "d6"
	desc = "A dice with six sides."
	icon = 'icons/obj/dice.dmi'
	icon_state = "d66"
	w_class = ITEM_SIZE_TINY
	attack_verb = list("diced")
	price_tag = 1
	spawn_tags = SPAWN_TAG_DICE
	var/sides = 6

/obj/item/dice/Initialize(mapload)
	. = ..()
	icon_state = "[name][rand(1,sides)]"

/obj/item/dice/d2
	name = "d2"
	desc = "A dice with two sides. Coins are undignified!"
	icon_state = "d2"
	sides = 2

/obj/item/dice/d4
	name = "d4"
	desc = "A dice with four sides. The nerd's caltrop."
	icon_state = "d44"
	sides = 4

/obj/item/dice/d8
	name = "d8"
	desc = "A dice with eight sides. It feels... lucky."
	icon_state = "d88"
	sides = 8

/obj/item/dice/d10
	name = "d10"
	desc = "A dice with ten sides. Useful for percentages."
	icon_state = "d1010"
	sides = 10

/obj/item/dice/d12
	name = "d12"
	desc = "A dice with twelve sides. There's an air of neglect about it."
	icon_state = "d1212"
	sides = 12

/obj/item/dice/d20
	name = "d20"
	desc = "A dice with twenty sides. The prefered dice to throw at the GM."
	icon_state = "d2020"
	sides = 20

/obj/item/dice/d100
	name = "d100"
	desc = "A dice with hundred sides. Can be used as a golfball."
	icon_state = "d10010"
	sides = 10

/*
Code below is works, but has duplication of a code.
Tryed to code it without duplication, but it doesn't worked.
Another builds like baystation12 also have a duplication.
*/

/obj/item/dice/attack_self(mob/user as mob)
	var/result = rand(1, sides)
	var/comment = ""
	if (result == 1 && sides == 20)
		comment = "Ouch, bad luck."
	else if (result == 20 && sides == 20)
		comment = "Nat 20!"
	icon_state = "[name][result]"
	user.visible_message(SPAN_NOTICE("[user] has thrown [src]. It lands on [result]. [comment]"), \
						 SPAN_NOTICE("You throw [src]. It lands on a [result]. [comment]"), \
						 SPAN_NOTICE("You hear [src] landing on a [result]. [comment]"))

/obj/item/dice/throw_impact(atom/hit_atom, var/speed)
	..()
	var/result = rand(1,sides)
	var/comment = ""
	if (result == 1 && sides == 20)
		comment = "Ouch, bad luck."
	else if (result == 20 && sides == 20)
		comment = "Nat 20!"
	icon_state = "[name][result]"
	src.visible_message(SPAN_NOTICE("\The [src] lands on [result]. [comment]"))

/obj/item/grenade/sonic
	name = "SG \"Loudmouth\""
	desc = "A hailer overclocked to reproduce a noise similar to the leading roaches."
	icon_state = "screamer"

/obj/item/grenade/sonic/prime()
	playsound(loc, 'sound/voice/shriek1.ogg', 100, 1, 8, 8)

	visible_message(SPAN_DANGER("\The [src] emits a horrifying wail!"))

	for (var/obj/structure/burrow/B in find_nearby_burrows(src))
		B.visible_message(SPAN_DANGER("\The [B] springs to life with interior motion!"))
		B.distress(TRUE)
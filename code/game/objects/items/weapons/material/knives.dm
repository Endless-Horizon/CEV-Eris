/obj/item/material/butterfly
	name = "butterfly knife"
	desc = "A basic metal blade concealed in a lightweight plasteel grip. Small enough when folded to fit in a pocket."
	icon_state = "butterflyknife"
	item_state = null
	hitsound = null
	var/active = 0
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("patted", "tapped")
	force_divisor = 0.25 // 15 when wielded with hardness 60 (steel)
	thrown_force_divisor = 0.25 // 5 when thrown with weight 20 (steel)
	structure_damage_factor = STRUCTURE_DAMAGE_BLADE

/obj/item/material/butterfly/update_force()
	if(active)
		edge = TRUE
		sharp = TRUE
		..() //Updates force.
		throwforce = max(3,force-3)
		hitsound = 'sound/weapons/bladeslice.ogg'
		icon_state += "_open"
		w_class = ITEM_SIZE_NORMAL
		tool_qualities = list(QUALITY_CUTTING = 20, QUALITY_WIRE_CUTTING = 10, QUALITY_SCREW_DRIVING = 5)
		attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	else
		force = WEAPON_FORCE_WEAK
		edge = FALSE
		sharp = FALSE
		hitsound = initial(hitsound)
		icon_state = initial(icon_state)
		w_class = initial(w_class)
		tool_qualities = list()
		attack_verb = initial(attack_verb)

/obj/item/material/butterfly/switchblade
	name = "switchblade"
	desc = "A classic switchblade with gold engraving. Just holding it makes you feel like a gangster."
	icon_state = "switchblade"
	unbreakable = 1

/obj/item/material/butterfly/attack_self(mob/user)
	active = !active
	if(active)
		to_chat(user, SPAN_NOTICE("You flip out \the [src]."))
		playsound(user, 'sound/weapons/flipblade.ogg', 15, 1)
	else
		to_chat(user, SPAN_NOTICE("\The [src] can now be concealed."))
	update_force()
	add_fingerprint(user)

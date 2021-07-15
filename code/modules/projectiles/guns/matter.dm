/obj/item/gun/matter
	bad_type = /obj/item/gun/matter
	var/max_stored_matter = 30
	var/stored_matter = 0
	var/matter_type

	var/projectile_cost = 1
	var/projectile_type

/obj/item/gun/matter/attackby(obj/item/I, mob/user)
	var/obj/item/stack/material/M = I
	if(istype(M) && M.material.name == matter_type)
		var/amount = min(M.get_amount(), round(max_stored_matter - stored_matter))
		if(M.use(amount))
			stored_matter += amount
		to_chat(user, "<span class='notice'>You load [amount] [matter_type] into \the [src].</span>")
	else
		..()

/obj/item/gun/matter/consume_next_projectile()
	if(stored_matter < projectile_cost)
		return null
	stored_matter -= projectile_cost
	return new projectile_type(src)

/obj/item/gun/matter/examine(user)
	. = ..()
	to_chat(user, "It holds [stored_matter]/[max_stored_matter] [matter_type].")

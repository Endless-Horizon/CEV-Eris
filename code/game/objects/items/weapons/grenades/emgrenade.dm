/obj/item/grenade/empgrenade
	name = "FS EMPG \"Frye\""
	desc = "EMP grenade, designed to disable electronics, augmentations and energy weapons."
	icon_state = "emp"
	item_state = "empgrenade"
	origin_tech = list(TECH_MATERIAL = 2, TECH_MAGNET = 3)

/obj/item/grenade/empgrenade/prime()
	..()
	if(empulse(src, 4, 10))
		icon_state = "emp_off"
		desc = "[initial(desc)] It has already been used."
	return

/obj/item/grenade/empgrenade/low_yield
	name = "FS EMPG \"Frye\" - C"
	desc = "A weaker variant of the \"Frye\" emp grenade, with lesser radius."
	icon_state = "lyemp"
	item_state = "empgrenade"
	origin_tech = list(TECH_MATERIAL = 2, TECH_MAGNET = 3)

/obj/item/grenade/empgrenade/low_yield/prime()
	..()
	if(empulse(src, 4, 1))
		icon_state = "emp_off"
		desc = "[initial(desc)] It has already been used."
	return

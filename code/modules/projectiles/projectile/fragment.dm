/obj/item/projectile/bullet/pellet/fragment
	damage_types = list(BRUTE = 10)
	range_step = 2
	embed = FALSE

	base_spread = 0 //causes it to be treated as a shrapnel explosion instead of cone
	spread_step = 20

	silenced = FALSE //embedding messages are still produced so it's kind of weird when enabled.
	no_attack_log = 1
	muzzle_type = null

/obj/item/projectile/bullet/pellet/fragment/strong
	damage_types = list(BRUTE = 15)

/obj/item/projectile/bullet/pellet/fragment/weak
	damage_types = list(BRUTE = 5)

/obj/item/projectile/bullet/pellet/fragment/invisible
	name = "explosion"
	icon_state = "invisible"
	embed = 0
	damage_types = list(BRUTE = 20)
	check_armour = ARMOR_BOMB

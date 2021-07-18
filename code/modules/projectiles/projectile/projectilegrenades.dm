/obj/item/projectile/bullet/batonround
	name = "baton round"
	icon_state = "grenade"
	damage_types = list(BRUTE = 10)
	agony = 80
	check_armour = ARMOR_MELEE
	armor_penetration = 0
	embed = FALSE
	sharp = FALSE

/obj/item/projectile/bullet/grenade
	name = "grenade shell"
	icon_state = "grenade"
	damage_types = list(BRUTE = 20)
	armor_penetration = 0
	embed = FALSE
	sharp = FALSE
	check_armour = ARMOR_BULLET

/obj/item/projectile/bullet/grenade/Move()	//Makes grenade shells cause their effect when they arrive at their target turf
	if(get_turf(src) == get_turf(original))
		grenade_effect(get_turf(src))
		qdel(src)
	else
		..()

/obj/item/projectile/bullet/grenade/on_hit(atom/target)	//Allows us to cause different effects for each grenade shell on hit
	grenade_effect(target)


/obj/item/projectile/bullet/grenade/
	name = "blast shell"
	var/devastation_range = 0
	var/heavy_impact_range = 0
	var/light_impact_range = 3
	var/flash_range = 10

/obj/item/projectile/bullet/grenade/proc/grenade_effect(target)
	explosion(target, devastation_range, heavy_impact_range, light_impact_range, flash_range)

/obj/item/projectile/bullet/grenade/frag
	name = "frag shell"
	var/range = 7
	var/f_type = /obj/item/projectile/bullet/pellet/fragment/strong
	var/f_amount = 50
	var/f_damage = 15
	var/f_penetration = 15
	var/f_step = 2
	var/same_turf_hit_chance = 15

/obj/item/projectile/bullet/grenade/frag/weak
	name = "frag shell"
	range = 7
	f_type = /obj/item/projectile/bullet/pellet/fragment/strong
	f_amount = 50
	f_damage = 15
	f_penetration = 10
	f_step = 1
	same_turf_hit_chance = 10

/obj/item/projectile/bullet/grenade/frag/grenade_effect(target)
	fragment_explosion(target, range, f_type, f_amount, f_damage, f_step, same_turf_hit_chance)

/obj/item/projectile/bullet/grenade/emp
	var/heavy_emp_range = 3
	var/light_emp_range = 8

/obj/item/projectile/bullet/grenade/emp/grenade_effect(target)
	empulse(target, heavy_emp_range, light_emp_range)

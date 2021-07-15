/obj/item/gun/energy/shrapnel
	name = "OR SDF \"Shellshock\" energy shotgun"
	desc = "An Oberth Republic Self Defence Force design, this mat-fab shotgun tends to burn through cells with use. The matter contained in empty cells can be converted directly into ammunition as well, if the safety bolts are loosened."
	icon = 'icons/obj/guns/energy/shrapnel.dmi'
	icon_state = "eshotgun"
	item_charge_meter = TRUE
	item_state = "eshotgun"
	charge_meter = TRUE
	w_class = ITEM_SIZE_HUGE
	force = WEAPON_FORCE_PAINFUL
	flags = CONDUCT
	slot_flags = SLOT_BACK
	origin_tech = list(TECH_COMBAT = 3, TECH_MAGNET = 2, TECH_ENGINEERING = 4)
	charge_cost = 25
	suitable_cell = /obj/item/cell/small
	cell_type = /obj/item/cell/small
	projectile_type = /obj/item/projectile/bullet/shotgun
	one_hand_penalty = 15 //full sized shotgun level
	fire_delay = 12 //Equivalent to a pump then fire time
	fire_sound = 'sound/weapons/guns/fire/energy_shotgun.ogg'
	init_firemodes = list(
		list(mode_name="Buckshot", mode_desc="Fires a buckshot synth-shell", projectile_type=/obj/item/projectile/bullet/pellet/shotgun, charge_cost=50, icon="kill"),
		list(mode_name="Grenade", mode_desc="Fires a frag synth-shell", projectile_type=/obj/item/projectile/bullet/grenade/frag/weak, charge_cost=10000, icon="grenade"),
		list(mode_name="Blast", mode_desc="Fires a slug synth-shell", projectile_type=/obj/item/projectile/bullet/shotgun, charge_cost=null, icon="destroy"),
	)
	price_tag = 2500
	spawn_tags = SPAWN_TAG_GUN_SHOTGUN_ENERGY
	twohanded = TRUE
	var/consume_cell = TRUE

/obj/item/gun/energy/shrapnel/consume_next_projectile()
	if(!cell) return null
	if(!ispath(projectile_type)) return null
	if(consume_cell && !cell.checked_use(charge_cost))
		visible_message(SPAN_WARNING("\The [cell] of \the [src] burns out!"))
		qdel(cell)
		cell = null
		playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
		new /obj/effect/decal/cleanable/ash(get_turf(src))
		return new projectile_type(src)
	else if(!consume_cell && !cell.checked_use(charge_cost))
		return null
	else
		return new projectile_type(src)

/obj/item/gun/energy/shrapnel/attackby(obj/item/I, mob/user)
	..()
	if(I.has_quality(QUALITY_BOLT_TURNING))
		if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, QUALITY_BOLT_TURNING, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
			if(consume_cell)
				consume_cell = FALSE
				to_chat(user, SPAN_NOTICE("You secure the safety bolts, preventing the weapon from destroying empty cells for use as ammuniton."))
			else
				consume_cell = TRUE
				to_chat(user, SPAN_NOTICE("You loosen the safety bolts, allowing the weapon to destroy empty cells for use as ammunition."))

/obj/item/gun/energy/shrapnel/mounted
	name = "SDF SC \"Schrapnell\""
	desc = "An energy-based shotgun, employing a matter fabricator to pull shotgun rounds from thin air and energy."
	icon_state = "shrapnel"
	self_recharge = TRUE
	use_external_power = TRUE
	safety = FALSE
	restrict_safety = TRUE
	consume_cell = FALSE
	cell_type = /obj/item/cell/small/high //Two shots
	spawn_blacklisted = TRUE
	charge_cost = 50
	twohanded = FALSE
	init_firemodes = list(
		list(mode_name="Buckshot", mode_desc="Fires a buckshot synth-shell", projectile_type=/obj/item/projectile/bullet/pellet/shotgun, charge_cost=100, icon="kill"),
		list(mode_name="Beanbag", mode_desc="Fires a beanbag synth-shell", projectile_type=/obj/item/projectile/bullet/shotgun/beanbag, charge_cost=25, icon="stun"),
		list(mode_name="Blast", mode_desc="Fires a slug synth-shell", projectile_type=/obj/item/projectile/bullet/shotgun, charge_cost=null, icon="destroy"),
	)

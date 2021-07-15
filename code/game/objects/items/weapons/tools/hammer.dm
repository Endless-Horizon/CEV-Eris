/obj/item/tool/hammer //needs new sprite
	name = "hammer"
	desc = "Used for applying blunt force to a surface."
	icon_state = "hammer"
	item_state = "hammer"
	force = WEAPON_FORCE_PAINFUL
	w_class = ITEM_SIZE_SMALL
	worksound = WORKSOUND_HAMMER
	flags = CONDUCT
	origin_tech = list(TECH_ENGINEERING = 1)
	tool_qualities = list(QUALITY_HAMMERING = 20, QUALITY_PRYING = 10)
	matter = list(MATERIAL_STEEL = 4, MATERIAL_WOOD = 2)
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked","flattened","pulped")
	rarity_value = 5

/obj/item/tool/hammer/homewrecker
	name = "homewrecker"
	desc = "A large steel chunk welded to a long handle which resembles a sledgehammer. Extremely heavy."
	icon_state = "homewrecker0"
	item_state = "homewrecker"
	wielded_icon = "homewrecker1"
	structure_damage_factor = STRUCTURE_DAMAGE_HEAVY
	armor_penetration = ARMOR_PEN_DEEP
	force_unwielded = WEAPON_FORCE_NORMAL
	force_wielded = WEAPON_FORCE_ROBUST
	slot_flags = SLOT_BELT|SLOT_BACK
	w_class = ITEM_SIZE_HUGE
	tool_qualities = list(QUALITY_HAMMERING = 15)
	matter = list(MATERIAL_STEEL = 15, MATERIAL_PLASTIC = 1)
	max_upgrades = 5
	spawn_tags = SPAWN_TAG_JUNKTOOL
	rarity_value = 32

/obj/item/tool/hammer/powered_hammer //to be made into proper two-handed tool as small "powered" hammer doesn't make sense
	name = "powered hammer"					//lacks normal sprites, both icon, item and twohanded for this
	desc = "Used for applying excessive blunt force to a surface. Powered edition."
	icon_state = "powered_hammer"
	item_state = "powered_hammer"
	structure_damage_factor = STRUCTURE_DAMAGE_BREACHING
	armor_penetration = ARMOR_PEN_DEEP
	force = WEAPON_FORCE_DANGEROUS
	w_class = ITEM_SIZE_HUGE
	tool_qualities = list(QUALITY_HAMMERING = 30)
	matter = list(MATERIAL_STEEL = 5, MATERIAL_PLASTEEL = 10, MATERIAL_PLASTIC = 1)
	degradation = 0.7
	use_power_cost = 2
	suitable_cell = /obj/item/cell/medium
	max_upgrades = 4
	rarity_value = 24

/obj/item/tool/hammer/powered_hammer/onestar_hammer
	name = "One Star sledgehammer"
	desc = "A sledgehammer model produced by One Star, used for applying immeasurable blunt force to anything in your way. Capable of breaching even the toughtest obstacles, and cracking the most resilient skulls."
	icon_state = "onehammer"
	item_state = "onehammer"
	wielded_icon = "onehammer_on"
	structure_damage_factor = STRUCTURE_DAMAGE_DESTRUCTIVE
	armor_penetration = ARMOR_PEN_EXTREME
	force_unwielded = WEAPON_FORCE_DANGEROUS
	force_wielded = WEAPON_FORCE_BRUTAL
	w_class = ITEM_SIZE_HUGE
	slot_flags = SLOT_BACK
	matter = list(MATERIAL_STEEL = 10, MATERIAL_PLATINUM = 5, MATERIAL_DIAMOND = 5)
	tool_qualities = list(QUALITY_HAMMERING = 50)
	degradation = 0.6
	use_power_cost = 1.5
	workspeed = 1.5
	max_upgrades = 2
	spawn_blacklisted = TRUE
	rarity_value = 10
	spawn_tags = SPAWN_TAG_OS_TOOL

/obj/item/tool/hammer/mace
	name = "mace"
	desc = "Used for applying blunt force trauma to a person's ribcage."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "mace"
	item_state = "mace"
	w_class = ITEM_SIZE_NORMAL
	armor_penetration = ARMOR_PEN_DEEP
	force = WEAPON_FORCE_DANGEROUS
	tool_qualities = list(QUALITY_HAMMERING = 20)
	spawn_tags = SPAWN_TAG_WEAPON
	rarity_value = 15
	structure_damage_factor = STRUCTURE_DAMAGE_BLUNT

/obj/item/tool/hammer/mace/makeshift
	name = "makeshift mace"
	desc = "Some metal attached to the end of a stick, for applying blunt force trauma to a roach."
	icon_state = "ghetto_mace"
	item_state = "ghetto_mace"
	force = WEAPON_FORCE_PAINFUL
	tool_qualities = list(QUALITY_HAMMERING = 15)
	degradation = 3 //This one breaks fast
	max_upgrades = 5 //all makeshift tools get more mods to make them actually viable for mid-late game
	rarity_value = 30
	spawn_tags = SPAWN_TAG_JUNKTOOL


/obj/item/tool/hammer/mace/makeshift/baseballbat
	name = "baseball bat"
	desc = "HOME RUN!"
	icon_state = "woodbat0"
	wielded_icon = "woodbat1"
	item_state = "woodbat0"
	force = WEAPON_FORCE_DANGEROUS
	armor_penetration = ARMOR_PEN_MODERATE
	attack_verb = list("smashed", "beaten", "slammed", "smacked", "struck", "battered", "bonked")
	hitsound = 'sound/weapons/genhit3.ogg'
	slot_flags = SLOT_BELT|SLOT_BACK

/obj/item/tool/hammer/mace/makeshift/baseballbat/bone
	name = "bone club"
	desc = "Seems like someone gave up an arm and a leg for this thing. And a head."
	icon_state = "bonemace"
	item_state = "bonemace"
	slot_flags = SLOT_BELT
	degradation = 1.5 //Something something bones are hard.
	spawn_blacklisted = TRUE

/obj/item/tool/hammer/charge
	name = "charge hammer"
	desc = "After many issues with scientists trying to hammer a nail, one bright individual wondered what could be achieved by attaching a stellar-grade ship engine to the back."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "chargehammer"
	item_state = "chargehammer"
	w_class = ITEM_SIZE_HUGE
	switched_on_force = WEAPON_FORCE_BRUTAL
	structure_damage_factor = STRUCTURE_DAMAGE_BREACHING
	switched_on_qualities = list(QUALITY_HAMMERING = 60)
	switched_off_qualities = list(QUALITY_HAMMERING = 35)
	toggleable = TRUE
	slot_flags = SLOT_BACK
	suitable_cell = /obj/item/cell/medium
	use_power_cost = 15
	rarity_value = 100
	spawn_frequency = 4
	var/datum/effect/effect/system/trail/T
	var/last_launch

/obj/item/tool/hammer/charge/New()
	..()
	T = new /datum/effect/effect/system/trail/fire()
	T.set_up(src)

/obj/item/tool/hammer/charge/Destroy()
	QDEL_NULL(T)
	return ..()

/obj/item/tool/hammer/charge/afterattack(atom/target, mob/user, proximity_flag, params)
	if(!switched_on || world.time < last_launch + 3 SECONDS)
		return
	var/cost = use_power_cost*get_dist(target, user)
	if(user.check_gravity())
		cost *= (user.mob_size/10)

	if(cell?.checked_use(cost))
		if(!wielded)
			var/drop_prob = 30
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				drop_prob *= H.stats.getMult(STAT_ROB, STAT_LEVEL_EXPERT)
			if(prob(drop_prob))
				to_chat(user, SPAN_WARNING("\The [src] launches from your grasp!"))
				user.drop_item(src)
				T.start()
				playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
				throw_at(target, get_dist(target, user), 1, user)
				T.stop()
				last_launch = world.time
				return
		last_launch = world.time
		T.start()
		playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
		user.throw_at(target, get_dist(target, user), 1, user)
		T.stop()

/obj/item/tool/hammer/IH
	name = "FS \"Ironhammer\" Breaching Hammer"
	desc = "A modified sledgehammer produced by Frozen Star for Ironhammer forces. This tool can take down standard walls and if the user is strong enough, reinforced walls."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "iron_hammer"
	item_state = "iron_hammer"
	wielded_icon = "iron_hammer_wielded"
	w_class = ITEM_SIZE_HUGE
	armor_penetration = ARMOR_PEN_DEEP
	force = WEAPON_FORCE_ROBUST
	structure_damage_factor = STRUCTURE_DAMAGE_BORING
	tool_qualities = list(QUALITY_HAMMERING = 40, QUALITY_PRYING = 1)
	matter = list(MATERIAL_STEEL = 15, MATERIAL_PLASTIC = 1, MATERIAL_PLASTEEL = 2)
	spawn_blacklisted = TRUE

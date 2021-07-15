//Warning! If you change icon_state or item_state, make sure you change path for sneath as well. icons/obj/sneath.dmi
/obj/item/tool/sword/nt
	name = "NT Shortsword"
	desc = "A saint looking sword, made to do God's work."
	icon = 'icons/obj/nt_melee.dmi'
	icon_state = "nt_shortsword"
	item_state = "nt_shortsword"
	force = WEAPON_FORCE_DANGEROUS
	throwforce = WEAPON_FORCE_WEAK
	armor_penetration = ARMOR_PEN_DEEP
	spawn_blacklisted = TRUE
	aspects = list(SANCTIFIED)
	price_tag = 300
	matter = list(MATERIAL_BIOMATTER = 25, MATERIAL_STEEL = 5)

/obj/item/tool/sword/nt/longsword
	name = "NT Longsword"
	desc = "A saint looking longsword, recommended by experianced crusaders."
	icon_state = "nt_longsword"
	item_state = "nt_longsword"
	force = WEAPON_FORCE_BRUTAL
	armor_penetration = ARMOR_PEN_EXTREME
	w_class = ITEM_SIZE_HUGE
	price_tag = 1200
	matter = list(MATERIAL_BIOMATTER = 75, MATERIAL_STEEL = 10, MATERIAL_PLASTEEL = 5, MATERIAL_DIAMOND = 1)


/obj/item/tool/knife/dagger/nt
	name = "NT Dagger"
	desc = "A saint looking dagger, even God have mercy."
	icon = 'icons/obj/nt_melee.dmi'
	icon_state = "nt_dagger"
	item_state = "nt_dagger"
	force = WEAPON_FORCE_PAINFUL
	armor_penetration = ARMOR_PEN_MASSIVE
	aspects = list(SANCTIFIED)
	price_tag = 120
	matter = list(MATERIAL_BIOMATTER = 10, MATERIAL_STEEL = 1)

/obj/item/tool/sword/nt/halberd
	name = "NT Halberd"
	desc = "A saint looking halberd, for emergency situation."
	icon_state = "nt_halberd"
	item_state = "nt_halberd"
	wielded_icon = "nt_halberd_wielded"
	force = WEAPON_FORCE_ROBUST
	armor_penetration = ARMOR_PEN_MASSIVE
	w_class = ITEM_SIZE_HUGE
	slot_flags = SLOT_BACK
	price_tag = 600
	matter = list(MATERIAL_BIOMATTER = 80, MATERIAL_STEEL = 8, MATERIAL_WOOD = 10, MATERIAL_PLASTEEL = 2)

/obj/item/tool/sword/nt/scourge
	name = "NT Scourge"
	desc = "A saint looking scourge, extreme punisment. Can be extended to slice stronger."
	icon_state = "nt_scourge"
	item_state = "nt_scourge"
	force = WEAPON_FORCE_PAINFUL
	var/force_extended = WEAPON_FORCE_DANGEROUS
	armor_penetration = ARMOR_PEN_DEEP
	var/armor_penetration_extended = ARMOR_PEN_HALF
	var/extended = FALSE
	w_class = ITEM_SIZE_BULKY
	price_tag = 1000
	matter = list(MATERIAL_BIOMATTER = 50, MATERIAL_STEEL = 5, MATERIAL_PLASTEEL = 2)

/obj/item/tool/sword/nt/scourge/attack_self(mob/user)
	if(isBroken)
		to_chat(user, SPAN_WARNING("\The [src] is broken."))
		return
	if(extended)
		unextend()
	else
		extend()

/obj/item/tool/sword/nt/scourge/proc/extend()
	extended = TRUE
	force += (force_extended - initial(force))
	armor_penetration += (armor_penetration_extended - initial(armor_penetration))
	slot_flags = null
	w_class = ITEM_SIZE_HUGE
	update_icon()

/obj/item/tool/sword/nt/scourge/proc/unextend()
	extended = FALSE
	w_class = initial(w_class)
	slot_flags = initial(slot_flags)
	armor_penetration = initial(armor_penetration)
	refresh_upgrades() //it's also sets all to default
	update_icon()

/obj/item/tool/sword/nt/scourge/on_update_icon()
	if(extended)
		icon_state = initial(icon_state) + "_extended"
	else
		icon_state = initial(icon_state)
	..()

/obj/item/shield/riot/nt
	name = "NT Shield"
	desc = "A saint looking shield, let the God protect you."
	icon = 'icons/obj/nt_melee.dmi'
	icon_state = "nt_shield"
	item_state = "nt_shield"
	force = WEAPON_FORCE_DANGEROUS
	armor = list(melee = 20, bullet = 20, energy = 20, bomb = 0, bio = 0, rad = 0)
	matter = list(MATERIAL_BIOMATTER = 25, MATERIAL_STEEL = 5, MATERIAL_PLASTEEL = 2)
	aspects = list(SANCTIFIED)
	spawn_blacklisted = TRUE
	price_tag = 1000
	base_block_chance = 40

/obj/item/shield/riot/nt/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/melee/baton) || istype(W, /obj/item/tool/sword/nt))
		on_bash(W, user)
	else
		..()

/* Clown Items
 * Contains:
 * 		Banana Peels
 *		Soap
 *		Bike Horns
 */

/*
 * Banana Peals
 */
/obj/item/bananapeel/Crossed(AM as mob|obj)
	if (isliving(AM))
		var/mob/living/M = AM
		if((locate(/obj/structure/multiz/stairs) in get_turf(loc)) || (locate(/obj/structure/multiz/ladder) in get_turf(loc)))
			visible_message(SPAN_DANGER("\The [M] carefully avoids stepping down on \the [src]."))
			return
		M.slip("the [src.name]",4)
/*
 * Soap
 */
/obj/item/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "soap"
	w_class = ITEM_SIZE_SMALL
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	matter = list(MATERIAL_BIOMATTER = 12)
	spawn_tags = SPAWN_TAG_ITEM_CLOWN

/obj/item/soap/New()
	..()
	create_reagents(20)
	wet()

/obj/item/soap/proc/wet()
	playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
	reagents.add_reagent("cleaner", 20)

/obj/item/soap/Crossed(AM as mob|obj)
	if (isliving(AM))
		var/mob/living/M = AM
		if((locate(/obj/structure/multiz/stairs) in get_turf(loc)) || (locate(/obj/structure/multiz/ladder) in get_turf(loc)))
			visible_message(SPAN_DANGER("\The [M] carefully avoids stepping down on \the [src]."))
			return
		M.slip("the [src.name]",3)

/obj/item/soap/afterattack(atom/target, mob/user as mob, proximity)
	if(!proximity) return

	else if(istype(target,/obj/effect/decal/cleanable))
		to_chat(user, "<span class='notice'>You scrub \the [target.name] out.</span>")
		qdel(target)
		return
	else if(istype(target,/turf))
		to_chat(user, "You start scrubbing the [target.name]")
		if(do_after(user, 50, target)) //Soap should be slower and worse than mop
			to_chat(user, "<span class='notice'>You scrub \the [target.name] clean.</span>")
			var/turf/T = target
			T.clean(src, user)
			return
		else
			to_chat(user, "<span class='notice'>You need to stand still to clean \the [target.name]!</span>")
			return
	else if(istype(target,/obj/structure/sink) || istype(target,/obj/structure/sink))
		to_chat(user, "<span class='notice'>You wet \the [src] in the sink.</span>")
		wet()
		return
	else if (istype(target, /obj/structure/mopbucket) || istype(target, /obj/item/reagent_containers/glass) || istype(target, /obj/structure/reagent_dispensers/watertank))
		if (target.reagents && target.reagents.total_volume)
			to_chat(user, "<span class='notice'>You wet \the [src] in the [target].</span>")
			wet()
			return
		else
			to_chat(user, "\The [target] is empty!")

	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && (target in user.client.screen))
		to_chat(user, "<span class='notice'>You need to take that [target.name] off before cleaning it.</span>")
		return
	else
		to_chat(user, "<span class='notice'>You clean \the [target.name].</span>")
		target.clean_blood()
		return



//attack_as_weapon
/obj/item/soap/attack(mob/living/target, mob/living/user, var/target_zone)
	if(ishuman(target) && ishuman(user) && !target.stat && user.targeted_organ == BP_MOUTH)
		user.visible_message(
			SPAN_DANGER("\The [user] washes \the [target]'s mouth out with soap!")
		)
		user.setClickCooldown(DEFAULT_QUICK_COOLDOWN) //prevent spam
		return
	..()

/obj/item/soap/nanotrasen
	desc = "A NeoTheology-brand bar of soap. Smells of biomatter."
	icon_state = "soapnt"

/obj/item/soap/deluxe
	icon_state = "soapdeluxe"

/obj/item/soap/deluxe/New()
	desc = "A deluxe Waffle Co. brand bar of soap. Smells of [pick("lavender", "vanilla", "strawberry", "chocolate" ,"space")]."
	..()

/obj/item/soap/syndie
	desc = "An untrustworthy bar of soap. Smells of fear."
	icon_state = "soapsyndie"

/*
 * Bike Horns
 */
/obj/item/bikehorn
	name = "bike horn"
	desc = "A horn off of a bicycle."
	icon = 'icons/obj/items.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"
	throwforce = WEAPON_FORCE_HARMLESS
	w_class = ITEM_SIZE_SMALL
	throw_speed = 3
	throw_range = 15
	attack_verb = list("HONKED")
	spawn_tags = SPAWN_TAG_ITEM_CLOWN
	var/spam_flag = 0

/obj/item/bikehorn/New()
	..()
	var/datum/component/item_upgrade/I = AddComponent(/datum/component/item_upgrade)
	I.weapon_upgrades = list(
		GUN_UPGRADE_HONK = TRUE,
		GUN_UPGRADE_RECOIL = 1.2,
		GUN_UPGRADE_DAMAGE_MULT = 0.8,
		GUN_UPGRADE_PEN_MULT = 0.8,
		GUN_UPGRADE_FIRE_DELAY_MULT = 1.2,
		GUN_UPGRADE_MOVE_DELAY_MULT = 1.2,
		GUN_UPGRADE_MUZZLEFLASH = 1.2,
		GUN_UPGRADE_CHARGECOST = 1.2,
		GUN_UPGRADE_OVERCHARGE_MAX = 1.2,
		GUN_UPGRADE_OVERCHARGE_RATE = 0.8
	)
	I.gun_loc_tag = GUN_MECHANISM

/obj/item/bikehorn/attack_self(mob/user)
	if (spam_flag == 0)
		spam_flag = 1
		playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
		src.add_fingerprint(user)
		spawn(20)
			spam_flag = 0
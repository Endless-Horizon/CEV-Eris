/obj/item/implant/carrion_spider
	name = "spooky spider"
	desc = "Small spider filled with some sort of strange fluid."
	icon = 'icons/obj/carrion_spiders.dmi'
	icon_state = "spiderling"
	allowed_organs = list(BP_HEAD, BP_CHEST, BP_GROIN)
	cruciform_resist = TRUE
	var/hidden = FALSE
	var/ready_to_attack = FALSE
	var/spider_price = 15
	var/gene_price = 0
	var/do_gibs = TRUE
	var/last_stun_time = 0 //Used to avoid cheese

	var/obj/item/organ/internal/carrion/core/owner_core
	var/mob/living/carbon/human/owner_mob

/obj/item/implant/carrion_spider/New()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/implant/carrion_spider/Destroy()
	. = ..()
	if(owner_core)
		owner_core.active_spiders -= src

/obj/item/implant/carrion_spider/Move(NewLoc, Dir, step_x, step_y, glide_size_override)
	last_stun_time = world.time
	..()

/obj/item/implant/carrion_spider/Process()
	if(ready_to_attack && (last_stun_time <= world.time - 4 SECONDS))
		for(var/mob/living/L in mobs_in_view(1, src))
			if(istype(L, /mob/living/simple_animal) || istype(L, /mob/living/carbon))
				if(is_carrion(L))
					continue
				install(L)
				to_chat(owner_mob, SPAN_NOTICE("[src] infested [L]"))
				break

/obj/item/implant/carrion_spider/on_uninstall()
	..()
	last_stun_time = world.time

/obj/item/implant/carrion_spider/attackby(obj/item/I, mob/living/user, params) //Overrides implanter behaviour
	if(I.force >= WEAPON_FORCE_WEAK)
		attack_animation(user)
		die_from_attack()

/obj/item/implant/carrion_spider/bullet_act(obj/item/projectile/P, def_zone)
	..()
	die_from_attack()

/obj/item/implant/carrion_spider/proc/die_from_attack()
	visible_message(SPAN_WARNING("[src] explodes into a bloody mess"))
	to_chat(owner_mob, SPAN_WARNING("You lost your connection with \the [src]"))
	die()

/obj/item/implant/carrion_spider/proc/die()
	if(!wearer)
		gibs(loc, null, /obj/effect/gibspawner/generic, "#666600", "#666600")

	qdel(src)

/obj/item/implant/carrion_spider/attack(mob/living/M, mob/living/user)
	if(!(istype(M, /mob/living/simple_animal) || istype(M, /mob/living/carbon)))
		to_chat(user, SPAN_WARNING("You can't implant spiders into robots."))
		return
	user.drop_item()
	M.attack_hand(user)
	user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	if(install(M, user.targeted_organ, user))
		to_chat(user, SPAN_NOTICE("You stealthily implant [M] with \the [src]"))

/obj/item/implant/carrion_spider/attack_self(mob/user)
	toggle_attack(user)
	..()

/obj/item/implant/carrion_spider/proc/toggle_attack(mob/user)
	if (ready_to_attack)
		ready_to_attack = FALSE
		to_chat(user, SPAN_NOTICE("\The [src] wont attack nearby creatures anymore."))
	else
		ready_to_attack = TRUE
		to_chat(user, SPAN_NOTICE("\The [src] is ready to attack nearby creatures."))

/obj/item/implant/carrion_spider/verb/hide_spider()
	set name = "Hide"
	set category = "Object"
	set src in oview(1)

	if(hidden)
		hidden = FALSE
		layer = initial(layer)
	else
		hidden = TRUE
		layer = PROJECTILE_HIT_THRESHHOLD_LAYER //You are still able to shoot them while they apper below tables

/obj/item/implant/carrion_spider/proc/update_owner_mob()
	owner_mob = owner_core.owner

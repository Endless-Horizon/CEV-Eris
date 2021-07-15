/obj/item/gun/launcher
	name = "launcher"
	desc = "A device that launches things."
	icon = 'icons/obj/guns/launcher.dmi'
	w_class = ITEM_SIZE_HUGE
	flags = CONDUCT
	slot_flags = SLOT_BACK

	muzzle_flash = 0
	fire_sound_text = "a launcher firing"
	bad_type = /obj/item/gun/launcher
	var/release_force = 0
	var/throw_distance = 10

//This normally uses a proc on projectiles and our ammo is not strictly speaking a projectile.
/obj/item/gun/launcher/can_hit(var/mob/living/target, var/mob/living/user)
	return 1

//Override this to avoid a runtime with suicide handling.
/obj/item/gun/launcher/handle_suicide(mob/living/user)
	to_chat(user, SPAN_WARNING("Shooting yourself with \a [src] is pretty tricky. You can't seem to manage it."))
	return

/obj/item/gun/launcher/proc/update_release_force(obj/item/projectile)
	return 0

/obj/item/gun/launcher/process_projectile(obj/item/projectile, mob/user, atom/target, var/target_zone, var/params, var/pointblank=0, var/reflex=0)
	update_release_force(projectile)
	projectile.loc = get_turf(user)
	projectile.throw_at(target, throw_distance, release_force, user)
	return 1

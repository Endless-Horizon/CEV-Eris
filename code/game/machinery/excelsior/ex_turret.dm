#define TURRET_PRIORITY_TARGET 2
#define TURRET_SECONDARY_TARGET 1
#define TURRET_NOT_TARGET 0

/obj/machinery/porta_turret/excelsior
	icon = 'icons/obj/machines/excelsior/turret.dmi'
	desc = "A fully automated anti infantry platform. Fires 7.62mm rounds"
	icon_state = "turret_legs"
	density = TRUE
	lethal = TRUE
	raised = TRUE
	circuit = /obj/item/weapon/electronics/circuitboard/excelsior_turret
	installation = null
	var/obj/item/ammo_magazine/ammo_box = /obj/item/ammo_magazine/ammobox/lrifle
	var/ammo = 0 // number of bullets left.
	var/ammo_max = 160
	var/working_range = 30 // how far this turret operates from excelsior teleporter
	health = 60

/obj/machinery/porta_turret/excelsior/proc/has_power_source_nearby()
	for (var/a in excelsior_teleporters)
		if (dist3D(src, a) <= working_range) //The turret and teleporter can be on a different zlevel
			return TRUE
	return FALSE

/obj/machinery/porta_turret/excelsior/examine(mob/user)
	if(!..(user, 2))
		return
	to_chat(user, "There [(ammo == 1) ? "is" : "are"] [ammo] round\s left!")
	if(!has_power_source_nearby())
		to_chat(user, "Seems to be powered down. No excelsior teleporter found nearby.")

/obj/machinery/porta_turret/excelsior/Initialize()
	. = ..()
	update_icon()

/obj/machinery/porta_turret/excelsior/setup()
	var/obj/item/ammo_casing/AM = initial(ammo_box.ammo_type)
	projectile = initial(AM.projectile_type)
	eprojectile = projectile
	shot_sound = 'sound/weapons/guns/fire/ltrifle_fire.ogg'
	eshot_sound = 'sound/weapons/guns/fire/ltrifle_fire.ogg'

/obj/machinery/porta_turret/excelsior/isLocked(mob/user)
	if(is_excelsior(user))
		return 0
	return 1

/obj/machinery/porta_turret/excelsior/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	var/data[0]
	data["access"] = !isLocked(user)
	data["locked"] = locked
	data["enabled"] = enabled

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "turret_control.tmpl", "Turret Controls", 500, 300)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/porta_turret/excelsior/HasController()
	return FALSE

/obj/machinery/porta_turret/excelsior/attackby(obj/item/ammo_magazine/I, mob/user)
	if(istype(I, ammo_box) && I.stored_ammo.len)
		if(ammo >= ammo_max)
			to_chat(user, SPAN_NOTICE("You cannot load more than [ammo_max] ammo."))
			return

		var/transfered_ammo = 0
		for(var/obj/item/ammo_casing/AC in I.stored_ammo)
			I.stored_ammo -= AC
			qdel(AC)
			ammo++
			transfered_ammo++
			if(ammo == ammo_max)
				break
		to_chat(user, SPAN_NOTICE("You loaded [transfered_ammo] bullets into [src]. It now contains [ammo] ammo."))
	else
		..()

/obj/machinery/porta_turret/excelsior/Process()
	if(!has_power_source_nearby())
		disabled = TRUE
		popDown()
		return
	if(anchored)
		disabled = FALSE
	..()

/obj/machinery/porta_turret/excelsior/assess_living(mob/living/L)
	if(!istype(L))
		return TURRET_NOT_TARGET

	if(L.invisibility >= INVISIBILITY_LEVEL_ONE)
		return TURRET_NOT_TARGET

	if(get_dist(src, L) > 7)
		return TURRET_NOT_TARGET

	if(!check_trajectory(L, src))
		return TURRET_NOT_TARGET

	if(emagged)		// If emagged not even the dead get a rest
		return L.stat ? TURRET_SECONDARY_TARGET : TURRET_PRIORITY_TARGET

	if(L.stat == DEAD)
		return TURRET_NOT_TARGET

	if(is_excelsior(L))
		return TURRET_NOT_TARGET

	if(L.lying)
		return TURRET_SECONDARY_TARGET

	return TURRET_PRIORITY_TARGET	//if the perp has passed all previous tests, congrats, it is now a "shoot-me!" nominee

/obj/machinery/porta_turret/excelsior/tryToShootAt()
	if(!ammo)
		return FALSE
	..()

// this turret has no cover, it is always raised
/obj/machinery/porta_turret/excelsior/popUp()
	raised = TRUE

/obj/machinery/porta_turret/excelsior/popDown()
	last_target = null
	raised = TRUE

/obj/machinery/porta_turret/excelsior/on_update_icon()
	cut_overlays()

	if(!(stat & BROKEN))
		add_overlays(image("turret_gun"))

/obj/machinery/porta_turret/excelsior/launch_projectile()
	ammo--
	..()

#undef TURRET_PRIORITY_TARGET
#undef TURRET_SECONDARY_TARGET
#undef TURRET_NOT_TARGET

//Toxic biomass and a few procs used by biomatter manipulation machines


//toxin attack proc, it's used for attacking people with checking their armor
/proc/toxin_attack(mob/living/victim, var/damage = rand(2, 4))
	if(istype(victim))
		var/hazard_protection = 100 - victim.getarmor(null, ARMOR_BIO)
		victim.apply_damage(max(0, damage * hazard_protection / 100 * victim.reagent_permeability()), TOX)


//this proc spill some biomass on the floor
//dirs_to_spread - list with dirs where biomass should expand after creation
/proc/spill_biomass(turf/target_location, var/dirs_to_spread = null)
	if(locate(/obj/effect/decal/cleanable/solid_biomass) in target_location)
		return
	new /obj/effect/decal/cleanable/solid_biomass(target_location)
	playsound(target_location, 'sound/effects/blobattack.ogg', 70, 1)
	if(dirs_to_spread)
		for(var/direction in dirs_to_spread)
			var/blocked = FALSE
			var/turf/neighbor = get_step(target_location, direction)
			if(!neighbor.density && !(locate(/obj/effect/decal/cleanable/solid_biomass) in neighbor))
				for(var/obj/O in neighbor)
					if(O.density)
						blocked = TRUE
						break
			else
				continue
			if(!blocked)
				var/obj/effect/decal/cleanable/solid_biomass/new_one = new(target_location)
				spawn(1)
					new_one.forceMove(neighbor)


/obj/effect/decal/cleanable/solid_biomass
	name = "solid biomass"
	desc = "It's good to do not touch this. And better to kill it with fire. Very toxic."
	icon = 'icons/obj/bioreactor_misc.dmi'
	icon_state = "biomass-1"
	anchored = TRUE


/obj/effect/decal/cleanable/solid_biomass/Initialize()
	. = ..()
	icon_state = "biomass-[rand(1, 3)]"
	START_PROCESSING(SSprocessing, src)

/obj/effect/decal/cleanable/solid_biomass/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()


/obj/effect/decal/cleanable/solid_biomass/Process()
	for(var/mob/living/creature in mobs_in_view(1, src))
		toxin_attack(creature, rand(4, 8))


/obj/effect/decal/cleanable/solid_biomass/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/mop) || istype(I, /obj/item/soap))
		to_chat(user, SPAN_NOTICE("You started removing this [src]. U-ugh. Disgusting..."))
		if(do_after(user, 3 SECONDS, src))
			to_chat(user, SPAN_NOTICE("You removed [src]."))
			toxin_attack(user, rand(25, 40))
			qdel(src)

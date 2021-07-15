//Bioreactor platform
//This part is most urgent in whole machine
//It's going through all items at its location and process them into biomass slowly (or almost slowly)
//So, this is doesn't matter how these things inside, you can even drop them from above!


/obj/machinery/multistructure/bioreactor_part/platform
	name = "bioreactor platform"
	icon_state = "platform_5"
	density = FALSE
	layer = LOW_OBJ_LAYER
	idle_power_usage = 200
	active_power_usage = 400
	var/make_glasswalls_after_creation = FALSE

/obj/machinery/multistructure/bioreactor_part/platform/Initialize()
	. = ..()
	update_icon()


/obj/machinery/multistructure/bioreactor_part/platform/Process()
	if(!MS)
		use_power(1)
		return
	if((!is_breached() || MS_bioreactor.is_operational()) && MS_bioreactor.chamber_solution)
		use_power(2)
		for(var/atom/movable/M in loc)

			//mob processing
			if(isliving(M))
				var/mob/living/victim = M
				//synthetic things not allowed
				if((issilicon(victim) || victim.mob_classification == CLASSIFICATION_SYNTHETIC) && victim.mob_size <= MOB_SMALL)
					victim.forceMove(MS_bioreactor.misc_output)
					continue
				//if our target has hazard protection, apply damage based on the protection percentage.
				var/hazard_protection = victim.getarmor(null, ARMOR_BIO)
				var/damage = CLONE_DAMAGE_PER_TICK - (CLONE_DAMAGE_PER_TICK * (hazard_protection/100))
				victim.apply_damage(damage, CLONE, used_weapon = "Biological")
				
				if(prob(10))
					playsound(loc, 'sound/effects/bubbles.ogg', 45, 1)
				if(victim.health <= -victim.maxHealth)
					MS_bioreactor.biotank_platform.take_amount(victim.mob_size*5)
					MS_bioreactor.biotank_platform.pipes_wearout(victim.mob_size/5, forced = TRUE)
					consume(victim)
				continue

			//object processing
			if(istype(M, /obj/item))
				if(M.anchored)
					continue
				var/obj/item/target = M
				//if we found biomatter, let's start processing
				//it will slowly disappear. Time based at size of object and we manipulate with its alpha (we also check for it)
				if(MATERIAL_BIOMATTER in target.matter)
					target.alpha -= round(100 / target.w_class)
					var/icon/I = new(target.icon, icon_state = target.icon_state)
					//we turn this things to degenerate sprite a bit
					I.Turn(rand(-10, 10))
					target.icon = I
					if(target.alpha <= 50)
						MS_bioreactor.biotank_platform.take_amount(target.matter[MATERIAL_BIOMATTER])
						MS_bioreactor.biotank_platform.pipes_wearout(target.w_class)
						target.matter -= MATERIAL_BIOMATTER
						//if we have other matter, let's spit it out
						for(var/material in target.matter)
							var/stack_type = material_stack_type(material_display_name(material))
							if(stack_type)
								var/obj/item/stack/material/waste = new stack_type(MS_bioreactor.misc_output)
								waste.amount = target.matter[material]
								waste.update_strings()
							target.matter -= material
						consume(target)
				else
					target.forceMove(MS_bioreactor.misc_output)
	else
		//if our machine is non operational, let's go idle powermode and pump out solution
		use_power(1)
		if(MS_bioreactor.chamber_solution)
			MS_bioreactor.pump_solution()


/obj/machinery/multistructure/bioreactor_part/platform/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/stack/material/glass/reinforced))
		var/obj/item/stack/material/glass = I
		var/list/glassless_dirs = get_opened_dirs()
		if(glass.use(glassless_dirs.len))
			to_chat(user, SPAN_NOTICE("[user] you careful placing [I] into [src]'s holders, making glass wall."))
			if(do_after(user, 3*glassless_dirs.len SECONDS, src))
				make_windows()
		else
			to_chat(user, SPAN_WARNING("Not enough amount of [I]."))
	..()


//This proc called on object/mob consumption
/obj/machinery/multistructure/bioreactor_part/platform/proc/consume(atom/movable/object)
	if(ishuman(object))
		var/mob/living/carbon/human/H = object
		for(var/obj/item/item in H.contents)
			//non robotic limbs will be consumed
			if(istype(item, /obj/item/organ))
				var/obj/item/organ/organ = item
				if(istype(organ, /obj/item/organ/external) && organ.nature == MODIFICATION_ORGANIC)
					continue
				var/obj/machinery/multistructure/bioreactor_part/platform/neighbor_platform = pick(MS_bioreactor.platforms)
				organ.forceMove(get_turf(neighbor_platform))
				organ.removed()
				continue
		if(H && H.mind && H.mind.key && H.stat == DEAD)
			var/mob/M = key2mob(H.mind.key)
			to_chat(M, SPAN_NOTICE("Your remains have been dissolved and reused. Your crew respawn time is reduced by 10 minutes."))
			M << 'sound/effects/magic/blind.ogg'  //Play this sound to a player whenever their respawn time gets reduced
			M.set_respawn_bonus("CORPSE_DISSOLVING", 10 MINUTES)
		
	qdel(object)
	//now let's add some dirt to the glass
	for(var/obj/structure/window/reinforced/bioreactor/glass in loc)
		if(glass.dir != MS_bioreactor.platform_enter_side && prob(10))
			glass.apply_dirt(1)
	if(prob(30))
		playsound(loc, 'sound/effects/bubbles.ogg', 50, 1)


/obj/machinery/multistructure/bioreactor_part/platform/on_update_icon()
	var/corner_dir = 0		//used at sprite determination, direction point to center of whole bioreactor chamber
	for(var/direction in cardinal)
		if(locate(type) in get_step(src, direction))
			corner_dir += direction
	if(corner_dir in list(9, 6, 5, 10))
		icon_state = "platform_[corner_dir]"


//There we going for open directions (dirs without neighbor platform and glass) and return list with them. It can be empty if everything okay
/obj/machinery/multistructure/bioreactor_part/platform/proc/get_opened_dirs()
	var/list/open_dirs = list()
	for(var/direction in cardinal)
		if(!locate(type) in get_step(src, direction))
			open_dirs += direction
		for(var/obj/structure/window/reinforced/bioreactor/exist_glass in loc)
			if(exist_glass.dir == direction)
				open_dirs -= exist_glass.dir
	return open_dirs


//Here we make our glass walls. First, we get open dirs (directions without platforms), then we check existed glass on.
//We remove window dirs from this list and, in the end, just creating our windows
/obj/machinery/multistructure/bioreactor_part/platform/proc/make_windows()
	var/list/open_dirs = get_opened_dirs()
	for(var/remaining_dir in open_dirs)
		var/obj/structure/window/reinforced/bioreactor/glass = new(loc)
		apply_window(glass, remaining_dir)


//There we apply sprites and directions to created glass
/obj/machinery/multistructure/bioreactor_part/platform/proc/apply_window(obj/structure/window/reinforced/glass, var/direction)
	if(MS_bioreactor.platform_enter_side == direction)
		glass.basestate = "platform_door"
		glass.icon_state = "platform_door"
	else
		glass.basestate = "[icon_state]-glass_[direction]"
		glass.icon_state = "[icon_state]-glass_[direction]"
	glass.dir = direction
	glass.update_icon()


//Here we go through our windows and check it for breach. If somewhere glass will be missing, we return TRUE and turn our bioreactor var
/obj/machinery/multistructure/bioreactor_part/platform/proc/is_breached()
	var/list/glass_dirs = get_opened_dirs()
	for(var/obj/structure/window/reinforced/glass in loc)
		if(glass.dir in glass_dirs)
			glass_dirs -= glass.dir
	if(glass_dirs.len)
		MS_bioreactor.chamber_breached = TRUE
		return TRUE
	MS_bioreactor.chamber_breached = FALSE
	return FALSE




//GLASS WALLS
/obj/structure/window/reinforced/bioreactor
	name = "bioreactor glass"
	icon = 'icons/obj/machines/bioreactor.dmi'
	layer = ABOVE_MOB_LAYER
	var/contamination_level = 0
	var/max_contamination_lvl = 5


/obj/structure/window/reinforced/bioreactor/examine(mob/user)
	..()
	switch(contamination_level)
		if(1)
			to_chat(user, SPAN_NOTICE("There are a few stains on it. Except this, [src] looks pretty clean."))
		if(2)
			to_chat(user, SPAN_NOTICE("You see a sign of biomatter on this [src]. Better to clean it up."))
		if(3)
			to_chat(user, SPAN_WARNING("This [src] has clear signs and stains of biomatter."))
		if(4)
			to_chat(user, SPAN_WARNING("You see a high amount of biomatter on \the [src]. It's dirty as hell."))
		if(5)
			to_chat(user, SPAN_WARNING("Now it's hard to see what's inside. Better to clean this [src]."))
		else
			to_chat(user, SPAN_NOTICE("This [src] is so clean, that you can see your reflection. Is that something green at your teeth?"))


/obj/structure/window/reinforced/bioreactor/on_update_icon()
	cut_overlays()
	..()
	if(contamination_level)
		var/biomass_alpha = min((50*contamination_level), 255)
		var/icon/default = new /icon(icon, icon_state)
		var/icon/biomass = new /icon('icons/obj/machines/bioreactor.dmi', "glass_biomass")
		biomass.Turn(-40, 40)
		biomass.Blend(rgb(0, 0, 0, biomass_alpha))
		default.Blend(biomass, ICON_MULTIPLY)
		add_overlays(default)


/obj/structure/window/reinforced/bioreactor/proc/apply_dirt(var/amount)
	contamination_level += amount
	if(contamination_level >= max_contamination_lvl)
		contamination_level = max_contamination_lvl
		opacity = FALSE
	if(contamination_level <= 0)
		contamination_level = 0
		opacity = TRUE
	update_icon()


/obj/structure/window/reinforced/bioreactor/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/mop) || istype(I, /obj/item/soap))
		if(istype(I, /obj/item/mop))
			if(I.reagents && !I.reagents.total_volume)
				to_chat(user, SPAN_WARNING("Your [I] is dry!"))
				return
		if(user.loc != loc)
			to_chat(user, SPAN_WARNING("You need to be inside to clean it up."))
			return
		to_chat(user, SPAN_NOTICE("You begin cleaning [src] with [I]..."))
		if(do_after(user, CLEANING_TIME * contamination_level, src))
			to_chat(user, SPAN_NOTICE("You clean \the [src]."))
			toxin_attack(user, 5*contamination_level)
			apply_dirt(-contamination_level)
			if(contamination_level >= 4)
				spill_biomass(user.loc, cardinal)
		else
			to_chat(user, SPAN_WARNING("You need to stand still to clean it properly."))
	else
		..()


/obj/structure/window/reinforced/bioreactor/MouseDrop_T(mob/victim, mob/user as mob)
	if(!ismob(victim) || !ishuman(user) || victim.anchored)
		return
	var/base_chance = 70
	if(victim == user)
		to_chat(user, SPAN_NOTICE("You try to climb over \the [src]..."))
		if(do_after(user, 3 SECONDS, src))
			if(prob(base_chance - 10*contamination_level))
				to_chat(user, SPAN_NOTICE("You successfully climbed \the [src]!"))
				if(user.loc != loc)
					user.forceMove(get_step(src, loc))
				else
					user.forceMove(get_step(src, user.dir))
			else
				to_chat(user, SPAN_WARNING("You slipped!"))
				user.Weaken(1)
	else
		to_chat(user, SPAN_NOTICE("You try to push \the [victim] over \the [src]"))
		to_chat(victim, SPAN_WARNING("\The [user] is trying to push you over \the [src]!"))
		if(do_after(user, 3 SECONDS, src))
			victim.visible_message(SPAN_WARNING("\The [user] pushes \the [victim] over \the [src]!"))
			victim.forceMove(get_step(src, user.dir))
/turf/simulated/wall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	icon = 'icons/turf/wall_masks.dmi'
	icon_state = "generic"
	layer = CLOSED_TURF_LAYER
	opacity = 1
	density = TRUE
	blocks_air = 1
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	var/ricochet_id = 0
	var/damage = 0
	var/damage_overlay = 0
	var/active
	var/can_open = 0
	var/material/material
	var/material/reinf_material
	var/last_state
	var/construction_stage
	var/hitsound = 'sound/weapons/Genhit.ogg'
	var/list/wall_connections = list("0", "0", "0", "0")

	/*
		If set, these vars will be used instead of the icon base taken from the material.
		These should be set at authortime
		Currently, they can only be set at authortime, on specially coded wall variants

		In future we should add some way to create walls of specific styles. Possibly during the construction process
	*/
	var/icon_base_override = ""
	var/icon_base_reinf_override = ""
	var/base_color_override = ""
	var/reinf_color_override = ""

	//These will be set from the set_material function. It just caches which base we're going to use, to simplify icon updating logic.
	//These should not be set at compiletime, they will be overwritten
	var/icon_base = ""
	var/icon_base_reinf = ""
	var/base_color = ""
	var/reinf_color = ""

	var/static/list/damage_overlays
	is_wall = TRUE

// Walls always hide the stuff below them.
/turf/simulated/wall/levelupdate()
	for(var/obj/O in src)
		O.hide(TRUE)
		SEND_SIGNAL(O, COMSIG_TURF_LEVELUPDATE, TRUE)

/turf/simulated/wall/New(newloc, materialtype, rmaterialtype)
	if (!damage_overlays)
		damage_overlays = new

		var/overlayCount = 16
		var/alpha_inc = 256 / overlayCount

		for(var/i = 1; i <= overlayCount; i++)
			var/image/img = image(icon = 'icons/turf/walls.dmi', icon_state = "overlay_damage")
			img.blend_mode = BLEND_MULTIPLY
			img.alpha = (i * alpha_inc) - 1
			damage_overlays.Add(img)


	icon_state = "blank"
	if(!materialtype)
		materialtype = MATERIAL_STEEL
	material = get_material_by_name(materialtype)
	if(!isnull(rmaterialtype))
		reinf_material = get_material_by_name(rmaterialtype)
	update_material(FALSE) //We call update material with update set to false, so it won't update connections or icon yet
	..(newloc)


/turf/simulated/wall/Initialize(mapload)
	..()

	if (mapload)
		//We defer icon updates to late initialize at roundstart
		return INITIALIZE_HINT_LATELOAD

	else
		//If we get here, this wall was built during the round
		//We'll update its connections and icons as normal
		update_connections(TRUE)
		update_icon()


/turf/simulated/wall/LateInitialize()
	//If we get here, this wall was mapped in at roundstart
	update_connections(FALSE)
	/*We set propagate to false when updating connections at roundstart
	This ensures that each wall will only update itself, once.
	*/

	update_icon()


/turf/simulated/wall/Destroy()
	STOP_PROCESSING(SSturf, src)
	dismantle_wall(null,null,1)
	. = ..()

/turf/simulated/wall/Process(wait, times_fired)
	// Calling parent will kill processing
	var/how_often = max(round(2 SECONDS / wait), 1)
	if(times_fired % how_often)
		return //We only work about every 2 seconds
	if(!radiate())
		return PROCESS_KILL

// Extracts angle's tan if ischance = TRUE.
// In other case it just makes bullets and lazorz go where they're supposed to.

/turf/simulated/wall/proc/projectile_reflection(obj/item/projectile/Proj, var/ischance = FALSE)
	if(Proj.starting)
		var/ricochet_temp_id = rand(1,1000)
		if(!ischance)
			Proj.ricochet_id = ricochet_temp_id
		var/turf/curloc = get_turf(src)

		var/check_x0 = 32 * curloc.x
		var/check_y0 = 32 * curloc.y
		var/check_x1 = 32 * Proj.starting.x
		var/check_y1 = 32 * Proj.starting.y
		var/check_x2 = 32 * Proj.original.x
		var/check_y2 = 32 * Proj.original.y
		var/corner_x0 = check_x0
		var/corner_y0 = check_y0
		if(check_y0 - check_y1 > 0)
			corner_y0 = corner_y0 - 16
		else
			corner_y0 = corner_y0 + 16
		if(check_x0 - check_x1 > 0)
			corner_x0 = corner_x0 - 16
		else
			corner_x0 = corner_x0 + 16

		// Checks if original is lower or upper than line connecting proj's starting and wall
		// In specific coordinate system that has wall as (0,0) and 'starting' as (r, 0), where r > 0.
		// So, this checks whether 'original's' y-coordinate is positive or negative in new c.s.
		// In order to understand, in which direction bullet will ricochet.
		// Actually new_y isn't y-coordinate, but it has the same sign.
		var/new_y = (check_y2 - corner_y0) * (check_x1 - corner_x0) - (check_x2 - corner_x0) * (check_y1 - corner_y0)
		// Here comes the thing which differs two situations:
		// First - bullet comes from north-west or south-east, with negative func value. Second - NE or SW.
		var/new_func = (corner_x0 - check_x1) * (corner_y0 - check_y1)

		// Added these wall things because my original code works well with one-tiled walls, but ignores adjacent turfs which in my current opinion was pretty wrong.
		var/wallnorth = 0
		var/wallsouth = 0
		var/walleast = 0
		var/wallwest = 0
		for (var/turf/simulated/wall/W in range(2, curloc))
			var/turf/tempwall = get_turf(W)
			if (tempwall.x == curloc.x)
				if (tempwall.y == (curloc.y - 1))
					wallnorth = 1
					if (!ischance)
						W.ricochet_id = ricochet_temp_id
				else if (tempwall.y == (curloc.y + 1))
					wallsouth = 1
					if (!ischance)
						W.ricochet_id = ricochet_temp_id
			if (tempwall.y == curloc.y)
				if (tempwall.x == (curloc.x + 1))
					walleast = 1
					if (!ischance)
						W.ricochet_id = ricochet_temp_id
				else if (tempwall.x == (curloc.x - 1))
					wallwest = 1
					if (!ischance)
						W.ricochet_id = ricochet_temp_id

		if((wallnorth || wallsouth) && ((Proj.starting.y - curloc.y)*(wallsouth - wallnorth) >= 0))
			if(!ischance)
				Proj.redirect(round(check_x1 / 32), round((2 * check_y0 - check_y1)/32), curloc, src)
				return
			else
				return abs((check_y0 - check_y1) / (check_x0 - check_x1))

		if((walleast || wallwest) && ((Proj.starting.x - curloc.x)*(walleast-wallwest) >= 0))
			if(!ischance)
				Proj.redirect(round((2 * check_x0 - check_x1) / 32), round(check_y1 / 32), curloc, src)
				return
			else
				return abs((check_x0 - check_x1) / (check_y0 - check_y1))

		if((new_y * new_func) > 0)
			if(!ischance)
				Proj.redirect(round((2 * check_x0 - check_x1) / 32), round(check_y1 / 32), curloc, src)
			else
				return abs((check_x0 - check_x1) / (check_y0 - check_y1))
		else
			if(!ischance)
				Proj.redirect(round(check_x1 / 32), round((2 * check_y0 - check_y1)/32), curloc, src)
			else
				return abs((check_y0 - check_y1) / (check_x0 - check_x1))
		return


/turf/simulated/wall/bullet_act(var/obj/item/projectile/Proj)

	if(src.ricochet_id != 0)
		if(src.ricochet_id == Proj.ricochet_id)
			src.ricochet_id = 0
			new /obj/effect/sparks(get_turf(Proj))
			return PROJECTILE_CONTINUE
		src.ricochet_id = 0
	var/proj_damage = Proj.get_structure_damage()
	if(istype(Proj,/obj/item/projectile/beam))
		burn(500)//TODO : fucking write these two procs not only for plasma (see plasma in materials.dm:283) ~
	else if(istype(Proj,/obj/item/projectile/ion))
		burn(500)

	if(Proj.can_ricochet && proj_damage != 0 && (src.x != Proj.starting.x) && (src.y != Proj.starting.y))
		var/ricochetchance = 1
		if(proj_damage <= 60)
			ricochetchance = 2 + round((60 - proj_damage) / 5)
			ricochetchance = min(ricochetchance * ricochetchance, 100)
		// here it is multiplied by 1/2 temporally, changes will be required when new wall system gets implemented
		ricochetchance = round(ricochetchance * projectile_reflection(Proj, TRUE) / 2)
		ricochetchance = min(max(ricochetchance, 0), 100)
		if(prob(ricochetchance))
			// projectile loses up to 50% of its damage when it ricochets, depending on situation
			var/damagediff = round(proj_damage / 2 + proj_damage * ricochetchance / 200) // projectile loses up to 50% of its damage when it ricochets, depending on situation
			Proj.damage_types[BRUTE] = round(Proj.damage_types[BRUTE] / 2 + Proj.damage_types[BRUTE] * ricochetchance / 200)
			Proj.damage_types[BURN] = round(Proj.damage_types[BURN] / 2 + Proj.damage_types[BURN] * ricochetchance / 200)
			take_damage(min(proj_damage - damagediff, 100))
			visible_message("<span class='danger'>The [Proj] ricochets from the surface of wall!</span>")
			projectile_reflection(Proj)
			new /obj/effect/sparks(get_turf(Proj))
			return PROJECTILE_CONTINUE // complete projectile permutation

	//cut some projectile damage here and not in projectile.dm, because we need not to all things what are using get_str_dam() becomes thin and weak.
	//in general, bullets have 35-95 damage, and they are plased in ~30 bullets magazines, so 50*30 = 150, but plasteel walls have only 400 hp =|
	//but you may also increase materials thickness or etc.
	proj_damage = round(Proj.get_structure_damage() / 3)//Yo may replace 3 to 5-6 to make walls fucking stronk as a Poland

	//cap the amount of damage, so that things like emitters can't destroy walls in one hit.
	var/damage_taken = 0
	if(Proj.nocap_structures)
		damage_taken = proj_damage * 4
	else
		damage_taken = min(proj_damage, 100)

	create_bullethole(Proj)//Potentially infinite bullet holes but most walls don't last long enough for this to be a problem.

	if(Proj.damage_types[BRUTE] && prob(src.damage / (material.integrity + reinf_material?.integrity) * 33))
		var/obj/item/trash/material/metal/slug = new(get_turf(Proj))
		slug.matter.Cut()
		slug.matter[reinf_material ? reinf_material.name : material.name] = 0.1
		slug.throw_at(get_turf(Proj), 0, 1)

	take_damage(damage_taken)

/turf/simulated/wall/hitby(AM as mob|obj, var/speed=THROWFORCE_SPEED_DIVISOR)
	..()
	if(ismob(AM))
		return

	var/tforce = AM:throwforce * (speed/THROWFORCE_SPEED_DIVISOR)
	if (tforce < 15)
		return

	take_damage(tforce)


/turf/simulated/wall/proc/clear_plants()
	for(var/obj/effect/overlay/wallrot/WR in src)
		qdel(WR)
	for(var/obj/effect/plant/plant in range(src, 1))
		if(plant.wall_mount == src) //shrooms drop to the floor
			qdel(plant)
		plant.update_neighbors()

/turf/simulated/wall/ChangeTurf(var/newtype)
	clear_plants()
	clear_bulletholes()
	..(newtype)

//Appearance
/turf/simulated/wall/examine(mob/user)
	. = ..(user)

	if(!damage)
		to_chat(user, SPAN_NOTICE("It looks fully intact."))
	else
		var/dam = damage / material.integrity
		if(dam <= 0.3)
			to_chat(user, SPAN_WARNING("It looks slightly damaged."))
		else if(dam <= 0.6)
			to_chat(user, SPAN_WARNING("It looks moderately damaged."))
		else
			to_chat(user, SPAN_DANGER("It looks heavily damaged."))

	if(locate(/obj/effect/overlay/wallrot) in src)
		to_chat(user, SPAN_WARNING("There is fungus growing on [src]."))

//Damage

/turf/simulated/wall/melt()

	if(!can_melt())
		return

	src.ChangeTurf(/turf/simulated/floor/plating)

	var/turf/simulated/floor/F = src
	if(!F)
		return
	F.burn_tile()
	F.icon_state = "wall_thermite"
	visible_message(SPAN_DANGER("\The [src] spontaneously combusts!.")) //!!OH SHIT!!
	return

/turf/simulated/wall/proc/take_damage(dam)
	if(dam)
		damage = max(0, damage + dam)
		update_damage()
	return

/turf/simulated/wall/proc/update_damage()
	var/cap = material.integrity
	if(reinf_material)
		cap += reinf_material.integrity

	if(locate(/obj/effect/overlay/wallrot) in src)
		cap = cap / 10

	if(damage >= cap)
		var/leftover = damage - cap
		if (leftover > 150)
			dismantle_wall(no_product = TRUE)
		else
			dismantle_wall()
	else
		update_icon()

	return

/turf/simulated/wall/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)//Doesn't fucking work because walls don't interact with air :(
	burn(exposed_temperature)

/turf/simulated/wall/adjacent_fire_act(turf/simulated/floor/adj_turf, datum/gas_mixture/adj_air, adj_temp, adj_volume)
	burn(adj_temp)
	if(adj_temp > material.melting_point)
		take_damage(log(RAND_DECIMAL(0.9, 1.1) * (adj_temp - material.melting_point)))

	return ..()

/turf/simulated/wall/proc/dismantle_wall(devastated, explode, no_product)
	playsound(src, 'sound/items/Welder.ogg', 100, 1)
	if(!no_product)
		if(reinf_material)
			reinf_material.place_dismantled_girder(src, reinf_material)
		else
			material.place_dismantled_girder(src)
		material.place_sheet(src, amount=3)

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O,/obj/item/contraband/poster))
			var/obj/item/contraband/poster/P = O
			P.roll_and_drop(src)
		else
			O.loc = src

	clear_plants()
	clear_bulletholes()
	material = get_material_by_name("placeholder")
	reinf_material = null
	update_connections(1)

	ChangeTurf(/turf/simulated/floor/plating)

/turf/simulated/wall/ex_act(severity)
	switch(severity)
		if(1)
			take_damage(rand(500, 800))
		if(2)
			take_damage(rand(200, 500))
		if(3)
			take_damage(rand(90, 250))
		else
	return



/turf/simulated/wall/proc/can_melt()
	if(material.flags & MATERIAL_UNMELTABLE)
		return 0
	return 1

/turf/simulated/wall/proc/thermitemelt(mob/user)
	if(!can_melt())
		return
	var/obj/effect/overlay/O = new/obj/effect/overlay(src)
	O.name = "Thermite"
	O.desc = "Looks hot."
	O.icon = 'icons/effects/fire.dmi'
	O.icon_state = "2"
	O.anchored = TRUE
	O.density = TRUE
	O.layer = 5

	src.ChangeTurf(/turf/simulated/floor/plating)

	var/turf/simulated/floor/F = src
	F.burn_tile()
	F.icon_state = "wall_thermite"
	to_chat(user, SPAN_WARNING("The thermite starts melting through the wall."))

	spawn(100)
		if(O)
			qdel(O)
//	F.sd_LumReset()		//TODO: ~Carn
	return

/turf/simulated/wall/proc/radiate()
	var/total_radiation = material.radioactivity + (reinf_material ? reinf_material.radioactivity / 2 : 0)
	if(!total_radiation)
		return

	for(var/mob/living/L in range(3,src))
		L.apply_effect(total_radiation, IRRADIATE,0)
	return total_radiation

/turf/simulated/wall/proc/burn(temperature)
	if(material.combustion_effect(src, temperature, 0.7))//it wont return something in any way, this proc is commented and it belongs to plasma material.(see materials.dm:283)
		spawn(2)
			new /obj/structure/girder(src)
			src.ChangeTurf(/turf/simulated/floor)
			for(var/turf/simulated/wall/W in RANGE_TURFS(3, src) - src)
				W.burn((temperature/4))
			for(var/obj/machinery/door/airlock/plasma/D in range(3,src))
				D.ignite(temperature/4)

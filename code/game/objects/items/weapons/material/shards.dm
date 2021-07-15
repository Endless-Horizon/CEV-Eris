// Glass shards
/obj/item/material/shard
	name = "shard"
	icon = 'icons/obj/shards.dmi'
	desc = "Made of nothing. How does this even exist?" // set based on material, if this desc is visible it's a bug (shards default to being made of glass)
	icon_state = "large"
	sharp = TRUE
	edge = TRUE
	w_class = ITEM_SIZE_TINY
	force_divisor = 0.2 // 6 with hardness 30 (glass)
	thrown_force_divisor = 0.4 // 4 with weight 15 (glass)
	item_state = "shard-glass"
	attack_verb = list("stabbed", "slashed", "sliced", "cut")
	default_material = MATERIAL_GLASS
	unbreakable = 1 //It's already broken.
	drops_debris = 0
	spawn_tags = SPAWN_TAG_MATERIAL_BUILDING_JUNK
	rarity_value = 6
	var/amount = 0

/obj/item/material/shard/New(newloc, material_key, _amount)
	if(_amount)
		amount = max(round(_amount, 0.01), 0.01) //We won't ever need to physically represent less than 1% of a material unit
	.=..()
	//Material will be set during the parent callstack
	if(!material)
		qdel(src)
		return


	//Shards must be made of some matter
	if (!amount)
		amount = round(RAND_DECIMAL(0.1, 1), 0.1)

	//Overwrite whatever was populated before. A shard contains <1 unit of a single material
	matter = list(material.name = amount)
	update_icon()

/obj/item/material/shard/set_material(var/new_material, var/update)
	..(new_material)
	if(!istype(material))
		return

	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 8)

	update_icon()

	if(material.shard_type)
		name = "[material.display_name] [material.shard_type]"
		desc = "A small piece of [material.display_name]. It looks sharp, you wouldn't want to step on it barefoot. Could probably be used as ... a throwing weapon?"
		switch(material.shard_type)
			if(SHARD_SPLINTER, SHARD_SHRAPNEL)
				gender = PLURAL
			else
				gender = NEUTER
	else
		qdel(src)

/obj/item/material/shard/on_update_icon()
	if(material)
		color = material.icon_colour
		// 1-(1-x)^2, so that glass shards with 0.3 opacity end up somewhat visible at 0.51 opacity
		alpha = 255 * (1 - (1 - material.opacity)*(1 - material.opacity))
	else
		color = "#ffffff"
		alpha = 255


	if (amount > 0.7)
		icon_state = "[material.shard_icon]["large"]"
	else if (amount < 0.4)
		icon_state = "[material.shard_icon]["medium"]"
	else
		icon_state = "[material.shard_icon]["small"]"
	//variable rotation based on randomness
	var/rot = rand(0, 360)
	var/matrix/M = matrix()
	M.Turn(rot)

	//Variable icon size based on material quantity
	//Shards will scale from 0.6 to 1.25 scale, in the range of 0..1 amount
	if (amount < 1)
		M.Scale(((1.25 - 0.8)*amount)+0.8)

	transform = M

/obj/item/material/shard/attackby(obj/item/I, mob/user)
	if(QUALITY_WELDING in I.tool_qualities)
		merge_shards(I, user)
		return
	return ..()

//Allows you to weld together similar shards in a tile to create useful sheets
/obj/item/material/shard/proc/merge_shards(obj/item/I, mob/user)
	if (!istype(loc, /turf))
		to_chat(user, SPAN_WARNING("You need to lay the shards down on a surface to do this!"))
		return

	var/list/shards = list()
	var/total = amount

	//Loop through all the other shards in the tile and cache them
	for (var/obj/item/material/shard/S in loc)
		if (S.material.name == material.name && S != src)
			shards.Add(S)
			total += S.amount

	//If there's less than one unit of material in total, we can't do anything
	if (total < 1)
		to_chat(user, SPAN_WARNING("There's not enough [material.name] in [shards.len < 2 ? "this piece" : "these [shards.len] pieces"] to make anything useful. Gather more."))
		return


	//Alright, we've got enough to make at least one sheet!
	var/obj/item/stack/output = null //This stack will contain the sheets
	to_chat(user, SPAN_NOTICE("You start welding the [name]s into useful material sheets..."))

	//Do a tool operation for each shard
	for (var/obj/item/material/shard/S in shards)
		if(I.use_tool(user, src, WORKTIME_NORMAL, QUALITY_WELDING, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
			//We meld each shard with ourselves
			amount += S.amount
			qdel(S)

			//And when our amount gets high enough, we split it off into a sheet
			if (amount > 1)
				//We create a new sheet stack if one doesn't exist yet
				//We also check the location and create a new stack if the old one is gone. Like if someone picked it up
				if (!output || output.loc != loc)
					output = material.place_sheet(loc)
					output.amount = 0
				output.amount++
				amount -= 1
			update_icon()
		else
			//If we fail any of the operations, we abort it all
			break


/obj/item/material/shard/Crossed(AM as mob|obj)
	..()
	if(isliving(AM))
		var/mob/M = AM

		if(M.buckled) //wheelchairs, office chairs, rollerbeds
			return

		playsound(src.loc, 'sound/effects/glass_step.ogg', 50, 1) // not sure how to handle metal shards with sounds
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.species.siemens_coefficient<0.5) //Thick skin.
				return

			if(H.shoes)
				return

			to_chat(M, SPAN_DANGER("You step on \the [src]!"))

			var/list/check = list(BP_L_LEG, BP_R_LEG)
			while(check.len)
				var/picked = pick(check)
				var/obj/item/organ/external/affecting = H.get_organ(picked)
				if(affecting)
					if(BP_IS_ROBOTIC(affecting))
						return
					if(affecting.take_damage(5, 0))
						H.UpdateDamageIcon()
					H.updatehealth()
					if(!(H.species.flags & NO_PAIN))
						H.Weaken(3)
					return
				check -= picked
			return

// Preset types - left here for the code that uses them
/obj/item/material/shard/shrapnel
	name = "shrapnel" //Needed for crafting
	rarity_value = 2.5

/obj/item/material/shard/shrapnel/New(loc)

	..(loc, MATERIAL_STEEL)

/obj/item/material/shard/shrapnel/scrap
	name = "scrap metal"
	amount = 1
	rarity_value = 5

/obj/item/material/shard/plasma/New(loc)
	..(loc, MATERIAL_PLASMAGLASS)

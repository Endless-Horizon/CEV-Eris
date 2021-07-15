//Todo: add leather and cloth for arbitrary coloured stools.
var/global/list/stool_cache = list() //haha stool

/obj/item/stool
	name = "stool"
	desc = "Apply butt."
	icon = 'icons/obj/furniture.dmi'
	icon_state = "stool_preview" //set for the map
	force = 10
	throwforce = 10
	w_class = ITEM_SIZE_HUGE
	var/base_icon = "stool_base"
	var/material/material
	var/material/padding_material

/obj/item/stool/padded
	icon_state = "stool_padded_preview" //set for the map

/obj/item/stool/New(var/newloc, var/new_material, var/new_padding_material)
	..(newloc)
	if(!new_material)
		new_material = MATERIAL_STEEL
	material = get_material_by_name(new_material)
	if(new_padding_material)
		padding_material = get_material_by_name(new_padding_material)
	if(!istype(material))
		qdel(src)
		return
	force = round(material.get_blunt_damage()*0.4)
	update_icon()

/obj/item/stool/padded/New(var/newloc, var/new_material)
	..(newloc, MATERIAL_STEEL, MATERIAL_CARPET)

/obj/item/stool/on_update_icon()
	// Prep icon.
	icon_state = ""
	cut_overlays()
	// Base icon.
	var/cache_key = "stool-[material.name]"
	if(isnull(stool_cache[cache_key]))
		var/image/I = image(icon, base_icon)
		I.color = material.icon_colour
		stool_cache[cache_key] = I
	associate_with_overlays(stool_cache[cache_key])
	// Padding overlay.
	if(padding_material)
		var/padding_cache_key = "stool-padding-[padding_material.name]"
		if(isnull(stool_cache[padding_cache_key]))
			var/image/I =  image(icon, "stool_padding")
			I.color = padding_material.icon_colour
			stool_cache[padding_cache_key] = I
		associate_with_overlays(stool_cache[padding_cache_key])
	// Strings.
	if(padding_material)
		name = "[padding_material.display_name] [initial(name)]" //this is not perfect but it will do for now.
		desc = "A padded stool. Apply butt. It's made of [material.use_name] and covered with [padding_material.use_name]."
	else
		name = "[material.display_name] [initial(name)]"
		desc = "A stool. Apply butt with care. It's made of [material.use_name]."

/obj/item/stool/proc/add_padding(var/padding_type)
	padding_material = get_material_by_name(padding_type)
	update_icon()

/obj/item/stool/proc/remove_padding()
	if(padding_material)
		padding_material.place_sheet(get_turf(src))
		padding_material = null
	update_icon()

/obj/item/stool/attack(mob/M as mob, mob/user as mob)
	if (prob(5) && isliving(M))
		user.visible_message(SPAN_DANGER("[user] breaks [src] over [M]'s back!"))
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		user.do_attack_animation(M)

		user.remove_from_mob(src)
		dismantle()
		qdel(src)
		var/mob/living/T = M
		T.Weaken(10)
		T.damage_through_armor(20, BRUTE, BP_CHEST, ARMOR_MELEE)
		return
	..()

/obj/item/stool/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if (prob(50))
				qdel(src)
				return
		if(3)
			if (prob(5))
				qdel(src)
				return

/obj/item/stool/proc/dismantle()
	if(material)
		material.place_sheet(get_turf(src))
	if(padding_material)
		padding_material.place_sheet(get_turf(src))
	qdel(src)

/obj/item/stool/attackby(obj/item/W, mob/user)
	if(istool(W))
		if(W.use_tool(user, src, WORKTIME_NEAR_INSTANT, QUALITY_BOLT_TURNING, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
			dismantle()
			qdel(src)
		if(padding_material)
			if(W.use_tool(user, src, WORKTIME_NEAR_INSTANT, QUALITY_CUTTING, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
				to_chat(user, "You remove the padding from \the [src].")
				remove_padding()
	else if(istype(W,/obj/item/stack))
		if(padding_material)
			to_chat(user, "\The [src] is already padded.")
			return
		var/obj/item/stack/C = W
		if(C.get_amount() < 1) // How??
			user.drop_from_inventory(C)
			qdel(C)
			return
		var/padding_type //This is awful but it needs to be like this until tiles are given a material var.
		if(istype(W,/obj/item/stack/tile/carpet))
			padding_type = MATERIAL_CARPET
		else if(istype(W,/obj/item/stack/material))
			var/obj/item/stack/material/M = W
			if(M.material && (M.material.flags & MATERIAL_PADDING))
				padding_type = "[M.material.name]"
		if(!padding_type)
			to_chat(user, "You cannot pad \the [src] with that.")
			return
		C.use(1)
		if(!istype(src.loc, /turf))
			user.drop_from_inventory(src)
			src.loc = get_turf(src)
		to_chat(user, "You add padding to \the [src].")
		add_padding(padding_type)
		return
	else
		..()


//Custom stools
//You can't pad them with something and they craft separately
/obj/item/stool/custom
	icon_state = "stool_base"

/obj/item/stool/custom/attackby(obj/item/W as obj, mob/user as mob)
	if(istool(W))
		if(W.use_tool(user, src, WORKTIME_NEAR_INSTANT, QUALITY_BOLT_TURNING, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
			dismantle()
			qdel(src)
	else if(istype(W,/obj/item/stack))
		to_chat(user, "\The [src] can't be padded.")
		return
	else
		..()

/obj/item/stool/custom/on_update_icon()
	return


/obj/item/stool/custom/bar_special
	name = "bar stool"
	icon_state = "bar_stool"

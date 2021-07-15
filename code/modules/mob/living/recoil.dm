/mob/living/proc/handle_recoil(var/obj/item/gun/G)
	deltimer(recoil_reduction_timer)
	if(G.one_hand_penalty)//If the gun has a two handed penalty and is not weilded.
		if(!G.wielded)
			recoil += G.one_hand_penalty //Then the one hand penalty wil lbe added to the recoil.
	if(G.recoil_buildup)
		recoil += G.recoil_buildup
		update_recoil()

/mob/living/proc/calc_recoil()
	recoil -= 300
	recoil_reduction_timer = addtimer(CALLBACK(src, .proc/calc_recoil), 1 SECONDS, TIMER_STOPPABLE)

	if(recoil <= 0)
		recoil = 0
		deltimer(recoil_reduction_timer)
	
	update_cursor()

//Called after setting recoil
/mob/living/proc/update_recoil()
	update_cursor()
	recoil_reduction_timer = addtimer(CALLBACK(src, .proc/calc_recoil), 1 SECONDS, TIMER_STOPPABLE)

/mob/living/proc/update_cursor()
	if(get_preference_value(/datum/client_preference/gun_cursor) != GLOB.PREF_YES)
		remove_cursor()
		return
	if(client)
		client.mouse_pointer_icon = initial(client.mouse_pointer_icon)
		var/offset = min(round(recoil), MAX_ACCURACY_OFFSET)
		var/icon/base = find_cursor_icon('icons/obj/gun_cursors/standard/standard.dmi', offset)
		ASSERT(isicon(base))
		client.mouse_pointer_icon = base

/mob/living/proc/remove_cursor()
	if(client)
		client.mouse_pointer_icon = initial(client.mouse_pointer_icon)

/proc/find_cursor_icon(var/icon_file, var/offset)
	var/list/L = GLOB.cursor_icons[icon_file]
	if(L)
		return L["[offset]"]

/proc/add_cursor_icon(var/icon/icon, var/icon_file, var/offset)
	var/list/L = GLOB.cursor_icons[icon_file]
	if(!L)
		GLOB.cursor_icons[icon_file] = list()
		L = GLOB.cursor_icons[icon_file]
	L["[offset]"] = icon

/proc/make_cursor_icon(var/icon_file, var/offset)
	var/icon/base = icon('icons/effects/96x96.dmi')
	var/icon/scaled = icon('icons/obj/gun_cursors/standard/standard.dmi') //Default cursor, cut into pieces according to their direction
	base.Blend(scaled, ICON_OVERLAY, x = 32, y = 32)

	for(var/dir in list(NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST))
		var/icon/overlay = icon('icons/obj/gun_cursors/standard/standard.dmi', "[dir]")
		var/pixel_y
		var/pixel_x
		if(dir & NORTH)
			pixel_y = CLAMP(offset, -MAX_ACCURACY_OFFSET, MAX_ACCURACY_OFFSET)
		if(dir & SOUTH)
			pixel_y = CLAMP(-offset, -MAX_ACCURACY_OFFSET, MAX_ACCURACY_OFFSET)
		if(dir & EAST)
			pixel_x = CLAMP(offset, -MAX_ACCURACY_OFFSET, MAX_ACCURACY_OFFSET)
		if(dir & WEST)
			pixel_x = CLAMP(-offset, -MAX_ACCURACY_OFFSET, MAX_ACCURACY_OFFSET)
		base.Blend(overlay, ICON_OVERLAY, x=32+pixel_x, y=32+pixel_y)
	add_cursor_icon(base, 'icons/obj/gun_cursors/standard/standard.dmi', offset)
	return base

/proc/send_all_cursor_icons(var/client/C)
	var/list/cursor_icons = GLOB.cursor_icons
	for(var/icon_file in cursor_icons)
		var/list/icons = cursor_icons[icon_file]
		for(var/offset in icons)
			var/icon/I = icons[offset]
			C << I
/obj/screen/item_action/top_bar/gun
	icon = 'icons/mob/screen/gun_actions.dmi'
	screen_loc = "8,1:13"
	minloc = "7,2:13"

/obj/screen/item_action/top_bar/gun/safety
	name = "safety"
	icon_state = "safety1"

/obj/screen/item_action/top_bar/gun/safety/on_update_icon()
	..()
	var/obj/item/weapon/gun/G = owner
	icon_state = "safety[G.safety]"


/obj/screen/item_action/top_bar/gun/fire_mode
	name = "fire mode"
	icon_state = "mode_semi"

/obj/screen/item_action/top_bar/gun/fire_mode/on_update_icon()
	..()
	var/obj/item/weapon/gun/G = owner
	if(G.sel_mode <= length(G.firemodes))
		var/datum/firemode/cur_mode = G.firemodes[G.sel_mode]
		icon_state = "mode_[cur_mode.icon_state]"


/obj/screen/item_action/top_bar/gun/scope
	name = "scope"
	icon_state = "scope0"
	screen_loc = "9,1:13"
	minloc = "8,2:13"

/obj/screen/item_action/top_bar/gun/scope/on_update_icon()
	..()
	var/obj/item/weapon/gun/G = owner
	icon_state = "scope[G.zoom]"


/obj/screen/item_action/top_bar/weapon_info
	icon = 'icons/mob/screen/gun_actions.dmi'
	screen_loc = "9:16,1:13"
	minloc = null
	name = "Weapon Info"
	icon_state = "info"

/obj/item/weapon/gun/ui_action_click(mob/living/user, action_name)
	switch(action_name)
		if("fire mode")
			toggle_firemode(user)
		if("scope")
			toggle_scope(user)
		if("safety")
			toggle_safety(user)
		if("Weapon Info")
			nano_ui_interact(user)

/obj/item/weapon/gun/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, state = GLOB.default_state)
	var/list/data = nano_ui_data(user)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "weapon_stats.tmpl", name, 700, 550, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()

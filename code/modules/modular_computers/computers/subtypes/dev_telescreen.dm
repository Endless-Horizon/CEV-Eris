/obj/item/modular_computer/telescreen
	name = "telescreen"
	desc = "A wall-mounted touchscreen computer."
	icon = 'icons/obj/modular_telescreen.dmi'
	icon_state = "telescreen"
	icon_state_menu = "menu"
	hardware_flag = PROGRAM_TELESCREEN
	anchored = TRUE
	density = FALSE
	base_idle_power_usage = 75
	base_active_power_usage = 300
	max_hardware_size = 2
	steel_sheet_cost = 10
	screen_light_strength = 2.7
	screen_light_range = 2.5
	max_damage = 300
	broken_damage = 150
	w_class = ITEM_SIZE_HUGE

/obj/item/modular_computer/telescreen/New()
	..()
	// Allows us to create "north bump" "south bump" etc. named objects, for more comfortable mapping.
	name = initial(name)

/obj/item/modular_computer/telescreen/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(QUALITY_PRYING in W.tool_qualities)
		var/choice
		if(!anchored)
			choice = input(user, "Where do you want to place \the [src]?", "Offset selection") in list("North", "South", "West", "East", "This tile", "Cancel")
			if(choice == "Cancel")
				return
		if(W.use_tool(user, src, WORKTIME_NORMAL, QUALITY_PRYING, FAILCHANCE_VERY_EASY, required_stat = STAT_COG))
			if(anchored)
				shutdown_computer()
				anchored = FALSE
				screen_on = FALSE
				pixel_x = 0
				pixel_y = 0
				to_chat(user, "You unsecure \the [src].")
			else
				var/valid = FALSE
				switch(choice)
					if("North")
						valid = TRUE
						pixel_y = 32
					if("South")
						valid = TRUE
						pixel_y = -32
					if("West")
						valid = TRUE
						pixel_x = -32
					if("East")
						valid = TRUE
						pixel_x = 32
					if("This tile")
						valid = TRUE

				if(valid)
					anchored = TRUE
					screen_on = TRUE
					to_chat(user, "You secure \the [src].")
				return
	..()

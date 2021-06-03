/mob/living/silicon/ai/Login()	//ThisIsDumb(TM) TODO: tidy this up ¬_¬ ~Carn
	..()
	regenerate_icons()
/*	flash = new /obj/screen()
	flash.icon_state = "blank"
	flash.name = "flash"
	flash.screen_loc = ui_entire_screen
	flash.layer = 17
	blind = new /obj/screen()
	blind.icon_state = "black"
	blind.name = " "
	blind.screen_loc = ui_entire_screen
	blind.mouse_opacity = 0
	blind.layer = 18
	blind.alpha = 0
	client.screen.Add( blind, flash )*/

	if(stat != DEAD)
		for(var/obj/machinery/ai_status_display/O in GLOB.machines) //change status
			O.mode = 1
			O.emotion = "Neutral"
	view_core()

	client.CAN_MOVE_DIAGONALLY = TRUE

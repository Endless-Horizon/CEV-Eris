//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
/mob/proc/update_Login_details()
	//Multikey checks and logging
	lastKnownIP	= client.address
	computer_id	= client.computer_id
	if(config.log_access)
		var/is_multikeying = 0
		for(var/mob/M in GLOB.player_list)
			if(M == src)	continue
			if( M.key && (M.key != key) )
				var/matches
				if( (M.lastKnownIP == client.address) )
					matches += "IP ([client.address])"
				if( (client.connection != "web") && (M.computer_id == client.computer_id) )
					if(matches)	matches += " and "
					matches += "ID ([client.computer_id])"
					is_multikeying = 1
				if(matches)
					if(M.client)
						message_admins("<font color='red'><B>Notice: </B></font><font color='blue'><A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has the same [matches] as <A href='?src=\ref[usr];priv_msg=\ref[M]'>[key_name_admin(M)]</A>.</font>", 1)
						log_access("Notice: [key_name(src)] has the same [matches] as [key_name(M)].")
					else
						message_admins("<font color='red'><B>Notice: </B></font><font color='blue'><A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has the same [matches] as [key_name_admin(M)] (no longer logged in). </font>", 1)
						log_access("Notice: [key_name(src)] has the same [matches] as [key_name(M)] (no longer logged in).")
		if(is_multikeying && !client.warned_about_multikeying)
			client.warned_about_multikeying = 1
			spawn(1 SECONDS)
				to_chat(src, "<b>WARNING:</b> It would seem that you are sharing connection or computer with another player. If you haven't done so already, please contact the staff via the Adminhelp verb to resolve this situation. Failure to do so may result in administrative action. You have been warned.")

/mob/Login()
	if(!client)
		return FALSE
	add_to_player_list()
	update_Login_details()
	log_access("Mob Login: [key_name(src)] was assigned to a [type]")
	world.update_status()
	client.screen = list() //remove hud items just in case
	client.images = list()

	// todo: see if this is needed
	if(hud_used)
		qdel(hud_used)		//remove the hud objects
	if(!hud_used)
		hud_used = new /datum/hud(src)

	next_move = 1
	sight |= SEE_SELF
	..()

	if(!client)
		return FALSE

	SEND_SIGNAL(src, COMSIG_MOB_LOGIN)

	if (key != client.key)
		key = client.key
	// reset_perspective(loc)

	//readd this mob's HUDs (antag, med, etc)
	// reload_huds()

	// reload_fullscreen() // Reload any fullscreen overlays this mob has.

	add_click_catcher()

	// sync_mind()

	if(loc && !isturf(loc))
		client.eye = loc
		client.perspective = EYE_PERSPECTIVE
	else
		client.eye = src
		client.perspective = MOB_PERSPECTIVE

	//set macro to normal incase it was overriden (like cyborg currently does)
	winset(src, null, "mainwindow.macro=macro hotkey_toggle.is-checked=false input.focus=true input.background-color=#D3B5B5")

	update_client_colour()
	// update_mouse_pointer()
	if (client)
		if(client.UI)
			client.UI.show()
		else
			client.create_UI(src.type)
		add_click_catcher()
		client.CAN_MOVE_DIAGONALLY = FALSE

		// for(var/foo in client.player_details.post_login_callbacks)
		// 	var/datum/callback/CB = foo
		// 	CB.Invoke()
		// log_played_names(client.ckey,name,real_name)
		// auto_deadmin_on_login()

	// log_message("Client [key_name(src)] has taken ownership of mob [src]([src.type])", LOG_OWNERSHIP)
	// SEND_SIGNAL(src, COMSIG_MOB_CLIENT_LOGIN, client)
	// client.init_verbs()

	return TRUE

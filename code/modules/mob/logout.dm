/mob/Logout()
	// SEND_SIGNAL(src, COMSIG_MOB_LOGOUT)
	// log_message("[key_name(src)] is no longer owning mob [src]([src.type])", LOG_OWNERSHIP)
	SStgui.on_logout(src)
	SSnano.user_logout(src) // this is used to clean up (remove) this user's Nano UIs
	unset_machine()
	remove_from_player_list()
	// if(client?.movingmob) //In the case the client was transferred to another mob and not deleted.
	// 	client.movingmob.client_mobs_in_contents -= src
	// 	UNSETEMPTY(client.movingmob.client_mobs_in_contents)
	// 	client.movingmob = null

	log_access("Logout: [key_name(src)]")
	if(admin_datums[src.ckey])
		if (SSticker.current_state == GAME_STATE_PLAYING) //Only report this stuff if we are currently playing.
			message_admins("Admin logout: [key_name(src)]")

	if(client && client.UI)
		client.UI.hide()
	..()
	return TRUE

/mob/new_player
	var/client/my_client // Need to keep track of this ourselves, since by the time Logout() is called the client has already been nulled

/mob/new_player/Login()
	if(!client)
		return

	if(!mind)
		mind = new /datum/mind(key)
		mind.active = TRUE
		mind.current = src

	. = ..()
	if(!. || !client)
		return FALSE

	if(join_motd)
		to_chat(src, "<div class=\"motd\">[join_motd]</div>", handle_whitespace=FALSE)
	to_chat(src, "<div class='info'>Game ID: <div class='danger'>[game_id]</div></div>")

	sight |= SEE_TURFS

	loc = null
	my_client = client
	GLOB.lobbyScreen.play_music(client)
	GLOB.lobbyScreen.show_titlescreen(client)

	new_player_panel()
	if(SSticker.current_state < GAME_STATE_SETTING_UP)
		var/tl = SSticker.GetTimeLeft()
		to_chat(src, "Please set up your character and select \"Ready\". The game will start [tl > 0 ? "in about [DisplayTimeText(tl)]" : "soon"].")

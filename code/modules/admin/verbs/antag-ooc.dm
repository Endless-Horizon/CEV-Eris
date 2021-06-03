ADMIN_VERB_ADD(/client/proc/aooc, R_ADMIN, FALSE)
/client/proc/aooc(msg as text)
	set category = "OOC"
	set name = "AOOC"
	set desc = "Antagonist OOC"

	if(!check_rights(R_ADMIN))
		return

	msg = sanitize(msg)
	if(!msg)
		return

	if(!holder)
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in AOOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in AOOC: [msg]")
			return

	var/display_name = src.key
	if(holder && holder.fakekey)
		display_name = holder.fakekey

	for(var/mob/M in GLOB.player_list)
		if((M.mind && M.mind.antagonist.len && M.client) || check_rights(R_ADMIN, 0, M))
			to_chat(M, "<font color='#960018'><span class='ooc'>" + create_text_tag("aooc", "Antag-OOC:", M.client) + " <EM>[display_name]:</EM> <span class='message linkify'>[msg]</span></span></font>")

	log_ooc("(ANTAG) [key] : [msg]")


/mob/living/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	//Mind updates
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client

	var/turf/T = get_turf(src)
	if (isturf(T))
		update_z(T.z)

	//If they're SSD, remove it so they can wake back up.
	update_antag_icons(mind)

	client.showSmartTip()


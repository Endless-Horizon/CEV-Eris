/proc/get_static_icon(icon/A, safety=1)
	var/icon/flat_icon = safety ? A : new(A)
	flat_icon.Blend(rgb(255,255,255))
	flat_icon.BecomeAlphaMask()
	var/icon/static_icon = new/icon('icons/effects/cameravis.dmi', "static_base")
	static_icon.AddAlphaMask(flat_icon)
	return static_icon

/mob/observer/eye/angel/proc/update_see_static_mobs()
	if(!client)
		return

	for(var/i in static_overlays)
		client.images.Remove(i)
		static_overlays.Remove(i)

	for(var/mob/living/L in GLOB.mob_living_list)
		static_overlays |= L.static_overlay
		client.images |= L.static_overlay

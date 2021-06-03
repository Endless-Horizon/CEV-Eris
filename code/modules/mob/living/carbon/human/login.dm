/mob/living/carbon/human/Login()
	. = ..()
	// if(!LAZYLEN(afk_thefts))
	// 	return

	update_hud()
	if(species)
		species.handle_login_special(src)
	return

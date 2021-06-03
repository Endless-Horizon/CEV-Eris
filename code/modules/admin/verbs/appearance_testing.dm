var/datum/appearance_test/appearance_test = new

#define TOGGLE(var) var ? "<font color='green'>ON</font>" : "<font color='red'>OFF</font>"
#define TRUEORFALSE(var) var ? "<font color='green'>TRUE</font>" : "<font color='red'>FALSE</font>"

/datum/appearance_test
	var/build_body = TRUE
	var/get_species_sprite = TRUE
	var/colorize_organ = TRUE
	var/cache_sprites = FALSE
	var/log_sprite_gen = TRUE
	var/log_sprite_gen_to_world = FALSE
	var/special_update = TRUE
	var/simple_setup = FALSE
	var/cache_generation_log = ""

/datum/appearance_test/proc/rebuild_humans()
	for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
		H.update_body()

/datum/appearance_test/proc/interact(var/mob/user)
	var/list/dat = list()
	dat += "<html><head><title>Appearance</title><body>"
	dat += "Build body from organs sprite - <a href='?src=\ref[src];build=1'>[TOGGLE(build_body)]</a><br>"
	dat += "Get species sprite for organs - <a href='?src=\ref[src];species=1'>[TOGGLE(get_species_sprite)]</a><br>"
	dat += "Colorize organ sprite - <a href='?src=\ref[src];color=1'>[TOGGLE(colorize_organ)]</a><br>"
	dat += "Use simple icon_state build - <a href='?src=\ref[src];simple=1'>[TOGGLE(simple_setup)]</a><br>"
	dat += "Cache human body sprite - <a href='?src=\ref[src];cache=1'>[TOGGLE(cache_sprites)]</a><br>"
	dat += "Log cache key generation - <a href='?src=\ref[src];log_cache=1'>[TOGGLE(log_sprite_gen)]</a>"
	dat += " (<a href='?src=\ref[src];view_generation_log=1'>View</a>)<br>"
	dat += "Log cache key generation to world - <a href='?src=\ref[src];log_cache_world=1'>[TOGGLE(log_sprite_gen_to_world)]</a><br>"
	dat += "Head sprite has special update_icon  - <a href='?src=\ref[src];special=1'>[TOGGLE(special_update)]</a><br>"
	dat += "<br><a href='?src=\ref[src];test_cache=1'>Test cache</a>"
	dat += " (<a href='?src=\ref[src];test_cache=1;draw_icons=1'>Output icons</a>)<br>."
	dat += "</body></html>"

	user << browse(jointext(dat, null), "window=test_sprite;size=330x220")

/datum/appearance_test/proc/output_cachelist(var/mob/user, var/draw_icons = FALSE)
	var/list/dat = list()
	dat += "<html><head><title>Cache list contents</title><body>"
	for(var/elem in human_icon_cache)
		dat += "KEY: [elem]<br>"
		var/icon/c_icon = human_icon_cache[elem]
		dat += "Isicon [TRUEORFALSE(isicon(c_icon))]<br>"
		if(draw_icons)
			user << browse_rsc(c_icon, "[elem].png")
			dat += "<img src = \"[elem].png\"><br>"
	dat += "</body></html>"

	user << browse(jointext(dat, null), "window=cache_list;size=1270x770")

/datum/appearance_test/proc/Log(string)
	if(log_sprite_gen)
		cache_generation_log += "[string]<br>"
		if(log_sprite_gen_to_world)
			to_chat(world, string)

/datum/appearance_test/proc/show_log(var/mob/user)
	user << browse(cache_generation_log, "window=cache_log;size=1270x770")

/client/proc/debug_human_sprite()
	set name = "Debug human sprites"
	set category = "Debug"
	appearance_test.interact(mob)

/datum/appearance_test/Topic(href, href_list)
	if(!check_rights(R_SERVER, 1))
		return
	var/rebuild = FALSE
	if(href_list["build"])
		build_body = !build_body
		rebuild = TRUE
	if(href_list["color"])
		colorize_organ = !colorize_organ
		rebuild = TRUE
	if(href_list["species"])
		get_species_sprite = !get_species_sprite
		rebuild = TRUE
	if(href_list["simple"])
		simple_setup = !simple_setup
		rebuild = TRUE
	if(href_list["cache"])
		cache_sprites = !cache_sprites
		rebuild = TRUE
	if(href_list["special"])
		special_update = !special_update
		rebuild = TRUE
	if(href_list["log_cache"])
		Log("Logging now [TOGGLE(!log_sprite_gen)] toggled by [key_name(usr)]")
		log_sprite_gen = !log_sprite_gen
	if(href_list["view_generation_log"])
		show_log(usr)
	if(href_list["log_cache_world"])
		log_sprite_gen_to_world = !log_sprite_gen_to_world
	if(href_list["test_cache"])
		output_cachelist(usr, href_list["draw_icons"])

	if(rebuild)
		rebuild_humans()
	interact(usr)

/mob/living/carbon/human/appearance_test/New()
	s_tone = -rand(10, 210)
	eyes_color = rgb(rand(1,220),rand(1,220),rand(1,220))
	..()
	var/list/organs = list(BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)
	for(var/i = 1 to 2)
		var/organ = pick(organs)
		organs -= organ
		if(organs_by_name[organ])
			qdel(organs_by_name[organ])
	force_update_limbs()
	update_body()

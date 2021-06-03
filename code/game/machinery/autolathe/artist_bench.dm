#define MAX_STAT_VALUE 12

/obj/machinery/autolathe/artist_bench
	name = "artist's bench"
	desc = "Insert wood, steel, glass, plasteel, plastic and a bit of your soul to create a beautiful work of art."
	icon = 'icons/obj/machines/autolathe.dmi'
	icon_state = "bench"
	circuit = /obj/item/weapon/electronics/circuitboard/artist_bench
	have_disk = FALSE
	have_reagents = FALSE
	have_recycling = FALSE
	have_design_selector = FALSE
	categories = list("Artwork")
	use_oddities = TRUE
	suitable_materials = list(MATERIAL_WOOD, MATERIAL_STEEL, MATERIAL_GLASS, MATERIAL_PLASTEEL, MATERIAL_PLASTIC)
	low_quality_print = FALSE
	var/min_mat = 20
	var/min_insight = 40

/obj/machinery/autolathe/artist_bench/nano_ui_data()
	var/list/data = list()

	data["have_disk"] = have_disk
	data["have_materials"] = have_materials
	data |= materials_data()

	if(inspiration)
		var/list/L = list()
		var/list/LE = inspiration.calculate_statistics()
		for(var/stat in LE)
			var/list/LF = list("name" = stat, "level" = LE[stat])
			L.Add(list(LF))

		data["oddity_name"] = oddity.name
		data["oddity_stats"] = L

	return data


/obj/machinery/autolathe/artist_bench/nano_ui_interact(mob/user, ui_key = "main", datum/nanoui/ui, force_open = NANOUI_FOCUS)
	var/list/data = nano_ui_data(user, ui_key)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "artist_bench.tmpl", "Artist's Bench UI", 600, 700)

		ui.add_template("_materials", "autolathe_materials.tmpl")

		ui.set_initial_data(data)

		ui.open()


/obj/machinery/autolathe/artist_bench/Topic(href, href_list)//var/mob/living/carbon/human/H, var/mob/living/user
	if(..())
		return

	if(href_list["create_art"])
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			var/ins_used = 0
			if(H.stats.getPerk(PERK_ARTIST) && H.sanity.insight > 40)
				ins_used = input("How much of your insight will you dedicate to this work? 40-[H.sanity.insight > 100 ? 100 : H.sanity.insight]","Insight Used") as null|num
			else
				ins_used = H.sanity.insight
			create_art(ins_used, H)
			return TRUE
		return FALSE

/obj/machinery/autolathe/artist_bench/proc/choose_base_art(ins_used, mob/living/carbon/human/user)
	var/list/LStats = list()

	if(inspiration && user.stats.getPerk(PERK_ARTIST))
		LStats = inspiration.calculate_statistics()

	var/weight_artwork_statue = 20
	var/weight_artwork_revolver = 1 + LStats[STAT_VIG] * 2
	var/weight_artwork_weapon = 1 + max(LStats[STAT_ROB], LStats[STAT_TGH]) * 2
	var/weight_artwork_oddity = 1 + max(LStats[STAT_COG], LStats[STAT_BIO]) * 2
	var/weight_artwork_tool = 2 + LStats[STAT_MEC] * 2
	var/weight_artwork_toolmod = 2 + LStats[STAT_MEC] * 2
	var/weight_artwork_gunmod = 2 + LStats[STAT_COG] * 2
	var/weight_artwork_gunPart = 1 + LStats[STAT_COG] + LStats[STAT_MEC]
	var/weight_artwork_armorPart = 2 + LStats[STAT_TGH] + LStats[STAT_BIO]

	if(ins_used >= 85)//Arbitrary values
		weight_artwork_revolver += 9
		weight_artwork_weapon += 9
		weight_artwork_gunPart += 5
	if(ins_used >= 70)
		weight_artwork_revolver += 4
		weight_artwork_weapon += 4
		weight_artwork_gunPart += 8
		weight_artwork_oddity += 13
		weight_artwork_gunmod += 8
		weight_artwork_armorPart += 8
	if(ins_used >= 55)
		weight_artwork_gunmod += 4
		weight_artwork_armorPart += 4
		weight_artwork_tool += 12
		weight_artwork_toolmod += 12
	else
		weight_artwork_statue += 12

	return pickweight(list(
		"artwork_revolver" = weight_artwork_revolver,
		"artwork_oddity" = weight_artwork_oddity,
		"artwork_toolmod" = weight_artwork_toolmod,
		"artwork_statue" = weight_artwork_statue,
		"artwork_gunPart" = weight_artwork_gunPart,
		"artwork_armorPart" = weight_artwork_armorPart
	))

/obj/machinery/autolathe/artist_bench/proc/choose_full_art(ins_used, mob/living/carbon/human/user)
	var/full_artwork = choose_base_art(ins_used, user)
	var/list/LStats = list()

	if(inspiration && user.stats.getPerk(PERK_ARTIST))
		LStats = inspiration.calculate_statistics()

	//var/weight_mechanical = 0 + LStats[STAT_MEC]
	//var/weight_cognition = 0 + LStats[STAT_COG]
	var/weight_biology = 0 + LStats[STAT_BIO]
	var/weight_robustness = 0 + LStats[STAT_ROB]
	//var/weight_toughness = 0 + LStats[STAT_TGH]
	var/weight_vigilance = 0 + LStats[STAT_VIG]

	if(full_artwork == "artwork_revolver")
		var/obj/item/weapon/gun/projectile/revolver/artwork_revolver/R = new(src)

		var/gun_pattern = pickweight(list(
			"pistol" = 16 + weight_robustness,
			"magnum" = 8 + weight_vigilance,
			"shotgun" = 8 + weight_robustness,
			"rifle" = 8 + weight_vigilance,
			"cap" = 16 + weight_biology,
		))

		switch(gun_pattern)

			if("pistol") //From havelock.dm, Arbitrary Values
				R.caliber = pick(CAL_PISTOL)
				R.damage_multiplier = 1.2 + rand(-5,5)/10
				R.penetration_multiplier = 1.2 + rand(-5,5)/10
				R.recoil_buildup = 18 + rand(-3,3)

			if("magnum") //From consul.dm, Arbitrary values
				R.caliber = CAL_MAGNUM
				R.damage_multiplier = 1.2 + rand(-5,5)/10
				R.penetration_multiplier = 1.2 + rand(-5,5)/10
				R.recoil_buildup = 35 + rand(-5,5)

			if("shotgun") //From bull.dm, Arbitrary values
				R.caliber = CAL_SHOTGUN
				R.damage_multiplier = 0.8 + rand(-2,2)/10
				R.penetration_multiplier = 0.75 + rand(-3,3)/10
				R.recoil_buildup = 1.2 + rand(-2,2)/10//from sawnoff.dm
				R.one_hand_penalty = 12 + rand(-2,3)
				R.bulletinsert_sound = 'sound/weapons/guns/interact/shotgun_insert.ogg'
				R.fire_sound = 'sound/weapons/guns/fire/shotgunp_fire.ogg'

			if("rifle")
				R.caliber = pick(CAL_CLRIFLE, CAL_SRIFLE, CAL_LRIFLE)
				R.fire_sound = 'sound/weapons/guns/fire/smg_fire.ogg'

			//No gun currently uses CAL_357 far as I know
			//	if("revolver")
			//		caliber = pick(CAL_357)

			if("cap")
				R.caliber = CAL_CAP

		if(R.max_shells == 3 && (gun_pattern == "shotgun"||"rocket"))//From Timesplitters triple-firing RPG far as I know
			R.init_firemodes = list(
				list(mode_name="Single shot", mode_desc="fire one barrel at a time", burst=1, icon="semi"),
				list(mode_name="Triple barrel",mode_desc="fire three barrels at once", burst=3, icon="auto"),
				)
		return R

	else if(full_artwork == "artwork_statue")
		var/obj/structure/artwork_statue/S = new(src)
		return S
	else if(full_artwork == "artwork_gunPart")
		var/obj/item/part/gun/artwork/P = new(src)
		return P
	else if(full_artwork == "artwork_armorPart")
		var/obj/item/part/armor/artwork/P = new(src)
		return P

	else if(full_artwork == "artwork_oddity")
		var/obj/item/weapon/oddity/artwork/O = new(src)
		var/list/oddity_stats = list(STAT_MEC = rand(0,1), STAT_COG = rand(0,1), STAT_BIO = rand(0,1), STAT_ROB = rand(0,1), STAT_TGH = rand(0,1), STAT_VIG = rand(0,1))//May not be nessecary
		var/stats_amt = 3
		if(ins_used >= 85)//Arbitrary values
			stats_amt += 3
		if(ins_used >= 70)
			stats_amt += 3
		if(ins_used >= 55)
			stats_amt += 3//max = 3*4*2+6 = 30 points, min 3*4+6 = 18
		for(var/i in 1 to stats_amt)
			var/stat = pick(ALL_STATS)
			oddity_stats[stat] = min(MAX_STAT_VALUE, oddity_stats[stat]+rand(1,2))

		O.oddity_stats = oddity_stats
		O.AddComponent(/datum/component/inspiration, O.oddity_stats, O.perk)
		return O

	else if(full_artwork == "artwork_toolmod")
		var/obj/item/weapon/tool_upgrade/artwork_tool_mod/TM = new(src, ins_used)
		return TM
	else
		return "ERR_ARTWORK"

/obj/machinery/autolathe/artist_bench/proc/create_art(ins_used, mob/living/carbon/human/user)
	ins_used = CLAMP(ins_used, 0, user.sanity.insight)
	//ins_used = max(ins_used, min_insight)//debug
	if(ins_used < min_insight)
		to_chat(user, SPAN_WARNING("At least 40 insight is needed to use this bench."))
		return
	FLICK("[initial(icon_state)]_work", src)
	working = TRUE
	if(!do_after(user, 15 * user.stats.getMult(STAT_MEC, STAT_LEVEL_GODLIKE), src))
		error = "Lost artist."
		working = FALSE
		return
	working = FALSE

	var/obj/artwork = choose_full_art(ins_used, user)
	var/datum/design/art
	if(isobj(artwork))
		art = new()
		randomize_materialas(artwork)
		art.build_path = artwork.type
		art.AssembleDesignInfo(artwork)
	else
		visible_message(SPAN_WARNING("Unknown error."))
		return
	var/err = can_print(art, ins_used)
	//err = ERR_OK //for debug
	if(err != ERR_OK)
		if(err in error_messages)
			error = error_messages[err]
		else
			error = "Unknown error."
		visible_message(SPAN_WARNING("[error]"))
		qdel(artwork)
		QDEL_NULL(art)
		return
	artwork.price_tag += ins_used
	artwork.make_art_review()
	artwork.forceMove(get_turf(src))

	consume_materials(art)
	if(isitem(artwork) && Adjacent(user))
		user.put_in_hands(artwork)
	user.sanity.insight -= ins_used
	if(!user.stats.getPerk(PERK_ARTIST))
		var/list/stat_change = list()

		var/stat_pool = rand(4,10) //Arbitrary value for how much to remove the stats by, from sanity_mob
		while(stat_pool--)
			LAZYAPLUS(stat_change, pick(ALL_STATS), -1)

		for(var/stat in stat_change)
			user.stats.changeStat(stat, stat_change[stat])
		to_chat(user, SPAN_WARNING("To create this work of art you have sacrificed a part of yourself."))
	else if(user.sanity.resting)
		user.sanity.finish_rest()

/obj/machinery/autolathe/artist_bench/can_print(datum/design/design)
	if(working)
		return "isworking"

	for(var/rmat in suitable_materials)
		if(stored_material[rmat] < min_mat)
			return ERR_NOMATERIAL

	var/error_mat = check_materials(design)

	if(error_mat != ERR_OK)
		return error_mat

	return ERR_OK


/obj/machinery/autolathe/artist_bench/proc/randomize_materialas(obj/O)
	var/material_num = pick(0, suitable_materials.len)
	var/list/new_materials = list()
	LAZYAPLUS(new_materials, pick(suitable_materials), rand(3,5))
	for(var/i in 1 to material_num)
		LAZYAPLUS(new_materials, pick(suitable_materials), rand(0,2))
	O.matter = new_materials

#undef MAX_STAT_VALUE

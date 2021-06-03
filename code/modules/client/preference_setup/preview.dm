datum/preferences
	var/icon/preview_icon
	var/icon/preview_south
	var/icon/preview_north
	var/icon/preview_east
	var/icon/preview_west
	var/preview_dir = SOUTH	//for augmentation

/datum/preferences/proc/update_preview_icon(naked = FALSE)
	// Determine what job is marked as 'High' priority, and dress them up as such.
	var/datum/job/previewJob

	// handles job first
	if(ASSISTANT_TITLE in job_low)
		previewJob = SSjob.GetJob(ASSISTANT_TITLE)
	else
		for(var/datum/job/job in SSjob.occupations)
			if(job.title == job_high)
				previewJob = job
				break

	// if(previewJob)
	// 	Silicons only need a very basic preview since there is no customization for them.
	// 	if(istype(previewJob,/datum/job/ai))
	// 		parent.show_character_previews(image('icons/mob/ai.dmi', icon_state = resolve_ai_icon(preferred_ai_core_display), dir = SOUTH))
	// 		return
	// 	if(istype(previewJob,/datum/job/cyborg))
	// 		parent.show_character_previews(image('icons/mob/robots.dmi', icon_state = "robot", dir = SOUTH))
	// 		return

	var/mob/living/carbon/human/dummy/mannequin/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	preview_icon = icon('icons/effects/96x64.dmi', bgstate)

	copy_to(mannequin, TRUE)

	if(previewJob)
		mannequin.job = previewJob.title
		previewJob.equip_preview(mannequin, player_alt_titles[previewJob.title])

	// add their drip
	if((equip_preview_mob & EQUIP_PREVIEW_LOADOUT) && !(previewJob && (equip_preview_mob & EQUIP_PREVIEW_JOB) && (previewJob.type == /datum/job/ai || previewJob.type == /datum/job/cyborg)))
		// Equip custom gear loadout, replacing any job items
		var/list/loadout_taken_slots = list()
		for(var/thing in Gear())
			var/datum/gear/G = gear_datums[thing]
			if(!G)
				continue
			var/permitted = FALSE
			if(G?.allowed_roles.len)
				if(previewJob)
					for(var/job_title in G.allowed_roles)
						if(previewJob.title == job_title)
							permitted = TRUE
			else
				permitted = TRUE

			if(G.whitelisted && (G.whitelisted != mannequin.species.name))
				permitted = TRUE

			if(!permitted)
				continue

			if(G.slot && G.slot != slot_accessory_buffer && !(G.slot in loadout_taken_slots) && G.spawn_on_mob(mannequin, gear_list[gear_slot][G.display_name]))
				loadout_taken_slots.Add(G.slot)

	mannequin.update_icons()

	// show_character_previews(mutable_appearance/MA)
	var/mutable_appearance/MA = new /mutable_appearance(mannequin)

	MA.dir = EAST
	var/image/I = image(MA)
	preview_east = I.icon // image(MA)

	MA.dir = WEST
	// var/icon/stamp = getFlatIcon(mannequin, WEST, always_use_defdir = 1)
	// preview_icon.Blend(stamp, ICON_OVERLAY, preview_icon.Width()/100 * 3, preview_icon.Height()/100 * 29)
	preview_west = image(MA)

	MA.dir = NORTH
	// stamp = getFlatIcon(mannequin, NORTH, always_use_defdir = 1)
	// preview_icon.Blend(stamp, ICON_OVERLAY,preview_icon.Width()/100 * 35, preview_icon.Height()/100 * 53)
	preview_north = image(MA)

	MA.dir = SOUTH
	// stamp = getFlatIcon(mannequin, SOUTH, always_use_defdir = 1)
	// preview_icon.Blend(stamp, ICON_OVERLAY, preview_icon.Width()/100 * 68,preview_icon.Height()/100 * 5)
	preview_south = image(MA)

	// Scaling here to prevent blurring in the browser.
	// preview_east.Scale(preview_east.Width() * 2, preview_east.Height() * 2)
	// preview_west.Scale(preview_west.Width() * 2, preview_west.Height() * 2)
	// preview_north.Scale(preview_north.Width() * 2, preview_north.Height() * 2)
	// preview_south.Scale(preview_south.Width() * 2, preview_south.Height() * 2)
	// preview_icon.Scale(preview_icon.Width() * 2, preview_icon.Height() * 2)
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)

	return MA

#define CLONING_START 	2	//Percent of total progress
#define CLONING_BONES	35
#define CLONING_MEAT 	70
#define CLONING_BODY 	90
#define CLONING_DONE	100

#define ANIM_OPEN 1
#define ANIM_NONE 0
#define ANIM_CLOSE -1

/obj/machinery/neotheology/cloner
	name = "NeoTheology's clonepod"
	desc = "The newest design and God's gift from NeoTheology, this automatic machine will return the flesh to the spirit in no time."
	icon = 'icons/obj/neotheology_pod.dmi'
	icon_state = "preview"
	density = TRUE
	anchored = TRUE
	layer = 2.8

	var/obj/machinery/neotheology/reader/reader
	var/reader_loc

	var/obj/machinery/neotheology/biomass_container/container
	var/container_loc

	var/mob/living/carbon/human/occupant
	var/cloning = FALSE
	var/closed = FALSE

	var/progress = 0

	var/cloning_speed = 1	//Try to avoid use of non integer values

	var/biomass_consumption = 2

	var/image/anim0 = null
	var/image/anim1 = null

	var/power_cost = 250

	var/clone_damage = 0

/obj/machinery/neotheology/cloner/New()
	..()
	icon = 'icons/obj/neotheology_machinery.dmi'
	update_icon()

/obj/machinery/neotheology/cloner/Destroy()
	if(occupant)
		qdel(occupant)
	return ..()

/obj/machinery/neotheology/cloner/proc/find_container()
	for(var/obj/machinery/neotheology/biomass_container/BC in orange(1,src))
		return BC
	return null


/obj/machinery/neotheology/cloner/proc/find_reader()
	for(var/obj/machinery/neotheology/reader/CR in orange(1,src))
		return CR
	return null


/obj/machinery/neotheology/cloner/proc/close_anim()
	qdel(anim0)
	anim0 = image(icon, "pod_closing0")
	anim0.layer = 5.01

	qdel(anim1)
	anim1 = image(icon, "pod_closing1")
	anim1.layer = 5.01
	anim1.pixel_z = 32

	update_icon()
	spawn(20)
		qdel(anim0)
		qdel(anim1)
		anim0 = null
		anim1 = null
		update_icon()

	return TRUE

/obj/machinery/neotheology/cloner/proc/open_anim()
	qdel(anim0)
	anim0 = image(icon, "pod_opening0")
	anim0.layer = 5.01

	qdel(anim1)
	anim1 = image(icon, "pod_opening1")
	anim1.layer = 5.01
	anim1.pixel_z = 32

	update_icon()
	spawn(20)
		qdel(anim0)
		qdel(anim1)
		anim0 = null
		anim1 = null
		update_icon()

	return TRUE

/obj/machinery/neotheology/cloner/proc/eject_contents()
	if(occupant)
		occupant.forceMove(loc)
		occupant = null
	else
		if(progress >= CLONING_MEAT)
			new /obj/item/reagent_containers/food/snacks/meat(loc)

	update_icon()

/obj/machinery/neotheology/cloner/proc/start()
	if(cloning)
		return

	reader = find_reader()
	if(!reader)
		return

	reader_loc = reader.loc

	container = find_container()
	if(!container)
		return

	reader.reading = TRUE
	reader.update_icon()

	container_loc = container.loc

	progress = 0

	cloning = TRUE

	occupant = null

	closed = TRUE

	close_anim()

	update_icon()
	return TRUE

/obj/machinery/neotheology/cloner/proc/stop()
	if(!cloning)
		return

	cloning = FALSE
	closed = FALSE
	if(reader)
		reader.reading = FALSE
		reader.update_icon()

	eject_contents()
	update_icon()
	return TRUE

/obj/machinery/neotheology/cloner/proc/done()
	occupant.setCloneLoss(clone_damage)
	occupant.setBrainLoss(0)
	occupant.updatehealth()
	stop()

///////////////

/obj/machinery/neotheology/cloner/Process()
	if(stat & NOPOWER)
		return

	if(cloning)
		if(!reader || reader.loc != reader_loc || !reader.implant || !container || container.loc != container_loc)
			open_anim()
			stop()
			update_icon()
			return

		progress += cloning_speed

		if(progress <= CLONING_DONE)
			if(container)
				if(!container.reagents.remove_reagent("biomatter", biomass_consumption))
					stop()
			else
				stop()

		if(occupant && ishuman(occupant))
			occupant.setCloneLoss(max(CLONING_DONE-progress, clone_damage))
			occupant.setBrainLoss(CLONING_DONE-progress)

			occupant.adjustOxyLoss(-4)
			occupant.Paralyse(4)

			occupant.updatehealth()


		if(progress >= CLONING_MEAT && !occupant)
			var/datum/core_module/cruciform/cloning/R = reader.implant.get_module(CRUCIFORM_CLONING)
			if(!R)
				open_anim()
				stop()
				update_icon()
				return

			occupant = new/mob/living/carbon/human(src)
			occupant.dna = R.dna.Clone()
			occupant.set_species()
			occupant.real_name = R.dna.real_name
			occupant.age = R.age
			occupant.UpdateAppearance()
			occupant.sync_organ_dna()
			occupant.flavor_text = R.flavor
			R.stats.copyTo(occupant.stats)

		if(progress == CLONING_BODY || progress <= CLONING_BODY && progress > CLONING_BODY-10)
			var/datum/effect/effect/system/spark_spread/s = new
			s.set_up(3, 1, src)
			s.start()

		if(progress == CLONING_DONE || progress >= CLONING_DONE-5)
			open_anim()
			closed = FALSE

		if(progress >= CLONING_DONE + 2)
			done()

		update_icon()

	use_power(power_cost)

/obj/machinery/neotheology/cloner/on_update_icon()
	icon_state = "pod_base0"

	cut_overlays()

	if(panel_open)
		var/image/P = image(icon, "pod_panel")
		add_overlays(P)

	var/image/I = image(icon, "pod_base1")
	I.layer = 5
	I.pixel_z = 32
	add_overlays(I)

	if(closed)
		I = image(icon, "pod_under")
		I.layer = 5
		add_overlays(I)

		I = image(icon, "pod_top_on")
		I.layer = 5.021
		I.pixel_z = 32
		add_overlays(I)


	/////////BODY
	var/P = progress
	if(cloning && P >= CLONING_START)
		var/icon/IC = icon(icon, "clone_bones")
		var/crop = 32-min(32,round(((P-CLONING_START)/(CLONING_BONES-CLONING_START))*32))
		IC.Crop(1,crop,IC.Width(),IC.Height())

		I = image(IC)
		I.layer = 5
		I.pixel_z = 11 + crop

		add_overlays(I)

		if(P >= CLONING_BONES)
			I = image(icon, "clone_meat")
			I.alpha = min(255,round(((P-CLONING_BONES)/(CLONING_MEAT-CLONING_BONES))*255))
			I.layer = 5
			I.pixel_z = 11
			add_overlays(I)

			if(P >= CLONING_MEAT && occupant)
				I = image(occupant.icon, occupant.icon_state)
				I.alpha = min(255,round(((P-CLONING_MEAT)/(CLONING_BODY-CLONING_MEAT))*255))
				I.overlays = occupant.overlays
				I.layer = 5
				I.pixel_z = 11
				add_overlays(I)

	//////////////

	if(closed)
		if(!anim0 && !anim1)
			I = image(icon, "pod_glass0")
			I.layer = 5.01
			add_overlays(I)

			I = image(icon, "pod_glass1")
			I.layer = 5.01
			I.pixel_z = 32
			add_overlays(I)

			I = image(icon, "pod_liquid0")
			I.layer = 5.01
			add_overlays(I)

			I = image(icon, "pod_liquid1")
			I.layer = 5.01
			I.pixel_z = 32
			add_overlays(I)

	if(anim0 && anim1)
		add_overlays(anim0)
		add_overlays(anim1)

	I = image(icon, "pod_top0")

	if(!cloning)
		I.layer = layer
	else
		I.layer = 5.02

	add_overlays(I)

	I = image(icon, "pod_top1")
	I.layer = 5.02
	I.pixel_z = 32
	add_overlays(I)


/////////////////////

/////////////////////
//BIOMASS CONTAINER
/////////////////////

/obj/machinery/neotheology/biomass_container
	name = "NeoTheology's biomass container"
	desc = "Making strange noises barrel, filled with a substance which at any time may become someone else's body."
	icon_state = "biocan"
	density = TRUE
	anchored = TRUE

	var/biomass_capacity = 600


/obj/machinery/neotheology/biomass_container/Initialize(mapload, d, bolt=TRUE)
	. = ..()
	create_reagents(biomass_capacity)
	if(SSticker.current_state != GAME_STATE_PLAYING)
		reagents.add_reagent("biomatter", 300)
	anchored = bolt
	var/turf/T = get_turf(src)
	T?.levelupdate()

/obj/machinery/neotheology/biomass_container/on_update_icon()
	cut_overlays()
	var/list/new_overlays = update_overlays()
	if(new_overlays.len)
		for(var/overlay in new_overlays)
			add_overlays(overlay)

/obj/machinery/neotheology/biomass_container/update_overlays()
	. = ..()
	if(panel_open)
		var/image/P = image(icon, "biocan_panel")
		P.dir = dir
		. += P

/obj/machinery/neotheology/biomass_container/examine(mob/user)
	if(!..(user, 2))
		return

	if(!reagents.has_reagent("biomatter"))
		to_chat(user, SPAN_NOTICE("It is empty."))
	else
		to_chat(user, SPAN_NOTICE("Filled to [reagents.total_volume]/[biomass_capacity]."))

/obj/machinery/neotheology/biomass_container/attackby(obj/item/I, mob/user)
	if (istype(I, /obj/item/stack/material/biomatter))
		var/obj/item/stack/material/biomatter/B = I
		if (B.biomatter_in_sheet && B.amount)
			var/sheets_amount_to_transfer = input(user, "How many sheets you want to load?", "Biomatter melting", 1) as num
			if(sheets_amount_to_transfer > 0)
				if(sheets_amount_to_transfer > B.amount)
					sheets_amount_to_transfer = B.amount
				var/total_transfer_from_stack = 0
				for(var/i=1;(i <= sheets_amount_to_transfer && i <= B.amount);i++)
					reagents.add_reagent("biomatter", B.biomatter_in_sheet)
					total_transfer_from_stack += B.biomatter_in_sheet
				B.use(sheets_amount_to_transfer)
				user.visible_message(
									"[user.name] inserted \the [B.name]'s sheets in \the [name].",
									"You inserted \the [B.name] in  (in amount: [sheets_amount_to_transfer]) \the [name].\
									And after that you see how the counter on \the [name] is incremented by [total_transfer_from_stack]."
									)
				ping()
			else
				to_chat(user, SPAN_WARNING("You can't insert [sheets_amount_to_transfer] in [name][sheets_amount_to_transfer < 0 ? " because it is literally impossible" :""]."))
			return
		else
			to_chat(user, SPAN_WARNING("\The [B.name] is exhausted and can't be melted to biomatter. "))

	if(istype(I, /obj/item/reagent_containers) && I.is_open_container())
		var/obj/item/reagent_containers/container = I
		if(container.reagents.get_reagent_amount("biomatter") == container.reagents.total_volume)
			container.reagents.trans_to_holder(reagents, container.amount_per_transfer_from_this)
			to_chat(user, SPAN_NOTICE("You transfer some of biomatter from \the [container] to \the [name]."))
		else
			to_chat(user, SPAN_NOTICE("You need clear biomatter to fill \the [name]."))

/////////////////////

/////////////////////
//CRUCIFORM IMPLANT READER
/////////////////////

/obj/machinery/neotheology/reader
	name = "NeoTheology's cruciform reader"
	desc = "The altar for scanning genetic information from medium of soul - the cruciform."
	icon_state = "reader_off"
	density = TRUE
	anchored = TRUE

	var/obj/item/implant/core_implant/cruciform/implant
	var/reading = FALSE


/obj/machinery/neotheology/reader/attackby(obj/item/I, mob/user as mob)
	if(istype(I, /obj/item/implant/core_implant/cruciform))
		var/obj/item/implant/core_implant/cruciform/C = I
		user.drop_item()
		C.forceMove(src)
		implant = C

	src.add_fingerprint(user)
	update_icon()

/obj/machinery/neotheology/reader/attack_hand(mob/user as mob)
	if(!implant)
		return

	if(reading)
		to_chat(user, SPAN_WARNING("You try to pull the [implant], but it does not move."))
		return

	user.put_in_active_hand(implant)
	implant = null

	src.add_fingerprint(user)
	update_icon()

/obj/machinery/neotheology/reader/on_deconstruction()
	if(implant)
		implant.forceMove(loc)
		implant = null
	return ..()

/obj/machinery/neotheology/reader/on_update_icon()
	cut_overlays()

	if(panel_open)
		var/image/P = image(icon, "reader_panel")
		add_overlays(P)


	icon_state = "reader_off"

	if(reading)
		icon_state = "reader_on"

	if(implant)
		var/image/I = image(icon, "reader_c_green")
		if(implant.get_module(CRUCIFORM_PRIEST))
			I = image(icon, "reader_c_red")
		add_overlays(I)


/////////////////////

/obj/machinery/neotheology
	icon = 'icons/obj/neotheology_machinery.dmi'

#undef ANIM_OPEN
#undef ANIM_NONE
#undef ANIM_CLOSE

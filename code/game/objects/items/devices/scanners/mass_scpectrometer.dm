
/obj/item/device/scanner/mass_spectrometer
	name = "mass spectrometer"
	desc = "A hand-held mass spectrometer which identifies trace chemicals in a blood sample."
	icon_state = "spectrometer"
	item_state = "analyzer"
	flags = CONDUCT
	reagent_flags = OPENCONTAINER

	matter = list(MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 1)
	origin_tech = list(TECH_MAGNET = 2, TECH_BIO = 2)

	charge_per_use = 7
	rarity_value = 50

	var/details = 0
	var/recent_fail = 0

/obj/item/device/scanner/mass_spectrometer/is_valid_scan_target(atom/O)
	if(!O.reagents || !O.reagents.total_volume)
		return FALSE
	return (O.is_open_container()) || istype(O, /obj/item/reagent_containers/syringe)

/obj/item/device/scanner/mass_spectrometer/scan(atom/A, mob/user)
	if(A != src)
		to_chat(user, SPAN_NOTICE("\The [src] takes a sample out of \the [A]"))
		reagents.clear_reagents()
		A.reagents.trans_to(src, 5)
	scan_title = "Spectrometer scan - [A]"
	scan_data = mass_spectrometer_scan(reagents, user, details)
	reagents.clear_reagents()
	user.show_message(scan_data)

/obj/item/device/scanner/mass_spectrometer/attack_self(mob/user)
	if(!can_use(user))
		return
	if(reagents.total_volume)
		scan(src, user)
	else
		..()

/obj/item/device/scanner/mass_spectrometer/New()
	..()
	create_reagents(5)

/obj/item/device/scanner/mass_spectrometer/on_reagent_change()
	if(reagents.total_volume)
		icon_state = initial(icon_state) + "_s"
	else
		icon_state = initial(icon_state)

/proc/mass_spectrometer_scan(var/datum/reagents/reagents, mob/user, var/details)
	if(!reagents || !reagents.total_volume)
		return SPAN_WARNING("No sample to scan.</span>")
	else
		var/list/blood_traces = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.id != "blood")
				reagents.clear_reagents()
				return SPAN_WARNING("The sample was contaminated! Please insert another sample")

			else
				blood_traces = params2list(R.data["trace_chem"])
				break

		var/list/dat = list("Trace Chemicals Found: ")
		for(var/datum/reagent/R in blood_traces)
			if(details)
				dat += "[R.name] ([blood_traces[R]] units) "
			else
				dat += "[R.name] "

		reagents.clear_reagents()
		return jointext(dat, "<br>")

/obj/item/device/scanner/mass_spectrometer/adv
	name = "advanced mass spectrometer"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = list(TECH_MAGNET = 4, TECH_BIO = 2)
	rarity_value = 100

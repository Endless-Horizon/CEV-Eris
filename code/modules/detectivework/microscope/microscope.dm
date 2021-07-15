//microscope code itself
/obj/machinery/microscope
	name = "high powered electron microscope"
	desc = "A highly advanced microscope capable of zooming up to 3000x."
	icon = 'icons/obj/forensics.dmi'
	icon_state = "microscope"
	anchored = TRUE
	density = TRUE

	var/obj/item/sample = null
	var/report_num = 0

/obj/machinery/microscope/attackby(obj/item/W as obj, mob/user as mob)

	if(sample)
		to_chat(user, SPAN_WARNING("There is already a slide in the microscope."))
		return

	if(istype(W, /obj/item/forensics/swab)|| istype(W, /obj/item/sample/fibers) || istype(W, /obj/item/sample/print))
		to_chat(user, SPAN_NOTICE("You insert \the [W] into the microscope."))
		user.unEquip(W)
		W.forceMove(src)
		sample = W
		update_icon()
		return

/obj/machinery/microscope/attack_hand(mob/user)

	if(!sample)
		to_chat(user, SPAN_WARNING("The microscope has no sample to examine."))
		return

	to_chat(user, SPAN_NOTICE("The microscope whirrs as you examine \the [sample]."))

	if(!do_after(user, 25, src) || !sample)
		to_chat(user, SPAN_NOTICE("You stop examining \the [sample]."))
		return

	to_chat(user, SPAN_NOTICE("Printing findings now..."))
	var/obj/item/paper/report = new(get_turf(src))
	report.stamped = list(/obj/item/stamp)
	report.set_overlays(list("paper_stamped"))
	report_num++

	if(istype(sample, /obj/item/forensics/swab))
		var/obj/item/forensics/swab/swab = sample

		report.name = "GSR report #[++report_num]: [swab.name]"
		report.info = "<b>Scanned item:</b><br>[swab.name]<br><br>"

		if(swab.gsr)
			report.info += "Residue from a [swab.gsr] bullet detected."
		else
			report.info += "No gunpowder residue found."

	else if(istype(sample, /obj/item/sample/fibers))
		var/obj/item/sample/fibers/fibers = sample
		report.name = "Fiber report #[++report_num]: [fibers.name]"
		report.info = "<b>Scanned item:</b><br>[fibers.name]<br><br>"
		if(fibers.evidence)
			report.info = "Molecular analysis on provided sample has determined the presence of unique fiber strings.<br><br>"
			for(var/fiber in fibers.evidence)
				report.info += "<span class='notice'>Most likely match for fibers: [fiber]</span><br><br>"
		else
			report.info += "No fibers found."
	else if(istype(sample, /obj/item/sample/print))
		report.name = "Fingerprint report #[report_num]: [sample.name]"
		report.info = "<b>Fingerprint analysis report #[report_num]</b>: [sample.name]<br>"
		var/obj/item/sample/print/card = sample
		if(card.evidence && card.evidence.len)
			report.info += "Surface analysis has determined unique fingerprint strings:<br><br>"
			for(var/prints in card.evidence)
				report.info += SPAN_NOTICE("Fingerprint string: ")
				if(!is_complete_print(prints))
					report.info += "INCOMPLETE PRINT"
				else
					report.info += "[prints]"
				report.info += "<br>"
		else
			report.info += "No information available."

	if(report)
		report.update_icon()
		if(report.info)
			to_chat(user, report.info)
	return

/obj/machinery/microscope/proc/remove_sample(var/mob/living/remover)
	if(!istype(remover) || remover.incapacitated() || !Adjacent(remover))
		return
	if(!sample)
		to_chat(remover, SPAN_WARNING("\The [src] does not have a sample in it."))
		return
	to_chat(remover, SPAN_NOTICE("You remove \the [sample] from \the [src]."))
	sample.forceMove(get_turf(src))
	remover.put_in_hands(sample)
	sample = null
	update_icon()

/obj/machinery/microscope/AltClick()
	remove_sample(usr)

/obj/machinery/microscope/MouseDrop(var/atom/other)
	if(usr == other)
		remove_sample(usr)
	else
		return ..()

/obj/machinery/microscope/on_update_icon()
	icon_state = "microscope"
	if(sample)
		icon_state += "slide"

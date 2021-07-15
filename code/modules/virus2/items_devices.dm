///////////////ANTIBODY SCANNER///////////////

/obj/item/device/antibody_scanner
	name = "antibody scanner"
	desc = "Scans living beings for antibodies in their blood."
	icon_state = "health"
	w_class = ITEM_SIZE_SMALL
	item_state = "electronic"
	matter = list(MATERIAL_PLASTIC = 1, MATERIAL_GLASS = 1)
	flags = CONDUCT
	rarity_value = 50

/obj/item/device/antibody_scanner/attack(mob/M as mob, mob/user as mob)
	if(!istype(M,/mob/living/carbon/))
		report("Scan aborted: Incompatible target.", user)
		return

	var/mob/living/carbon/C = M
	if (istype(C,/mob/living/carbon/human/))
		var/mob/living/carbon/human/H = C
		if(H.species.flags & NO_BLOOD)
			report("Scan aborted: The target does not have blood.", user)
			return

	if(!C.antibodies.len)
		report("Scan Complete: No antibodies detected.", user)
		return

	if (CLUMSY in user.mutations && prob(50))
		// I was tempted to be really evil and rot13 the output.
		report("Antibodies detected: [reverse_text(antigens2string(C.antibodies))]", user)
	else
		report("Antibodies detected: [antigens2string(C.antibodies)]", user)

/obj/item/device/antibody_scanner/proc/report(var/text, mob/user as mob)
	to_chat(user, "\blue \icon[src] \The [src] beeps, \"[text]\"")

///////////////VIRUS DISH///////////////

/obj/item/virusdish
	name = "virus dish"
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"
	var/datum/disease2/disease/virus2
	var/growth = 0
	var/basic_info
	var/info = 0
	var/analysed = 0

/obj/item/virusdish/random
	name = "virus sample"

/obj/item/virusdish/random/New()
	..()
	src.virus2 = new /datum/disease2/disease
	src.virus2.makerandom()
	growth = rand(5, 50)

/obj/item/virusdish/attackby(var/obj/item/W as obj,var/mob/living/carbon/user as mob)
	if(istype(W,/obj/item/hand_labeler) || istype(W,/obj/item/reagent_containers/syringe))
		return
	..()
	if(prob(50))
		to_chat(user, SPAN_DANGER("\The [src] shatters!"))
		if(virus2.infectionchance > 0)
			for(var/mob/living/carbon/target in view(1, get_turf(src)))
				if(airborne_can_reach(get_turf(src), get_turf(target)))
					infect_virus2(target, src.virus2)
		qdel(src)

/obj/item/virusdish/examine(mob/user)
	..()
	if(basic_info)
		to_chat(user, "[basic_info] : <a href='?src=\ref[src];info=1'>More Information</a>")

/obj/item/virusdish/Topic(href, href_list)
	. = ..()
	if(.) return 1

	if(href_list["info"])
		usr << browse(info, "window=info_\ref[src]")
		return 1

/obj/item/ruinedvirusdish
	name = "ruined virus sample"
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"
	desc = "The bacteria in the dish are completely dead."

/obj/item/ruinedvirusdish/attackby(var/obj/item/W as obj,var/mob/living/carbon/user as mob)
	if(istype(W,/obj/item/hand_labeler) || istype(W,/obj/item/reagent_containers/syringe))
		return ..()

	if(prob(50))
		to_chat(user, "\The [src] shatters!")
		qdel(src)

///////////////GNA DISK///////////////

/obj/item/diseasedisk
	name = "blank GNA disk"
	icon = 'icons/obj/discs.dmi'
	icon_state = "purple"
	w_class = ITEM_SIZE_TINY
	var/datum/disease2/effectholder/effect
	var/list/species
	var/stage = 1
	var/analysed = 1

/obj/item/diseasedisk/premade/Initialize(mapload)
	. = ..()
	name = "blank GNA disk (stage: [stage])"
	effect = new /datum/disease2/effectholder
	effect.effect = new /datum/disease2/effect/invisible
	effect.stage = stage

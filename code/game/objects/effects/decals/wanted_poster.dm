/obj/item/contraband/poster/wanted
	bad_type = /obj/item/contraband/poster/wanted

/obj/item/contraband/poster/wanted/New(turf/loc, icon/person_icon, wanted_name, description)
	name = "wanted poster ([wanted_name])"
	desc = "A wanted poster for [wanted_name]."
	desc = description
	..(loc, new /datum/poster/wanted (person_icon, wanted_name, description))

/datum/poster/wanted/New(var/icon/person_icon, var/person_name, var/description)
	name = person_name
	desc = description
	person_icon = icon(person_icon, dir = SOUTH)//copy the image so we don't mess with the one in the record.
	var/icon/the_icon = icon(icon, "wanted_background")
	var/icon/icon_foreground = icon(icon, "wanted_foreground")
	person_icon.Shift(SOUTH, 7)
	person_icon.Crop(7,4,26,30)
	person_icon.Crop(-5,-2,26,29)
	the_icon.Blend(person_icon, ICON_OVERLAY)
	the_icon.Blend(icon_foreground, ICON_OVERLAY)

	the_icon.Insert(the_icon, "wanted")
	the_icon.Insert('icons/obj/contraband.dmi', "poster_being_set")
	the_icon.Insert('icons/obj/contraband.dmi', "poster_ripped")
	icon = the_icon

/datum/poster/wanted/set_design(var/obj/item/contraband/poster/P)
	..()
	P.name = "wanted poster ([name])"

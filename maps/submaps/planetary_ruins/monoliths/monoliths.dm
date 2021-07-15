/datum/map_template/ruin/exoplanet/monolith
	name = "Monolith Ring"
	id = "planetsite_monoliths"
	description = "Bunch of monoliths surrounding an artifact."
	suffix = "monoliths/monoliths.dmm"
	cost = 1
	template_flags = TEMPLATE_FLAG_NO_RUINS
	ruin_tags = RUIN_ALIEN

/obj/structure/monolith
	name = "monolith"
	desc = "An obviously artifical structure of unknown origin. The symbols '<font face='Shage'>DWNbTX</font>' are engraved on the base."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "monolith"
	plane = ABOVE_HUD_LAYER
	layer = ABOVE_HUD_LAYER
	density = 1
	anchored = 1
	var/active = 0

/obj/structure/monolith/Initialize()
	. = ..()
	SetIconState("monolith")
	var/material/A = get_material_by_name(MATERIAL_VOXALLOY)
	if(A)
		color = A.icon_colour
	if(config.use_overmap)
		var/obj/effect/overmap/sector/exoplanet/E = map_sectors["[z]"]
		if(istype(E))
			desc += "\nThere are images on it: [E.get_engravings()]"

/obj/structure/monolith/on_update_icon()
	cut_overlays()
	if(active)
		var/image/I = image(icon,"[icon_state]_1")
		I.appearance_flags = RESET_COLOR
		I.color = get_random_colour(0, 150, 255)
		I.layer = ABOVE_LIGHTING_LAYER
		I.plane = ABOVE_LIGHTING_PLANE
		add_overlays(I)
		set_light(0.3, 0.1, 2, l_color = I.color)

/obj/structure/monolith/attack_hand(mob/user)
	visible_message("[user] touches \the [src].")
	if(config.use_overmap && istype(user,/mob/living/carbon/human))
		var/obj/effect/overmap/sector/exoplanet/E = map_sectors["[z]"]
		if(istype(E))
			var/mob/living/carbon/human/H = user
			if(!H.isSynthetic())
				active = 1
				update_icon()
				if(prob(70))
					to_chat(H, "<span class='notice'>As you touch \the [src], you suddenly get a vivid image - [E.get_engravings()]</span>")
				else
					to_chat(H, "<span class='warning'>An overwhelming stream of information invades your mind!</span>")
					var/vision = ""
					for(var/i = 1 to 10)
						vision += pick(E.actors) + " " + pick("killing","dying","gored","expiring","exploding","mauled","burning","flayed","in agony") + ". "
					to_chat(H, "<span class='danger'><font size=2>[uppertext(vision)]</font></span>")
					H.Paralyse(2)
					H.hallucination(20, 100)
				return
	to_chat(user, "<span class='notice'>\The [src] is still.</span>")
	return ..()

/decl/flooring/reinforced/alium
	name = "ancient alien floor"
	desc = "This obviously wasn't made for your feet. Looks pretty old."
	icon = 'icons/turf/flooring/misc.dmi'
	icon_base = "alienvault"
	build_type = null
	has_damage_range = 6
	flags = TURF_ACID_IMMUNE | TURF_HIDES_THINGS
	can_paint = null

/turf/simulated/wall/alium
	icon = 'icons/turf/walls.dmi'
	icon_state = "alienvault"
	material = MATERIAL_VOXALLOY

/turf/simulated/floor/alium
	name = "ancient alien plating"
	desc = "This obviously wasn't made for your feet. Looks pretty old."
	icon = 'icons/turf/flooring/misc.dmi'
	icon_state = "alienvault"
	mineral = MATERIAL_VOXALLOY
	initial_flooring = /decl/flooring/reinforced/alium

/turf/simulated/floor/alium/airless
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/alium/ruin
	oxygen = 0
	nitrogen = 0
	initial_gas = null

/turf/simulated/floor/alium/ruin/Initialize()
	. = ..()
	if(prob(10))
		ChangeTurf(get_base_turf_by_area(src))

/turf/simulated/wall/alium/attackby(obj/item/W as obj, mob/user as mob)
	return
	// ALIUM DOES NOT GIVE A FUCK

/turf/simulated/floor/alium/attackby(obj/item/W as obj, mob/user as mob)
	return
	// ALIUM DOES NOT GIVE A FUCK

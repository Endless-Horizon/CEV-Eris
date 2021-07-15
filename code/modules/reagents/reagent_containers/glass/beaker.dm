/obj/item/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A beaker."
	icon_state = "beaker"
	item_state = "beaker"
	label_icon_state = "label_beaker"
	filling_states = "20;40;60;80;100"
	spawn_tags = SPAWN_TAG_JUNK
	rarity_value = 20

/obj/item/reagent_containers/glass/beaker/Initialize()
	. = ..()
	desc += " Can hold up to [volume] units."

/obj/item/reagent_containers/glass/beaker/pickup(mob/user)
	..()
	playsound(src,'sound/items/Glass_Fragment_take.ogg',50,1)

/obj/item/reagent_containers/glass/beaker/dropped(mob/user)
	..()
	playsound(src,'sound/items/Glass_Fragment_drop.ogg',50,1)

/obj/item/reagent_containers/glass/beaker/on_update_icon()
	cut_overlays()

	if(reagents?.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "[icon_state]-[get_filling_state()]")
		filling.color = reagents.get_color()
		add_overlay(filling)

	if(has_lid())
		var/lid_icon = lid_icon_state ? lid_icon_state : "lid_[icon_state]"
		var/mutable_appearance/lid = mutable_appearance(icon, lid_icon)
		add_overlay(lid)

	if(label_text)
		var/label_icon = label_icon_state ? label_icon_state : "label_[icon_state]"
		var/mutable_appearance/label = mutable_appearance(icon, label_icon)
		add_overlay(label)


//// Subtypes ////

/obj/item/reagent_containers/glass/beaker/large
	name = "large beaker"
	desc = "A large beaker."
	icon_state = "beakerlarge"
	label_icon_state = "label_beakerlarge"
	matter = list(MATERIAL_GLASS = 2)
	volume = 120
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,60,120)
	rarity_value = 40

/obj/item/reagent_containers/glass/beaker/noreact
	name = "cryostasis beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions."
	icon_state = "beakernoreact"
	matter = list(MATERIAL_GLASS = 1, MATERIAL_STEEL = 2)
	volume = 60
	amount_per_transfer_from_this = 10
	reagent_flags = OPENCONTAINER | NO_REACT
	spawn_blacklisted = TRUE

/obj/item/reagent_containers/glass/beaker/bluespace
	name = "bluespace beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology."
	icon_state = "beakerbluespace"
	label_icon_state = "label_beakerbluespace"
	matter = list(MATERIAL_STEEL = 4, MATERIAL_PLASMA = 1)
	volume = 300
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,60,120,300)
	lid_icon_state = "lid_beakerbluespace"
	spawn_blacklisted = TRUE

/obj/item/reagent_containers/glass/beaker/bowl
	name = "mixing bowl"
	desc = "A large mixing bowl."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mixingbowl"
	matter = list(MATERIAL_STEEL = 2)
	volume = 180
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,60,120,180)
	unacidable = FALSE

/obj/item/reagent_containers/glass/beaker/vial
	name = "vial"
	desc = "A small glass vial."
	icon_state = "vial"
	label_icon_state = "label_vial"
	matter = list(MATERIAL_GLASS = 1)
	volume = 30
	w_class = ITEM_SIZE_TINY
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25)
	spawn_tags = SPAWN_TAG_VIAL
	rarity_value = 20

/obj/item/reagent_containers/glass/beaker/vial/nanites
	preloaded_reagents = list("nanites" = 30)
	rarity_value = 40

/obj/item/reagent_containers/glass/beaker/vial/uncapnanites
	preloaded_reagents = list("uncap nanites" = 30)
	spawn_blacklisted = TRUE


/obj/item/reagent_containers/glass/beaker/cryoxadone
	preloaded_reagents = list("cryoxadone" = 30)
	spawn_blacklisted = TRUE

/obj/item/reagent_containers/glass/beaker/sulphuric
	preloaded_reagents = list("sacid" = 60)

/obj/item/reagent_containers/glass/beaker/vial/vape
	name = "vape vial"
	desc = "A small plastic vial."
	icon_state = "vial_plastic"
	matter = list(MATERIAL_PLASTIC = 1)
	spawn_tags = null

/obj/item/reagent_containers/glass/beaker/vial/vape/berry
	name = "berry vape vial"
	preloaded_reagents = list("nicotine" = 20, "berryjuice" = 10)

/obj/item/reagent_containers/glass/beaker/vial/vape/lemon
	name = "lemon vape vial"
	preloaded_reagents = list("nicotine" = 20, "lemonjuice" = 10)

/obj/item/reagent_containers/glass/beaker/vial/vape/banana
	name= "banana vape vial"
	preloaded_reagents = list("nicotine" = 20, "banana" = 10)

/obj/item/reagent_containers/glass/beaker/vial/vape/nicotine
	name = "nicotine vape vial"
	preloaded_reagents = list("nicotine" = 30)

/obj/item/reagent_containers/glass/bucket
	desc = "It's a bucket."
	name = "bucket"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	matter = list(MATERIAL_PLASTIC = 2)
	w_class = ITEM_SIZE_NORMAL
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(10,20,30,60,120,200)
	volume = 200
	unacidable = 0
	spawn_tags = SPAWN_TAG_JUNK
	rarity_value = 20

/obj/item/reagent_containers/glass/bucket/attackby(obj/D, mob/user)

	if(is_proximity_sensor(D))
		to_chat(user, "You add [D] to [src].")
		qdel(D)
		user.put_in_hands(new /obj/item/bucket_sensor)
		user.drop_from_inventory(src)
		qdel(src)
		return
	else if(istype(D, /obj/item/mop))
		return
	else
		return ..()

/obj/item/reagent_containers/glass/bucket/on_update_icon()
	cut_overlays()
	if(reagents.total_volume >= 1)
		add_overlays("water_bucket")
	if(has_lid())
		var/image/lid = image(icon, src, "lid_[initial(icon_state)]")
		add_overlays(lid)

/obj/item/reagent_containers/glass/beaker/hivemind
	preloaded_reagents = list("nanites" = 30, "uncap nanites" = 30)
	spawn_blacklisted = TRUE

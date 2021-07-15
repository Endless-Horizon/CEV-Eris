/obj/item/reagent_containers/food/snacks/meat
	name = "meat"
	desc = "A slab of meat cut from a nondescript animal. The core ingredient in thousands upon thousands of food recipes, in one way or another."
	icon_state = "meat"
	health = 180
	filling_color = "#FF1C1C"
	center_of_mass = list("x"=16, "y"=14)
	bitesize = 3
	matter = list(MATERIAL_BIOMATTER = 20)
	preloaded_reagents = list("protein" = 9)
	taste_tag = list(MEAT_FOOD)

/obj/item/reagent_containers/food/snacks/meat/attackby(obj/item/I, mob/user)
	if(QUALITY_CUTTING in I.tool_qualities)
		if(I.use_tool(user, src, WORKTIME_NORMAL, QUALITY_CUTTING, FAILCHANCE_ZERO, required_stat = STAT_BIO))
			to_chat(user, SPAN_NOTICE("You cut the meat into thin strips."))
			new /obj/item/reagent_containers/food/snacks/rawcutlet(src)
			new /obj/item/reagent_containers/food/snacks/rawcutlet(src)
			new /obj/item/reagent_containers/food/snacks/rawcutlet(src)
			qdel(src)
	else
		..()

/obj/item/reagent_containers/food/snacks/meat/syntiflesh
	name = "synthetic meat"
	desc = "A synthetic slab of flesh. You probably won't not be able to not tell the difference from the real thing maybe!"

// Seperate definitions because some food likes to know if it's human.
// TODO: rewrite kitchen code to check a var on the meat item so we can remove
// all these sybtypes.
/obj/item/reagent_containers/food/snacks/meat/human
/obj/item/reagent_containers/food/snacks/meat/monkey
	//same as plain meat

/obj/item/reagent_containers/food/snacks/meat/corgi
	name = "Corgi meat"
	desc = "Tastes like... well, you know."

/obj/item/reagent_containers/food/snacks/meat/roachmeat
	desc = "A slab of sickly-green bubbling meat cut from a giant roach. You swear you can see it still twitching occasionally. Delicious!"
	icon_state = "xenomeat"
	filling_color = "#E2FFDE"

	bitesize = 6
	preloaded_reagents = list("protein" = 4, "blattedin" = 8, "diplopterum" = 7)

/obj/item/reagent_containers/food/snacks/meat/roachmeat/seuche
	preloaded_reagents = list("protein" = 4, "seligitillin" = 8, "diplopterum" = 6)

/obj/item/reagent_containers/food/snacks/meat/roachmeat/panzer
	preloaded_reagents = list("protein" = 8, "blattedin" = 12, "starkellin" = 15, "diplopterum" = 4)

/obj/item/reagent_containers/food/snacks/meat/roachmeat/fuhrer
	preloaded_reagents = list("protein" = 6, "seligitillin" = 6, "fuhrerole" = 12, "diplopterum" = 6)

/obj/item/reagent_containers/food/snacks/meat/roachmeat/kaiser
	preloaded_reagents = list("protein" = 6, "blattedin" = 12, "seligitillin" = 6, "starkellin" = 15, "fuhrerole" = 12, "diplopterum" = 6)

/obj/item/reagent_containers/food/snacks/meat/roachmeat/jager
	preloaded_reagents = list("protein" = 6, "blattedin" = 6, "gewaltine" = 8, "diplopterum" = 2)

/obj/item/reagent_containers/food/snacks/meat/roachmeat/kraftwerk 
	preloaded_reagents = list("protein" = 6, "blattedin" = 6, "gewaltine" = 6, "uncap nanites" = 2, "nanites" = 3)

/obj/item/reagent_containers/food/snacks/meat/spider
	desc = "A bloated slab of sickly-green meat cut from a spider. The venom just gives it more flavor. Delicious!"
	icon_state = "xenomeat"
	filling_color = "#E2FFDE"

	bitesize = 6
	preloaded_reagents = list("protein" = 7, "pararein" = 12)

/obj/item/reagent_containers/food/snacks/meat/spider/hunter
	desc = "A bloated slab of sickly-green meat cut from a spider. The venom just gives it more flavor. Delicious!"
	icon_state = "xenomeat"
	filling_color = "#E2FFDE"

	bitesize = 6
	preloaded_reagents = list("protein" = 9, "aranecolmin" = 8, "pararein" = 2)

/obj/item/reagent_containers/food/snacks/meat/spider/nurse
	desc = "A bloated slab of sickly-green meat cut from a spider. The venom just gives it more flavor. Delicious!"
	icon_state = "xenomeat"
	filling_color = "#E2FFDE"
	
	bitesize = 6
	preloaded_reagents = list("protein" = 8, "pararein" = 8)

/obj/item/reagent_containers/food/snacks/meat/carp
	name = "carp fillet"
	desc = "A juicy fillet cut from a carp. The potent and powerful venom they produce just gives it a unique tang. Delicious!"
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"
	center_of_mass = list("x"=17, "y"=13)
	bitesize = 6
	preloaded_reagents = list("protein" = 8, "carpotoxin" = 8)

/obj/item/reagent_containers/food/snacks/meat/bearmeat
	name = "bear meat"
	desc = "A slab of meat so manly you can almost smell the concentrated testosterone in it."
	icon_state = "bearmeat"
	filling_color = "#DB0000"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=10)
	preloaded_reagents = list("protein" = 12, "hyperzine" = 5)

/obj/item/reagent_containers/food/snacks/meat/xenomeat
	name = "meat"
	desc = "A fatty cut of bright-green meat. The overwhelmingly powerful smell of the acid within burns your sinuses and makes your eyes water."
	icon_state = "xenomeat"
	filling_color = "#43DE18"
	bitesize = 6
	center_of_mass = list("x"=16, "y"=10)
	preloaded_reagents = list("protein" = 6, "pacid" = 6)

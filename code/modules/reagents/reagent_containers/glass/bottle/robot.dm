/obj/item/reagent_containers/glass/bottle/robot
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle-4"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100)
	volume = 60
	spawn_tags = null
	var/reagent = ""


/obj/item/reagent_containers/glass/bottle/robot/inaprovaline
	name = "internal inaprovaline bottle"
	desc = "A small bottle. Contains inaprovaline - used to stabilize patients."
	reagent = "inaprovaline"

	New()
		..()
		reagents.add_reagent("inaprovaline", 60)


/obj/item/reagent_containers/glass/bottle/robot/antitoxin
	name = "internal anti-toxin bottle"
	desc = "A small bottle of Anti-toxins. Counters poisons, and repairs damage, a wonder drug."
	reagent = "anti_toxin"

	New()
		..()
		reagents.add_reagent("anti_toxin", 60)

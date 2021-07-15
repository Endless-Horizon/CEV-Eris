//hunters have the most poison and move the fastest, so they can find prey
/mob/living/carbon/superior_animal/giant_spider/hunter
	name = "Sokuryou Spider"
	desc = "A massive widow spider. This arachnid skitters around deftly, and an unknown liquid drips from its fangs."
	icon_state = "hunter"
	icon_living = "hunter"
	maxHealth = 90
	health = 90
	melee_damage_lower = 10
	melee_damage_upper = 20
	poison_per_bite = 5
	move_to_delay = 4
	meat_type = /obj/item/reagent_containers/food/snacks/meat/spider/hunter
	meat_amount = 4
	rarity_value = 75

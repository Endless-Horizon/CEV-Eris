
/*
 * Lunchbox
 */

/obj/item/storage/lunchbox
	name = "heart lunchbox"
	desc = "With love."
	icon_state = "lunchbox_heart"
	item_state = "lunchbox_heart"
	w_class = ITEM_SIZE_NORMAL
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = DEFAULT_NORMAL_STORAGE
	attack_verb = "lunched"

	can_hold = list(
		/obj/item/reagent_containers/food
		)

/obj/item/storage/lunchbox/rainbow
	name = "rainbow lunchbox"
	desc = "Rainbow bow."
	icon_state = "lunchbox_rainbow"
	item_state = "lunchbox_rainbow"

/obj/item/storage/lunchbox/cat
	name = "cat lunchbox"
	desc = "Meowbox."
	icon_state = "lunchbox_cat"
	item_state = "lunchbox_cat"
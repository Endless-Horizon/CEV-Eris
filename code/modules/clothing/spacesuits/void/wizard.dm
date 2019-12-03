//Wizard Rig
/obj/item/clothing/head/helmet/space/void/wizard
	name = "gem-encrusted voidsuit helmet"
	desc = "A bizarre gem-encrusted helmet that radiates magical energies."
	icon_state = "rig0-wiz"
	item_state_slots = list(
		slot_l_hand_str = "wiz_helm",
		slot_r_hand_str = "wiz_helm",
		)
	unacidable = 1 //No longer shall our kind be foiled by lone chemists with spray bottles!
	armor = list(
		melee = ARMOR_MELEE_LARGE,
		bullet = ARMOR_BULLET_LARGE,
		energy = ARMOR_ENERGY_SMALL,
		bomb = ARMOR_BOMB_SMALL,
		bio = ARMOR_BIO_IMMUNE,
		rad = ARMOR_RAD_MAJOR
	)
	siemens_coefficient = 0.7

/obj/item/clothing/suit/space/void/wizard
	icon_state = "rig-wiz"
	name = "gem-encrusted voidsuit"
	desc = "A bizarre gem-encrusted suit that radiates strange energy readings."
	item_state = "wiz_voidsuit"
	slowdown = 1
	unacidable = 1
	armor = list(
		melee = ARMOR_MELEE_LARGE,
		bullet = ARMOR_BULLET_LARGE,
		energy = ARMOR_ENERGY_SMALL,
		bomb = ARMOR_BOMB_SMALL,
		bio = ARMOR_BIO_IMMUNE,
		rad = ARMOR_RAD_MAJOR
	)
	siemens_coefficient = 0.7

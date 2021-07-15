/obj/item/computer_hardware/tesla_link
	name = "tesla link"
	desc = "An advanced tesla link that wirelessly recharges connected device from nearby area power controller."
	icon_state = "teslalink"
	hardware_size = 1
	matter = list(MATERIAL_STEEL = 1, MATERIAL_PLASTIC = 1, MATERIAL_GOLD = 1)
	origin_tech = list(TECH_DATA = 2, TECH_POWER = 3, TECH_ENGINEERING = 2)
	price_tag = 200
	rarity_value = 5.55
	var/passive_charging_rate = 250			// W

// CPU that allows the computer to run programs.
// Better CPUs are obtainable via research and can run more programs on background.

/obj/item/computer_hardware/processor_unit
	name = "standard processor board"
	desc = "A CPU board used in most computers. It can run up to three programs simultaneously."
	icon_state = "cpuboard"
	matter = list(MATERIAL_STEEL = 1, MATERIAL_PLASTIC = 2)
	matter_reagents = list("silicon" = 20)
	hardware_size = 2
	power_usage = 50
	critical = TRUE
	malfunction_probability = 1
	origin_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 2)
	rarity_value = 8.33

	var/max_programs = 3

/obj/item/computer_hardware/processor_unit/small
	name = "standard microprocessor"
	desc = "A miniaturised CPU used in most portable devices. It can run up to two programs simultaneously."
	icon_state = "cpu"
	matter = list(MATERIAL_STEEL = 1, MATERIAL_PLASTIC = 1)
	hardware_size = 1
	power_usage = 25
	max_programs = 2


/obj/item/computer_hardware/processor_unit/adv
	name = "advanced processor board"
	desc = "An advanced CPU board. It can run up to four programs simultaneously."
	icon_state = "cpuboard_adv"
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2)
	matter_reagents = list("silicon" = 30)
	power_usage = 100
	max_programs = 4
	price_tag = 80
	rarity_value = 16.66
	origin_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 3)

/obj/item/computer_hardware/processor_unit/adv/small
	name = "advanced microprocessor"
	desc = "An advanced CPU for use in portable devices. It can run up to three programs simultaneously."
	icon_state = "cpu_adv"
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 1)
	hardware_size = 1
	power_usage = 40
	max_programs = 3
	rarity_value = 12.5


/obj/item/computer_hardware/processor_unit/super
	name = "photonic processor board"
	desc = "A photonic CPU board prototype. It can run up to five programs simultaneously, but uses a lot of power."
	icon_state = "cpuboard_super"
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2, MATERIAL_GLASS = 2, MATERIAL_PLASMA = 2)
	matter_reagents = list("silicon" = 40)
	hardware_size = 2
	power_usage = 250
	max_programs = 5
	origin_tech = list(TECH_DATA = 5, TECH_ENGINEERING = 4)
	price_tag = 200
	rarity_value = 50

/obj/item/computer_hardware/processor_unit/super/small
	name = "photonic microprocessor"
	desc = "A photonic CPU prototype for portable devices. It can run up to four programs simultaneously."
	icon_state = "cpu_super"
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 1, MATERIAL_GLASS = 2, MATERIAL_PLASMA = 2)
	hardware_size = 1
	power_usage = 75
	max_programs = 4
	rarity_value = 50

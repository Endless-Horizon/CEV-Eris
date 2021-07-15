/obj/item/computer_hardware/led
	name = "light emitting diode"
	desc = "Little bit of circuitry that emits light when a current is passed through it."
	icon_state = "led"
	power_usage = 45 //W
	enabled = FALSE
	matter = list(MATERIAL_STEEL = 1, MATERIAL_PLASTIC = 1)
	matter_reagents = list("silicon" = 5)
	var/brightness_power = 1
	var/brightness_range = 3
	var/brightness_color = "#e5f3ff" //LEDs has slightly blue tint

/obj/item/computer_hardware/led/enabled()
	if (holder2)
		holder2.set_light()

/obj/item/computer_hardware/led/disabled()
	if (holder2)
		holder2.set_light()


/obj/item/computer_hardware/led/adv
	name = "heavy duty LED"
	desc = "A large LED assembly with metal cooling fins. Can be installed in a PDA."
	icon_state = "led_adv"
	power_usage = 90
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 2)
	matter_reagents = list("silicon" = 10)
	brightness_power = 2
	brightness_range = 4

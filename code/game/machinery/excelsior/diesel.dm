// this generator works with reagent instead of sheets.

/obj/machinery/power/port_gen/pacman/diesel
	name = "diesel generator"
	icon = 'icons/obj/machines/excelsior/generator.dmi'
	icon_state = "base"
	circuit = /obj/item/electronics/circuitboard/diesel
	max_fuel_volume = 300
	power_gen = 16000 // produces 20% less watts output per power level setting.
	time_per_fuel_unit = 12

	reagent_flags = OPENCONTAINER
	use_reagents_as_fuel = TRUE

/obj/machinery/power/port_gen/pacman/diesel/on_update_icon()
	cut_overlays()
	if(active)
		add_overlays("on")
		if(HasFuel())
			add_overlays("rotor_working")
			add_overlays("[max(round(reagents.total_volume / reagents.maximum_volume, 0.25) * 100, 25)]")
		else
			add_overlays("0")
	else
		add_overlays("off")

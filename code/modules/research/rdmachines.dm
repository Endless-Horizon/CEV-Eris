//Devices that link into the R&D console fall into thise type for easy identification and some shared procs.
/obj/machinery/r_n_d
	name = "R&D Device"
	icon = 'icons/obj/machines/research.dmi'
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	use_power = IDLE_POWER_USE
	var/obj/machinery/computer/rdconsole/linked_console

/obj/machinery/r_n_d/attack_hand(mob/user)
	return


//All lathe-type devices that link into the R&D console fall into thise type for easy identification and some shared procs
/obj/machinery/autolathe/rnd
	queue_max = 16

	have_disk = FALSE
	have_recycling = FALSE
	have_design_selector = FALSE
	low_quality_print = FALSE

	var/obj/machinery/computer/rdconsole/linked_console

/obj/machinery/autolathe/rnd/Destroy()
	if(linked_console)
		if(linked_console.linked_lathe == src)
			linked_console.linked_lathe = null
		if(linked_console.linked_imprinter == src)
			linked_console.linked_imprinter = null
		linked_console = null
	return ..()


/obj/machinery/autolathe/rnd/protolathe
	name = "protolathe"
	desc = "A machine used for construction of advanced prototypes. Operated from an R\&D console."
	icon_state = "protolathe"
	circuit = /obj/item/electronics/circuitboard/protolathe

	build_type = PROTOLATHE
	storage_capacity = 120


/obj/machinery/autolathe/rnd/imprinter
	name = "circuit imprinter"
	desc = "A machine used for printing advanced circuit boards. Operated from an R\&D console."
	icon_state = "imprinter"
	circuit = /obj/item/electronics/circuitboard/circuit_imprinter

	build_type = IMPRINTER
	storage_capacity = 60
	speed = 3


// Versions with some materials already loaded, to be used on map spawn
/obj/machinery/autolathe/rnd/protolathe/loaded
	stored_material = list(
		MATERIAL_STEEL = 60,
		MATERIAL_GLASS = 60,
		MATERIAL_PLASTIC = 60
		)


/obj/machinery/autolathe/rnd/imprinter/loaded
	stored_material = list(
		MATERIAL_STEEL = 30,
		MATERIAL_PLASTIC = 30
		)

/obj/machinery/autolathe/rnd/imprinter/loaded/Initialize()
	. = ..()
	container = new /obj/item/reagent_containers/glass/beaker/silicon(src)

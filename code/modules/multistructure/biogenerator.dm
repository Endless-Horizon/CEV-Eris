

//Power biomatter generator
//This machine use biomatter reagent and some of O2 to produce power (it also produce CO2)
//It has a few components that can be weared out, so operator should check this machine from time o time and tinker it
//In this case, our multistructure datum not just holder, but core of our machine and process by its own

#define WEAROUT_CHANCE 10

/datum/multistructure/biogenerator
	structure = list(
		list(/obj/machinery/multistructure/biogenerator_part/generator, /obj/machinery/multistructure/biogenerator_part/console, /obj/machinery/multistructure/biogenerator_part/port)
					)
	var/obj/machinery/multistructure/biogenerator_part/console/screen
	var/obj/machinery/multistructure/biogenerator_part/port/port
	var/obj/machinery/multistructure/biogenerator_part/generator/generator

	var/working = FALSE
	var/last_output_power = 0		//used at UI


/datum/multistructure/biogenerator/init()
	..()
	START_PROCESSING(SSprocessing, src)


/datum/multistructure/biogenerator/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()


/datum/multistructure/biogenerator/connect_elements()
	..()
	screen 		= locate() in elements
	port 		= locate() in elements
	generator	= locate() in elements


/datum/multistructure/biogenerator/is_operational()
	. = ..()
	if(!.)
		return FALSE

	if(!generator.core || !generator.chamber)
		return FALSE
	if(!generator.core.coil_condition || !generator.core.powernet || !generator.chamber.wires || !generator.chamber.wires_integrity)
		return FALSE

	if(!generator.chamber.network1 || !generator.chamber.network2 || !generator.chamber.air1 || !generator.chamber.air2)
		return FALSE
	if(generator.chamber.air1.gas["oxygen"] < 1)
		return FALSE

	if(port.pipes_dirtiness == 5 || !port.tank || !port.tank.reagents.has_reagent("biomatter", 1))
		return FALSE

	return TRUE


/datum/multistructure/biogenerator/Process()
	if(!is_operational() && working)
		deactivate()
	if(working)
		//amount of removed biomatter depends on how our pipes clean
		//amount of produced power is also depends on how many biomatter we got
		var/biomatter_amount = 1/max(1, port.pipes_dirtiness)
		port.tank.reagents.remove_reagent("biomatter", biomatter_amount)
		generator.chamber.consume_and_produce()
		var/output_power = 100000

		//port wearout
		port.working_cycles++
		if(port.working_cycles >= port.wearout_cycle && prob(WEAROUT_CHANCE))
			port.pipes_dirtiness++

		//chamber wearout
		generator.chamber.working_cycles++
		if(generator.chamber.working_cycles >= generator.chamber.wearout_cycle && prob(WEAROUT_CHANCE))
			generator.chamber.wires_integrity--

		//core wearout
		//water consumption
		generator.core.working_cycles++
		if(generator.core.working_cycles >= generator.core.wearout_cycle && prob(WEAROUT_CHANCE))
			generator.core.coil_condition--


		var/chamber_contribution = (output_power/2) / 100 * generator.chamber.wires_integrity
		var/core_contribution = (output_power/2) / 100 * generator.core.coil_condition
		output_power = (chamber_contribution + core_contribution) * biomatter_amount
		generator.core.add_avail(output_power)
		last_output_power = output_power
	screen.metrics_update(src)


/datum/multistructure/biogenerator/proc/activate()
	generator.icon_state 		= "generator-working"
	generator.core.icon_state 	= "core-working"
	port.icon_state 			= "port-working"
	working = TRUE


/datum/multistructure/biogenerator/proc/deactivate()
	generator.icon_state 		= initial(generator.icon_state)
	generator.core.icon_state 	= initial(generator.core.icon_state)
	port.icon_state 			= initial(port.icon_state)
	working = FALSE
	last_output_power = 0



/obj/machinery/multistructure/biogenerator_part
	name = "biogenerator part"
	icon = 'icons/obj/machines/biogenerator.dmi'
	anchored = TRUE
	density = TRUE
	MS_type = /datum/multistructure/biogenerator


//Our console. Displays metrics
/obj/machinery/multistructure/biogenerator_part/console
	name = "biogenerator screen"
	icon_state = "screen-working"

	//we store it here and update with special proc
	var/list/metrics = list("operational" = FALSE,
							"output_power" = 0,
							"O2_input" = FALSE,
							"CO2_output" = FALSE,
							"tank" = FALSE,
							"tank_bio_amount" = 0,
							"pipes_condition" = 0,
							"coil_condition" = 0,
							"powernet_detected" = FALSE,
							"wires" = FALSE,
							"wires_integrity" = 0)


/obj/machinery/multistructure/biogenerator_part/console/proc/metrics_update(var/datum/multistructure/biogenerator/master)
	metrics["operational"] = master.is_operational()
	metrics["output_power"] = master.last_output_power
	if(master.generator && master.generator.chamber && master.generator.chamber.air1 && master.generator.chamber.air1.gas["oxygen"] >= 1)
		metrics["O2_input"] = TRUE
	else
		metrics["O2_input"] = FALSE
	if(master.generator && master.generator.chamber && master.generator.chamber.air2 && master.generator.chamber.network2)
		metrics["CO2_output"] = TRUE
	else
		metrics["CO2_output"] = FALSE
	if(master.port)
		if(master.port.tank)
			metrics["tank"] = TRUE
			metrics["tank_bio_amount"] = master.port.tank.reagents.get_reagent_amount("biomatter")
		else
			metrics["tank"] = FALSE
		metrics["pipes_condition"] = master.port.pipes_dirtiness
	if(master.generator && master.generator.core)
		metrics["coil_condition"] = master.generator.core.coil_condition
		if(master.generator.core.powernet)
			metrics["powernet_detected"] = TRUE
		else
			metrics["powernet_detected"] = FALSE
	if(master.generator && master.generator.chamber)
		if(master.generator.chamber.wires)
			metrics["wires"] = TRUE
			metrics["wires_integrity"] = master.generator.chamber.wires_integrity
		else
			metrics["wires"] = FALSE


/obj/machinery/multistructure/biogenerator_part/console/attack_hand(mob/user as mob)
	if(MS)
		return ui_interact(user)

//UI
/obj/machinery/multistructure/biogenerator_part/console/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = GLOB.default_state)
	var/list/data = metrics


	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "nt_biogen.tmpl", src.name, 400, 400, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)


//Port. Here we connect any biomatter tanks
/obj/machinery/multistructure/biogenerator_part/port
	name = "biogenerator port"
	icon_state = "port"
	density = FALSE
	var/obj/structure/reagent_dispensers/tank
	var/working_cycles = 0
	var/wearout_cycle = 1200
	var/pipes_dirtiness = 0


/obj/machinery/multistructure/biogenerator_part/port/update_icon()
	overlays.Cut()
	if(panel_open)
		overlays += "port-opened"
		if(pipes_dirtiness)
			if(pipes_dirtiness == 1)
				overlays += "port_dirty_low"
			else if(pipes_dirtiness <= 3)
				overlays += "port_dirty_medium"
			else
				overlays += "port_dirty_full"


/obj/machinery/multistructure/biogenerator_part/port/examine(mob/user)
	. = ..()
	if(panel_open)
		if(pipes_dirtiness)
			to_chat(user, SPAN_WARNING("You see a layers of a solid biomass here."))
		else
			to_chat(user, SPAN_NOTICE("You didn't see any signs of biomass here. Pipes are clear."))


/obj/machinery/multistructure/biogenerator_part/port/attackby(var/obj/item/I, var/mob/user)
	var/tool_type = I.get_tool_type(user, list(QUALITY_BOLT_TURNING, QUALITY_SCREW_DRIVING, QUALITY_PRYING), src)
	switch(tool_type)
		if(QUALITY_BOLT_TURNING)
			if(panel_open)
				to_chat(user, SPAN_WARNING("You should close cover first."))
				return
			if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_VERY_EASY,  required_stat = STAT_MEC))
				if(tank)
					tank.anchored = FALSE
					tank = null
					playsound(src, 'sound/machines/airlock_ext_open.ogg', 60, 1)
					to_chat(user, SPAN_NOTICE("You detached [tank] from [src]."))
				else
					tank = locate(/obj/structure/reagent_dispensers) in get_turf(src)
					if(tank)
						tank.anchored = TRUE
						playsound(src, 'sound/machines/airlock_ext_close.ogg', 60, 1)
						to_chat(user, SPAN_NOTICE("You attached [tank] to [src]."))

		if(QUALITY_SCREW_DRIVING)
			if(tank)
				to_chat(user, SPAN_WARNING("You need to detach [tank] first."))
				return
			if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_EASY,  required_stat = STAT_MEC, forced_sound = WORKSOUND_SCREW_DRIVING))
				panel_open = !panel_open
				to_chat(user, SPAN_NOTICE("You [panel_open ? "open" : "close"] the panel."))

		if(QUALITY_PRYING)
			if(panel_open)
				to_chat(user, SPAN_NOTICE("You begin deconstructing [src]..."))
				if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_NORMAL,  required_stat = STAT_MEC))
					dismantle()

	if(panel_open && (istype(I, /obj/item/weapon/soap) || istype(I, /obj/item/weapon/reagent_containers/glass/rag)))
		if(pipes_dirtiness)
			pipes_dirtiness--
			if(pipes_dirtiness < 0)
				pipes_dirtiness = 0
			if(pipes_dirtiness >= 4)
				spill_biomass(loc, cardinal)
				toxin_attack(user, rand(20, 30))
			to_chat(user, SPAN_NOTICE("You clean the pipes."))
			if(!pipes_dirtiness)
				working_cycles = 0
		else
			to_chat(user, SPAN_WARNING("Pipes are already clean."))
	update_icon()



//Generator. Just a dummy, cause all magic do it's chamber and core
//We use two various machines. Chamber from atmospherics (because it's has all gas manipulation dark magic)
//And core from power. (Same for power)
/obj/machinery/multistructure/biogenerator_part/generator
	name = "biogenerator"
	icon_state = "generator"
	layer = BELOW_OBJ_LAYER
	var/obj/machinery/atmospherics/binary/biogen_chamber/chamber
	var/obj/machinery/power/biogenerator_core/core


/obj/machinery/multistructure/biogenerator_part/generator/New()
	. = ..()
	chamber 	= new(loc)
	chamber.generator = src
	core 		= new(loc)
	core.generator = src


/obj/machinery/multistructure/biogenerator_part/generator/Destroy()
	if(chamber)
		chamber.generator = null
		qdel(chamber)
		chamber = null
	if(core)
		core.generator = null
		qdel(core)
		core = null
	return ..()


/obj/machinery/atmospherics/binary/biogen_chamber
	name = "biogenerator chambers"
	icon = 'icons/obj/machines/biogenerator.dmi'
	icon_state = "chambers"
	anchored = TRUE
	layer = LOW_OBJ_LAYER
	var/obj/machinery/multistructure/biogenerator_part/generator/generator
	var/working_cycles = 0
	var/wearout_cycle = 500
	var/wires_integrity = 100
	var/wires = TRUE


/obj/machinery/atmospherics/binary/biogen_chamber/Destroy()
	if(generator)
		var/obj/machinery/multistructure/biogenerator_part/generator/gen = generator
		generator.chamber = null
		generator = null
		qdel(gen)
	return ..()


/obj/machinery/atmospherics/binary/biogen_chamber/update_icon()
	if(panel_open)
		if(wires)
			icon_state = "chambers-wires"
		else
			icon_state = "chambers-wireless"
	else
		icon_state = initial(icon_state)


/obj/machinery/atmospherics/binary/biogen_chamber/examine(mob/user)
	. = ..()
	if(panel_open)
		if(wires)
			if(!wires_integrity)
				to_chat(user, SPAN_WARNING("All wiring is damaged and not functional."))
			else if(wires_integrity < 30)
				to_chat(user, SPAN_WARNING("Wiring is completly burnt. But somehow it's still functional."))
			else if(wires_integrity < 50)
				to_chat(user, SPAN_WARNING("Wiring is damaged, most of cables are burnt."))
			else if(wires_integrity < 80)
				to_chat(user, SPAN_NOTICE("Wiring is slightly damaged and some of them are burnt."))
			else
				to_chat(user, SPAN_NOTICE("Wiring looks like new."))
		else
			to_chat(user, SPAN_WARNING("There are no wires here."))


/obj/machinery/atmospherics/binary/biogen_chamber/attackby(var/obj/item/I, var/mob/user)
	var/tool_type = I.get_tool_type(user, list(QUALITY_SCREW_DRIVING, QUALITY_WIRE_CUTTING), src)
	switch(tool_type)
		if(QUALITY_SCREW_DRIVING)
			if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_EASY,  required_stat = STAT_MEC, forced_sound = WORKSOUND_SCREW_DRIVING))
				panel_open = !panel_open
				to_chat(user, SPAN_NOTICE("You [panel_open ? "open" : "close"] the cover."))

		if(QUALITY_WIRE_CUTTING)
			if(panel_open)
				if(wires)
					var/datum/multistructure/biogenerator/biogenerator = generator.MS
					if(biogenerator.working)
						shock(user, 100)
						return
					if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_EASY,  required_stat = STAT_MEC, forced_sound = WORKSOUND_WIRECUTTING))
						wires = FALSE
						to_chat(user, SPAN_NOTICE("You cut old wires."))
				else
					to_chat(user, SPAN_WARNING("There are no wires here."))
			else
				to_chat(user, SPAN_WARNING("You need open cover first."))

	if(istype(I, /obj/item/stack/cable_coil))
		if(!panel_open)
			to_chat(user, SPAN_WARNING("Cover is closed."))
			return
		if(wires)
			to_chat(user, SPAN_WARNING("You should cut old wires first."))
			return
		var/obj/item/stack/cable_coil/cables = I
		if(cables.use(10))
			wires_integrity = 100
			working_cycles = 0
			wires = TRUE
		else
			to_chat(user, SPAN_WARNING("You need atleast 10 cables to replace wiring."))
	update_icon()


//in this proc we consume O2 and produce CO2
/obj/machinery/atmospherics/binary/biogen_chamber/proc/consume_and_produce()
	var/gas_output_temperature = 0
	if(air1 && air2)
		if(air1.gas["oxygen"])
			air1.gas["oxygen"] -= 1
			gas_output_temperature = air1.temperature + rand(20, 30)
			air1.update_values()
			air2.adjust_gas_temp("carbon_dioxide", 1, gas_output_temperature)
			network1.update = TRUE
			network2.update = TRUE


/obj/machinery/power/biogenerator_core
	name = "biogenerator core"
	icon = 'icons/obj/machines/biogenerator.dmi'
	icon_state = "core"
	anchored = TRUE
	layer = LOW_OBJ_LAYER
	var/obj/machinery/multistructure/biogenerator_part/generator/generator
	var/coil_condition = 100
	var/working_cycles = 0
	var/wearout_cycle = 600
	var/coil_frame = TRUE


/obj/machinery/power/biogenerator_core/Initialize()
	. = ..()
	connect_to_network()


/obj/machinery/power/biogenerator_core/Destroy()
	disconnect_from_network()
	if(generator)
		var/obj/machinery/multistructure/biogenerator_part/generator/gen = generator
		generator.core = null
		generator = null
		qdel(gen)
	return ..()


/obj/machinery/power/biogenerator_core/update_icon()
	if(!coil_frame)
		icon_state = "core-frameless"
		return
	icon_state = initial(icon_state)


/obj/machinery/power/biogenerator_core/examine(mob/user)
	. = ..()
	if(!coil_condition)
		to_chat(user, SPAN_WARNING("Coil is completly burnt."))
	else if(coil_condition < 30)
		to_chat(user, SPAN_WARNING("Most of coil's sectors are burnt, but it's still functional."))
	else if(coil_condition < 50)
		to_chat(user, SPAN_WARNING("Half of coil's sectors are damaged."))
	else if(coil_condition < 80)
		to_chat(user, SPAN_NOTICE("You can see damaged sectors at [src]'s coil."))
	else
		to_chat(user, SPAN_NOTICE("Coil looks like new."))


/obj/machinery/power/biogenerator_core/attackby(var/obj/item/I, var/mob/user)
	var/datum/multistructure/biogenerator/biogenerator = generator.MS
	if(biogenerator.working)
		shock(user, 100)
		return

	var/tool_type = I.get_tool_type(user, list(QUALITY_SCREW_DRIVING, QUALITY_WELDING), src)
	switch(tool_type)
		if(QUALITY_SCREW_DRIVING)
			if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_EASY,  required_stat = STAT_MEC, forced_sound = WORKSOUND_SCREW_DRIVING))
				if(coil_frame)
					coil_frame = FALSE
					to_chat(user, SPAN_NOTICE("You carefully unfasten frame of [src]."))
				else
					coil_frame = TRUE
					to_chat(user, SPAN_NOTICE("You fastened frame of [src] back."))

		if(QUALITY_WELDING)
			if(coil_frame)
				to_chat(user, SPAN_WARNING("You need to remove that frame first!"))
				return
			if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_NORMAL,  required_stat = STAT_MEC))
				to_chat(user, SPAN_NOTICE("You fixed damaged sectors of [src]'s coil."))
				coil_condition = 100
				working_cycles = 0

	update_icon()


/obj/machinery/power/biogenerator_core/attack_hand(mob/user as mob)
	var/datum/multistructure/biogenerator/biogenerator = generator.MS
	if(biogenerator.working)
		shock(user, 100)


#undef WEAROUT_CHANCE
/**********************Unloading unit**************************/


/obj/machinery/mineral/unloading_machine
	name = "unloading machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"
	density = TRUE
	anchored = TRUE
	var/input_dir = null
	var/output_dir = null


/obj/machinery/mineral/unloading_machine/New()
	..()
	spawn()
		//Locate our output and input machinery.
		var/obj/marker = null
		marker = locate(/obj/landmark/machinery/input) in range(1, loc)
		if(marker)
			input_dir = get_dir(src, marker)
		marker = locate(/obj/landmark/machinery/output) in range(1, loc)
		if(marker)
			output_dir = get_dir(src, marker)

/obj/machinery/mineral/unloading_machine/Process()
	if(output_dir && input_dir)
		var/turf/input = get_step(src, input_dir)
		var/obj/structure/ore_box/BOX = locate() in input
		if(BOX)
			var/turf/output = get_step(src, output_dir)
			var/i = 0
			for(var/obj/item/ore/O in BOX.contents)
				O.forceMove(output)
				if(++i>=10)
					return

		if(locate(/obj/item) in input)
			var/obj/item/O
			for(var/i = 0; i<10; i++)
				O = locate(/obj/item) in input
				if(O)
					O.forceMove(get_step(src, output_dir))
				else
					break

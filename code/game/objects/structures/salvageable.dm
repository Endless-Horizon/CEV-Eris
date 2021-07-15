/obj/structure/salvageable
	name = "broken macninery"
	desc = "Broken beyond repair, but looks like you can still salvage something from this."
	icon = 'icons/obj/salvageable.dmi'
	density = TRUE
	anchored = TRUE
	bad_type = /obj/structure/salvageable
	spawn_frequency = 13
	spawn_tags = SPAWN_TAG_SALVAGEABLE
	var/salvageable_parts = list()

/obj/structure/salvageable/proc/dismantle()
	new /obj/machinery/constructable_frame/machine_frame (src.loc)
	for(var/path in salvageable_parts)
		if(prob(salvageable_parts[path]))
			new path (loc)
	return

/obj/structure/salvageable/attackby(obj/item/I, mob/user)
	if(I.get_tool_type(usr, list(QUALITY_PRYING), src))
		to_chat(user, SPAN_NOTICE("You start salvage anything useful from \the [src]."))
		if(I.use_tool(user, src, WORKTIME_LONG, QUALITY_PRYING, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
			dismantle()
			qdel(src)
			return

//Types themself, use them, but not the parent object

/obj/structure/salvageable/machine
	name = "broken machine"
	icon_state = "machine"
	salvageable_parts = list(
		/obj/item/stock_parts/console_screen = 80,
		/obj/item/stack/cable_coil{amount = 5} = 80,
		/obj/item/trash/material/circuit = 60,
		/obj/item/trash/material/metal = 60,
		/obj/item/stock_parts/capacitor = 40,
		/obj/item/stock_parts/capacitor = 40,
		/obj/item/stock_parts/scanning_module = 40,
		/obj/item/stock_parts/scanning_module = 40,
		/obj/item/stock_parts/manipulator = 40,
		/obj/item/stock_parts/manipulator = 40,
		/obj/item/stock_parts/micro_laser = 40,
		/obj/item/stock_parts/micro_laser = 40,
		/obj/item/stock_parts/matter_bin = 40,
		/obj/item/stock_parts/matter_bin = 40,
		/obj/item/stock_parts/capacitor/adv = 20,
		/obj/item/stock_parts/scanning_module/adv = 20,
		/obj/item/stock_parts/manipulator/nano = 20,
		/obj/item/stock_parts/micro_laser/high = 20,
		/obj/item/stock_parts/matter_bin/adv = 20,
		/obj/item/stock_parts/manipulator/pico = 5,
		/obj/item/stock_parts/matter_bin/super = 5,
		/obj/item/stock_parts/micro_laser/ultra = 5,
		/obj/item/stock_parts/scanning_module/phasic = 5
	)

/obj/structure/salvageable/machine/Initialize()
	. = ..()
	icon_state = "machine[rand(0,6)]"

/obj/structure/salvageable/computer
	name = "broken computer"
	icon_state = "computer"
	rarity_value = 16
	salvageable_parts = list(
		/obj/item/stock_parts/console_screen = 80,
		/obj/item/stack/cable_coil{amount = 5} = 90,
		/obj/item/stack/material/glass{amount = 5} = 90,
		/obj/item/trash/material/circuit = 60,
		/obj/item/trash/material/metal = 60,
		/obj/item/stock_parts/capacitor = 60,
		/obj/item/stock_parts/capacitor = 60,
		/obj/item/computer_hardware/network_card = 40,
		/obj/item/computer_hardware/network_card = 40,
		/obj/item/computer_hardware/processor_unit = 40,
		/obj/item/computer_hardware/processor_unit = 40,
		/obj/item/computer_hardware/card_slot = 40,
		/obj/item/computer_hardware/card_slot = 40,
		/obj/item/stock_parts/capacitor/adv = 30,
		/obj/item/computer_hardware/network_card/advanced = 20,
		/obj/item/stock_parts/capacitor/super = 5
	)

/obj/structure/salvageable/computer/Initialize()
	. = ..()
	icon_state = "computer[rand(0,7)]"

/obj/structure/salvageable/autolathe
	name = "broken autolathe"
	icon_state = "autolathe"
	spawn_tags = SPAWN_TAG_SALVAGEABLE_AUTOLATHE
	salvageable_parts = list(
		/obj/item/stock_parts/console_screen = 80,
		/obj/item/stack/cable_coil{amount = 5} = 80,
		/obj/item/trash/material/circuit = 60,
		/obj/item/trash/material/metal = 60,
		/obj/item/stock_parts/capacitor = 40,
		/obj/item/stock_parts/scanning_module = 40,
		/obj/item/stock_parts/manipulator = 40,
		/obj/item/stock_parts/micro_laser = 40,
		/obj/item/stock_parts/micro_laser = 40,
		/obj/item/stock_parts/micro_laser = 40,
		/obj/item/stock_parts/matter_bin = 40,
		/obj/item/stock_parts/matter_bin = 40,
		/obj/item/stock_parts/matter_bin = 40,
		/obj/item/stock_parts/matter_bin = 40,
		/obj/item/stock_parts/capacitor/adv = 20,
		/obj/item/stock_parts/micro_laser/high = 20,
		/obj/item/stock_parts/micro_laser/high = 20,
		/obj/item/stock_parts/matter_bin/adv = 20,
		/obj/item/stock_parts/matter_bin/adv = 20,
		/obj/item/electronics/circuitboard/autolathe = 5,
		/obj/item/stack/material/steel{amount = 20} = 40,
		/obj/item/stack/material/glass{amount = 20} = 40,
		/obj/item/stack/material/plastic{amount = 20} = 40,
		/obj/item/stack/material/plasteel{amount = 10} = 40,
		/obj/item/stack/material/silver{amount = 10} = 20,
		/obj/item/stack/material/gold{amount = 10} = 20,
		/obj/item/stack/material/plasma{amount = 10} = 20,
		/obj/item/stack/material/uranium{amount = 3} = 5,
		/obj/item/stack/material/diamond{amount = 1} = 1
	)

/obj/structure/salvageable/implant_container
	name = "old container"
	icon_state = "implant-container"
	rarity_value = 33
	salvageable_parts = list(
		/obj/item/stock_parts/console_screen = 80,
		/obj/item/stack/cable_coil{amount = 5} = 80,
		/obj/item/trash/material/circuit = 60,
		/obj/item/trash/material/metal = 60,
		/obj/item/implant/death_alarm = 15,
		/obj/item/implant/explosive = 10,
		/obj/item/implant/freedom = 5,
		/obj/item/implant/tracking = 10,
		/obj/item/implant/chem = 10,
		/obj/item/organ/external/robotic/l_arm = 20,
		/obj/item/organ/external/robotic/r_arm = 20,
		/obj/item/organ/external/robotic/l_leg = 20,
		/obj/item/organ/external/robotic/r_leg = 20,
		/obj/item/organ/external/robotic/groin = 10,
		/obj/item/implantcase = 30,
		/obj/item/implanter = 30,
		/obj/item/stack/material/steel{amount = 10} = 30,
		/obj/item/stack/material/glass{amount = 10} = 30,
		/obj/item/stack/material/silver{amount = 10} = 30
	)

obj/structure/salvageable/implant_container/Initialize()
	. = ..()
	icon_state = "implant_container[rand(0,1)]"

/obj/structure/salvageable/data
	name = "broken data storage"
	icon_state = "data"
	rarity_value = 16
	salvageable_parts = list(
		/obj/item/stock_parts/console_screen = 80,
		/obj/item/stack/cable_coil{amount = 5} = 90,
		/obj/item/stack/material/glass{amount = 5} = 90,
		/obj/item/trash/material/circuit = 60,
		/obj/item/trash/material/metal = 60,
		/obj/item/computer_hardware/network_card = 40,
		/obj/item/computer_hardware/network_card = 40,
		/obj/item/computer_hardware/processor_unit = 40,
		/obj/item/computer_hardware/processor_unit = 40,
		/obj/item/computer_hardware/hard_drive = 50,
		/obj/item/computer_hardware/hard_drive = 50,
		/obj/item/computer_hardware/hard_drive = 50,
		/obj/item/computer_hardware/hard_drive = 50,
		/obj/item/computer_hardware/hard_drive = 50,
		/obj/item/computer_hardware/hard_drive = 50,
		/obj/item/computer_hardware/hard_drive/advanced = 30,
		/obj/item/computer_hardware/hard_drive/advanced = 30,
		/obj/item/computer_hardware/network_card/advanced = 20
	)

obj/structure/salvageable/data/Initialize()
	. = ..()
	icon_state = "data[rand(0,1)]"

/obj/structure/salvageable/server
	name = "broken server"
	icon_state = "server"
	rarity_value = 16
	salvageable_parts = list(
		/obj/item/stock_parts/console_screen = 80,
		/obj/item/stack/cable_coil{amount = 5} = 90,
		/obj/item/stack/material/glass{amount = 5} = 90,
		/obj/item/trash/material/circuit = 60,
		/obj/item/trash/material/metal = 60,
		/obj/item/computer_hardware/network_card = 40,
		/obj/item/computer_hardware/network_card = 40,
		/obj/item/computer_hardware/processor_unit = 40,
		/obj/item/computer_hardware/processor_unit = 40,
		/obj/item/stock_parts/subspace/amplifier = 40,
		/obj/item/stock_parts/subspace/amplifier = 40,
		/obj/item/stock_parts/subspace/analyzer = 40,
		/obj/item/stock_parts/subspace/analyzer = 40,
		/obj/item/stock_parts/subspace/ansible = 40,
		/obj/item/stock_parts/subspace/ansible = 40,
		/obj/item/stock_parts/subspace/transmitter = 40,
		/obj/item/stock_parts/subspace/transmitter = 40,
		/obj/item/stock_parts/subspace/crystal = 30,
		/obj/item/stock_parts/subspace/crystal = 30,
		/obj/item/computer_hardware/network_card/advanced = 20
	)

obj/structure/salvageable/server/Initialize()
	. = ..()
	icon_state = "server[rand(0,1)]"

/obj/structure/salvageable/personal
	name = "personal terminal"
	icon_state = "personal"
	rarity_value = 20
	salvageable_parts = list(
		/obj/item/stock_parts/console_screen = 90,
		/obj/item/stack/cable_coil{amount = 5} = 90,
		/obj/item/computer_hardware/led = 40,
		/obj/item/computer_hardware/led/adv = 40,
		/obj/item/stack/material/glass{amount = 5} = 70,
		/obj/item/trash/material/circuit = 60,
		/obj/item/trash/material/metal = 60,
		/obj/item/computer_hardware/network_card = 60,
		/obj/item/computer_hardware/network_card/advanced = 40,
		/obj/item/computer_hardware/network_card/wired = 40,
		/obj/item/computer_hardware/card_slot = 40,
		/obj/item/computer_hardware/processor_unit = 60,
		/obj/item/computer_hardware/processor_unit/small = 50,
		/obj/item/computer_hardware/processor_unit/adv = 40,
		/obj/item/computer_hardware/processor_unit/adv/small = 30,
		/obj/item/computer_hardware/hard_drive = 60,
		/obj/item/computer_hardware/hard_drive/advanced = 40,
		/obj/spawner/lathe_disk = 40,
		/obj/spawner/lathe_disk/advanced = 10,
	)

obj/structure/salvageable/personal/Initialize()
	. = ..()
	icon_state = "personal[rand(0,12)]"
	new /obj/structure/table/reinforced (loc)

/obj/structure/salvageable/bliss
	name = "strange terminal"
	icon_state = "bliss"
	rarity_value = 100
	salvageable_parts = list(
		/obj/item/stock_parts/console_screen = 90,
		/obj/item/stack/cable_coil{amount = 5} = 90,
		/obj/item/computer_hardware/processor_unit/adv = 60,
		/obj/item/computer_hardware/hard_drive/cluster = 50,
		/obj/item/computer_hardware/hard_drive/portable/advanced/shady = 50,
		/obj/item/computer_hardware/hard_drive/portable/advanced/nuke = 50,
		/obj/item/stock_parts/capacitor/excelsior = 5,
		/obj/item/stock_parts/scanning_module/excelsior = 5,
		/obj/item/stock_parts/manipulator/excelsior = 5,
		/obj/item/stock_parts/micro_laser/excelsior = 5
	)

obj/structure/salvageable/bliss/Initialize()
	. = ..()
	icon_state = "bliss[rand(0,1)]"

/obj/structure/salvageable/bliss/attackby(obj/item/I, mob/user)
	if(I.get_tool_type(usr, list(QUALITY_PRYING), src))
		to_chat(user, SPAN_NOTICE("You start salvage anything useful from \the [src]."))
		if(I.use_tool(user, src, WORKTIME_LONG, QUALITY_PRYING, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
			playsound(user, 'sound/machines/shutdown.ogg', 60, 1)
			dismantle()
			qdel(src)
			return

//////////////////
//// ONE STAR ////
//////////////////
/obj/structure/salvageable/os
	spawn_tags = SPAWN_TAG_SALVAGEABLE_OS
	rarity_value = 20
	spawn_blacklisted = TRUE
	bad_type = /obj/structure/salvageable/os

/obj/structure/salvageable/os/machine
	name = "broken machine"
	icon_state = "os-machine"
	salvageable_parts = list(
		/obj/item/stock_parts/console_screen = 80,
		/obj/item/stack/cable_coil{amount = 5} = 80,
		/obj/item/stock_parts/capacitor/one_star = 40,
		/obj/item/stock_parts/capacitor/one_star = 40,
		/obj/item/stock_parts/scanning_module/one_star = 40,
		/obj/item/stock_parts/scanning_module/one_star = 40,
		/obj/item/stock_parts/manipulator/one_star = 40,
		/obj/item/stock_parts/manipulator/one_star = 40,
		/obj/item/stock_parts/micro_laser/one_star = 40,
		/obj/item/stock_parts/micro_laser/one_star = 40,
		/obj/item/stock_parts/matter_bin/one_star = 40,
		/obj/item/stock_parts/matter_bin/one_star = 40,
		/obj/spawner/prothesis_one_star = 20
	)

/obj/structure/salvageable/os/computer
	name = "broken computer"
	icon_state = "os-computer"
	rarity_value = 33
	salvageable_parts = list(
		/obj/item/stock_parts/console_screen = 80,
		/obj/item/stack/cable_coil{amount = 5} = 90,
		/obj/item/stack/material/glass{amount = 5} = 90,
		/obj/item/stock_parts/capacitor/one_star = 60,
		/obj/item/stock_parts/capacitor/one_star = 60,
		/obj/item/computer_hardware/processor_unit/super = 40,
		/obj/item/computer_hardware/processor_unit/super = 40,
		/obj/item/computer_hardware/card_slot = 40,
		/obj/item/computer_hardware/card_slot = 40,
		/obj/item/computer_hardware/network_card/advanced = 40
	)

/obj/structure/salvageable/os/implant_container
	name = "old container"
	icon_state = "os-container"
	rarity_value = 66
	salvageable_parts = list(
		/obj/item/stock_parts/console_screen = 80,
		/obj/item/stack/cable_coil{amount = 5} = 80,
		/obj/item/implant/death_alarm = 30,
		/obj/item/implant/explosive = 20,
		/obj/item/implant/freedom = 20,
		/obj/item/implant/tracking = 30,
		/obj/item/implant/chem = 30,
		/obj/item/organ/external/robotic/l_arm = 20,
		/obj/item/organ/external/robotic/r_arm = 20,
		/obj/item/organ/external/robotic/l_leg = 20,
		/obj/item/organ/external/robotic/r_leg = 20,
		/obj/item/organ/external/robotic/groin = 10,
		/obj/item/implantcase = 30,
		/obj/item/implanter = 30
	)

/obj/structure/salvageable/os/data
	name = "broken data storage"
	icon_state = "os-data"
	rarity_value = 33
	salvageable_parts = list(
		/obj/item/stock_parts/console_screen = 90,
		/obj/item/stack/cable_coil{amount = 5} = 90,
		/obj/item/stack/material/glass{amount = 5} = 90,
		/obj/item/computer_hardware/processor_unit/adv = 60,
		/obj/item/computer_hardware/processor_unit/super = 50,
		/obj/item/computer_hardware/hard_drive/super = 50,
		/obj/item/computer_hardware/hard_drive/super = 50,
		/obj/item/computer_hardware/hard_drive/cluster = 50,
		/obj/item/computer_hardware/network_card/wired = 40
	)

/obj/structure/salvageable/os/server
	name = "broken server"
	icon_state = "os-server"
	rarity_value = 33
	salvageable_parts = list(
		/obj/item/stock_parts/console_screen = 80,
		/obj/item/stack/cable_coil{amount = 5} = 90,
		/obj/item/stack/material/glass{amount = 5} = 90,
		/obj/item/computer_hardware/network_card/wired = 40,
		/obj/item/computer_hardware/network_card/wired = 40,
		/obj/item/computer_hardware/processor_unit/super = 40,
		/obj/item/computer_hardware/processor_unit/super = 40,
		/obj/item/stock_parts/subspace/amplifier = 40,
		/obj/item/stock_parts/subspace/amplifier = 40,
		/obj/item/stock_parts/subspace/analyzer = 40,
		/obj/item/stock_parts/subspace/analyzer = 40,
		/obj/item/stock_parts/subspace/ansible = 40,
		/obj/item/stock_parts/subspace/ansible = 40,
		/obj/item/stock_parts/subspace/transmitter = 40,
		/obj/item/stock_parts/subspace/transmitter = 40,
		/obj/item/stock_parts/subspace/crystal = 30,
		/obj/item/stock_parts/subspace/crystal = 30,
		/obj/item/computer_hardware/network_card/wired = 20
	)

/obj/structure/salvageable/os/console
	name = "pristine console"
	desc = "Despite being in pristine condition this console doesn't respond to anything, but looks like you can still salvage something from this."
	icon_state = "os_console"
	rarity_value = 66
	salvageable_parts = list(
		/obj/item/computer_hardware/hard_drive/portable/research_points = 90,
		/obj/item/computer_hardware/hard_drive/portable/research_points/rare = 45,
		/obj/item/stack/cable_coil{amount = 5} = 90,
		/obj/item/stock_parts/console_screen = 80,
		/obj/item/stock_parts/capacitor/one_star = 60,
		/obj/item/stock_parts/capacitor/one_star = 60,
		/obj/item/computer_hardware/processor_unit/super = 40,
		/obj/item/computer_hardware/processor_unit/super = 40,
		/obj/item/computer_hardware/card_slot = 40,
		/obj/item/computer_hardware/card_slot = 40,
		/obj/item/computer_hardware/network_card/advanced = 40
	)

/obj/structure/salvageable/os/console_broken
	name = "broken console"
	icon_state = "os_console_broken"
	rarity_value = 33
	salvageable_parts = list(
		/obj/item/computer_hardware/hard_drive/portable/research_points = 50,
		/obj/item/computer_hardware/hard_drive/portable/research_points/rare = 25,
		/obj/item/stack/cable_coil{amount = 5} = 90,
		/obj/item/stock_parts/console_screen = 80,
		/obj/item/stock_parts/capacitor/one_star = 60,
		/obj/item/stock_parts/capacitor/one_star = 60,
		/obj/item/computer_hardware/processor_unit/super = 40,
		/obj/item/computer_hardware/processor_unit/super = 40,
		/obj/item/computer_hardware/card_slot = 40,
		/obj/item/computer_hardware/card_slot = 40,
		/obj/item/computer_hardware/network_card/advanced = 40
	)

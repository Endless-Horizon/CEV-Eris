/datum/craft_recipe/tool
	category = "Tools"
	time = 100
	related_stats = list(STAT_COG)


/datum/craft_recipe/tool/webtape
	name = "Web tape"
	result = /obj/item/tool/tape_roll/web
	steps = list(
		list(/obj/item/stack/medical/bruise_pack/handmade, 3, "time" = 50),
		list(/obj/effect/spider/stickyweb, 1, "time" = 30)
	)

//A shard of glass wrapped in tape makes a crude sort of knife
/datum/craft_recipe/tool/shiv
	name = "Shiv"
	result = /obj/item/tool/shiv
	steps = list(
		list(/obj/item/material/shard, 1, "time" = 30),
		list(QUALITY_ADHESIVE, 15, 70)
	)

//A rod wrapped in tape makes a crude screwthing
/datum/craft_recipe/tool/screwpusher
	name = "Screwpusher"
	result = /obj/item/tool/screwdriver/improvised
	steps = list(
		list(/obj/item/stack/rods, 1, "time" = 30),
		list(QUALITY_ADHESIVE, 15, 70)
	)

//Rods bent into wierd shapes and held together with a screw
/datum/craft_recipe/tool/wiremanglers
	name = "Wiremanglers"
	result = /obj/item/tool/wirecutters/improvised
	steps = list(
		list(/obj/item/stack/rods, 1, "time" = 30),
		list(QUALITY_PRYING, 10, 70),
		list(/obj/item/stack/rods, 1, "time" = 30),
		list(QUALITY_PRYING, 10, 70),
		list(QUALITY_SCREW_DRIVING, 10, 70),
	)


//A pair of rods laboriously twisted into a useful shape
/datum/craft_recipe/tool/rebar
	name = "Rebar"
	result = /obj/item/tool/crowbar/improvised
	steps = list(
		list(/obj/item/stack/rods, 2, "time" = 300)
	)


//A metal sheet with some holes cut in it
/datum/craft_recipe/tool/sheetspanner
	name = "Sheet spanner"
	result = /obj/item/tool/wrench/improvised
	steps = list(
		list(CRAFT_MATERIAL, 1, MATERIAL_STEEL),
		list(QUALITY_SAWING, 10, 70)
	)


//A rod and a sheet bound together with ducks
/datum/craft_recipe/tool/junkshovel
	name = "Junk shovel"
	result = /obj/item/tool/shovel/improvised
	steps = list(
		list(CRAFT_MATERIAL, 1, MATERIAL_STEEL),
		list(/obj/item/stack/rods, 1, 30),
		list(QUALITY_ADHESIVE, 15, 150)
	)


//A rod with bits of pointy shrapnel stuck to it. Good weapon
/datum/craft_recipe/tool/choppa
	name = "Choppa"
	result = /obj/item/tool/saw/improvised
	steps = list(
		list(/obj/item/stack/rods, 1, 30),
		list(QUALITY_CUTTING, 15, 150)
	)

//Some pipes duct taped together, attached to a tank and an igniter
/datum/craft_recipe/tool/jurytorch
	name = "Jury-rigged torch"
	result = /obj/item/tool/weldingtool/improvised
	steps = list(
		list(/obj/item/device/assembly/igniter, 1),
		list(/obj/item/tank/emergency_oxygen, 1),
		list(QUALITY_ADHESIVE, 15, 100),
		list(QUALITY_SCREW_DRIVING, 10, 40)
	)

/datum/craft_recipe/tool/toolimplant
	name = "Multitool implant"
	result = /obj/item/organ_module/active/multitool/improvised
	steps = list(
		list(/obj/item/storage/toolbox, 1),
		list(/obj/item/electronics/circuitboard, 1),
		list(/obj/item/organ/external/robotic, 1),
		list(/obj/item/stack/cable_coil, 5, "time" = 20),
		list(/obj/item/tool/shiv, 1),
		list(/obj/item/tool/screwdriver/improvised, 1),
		list(/obj/item/tool/wirecutters/improvised, 1),
		list(/obj/item/tool/crowbar/improvised, 1),
		list(/obj/item/tool/wrench/improvised, 1),
		list(/obj/item/tool/shovel/improvised, 1),
		list(/obj/item/tool/saw/improvised, 1),
		list(/obj/item/tool/weldingtool/improvised, 1),
		list(QUALITY_ADHESIVE, 15, 70)
	)

/*************************
	TOOL MODS
*************************/
//Metal rods reinforced with fiber tape
/datum/craft_recipe/tool/brace
	name = "Tool mod: Brace bar"
	result = /obj/item/tool_upgrade/reinforcement/stick
	steps = list(
		list(/obj/item/stack/rods, 3, 30),
		list(CRAFT_MATERIAL, 5, MATERIAL_PLASTEEL),
		list(QUALITY_ADHESIVE, 50, 150)
	)



//A metal plate with bolts drilled and wrenched into it
/datum/craft_recipe/tool/plate
	name = "Tool mod: reinforcement plate"
	result = /obj/item/tool_upgrade/reinforcement/plating
	steps = list(
		list(CRAFT_MATERIAL, 5, MATERIAL_PLASTEEL),
		list(QUALITY_DRILLING, 10, 150),
		list(/obj/item/stack/rods, 2, 30),
		list(QUALITY_BOLT_TURNING, 10, 150),
	)


//An array of sharpened bits of metal to turn a tool into more of a weapon
/datum/craft_recipe/tool/spikes
	name = "Tool mod: Spikes"
	result = /obj/item/tool_upgrade/augment/spikes
	steps = list(
		list(/obj/item/stack/rods, 2, 30),
		list(QUALITY_WELDING, 10, 150),
		list(CRAFT_MATERIAL, 3, MATERIAL_PLASTEEL),
		list(QUALITY_WELDING, 10, 150),
	)


//just a clamp with a flat surface to hammer something
/datum/craft_recipe/tool/hammer_addon
	name = "Tool mod: Flat surface"
	result = /obj/item/tool_upgrade/augment/hammer_addon
	steps = list(
		list(/obj/item/stack/rods, 2, 30),
		list(QUALITY_WELDING, 10, 150),
		list(CRAFT_MATERIAL, 3, MATERIAL_PLASTEEL),
		list(QUALITY_WELDING, 10, 150),
	)

//An improvised adapter to fit a larger power cell. This is pretty fancy as crafted items go
//Requires an APC frame, a fuckton of wires, a large cell, and several tools
/datum/craft_recipe/tool/cell_mount
	name = "Tool mod: Heavy cell mount"
	result = /obj/item/tool_upgrade/augment/cell_mount
	steps = list(
		list(/obj/item/frame/apc, 2, "time" = 30),			//hull
		list(QUALITY_SCREW_DRIVING, 10, "time" = 40),		//prepare hull
		list(CRAFT_MATERIAL, 3, MATERIAL_PLASTEEL),			//additional frame to support wires
		list(QUALITY_WELDING, 10, "time" = 70),				//secure frame
		list(/obj/item/stack/cable_coil, 30, "time" = 10),	//add wiring
		list(QUALITY_WIRE_CUTTING, 10, "time" = 60),		//adjust wiring
		list(/obj/item/cell/large, 1),				//cell for parts
		list(QUALITY_SAWING, 10, "time" = 70),				//The large cell is disassembled for parts
		list(QUALITY_WELDING, 10, "time" = 70),				//weld parts in place
	)

//Welding backpack disassembled into a smaller tank
/datum/craft_recipe/tool/fuel_tank
	name = "Tool mod: Expanded fuel tank"
	result = /obj/item/tool_upgrade/augment/fuel_tank

	steps = list(
		list(/obj/item/weldpack, 1, "time" = 30),
		list(QUALITY_SAWING, 10, "time" = 120),//Disassemble the backpack
		list(QUALITY_BOLT_TURNING, 10, 40), //And open some valves
	)

/datum/craft_recipe/tool/makeshift_centrifuge
	name = "Manual centrifuge"
	result = /obj/item/device/makeshift_centrifuge

	steps = list(
		list(CRAFT_MATERIAL, 4, MATERIAL_STEEL),
		list(QUALITY_SAWING, 10, "time" = 80),
		list(/obj/item/stack/rods, 2, 30),
		list(QUALITY_WIRE_CUTTING, 10, 20),
		list(QUALITY_WELDING, 10, "time" = 70)
	)

/datum/craft_recipe/tool/makeshift_grinder
	name = "Mortar and pestle"
	result = /obj/item/storage/makeshift_grinder

	steps = list(
		list(CRAFT_MATERIAL, 2, MATERIAL_STEEL),
		list(QUALITY_WIRE_CUTTING, 10, 20),
		list(QUALITY_PRYING, 10, 80),
		list(/obj/item/stack/rods, 1, 30)
	)

/datum/craft_recipe/tool/makeshift_electrolyser
	name = "Makeshift electrolyser"
	result = /obj/item/device/makeshift_electrolyser

	steps = list(
		list(CRAFT_MATERIAL, 2, MATERIAL_STEEL),
		list(QUALITY_WIRE_CUTTING, 10, 20),
		list(/obj/item/stack/cable_coil, 30, "time" = 10),
		list(QUALITY_WIRE_CUTTING, 10, 20),
		list(/obj/item/stack/rods, 2, 30)
	)

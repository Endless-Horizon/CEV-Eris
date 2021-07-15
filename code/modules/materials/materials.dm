/*
	MATERIAL DATUMS
	This data is used by various parts of the game for basic physical properties and behaviors
	of the metals/materials used for constructing many objects. Each var is commented and should be pretty
	self-explanatory but the various object types may have their own documentation. ~Z

	PATHS THAT USE DATUMS
		turf/simulated/wall
		obj/item/material
		obj/structure/barricade
		obj/item/stack/material
		obj/structure/table

	VALID ICONS
		WALLS
			stone
			metal
			solid
			cult
		DOORS
			stone
			metal
			resin
			wood
*/

// Assoc list containing all material datums indexed by name.
var/list/name_to_material

//Returns the material the object is made of, if applicable.
//Will we ever need to return more than one value here? Or should we just return the "dominant" material.
/obj/proc/get_material()
	return null

//mostly for convenience
/obj/proc/get_material_name()
	var/material/material = get_material()
	if(material)
		return material.name

// Builds the datum list above.
/proc/populate_material_list(force_remake=0)
	if(name_to_material && !force_remake) return // Already set up!
	name_to_material = list()
	for(var/type in typesof(/material) - /material)
		var/material/new_mineral = new type
		if(!new_mineral.name)
			continue
		name_to_material[lowertext(new_mineral.name)] = new_mineral
	return 1

// Safety proc to make sure the material list exists before trying to grab from it.
/proc/get_material_by_name(name)
	if(!name_to_material)
		populate_material_list()
	var/material/M = name_to_material[lowertext(name)]
	if(!M)
		error("Invalid material given: [name]")
	return M

/proc/get_material_name_by_stack_type(stype)
	if(!name_to_material)
		populate_material_list()

	for(var/name in name_to_material)
		var/material/M = name_to_material[name]
		if(M.stack_type == stype)
			return M.name
	return null

/proc/material_display_name(name)
	var/material/material = get_material_by_name(name)
	if(material)
		return material.display_name
	return null

/proc/material_stack_type(name)
	var/material/material = get_material_by_name(name)
	if(material)
		return material.stack_type
	return null

// Material definition and procs follow.
/material
	var/name	                          // Unique name for use in indexing the list.
	var/display_name                      // Prettier name for display.
	var/use_name
	var/flags = 0                         // Various status modifiers.
	var/sheet_singular_name = "sheet"
	var/sheet_plural_name = "sheets"

	// Shards/tables/structures
	var/shard_type = SHARD_SHRAPNEL       // Path of debris object.
	var/shard_icon                        // Related to above.
	var/shard_can_repair = 1              // Can shards be turned into sheets with a welder?
	var/list/recipes                      // Holder for all recipes usable with a sheet of this material.
	var/destruction_desc = "breaks apart" // Fancy string for barricades/tables/objects exploding.

	// Icons
	var/icon_colour                                      // Colour applied to products of this material.
	var/icon_base = "metal"                              // Wall and table base icon tag. See header.
	var/door_icon_base = "metal"                         // Door base icon tag. See header.
	var/icon_reinf = "reinf_metal"                       // Overlay used
	var/list/stack_origin_tech = list(TECH_MATERIAL = 1) // Research level for stacks.

	// Attributes
	var/cut_delay = 0            // Delay in ticks when cutting through this wall.
	var/radioactivity            // Radiation var. Used in wall and object processing to irradiate surroundings.
	var/ignition_point           // K, point at which the material catches on fire.
	var/melting_point = 1800     // K, walls will take damage if they're next to a fire hotter than this
	var/integrity = 150          // General-use HP value for products.
	var/opacity = 1              // Is the material transparent? 0.5< makes transparent walls/doors.
	var/explosion_resistance = 5 // Only used by walls currently.
	var/conductive = 1           // Objects with this var add CONDUCTS to flags on spawn.
	var/list/composite_material  // If set, object matter var will be a list containing these values.

	// Placeholder vars for the time being, todo properly integrate windows/light tiles/rods.
	var/created_window
	var/created_window_full
	var/rod_product
	var/wire_product
	var/list/window_options = list()

	// Damage values.
	var/hardness = 60            // Prob of wall destruction by hulk, used for edge damage in weapons.
	var/weight = 20              // Determines blunt damage/throwforce for weapons.

	// Noise when someone is faceplanted onto a table made of this material.
	var/tableslam_noise = 'sound/weapons/tablehit1.ogg'
	// Noise made when a simple door made of this material opens or closes.
	var/dooropen_noise = 'sound/effects/stonedoor_openclose.ogg'
	// Noise made when you hit structure made of this material.
	var/hitsound = 'sound/weapons/genhit.ogg'
	// Path to resulting stacktype. Todo remove need for this.
	var/stack_type
	// Wallrot crumble message.
	var/rotting_touch_message = "crumbles under your touch"

// Placeholders for light tiles and rglass.
/material/proc/build_rod_product(var/mob/user, var/obj/item/stack/used_stack, var/obj/item/stack/target_stack)
	if(!rod_product)
		to_chat(user, SPAN_WARNING("You cannot make anything out of \the [target_stack]"))
		return
	if(used_stack.get_amount() < 1 || target_stack.get_amount() < 1)
		to_chat(user, SPAN_WARNING("You need one rod and one sheet of [display_name] to make anything useful."))
		return
	used_stack.use(1)
	target_stack.use(1)
	var/obj/item/stack/S = new rod_product(get_turf(user))
	S.add_fingerprint(user)
	S.add_to_stacks(user)

/material/proc/build_wired_product(var/mob/user, var/obj/item/stack/used_stack, var/obj/item/stack/target_stack)
	if(!wire_product)
		to_chat(user, SPAN_WARNING("You cannot make anything out of \the [target_stack]"))
		return
	if(used_stack.get_amount() < 5 || target_stack.get_amount() < 1)
		to_chat(user, SPAN_WARNING("You need five wires and one sheet of [display_name] to make anything useful."))
		return

	used_stack.use(5)
	target_stack.use(1)
	to_chat(user, SPAN_NOTICE("You attach wire to the [name]."))
	var/obj/item/product = new wire_product(get_turf(user))
	if(!(user.l_hand && user.r_hand))
		user.put_in_hands(product)

// Make sure we have a display name and shard icon even if they aren't explicitly set.
/material/New()
	..()
	if(!display_name)
		display_name = name
	if(!use_name)
		use_name = display_name
	if(!shard_icon)
		shard_icon = shard_type

// This is a placeholder for proper integration of windows/windoors into the system.
/material/proc/build_windows(var/mob/living/user, var/obj/item/stack/used_stack)
	return 0

// Weapons handle applying a divisor for this value locally.
/material/proc/get_blunt_damage()
	return weight //todo

// Return the matter comprising this material.
/material/proc/get_matter()
	var/list/temp_matter = list()
	if(islist(composite_material))
		for(var/material_string in composite_material)
			temp_matter[material_string] = composite_material[material_string]
	else
		temp_matter[name] = 1
	return temp_matter

// As above.
/material/proc/get_edge_damage()
	return hardness //todo

// Snowflakey, only checked for alien doors at the moment.
/material/proc/can_open_material_door(var/mob/living/user)
	return 1

// Currently used for weapons and objects made of uranium to irradiate things.
/material/proc/products_need_process()
	return (radioactivity>0) //todo

// Used by walls when qdel()ing to avoid neighbor merging.
/material/placeholder
	name = "placeholder"

// Places a girder object when a wall is dismantled, also applies reinforced material.
/material/proc/place_dismantled_girder(target, material/reinf_material)
	var/obj/structure/girder/G = new(target)
	if(reinf_material)
		G.reinf_material = reinf_material
		G.reinforce_girder()

// Use this to drop a given amount of material.
/material/proc/place_material(target, amount=1)
	// Drop the integer amount of sheets
	if(place_sheet(target, round(amount)))
		amount -= round(amount)

	// If there is a remainder left, drop it as a shard instead
	if(amount)
		place_shard(target, amount)

// Debris product. Used ALL THE TIME.
/material/proc/place_sheet(target, amount=1)
	if(stack_type)
		return new stack_type(target, amount)

// As above.
/material/proc/place_shard(target, amount=1)
	if(shard_type)
		return new /obj/item/material/shard(target, src.name, amount)

// Used by walls and weapons to determine if they break or not.
/material/proc/is_brittle()
	return !!(flags & MATERIAL_BRITTLE)

/material/proc/combustion_effect(var/turf/T, var/temperature)
	return

// Datum definitions follow.
/material/uranium
	name = MATERIAL_URANIUM
	stack_type = /obj/item/stack/material/uranium
	radioactivity = 12
	icon_base = "stone"
	icon_reinf = "reinf_stone"
	icon_colour = "#007A00"
	weight = 22
	stack_origin_tech = list(TECH_MATERIAL = 5)
	door_icon_base = "stone"

/material/diamond
	name = MATERIAL_DIAMOND
	stack_type = /obj/item/stack/material/diamond
	flags = MATERIAL_UNMELTABLE
	cut_delay = 60
	icon_colour = "#00FFE1"
	opacity = 0.4
	shard_type = SHARD_SHARD
	tableslam_noise = 'sound/effects/Glasshit.ogg'
	hardness = 100
	stack_origin_tech = list(TECH_MATERIAL = 6)

/material/gold
	name = MATERIAL_GOLD
	stack_type = /obj/item/stack/material/gold
	icon_colour = "#EDD12F"
	weight = 24
	hardness = 40
	stack_origin_tech = list(TECH_MATERIAL = 4)
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"

/material/gold/bronze //placeholder for ashtrays
	name = "bronze"
	icon_colour = "#EDD12F"

/material/silver
	name = MATERIAL_SILVER
	stack_type = /obj/item/stack/material/silver
	icon_colour = "#D1E6E3"
	weight = 22
	hardness = 50
	stack_origin_tech = list(TECH_MATERIAL = 3)
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"

/material/plasma
	name = MATERIAL_PLASMA
	stack_type = /obj/item/stack/material/plasma
	ignition_point = PLASMA_MINIMUM_BURN_TEMPERATURE
	icon_base = "stone"
	icon_colour = "#FC2BC5"
	shard_type = SHARD_SHARD
	hardness = 30
	stack_origin_tech = list(TECH_MATERIAL = 2, TECH_PLASMA = 2)
	door_icon_base = "stone"
	sheet_singular_name = "crystal"
	sheet_plural_name = "crystals"

/*
// Commenting this out while fires are so spectacularly lethal, as I can't seem to get this balanced appropriately.
/material/plasma/combustion_effect(var/turf/T, var/temperature, var/effect_multiplier)
	if(isnull(ignition_point))
		return 0
	if(temperature < ignition_point)
		return 0
	var/totalPlasma = 0
	for(var/turf/simulated/floor/target_tile in RANGE_TURFS(2, T))
		var/plasmaToDeduce = (temperature/30) * effect_multiplier
		totalPlasma += plasmaToDeduce
		target_tile.assume_gas("plasma", plasmaToDeduce, 200+T0C)
		spawn (0)
			target_tile.hotspot_expose(temperature, 400)
	return round(totalPlasma/100)
*/

/material/stone
	name = MATERIAL_SANDSTONE
	stack_type = /obj/item/stack/material/sandstone
	icon_base = "stone"
	icon_reinf = "reinf_stone"
	icon_colour = "#D9C179"
	shard_type = SHARD_STONE_PIECE
	weight = 22
	hardness = 55
	door_icon_base = "stone"
	sheet_singular_name = "brick"
	sheet_plural_name = "bricks"

/material/stone/marble
	name = MATERIAL_MARBLE
	icon_colour = "#AAAAAA"
	weight = 26
	hardness = 100
	integrity = 201 //hack to stop kitchen benches being flippable, todo: refactor into weight system
	stack_type = /obj/item/stack/material/marble

/material/steel
	name = MATERIAL_STEEL
	stack_type = /obj/item/stack/material/steel
	integrity = 150
	icon_base = "solid"
	icon_reinf = "reinf_over"
	icon_colour = PLASTEEL_COLOUR
	hitsound = 'sound/weapons/genhit.ogg'

/material/steel/holographic
	name = "holo" + MATERIAL_STEEL
	display_name = MATERIAL_STEEL
	stack_type = null
	shard_type = SHARD_NONE

/material/plasteel
	name = MATERIAL_PLASTEEL
	stack_type = /obj/item/stack/material/plasteel
	integrity = 400
	melting_point = 6000
	icon_base = "solid"
	icon_reinf = "reinf_over"
	icon_colour = PLASTEEL_COLOUR//"#777777"
	explosion_resistance = 25
	hardness = 80
	weight = 23
	stack_origin_tech = list(TECH_MATERIAL = 2)
	hitsound = 'sound/weapons/genhit.ogg'

/material/plasteel/titanium
	name = "titanium"
	stack_type = null
	icon_base = "metal"
	door_icon_base = "metal"
	icon_colour = "#D1E6E3"
	icon_reinf = "reinf_metal"

/material/glass
	name = MATERIAL_GLASS
	stack_type = /obj/item/stack/material/glass
	flags = MATERIAL_BRITTLE
	icon_colour = "#00E1FF"
	opacity = 0.3
	integrity = 100
	shard_type = SHARD_SHARD
	tableslam_noise = 'sound/effects/Glasshit.ogg'
	hardness = 30
	weight = 15
	door_icon_base = "stone"
	destruction_desc = "shatters"
	window_options = list("One Direction" = 1, "Full Window" = 6)
	created_window = /obj/structure/window/basic
	created_window_full = /obj/structure/window/basic/full
	rod_product = /obj/item/stack/material/glass/reinforced
	hitsound = 'sound/effects/Glasshit.ogg'

/material/glass/build_windows(var/mob/living/user, var/obj/item/stack/used_stack)

	if(!user || !used_stack || !created_window || !window_options.len)
		return 0

	if(!user.IsAdvancedToolUser())
		to_chat(user, SPAN_WARNING("This task is too complex for your clumsy hands."))
		return 1

	var/turf/T = user.loc
	if(!istype(T))
		to_chat(user, SPAN_WARNING("You must be standing on open flooring to build a window."))
		return 1

	var/title = "Sheet-[used_stack.name] ([used_stack.get_amount()] sheet\s left)"
	var/choice = input(title, "What would you like to construct?") as null|anything in window_options

	if(!choice || !used_stack || !user || used_stack.loc != user || user.stat || user.loc != T)
		return 1

	// Get the closest available dir to the user's current facing.
	var/build_dir = SOUTHWEST //Default to southwest for fulltile windows.
	if(choice in list("One Direction","Windoor"))
		// Get data for building windows here.
		var/list/possible_directions = cardinal.Copy()
		var/window_count = 0
		for (var/obj/structure/window/check_window in user.loc)
			window_count++
			possible_directions  -= check_window.dir


		var/failed_to_build

		if(window_count >= 4)
			failed_to_build = 1
		else
			if(possible_directions.len)
				for(var/direction in list(user.dir, turn(user.dir,90), turn(user.dir,180), turn(user.dir,270) ))
					if(direction in possible_directions)
						build_dir = direction
						break
			else
				failed_to_build = 1
			if(!failed_to_build && choice == "Windoor")
				if(!is_reinforced())
					to_chat(user, SPAN_WARNING("This material is not reinforced enough to use for a door."))
					return
				if((locate(/obj/structure/windoor_assembly) in T.contents) || (locate(/obj/machinery/door/window) in T.contents))
					failed_to_build = 1

		if(failed_to_build)
			to_chat(user, SPAN_WARNING("There is no room in this location."))
			return 1

	else
		build_dir = SOUTHWEST
		//We're attempting to build a full window.
		//We need to find a suitable low wall to build ontop of
		var/obj/structure/low_wall/mount = null
		//We will check the tile infront of the user
		var/turf/t = get_step(T, user.dir)
		mount = locate(/obj/structure/low_wall) in t


		if (!mount)
			to_chat(user, SPAN_WARNING("Full windows must be mounted on a low wall infront of you."))
			return 1

		if (locate(/obj/structure/window) in t)
			to_chat(user, SPAN_WARNING("The target tile must be clear of other windows"))
			return 1

		//building will be successful, lets set the build location
		T = t

	var/build_path = /obj/structure/windoor_assembly
	var/sheets_needed = window_options[choice]
	if(choice == "Windoor")
		build_dir = user.dir
	else if (choice == "Full Window")
		build_path = created_window_full
	else
		build_path = created_window

	if(used_stack.get_amount() < sheets_needed)
		to_chat(user, SPAN_WARNING("You need at least [sheets_needed] sheets to build this."))
		return 1

	// Build the structure and update sheet count etc.
	used_stack.use(sheets_needed)
	var/obj/O = new build_path(T, build_dir)
	O.Created(user)
	return 1

/material/glass/proc/is_reinforced()
	return (hardness > 35) //todo

/material/glass/reinforced
	name = MATERIAL_RGLASS
	display_name = "reinforced glass"
	stack_type = /obj/item/stack/material/glass/reinforced
	flags = MATERIAL_BRITTLE
	icon_colour = "#00E1FF"
	opacity = 0.3
	integrity = 100
	shard_type = SHARD_SHARD
	tableslam_noise = 'sound/effects/Glasshit.ogg'
	hardness = 40
	weight = 30
	stack_origin_tech = "materials=2"
	composite_material = list(MATERIAL_STEEL = 2,MATERIAL_GLASS = 3)
	window_options = list("One Direction" = 1, "Full Window" = 6, "Windoor" = 5)
	created_window = /obj/structure/window/reinforced
	created_window_full = /obj/structure/window/reinforced/full
	wire_product = null
	rod_product = null

/material/glass/plasma
	name = MATERIAL_PLASMAGLASS
	display_name = "borosilicate glass"
	stack_type = /obj/item/stack/material/glass/plasmaglass
	flags = MATERIAL_BRITTLE
	integrity = 100
	icon_colour = "#FC2BC5"
	stack_origin_tech = list(TECH_MATERIAL = 4)
	created_window = /obj/structure/window/plasmabasic
	created_window_full = /obj/structure/window/plasmabasic/full
	wire_product = null
	rod_product = /obj/item/stack/material/glass/plasmarglass

/material/glass/plasma/reinforced
	name = MATERIAL_RPLASMAGLASS
	display_name = "reinforced borosilicate glass"
	stack_type = /obj/item/stack/material/glass/plasmarglass
	stack_origin_tech = list(TECH_MATERIAL = 5)
	composite_material = list() //todo
	created_window = /obj/structure/window/reinforced/plasma
	created_window_full = /obj/structure/window/reinforced/plasma/full
	hardness = 40
	weight = 30
	//composite_material = list() //todo
	rod_product = null

/material/plastic
	name = MATERIAL_PLASTIC
	stack_type = /obj/item/stack/material/plastic
	flags = MATERIAL_BRITTLE
	icon_base = "solid"
	icon_reinf = "reinf_over"
	icon_colour = "#CCCCCC"
	hardness = 10
	weight = 12
	melting_point = T0C+371 //assuming heat resistant plastic
	stack_origin_tech = list(TECH_MATERIAL = 3)

/material/plastic/holographic
	name = "holoplastic"
	display_name = "plastic"
	stack_type = null
	shard_type = SHARD_NONE

/material/osmium
	name = MATERIAL_OSMIUM
	stack_type = /obj/item/stack/material/osmium
	icon_colour = "#9999FF"
	stack_origin_tech = list(TECH_MATERIAL = 5)
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"

/material/tritium
	name = MATERIAL_TRITIUM
	stack_type = /obj/item/stack/material/tritium
	icon_colour = "#777777"
	stack_origin_tech = list(TECH_MATERIAL = 5)
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"

/material/mhydrogen
	name = MATERIAL_MHYDROGEN
	stack_type = /obj/item/stack/material/mhydrogen
	icon_colour = "#E6C5DE"
	stack_origin_tech = list(TECH_MATERIAL = 6, TECH_POWER = 6, TECH_MAGNET = 5)
	display_name = "metallic hydrogen"

/material/platinum
	name = MATERIAL_PLATINUM
	stack_type = /obj/item/stack/material/platinum
	icon_colour = "#9999FF"
	weight = 27
	stack_origin_tech = list(TECH_MATERIAL = 2)
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"

/material/iron
	name = MATERIAL_IRON
	stack_type = /obj/item/stack/material/iron
	icon_colour = "#5C5454"
	weight = 22
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"
	hitsound = 'sound/weapons/smash.ogg'

// Adminspawn only, do not let anyone get this.
/material/voxalloy
	name = "voxalloy"
	display_name = "durable alloy"
	stack_type = null
	icon_colour = "#6C7364"
	integrity = 1200
	melting_point = 6000       // Hull plating.
	explosion_resistance = 200 // Hull plating.
	hardness = 500
	weight = 500

/material/wood
	name = MATERIAL_WOOD
	stack_type = /obj/item/stack/material/wood
	icon_colour = "#824B28"
	integrity = 50
	icon_base = "solid"
	explosion_resistance = 2
	shard_type = SHARD_SPLINTER
	shard_can_repair = 0 // you can't weld splinters back into planks
	hardness = 15
	weight = 18
	melting_point = T0C+300 //okay, not melting in this case, but hot enough to destroy wood
	ignition_point = T0C+288
	stack_origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 1)
	dooropen_noise = 'sound/effects/doorcreaky.ogg'
	door_icon_base = "wood"
	destruction_desc = "splinters"
	sheet_singular_name = "plank"
	sheet_plural_name = "planks"
	hitsound = 'sound/effects/woodhit.ogg'

/material/wood/holographic
	name = "holowood"
	display_name = "wood"
	stack_type = null
	shard_type = SHARD_NONE

/material/cardboard
	name = MATERIAL_CARDBOARD
	stack_type = /obj/item/stack/material/cardboard
	flags = MATERIAL_BRITTLE
	integrity = 10
	icon_base = "solid"
	icon_reinf = "reinf_over"
	icon_colour = "#AAAAAA"
	hardness = 1
	weight = 1
	ignition_point = T0C+232 //"the temperature at which book-paper catches fire, and burns." close enough
	melting_point = T0C+232 //temperature at which cardboard walls would be destroyed
	stack_origin_tech = list(TECH_MATERIAL = 1)
	door_icon_base = "wood"
	destruction_desc = "crumples"

/material/cloth //todo
	name = MATERIAL_CLOTH
	stack_origin_tech = list(TECH_MATERIAL = 2)
	door_icon_base = "wood"
	ignition_point = T0C+232
	melting_point = T0C+300
	flags = MATERIAL_PADDING

/material/biomatter
	name = MATERIAL_BIOMATTER
	stack_type = /obj/item/stack/material/biomatter
	icon_colour = "#F48042"
	stack_origin_tech = list(TECH_MATERIAL = 2, TECH_BIO = 2)
	sheet_singular_name = "sheet"
	sheet_plural_name = "sheets"

/material/compressed
	name = MATERIAL_COMPRESSED
	stack_type = /obj/item/stack/material/compressed
	icon_colour = "#00E1FF"
	sheet_singular_name = "cartrigde"
	sheet_plural_name = "cartridges"

//TODO PLACEHOLDERS:
/material/leather
	name = MATERIAL_LEATHER
	icon_colour = "#5C4831"
	stack_origin_tech = list(TECH_MATERIAL = 2)
	flags = MATERIAL_PADDING
	ignition_point = T0C+300
	melting_point = T0C+300

/material/carpet
	name = "carpet"
	display_name = "comfy"
	use_name = "red upholstery"
	icon_colour = "#DA020A"
	flags = MATERIAL_PADDING
	ignition_point = T0C+232
	melting_point = T0C+300
	sheet_singular_name = "tile"
	sheet_plural_name = "tiles"

/material/cotton
	name = "cotton"
	display_name ="cotton"
	icon_colour = "#FFFFFF"
	flags = MATERIAL_PADDING
	ignition_point = T0C+232
	melting_point = T0C+300

/material/cloth_teal
	name = "teal"
	display_name ="teal"
	use_name = "teal cloth"
	icon_colour = "#00EAFA"
	flags = MATERIAL_PADDING
	ignition_point = T0C+232
	melting_point = T0C+300

/material/cloth_black
	name = "black"
	display_name = "black"
	use_name = "black cloth"
	icon_colour = "#505050"
	flags = MATERIAL_PADDING
	ignition_point = T0C+232
	melting_point = T0C+300

/material/cloth_green
	name = "green"
	display_name = "green"
	use_name = "green cloth"
	icon_colour = "#01C608"
	flags = MATERIAL_PADDING
	ignition_point = T0C+232
	melting_point = T0C+300

/material/cloth_puple
	name = "purple"
	display_name = "purple"
	use_name = "purple cloth"
	icon_colour = "#9C56C4"
	flags = MATERIAL_PADDING
	ignition_point = T0C+232
	melting_point = T0C+300

/material/cloth_blue
	name = "blue"
	display_name = "blue"
	use_name = "blue cloth"
	icon_colour = "#6B6FE3"
	flags = MATERIAL_PADDING
	ignition_point = T0C+232
	melting_point = T0C+300

/material/cloth_beige
	name = "beige"
	display_name = "beige"
	use_name = "beige cloth"
	icon_colour = "#E8E7C8"
	flags = MATERIAL_PADDING
	ignition_point = T0C+232
	melting_point = T0C+300

/material/cloth_lime
	name = "lime"
	display_name = "lime"
	use_name = "lime cloth"
	icon_colour = "#62E36C"
	flags = MATERIAL_PADDING
	ignition_point = T0C+232
	melting_point = T0C+300

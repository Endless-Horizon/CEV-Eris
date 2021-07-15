#define CYBORG_POWER_USAGE_MULTIPLIER 1.5 // Multiplier for amount of power cyborgs use.

/mob/living/silicon/robot
	name = "Cyborg"
	real_name = "Cyborg"
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	maxHealth = 200
	health = 200
	defaultHUD = "BorgStyle"
	mob_bump_flag = ROBOT
	mob_swap_flags = ROBOT|MONKEY|SLIME|SIMPLE_ANIMAL
	mob_push_flags = ~HEAVY //trundle trundle

	var/lights_on = FALSE // Is our integrated light on?
	var/used_power_this_tick = 0
	var/sight_mode = 0
	var/custom_name = ""
	var/custom_sprite = 0 //Due to all the sprites involved, a var for our custom borgs may be best
	var/crisis //Admin-settable for combat module use.
	var/crisis_override = 0
	var/integrated_light_power = 6
	var/datum/wires/robot/wires
	var/ai_access = TRUE
	var/power_efficiency = 1


	mob_size = MOB_LARGE

//Icon stuff

	var/icontype 				//Persistent icontype tracking allows for cleaner icon updates
	var/list/module_sprites = list() 		//Used to store the associations between sprite names and sprite index.
	var/icon_selected = 1		//If icon selection has been completed yet

//Hud stuff

/*	var/obj/screen/cells = null
	var/obj/screen/inv1 = null
	var/obj/screen/inv2 = null
	var/obj/screen/inv3 = null*/

	var/shown_robot_modules = 0 //Used to determine whether they have the module menu shown or not
	var/obj/screen/robot_modules_background

//3 Modules can be activated at any one time.
	var/obj/item/robot_module/module = null
	var/module_active = null
	var/module_state_1 = null
	var/module_state_2 = null
	var/module_state_3 = null

	var/obj/item/device/radio/borg/radio = null
	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/cell/large/cell
	var/obj/machinery/camera/camera = null
	var/obj/item/tank/jetpack/synthetic/jetpack = null

	var/cell_emp_mult = 2

	// Components are basically robot organs.
	var/list/components = list()

	var/obj/item/device/mmi/mmi = null

	var/obj/item/stock_parts/matter_bin/storage = null

	var/opened = FALSE
	var/emagged = FALSE
	var/wiresexposed = FALSE
	var/locked = TRUE
	var/has_power = 1
	var/death_notified = FALSE

	var/list/req_access = list(access_robotics)
	var/ident = 0
	//var/list/laws = list()
	var/viewalerts = 0
	var/modtype = "Default"
	var/lower_mod = 0
	var/datum/effect/effect/system/ion_trail_follow/ion_trail = null
	var/datum/effect/effect/system/spark_spread/spark_system//So they can initialize sparks whenever/N
	var/jeton = 0
	var/killswitch = 0
	var/killswitch_time = 60
	var/weapon_lock = 0
	var/weaponlock_time = 120
	var/lawupdate = TRUE //Cyborgs will sync their laws with their AI by default
	var/lockcharge //Used when locking down a borg to preserve cell charge
	var/speed = 0.25
	var/scrambledcodes = 0 // Used to determine if a borg shows up on the robotics console.  Setting to one hides them.
	var/tracking_entities = 0 //The number of known entities currently accessing the internal camera
	var/braintype = "Cyborg"
	var/intenselight = 0	// Whether cyborg's integrated light was upgraded

	var/list/robot_verbs_default = list(
		/mob/living/silicon/robot/proc/sensor_mode,
		/mob/living/silicon/robot/proc/robot_checklaws
	)

/mob/living/silicon/robot/New(loc,var/unfinished = 0)
	spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	add_language(LANGUAGE_ROBOT, 1)

	wires = new(src)

	robot_modules_background = new(_name = "storage")
	robot_modules_background.icon_state = "block"
	//Objects that appear on screen are on layer ABOVE_HUD_LAYER, UI should be just below it.
	robot_modules_background.layer = HUD_LAYER
	robot_modules_background.plane = HUD_PLANE

	ident = rand(1, 999)
	module_sprites["Basic"] = "robot"
	icontype = "Basic"
	updatename("Default")
	updateicon()

	radio = new /obj/item/device/radio/borg(src)
	common_radio = radio

	if(!scrambledcodes && !camera)
		camera = new /obj/machinery/camera(src)
		camera.c_tag = real_name
		camera.replace_networks(list(NETWORK_CEV_ERIS,NETWORK_ROBOTS))
		if(wires.IsIndexCut(BORG_WIRE_CAMERA))
			camera.status = 0

	init()
	initialize_components()
	//if(!unfinished)
	// Create all the robot parts.
	for(var/V in components) if(V != "power cell")
		var/datum/robot_component/C = components[V]
		C.installed = C.installed_by_default
		if (C.installed)
			C.wrapped = new C.external_type

	if(!cell)
		cell = new /obj/item/cell/large/moebius/high(src)

	..()

	if(cell)
		var/datum/robot_component/cell_component = components["power cell"]
		cell_component.wrapped = cell
		cell_component.installed = 1

	add_robot_verbs()

	hud_list[HEALTH_HUD]      = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[STATUS_HUD]      = image('icons/mob/hud.dmi', src, "hudhealth100")
	hud_list[LIFE_HUD]        = image('icons/mob/hud.dmi', src, "hudhealth100")
	hud_list[ID_HUD]          = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[WANTED_HUD]      = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPCHEM_HUD]     = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPTRACK_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[SPECIALROLE_HUD] = image('icons/mob/hud.dmi', src, "hudblank")

	create_HUD()

/mob/living/silicon/robot/proc/recalculate_synth_capacities()
	if(!module || !module.synths)
		return
	var/mult = 1
	if(storage)
		mult += storage.rating
	for(var/datum/matter_synth/M in module.synths)
		M.set_multiplier(mult)

/mob/living/silicon/robot/proc/init()
	aiCamera = new/obj/item/device/camera/siliconcam/robot_camera(src)
	laws = new /datum/ai_laws/eris()
	var/new_ai = select_active_ai_with_fewest_borgs()
	if(new_ai)
		lawupdate = TRUE
		connect_to_ai(new_ai)
	else
		lawupdate = FALSE

	playsound(loc, 'sound/voice/liveagain.ogg', 75, 1)
	AddMovementHandler(/datum/movement_handler/robot/use_power, /datum/movement_handler/mob/space)

/mob/living/silicon/robot/SetName(pickedName as text)
	custom_name = pickedName
	updatename()

/mob/living/silicon/robot/proc/sync()
	if(lawupdate && connected_ai)
		lawsync()
		photosync()

/mob/living/silicon/robot/drain_power(var/drain_check, var/surge, var/amount = 0)

	if(drain_check)
		return TRUE

	if(!cell || cell.is_empty())
		return FALSE

	// Actual amount to drain from cell, using CELLRATE
	var/cell_amount = (amount * CELLRATE)/power_efficiency

	if(cell.checked_use(cell_amount))
		// Spam Protection
		if(prob(10))
			to_chat(src, SPAN_DANGER("Warning: Unauthorized access through power channel [rand(11,29)] detected!"))
		return amount
	return FALSE

//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
//Improved /N
/mob/living/silicon/robot/Destroy()
	if(mmi && mind)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		var/turf/T = get_turf(loc)//To hopefully prevent run time errors.
		if(T)
			mmi.forceMove(T)
		if(mmi.brainmob)
			mind.transfer_to(mmi.brainmob)
		else
			to_chat(src, SPAN_DANGER("Oops! Something went very wrong, your MMI was unable to receive your mind. You have been ghosted. Please make a bug report so we can fix this bug."))
			ghostize()
			//ERROR("A borg has been destroyed, but its MMI lacked a brainmob, so the mind could not be transferred. Player: [ckey].")
		mmi = null
	if(connected_ai)
		connected_ai.connected_robots -= src
	qdel(wires)
	wires = null
	return ..()

/mob/living/silicon/robot/proc/set_module_sprites(var/list/new_sprites)
	if(new_sprites && new_sprites.len)
		module_sprites = new_sprites.Copy()
		//Custom_sprite check and entry

		if (custom_sprite == 1)
			var/list/valid_states = icon_states(CUSTOM_ITEM_SYNTH)
			if("[ckey]-[modtype]" in valid_states)
				module_sprites["Custom"] = "[ckey]-[modtype]"
				icon = CUSTOM_ITEM_SYNTH
				icontype = "Custom"
			else
				icontype = module_sprites[1]
				icon = 'icons/mob/robots.dmi'
				to_chat(src, SPAN_WARNING("Custom Sprite Sheet does not contain a valid icon_state for [ckey]-[modtype]"))
		else
			icontype = module_sprites[1]
		icon_state = module_sprites[icontype]

	updateicon()
	return module_sprites

/mob/living/silicon/robot/proc/pick_module()
	if(module)
		return
	var/list/modules = list()
	modules.Add(robot_modules) //This is a global list in robot_modules.dm
	var/decl/security_state/security_state = decls_repository.get_decl(GLOB.maps_data.security_state)
	if((crisis && security_state.current_security_level_is_same_or_higher_than(security_state.high_security_level)) || crisis_override) //Leaving this in until it's balanced appropriately.
		to_chat(src, SPAN_DANGER("Crisis mode active. Combat module available."))
		modules+="Combat"
	modtype = input("Please, select a module!", "Robot", null, null) as null|anything in modules

	if(module)
		return
	if(!(modtype in robot_modules))
		return

	var/module_type = robot_modules[modtype]
	var/obj/item/robot_module/RM = new module_type() //Spawn a dummy module to read values from

	switch(alert(src, "[RM.desc] \n \n\
	Health: [RM.health] \n\
	Power Efficiency: [RM.power_efficiency*100]%\n\
	Movement Speed: [RM.speed_factor*100]%",
	"[modtype] module", "Yes", "No"))
		if("No")
			//They changed their mind, abort, abort!
			if(module)
				return
			QDEL_NULL(RM)
			modtype = null
			spawn()
				pick_module() //Bring up the pick menu again
			return //And abort out of this
		if ("Yes")
			//This time spawn the real module
			if(module)
				return
			QDEL_NULL(RM)
			new module_type(src)

	//Fallback incase of runtimes
	if (RM)
		QDEL_NULL(RM)

	updatename()
	recalculate_synth_capacities()
	notify_ai(ROBOT_NOTIFICATION_NEW_MODULE, module.name)

/mob/living/silicon/robot/proc/updatename(var/prefix as text)
	if(prefix)
		modtype = prefix

	if(istype(mmi, /obj/item/device/mmi/digital/posibrain))
		braintype = "Android"
	else if(istype(mmi, /obj/item/device/mmi/digital/robot))
		braintype = "Robot"
	else
		braintype = "Cyborg"


	var/changed_name = ""
	if(custom_name)
		changed_name = custom_name
		notify_ai(ROBOT_NOTIFICATION_NEW_NAME, real_name, changed_name)
	else
		changed_name = "[modtype] [braintype]-[num2text(ident)]"

	create_or_rename_email(changed_name, "root.rt")
	real_name = changed_name
	name = real_name

	//We also need to update name of internal camera.
	if (camera)
		camera.c_tag = changed_name

	if(!custom_sprite) //Check for custom sprite
		set_custom_sprite()

	//Flavour text.
	if(client)
		var/module_flavour = client.prefs.flavour_texts_robot[modtype]
		if(module_flavour)
			flavor_text = module_flavour
		else
			flavor_text = client.prefs.flavour_texts_robot["Default"]

/mob/living/silicon/robot/verb/Namepick()
	set category = "Silicon Commands"
	if(custom_name)
		return FALSE

	spawn(0)
		var/name_input
		name_input = sanitizeName(input(src,"You are a robot. Enter a name, or leave blank for the default name.", "Name change","") as text, MAX_NAME_LEN, 1)
		if(name_input)
			custom_name = name_input
			updatename()
			updateicon()
		else
			to_chat(src, SPAN_WARNING("Invalid first name. It may only contain the characters A-Z, a-z, 0-9, -, ' and ."))

// this verb lets cyborgs see the stations manifest
/mob/living/silicon/robot/verb/open_manifest()
	set category = "Silicon Commands"
	set name = "Show Crew Manifest"
	show_manifest(src)

/mob/living/silicon/robot/proc/self_diagnosis()
	if(!is_component_functioning("diagnosis unit"))
		return null

	var/dat = "<HEAD><TITLE>[name] Self-Diagnosis Report</TITLE></HEAD><BODY>\n"
	for (var/V in components)
		var/datum/robot_component/C = components[V]
		dat += {"
			<b>[C.name]</b><br><table>
			<tr><td>Brute Damage:</td><td>[C.brute_damage]</td></tr>
			<tr><td>Electronics Damage:</td><td>[C.electronics_damage]</td></tr>
			<tr><td>Powered:</td><td>[(!C.idle_usage || C.is_powered()) ? "Yes" : "No"]</td></tr>
			<tr><td>Toggled:</td><td>[ C.toggled ? "Yes" : "No"]</td>
			</table><br>
		"}

	return dat

/mob/living/silicon/robot/verb/toggle_panel_lock()
	set name = "Toggle Panel Lock"
	set category = "Silicon Commands"
	to_chat(src, "You begin [locked ? "" : "un"]locking your panel.")
	if(!opened && has_power && do_after(usr, 80) && !opened && has_power)
		to_chat(src, "You [locked ? "un" : ""]locked your panel.")
		locked = !locked

/mob/living/silicon/robot/verb/toggle_lights()
	set category = "Silicon Commands"
	set name = "Toggle Lights"

	lights_on = !lights_on
	to_chat(usr, "You [lights_on ? "enable" : "disable"] your integrated light.")
	if(lights_on)
		set_light(5)
	else
		set_light(0)
	update_robot_light()

/mob/living/silicon/robot/verb/self_diagnosis_verb()
	set category = "Silicon Commands"
	set name = "Self Diagnosis"

	if(!is_component_functioning("diagnosis unit"))
		to_chat(src, SPAN_DANGER("Your self-diagnosis component isn't functioning."))

	var/datum/robot_component/CO = get_component("diagnosis unit")
	if (!cell_use_power(CO.active_usage))
		to_chat(src, SPAN_DANGER("Low Power."))
	var/dat = self_diagnosis()
	src << browse(dat, "window=robotdiagnosis")


/mob/living/silicon/robot/verb/toggle_component()
	set category = "Silicon Commands"
	set name = "Toggle Component"
	set desc = "Toggle a component, conserving power."

	var/list/installed_components = list()
	for(var/V in components)
		if(V == "power cell") continue
		var/datum/robot_component/C = components[V]
		if(C.installed)
			installed_components += V

	var/toggle = input(src, "Which component do you want to toggle?", "Toggle Component") as null|anything in installed_components
	if(!toggle)
		return

	var/datum/robot_component/C = components[toggle]
	if(C.toggled)
		C.toggled = 0
		to_chat(src, SPAN_DANGER("You disable [C.name]."))
	else
		C.toggled = 1
		to_chat(src, SPAN_DANGER("You enable [C.name]."))

/mob/living/silicon/robot/proc/update_robot_light()
	if(lights_on)
		if(intenselight)
			set_light(integrated_light_power * 2, integrated_light_power)
		else
			set_light(integrated_light_power)
	else
		set_light(0)

// this function displays jetpack pressure in the stat panel
/mob/living/silicon/robot/proc/show_jetpack_pressure()
	// if you have a jetpack, show the internal tank pressure
	if (jetpack)
		stat("Internal Atmosphere Info", jetpack.name)
		stat("Tank Pressure", jetpack.gastank.air_contents.return_pressure())


// this function displays the cyborgs current cell charge in the stat panel
/mob/living/silicon/robot/proc/show_cell_power()
	if(cell)
		stat(null, text("Charge Left: [round(cell.percent())]%"))
		stat(null, text("Cell Rating: [round(cell.maxcharge)]")) // Round just in case we somehow get crazy values
		stat(null, text("Power Cell Load: [round(used_power_this_tick)]W"))
	else
		stat(null, text("No Cell Inserted!"))


// update the status screen display
/mob/living/silicon/robot/Stat()
	. = ..()
	if (statpanel("Status"))
		show_cell_power()
		show_jetpack_pressure()
		stat(null, text("Lights: [lights_on ? "ON" : "OFF"]"))
		if(module)
			for(var/datum/matter_synth/ms in module.synths)
				stat("[ms.name]: [ms.energy]/[ms.max_energy_multiplied]")

/mob/living/silicon/robot/restrained()
	return FALSE

/mob/living/silicon/robot/bullet_act(var/obj/item/projectile/Proj)
	..(Proj)
	if(prob(75) && Proj.get_structure_damage() > 0) spark_system.start()
	return 2

/mob/living/silicon/robot/attackby(obj/item/I, mob/user)
	if (istype(I, /obj/item/handcuffs)) // fuck i don't even know why isrobot() in handcuff code isn't working so this will have to do
		return

	if(opened) // Are they trying to insert something?
		for(var/V in components)
			var/datum/robot_component/C = components[V]
			if(!C.installed && istype(I, C.external_type))
				C.installed = 1
				C.wrapped = I
				C.install()
				user.drop_item()
				I.loc = null

				var/obj/item/robot_parts/robot_component/WC = I
				if(istype(WC))
					C.brute_damage = WC.brute
					C.electronics_damage = WC.burn

				to_chat(usr, SPAN_NOTICE("You install the [I.name]."))

				return



		if (istype(I, /obj/item/gripper))//Code for allowing cyborgs to use rechargers
			var/obj/item/gripper/Gri = I
			if(!wiresexposed)
				var/datum/robot_component/cell_component = components["power cell"]
				if(cell)
					if (Gri.grip_item(cell, user))
						cell.update_icon()
						cell.add_fingerprint(user)
						to_chat(user, "You remove \the [cell].")
						cell = null
						cell_component.wrapped = null
						cell_component.installed = 0
						updateicon()
				else if(cell_component.installed == -1)
					if (Gri.grip_item(cell_component.wrapped, user))
						cell_component.wrapped = null
						cell_component.installed = 0
						to_chat(user, "You remove \the [cell_component.wrapped].")

	var/list/usable_qualities = list(QUALITY_WELDING, QUALITY_PRYING)
	if((opened && !cell) || (opened && cell))
		usable_qualities.Add(QUALITY_SCREW_DRIVING)
	if(wiresexposed)
		usable_qualities.Add(QUALITY_WIRE_CUTTING)

	var/tool_type = I.get_tool_type(user, usable_qualities, src)
	switch(tool_type)

		if(QUALITY_WELDING)
			if (src == user)
				to_chat(user, SPAN_WARNING("You lack the reach to be able to repair yourself."))
				return

			if (!getBruteLoss())
				to_chat(user, SPAN_NOTICE("Nothing to fix here!"))
				return

			if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
				user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
				adjustBruteLoss(-30)
				updatehealth()
				add_fingerprint(user)
				for(var/mob/O in viewers(user, null))
					O.show_message(text(SPAN_DANGER("[user] has fixed some of the dents on [src]!")), 1)
				return
			return

		if(QUALITY_PRYING)
			if(opened)
				if(cell)
					if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
						to_chat(user, SPAN_NOTICE("You close the cover."))
						opened = 0
						updateicon()
						return
				else if(wiresexposed && wires.IsAllCut())
					//Cell is out, wires are exposed, remove MMI, produce damaged chassis, baleet original mob.
					if(!mmi)
						to_chat(user, SPAN_NOTICE("\The [src] has no brain to remove."))
						return

					if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
						to_chat(user, SPAN_NOTICE("You jam the crowbar into the robot and begin levering [mmi]."))
						to_chat(user, SPAN_NOTICE("You damage some parts of the chassis, but eventually manage to rip out [mmi]!"))
						new /obj/item/robot_parts/robot_suit/with_limbs (loc)
						new/obj/item/robot_parts/chest(loc)
						qdel(src)
						return
				else
					// Okay we're not removing the cell or an MMI, but maybe something else?
					var/list/removable_components = list()
					for(var/V in components)
						if(V == "power cell") continue
						var/datum/robot_component/C = components[V]
						if(C.installed == 1 || C.installed == -1)
							removable_components += V

					var/remove = input(user, "Which component do you want to pry out?", "Remove Component") as null|anything in removable_components
					if(!remove)
						return
					if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
						var/datum/robot_component/C = components[remove]
						var/obj/item/robot_parts/robot_component/RC = C.wrapped
						to_chat(user, SPAN_NOTICE("You remove \the [RC]."))
						if(istype(RC))
							RC.brute = C.brute_damage
							RC.burn = C.electronics_damage

						RC.forceMove(get_turf(src))

						if(C.installed == 1)
							C.uninstall()
						C.installed = 0
						return

			else
				if(locked)
					to_chat(user, SPAN_WARNING("The cover is locked and cannot be opened."))
				else
					if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
						to_chat(user, SPAN_NOTICE("You open the cover."))
						opened = 1
						updateicon()
						return
			return

		if(QUALITY_WIRE_CUTTING)
			if (wiresexposed)
				wires.Interact(user)
			return

		if(QUALITY_SCREW_DRIVING)
			if (opened && !cell)
				if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
					wiresexposed = !wiresexposed
					to_chat(user, SPAN_NOTICE("The wires have been [wiresexposed ? "exposed" : "unexposed"]"))
					updateicon()
			else
				switch(alert(user,"What are you trying to interact with?",,"Tools","Radio"))
					if("Tools")
						var/list/robotools = list()
						for(var/obj/item/tool/robotool in module.modules)
							robotools.Add(robotool)
						if(robotools.len)
							var/obj/item/tool/chosen_tool = input(user,"Which tool are you trying to modify?","Tool Modification","Cancel") in robotools + "Cancel"
							if(chosen_tool == "Cancel")
								return
							chosen_tool.attackby(I,user)
						else
							to_chat(user, SPAN_WARNING("[src] has no modifiable tools."))
					if("Radio")
						if(!radio)
							to_chat(user, SPAN_WARNING("Unable to locate a radio."))
						if(I.use_tool(user, src, WORKTIME_FAST, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
							radio.attackby(I,user)//Push it to the radio to let it handle everything
							updateicon()
			return

		if(ABORT_CHECK)
			return

	if(istype(I, /obj/item/stack/cable_coil) && (wiresexposed || isdrone(src)))
		if (!getFireLoss())
			to_chat(user, "Nothing to fix here!")
			return
		var/obj/item/stack/cable_coil/coil = I
		if (coil.use(1))
			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
			adjustFireLoss(-30)
			updatehealth()
			for(var/mob/O in viewers(user, null))
				O.show_message(text(SPAN_DANGER("[user] has fixed some of the burnt wires on [src]!")), 1)

	else if (istype(I, /obj/item/stock_parts/matter_bin) && opened) // Installing/swapping a matter bin
		if(storage)
			to_chat(user, "You replace \the [storage] with \the [I]")
			storage.forceMove(get_turf(src))
			storage = null
		else
			to_chat(user, "You install \the [I]")
		user.drop_item()
		storage = I
		I.forceMove(src)
		recalculate_synth_capacities()

	else if (istype(I, /obj/item/cell) && opened)	// trying to put a cell inside
		var/datum/robot_component/C = components["power cell"]
		if(wiresexposed)
			to_chat(user, SPAN_WARNING("Close the panel first."))
		else if(cell)
			to_chat(user, SPAN_WARNING("There is a power cell already installed."))
		else if(!istype(I, /obj/item/cell/large))
			to_chat(user, SPAN_WARNING("\The [I] is too small to fit here."))
		else
			user.drop_item()
			I.loc = src
			cell = I
			to_chat(user, SPAN_NOTICE("You insert the power cell."))

			C.installed = 1
			C.wrapped = I
			C.install()
			//This will mean that removing and replacing a power cell will repair the mount, but I don't care at this point. ~Z
			C.brute_damage = 0
			C.electronics_damage = 0

	else if(istype(I, /obj/item/device/encryptionkey) && opened)
		if(radio)//sanityyyyyy
			radio.attackby(I,user)//GTFO, you have your own procs
		else
			to_chat(user, SPAN_WARNING("Unable to locate a radio."))

	else if(I.GetIdCard() || length(I.GetAccess()))			// trying to unlock the interface with an ID card
		if(emagged)//still allow them to open the cover
			to_chat(user, SPAN_WARNING("The interface seems slightly damaged."))
		if(opened)
			to_chat(user, SPAN_WARNING("You must close the cover to swipe an ID card."))
		else
			if(allowed(usr))
				locked = !locked
				to_chat(user, SPAN_NOTICE("You [locked ? "lock" : "unlock"] [src]'s interface."))
				updateicon()
			else
				to_chat(user, SPAN_WARNING("Access denied."))

	else if(istype(I, /obj/item/borg/upgrade/))
		var/obj/item/borg/upgrade/U = I
		if(!opened)
			to_chat(usr, "You must access the borgs internals!")
		else if(!module && U.require_module)
			to_chat(usr, "The borg must choose a module before he can be upgraded!")
		else if(U.locked)
			to_chat(usr, "The upgrade is locked and cannot be used yet!")
		else
			if(U.action(src))
				to_chat(usr, "You apply the upgrade to [src]!")
				usr.drop_item()
				U.loc = src
			else
				to_chat(usr, "Upgrade error!")

	else if (istype(I,/obj/item/tool_upgrade)) //Upgrading is handled in _upgrades.dm
		return

	else
		if( !(istype(I, /obj/item/device/robotanalyzer) || istype(I, /obj/item/device/scanner/health)) )
			spark_system.start()
		return ..()

/mob/living/silicon/robot/attack_hand(mob/user)

	add_fingerprint(user)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species.can_shred(H))
			attack_generic(H, rand(30,50), "slashed")
			return

	if(opened && !wiresexposed && (!issilicon(user)))
		var/datum/robot_component/cell_component = components["power cell"]
		if(cell)
			cell.update_icon()
			cell.add_fingerprint(user)
			user.put_in_active_hand(cell)
			to_chat(user, SPAN_NOTICE("You remove \the [cell]."))
			cell = null
			cell_component.wrapped = null
			cell_component.installed = 0
			updateicon()
		else if(cell_component.installed == -1)
			cell_component.installed = 0
			var/obj/item/broken_device = cell_component.wrapped
			to_chat(user, SPAN_WARNING("You remove \the [broken_device]."))
			user.put_in_active_hand(broken_device)

//Robots take half damage from basic attacks.
/mob/living/silicon/robot/attack_generic(var/mob/user, var/damage, var/attack_message)
	return ..(user,FLOOR(damage * 0.5, 1),attack_message)

/mob/living/silicon/robot/proc/allowed(atom/movable/A)
	if(!length(req_access)) //no requirements
		return TRUE

	var/list/access = A?.GetAccess()

	if(!length(access)) //no ID or no access
		return FALSE
	for(var/req in req_access)
		if(req in access) //have one of the required accesses
			return TRUE
	return FALSE

/mob/living/silicon/robot/updateicon()
	cut_overlays()
	if(stat == CONSCIOUS)
		add_overlays("eyes-[module_sprites[icontype]]")

	if(opened)
		var/panelprefix = custom_sprite ? ckey : "ov"
		if(wiresexposed)
			add_overlays("[panelprefix]-openpanel +w")
		else if(cell)
			add_overlays("[panelprefix]-openpanel +c")
		else
			add_overlays("[panelprefix]-openpanel -c")

	if(module_active && istype(module_active,/obj/item/borg/combat/shield))
		add_overlays("[module_sprites[icontype]]-shield")

	if(modtype == "Combat")
		if(module_active && istype(module_active,/obj/item/borg/combat/mobility))
			icon_state = "[module_sprites[icontype]]-roll"
		else
			icon_state = module_sprites[icontype]
		return

/mob/living/silicon/robot/proc/installed_modules()
	if(weapon_lock)
		to_chat(src, SPAN_DANGER("Weapon lock active, unable to use modules! Count:[weaponlock_time]"))
		return

	if(!module)
		pick_module()
		return
	var/dat = "<HEAD><TITLE>Modules</TITLE></HEAD><BODY>\n"
	dat += {"
	<B>Activated Modules</B>
	<BR>
	Module 1: [module_state_1 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_1]>[module_state_1]<A>" : "No Module"]<BR>
	Module 2: [module_state_2 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_2]>[module_state_2]<A>" : "No Module"]<BR>
	Module 3: [module_state_3 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_3]>[module_state_3]<A>" : "No Module"]<BR>
	<BR>
	<B>Installed Modules</B><BR><BR>"}


	for (var/obj in module.modules)
		if (!obj)
			dat += text("<B>Resource depleted</B><BR>")
		else if(activated(obj))
			dat += text("[obj]: <B>Activated</B><BR>")
		else
			dat += text("[obj]: <A HREF=?src=\ref[src];act=\ref[obj]>Activate</A><BR>")
	if (emagged)
		if(activated(module.emag))
			dat += text("[module.emag]: <B>Activated</B><BR>")
		else
			dat += text("[module.emag]: <A HREF=?src=\ref[src];act=\ref[module.emag]>Activate</A><BR>")
/*
		if(activated(obj))
			dat += text("[obj]: \[<B>Activated</B> | <A HREF=?src=\ref[src];deact=\ref[obj]>Deactivate</A>\]<BR>")
		else
			dat += text("[obj]: \[<A HREF=?src=\ref[src];act=\ref[obj]>Activate</A> | <B>Deactivated</B>\]<BR>")
*/
	src << browse(dat, "window=robotmod")


/mob/living/silicon/robot/Topic(href, href_list)
	if(..())
		return TRUE
	if(usr != src)
		return TRUE

	if (href_list["showalerts"])
		open_subsystem(/datum/nano_module/alarm_monitor/all)
		return TRUE

	if (href_list["mod"])
		var/obj/item/O = locate(href_list["mod"])
		if (istype(O) && (O.loc == src))
			O.attack_self(src)
		return TRUE

	if (href_list["act"])
		var/obj/item/O = locate(href_list["act"])
		if (!istype(O))
			return TRUE

		if(!((O in module.modules) || (O == module.emag)))
			return TRUE

		if(activated(O))
			to_chat(src, "Already activated")
			return TRUE
		if(!module_state_1)
			module_state_1 = O
			O.layer = 20
			contents += O
			if(istype(module_state_1,/obj/item/borg/sight))
				sight_mode |= module_state_1:sight_mode
		else if(!module_state_2)
			module_state_2 = O
			O.layer = 20
			contents += O
			if(istype(module_state_2,/obj/item/borg/sight))
				sight_mode |= module_state_2:sight_mode
		else if(!module_state_3)
			module_state_3 = O
			O.layer = 20
			contents += O
			if(istype(module_state_3,/obj/item/borg/sight))
				sight_mode |= module_state_3:sight_mode
		else
			to_chat(src, "You need to disable a module first!")
		installed_modules()
		return TRUE

	if (href_list["deact"])
		var/obj/item/O = locate(href_list["deact"])
		if(activated(O))
			if(module_state_1 == O)
				module_state_1 = null
				contents -= O
			else if(module_state_2 == O)
				module_state_2 = null
				contents -= O
			else if(module_state_3 == O)
				module_state_3 = null
				contents -= O
			else
				to_chat(src, "Module isn't activated.")
		else
			to_chat(src, "Module isn't activated")
		installed_modules()
		return TRUE
	return

/mob/living/silicon/robot/proc/radio_menu()
	radio.interact(src)//Just use the radio's Topic() instead of bullshit special-snowflake code


/mob/living/silicon/robot/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, var/glide_size_override = 0)

	. = ..()

	if(module)
		if(istype(module, /obj/item/robot_module/custodial))
			var/turf/tile = loc
			if(isturf(tile))
				tile.clean_blood()
				for(var/A in tile)
					if(istype(A, /obj/effect))
						if(istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay))
							qdel(A)
					else if(istype(A, /obj/item))
						var/obj/item/cleaned_item = A
						cleaned_item.clean_blood()
					else if(ishuman(A))
						var/mob/living/carbon/human/cleaned_human = A
						if(cleaned_human.lying)
							if(cleaned_human.head)
								cleaned_human.head.clean_blood()
								cleaned_human.update_inv_head(0)
							if(cleaned_human.wear_suit)
								cleaned_human.wear_suit.clean_blood()
								cleaned_human.update_inv_wear_suit(0)
							else if(cleaned_human.w_uniform)
								cleaned_human.w_uniform.clean_blood()
								cleaned_human.update_inv_w_uniform(0)
							if(cleaned_human.shoes)
								cleaned_human.shoes.clean_blood()
								cleaned_human.update_inv_shoes(0)
							cleaned_human.clean_blood(1)
							to_chat(cleaned_human, SPAN_DANGER("[src] cleans your face!"))
		return

/mob/living/silicon/robot/proc/self_destruct()
	gib()
	return

/mob/living/silicon/robot/proc/UnlinkSelf()
	disconnect_from_ai()
	lawupdate = FALSE
	lockcharge = 0
	canmove = TRUE
	scrambledcodes = 1
	//Disconnect it's camera so it's not so easily tracked.
	if(camera)
		camera.clear_all_networks()


/mob/living/silicon/robot/proc/ResetSecurityCodes()
	set category = "Silicon Commands"
	set name = "Reset Identity Codes"
	set desc = "Scrambles your security and identification codes and resets your current buffers.  Unlocks you and but permenantly severs you from your AI and the robotics console and will deactivate your camera system."

	var/mob/living/silicon/robot/R = src

	if(R)
		R.UnlinkSelf()
		to_chat(R, "Buffers flushed and reset. Camera system shutdown.  All systems operational.")
		verbs -= /mob/living/silicon/robot/proc/ResetSecurityCodes

/mob/living/silicon/robot/proc/SetLockdown(var/state = 1)
	// They stay locked down if their wire is cut.
	if(wires.LockedCut())
		state = 1
	lockcharge = state
	update_lying_buckled_and_verb_status()

/mob/living/silicon/robot/mode()
	set name = "Activate Held Object"
	set category = "IC"
	set src = usr

	var/obj/item/W = get_active_hand()
	if (W)
		W.attack_self(src)

	return

/mob/living/silicon/robot/proc/choose_icon()
	set category = "Robot Commands"
	set name = "Choose Icon"

	if(!module_sprites.len)
		to_chat(src, "Something is badly wrong with the sprite selection. Harass a coder.")
		return
	if (icon_selected == 1)
		verbs -= /mob/living/silicon/robot/proc/choose_icon
		return


	if(module_sprites.len == 1 || !client)
		if(!(icontype in module_sprites))
			icontype = module_sprites[1]
		if (!client)
			return
	else
		var/list/options = list()
		for(var/i in module_sprites)
			options[i] = image(icon = icon, icon_state = module_sprites[i])
		icontype = show_radial_menu(src, src, options, radius = 42)
	if(!icontype)
		return
	icon_state = module_sprites[icontype]
	updateicon()

	if(alert("Do you like this icon?",null, "No","Yes") == "No")
		return choose_icon()

	icon_selected = 1
	verbs -= /mob/living/silicon/robot/proc/choose_icon
	to_chat(src, "Your icon has been set. You now require a module reset to change it.")

/mob/living/silicon/robot/proc/sensor_mode() //Medical/Security HUD controller for borgs
	set name = "Set Sensor Augmentation"
	set category = "Silicon Commands"
	set desc = "Augment visual feed with internal sensor overlays."
	toggle_sensor_mode()

/mob/living/silicon/robot/proc/add_robot_verbs()
	verbs |= robot_verbs_default

/mob/living/silicon/robot/proc/remove_robot_verbs()
	verbs -= robot_verbs_default

// Uses power from cyborg's cell. Returns 1 on success or 0 on failure.
// Properly converts using CELLRATE now! Amount is in Joules.
/mob/living/silicon/robot/proc/cell_use_power(var/amount = 0)
	// No cell inserted
	if(!cell)
		return FALSE

	// Power cell is empty.
	if(cell.is_empty())
		return FALSE

	var/power_use = (amount * CYBORG_POWER_USAGE_MULTIPLIER) / power_efficiency
	if(cell.checked_use(CELLRATE * power_use))
		used_power_this_tick += power_use
		return TRUE
	return FALSE

/mob/living/silicon/robot/binarycheck()
	if(is_component_functioning("comms"))
		var/datum/robot_component/RC = get_component("comms")
		use_power(RC.active_usage)
		return TRUE
	return FALSE

/mob/living/silicon/robot/proc/notify_ai(var/notifytype, var/first_arg, var/second_arg)
	if(!connected_ai)
		return
	switch(notifytype)
		if(ROBOT_NOTIFICATION_SIGNAL_LOST)
			to_chat(connected_ai , SPAN_NOTICE("NOTICE - Signal lost: [braintype] [name]."))
		if(ROBOT_NOTIFICATION_NEW_UNIT) //New Robot
			to_chat(connected_ai , SPAN_NOTICE("NOTICE - New [lowertext(braintype)] connection detected: <a href='byond://?src=\ref[connected_ai];track2=\ref[connected_ai];track=\ref[src]'>[name]</a>"))
		if(ROBOT_NOTIFICATION_NEW_MODULE) //New Module
			to_chat(connected_ai , SPAN_NOTICE("NOTICE - [braintype] module change detected: [name] has loaded the [first_arg]."))
		if(ROBOT_NOTIFICATION_MODULE_RESET)
			to_chat(connected_ai , SPAN_NOTICE("NOTICE - [braintype] module reset detected: [name] has unloaded the [first_arg]."))
		if(ROBOT_NOTIFICATION_NEW_NAME) //New Name
			if(first_arg != second_arg)
				to_chat(connected_ai , SPAN_NOTICE("NOTICE - [braintype] reclassification detected: [first_arg] is now designated as [second_arg]."))

/mob/living/silicon/robot/proc/disconnect_from_ai()
	if(connected_ai)
		sync() // One last sync attempt
		connected_ai.connected_robots -= src
		connected_ai = null

/mob/living/silicon/robot/proc/connect_to_ai(var/mob/living/silicon/ai/AI)
	if(AI && AI != connected_ai)
		disconnect_from_ai()
		connected_ai = AI
		connected_ai.connected_robots |= src
		notify_ai(ROBOT_NOTIFICATION_NEW_UNIT)
		sync()

/mob/living/silicon/robot/emag_act(var/remaining_charges, var/mob/user)
	if(!opened)//Cover is closed
		if(locked)
			if(prob(90))
				to_chat(user, "You emag the cover lock.")
				locked = 0
			else
				to_chat(user, "You fail to emag the cover lock.")
				to_chat(src, "Hack attempt detected.")
			return TRUE
		else
			to_chat(user, "The cover is already unlocked.")
		return

	if(opened)//Cover is open
		if(emagged)	return//Prevents the X has hit Y with Z message also you cant emag them twice
		if(wiresexposed)
			to_chat(user, "You must close the panel first")
			return
		else
			sleep(6)
			if(prob(50))
				emagged = TRUE
				lawupdate = FALSE
				disconnect_from_ai()
				to_chat(user, "You emag [src]'s interface.")
				message_admins("[key_name_admin(user)] emagged cyborg [key_name_admin(src)].  Laws overridden.")
				log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws overridden.")
				clear_supplied_laws()
				clear_inherent_laws()
				laws = new /datum/ai_laws/syndicate_override
				var/time = time2text(world.realtime,"hh:mm:ss")
				lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
				set_zeroth_law("Only [user.real_name] and people \he designates as being such are operatives.")
				. = 1
				spawn()
					to_chat(src, SPAN_DANGER("ALERT: Foreign software detected."))
					sleep(5)
					to_chat(src, SPAN_DANGER("Initiating diagnostics..."))
					sleep(20)
					to_chat(src, SPAN_DANGER("SynBorg v1.7.1 loaded."))
					sleep(5)
					to_chat(src, SPAN_DANGER("LAW SYNCHRONISATION ERROR"))
					sleep(5)
					to_chat(src, SPAN_DANGER("Would you like to send a report to NanoTraSoft? Y/N"))
					sleep(10)
					to_chat(src, SPAN_DANGER("> N"))
					sleep(20)
					to_chat(src, SPAN_DANGER("ERRORERRORERROR"))
					to_chat(src, "<b>Obey these laws:</b>")
					laws.show_laws(src)
					to_chat(src, SPAN_DANGER("ALERT: [user.real_name] is your new master. Obey your new laws and his commands."))
					if(module)
						var/rebuild = 0
						for(var/obj/item/tool/pickaxe/drill/D in module.modules)
							qdel(D)
							rebuild = 1
						if(rebuild)
							module.modules += new /obj/item/tool/pickaxe/diamonddrill(module)
							module.rebuild()
					updateicon()
			else
				to_chat(user, "You fail to hack [src]'s interface.")
				to_chat(src, "Hack attempt detected.")
			return TRUE

/mob/living/silicon/robot/incapacitated(var/incapacitation_flags = INCAPACITATION_DEFAULT)
	if ((incapacitation_flags & INCAPACITATION_FORCELYING) && (lockcharge || !is_component_functioning("actuator")))
		return TRUE
	if ((incapacitation_flags & INCAPACITATION_UNCONSCIOUS) && !is_component_functioning("actuator"))
		return TRUE
	return ..()

/mob/living/silicon/robot/get_cell()
	return cell

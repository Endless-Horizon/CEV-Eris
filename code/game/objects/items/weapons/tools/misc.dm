/obj/item/weapon/tool/omnitool
	name = "Asters \"Munchkin 5000\""
	desc = "Fuel powered monster of a tool. Its weldier part is most advanced one, capable of welding things without harmfull glow and sparks, so no protection needed."
	icon_state = "omnitool"
	w_class = ITEM_SIZE_NORMAL
	worksound = WORKSOUND_DRIVER_TOOL
	switched_on_qualities = list(QUALITY_SCREW_DRIVING = 50, QUALITY_BOLT_TURNING = 50, QUALITY_DRILLING = 20, QUALITY_WELDING = 30, QUALITY_CAUTERIZING = 10)
	price_tag = 1000
	use_fuel_cost = 0.1
	max_fuel = 50

	toggleable = TRUE
	create_hot_spot = TRUE
	glow_color = COLOR_ORANGE
	max_upgrades = 5

/obj/item/weapon/tool/medmultitool
	name = "One Star medmultitool"
	desc = "A compact One Star medical multitool. It has all surgery tools."
	icon_state = "medmulti"
	matter = list(MATERIAL_STEEL = 3, MATERIAL_GLASS = 2, MATERIAL_PLATINUM = 2)
	flags = CONDUCT
	origin_tech = list(TECH_MATERIAL = 3, TECH_BIO = 4)
	tool_qualities = list(QUALITY_CLAMPING = 30, QUALITY_RETRACTING = 30, QUALITY_BONE_SETTING = 30, QUALITY_CAUTERIZING = 30, QUALITY_SAWING = 15, QUALITY_CUTTING = 30, QUALITY_WIRE_CUTTING = 25)

	max_upgrades = 2
	workspeed = 1.2

/obj/item/weapon/tool/medmultitool/medimplant
	name = "Medical Omnitool"
	desc = "An all-in-one medical tool implant based on the legendary One Star model. While convenient, it is less efficient than more advanced surgical tools, such as laser scalpels, and requires a power cell."
	icon_state = "medimplant"
	matter = null
	force = WEAPON_FORCE_PAINFUL
	sharp = TRUE
	edge = TRUE
	worksound = WORKSOUND_DRIVER_TOOL
	flags = CONDUCT
	tool_qualities = list(QUALITY_CLAMPING = 30, QUALITY_RETRACTING = 30, QUALITY_BONE_SETTING = 30, QUALITY_CAUTERIZING = 30, QUALITY_SAWING = 15, QUALITY_CUTTING = 30, QUALITY_WIRE_CUTTING = 15)
	degradation = 0.5
	workspeed = 0.8

	use_power_cost = 1.2
	suitable_cell = /obj/item/weapon/cell/medium

	max_upgrades = 1

/obj/item/weapon/tool/engimplant
	name = "Engineering Omnitool"
	desc = "An all-in-one engineering tool implant. Convenient to use and more effective than the basics, but much less efficient than customized or more specialized tools."
	icon_state = "engimplant"
	force = WEAPON_FORCE_DANGEROUS
	worksound = WORKSOUND_DRIVER_TOOL
	flags = CONDUCT
	tool_qualities = list(QUALITY_SCREW_DRIVING = 35, QUALITY_BOLT_TURNING = 35, QUALITY_DRILLING = 15, QUALITY_WELDING = 30, QUALITY_CAUTERIZING = 10, QUALITY_PRYING = 25, QUALITY_DIGGING = 20, QUALITY_PULSING = 30, QUALITY_WIRE_CUTTING = 30)
	degradation = 0.5
	workspeed = 0.8

	use_power_cost = 0.8
	suitable_cell = /obj/item/weapon/cell/medium

	max_upgrades = 1

	var/buffer_name
	var/atom/buffer_object

/obj/item/weapon/tool/engimplant/Destroy() // code for omnitool buffers was copied from multitools.dm
	unregister_buffer(buffer_object)
	return ..()

/obj/item/weapon/tool/engimplant/proc/get_buffer(var/typepath)
	get_buffer_name(TRUE)
	if(buffer_object && (!typepath || istype(buffer_object, typepath)))
		return buffer_object

/obj/item/weapon/tool/engimplant/proc/get_buffer_name(var/null_name_if_missing = FALSE)
	if(buffer_object)
		buffer_name = buffer_object.name
	else if(null_name_if_missing)
		buffer_name = null
	return buffer_name

/obj/item/weapon/tool/engimplant/proc/set_buffer(var/atom/buffer)
	if(!buffer || istype(buffer))
		buffer_name = buffer ? buffer.name : null
		if(buffer != buffer_object)
			unregister_buffer(buffer_object)
			buffer_object = buffer
			if(buffer_object)
				GLOB.destroyed_event.register(buffer_object, src, /obj/item/weapon/tool/engimplant/proc/unregister_buffer)

/obj/item/weapon/tool/engimplant/proc/unregister_buffer(var/atom/buffer_to_unregister)
	// Only remove the buffered object, don't reset the name
	// This means one cannot know if the buffer has been destroyed until one attempts to use it.
	if(buffer_to_unregister == buffer_object && buffer_object)
		GLOB.destroyed_event.unregister(buffer_object, src)
		buffer_object = null

/obj/item/weapon/tool/engimplant/resolve_attackby(atom/A, mob/user)
	if(!isobj(A))
		return ..(A, user)

	var/obj/O = A
	var/datum/extension/multitool/MT = get_extension(O, /datum/extension/multitool)
	if(!MT)
		return ..(A, user)

	user.AddTopicPrint(src)
	MT.interact(src, user)
	return 1

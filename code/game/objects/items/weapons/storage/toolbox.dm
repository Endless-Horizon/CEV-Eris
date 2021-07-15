/obj/item/storage/toolbox
	name = "toolbox"
	desc = "Danger. Very robust."
	icon = 'icons/obj/storage.dmi'
	icon_state = "red"
	item_state = "toolbox_red"
	flags = CONDUCT
	force = WEAPON_FORCE_PAINFUL
	structure_damage_factor = STRUCTURE_DAMAGE_BLUNT
	throwforce = WEAPON_FORCE_NORMAL
	throw_speed = 1
	throw_range = 7
	w_class = ITEM_SIZE_BULKY
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = 14 //enough to hold all starting contents
	origin_tech = list(TECH_COMBAT = 1)
	attack_verb = list("robusted")
	spawn_blacklisted = FALSE
	rarity_value = 10
	spawn_frequency = 10
	spawn_tags = SPAWN_TAG_TOOLBOX
	bad_type = /obj/item/storage/toolbox

/obj/item/storage/toolbox/emergency
	name = "emergency toolbox"
	icon_state = "red"
	item_state = "toolbox_red"
	rarity_value = 30

/obj/item/storage/toolbox/emergency/populate_contents()
	new /obj/item/tool/crowbar(src)
	new /obj/item/extinguisher/mini(src)
	if(prob(50))
		new /obj/item/device/lighting/toggleable/flashlight(src)
	else
		new /obj/item/device/lighting/glowstick/flare(src)
	if (prob(40))
		new /obj/item/tool/tape_roll(src)
	new /obj/item/device/radio(src)

/obj/item/storage/toolbox/mechanical
	name = "mechanical toolbox"
	icon_state = "blue"
	item_state = "toolbox_blue"

/obj/item/storage/toolbox/mechanical/populate_contents()
	new /obj/item/tool/screwdriver(src)
	new /obj/item/tool/wrench(src)
	new /obj/item/tool/weldingtool(src)
	new /obj/item/tool/crowbar(src)
	if(prob(50))
		new /obj/item/tool/wirecutters(src)
	else
		new /obj/item/tool/wirecutters/pliers(src)
	new /obj/item/device/scanner/gas(src)

/obj/item/storage/toolbox/electrical
	name = "electrical toolbox"
	icon_state = "yellow"
	item_state = "toolbox_yellow"
	rarity_value = 20

/obj/item/storage/toolbox/electrical/populate_contents()
	var/color = pick("red","yellow","green","blue","pink","orange","cyan","white")

	new /obj/item/tool/screwdriver(src)
	if(prob(50))
		new /obj/item/tool/wirecutters(src)
	else
		new /obj/item/tool/wirecutters/pliers(src)
	new /obj/item/device/t_scanner(src)
	new /obj/item/tool/crowbar(src)
	new /obj/item/stack/cable_coil(src,30,color)
	new /obj/item/stack/cable_coil(src,30,color)

	if(prob(5))
		new /obj/item/clothing/gloves/insulated(src)
	else if(prob(10))
		new /obj/item/tool/multitool(src)
	else
		new /obj/item/stack/cable_coil(src,30,color)

	if(prob(60))
		new /obj/item/tool/tape_roll(src)

/obj/item/storage/toolbox/syndicate
	name = "suspicious looking toolbox"
	icon_state = "syndicate"
	item_state = "toolbox_syndi"
	origin_tech = list(TECH_COMBAT = 1, TECH_COVERT = 1)
	force = WEAPON_FORCE_DANGEROUS
	spawn_blacklisted = TRUE

/obj/item/storage/toolbox/syndicate/populate_contents()
	var/obj/item/tool/cell_tool

	new /obj/item/clothing/gloves/insulated(src)

	cell_tool = new /obj/item/tool/screwdriver/combi_driver(src)
	qdel(cell_tool.cell)
	cell_tool.cell = new /obj/item/cell/small/super(cell_tool)

	cell_tool = new /obj/item/tool/crowbar/pneumatic(src)
	qdel(cell_tool.cell)
	cell_tool.cell = new /obj/item/cell/medium/super(cell_tool)

	new /obj/item/tool/weldingtool/advanced(src)
	new /obj/item/tool/wirecutters/armature(src)
	new /obj/item/tool/multitool(src)
	new /obj/item/cell/medium/super(src)
	new /obj/item/cell/small/super(src)


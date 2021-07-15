/obj/machinery/autolathe/bioprinter
	name = "NeoTheology Bioprinter"
	desc = "NeoTheology machine for printing things using biomass."
	icon_state = "bioprinter"
	unsuitable_materials = list()
	speed = 3 
	storage_capacity = 360
	build_type = AUTOLATHE | BIOPRINTER
	high_quality_faction_list = list(FACTION_NEOTHEOLOGY)

/obj/machinery/autolathe/bioprinter/attackby(obj/item/I, mob/user)
	//hacky way to forbid deconstruction but use ..()
	var/tool_type = I.get_tool_type(user, list(QUALITY_SCREW_DRIVING), src)
	if(tool_type == QUALITY_SCREW_DRIVING)
		return

	//it needs to have panel open, but just in case
	if(istype(I, /obj/item/storage/part_replacer))
		return

	..(I, user)

/obj/machinery/autolathe/bioprinter/disk
	default_disk = /obj/item/computer_hardware/hard_drive/portable/design/nt_bioprinter

/obj/machinery/autolathe/bioprinter/public
	default_disk = /obj/item/computer_hardware/hard_drive/portable/design/nt_bioprinter_public

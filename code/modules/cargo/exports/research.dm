// Sell tech levels
/datum/export/tech
	cost = 500
	unit_name = "technology data"
	export_types = list(/obj/item/computer_hardware/hard_drive)

/datum/export/tech/get_cost(obj/O)
	var/obj/item/computer_hardware/hard_drive/D = O
	var/cost = 0

	for(var/f in D.find_files_by_type(/datum/computer_file/binary/tech))
		var/datum/computer_file/binary/tech/T = f
		cost += T.node.getCost()

	return ..() * cost


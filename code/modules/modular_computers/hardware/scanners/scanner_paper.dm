/obj/item/computer_hardware/scanner/paper
	name = "paper scanner module"
	desc = "A paper scanning module. It can scan writing and save it to a file."
	active_power_usage = 400 //Its just a sheet of paper, much cheaper than other scans

/obj/item/computer_hardware/scanner/paper/can_use_scanner(mob/user, obj/item/paper/target, proximity = TRUE)
	if(!..())
		return 0
	if(!istype(target))
		return 0
	return 1

/obj/item/computer_hardware/scanner/paper/do_on_afterattack(mob/user, obj/item/paper/target, proximity)
	if(!driver || !driver.using_scanner)
		return FALSE
	if(!can_use_scanner(user, target, proximity))
		return FALSE
	var/data = html2pencode(target.info)
	if(!data)
		return FALSE
	if (!scan_power_use())
		return FALSE
	to_chat(user, "You scan \the [target] with [src].")
	driver.data_buffer = data
	SSnano.update_uis(driver.NM)
	return TRUE

/obj/item/computer_hardware/scanner/paper/do_on_attackby(mob/user, atom/target)
	return do_on_afterattack(user, target, TRUE)
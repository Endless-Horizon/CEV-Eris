/obj/item/weapon/computer_hardware/scanner/atmos
	name = "atmospheric scanner module"
	desc = "An atmospheric scanner module. It can scan the surroundings and report the composition of gases."
	can_run_scan = 1

/obj/item/weapon/computer_hardware/scanner/atmos/can_use_scanner(mob/user, atom/target, proximity = TRUE)
	if(!..())
		return 0
	if(!target.simulated)
		return 0
	return 1

/obj/item/weapon/computer_hardware/scanner/atmos/run_scan(mob/user, datum/computer_file/program/scanner/program)
	if(..())
		program.data_buffer = html2pencode(scan_data(user, user.loc)) || program.data_buffer

/obj/item/weapon/computer_hardware/scanner/atmos/do_on_afterattack(mob/user, atom/target, proximity)
	if(!isobj(target))
		return
	if (!scan_power_use())
		return
	if(driver && driver.using_scanner)
		var/data = scan_data(user, target, proximity)
		if(!data)
			return
		driver.data_buffer = data
		if(!SSnano.update_uis(driver.NM))
			holder2.run_program(driver.filename)
			driver.NM.nano_ui_interact(user)

/obj/item/weapon/computer_hardware/scanner/atmos/proc/scan_data(mob/user, atom/target, proximity = TRUE)
	if(!can_use_scanner(user, target, proximity))
		return 0
	var/air_contents = target.return_air()
	if(!air_contents)
		return 0
	var/list/raw = atmosanalyzer_scan(target, air_contents)
	return jointext(raw, "<br>")

/obj/item/weapon/computer_hardware/scanner/reagent
	name = "reagent scanner module"
	desc = "A reagent scanner module. It can scan and analyze various reagents."

/obj/item/weapon/computer_hardware/scanner/reagent/can_use_scanner(mob/user, obj/target, proximity = TRUE)
	if(!..(user, target, proximity))
		return 0
	if(!istype(target))
		return 0
	return 1

/obj/item/weapon/computer_hardware/scanner/reagent/do_on_afterattack(mob/user, obj/target, proximity)
	if(!can_use_scanner(user, target, proximity))
		return
	if (!scan_power_use())
		return
	var/dat = reagent_scan_results(target)
	if(driver && driver.using_scanner)
		driver.data_buffer = dat
		if(!SSnano.update_uis(driver.NM))
			holder2.run_program(driver.filename)
			driver.NM.nano_ui_interact(user)

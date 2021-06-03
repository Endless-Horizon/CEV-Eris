/obj/item/weapon/computer_hardware/hard_drive
	name = "basic hard drive"
	desc = "A small power efficient solid state drive for use in basic computers where power efficiency is desired."
	icon_state = "hdd_normal"
	power_usage = 25					// SSD or something with low power usage
	hardware_size = 1
	critical = TRUE
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 1, MATERIAL_GLASS = 1)
	origin_tech = list(TECH_DATA = 1, TECH_ENGINEERING = 1)
	price_tag = 50
	rarity_value = 12.5
	var/max_capacity = 128
	var/used_capacity = 0
	var/read_only = FALSE
	var/list/stored_files = list()		// List of stored files on this drive. DO NOT MODIFY DIRECTLY!
	var/list/default_files = list(		// List of files stored on this drive when spawned.
		/datum/computer_file/program/computerconfig,
		/datum/computer_file/program/downloader,
		/datum/computer_file/program/filemanager
	)


/obj/item/weapon/computer_hardware/hard_drive/advanced
	name = "advanced hard drive"
	desc = "A hybrid hard drive for use in higher grade computers where balance between power efficiency and capacity is desired."
	icon_state = "hdd_advanced"
	max_capacity = 256
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 1, MATERIAL_GLASS = 1, MATERIAL_SILVER = 2)
	origin_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 2)
	price_tag = 100
	rarity_value = 25
	power_usage = 50 					// Hybrid, medium capacity and medium power storage
	hardware_size = 2

/obj/item/weapon/computer_hardware/hard_drive/super
	name = "super hard drive"
	desc = "A hard drive for use in cluster storage solutions where capacity is more important than power efficiency."
	icon_state = "hdd_super"
	max_capacity = 512
	matter = list(MATERIAL_STEEL = 2, MATERIAL_PLASTIC = 1, MATERIAL_GLASS = 1, MATERIAL_GOLD = 2)
	origin_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 3)
	price_tag = 200
	rarity_value = 50
	power_usage = 100					// High-capacity but uses lots of power, shortening battery life. Best used with APC link.
	hardware_size = 2

/obj/item/weapon/computer_hardware/hard_drive/cluster
	name = "cluster hard drive"
	desc = "A large storage cluster consisting of multiple hard drives for usage in high capacity storage systems."
	icon_state = "hdd_cluster"
	power_usage = 500
	origin_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 4)
	price_tag = 500
	max_capacity = 2048
	matter = list(MATERIAL_STEEL = 8, MATERIAL_PLASTIC = 4, MATERIAL_GLASS = 4, MATERIAL_GOLD = 8)
	hardware_size = 3

// For tablets, etc. - highly power efficient.
/obj/item/weapon/computer_hardware/hard_drive/small
	name = "small hard drive"
	desc = "A small highly efficient solid state drive for portable devices."
	matter = list(MATERIAL_STEEL = 1, MATERIAL_PLASTIC = 1, MATERIAL_GLASS = 1)
	icon_state = "hdd_small"
	power_usage = 10
	origin_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 2)
	price_tag = 50
	rarity_value = 8.33
	max_capacity = 64
	hardware_size = 1

/obj/item/weapon/computer_hardware/hard_drive/small/adv
	name = "small advanced hard drive"
	desc = "An upgraded version of miniature hard drive used in portable devices."
	matter = list(MATERIAL_STEEL = 1, MATERIAL_PLASTIC = 1, MATERIAL_GLASS = 1, MATERIAL_SILVER = 1)
	power_usage = 20
	origin_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 3)
	price_tag = 100
	rarity_value = 16.66
	max_capacity = 128

/obj/item/weapon/computer_hardware/hard_drive/micro
	name = "micro hard drive"
	desc = "A small micro hard drive for portable devices."
	icon_state = "hdd_micro"
	power_usage = 2
	matter = list(MATERIAL_STEEL = 1, MATERIAL_GLASS = 1)
	origin_tech = list(TECH_DATA = 1, TECH_ENGINEERING = 1)
	price_tag = 25
	max_capacity = 32
	hardware_size = 1

/obj/item/weapon/computer_hardware/hard_drive/Initialize()
	. = ..()
	install_default_files()

/obj/item/weapon/computer_hardware/hard_drive/Destroy()
	stored_files = null
	return ..()

/obj/item/weapon/computer_hardware/hard_drive/examine(mob/user)
	. = ..()
	to_chat(user, SPAN_NOTICE("It can store up to [max_capacity] GQ."))

/obj/item/weapon/computer_hardware/hard_drive/diagnostics(mob/user)
	..()
	// 999 is a byond limit that is in place. It's unlikely someone will reach that many files anyway, since you would sooner run out of space.
	to_chat(user, "NT-NFS File Table Status: [stored_files.len]/999")
	to_chat(user, "Storage capacity: [used_capacity]/[max_capacity]GQ")

/obj/item/weapon/computer_hardware/hard_drive/disabled()
	..()
	holder2?.on_disk_disabled(src)

// Use this proc to add file to the drive. Returns 1 on success and 0 on failure. Contains necessary sanity checks.
/obj/item/weapon/computer_hardware/hard_drive/proc/store_file(datum/computer_file/F)
	if(!try_store_file(F))
		return FALSE
	F.holder = src
	stored_files.Add(F)
	recalculate_size()
	return TRUE

// Adds default files to the drive.
/obj/item/weapon/computer_hardware/hard_drive/proc/install_default_files()
	for(var/file_typepath in default_files)
		store_file(new file_typepath)
	return TRUE

// Use this proc to remove file from the drive. Returns 1 on success and 0 on failure. Contains necessary sanity checks.
/obj/item/weapon/computer_hardware/hard_drive/proc/remove_file(datum/computer_file/F)
	if(!F || !istype(F))
		return FALSE

	if(!stored_files)
		return FALSE

	if(read_only)
		return FALSE

	if(!check_functionality())
		return FALSE

	if(F in stored_files)
		// If removed file is a program that's currently running, kill it
		if(istype(F, /datum/computer_file/program) && holder2 && (F in holder2.all_threads))
			var/datum/computer_file/program/PRG = F
			PRG.event_file_removed()

		stored_files -= F
		recalculate_size()
		return TRUE

	return FALSE

// Loops through all stored files and recalculates used_capacity of this drive
/obj/item/weapon/computer_hardware/hard_drive/proc/recalculate_size()
	var/total_size = 0
	for(var/datum/computer_file/F in stored_files)
		total_size += F.size

	used_capacity = total_size

// Checks whether file can be stored on the hard drive.
/obj/item/weapon/computer_hardware/hard_drive/proc/can_store_file(size = 1)
	// In the unlikely event someone manages to create that many files.
	// BYOND is acting weird with numbers above 999 in loops (infinite loop prevention)

	if(!stored_files)
		return FALSE

	if(read_only || !check_functionality())
		return FALSE

	if(stored_files.len >= 999)
		return FALSE
	if(used_capacity + size > max_capacity)
		return FALSE

	return TRUE

// Checks whether we can store the file. We can only store unique files, so this checks whether we wouldn't get a duplicity by adding a file.
/obj/item/weapon/computer_hardware/hard_drive/proc/try_store_file(datum/computer_file/F)
	if(!F || !istype(F))
		return 0
	if(!can_store_file(F.size))
		return 0

	var/list/badchars = list("/",":","*","?","<",">","|", ".")
	for(var/char in badchars)
		if(findtext(F.filename, char))
			return 0

	// This file is already stored. Don't store it again.
	if(F in stored_files)
		return 0

	var/name = F.filename + "." + F.filetype
	for(var/datum/computer_file/file in stored_files)
		if((file.filename + "." + file.filetype) == name)
			return 0
	return 1

// Tries to find the file by filename. Returns null on failure
/obj/item/weapon/computer_hardware/hard_drive/proc/find_file_by_name(filename)
	if(!check_functionality())
		return null

	if(!filename)
		return null

	for(var/f in stored_files)
		var/datum/computer_file/F = f
		if(F.filename == filename)
			return F
	return null


/obj/item/weapon/computer_hardware/hard_drive/proc/find_files_by_type(typepath)
	var/list/files = list()

	if(!check_functionality())
		return files

	if(!typepath)
		return files

	for(var/f in stored_files)
		if(istype(f, typepath))
			files += f

	return files

/obj/item/weapon/computer_hardware/hard_drive/proc/get_disk_name()
	var/datum/computer_file/data/D = find_file_by_name("DISK_NAME")
	if(!istype(D))
		return null

	return sanitizeSafe(D.stored_data, max_length = MAX_LNAME_LEN)


/obj/item/weapon/computer_hardware/hard_drive/proc/set_autorun(program)
	var/datum/computer_file/data/autorun = find_file_by_name("autorun")
	if(!istype(autorun))
		autorun = new /datum/computer_file/data
		autorun.filename = "AUTORUN"
		store_file(autorun)

	autorun.stored_data = "[program]"


// Disk UI data, used by file browser UI
/obj/item/weapon/computer_hardware/hard_drive/nano_ui_data()
	var/list/data = list(
		"read_only" = read_only,
		"disk_name" = get_disk_name(),
		"max_capacity" = max_capacity,
		"used_capacity" = used_capacity
	)

	var/list/files = list()
	for(var/datum/computer_file/F in stored_files)
		files.Add(list(list(
			"filename" = F.filename,
			"filetype" = F.filetype,
			"size" = F.size,
			"undeletable" = F.undeletable
		)))
	data["files"] = files
	return data

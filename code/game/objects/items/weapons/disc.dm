/obj/item/disk
	name = "disk"
	icon = 'icons/obj/discs.dmi'
	icon_state = "data-red"
	item_state = "card-id"
	w_class = ITEM_SIZE_SMALL
	flags = CONDUCT
	force = WEAPON_FORCE_WEAK
	throwforce = WEAPON_FORCE_WEAK
	matter = list(MATERIAL_PLASTIC = 2, MATERIAL_STEEL = 1)

//The return of data disks?? Just for transferring between genetics machine/cloning machine.
//TO-DO: Make the genetics machine accept them.
/obj/item/disk/data
	name = "Cloning Data Disk"
	icon_state = "data-purple"
	var/datum/dna2/record/buf
	var/read_only = FALSE //Well,it's still a floppy disk

/obj/item/disk/data/New()
	..()
	var/diskcolor = pick("red","blue","green","purple","black")
	icon_state = "data-[diskcolor]"

/obj/item/disk/data/proc/initializeDisk()
	buf = new
	buf.dna=new

/obj/item/disk/data/attack_self(mob/user as mob)
	read_only = !read_only
	to_chat(user, "You flip the write-protect tab to [read_only ? "protected" : "unprotected"].")

/obj/item/disk/data/examine(mob/user)
	..(user)
	to_chat(user, text("The write-protect tab is set to [read_only ? "protected" : "unprotected"]."))
	return


// Subtypes

/obj/item/disk/data/demo
	name = "data disk - 'God Emperor of Mankind'"
	read_only = TRUE

/obj/item/disk/data/demo/New()
	..()
	initializeDisk()
	buf.types=DNA2_BUF_UE|DNA2_BUF_UI
	//data = "066000033000000000AF00330660FF4DB002690"
	//data = "0C80C80C80C80C80C8000000000000161FBDDEF" - Farmer Jeff
	buf.dna.real_name="God Emperor of Mankind"
	buf.dna.unique_enzymes = md5(buf.dna.real_name)
	buf.dna.UI=list(0x066,0x000,0x033,0x000,0x000,0x000,0xAF0,0x033,0x066,0x0FF,0x4DB,0x002,0x690)
	//buf.dna.UI=list(0x0C8,0x0C8,0x0C8,0x0C8,0x0C8,0x0C8,0x000,0x000,0x000,0x000,0x161,0xFBD,0xDEF) // Farmer Jeff
	buf.dna.UpdateUI()

/obj/item/disk/data/monkey
	name = "data disk - 'Mr. Muggles'"
	read_only = TRUE

/obj/item/disk/data/monkey/New()
	..()
	initializeDisk()
	buf.types=DNA2_BUF_SE
	var/list/new_SE=list(0x098,0x3E8,0x403,0x44C,0x39F,0x4B0,0x59D,0x514,0x5FC,0x578,0x5DC,0x640,0x6A4)
	for(var/i=new_SE.len;i<=DNA_SE_LENGTH;i++)
		new_SE += rand(1,1024)
	buf.dna.SE=new_SE
	buf.dna.SetSEValueRange(MONKEYBLOCK,0xDAC, 0xFFF)

/*
 *	Diskette Box
 */

/obj/item/storage/box/disks
	name = "Diskette Box"
	icon = 'icons/obj/storage/boxes.dmi'
	icon_state = "box"
	initial_amount = 7
	spawn_type = /obj/item/disk/data

/obj/item/storage/box/disks/populate_contents()
	for(var/i in 1 to initial_amount)
		new spawn_type(src)

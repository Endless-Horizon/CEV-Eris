/mob/living/silicon/robot/syndicate
	lawupdate = 0
	scrambledcodes = 1
	icon_state = "securityrobot"
	modtype = "Security"
	lawchannel = "State"
	idcard_type = /obj/item/card/id/syndicate

/mob/living/silicon/robot/syndicate/New()
	if(!cell)
		// Starts with a fancy high capacity cell
		cell = new /obj/item/cell/large/hyper(src)

	..()

/mob/living/silicon/robot/syndicate/init()
	aiCamera = new/obj/item/device/camera/siliconcam/robot_camera(src)

	laws = new /datum/ai_laws/syndicate_override
	cut_overlays()
	init_id()
	new /obj/item/robot_module/syndicate(src)

	radio.keyslot = new /obj/item/device/encryptionkey/syndicate(radio)
	radio.recalculateChannels()

	playsound(loc, 'sound/mechs/nominalsyndi.ogg', 75, 0)

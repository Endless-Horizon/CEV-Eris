/obj/item/device/radio/intercom
	name = "station intercom (General)"
	desc = "Talk through this."
	icon_state = "intercom"
	anchored = TRUE
	spawn_tags = null
	slot_flags = null
	w_class = ITEM_SIZE_BULKY
	canhear_range = 2
	flags = CONDUCT | NOBLOODY
	var/number = 0
	var/area/linked_area

/obj/item/device/radio/intercom/Initialize(mapload, ndir, building)
	. = ..()
	// if(building)
	// 	setDir(ndir)
	var/area/current_area = get_area(src)
	if(!current_area)
		return
	// GOOD FUCKING LORD DO **NOT** LOOP ADDING SIGNALS
	// todo: remove apc delete because you can just rebuild apcs
	RegisterSignal(current_area, COMSIG_AREA_APC_DELETED, .proc/on_apc_removal)
	RegisterSignal(current_area, COMSIG_AREA_APC_POWER_CHANGE, .proc/AreaPowerCheck)

/**
 * Proc called whenever the intercom's area loses or gains power. Responsible for setting the `on` variable and calling `update_icon()`.
 *
 * Normally called after the intercom's area recieves the `COMSIG_AREA_POWER_CHANGE` signal, but it can also be called directly.
 * Arguments:
 * * source - the area that just had a power change.
 */
/obj/item/device/radio/intercom/proc/AreaPowerCheck(datum/source)
	var/area/current_area = get_area(src)
	if(!current_area)
		on = FALSE
	else
		on = current_area.powered(EQUIP) // set "on" to the equipment power status of our area.

	icon_state = on ? initial(icon_state) : "intercom-p"

/obj/item/device/radio/intercom/proc/on_apc_removal()
	SIGNAL_HANDLER
	linked_area = null
	on = FALSE
	icon_state = "intercom-p"

/obj/item/device/radio/intercom/custom
	name = "station intercom (Custom)"
	broadcasting = 0
	listening = 0

/obj/item/device/radio/intercom/interrogation
	name = "station intercom (Interrogation)"
	frequency  = 1449

/obj/item/device/radio/intercom/private
	name = "station intercom (Private)"
	frequency = AI_FREQ

/obj/item/device/radio/intercom/department
	canhear_range = 5
	broadcasting = 0
	listening = 1

/obj/item/device/radio/intercom/department/medbay
	name = "station intercom (Medbay)"
	frequency = MED_I_FREQ

/obj/item/device/radio/intercom/department/security
	name = "station intercom (Security)"
	frequency = SEC_I_FREQ

/obj/item/device/radio/intercom/department/medbay/New()
	..()
	internal_channels = default_medbay_channels.Copy()

/obj/item/device/radio/intercom/department/security/New()
	..()
	internal_channels = list(
		num2text(PUB_FREQ) = list(),
		num2text(SEC_I_FREQ) = list(access_security)
	)

/obj/item/device/radio/intercom/syndicate
	name = "illicit intercom"
	desc = "Talk through this. Evilly"
	frequency = SYND_FREQ
	subspace_transmission = 1
	syndie = 1

/obj/item/device/radio/intercom/syndicate/New()
	..()
	internal_channels[num2text(SYND_FREQ)] = list(access_syndicate)

/obj/item/device/radio/intercom/attack_ai(mob/user as mob)
	src.add_fingerprint(user)
	attack_self(user)

/obj/item/device/radio/intercom/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	attack_self(user)

/obj/item/device/radio/intercom/receive_range(freq, level)
	if (!on)
		return -1
	if(!(0 in level))
		var/turf/position = get_turf(src)
		if(isnull(position) || !(position.z in level))
			return -1
	if (!src.listening)
		return -1
	if(freq in ANTAG_FREQS)
		if(!(src.syndie))
			return -1//Prevents broadcast of messages over devices lacking the encryption

	return canhear_range


/obj/item/device/radio/intercom/broadcasting
	broadcasting = 1

/obj/item/device/radio/intercom/locked
    var/locked_frequency

/obj/item/device/radio/intercom/locked/set_frequency(var/frequency)
	if(frequency == locked_frequency)
		..(locked_frequency)

/obj/item/device/radio/intercom/locked/list_channels()
	return ""

/obj/item/device/radio/intercom/locked/ai_private
	name = "\improper AI intercom"
	frequency = AI_FREQ
	broadcasting = 1
	listening = 1

/obj/item/device/radio/intercom/locked/confessional
	name = "confessional intercom"
	frequency = 1480

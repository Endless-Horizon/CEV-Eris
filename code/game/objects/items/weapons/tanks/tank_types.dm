/* Types of tanks!
 * Contains:
 *		Oxygen
 *		Anesthetic
 *		Air
 *		Plasma
 *		Emergency Oxygen
 */

/*
 * Oxygen
 */
/obj/item/tank/oxygen
	name = "oxygen tank"
	desc = "A tank of oxygen."
	icon_state = "oxygen"
	force = WEAPON_FORCE_PAINFUL
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	default_pressure = 6*ONE_ATMOSPHERE
	default_gas = "oxygen"
	slot_flags = SLOT_BACK

/obj/item/tank/oxygen/examine(mob/user)
	if(..(user, 0) && air_contents.gas["oxygen"] < 10)
		to_chat(user, text(SPAN_WARNING("The meter on \the [src] indicates you are almost out of oxygen!")))


/obj/item/tank/oxygen/red
	desc = "A tank of oxygen, this one is red."
	icon_state = "oxygen_red"

/obj/item/tank/oxygen/yellow
	desc = "A tank of oxygen, this one is yellow."
	icon_state = "oxygen_yellow"


/*
 * Anesthetic
 */
/obj/item/tank/anesthetic
	name = "anesthetic tank"
	desc = "A tank with an N2O/O2 gas mix."
	icon_state = "anesthetic"
	default_pressure = 3*ONE_ATMOSPHERE
	rarity_value = 30

/obj/item/tank/anesthetic/spawn_gas()
	air_contents.adjust_multi(
		"oxygen", default_pressure*volume/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD,
		"sleeping_agent", default_pressure*volume/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD
	)


/*
 * Air
 */
/obj/item/tank/air
	name = "air tank"
	desc = "Mixed anyone?"
	icon_state = "air"
	force = WEAPON_FORCE_PAINFUL
	default_pressure = 6*ONE_ATMOSPHERE
	slot_flags = SLOT_BACK

/obj/item/tank/air/examine(mob/user)
	if(..(user, 0) && air_contents.gas["oxygen"] < 1 && loc==user)
		to_chat(user, SPAN_DANGER("The meter on the [src.name] indicates you are almost out of air!"))
		user << sound('sound/effects/alert.ogg')

/obj/item/tank/air/spawn_gas()
	air_contents.adjust_multi(
		"oxygen", default_pressure*volume/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD,
		"nitrogen", default_pressure*volume/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD
	)



/*
 * Plasma
 */
/obj/item/tank/plasma
	name = "plasma tank"
	desc = "Contains dangerous plasma. Do not inhale. Warning: extremely flammable."
	icon_state = "plasma"
	force = WEAPON_FORCE_NORMAL
	gauge_icon = null
	flags = CONDUCT
	slot_flags = null	//they have no straps!
	default_pressure = 3*ONE_ATMOSPHERE
	default_gas = "plasma"
	rarity_value = 30


/*
 * Emergency Oxygen
 */
/obj/item/tank/emergency_oxygen
	name = "emergency oxygen tank"
	desc = "Used for emergencies. Contains very little oxygen, so try to conserve it until you actually need it."
	icon_state = "emergency"
	gauge_icon = "indicator-tank-small"
	gauge_cap = 4
	flags = CONDUCT
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_SMALL
	force = WEAPON_FORCE_NORMAL
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	default_pressure = 3*ONE_ATMOSPHERE
	default_gas = "oxygen"
	volume = 2 //Tiny. Real life equivalents only have 21 breaths of oxygen in them. They're EMERGENCY tanks anyway -errorage (dangercon 2011)
	rarity_value = 10

/obj/item/tank/emergency_oxygen/examine(mob/user)
	if(..(user, 0) && air_contents.gas["oxygen"] < 0.2 && loc==user)
		to_chat(user, text(SPAN_DANGER("The meter on the [src.name] indicates you are almost out of air!")))
		user << sound('sound/effects/alert.ogg')

/obj/item/tank/emergency_oxygen/engi
	name = "extended-capacity emergency oxygen tank"
	icon_state = "emergency_engi"
	volume = 6
	rarity_value = 20

/obj/item/tank/emergency_oxygen/double
	name = "double emergency oxygen tank"
	icon_state = "emergency_double"
	gauge_icon = "indicator-tank-double"
	volume = 10
	rarity_value = 25

/obj/item/tank/emergency_oxygen/nitrogen
	name = "emergency nitrogen tank"
	desc = "What kind of emergency would a tank of inert nitrogen prepare for?"
	icon_state = "emergency_nitrogen"
	default_pressure = 6*ONE_ATMOSPHERE
	default_gas = "nitrogen"
	rarity_value = 15

/obj/item/tank/emergency_oxygen/nitrogen/examine(mob/user)
	if(..(user, 0) && air_contents.gas["nitrogen"] < 0.2 && loc==user)
		to_chat(user, text(SPAN_DANGER("The meter on the [src.name] indicates you are almost out of nitrogen!")))
		user << sound('sound/effects/alert.ogg')

/*
 * Nitrogen
 */
/obj/item/tank/nitrogen
	name = "nitrogen tank"
	desc = "Many a death for mistaking it for a fire extinguisher."
	force = WEAPON_FORCE_PAINFUL
	icon_state = "nitrogen"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	default_pressure = 9*ONE_ATMOSPHERE
	default_gas = "nitrogen"
	rarity_value = 30

/obj/item/tank/nitrogen/examine(mob/user)
	if(..(user, 0) && air_contents.gas["nitrogen"] < 10)
		to_chat(user, text(SPAN_DANGER("The meter on \the [src] indicates you are almost out of nitrogen!")))
		//playsound(user, 'sound/effects/alert.ogg', 50, 1)

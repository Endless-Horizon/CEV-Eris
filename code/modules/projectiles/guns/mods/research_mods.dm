// 	 EXPERIMENTAL WEAPON MODS
//------------------------------------------------

//Increases penetration multiplier, projectile speed. Increases fire delay. Acquired via science
/obj/item/gun_upgrade/barrel/mag_accel
	name = "Moebius \"Penetrator\" magnetic accelerator barrel"
	desc = "Uses sympathetic magnetic coiling to increase exit velocity of a metal projectile."
	icon_state = "Penetrator"
	matter = list(MATERIAL_PLASTIC = 2, MATERIAL_PLASTEEL = 1, MATERIAL_GOLD = 1)
	rarity_value = 30
	spawn_blacklisted = TRUE

/obj/item/gun_upgrade/barrel/mag_accel/New()
	..()
	var/datum/component/item_upgrade/I = AddComponent(/datum/component/item_upgrade)
	I.weapon_upgrades = list(
		GUN_UPGRADE_PEN_MULT = 1.2,
		GUN_UPGRADE_STEPDELAY_MULT = 0.8,
		GUN_UPGRADE_FIRE_DELAY_MULT = 1.5
		)
	I.gun_loc_tag = GUN_BARREL
	I.req_gun_tags = list(GUN_PROJECTILE)


//Adds +10 burn damage to a bullet, lowers armor penetration, adds a constant projectile offset, increases recoil and fire delay. Acquired via science
/obj/item/gun_upgrade/barrel/overheat
	name = "Moebius \"Caster\" magnetic overheat barrel"
	desc = "Uses magnetic induction to heat the projectile of a weapon. Arguable combat effectiveness, but flashy nonetheless."
	icon_state = "Caster"
	matter = list(MATERIAL_PLASTIC = 2, MATERIAL_PLASTEEL = 1, MATERIAL_GOLD = 1)
	rarity_value = 30
	spawn_blacklisted = TRUE

/obj/item/gun_upgrade/barrel/overheat/New()
	..()
	var/datum/component/item_upgrade/I = AddComponent(/datum/component/item_upgrade)
	I.weapon_upgrades = list(
		GUN_UPGRADE_PEN_MULT = 0.8,
		GUN_UPGRADE_DAMAGE_BURN = 10,
		GUN_UPGRADE_OFFSET = 5,
		GUN_UPGRADE_RECOIL = 1.5,
		GUN_UPGRADE_FIRE_DELAY_MULT = 1.2
		)
	I.gun_loc_tag = GUN_BARREL
	I.req_gun_tags = list(GUN_PROJECTILE)


// Double damage at the cost of more recoil and a tripled energy consumption
/obj/item/gun_upgrade/mechanism/battery_shunt
	name = "Moebius \"Thunder\" battery shunt"
	desc = "This experimental battery shunt is a cutting edge tool attachment which bypasses battery protection circuits to deliver the maximum amount of power in the shortest amount of time."
	icon_state = "battery_shunt"
	matter = list(MATERIAL_PLASTIC = 2, MATERIAL_PLASTEEL = 1, MATERIAL_GOLD = 1, MATERIAL_URANIUM = 1)
	spawn_blacklisted = TRUE

/obj/item/gun_upgrade/mechanism/battery_shunt/New()
	..()
	var/datum/component/item_upgrade/I = AddComponent(/datum/component/item_upgrade)
	I.weapon_upgrades = list(
	GUN_UPGRADE_RECOIL = 1.2,
	GUN_UPGRADE_DAMAGE_MULT = 1.5,
	GUN_UPGRADE_CHARGECOST = 3)
	I.req_fuel_cell = REQ_CELL
	I.gun_loc_tag = GUN_MECHANISM

// Greatly increase firerate at the cost of lower damage
/obj/item/gun_upgrade/mechanism/overdrive
	name = "Moebius \"Tesla\" overdrive chip"
	desc = "This experimental chip is a cutting edge tool attachment which bypasses power management protocols to dramatically increase the rate of fire at the cost of a reduced stopping power."
	icon_state = "overdrive"
	matter = list(MATERIAL_PLASTIC = 2, MATERIAL_PLASTEEL = 1, MATERIAL_GOLD = 1, MATERIAL_URANIUM = 1)
	spawn_blacklisted = TRUE

/obj/item/gun_upgrade/mechanism/overdrive/New()
	..()
	var/datum/component/item_upgrade/I = AddComponent(/datum/component/item_upgrade)
	I.weapon_upgrades = list(
	GUN_UPGRADE_RECOIL = 1.2,
	GUN_UPGRADE_DAMAGE_MULT = 0.20,
	GUN_UPGRADE_AGONY_MULT = 0.2,
	GUN_UPGRADE_FIRE_DELAY_MULT = 0.25,
	GUN_UPGRADE_FULLAUTO = TRUE,
	GUN_UPGRADE_CHARGECOST = 0.15,
	GUN_UPGRADE_FIRE_DELAY_MULT = 0.25)
	I.req_fuel_cell = REQ_CELL
	I.gun_loc_tag = GUN_MECHANISM

// Add toxin damage to your weapon
/obj/item/gun_upgrade/barrel/toxin_coater
	name = "Moebius \"Black Mamba\" toxin coater"
	desc = "This experimental barrel coats bullets with a thin layer of toxins just before they leave the weapon. Do not lick it."
	icon_state = "toxin_coater"
	matter = list(MATERIAL_PLASTIC = 2, MATERIAL_PLASTEEL = 1, MATERIAL_GOLD = 2)
	spawn_blacklisted = TRUE

/obj/item/gun_upgrade/barrel/toxin_coater/New()
	..()
	var/datum/component/item_upgrade/I = AddComponent(/datum/component/item_upgrade)
	I.weapon_upgrades = list(
	GUN_UPGRADE_DAMAGE_TOX = 5)
	I.req_gun_tags = list(GUN_PROJECTILE)
	I.gun_loc_tag = GUN_BARREL

// Add radiation damage to your weapon
/obj/item/gun_upgrade/barrel/isotope_diffuser
	name = "Moebius \"Atomik\" isotope diffuser"
	desc = "This experimental barrel constantly sprays a thin mist of radioactive isotopes to make projectiles leaving the weapons deadlier. Do not put it in your mouth."
	icon_state = "isotope_diffuser"
	matter = list(MATERIAL_PLASTIC = 2, MATERIAL_PLASTEEL = 1, MATERIAL_URANIUM = 2)
	spawn_blacklisted = TRUE

/obj/item/gun_upgrade/barrel/isotope_diffuser/New()
	..()
	var/datum/component/item_upgrade/I = AddComponent(/datum/component/item_upgrade)
	I.weapon_upgrades = list(
	GUN_UPGRADE_DAMAGE_RADIATION = 30)
	I.req_gun_tags = list(GUN_PROJECTILE)
	I.gun_loc_tag = GUN_BARREL

// Add psy damage to your weapon
/obj/item/gun_upgrade/mechanism/psionic_catalyst
	name = "Moebius \"Mastermind\" psionic catalyst"
	desc = "This controversial device greatly amplifies the natural psionic ability of the user and allows them to project their will into the world. Before the development of the Psi Amp, psionic disciplines were mostly detectable only in a lab environment."
	icon_state = "psionic_catalyst"
	matter = list(MATERIAL_SILVER = 3, MATERIAL_PLASTEEL = 3, MATERIAL_URANIUM = 3)
	spawn_blacklisted = TRUE

/obj/item/gun_upgrade/mechanism/psionic_catalyst/New()
	..()
	var/datum/component/item_upgrade/I = AddComponent(/datum/component/item_upgrade)
	I.weapon_upgrades = list(
	GUN_UPGRADE_DAMAGE_PSY = 0.4)
	I.req_gun_tags = list(GUN_PROJECTILE)
	I.gun_loc_tag = GUN_MECHANISM

/obj/item/gun_upgrade/barrel/gauss
	name = "Syndicate \"Gauss Coil\" barrel"
	desc = "Make bullet pierce through wall and penetrate armors easily, but losing rate of fire and increece recoil."
	icon_state = "Gauss"
	spawn_blacklisted = TRUE

/obj/item/gun_upgrade/barrel/gauss/New()
	..()
	var/datum/component/item_upgrade/I = AddComponent(/datum/component/item_upgrade)
	I.weapon_upgrades = list(
		GUN_UPGRADE_DAMAGE_BRUTE = 5,
		GUN_UPGRADE_STEPDELAY_MULT = 0.8,
		GUN_UPGRADE_PEN_MULT = 1.3,
		GUN_UPGRADE_PIERC_MULT = 1,
		GUN_UPGRADE_FIRE_DELAY_MULT = 1.4,
		GUN_UPGRADE_RECOIL = 1.4
		)
	I.removal_time *= 10
	I.gun_loc_tag = GUN_BARREL
	I.req_gun_tags = list(GUN_PROJECTILE)


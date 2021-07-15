//*****************
//**Cham Jumpsuit**
//*****************

/obj/item/proc/disguise(newtype, mob/user)
	if(!user || user.incapacitated())
		return
	//this is necessary, unfortunately, as initial() does not play well with list vars
	var/obj/item/copy = new newtype(null) //so that it is GCed once we exit

	desc = copy.desc
	name = copy.name
	icon = copy.icon
	icon_state = copy.icon_state
	item_state = copy.item_state
	body_parts_covered = copy.body_parts_covered

	item_icons = copy.item_icons.Copy()
	item_state_slots = copy.item_state_slots.Copy()
	//copying sprite_sheets_obj should be unnecessary as chameleon items are not refittable.
	update_wear_icon()

	return copy //for inheritance

/proc/generate_chameleon_choices(basetype, blacklist=list())
	. = list()

	var/i = 1 //in case there is a collision with both name AND icon_state
	for(var/typepath in typesof(basetype) - blacklist)
		var/obj/O = typepath
		if(initial(O.icon) && initial(O.icon_state))
			var/name = initial(O.name)
			if(name in .)
				name += " ([initial(O.icon_state)])"
			if(name in .)
				name += " \[[i++]\]"
			.[name] = typepath

/obj/item/clothing/under/chameleon
//starts off as black
	name = "black jumpsuit"
	desc = "It's a plain jumpsuit. It seems to have a small dial on the wrist."
	icon_state = "black"
	item_state = "bl_suit"
	spawn_blacklisted = TRUE
	spawn_tags = SPAWN_TAG_CLOTHING_UNDER_CHAMALEON

	origin_tech = list(TECH_COVERT = 3)
	var/global/list/clothing_choices

/obj/item/clothing/under/chameleon/New()
	..()
	if(!clothing_choices)
		clothing_choices = generate_chameleon_choices(/obj/item/clothing/under)

/obj/item/clothing/under/chameleon/emp_act(severity)
	name = "psychedelic"
	desc = "Groovy!"
	icon_state = "psyche"
	item_state_slots[slot_w_uniform_str] = "psyche"
	update_icon()
	update_wear_icon()

/obj/item/clothing/under/chameleon/verb/change(picked in clothing_choices)
	set name = "Change Jumpsuit Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)

//*****************
//**Chameleon Hat**
//*****************

/obj/item/clothing/head/chameleon
	name = "grey cap"
	icon_state = "greysoft"
	desc = "It looks like a plain hat, but upon closer inspection, there's an advanced holographic array installed inside. It seems to have a small dial inside."
	origin_tech = list(TECH_COVERT = 3)
	body_parts_covered = 0
	spawn_blacklisted = TRUE
	spawn_tags = SPAWN_TAG_CLOTHING_HEAD_CHAMALEON
	var/global/list/clothing_choices

/obj/item/clothing/head/chameleon/New()
	..()
	if(!clothing_choices)
		var/blocked = list(src.type, /obj/item/clothing/head/justice,)//Prevent infinite loops and bad hats.
		clothing_choices = generate_chameleon_choices(/obj/item/clothing/head, blocked)

/obj/item/clothing/head/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey colour."
	icon_state = "greysoft"
	update_icon()
	update_wear_icon()

/obj/item/clothing/head/chameleon/verb/change(picked in clothing_choices)
	set name = "Change Hat/Helmet Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)

//******************
//**Chameleon Suit**
//******************

/obj/item/clothing/suit/chameleon
	name = "armor"
	icon_state = "armor"
	item_state = "armor"
	desc = "It appears to be a vest of standard armor, except this is embedded with a hidden holographic cloaker, allowing it to change it's appearance, but offering no protection.. It seems to have a small dial inside."
	origin_tech = list(TECH_COVERT = 3)
	spawn_blacklisted = TRUE
	var/global/list/clothing_choices

/obj/item/clothing/suit/chameleon/New()
	..()
	if(!clothing_choices)
		var/blocked = list(src.type, null)
		clothing_choices = generate_chameleon_choices(/obj/item/clothing/suit, blocked)

/obj/item/clothing/suit/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "armor"
	desc = "An armored vest that protects against some damage."
	icon_state = "armor"
	update_icon()
	update_wear_icon()

/obj/item/clothing/suit/chameleon/verb/change(picked in clothing_choices)
	set name = "Change Oversuit Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)

//*******************
//**Chameleon Shoes**
//*******************
/obj/item/clothing/shoes/chameleon
	name = "black shoes"
	icon_state = "black"
	item_state = "black"
	desc = "They're comfy black shoes, with clever cloaking technology built in. It seems to have a small dial on the back of each shoe."
	origin_tech = list(TECH_COVERT = 3)
	spawn_blacklisted = TRUE
	spawn_tags = SPAWN_TAG_SHOES_CHAMALEON
	var/global/list/clothing_choices

/obj/item/clothing/shoes/chameleon/New()
	..()
	if(!clothing_choices)
		var/blocked = list(src.type, /obj/item/clothing/shoes/syndigaloshes, /obj/item/clothing/shoes/cyborg)//prevent infinite loops and bad shoes.
		clothing_choices = generate_chameleon_choices(/obj/item/clothing/shoes, blocked)

/obj/item/clothing/shoes/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "black shoes"
	desc = "A pair of black shoes."
	icon_state = "black"
	item_state = "black"
	update_icon()
	update_wear_icon()

/obj/item/clothing/shoes/chameleon/verb/change(picked in clothing_choices)
	set name = "Change Footwear Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)

//**********************
//**Chameleon Backpack**
//**********************
/obj/item/storage/backpack/chameleon
	name = "grey backpack"
	icon_state = "backpack"
	item_state = "backpack"
	desc = "A backpack outfitted with cloaking tech. It seems to have a small dial inside, kept away from the storage."
	origin_tech = list(TECH_COVERT = 3)
	spawn_blacklisted = TRUE
	spawn_tags = SPAWN_TAG_BACKPACK_CHAMALEON
	rarity_value = 50
	var/global/list/clothing_choices

/obj/item/storage/backpack/chameleon/Initialize()
	. = ..()
	if(!clothing_choices)
		var/blocked = list(src.type, /obj/item/storage/backpack/satchel/leather/withwallet)
		clothing_choices = generate_chameleon_choices(/obj/item/storage/backpack, blocked)

/obj/item/storage/backpack/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "grey backpack"
	desc = "A backpack outfitted with cloaking tech. It seems to have a small dial inside, kept away from the storage."
	icon_state = "backpack"
	item_state = "backpack"
	update_icon()
	update_wear_icon()

/obj/item/storage/backpack/chameleon/verb/change(picked in clothing_choices)
	set name = "Change Backpack Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)

//********************
//**Chameleon Gloves**
//********************

/obj/item/clothing/gloves/chameleon
	name = "black gloves"
	icon_state = "black"
	item_state = "bgloves"
	desc = "It looks like a pair of gloves, but it seems to have a small dial inside."
	origin_tech = list(TECH_COVERT = 3)
	spawn_blacklisted = TRUE
	spawn_tags = SPAWN_TAG_GLOVES_CHAMALEON
	var/global/list/clothing_choices

/obj/item/clothing/gloves/chameleon/New()
	..()
	if(!clothing_choices)
		clothing_choices = generate_chameleon_choices(/obj/item/clothing/gloves, list(src.type))

/obj/item/clothing/gloves/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "black gloves"
	desc = "It looks like a pair of gloves, but it seems to have a small dial inside."
	icon_state = "black"
	update_icon()
	update_wear_icon()

/obj/item/clothing/gloves/chameleon/verb/change(picked in clothing_choices)
	set name = "Change Gloves Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)

//******************
//**Chameleon Mask**
//******************

/obj/item/clothing/mask/chameleon
	name = "gas mask"
	icon_state = "gas_alt"
	item_state = "gas_alt"
	desc = "It looks like a plain gask mask, but on closer inspection, it seems to have a small dial inside."
	origin_tech = list(TECH_COVERT = 3)
	spawn_blacklisted = TRUE
	spawn_tags = SPAWN_TAG_MASK_CONTRABAND
	flags_inv = HIDEEYES|HIDEFACE
	var/global/list/clothing_choices

/obj/item/clothing/mask/chameleon/New()
	..()
	if(!clothing_choices)
		clothing_choices = generate_chameleon_choices(/obj/item/clothing/mask, list(src.type))

/obj/item/clothing/mask/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "gas mask"
	desc = "It's a gas mask."
	icon_state = "gas_alt"
	update_icon()
	update_wear_icon()

/obj/item/clothing/mask/chameleon/verb/change(picked in clothing_choices)
	set name = "Change Mask Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)

//*********************
//**Chameleon Glasses**
//*********************

/obj/item/clothing/glasses/chameleon
	name = "Optical Meson Scanner"
	icon_state = "meson"
	item_state = "glasses"
	desc = "It looks like a plain set of mesons, but on closer inspection, it seems to have a small dial inside."
	origin_tech = list(TECH_COVERT = 3)
	spawn_blacklisted = TRUE
	spawn_tags = SPAWN_TAG_GLASSES_CHAMALEON
	var/list/global/clothing_choices

/obj/item/clothing/glasses/chameleon/New()
	..()
	if(!clothing_choices)
		clothing_choices = generate_chameleon_choices(/obj/item/clothing/glasses, list(src.type))

/obj/item/clothing/glasses/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "Optical Meson Scanner"
	desc = "It's a set of mesons."
	icon_state = "meson"
	update_icon()
	update_wear_icon()

/obj/item/clothing/glasses/chameleon/verb/change(picked in clothing_choices)
	set name = "Change Glasses Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(!ispath(clothing_choices[picked]))
		return

	disguise(clothing_choices[picked], usr)

//*****************
//**Chameleon Gun**
//*****************
/obj/item/gun/energy/chameleon
	name = "FS HG .40 Magnum \"Avasarala\""
	desc = "A hologram projector in the shape of a gun. There is a dial on the side to change the gun's disguise."
	icon = 'icons/obj/guns/projectile/avasarala.dmi'
	icon_state = "avasarala"
	w_class = ITEM_SIZE_NORMAL
	spawn_blacklisted = TRUE
	spawn_tags = SPAWN_TAG_GUN_ENERGY_CHAMALEON
	rarity_value = 25
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2, TECH_COVERT = 2)
	matter = list()

	fire_sound = 'sound/weapons/Gunshot.ogg'
	projectile_type = /obj/item/projectile/chameleon
	charge_meter = 0
	charge_cost = 20 //uses next to no power, since it's just holograms

	var/obj/item/projectile/copy_projectile
	var/global/list/gun_choices

/obj/item/gun/energy/chameleon/New()
	..()

	if(!gun_choices)
		gun_choices = list()
		for(var/gun_type in typesof(/obj/item/gun/) - src.type)
			var/obj/item/gun/G = gun_type
			src.gun_choices[initial(G.name)] = gun_type

/obj/item/gun/energy/chameleon/consume_next_projectile()
	var/obj/item/projectile/P = ..()
	if(P && ispath(copy_projectile))
		P.name = initial(copy_projectile.name)
		P.icon = initial(copy_projectile.icon)
		P.icon_state = initial(copy_projectile.icon_state)
		P.pass_flags = initial(copy_projectile.pass_flags)
		P.hitscan = initial(copy_projectile.hitscan)
		P.step_delay = initial(copy_projectile.step_delay)
		P.muzzle_type = initial(copy_projectile.muzzle_type)
		P.tracer_type = initial(copy_projectile.tracer_type)
		P.impact_type = initial(copy_projectile.impact_type)
	return P

/obj/item/gun/energy/chameleon/emp_act(severity)
	name = "FS HG .40 Magnum \"Avasarala\""
	desc = "A hologram projector in the shape of a gun. There is a dial on the side to change the gun's disguise."
	icon_state = "avasarala"
	update_icon()
	update_wear_icon()

/obj/item/gun/energy/chameleon/disguise(newtype)
	var/obj/item/gun/copy = ..()

	flags_inv = copy.flags_inv
	fire_sound = copy.fire_sound
	fire_sound_text = copy.fire_sound_text

	var/obj/item/gun/energy/E = copy
	if(istype(E))
		copy_projectile = E.projectile_type
		//charge_meter = E.charge_meter //does not work very well with icon_state changes, ATM
	else
		copy_projectile = null
		//charge_meter = 0

/obj/item/gun/energy/chameleon/verb/change(picked in gun_choices)
	set name = "Change Gun Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(!ispath(gun_choices[picked]))
		return

	disguise(gun_choices[picked], usr)

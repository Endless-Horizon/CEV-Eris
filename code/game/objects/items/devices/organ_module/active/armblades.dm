/obj/item/tool/armblade
	icon_state = "armblade"
	item_state = null
	name = "armblade"
	desc = "A mechanical blade deployed from your arm. The favourite hidden weapon of many criminal types."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "armblade"
	worksound = WORKSOUND_HARD_SLASH
	force = WEAPON_FORCE_DANGEROUS
	throwforce = WEAPON_FORCE_WEAK
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("stabbed", "chopped", "cut")
	armor_penetration = ARMOR_PEN_MODERATE
	tool_qualities = list(QUALITY_CUTTING = 20)
	spawn_blacklisted = TRUE

/obj/item/organ_module/active/simple/armblade
	name = "embedded armblade"
	desc = "A mechanical blade designed to be inserted into an arm. Gives you a nice advantage in a brawl."
	verb_name = "Deploy armblade"
	icon_state = "armblade"
	matter = list(MATERIAL_STEEL = 16)
	allowed_organs = list(BP_R_ARM, BP_L_ARM)
	holding_type = /obj/item/tool/armblade


/obj/item/tool/armblade/claws
	icon_state = "wolverine"
	name = "claws"
	desc = "A set of claws deployed from the tips of your fingers. Great for cutting people into ribbons."

/obj/item/organ_module/active/simple/wolverine
	name = "embedded claws"
	desc = "A variant on the popular armblade, these claws allow for a more traditional unarmed brawl style while still mantaining your advantage."
	verb_name = "Deploy embedded claws"
	icon_state = "wolverine"
	allowed_organs = list(BP_R_ARM, BP_L_ARM)
	holding_type = /obj/item/tool/armblade/claws

/obj/item/organ_module/active/simple/armblade/energy_blade
	name = "energy armblade"
	desc = "A energy blade designed to be inserted into an arm. Gives you a nice advantage in a brawl."
	verb_name = "Deploy energyblade"
	icon_state = "energyblade"
	origin_tech = list(TECH_MAGNET = 3, TECH_COVERT = 4)
	holding_type = /obj/item/melee/energy/blade/organ_module

/obj/item/organ_module/active/simple/armblade/energy_blade/deploy(mob/living/carbon/human/H, obj/item/organ/external/E)
	..()
	playsound(H.loc, 'sound/weapons/saberon.ogg', 50, 1)

/obj/item/organ_module/active/simple/armblade/energy_blade/retract(mob/living/carbon/human/H, obj/item/organ/external/E)
	..()
	playsound(H.loc, 'sound/weapons/saberoff.ogg', 50, 1)
